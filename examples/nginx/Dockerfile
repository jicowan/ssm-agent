FROM amazonlinux:2

RUN yum update -y \
 && yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm \
 && yum install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm \
 && yum install -y python \
 && yum install -y shadow-utils \
 && amazon-linux-extras install -y epel \
 && yum install -y supervisor \
 && yum install -y nginx \
 && yum install -y net-tools \
 && yum install -y sudo \
 && yum clean all \
 && rm -rf /var/cache/yum \
 && mv /etc/amazon/ssm/seelog.xml.template /etc/amazon/ssm/seelog.xml 
RUN adduser ssm-user
RUN echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
 && groupmems -a ssm-user -g wheel
COPY files/systemctl.py /usr/bin/systemctl
COPY files/entrypoint.sh /usr/local/bin/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY files/nginx.conf /etc/nginx/nginx.conf
RUN chmod +x /usr/local/bin/entrypoint.sh 
EXPOSE 80
CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf" ]
