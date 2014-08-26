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

module FileAdmin

  # 入力値チェック
  module Validation

    # 空文字列判定
    def is_empty?(value)
      return value.nil? || value.empty?
    end

    # 文字列必須チェック
    def check_required_string(name, value)
      if value.nil? || value.class != String || value.empty?
        @logger.error("'%s' must not be empty", name)
        return false
      end
      return true
    end

    # 文字列配列必須チェック
    def check_required_array(name, value)
      if value.nil? || value.class != Array || value.empty?
        @logger.error("'%s' must not be empty", name)
        return false
      end
      value.each {|v|
        return false unless check_required_string(name, v)
      }
      return true
    end

    # 日時文字列書式形式チェック
    def check_format_strftime(name, value)
      return true if is_empty?(value)
      return true if value =~ /^%Y(-?%m(-?%d(-?%H(-?%M(-?%S)?)?)?)?)?$/
      @logger.error("'%s' must be strftime format: %s", name, value)
      return false
    end

    # 期間指定形式チェック
    def check_format_period(name, value)
      return true if is_empty?(value)
      return true if value =~ /^\d+ +(second|minute|hour|day|week|month|year)s? +ago$/
      @logger.error("'%s' must be period format: %s", name, value)
      return false
    end

  end
end
