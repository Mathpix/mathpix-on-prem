{{- define "mathpix-ocr.ecrJobSpec" }}
spec:
  serviceAccountName: ecr-credential-updater
  restartPolicy: OnFailure
  containers:
  - name: ecr-updater
    image: amazon/aws-cli:2.15.30
    env:
    - name: AWS_DEFAULT_REGION
      value: "us-east-1"
    - name: ECR_REGISTRY
      value: "426887012336.dkr.ecr.us-east-1.amazonaws.com"
    - name: SECRET_NAME
      value: "ecr-registry-secret"
    - name: NAMESPACE
      value: {{ .Release.Namespace }}
    - name: AWS_ACCESS_KEY_ID
      valueFrom:
        secretKeyRef:
          name: aws-creds
          key: AWS_ACCESS_KEY_ID
    - name: AWS_SECRET_ACCESS_KEY
      valueFrom:
        secretKeyRef:
          name: aws-creds
          key: AWS_SECRET_ACCESS_KEY
    command:
    - /bin/bash
    - -c
    - |
      set -e
      echo "Starting ECR credential update for namespace: $NAMESPACE"
      curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
      chmod +x kubectl
      mv kubectl /usr/local/bin/
      echo "Getting ECR login token..."
      TOKEN=$(aws ecr get-login-password --region $AWS_DEFAULT_REGION)
      if [ -z "$TOKEN" ]; then
        echo "Failed to get ECR token"
        exit 1
      fi
      echo "Creating/updating secret: $SECRET_NAME in namespace: $NAMESPACE"
      kubectl create secret docker-registry $SECRET_NAME \
        --docker-server=$ECR_REGISTRY \
        --docker-username=AWS \
        --docker-password=$TOKEN \
        --namespace=$NAMESPACE \
        --dry-run=client -o yaml | kubectl apply -f -
      echo "ECR credential secret updated successfully!"
{{- end }}
