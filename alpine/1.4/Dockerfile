FROM oondeo/python:3.7

ARG NODE_VERSION='8.12' 

ENV SUMMARY="flectra base image"	\
    DESCRIPTION="Flectra base image. The image use scripts and configurations compatible \
        with redhat openshift."

LABEL summary="$SUMMARY" \
      description="$DESCRIPTION" \
      io.k8s.description="$DESCRIPTION" \
      io.k8s.display-name="flectra" \
      io.openshift.s2i.scripts-url=image:///usr/libexec/s2i \
      io.s2i.scripts-url=image:///usr/libexec/s2i \
      com.redhat.component="core" \
      name="oondeo/flectra" \
      version=$ALPINE_VERSION \
      release="1" \
      maintainer="OONDEO <info@oondeo.es>"

USER root

# FROM python:$PYTHON_VERSION-alpine$ALPINE_VERSION as python
# RUN apk add --no-cache --virtual .build-deps  $BUILD_DEPS
ENV ODOO_VERSION="11.0" \
    FLECTRA_VERSION="1.4" \
    FLECTRA_REV="0"

ENV  ODOO_HOME=$HOME \
     ODOO_ADDONS_HOME="/mnt/extra-addons" \
     ODOO_SERVER="flectra" \
     ODOO_MODULE_FILE="__init__.pyc" \
     UNACCENT=True \
     OCA_URL="https://github.com/OCA" \
     FLECTRA_URL="https://gitlab.com/flectra-hq/flectra/-/archive/v$FLECTRA_VERSION.$FLECTRA_REV/flectra-v$FLECTRA_VERSION.$FLECTRA_REV.tar.bz2" \
     VERSION=$ODOO_VERSION 

# COPY --from=node:$NODE_VERSION-alpine /usr/local /usr/
# COPY --from=python:$PYTHON_VERSION-alpine$ALPINE_VERSION /usr/local /usr/
RUN apk-install -t wkhtmltopdf qt5-qtbase qt5-qtbase-x11 qt5-qtsvg qt5-qtwebkit \
    && apk-install wkhtmltopdf@testing

# ARG RUN_DEPS='curl'
# RUN apk-install -t .run-deps $RUN_DEPS

RUN curl -Lo  /tmp/GeoLiteCity.dat.gz http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz && gunzip /tmp/GeoLiteCity.dat.gz && mkdir -p /usr/share/GeoIP/ && mv /tmp/GeoLiteCity.dat /usr/share/GeoIP/ \
    && rm -rf /tmp/*


ARG BUILD_DEPS=' \
        bzip2-dev \
		coreutils \
		dpkg-dev dpkg \
		expat-dev \
		findutils \
		gcc \
		gdbm-dev \
		libc-dev \
		libffi-dev \
		libnsl-dev \
		libressl-dev \
		libtirpc-dev \
		linux-headers \
		make \
		ncurses-dev \
		pax-utils \
		readline-dev \
		sqlite-dev \
		tcl-dev \
		tk \
		tk-dev \
		util-linux-dev \
		xz-dev \
        zlib-dev \
        git \
        unzip \
        xmlsec-dev \
        libxslt-dev \
        jpeg-dev \
        cyrus-sasl-dev \
        openldap-dev \
        fontconfig-dev \
        libxml2-dev \
        postgresql-dev \
        sassc \
        nodejs npm \
    ' 
ARG ODOO_MODULES=""
ARG PYTHON_MODULES=" \
Babel \
decorator \
docutils \
ebaysdk \
feedparser \
gevent \
gevent \
greenlet \
greenlet \
html2text \
Jinja2 \
lxml \
Mako \
MarkupSafe \
mock \
num2words \
numpy \
oauthlib \
ofxparse \
passlib \
phonenumbers \
Pillow \
psutil \
psycopg2 \
pydot \
pyldap \
pyparsing \
PyPDF2 \
pyserial \
python-dateutil \
pytz \
pyusb \
PyYAML \
qrcode \
reportlab \
requests \
suds-jurko \
unittest2 \
vatnumber \
vobject \
Werkzeug \
xlrd \
XlsxWriter \
xlwt  \
     "
ARG NODE_MODULES="less less-plugin-clean-css"

RUN apk-install -t .build-deps $BUILD_DEPS \
    && ln -s /usr/bin/sassc /usr/bin/sass \
    && npm install -g $NODE_MODULES \
    && pip install --no-cache-dir $PYTHON_MODULES \
    && curl -Lo /tmp/flectra.tbz2 $FLECTRA_URL \
    && mkdir -p /tmp/flectra && tar -jxf /tmp/flectra.tbz2 --strip 1 -C /tmp/flectra \
    && cd /tmp/flectra \
    && python setup.py install \
    && cp /tmp/flectra/flectra-bin /usr/local/bin/flectra && chmod +x /usr/local/bin/flectra \
    && install-deps /usr/local \
    && npm cache clean --force && rm -rf ~/.cache/pip && rm -rf /tmp/*


COPY ./entrypoint.sh /
COPY ./install.sh /

ENTRYPOINT [ "/sbin/tini", "-g" ,"--", "container-entrypoint", "/entrypoint.sh" ]

#extra libraries
ADD https://gitlab.com/flectra-hq/developer-tools/raw/master/flectra_rename_script/odoo_flectra.py /usr/local/bin/odoo_flectra

RUN sed -i 's/# !\/usr\/bin\/python/#!\/usr\/bin\/python3/g' /usr/local/bin/odoo_flectra.py && chmod 755 /usr/local/bin/odoo_flectra \
        && cd /tmp && curl -Lo /tmp/master.zip "https://github.com/OCA/maintainer-quality-tools/archive/master.zip" && unzip /tmp/master.zip \
        && mv maintainer-quality-tools-master /opt/maintainer-quality-tools \
        && pip3 install --no-cache-dir ptvsd && pip3 install --no-cache-dir -r /opt/maintainer-quality-tools/requirements.txt \
        && rm -rf ~/.cache/pip && rm -rf /tmp/*

RUN mkdir -p /mnt/extra-addons && chown 1001:0 /mnt/extra-addons && chmod 775 /mnt/extra-addons

VOLUME [ '/mnt/extra-addons' ]
USER 1001