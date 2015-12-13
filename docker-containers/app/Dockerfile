# Main application for reddit search
FROM        perl:latest
MAINTAINER Jason Baumgartner jason@pushshift.io

RUN apt-get update && apt-get install -y mysql-client
RUN curl -L http://cpanmin.us | perl - App::cpanminus
RUN cpanm DBI DBD::mysql Mojolicious Mojolicious::Lite Cpanel::JSON::XS Math::Base36 Text::Markdown HTML::Entities Math::BaseCnv
ADD rsapp /opt/rsapp
CMD /opt/rsapp/script/rsapp prefork
EXPOSE 3000
