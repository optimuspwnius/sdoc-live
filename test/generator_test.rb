require "test_helper"
require "tmpdir"
require "fileutils"
require "pathname"

class GeneratorTest < Minitest::Test

  def setup
    SdocLive.configuration = nil

    @tmpdir = Dir.mktmpdir("sdoc_live_test")

    # Create minimal source structure
    FileUtils.mkdir_p(File.join(@tmpdir, "app", "models"))
    FileUtils.mkdir_p(File.join(@tmpdir, "lib"))

    File.write(File.join(@tmpdir, "README.md"), "# Test App\n\nTest documentation.")
    File.write(File.join(@tmpdir, "app", "models", "user.rb"), <<~RUBY)
      # A user of the system.
      #
      # == Attributes
      # * +name+ - The user's name
      # * +email+ - The user's email
      class User
        attr_accessor :name, :email

        def initialize(name:, email:)
          @name = name
          @email = email
        end

        # Returns a greeting string.
        def greeting
          "Hello, \#{ name }!"
        end
      end
    RUBY

    File.write(File.join(@tmpdir, "lib", "calculator.rb"), <<~RUBY)
      # A simple calculator.
      class Calculator
        # Adds two numbers.
        def add(a, b)
          a + b
        end
      end
    RUBY
  end

  def teardown
    FileUtils.rm_rf(@tmpdir)
    SdocLive.configuration = nil
  end

  def test_build_generates_output_directory
    output_dir = File.join(@tmpdir, "public", "doc")

    SdocLive.configure do |config|
      config.output_dir = output_dir
      config.source_dirs = ["app", "lib"]
    end

    generator = SdocLive::Generator.new(root: @tmpdir)
    generator.build

    assert Dir.exist?(output_dir), "Output directory should be created"
  end

  def test_build_generates_index_html
    output_dir = File.join(@tmpdir, "public", "doc")

    SdocLive.configure do |config|
      config.output_dir = output_dir
      config.source_dirs = ["app", "lib"]
    end

    generator = SdocLive::Generator.new(root: @tmpdir)
    generator.build

    assert File.exist?(File.join(output_dir, "index.html")), "index.html should be generated"
  end

  def test_build_with_custom_title
    output_dir = File.join(@tmpdir, "public", "doc")

    SdocLive.configure do |config|
      config.output_dir = output_dir
      config.title = "My Custom Docs"
      config.source_dirs = ["app", "lib"]
    end

    generator = SdocLive::Generator.new(root: @tmpdir)
    generator.build

    index_content = File.read(File.join(output_dir, "index.html"))
    assert_includes index_content, "My Custom Docs"
  end

  def test_build_includes_main_file
    output_dir = File.join(@tmpdir, "public", "doc")

    SdocLive.configure do |config|
      config.output_dir = output_dir
      config.source_dirs = ["app", "lib"]
    end

    generator = SdocLive::Generator.new(root: @tmpdir)
    generator.build

    # The index.html is a frameset; the README content lives in a separate file
    readme_files = Dir.glob(File.join(output_dir, "**/*README*"))
    refute_empty readme_files, "Should generate a README doc file"

    readme_content = File.read(readme_files.first)
    assert_includes readme_content, "Test App"
  end

  def test_build_without_main_file
    FileUtils.rm(File.join(@tmpdir, "README.md"))

    output_dir = File.join(@tmpdir, "public", "doc")

    SdocLive.configure do |config|
      config.output_dir = output_dir
      config.source_dirs = ["app", "lib"]
    end

    generator = SdocLive::Generator.new(root: @tmpdir)
    generator.build

    assert Dir.exist?(output_dir), "Should still generate docs without a main file"
  end

  def test_build_with_only_lib
    output_dir = File.join(@tmpdir, "public", "doc")

    SdocLive.configure do |config|
      config.output_dir = output_dir
      config.source_dirs = ["lib"]
    end

    generator = SdocLive::Generator.new(root: @tmpdir)
    generator.build

    assert File.exist?(File.join(output_dir, "index.html"))
  end

  def test_default_output_dir
    generator = SdocLive::Generator.new(root: @tmpdir)
    output_dir = generator.instance_variable_get(:@output_dir)

    assert_equal Pathname.new(@tmpdir).join("public", "doc"), output_dir
  end

  def test_default_source_dirs
    generator = SdocLive::Generator.new(root: @tmpdir)
    source_dirs = generator.instance_variable_get(:@source_dirs)

    expected = ["app", "lib"].map { File.join(@tmpdir, it) }
    assert_equal expected, source_dirs
  end

  def test_watch_dirs_default_to_source_dirs
    generator = SdocLive::Generator.new(root: @tmpdir)
    watch_dirs = generator.instance_variable_get(:@watch_dirs)

    expected = ["app", "lib"].map { Pathname.new(File.join(@tmpdir, it)) }
    assert_equal expected, watch_dirs
  end

  def test_watch_dirs_skip_nonexistent
    SdocLive.configure do |config|
      config.source_dirs = ["app", "lib", "nonexistent"]
    end

    generator = SdocLive::Generator.new(root: @tmpdir)
    watch_dirs = generator.instance_variable_get(:@watch_dirs)

    assert_equal 2, watch_dirs.length
    refute watch_dirs.any? { it.to_s.include?("nonexistent") }
  end

end
