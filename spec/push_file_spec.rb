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

require File.join(File.dirname(__FILE__), 'helper')
require File.join(File.dirname(__FILE__), '../file_admin/push_file')

FileAdmin::Logger.console_enabled = false
FileAdmin::Logger.syslog_enabled = false


describe FileAdmin::PushFile do

  subject { object_maker(FileAdmin::PushFile, conf) }

  let(:base_conf) { {
      "label" => "リモート退避試験",
      "basedir" => "#{Dir.pwd}/testdir/src/",
      "host" => "localhost",
      "rdir" => "#{Dir.pwd}/testdir/dest/",
      "pattern" => [ "file1_*.txt", "file2_*.txt" ],
    } }


  describe "valid?" do

    context "全指定 (patternは配列)" do
      let(:conf) { base_conf }
      it { expect(subject).to be_valid }
    end

    context "全指定 (patternは文字列)" do
      let(:conf) { base_conf.merge("pattern" => "file_*.txt") }
      it { expect(subject).to be_valid }
    end

    context "labelなし" do
      let(:conf) { base_conf.merge("label" => nil) }
      it { expect(subject).not_to be_valid }
    end

    context "basedirなし" do
      let(:conf) { base_conf.merge("basedir" => nil) }
      it { expect(subject).not_to be_valid }
    end

    context "hostなし" do
      let(:conf) { base_conf.merge("host" => nil) }
      it { expect(subject).not_to be_valid }
    end

    context "rdirなし" do
      let(:conf) { base_conf.merge("rdir" => nil) }
      it { expect(subject).not_to be_valid }
    end

    context "patternなし" do
      let(:conf) { base_conf.merge("pattern" => nil) }
      it { expect(subject).not_to be_valid }
    end

    context "patternが空配列" do
      let(:conf) { base_conf.merge("pattern" => [ ] ) }
      it { expect(subject).not_to be_valid }
    end

    context "patternが空文字の配列" do
      let(:conf) { base_conf.merge("pattern" => [ "" ] ) }
      it { expect(subject).not_to be_valid }
    end
  end


  describe "process" do
    let(:time) { Time.now }
    let(:timestamp) {
      (0..2).collect {|i| %x{date -d'#{i} days ago' +%Y%m%d}.chop }
    }
    let(:file_list_1) { timestamp.collect {|dt| "file1_#{dt}.txt" } }
    let(:file_list_2) { timestamp.collect {|dt| "file2_#{dt}.txt" } }
    let(:file_list) { file_list_1 + file_list_2 }
    let(:files_not_in_process) {
      file_list.reject {|f| files_in_process.include?(f) }
    }

    before(:each) do
      %x{mkdir -p testdir/src}
      %x{mkdir -p testdir/dest}
      file_list.each {|f|
        %x{echo #{f} > testdir/src/#{f}}
      }
    end
    after(:each) do
      %x{chmod -R +w testdir}
      %x{rm -rf testdir}
    end


    describe "正常系" do

      shared_examples_for "退避して正常終了" do
        before do
          @retval = subject.process(time, dry_run)
        end
        context "通常 (retval,dest)" do
          let(:dry_run) { false }
          it { expect(@retval).to be_truthy }
          it {
            files_in_process.each {|f|
              expect(Pathname("testdir/dest/#{f}")).to be_file
            }
          }
          it {
            files_not_in_process.each {|f|
              expect(Pathname("testdir/dest/#{f}")).not_to exist
            }
          }
        end
        context "ドライ (retval,dest)" do
          let(:dry_run) { true }
          it { expect(@retval).to be_truthy }
          it {
            file_list.each {|f|
              expect(Pathname("testdir/dest/#{f}")).not_to exist
            }
          }
        end
      end

      describe "絞込みなし" do
        it_behaves_like "退避して正常終了"
        let(:files_in_process) { file_list_1 + file_list_2 }
        let(:conf) { base_conf }
      end

      describe "patternで絞込み" do
        it_behaves_like "退避して正常終了"
        let(:files_in_process) { file_list_1 }
        let(:conf) { base_conf.merge("pattern" => "file1_*.txt") }
      end

      describe "patternで絞込み" do
        it_behaves_like "退避して正常終了"
        let(:files_in_process) { file_list_2 }
        let(:conf) { base_conf.merge("pattern" => "file2_*.txt") }
      end
    end


    describe "境界系" do

      shared_examples_for "退避しないで正常終了" do
        before do
          @retval = subject.process(time, dry_run)
        end
        context "通常 (retval,dest)" do
          let(:dry_run) { false }
          it { expect(@retval).to be_truthy }
          it {
            file_list.each {|f|
              expect(Pathname("testdir/dest/#{f}")).not_to exist
            }
          }
        end
        context "ドライ (retval,dest)" do
          let(:dry_run) { true }
          it { expect(@retval).to be_truthy }
          it {
            file_list.each {|f|
              expect(Pathname("testdir/dest/#{f}")).not_to exist
            }
          }
        end
      end

      describe "pattern絞込みで0件" do
        it_behaves_like "退避しないで正常終了"
        let(:conf) {
          base_conf.merge("pattern" => ["file_*.txt"])
        }
      end
    end


    describe "異常系" do

      describe "basedir不正" do
        let(:conf) { base_conf.merge("basedir" => "testdir/nosrc") }
        before do
          @retval = subject.process(time, dry_run)
        end

        context "通常 (retval,dest)" do
          let(:dry_run) { false }
          it { expect(@retval).to be_falsey }
          it {
            file_list.each {|f|
              expect(Pathname("testdir/dest/#{f}")).not_to exist
            }
          }
        end
        context "ドライ (retval,dest); dryでもchdirする" do
          let(:dry_run) { true }
          # dry_runでもchdirするのでfalse
          it { expect(@retval).to be_falsey }
          it {
            file_list.each {|f|
              expect(Pathname("testdir/dest/#{f}")).not_to exist
            }
          }
        end
      end

      describe "移動失敗 (書込権限なし)" do
        let(:conf) { base_conf }
        before do
          %x{chmod a-x testdir/dest/}
          @retval = subject.process(time, dry_run)
        end
        after do
          %x{chmod a+x testdir/dest/}
        end

        context "通常 (retval,dest)" do
          let(:dry_run) { false }
          it { expect(@retval).to be_falsey }
          it {
            file_list.each {|f|
              expect(Pathname("testdir/dest/#{f}")).not_to exist
            }
          }
        end
        context "ドライ (retval,dest)" do
          let(:dry_run) { true }
          it { expect(@retval).to be_truthy }
          it {
            file_list.each {|f|
              expect(Pathname("testdir/dest/#{f}")).not_to exist
            }
          }
        end
      end

    end
  end

end
