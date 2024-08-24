# frozen_string_literal: true
#
#  Copyright 2012,2024 agwlvssainokuni
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

require_relative 'logger'
require_relative 'validation'
require_relative 'command'
require_relative 'selector'
require_relative 'time_utils'

module FileAdmin

  # ファイル退避機能
  #   label
  #   basedir
  #   pattern
  #   regexp (opt)
  #   cond (opt)
  #   suffix (opt)
  #   tsformat
  #   grace_period
  #   to_dir
  class BackupFile
    include Validation
    include Command
    include Selector
    include TimeUtils

    # 設定値の妥当性チェック
    def valid?()
      @logger = Logger.new("BACKUP")
      valid = true
      valid = false unless check_required_string('label', @label)
      valid = false unless check_required_string('basedir', @basedir)
      valid = false unless check_required_array('pattern', Array(@pattern))
      valid = false unless check_required_string('tsformat', @tsformat)
      valid = false unless check_format_strftime('tsformat', @tsformat)
      valid = false unless check_required_string('grace_period', @grace_period)
      valid = false unless check_format_period('grace_period', @grace_period)
      valid = false unless check_required_string('to_dir', @to_dir)
      return valid
    end

    # ファイル退避
    def process(time = Time.now, dry_run = false)
      @logger = Logger.new("BACKUP[#{@label}]")
      @logger.debug("start")

      threshold_time = calculate_time(time, @grace_period)
      unless threshold_time.to_i < time.to_i
        @logger.debug("process ignored")
        return true
      end

      Dir.chdir(@basedir) {

        threshold = threshold_time.strftime(@tsformat)
        @logger.debug("threshold: %s", threshold)

        collect_targets_by_threshold(threshold).each { |file|
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
