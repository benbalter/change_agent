require_relative "change_agent/version"
require_relative "change_agent/document"
require_relative "change_agent/sync"
require_relative "change_agent/client"
require "rugged"
require 'pathname'
require "dotenv"

module ChangeAgent

  def self.init(directory=nil, remote=nil)
    Client.new(directory, remote)
  end

end

Dotenv.load
