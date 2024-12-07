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
	"studen_id"	INTEGER NOT NULL,
	PRIMARY KEY("rid" AUTOINCREMENT),
	FOREIGN KEY("studen_id") REFERENCES "student"("sid")
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
INSERT INTO "record" ("rid","date","comment","studen_id") VALUES (1,'02/11/2024','borrow',4),
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
