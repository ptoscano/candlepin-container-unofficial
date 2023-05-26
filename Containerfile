FROM quay.io/centos/centos:stream8

# first make sure the system is up-to-date;
# enable the needed modules for jss and newer postgresql;
# install what is needed to deploy and run candlepin,
# and the basic stuff to run the ansible playbook
RUN dnf --setopt install_weak_deps=False -y update \
  && dnf module enable -y pki-core pki-deps postgresql:12 \
  && dnf --setopt install_weak_deps=False -y install \
    systemd initscripts glibc-langpack-en openssh-server passwd sudo acl \
    git-core ncurses python3 python3-psycopg2 \
    createrepo_c expect gettext hostname java-11-openjdk-devel jss openssl pki-servlet-engine python3-libxml2 python3-requests rpm-build rpm-sign unzip wget \
    postgresql-server postgresql postgresql-jdbc \
  && dnf clean all

# set the unversioned 'python' command, used in scripts
RUN alternatives --set python /usr/bin/python3

# set the wanted java
RUN alternatives --set java /usr/lib/jvm/java-11-openjdk-*/bin/java \
  && alternatives --set javac /usr/lib/jvm/java-11-openjdk-*/bin/javac

# create a separate user
RUN useradd candlepin && echo "candlepin" | passwd candlepin --stdin
COPY sudoers.d/candlepin /etc/sudoers.d

USER candlepin
WORKDIR /home/candlepin
RUN mkdir -p devel/candlepin
COPY candlepin.git devel/candlepin

USER root
CMD ["/sbin/init"]
EXPOSE 22 8080 8443
