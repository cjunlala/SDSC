--借书后存书量减
CREATE TRIGGER lend_num_mins
AFTER INSERT ON lend_return
WHEN NEW.return_date is null
BEGIN
    UPDATE book
    SET remain = remain - NEW.lend_number
    WHERE bid = NEW.book_id;
END;

--还书后存书量加
CREATE TRIGGER return_num_add
BEFORE UPDATE ON lend_return
WHEN OLD.return_date IS NULL AND NEW.return_date IS NOT NULL
BEGIN
    UPDATE book
    SET remain = remain + NEW.return_number
    WHERE bid = NEW.book_id;
END;

--借书前检查库存
CREATE TRIGGER check_remain_before_update
BEFORE UPDATE ON lend_return
BEGIN
    -- CHECK
    SELECT CASE
        WHEN (SELECT remain FROM book WHERE bid = NEW.book_id) < 1 THEN
            RAISE(FAIL, 'The inventory is 0, and the book cannot be borrowed.')
    END;
END;

--逾期记录插入逾期表
CREATE TRIGGER handle_overdue
BEFORE UPDATE ON lend_return
WHEN OLD.return_date IS NULL
  AND NEW.return_date IS NOT NULL
  AND (JULIANDAY(NEW.return_date) - JULIANDAY(NEW.lend_date)) > 30
BEGIN
    INSERT INTO rules (student_id, book_id, overdue_days, books_num, penalty)
    SELECT
        NEW.student_id,
        NEW.book_id,
        CAST((JULIANDAY(NEW.return_date) - JULIANDAY(NEW.lend_date)) AS INTEGER) - 30 AS overdue_days,
        NEW.lend_number,
        (CAST((JULIANDAY(NEW.return_date) - JULIANDAY(NEW.lend_date)) AS INTEGER) - 30) * NEW.lend_number * 0.01;
END;

--借还书记录插入记录表
CREATE TRIGGER insert_record
BEFORE UPDATE ON lend_return
BEGIN
    -- insert record
    INSERT INTO record (date, comment, student_id)
    VALUES (
        DATETIME('now'),
        CASE
            WHEN NEW.return_date IS NULL THEN 'borrow'
            ELSE 'return'
        END,
        NEW.student_id
    );
END;