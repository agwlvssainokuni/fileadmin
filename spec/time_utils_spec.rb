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
require File.join(File.dirname(__FILE__), '../file_admin/time_utils')


describe FileAdmin::TimeUtils do
  include FileAdmin::TimeUtils

  describe "calculate_time" do
    subject { calculate_time(@time, value) }
    before(:all) { @time = Time.parse("2010/10/10") }

    context "計算可能" do
      let(:value) { "1 year ago 1 month ago 1 day ago" }
      it { is_expected.to eq Time.parse("2009/09/09") }
    end

    context "計算不可(形式不正で例外)" do
      let(:value) { "invalid" }
      it {
        expect { subject }.to raise_error(ArgumentError)
      }
    end
  end

end
