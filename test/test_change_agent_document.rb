# frozen_string_literal: true

require 'helper'

class TestChangeAgentDocument < Minitest::Test
  def setup
    init_tempdir
    @client = ChangeAgent::Client.new tempdir
    @document = ChangeAgent::Document.new('foo', @client)
    @namespaced_document = ChangeAgent::Document.new('bar/foo', @client)
  end

  def teardown
    FileUtils.rm_rf tempdir
  end

  should 'store the document path on init' do
    assert_equal 'foo', @document.path
  end

  should 'accept a client if passed' do
    doc = ChangeAgent::Document.new('foo', ChangeAgent::Client.new)
    assert_equal ChangeAgent::Client, doc.instance_variable_get('@client').class
  end

  should 'build a client from a directory' do
    assert_equal ChangeAgent::Client, @document.instance_variable_get('@client').class
  end

  should 'expose the git client' do
    assert_equal Rugged::Repository, @document.repo.class
  end

  should "read a file's contents" do
    @document.contents = 'bar'
    @document.write
    @document.contents = nil # prevent caching
    assert_equal 'bar', @document.contents
  end

  should "write a file's contents" do
    @document.contents = 'bar'
    @document.write
    @document.contents = nil # prevent caching
    assert_equal 'bar', @client.get('foo')
  end

  should 'commit the document to the repo' do
    @document.contents = 'bar'
    @document.write
    @document.contents = nil # prevent caching
    assert_equal "Updating #{@document.key}", @document.repo.last_commit.message
  end

  should 'delete the document' do
    @document.contents = 'bar'
    @document.write
    @document.contents = nil # prevent caching
    assert @client.get 'foo'
    @document.delete
    refute @client.get 'foo'
    assert_equal "Removing #{@document.key}", @document.repo.last_commit.message
  end

  should 'allow two files in the same folder' do
    doc = ChangeAgent::Document.new('foo/bar', @client)
    doc.contents = 'baz'
    doc.write
    doc.contents = nil # prevent caching
    assert_equal 'baz', @client.get('foo/bar')

    doc = ChangeAgent::Document.new('foo/bar2', @client)
    doc.contents = 'baz2'
    doc.write
    doc.contents = nil # prevent caching
    assert_equal 'baz2', @client.get('foo/bar2')
  end

  should "know if a file's changed" do
    refute @document.changed?

    @client.set 'foo', 'bar'
    refute @document.changed?

    @document.contents = 'baz'
    assert @document.changed?
  end
end
