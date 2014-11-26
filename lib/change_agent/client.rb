module ChangeAgent
  class Client

    attr_accessor :directory

    def initialize(directory=nil)
      @directory = File.expand_path(directory || Dir.pwd)
    end

    def git
      @git ||= Git.init directory
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
