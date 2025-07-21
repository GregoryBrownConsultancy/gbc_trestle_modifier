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
  spec.homepage = "https://github.com/GregoryBrownConsultancy/gbc_trestle_modifier"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["source_code_uri"] = spec.homepage

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
  spec.add_dependency "activesupport"
  spec.add_dependency "trestle"
end
