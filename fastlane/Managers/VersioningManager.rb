# frozen_string_literal: true

class VersioningManager
  def initialize(
    fastlane:,
    project_path:,
    main_target_name:
  )
    @fastlane = fastlane
    @project_path = project_path
    @main_target_name = main_target_name
  end

  def build_number=(build_number)
    @fastlane.increment_build_number(
      build_number: build_number,
      xcodeproj: @project_path
    )
  end

  def build_number
    @fastlane.get_build_number(xcodeproj: @project_path)
  end

  def version_number
    @fastlane.get_version_number(
      xcodeproj: @project_path,
      target: @main_target_name
    )
  end

  def version_number=(version_number)
    @fastlane.increment_version_number(
      version_number: version_number,
      xcodeproj: @project_path
    )
  end

  def version_and_build_number
    "#{version_number} (Build: #{build_number})"
  end

  def release_tag
    "release/#{version_number}/#{@fastlane.number_of_commits}"
  end
end
