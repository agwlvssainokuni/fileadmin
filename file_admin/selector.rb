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

module FileAdmin

  # 対象抽出
  module Selector

    # 対象を抽出してリストとして取得する。
    def collect_targets()
      list = []
      Array(@pattern).each {|dirpat|
        l = select_by_dir_pattern(dirpat)
        list += l.sort[0..-(@exclude.to_i + 1)]
      }
      return list
    end

    # 閾値を指定して対象を抽出してリストとして取得する。
    def collect_targets_by_threshold(threshold)
      list = []
      Array(@pattern).each {|prefix|
        pos = (prefix =~ /\/$/ ? 0 : File.basename(prefix).length)
        l = select_by_dir_pattern("#{prefix}*#{@suffix}")
        list += l.sort.select {|name|
          threshold > File.basename(name, @suffix.to_s)[pos..-1]
        }
      }
      return list
    end

    # DIRパターンを指定して対象を取得する。
    private
    def select_by_dir_pattern(dirpat)
      if @regexp.nil? || @regexp.empty?
        return Dir.glob(dirpat)
      else
        re = Regexp.new(@regexp)
        if @cond.nil? || @cond.empty?
          return Dir.glob(dirpat).select {|name| name =~ re }
        else
          return Dir.glob(dirpat).select {|name|
            next false unless name =~ re
            eval(@cond)
          }
        end
      end
    end

  end
end
