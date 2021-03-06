require "spec_helper"

module LicenseFinder
  module CLI
    describe Dependencies do
      describe "add" do
        it "should add a dependency" do
          DependencyManager.should_receive(:create_non_bundler).with("MIT", "js_dep", "1.2.3")

          silence_stdout do
            subject.add("MIT", "js_dep", "1.2.3")
          end
        end

        it "does not require a version" do
          DependencyManager.should_receive(:create_non_bundler).with("MIT", "js_dep", nil)

          silence_stdout do
            subject.add("MIT", "js_dep")
          end
        end

        it "should have a -a option to approve the added dependency" do
          DependencyManager.should_receive(:create_non_bundler).with("MIT", "js_dep", "1.2.3")
          DependencyManager.should_receive(:approve!).with("js_dep")

          silence_stdout do
            LicenseFinder::CLI::Main.start(["dependencies", "add", "--approve", "MIT", "js_dep", "1.2.3"])
          end
        end
      end

      describe "remove" do
        it "should remove a dependency" do
          DependencyManager.should_receive(:destroy_non_bundler).with("js_dep")
          silence_stdout do
            subject.remove("js_dep")
          end
        end
      end
    end

    describe Main do
      describe "default" do
        it "should check for action items" do
          DependencyManager.should_receive(:sync_with_bundler)
          Dependency.stub(:unapproved) { [] }
          silence_stdout do
            described_class.start([])
          end
        end
      end

      describe "#rescan" do
        it "resyncs with Gemfile" do
          DependencyManager.should_receive(:sync_with_bundler)
          Dependency.stub(:unapproved) { [] }

          silence_stdout do
            subject.rescan
          end
        end
      end

      describe "#license" do
        it "should update the license on the requested gem" do
          DependencyManager.should_receive(:license!).with("foo_gem", "foo")

          silence_stdout do
            subject.license 'foo', 'foo_gem'
          end
        end
      end

      describe "#approve" do
        it "should approve the requested gem" do
          DependencyManager.should_receive(:approve!).with("foo")

          silence_stdout do
            subject.approve 'foo'
          end
        end
      end

      describe "#action_items" do
        it "reports unapproved dependencies" do
          Dependency.stub(:unapproved) { ['one dependency'] }
          TextReport.stub(:new) { stub(:report, to_s: "a report!") }
          silence_stdout do
            $stdout.stub(:puts)
            $stdout.should_receive(:puts).with(/dependencies/i)
            expect { subject.action_items }.to raise_error(SystemExit)
          end
        end

        it "reports that all dependencies are approved" do
          Dependency.stub(:unapproved) { [] }
          silence_stdout do
            $stdout.should_receive(:puts).with(/approved/i)
            expect { subject.action_items }.to_not raise_error
          end
        end
      end
    end
  end
end
