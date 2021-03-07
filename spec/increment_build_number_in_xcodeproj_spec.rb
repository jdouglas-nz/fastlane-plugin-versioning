require 'spec_helper'

describe Fastlane::Actions::IncrementBuildNumberInXcodeprojAction do
  describe "Increment Version Number in xcodeproj Integration" do

    before do
      copy_xcodeproj_fixtures
    end

    def current_build_number
      Fastlane::FastFile.new.parse("lane :test do
        get_build_number_from_xcodeproj
      end").runner.execute(:test)
    end

    def current_target_build_number
      Fastlane::FastFile.new.parse("lane :test do
        get_build_number_from_xcodeproj(target: 'versioning_fixture_project')
      end").runner.execute(:test)
    end

    it "should set explicitly provided version number to xcodeproj" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_build_number_in_xcodeproj(build_number: '1.9.4.1')
      end").runner.execute(:test)

      expect(current_build_number).to eq("1.9.4.1")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to eq("1.9.4.1")
    end

    it "should increment build number by default and set it to xcodeproj" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_build_number_in_xcodeproj
      end").runner.execute(:test)

      expect(current_build_number).to eq("2")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to eq("2")
    end

    it "should explicitly set a target build number if specified" do
      result = Fastlane::FastFile.new.parse("lane :test do
        increment_build_number_in_xcodeproj(build_number:'22', target: 'versioning_fixture_project')
      end").runner.execute(:test)

      expect(current_target_build_number).to eq("22")
      expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to eq("22")
    end


    it "should not crash when specifying build configuration name, target and project" do
      file = Fastlane::FastFile.new.parse("
        lane :increment do
          increment_build_number_in_xcodeproj(
            xcodeproj: '/tmp/fastlane/tests/fastlane/xcodeproj/versioning_fixture_project.xcodeproj',
            target: 'versioning_fixture_project',
            build_configuration_name: 'Release'
          )
        end")
        
        expect { 
          result = file.runner.execute(:increment)
          expect(result).to eq("2")
        }.not_to raise_error
    end

    it "should not crash when specifying  build configuration name, target, project and build number" do
      file = Fastlane::FastFile.new.parse("
        lane :increment do
          increment_build_number_in_xcodeproj(
            xcodeproj: '/tmp/fastlane/tests/fastlane/xcodeproj/versioning_fixture_project.xcodeproj',
            target: 'versioning_fixture_project',
            build_configuration_name: 'Release',
            build_number: '50'
          )
        end")
        
        expect { 
          result = file.runner.execute(:increment)
          expect(result).to eq("50")
        }.not_to raise_error
    end

    it "should not replace Xcode's annotations with generic ones" do
      xcodeproj_path = '/tmp/fastlane/tests/fastlane/xcodeproj/Test.xcodeproj'

      pbxproj_path = File.join(xcodeproj_path, "project.pbxproj")

      # file = Fastlane::FastFile.new.parse("
      #   lane :bump do
      #     increment_build_number_in_xcodeproj(
      #       xcodeproj: '#{xcodeproj_path}',
      #       scheme: 'Dev Test',
      #       bump_type: 'minor'
      #     )
      #   end")

      pbxproj_path = File.join(xcodeproj_path, "project.pbxproj")

      # given this file will not be modified, the quickest way I could think to assert that nothing changes
      # is to just grab the offending lines out of the file and do a contains and not contains
      nuke_line = line_from_file(18, pbxproj_path)
      nuke_line_2 = line_from_file(135, pbxproj_path)
      alamofire_line = line_from_file(19, pbxproj_path)
      alamofire_line_2 = line_from_file(136, pbxproj_path)

      expect(nuke_line).to include("Nuke in Frameworks")
      expect(nuke_line).not_to include("BuildFile")
      
      expect(alamofire_line).to include("Alamofire in Frameworks")
      expect(alamofire_line).not_to include("BuildFile")

      expect(nuke_line_2).to include("Nuke in Frameworks")
      expect(nuke_line_2).not_to include("BuildFile")

      expect(alamofire_line_2).to include("Alamofire in Frameworks")
      expect(alamofire_line_2).not_to include("BuildFile")
    end

    it "should only adjust the specified schemes version" do 
      expect(false).to be(true) 
    end
    
    after do
      cleanup_fixtures
    end
  end
end
