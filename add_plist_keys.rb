require 'xcodeproj'
project_path = 'Gallery Cleaner.xcodeproj'
project = Xcodeproj::Project.open(project_path)
project.targets.each do |target|
  target.build_configurations.each do |config|
    config.build_settings['INFOPLIST_KEY_NSPhotoLibraryUsageDescription'] = 'We need access to your photos to find and clean duplicates and large files.'
    config.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
  end
end
project.save
