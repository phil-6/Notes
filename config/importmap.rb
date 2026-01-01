# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "@rails/request.js", to: "requestjs.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# Lexxy rich text editor
pin "lexxy", to: "lexxy.js"
pin "@rails/activestorage", to: "activestorage.esm.js"

# Sortable.js for drag and drop
pin "sortablejs", to: "https://cdn.jsdelivr.net/npm/sortablejs@1.15.3/modular/sortable.esm.js"
