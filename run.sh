#!/bin/bash

if [[ -z "${SECRET_KEY}" ]]
then
  echo "no SECRET_KEY define, generate it"
  SECRET_KEY=$(openssl rand -hex 16)
fi

sed -i -e "s|base_url : False|base_url : ${BASE_URL}|g" \
       -e "s/image_proxy : False/image_proxy : ${IMAGE_PROXY}/g" \
       -e "s/ultrasecretkey/${SECRET_KEY}/!g" \
       /usr/local/searx/searx/settings.yml

uwsgi --ini /usr/local/searx/searx.ini
