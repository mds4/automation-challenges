#!/bin/bash

PORT=8000

echo -e "\033[34mStarting up and making sure the wordserver is running...\033[0m"
echo ""
curl -s -m 3 -o /dev/null "http://localhost:${PORT}/"
if [[ $? -ne 0 ]]; then
  echo -e "\033[31;1mThe wordserver doesn't appear to be running (or isn't listing on port ${PORT}). Please start it up and re-run $0\033[0m"
  exit 1
fi

echo -e "\033[36mprint the list of words (should be empty json):\033[0m"
curl -s "http://localhost:${PORT}/words"
echo ""


echo -e "\033[36madd some words into the list (no output)\033[0m"
curl -s -X PUT "http://localhost:${PORT}/word/foo" -d '{"word": "foo"}'
curl -s -X PUT "http://localhost:${PORT}/word/foo" -d '{"word": "foo"}'
curl -s -X PUT "http://localhost:${PORT}/word/foo" -d '{"word": "foo"}'
curl -s -X PUT "http://localhost:${PORT}/word/bar" -d '{"word": "bar"}'
curl -s -X PUT "http://localhost:${PORT}/word/bar" -d '{"word": "bar"}'
curl -s -X PUT "http://localhost:${PORT}/word/baz" -d '{"word": "baz"}'
curl -s -X PUT "http://localhost:${PORT}/word/testing" -d '{"word": "testing"}'
curl -s -X PUT "http://localhost:${PORT}/word/test" -d '{"word": "test"}'
curl -s -X PUT "http://localhost:${PORT}/word/testing" -d '{"word": "testing"}'
echo ""

echo -e "\033[36mprint the list of words again\033[0m"
curl -s "http://localhost:${PORT}/words"
echo ""

echo -e "\033[36mprint an existing word (bar)\033[0m"
curl -s "http://localhost:${PORT}/words/bar"
echo ""

echo -e "\033[36mprint a non-existing (but valid) word (omgwtfbbq) (prints with 0)\033[0m"
curl -s "http://localhost:${PORT}/words/omgwtfbbq"
echo ""

echo -e "\033[34mNow, test some things that should not work...\033[0m"
echo ""

echo -e "\033[36mTry a POST (should be 501 Not Implemented)\033[0m"
curl -s -X POST "http://localhost:${PORT}/words/"
echo ""

echo -e "\033[36mTry a GET to a non-existant endpoint (should be 404 Not Found)\033[0m"
curl -s "http://localhost:${PORT}/foobar"
echo ""

echo -e "\033[36mTry a PUT to a non-existant endpoint (should be 404 Not Found)\033[0m"
curl -s -X PUT "http://localhost:${PORT}/foobar"
echo ""

echo -e "\033[36mTry a PUT with no data (should be 400 Bad Request)\033[0m"
curl -s -X PUT "http://localhost:${PORT}/word/blah"
echo ""

echo -e "\033[36mTry a PUT with an invalid word in the URI (should be 400 Bad Request)\033[0m"
curl -s -X PUT "http://localhost:${PORT}/word/blah123" -d '{"word": "blah"}'
echo ""

echo -e "\033[36mTry a PUT with empty json (should be 400 Bad Request)\033[0m"
curl -s -X PUT "http://localhost:${PORT}/word/blah" -d '{}'
echo ""

echo -e "\033[36mTry a PUT with invalid json (should be 400 Bad Request)\033[0m"
curl -s -X PUT "http://localhost:${PORT}/word/blah" -d '{word => wait, what is this}'
echo ""

echo -e "\033[36mTry a PUT with empty 'word' in the json (should be 400 Bad Request)\033[0m"
curl -s -X PUT "http://localhost:${PORT}/word/blah" -d '{"word": ""}'
echo ""

echo -e "\033[36mTry a PUT without word in the json (should be 400 Bad Request)\033[0m"
curl -s -X PUT "http://localhost:${PORT}/word/blah" -d '{"notaword": "blah"}'
echo ""

echo -e "\033[36mTry a PUT with multiple words in the json (should be 400 Bad Request)\033[0m"
curl -s -X PUT "http://localhost:${PORT}/word/blah" -d '{["word": "one", "word": "two"]}'
echo ""

echo -e "\033[36mTry a PUT with an invalid word in the json (should be 400 Bad Request)\033[0m"
curl -s -X PUT "http://localhost:${PORT}/word/blah" -d '{"word": "not a word"}'
echo ""

echo -e "\033[36mTry a PUT with another invalid word in the json (should be 400 Bad Request)\033[0m"
curl -s -X PUT "http://localhost:${PORT}/word/blah" -d '{"word": "word!"}'
echo ""

echo -e "\033[36mTry a PUT with yet another invalid word in the json (should be 400 Bad Request)\033[0m"
curl -s -X PUT "http://localhost:${PORT}/word/blah" -d '{"word": "word123"}'
echo ""

echo -e "\033[36mTry a GET with an invalid word in the URI (should be 400 Bad Request)\033[0m"
curl -s "http://localhost:${PORT}/words/not%20a%20word"
echo ""
