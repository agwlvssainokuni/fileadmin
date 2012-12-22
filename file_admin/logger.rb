# -*- coding: utf-8 -*-
#
# Copyright 2012 Norio Agawa
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'syslog'

module FileAdmin

  # ログ出力機能
  class Logger
    include Syslog::Constants

    # 初期化
    def initialize(l = "")
      @label = (l.empty? ? l : l + " ")
    end

    # コンソールへの出力
    @@console_enabled = false
    def self.console_enabled=(v); @@console_enabled = v; end
    def self.console_enabled; @@console_enabled; end
    def console(level, msg, *arg)
      printf("[#{level}] #{@label}#{msg}\n", *arg) if @@console_enabled
    end

    # SYSLOGへの出力
    @@syslog_enabled = true
    def self.syslog_enabled=(v); @@syslog_enabled = v; end
    def self.syslog_enabled; @@syslog_enabled; end
    def syslog(prio, level, msg, *arg)
      Syslog.open("FILEADMIN") {|log|
        log.log(prio, "[#{level}] #{@label}#{msg}", *arg)
      } if @@syslog_enabled
    end

    # デバッグログ (コンソール)
    def debug(msg, *arg)
      console("DEBUG", msg, *arg)
    end

    # 通知ログ (コンソール、SYSLOG)
    def notice(msg, *arg)
      console("NOTICE", msg, *arg)
      syslog(LOG_NOTICE, "NOTICE", msg, *arg)
    end

    # エラーログ (コンソール、SYSLOG)
    def error(msg, *arg)
      console("ERROR", msg, *arg)
      syslog(LOG_ERR, "ERROR", msg, *arg)
    end

  end
end
