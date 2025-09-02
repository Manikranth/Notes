# OPA (Open Policy Agent) - Complete Notes

## 📋 Table of Contents

<details>
<summary>Click to expand</summary>

1. [OPA Basics](#opa-basics)
2. [Terraform Integration](#terraform-integration)
3. [Azure DevOps Integration](#azure-devops-integration)
4. [OPA Deployment Modes](#opa-deployment-modes)
5. [Data Sources & Policy Management](#data-sources--policy-management)
6. [Code Examples](#code-examples)
7. [Testing](#testing)
8. [Kubernetes Admission Control](#kubernetes-admission-control)

</details>

---
&nbsp;
## 🎯 OPA Basics

> **Key Point**: OPA will only take JSON as Input (to send the terraform plan to OPA need to run `tf show -json`)

&nbsp;

### OPA Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Input Data    │    │  Rego Policies  │    │  Data Sources   │
│     (JSON)      │    │                 │    │                 │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                      │                      │
          │                      │                      │
          └──────────────────────┼──────────────────────┘
                                 │
                                 ▼
                      ┌─────────────────┐
                      │   OPA Engine    │
                      │                 │
                      │ ┌─────────────┐ │
                      │ │   Policy    │ │
                      │ │ Evaluation  │ │
                      │ └─────────────┘ │
                      └─────────┬───────┘
                                │
                                ▼
                      ┌─────────────────┐
                      │ Policy Decision │
                      │   (Allow/Deny)  │
                      └─────────────────┘
```

---

&nbsp;
### Data Source Options

**Data Sources (Policy data)**: External inputs to your policies that aren't in the Terraform plan or rego.

- JSON Web Token
- Query input
- Push data
- Bundle API
- `http.send` function inside policy

> **⚠️ Problem**: You have to make extra network calls
---
&nbsp;
## 🚀 Azure DevOps Integration

> **Short answer**: Azure DevOps (ADO) agents don't magically "know" OPA. You give them OPA in one of four common ways:

### Option 1: Microsoft-hosted agent (install OPA at runtime) - **Most Common**

<details>
<summary>Complete Pipeline Example</summary>

```yaml
# azure-pipelines.yml
trigger:
- main

pool:
  vmImage: 'ubuntu-latest'

variables:
  OPA_VERSION: '0.63.0'          # pin versions—don't float
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

</details>

### Option 2: Container job (OPA baked in)

<details>
<summary>Container-based Pipeline</summary>

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

**Pros:**
- Same toolchain everywhere
- No per-run downloads

**Cons:**
- You must maintain and version the image (which is a good thing, but it's work)

</details>

---

&nbsp;
## 📦 OPA Deployment Modes

### Deployment Options

```
┌─────────────────────────────────────────────────────────────────┐
│                    OPA Deployment Modes                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  🔄 Pipeline Mode              🖥️  Server/Service Mode           │
│  ┌─────────────────┐           ┌─────────────────────────────┐  │
│  │ Short-lived OPA │           │ Long-lived OPA              │  │
│  │ Latest repo     │           │ Auto-pulls bundles          │  │
│  │ snapshot        │           │ Central service             │  │
│  └─────────────────┘           └─────────────────────────────┘  │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│  Deployment Options:                                            │
│  • Self-contained binary                                        │
│  • Kubernetes sidecar container                                 │
│  • GO library (for GO applications)                             │
│  • WASM                                                         │
└─────────────────────────────────────────────────────────────────┘
```

### Server/Services Deployment Patterns

- **Same Pod/VM**: OPA installed in same server where validation is needed
- **Sidecar**: OPA in same pod as API service, validates all API calls
- **System Service**: OPA as systemd service running all the time
- **Proxy Integration**: Engine X before API service, calls OPA first
- **Kubernetes Controller**: OPA runs as controller, validates cluster requests

---
&nbsp;
## 📊 Data Sources & Policy Management

### The Problem with Static Data

```rego
package terraform.policy

allowed_vms = ["t3.micro", "t3.small"]   # <--- Data as part of Rego file
                                         # Problem: what if this list changes often?

deny[msg] {
  input.resource.type == "aws_instance"
  not input.resource.instance_type in allowed_vms
  msg := sprintf("VM type %s not allowed", [input.resource.instance_type])
}
```

### Solution: Separate Data from Policy

**External Data File:**
```json
{
  "allowed_vm_types": ["t3.micro", "t3.small", "t3.medium"]
}
```

> **Key Insight**: You separate "data" from "policy"

&nbsp;

### Dynamic Update Workflow
Eample: 
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Security Team   │    │     CI/CD       │    │ Artifact Store  │
│ Updates JSON    │───▶│   Packages      │───▶│   (S3/GCS/     │
│                 │    │   Bundle        │    │   Registry)     │
└─────────────────┘    └─────────────────┘    └─────────┬───────┘
                                                        │
                                                        │ Pulls Bundle
                                                        ▼
                                              ┌─────────────────┐
                                              │  OPA Instance   │
                                              │ (Auto-reloads)  │
                                              └─────────────────┘
```

### Bundle Structure
**Bundle = Policy(.rego) + Data.json**
> **Key Insight**: what pulls the bundle? -- It the OPS config.json file

&nbsp;
### OPA Configuration
 OPS config.json file is the one that pulls the data from the *** Artifact Store ***
<summary>OPA Server Configuration</summary>

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

**VM Usage:**
```bash
# Write config.yaml (or .json) on disk
# Start OPA with:
opa run --server --config-file=/etc/opa/config.yaml
# or
opa run --server --config-file=config.yaml
```

**Kubernetes - Sidecar:**
- Put config in ConfigMap
- Mount into OPA container
- Pass `--config-file=/config/config.yaml`



---

&nbsp;

## 💻 Code Examples

### File Structure Examples

#### Basic Structure
```
|---- policy.rego
|---- input.json
|---- policy_test.rego
```

#### With Dynamic Data
```
|---- policy.rego
|---- input.json
|---- data.json
|---- policy_test.rego
```

### Policy Examples

<details>
<summary>Basic Policy (Static Data)</summary>

**policy.rego**
```javascript
package policy // this can be anything

default allow = false

allow {
    input.user.roles[_] = "admin" // "admin" is data
}
```

**input.json**
```json
{
  "user": {
    "username": "munna",
    "role": ["QA", "DEV", "Admin"]
  }
}
```

</details>

<details>
<summary>Dynamic Data Policy</summary>

**policy.rego**
```javascript
package policy // this can be anything

default allow = false

allow {
    some r
    input.user.roles[r] = data.allowed_role[_]
}
```

**data.json**
```json
{
  "allowed_role": ["admin", "superuser"]
}
```

**input.json**
```json
{
  "user": {
    "username": "munna",
    "role": ["QA", "DEV", "Admin"]
  }
}
```

</details>

---

### Logic Operations

#### OR Logic (Multiple Allow Statements)
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
> If **any one** of those checks passes, it would Allow.

#### AND Logic (Single Allow Statement)
```rego
package policy

default allow = false

allow if {
    input.user.role[_] == "admin"
    input.user.role[_] == "superadmin"
}
```

---

## 🧪 what is test.rego?

### Test File Structure

<details>
<summary>Complete Test Example</summary>

**policy_test.rego**
```javascript
package policy_test

import data.policy.allow

test_allow_is_false_by_default {
    not allow
}

test_allow_if_admin {
    allow with input as {
        "user": {
            "role": ["admin"]
        }
    }
    allow with input as {
        "user": {
            "role": ["superuser"]
        }
    }
}

test_allow_if_not_admin {
    not allow with input as {
        "user": {
            "role": ["Dev"]
        }
    }
    not allow with input as {
        "user": {
            "role": ["QA"]
        }
    }
}
```

</details>

### Testing Commands

```bash
opa fmt       # → check formatting
opa check     # → validate syntax
opa test      # → run unit tests (*_test.rego)
```

> **Note**: `test.rego` is not used in OPA as services/server. It's only used in the pipeline for TEST confidence purposes. It would be in the rego repo and runs in the CI process.

---
🔧 OPA CLI Commands 
```
# Format Rego code (fix style issues)
opa fmt policy.rego

# Check for syntax errors
opa check policy.rego

# Run unit tests (any *_test.rego files)
opa test .

# Run tests with verbose output
opa test -v .

# Run tests with coverage
opa test -c .

# Evaluate a rule against some input
opa eval -i input.json -d policy.rego "data.policy.allow"

# Pretty output
opa eval --format pretty -i input.json -d policy.rego "data"

# Show partial evaluation (handy for debugging rules)
opa eval --partial -i input.json -d policy.rego "data.policy.allow"

# Start OPA server on default port 8181
opa run --server

# Start OPA server with a config file
opa run --server --config-file=config.yaml

# Change listen address/port
opa run --server --addr=:8182

# Run OPA with a policy and data file loaded
opa run -d policy.rego -d data.json --server

# Check bundle validity
opa exec --bundle ./bundle.tar.gz --eval "data"

# Print OPA version
opa version

# Run OPA REPL (interactive shell)
opa run

# Get help for any command
opa --help
```


---

## Rego modules and imports

### What are Rego modules?

Every .rego file is a module.

A module has:

- A package name (namespace)
- Rules (your logic)
- Optional imports

### Why use modules?
- Split logic into separate files.
- Create libraries of reusable helpers (string functions, common checks).
- Avoid one giant policy.rego file.

### syntax 
```
import data.utils.is_public_get
```

```
import data.utils as u

allow { u.is_public_get }
```

---
## External lookups
- Recommended to bundle it and then send it to OPA. "

- There is an option to call - do a GET request with a **"HTTP send"** with the below code, but it is not at all recommended. That is an option, but don't do it.

```
resp := http.send({"method":"GET","url": data.endpoints.prices, "timeout": "1s"})
resp.status == 200
prices := json.unmarshal(resp.body)
```
### Why it’s discouraged:
- Latency & flakiness on the hot path.
- Non-deterministic decisions (bad for audit).
- Often disabled by capabilities, not available in WASM, and awkward with partial eval.


> ### Rule of thumb:
> - Runtime decisions should be pure: decision = f(input, policy, data) with data already local.
> - If data changes often, automate the feed (bundle pipeline or sync job).
---

&nbsp;

## OPA Bench
It measures how fast your policy runs (how many nanoseconds per evaluation)
> **Key Point**: Think of it like a stopwatch for your Rego rule.

### Why do we need it?
- In pipelines, speed usually doesn’t matter (Terraform plan check can take seconds).
- But in runtime use cases (sidecar, admission control, API auth), your policy may run thousands of times per second.
- You want to be sure your rule isn’t slow.

```
opa bench -i input.json -d policy.rego "data.policy.allow"
```
> **opa test** → Does my policy logic work?
> **opa bench** → How fast is my policy logic?
---
&nbsp;
## ☸️ Kubernetes Admission Control (OPA Gatekeeper)

- Deployed as a set of pods + CRDs inside your cluster
- Enforces policies (written in Rego) when resources are created/updated via the API server.

&nbsp;
### ConstraintTemplate
- Defines the Rego logic (policy “class”).
- Includes a schema for parameters.

```
rego: |
        package k8srequiredlabels

        violation[{"msg": msg}] {
          required := {l | l := input.parameters.labels[_]}     # from Constraint
          provided := {l | l := input.review.object.metadata.labels[l]}
          missing := required - provided
          count(missing) > 0
          msg := sprintf("Missing required labels: %v", [missing])
        }
```

```
kubectl apply -f constrainttemplate.yaml.
```
> This willl create a New CRD(Custom Resource Definition) - It’s how Kubernetes lets you extend its API with new resource types.

### Constraint
- An instance of a ConstraintTemplate (policy “object”).
- Sets the actual parameters and which resources it applies to.

```
kubectl apply -f constraint.yaml.
```

 
### Admission Control
- When you run kubectl apply, the API server sends an AdmissionReview request to Gatekeeper.
- Gatekeeper runs the resource against relevant Constraints.


### Audit Mode
- Gatekeeper runs a periodic scan of the whole cluste and Reports violations for existing resources
- ```status.violations``` of each Constraint.

**Purpose**: Runs before objects are persisted in the Kubernetes API server.
**Function**: Validates/denies resource changes (CREATE/UPDATE/DELETE of Pods, Deployments, CRDs, etc.).

> **Key Point**: It's not about traffic into your app, it's about what gets into etcd as a cluster resource.

> **Think**: "Guardrails for cluster config/state."


---

&nbsp;

## 🔧 Terraform Integration

### Terraform Library Functions

<details>
<summary>Essential Helper Functions</summary>

```rego
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
```

</details>

---

&nbsp;

Pipeline 

git clone terrraform repo
Terraform plan
terraform plan -out=plan.tfplan 
terraform show -json plan.tfplan > plan.json 
opa insall
git clode rego repo (or) cp s3://
unzip 
opa eval -i plan.json -d policy.rego -d data.json "data.policy.allow"

&nbsp;

## OPA Flow in CI/CD
- dev push the code to git hub 
- trigger the CI pipeline (runs - ops test) - pass/fail
- PR is raied - PR validation (CI) - Run *** opa eval *** -- this will block merage the code to main
- CD pipeline (post-merge, before apply) - Run *** opa eval *** agin -- this will block deployemnt 


---

&nbsp;

## List mapping / filtering
```
is_admin {
  roles := ["dev", "qa", "admin"]
  roles[_] == "admin"
}
```

Transform a list of strings to uppercase:
```
upper_roles[upper(r)] {
  r := ["dev", "qa", "admin"][_]
}
```

&nbsp;

## Conversion (string ↔ number)
Convert string to number:
```
num := to_number("42")   # 42
```

Convert number to string:

```
s := sprintf("%v", [123]) 
```

&nbsp;

## String manipulation
Check prefix/suffix:
```
startswith("team-ops", "team-")   # true
endswith("report.csv", ".csv")    # true
```

Split and join:
```
parts := split("a,b,c", ",")    # ["a","b","c"]
joined := concat("-", parts)    # "a-b-c"
```

Substring search:
```
contains("kubernetes", "net")   # true
```

Regex match:
```
regex.match("^[a-z]+$", "hello")  # true
```
&nbsp;

## Data lookups / mapping

Check if a VM type is allowed:
```
allowed := {"t2.micro", "m5.large"}
vm := "t2.micro"

allow { allowed[vm] }
```

Map names to costs:
```
prices := {
  "t2.micro": 10,
  "m5.large": 50,
}

cost := prices["m5.large"]   # 50
```
&nbsp;

## Comprehensions (filter + map in one go)

Collect all create actions from a plan:
```
creates := {rc.address |
  rc := input.resource_changes[_]
  rc.change.actions[_] == "create"
}
```

---
## Azure VM list
- ***General***: Standard_A2, Standard_D4s_v3
- ***Memory-Optimized***: Standard_E8s_v4, Standard_M64s
- ***GPU***: Standard_NC6
- ***Storage-Optimized***: Standard_L8s
- ***HPC***: Standard_H16

---
&nbsp;

## 🎯 Quick Reference

### Essential Commands
```bash
# Generate Terraform plan JSON
terraform plan -out=plan.tfplan
terraform show -json plan.tfplan > plan.json

# OPA Evaluation
opa eval --input plan.json --data policies 'data.terraform.policy.deny'

# OPA Server
opa run --server --config-file=config.yaml
```

&nbsp;

### Key Concepts
- **Bundle**: Policy(.rego) + Data.json
- **Input**: Always JSON format
- **Data Sources**: External reference data
- **Testing**: Unit tests with `*_test.rego` files
- **Deployment**: Pipeline vs Server modes