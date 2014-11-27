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
      @contents ||= begin
        tree = repo.head.target.tree
        blob = repo.lookup tree.path(path)[:oid]
        blob.content
      end
    rescue Rugged::ReferenceError, Rugged::TreeError
      nil
    end

    def write
      clean_path
      oid = repo.write contents, :blob
      repo.index.add(path: path, oid: oid, mode: 0100644)

      Rugged::Commit.create repo,
        message: "Updating #{path}",
        parents: repo.empty? ? [] : [ repo.head.target ],
        tree: repo.index.write_tree(repo),
        update_ref: 'HEAD'
    end

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

    def clean_path
      return if repo.empty?
      dirs = []
      tree = repo.head.target.tree
      path.split("/").each do |part|
        file = dirs.push(part).join("/")
        delete(file) if tree.path(file) && tree.path(file)[:type] == :blob
      end
    rescue Rugged::TreeError
      nil
    end
  end
end
