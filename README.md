# Mathpix on-premise

- [Prerequisites](#prerequisites)
- [API](#api)
  - [Updating files](#updating-files)
    - [Adding your Mathpix on-prem license](#adding-your-mathpix-on-prem-license)
    - [Setting up initial credentials](#updating-the-credentials)
    - [Replacing the docker images (if not using AWS ECR)](#replacing-the-docker-images-if-not-using-aws-ecr)
  - [Deploying Mathpix on-prem](#deploying-mathpix-on-prem)
  - [How to](#how-to)
    - [Update mathpix on-prem license](#update-mathpix-on-prem-license)
    - [Update default credentials](#update-default-credentials)
    - [Scale the Mathpix API](#scale-the-mathpix-api)
- [SCS](#scs)
  - [Publisher](#publisher)
  - [Consumer](#consumer)
  - [GCP GKE Setup](#gcp-gke-setup)
  - [RabbitMQ Broker](#rabbitmq-broker)

## Prerequisites

| Requirement | GCP Kubernetes Engine | AWS EKS |
|-------------|-----------------------|---------|
| A Kubernetes cluster | [Create a cluster](https://cloud.google.com/kubernetes-engine/docs/how-to/creating-a-zonal-cluster) | [Create a cluster](https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html) |
| Installed `kubectl` version 1.30 or higher  | [Install kubectl](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl#generate_kubeconfig_entry) | [Install kubectl](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html) |
| Nodes with NVIDIA GPUs and drivers | [GPU Drivers](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/google-gke.html) | [GPU Drivers](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/amazon-eks.html) |

To confirm you have GPU nodes available after configuring kubectl to connect to your cluster, run:

```
kubectl describe nodes
```

And you should see the nodes with the `nvidia.com/gpu` resource: 

```
Allocated resources:
  Resource           Requests       Limits
  --------           --------       ------
  ...
  nvidia.com/gpu     1              1
```

## API

### Updating files

#### Adding your Mathpix on-prem license
First you'll need to copy `kubernetes-manifests/mathpix/mathpix.env.example` to `kubernetes-manifests/mathpix/mathpix.env` and add your `MATHPIX_ON_PREM_LICENSE` to it.

```
cp kubernetes-manifests/mathpix/mathpix.env.example kubernetes-manifests/mathpix/mathpix.env
# Now open kubernetes-manifests/mathpix/mathpix.env
# Replace REPLACE_WITH_YOUR_LICENSE with your license
# MATHPIX_ON_PREM_LICENSE=REPLACE_WITH_YOUR_LICENSE
```

#### Setting up initial credentials

You should update the credentials in the [kubernetes-manifests/jobs/update-credentials/credentials.json](kubernetes-manifests/jobs/update-credentials/credentials.json) file with the credentials you want to use to access the Mathpix on-prem OCR API. 

#### Replacing the docker images (if not using AWS ECR)

If you haven't had your AWS account granted access to download images from our AWS ECR then you should update the images to point to your registry where your cluster can access them. If you're using Google Cloud Platform or another kubernetes cluster without access you'll need to get our images (we'll help you with this) and then push them to your google container registry or google artifact registry and replace the image fields in these files:

- [kubernetes-manifests/mathpix/mathpix-deployment.yaml](kubernetes-manifests/mathpix/mathpix-deployment.yaml)
- [kubernetes-manifests/jobs/migrate-schema.yaml](kubernetes-manifests/jobs/migrate-schema.yaml)
- [kubernetes-manifests/jobs/update-credentials/update-credentials.yaml](kubernetes-manifests/jobs/update-credentials/update-credentials.yaml)

### Deploying Mathpix on-prem

To create the entire Mathpix on-prem deployment:

```
kubectl apply -k ./kubernetes-manifests
```

To remove the on-prem deployment, run:

```
kubectl delete -k ./kubernetes-manifests
```

The Mathpix API will take a few minutes to start up, you can check the status with:

```
kubectl get pods 
# or
kubectl wait --for=condition=ready pod -l app=mathpix-api --timeout=600s
```

To see the load balancer with the Mathpix service, run:

```
kubectl get svc mathpix-loadbalancer -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

To verify that the Mathpix service is running, run:

```
API_URL=$(kubectl get svc mathpix-loadbalancer -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
curl -s $API_URL/region-health
```

To send OCR requests with the default Mathpix on-prem credentials, run:

```
API_URL=$(kubectl get svc mathpix-loadbalancer -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# Image
curl -X POST $API_URL/v3/text \
     -H 'app_id: mathpix-test-app-1' -H 'app_key: replace-with-your-app-key-1' -H 'Content-Type: application/json' \
     --data '{"src": "https://mathpix-ocr-examples.s3.amazonaws.com/cases_hw.jpg", "math_inline_delimiters": ["$", "$"], "rm_spaces": true}'


# PDF
curl -X POST $API_URL/v3/pdf \
     -H 'app_id: mathpix-test-app-1' -H 'app_key: replace-with-your-app-key-1' -H 'Content-Type: application/json' \
     --data '{ "url": "http://cs229.stanford.edu/notes2020spring/cs229-notes1.pdf", "conversion_formats": {"docx": true, "tex.zip": true}}'
```

## How to

### Update mathpix on-prem license

To update the mathpix on-prem license, modify the file `kubernetes-manifests/mathpix/mathpix.env` and run:

```
kubectl apply -k ./kubernetes-manifests/mathpix
```

### Update API credentials

To update your API credentials, modify the file `kubernetes-manifests/jobs/update-credentials/credentials.json` and run:

```
kubectl apply -k ./kubernetes-manifests/api/jobs/update-credentials
```

### Scale the Mathpix API

```
kubectl scale deploy mathpix-api --replicas 3
```

## SCS

To deploy the secure conversions service you'll need to update a few files in the `kubernetes-manifests/scs` directory.

Then you'll need to make a new overlay by copying the `kubernetes-manifests/scs/overlays/example` to a new directory:

```
cp kubernetes-manifests/scs/overlays/example kubernetes-manifests/scs/overlays/your-overlay-name
```

Next, you'll need to update these files to point to the correct SCS image that you have access to.

- `kubernetes-manifests/scs/overlays/your-overlay-name/consumer/kustomization.yaml`
- `kubernetes-manifests/scs/overlays/your-overlay-name/publisher/kustomization.yaml`

```
images:
  - name: external_image
    newName: REPLACE_WITH_REGISTRY_REPO_IMAGE
    newTag: REPLACE_WITH_REGISTRY_REPO_IMAGE_TAG
```

### Publisher

To deploy a publisher job which you'll need to update the `kubernetes-manifests/scs/overlays/your-overlay-name/publisher/secrets.yaml` file to point to the correct values for the following secrets:

- `AMQP_URL`
- `STORAGE_ENDPOINT_URL`
- `ACCESS_KEY_ID`
- `SECRET_ACCESS_KEY`

Then you'll want to update the `kubernetes-manifests/scs/overlays/your-overlay-name/publisher/configmap.yaml` file to point to the correct values for the following configmaps:

- `NAME`
- `JOB_ID`
- `INPUT_BUCKET`
- `INPUT_FOLDER`
- `OUTPUT_BUCKET`
- `OUTPUT_FOLDER`

Once you've updated these files, you can deploy the secure conversions service publisher using the following command:

```
kubectl apply -k ./kubernetes-manifests/scs/overlays/your-overlay-name/publisher
```

## Consumer

To deploy the secure conversions consumer you'll need to update a few files in the `kubernetes-manifests/scs/consumer` directory.

You'll need to update the `kubernetes-manifests/scs/overlays/your-overlay-name/consumer/secrets.yaml` file to point to the correct values for the following secrets:

- `AMQP_URL` - The connection string for the rabbitmq cluster (see [RabbitMQ Broker](#rabbitmq-broker) below)
- `STORAGE_ENDPOINT_URL` - The S3 compatible storage endpoint url
- `ACCESS_KEY_ID` - The access key id for the S3 compatible storage endpoint
- `SECRET_ACCESS_KEY` - The secret access key for the S3 compatible storage endpoint

Then you'll need to update the `kubernetes-manifests/scs/overlays/your-overlay-name/consumer/configmap.yaml` file to point to the correct values for the following configmaps:

- `NAME`
- `JOB_ID`

Once you've updated these files, you can deploy the secure conversions consumer using the following command:

```
kubectl apply -k ./kubernetes-manifests/scs/overlays/your-overlay-name/consumer
```

## GCP GKE Cluster Setup

To create a GKE cluster with the GPU operator and GPU nodes from scratch you can use terraform. Look at the [README.md](kubernetes-cluster-setup/gke/README.md) in the [`kubernetes-cluster-setup/gke/`](kubernetes-cluster-setup/gke/) directory for more information.

## RabbitMQ Broker

The only external dependency for the SCS is the RabbitMQ broker. This can be any rabbitmq broker that supports the AMQP 0.9.1 protocol, for processing large files the heartbeat should be disabled and consumer_timeout set to 3600000 (1 hour).

You can also create a rabbitmq broker in kubernetes using the `rabbitmq-operator` and the cluster configuration in the `rabbitmq-broker-setup` directory:

```bash
# Install the rabbitmq cluster operator
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install rabbitmq-cluster-operator bitnami/rabbitmq-cluster-operator

# Create a rabbitmq cluster
kubectl apply -f .
```

Once that's finished you can get the connection string for the rabbitmq cluster using this:

```bash
kubectl get secret rabbitmq-cluster-default-user -n default -o jsonpath="{.data.connection_string}" | base64 --decode
```

**Note:**: The connection string should end with a `/`, some clusters may add the kubernetes user as the default vhost, which should be removed along with the `%` character denoting the end of the string.
