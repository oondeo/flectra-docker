FROM flectrahq/flectra

#Migrate from suds to python-zeep

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN set -x; \
        apt-get update -qq \
        && DEBIAN_FRONTEND=noninteractive apt-get install -yqq --no-install-recommends \
            python3-paramiko \
            python3-crypto \
            python3-wheel \
            python3-pil \
            python3-lasso \
            python3-watchdog \
            python3-num2words \
            libxmlsec1-dev \
            xz-utils \
    	    rsync \
        && rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh /

#openshift compat
RUN chgrp -R 0 /mnt/extra-addons /var/lib/flectra && chmod -R 775 /var/lib/flectra /mnt && chmod g+w /etc/passwd  

# Set default user when running the container
USER 101