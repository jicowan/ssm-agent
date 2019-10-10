FROM amazonlinux:2
RUN yum update -y \
 && yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm \
 && yum install -y python \
 && yum install -y shadow-utils \
 && yum clean all \
 && rm -rf /var/cache/yum \
 && mv /etc/amazon/ssm/seelog.xml.template /etc/amazon/ssm/seelog.xml
COPY files/systemctl.py /usr/bin/systemctl
COPY files/entrypoint.sh /usr/local/bin/
RUN adduser ssm-user
RUN chmod +x /usr/local/bin/entrypoint.sh 
ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "systemctl", "start", "amazon-ssm-agent" ]