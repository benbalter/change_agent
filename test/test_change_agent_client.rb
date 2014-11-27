require 'helper'

class TestChangeAgentClient < Minitest::Test

  def setup
    init_tempdir
    @client = ChangeAgent::Client.new(tempdir)
  end

  def teardown
    FileUtils.rm_rf tempdir
  end

  should "set the directory on init" do
    assert_equal tempdir, @client.directory
  end

  should "clone into existing repos" do
    repo = "https://github.com/benbalter/change_agent"
    agent = ChangeAgent::Client.new(tempdir, repo)
    assert_equal repo, agent.repo.remotes.first.url
    assert Dir.entries(tempdir).count > 5
  end

  should "default to the pwd" do
    assert_equal Dir.pwd, ChangeAgent::Client.new.directory
  end

  should "init the git object" do
    assert_equal Rugged::Repository, @client.repo.class
    assert_equal tempdir + "/.git/", @client.repo.path
  end

  should "store a value" do
    @client.set "foo", "bar"
    tree = @client.repo.head.target.tree
    blob = @client.repo.lookup tree["foo"][:oid]
    assert_equal "bar", blob.content
  end

  should "store a namespaced value" do
    @client.set "foo/bar", "baz"
    tree = @client.repo.head.target.tree
    blob = @client.repo.lookup tree.path("foo/bar")[:oid]
    assert_equal "baz", blob.content
  end

  should "retrieve a file's value" do
    @client.set "foo", "bar"
    assert_equal "bar", @client.get("foo")
  end

  should "retrive a namespaced file's value" do
    @client.set "foo/bar", "baz"
    assert_equal "baz", @client.get("foo/bar")
  end

  should "not err on an unknown value" do
    refute @client.get "does/not/exist"
  end
end
