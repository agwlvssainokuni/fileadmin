# -*- coding: utf-8 -*-
#
#  Copyright 2012 Norio Agawa
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

require File.join(File.dirname(__FILE__), '../file_admin/logger')
require File.join(File.dirname(__FILE__), '../file_admin/validation')


FileAdmin::Logger.console_enabled = false
FileAdmin::Logger.syslog_enabled = false


describe FileAdmin::Validation do
  include FileAdmin::Validation

  before(:all) do
    @logger = FileAdmin::Logger.new()
    @name = "パラメタ名"
  end

  describe "check_required_string" do
    subject { check_required_string(@name, value) }

    context "空でない文字列" do
      let(:value) { "aaa" }
      it { should be_true }
    end
    context "nil" do
      let(:value) { nil }
      it { should be_false }
    end
    context "空文字列" do
      let(:value) { "" }
      it { should be_false }
    end
    context "文字列でない(数値:1)" do
      let(:value) { 1 }
      it { should be_false }
    end
  end

  describe "check_required_array" do
    subject { check_required_array(@name, value) }

    context "空でない配列" do
      let(:value) { ["aaa"] }
      it { should be_true }
    end
    context "nil" do
      let(:value) { nil }
      it { should be_false }
    end
    context "空配列" do
      let(:value) { [] }
      it { should be_false }
    end
    context "空文字列を含む配列" do
      let(:value) { [""] }
      it { should be_false }
    end
    context "配列でない(数値:1)" do
      let(:value) { 1 }
      it { should be_false }
    end
  end

  describe "check_format_strftime" do
    subject { check_format_strftime(@name, value) }

    context "年月日時分秒(%Y%m%d%H%M%S)の並び" do
      context "%Y" do
        let(:value) { "%Y" }
        it { should be_true }
      end
      context "%Y%m" do
        let(:value) { "%Y%m" }
        it { should be_true }
      end
      context "%Y%m%d" do
        let(:value) { "%Y%m%d" }
        it { should be_true }
      end
      context "%Y%m%d%H" do
        let(:value) { "%Y%m%d%H" }
        it { should be_true }
      end
      context "%Y%m%d%H%M" do
        let(:value) { "%Y%m%d%H%M" }
        it { should be_true }
      end
      context "%Y%m%d%H%M%S" do
        let(:value) { "%Y%m%d%H%M%S" }
        it { should be_true }
      end
    end

    context "nil" do
      let(:value) { nil }
      it { should be_true }
    end

    context "空文字列" do
      let(:value) { "" }
      it { should be_true }
    end

    context "月日時分秒(%m%d%H%M%S)の単独指定" do
      context "%m" do
        let(:value) { "%m" }
        it { should be_false }
      end
      context "%d" do
        let(:value) { "%d" }
        it { should be_false }
      end
      context "%H" do
        let(:value) { "%H" }
        it { should be_false }
      end
      context "%M" do
        let(:value) { "%M" }
        it { should be_false }
      end
      context "%S" do
        let(:value) { "%S" }
        it { should be_false }
      end
    end

    context "年月日時分秒(%M%m%d%H%M%S)の中抜き指定" do
      context "%Y%d" do
        let(:value) { "%Y%d" }
        it { should be_false }
      end
      context "%Y%m%H" do
        let(:value) { "%Y%m%H" }
        it { should be_false }
      end
      context "%Y%m%d%M" do
        let(:value) { "%Y%m%d%M" }
        it { should be_false }
      end
      context "%Y%m%d%H%S" do
        let(:value) { "%Y%m%d%H%S" }
        it { should be_false }
      end
    end
  end

  describe "check_format_period" do
    subject { check_format_period(@name, value) }

    context "年月週日時分秒" do
      context "123 year ago" do
        let(:value) { "123 year ago" }
        it { should be_true }
      end
      context "123 years ago" do
        let(:value) { "123 years ago" }
        it { should be_true }
      end
      context "123 month ago" do
        let(:value) { "123 month ago" }
        it { should be_true }
      end
      context "123 months ago" do
        let(:value) { "123 months ago" }
        it { should be_true }
      end
      context "123 week ago" do
        let(:value) { "123 week ago" }
        it { should be_true }
      end
      context "123 weeks ago" do
        let(:value) { "123 weeks ago" }
        it { should be_true }
      end
      context "123 day ago" do
        let(:value) { "123 day ago" }
        it { should be_true }
      end
      context "123 days ago" do
        let(:value) { "123 days ago" }
        it { should be_true }
      end
      context "123 hour ago" do
        let(:value) { "123 hour ago" }
        it { should be_true }
      end
      context "123 hours ago" do
        let(:value) { "123 hours ago" }
        it { should be_true }
      end
      context "123 minute ago" do
        let(:value) { "123 minute ago" }
        it { should be_true }
      end
      context "123 minutes ago" do
        let(:value) { "123 minutes ago" }
        it { should be_true }
      end
      context "123 second ago" do
        let(:value) { "123 second ago" }
        it { should be_true }
      end
      context "123 seconds ago" do
        let(:value) { "123 seconds ago" }
        it { should be_true }
      end
    end

    context "nil" do
      let(:value) { nil }
      it { should be_true }
    end

    context "空文字列" do
      let(:value) { "" }
      it { should be_true }
    end

    context "数字指定なし" do
      context "year ago" do
        let(:value) { "year ago" }
        it { should be_false }
      end
      context "years ago" do
        let(:value) { "years ago" }
        it { should be_false }
      end
      context "month ago" do
        let(:value) { "month ago" }
        it { should be_false }
      end
      context "months ago" do
        let(:value) { "months ago" }
        it { should be_false }
      end
      context "week ago" do
        let(:value) { "week ago" }
        it { should be_false }
      end
      context "weeks ago" do
        let(:value) { "weeks ago" }
        it { should be_false }
      end
      context "day ago" do
        let(:value) { "day ago" }
        it { should be_false }
      end
      context "days ago" do
        let(:value) { "days ago" }
        it { should be_false }
      end
      context "hour ago" do
        let(:value) { "hour ago" }
        it { should be_false }
      end
      context "hours ago" do
        let(:value) { "hours ago" }
        it { should be_false }
      end
      context "minute ago" do
        let(:value) { "minute ago" }
        it { should be_false }
      end
      context "minutes ago" do
        let(:value) { "minutes ago" }
        it { should be_false }
      end
      context "second ago" do
        let(:value) { "second ago" }
        it { should be_false }
      end
      context "seconds ago" do
        let(:value) { "seconds ago" }
        it { should be_false }
      end
    end

    context "単位指定なし" do
      context "123 ago" do
        let(:value) { "123 ago" }
        it { should be_false }
      end
    end

    context "agoなし" do
      context "123 year" do
        let(:value) { "123 year" }
        it { should be_false }
      end
      context "123 years" do
        let(:value) { "123 years" }
        it { should be_false }
      end
      context "123 month" do
        let(:value) { "123 month" }
        it { should be_false }
      end
      context "123 months" do
        let(:value) { "123 months" }
        it { should be_false }
      end
      context "123 week" do
        let(:value) { "123 week" }
        it { should be_false }
      end
      context "123 weeks" do
        let(:value) { "123 weeks" }
        it { should be_false }
      end
      context "123 day" do
        let(:value) { "123 day" }
        it { should be_false }
      end
      context "123 days" do
        let(:value) { "123 days" }
        it { should be_false }
      end
      context "123 hour" do
        let(:value) { "123 hour" }
        it { should be_false }
      end
      context "123 hours" do
        let(:value) { "123 hours" }
        it { should be_false }
      end
      context "123 minute" do
        let(:value) { "123 minute" }
        it { should be_false }
      end
      context "123 minutes" do
        let(:value) { "123 minutes" }
        it { should be_false }
      end
      context "123 second" do
        let(:value) { "123 second" }
        it { should be_false }
      end
      context "123 seconds" do
        let(:value) { "123 seconds" }
        it { should be_false }
      end
    end

  end
end
