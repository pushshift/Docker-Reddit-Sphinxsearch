# Main application for reddit search
FROM        perl:latest
MAINTAINER Jason Baumgartner jason@pushshift.io

RUN apt-get update && apt-get install -y mysql-client nano vim bzip2 lbzip2
RUN curl -L http://cpanmin.us | perl - App::cpanminus
RUN cpanm DBI DBD::mysql Mojolicious Mojolicious::Lite Cpanel::JSON::XS Math::Base36 Text::Markdown HTML::Entities Math::BaseCnv Term::ANSIColor Time::Piece
ADD rsapp /opt/rsapp
CMD /opt/rsapp/script/rsapp prefork
EXPOSE 3000
