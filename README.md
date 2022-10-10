[ja](./README.ja.md)

# Shell.Monaledge.MyArticles.Downloader

Get all my articles posted on monalage [bash]

<!--

# DEMO

* [DEMO](https://ytyaru.github.io/Shell.Shell.Monaledge.MyArticles.Downloader.20221010174354/)

# Features

* sales point

-->

# Requirement

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

# Installation

```sh
git clone https://github.com/ytyaru/Shell.Shell.Monaledge.MyArticles.Downloader.20221010174354
```

# Usage

1. Get articles from Monalage
1. Save as Markdown
1. Edit with a text editor

## Get Articles from Monalage

```sh
cd Shell.Monaledge.Api.MyInfo.MyArticles.20221007104359/src
ADDRESS='Your Monacoin address registered with Monaledge'
./run.sh $ADDRESS
```

It is collectively saved in a SQLite3 file called `monaledge.db`.

### Execution time

Wait 1 second for each request. Server load measures. Therefore, the time required to acquire all the cases is as follows.

　リクエストするたび1秒ウェイトする。サーバ負荷対策。このため全件取得にかかる時間は以下の通り。

```
number of articles + (number of articles / 10) + 1
```

If the number of articles is 100, it takes 111 seconds. The reason why it is 1/10 is that `myArticles` gets 10 articles each. `+1` is the minute of `myInfo`. After that, issue the `article` for the number of articles and get the text. So this takes a long time.

## Save as markdown

If you want to save it as a markdown file, execute the following after executing the above.

```sh
./file.sh
```

Articles are saved in a file called `Article ID.md` under `./md`.

```markdown
---
title: "some title"
date: createdAt
lastmod: updatedAt
categories: ["category"]
---

body...
```

* The title, date and time, and category are set in the front matter.
* The date and time is a value like `2022-05-10T09:37:51.045Z`.
* Category names include `cryptocurrency` and `IT technology`.
* The title and text are the text as registered on the monagency editing screen. markdown.

## Edit with a text editor

```sql
select edit(content, 'vim') from articles where id = 452;
```

Get the body of the article ID and edit it with `vim`. It is possible with `edit()` function of SQLite3. Specify the text as the first argument and the editor command as the second argument.

When I tried the editor in the GUI, `mousepad` was successful, but `pluma` did not display the text.

## Tally

### number of articles

```sql
> select count(*) from articles;
172
```

### List of comments other than your own

```sql
> select count(*) from comments where user_id != 92;
41
```

`92` is my user ID.

### Total mona received

```sql
> select sum(sent_mona) from articles;
19.602588
```

<!--

# Note

* important point

-->

# Author

ytyaru

* [![github](http://www.google.com/s2/favicons?domain=github.com)](https://github.com/ytyaru "github")
* [![hatena](http://www.google.com/s2/favicons?domain=www.hatena.ne.jp)](http://ytyaru.hatenablog.com/ytyaru "hatena")
* [![twitter](http://www.google.com/s2/favicons?domain=twitter.com)](https://twitter.com/ytyaru1 "twitter")
* [![mastodon](http://www.google.com/s2/favicons?domain=mstdn.jp)](https://mstdn.jp/web/accounts/233143 "mastdon")

# License

This software is CC0 licensed.

[![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png "CC0")](http://creativecommons.org/publicdomain/zero/1.0/deed.en)

