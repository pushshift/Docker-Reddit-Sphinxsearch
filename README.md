# Docker-Reddit-Sphinxsearch
Docker container for sphinxsearch -- used for adding Reddit comments for search 

Install steps:

1.  ```git clone https://github.com/pushshift/Docker-Reddit-Sphinxsearch.git```
2.  ```docker build -t redditsphinx .```
3.  ```docker run -d -p 9306:9306 --name rs redditsphinx``` (maps host port 9306 to docker container port 9306 -- adjust if needed)

Test:

```mysql -P 9306 -h 127.0.0.1```

This should bring up a MySQL interactive prompt.

