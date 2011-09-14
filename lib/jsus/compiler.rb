module Jsus::Compiler
  # Handles main features of jsus
  extend self

  def post_process!(content, postproc)
    postproc.each do |processor|
      case processor.strip
      when /^moocompat12$/i
        content.gsub!(/\/\/<1.2compat>.*?\/\/<\/1.2compat>/m, '')
        content.gsub!(/\/\*<1.2compat>\*\/.*?\/\*<\/1.2compat>\*\//m, '')
      when /^mooltie8$/i
        content.gsub!(/\/\/<ltIE8>.*?\/\/<\/ltIE8>/m, '')
        content.gsub!(/\/\*<ltIE8>\*\/.*?\/\*<\/ltIE8>\*\//m, '')
      else
        Jsus.logger.error "Unknown post-processor: #{processor}"
      end
    end
  end

  def generate_includes(package, includes_root, output_file)
    File.open(output_file, "w") do |f|
      c = Jsus::Container.new(*(package.source_files.to_a + package.linked_external_dependencies.to_a))
      paths = c.required_files(includes_root)
      f.puts Jsus::Util::CodeGenerator.generate_includes(paths)
    end
  end

end
