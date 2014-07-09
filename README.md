forum-watcher
=============

A fairly primitive tool for scraping forums. The approach is:

- Parse a forum for thread topics and URLS
- Apply a regex pattern to thread topic (or the contents of each individual thread)
- E-mail on match

This really should be built into a more general framework. Currently, a different script exists for each forum or site to be scraped, with different xpath and regex patterns.
