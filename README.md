# Awesome-GitOps

[![Awesome](https://awesome.re/badge.svg)](https://awesome.re)

A curated list for awesome GitOps resources inspired by [@sindresorhus' awesome](https://github.com/sindresorhus/awesome)

## What is GitOps?

GitOps is a way to do [Continuous Delivery](https://en.wikipedia.org/wiki/Continuous_delivery). It works by using [Git](https://git-scm.com/) as a single source of truth for [declarative infrastructure and applications](https://en.wikipedia.org/wiki/Infrastructure_as_code), together with tools ensuring the actual state of infrastructure and applications converges towards the target state declared in Git. With Git at the center of your delivery pipelines, developers can make pull requests to accelerate and simplify application deployments and operations tasks to your infrastructure or container-orchestration system (e.g. [Kubernetes](https://kubernetes.io/)).

## Why is GitOps awesome?

It [increases developer productivity](https://www.weave.works/technologies/gitops/#key-benefits), [enhances developer experience](https://www.weave.works/technologies/gitops/#key-benefits), [improves stability](https://www.weave.works/technologies/gitops/#key-benefits), all while having [higher reliability](https://www.weave.works/technologies/gitops/#key-benefits), [higher consistency](https://www.weave.works/technologies/gitops/#key-benefits) and [stronger security guarantees](https://www.weave.works/technologies/gitops/#key-benefits).

Modern software development practices _assume_ support for reviewing changes, tracking history, comparing versions, and rolling back bad updates; GitOps applies the same tooling and engineering perspective to managing the systems that deliver direct business value to users and customers.

- [Awesome-GitOps](#Awesome-GitOps)
  - [Tools](#Tools)
  - [Ancillary Tools](#Ancillary-Tools)
  - [Tutorials](#Tutorials)

## Background

- [Operations by pull request](https://www.weave.works/blog/gitops-operations-by-pull-request) - a blog entry about how GitOps came about at Weaveworks

## Tools

- [Flux](https://github.com/weaveworks/flux) - The GitOps Kubernetes operator
- [Flagger](https://github.com/weaveworks/flagger) - Progressive delivery Kubernetes operator (Canary, A/B testing and Blue/Green deployments automation)
- [Weave Cloud](https://www.weave.works/product/cloud/) - GitOps experience, workflows and dashboard for your cluster(s) (commercial product from Weaveworks)

## Ancillary Tools

### Secrets
- [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets) - One-way encrypted Secrets 
- [SOPS](https://github.com/mozilla/sops) - Secrets OPerationS

## Tutorials

- [Managing Helm releases the GitOps way](https://github.com/fluxcd/helm-operator-get-started) - Flux and Helm Operator tutorial
- [Automating Istio canary deployments with GitOps](https://github.com/stefanprodan/gitops-istio) - Progressive Delivery tutorial with Flagger, Flux, Helm Operator and Istio
- [Managing a multi-tenant cluster with GitOps](https://github.com/stefanprodan/fluxcd-multi-tenancy) - Flux and Kustomize tutorial
