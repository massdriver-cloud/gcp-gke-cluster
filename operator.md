### Google Kubernetes Engine (GKE)

Google Kubernetes Engine (GKE) is a managed, production-ready environment for deploying containerized applications. It provides a managed Kubernetes service that simplifies the tasks of managing, scaling, and upgrading containerized applications.

### Design Decisions

1. **Node Pools Management**: We utilize the GKE managed node pools feature, allowing different machine types and auto-scaling configurations.
2. **Workload Identity**: Enabled to improve security by allowing Kubernetes workloads to authenticate as Google Cloud service accounts.
3. **Private Cluster**: Private nodes are enabled to ensure that nodes do not have public IP addresses.
4. **Add-ons Configuration**: Add-ons like horizontal pod autoscaling, HTTP load balancing, and DNS cache are configured.
5. **Logging and Monitoring**: Both system and workload components logging and monitoring are configured through GKE's logging and monitoring services.
6. **Security**: Shielded nodes are enabled for enhanced protection against rootkits and bootkits.
7. **Custom Service Accounts**: Node pools are configured to use custom service accounts with specific IAM roles for enhanced security.

### Install Kubectl

You will first need to install `kubectl` to interact with the kubernetes cluster. Installation instructions for Windows, Mac and Linux can be found [here](https://kubernetes.io/docs/tasks/tools/#kubectl).

Note: While `kubectl` generally has forwards and backwards compatibility of core capabilities, it is best if your `kubectl` client version is matched with your kubernetes cluster version. This ensures the best stability and compability for your client.

The standard way to manage connection and authentication details for kubernetes clusters is through a configuration file called a [`kubeconfig`](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/) file.

### Download the Kubeconfig File

The standard way to manage connection and authentication details for kubernetes clusters is through a configuration file called a [`kubeconfig`](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/) file. The `kubernetes-cluster` artifact that is created when you make a kubernetes cluster in Massdriver contains the basic information needed to create a `kubeconfig` file. Because of this, Massdriver makes it very easy for you to download a `kubeconfig` file that will allow you to use `kubectl` to query and administer your cluster.

For more information on downloading your `kubeconfig` file, [check out our documentation](https://docs.massdriver.cloud/runbooks/kubernetes/access#downloading-your-kubeconfig-file).

### Use the Kubeconfig File

Once the `kubeconfig` file is downloaded, you can move it to your desired location. By default, `kubectl` will look for a file named `config` located in the `$HOME/.kube` directory. If you would like this to be your default configuration, you can rename and move the file to `$HOME/.kube/config`.

A single `kubeconfig` file can hold multiple cluster configurations, and you can select your desired cluster through the use of [`contexts`](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/#context). Alternatively, you can have multiple `kubeconfig` files and select your desired file through the `KUBECONFIG` environment variable or the `--kubeconfig` flag in `kubectl`.

### Runbook

#### Unable to Connect to GKE Cluster

If you are unable to connect to your GKE cluster, you might need to reconfigure your Kubernetes context.

```sh
# Retrieve cluster credentials
gcloud container clusters get-credentials <cluster-name> --region <region> --project <project-id>
```

This command configures `kubectl` to use the cluster's credentials.

#### Troubleshooting Pod Issues

Sometimes, your pods might not behave as expected. You can describe and get logs for the pods:

```sh
# Describe the pod
kubectl describe pod <pod-name> -n <namespace>

# Check pod logs
kubectl logs <pod-name> -n <namespace>
```

Use these commands to get detailed information about the pod's state and any recent log output.

#### Checking Cluster and Nodes Health

To check the overall health of your GKE cluster and the nodes, you can use the following commands:

```sh
# Get cluster details
gcloud container clusters describe <cluster-name> --region <region> --project <project-id>

# List all nodes
kubectl get nodes
```

These commands provide an overview of the cluster's configuration and the status of all nodes within it.

#### Debugging Service Issues

If a service is not behaving as expected, you can describe the service and its endpoints:

```sh
# Describe the service
kubectl describe service <service-name> -n <namespace>

# Check endpoints
kubectl get endpoints <service-name> -n <namespace>
```

These commands give insights into the service configuration and which pods are backing it.

#### Pod Scheduling Issues

If your pods are not scheduling, there might be a resource constraint or taints/tolerations issue:

```sh
# Check scheduler events
kubectl get events -n <namespace>

# Describe the nodes
kubectl describe nodes
```

Reviewing events and node descriptions can help identify why pods are not being scheduled.

#### Node Pool Autoscaling Issues

If node pools are not autoscaling as expected, verify the autoscaling configuration:

```sh
# Describe the node pool
gcloud container node-pools describe <node-pool-name> --region <region> --cluster <cluster-name> --project <project-id>
```

Check the current settings and history to diagnose discrepancies.

#### Container Crashes

If a container within a pod crashes or restarts frequently:

```sh
# Describe the pod to see container status and reason for restarts
kubectl describe pod <pod-name> -n <namespace>

# Get logs, including previous instance if it crashed
kubectl logs <pod-name> -n <namespace> --previous
```

Assess the logs and container status to determine the cause of the crashes.
