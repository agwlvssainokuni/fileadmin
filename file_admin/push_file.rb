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
require File.join(File.dirname(__FILE__), 'time_utils')

module FileAdmin

  # リモート退避機能
  #   label
  #   basedir
  #   host
  #   rdir
  #   pattern
  class PushFile
    include Validation
    include Command
    include Selector
    include TimeUtils

    # 設定値の妥当性チェック
    def valid?()
      @logger = Logger.new("PUSH")
      valid = true
      valid = false unless check_required_string('label', @label)
      valid = false unless check_required_string('basedir', @basedir)
      valid = false unless check_required_string('host', @host)
      valid = false unless check_required_string('rdir', @rdir)
      valid = false unless check_required_array('pattern', Array(@pattern))
      return valid
    end

    # ファイル退避
    def process(time = Time.now, dry_run = false)
      @logger = Logger.new("PUSH[#{@label}]")
      @logger.debug("start")

      Dir.chdir(@basedir) {
        return false unless rsync_to_push(".", @host, @rdir, @pattern, dry_run)
        args = Array(@pattern).flat_map {|p| ["--include", p]}
        args << "--exclude" << "*" unless @pattern.nil? || @pattern.empty?
        @logger.notice("rsync -a --delete %s %s:%s %s: OK",
                       ".", @host, @rdir, args * " ") unless dry_run
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
