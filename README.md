# Wiz IaC Scanning Test (HCP Terraform Integration)

## Objective
This repository validates Wiz IaC scanning integration with HCP Terraform Run Tasks, focusing on:

- Detection of insecure Terraform configurations
- Enforcement of blocking controls
- Behavior of exception handling (ignore rules)

---

## Architecture Overview

GitHub Repo → HCP Terraform Workspace → Wiz Run Task → Policy Evaluation → Block/Pass

---

## Test Setup

### Components
- HCP Terraform (workspace connected to GitHub repo)
- Wiz IaC Run Task
- Terraform (no cloud provider required)
- Kubernetes Terraform resources (used for static analysis)

---

## Test Configuration

The main.tf file contains intentionally insecure Kubernetes configurations to trigger Wiz findings.

### Misconfigurations included:
- Missing hostAliases
- Running containers as root (run_as_user = 0)
- Privileged containers
- Allowing privilege escalation
- Use of latest image tag
- Missing resource limits
- Host network enabled

---

## Example Findings

Wiz detects multiple IaC violations such as:

- Host Aliases Undefined Or Empty (HIGH)
- Privileged Container (HIGH)
- Run as Root User (HIGH)
- Host Network Enabled (MED/HIGH)
- Missing Resource Limits (MED)
- Unpinned Image Tag (latest) (LOW/MED)

---

## Expected Behavior

When misconfigurations exist:

- Terraform plan succeeds
- Wiz Run Task executes
- Findings are detected
- Run is blocked (Post-plan FAILED)

Flow:
Plan → Wiz Scan → Findings → FAIL → Apply Blocked

---

## Example Output

Post-plan failed
Run Task: wiz-runtask-test
Status: Failed

Wiz scan detected:
- 0 critical
- 4 high
- 0 medium
- 0 low findings

---

## Exception Handling Testing

### 1. Global Ignore Rule
- Suppresses findings across all workspaces
- Works but introduces blast radius risk

### 2. Scoped Ignore Rule
Tested using:
- Repository filter
- File path
- Resource name

Limitations:
- Limited granularity
- Not always reliable

### 3. Tag-based Scoping
- Tested using Kubernetes labels
- Inconsistent behavior in IaC context

---

## Key Findings

- Wiz Run Task successfully blocks Terraform runs
- Exception handling is not granular enough
- Ignore rules are primarily global or weakly scoped
- No reliable inline suppression (unlike Checkov)

---

## Key Insight

Wiz IaC scanning provides strong enforcement capabilities, but exception handling introduces potential blast-radius risks due to limited scoping controls.

---

## Conclusion

This PoC validates that:

- Wiz IaC scanning integrates with HCP Terraform
- Policy violations can block deployments
- Exception handling requires careful governance

---

## Next Steps

- Define a safe exception model
- Evaluate policy scoping strategies
- Consider combining Wiz with CI/CD controls (e.g., GitHub Actions)

---

## Author

Hanief – Cloud Security Engineer
