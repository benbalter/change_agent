module ChangeAgent
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
      FileUtils.mkdir_p directory unless Dir.exists? directory
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
  end
end
