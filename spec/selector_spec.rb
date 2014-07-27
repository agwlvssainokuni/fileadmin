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
require File.join(File.dirname(__FILE__), '../file_admin/selector')


FileAdmin::Logger.console_enabled = false
FileAdmin::Logger.syslog_enabled = false


describe FileAdmin::Selector do
  include FileAdmin::Selector

  before(:all) do
    @logger = FileAdmin::Logger.new()
    @list = [
             "testdir/dir1/file11.txt",
             "testdir/dir1/file12.txt",
             "testdir/dir2/file21.txt",
             "testdir/dir2/file22.txt",
             "testdir/dir3/file31.lst",
             "testdir/dir3/file32.lst"
            ]
  end

  before(:each) do
    @list.each {|file|
      %x{mkdir -p #{File.dirname(file)}}
      %x{touch #{file}}
    }
  end

  after(:each) do
    %x{rm -rf testdir}
  end

  describe "collect_targets" do
    subject { collect_targets() }

    context "@patternを指定(文字列)して絞込み" do
      before do
        @pattern = "testdir/*/*"
      end
      it { is_expected.to match_array @list }
    end
    context "@patternを指定(配列)して絞込み" do
      before do
        @pattern = [
                    "testdir/dir1/*", "testdir/dir2/*", "testdir/dir3/*"
                   ]
      end
      it { is_expected.to match_array @list }
    end
    context "@patternと@regexpを指定して絞込み" do
      before do
        @pattern = "testdir/*/*"
        @regexp = "file(\\d{2})\\.txt$"
      end
      it { is_expected.to match_array @list[0..3] }
    end
    context "@patternと@regexpと@condを指定して絞込み" do
      before do
        @pattern = "testdir/*/*"
        @regexp = "file(\\d{2})\\.txt$"
        @cond = "$1.to_i > 20"
      end
      it { is_expected.to match_array @list[2..3] }
    end
    context "@pattern(文字列)と@excludeを指定して絞込み" do
      before do
        @pattern = "testdir/*/*"
        @exclude = "1"
      end
      it { is_expected.to match_array @list[0..4] }
    end
    context "@pattern(配列)と@excludeを指定して絞込み" do
      before do
        @pattern = [
                    "testdir/dir1/*", "testdir/dir2/*", "testdir/dir3/*"
                   ]
        @exclude = "1"
      end
      it { is_expected.to match_array [@list[0], @list[2], @list[4]] }
    end
  end

  describe "collect_targets_by_threshold" do
    subject { collect_targets_by_threshold("30") }

    context "@patternを指定(文字列)して絞込み" do
      before do
        @pattern = "testdir/*/file"
        @suffix = ".txt"
      end
      it { is_expected.to match_array @list[0..3] }
    end
    context "@patternを指定(配列)して絞込み" do
      before do
        @pattern = [
                    "testdir/dir1/file", "testdir/dir2/file", "testdir/dir3/file"
                   ]
        @suffix = ".txt"
      end
      it { is_expected.to match_array @list[0..3] }
    end
    context "@patternと@regexpを指定して絞込み" do
      before do
        @pattern = "testdir/*/file"
        @suffix = ".txt"
        @regexp = "file(\\d1)\\.txt$"
      end
      it { is_expected.to match_array [@list[0], @list[2]] }
    end
    context "@patternと@regexpと@condを指定して絞込み" do
      before do
        @pattern = "testdir/*/file"
        @suffix = ".txt"
        @regexp = "file(\\d1)\\.txt$"
        @cond = "$1.to_i > 20"
      end
      it { is_expected.to match_array [@list[2]] }
    end
  end
end
