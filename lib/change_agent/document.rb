module ChangeAgent
  class Document

    attr_writer :contents
    attr_accessor :path
    alias_method :key, :path

    def initialize(path, client_or_directory=nil)
      @path = path
      if client_or_directory.class == ChangeAgent::Client
        @client = client_or_directory
      else
        @client = ChangeAgent::Client.new(client_or_directory)
      end
    end

    def repo
      @client.repo
    end

    def contents
      @contents ||= blob_contents
    end

    def changed?
      contents != blob_contents
    end

    def save
      oid = repo.write contents, :blob
      repo.index.add(path: path, oid: oid, mode: 0100644)

      Rugged::Commit.create repo,
        message: "Updating #{path}",
        parents: repo.empty? ? [] : [ repo.head.target ],
        tree: repo.index.write_tree(repo),
        update_ref: 'HEAD'
    end
    alias_method :write, :save

    def delete(file=path)
      repo.index.remove(file)

      Rugged::Commit.create repo,
        message: "Removing #{path}",
        parents: [repo.head.target],
        tree: repo.index.write_tree(repo),
        update_ref: 'HEAD'
    rescue Rugged::IndexError
      false
    end

    def inspect
      "#<ChangeAgent::Document path=\"#{path}\">"
    end

    private

    def blob_contents
      tree = repo.head.target.tree
      blob = repo.lookup tree.path(path)[:oid]
      blob.content.force_encoding("UTF-8")
    rescue Rugged::ReferenceError, Rugged::TreeError
      nil
    end
  end
end
