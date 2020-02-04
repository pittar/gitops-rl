#!/bin/bash

LANG=C

echo ""
echo "*****************************************************"
echo "**                                                 **"
echo "**  Demo Setup:                                    **"
echo "**    - Install ArgoCD Operator.                   **"
echo "**                                                 **"
echo "*****************************************************"

echo "Create the Argo CD project."
oc adm new-project argocd

echo "Configure RBAC for Argo CD"
oc create -f install/argocd/deploy/service_account.yaml -n argocd
oc create -f install/argocd/deploy/role.yaml -n argocd
oc create -f install/argocd/deploy/role_binding.yaml -n argocd

echo "Add the Argo CRDs."
oc create -f install/argocd/deploy/argo-cd -n argocd

echo "Add the Argo CD Operator."
oc create -f install/argocd/deploy/crds/argoproj_v1alpha1_argocd_crd.yaml -n argocd
sleep 5

echo "There should be three CRDs."
oc get crd | grep argo

echo "Deploy the Operator."
oc create -f install/argocd/deploy/operator.yaml -n argocd

echo "Waiting for Argo CD operator to start."
sleep 15

while oc get deployment/argocd-operator -n argocd | grep "0/1" >> /dev/null;
do
    echo "Waiting..."
    sleep 3
done
echo "Argo CD Operator ready!"

echo "Create an instance of Argo CD."
oc create -f install/argocd/examples/argocd-minimal.yaml -n argocd

echo "Waiting for Argo CD to start."
sleep 5

until oc get deployment/argocd-server -n argocd | grep "1/1" >> /dev/null;
do
    echo "Waiting..."
    sleep 3
done
echo "Argo CD ready!"

echo ""
echo "Printing default admin password:"
oc -n argocd get pod -l "app.kubernetes.io/name=argocd-server" -o jsonpath='{.items[*].metadata.name}'
echo ""
echo ""
