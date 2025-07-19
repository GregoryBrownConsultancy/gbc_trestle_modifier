# frozen_string_literal: true

require_relative "lib/gbc_trestle_modifier/version"

Gem::Specification.new do |spec|
  spec.name = "gbc_trestle_modifier"
  spec.version = GbcTrestleResourceGenerator::VERSION
  spec.authors = ["Gregory Brown"]
  spec.email = ["greg@gregorybrown.com.br"]

  spec.summary = "Adds a custom generators and better menu handling for Trestle"
  spec.description = <<-DESCRIPTION
    Treste is a great tool for rapid prototyping projects. I use it in loads
    of my projects. There are a couple of things that kind of tick me off though;
    Trestle resources tend to become large files in the app/admin folder due to the
    way they are written. I find it hard to read/maintain them as a big file, so I#{" "}
    split them up into smaller files and created a generator to ensure that they#{" "}
    always follow a standard. Another pet peeve is the menu handling. Handling menu itmes
    in each resource quickly becomes a nightmare. Ordering them requires a lot of#{" "}
    manual work. To keep things simpler, inspired by the work from the crowd at WinterCMS,
    I created a menu.yml file that is used to manage the menu. I also created a helper that
    simplifies the placing of the menu.#{" "}
  DESCRIPTION
  spec.homepage = "https://gregorybrown.com.br"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependency
  spec.add_runtime_dependency "trestle"

  # development dependencies
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rubocop-rspec"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
