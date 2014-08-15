#!/usr/bin/python

PORT = 8000

import BaseHTTPServer
import json
import re
import sys

words = {}

class WordServer(BaseHTTPServer.BaseHTTPRequestHandler):
  # Server Headers
  sys_version = ''
  server_version = 'WordServer/1.0.0'

  # use a json error message format
  error_content_type = 'application/json'
  error_message_format = '{"error": "%(message)s"}\n'

  # dummy log handler method
  def log_message(self, *args, **kwargs):
    return

  # PUT doesn't make sense in this context since we're not creating/updating the URI (probably should be POST instead), but roll with it anyway
  def do_PUT(req):
    # check if the URI is /words/WORDNAME
    uri = re.match(r'/word/([^/]+)$', req.path, re.L|re.U)
    if uri:
      try:
        # It's unclear if we should store WORDNAME from the URI or ONE_WORD from the json blob, so save the WORDNAME just in case
        word = re.match(r'([^\W\d_]+)$', uri.group(1), re.L|re.U).group(1)
        # check if Content-Length is set
        if 'Content-Length' not in req.headers:
          raise
        # try to read the content and parse as json
        data = json.loads(req.rfile.read(int(req.headers['Content-Length'])))
        # make sure 'word' is in the data
        if 'word' not in data:
          raise
        # make sure the value of word is a single word
        jsonword = re.match(r'([^\W\d_]+)$', data['word'], re.L|re.U).group(1).lower()
        # It's unclear if we should store WORDNAME from the URI or ONE_WORD from the json blob, but since we're making the effort to accept this json, we'll use the word from that.
        if jsonword in words:
          # word already exists, increment the count by one
          words[jsonword] += 1
        else:
          # word did not exist, add it with a count of one
          words[jsonword] = 1
        # send back an empty response of 204 (No Content)
        req.send_response(204)
      except:
        # Send back a 400 Bad Request error message.
        req.send_response(400)
        req.send_header('Content-Type', 'application/json')
        req.end_headers()
        req.wfile.write('{"error": "PUT requests must be one word in length"}\n')
        return
    else:
      # URI is not one that we support, send back a 404
      req.send_error(404)

  def do_GET(req):
    # check if the URI is /words or /words/WORDNAME
    uri = re.match(r'/words(/([^/]+))?$', req.path, re.L|re.U)
    if uri:
      try:
        data = ''
        # a word was specified
        if uri.group(2):
          # make sure it's a single word
          word = re.match(r'([^\W\d_]+)$', uri.group(2), re.L|re.U).group(1)
          if word in words:
            # if it exists, return the count
            data = {word: words[word]}
          else:
            # otherwise, return a fake hash of zero
            data = {word: 0}
        # no word was specified, print the whole list
        else:
          data = words
        req.send_response(200)
        req.send_header('Content-Type', 'application/json')
        req.end_headers()
        req.wfile.write(json.dumps(data, sort_keys=True))
        req.wfile.write('\n')
      except:
        req.send_error(400)
    else:
      # URI is not one that we support, send back a 404
      req.send_error(404)

if __name__ == '__main__':
  try:
    httpd = BaseHTTPServer.HTTPServer(('', PORT), WordServer)
    httpd.serve_forever()
  except KeyboardInterrupt:
    sys.stderr.write("Exiting on user interrupt.\n")
    sys.exit(0)
  except:
    sys.stderr.write("Error: %s" % sys.exc_info()[0])
    sys.exit(1)
