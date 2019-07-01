FROM flectrahq/flectra:1.6

#Migrate from suds to python-zeep

USER root

ENV HOME=/var/lib/flectra

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

RUN pip3 install --no-cache-dir ptvsd phonenumbers oauthlib redis psycogreen vobject python-ldap qrcode zeep xlrd xlsxwriter \
        &&  rm -rf ~/.cache/pip && rm -rf /tmp/*

#openshift compat
RUN  mkdir -p /opt/addons && chgrp -R 0 /mnt/extra-addons /var/lib/flectra /opt/addons  && chmod -R 775 /var/lib/flectra /mnt /opt/addons \
        && usermod -g root flectra && chmod g+w /etc/passwd && sed -i 's/flectra.cli.main/import os;os.umask(0);flectra.cli.main/' /usr/bin/flectra


COPY ./entrypoint.sh /
COPY ./install.sh /



#extra libraries
ADD "https://gitlab.com/flectra-hq/developer-tools/raw/master/flectra_rename_script/odoo_flectra.py" /usr/local/bin/odoo_flectra.py

RUN chmod 755 /usr/local/bin/odoo_flectra.py && ln -s /usr/bin/pip3 /usr/local/bin/pip

RUN /install.sh "https://github.com/OCA/maintainer-quality-tools/archive/master.zip" /opt/maintainer-quality-tools

ENV VERSION='11.0' ODOO_VERSION='11.0'

# Set default user when running the container
USER 101
