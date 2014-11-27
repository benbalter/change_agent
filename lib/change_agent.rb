require_relative "change_agent/version"
require_relative "change_agent/document"
require_relative "change_agent/client"
require "rugged"
require 'pathname'

module ChangeAgent

  def self.init(directory=nil, remote=nil)
    Client.new(directory, remote)
  end

end
