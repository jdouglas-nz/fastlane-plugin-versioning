require 'spec_helper'

describe Fastlane::Actions::IncrementVersionNumberInXcodeprojAction do
  describe "Increment Version Number in xcodeproj Integration" do

    before do
      copy_xcodeproj_fixtures
      copy_info_plist_fixtures
      fake_api_responses
    end

    def current_version
      version = Fastlane::FastFile.new.parse("lane :test do
        get_version_number_from_xcodeproj
      end").runner.execute(:test)
      version
    end

    def current_target_version
      version = Fastlane::FastFile.new.parse("lane :test do
        get_version_number_from_xcodeproj(target: 'versioning_fixture_project')
      end").runner.execute(:test)
      version
    end

    it "should set explicitly provided version number to xcodeproj" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_xcodeproj(version_number: '1.9.4')
      end").runner.execute(:test)

      expect(current_version).to eq("1.9.4")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("1.9.4")
    end

    it "should bump patch version by default and set it to xcodeproj" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_xcodeproj
      end").runner.execute(:test)

      expect(current_version).to eq("0.0.2")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("0.0.2")
    end

    it "should bump patch version and set it to xcodeproj" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_xcodeproj(bump_type: 'patch')
      end").runner.execute(:test)

      expect(current_version).to eq("0.0.2")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("0.0.2")
    end

    it "should bump minor version and set it to xcodeproj" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_xcodeproj(bump_type: 'minor')
      end").runner.execute(:test)

      expect(current_version).to eq("0.1.0")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("0.1.0")
    end

    it "should omit zero in patch version if omit_zero_patch_version is true" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_xcodeproj(bump_type: 'minor', omit_zero_patch_version: true)
      end").runner.execute(:test)

      expect(current_version).to eq("0.1")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("0.1")
    end

    it "should bump major version and set it to xcodeproj" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_xcodeproj(bump_type: 'major')
      end").runner.execute(:test)

      expect(current_version).to eq("1.0.0")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("1.0.0")
    end

    it "should bump version using App Store version as a source" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_xcodeproj(bump_type: 'major', version_source: 'appstore')
      end").runner.execute(:test)

      expect(current_version).to eq("3.0.0")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("3.0.0")
    end

    it "should explicitly set a target version number if specified" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_version_number_in_xcodeproj(version_number:'1.0.0', target: 'versioning_fixture_project')
      end").runner.execute(:test)

      expect(current_target_version).to eq("1.0.0")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("1.0.0")
    end


    it "should not replace Xcode's annotations with generic ones" do
      xcodeproj_path = '/tmp/fastlane/tests/fastlane/xcodeproj/Test.xcodeproj'

      pbxproj_path = File.join(xcodeproj_path, "project.pbxproj")

      file = Fastlane::FastFile.new.parse("
        lane :bump do
          increment_version_number_in_xcodeproj(
            xcodeproj: '#{xcodeproj_path}',
            scheme: 'Dev Test',
            bump_type: 'minor'
          )
        end")

      pbxproj_path = File.join(xcodeproj_path, "project.pbxproj")

      # given this file will not be modified, the quickest way I could think to assert that nothing changes
      # is to just grab the offending lines out of the file and do a contains and not contains
      nuke_line = line_from_file(18, pbxproj_path)
      nuke_line_2 = line_from_file(135, pbxproj_path)
      alamofire_line = line_from_file(19, pbxproj_path)
      alamofire_line_2 = line_from_file(136, pbxproj_path)

      file.runner.execute(:bump)

      nuke_line_test = line_from_file(18, pbxproj_path)


      expect(nuke_line).to include("Nuke in Frameworks")
      expect(nuke_line_2).to include("Nuke in Frameworks")
      expect(nuke_line).not_to include("BuildFile in Frameworks")

      expect(alamofire_line).to include("Alamofire in Frameworks")
      expect(alamofire_line_2).to include("Alamofire in Frameworks")
      expect(alamofire_line).not_to include("BuildFile in Frameworks")
    end

    # it "should only adjust the specified schemes version" do 
      
    # end
    
    
    after do
      cleanup_fixtures
    end
  end
end
