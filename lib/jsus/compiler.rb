module Jsus::Compiler
  # Handles main features of jsus
  extend self

  def generate_includes(package, includes_root, output_file)
    File.open(output_file, "w") do |f|
      c = Jsus::Container.new(*(package.source_files.to_a + package.linked_external_dependencies.to_a))
      paths = c.required_files(includes_root)
      f.puts Jsus::Util::CodeGenerator.generate_includes(paths)
    end
  end

end
