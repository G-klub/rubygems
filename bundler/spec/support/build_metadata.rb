# frozen_string_literal: true

require_relative "path"
require_relative "helpers"

module Spec
  module BuildMetadata
    include Spec::Path
    include Spec::Helpers

    def write_build_metadata(build_metadata, dir: source_root)
      build_metadata.merge!(
        :git_commit_sha => git_commit_sha,
      )

      replace_build_metadata(build_metadata, dir: dir) # rubocop:disable Style/HashSyntax
    end

    def replace_build_metadata(build_metadata, dir: source_root)
      build_metadata_file = File.expand_path("lib/bundler/build_metadata.rb", dir)

      ivars = build_metadata.sort.map do |k, v|
        "    @#{k} = #{loaded_gemspec.send(:ruby_code, v)}"
      end.join("\n")

      contents = File.read(build_metadata_file)
      contents.sub!(/^(\s+# begin ivars).+(^\s+# end ivars)/m, "\\1\n#{ivars}\n\\2")
      File.open(build_metadata_file, "w") {|f| f << contents }
    end

  private

    def git_commit_sha
      ruby_core_tarball? ? "unknown" : sys_exec("git rev-parse --short HEAD", :dir => source_root).strip
    end

    extend self
  end
end
