# -*- coding: utf-8 -*-
#
#  Copyright 2012,2014 agwlvssainokuni
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

  # 一対一アーカイブ作成機能
  #   label
  #   basedir
  #   pattern
  #   regexp (opt)
  #   cond (opt)
  #   exclude (opt)
  #   suffix (opt)
  #   to_dir (opt)
  #   chown (opt)
  class ForeachArchive
    include Validation
    include Command
    include Selector

    # 設定値の妥当性チェック
    def valid?()
      @logger = Logger.new("FOREACH")
      valid = true
      valid = false unless check_required_string('label', @label)
      valid = false unless check_required_string('basedir', @basedir)
      valid = false unless check_required_array('pattern', Array(@pattern))
      return valid
    end

    # 一対一アーカイブ作成
    def process(time = Time.now, dry_run = false)
      @logger = Logger.new("FOREACH[#{@label}]")
      @logger.debug("start")

      Dir.chdir(@basedir) {

        files = collect_targets()
        files = files.select {|f| File.file?(f) }
        if files.empty?
          @logger.debug("no files, skipped")
          return true
        end

        files.each {|f|

          if is_empty?(@to_dir)
            arcfile = sprintf("./%s/%s.zip",
                              File.dirname(f),
                              File.basename(f, @suffix.to_s))
          else
            arcfile = sprintf("%s/%s.zip",
                              @to_dir,
                              File.basename(f, @suffix.to_s))
          end

          return false unless zip_with_moving_files(arcfile, Array(f), dry_run)
          @logger.notice("zip -mr %s %s: OK", arcfile, f)
          unless is_empty?(@chown)
            return false unless chown(@chown, arcfile, dry_run)
          end
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
