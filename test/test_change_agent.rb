require 'helper'

class TestChangeAgent < Minitest::Test

  def setup
    init_tempdir
  end
  
  should "return a ChangeAgent::Client" do
    assert_equal ChangeAgent::Client, ChangeAgent.init(tempdir).class
  end
end
