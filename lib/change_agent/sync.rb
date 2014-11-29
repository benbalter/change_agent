module ChangeAgent
  module Sync

    class MergeConflict < StandardError; end
    class MissingRemote < ArgumentError; end

    attr_writer :credentials

    DEFAULT_REMOTE = "origin"
    DEFAULT_REMOTE_BRANCH = "origin/master"
    DEFAULT_LOCAL_REF = "refs/heads/master"

    # Default to token-based credentials passed as GITHUB_TOKEN
    # Can be over ridden by overwritting @credentials with a
    # different Rugged Credentialing method
    def credentials
      @credentials ||= Rugged::Credentials::UserPassword.new({
         :username => "x-oauth-basic",
         :password => ENV["GITHUB_TOKEN"]
      })
    end

    # Helper method to return all remots
    def remotes
      repo.remotes
    end

    # Helper method to simplify adding a remote
    def add_remote(name, url)
      remotes.create name, url
    end

    # Does the current repo have at least a single remote?
    def has_remotes?
      remotes.count > 0
    end

    # Push to a remote
    #
    # Options:
    #  :remote - the name of the remote (default: origin)
    #  :ref    - the ref to push (default: "refs/heads/master")
    def push(options={})
      raise MissingRemote unless has_remotes?
      options.merge! :remote => DEFAULT_REMOTE, :ref => DEFAULT_LOCAL_REF
      remotes[options[:remote]].push([options[:ref]], {:credentials => credentials})
    end

    # Fetch a remote
    #
    # Options:
    #  remote - the name of the remote (default: origin)
    def fetch(remote=nil)
      raise MissingRemote unless has_remotes?
      repo.fetch(remote || DEFAULT_REMOTE, {:credentials => credentials})
    end

    # Merge two refs
    #
    # Options:
    #  :from   - the remote ref (default: "origin/master")
    #  :to     - the local ref  (default: "refs/heads/master")
    def merge(options={})
      options.merge! :from => DEFAULT_REMOTE_BRANCH, :to => DEFAULT_LOCAL_REF
      theirs = repo.rev_parse options[:from]
      ours = repo.rev_parse options[:to]

      analysis = repo.merge_analysis(theirs)
      return analysis if analysis.include? :up_to_date

      base = repo.rev_parse(repo.merge_base(ours, theirs))
      index = ours.tree.merge(theirs.tree, base.tree)

      raise MergeConflict if index.conflicts?

      Rugged::Commit.create(repo, {
        parents: [ours, theirs],
        tree: index.write_tree(repo),
        message: "Merged `#{options[:from]}` into `#{options[:to].sub("refs/heads/", "")}`",
        update_ref: options[:to]
      })
    end

    # Fetch a remote and merge
    #
    # Options:
    #  :remote - the name of the remote (default: origin)
    #  :from   - the remote ref (default: "origin/master")
    #  :to     - the local ref  (default: "refs/heads/master")
    def pull(options={})
      fetch(options[:remote])
      merge(options)
    end

    # Perform both a pull and a push
    #
    # Will fail if any conflicts occur
    def sync
      pull && push
    end
  end
end
