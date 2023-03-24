# frozen_string_literal: true

require "uri"
require "open-uri"
require "zip"

module Cldr
  module Download
    DEFAULT_SOURCE = "http://unicode.org/Public/cldr/%{version}/core.zip"
    DEFAULT_TARGET = "./vendor/cldr"
    DEFAULT_VERSION = 41

    class << self
      def download(source = DEFAULT_SOURCE, target = DEFAULT_TARGET, version = DEFAULT_VERSION, &block)
        source = format(source, version: version)
        target ||= File.expand_path(DEFAULT_TARGET)

        URI.parse(source).open do |tempfile|
          FileUtils.mkdir_p(target)
          Zip.on_exists_proc = true
          Zip::File.open(tempfile.path) do |file|
            file.each do |entry|
              path = File.join(target, entry.name)
              FileUtils.mkdir_p(File.dirname(path))
              file.extract(entry, path)
              yield path if block_given?
            end
          end
        end
      end
    end
  end
end
