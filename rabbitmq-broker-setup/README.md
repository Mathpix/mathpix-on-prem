# Setup the rabbitmq cluster

```bash
# Install the rabbitmq cluster operator
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install rabbitmq-cluster-operator bitnami/rabbitmq-cluster-operator

# Create a rabbitmq cluster
kubectl apply -f .
```