OPA will only take Json as Input (to sent the terrafrom plan to OPA need to run "tf show -json")




package terraform.library

# TFPLAN should be the terraform execution plan file in JSON format
# You can create it with the following command: terraform show -json plan_file_name > plan.json

import input as tfplan
import future.keywords
import input.resource_changes as resources

# Get resources by type
get_resources_by_type(type) = filtered_resources {
    filtered_resources := [resource | resource := resources[_]; resource.type = type]
}

# Get resources by action
get_resources_by_action(action) = filtered_resources {
    filtered_resources := [resource | resource := resources[_]; resource.change.actions[_] = action]
}

# Get resources by type and action
get_resources_by_type_and_action(type, action) = filtered_resources {
    filtered_resources := [resource | resource := resources[_]; resource.type = type; resource.change.actions[_] = action]
}

# Get resource by name
get_resource_by_name(resource_name) = filtered_resources {
    filtered_resources := [resource | resource := resources[_]; resource.name = resource_name]
}

# Get resource by type and name
get_resource_by_type_and_name(type, resource_name) = filtered_resources {
    filtered_resources := [resource | resource := resources[_]; resource.type = type; resource.name = resource_name]
}









Short answer: Azure DevOps (ADO) agents don’t magically “know” OPA. You give them OPA in one of four common ways:

Install OPA on-the-fly in the job (most common for Microsoft-hosted agents)

Use a container job where the container image already has OPA baked in

1) Microsoft-hosted agent: install OPA at runtime

Microsoft-hosted pools (e.g., ubuntu-latest) start clean each run. You add steps to fetch OPA, verify it, then run it. This gives you reproducibility and pinned versions.

# azure-pipelines.yml
```yml
trigger:
- main

pool:
  vmImage: 'ubuntu-latest'

variables:
  OPA_VERSION: '0.63.0'          # pin versions—don’t float
  OPA_SHA256: '<<paste-official-sha256-here>>'

stages:
- stage: validate
  jobs:
  - job: terraform_plan_and_policy
    steps:
    - checkout: self
      fetchDepth: 1

    # (Optional) Cache the OPA binary between runs to save time
    - task: Cache@2
      inputs:
        key: 'opa | $(OPA_VERSION)'
        path: '$(Pipeline.Workspace)/tools/opa'
      displayName: Cache OPA binary

    - bash: |
        set -euo pipefail
        mkdir -p "$(Pipeline.Workspace)/tools/opa"
        cd "$(Pipeline.Workspace)/tools/opa"
        if [ ! -f ./opa ]; then
          curl -L -o opa "https://openpolicyagent.org/downloads/v$(OPA_VERSION)/opa_linux_amd64_static"
          echo "$(OPA_SHA256)  opa" | sha256sum -c -
          chmod +x opa
        fi
        echo "##vso[task.prependpath]$(Pipeline.Workspace)/tools/opa"
      displayName: Install OPA CLI (verified)

    # Terraform init/plan -> JSON
    - bash: |
        set -euo pipefail
        terraform -version
        terraform init -input=false
        terraform plan -out=plan.tfplan
        terraform show -json plan.tfplan > plan.json
      displayName: Terraform plan to JSON

    # Pull policies (this repo or a central policy repo)
    - bash: |
        set -euo pipefail
        # Example: policy lives under ./policies in this repo
        ls -la policies
      displayName: Show policy bundle

    # Evaluate with OPA (Rego)
    - bash: |
        set -euo pipefail
        opa version
        # Example: expect a rule that collects denials at data.terraform.policy.deny
        opa eval \
          --format pretty \
          --input plan.json \
          --data policies \
          'data.terraform.policy.deny'
      displayName: OPA eval (dry run)

    # Fail the job if any denials returned
    - bash: |
        set -euo pipefail
        DENY_COUNT=$(opa eval --input plan.json --data policies 'count(data.terraform.policy.deny)' -f raw)
        echo "deny count: $DENY_COUNT"
        if [ "$DENY_COUNT" -gt 0 ]; then
          echo "Policy violations found:"
          opa eval --input plan.json --data policies 'data.terraform.policy.deny' --format pretty
          exit 1
        fi
      displayName: Enforce policy gate
```

Notes:

Pin versions (OPA_VERSION) and verify checksum (OPA_SHA256) — this is table stakes for production supply-chain hygiene.

Use Cache@2 to avoid re-downloading OPA every run.

You can swap opa eval for Conftest if you prefer that workflow.

2) Container job: bring your own image with OPA baked in

If you like fully reproducible tooling, ship OPA in the container that runs the job.

```yaml
pool:
  vmImage: 'ubuntu-latest'

container:
  image: ghcr.io/your-org/devsecops-opa-terraform:1.7.3  # includes terraform, opa, jq
  options: --user 0  # if needed

steps:
- checkout: self
- bash: |
    terraform init -input=false
    terraform plan -out=plan.tfplan
    terraform show -json plan.tfplan > plan.json
  displayName: Terraform plan

- bash: |
    opa eval --input plan.json --data policies 'data.terraform.policy.deny'
  displayName: OPA eval
```

## Pros:

Same toolchain everywhere.

No per-run downloads.
## Cons:

You must maintain and version the image (which is a good thing, but it’s work).



Deployment:
- OPA is self Contained binary
- You want to deploy OPA for every service you have, you don't want to centralized - where are you Checking for all the services
- In the kubernetes we can install side car container
- if you are writtinga GO application you cab passin as GO library
- WASM



Digram:
tfplan ---------------v
Rego    ---------->  OPA
value (data) ---------^



Value (Policy data)
External inputs to your policies that aren’t in the Terraform plan or rego.
  - Jason web tiken 
  - as party of quty input
  - Puch data
  - budle API
  - http.sebd function inside policy 

  we can this a data 
  popblem - you have to make extra network calls




