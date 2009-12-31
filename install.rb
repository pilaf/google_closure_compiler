#initializer = <<EOT
#GoogleClosureCompiler.configure do |config|
#  #config.compiler_application_path = '/path/to/compiler.jar'
#  #config.java_path = '/path/to/java'
#  #config.compilation_level = :simple
#end
#EOT

# Display INSTALL document
puts '', IO.read(File.join(File.dirname(__FILE__), 'INSTALL')), ''
