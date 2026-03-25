require "test_helper"

class ConfigurationTest < Minitest::Test

  def setup
    SdocLive.configuration = nil
  end

  def teardown
    SdocLive.configuration = nil
  end

  def test_default_source_dirs
    config = SdocLive.configuration
    assert_equal ["app", "lib"], config.source_dirs
  end

  def test_default_watch_file_type_regex
    config = SdocLive.configuration
    assert_equal(/\.rb$/, config.watch_file_type_regex)
  end

  def test_default_title
    config = SdocLive.configuration
    assert_equal "Documentation", config.title
  end

  def test_default_main_file
    config = SdocLive.configuration
    assert_equal "README.md", config.main_file
  end

  def test_default_output_dir_is_nil
    config = SdocLive.configuration
    assert_nil config.output_dir
  end

  def test_default_watch_dirs_is_nil
    config = SdocLive.configuration
    assert_nil config.watch_dirs
  end

  def test_default_rdoc_options_is_nil
    config = SdocLive.configuration
    assert_nil config.rdoc_options
  end

  def test_configure_block
    SdocLive.configure do |config|
      config.title = "My App Docs"
    end

    assert_equal "My App Docs", SdocLive.configuration.title
  end

  def test_configure_preserves_other_defaults
    SdocLive.configure do |config|
      config.title = "Custom"
    end

    assert_equal ["app", "lib"], SdocLive.configuration.source_dirs
    assert_equal "README.md", SdocLive.configuration.main_file
  end

  def test_configure_source_dirs
    SdocLive.configure do |config|
      config.source_dirs = ["app", "lib", "engines"]
    end

    assert_equal ["app", "lib", "engines"], SdocLive.configuration.source_dirs
  end

  def test_configure_output_dir
    SdocLive.configure do |config|
      config.output_dir = "/tmp/docs"
    end

    assert_equal "/tmp/docs", SdocLive.configuration.output_dir
  end

  def test_configure_watch_file_type_regex
    SdocLive.configure do |config|
      config.watch_file_type_regex = /\.(rb|slim)$/
    end

    assert_equal(/\.(rb|slim)$/, SdocLive.configuration.watch_file_type_regex)
  end

  def test_configure_rdoc_options
    SdocLive.configure do |config|
      config.rdoc_options = ["--all", "--hyperlink-all"]
    end

    assert_equal ["--all", "--hyperlink-all"], SdocLive.configuration.rdoc_options
  end

  def test_configure_main_file
    SdocLive.configure do |config|
      config.main_file = "GUIDE.md"
    end

    assert_equal "GUIDE.md", SdocLive.configuration.main_file
  end

  def test_default_cache_control
    config = SdocLive.configuration
    assert_equal "no-cache", config.cache_control
  end

  def test_configure_cache_control
    SdocLive.configure do |config|
      config.cache_control = "public, max-age=3600"
    end

    assert_equal "public, max-age=3600", SdocLive.configuration.cache_control
  end

end
