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

require 'yaml'
require File.join(File.dirname(__FILE__), '../file_admin/foreach_archive')

FileAdmin::Logger.console_enabled = false
FileAdmin::Logger.syslog_enabled = false


describe FileAdmin::ForeachArchive do

  subject { YAML.object_maker(FileAdmin::ForeachArchive, conf) }

  let(:base_conf) { {
      "label" => "一対一アーカイブ試験",
      "basedir" => "#{Dir.pwd}/testdir/src",
      "pattern" => [ "dir1/*", "dir2/*" ],
      "regexp" => "file(\\d{2})\\.txt$",
      "cond" => "$1.to_i > 10",
      "exclude" => "0",
      "suffix" => ".txt",
      "to_dir" => "#{Dir.pwd}/testdir/dest",
      "chown" => "#{%x{whoami}.chop}:#{%x{whoami}.chop}"
    } }


  describe "valid?" do

    context "全指定 (patternは配列)" do
      let(:conf) { base_conf }
      it { subject.should be_valid }
    end

    context "全指定 (patternは文字列)" do
      let(:conf) { base_conf.merge("pattern" => "dir1/*") }
      it { subject.should be_valid }
    end

    context "labelなし" do
      let(:conf) { base_conf.merge("label" => nil) }
      it { subject.should_not be_valid }
    end

    context "basedirなし" do
      let(:conf) { base_conf.merge("basedir" => nil) }
      it { subject.should_not be_valid }
    end

    context "patternなし" do
      let(:conf) { base_conf.merge("pattern" => nil) }
      it { subject.should_not be_valid }
    end

    context "patternが空配列" do
      let(:conf) { base_conf.merge("pattern" => [ ] ) }
      it { subject.should_not be_valid }
    end

    context "patternが空文字の配列" do
      let(:conf) { base_conf.merge("pattern" => [ "" ] ) }
      it { subject.should_not be_valid }
    end

    context "regexpなし" do
      let(:conf) { base_conf.merge("regexp" => nil) }
      it { subject.should be_valid }
    end

    context "condなし" do
      let(:conf) { base_conf.merge("cond" => nil) }
      it { subject.should be_valid }
    end

    context "excludeなし" do
      let(:conf) { base_conf.merge("exclude" => nil) }
      it { subject.should be_valid }
    end

    context "suffixなし" do
      let(:conf) { base_conf.merge("suffix" => nil) }
      it { subject.should be_valid }
    end

    context "to_dirなし" do
      let(:conf) { base_conf.merge("to_dir" => nil) }
      it { subject.should be_valid }
    end

    context "chownなし" do
      let(:conf) { base_conf.merge("chown" => nil) }
      it { subject.should be_valid }
    end
  end


  describe "process" do
    let(:time) { Time.now }
    let(:arcdir) { "testdir/dest" }
    let(:files_not_in_archive) {
      file_list.reject {|f| files_in_archive.include?(f) }
    }

    def arcfile(f)
      dname = File.dirname(f)
      bname = File.basename(f, ".txt")
      if arcdir
        return "#{arcdir}/#{bname}.zip"
      else
        return "testdir/src/#{dname}/#{bname}.zip"
      end
    end

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

      shared_examples_for "一対一アーカイブして正常終了" do
        before do
          @retval = subject.process(time, dry_run)
        end
        context "通常 (retval,inarc(arc,orig,unzip),not_inarc(arc,orig))" do
          let(:dry_run) { false }
          it { @retval.should be_true }
          it {
            files_in_archive.each {|f|
              Pathname(arcfile(f)).should be_file
            }
          }
          it {
            files_in_archive.each {|f|
              Pathname("testdir/src/#{f}").should_not exist
            }
          }
          it {
            files_in_archive.each {|f|
              %x{unzip -l #{arcfile(f)} #{f} 2>&1}
              $?.should == 0
            }
          }
          it {
            files_not_in_archive.each {|f|
              Pathname(arcfile(f)).should_not exist
            }
          }
          it {
            files_not_in_archive.each {|f|
              Pathname("testdir/src/#{f}").should be_file
            }
          }
        end
        context "ドライ (retval,arcfile,file_list)" do
          let(:dry_run) { true }
          it { @retval.should be_true }
          it {
            file_list.each {|f|
              Pathname(arcfile(f)).should_not exist
            }
          }
          it {
            file_list.each {|f|
              Pathname("testdir/src/#{f}").should be_file
            }
          }
        end
      end

      describe "単一ファイル" do
        it_behaves_like "一対一アーカイブして正常終了"
        let(:file_list) { [ "dir1/file11.txt" ] }
        let(:files_in_archive) { file_list }
        let(:conf) { base_conf }
      end

      describe "複数ファイル (絞込みなし)" do
        it_behaves_like "一対一アーカイブして正常終了"
        let(:file_list) {
          [
           "dir1/file11.txt", "dir1/file12.txt",
           "dir2/file21.txt", "dir2/file22.txt"
          ]
        }
        let(:files_in_archive) { file_list }
        let(:conf) { base_conf }
      end

      describe "複数ファイル (patternで絞込み)" do
        it_behaves_like "一対一アーカイブして正常終了"
        let(:file_list) {
          [
           "dir1/file11.txt", "dir1/file12.txt",
           "dir2/file21.txt", "dir2/file22.txt"
          ]
        }
        let(:files_in_archive) { [ file_list[0], file_list[1] ] }
        let(:conf) { base_conf.merge("pattern" => "dir1/*") }
      end

      describe "複数ファイル (regexpで絞込み)" do
        it_behaves_like "一対一アーカイブして正常終了"
        let(:file_list) {
          [
           "dir1/file11.txt", "dir1/file12.txt",
           "dir2/file21.txt", "dir2/file22.txt"
          ]
        }
        let(:files_in_archive) { [ file_list[0], file_list[2] ] }
        let(:conf) { base_conf.merge("regexp" => "file(\\d1)\\.txt$") }
      end

      describe "複数ファイル (condで絞込み)" do
        it_behaves_like "一対一アーカイブして正常終了"
        let(:file_list) {
          [
           "dir1/file11.txt", "dir1/file12.txt",
           "dir2/file21.txt", "dir2/file22.txt"
          ]
        }
        let(:files_in_archive) { [ file_list[2], file_list[3] ] }
        let(:conf) { base_conf.merge("cond" => "$1.to_i > 20") }
      end

      describe "複数ファイル (excludeで絞込み)" do
        it_behaves_like "一対一アーカイブして正常終了"
        let(:file_list) {
          [
           "dir1/file11.txt", "dir1/file12.txt",
           "dir2/file21.txt", "dir2/file22.txt"
          ]
        }
        let(:files_in_archive) { [ file_list[0], file_list[1] ] }
        let(:conf) {
          base_conf.merge("pattern" => "*/*", "exclude" => "2")
        }
      end

      describe "複数ファイル (to_dir指定なし)" do
        it_behaves_like "一対一アーカイブして正常終了"
        let(:file_list) {
          [
           "dir1/file11.txt", "dir1/file12.txt",
           "dir2/file21.txt", "dir2/file22.txt"
          ]
        }
        let(:files_in_archive) { file_list }
        let(:conf) { base_conf.merge("to_dir" => nil) }
        let(:arcdir) { nil }
      end

      describe "複数ファイル (chown指定なし)" do
        it_behaves_like "一対一アーカイブして正常終了"
        let(:file_list) {
          [
           "dir1/file11.txt", "dir1/file12.txt",
           "dir2/file21.txt", "dir2/file22.txt"
          ]
        }
        let(:files_in_archive) { file_list }
        let(:conf) { base_conf.merge("chown" => nil) }
      end
    end


    describe "境界系" do

      shared_examples_for "一対一アーカイブしないで正常終了" do
        before do
          @retval = subject.process(time, dry_run)
        end
        context "通常 (retval,arcfile,file_list)" do
          let(:dry_run) { false }
          it { @retval.should be_true }
          it {
            file_list.each {|f|
              Pathname(arcfile(f)).should_not exist
            }
          }
          it {
            file_list.each {|f|
              Pathname("testdir/src/#{f}").should be_file
            }
          }
        end
        context "ドライ (retval,arcfile,file_list)" do
          let(:dry_run) { true }
          it { @retval.should be_true }
          it {
            file_list.each {|f|
              Pathname(arcfile(f)).should_not exist
            }
          }
          it {
            file_list.each {|f|
              Pathname("testdir/src/#{f}").should be_file
            }
          }
        end
      end

      describe "pattern絞込みでディレクトリのみ" do
        it_behaves_like "一対一アーカイブしないで正常終了"
        let(:file_list) {
          [
           "dir1/file11.txt", "dir1/file12.txt",
           "dir2/file21.txt", "dir2/file22.txt"
          ]
        }
        let(:conf) {
          base_conf.merge("pattern" => "*", "cond" => nil,
                          "regexp" => nil, "exclude" => nil)
        }
      end

      describe "regexp絞込みでディレクトリのみ" do
        it_behaves_like "一対一アーカイブしないで正常終了"
        let(:file_list) {
          [
           "dir1/file11.txt", "dir1/file12.txt",
           "dir2/file21.txt", "dir2/file22.txt"
          ]
        }
        let(:conf) { base_conf.merge("regexp" => "(\\d{2})\\.not$") }
      end

      describe "pattern絞込みでディレクトリのみ" do
        it_behaves_like "一対一アーカイブしないで正常終了"
        let(:file_list) {
          [
           "dir1/file11.txt", "dir1/file12.txt",
           "dir2/file21.txt", "dir2/file22.txt"
          ]
        }
        let(:conf) { base_conf.merge("cond" => "$1.to_i < 0") }
      end
    end


    describe "異常系" do

      describe "basedir不正" do
        let(:file_list) {
          [
           "dir1/file11.txt", "dir1/file12.txt",
           "dir2/file21.txt", "dir2/file22.txt"
          ]
        }
        let(:conf) { base_conf.merge("basedir" => "testdir/nosrc") }
        before do
          @retval = subject.process(time, dry_run)
        end

        context "通常 (retval,arcfile,file_list)" do
          let(:dry_run) { false }
          it { @retval.should be_false }
          it {
            file_list.each {|f|
              Pathname(arcfile(f)).should_not exist
            }
          }
          it {
            file_list.each {|f|
              Pathname("testdir/src/#{f}").should be_file
            }
          }
        end
        context "ドライ (retval,arcfile,file_list); dryでもchdirする" do
          let(:dry_run) { true }
          # dry_runでもchdirするのでfalse
          it { @retval.should be_false }
          it {
            file_list.each {|f|
              Pathname(arcfile(f)).should_not exist
            }
          }
          it {
            file_list.each {|f|
              Pathname("testdir/src/#{f}").should be_file
            }
          }
        end
      end

      describe "zip作成失敗 (書込権限なし)" do
        let(:file_list) {
          [
           "dir1/file11.txt", "dir1/file12.txt",
           "dir2/file21.txt", "dir2/file22.txt"
          ]
        }
        let(:conf) { base_conf }
        before do
          %x{chmod -w testdir/dest}
          @retval = subject.process(time, dry_run)
        end

        context "通常 (retval,arcfile,file_list)" do
          let(:dry_run) { false }
          it { @retval.should be_false }
          it {
            file_list.each {|f|
              Pathname(arcfile(f)).should_not exist
            }
          }
          it {
            file_list.each {|f|
              Pathname("testdir/src/#{f}").should be_file
            }
          }
        end
        context "ドライ (retval,arcfile,file_list)" do
          let(:dry_run) { true }
          it { @retval.should be_true }
          it {
            file_list.each {|f|
              Pathname(arcfile(f)).should_not exist
            }
          }
          it {
            file_list.each {|f|
              Pathname("testdir/src/#{f}").should be_file
            }
          }
        end
      end

      describe "chown失敗 (存在しないユーザ)" do
        let(:file_list) {
          [
           "dir1/file11.txt", "dir1/file12.txt",
           "dir2/file21.txt", "dir2/file22.txt"
          ]
        }
        let(:conf) { base_conf.merge("chown" => "nouser") }
        before do
          @retval = subject.process(time, dry_run)
        end

        context "通常 (retval,arcfile,file_list); 1つめのzipは作られる" do
          let(:dry_run) { false }
          it { @retval.should be_false }
          # 1つめのzipは作られる
          it {
            file_list[1..-1].each {|f|
              Pathname(arcfile(f)).should_not exist
            }
            Array(file_list[0]).each {|f|
              Pathname(arcfile(f)).should be_file
            }
          }
          it {
            file_list[1..-1].each {|f|
              Pathname("testdir/src/#{f}").should be_file
            }
            Array(file_list[0]).each {|f|
              Pathname("testdir/src/#{f}").should_not exist
            }
          }
        end
        context "ドライ (retval,arcfile,file_list)" do
          let(:dry_run) { true }
          it { @retval.should be_true }
          it {
            file_list.each {|f|
              Pathname(arcfile(f)).should_not exist
            }
          }
          it {
            file_list.each {|f|
              Pathname("testdir/src/#{f}").should be_file
            }
          }
        end
      end

    end
  end

end
