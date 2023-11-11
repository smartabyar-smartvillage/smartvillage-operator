
# Become a Red Hat Developer

- Get started for free at [developers.redhat.com](https://developers.redhat.com/). 
- Click [ Start building apps ] in the top left corner. 
- Click [ Developer Sandbox for Red Hat OpenShift ](https://developers.redhat.com/developer-sandbox). 
- Click [ Start your sandbox for free ]. 
- Click [ Register for a Red Hat account ]. 
- You can simply use your existing GitHub, GMail, or Microsoft account
- Click [ DevSandbox ] to login. 

# Download the oc command

- Click the [ ? ] button in the top right of the Developer Sandbox. 
- Click [ Command line tools ]. 
- Click the download link for your operating system. 
- You'll need to extract the `oc` command and place it in your path, for example in a `bin` directory in your `$HOME` directory. 

# Log into the OpenShift Developer Sandbox in your terminal

- Click your username in the top right corner of the Developer Sandbox. 
- Click [ Copy login command ]. 
- Click [ DevSandbox ]. 
- Click [ Display token ]. 
- Copy the line to the clipboard that looks like this `oc login --token=sha256~DFEbJlutndAeZi4VABjJyfXeov1C3ZtSJypVq4DJvFg --server=https://api.sandbox-m2.ll9k.p1.openshiftapps.com:6443`. 
- Paste the command into your terminal to log in to the Developer Sandbox in the terminal. 

## Grant the default service account edit privileges in your namespace. 

```bash
oc create rolebinding default-edit --clusterrole=edit --serviceaccount=$(oc get project -o jsonpath={.items[0].metadata.name}):default
```

- Run a debug pod that can run Ansible and OpenShift

```bash
oc debug --image quay.io/computateorg/smartvillage-operator
```

- Load the name of your namespace into an environment variable. 

```bash
export OPENSHIFT_NAMESPACE=$(kubectl get project -o jsonpath={.items[0].metadata.name})
```

## Install the MongoDB NOSQL Database in the OpenShift Developer Sandbox

```bash
ansible-playbook apply-edgemongodb.yaml \
  -e ansible_operator_meta_namespace=$(kubectl get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=kustomize/overlays/sandbox/edgemongodbs/mongodb/edgemongodb.yaml
```

## Install the Orion-LD Context Broker in the OpenShift Developer Sandbox

```bash
ansible-playbook apply-orionldcontextbroker.yaml \
  -e ansible_operator_meta_namespace=$(kubectl get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=kustomize/overlays/sandbox/orionldcontextbrokers/orion-ld/orionldcontextbroker.yaml
```

## Install the RabbitMQ in the OpenShift Developer Sandbox

```bash
ansible-playbook apply-edgerabbitmq.yaml \
  -e ansible_operator_meta_namespace=$(kubectl get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=kustomize/overlays/sandbox/edgerabbitmqs/rabbitmq/edgerabbitmq.yaml
```

## Install zookeeper in the OpenShift Developer Sandbox

```bash
ansible-playbook apply-edgezookeeper.yaml \
  -e ansible_operator_meta_namespace=$(kubectl get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=kustomize/overlays/sandbox/edgezookeepers/default/edgezookeeper.yaml
```

## Install solr in the OpenShift Developer Sandbox

```bash
oc apply -k kustomize/overlays/sandbox/edgesolrs/default/configmaps/

ansible-playbook apply-edgesolr.yaml \
  -e ansible_operator_meta_namespace=$(kubectl get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=kustomize/overlays/sandbox/edgesolrs/default/edgesolrs/default/edgesolr.yaml
```

## Install the IoT Agent JSON in the OpenShift Developer Sandbox

```bash
ansible-playbook apply-iotagentjson.yaml \
  -e ansible_operator_meta_namespace=$(kubectl get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=kustomize/overlays/sandbox/iotagentjsons/iotagent-json/iotagentjson.yaml
```

## Install postgres in the OpenShift Developer Sandbox

```bash

ansible-playbook apply-edgepostgres.yaml \
  -e ansible_operator_meta_namespace=$(kubectl get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=kustomize/overlays/sandbox/edgepostgress/postgres/edgepostgres.yaml
```

## Install the SmartaByarSmartVillage in the OpenShift Developer Sandbox

```bash
ansible-playbook apply-smartabyarsmartvillage.yaml \
  -e ansible_operator_meta_namespace=$(kubectl get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=kustomize/overlays/sandbox/smartabyarsmartvillages/smartvillage/smartabyarsmartvillage.yaml
```

## Install the Traffic Flow Observed JSON in the OpenShift Developer Sandbox

```bash
ansible-playbook apply-trafficflowobserved.yaml \
  -e ansible_operator_meta_namespace=$(kubectl get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=kustomize/overlays/sandbox/trafficflowobserveds/sweden-veberod-1-lakaregatan-ne/trafficflowobserved.yaml
```

- [Install Red Hat MicroShift following the official documentation here](https://access.redhat.com/documentation/en-us/red_hat_build_of_microshift). 
- Make sure you have the `oc` command in your terminal after installation of MicroShift. 
- Make sure microshift is running: `systemctl status microshift`. 
- Watch the logs for MicroShift if you find any problems: `journalctl -fu microshift`
- Make sure your computer has an actual ethernet connection and not WIFI for MicroShift to work. 
