#!/bin/bash

export KUBE_NAMESPACE=${KUBE_NAMESPACE}
export KUBE_SERVER=${KUBE_SERVER}

if [[ -z ${VERSION} ]] ; then
    export VERSION=${IMAGE_VERSION}
fi


echo "deploy ${VERSION} to tools namespace, using PTTG_TOOLS drone secret"
export KUBE_TOKEN=${PTTG_TOOLS}


if [[ -z ${KUBE_TOKEN} ]] ; then
    echo "Failed to find a value for KUBE_TOKEN - exiting"
    exit -1
fi

export WHITELIST=${WHITELIST:-0.0.0.0/0}

export DNS_PREFIX=tools.notprod.
export KC_REALM=pttg-qa


export DOMAIN_NAME=rps-enquiry.${DNS_PREFIX}pttg.homeoffice.gov.uk

echo "DOMAIN_NAME is $DOMAIN_NAME"

cd kd

kd --insecure-skip-tls-verify \
    -f networkPolicy.yaml \
    -f ingress.yaml \
    -f deployment.yaml \
    -f service.yaml
