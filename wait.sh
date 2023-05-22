#!/bin/bash

if [ "$NAMESPACE" = "" ]
then
  echo "please define NAMESPACE"
  exit 1
fi
if [ "$EXTERNALSECRET" = "" ]
then
  echo "please define EXTERNALSECRET"
  exit 1
fi
if [ "$WAIT_TIMEOUT" = "" ]; then
  WAIT_TIMEOUT=60
fi
if [ "$WAIT_INTERVAL" = "" ]; then
  WAIT_INTERVAL=5
fi

echo "Checking kubernetes version..."
kubectl version

# Check if the ExternalSecret resource exists
if kubectl get externalsecret.external-secrets.io $EXTERNALSECRET -n $NAMESPACE &> /dev/null; then
    # Check the ExternalSecret resource status
    status=$(kubectl get externalsecret.external-secrets.io $EXTERNALSECRET -n $NAMESPACE -o=jsonpath='{.status.conditions[?(@.type=="Ready")].status}')
    reason=$(kubectl get externalsecret.external-secrets.io $EXTERNALSECRET -n $NAMESPACE -o=jsonpath='{.status.conditions[?(@.type=="Ready")].reason}')

    # Set start time
    start_time=$(date +%s)

    while [ "$status" != "True" ]; do
        # Check if WAIT_TIMEOUT has been exceeded
        current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))

        if [ $elapsed_time -gt $WAIT_TIMEOUT ]; then
            echo "WAIT_TIMEOUT of $WAIT_TIMEOUT seconds exceeded waiting for ExternalSecret resource $EXTERNALSECRET to be ready in namespace $NAMESPACE."
            exit 2
        fi

        if [ "$reason" == "SecretSyncedError" ]; then
            echo "SecretSyncedError for ExternalSecret resource $EXTERNALSECRET in namespace $NAMESPACE."
            exit 3
        fi

        echo "Waiting for ExternalSecret resource $EXTERNALSECRET to be ready in namespace $NAMESPACE..."
        sleep $WAIT_INTERVAL
        status=$(kubectl get externalsecret.external-secrets.io $EXTERNALSECRET -n $NAMESPACE -o=jsonpath='{.status.conditions[?(@.type=="Ready")].status}')
    done

    echo "ExternalSecret resource $EXTERNALSECRET is ready in namespace $NAMESPACE."
    exit 0
else
    echo "ExternalSecret resource $EXTERNALSECRET not found in namespace $NAMESPACE."
    exit 1
fi
