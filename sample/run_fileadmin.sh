#!/bin/bash

basedir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

ruby -I ${basedir}/.. ${basedir}/../fileadmin.rb $* <(

cat <<__CONFIG__
- !ruby/object:FOREACH
  label: 一対一アーカイブ
  basedir: ${basedir}/0file
  pattern: foreach_*.txt
  regexp: "_(\\\\d{14})\\\\.txt\$"
  suffix: ".txt"
  to_dir: ${basedir}/1arch

- !ruby/object:AGGREGATE
  label: 集約アーカイブ
  basedir: ${basedir}/0file
  pattern: aggregate_*.txt
  arcname: aggregate_
  tsformat: "%Y%m%d%H%M%S"
  to_dir: ${basedir}/1arch

- !ruby/object:BACKUP
  label: 退避テスト
  basedir: ${basedir}/1arch
  pattern:
    - foreach_
    - aggregate_
  suffix: .zip
  tsformat: "%Y%m%d"
  grace_period: "1 day ago"
  to_dir: ${basedir}/2back

- !ruby/object:CLEANUP
  label: 削除テスト
  basedir: ${basedir}/2back
  pattern:
    - foreach_
    - aggregate_
  suffix: .zip
  tsformat: "%Y%m%d"
  grace_period: "2 days ago"
__CONFIG__

)
