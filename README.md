




[![Massdriver][logo]][website]

# gcp-gke-cluster

[![Release][release_shield]][release_url]
[![Contributors][contributors_shield]][contributors_url]
[![Forks][forks_shield]][forks_url]
[![Stargazers][stars_shield]][stars_url]
[![Issues][issues_shield]][issues_url]
[![MIT License][license_shield]][license_url]

<!--
##### STILL NEED TO GET SLACK WORKING ###
[!["Slack Community"](%s)][slack]
-->


GKE is a managed Kubernetes service in GCP that implements the full Kubernetes API, 4-way autoscaling, release channels and multi-cluster support.


---

## Design

For detailed information, check out our [Operator Guide](operator.mdx) for this bundle.

## Usage

Our bundles aren't intended to be used locally, outside of testing. Instead, our bundles are designed to be configured, connected, deployed and monitored in the [Massdriver][website] platform.

### What are Bundles?

Bundles are the basic building blocks of infrastructure, applications, and architectures in [Massdriver][website]. Read more [here](https://docs.massdriver.cloud/concepts/bundles).

## Bundle

### Params

Form input parameters for configuring a bundle for deployment.

<details>
<summary>View</summary>

<!-- PARAMS:START -->
## Properties

- **`cluster_configuration`** *(object)*: Configure the basic settings and capabilities of the cluster.
  - **`enable_binary_authorization`** *(boolean)*: WARNING: This can prevent container workloads from running! Binary Authorization is a deploy-time security control that ensures only trusted container images are deployed on Google Kubernetes Engine (GKE). More information here: https://cloud.google.com/binary-authorization. Default: `False`.
- **`cluster_networking`** *(object)*: Configure the network configuration of the cluster.
  - **`cluster_ipv4_cidr_block`** *(string)*: CIDR block to use for kubernetes pods. Set to /netmask (e.g. /16) to have a range chosen with a specific netmask. Set to a CIDR notation (e.g. 10.96.0.0/14) from the RFC-1918 private networks (e.g. 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) to pick a specific range to use. Default: `/16`.
  - **`master_ipv4_cidr_block`** *(string)*: CIDR block to use for kubernetes control plane. The mask for this must be exactly /28. Must be from the RFC-1918 private networks (e.g. 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16), and should not conflict with other ranges in use. It is recommended to use consecutive /28 blocks from the 172.16.0.0/16 range for all your GKE clusters (172.16.0.0/28 for the first cluster, 172.16.0.16/28 for the second, etc.). Default: `172.16.0.0/28`.

    Examples:
    ```json
    "10.100.0.0/16"
    ```

    ```json
    "192.24.12.0/22"
    ```

  - **`services_ipv4_cidr_block`** *(string)*: CIDR block to use for kubernetes services. Set to /netmask (e.g. /20) to have a range chosen with a specific netmask. Set to a CIDR notation (e.g. 10.96.0.0/14) from the RFC-1918 private networks (e.g. 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) to pick a specific range to use. Default: `/20`.
- **`core_services`** *(object)*: Configure core services in Kubernetes for Massdriver to manage.
  - **`cloud_dns_managed_zones`** *(array)*: Select any Cloud DNS Managed Zones associated with this cluster to allow the cluster to automatically manage DNS records and SSL certificates. Default: `[]`.
    - **Items** *(string)*
  - **`enable_ingress`** *(boolean)*: Enabling this will create an nginx ingress controller in the cluster, allowing internet traffic to flow into web accessible services within the cluster. Default: `False`.
- **`k8s_version`** *(string)*: The version of Kubernetes to run. Must be one of: `['1.19', '1.20', '1.21', '1.22']`.
- **`node_groups`** *(array)*
  - **Items** *(object)*: Definition of a node group.
    - **`machine_type`** *(string)*: Machine type to use in the node group. Must be one of: `['e2-micro', 'e2-small', 'e2-medium', 'e2-standard-2', 'e2-standard-4', 'e2-standard-8', 'e2-standard-16', 'e2-standard-32', 'e2-highmem-2', 'e2-highmem-4', 'e2-highmem-8', 'e2-highmem-16', 'e2-highcpu-2', 'e2-highcpu-4', 'e2-highcpu-8', 'e2-highcpu-16', 'e2-highcpu-32']`.
    - **`max_size`** *(number)*: Maximum number of instances in the node group. Default: `10`.
    - **`min_size`** *(number)*: Minimum number of instances in the node group. Default: `1`.
    - **`name`** *(string)*: The name of the node group. Default: ``.
## Examples

  ```json
  {
      "__name": "Development",
      "k8s_version": "1.21",
      "node_groups": [
          {
              "machine_type": [
                  "e2-highcpu-2"
              ],
              "max_size": 5,
              "min_size": 1,
              "name": "small-pool"
          }
      ]
  }
  ```

  ```json
  {
      "__name": "Production",
      "k8s_version": "1.21",
      "node_groups": [
          {
              "machine_type": [
                  "n2-standard-16"
              ],
              "max_size": 20,
              "min_size": 1,
              "name": "big-pool-general"
          },
          {
              "machine_type": [
                  "n2-highmem-16"
              ],
              "max_size": 6,
              "min_size": 1,
              "name": "big-pool-high-mem"
          }
      ]
  }
  ```

<!-- PARAMS:END -->

</details>

### Connections

Connections from other bundles that this bundle depends on.

<details>
<summary>View</summary>

<!-- CONNECTIONS:START -->
## Properties

- **`gcp_authentication`** *(object)*: GCP Service Account. Cannot contain additional properties.
  - **`data`** *(object)*
    - **`auth_provider_x509_cert_url`** *(string)*: Auth Provider x509 Certificate URL. Default: `https://www.googleapis.com/oauth2/v1/certs`.

      Examples:
      ```json
      "https://example.com/some/path"
      ```

      ```json
      "https://massdriver.cloud"
      ```

    - **`auth_uri`** *(string)*: Auth URI. Default: `https://accounts.google.com/o/oauth2/auth`.

      Examples:
      ```json
      "https://example.com/some/path"
      ```

      ```json
      "https://massdriver.cloud"
      ```

    - **`client_email`** *(string)*: Service Account Email.

      Examples:
      ```json
      "jimmy@massdriver.cloud"
      ```

      ```json
      "service-account-y@gmail.com"
      ```

    - **`client_id`** *(string)*: .
    - **`client_x509_cert_url`** *(string)*: Client x509 Certificate URL.

      Examples:
      ```json
      "https://example.com/some/path"
      ```

      ```json
      "https://massdriver.cloud"
      ```

    - **`private_key`** *(string)*: .
    - **`private_key_id`** *(string)*: .
    - **`project_id`** *(string)*: .
    - **`token_uri`** *(string)*: Token URI. Default: `https://oauth2.googleapis.com/token`.

      Examples:
      ```json
      "https://example.com/some/path"
      ```

      ```json
      "https://massdriver.cloud"
      ```

    - **`type`** *(string)*: . Default: `service_account`.
  - **`specs`** *(object)*
    - **`gcp`** *(object)*: .
      - **`project`** *(string)*
      - **`region`** *(string)*: GCP region. Must be one of: `['us-east1', 'us-east4', 'us-west1', 'us-west2', 'us-west3', 'us-west4', 'us-central1']`.

        Examples:
        ```json
        "us-west2"
        ```

      - **`resource`** *(string)*
      - **`service`** *(string)*
      - **`zone`** *(string)*: GCP Zone.

        Examples:
- **`subnetwork`** *(object)*: A region-bound network for deploying GCP resources. Cannot contain additional properties.
  - **`data`** *(object)*
    - **`infrastructure`** *(object)*
      - **`cidr`** *(string)*

        Examples:
        ```json
        "10.100.0.0/16"
        ```

        ```json
        "192.24.12.0/22"
        ```

      - **`gcp_global_network_grn`** *(string)*: GCP Resource Name (GRN).

        Examples:
        ```json
        "projects/my-project/global/networks/my-global-network"
        ```

        ```json
        "projects/my-project/regions/us-west2/subnetworks/my-subnetwork"
        ```

        ```json
        "projects/my-project/topics/my-pubsub-topic"
        ```

        ```json
        "projects/my-project/subscriptions/my-pubsub-subscription"
        ```

        ```json
        "projects/my-project/locations/us-west2/instances/my-redis-instance"
        ```

        ```json
        "projects/my-project/locations/us-west2/clusters/my-gke-cluster"
        ```

      - **`grn`** *(string)*: GCP Resource Name (GRN).

        Examples:
        ```json
        "projects/my-project/global/networks/my-global-network"
        ```

        ```json
        "projects/my-project/regions/us-west2/subnetworks/my-subnetwork"
        ```

        ```json
        "projects/my-project/topics/my-pubsub-topic"
        ```

        ```json
        "projects/my-project/subscriptions/my-pubsub-subscription"
        ```

        ```json
        "projects/my-project/locations/us-west2/instances/my-redis-instance"
        ```

        ```json
        "projects/my-project/locations/us-west2/clusters/my-gke-cluster"
        ```

  - **`specs`** *(object)*
    - **`gcp`** *(object)*: .
      - **`project`** *(string)*
      - **`region`** *(string)*: GCP region. Must be one of: `['us-east1', 'us-east4', 'us-west1', 'us-west2', 'us-west3', 'us-west4', 'us-central1']`.

        Examples:
        ```json
        "us-west2"
        ```

      - **`resource`** *(string)*
      - **`service`** *(string)*
      - **`zone`** *(string)*: GCP Zone.

        Examples:
<!-- CONNECTIONS:END -->

</details>

### Artifacts

Resources created by this bundle that can be connected to other bundles.

<details>
<summary>View</summary>

<!-- ARTIFACTS:START -->
## Properties

- **`kubernetes_cluster`** *(object)*: Kubernetes cluster authentication and cloud-specific configuration. Cannot contain additional properties.
  - **`data`** *(object)*
    - **`authentication`** *(object)*
      - **`cluster`** *(object)*
        - **`certificate-authority-data`** *(string)*
        - **`server`** *(string)*
      - **`user`** *(object)*
        - **`token`** *(string)*
    - **`infrastructure`** *(object)*: Cloud specific Kubernetes configuration data.
      - **One of**
        - AWS EKS infrastructure config*object*: . Cannot contain additional properties.
          - **`arn`** *(string)*: Amazon Resource Name.

            Examples:
            ```json
            "arn:aws:rds::ACCOUNT_NUMBER:db/prod"
            ```

            ```json
            "arn:aws:ec2::ACCOUNT_NUMBER:vpc/vpc-foo"
            ```

          - **`oidc_issuer_url`** *(string)*: An HTTPS endpoint URL.

            Examples:
            ```json
            "https://example.com/some/path"
            ```

            ```json
            "https://massdriver.cloud"
            ```

        - Azure Infrastructure Resource ID*object*: Minimal Azure Infrastructure Config. Cannot contain additional properties.
          - **`ari`** *(string)*: Azure Resource ID.

            Examples:
            ```json
            "/subscriptions/12345678-1234-1234-abcd-1234567890ab/resourceGroups/resource-group-name/providers/Microsoft.Network/virtualNetworks/network-name"
            ```

        - GCP Infrastructure GRN*object*: Minimal GCP Infrastructure Config. Cannot contain additional properties.
          - **`grn`** *(string)*: GCP Resource Name (GRN).

            Examples:
            ```json
            "projects/my-project/global/networks/my-global-network"
            ```

            ```json
            "projects/my-project/regions/us-west2/subnetworks/my-subnetwork"
            ```

            ```json
            "projects/my-project/topics/my-pubsub-topic"
            ```

            ```json
            "projects/my-project/subscriptions/my-pubsub-subscription"
            ```

            ```json
            "projects/my-project/locations/us-west2/instances/my-redis-instance"
            ```

            ```json
            "projects/my-project/locations/us-west2/clusters/my-gke-cluster"
            ```

  - **`specs`** *(object)*
    - **`kubernetes`** *(object)*: Kubernetes distribution and version specifications.
      - **`cloud`** *(string)*: Must be one of: `['aws', 'gcp', 'azure']`.
      - **`distribution`** *(string)*: Must be one of: `['eks', 'gke', 'aks']`.
      - **`platform_version`** *(string)*
      - **`version`** *(string)*
<!-- ARTIFACTS:END -->

</details>

## Contributing

<!-- CONTRIBUTING:START -->

### Bug Reports & Feature Requests

Did we miss something? Please [submit an issue](https://github.com/massdriver-cloud/gcp-gke-cluster/issues) to report any bugs or request additional features.

### Developing

**Note**: Massdriver bundles are intended to be tightly use-case scoped, intention-based, reusable pieces of IaC for use in the [Massdriver][website] platform. For this reason, major feature additions that broaden the scope of an existing bundle are likely to be rejected by the community.

Still want to get involved? First check out our [contribution guidelines](https://docs.massdriver.cloud/bundles/contributing).

### Fix or Fork

If your use-case isn't covered by this bundle, you can still get involved! Massdriver is designed to be an extensible platform. Fork this bundle, or [create your own bundle from scratch](https://docs.massdriver.cloud/bundles/development)!

<!-- CONTRIBUTING:END -->

## Connect

<!-- CONNECT:START -->

Questions? Concerns? Adulations? We'd love to hear from you!

Please connect with us!

[![Email][email_shield]][email_url]
[![GitHub][github_shield]][github_url]
[![LinkedIn][linkedin_shield]][linkedin_url]
[![Twitter][twitter_shield]][twitter_url]
[![YouTube][youtube_shield]][youtube_url]
[![Reddit][reddit_shield]][reddit_url]

<!-- markdownlint-disable -->

[logo]: https://raw.githubusercontent.com/massdriver-cloud/docs/main/static/img/logo-with-logotype-horizontal-400x110.svg
[docs]: https://docs.massdriver.cloud/?utm_source=github&utm_medium=readme&utm_campaign=gcp-gke-cluster&utm_content=docs
[website]: https://www.massdriver.cloud/?utm_source=github&utm_medium=readme&utm_campaign=gcp-gke-cluster&utm_content=website
[github]: https://github.com/massdriver-cloud?utm_source=github&utm_medium=readme&utm_campaign=gcp-gke-cluster&utm_content=github
[slack]: https://massdriverworkspace.slack.com/?utm_source=github&utm_medium=readme&utm_campaign=gcp-gke-cluster&utm_content=slack
[linkedin]: https://www.linkedin.com/company/massdriver/?utm_source=github&utm_medium=readme&utm_campaign=gcp-gke-cluster&utm_content=linkedin



[contributors_shield]: https://img.shields.io/github/contributors/massdriver-cloud/gcp-gke-cluster.svg?style=for-the-badge
[contributors_url]: https://github.com/massdriver-cloud/gcp-gke-cluster/graphs/contributors
[forks_shield]: https://img.shields.io/github/forks/massdriver-cloud/gcp-gke-cluster.svg?style=for-the-badge
[forks_url]: https://github.com/massdriver-cloud/gcp-gke-cluster/network/members
[stars_shield]: https://img.shields.io/github/stars/massdriver-cloud/gcp-gke-cluster.svg?style=for-the-badge
[stars_url]: https://github.com/massdriver-cloud/gcp-gke-cluster/stargazers
[issues_shield]: https://img.shields.io/github/issues/massdriver-cloud/gcp-gke-cluster.svg?style=for-the-badge
[issues_url]: https://github.com/massdriver-cloud/gcp-gke-cluster/issues
[release_url]: https://github.com/massdriver-cloud/gcp-gke-cluster/releases/latest
[release_shield]: https://img.shields.io/github/release/massdriver-cloud/gcp-gke-cluster.svg?style=for-the-badge
[license_shield]: https://img.shields.io/github/license/massdriver-cloud/gcp-gke-cluster.svg?style=for-the-badge
[license_url]: https://github.com/massdriver-cloud/gcp-gke-cluster/blob/main/LICENSE


[email_url]: mailto:support@massdriver.cloud
[email_shield]: https://img.shields.io/badge/email-Massdriver-black.svg?style=for-the-badge&logo=mail.ru&color=000000
[github_url]: mailto:support@massdriver.cloud
[github_shield]: https://img.shields.io/badge/follow-Github-black.svg?style=for-the-badge&logo=github&color=181717
[linkedin_url]: https://linkedin.com/in/massdriver-cloud
[linkedin_shield]: https://img.shields.io/badge/follow-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&color=0A66C2
[twitter_url]: https://twitter.com/massdriver?utm_source=github&utm_medium=readme&utm_campaign=gcp-gke-cluster&utm_content=twitter
[twitter_shield]: https://img.shields.io/badge/follow-Twitter-black.svg?style=for-the-badge&logo=twitter&color=1DA1F2
[discourse_url]: https://community.massdriver.cloud?utm_source=github&utm_medium=readme&utm_campaign=gcp-gke-cluster&utm_content=discourse
[discourse_shield]: https://img.shields.io/badge/join-Discourse-black.svg?style=for-the-badge&logo=discourse&color=000000
[youtube_url]: https://www.youtube.com/channel/UCfj8P7MJcdlem2DJpvymtaQ
[youtube_shield]: https://img.shields.io/badge/subscribe-Youtube-black.svg?style=for-the-badge&logo=youtube&color=FF0000
[reddit_url]: https://www.reddit.com/r/massdriver
[reddit_shield]: https://img.shields.io/badge/subscribe-Reddit-black.svg?style=for-the-badge&logo=reddit&color=FF4500

<!-- markdownlint-restore -->

<!-- CONNECT:END -->
