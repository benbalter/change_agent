require 'helper'

class TestChangeAgentClient < Minitest::Test

  def setup
    init_tempdir
    @client = ChangeAgent::Client.new(tempdir)
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
    file = File.expand_path "foo", tempdir
    assert File.exists? file
    assert_equal "bar", File.open(file).read
  end

  should "store a namespaced value" do
    @client.set "foo/bar", "baz"
    file = File.expand_path "foo/bar", tempdir
    assert File.exists? file
    assert_equal "baz", File.open(file).read
  end

  should "retrieve a file's value" do
    file = File.expand_path "foo", tempdir
    File.write file, "bar"
    assert_equal "bar", @client.get("foo")
  end

  should "retrive a namespaced file's value" do
    file = File.expand_path "foo/bar", tempdir
    FileUtils.mkdir_p File.dirname(file)
    File.write file, "baz"
    assert_equal "baz", @client.get("foo/bar")
  end

  should "round trip a value" do
    @client.set "foo", "bar"
    assert_equal "bar", @client.get("foo")
  end

  should "round trip a namespaced value" do
    @client.set "foo/bar", "baz"
    assert_equal "baz", @client.get("foo/bar")
  end

  should "not err on an unknown value" do
    refute @client.get "does/not/exist"
  end
end
