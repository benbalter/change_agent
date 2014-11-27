require 'helper'

class TestChangeAgentDocument < Minitest::Test

  def setup
    init_tempdir
    @document = ChangeAgent::Document.new("foo", tempdir)
    @namespaced_document = ChangeAgent::Document.new("bar/foo", tempdir)
  end

  should "store the document key on init" do
    assert_equal "foo", @document.key
  end

  should "accept a client if passed" do
    doc = ChangeAgent::Document.new("foo", ChangeAgent::Client.new)
    assert_equal ChangeAgent::Client, doc.instance_variable_get("@client").class
  end

  should "build a client from a directory" do
    assert_equal ChangeAgent::Client, @document.instance_variable_get("@client").class
  end

  should "expose the git client" do
    assert_equal Git::Base, @document.git.class
  end

  should "calcuate the base_dir" do
    assert_equal tempdir, @document.base_dir
  end

  should "calcuate the directory" do
    assert_equal tempdir, @document.directory

    expected = File.expand_path "bar", tempdir
    assert_equal expected, @namespaced_document.directory
  end

  should "know the file path" do
    expected = File.expand_path "foo", tempdir
    assert_equal expected, @document.path

    expected = File.expand_path "bar/foo", tempdir
    assert_equal expected, @namespaced_document.path
  end

  should "know if a file exists" do
    refute @document.exists?
    FileUtils.touch @document.path
    assert @document.exists?
  end

  should "read a file's contents" do
    File.write @document.path, "bar"
    assert_equal "bar", @document.contents
  end

  should "write a file's contents" do
    @document.contents = "bar"
    assert_equal "bar", @document.contents
    @document.write
    assert_equal "bar", File.open(@document.path).read
  end

  should "commit the document to the repo" do
    @document.contents = "bar"
    @document.write
    assert_equal 1, @document.git.log.count
    assert_equal "Updating #{@document.path}", @document.git.log.first.message
  end

  should "delete the document" do
    @document.contents = "bar"
    @document.write
    assert File.exists? @document.path
    @document.delete
    refute File.exists? @document.path
  end

  should "clobber conflicting namespace" do
    @document.contents = "bar"
    @document.write

    doc = ChangeAgent::Document.new("foo/bar", tempdir)
    doc.contents = "baz"
    doc.write
    path = File.expand_path("foo/bar", tempdir)
    assert File.exists? path
    assert_equal "baz", File.open(path).read
  end

  should "reject invalid keys" do
    assert_raises ChangeAgent::InvalidKey do
      assert ChangeAgent::Document.new("../foo/bar", tempdir)
    end
  end
end
