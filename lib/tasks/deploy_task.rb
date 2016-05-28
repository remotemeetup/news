desc "deploy to gh-pages"
task :upload do
  system "git subtree push --prefix=site git@github.com:remotemeetup/news.git gh-pages"
end
