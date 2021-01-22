# Creamos la imagen a partir de ubuntu versión 18.04
FROM ubuntu:18.04

# Damos información sobre la imagen que estamos creando
LABEL \
	version="1.0" \
	description="Ubuntu + Apache2 + virtual host + ftp + ssh + git" \
	creationDate="20-01-2021" \
	maintainer="Ana Ribaguda <aribaguda@birt.eus>"

# Instalamos el editor nano, apache, proftpd, ssh, git
RUN \
	apt-get update \
	&& apt-get install nano \
	&& apt-get install apache2 --yes \
	&& apt-get install --yes proftpd \
	&& apt-get install ssh --yes \
	&& apt-get install git --yes \
	&& mkdir /var/www/html/sitio1 /var/www/html/sitio2


# Copiamos el index al directorio por defecto del servidor Web
COPY index1.html index2.html sitio1.conf sitio2.conf sitio1.key sitio1.cer proftpd.conf  tls.conf proftpd.key  proftpd.crt SSH-key/id_rsa_git /

RUN \
	mv /index1.html /var/www/html/sitio1/index.html \
	&& mv /index2.html /var/www/html/sitio2/index.html \
	&& mv /sitio1.conf /etc/apache2/sites-available \
	&& a2ensite sitio1 \
	&& mv /sitio2.conf /etc/apache2/sites-available \
	&& a2ensite sitio2 \
	&& mv /sitio1.key /etc/ssl/private \
	&& mv /sitio1.cer /etc/ssl/certs \
	&& a2enmod ssl
	
RUN mv /proftpd.conf  /etc/proftpd/proftpd.conf  \
    && mv /proftpd.key  /etc/ssl/private/proftpd.key \
    && mv /proftpd.crt  /etc/ssl/certs/proftpd.crt \
    && mv /tls.conf  /etc/proftpd/tls.conf 
   

RUN useradd -m -d /var/www/html/sitio1 -s /sbin/nologin -p $(openssl passwd -1 aribaguda1) aribaguda1 \
    && chown -R aribaguda1 /var/www/html/sitio1 \
	&& useradd -m -d /var/www/html/sitio2 -s /bin/bash -p $(openssl passwd -1 aribaguda2) aribaguda2 \
    && chown -R aribaguda2 /var/www/html/sitio2
	
RUN cd /etc && echo "aribaguda2" >> ftpusers

RUN eval "$(ssh-agent -s)" \
    && chmod 700 /id_rsa_git \
	&& ssh-add /id_rsa_git  \
	&& ssh-keyscan -H github.com >> /etc/ssh/ssh_known_hosts \
	&& git clone git@github.com:deaw-birt/deaw03-te1-ftp-anonimo.git   /srv/ftp/anonimo
	

# Indicamos el puerto que utiliza la imagen
EXPOSE 80
EXPOSE 443
EXPOSE 21  
EXPOSE 20 
EXPOSE 33 22 50000-50030

