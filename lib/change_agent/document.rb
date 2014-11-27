module ChangeAgent
  class InvalidKey < ArgumentError; end

  class Document

    attr_accessor :key
    attr_writer :contents

    def initialize(key, client_or_directory=nil)
      @key = key
      if client_or_directory.class == ChangeAgent::Client
        @client = client_or_directory
      else
        @client = ChangeAgent::Client.new(client_or_directory)
      end
      raise InvalidKey unless path_in_repo?
    end

    def git
      @client.git
    end

    # base dir for repo
    def base_dir
      @client.directory
    end

    # directory containing file
    def directory
      @directory ||= File.dirname(path)
    end

    def path
      File.expand_path key, base_dir
    end

    def exists?
      File.exists? path
    end

    def contents
      @contents ||= File.open(path).read
    rescue Errno::ENOENT
      nil
    end

    def write
      mkdir
      File.write(path, contents)
      commit
    end

    def commit
      git.add(path)
      git.commit "Updating #{path}"
    end

    def delete
      git.remove(path)
    end

    def inspect
      "#<ChangeAgent::Document key=\"#{key}\">"
    end

    private

    def base_dir_regex
      Regexp.new('^' + Regexp.escape(base_dir) + "/")
    end

    def path_in_repo?
      path.match base_dir_regex
    end

    # Similar to mkdir_p, but removes files in the path
    # this avoids namespace conflicts
    def mkdir
      return if File.file? path
      dirs = []
      relative_path = path.gsub base_dir_regex, ""
      relative_path.split("/").each do |part|
        dirs.push part
        file = File.expand_path(dirs.join("/"), tempdir)
        File.delete file if File.file? file
      end
      FileUtils.mkdir_p directory
    end
  end
end
