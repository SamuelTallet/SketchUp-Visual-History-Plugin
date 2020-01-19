# Visual History (VHY) extension for SketchUp 2017 or newer version.
# Copyright: © 2020 Samuel Tallet <samuel.tallet arobase gmail.com>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3.0 of the License, or
# (at your option) any later version.
# 
# If you release a modified version of this program TO THE PUBLIC,
# the GPL requires you to MAKE THE MODIFIED SOURCE CODE AVAILABLE
# to the program's users, UNDER THE GPL.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
# 
# Get a copy of the GPL here: https://www.gnu.org/licenses/gpl.html

raise 'The VHY plugin requires at least Ruby 2.2.0 or SketchUp 2017.'\
  unless RUBY_VERSION.to_f >= 2.2 # SketchUp 2017 includes Ruby 2.2.4.

require 'fileutils'
require 'sketchup'

# Visual History plugin namespace.
module VisualHistory

  # ImageMagick wrapper.
  module ImageMagick

    # Returns absolute path to ImageMagick convert executable.
    #
    # @return [String]
    def self.convert_exe

      File.join(__dir__, 'ImageMagick', 'Win', 'convert.exe')

    end

    # Converts many JPG files to one GIF.
    #
    # @param [Integer] delay
    # @param [String] in_dir
    # @param [String] out_dir
    # @param [String] out_filename
    # @raise [ArgumentError]
    #
    # @return [nil]
    def self.convert_jpg_to_gif(delay, in_dir, out_dir, out_filename)

      raise ArgumentError.new('Delay parameter must be an Integer.')\
        unless delay.is_a?(Integer)

      raise ArgumentError.new('In Dir. parameter must be a String.')\
        unless in_dir.is_a?(String)

      raise ArgumentError.new('Out Dir. parameter must be a String.')\
        unless out_dir.is_a?(String)

      raise ArgumentError.new('Out Filename parameter must be a String.')\
        unless out_filename.is_a?(String)

      command =\
        '"' + convert_exe + '" -delay ' + delay.to_s + ' "' +
        File.join(in_dir, '*.jpg') + '" "' +
        File.join(out_dir, out_filename + '.gif') + '"'

      status = system(command)

      if status != true

        UI.messagebox('Visual History Error: Command failed: ' + command)

      end

      nil

    end

  end

end
