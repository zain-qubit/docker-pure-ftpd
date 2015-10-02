.PHONY: build run kill enter

build:
	sudo docker build --rm -t wheezy-pure-ftp-demo .

run: kill
	sudo docker run -d --name ftpd_server -p 21:21 -p 50000-50009:50000-50009 wheezy-pure-ftp-demo

kill:
	-sudo docker kill ftpd_server
	-sudo docker rm ftpd_server

enter:
	sudo docker exec -it ftpd_server sh -c "export TERM=xterm && bash"
