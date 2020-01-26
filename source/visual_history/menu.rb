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

require 'sketchup'
require 'visual_history/viewer'
require 'visual_history/grouponents'

# Visual History plugin namespace.
module VisualHistory

  # Connects Visual History plugin menu to SketchUp user interface.
  class Menu

    # Adds Visual History plugin menu in a SketchUp menu.
    #
    # @param [Sketchup::Menu] parent_menu Target parent menu.
    # @raise [ArgumentError]
    def initialize(parent_menu)

      raise ArgumentError.new('Parent Menu param. must be a SketchUp::Menu.')\
        unless parent_menu.is_a?(Sketchup::Menu)

      @menu = parent_menu.add_submenu(NAME)

      add_menu_items

    end

    # Adds Visual History plugin menu items...
    #
    # @return [nil]
    def add_menu_items

      @menu.add_item(TRANSLATE['Show Visual History']) {

        Viewer.show_html_dialog

      }

      @menu.add_item(TRANSLATE['Pause/Restart State Recording']) {

        Viewer.pause_state_recording

      }

      @menu.add_item(TRANSLATE['Force Current State Recording']) {

        Viewer.force_state_recording

      }

      @menu.add_item(TRANSLATE['Center Selection Relatively to Origin']) {

        Grouponents.center_selected

      }

      @menu.add_item(TRANSLATE['Clear Visual History']) {

        Viewer.cleanup_and_reset

      }

      @menu.add_item(TRANSLATE['Rotate Selection by 360° in 32 Steps']) {

        Grouponents.rotate_selected

      }

      @menu.add_item(TRANSLATE['Make Selection Rebound in 32 Steps']) {

        Grouponents.rebound_selected

      }

      @menu.add_item(TRANSLATE['Export History as GIF...']) {

        Viewer.export_to_gif

      }

      nil

    end

  end

end
