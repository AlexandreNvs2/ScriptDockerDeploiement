FROM debian:9

# Configuration de base
ENV container=docker
ENV LC_ALL=C
ENV DEBIAN_FRONTEND=noninteractive
ENV init=/lib/systemd/systemd

# 🔧 Corriger les sources vers l'archive Debian (stretch est obsolète)
RUN sed -i '/stretch-updates/d' /etc/apt/sources.list && \
    sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' /etc/apt/sources.list && \
    sed -i 's|http://security.debian.org/debian-security|http://archive.debian.org/debian-security|g' /etc/apt/sources.list && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until

# 📦 Installation des paquets nécessaires
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        systemd python sudo bash iproute net-tools \
        openssh-server openssh-client vim && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 🔐 Activer login root SSH
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin/PermitRootLogin/' /etc/ssh/sshd_config

# 🧹 Nettoyage systemd
RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
           /etc/systemd/system/*.wants/* \
           /lib/systemd/system/local-fs.target.wants/* \
           /lib/systemd/system/sockets.target.wants/*udev* \
           /lib/systemd/system/sockets.target.wants/*initctl* \
           /lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup* \
           /lib/systemd/system/systemd-update-utmp*

# 🔗 Lien pour init
RUN ln -sf /lib/systemd/systemd /sbin/init

# (facultatif) Définir un mot de passe root connu
RUN sed -i 's#root:\*#root:sa3tHJ3/KuYvI#' /etc/shadow

# 📁 Volume requis pour cgroups avec systemd
VOLUME ["/sys/fs/cgroup"]

# 🚀 Lancer systemd au démarrage du conteneur
ENTRYPOINT ["/lib/systemd/systemd"]

