// Minimal @rails/request.js placeholder
// This is a lightweight fetch wrapper for Rails
export class FetchRequest {
  constructor(method, url, options = {}) {
    this.method = method
    this.url = url
    this.options = options
  }

  async perform() {
    const response = await fetch(this.url, {
      method: this.method,
      headers: {
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]')?.content,
        'Accept': 'application/json',
        ...this.options.headers
      },
      body: this.options.body
    })
    return response
  }
}

export function get(url, options) {
  return new FetchRequest('GET', url, options).perform()
}

export function post(url, options) {
  return new FetchRequest('POST', url, options).perform()
}

export function patch(url, options) {
  return new FetchRequest('PATCH', url, options).perform()
}

export function destroy(url, options) {
  return new FetchRequest('DELETE', url, options).perform()
}
