#!/bin/bash

export basedir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

${basedir}/../fileadmin.rb --erb $* <(

cat <<__CONFIG__
- !ruby/object:FOREACH
  label: 一対一アーカイブ
  basedir: <%= ENV['basedir'] %>/0file
  pattern: foreach_*.txt
  regexp: "_(\\\\d{14})\\\\.txt\$"
  suffix: ".txt"
  to_dir: <%= ENV['basedir'] %>/1arch

- !ruby/object:AGGREGATE
  label: 集約アーカイブ
  basedir: <%= ENV['basedir'] %>/0file
  pattern: aggregate_*.txt
  arcname: aggregate_
  tsformat: "%Y%m%d%H%M%S"
  to_dir: <%= ENV['basedir'] %>/1arch

- !ruby/object:BACKUP
  label: 退避テスト
  basedir: <%= ENV['basedir'] %>/1arch
  pattern:
    - foreach_
    - aggregate_
  suffix: .zip
  tsformat: "%Y%m%d"
  grace_period: "1 day ago"
  to_dir: <%= ENV['basedir'] %>/2back

- !ruby/object:BACKUP
  label: リモート退避テスト
  basedir: <%= ENV['basedir'] %>/2back
  pattern:
    - foreach_
    - aggregate_
  suffix: .zip
  tsformat: "%Y%m%d"
  grace_period: "2 day ago"
  to_dir: <%= ENV['basedir'] %>/2back/work/

- !ruby/object:FETCH
  label: リモート退避テスト
  basedir: <%= ENV['basedir'] %>/3back/work/
  host: localhost
  rdir: <%= ENV['basedir'] %>/2back/work/
  pattern:
    - foreach_*.zip
    - aggregate_*.zip
  ext: done
  to_dir: <%= ENV['basedir'] %>/3back/

- !ruby/object:CLEANUP
  label: リモート退避テスト
  basedir: <%= ENV['basedir'] %>/2back/work
  pattern:
    - foreach_
    - aggregate_
  suffix: .zip.done
  tsformat: "%Y%m%d"
  grace_period: "3 days ago"

- !ruby/object:CLEANUP
  label: 削除テスト
  basedir: <%= ENV['basedir'] %>/3back
  pattern:
    - foreach_
    - aggregate_
  suffix: .zip
  tsformat: "%Y%m%d"
  grace_period: "4 days ago"

- !ruby/object:PUSH
  label: ファイル配信テスト
  basedir: <%= ENV['basedir'] %>/3back/
  host: localhost
  rdir: <%= ENV['basedir'] %>/4dest/
  pattern:
    - foreach_*.zip
    - aggregate_*.zip
__CONFIG__

)
