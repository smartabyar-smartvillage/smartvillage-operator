
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
oc create -k kustomize/overlays/openshift-local/base/
```

## Deploy PostgreSQL relational database to OpenShift Local

```bash
oc create -k kustomize/overlays/openshift-local/app/edgepostgress/
```

Watch for pods and events in the `postgres` namespace: 

```bash
oc -n postgres get events -w
oc -n postgres get pods -w
```

## Deploy Apache Solr to OpenShift Local

```bash
oc create -k kustomize/overlays/openshift-local/app/edgesolrs/
```

Watch for pods and events in the `solr` namespace: 

```bash
oc -n solr get events -w
oc -n solr get pods -w
```

## Deploy AMQ Streams Kafka to OpenShift Local

```bash
oc create -k kustomize/overlays/openshift-local/app/edgekafkas/
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
oc create -k kustomize/overlays/openshift-local/app/smartabyarsmartvillages/
```

Watch for pods and events in the `smartvillage` namespace: 

```bash
oc -n smartvillage get events -w
oc -n smartvillage get pods -w
```
