# Kubernetes on Vagrant

If you're interested to run a Kubernetes cluster on your local machine, using Vagrant is
one of the best options to get as close as a production-grade experience.

This repo is running on top of the following technologies:

- Kubernetes v1.24
- Vagrant v2.2.19
- containerd v1.6.4

## How to run?

To use this repo, and to get the most out of it, first install direnv from the following
link:

<https://direnv.net/#basic-installation>

Then allow the env of the current directory to be applied using:

```bash
direnv allow .
```

The last step is to run the cluster using: `vagrant up`

Now, you can simply interact with your cluster: `k cluster-info`.

**NOTE**: If you don't want to install **direnv**, you can simply run this command as a
workaround:

```bash
export KUBECONFIG=.kube/config
```
