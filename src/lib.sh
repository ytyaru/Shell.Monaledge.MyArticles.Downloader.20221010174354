#!/usr/bin/env bash
set -Ceu
#---------------------------------------------------------------------------
# モナレッジのAPIで指定したユーザの記事を取得する。SQLite3 DBファイルに保存する。
# $1: モナレッジに登録したモナコイン用アドレス
# CreatedAt: 2022-10-07
#---------------------------------------------------------------------------
Run() {
	THIS="$(realpath "${BASH_SOURCE:-0}")"; HERE="$(dirname "$THIS")"; PARENT="$(dirname "$HERE")"; THIS_NAME="$(basename "$THIS")"; APP_ROOT="$PARENT";
	cd "$HERE"
	[ -f 'error.sh' ] && . error.sh
	local DB=monaledge.db
	createDb() { [ -f "$DB" ] || sqlite3 "$DB" < create-table.sql; }
	createDb

	local ADDRESS="$1" # MEHCqJbgiNERCH3bRAtNSSD9uxPViEX1nu
	local AUTHOR_ID=92
	local PAGE=0
	local URL=https://monaledge.com:8443
	local API_MYINFO=$URL/myInfo
	local API_MYARTICLES=$URL/myArticles
	local API_ARTICLE=$URL/article
	local DATA_MYINFO='{"address":"'$ADDRESS'"}'
	local DATA_MYARTICLES='{"page":'$PAGE',"author_id":'$AUTHOR_ID'}'
	local HEADER='Content-Type:application/json'
	Post() { curl -X POST -H $HEADER -d "$2" $1; sleep 1; }
	Get() { curl -H $HEADER "$1"; sleep 1; }
	GetMyInfo() { Post "$API_MYINFO" "$DATA_MYINFO"; }
	GetMyArticles() { Post "$API_MYARTICLES" "$DATA_MYARTICLES"; }
	GetArticle() { Get "${API_ARTICLE}?id=$1"; }

	local MY_INFO="$(GetMyInfo)"
	echo "$MY_INFO"
	local AUTHOR_ID="$(echo "$MY_INFO" | jq .id)"
	escape() { echo "$(cat -)" | sed -e "s/'/''/g"; } # SQLメタ文字であるシングルクォートをエスケープする
	quote() { echo "$(cat -)" | sed -e "s/^/'/" | sed -e "s/$/'/"; } # 文字列型をクォートする
	values() { local O="$(echo "$ARTICLES" | jq -r ".$1")"; [ 1 -eq $2 ] && echo "$O" | escape | quote || echo "$O" | null2zero; }
	null2zero() { echo "$(cat -)" | sed -e 's/null/0/g'; } 
	enclose() { echo "$(cat -)" | sed -e 's/^/(/' | sed -e 's/$/)/'; }
	comma() { echo "$(cat -)" | sed -e 's/$/,/'; }
	insertArticleHeaders() {
		REMAINS_COUNT=-1
		while [ 1 -eq 1 ]; do
			# APIでリクエストする
			PAGE=$(( PAGE + 1 ))
			DATA_MYARTICLES='{"page":'$PAGE',"author_id":'$AUTHOR_ID'}'
			echo "$DATA_MYARTICLES"
			MY_ARTICLES="$(GetMyArticles)"
			ALL_COUNT="$(echo "$MY_ARTICLES" | jq .articlesCount)"
			NOW_COUNT="$(echo "$MY_ARTICLES" | jq '.articles | length')"
			[ -1 -eq $REMAINS_COUNT ] && REMAINS_COUNT=$(( ALL_COUNT - NOW_COUNT )) || REMAINS_COUNT=$(( REMAINS_COUNT - NOW_COUNT ))
			ARTICLES="$(echo $MY_ARTICLES | jq '.articles[] | del(.author_id)')"
			echo "========== $PAGE p あと $REMAINS_COUNT 件 =========="
			
			# DBに挿入する
			local RECORDS="$(paste -d, \
				<(values 'id' 0) \
				<(values 'title' 1) \
				<(values 'sent_mona' 0) \
				<(values 'access' 0) \
				<(values 'ogp_path' 1) \
				<(values 'category' 0) \
				<(values 'createdAt' 1) \
				<(values 'updatedAt' 1) \
			| enclose | comma)"
			local SQL="insert into articles(id,title,sent_mona,access,ogp_path,category,created,updated) values ${RECORDS%,};";
			sqlite3 "$DB" "$SQL"
			[ $REMAINS_COUNT -lt 1 ] && break
		done
	}
	insertArticleHeaders
	insertArticleContents() {
		DelHT() { echo "$(cat -)" | awk '{print substr($0, 2, length($0)-2)}'; } # 先頭と末尾の1字削除
		echo "$(sqlite3 "$DB" "select id from articles order by id asc;")" | while read article_id; do
			echo "===== $article_id ====="
			# 本文
			JSON="$(GetArticle $article_id)"
			echo "$JSON"
			#CONTENT="$(echo "$JSON" | jq .content | DelHT | escape)"
			#CONTENT="$(echo "$JSON" | jq -r .content | DelHT | escape)"
			CONTENT="$(echo "$JSON" | jq -r .content | escape)"
			SQL="update articles set content = '$CONTENT' where id = $article_id;"
			echo "$SQL"
			sqlite3 "$DB" "$SQL"
			# コメント
			COUNT=$(echo "$JSON" | jq ".comments | length")
			[ $COUNT -lt 1 ] && continue
			values() { local O="$(echo "$JSON" | jq -r ".comments[].$1")"; [ 1 -eq $2 ] && echo "$O" | escape | quote || echo "$O" | null2zero; }
			local RECORDS="$(paste -d, \
				<(values 'id' 0) \
				<(values 'article_id' 0) \
				<(values 'createdAt' 1) \
				<(values 'updatedAt' 1) \
				<(values 'from' 0) \
				<(echo "$JSON" | jq .comments[].comment | DelHT | escape | quote) \
			| enclose | comma)"
			#<(echo "$JSON" | jq .comments[].comment | DelHT | escape | quote) \
			#<(echo "$JSON" | jq -r .comments[].comment | escape | quote) \
			#<(echo "$JSON" | echo "$(jq -r .comments[].comment)" | escape | quote) \

			#SQL="insert into comments(id,article_id,created,updated,user_id,content) values ${RECORDS%,};"
			#VALUES="${RECORDS%,}"
			#VALUES="$(echo -e $VALUES)"
			VALUES="$(echo -e "${RECORDS%,}")"
			#SQL="insert into comments(id,article_id,created,updated,user_id,content) values $VALUES";"
			SQL="insert into comments(id,article_id,created,updated,user_id,content) values $VALUES;"
			echo "$SQL"
			sqlite3 "$DB" "$SQL"
		done
	}
	insertArticleContents
}
Run "$@"

