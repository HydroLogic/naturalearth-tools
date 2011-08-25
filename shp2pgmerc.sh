#!/bin/sh

OGR2OGR=`which ogr2ogr`
SHP2PGSQL=`which shp2pgsql`
PSQL=`which psql`

ROOT=$1
MERC="${ROOT}/900913"
GOOG="+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0.0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs +over"

mkdir -p ${MERC}
rm -f ${MERC}/*

for SHP in `ls -a ${ROOT}/*.shp`
do
    DIR=`dirname ${SHP}`
    BASE=`basename ${SHP}`

    TABLE=`perl -e '$ARGV[0] =~ /^((?:\d+)m)_(.*)\.shp$/; print "$2_$1";' ${BASE}`
    # TABLE=`echo ${BASE} | awk '{split($0, parts, "."); print parts[1]}'`

    echo "[${TABLE}] reproject"

    ${OGR2OGR} -f "ESRI Shapefile" -t_srs ${GOOG} ${MERC}/900913_${BASE} ${DIR}/${BASE}

    echo "[${TABLE}] prepare sql"

    ${SHP2PGSQL} -s 900913 -W WINDOWS-1252 -c -I ${MERC}/900913_${BASE} ${TABLE} > ${MERC}/900913_${TABLE}.sql

    echo "[${TABLE}] import sql"

    ${PSQL} -U naturalearth < ${MERC}/900913_${TABLE}.sql

done