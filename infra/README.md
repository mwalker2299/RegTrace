# Infrastructure

## Current State

This repository **does not currently deploy to AWS or any cloud environment**.

Infrastructure-as-code and cloud deployment are **planned future milestones**, but are intentionally deferred while the core application architecture and feature slices are being developed.

At present, infrastructure concerns focus on:

* Reproducible local development
* Containerized builds
* CI validation pipelines
* Deployment readiness via Docker images

The goal is to establish **production-aligned engineering practices early**, even before introducing cloud infrastructure.

---

## Environments

We do **not** currently maintain separate deployed environments such as:

* `dev`
* `staging`
* `production`

Instead, we use a containerized staging analogue within CI.

### CI Staging Analogue (Docker Compose)

End-to-end (E2E) tests run against a full Docker Compose stack that includes:

* API service
* Web application
* Database
* Reverse proxy

This environment serves as a **pre-merge integration gate** and acts as a functional equivalent of a staging environment.

Key characteristics:

* Containers are built from the same Dockerfiles intended for deployment.
* Services communicate over real networks (no mocks).
* Health checks and smoke tests validate system startup.
* E2E tests exercise real authentication and API flows.

Pull requests must pass this stage before merging.

---

## Merge & Release Model

The workflow is intentionally simple:

1. Pull Request opened
2. CI runs:

   * formatting, linting, type checks
   * unit and integration tests
   * container build validation
   * Docker Compose E2E tests (staging analogue)
3. Successful PR merge to `trunk`
4. Merge triggers publication of new container images

This ensures that `trunk` always represents a deployable artifact, even though automated cloud deployment is not yet enabled.

---

## Future Direction

Planned infrastructure evolution includes:

* AWS deployment
* Environment separation (`dev`, `staging`, `prod`)
* Infrastructure as Code (Terraform)
* Managed database and secrets management
* Automated deployment pipelines

The current Docker-based workflow is designed so that introducing cloud infrastructure later requires minimal architectural change.
