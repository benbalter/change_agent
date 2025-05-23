# frozen_string_literal: true

module ChangeAgent
  class Client
    include ChangeAgent::Sync
    attr_accessor :directory

    def initialize(directory = nil, remote = nil)
      @directory = File.expand_path(directory || Dir.pwd)
      @remote = remote
    end

    def repo
      @repo ||= if @remote.nil?
                  Rugged::Repository.init_at directory
                else
                  Rugged::Repository.clone_at @remote, directory, { credentials: credentials }
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
