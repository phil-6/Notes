# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "@rails/request.js", to: "requestjs.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# Lexxy rich text editor - using CDN until vendored version is available
pin "lexxy", to: "https://cdn.jsdelivr.net/npm/@37signals/lexxy@0.1.0/dist/lexxy.js"
pin "@rails/activestorage", to: "activestorage.esm.js"
