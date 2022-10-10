# モナレッジに投稿した自分の記事を全件取得する【bash】

　ついにできた。

<!-- more -->

# ブツ

* [][]

[]:https://github.com/ytyaru/

# 実行

```sh
ADDRESS='モナレッジに登録した自分のモナコイン用アドレス'
NAME=''
git clone 
./run.sh 
```

　`monaledge.db`というSQLite3ファイルに一括保存される。

## 実行時間

　リクエストするたび1秒ウェイトする。サーバ負荷対策。このため全件取得にかかる時間は以下の通り。

```
記事件数 + (記事件数 / 10) 秒 + 1
```

　もし記事数が100件なら111秒かかる。10分の1になっているのは`myArticles`で10件ずつ記事を取得するから。`+1`は`myInfo`の分。あとは記事数だけ`article`を発行して本文を取得する。よってこれだけ時間がかかる。

## マークダウンとして保存

　もしマークダウンファイルとして保存したいなら、上記を実行したあとに以下を実行する。

```sh
./file.sh
```

　すると`./md`配下に`記事ID.md`というファイルで記事が保存される。

```markdown
---
title: "タイトル"
date: 作成日時
lastmod: 更新日時
categories: ["カテゴリ名"]
---

本文
```

　フロントマターにタイトルや日時、カテゴリをセットした状態になる。

　日時は`2022-05-10T09:37:51.045Z`のような値。

　カテゴリ名は`暗号通貨`や`IT技術`など。

　タイトルや本文はモナレッジの編集画面で登録したままのテキスト。マークダウン。

## テキストエディタで編集

```sql
select edit(content, 'vim') from articles where id = 452;
```

　記事IDの本文を取得し、`vim`で編集する。SQLite3の`edit()`関数で可能。第一引数に本文、第二引数にエディタコマンドを指定する。

　エディタをGUIで試してみたら`mousepad`は成功したが、`pluma`は本文が表示されなかった。

# DB確認

## CLIモード

```sh
sqlite3 monaledge.db
```
```sh
sqlite> 
```

## テーブル名一覧

```sql
.tables
```
```sql
articles    categories  comments    users
```

## スキーマ一覧

```sql
select sql from sqlite_master;
```
```sql
CREATE TABLE articles(
    id integer not null primary key,
    article_id integer not null unique,
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
)

CREATE TABLE comments(
    id integer not null primary key,
    comment_id integer not null unique,
    article_id integer not null,
    created integer not null,
    updated integer not null,
    user_id integer not null,
    content text not null,
    foreign key (article_id) references articles(article_id)
)

CREATE TABLE users(
    id integer not null primary key,
    user_id integer not null unique,
    address text not null unique,
    created integer not null,
    updated integer not null,
    name text not null,
    icon_image_path text
)


CREATE TABLE categories(
    id integer not null primary key,
    name text not null unique
)
```

# 集計

　DBにすると一瞬で集計できる。

## 記事数

```sql
> select count(*) from articles;
172
```

　私はモナレッジで172記事も書いたらしい。

## 自分以外のコメント一覧

```sql
select content from comments where user_id != 92;
```

　`92`は私のユーザID。今まで41件もコメントをいただきました。感謝。

```sql
> select count(*) from comments where user_id != 92;
41
```

## 頂いたモナ総額

```sql
> select sum(sent_mona) from articles;
19.602588
```

　これまでで19.6モナ頂きました。ありがとうございます＜（＿＿）＞

# コード

* `run.sh`
    * `lib.sh`
* `file.sh`

　[モナレッジAPIを調べる][]で見つけた`myInfo`,`myArticles`,`article`のAPI叩いてDBに登録する。

[モナレッジAPIを調べる]:

　sqlite3とjqコマンドを使った。SQL構文のところで苦労した。文字列はシングルクォートするけど数値はしないとか。テキストの中身にシングルクォートがあるかもしれないからエスケープするとか。それをSQL文に組み立てるとか。それをbash構文内でやるとか。あとJSON内の文字列エスケープも`jq`の`-r`でやる。そうした細かい所とその合わせ技に苦労した。

# 課題

　DBを更新できない。現状、実行するたびにDBファイルを削除してすべてのデータを取得し直すしかない。とても効率が悪い。DBにない分だけを最少リクエストで取得したい。存在しない記事はもちろん、更新された既存記事もよしなにやってほしい。そのへんをシェルスクリプトで実装しようとするとかなり大変なので、Pythonで書いたほうがよさそう。

