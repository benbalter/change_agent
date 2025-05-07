require 'rubygems'
require 'bundler'
require 'minitest/autorun'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

def tempdir
  File.expand_path './tmp', File.dirname(__FILE__)
end

def init_tempdir
  FileUtils.rm_rf tempdir
  FileUtils.mkdir tempdir
end

require 'change_agent'
