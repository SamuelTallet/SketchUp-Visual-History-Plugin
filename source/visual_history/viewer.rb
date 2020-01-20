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
require 'fileutils'
require 'visual_history/html_dialogs'
require 'visual_history/imagemagick'

# Visual History plugin namespace.
module VisualHistory

  # Viewer.
  module Viewer

    # Returns absolute path to temporary directory.
    #
    # @return [String]
    def self.temp_dir

      File.join(Sketchup.temp_dir, 'Visual History Viewer for SketchUp')

    end

    # Forces recording of current state (thanks to a null operation).
    #
    # @return [nil]
    def self.force_state_recording(operation_name = '')

      model = Sketchup.active_model

      return if model.active_entities.first.nil?

      model.start_operation(
        operation_name,
        true # disable_ui
      )

      model.active_entities.first.hidden = !model.active_entities.first.hidden?

      model.active_entities.first.hidden = !model.active_entities.first.hidden?

      # XXX This will add a state. 
      #
      # @see ModelObserver#onTransactionCommit
      model.commit_operation

      nil

    end

    # Adds a state.
    #
    # @return [nil]
    def self.add_state

      if SESSION[:states_count].nil?

        SESSION[:states_count] = 0

      end

      FileUtils.mkdir_p(temp_dir) unless File.exist?(temp_dir)

      SESSION[:states_count] += 1

      # If we reached limit of undo stack:
      if SESSION[:states_count] > 99

        cleanup_and_reset

        # XXX This “hack” will recycle visual history without bothering user.
        force_state_recording(TRANSLATE['Recycle Visual History'])

        show_html_dialog

        return

      end

      if SESSION[:states_count] < 10

        fname = File.join(temp_dir, '0' + SESSION[:states_count].to_s + '.jpg')

      else

        fname = File.join(temp_dir, SESSION[:states_count].to_s + '.jpg')

      end

      Sketchup.active_model.active_view.write_image({

        :filename     => fname,
        :width        => 320,
        :height       => 240,
        :antialias    => true,
        :compression  => 0.8,
        :transparent  => false

      })

      nil

    end

    # Removes last state.
    #
    # @return [nil]
    def self.remove_last_state

      return if SESSION[:states_count].nil?

      if SESSION[:states_count] < 10

        fname = File.join(temp_dir, '0' + SESSION[:states_count].to_s + '.jpg')

      else

        fname = File.join(temp_dir, SESSION[:states_count].to_s + '.jpg')

      end

      File.delete(fname) if File.exist?(fname)

      SESSION[:states_count] -= 1

      if SESSION[:states_count] < 0

        SESSION[:states_count] = 0

      end

      nil

    end

    # Goes back to a state.
    # 
    # @param [Integer] state_index
    # @raise [ArgumentError]
    #
    # @return [nil]
    def self.go_back_to_state(state_index)

      raise ArgumentError, 'State Index must be an Integer.'\
        unless state_index.is_a?(Integer)

      return if SESSION[:states_count].nil?

      states_to_remove = SESSION[:states_count] - state_index

      states_to_remove.times do

        # XXX This will remove last state.
        #
        # @see ModelObserver#onTransactionUndo
        Sketchup.send_action('editUndo:')

      end

      nil

    end

    # Cleans up temporary directory and resets SESSION storage.
    #
    # @return [nil]
    def self.cleanup_and_reset

      FileUtils.remove_dir(temp_dir) if File.exist?(temp_dir)

      SESSION[:states_count] = nil

      # If HTML dialog was opened at least one time:
      if SESSION[:html_dialog].is_a?(UI::HtmlDialog)

        SESSION[:html_dialog].close

        SESSION[:html_dialog] = nil

      end

      nil

    end

    # Shows "Visual History Viewer" HTML dialog?
    #
    # @return [nil]
    def self.show_html_dialog

      if SESSION[:states_count].nil? || SESSION[:states_count].zero?

        UI.messagebox(TRANSLATE['History is empty.'])

        return

      end

      html_dialog = UI::HtmlDialog.new(

        dialog_title:    TRANSLATE['Visual History Viewer'],
        preferences_key: 'VHY Viewer',
        scrollable:      true,
        width:           220,
        height:          565,
        min_width:       220,
        min_height:      565

      )

      html_dialog.set_html(HTMLDialogs.merge(

        # Note: Paths below are relative to `HTMLDialogs::DIR`.
        document: 'viewer.rhtml',
        scripts: ['viewer.js'],
        styles: ['viewer.css']

      ))

      html_dialog.add_action_callback('goBackToState') do |_ctx, state_index|

        go_back_to_state(state_index.to_i)
        
      end

      html_dialog.show

      SESSION[:html_dialog] = html_dialog

      nil

    end

    # Reloads "Visual History Viewer" HTML dialog?
    #
    # @return [nil]
    def self.reload_html_dialog

      # If HTML dialog was opened at least one time:
      if SESSION[:html_dialog].is_a?(UI::HtmlDialog)

        SESSION[:html_dialog].close

        show_html_dialog

      end

      nil

    end

    # Exports history to an animated GIF image?
    #
    # @return [nil]
    def self.export_to_gif

      if SESSION[:states_count].nil? || SESSION[:states_count].zero?

        UI.messagebox(TRANSLATE['History is empty.'])

        return

      end

      gif_output_dir = UI.select_directory({

        :title => TRANSLATE['Select a Directory for GIF Output.']

      })

      # If user selected a directory:
      if gif_output_dir.is_a?(String)

        gif_delay = UI.inputbox(

          [TRANSLATE['Delay between each frame'] + ' '], # Prompt
          [10], # Default
          TRANSLATE['GIF Customization'] + ' - ' + NAME # Title

        )

        if gif_delay.is_a?(Array)

          gif_delay = gif_delay[0]

        else

          gif_delay = 10

        end

        ImageMagick.convert_jpg_to_gif(

          gif_delay.to_i,
          temp_dir, # in_dir
          gif_output_dir,
          'SketchUp History (' + Time.now.to_i.to_s + ')' # out_filename

        )

      end

      nil

    end

  end

end
