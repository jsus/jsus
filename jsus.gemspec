# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{jsus}
  s.version = "0.1.11"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mark Abramov"]
  s.date = %q{2010-11-23}
  s.default_executable = %q{jsus}
  s.description = %q{Javascript packager and dependency resolver}
  s.email = %q{markizko@gmail.com}
  s.executables = ["jsus"]
  s.extra_rdoc_files = [
    "LICENSE",
    "README",
    "TODO"
  ]
  s.files = [
    ".autotest",
    ".document",
    ".rspec",
    "CHANGELOG",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE",
    "Manifest",
    "README",
    "Rakefile",
    "TODO",
    "VERSION",
    "bin/jsus",
    "jsus.gemspec",
    "lib/jsus.rb",
    "lib/jsus/container.rb",
    "lib/jsus/package.rb",
    "lib/jsus/packager.rb",
    "lib/jsus/pool.rb",
    "lib/jsus/source_file.rb",
    "lib/jsus/tag.rb",
    "spec/data/Basic/README",
    "spec/data/Basic/app/javascripts/Orwik/Source/Library/Color.js",
    "spec/data/Basic/app/javascripts/Orwik/Source/Widget/Input/Input.Color.js",
    "spec/data/Basic/app/javascripts/Orwik/Source/Widget/Input/Input.js",
    "spec/data/Basic/app/javascripts/Orwik/Source/Widget/Widget.js",
    "spec/data/Basic/app/javascripts/Orwik/package.yml",
    "spec/data/ChainDependencies/app/javascripts/Class/Source/Class.js",
    "spec/data/ChainDependencies/app/javascripts/Class/package.yml",
    "spec/data/ChainDependencies/app/javascripts/Hash/Source/Hash.js",
    "spec/data/ChainDependencies/app/javascripts/Hash/package.yml",
    "spec/data/ChainDependencies/app/javascripts/Mash/Source/Mash.js",
    "spec/data/ChainDependencies/app/javascripts/Mash/package.yml",
    "spec/data/Extensions/app/javascripts/Core/Source/Class.js",
    "spec/data/Extensions/app/javascripts/Core/package.yml",
    "spec/data/Extensions/app/javascripts/Orwik/Extensions/Class.js",
    "spec/data/Extensions/app/javascripts/Orwik/package.yml",
    "spec/data/ExternalDependencies/app/javascripts/Orwik/Source/Test.js",
    "spec/data/ExternalDependencies/app/javascripts/Orwik/package.yml",
    "spec/data/ExternalInternalDependencies/Core/Class/Source/Class.js",
    "spec/data/ExternalInternalDependencies/Core/Class/Source/Type.js",
    "spec/data/ExternalInternalDependencies/Core/Class/package.yml",
    "spec/data/ExternalInternalDependencies/Core/Hash/Source/Hash.js",
    "spec/data/ExternalInternalDependencies/Core/Hash/package.yml",
    "spec/data/ExternalInternalDependencies/Core/Mash/Source/Mash.js",
    "spec/data/ExternalInternalDependencies/Core/Mash/package.yml",
    "spec/data/ExternalInternalDependencies/Test/Source/Library/Color.js",
    "spec/data/ExternalInternalDependencies/Test/Source/Widget/Input/Input.Color.js",
    "spec/data/ExternalInternalDependencies/Test/Source/Widget/Input/Input.js",
    "spec/data/ExternalInternalDependencies/Test/Source/Widget/Widget.js",
    "spec/data/ExternalInternalDependencies/Test/package.yml",
    "spec/data/JsonPackage/Source/Sheet.DOM.js",
    "spec/data/JsonPackage/Source/Sheet.js",
    "spec/data/JsonPackage/Source/SheetParser.CSS.js",
    "spec/data/JsonPackage/Source/sg-regex-tools.js",
    "spec/data/JsonPackage/package.json",
    "spec/data/OutsideDependencies/README",
    "spec/data/OutsideDependencies/app/javascripts/Core/Source/Class/Class.Extras.js",
    "spec/data/OutsideDependencies/app/javascripts/Core/Source/Class/Class.js",
    "spec/data/OutsideDependencies/app/javascripts/Core/Source/Native/Hash.js",
    "spec/data/OutsideDependencies/app/javascripts/Core/package.yml",
    "spec/data/OutsideDependencies/app/javascripts/Orwik/Source/Library/Color.js",
    "spec/data/OutsideDependencies/app/javascripts/Orwik/Source/Widget/Input/Input.Color.js",
    "spec/data/OutsideDependencies/app/javascripts/Orwik/Source/Widget/Input/Input.js",
    "spec/data/OutsideDependencies/app/javascripts/Orwik/Source/Widget/Widget.js",
    "spec/data/OutsideDependencies/app/javascripts/Orwik/package.yml",
    "spec/data/bad_test_source_one.js",
    "spec/data/bad_test_source_two.js",
    "spec/data/test_source_one.js",
    "spec/lib/jsus/container_spec.rb",
    "spec/lib/jsus/package_spec.rb",
    "spec/lib/jsus/packager_spec.rb",
    "spec/lib/jsus/pool_spec.rb",
    "spec/lib/jsus/source_file_spec.rb",
    "spec/lib/jsus/tag_spec.rb",
    "spec/shared/class_stubs.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/markiz/jsus}
  s.licenses = ["Public Domain"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Javascript packager and dependency resolver}
  s.test_files = [
    "spec/lib/jsus/container_spec.rb",
    "spec/lib/jsus/package_spec.rb",
    "spec/lib/jsus/packager_spec.rb",
    "spec/lib/jsus/pool_spec.rb",
    "spec/lib/jsus/source_file_spec.rb",
    "spec/lib/jsus/tag_spec.rb",
    "spec/shared/class_stubs.rb",
    "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<bundler>, [">= 0"])
      s.add_runtime_dependency(%q<rspec>, [">= 0"])
      s.add_runtime_dependency(%q<jeweler>, [">= 0"])
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
      s.add_runtime_dependency(%q<json_pure>, [">= 0"])
      s.add_runtime_dependency(%q<rgl>, [">= 0"])
      s.add_runtime_dependency(%q<choice>, [">= 0"])
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
      s.add_runtime_dependency(%q<json_pure>, [">= 0"])
      s.add_runtime_dependency(%q<rgl>, [">= 0"])
      s.add_runtime_dependency(%q<choice>, [">= 0"])
    else
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<json_pure>, [">= 0"])
      s.add_dependency(%q<rgl>, [">= 0"])
      s.add_dependency(%q<choice>, [">= 0"])
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<json_pure>, [">= 0"])
      s.add_dependency(%q<rgl>, [">= 0"])
      s.add_dependency(%q<choice>, [">= 0"])
    end
  else
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<json_pure>, [">= 0"])
    s.add_dependency(%q<rgl>, [">= 0"])
    s.add_dependency(%q<choice>, [">= 0"])
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<json_pure>, [">= 0"])
    s.add_dependency(%q<rgl>, [">= 0"])
    s.add_dependency(%q<choice>, [">= 0"])
  end
end

