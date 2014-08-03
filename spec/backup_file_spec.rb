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
require File.join(File.dirname(__FILE__), '../file_admin/backup_file')

FileAdmin::Logger.console_enabled = false
FileAdmin::Logger.syslog_enabled = false


describe FileAdmin::BackupFile do

  subject { object_maker(FileAdmin::BackupFile, conf) }

  let(:base_conf) { {
      "label" => "ファイル退避試験",
      "basedir" => "#{Dir.pwd}/testdir/src",
      "pattern" => [ "dir1/file1_", "dir2/file2_" ],
      "regexp" => "file[12]_(\\d{8})\\.txt$",
      "cond" => "$1 > '00000000'",
      "suffix" => ".txt",
      "tsformat" => "%Y%m%d",
      "grace_period" => "2 days ago",
      "to_dir" => "#{Dir.pwd}/testdir/dest"
    } }


  describe "valid?" do

    context "全指定 (patternは配列)" do
      let(:conf) { base_conf }
      it { expect(subject).to be_valid }
    end

    context "全指定 (patternは文字列)" do
      let(:conf) { base_conf.merge("pattern" => "dir1/file_") }
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

    context "regexpなし" do
      let(:conf) { base_conf.merge("regexp" => nil) }
      it { expect(subject).to be_valid }
    end

    context "condなし" do
      let(:conf) { base_conf.merge("cond" => nil) }
      it { expect(subject).to be_valid }
    end

    context "suffixなし" do
      let(:conf) { base_conf.merge("suffix" => nil) }
      it { expect(subject).to be_valid }
    end

    context "tsformatなし" do
      let(:conf) { base_conf.merge("tsformat" => nil) }
      it { expect(subject).not_to be_valid }
    end

    context "tsformat形式不正" do
      let(:conf) { base_conf.merge("tsformat" => "invalid") }
      it { expect(subject).not_to be_valid }
    end

    context "grace_periodなし" do
      let(:conf) { base_conf.merge("grace_period" => nil) }
      it { expect(subject).not_to be_valid }
    end

    context "grace_period形式不正" do
      let(:conf) { base_conf.merge("grace_period" => "invalid") }
      it { expect(subject).not_to be_valid }
    end

    context "to_dirなし" do
      let(:conf) { base_conf.merge("to_dir" => nil) }
      it { expect(subject).not_to be_valid }
    end
  end


  describe "process" do
    let(:time) { Time.now }
    let(:timestamp) {
      (0..5).collect {|i| %x{date -d'#{i} days ago' +%Y%m%d}.chop }
    }
    let(:file_list_1) { timestamp.collect {|dt| "dir1/file1_#{dt}.txt" } }
    let(:file_list_2) { timestamp.collect {|dt| "dir2/file2_#{dt}.txt" } }
    let(:file_list) { file_list_1 + file_list_2 }
    let(:files_not_in_process) {
      file_list.reject {|f| files_in_process.include?(f) }
    }

    before(:each) do
      %x{mkdir -p testdir/src}
      %x{mkdir -p testdir/dest}
      file_list.each {|f|
        %x{mkdir -p testdir/src/#{File.dirname(f)}}
        %x{touch testdir/src/#{f}}
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
        context "通常 (retval,src(proc,not),dest(proc,not))" do
          let(:dry_run) { false }
          it { expect(@retval).to be_truthy }
          it {
            files_in_process.each {|f|
              expect(Pathname("testdir/src/#{f}")).not_to exist
            }
          }
          it {
            files_not_in_process.each {|f|
              expect(Pathname("testdir/src/#{f}")).to be_file
            }
          }
          it {
            files_in_process.each {|f|
              bname = File.basename(f)
              expect(Pathname("testdir/dest/#{bname}")).to be_file
            }
          }
          it {
            files_not_in_process.each {|f|
              bname = File.basename(f)
              expect(Pathname("testdir/dest/#{bname}")).not_to exist
            }
          }
        end
        context "ドライ (retval,src,dest)" do
          let(:dry_run) { true }
          it { expect(@retval).to be_truthy }
          it {
            file_list.each {|f|
              expect(Pathname("testdir/src/#{f}")).to be_file
            }
          }
          it {
            file_list.each {|f|
              bname = File.basename(f)
              expect(Pathname("testdir/dest/#{bname}")).not_to exist
            }
          }
        end
      end

      describe "絞込みなし" do
        it_behaves_like "退避して正常終了"
        let(:files_in_process) {
          file_list_1[3..-1] + file_list_2[3..-1]
        }
        let(:conf) { base_conf }
      end

      describe "patternで絞込み" do
        it_behaves_like "退避して正常終了"
        let(:files_in_process) {
          file_list_1[3..-1]
        }
        let(:conf) { base_conf.merge("pattern" => "dir1/file1_") }
      end

      describe "regexpで絞込み" do
        it_behaves_like "退避して正常終了"
        let(:files_in_process) {
          file_list_1[3..-1]
        }
        let(:conf) {
          base_conf.merge("regexp" => "file1_(\\d{8})\\.txt$")
        }
      end

      describe "絞込みなし" do
        it_behaves_like "退避して正常終了"
        let(:files_in_process) {
          file_list_1[3..-1] + file_list_2[3..-1]
        }
        let(:conf) { base_conf }
      end

      describe "condで絞込み" do
        it_behaves_like "退避して正常終了"
        let(:files_in_process) {
          file_list_1[3..-2] + file_list_2[3..-2]
        }
        let(:conf) {
          dt = %x{date -d'5 days ago' +%Y%m%d}.chop
          base_conf.merge("cond" => "$1 > '#{dt}'")
        }
      end
    end


    describe "境界系" do

      shared_examples_for "退避しないで正常終了" do
        before do
          @retval = subject.process(time, dry_run)
        end
        context "通常 (retval,src,dest)" do
          let(:dry_run) { false }
          it { expect(@retval).to be_truthy }
          it {
            file_list.each {|f|
              expect(Pathname("testdir/src/#{f}")).to be_file
            }
          }
          it {
            file_list.each {|f|
              bname = File.basename(f)
              expect(Pathname("testdir/dest/#{bname}")).not_to exist
            }
          }
        end
        context "ドライ (retval,src,dest)" do
          let(:dry_run) { true }
          it { expect(@retval).to be_truthy }
          it {
            file_list.each {|f|
              expect(Pathname("testdir/src/#{f}")).to be_file
            }
          }
          it {
            file_list.each {|f|
              bname = File.basename(f)
              expect(Pathname("testdir/dest/#{bname}")).not_to exist
            }
          }
        end
      end

      describe "pattern絞込みでディレクトリのみ" do
        it_behaves_like "退避しないで正常終了"
        let(:conf) {
          base_conf.merge("pattern" => [ "dir1", "dir2" ],
                          "cond" => nil, "regexp" => nil,
                          "suffix" => nil)
        }
      end

      describe "pattern絞込みで0件" do
        it_behaves_like "退避しないで正常終了"
        let(:conf) {
          base_conf.merge("pattern" => ["dir1/file2_", "dir2/file1_"])
        }
      end

      describe "regexp絞込みで0件" do
        it_behaves_like "退避しないで正常終了"
        let(:conf) {
          base_conf.merge("regexp" => "file[34]_(\\d{8})\\.txt$")
        }
      end

      describe "cond絞込みで0件" do
        it_behaves_like "退避しないで正常終了"
        let(:conf) {
          base_conf.merge( "cond" => "$1 > '9'" )
        }
      end

      describe "grace_periodが0" do
        it_behaves_like "退避しないで正常終了"
        let(:conf) {
          base_conf.merge("grace_period" => "0 days ago")
        }
      end
    end


    describe "異常系" do

      describe "basedir不正" do
        let(:conf) { base_conf.merge("basedir" => "testdir/nosrc") }
        before do
          @retval = subject.process(time, dry_run)
        end

        context "通常 (retval,src,dest)" do
          let(:dry_run) { false }
          it { expect(@retval).to be_falsey }
          it {
            file_list.each {|f|
              expect(Pathname("testdir/src/#{f}")).to be_file
            }
          }
          it {
            file_list.each {|f|
              bname = File.basename(f)
              expect(Pathname("testdir/dest/#{bname}")).not_to exist
            }
          }
        end
        context "ドライ (retval,src,dest); dryでもchdirする" do
          let(:dry_run) { true }
          # dry_runでもchdirするのでfalse
          it { expect(@retval).to be_falsey }
          it {
            file_list.each {|f|
              expect(Pathname("testdir/src/#{f}")).to be_file
            }
          }
          it {
            file_list.each {|f|
              bname = File.basename(f)
              expect(Pathname("testdir/dest/#{bname}")).not_to exist
            }
          }
        end
      end

      describe "移動失敗 (書込権限なし)" do
        let(:conf) { base_conf }
        before do
          %x{chmod -w testdir/src/dir1}
          %x{chmod -w testdir/src/dir2}
          @retval = subject.process(time, dry_run)
        end

        context "通常 (retval,src,dest)" do
          let(:dry_run) { false }
          it { expect(@retval).to be_falsey }
          it {
            file_list.each {|f|
              expect(Pathname("testdir/src/#{f}")).to be_file
            }
          }
          it {
            file_list.each {|f|
              bname = File.basename(f)
              expect(Pathname("testdir/dest/#{bname}")).not_to exist
            }
          }
        end
        context "ドライ (retval,src,dest)" do
          let(:dry_run) { true }
          it { expect(@retval).to be_truthy }
          it {
            file_list.each {|f|
              expect(Pathname("testdir/src/#{f}")).to be_file
            }
          }
          it {
            file_list.each {|f|
              bname = File.basename(f)
              expect(Pathname("testdir/dest/#{bname}")).not_to exist
            }
          }
        end
      end

    end
  end

end
