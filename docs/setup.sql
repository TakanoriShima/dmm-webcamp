CREATE DATABASE todolist;
CREATE DATABASE booklist default character set utf8;
CREATE TABLE booklist.books (
    id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    book_title VARCHAR(100),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO booklist.books (book_title) VALUES("非エンジニアのためのプログラミング講座");
INSERT INTO booklist.books (book_title) VALUES("プログラミングPHP");
INSERT INTO booklist.books (book_title) VALUES("入門HTML5");