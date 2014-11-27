require 'helper'

class TestChangeAgentSync < Minitest::Test

  def setup
    init_tempdir
    @client = ChangeAgent::Client.new tempdir
    @demo = ChangeAgent::Client.new "https://github.com/benbalter/change_agent_demo"
  end

  def teardown
    FileUtils.rm_rf tempdir
  end

  should "return the remotes" do
    assert_equal Rugged::RemoteCollection, @client.remotes.class
  end

  should "add remotes" do
    assert_equal 0, @client.remotes.count
    @client.add_remote "origin", "https://github.com/benbalter/change_agent_demo"
    assert_equal 1, @client.remotes.count
  end

  should "know when the repo has remotes" do
    refute @client.has_remotes?
    @client.add_remote "origin", "https://github.com/benbalter/change_agent_demo"
    assert @client.has_remotes?
  end

  should "fetch" do
    @client.add_remote "origin", "https://github.com/benbalter/change_agent_demo"
    assert_raises Rugged::ReferenceError do
      @client.repo.rev_parse "origin/master"
    end
    @client.fetch
    assert @client.repo.rev_parse "origin/master"
  end

  should "merge" do
    head = @demo.repo.head.target.oid
    @demo.repo.reset "d877861", :hard
    assert @demo.merge
    assert_equal "Merged `origin/master` into `master`", @demo.repo.last_commit.message
    assert head != @demo.repo.head.target.oid
  end

  should "pull" do
    head = @demo.repo.head.target.oid
    @demo.repo.reset "d877861", :hard
    assert @demo.pull
    assert_equal "Merged `origin/master` into `master`", @demo.repo.last_commit.message
    assert head != @demo.repo.head.target.oid
  end
end
