# Setup the rabbitmq cluster

```bash
# Install the rabbitmq cluster operator
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install rabbitmq-cluster-operator bitnami/rabbitmq-cluster-operator -f values.yaml

# Wait for the rabbitmq cluster operator to be ready
kubectl wait --for=condition=available --timeout=300s deployment \
  -l app.kubernetes.io/name=rabbitmq-cluster-operator,app.kubernetes.io/instance=rabbitmq-cluster-operator \
  --namespace default

# Create a rabbitmq cluster
kubectl apply -f storage-class.yaml
kubectl apply -f pod-disruption-budget.yaml
kubectl apply -f cluster.yaml
```

Once that's finished you can get the connection string for the rabbitmq cluster using this:

```bash
kubectl get secret rabbitmq-cluster-default-user -n default -o jsonpath="{.data.connection_string}" | base64 --decode
```

**Note:**: The connection string should end with a `/`, some clusters may add the kubernetes user as the default vhost, which should be removed along with the `%` character denoting the end of the string.

## Remove the rabbitmq cluster:

```bash
kubectl delete -f storage-class.yaml
kubectl delete -f pod-disruption-budget.yaml
kubectl delete -f cluster.yaml
helm uninstall rabbitmq-cluster-operator
```
