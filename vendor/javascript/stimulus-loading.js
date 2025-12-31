// stimulus-loading.js is a minimal shim for the stimulus-loading module
// since we're loading controllers manually

export function eagerLoadControllersFrom(path, application) {
  // Controllers are already imported in the application
  console.log("Stimulus controllers loaded")
}

export function lazyLoadControllersFrom(path, application) {
  // Not used in this application
}
