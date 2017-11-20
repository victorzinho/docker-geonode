FROM ubuntu:16.04

MAINTAINER Víctor González <victor.gonzalez@geomati.co>

ENV TOMCAT_VERSION 8.5.23
ENV GEONODE_REPO_BRANCH 2.6.x
ENV GEOSERVER_DATA_DIR /opt/gs_data_dir

# Install packages with apt
RUN apt-get update -y      \
  && apt-get install -y --no-install-recommends \
    apache2                \
    build-essential        \
    gdal-bin               \
    git-core               \
    libapache2-mod-wsgi    \
    libgeos-dev            \
    libjpeg-dev            \
    libpng12-dev           \
    libpq-dev              \
    libproj-dev            \
    libxml2-dev            \
    libxslt1-dev           \
    openjdk-8-jre-headless \
    patch                  \
    python                 \
    python-dev             \
    python-gdal            \
    python-pycurl          \
    python-imaging         \
    python-pastescript     \
    python-pip             \
    python-psycopg2        \
    python-urlgrabber      \
    wget                   \
  && rm -rf /var/lib/apt/lists/* \
  && pip install --upgrade pip \
  && wget http://www-eu.apache.org/dist/tomcat/tomcat-8/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz \
  && tar xzf apache-tomcat-${TOMCAT_VERSION}.tar.gz \
  && mv apache-tomcat-${TOMCAT_VERSION} /var/lib/tomcat8

# Add Apache2 site and sample geoserver data dir
ADD geonode.conf /etc/apache2/sites-available/geonode.conf
ADD geoserver ${GEOSERVER_DATA_DIR}

# Install GeoNode
RUN git clone https://github.com/GeoNode/geonode.git --branch ${GEONODE_REPO_BRANCH} /var/geonode
WORKDIR /var/geonode
RUN pip install -e . \
  && paver setup \
  && cp downloaded/geoserver-2.9.x-oauth2.war /var/lib/tomcat8/webapps/geoserver.war \
  && python manage.py collectstatic --noinput \
  && mkdir -p geonode/uploaded/thumbs \
  && mkdir -p geonode/uploaded/layers \
  && chmod -Rf 777 geonode/uploaded/thumbs \
  && chmod -Rf 777 geonode/uploaded/layers \
  && chown -R www-data: . \
  && python manage.py migrate \
  && a2enmod proxy_http \
  && a2dissite 000-default \
  && a2ensite geonode \
  && service apache2 restart

ADD docker-entrypoint.sh /var/docker-entrypoint.sh
ENTRYPOINT /var/docker-entrypoint.sh

