FROM quay.io/centos/centos:stream9

ARG cp_ref=main

# make sure the system is up-to-date
RUN dnf --setopt install_weak_deps=False -y update && dnf clean all

# install the basic stuff to run the ansible playbook;
# the python3.11 bits are needed because ansible-core requires
# python3.11
RUN dnf --setopt install_weak_deps=False -y install \
  systemd ansible-core sudo acl \
  python3.11-psycopg2 \
  && dnf clean all

# create a separate user
RUN useradd candlepin
COPY sudoers.d/candlepin /etc/sudoers.d

USER candlepin
WORKDIR /home/candlepin
RUN mkdir -p ansible/roles/candlepin
COPY playbook.yml requirements.yml ansible
COPY roles/candlepin ansible/roles/candlepin
RUN printf -- "---\ncp_git_ref: $cp_ref\n" > ansible/vars.yml
RUN ansible-galaxy collection install -r ansible/requirements.yml

USER root
CMD ["/sbin/init"]
EXPOSE 8080 8443
