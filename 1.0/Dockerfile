#Partially from Odoo's dockerfile
#github.com/odoo/docker

FROM debian:stretch
MAINTAINER FlectraHQ <flectra@flectrahq.com>

# Generate locale C.UTF-8 for postgres and general locale data
ENV LANG C.UTF-8
ENV FLECTRA_VERSION=1.0
ENV FLECTRA_RELEASE=latest

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN set -x; \
        apt-get update \
        && apt-get install -y --no-install-recommends \
            ca-certificates \
            curl \
            node-less \
            python3-pip \
            python3-setuptools \
            python3-renderpm \
            libssl1.0-dev \
            xz-utils \
        && curl -o wkhtmltox.tar.xz -SL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz \
        && echo '3f923f425d345940089e44c1466f6408b9619562 wkhtmltox.tar.xz' | sha1sum -c - \
        && tar xvf wkhtmltox.tar.xz \
        && cp wkhtmltox/lib/* /usr/local/lib/ \
        && cp wkhtmltox/bin/* /usr/local/bin/ \
        && cp -r wkhtmltox/share/man/man1 /usr/local/share/man/

# Install Flectra
RUN set -x; \
        curl -o flectra_${FLECTRA_VERSION}.${FLECTRA_RELEASE}_all.deb -SL https://download.flectrahq.com/1.0/pub/deb/flectra_${FLECTRA_VERSION}.${FLECTRA_RELEASE}_all.deb \
		&& curl -o flectra_${FLECTRA_VERSION}.${FLECTRA_RELEASE}_amd64.changes -SL https://download.flectrahq.com/1.0/pub/deb/flectra_${FLECTRA_VERSION}.${FLECTRA_RELEASE}_amd64.changes \
		&& echo "`sed -n '/^Checksums-Sha1:$/{n;p;n;p;n;p}' flectra_${FLECTRA_VERSION}.${FLECTRA_RELEASE}_amd64.changes | tail -1 | awk '{print $1}'` flectra_${FLECTRA_VERSION}.${FLECTRA_RELEASE}_all.deb" | sha1sum -c \
        && dpkg --force-depends -i flectra_${FLECTRA_VERSION}.${FLECTRA_RELEASE}_all.deb \
        && apt-get update \
        && apt-get -y install -f --no-install-recommends \
        && rm -rf /var/lib/apt/lists/* flectra_${FLECTRA_VERSION}.${FLECTRA_RELEASE}_all.deb

# Copy entrypoint script and Flectra configuration file
RUN pip3 install num2words
COPY ./entrypoint.sh /
COPY ./flectra.conf /etc/flectra/
RUN chown flectra /etc/flectra/flectra.conf

# Mount /var/lib/flectra to allow restoring filestore and /mnt/extra-addons for users addons
RUN mkdir -p /mnt/extra-addons \
        && chown -R flectra /mnt/extra-addons
VOLUME ["/var/lib/flectra", "/mnt/extra-addons"]

# Expose Flectra services
EXPOSE 7073 7072

# Set the default config file
ENV FLECTRA_RC /etc/flectra/flectra.conf

# Set default user when running the container
USER flectra

ENTRYPOINT ["/entrypoint.sh"]
CMD ["flectra"]
