require "test_helper"

class VersionTest < Minitest::Test

  def test_version_is_set
    refute_nil SdocLive::VERSION
  end

  def test_version_format
    assert_match(/\A\d+\.\d+\.\d+\z/, SdocLive::VERSION)
  end

end
