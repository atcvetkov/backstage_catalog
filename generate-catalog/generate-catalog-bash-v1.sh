#!/bin/bash

# Define your namespace
NAMESPACE="glass"

# Define the name for the summary file
SUMMARY_FILE="../all-components.yaml"

# Remove the summary file if it already exists
[ -f "$SUMMARY_FILE" ] && rm "$SUMMARY_FILE"

# Cleanup catalog-entries directory
rm -r ../catalog-entries/*.yaml

# Create a list to hold the targets
targets=()

# Iterate through each deployment in the namespace
# for deployment in $(kubectl get deployments -n $NAMESPACE -o=jsonpath='{.items[*].metadata.name}'); do
for deployment in $(kubectl get deployments -n $NAMESPACE -o=jsonpath='{range .items[?(@.metadata.labels.framework=="sole")]}{.metadata.name}{"\n"}{end}'); do
    label_app_kubernetes=$(kubectl get deployment $deployment -n $NAMESPACE -o=jsonpath='{.metadata.labels.app\.kubernetes\.io\/name}')

    # Create YAML content
    cat > "../catalog-entries/$deployment.yaml" <<EOF
---
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: $deployment
  description: Sole Application
  namespace: $NAMESPACE
  annotations:
    # backstage.io/kubernetes-label-selector: app.kubernetes.io/name=$label_app_kubernetes,framework=sole
    backstage.io/kubernetes-label-selector: app.kubernetes.io/instance=$deployment,framework=sole
  links:
    - url: https://example.com/user
      title: Examples Users
      icon: user
    - url: https://example.com/group
      title: Example Group
      icon: group
    - url: https://example.com/cloud
      title: Link with Cloud Icon
      icon: cloud
    - url: https://example.com/dashboard
      title: Dashboard
      icon: dashboard
    - url: https://example.com/help
      title: Support
      icon: help
    - url: https://example.com/web
      title: Website
      icon: web
    - url: https://example.com/alert
      title: Alerts
      icon: alert
  tags:
    - sole
    - deu02
    - development
  labels:
    framework: sole
    odp_cluster: deu02
    odp_envirnment: development
spec:
  type: service
  lifecycle: experimental
  owner: exp-core
  system: sole-mf
EOF

    # Add the deployment.yaml file to the list of targets
    targets+=("./catalog-entries/$deployment.yaml")
done

# Create YAML content for the summary file
cat > "$SUMMARY_FILE" <<EOF
apiVersion: backstage.io/v1alpha1
kind: Location
metadata:
  name: all-sole-components
  description: A collection of all Sole Backstage example components
spec:
  targets:
EOF

# Add the list of targets to the summary file
for target in "${targets[@]}"; do
    echo "    - $target" >> "$SUMMARY_FILE"
done

echo "Summary file '$SUMMARY_FILE' created successfully."
