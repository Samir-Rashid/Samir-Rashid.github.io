# Nix environment for Jekyll blog development

# The instructions from this blog post worked.
# https://nathan.gs/2019/04/19/using-jekyll-and-nix-to-blog/
# $ nix-shell -p bundler -p bundix --run 'bundler update; bundler lock; bundler package --no-install --path vendor; bundix; rm -rf vendor'

with import <nixpkgs> { };

let jekyll_env = bundlerEnv rec {
    name = "jekyll_env";
    inherit ruby;
    gemfile = ./Gemfile;
    lockfile = ./Gemfile.lock;
    gemset = ./gemset.nix;
  };
in
  stdenv.mkDerivation rec {
    name = "jekyll";
    buildInputs = [ jekyll_env bundler ruby zlib nodejs_24 ];

    # need to update the main.min.js if you edit js files
    shellHook = ''
      # alias make='${jekyll_env}/bin/jekyll serve -l -H localhost'
      npm i
      npm run uglify
      exec ${jekyll_env}/bin/jekyll serve --watch --force_polling --future
    '';
  }

# echo "Use `bundle exec jekyll serve`"
# BUNDLE_FORCE_RUBY_PLATFORM = "true";


# To update from upstream:

# git checkout -b academicpages-master master
# git pull https://github.com/academicpages/academicpages.github.io.git master
# git pull https://github.com/academicpages/academicpages.github.io.git master --no-rebase
# git checkout master
# git merge academicpages-master
