
# Clone the Smart Village Operator

Create a directory for the Smart Village Operator source code: 


```bash
mkdir ~/.local/src
```

Clone the Smart Village Operator source code: 

```bash
git clone git@github.com:computate-org/smartvillage-operator.git ~/.local/src/smartvillage-operator
```

# Install prerequisite helm binary

Download the latest [helm binary here](https://github.com/helm/helm/releases), I recommend the Linux amd64 binary if you are on a Linux x86_64 system. 

```bash
mkdir -p ~/.local/opt/helm/
tar xvf ~/Downloads/helm-v3.13.2-linux-amd64.tar.gz --strip-components=1 -C ~/.local/opt/helm/
cp ~/.local/opt/helm/helm ~/.local/bin/
```

# Install prerequisite python libraries

```bash
pip3 install pika paho-mqtt
```

## Deploy the required namespaces, subscriptions, SCCs, and CRDs for the Smart Village Operator

```bash
oc apply -k kustomize/overlays/openshift-local/base/
```

## Install the MongoDB NOSQL Database in the OpenShift Developer openshift-local

```bash
ansible-playbook ~/.local/src/smartvillage-operator/apply-edgemongodb.yaml \
  -e crd_path=~/.local/src/smartvillage-operator/kustomize/overlays/openshift-local/ansible/edgemongodbs/mongodb/edgemongodb.yaml

oc -n mongodb get pod -l app.kubernetes.io/instance=mongodb -w
oc -n mongodb logs -l app.kubernetes.io/instance=mongodb -f
```

## Install the RabbitMQ in the OpenShift Developer openshift-local

```bash
ansible-playbook ~/.local/src/smartvillage-operator/apply-edgerabbitmq.yaml \
  -e crd_path=~/.local/src/smartvillage-operator/kustomize/overlays/openshift-local/ansible/edgerabbitmqs/rabbitmq/edgerabbitmq.yaml

oc -n rabbitmq get pod -l app.kubernetes.io/name=rabbitmq -w
oc -n rabbitmq logs -l app.kubernetes.io/name=rabbitmq -f
```

## Install postgres in the OpenShift Developer openshift-local

```bash
oc -n postgres create configmap smartvillage-db-create --from-file ~/.local/src/smartabyar-smartvillage/src/main/resources/sql/db-create.sql

ansible-playbook ~/.local/src/smartvillage-operator/apply-edgepostgres.yaml \
  -e crd_path=~/.local/src/smartvillage-operator/kustomize/overlays/openshift-local/ansible/edgepostgress/postgres/edgepostgres.yaml
```

You should see a play recap that has failed. 
This is expected because the postgres pod is barely getting created. 
The final tasks in the playbook expect the database create SQL scripts to be run for the smartvillage application in postgres.  
Retry the playbook once the postgres pod is running. 

```bash
ansible-playbook ~/.local/src/smartvillage-operator/apply-edgepostgres.yaml \
  -e crd_path=~/.local/src/smartvillage-operator/kustomize/overlays/openshift-local/ansible/edgepostgress/postgres/edgepostgres.yaml

oc -n postgres get pod -l postgres-operator.crunchydata.com/cluster=postgres -w
oc -n postgres logs -l postgres-operator.crunchydata.com/cluster=postgres -f
```

## Install the scorpiobroker Context Broker in the OpenShift Developer openshift-local

### Copy the kafka secrets to the `scorpiobroker` namespace. 

```bash
oc -n postgres get secret postgres-pguser-scorpiobroker -o json \
    | jq 'del(.metadata["namespace","creationTimestamp","resourceVersion","selfLink","uid","ownerReferences"])' \
    | oc -n scorpiobroker apply -f -

```bash
ansible-playbook ~/.local/src/smartvillage-operator/apply-scorpiobroker.yaml \
  -e crd_path=~/.local/src/smartvillage-operator/kustomize/overlays/openshift-local/ansible/scorpiobrokers/scorpiobroker/scorpiobroker.yaml

oc -n scorpiobroker get pod -l app.kubernetes.io/name=scorpiobroker -w
oc -n scorpiobroker logs -l app.kubernetes.io/name=scorpiobroker -f
```

## Install the IoT Agent JSON in the OpenShift Developer openshift-local

```bash
ansible-playbook ~/.local/src/smartvillage-operator/apply-iotagentjson.yaml \
  -e crd_path=~/.local/src/smartvillage-operator/kustomize/overlays/openshift-local/ansible/iotagentjsons/iotagent-json/iotagentjson.yaml

oc -n iotagent get pod -l app.kubernetes.io/instance=iotagent-json -w
oc -n iotagent logs -l app.kubernetes.io/instance=iotagent-json -f
```

## Install zookeeper in the OpenShift Developer openshift-local

```bash
ansible-playbook ~/.local/src/smartvillage-operator/apply-edgezookeeper.yaml \
  -e crd_path=~/.local/src/smartvillage-operator/kustomize/overlays/openshift-local/ansible/edgezookeepers/default/edgezookeeper.yaml

oc -n zookeeper get pod -l app=zookeeper -w
oc -n zookeeper logs -l app=zookeeper -f
```

## Install solr in the OpenShift Developer openshift-local

```bash
oc apply -k kustomize/overlays/openshift-local/ansible/edgesolrs/solr/configmaps/

ansible-playbook ~/.local/src/smartvillage-operator/apply-edgesolr.yaml \
  -e crd_path=~/.local/src/smartvillage-operator/kustomize/overlays/openshift-local/ansible/edgesolrs/solr/edgesolrs/solr/edgesolr.yaml

oc -n solr get pod -l app=solr -w
oc -n solr logs -l app=solr -f
```

You should see a play recap that has failed. 
This is expected because the solr pod is barely getting created. 
The final tasks in the playbook expect the solr pod to be running to upload the computate configset, and create a smartvillage solr collection based on the computate configset. 
Retry the playbook once the solr pod is running. 

```bash
ansible-playbook ~/.local/src/smartvillage-operator/apply-edgesolr.yaml \
  -e crd_path=~/.local/src/smartvillage-operator/kustomize/overlays/openshift-local/ansible/edgesolrs/solr/edgesolrs/solr/edgesolr.yaml

oc -n solr get pod -l app=solr -w
oc -n solr logs -l app=solr -f
```

## Copy secrets

### Copy the `smartvillage` secrets to the `smartvillage` namespace. 

```bash
oc -n postgres get secret postgres-pguser-smartvillage -o json \
    | jq 'del(.metadata["namespace","creationTimestamp","resourceVersion","selfLink","uid","ownerReferences"])' \
    | oc -n smartvillage apply -f -
oc -n kafka get secret smartvillage-kafka -o json \
    | jq 'del(.metadata["namespace","creationTimestamp","resourceVersion","selfLink","uid","ownerReferences"])' \
    | oc -n smartvillage apply -f -
oc -n kafka get secret default-cluster-ca-cert -o json \
    | jq 'del(.metadata["namespace","creationTimestamp","resourceVersion","selfLink","uid","ownerReferences"])' \
    | oc -n smartvillage apply -f -
```

## Install the SmartaByarSmartVillage in the OpenShift Developer openshift-local

```bash
ansible-playbook ~/.local/src/smartvillage-operator/apply-smartabyarsmartvillage.yaml \
  -e crd_path=~/.local/src/smartvillage-operator/kustomize/overlays/openshift-local/ansible/smartabyarsmartvillages/smartvillage/smartabyarsmartvillage.yaml

oc -n smartvillage get events -w
oc -n smartvillage get pods -w
```

## Install the Traffic Simulation JSON in the OpenShift Developer openshift-local

```bash
ansible-playbook ~/.local/src/smartvillage-operator/apply-trafficsimulation.yaml -e enable_dev_nodeports=true \
  -e crd_path=~/.local/src/smartvillage-operator/kustomize/overlays/openshift-local/ansible/trafficsimulations/veberod-intersection-1/trafficsimulation.yaml
```

## Install the SmartTrafficLight JSON in the OpenShift Developer openshift-local

```bash
ansible-playbook ~/.local/src/smartvillage-operator/apply-smarttrafficlight.yaml -e enable_dev_nodeports=true \
  -e crd_path=~/.local/src/smartvillage-operator/kustomize/overlays/openshift-local/ansible/smarttrafficlights/veberod-intersection-1/smarttrafficlight.yaml
```

## Install the Traffic Flow Observed JSON in the OpenShift Developer openshift-local

```bash
ansible-playbook ~/.local/src/smartvillage-operator/apply-trafficflowobserved.yaml -e enable_dev_nodeports=true \
  -e crd_path=~/.local/src/smartvillage-operator/kustomize/overlays/openshift-local/ansible/trafficflowobserveds/sweden-veberod-1-lakaregatan-ne/trafficflowobserved.yaml
```

```bash
ansible-playbook ~/.local/src/smartvillage-operator/apply-trafficflowobserved.yaml -e enable_dev_nodeports=true \
  -e crd_path=~/.local/src/smartvillage-operator/kustomize/overlays/openshift-local/ansible/trafficflowobserveds/sweden-veberod-1-sjobovagen-se/trafficflowobserved.yaml
```

## Install the Crowd Flow Observed JSON in the OpenShift Developer openshift-local

```bash
ansible-playbook ~/.local/src/smartvillage-operator/apply-crowdflowobserved.yaml -e enable_dev_nodeports=true \
  -e crd_path=~/.local/src/smartvillage-operator/kustomize/overlays/openshift-local/ansible/crowdflowobserveds/sweden-veberod-1-sjobovagen-se-dorrodsvagen-sw/crowdflowobserved.yaml
```

```bash
ansible-playbook ~/.local/src/smartvillage-operator/apply-crowdflowobserved.yaml -e enable_dev_nodeports=true \
  -e crd_path=~/.local/src/smartvillage-operator/kustomize/overlays/openshift-local/ansible/crowdflowobserveds/sweden-veberod-1-dorrodsvagen-ne-sjobovagen-se/crowdflowobserved.yaml
```

```bash
ansible-playbook ~/.local/src/smartvillage-operator/apply-crowdflowobserved.yaml -e enable_dev_nodeports=true \
  -e crd_path=~/.local/src/smartvillage-operator/kustomize/overlays/openshift-local/ansible/crowdflowobserveds/sweden-veberod-1-sjobovagen-nw-lakaregatan-ne/crowdflowobserved.yaml
```

```bash
ansible-playbook ~/.local/src/smartvillage-operator/apply-crowdflowobserved.yaml -e enable_dev_nodeports=true \
  -e crd_path=~/.local/src/smartvillage-operator/kustomize/overlays/openshift-local/ansible/crowdflowobserveds/sweden-veberod-1-lakaregatan-sw-sjobovagen-nw/crowdflowobserved.yaml
```
