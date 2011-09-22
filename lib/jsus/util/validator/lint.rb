module Jsus
  module Util
    module Validator
      # Runs JSLint by Douglas Crockford on the source files
      class Lint < Base

        class <<self
          require 'execjs'

          # Javascript context for JSLint
          # @api semipublic
          def context
            @context ||= ExecJS.compile(lint_source)
          end

          # Source code for js lint
          # @api semipublic
          def lint_source
            @lint_source ||= File.read(lint_path)
          end # self.lint_source

          # File path for js lint source
          # @api semipublic
          def lint_path
            @lint_path ||= File.expand_path("../../../../../vendor/jslint.js", __FILE__)
          end # self.lint_path
        end # class <<self

        # Runs JSLint by Douglas Crockford on the source files
        # and returns validation errors.
        # @return [Array] validation errors
        # @api public
        def validation_errors
          @validation_errors ||= sources.inject([]) do |result, sf|
            errors = self.class.context.exec(%Q{JSLINT("#{sf.content.gsub('"', '\\"').gsub("\n", '\\n')}", \{#{lint_options}\}); return JSLINT.errors})
            errors.compact.each do |error|
              if error["id"] == "(error)"
                result << "in #{sf.filename} (#{error["line"]}:#{error["character"]}): #{error["reason"]}"
              end
            end
            result
          end
        end

        def lint_options
          "browser: true, undef: true, node: true, rhino: true, eqeq: true, vars: true, sloppy: true, white: true, adsafe: false, plusplus: true, maxerr: 50, indent: 4"
        end # lint_options
      end # class Lint
    end # module Validator
  end # module Util
end # module Jsus
