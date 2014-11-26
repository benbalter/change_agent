require_relative "change_agent/version"
require_relative "change_agent/document"
require_relative "change_agent/client"
require "git"

module ChangeAgent

  def self.init(directory=nil)
    Client.new(directory)
  end

end
