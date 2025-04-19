# CI/CD Pipeline: Jenkins, Docker, DockerHub, and Kubernetes [WEBSITE URL:](https://website.theaditya.co.uk/)

This repository contains the code and configurations for a CI/CD pipeline that automates the following workflow:
1. Jenkins builds a Docker image from the source code.
2. Jenkins tags and pushes the image to DockerHub.
3. Kubernetes pulls the image from DockerHub and deploys it to the cluster.

## Prerequisites
Ensure the following tools and services are set up before using this pipeline:
- Jenkins is installed and configured with the required plugins:
  - Docker Pipeline
  - Kubernetes Continuous Deploy
  - GitHub Integration
- A DockerHub account with repository access.
- A Kubernetes cluster (e.g., minikube, AWS EKS, GCP GKE, Azure AKS).
- `kubectl` CLI configured to interact with your Kubernetes cluster.
- Access to the Jenkins server with proper permissions.

---

## Jenkins Pipeline Overview
The Jenkins pipeline defined in `Jenkinsfile` performs the following steps:
1. Clones the repository from GitHub.
2. Builds a Docker image using the `Dockerfile`.
3. Tags the image with the `latest` tag and a unique build tag.
4. Pushes the tagged image to DockerHub.
5. Deploys the application to the Kubernetes cluster using `kubectl`.

---

## Configuration Steps

### 1. Set Up DockerHub Credentials in Jenkins
- In Jenkins, navigate to **Manage Jenkins > Credentials > Global**.
- Add a new credential:
  - **Kind**: Username and password.
  - **ID**: `dockerhub`.
  - Provide your DockerHub username and password.

### 2. Set Up Jenkins Pipeline
- Create a Jenkins Pipeline project.
- Link the project to this GitHub repository.
- Ensure the Jenkins node has Docker installed and configured.

### 3. Set Up Kubernetes Access
- Install the `kubectl` CLI on the Jenkins node.
- Configure access to your Kubernetes cluster using a `kubeconfig` file.
- Ensure Jenkins has permission to apply Kubernetes manifests.

### 4. Update Kubernetes YAMLs
- Modify the `deployment.yaml` file to point to your DockerHub repository and desired image tag.

Example:
```yaml
containers:
  - name: app
    image: <your-dockerhub-username>/app-name:latest
    ports:
      - containerPort: 80
```

---

## Running the Pipeline
1. Push your code changes to the GitHub repository.
2. Jenkins will automatically trigger the pipeline (if webhooks are configured).
3. Monitor the Jenkins console to ensure all steps complete successfully:
   - Clone Repository
   - Build Docker Image
   - Push Image to DockerHub
   - Deploy to Kubernetes Cluster
4. Verify the deployment in Kubernetes:
   ```bash
   kubectl get pods
   kubectl get svc
   ```

---

## Accessing the Application
- If a Kubernetes **Service** is exposed, retrieve the external IP:
  ```bash
  kubectl get svc
  ```
- If using an **Ingress**, ensure your DNS is configured and access the application via the hostname.

---

## Troubleshooting
- **DockerHub Push Issues**: Verify DockerHub credentials in Jenkins and repository access.
- **Kubernetes Deployment Issues**: Check the logs of the deployed pod:
  ```bash
  kubectl logs <pod-name>
  ```
- **Pipeline Failures**: Review the Jenkins console logs for detailed error messages.

---

## Contributing
Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

---