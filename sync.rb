require 'xcodeproj'
require 'fileutils'

project_path = './Gallery Cleaner.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

# Clean up existing files in the main group first to avoid duplicates
main_group = project.main_group['Gallery Cleaner']
main_group.clear

# Helper to recursively add files
def add_files(dir, current_group, target)
  Dir.foreach(dir) do |item|
    next if item == '.' or item == '..' or item == '.DS_Store'
    
    path = File.join(dir, item)
    if File.directory?(path)
      # Create subgroup
      subgroup = current_group.new_group(item)
      add_files(path, subgroup, target)
    elsif item.end_with?('.swift') || item.end_with?('.xcassets')
      # Add file reference
      file_ref = current_group.new_file(path)
      # Add to target if it's a source file
      if item.end_with?('.swift')
        target.source_build_phase.add_file_reference(file_ref, true)
      elsif item.end_with?('.xcassets')
        target.resources_build_phase.add_file_reference(file_ref, true)
      end
    end
  end
end

# Clear build phases manually added to avoid duplicates if re-running
target.source_build_phase.files.each do |build_file|
  if build_file.file_ref && build_file.file_ref.path && build_file.file_ref.path.start_with?('Gallery Cleaner/')
    build_file.remove_from_project
  end
end
target.resources_build_phase.files.each do |build_file|
  if build_file.file_ref && build_file.file_ref.path && build_file.file_ref.path.start_with?('Gallery Cleaner/')
    build_file.remove_from_project
  end
end

# Clear again to be safe
target.source_build_phase.clear
target.resources_build_phase.clear

# We need to add files back
add_files('./Gallery Cleaner', main_group, target)

# Save the project
project.save
