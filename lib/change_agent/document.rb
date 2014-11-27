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
      index = repo.index
      index.read_tree(repo.head.target.tree) unless repo.empty?
      index.add(:path => path, :oid => oid, :mode => 0100644)

      options = {}
      options[:tree] = index.write_tree(repo)
      options[:message] ||= "Updating #{path}"
      options[:parents] = repo.empty? ? [] : [ repo.head.target ]
      options[:update_ref] = 'HEAD'

      Rugged::Commit.create(repo, options)
    end

    def delete(file=path)
      repo.index.remove(file)
      commit_tree = repo.index.write_tree repo
      Rugged::Commit.create repo,
        message: "Removing #{path}",
        parents: [repo.head.target],
        tree: commit_tree,
        update_ref: 'HEAD'
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
        delete(file) if tree.path(file)
      end
    rescue Rugged::TreeError
      nil
    end
  end
end
