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

    after do
      cleanup_fixtures
    end
  end
end
