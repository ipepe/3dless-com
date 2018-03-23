require 'slim'

set :build_dir, 'docs'
set :fonts_dir, 'fonts'

page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

activate :sprockets

configure :development do
  activate :livereload, apply_js_live: false
end

configure :build do
  activate :minify_css
  activate :minify_javascript
end
