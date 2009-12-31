module GoogleClosureCompiler
  class Javascript
    DEFAULT_CLI_OPTIONS = {
      :warning_level        => 'QUIET',
      :summary_detail_level => '0',
      :third_party          => 'true'
    }.freeze

    def initialize(content)
      @content = content
    end

    def compiled
      if cli_installed?
        compile_through_cli
      else
        response = GoogleClosureCompiler::Request.new(@content).send
        if response.success?
          response.compiled_code
        elsif response.file_too_big? && ActionMailer::Base.default_url_options[:host]
          request = GoogleClosureCompiler::Request.new(@content)
          save_content_to_tmp_file
          request.code_url = "http://#{ActionMailer::Base.default_url_options[:host]}/javascripts/google_closure_compiler_tmp.js"
          response = request.send
          File.delete content_file_path
          if response.success?
            response.compiled_code
          else
            @content
          end
        else
          @content
        end
      end
    end

  private
    
    def compile_through_cli
      save_to_tmp_file
      `#{GoogleClosureCompiler.java_path} -jar #{GoogleClosureCompiler.compiler_application_path} #{hash_to_options(cli_options)}`
      $?.success? ? File.read(compiled_content_file_path) : @content
    ensure
      delete_tmp_files
    end

    def cli_options
      DEFAULT_CLI_OPTIONS.merge({
        :js                   => content_file_path,
        :js_output_file       => compiled_content_file_path,
        :compilation_level    => GoogleClosureCompiler.compilation_level,
      })
    end

    def cli_installed?
      return unless GoogleClosureCompiler.compiler_application_path
      output = `#{GoogleClosureCompiler.java_path} -jar #{GoogleClosureCompiler.compiler_application_path} --helpshort`
      output.include?('Usage: java [jvm-flags...] com.google.javascript.jscomp.CompilerRunner [flags...] [args...]')
    end

    def delete_tmp_files
      File.delete(content_file_path) if File.exists?(content_file_path)
      File.delete(compiled_content_file_path) if File.exists?(compiled_content_file_path)
    end
    
    def save_to_tmp_file
      File.open(content_file_path, 'w+') { |file| file.write @content }
    end
    
    def content_file_path
      @content_file_path ||= Rails.root.join('tmp', "google_closure_compiler_#{Time.now.to_i}.js")
    end

    def compiled_content_file_path
      @compiled_content_file_path ||= Rails.root.join('tmp', "google_closure_compiler_output_#{Time.now.to_i}.js")
    end
    
    def hash_to_options(hash)
      hash.map {|key, value| "--#{key} #{value}" }.join(' ')
    end
  end
end
