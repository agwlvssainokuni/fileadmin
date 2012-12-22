# -*- coding: utf-8 -*-
#
#  Copyright 2012 Norio Agawa
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

require File.join(File.dirname(__FILE__), 'logger')
require File.join(File.dirname(__FILE__), 'foreach_archive')
require File.join(File.dirname(__FILE__), 'aggregate_archive')
require File.join(File.dirname(__FILE__), 'backup_file')
require File.join(File.dirname(__FILE__), 'cleanup_file')
require 'yaml'

module FileAdmin

  # YAML形式を読み込む際の「タグ=>オブジェクト 対応」を定義する。
  {
    "foreach" => ForeachArchive,
    "aggregate" => AggregateArchive,
    "backup" => BackupFile,
    "cleanup" => CleanupFile
  }.each_pair {|tag, klass| 
    YAML.add_private_type(tag) {|t, v| YAML.object_maker(klass, v) }
  }

end
