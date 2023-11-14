
# Clone the Smart Village Operator

Create a directory for the Smart Village Operator source code: 


```bash
mkdir ~/.local/src
```

Clone the Smart Village Operator source code: 

```bash
git clone git@github.com:computate-org/smartvillage-operator.git ~/.local/src/smartvillage-operator
```

## Deploy the operator into the smartvillage-operator-manager namespace

```bash
cd ~/.local/src/smartvillage-operator
make deploy
```

## View the logs of the operator

```bash
oc logs -n smartvillage-operator-system deployment/smartvillage-operator-controller-manager -f
```

## Deploy the required namespaces, subscriptions, SCCs, and CRDs for the Smart Village Operator

```bash
oc create -k kustomize/overlays/openshift-local/app/base/
```

## Deploy PostgreSQL relational database to OpenShift Local

```bash
oc create -k kustomize/overlays/openshift-local/app/app/edgepostgress/
```

Watch for pods and events in the `postgres` namespace: 

```bash
oc -n postgres get events -w
oc -n postgres get pods -w
```

## Deploy Apache Solr to OpenShift Local

```bash
oc create -k kustomize/overlays/openshift-local/app/app/edgesolrs/
```

Watch for pods and events in the `solr` namespace: 

```bash
oc -n solr get events -w
oc -n solr get pods -w
```

## Deploy AMQ Streams Kafka to OpenShift Local

```bash
oc create -k kustomize/overlays/openshift-local/app/app/edgekafkas/
```

Watch for pods and events in the `kafka` namespace: 

```bash
oc -n kafka get events -w
oc -n kafka get pods -w
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

## Deploy Smarta Byar Smart Village to OpenShift Local

```bash
oc create -k kustomize/overlays/openshift-local/app/app/smartabyarsmartvillages/
```

Watch for pods and events in the `smartvillage` namespace: 

```bash
oc -n smartvillage get events -w
oc -n smartvillage get pods -w
```

## Install the Traffic Flow Observed JSON in the OpenShift Developer Sandbox

```bash
ansible-playbook apply-trafficflowobserved.yaml -e enable_dev_nodeports=true \
  -e ansible_operator_meta_namespace=$(kubectl get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=kustomize/overlays/openshift-local/app/trafficflowobserveds/sweden-veberod-1-lakaregatan-ne/trafficflowobserved.yaml
```

```bash
ansible-playbook apply-trafficflowobserved.yaml -e enable_dev_nodeports=true \
  -e ansible_operator_meta_namespace=$(kubectl get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=kustomize/overlays/openshift-local/app/trafficflowobserveds/sweden-veberod-1-sjobovagen-se/trafficflowobserved.yaml
```

## Install the Crowd Flow Observed JSON in the OpenShift Developer Sandbox

```bash
ansible-playbook apply-crowdflowobserved.yaml -e enable_dev_nodeports=true \
  -e ansible_operator_meta_namespace=$(kubectl get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=kustomize/overlays/openshift-local/app/crowdflowobserveds/sweden-veberod-1-sjobovagen-se-dorrodsvagen-sw/crowdflowobserved.yaml
```

```bash
ansible-playbook apply-crowdflowobserved.yaml -e enable_dev_nodeports=true \
  -e ansible_operator_meta_namespace=$(kubectl get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=kustomize/overlays/openshift-local/app/crowdflowobserveds/sweden-veberod-1-dorrodsvagen-ne-sjobovagen-se/crowdflowobserved.yaml
```

```bash
ansible-playbook apply-crowdflowobserved.yaml -e enable_dev_nodeports=true \
  -e ansible_operator_meta_namespace=$(kubectl get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=kustomize/overlays/openshift-local/app/crowdflowobserveds/sweden-veberod-1-sjobovagen-nw-lakaregatan-ne/crowdflowobserved.yaml
```

```bash
ansible-playbook apply-crowdflowobserved.yaml -e enable_dev_nodeports=true \
  -e ansible_operator_meta_namespace=$(kubectl get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=kustomize/overlays/openshift-local/app/crowdflowobserveds/sweden-veberod-1-lakaregatan-sw-sjobovagen-nw/crowdflowobserved.yaml
```

```bash
ansible-playbook apply-crowdflowobserved.yaml -e enable_dev_nodeports=true \
  -e ansible_operator_meta_namespace=$(kubectl get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=kustomize/overlays/openshift-local/app/crowdflowobserveds/sweden-veberod-1-sjobovagen-se-dorrodsvagen-sw/crowdflowobserved.yaml
```
