
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
oc create role default-edit-rolebindings --verb=get,list,watch,create,update,patch,delete --resource=roles,rolebindings
oc create rolebinding default-edit-rolebindings --role=default-edit-rolebindings --serviceaccount=$(oc get project -o jsonpath={.items[0].metadata.name}):default
```

- Run a debug pod that can run Ansible and OpenShift

```bash
oc debug --image quay.io/computateorg/smartvillage-operator
```

- Load the name of your namespace into an environment variable. 

```bash
export OPENSHIFT_NAMESPACE=$(oc get project -o jsonpath={.items[0].metadata.name})
```

## Install the MongoDB NOSQL Database in the OpenShift Developer Sandbox

```bash
ansible-playbook apply-edgemongodb.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=kustomize/overlays/sandbox/edgemongodbs/mongodb/edgemongodb.yaml

oc get pod -l app.kubernetes.io/instance=mongodb -w
oc logs -l app.kubernetes.io/instance=mongodb -f
```

## Install the RabbitMQ in the OpenShift Developer Sandbox

```bash
ansible-playbook apply-edgerabbitmq.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=kustomize/overlays/sandbox/edgerabbitmqs/rabbitmq/edgerabbitmq.yaml

oc get pod -l app.kubernetes.io/name=rabbitmq -w
oc logs -l app.kubernetes.io/name=rabbitmq -f
```

## Install the Orion-LD Context Broker in the OpenShift Developer Sandbox

```bash
ansible-playbook apply-orionldcontextbroker.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=kustomize/overlays/sandbox/orionldcontextbrokers/orion-ld/orionldcontextbroker.yaml

oc get pod -l app.kubernetes.io/instance=orion-ld -w
oc logs -l app.kubernetes.io/instance=orion-ld -f
```

## Install the IoT Agent JSON in the OpenShift Developer Sandbox

```bash
ansible-playbook apply-iotagentjson.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=kustomize/overlays/sandbox/iotagentjsons/iotagent-json/iotagentjson.yaml
```

## Install zookeeper in the OpenShift Developer Sandbox

```bash
ansible-playbook apply-edgezookeeper.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=kustomize/overlays/sandbox/edgezookeepers/default/edgezookeeper.yaml
```

## Install solr in the OpenShift Developer Sandbox

```bash
oc apply -k kustomize/overlays/sandbox/edgesolrs/default/configmaps/

ansible-playbook apply-edgesolr.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=kustomize/overlays/sandbox/edgesolrs/default/edgesolrs/default/edgesolr.yaml
```

## Install postgres in the OpenShift Developer Sandbox

```bash
oc create configmap smartvillage-db-create --from-file ~/.local/src/smartabyar-smartvillage/src/main/resources/sql/db-create.sql

ansible-playbook apply-edgepostgres.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=kustomize/overlays/sandbox/edgepostgress/postgres/edgepostgres.yaml
```

## Install the SmartaByarSmartVillage in the OpenShift Developer Sandbox

```bash
ansible-playbook apply-smartabyarsmartvillage.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=kustomize/overlays/sandbox/smartabyarsmartvillages/smartvillage/smartabyarsmartvillage.yaml
```

## Install the Traffic Flow Observed JSON in the OpenShift Developer Sandbox

```bash
ansible-playbook apply-trafficflowobserved.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=kustomize/overlays/sandbox/trafficflowobserveds/sweden-veberod-1-lakaregatan-ne/trafficflowobserved.yaml
```

```bash
ansible-playbook apply-trafficflowobserved.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=kustomize/overlays/sandbox/trafficflowobserveds/sweden-veberod-1-sjobovagen-se/trafficflowobserved.yaml
```

## Install the Crowd Flow Observed JSON in the OpenShift Developer Sandbox

```bash
ansible-playbook apply-crowdflowobserved.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=kustomize/overlays/sandbox/crowdflowobserveds/sweden-veberod-1-sjobovagen-se-dorrodsvagen-sw/crowdflowobserved.yaml
```

```bash
ansible-playbook apply-crowdflowobserved.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=kustomize/overlays/sandbox/crowdflowobserveds/sweden-veberod-1-dorrodsvagen-ne-sjobovagen-se/crowdflowobserved.yaml
```

```bash
ansible-playbook apply-crowdflowobserved.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=kustomize/overlays/sandbox/crowdflowobserveds/sweden-veberod-1-sjobovagen-nw-lakaregatan-ne/crowdflowobserved.yaml
```

```bash
ansible-playbook apply-crowdflowobserved.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=kustomize/overlays/sandbox/crowdflowobserveds/sweden-veberod-1-lakaregatan-sw-sjobovagen-nw/crowdflowobserved.yaml
```

```bash
ansible-playbook apply-crowdflowobserved.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=kustomize/overlays/sandbox/crowdflowobserveds/sweden-veberod-1-sjobovagen-se-dorrodsvagen-sw/crowdflowobserved.yaml
```
