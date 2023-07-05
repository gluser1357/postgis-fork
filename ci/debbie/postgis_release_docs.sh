#!/usr/bin/env bash

set -e

export PG_VER=13
# export PGPORT=8442
export OS_BUILD=64
#this is passed in via postgis_make_dist.sh via jenkins
#export reference=
export PROJECTS=/var/lib/jenkins/workspace
export GEOS_VER=3.10
export GDAL_VER=3.4
export WEB_DIR=/var/www/postgis_stuff
export PGPATH=${PROJECTS}/pg/rel/pg${PG_VER}w${OS_BUILD}
export PATH="${PGPATH}/bin:$PATH"
export LD_LIBRARY_PATH="${PROJECTS}/gdal/rel-${GDAL_VER}w${OS_BUILD}/lib:${PROJECTS}/geos/rel-${GEOS_VER}w${OS_BUILD}/lib:${PGPATH}/lib"

./autogen.sh



POSTGIS_MAJOR_VERSION=`grep ^POSTGIS_MAJOR_VERSION Version.config | cut -d= -f2`
POSTGIS_MINOR_VERSION=`grep ^POSTGIS_MINOR_VERSION Version.config | cut -d= -f2`
POSTGIS_MICRO_VERSION=`grep ^POSTGIS_MICRO_VERSION Version.config | cut -d= -f2`

# TODO: take base as env variable ?
HTML_DIR=/var/www/postgis_docs/manual-${POSTGIS_MAJOR_VERSION}.${POSTGIS_MINOR_VERSION}

echo $PATH

#sh autogen.sh

if [ -f GNUMakefile ]; then
  make distclean
fi

#  --with-gdalconfig=${PROJECTS}/gdal/rel-${GDAL_VER}w${OS_BUILD}/bin/gdal-config
#  --without-raster

CPPFLAGS="-I${PGPATH}/include"  \
LDFLAGS="-L${PGPATH}/lib"  ./configure \
  --with-pgconfig=${PGPATH}/bin/pg_config \
  --with-geosconfig=${PROJECTS}/geos/rel-${GEOS_VER}w${OS_BUILD}/bin/geos-config \
  --without-raster --without-protobuf \
  --htmldir ${HTML_DIR}
make clean

# generating postgis_revision.h in case hasn't been generated
if test -f utils/repo_revision.pl; then
	echo "Generating postgis_revision.h"
	perl utils/repo_revision.pl
fi
export VREV="`cat postgis_revision.h | awk '{print $3}'`"
echo "VREV is ${VREV}"
cd doc


#sed -e "s:</title>:</title><subtitle><subscript>SVN Revision (<emphasis>${POSTGIS_SVN_REVISION}</emphasis>)</subscript></subtitle>:" postgis.xml.orig > postgis.xml

echo "Micro: $POSTGIS_MICRO_VERSION"
#inject a development time stamp if we are in development branch
# TODO: provide support for an env variable to do this ?
if [[ "$POSTGIS_MICRO_VERSION" == *"dev"* ]]; then
  cp postgis.xml postgis.xml.orig #we for dev will inject stuff into file, so backup original
  export GIT_TIMESTAMP=`git log -1 --pretty=format:%ct`
  export GIT_TIMESTAMP="`date -d @$GIT_TIMESTAMP`" #convert to UTC date
  echo "GIT_TIMESTAMP: ${GIT_TIMESTAMP}"
  export part_old="</title>"
  export part_new="</title><subtitle><subscript>DEV (<emphasis>$GIT_TIMESTAMP rev. $VREV </emphasis>)</subscript></subtitle>"
  sed -i 's,'"$part_old"','"$part_new"',' postgis.xml
fi

make cheatsheets
make pdf
make epub
make -e chunked-html-web # TODO: do we really want this too in the doc-html-*.tar.gz package ?
make html-localized # TODO: do we really want this too in the doc-html-*.tar.gz package ?

package="doc-html-${POSTGIS_MAJOR_VERSION}.${POSTGIS_MINOR_VERSION}.${POSTGIS_MICRO_VERSION}.tar.gz"
tar -czf "$package" --exclude='static' --exclude='wkt' --exclude '*.o' html

# Install all html
make html-assets-install
make html-install
make chunked-html-web-install
make html-install-localized
make chunked-html-web-install-localized
chmod -R 755 ${HTML_DIR} # TODO: still needed ?



# TODO: Replace all of this by `make *-install`
cp -R *.pdf /var/www/postgis_stuff/
cp -R *.epub /var/www/postgis_stuff/

cp -R $package /var/www/postgis_stuff/


if [[ "$POSTGIS_MICRO_VERSION" == *"dev"* ]]; then

  #rename the files without the micro if it's a development branch
  for f in ${WEB_DIR}/*${POSTGIS_MICRO_VERSION}; do
    newname=$(echo "$f" | sed "s/${POSTGIS_MICRO_VERSION}//");
    mv -vi $f $newname
  done

  # restore the backedup xml file
  cp postgis.xml.orig postgis.xml

fi
