#!/usr/bin/env python

import sys
import ujson
import MySQLdb

conn = MySQLdb.connect(host= "127.0.0.1",port=9306,db="rt")
conn.set_character_set('utf8')
x = conn.cursor()

for line in sys.stdin:
    j = ujson.loads(line)
    x.execute("""REPLACE INTO rt VALUES (%s,%s,%s,%s,%s,%s)""", (int(j['id'],36),j['body'],j['created_utc'],int(j['subreddit_id'][3:],36),int(j['link_id'][3:],36),j['score']))

conn.close()
