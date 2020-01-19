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

# Visual History plugin namespace.
module VisualHistory

  # Groups or components.
  class Grouponents

    # Centers a grouponent (aka Moves grouponent to origin point).
    #
    # XXX Algorithm comes from:
    # https://www.fsdeveloper.com/forum/threads/centering-objects.71321/
    #
    # @param [Sketchup::Group, Sketchup::ComponentInstance] grouponent
    # @raise [ArgumentError]
    #
    # @return [nil]
    def self.center(grouponent)

      raise ArgumentError.new('Grouponent parameter is invalid.')\
        unless grouponent.is_a?(Sketchup::Group)\
          || grouponent.is_a?(Sketchup::ComponentInstance)

      grouponent_bounds = grouponent.bounds

      grouponent_center_point = grouponent_bounds.center

      grouponent_lower_point = grouponent_bounds.corner(0)

      grouponent_center_point.z = grouponent_lower_point.z

      vector = grouponent_center_point.vector_to(ORIGIN)

      # FIXME: Why `move!` method doesn't work like `transform!` one?
      grouponent.transform!(Geom::Transformation.translation(vector))

      Sketchup.send_action('viewFront:')

      Sketchup.active_model.active_view.zoom(grouponent)

      nil

    end

    # Centers selected grouponent.
    #
    # @return [nil]
    def self.center_selected

      selection = Sketchup.active_model.selection

      if selection.empty?

        UI.messagebox(TRANSLATE['First, select a group or a component.'])

        return

      end

      entity = selection.first

      if entity.is_a?(Sketchup::Group)\
        || entity.is_a?(Sketchup::ComponentInstance)

        center(entity)

      else

        UI.messagebox(TRANSLATE['First, select a group or a component.'])

      end

      nil

    end

    # Rotates a grouponent by 360 degrees in 32 steps.
    #
    # @param [Sketchup::Group, Sketchup::ComponentInstance] grouponent
    # @raise [ArgumentError]
    #
    # @return [nil]
    def self.rotate(grouponent)

      raise ArgumentError.new('Grouponent parameter is invalid.')\
        unless grouponent.is_a?(Sketchup::Group)\
          || grouponent.is_a?(Sketchup::ComponentInstance)

      Sketchup.status_text = TRANSLATE['Rotation... Please wait.']

      32.times do

        grouponent.transform!(
          Geom::Transformation.rotation(ORIGIN, Z_AXIS, 11.25.degrees)
        )

      end

      Sketchup.status_text = nil

      nil

    end

    # Rotates selected grouponent by 360 degrees in 32 steps.
    #
    # @return [nil]
    def self.rotate_selected

      selection = Sketchup.active_model.selection

      if selection.empty?

        UI.messagebox(TRANSLATE['First, select a group or a component.'])

        return

      end

      entity = selection.first

      if entity.is_a?(Sketchup::Group)\
        || entity.is_a?(Sketchup::ComponentInstance)

        rotate(entity)

      else

        UI.messagebox(TRANSLATE['First, select a group or a component.'])

      end

      nil

    end

  end

end
