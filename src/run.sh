#!/usr/bin/env bash
set -Ceu
#---------------------------------------------------------------------------
# モナレッジのAPIで指定したユーザの記事を取得する。
# CreatedAt: 2022-10-07
#---------------------------------------------------------------------------
Run() {
	THIS="$(realpath "${BASH_SOURCE:-0}")"; HERE="$(dirname "$THIS")"; PARENT="$(dirname "$HERE")"; THIS_NAME="$(basename "$THIS")"; APP_ROOT="$PARENT";
	cd "$HERE"
	[ -f 'error.sh' ] && . error.sh
	# 必要コマンドのインストール
	IsExistCmd() { type "$1" > /dev/null 2>&1; }
	Install() { IsExistCmd "$1" || sudo apt install -y "$1"; }
	for cmd in {sqlite3,jq}; do { Install "$cmd"; } done;
	# 引数ルーティング
	ParseCommand() {
		THIS_NAME=`basename "$BASH_SOURCE"`
		SUMMARY='モナレッジのAPIで指定したユーザの記事を全件取得する。'
		VERSION=0.0.1
		ARG_FLAG=; ARG_OPT=;
		Help() { eval "echo -e \"$(cat help.txt)\""; }
		Version() { echo "$VERSION"; }
		while getopts ":hvfo:" OPT; do
		case $OPT in
			h) Help; exit 0;;
			v) Version; exit 0;;
		esac
		done
		shift $(($OPTIND - 1))
		[ $# -eq 0 ] && { Error '第一引数にモナレッジで登録したモナコイン用アドレスを指定してください。'; Help; exit 1; } || :;
	}
	ParseCommand "$@"
	./lib.sh "$1"
}
Run "$@"
