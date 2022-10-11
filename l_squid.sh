#!/usr/bin/env bash

root="${1}"
config=${root}/config

sudo docker run --rm -ti \
	--name l_squid \
	-v ${config}/squid.conf:/etc/squid/squid.conf \
	-v ${root}/log/:/var/log/squid/ \
	-p 127.0.0.1:27000:27000 \
	-p 127.0.0.1:27001:27001 \
	ubuntu/squid:latest
#	datadog/squid
