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

require 'time'

module FileAdmin

  # 時間ユーティリティ
  module TimeUtils

    # 起点時刻から差分時間を変異させた時刻を算出する。
    def calculate_time(time, diff)
      tm = time.strftime("%Y/%m/%d %H:%M:%S")
      out = %x{date -d "#{tm} #{diff}" +"%Y/%m/%d %H:%M:%S" 2>&1}
      unless $? == 0
        raise ArgumentError, out
      end
      return Time.parse(out)
    end

  end
end
