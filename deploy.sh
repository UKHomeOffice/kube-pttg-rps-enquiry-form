#!/bin/bash

export KUBE_NAMESPACE=${KUBE_NAMESPACE}
export KUBE_SERVER=${KUBE_SERVER}

if [[ -z ${VERSION} ]] ; then
    export VERSION=${IMAGE_VERSION}
fi

if [[ ${ENVIRONMENT} == "pr" ]] ; then
    echo "deploy ${VERSION} to pr namespace, using PTTG_RPS_PR drone secret"
    export KUBE_TOKEN=${PTTG_RPS_PR}
else
    if [[ ${ENVIRONMENT} == "test" ]] ; then
        echo "deploy ${VERSION} to test namespace, using PTTG_RPS_TEST drone secret"
        export KUBE_TOKEN=${PTTG_RPS_TEST}
    else
        echo "deploy ${VERSION} to dev namespace, using PTTG_RPS_DEV drone secret"
        export KUBE_TOKEN=${PTTG_RPS_DEV}
    fi
fi

if [[ -z ${KUBE_TOKEN} ]] ; then
    echo "Failed to find a value for KUBE_TOKEN - exiting"
    exit -1
fi

export WHITELIST=${WHITELIST:-0.0.0.0/0}

if [ "${ENVIRONMENT}" == "pr" ] ; then
    export DNS_PREFIX=
    export KC_REALM=pttg-production
else
    export DNS_PREFIX=${ENVIRONMENT}.notprod.
    export KC_REALM=pttg-qa
fi

export DOMAIN_NAME=rps-enqiry.${DNS_PREFIX}pttg.homeoffice.gov.uk

echo "DOMAIN_NAME is $DOMAIN_NAME"

cd kd

kd --insecure-skip-tls-verify \
    -f networkPolicy.yaml \
    -f ingress.yaml \
    -f deployment.yaml \
    -f service.yaml
