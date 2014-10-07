FileAdmin - ファイル管理
========================

# コマンドライン
```bash
fileadmin.rb [options] 設定ファイル...
    --time TIME        基準日時指定 (省略時: システム日時)
    --[no-]conftest    設定チェック (省略時: 設定チェックなし)
    --[no-]dry-run     ドライラン   (省略時: ドライランなし)
    --[no-]syslog      SYSLOG出力フラグ (省略時: SYSLOG出力する)
    --[no-]console     コンソール出力フラグ (省略時: コンソール出力しない)
```


# 設定ファイル
## 集約アーカイブ作成機能
### 型指定: `!ruby/object:AGGREGATE`


### 機能概要
*	指定されたディレクトリ (basedir) 配下でパターン (pattern, regexp, cond) に合致するファイルのうち、直近のもの (exclude個) を除外したものを、まとめて一つのZIPファイルにアーカイブする。
*	アーカイブすると、元のファイルは削除される。

### パラメタ
|パラメタ名|     | 意味
|:-------|:----:|:---
|label   |必須  | 設定の表示名。SYSLOGに出力するログ文言に埋込まれる。
|basedir |必須  | アーカイブ対象のファイルを探す際の起点のディレクトリを指定する。
|pattern |必須  | アーカイブ対象のファイルを探す際のパターンを指定する。ワイルドカード(*)指定可。複数可。
|regexp  |省略可| アーカイブ対象のファイルを更に絞り込むための正規表現を指定する。
|cond    |省略可| 上記正規表現で照合した後で更に絞り込むための条件式を指定する。
|exclude |省略可| pattern, regexp, condの条件に合致したファイルの中で、昇順にソートして末尾 exclude 個を除外する。
|arcname |必須  | アーカイブファイルの基本名。作成するアーカイブファイルの名前は"{基本名}{タイムスタンプ}.zip"。
|tsformat|必須  | アーカイブファイルの名前に入れるタイムスタンプの書式。典型的には"%Y%m%d%H%M%S"。
|to_dir  |省略可| アーカイブファイルの作成先ディレクトリを指定する。省略すると basedir に作成される。
|chown   |省略可| アーカイブファイルを作成した後で `chown` する場合に指定する。省略すると `chown` しない。


## 一対一アーカイブ作成機能
### 型指定: `!ruby/object:FOREACH`

### 機能概要
*	指定されたディレクトリ (basedir) 配下でパターン (pattern, regexp, cond) に合致するファイルのうち、直近のもの (exclude個) を除外したものを、一つずつ別々のZIPファイルにアーカイブする。
*	アーカイブすると、元のファイルは削除される。

### パラメタ
|パラメタ名|      | 意味
|:-------|:----:|:---
|label   |必須  | 設定の表示名。SYSLOGに出力するログ文言に埋込まれる。
|basedir |必須  | アーカイブ対象のファイルを探す際の起点のディレクトリを指定する。
|pattern |必須  | アーカイブ対象のファイルを探す際のパターンを指定する。ワイルドカート(*)指定可。複数可。
|regexp  |省略可| アーカイブ対象のファイルを更に絞り込むための正規表現を指定する。
|cond    |省略可| 上記正規表現で照合した後で更に絞り込むための条件式を指定する。
|exclude |省略可| pattern, regexp, condの条件に合致したファイルの中で、昇順にソートして末尾 exclude 個を除外する。
|suffix  |省略可| アーカイブファイルの名前を形成する際に、元のファイル名から除外する「拡張子」の部分を指定する。
|to_dir  |省略可| アーカイブファイルの作成先ディレクトリを指定する。省略すると basedir に作成される。
|chown   |省略可| アーカイブファイルを作成した後で `chown` する場合に指定する。省略すると `chown` しない。


## ファイル退避機能
### 型指定: `!ruby/object:BACKUP`

### 機能概要
*	指定されたディレクトリ (basedir) 配下でパターン (pattern, regexp, cond) に合致するファイルのうち、所定の期間 (grace_period) 以降のタイムスタンプを持つものを、宛先ディレクトリ (to_dir) に移動する。

### パラメタ
  #   label
  #   basedir
  #   pattern
  #   regexp (opt)
  #   cond (opt)
  #   suffix (opt)
  #   tsformat
  #   grace_period
  #   to_dir


## ファイル退避機能(改)
### 型指定: `!ruby/object:BACKUPALT`

### 機能概要
*	指定されたディレクトリ (basedir) 配下でパターン (pattern, regexp, cond) に合致するファイルのうち、直近のもの (exclude個) を除外したものを、宛先ディレクトリ (to_dir) に移動する。

### パラメタ
  #   label
  #   basedir
  #   pattern
  #   regexp (opt)
  #   cond (opt)
  #   exclude (opt)
  #   to_dir


## ファイル削除機能
### 型指定: `!ruby/object:CLEANUP`

### 機能概要
*	指定されたディレクトリ (basedir) 配下でパターンに合致するファイルのうち、所定の期間 (grace_period) 以降のタイムスタンプを持つものを削除する。

### パラメタ
  #   label
  #   basedir
  #   pattern
  #   regexp (opt)
  #   cond (opt)
  #   suffix (opt)
  #   tsformat
  #   grace_period


## ファイル削除機能(改)
### 型指定: `!ruby/object:CLEANUPALT`

### 機能概要
*	指定されたディレクトリ (basedir) 配下でパターン (pattern, regexp, cond) に合致するファイルのうち、直近のもの (exclude個) を除外したものを、宛先ディレクトリ (to_dir) に移動する。

### パラメタ
  #   label
  #   basedir
  #   pattern
  #   regexp (opt)
  #   cond (opt)
  #   exclude (opt)


## リモート退避機能
### 型指定: `!ruby/object:FETCH`

### 機能概要
*	リモートディレクトリ (host, rdir) 配下のパターン (pattern) に合致するファイルを、ローカルディレクトリ (basedir) に複製 (`rsync`) する。
*	複製した個々のファイルについて、リモートディレクトリにあるファイルとチェックサムを照合し (sumcmd) する。
*	チェックサムが合致したら、最終的な宛先ローカルディレクトリ (to_dir) に移動する。

### パラメタ
  #   label
  #   basedir
  #   host
  #   rdir
  #   pattern
  #   ext
  #   to_dir
  #   sumcmd (opt)


## リモート退避機能
### 型指定: `!ruby/object:PUSH`

### 機能概要
*	ローカルディレクトリ (basedir) 配下でパターン (pattern) に合致するファイルを、リモートディレクトリ (host, rdir) に複製 (`rsync`) する。

### パラメタ
  #   label
  #   basedir
  #   host
  #   rdir
  #   pattern

