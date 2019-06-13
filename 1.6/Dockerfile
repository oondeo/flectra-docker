FROM flectrahq/flectra:1.6

#Migrate from suds to python-zeep

USER root
# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN set -x; echo deb http://ftp.debian.org/debian stretch-backports main > /etc/apt/sources.list.d/backports.list \
        && apt-get update -qq \
        && DEBIAN_FRONTEND=noninteractive apt-get install -yqq --no-install-recommends \
            python3-paramiko \
            python3-crypto \
            python3-wheel \
            python3-pil \
            python3-lasso \
            python3-lxml \
            python3-num2words \
            python3-cffi \
            python3-tz \
            python3-unidecode \
            python3-requests \
            python3-numpy \
            python3-pandas \
            python3-dev \
            python3-gevent \
            build-essential \
            libxmlsec1-dev \
            xz-utils \
    	    rsync \
            unzip \
            git \
            uwsgi uwsgi-emperor uwsgi-plugin-python3 \
        && rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh /
COPY ./install.sh /

#openshift compat
RUN usermod -g root flectra && chgrp -R 0 /mnt/extra-addons /var/lib/flectra && chmod -R 775 /var/lib/flectra /mnt && chmod g+w /etc/passwd  

#extra libraries
ADD https://gitlab.com/flectra-hq/developer-tools/raw/master/flectra_rename_script/odoo_flectra.py /usr/local/bin/odoo_flectra.py

RUN chmod 755 /usr/local/bin/odoo_flectra.py && ln -s /usr/bin/pip3 /usr/local/bin/pip \
        && cd /tmp && curl -Lo /tmp/master.zip "https://github.com/OCA/maintainer-quality-tools/archive/master.zip" && unzip /tmp/master.zip \
        && mv maintainer-quality-tools-master /opt/maintainer-quality-tools \
        && pip3 install --no-cache-dir ptvsd phonenumbers oauthlib && pip3 install --no-cache-dir -r /opt/maintainer-quality-tools/requirements.txt \
        && rm -rf ~/.cache/pip && rm -rf /tmp/*
ENV VERSION='11.0' ODOO_VERSION='11.0'

# Set default user when running the container
USER 101
