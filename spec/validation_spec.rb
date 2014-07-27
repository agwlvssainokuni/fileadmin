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
    subject {
check_required_string(@name, value)
}

    context "空でない文字列" do
      let(:value) { "aaa" }
      it { is_expected.to be_truthy }
    end
    context "nil" do
      let(:value) { nil }
      it { is_expected.to be_falsey }
    end
    context "空文字列" do
      let(:value) { "" }
      it { is_expected.to be_falsey }
    end
    context "文字列でない(数値:1)" do
      let(:value) { 1 }
      it { is_expected.to be_falsey }
    end
  end

  describe "check_required_array" do
    subject { check_required_array(@name, value) }

    context "空でない配列" do
      let(:value) { ["aaa"] }
      it { is_expected.to be_truthy }
    end
    context "nil" do
      let(:value) { nil }
      it { is_expected.to be_falsey }
    end
    context "空配列" do
      let(:value) { [] }
      it { is_expected.to be_falsey }
    end
    context "空文字列を含む配列" do
      let(:value) { [""] }
      it { is_expected.to be_falsey }
    end
    context "配列でない(数値:1)" do
      let(:value) { 1 }
      it { is_expected.to be_falsey }
    end
  end

  describe "check_format_strftime" do
    subject { check_format_strftime(@name, value) }

    context "年月日時分秒(%Y%m%d%H%M%S)の並び" do
      context "%Y" do
        let(:value) { "%Y" }
        it { is_expected.to be_truthy }
      end
      context "%Y%m" do
        let(:value) { "%Y%m" }
        it { is_expected.to be_truthy }
      end
      context "%Y%m%d" do
        let(:value) { "%Y%m%d" }
        it { is_expected.to be_truthy }
      end
      context "%Y%m%d%H" do
        let(:value) { "%Y%m%d%H" }
        it { is_expected.to be_truthy }
      end
      context "%Y%m%d%H%M" do
        let(:value) { "%Y%m%d%H%M" }
        it { is_expected.to be_truthy }
      end
      context "%Y%m%d%H%M%S" do
        let(:value) { "%Y%m%d%H%M%S" }
        it { is_expected.to be_truthy }
      end
    end

    context "nil" do
      let(:value) { nil }
      it { is_expected.to be_truthy }
    end

    context "空文字列" do
      let(:value) { "" }
      it { is_expected.to be_truthy }
    end

    context "月日時分秒(%m%d%H%M%S)の単独指定" do
      context "%m" do
        let(:value) { "%m" }
        it { is_expected.to be_falsey }
      end
      context "%d" do
        let(:value) { "%d" }
        it { is_expected.to be_falsey }
      end
      context "%H" do
        let(:value) { "%H" }
        it { is_expected.to be_falsey }
      end
      context "%M" do
        let(:value) { "%M" }
        it { is_expected.to be_falsey }
      end
      context "%S" do
        let(:value) { "%S" }
        it { is_expected.to be_falsey }
      end
    end

    context "年月日時分秒(%M%m%d%H%M%S)の中抜き指定" do
      context "%Y%d" do
        let(:value) { "%Y%d" }
        it { is_expected.to be_falsey }
      end
      context "%Y%m%H" do
        let(:value) { "%Y%m%H" }
        it { is_expected.to be_falsey }
      end
      context "%Y%m%d%M" do
        let(:value) { "%Y%m%d%M" }
        it { is_expected.to be_falsey }
      end
      context "%Y%m%d%H%S" do
        let(:value) { "%Y%m%d%H%S" }
        it { is_expected.to be_falsey }
      end
    end
  end

  describe "check_format_period" do
    subject { check_format_period(@name, value) }

    context "年月週日時分秒" do
      context "123 year ago" do
        let(:value) { "123 year ago" }
        it { is_expected.to be_truthy }
      end
      context "123 years ago" do
        let(:value) { "123 years ago" }
        it { is_expected.to be_truthy }
      end
      context "123 month ago" do
        let(:value) { "123 month ago" }
        it { is_expected.to be_truthy }
      end
      context "123 months ago" do
        let(:value) { "123 months ago" }
        it { is_expected.to be_truthy }
      end
      context "123 week ago" do
        let(:value) { "123 week ago" }
        it { is_expected.to be_truthy }
      end
      context "123 weeks ago" do
        let(:value) { "123 weeks ago" }
        it { is_expected.to be_truthy }
      end
      context "123 day ago" do
        let(:value) { "123 day ago" }
        it { is_expected.to be_truthy }
      end
      context "123 days ago" do
        let(:value) { "123 days ago" }
        it { is_expected.to be_truthy }
      end
      context "123 hour ago" do
        let(:value) { "123 hour ago" }
        it { is_expected.to be_truthy }
      end
      context "123 hours ago" do
        let(:value) { "123 hours ago" }
        it { is_expected.to be_truthy }
      end
      context "123 minute ago" do
        let(:value) { "123 minute ago" }
        it { is_expected.to be_truthy }
      end
      context "123 minutes ago" do
        let(:value) { "123 minutes ago" }
        it { is_expected.to be_truthy }
      end
      context "123 second ago" do
        let(:value) { "123 second ago" }
        it { is_expected.to be_truthy }
      end
      context "123 seconds ago" do
        let(:value) { "123 seconds ago" }
        it { is_expected.to be_truthy }
      end
    end

    context "nil" do
      let(:value) { nil }
      it { is_expected.to be_truthy }
    end

    context "空文字列" do
      let(:value) { "" }
      it { is_expected.to be_truthy }
    end

    context "数字指定なし" do
      context "year ago" do
        let(:value) { "year ago" }
        it { is_expected.to be_falsey }
      end
      context "years ago" do
        let(:value) { "years ago" }
        it { is_expected.to be_falsey }
      end
      context "month ago" do
        let(:value) { "month ago" }
        it { is_expected.to be_falsey }
      end
      context "months ago" do
        let(:value) { "months ago" }
        it { is_expected.to be_falsey }
      end
      context "week ago" do
        let(:value) { "week ago" }
        it { is_expected.to be_falsey }
      end
      context "weeks ago" do
        let(:value) { "weeks ago" }
        it { is_expected.to be_falsey }
      end
      context "day ago" do
        let(:value) { "day ago" }
        it { is_expected.to be_falsey }
      end
      context "days ago" do
        let(:value) { "days ago" }
        it { is_expected.to be_falsey }
      end
      context "hour ago" do
        let(:value) { "hour ago" }
        it { is_expected.to be_falsey }
      end
      context "hours ago" do
        let(:value) { "hours ago" }
        it { is_expected.to be_falsey }
      end
      context "minute ago" do
        let(:value) { "minute ago" }
        it { is_expected.to be_falsey }
      end
      context "minutes ago" do
        let(:value) { "minutes ago" }
        it { is_expected.to be_falsey }
      end
      context "second ago" do
        let(:value) { "second ago" }
        it { is_expected.to be_falsey }
      end
      context "seconds ago" do
        let(:value) { "seconds ago" }
        it { is_expected.to be_falsey }
      end
    end

    context "単位指定なし" do
      context "123 ago" do
        let(:value) { "123 ago" }
        it { is_expected.to be_falsey }
      end
    end

    context "agoなし" do
      context "123 year" do
        let(:value) { "123 year" }
        it { is_expected.to be_falsey }
      end
      context "123 years" do
        let(:value) { "123 years" }
        it { is_expected.to be_falsey }
      end
      context "123 month" do
        let(:value) { "123 month" }
        it { is_expected.to be_falsey }
      end
      context "123 months" do
        let(:value) { "123 months" }
        it { is_expected.to be_falsey }
      end
      context "123 week" do
        let(:value) { "123 week" }
        it { is_expected.to be_falsey }
      end
      context "123 weeks" do
        let(:value) { "123 weeks" }
        it { is_expected.to be_falsey }
      end
      context "123 day" do
        let(:value) { "123 day" }
        it { is_expected.to be_falsey }
      end
      context "123 days" do
        let(:value) { "123 days" }
        it { is_expected.to be_falsey }
      end
      context "123 hour" do
        let(:value) { "123 hour" }
        it { is_expected.to be_falsey }
      end
      context "123 hours" do
        let(:value) { "123 hours" }
        it { is_expected.to be_falsey }
      end
      context "123 minute" do
        let(:value) { "123 minute" }
        it { is_expected.to be_falsey }
      end
      context "123 minutes" do
        let(:value) { "123 minutes" }
        it { is_expected.to be_falsey }
      end
      context "123 second" do
        let(:value) { "123 second" }
        it { is_expected.to be_falsey }
      end
      context "123 seconds" do
        let(:value) { "123 seconds" }
        it { is_expected.to be_falsey }
      end
    end

  end
end
