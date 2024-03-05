#!/bin/bash

# Define your namespace
NAMESPACE="glass"

# Define the name for the summary file
SUMMARY_FILE="../all-components.yaml"

# Remove the summary file if it already exists
[ -f "$SUMMARY_FILE" ] && rm "$SUMMARY_FILE"

# Create a list to hold the targets
targets=()

# Iterate through each deployment in the namespace
for deployment in $(kubectl get deployments -n $NAMESPACE -o=jsonpath='{.items[*].metadata.name}'); do
    label_app_kubernetes=$(kubectl get deployment $deployment -n $NAMESPACE -o=jsonpath='{.metadata.labels.app\.kubernetes\.io\/name}')

    # Create YAML content
    cat > "../catalog-entries/$deployment.yaml" <<EOF
---
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: $label_app_kubernetes
  annotations:
    backstage.io/kubernetes-label-selector: app.kubernetes.io/name=$label_app_kubernetes,framework=sole
spec:
  type: service
  lifecycle: experimental
  owner: exp-core
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
