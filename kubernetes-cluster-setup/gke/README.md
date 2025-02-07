# GKE Cluster with nvidia gpu operator

## Requirements

1. Google cloud platform account and project
2. [`gcloud` CLI](https://cloud.google.com/sdk/docs/install)
4. [`terraform` CLI](https://developer.hashicorp.com/terraform/downloads)

#### Setup

1. Requires the `gcloud` SDK binary -- [Download here](https://cloud.google.com/sdk/docs/install)

2. Requires the Terraform cli @ Version 1.3.4 or higher -- [Download here](https://developer.hashicorp.com/terraform/downloads)

3. To run this module assumes elevated permissions (Kubernetes Engine Admin) in your GCP account, specifically permissions to create VPC networks, GKE clusters, and Compute nodes. This will not work on accounts using the "free plan" as you cannot use GPU nodes until a billing account is attached and activated. 

4. You will need to enable both the Kubernetes API and the Compute Engine APIs enabled. Click [the GKE tab in the GCP panel](https://console.cloud.google.com/kubernetes) for your project and enable the GKE API, which will also enable the Compute engine API at the same time

5. Ensure you have [GPU Quota](https://cloud.google.com/compute/quotas#gpu_quota) in your desired region/zone. You can [request](GPU Quota) if it is not enabled in a new account. You will need quota for both `GPUS_ALL_REGIONS` and for the specific GPU in the desired region.

## Creating the GKE cluster: 

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and update the values as desired.

```
cp terraform.tfvars.example terraform.tfvars
```

2. Login to GCP with `gcloud` cli:

```
gcloud auth application-default login
```

3. Initialize terraform which downloads the required providers:

```
terraform init
```

4. Plan the terraform deployment:

```
terraform plan
```

6. If you're happy with the plan, apply the changes:

```
terraform apply
```

7. After the cluster has been created, you can connect to the cluster with `kubectl` by running the following two commands after the cluster is created:

```
gcloud components install gke-gcloud-auth-plugin
gcloud container clusters get-credentials <CLUSTER_NAME> --region=<REGION>
```

## Deleting the GKE cluster:

You can delete the cluster with the following command:

```
terraform destroy
```
