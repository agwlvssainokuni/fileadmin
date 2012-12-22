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
require File.join(File.dirname(__FILE__), '../file_admin/command')

FileAdmin::Logger.console_enabled = false
FileAdmin::Logger.syslog_enabled = false


describe FileAdmin::Command do
  include FileAdmin::Command

  before(:all) do
    @logger = FileAdmin::Logger.new()
  end
  before do
    %x{mkdir -p testdir}
  end
  after do
    %x{chmod -R +w testdir}
    %x{rm -rf testdir}
  end

  describe "mv" do
    subject { mv("testdir/src/file.txt", "testdir/dest") }
    let(:from_file) { Pathname("testdir/src/file.txt") }
    let(:to_file) { Pathname("testdir/dest/file.txt") }

    before do
      %x{mkdir -p testdir/src}
      %x{mkdir -p testdir/dest}
      %x{touch testdir/src/file.txt}
    end

    context "成功 (retval, from_file, to_file)" do
      before do
        @retval = subject
      end
      it { @retval.should be_true }
      it { from_file.should_not exist }
      it { to_file.should be_file }
    end
    context "失敗/権限無し (retval, from_file, to_file)" do
      before do
        %x{chmod -w testdir/dest}
        @retval = subject
      end
      it { @retval.should be_false }
      it { from_file.should be_file }
      it { to_file.should_not exist }
    end
  end

  describe "rm" do
    subject { rm("testdir/file.txt") }
    let(:file) { Pathname("testdir/file.txt") }

    before do
      %x{touch testdir/file.txt}
    end

    context "成功 (retval, file)" do
      before do
        @retval = subject
      end
      it { @retval.should be_true }
      it { file.should_not exist }
    end
    context "失敗/権限なし (retval, file)" do
      before do
        %x{chmod -w testdir}
        @retval = subject
      end
      it { @retval.should be_false }
      it { file.should be_file }
    end
  end

  describe "zip_with_moving_files" do
    subject { zip_with_moving_files("testdir/dest.zip", @list) }
    let(:zipfile) { Pathname("testdir/dest.zip") }

    before(:all) do
      @list = ["testdir/src/dir1/file1.txt", "testdir/src/dir2/file2.txt"]
    end
    before do
      @list.each {|file|
        %x{mkdir -p #{File.dirname(file)}}
        %x{touch #{file}}
      }
    end

    context "成功 (retval, zip, unzip -l, file)" do
      before do
        @retval = subject
      end
      it { @retval.should be_true }
      it { zipfile.should exist }
      it {
        @list.each {|file|
          %x{unzip -l #{zipfile} #{file} 2>&1}
          $?.should == 0
        }
      }
      it {
        @list.each {|file| Pathname(file).should_not exist }
      }
    end
    context "失敗/権限なし (retval, zip, file)" do
      before do
        %x{chmod -w testdir}
        @retval = subject
      end
      it { @retval.should be_false }
      it { zipfile.should_not be_file }
      it {
        @list.each {|file| Pathname(file).should be_file }
      }
    end
  end

  describe "zip_without_moving_files" do
    subject { zip_without_moving_files("testdir/dest.zip", @list) }
    let(:zipfile) { Pathname("testdir/dest.zip") }

    before(:all) do
      @list = ["testdir/src/dir1/file1.txt", "testdir/src/dir2/file2.txt"]
    end
    before do
      @list.each {|file|
        %x{mkdir -p #{File.dirname(file)}}
        %x{touch #{file}}
      }
    end

    context "成功 (retval, zip, unzip -l, file)" do
      before do
        @retval = subject
      end
      it { @retval.should be_true }
      it { zipfile.should exist }
      it {
        @list.each {|file|
          %x{unzip -l #{zipfile} #{file} 2>&1}
          $?.should == 0
        }
      }
      it {
        @list.each {|file| Pathname(file).should be_file }
      }
    end
    context "失敗/権限なし (retval, zip, file)" do
      before do
        %x{chmod -w testdir}
        @retval = subject
      end
      it { @retval.should be_false }
      it { zipfile.should_not be_file }
      it {
        @list.each {|file| Pathname(file).should be_file }
      }
    end
  end

end
