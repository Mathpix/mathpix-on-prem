# Setup the rabbitmq cluster

```bash
# Install the rabbitmq cluster operator
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install rabbitmq-cluster-operator bitnami/rabbitmq-cluster-operator -f values.yaml

# Create a rabbitmq cluster
kubectl apply -f storage-class.yaml
kubectl apply -f pod-disruption-budget.yaml
kubectl apply -f cluster.yaml
```