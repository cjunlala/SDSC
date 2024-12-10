BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "book" (
	"bid"	INTEGER NOT NULL,
	"bname"	TEXT NOT NULL,
	"authors"	TEXT NOT NULL,
	"publish_date"	TEXT NOT NULL,
	"publish"	TEXT NOT NULL,
	"price"	INTEGER NOT NULL,
	"remain"	INTEGER NOT NULL,
	"stock "	INTEGER NOT NULL,
	"type_id"	TEXT NOT NULL,
	PRIMARY KEY("bid"),
	FOREIGN KEY("type_id") REFERENCES "type"("tid")
);
CREATE TABLE IF NOT EXISTS "lend_return" (
	"id"	INTEGER NOT NULL,
	"student_id"	INTEGER NOT NULL,
	"book_id"	INTEGER NOT NULL,
	"lend_date"	TEXT NOT NULL,
	"return_date"	TEXT DEFAULT NULL,
	"keep_lending"	INTEGER,
	"lend_number"	INTEGER NOT NULL,
	"return_number"	INTEGER NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("book_id") REFERENCES "book"("bid"),
	FOREIGN KEY("student_id") REFERENCES "student"("sid")
);
CREATE TABLE IF NOT EXISTS "record" (
	"rid"	INTEGER NOT NULL,
	"date"	TEXT NOT NULL,
	"comment"	TEXT,
	"student_id"	INTEGER NOT NULL,
	PRIMARY KEY("rid" AUTOINCREMENT),
	FOREIGN KEY("student_id") REFERENCES "student"("sid")
);
CREATE TABLE IF NOT EXISTS "rules" (
	"rid"	INTEGER NOT NULL,
	"student_id"	INTEGER NOT NULL,
	"book_id"	INTEGER NOT NULL,
	"overdue_days"	INTEGER NOT NULL,
	"books_num"	INTEGER NOT NULL,
	"penalty"	INTEGER NOT NULL,
	PRIMARY KEY("rid" AUTOINCREMENT),
	FOREIGN KEY("book_id") REFERENCES "book"("bid"),
	FOREIGN KEY("student_id") REFERENCES "student"("sid")
);
CREATE TABLE IF NOT EXISTS "student" (
	"sid"	INTEGER NOT NULL,
	"sname"	TEXT NOT NULL,
	"ssex"	INTEGER NOT NULL,
	"sphone"	TEXT NOT NULL,
	PRIMARY KEY("sid" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "type" (
	"tid"	INTEGER NOT NULL,
	"tname"	TEXT NOT NULL,
	PRIMARY KEY("tid" AUTOINCREMENT)
);
INSERT INTO "book" ("bid","bname","authors","publish_date","publish","price","remain","stock ","type_id") VALUES (1,'The Old Man and the Sea','Ernest Hemingway','2002','Charles Scribner''s Sons',69,3,4,'1'),
 (2,'Wuthering Heights','Emily Bronte','1999','Thomas Cautley Newby',45,3,5,'1'),
 (3,'The Little Prince','Antoine de Saint-Exupéry','2018','Harcourt Brace Jovanovich',59,0,1,'3');
INSERT INTO "lend_return" ("id","student_id","book_id","lend_date","return_date","keep_lending","lend_number","return_number") VALUES (1,4,3,'02/11/2024','NULL',0,1,0),
 (2,2,1,'24/11/2024','NULL',0,1,0),
 (3,1,2,'27/10/2024','NULL',1,1,0),
 (4,3,2,'01/12/2024','NULL',0,1,0),
 (5,4,1,'31/08/2024','02/09/2024',0,1,1),
 (6,1,3,'27/09/2024','10/10/2024',0,1,1);
INSERT INTO "record" ("rid","date","comment","student_id") VALUES (1,'02/11/2024','borrow',4),
 (2,'24/11/2024','borrow',2),
 (3,'27/10/2024','borrow',1),
 (4,'01/12/2024','borrow',3),
 (5,'31/08/2024','borrow',4),
 (6,'02/09/2024','return',4),
 (7,'27/09/2024','borrow',1),
 (8,'10/10/2024','return',1);
INSERT INTO "rules" ("rid","student_id","book_id","overdue_days","books_num","penalty") VALUES (1,4,3,3,1,6);
INSERT INTO "student" ("sid","sname","ssex","sphone") VALUES (1,'Moses Chan Ho',0,'6014 3258'),
 (2,'Fala Chen',1,'9690 4754'),
 (3,'Kathy Chow Hoi - mei',1,'3153 1368'),
 (4,'William So Wing - hong',0,'5714 7910');
INSERT INTO "type" ("tid","tname") VALUES (1,'novel'),
 (2,'science'),
 (3,'juvenile literature');
COMMIT;

----trigger
--借书后存书量减
CREATE TRIGGER lend_num_mins
AFTER INSERT ON lend_return
BEGIN
    UPDATE book
    SET remain = remain - NEW.lend_number
    WHERE bid = NEW.book_id;
END;

--还书后存书量加
CREATE TRIGGER return_num_add
AFTER UPDATE ON lend_return
BEGIN
    UPDATE book
    SET remain = remain + NEW.return_number
    WHERE bid = NEW.book_id;
END;

--借书前检查库存
CREATE TRIGGER check_remain_before_update
BEFORE INSERT ON lend_return
BEGIN
    -- CHECK
    SELECT CASE
        WHEN (SELECT remain FROM book WHERE bid = NEW.book_id) < 1 THEN
            RAISE(FAIL, 'The inventory is 0, and the book cannot be borrowed.')
    END;
END;

--逾期记录插入逾期表
CREATE TRIGGER handle_overdue
AFTER UPDATE ON lend_return
WHEN  (JULIANDAY(strftime('%Y-%m-%d',
                 substr(NEW.return_date, 7, 4) || '-' ||
                 substr(NEW.return_date, 4, 2) || '-' ||
                 substr(NEW.return_date, 1, 2)) )-JULIANDAY(strftime('%Y-%m-%d',
                 substr(NEW.lend_date, 7, 4) || '-' ||
                 substr(NEW.lend_date, 4, 2) || '-' ||
                 substr(NEW.lend_date, 1, 2)) )) > 30
BEGIN
    INSERT INTO rules (student_id, book_id, overdue_days, books_num, penalty)
    SELECT
        NEW.student_id,
        NEW.book_id,
        CAST((JULIANDAY(strftime('%Y-%m-%d',
                 substr(NEW.return_date, 7, 4) || '-' ||
                 substr(NEW.return_date, 4, 2) || '-' ||
                 substr(NEW.return_date, 1, 2)) )-JULIANDAY(strftime('%Y-%m-%d',
                 substr(NEW.lend_date, 7, 4) || '-' ||
                 substr(NEW.lend_date, 4, 2) || '-' ||
                 substr(NEW.lend_date, 1, 2)) )) AS INTEGER) - 30 AS overdue_days,
        NEW.lend_number,
        (CAST((JULIANDAY(strftime('%Y-%m-%d',
                 substr(NEW.return_date, 7, 4) || '-' ||
                 substr(NEW.return_date, 4, 2) || '-' ||
                 substr(NEW.return_date, 1, 2)) )-JULIANDAY(strftime('%Y-%m-%d',
                 substr(NEW.lend_date, 7, 4) || '-' ||
                 substr(NEW.lend_date, 4, 2) || '-' ||
                 substr(NEW.lend_date, 1, 2)) )) AS INTEGER) - 30) * NEW.lend_number * 0.01;
END


--借书记录插入记录表
CREATE TRIGGER insert_record_lend
AFTER INSERT ON lend_return
BEGIN
    -- insert record
    INSERT INTO record (date, comment, student_id)
    VALUES (
        NEW.lend_date,
        'borrow',
        NEW.student_id
    );
END;


--还书记录插入记录表
CREATE TRIGGER insert_record_return
AFTER UPDATE ON lend_return
BEGIN
    -- insert record
    INSERT INTO record (date, comment, student_id)
    VALUES (
        NEW.return_date,
        'return',
        NEW.student_id
    );
END;

--图书库存量视图
CREATE VIEW v_book
AS
SELECT bid , bname, remain
FROM book


-----video test
-- a new student
INSERT INTO student ("sname","ssex","sphone")
VALUES ('Anna',0,'5894 7000')

select * from student

--A new book
INSERT INTO book ("bid","bname","authors","publish_date","publish","price","remain","stock ","type_id")
VALUES (4,'Database Management Systems','Raghu Ramakrishnan','2003','McGraw-Hili',139,4,4,'2')
--check the inventory
select * from v_book

--check anna's record table
select * from record where student_id=5
--check the rules table
select * from rules where student_id=5

--anna lend a book "The Old Man and the Sea" at 2024.11.02
 INSERT INTO lend_return  ("student_id","book_id","lend_date","return_date","keep_lending","lend_number","return_number")
VALUES (5,1,'02/11/2024',NULL,0,1,0)

--recheck the inventory
select * from v_book

--anna want to lend the book "The Little Prince", and found there is no remain
INSERT INTO lend_return ("student_id","book_id","lend_date","return_date","keep_lending","lend_number","return_number")
VALUES (5,3,'02/12/2024',NULL,0,1,0)

--Anna borrowed the book 'Database Management Systems' to help her learn the database course
INSERT INTO lend_return ("student_id","book_id","lend_date","return_date","keep_lending","lend_number","return_number")
VALUES (5,4,'02/12/2024',NULL,0,1,0)
--recheck the inventory
select * from v_book

--Anna return the "The Old Man and the Sea" at 2024.12.08 and found it was overdue
UPDATE lend_return
set return_date='08/12/2024', return_number = 1
where student_id = 5 and book_id = 1
--recheck the inventory
select * from v_book

--recheck anna's record table
select * from record where student_id=5
--recheck the rules table
select * from rules where student_id=5


