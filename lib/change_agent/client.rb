module ChangeAgent
  class Client

    attr_accessor :directory

    def initialize(directory=nil, remote=nil)
      @directory = File.realpath(directory || Dir.pwd)
      @remote = remote
    end

    def repo
      # Git repo already exists, don't do anything but load it
      @repo ||= Rugged::Repository.new directory
    rescue Rugged::RepositoryError
      if @remote.nil? # init a new repo at the given path
        @repo ||= Rugged::Repository.init_at directory
      else # Clone a repo from a remote
        @repo ||= Rugged::Repository.clone_at @remote, directory
      end
    end

    def set(key, value)
      document = Document.new(key, self)
      document.contents = value
      document.write
      document
    end

    def get(key)
      get_document(key).contents
    end

    def get_document(key)
      Document.new(key, self)
    end

    def delete(key)
      Document.new(key, self).delete
    end

    def inspect
      "#<ChangeAgent::Client repo=\"#{directory}\">"
    end
  end
end
