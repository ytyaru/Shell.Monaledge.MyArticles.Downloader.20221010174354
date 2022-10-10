PRAGMA foreign_keys=true;
create table if not exists articles(
    id integer not null primary key,
    --article_id integer not null unique,
    created text not null,
    updated text not null,
    title text not null,
    --sent_mona decimal not null,
    --sent_mona integer not null,
    sent_mona text not null,
    access integer not null,
    ogp_path text not null,
    category integer not null,
    content text
);
create table if not exists comments(
    id integer not null primary key,
    --comment_id integer not null unique,
    article_id integer not null,
    created integer not null,
    updated integer not null,
    user_id integer not null,
    content text not null,
    foreign key (article_id) references articles(id)
);
create table if not exists users(
    id integer not null primary key,
    --user_id integer not null unique,
    address text not null unique,
    created integer not null,
    updated integer not null,
    name text not null,
    icon_image_path text
);
create table if not exists categories(
    id integer not null primary key,
    name text not null unique
);
-- https://github.com/Raiu1210/omaemona_front/blob/8174d5d0ff5f37370a7f7f9fd8fdb60daca4ddd1/myModules/categoryUtils.js
insert into categories(id,name) values (0,'未分類'),(1,'その他'),(2,'暗号通貨'),(3,'モナコイン'),(4,'温泉'),(5,'神社・お寺'),(6,'趣味'),(10,'カーライフ'),(7,'日記'),(8,'IT技術'),(9,'ガジェット'),(11,'本'),(12,'創作話'),(13,'怖い話');
