FROM debian:latest 

RUN apt-get update
RUN apt-get install -y wget libexpat1 libodbc1 libmysqlclient18 libmysqlclient18 libpq5
WORKDIR "/tmp"
RUN wget http://sphinxsearch.com/files/sphinxsearch_2.2.10-release-1~jessie_amd64.deb
RUN dpkg -i sphinx*
RUN rm sphinxsearch*
RUN mkdir -p /etc/sphinxsearch
RUN mkdir -p /usr/sphinxsearch/data
ADD sphinx.conf /etc/sphinxsearch/sphinx.conf
EXPOSE 9312 9306
ENTRYPOINT ["/usr/bin/searchd","-c","/etc/sphinxsearch/sphinx.conf","--nodetach"] 
