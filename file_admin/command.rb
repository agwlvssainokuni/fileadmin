# -*- coding: utf-8 -*-
#
#  Copyright 2012,2015 agwlvssainokuni
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

require 'etc'
require 'open3'
require 'fileutils'
require 'pathname'

module FileAdmin

  # コマンド実行機能
  module Command

    # ファイルをディレクトリに移動する。
    def mv(file, path, dry_run = false)
      @logger.debug("processing: mv %s %s", file, path)
      return true if dry_run
      begin
        to_file = Pathname(path).join(File.basename(file))
        FileUtils.mv(file, to_file)
        return true
      rescue Exception => err
        @logger.error("mv %s %s: NG, class=%s, message=%s",
                      file, path, err.class, err.message)
        return false
      end
    end

    # ファイルを削除する。
    def rm(file, dry_run = false)
      @logger.debug("processing: rm %s", file)
      return true if dry_run
      begin
        File.unlink(file)
        return true
      rescue Exception => err
        @logger.error("rm %s: NG, class=%s, message=%s",
                      file, err.class, err.message)
        return false
      end
    end

    # リストで指定されたファイルを対象としてアーカイブする (削除あり)。
    def zip_with_moving_files(arcfile, filelist, dry_run = false)
      return exec_zip(arcfile, filelist, true, dry_run)
    end

    # リストで指定されたファイルを対象としてアーカイブする (削除なし)。
    def zip_without_moving_files(arcfile, filelist, dry_run = false)
      return exec_zip(arcfile, filelist, false, dry_run)
    end

    # リストで指定されたファイル/ディレクトリを対象として
    # ZIPコマンドを実行する。
    def exec_zip(arcfile, filelist, move, dry_run = false)
      zip_opt = (move ? "-mr" : "-r")
      @logger.debug("processing: zip %s %s %s",
                    zip_opt, arcfile, filelist * " ")
      return true if dry_run
      out, status = Open3.popen2e("zip", zip_opt, arcfile, "-@") {|si, so, th|
        filelist.each {|file| si.puts(file) }
        si.close_write
        [so.readlines(nil), th.value]
      }
      unless status.success?
        @logger.error("zip %s %s %s: NG, status=%d, out=%s",
                      zip_opt, arcfile, filelist * " ", status, out)
        return false
      end
      return true
    end

    # ディレクトリを同期 (RSYNC) する
    def rsync(src, dest, pattern, option, dry_run = false)
      args = Array(pattern).flat_map {|p| ["--include", p]}
      args << "--exclude" << "*" unless pattern.nil? || pattern.empty?
      args += Array(option)
      @logger.debug("processing: rsync -a %s %s %s",
                    src, dest, args * " ")
      return true if dry_run
      out, status = Open3.capture2e("rsync", "-a", src, dest, *args)
      unless status.success?
        @logger.error("rsync -a %s %s %s: NG, status=%d, out=%s",
                      src, dest, args * " ", status, out)
        return false
      end
      return true
    end

    # リモートとローカルのファイルをチェックサムで検証する。
    def checksum(host, rdir, filelist, sumcmd = "sha1sum", dry_run = false)
      rcmd = sprintf("(cd %s; %s -c)", rdir, sumcmd)
      @logger.debug("processing: %s -b %s | ssh %s \"%s\"",
                    sumcmd, filelist * " ", host, rcmd)
      return true if dry_run
      out, err, status = IO.pipe {|err_r, err_w|
        o, s = Open3.pipeline_r( [sumcmd, "-b", *filelist],
                                 ["ssh", host, rcmd],
                                 :err => err_w) {|so, th|
          [so.readlines(nil), [th[0].value, th[1].value]]
        }
        err_w.close
        [o, err_r.readlines(nil), s]
      }
      unless status[0].success? && status[1].success?
        @logger.error("%s -b %s | ssh %s \"%s\": NG, status=%d|%d, out=%s, err=%s",
                      sumcmd, filelist * " ", host, rcmd,
                      status[0], status[1], out, err)
        return false
      end
      return true
    end

    # リモートのファイルの名前を変更する。
    def rename(host, rdir, sname, dname, dry_run = false)
      rcmd = sprintf("(cd %s; mv %s %s)", rdir, sname, dname)
      @logger.debug("processing: ssh %s \"%s\"",
                    host, rcmd)
      return true if dry_run
      out, status = Open3.capture2e("ssh", host, rcmd)
      unless status.success?
        @logger.debug("ssh %s \"%s\": NG, status=%d, out=%s",
                      host, rcmd, status, out)
        return false
      end
      return true
    end

    # ファイルの所有者を変更する。
    def chown(owner, path, dry_run = false)
      @logger.debug("processing: chown %s %s", owner, path)
      return true if dry_run
      begin
        og = owner.split(":")
        if og.length < 2
          u = Etc.getpwnam(og[0])
          File.chown(u.uid, -1, path)
        else
          u = Etc.getpwnam(og[0])
          g = Etc.getgrnam(og[1])
          File.chown(u.uid, g.gid, path)
        end
        return true
      rescue Exception => err
        @logger.error("chown %s %s: NG, class=%s, message=%s",
                      owner, path, err.class, err.message)
        return false
      end
    end

  end
end
