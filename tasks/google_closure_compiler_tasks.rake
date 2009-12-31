namespace :google_closure_compiler do
  namespace :config do
    desc 'Verify the Java executable and compiler JAR are in place'
    task :verify_paths => :environment do
      if File.exist?(GoogleClosureCompiler.java_path)
        puts "Java executable OK: #{GoogleClosureCompiler.java_path}"
      else
        puts "Java executable not found: #{GoogleClosureCompiler.java_path}"
        puts "Please install Java 1.6 or point to the right executable"
        puts "using the initializer."
      end

      if File.exist?(GoogleClosureCompiler.compiler_application_path)
        puts "Compiler OK: #{GoogleClosureCompiler.compiler_application_path}"
      else
        puts "Compiler not found: #{GoogleClosureCompiler.compiler_application_path}"
        puts "Try installing it using rake google_closure_compiler:compiler:install"
        puts "or set the right path in the initializer."
      end
    end
  end

  namespace :compiler do
    desc 'Downloads the Google Closure Compiler JAR file and installs it under vendor'
    task :install do
      if File.exists?('vendor/closure-compiler/compiler.jar')
        puts "Closure Compiler is already installed on this app."
        exit
      end

      require 'open-uri'

      url     = 'http://closure-compiler.googlecode.com/files/compiler-latest.zip'
      exdir   = 'closure-compiler'
      zipfile = 'compiler-latest.zip'

      chdir 'vendor' do
        puts "Downloading Closure from #{url}"
        File.open(zipfile, 'wb') do |dst|
          open url do |src|
            while chunk = src.read(4096)
              dst << chunk
            end
          end
        end

        puts 'Unpacking Closure...'
        rm_rf exdir
        `unzip #{zipfile} -d #{exdir}`
        rm_f zipfile

        puts 'Closure successfully installed.'
      end
    end

    desc 'Removes the Google Closure Compiler from vendor'
    task :remove do
      rm_rf 'vendor/closure-compiler'
      puts 'Google Closure Compiler removed'
    end

    desc 'Installs the Google Closure Compiler removing the existing installation first'
    task :reinstall => [:remove, :install]
  end
end
