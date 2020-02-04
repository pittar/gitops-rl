#!/bin/bash

LANG=C

echo ""
echo "*****************************************************"
echo "**                                                 **"
echo "**  Demo Setup:                                    **"
echo "**    - Install Bitnami Sealed Secrets Operator.   **"
echo "**    - Copy Sealed Secrets public key.            **"
echo "**                                                 **"
echo "*****************************************************"


echo "Create config project for cluster configuration."
oc create -f gitops/projects/config-project.yaml
echo "Creating security app for security context constraints."
oc create -f gitops/applications/dc1/cluster-config/security-application.yaml
echo "Create sealed secrets application."
oc create -f gitops/applications/dc1/cluster-config/sealedsecrets-application.yaml

echo "Waiting for Bitnami Sealed Secrets controller to start."
sleep 5

until oc get deployment/sealed-secrets-controller -n openshift-secrets | grep "1/1" >> /dev/null;
do
    echo "Waiting..."
    sleep 3
done
echo "Sealed Secrets ready!"
echo ""

echo "Create dir for Sealed Secrets public key. (~/bitnami)."
mkdir -p ~/bitnami

echo "Get the public key from the Sealed Secrets secret."
if [[ "$OSTYPE" == "darwin"* ]]; then
    oc get secret -o yaml -n openshift-secrets -l sealedsecrets.bitnami.com/sealed-secrets-key | grep tls.crt | cut -d' ' -f6 | base64 -D > ~/bitnami/publickey.pem
else
    oc get secret -o yaml -n openshift-secrets -l sealedsecrets.bitnami.com/sealed-secrets-key | grep tls.crt | cut -d' ' -f6 | base64 -d > ~/bitnami/publickey.pem
fi

echo "Done!"
