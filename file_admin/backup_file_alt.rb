# -*- coding: utf-8 -*-
#
#  Copyright 2012,2016 agwlvssainokuni
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
require File.join(File.dirname(__FILE__), 'validation')
require File.join(File.dirname(__FILE__), 'command')
require File.join(File.dirname(__FILE__), 'selector')

module FileAdmin

  # ファイル退避機能
  #   label
  #   basedir
  #   pattern
  #   regexp (opt)
  #   cond (opt)
  #   exclude (opt)
  #   to_dir
  class BackupFileAlt
    include Validation
    include Command
    include Selector

    # 設定値の妥当性チェック
    def valid?()
      @logger = Logger.new("BACKUPALT")
      valid = true
      valid = false unless check_required_string('label', @label)
      valid = false unless check_required_string('basedir', @basedir)
      valid = false unless check_required_array('pattern', Array(@pattern))
      valid = false unless check_required_string('to_dir', @to_dir)
      return valid
    end

    # ファイル退避
    def process(time = Time.now, dry_run = false)
      @logger = Logger.new("BACKUPALT[#{@label}]")
      @logger.debug("start")

      Dir.chdir(@basedir) {

        files = collect_targets()
        files = files.select {|f| File.file?(f) }
        if files.empty?
          @logger.debug("no files, skipped")
          return true
        end

        files.each {|file|
          next unless File.file?(file)
          return false unless mv(file, @to_dir, dry_run)
          @logger.info("mv %s %s: OK", file, @to_dir) unless dry_run
        }
      }

      @logger.debug("end normally")
      return true
    rescue Exception => err
      @logger.error("chdir %s: NG; class=%s, message=%s",
                    @basedir, err.class, err.message)
      return false
    end

  end
end
