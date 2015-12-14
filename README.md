# Docker-Reddit-Sphinxsearch

#### What does this do?

This application allows one to process Reddit JSON objects and index them using Sphinxsearch and MySQL to provide a full-featured RESTful service.  The application uses three Docker containers to keep a fully encapsulated environment that can also be expanded outside of Docker if needed. 

#### Prerequisites 

The programs docker and git should be installed before installation of this repository.  A MySQL client is also very helpful and highly recommended.  Also, you'll want to make sure you have a program to uncompress data if needed (bzip2 for instance).  The steps below are for a Debian based architecture such as Ubuntu 14.04, but other environments can be used if Docker is supported on them.  

#### Prerequisite Installation for Ubuntu 14.04+ 

1.  ```which git || sudo apt-get install git```
2.  ```which docker || sudo wget -qO- https://get.docker.com/ | sh```
3.  ```which mysql || sudo apt-get install mysql-client-core-5.6```
4.  ```which bzip2 || sudo apt-get install bzip2```

#### Main Installation Steps:

1.  ```git clone https://github.com/pushshift/Docker-Reddit-Sphinxsearch.git```
2.  ```cd Docker-Reddit-Sphinxsearch/docker-containers```
3.  ```docker build -t rs-sphinxsearch sphinxsearch```
4.  ```docker build -t rs-database database```
5.  ```docker build -t rs-app app```
6.  ```docker run -d --name rs-sphinxsearch rs-sphinxsearch```
7.  ```docker run -d --name rs-database -e MYSQL_ALLOW_EMPTY_PASSWORD=yes rs-database```
8.  ```docker run -dt --name rs-app -p 3000:3000 -v /tmp:/tmp --link rs-database --link rs-sphinxsearch rs-app```

#### What does this do?

This will create three running containers (rs-sphinxsearch, rs-database and rs-app).  The rs-app application container is linked to the two other containers.  The application api is now available on port 3000 of localhost.  You can configure nginx or apache to reverse proxy to this port and include SSL, gzip, etc.  

You will need to get data from http://files.pushshift.io/reddit/comments/monthly.

To get started, try grabbing the file located at http://files.pushshift.io/reddit/comments/monthly/RC_2010-01.bz2.  Put this file in your hosts /tmp directory.  Once you have this file, you can load it into the database.  The easiest way to do this is to enter the application container and load it from the /tmp directory, which is mapped to your host's /tmp directory in step 8 above.  

#### Importing data from the application container

1.  ```docker exec -it rs-app bash``` (You should now be in the container evidenced by a new prompt)
2.  ```bzip2 -cd /tmp/RC_2010-01.bz2 | /opt/rsapp/load-data.pl```
