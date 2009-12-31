require "rexml/document"

# Adapted from Smurf plugin http://github.com/thumblemonks/smurf/
if Rails.version =~ /^2\.2\./

  # Support for Rails >= 2.2.x
  module GoogleClosureCompiler

    module JavaScriptSources
    private
      def joined_contents
        GoogleClosureCompiler::Javascript.new(super).compiled
      end
    end

  end

  ActionView::Helpers::AssetTagHelper::JavaScriptSources.send(:include, GoogleClosureCompiler::JavaScriptSources)

else

  # Support for Rails <= 2.1.x
  module ActionView::Helpers::AssetTagHelper
  private

    def join_asset_file_contents_with_compilation(files)
      content = join_asset_file_contents_without_compilation(files)
      if !files.grep(%r[/javascripts]).empty?
        content = GoogleClosureCompiler::Javascript.new(content).compiled
      end
      content
    end

    alias_method_chain :join_asset_file_contents, :compilation

  end

end

module GoogleClosureCompiler

  # Map compilation level shorthands to their expanded
  # version for use with the actual compiler
  COMPILATION_LEVELS = {
    :whitespace => 'WHITESPACE_ONLY',
    :simple     => 'SIMPLE_OPTIMIZATIONS',
    :advanced   => 'ADVANCED_OPTIMIZATIONS'
  }.freeze

  # Use vendor/closure-compiler/compiler.jar as default path
  # for the Closure Compiler Java app
  DEFAULT_COMPILER_APPLICATION_PATH = Rails.root.join('vendor', 'closure-compiler', 'compiler.jar').freeze

  # By default try to find the Java executable path using `which`.
  # Fallback to plain 'java' if nothing is returned
  DEFAULT_JAVA_PATH = [`which java`.chomp, 'java'].reject(&:blank?).first.freeze

  class << self
    attr_writer :compilation_level, :java_path, :compiler_application_path

    # Shorthand for prettier configuration,
    # yields self
    #
    def configure
      yield self
    end

    # Returns the user-defined compiler application path
    # if given, otherwise fallbacks to <tt>vendor/closure-compiler/compile.jar</tt>
    #
    def compiler_application_path
      @compiler_application_path || DEFAULT_COMPILER_APPLICATION_PATH
    end
  
    # Returns a compilation level string suitable for use with
    # the compiler
    #
    def compilation_level
      # Try to map the compilation level to its expanded
      # version first, otherwise just return what was given
      COMPILATION_LEVELS[@compilation_level || :simple] || @compilation_level
    end
    
    # Returns the user-defined Java executable path
    # if given, otherwise fallbacks to the return value of
    # running the shell command:
    #
    #   which java
    # 
    # or simply <tt>'java'</tt> if nothing is found
    #
    def java_path
      @java_path || DEFAULT_JAVA_PATH
    end
  end
end
