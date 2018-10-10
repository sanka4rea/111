FROM ubuntu:16.04
MAINTAINER sanka4rea <sanka4rea@gmail.com>
LABEL Description="UCSC Genome Browser database"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y wget rsync \
    mysql-server \
    mysql-client-5.7 mysql-client-core-5.7 \
    libmysqlclient-dev && \
    apt-get clean

RUN mkdir /data && mkdir /var/run/mysqld

RUN { \
        echo '[mysqld]'; \
        echo 'skip-host-cache'; \
        echo 'skip-name-resolve'; \
        echo 'datadir = /data'; \
        echo 'local-infile = 1'; \
        echo 'default-storage-engine = MYISAM'; \
        echo 'bind-address = 0.0.0.0'; \
    } > /etc/mysql/my.cnf

RUN mysqld --initialize-insecure && chown -R mysql:mysql /data

RUN wget http://hgdownload.cse.ucsc.edu/admin/hgcentral.sql

RUN mysqld -u root & \
    sleep 6s &&\
    echo "GRANT ALL ON *.* TO admin@'%' IDENTIFIED BY 'admin'; FLUSH PRIVILEGES" | mysql && \
    echo "create database hgcentral" | mysql && \
    echo "create database hgFixed" | mysql && \
    echo "create database hg19" | mysql && \
    mysql -D hgcentral < hgcentral.sql && \
    rm hgcentral.sql

RUN rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg19/chromInfo.MYD /data/hg19 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg19/chromInfo.MYI /data/hg19 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg19/chromInfo.frm /data/hghg19 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg19/cytoBandIdeo.MYD /data/hg19 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg19/cytoBandIdeo.MYI /data/hg19 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg19/cytoBandIdeo.frm /data/hg19 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg19/grp.MYD /data/hg19 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg19/grp.MYI /data/hg19 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg38/grp.frm /data/hg19 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg19/hgFindSpec.MYD /data/hg19 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg19/hgFindSpec.MYI /data/hg19 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg19/hgFindSpec.frm /data/hg19 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg19/trackDb.MYD /data/hg19 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg19/trackDb.MYI /data/hg19 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg19/trackDb.frm /data/hg19 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg19/gold.MYD /data/hg19 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg19/gold.MYI /data/hg19 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg19/gold.frm /data/hg19 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg19/gap.MYD /data/hg19 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg19/gap.MYI /data/hg19 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg19/gap.frm /data/hg19 && \
    chown -R mysql.mysql /data/hg19

EXPOSE 3306

CMD ["mysqld", "-u", "root"]
