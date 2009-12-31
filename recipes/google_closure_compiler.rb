after "deploy:update", "deploy:google_closure_compiler:install"

namespace :deploy
  namespace :google_closure_compiler do
    task :create_compiler_dir do
      run "mkdir -p #{shared_path}/closure-compiler"
    end

    task :create_symlink do
      symlink = "#{current_path}/vendor/closure-compiler"
      run "[ -h #{symlink} ] || ln -sT #{shared_path}/closure-compiler #{symlink}"
    end

    desc "Install the Google Closure Compiler JAR file"
    task :install do
      run "cd #{current_path} && rake google_closure_compiler:compiler:install"
    end

    before 'deploy:google_closure_compiler:create_symlink', 'deploy:google_closure_compiler:create_compiler_dir'
    before 'deploy:google_closure_compiler:install', 'deploy:google_closure_compiler:create_symlink'
  end
end
