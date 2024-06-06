ARG BASEOS_DIGEST
FROM quay.io/centos/centos:stream8${BASEOS_DIGEST:-}

ENV container docker

RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-Stream-* \
  && sed -i 's|#baseurl=http://mirror.centos.org|baseurl=https://vault.centos.org|g' /etc/yum.repos.d/CentOS-Stream-*

RUN yum -y update \
  && yum -y install \
  epel-release \
  hostname \
  initscripts \
  python3 \
  sudo \
  which \
  && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
  && yum clean all

# selectively remove systemd targets -- See https://hub.docker.com/_/centos/
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
  systemd-tmpfiles-setup.service ] || rm -f $i; done); \
  rm -f /lib/systemd/system/multi-user.target.wants/*;\
  rm -f /etc/systemd/system/*.wants/*;\
  rm -f /lib/systemd/system/local-fs.target.wants/*; \
  rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
  rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
  rm -f /lib/systemd/system/basic.target.wants/*;\
  rm -f /lib/systemd/system/anaconda.target.wants/*;

STOPSIGNAL SIGRTMIN+3

VOLUME ["/sys/fs/cgroup"]
CMD ["/sbin/init"]
