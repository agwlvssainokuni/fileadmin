#!/usr/bin/ruby
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

require 'optparse'
require 'time'
require 'syck'
require 'yaml'
require File.join(File.dirname(__FILE__), 'file_admin/yaml_conf')


Version = "1.0."
PARAM = {
  :time => Time.now,
  :conftest => false,
  :dry_run => false
}

opt = OptionParser.new
opt.on("--time TIME", "基準日時指定") {|p| PARAM[:time] = Time.parse(p) }
opt.on("--[no-]conftest", "設定チェック") {|p| PARAM[:conftest] = p }
opt.on("--[no-]dry-run", "ドライライン") {|p| PARAM[:dry_run] = p }
opt.on("--[no-]syslog", "SYSLOG出力フラグ") {|p| FileAdmin::Logger.syslog_enabled = p }
opt.on("--[no-]console", "コンソール出力フラグ") {|p| FileAdmin::Logger.console_enabled = p }
opt.parse!(ARGV)

logger = FileAdmin::Logger.new("")
logger.debug("time     = %s", PARAM[:time].to_s)
logger.debug("conftest = %s", PARAM[:conftest])
logger.debug("dry-run  = %s", PARAM[:dry_run])
logger.debug("syslog   = %s", FileAdmin::Logger.syslog_enabled)
logger.debug("console  = %s", FileAdmin::Logger.console_enabled)


ok = true
YAML.each_document(ARGF) {|doc|
  doc.each {|conf|
    if PARAM[:conftest]
      ok = false unless conf.valid?()
    else
      ok = false unless conf.process(PARAM[:time], PARAM[:dry_run])
    end
  }
}

exit(ok ? 0 : 1)
