# frozen_string_literal: true

module Bundle
  module Brewfile
    module_function

    def path(dash_writes_to_stdout: false, global: false, file: nil)
      env_bundle_file_global = ENV.fetch("HOMEBREW_BUNDLE_FILE_GLOBAL", nil)
      env_bundle_file = ENV.fetch("HOMEBREW_BUNDLE_FILE", nil)

      filename = if global
        if env_bundle_file_global.present?
          env_bundle_file_global
        else
          raise "'HOMEBREW_BUNDLE_FILE' cannot be specified with '--global'" if env_bundle_file.present?

          "#{Dir.home}/.Brewfile"
        end
      elsif file.present?
        handle_file_value(file, dash_writes_to_stdout)
      elsif env_bundle_file.present?
        env_bundle_file
      else
        "Brewfile"
      end

      Pathname.new(filename).expand_path(Dir.pwd)
    end

    def read(global: false, file: nil)
      Brewfile.path(global: global, file: file).read
    rescue Errno::ENOENT
      raise "No Brewfile found"
    end

    def handle_file_value(filename, dash_writes_to_stdout)
      if filename != "-"
        filename
      elsif dash_writes_to_stdout
        "/dev/stdout"
      else
        "/dev/stdin"
      end
    end
  end
end
