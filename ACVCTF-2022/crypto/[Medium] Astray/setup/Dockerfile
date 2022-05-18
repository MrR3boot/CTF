FROM alpine:latest

RUN apk add --update --no-cache openssh 
COPY entrypoint.sh /
COPY flag.txt /root/
COPY id_rsa.pub /root/.ssh/authorized_keys
RUN echo "root:dFcV5D3@fG" | chpasswd
RUN echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config
ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 22