```rego
package terraform.policy

allowed_vms = ["t3.micro", "t3.small"]   <--- Data you can write as part of the Rego file. but what if this list changes often 

deny[msg] {
  input.resource.type == "aws_instance"
  not input.resource.instance_type in allowed_vms
  msg := sprintf("VM type %s not allowed", [input.resource.instance_type])
}
```
You separate “data” from “policy” 

```json
{
  "allowed_vm_types": ["t3.micro", "t3.small", "t3.medium"]
}
```
This list can list can be featched (by a  script) or they can ypdate in the there Git thta will trigger a pipleine whicj will bundel up the data and policy and store it a any location.






two modes:
Pipelines → short-lived OPA, feed latest repo snapshot.
Runtime / sidecars → long-lived OPA, auto-pulls bundles from a central service.


## Policy at runtime:
OPA runs as a long-lived server process (or sidecar).
Other apps/services query it via REST calls

You install the ops in the same server (where you what to run the check aginest)
- installing OPA in the same pod as a different container for the API service, any calls that made to the API will be validated via OPS in the same pod
- Or you can install an VM as a system MD service that runs all the time and does the validation made it to that server
- The other can be like proxy integration where engine X word before the API service and calls the Oppa and only the forward requested request would go to the API service
- Open runs as a controller within the cost and validate any request that comes to the Cluster



1. How OPA consumes data

OPA doesn’t “scrape a website” or read random files itself.
It expects "bundles" or "files you load". A bundle is just a tarball/zip that contains:

- policy/ → your Rego code
- data.json → your reference data

OPA runs with a config that says:
“Hey OPA, every 5 minutes, pull the latest bundle from this URL.”

So when the security team updates the VM list in Git → CI/CD builds a new bundle → publishes to S3, cloude stotage, or an artifact repo → OPA fetches fro thhere.

2. Typical dynamic update workflow

Security team updates a JSON list (or YAML, doesn’t matter).

```json
{
  "allowed_vm_types": ["t3.micro", "t3.small", "t3.medium"]
}
```

Commit → CI/CD pipeline packages policies + data into a bundle.

**bundle = policy(.rego) + data.json ***

Bundle is uploaded to an artifact store (S3 bucket, GCS bucket, Artifactory, OCI registry).

Each OPA instance has a **config** like:
```json
{
  "services": {
    "policy-bundle": {
      "url": "https://s3.amazonaws.com/my-opa-bundles"
    }
  },
  "bundles": {
    "infra-policies": {
      "service": "policy-bundle",
      "resource": "terraform/bundle.tar.gz",
      "polling": {
        "min_delay_seconds": 60,
        "max_delay_seconds": 120
      }
    }
  }
}
```
where does the congif file live?
VM:
Write config.yaml (or .json) on disk.
Start OPA with: opa run --server --config-file=/etc/opa/config.yaml.
*** opa run --server --config-file=config.yaml ***

Kubernetes — Sidecar next to your app:
- Put the config in a ConfigMap.
- Mount it into the OPA container and pass --config-file=/config/config.yaml.
- You can do this either directly in a Deployment manifest or via Helm values

That tells OPA: pull the latest bundle every minute or two.

OPA reloads policies and data without restart.
It stors it in in-memorey in the server.









code smaple :
 |---- Policy.Rego
 |---- Input.json
 |---- policy_TEST.Rego


policy.rego
```js
package policy ## this can be any thing

 default allow = false
 
 allow{
    input.user.roles[_] = "admin" ## "admin" is data if you have Dynamic data you would put that in a data source 
 } 

```

input.json
```json
{
  "user"{
    "username" = "munna"
    "role" = ["QA","DEV","Admin"]
  }
}
```




 if you have a dynamic change in Data, this is what the file structure looks like
 
 |---- Policy.Rego
 |---- Input.json
 |---- data.json
 |---- policy_TEST.Rego


policy.rego
```js
package policy ## this can be any thing

 default allow = false
 
 allow{
  same r
  input.user.roles[r] = data.allowed_role[_]
 } 

```

data.json 
```json
allowed_role : ["admin","superuser"]
```

input.json
```json
{
  "user"{
    "username" = "munna"
    "role" = ["QA","DEV","Admin"]
  }
}
```

policy_test.rego
```js
Package policy_TEST

Import data.policy.allow

tes_allow_is_false_by_default {
  not allowe
}

test_allow_if_admin {
  allow with input as {
      "user": {
          "role" : ["admin"]
      }
  }
  allow with input as {
      "user": {
          "role" : ["super user"]
      }
  }
}

test_allow_if_not_admin {
  not allow with input as {
      "user": {
          "role" : ["Dev"]
      }
  }
  not allow with input as {
      "user": {
          "role" : ["QA"]
      }
  }
}


```


## policy_test.rego:
A unit test file for your Rego policies. 
Discovered and executed by opa test


test.rego is not used in Opa Run time it only used in the pipeline for TEST confident purpose. It would be in the rego repo And runs in the CI process.

- opa fmt → check formatting
- opa check → validate syntax
- opa test → run unit tests (*_test.rego)





If we write a multiple allow statements in a policy, it would consider as a "or" Meaning, if any one of those checks the box it would Allow.
 In the below example, if the role admin or super admin, it would pass. 
```rego
package policy

default allow = false

allow if {
    input.user.role[_] == "admin"
}


allow if {
    input.user.role[_] == "superadmin"
}
```
if you want a "AND"

```rego
package policy

default allow = false

allow if {
    input.user.role[_] == "admin"
    input.user.role[_] == "superadmin"
}

```

