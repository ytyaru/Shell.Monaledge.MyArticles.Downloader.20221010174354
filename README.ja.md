[en](./README.md)

# Shell.Monaledge.MyArticles.Downloader

　モナレッジに投稿した自分の記事を全件取得する【bash】

<!--

# デモ

* [デモ](https://ytyaru.github.io/Shell.Shell.Monaledge.MyArticles.Downloader.20221010174354/)

# 特徴

* セールスポイント

-->

# 開発環境

* <time datetime="2022-10-10T17:42:45+0900">2022-10-10</time>
* [Raspbierry Pi](https://ja.wikipedia.org/wiki/Raspberry_Pi) 4 Model B Rev 1.2
* [Raspberry Pi OS](https://ja.wikipedia.org/wiki/Raspbian) buster 10.0 2020-08-20 <small>[setup](http://ytyaru.hatenablog.com/entry/2020/10/06/111111)</small>
* bash 5.0.3(1)-release
* sqlite3 3.39.0
* jq 1.5-1-a5b5cbe

```sh
$ uname -a
Linux raspberrypi 5.10.103-v7l+ #1529 SMP Tue Mar 8 12:24:00 GMT 2022 armv7l GNU/Linux
```

# インストール

```sh
git clone https://github.com/ytyaru/Shell.Shell.Monaledge.MyArticles.Downloader.20221010174354
```

# 使い方

1. モナレッジから記事を取得する
1. マークダウンとして保存する
1. テキストエディタで編集する

## モナレッジから記事を取得する

```sh
cd Shell.Monaledge.Api.MyInfo.MyArticles.20221007104359/src
ADDRESS='モナレッジに登録した自分のモナコイン用アドレス'
./run.sh $ADDRESS
```

　`monaledge.db`というSQLite3ファイルに一括保存される。

### 実行時間

　リクエストするたび1秒ウェイトする。サーバ負荷対策。このため全件取得にかかる時間は以下の通り。

```
記事件数 + (記事件数 / 10) 秒 + 1
```

　もし記事数が100件なら111秒かかる。10分の1になっているのは`myArticles`で10件ずつ記事を取得するから。`+1`は`myInfo`の分。あとは記事数だけ`article`を発行して本文を取得する。よってこれだけ時間がかかる。

## マークダウンとして保存する

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

## テキストエディタで編集する

```sql
select edit(content, 'vim') from articles where id = 452;
```

　記事IDの本文を取得し、`vim`で編集する。SQLite3の`edit()`関数で可能。第一引数に本文、第二引数にエディタコマンドを指定する。

　エディタをGUIで試してみたら`mousepad`は成功したが、`pluma`は本文が表示されなかった。

## 集計する

### 記事数

```sql
> select count(*) from articles;
172
```

### 自分以外のコメント一覧

```sql
> select count(*) from comments where user_id != 92;
41
```

　`92`は自分のユーザID。

### 頂いたモナ総額

```sql
> select sum(sent_mona) from articles;
19.602588
```

<!--

# 注意

* 注意点など

-->

# 著者

　ytyaru

* [![github](http://www.google.com/s2/favicons?domain=github.com)](https://github.com/ytyaru "github")
* [![hatena](http://www.google.com/s2/favicons?domain=www.hatena.ne.jp)](http://ytyaru.hatenablog.com/ytyaru "hatena")
* [![twitter](http://www.google.com/s2/favicons?domain=twitter.com)](https://twitter.com/ytyaru1 "twitter")
* [![mastodon](http://www.google.com/s2/favicons?domain=mstdn.jp)](https://mstdn.jp/web/accounts/233143 "mastdon")

# ライセンス

　このソフトウェアはCC0ライセンスである。

[![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png "CC0")](http://creativecommons.org/publicdomain/zero/1.0/deed.ja)

