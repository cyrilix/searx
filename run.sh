#!/bin/sh

SETTINGS_FILE="/usr/local/searx/searx/settings.yml"

if [ -z "${SECRET_KEY}" ]
then
  echo "no SECRET_KEY define, generate it"
  SECRET_KEY=$(openssl rand -hex 16)
fi

echo "Configure base_url parameter"
sed -i -e "s|base_url : False|base_url : ${BASE_URL}|g" ${SETTINGS_FILE}

echo "Configure image_proxy parameter"
sed -i -e "s/image_proxy : False/image_proxy : ${IMAGE_PROXY}/g" ${SETTINGS_FILE}

echo "Configure secret_key parameter"
sed -i -e "s/ultrasecretkey/${SECRET_KEY}/g" ${SETTINGS_FILE}

uwsgi --ini /usr/local/searx/searx.ini
