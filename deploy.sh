#!/bin/bash

export KUBE_NAMESPACE=${KUBE_NAMESPACE}
export KUBE_SERVER=${KUBE_SERVER}

log()
{
    if [[ $1 == ---* ]] ; then
        echo -e "\033[34m $1 \033[39m"
    elif [[ $1 == \[error\]* ]] ; then
        echo -e "\033[31m $1 \033[39m"
    else
        echo $1
    fi
}

if [[ -z ${VERSION} ]] ; then
    export VERSION=${IMAGE_VERSION}
fi

if [[ ${ENVIRONMENT} == "pr" ]] ; then
    log "--- PRODUCTION PRODUCTION PRODUCTION"
    log "--- deploying ${VERSION} to pr namespace, using PTTG_RPS_PR drone secret"
    export KUBE_TOKEN=${PTTG_RPS_PR}
else
    if [[ ${ENVIRONMENT} == "test" ]] ; then
        log "--- deploying ${VERSION} to test namespace, using PTTG_RPS_TEST drone secret"
        export KUBE_TOKEN=${PTTG_RPS_TEST}
    else
        log "--- deploying ${VERSION} to dev namespace, using PTTG_RPS_DEV drone secret"
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
    export PROD_OR_NOTPROD=prod
else
    export DNS_PREFIX=${ENVIRONMENT}.notprod.
    export KC_REALM=pttg-qa
    export PROD_OR_NOTPROD=notprod
fi

export DOMAIN_NAME=enquiry-rps.${DNS_PREFIX}pttg.homeoffice.gov.uk

log "--- DOMAIN_NAME is $DOMAIN_NAME"

cd kd

kd --insecure-skip-tls-verify \
    -f networkPolicy.yaml \
    -f ingress.yaml \
    -f deployment.yaml \
    -f service.yaml
