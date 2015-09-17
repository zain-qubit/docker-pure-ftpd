FROM debian:wheezy

MAINTAINER Zain ul Abideen <zain@qubit.com>

# properly setup debian sources
ENV DEBIAN_FRONTEND noninteractive
RUN echo "deb http://http.debian.net/debian wheezy main\n\
deb-src http://http.debian.net/debian wheezy main\n\
deb http://http.debian.net/debian wheezy-updates main\n\
deb-src http://http.debian.net/debian wheezy-updates main\n\
deb http://security.debian.org wheezy/updates main\n\
deb-src http://security.debian.org wheezy/updates main\n\
" > /etc/apt/sources.list
RUN apt-get -y update

# install package building helpers
RUN apt-get -y --force-yes install dpkg-dev debhelper

# install dependancies
RUN apt-get -y build-dep pure-ftpd

# build from source
RUN mkdir /tmp/pure-ftpd/ && \
	cd /tmp/pure-ftpd/ && \
	apt-get source pure-ftpd && \
	cd pure-ftpd-* && \
	sed -i '/^optflags=/ s/$/ --without-capabilities/g' ./debian/rules && \
	dpkg-buildpackage -b -uc

# install the new deb files
RUN dpkg -i /tmp/pure-ftpd/pure-ftpd-common*.deb
RUN apt-get -y install openbsd-inetd
RUN dpkg -i /tmp/pure-ftpd/pure-ftpd_*.deb

# Prevent pure-ftpd upgrading
RUN apt-mark hold pure-ftpd pure-ftpd-common

# setup ftpgroup and ftpuser
RUN groupadd ftpgroup
RUN useradd -g ftpgroup -d /dev/null -s /etc ftpuser

# generate self-signed certificate and private key
RUN mkdir -p /etc/ssl/private/
RUN openssl req -x509 -nodes -days 7300 -newkey rsa:2048 -keyout /etc/ssl/private/pure-ftpd.pem -out /etc/ssl/private/pure-ftpd.pem -subj "/C=_/ST=_/L=_/O=_/OU=_/CN=_/emailAddress=_"
RUN chmod 600 /etc/ssl/private/pure-ftpd.pem

# startup
CMD /usr/sbin/pure-ftpd --verboselog --tls=1 -p 50000:50009 -c 5 -C 10 -l puredb:/etc/pure-ftpd/pureftpd.pdb -E -j -R

EXPOSE 21/tcp 50000-50009
