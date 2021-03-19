FROM oraclelinux:7-slim
MAINTAINER yoku0825

RUN yum upgrade -y && yum clean all
RUN yum install -y oracle-epel-release-el7 && yum clean all
RUN yum install -y wget tar xz gzip openssl11-libs sudo && yum clean all
RUN wget -q https://downloads.mysql.com/archives/get/p/23/file/mysql-8.0.22-linux-glibc2.12-x86_64.tar.xz \
      -O /tmp/mysql-8.0.22-linux-glibc2.12-x86_64.tar.xz && \
    tar xf /tmp/mysql-8.0.22-linux-glibc2.12-x86_64.tar.xz mysql-8.0.22-linux-glibc2.12-x86_64/bin/mysql{,binlog} && \
    mv mysql-8.0.22-linux-glibc2.12-x86_64/bin/mysql /usr/bin/mysql80 && \
    mv mysql-8.0.22-linux-glibc2.12-x86_64/bin/mysqlbinlog /usr/bin/mysqlbinlog80 && \
    rm /tmp/mysql-8.0.22-linux-glibc2.12-x86_64.tar.xz && \
    rm -r mysql-8.0.22-linux-glibc2.12-x86_64 && \
    wget -q https://downloads.mysql.com/archives/get/p/23/file/mysql-5.7.32-linux-glibc2.12-x86_64.tar.gz \
      -O /tmp/mysql-5.7.32-linux-glibc2.12-x86_64.tar.gz && \
    tar xf /tmp/mysql-5.7.32-linux-glibc2.12-x86_64.tar.gz mysql-5.7.32-linux-glibc2.12-x86_64/bin/mysql{,binlog} && \
    mv mysql-5.7.32-linux-glibc2.12-x86_64/bin/mysql /usr/bin/mysql57 && \
    mv mysql-5.7.32-linux-glibc2.12-x86_64/bin/mysqlbinlog /usr/bin/mysqlbinlog57 && \
    rm /tmp/mysql-5.7.32-linux-glibc2.12-x86_64.tar.gz && \
    rm -r mysql-5.7.32-linux-glibc2.12-x86_64
COPY entrypoint.sh /opt/binlog_stream/entrypoint.sh
COPY binlog_stream_wrapper.sh /opt/binlog_stream/binlog_stream_wrapper.sh

ENTRYPOINT /opt/binlog_stream/entrypoint.sh
