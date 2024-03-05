#!/bin/bash

# Define your namespace
NAMESPACE="glass"

# Define the name for the summary file
SUMMARY_FILE="../all-components-v2.yaml"

# Remove the summary file if it already exists
[ -f "$SUMMARY_FILE" ] && rm "$SUMMARY_FILE"

# Iterate through each deployment in the namespace
# for deployment in $(kubectl get deployments -n $NAMESPACE -o=jsonpath='{.items[*].metadata.name}'); do
for deployment in $(kubectl get deployments -n $NAMESPACE -o=jsonpath='{range .items[?(@.metadata.labels.framework=="sole")]}{.metadata.name}{"\n"}{end}'); do
    label_app_kubernetes=$(kubectl get deployment $deployment -n $NAMESPACE -o=jsonpath='{.metadata.labels.app\.kubernetes\.io\/name}')

    # Update YAML content
    cat >> "$SUMMARY_FILE" <<EOF
---
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: $deployment
  namespace: $NAMESPACE
  annotations:
    # backstage.io/kubernetes-label-selector: app.kubernetes.io/name=$label_app_kubernetes,framework=sole
    backstage.io/kubernetes-label-selector: app.kubernetes.io/instance=$deployment,framework=sole
  tags:
    - sole
    - $label_app_kubernetes
spec:
  type: service
  lifecycle: experimental
  owner: exp-core
EOF
done

echo "Summary file '$SUMMARY_FILE' created successfully."


# echo "apiVersion: backstage.io/v1alpha1"
# echo "kind: Component"
# echo "metadata:"
# echo "  name: $label_app_kubernetes"
# echo "  annotations:"
# echo "    backstage.io/kubernetes-label-selector: app.kubernetes.io/name=$label_app_kubernetes,framework=sole"
# echo "spec:"
# echo "  type: service"
# echo "  lifecycle: experimental"
# echo "  owner: exp-core"
