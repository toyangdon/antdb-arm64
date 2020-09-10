FROM centos:7
#RUN rm -Rf /etc/yum.repos.d/*.repo
#ADD ips.repo /etc/yum.repos.d/
RUN yum clean all && yum makecache
RUN yum install -y perl-ExtUtils-Embed flex bison readline-devel zlib-devel openssl-devel pam-devel libxml2-devel libxslt-devel openldap-devel python-devel libssh2-devel
RUN rpm --rebuilddb && yum install -y sg3_utils lrzsz vim which make wget gcc rsync net-tools unzip dos2unix strace gdb sudo
RUN rpm --rebuilddb && yum -y install openssh-server openssh-clients
RUN sed -ri 's/session required pam_loginuid.so/#session required pam_loginuid.so/g' /etc/pam.d/sshd
RUN sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config
RUN sed -i "s/#UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_ecdsa_key
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_ed25519_key
#ADD adb-4.0.617ddbdf.tar.gz /tmp/
COPY antdb.tar.gz /tmp/
#RUN rpm -ivh /tmp/adb-4.0.617ddbdf-10.el7.centos.x86_64.rpm && rpm -ivh /tmp/adb-debuginfo-4.0.617ddbdf-10.el7.centos.x86_64.rpm
RUN cd /tmp && mkdir -p /opt/app/adb && tar -xf antdb.tar.gz -C /opt/app/adb
RUN echo "root:123456" | chpasswd
RUN groupadd adb && useradd -g adb adb && mkdir -p /home/adb/data/shell && chown -R adb:adb /home/adb/data && chmod -R 777 /home/adb
RUN echo "adb:123456" | chpasswd
RUN chown -R adb:adb /opt/app/adb && chmod -R 755 /opt/app/adb
RUN sed -i '/^adb          ALL=(ALL)       NOPASSWD: ALL$/d' /etc/sudoers && sed -i '$a\adb          ALL=(ALL)       NOPASSWD: ALL' /etc/sudoers
USER adb
ENV ADB_HOME /opt/app/adb
ENV PATH $ADB_HOME/bin:$PATH
ENV LD_LIBRARY_PATH=$ADB_HOME/lib:$LD_LIBRARY_PATH
ENV PARAMS=""
ADD start.sh /home/adb/data/shell
#ADD init_pgxc_node.sh /home/adb/data/shell
RUN sudo chmod 755 /home/adb/data/shell/*.sh
CMD echo $PARAMS > /tmp/params.txt && /home/adb/data/shell/start.sh && tail -f /tmp/params.txt
