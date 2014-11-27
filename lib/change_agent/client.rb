module ChangeAgent
  class Client

    attr_accessor :directory

    def initialize(directory=nil, remote=nil)
      @directory = File.expand_path(directory || Dir.pwd)
      @remote = remote
    end

    def repo
      if @remote.nil?
        @repo ||= Rugged::Repository.init_at directory
      else
        @repo ||= Rugged::Repository.clone_at @remote, directory
      end
    end

    def set(key, value)
      document = Document.new(key, self)
      document.contents = value
      return unless document.changed?
      document.save
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
