
Docker Pure-ftpd Server
============================

This includes both a plain FTP server and a FTP-over-SSL/TLS (FTPS) server.

----------------------------------------

**A self-signed certificate and a private key is generated to use FTP-over-SSL/TLS (FTPS).**

You need to replace the underscores in the following line in the `Dockerfile` with appropriate values:

```
# generate self-signed certificate and private key
RUN mkdir -p /etc/ssl/private/
RUN openssl req -x509 -nodes -days 7300 -newkey rsa:2048 -keyout /etc/ssl/private/pure-ftpd.pem -out /etc/ssl/private/pure-ftpd.pem -subj "/C=_/ST=_/L=_/O=_/OU=_/CN=_/emailAddress=_"
```

- **/C=** 2 letter ISO country code
- **/ST=** State
- **/L=** Location, city
- **/O=** Organization
- **/OU=** Organizational Unit, Department
- **/CN=** Common Name, for a website certificate this is the FQDN
- **/emailAddress=** Email ID

----------------------------------------

Starting it 
------------------------------

`docker run -d -p 21:21 -p 50000-50009:50000-50009 --name ftpd_server zaininfo/pure-ftpd `

Operating it
------------------------------

`docker exec -it ftpd_server /bin/bash`

Example usage once inside
------------------------------

Create an ftp user: `e.g. bob with chroot access only to /home/ftpusers/bob`
```bash
pure-pw useradd bob -u ftpuser -d /home/ftpusers/bob
pure-pw mkdb
```
*No restart should be needed.*

More info on usage here: https://download.pureftpd.org/pure-ftpd/doc/README.Virtual-Users


Test your connection
-------------------------
From the host machine:
```bash
ftp -p localhost 21
```

----------------------------------------

Default pure-ftpd options explained
-------------------------------------

```
/usr/sbin/pure-ftpd # path to pure-ftpd executable
--verboselog (logs all actions to either /var/log/messages or a separate pureftpd.log)
--tls=1 (clients can connect either the traditional way or through an
SSL/TLS layer)
-p 50000:50009 (open a port range to the FTP server)
-c 5 # --maxclientsnumber (no more than 5 people at once)
-C 10 # --maxclientsperip (no more than 10 requests from the same ip)
-l puredb:/etc/pure-ftpd/pureftpd.pdb # --login (login file for virtual users)
-E # --noanonymous (only real users)
-j # --createhomedir (auto create home directory if it doesnt already exist)
-R # --nochmod (prevent usage of the CHMOD command)
```

For more information please see `man pure-ftpd`, or visit: https://www.pureftpd.org/

----------------------------------------


Development (via git clone)
```bash
# Clone the repo
git clone https://github.com/zaininfo/docker-pure-ftpd.git
cd docker-pure-ftpd
# Build the image
make build
# Run container in background:
make run
# enter a bash shell insdie the container:
make enter
```

Credits
-------------
Thanks for the help on stackoverflow with this!
https://stackoverflow.com/questions/23930167/installing-pure-ftpd-in-docker-debian-wheezy-error-421
