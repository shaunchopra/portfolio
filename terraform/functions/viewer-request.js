// CloudFront Function (cloudfront-js-2.0), viewer-request, for www.shaunchopra.com.
//  1. 301 apex (shaunchopra.com) -> https://www.shaunchopra.com (canonical host, SEO).
//  2. Map directory-style URLs to index.html for Astro `build.format: 'directory'`:
//       /          -> /index.html
//       /foo/      -> /foo/index.html
//       /foo       -> /foo/index.html   (last segment has no ".")
//       /foo.css   -> unchanged

var CANONICAL_HOST = 'www.shaunchopra.com';
var REDIRECT_HOSTS = { 'shaunchopra.com': true };

function buildQueryString(qs) {
  var parts = [];
  for (var key in qs) {
    var entry = qs[key];
    if (entry.multiValue) {
      for (var i = 0; i < entry.multiValue.length; i++) {
        parts.push(key + '=' + entry.multiValue[i].value);
      }
    } else if (entry.value === '') {
      parts.push(key);
    } else {
      parts.push(key + '=' + entry.value);
    }
  }
  return parts.length ? '?' + parts.join('&') : '';
}

function handler(event) {
  var request = event.request;
  var host = request.headers.host ? request.headers.host.value.toLowerCase() : '';

  if (REDIRECT_HOSTS[host]) {
    return {
      statusCode: 301,
      statusDescription: 'Moved Permanently',
      headers: {
        location: { value: 'https://' + CANONICAL_HOST + request.uri + buildQueryString(request.querystring) },
        'cache-control': { value: 'max-age=86400' }
      }
    };
  }

  var uri = request.uri;
  if (uri.endsWith('/')) {
    request.uri = uri + 'index.html';
  } else {
    var lastSegment = uri.substring(uri.lastIndexOf('/') + 1);
    if (lastSegment.indexOf('.') === -1) {
      request.uri = uri + '/index.html';
    }
  }
  return request;
}
