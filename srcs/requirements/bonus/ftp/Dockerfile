FROM debian:bullseye

LABEL version="1.0" description="FTP Server for WordPress Files"

RUN apt-get update && apt-get install -y --no-install-recommends \
	vsftpd \
	&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/vsftpd /var/run/vsftpd /var/log && \
	touch /var/log/vsftpd.log

COPY conf/vsftpd.conf /etc/vsftpd/vsftpd.conf

COPY tools/setup.sh /tmp/setup.sh
RUN chmod +x /tmp/setup.sh

EXPOSE 21 21100-21110

ENTRYPOINT ["/tmp/setup.sh"]
CMD ["vsftpd", "/etc/vsftpd/vsftpd.conf"]
