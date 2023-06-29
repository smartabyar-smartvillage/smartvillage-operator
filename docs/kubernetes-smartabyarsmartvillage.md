
# Install helm

Follow these docs: https://helm.sh/docs/intro/install/

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

## Install Apache Solr Operator

```bash
helm repo add apache-solr https://solr.apache.org/charts
kubectl create -f https://solr.apache.org/operator/downloads/crds/v0.6.0/all-with-dependencies.yaml
helm install solr-operator apache-solr/solr-operator --version 0.6.0
```

## Patch strimzi-cluster-operator service account to pull from Red Hat Registry

```bash
kubectl patch serviceaccount strimzi-cluster-operator -p '{"imagePullSecrets": [{"name": "redhat-reg"}]}'
kubectl delete pod -l name:strimzi-cluster-operator
```

## Patch smartvillage-kafka-zookeeper service account to pull from Red Hat Registry

```bash
kubectl patch serviceaccount smartvillage-kafka-zookeeper -p '{"imagePullSecrets": [{"name": "redhat-reg"}]}'
kubectl delete pod -l strimzi.io/name=smartvillage-kafka-zookeeper
```

## Create minikube NodePort tunnels

In 4 different terminals, create tunnels to the following nodeports: 

```bash
minikube -n smartvillage service site-nodeport --url
```

```bash
minikube -n smartvillage service postgres-nodeport --url
```

```bash
minikube -n smartvillage service zookeeper-nodeport --url
```

```bash
minikube -n smartvillage service solr-nodeport --url
```

```bash
minikube -n smartvillage service smartvillage-kafka-kafka-0 --url
```

