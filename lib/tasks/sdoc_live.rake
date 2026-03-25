namespace :sdoc do

  desc "Generate SDoc documentation"
  task :build do
    require "sdoc_live"

    generator = SdocLive::Generator.new
    generator.build

    puts "SDoc build completed successfully!"
  end

end
