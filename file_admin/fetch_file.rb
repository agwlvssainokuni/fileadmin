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
require File.join(File.dirname(__FILE__), 'time_utils')

module FileAdmin

  # リモート退避機能
  #   label
  #   basedir
  #   host
  #   rdir
  #   pattern
  #   ext
  #   to_dir
  #   sumcmd (opt)
  class FetchFile
    include Validation
    include Command
    include Selector
    include TimeUtils

    # 設定値の妥当性チェック
    def valid?()
      @logger = Logger.new("FETCH")
      valid = true
      valid = false unless check_required_string('label', @label)
      valid = false unless check_required_string('basedir', @basedir)
      valid = false unless check_required_string('host', @host)
      valid = false unless check_required_string('rdir', @rdir)
      valid = false unless check_required_array('pattern', Array(@pattern))
      valid = false unless check_required_string('ext', @ext)
      valid = false unless check_required_string('to_dir', @to_dir)
      return valid
    end

    # ファイル退避
    def process(time = Time.now, dry_run = false)
      @logger = Logger.new("FETCH[#{@label}]")
      @logger.debug("start")

      Dir.chdir(@basedir) {

        src = "#{@host}:#{@rdir}"
        dest = "."
        filelist = Array(@pattern).flat_map {|pat|
          return false unless rsync(src, dest, pat, [], dry_run)
          @logger.info("rsync -a %s %s --include %s --exclude *: OK",
                         src, dest, pat) unless dry_run
          Dir.glob(pat)
        }

        if filelist.empty?
          @logger.debug("process ignored")
          return true
        end

        cmd = if is_empty?(@sumcmd); "sha1sum" else @sumcmd end
        return false unless checksum(@host, @rdir, filelist, cmd, dry_run)
        @logger.info("%s -b %s | ssh %s \"(cd %s; %s -c)\": OK",
                       cmd, filelist * " ", @host, @rdir, cmd) unless dry_run

        filelist.each {|file|

          to_file = "#{file}.#{@ext}"
          return false unless rename(@host, @rdir, file, to_file, dry_run)
          @logger.info("ssh %s \"(cd %s; mv %s %s)\": OK",
                         @host, @rdir, file, to_file) unless dry_run

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
