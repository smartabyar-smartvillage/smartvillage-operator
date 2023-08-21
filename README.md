
# Clone the Smart Village Operator

Create a directory for the Smart Village Operator source code: 


```bash
mkdir ~/.local/src
```

Clone the Smart Village Operator source code: 

```bash
git clone git@github.com:computate-org/smartvillage-operator.git ~/.local/src/smartvillage-operator
```

# Install Ansible dependencies on Linux

```bash
pkcon install -y git
pkcon install -y python3
pkcon install -y python3-pip
pip install virtualenv openshift jmespath
```

## Install the latest Python and setup a new Python virtualenv

This step might be virtualenv-3 for you. 

```bash
virtualenv ~/python

source ~/python/bin/activate
echo "source ~/python/bin/activate" | tee -a ~/.bashrc
source ~/.bashrc
```

## Install the latest Ansible

```bash
pip install setuptools_rust wheel
pip install --upgrade pip
pip install ansible
```

# Install Smart Village Operator on Kubernetes Kind

## Install Kubernetes Kind

See the documentation [here](https://kind.sigs.k8s.io/docs/user/quick-start/). 

```bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.18.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/bin/kind
```

Create a cluster with ingress available on port 8080 and 8043

```bash
echo '
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 8080
    protocol: TCP
  - containerPort: 443
    hostPort: 8043
    protocol: TCP
' > /tmp/kind-cluster.yaml
```

Create the cluster on Red Hat Enterprise Linux: 

```bash
systemd-run --user --scope --property=Delegate=yes kind create cluster --config=/tmp/kind-cluster.yaml
```

Create the cluster on Microsoft Windows:

```bash
kind create cluster --config=/tmp/kind-cluster.yaml
```

Apply Contour components for Ingress

```bash
kubectl apply -f https://projectcontour.io/quickstart/contour.yaml
kubectl patch daemonsets -n projectcontour envoy -p '{"spec":{"template":{"spec":{"nodeSelector":{"ingress-ready":"true"},"tolerations":[{"key":"node-role.kubernetes.io/control-plane","operator":"Equal","effect":"NoSchedule"},{"key":"node-role.kubernetes.io/master","operator":"Equal","effect":"NoSchedule"}]}}}}'
```

## ERROR: failed to create cluster: running kind with rootless provider requires setting systemd property "Delegate=yes"

If you get the error above, follow the instructions [here](https://kind.sigs.k8s.io/docs/user/rootless/). 
You may not need to modify `/etc/default/grub`. 

After following these instructions, *reboot your computer*. 

## Install kubectl


```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/bin/
```

Test that you can connect to your kubernetes cluster

```bash
kubectl get pod -A
```

## Install the Operator SDK

```bash
export ARCH=$(case $(uname -m) in x86_64) echo -n amd64 ;; aarch64) echo -n arm64 ;; *) echo -n $(uname -m) ;; esac)
export OS=$(uname | awk '{print tolower($0)}')
export OPERATOR_SDK_DL_URL=https://github.com/operator-framework/operator-sdk/releases/download/v1.28.1
curl -LO ${OPERATOR_SDK_DL_URL}/operator-sdk_${OS}_${ARCH}
gpg --keyserver keyserver.ubuntu.com --recv-keys 052996E2A20B5C7E
curl -LO ${OPERATOR_SDK_DL_URL}/checksums.txt
curl -LO ${OPERATOR_SDK_DL_URL}/checksums.txt.asc
gpg -u "Operator SDK (release) <cncf-operator-sdk@cncf.io>" --verify checksums.txt.asc
grep operator-sdk_${OS}_${ARCH} checksums.txt | sha256sum -c -
sudo chmod +x operator-sdk_${OS}_${ARCH} && sudo mv operator-sdk_${OS}_${ARCH} /usr/bin/operator-sdk
```


Install operators to cluster

```bash
operator-sdk olm install
```


## Create a new namespace in kubernetes for the Smart Village Operator and application. 

```bash
kubectl create namespace smartvillage
```

## Configure the new namespace as the current context
```bash
kubectl config set-context --current --namespace=smartvillage
```

## Install Red Hat Pull Secret

Create a free Red Hat Developer account, and download your Red Hat OpenShift pull secret [https://console.redhat.com/openshift/create/local](https://console.redhat.com/openshift/create/local). 

```bash
kubectl create secret generic redhat-reg --from-file=.dockerconfigjson="$HOME/Downloads/pull-secret" --type=kubernetes.io/dockerconfigjson
```

## Install the required AMQ Broker Operator bundle

```bash
cd ~/.local/src/smartvillage-operator
kubectl apply -k kustomize/operators/amq-broker-in-namespace/
kubectl patch serviceaccount amq-broker-controller-manager -p '{"imagePullSecrets": [{"name": "redhat-reg"}]}'
kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "redhat-reg"}]}'
```

## Deploy the operator into the namespace

```bash
cd ~/.local/src/smartvillage-operator
make deploy
```

## Deploy the FIWARE components into the namespace

This will install the following applications: 

- An Edge version of the Red Hat AMQ Broker for AMQP and MQTT protocols
- A FIWARE Orion-LD Context Broker for smart device entity data
- An IoT Agent JSON for receiving AMQP and MQTT messages and updating the Context Broker
- The Smarta Byar Smart Village Sync microservice, for sending context broker subscription data to the Smart Village application. 

```bash
cd ~/.local/src/smartvillage-operator
kubectl apply -k kustomize/overlays/kubernetes/
```

## View the events of the deployment

```bash
kubectl get events -w
kubectl get pod
```

## View the logs of the operator

```bash
kubectl logs -n smartvillage-operator-system deployment/smartvillage-operator-controller-manager -f
```

## Expose the orion-ld context broker as Ingress

Create an HTTP Proxy with CORS for orion-ld at localhost

```bash
echo '
apiVersion: projectcontour.io/v1
kind: HTTPProxy
metadata:
  name: orion-ld
spec:
  virtualhost:
    fqdn: localhost
    corsPolicy:
        allowCredentials: true
        allowOrigin:
          - "*" # allows any origin
        allowMethods:
          - GET
          - POST
          - OPTIONS
        allowHeaders:
          - authorization
          - cache-control
          - fiware-service
          - fiware-servicepath
        exposeHeaders:
          - Content-Length
          - Content-Range
        maxAge: "10m" # preflight requests can be cached for 10 minutes.
  routes:
    - conditions:
      - prefix: /
      services:
        - name: orion-ld
          port: 1026
' > /tmp/contour-cors.yaml

kubectl apply -f /tmp/contour-cors.yaml
```

Expose an Ingress for orion-ld

```bash
echo '
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: orion-ld
spec:
  rules:
    - host: localhost
      http:
        paths:
          - backend:
              service: 
                name: orion-ld
                port:
                  number: 1026
            path: /orion-ld
            pathType: Prefix
' > /tmp/ingress.yaml

oc apply -f /tmp/ingress.yaml
```

## Optional: Deploy sample Smart Data Models into the namespace

Some sample TrafficFlowObserved Smart Data Models are provided, 
as well as an Orion-LD Smart Village Sync microservice. 
These will automatically be sent by MQTT to the IoT Agent JSON, 
and into the Orion-LD Context broker. A subscription is set up
that will publish to the Orion-LD Smart Village Sync service. 
The Orion-LD Smart Village Sync is for publishing securely 
device entity data to the Smart Village platform in the cloud. 

```bash
cd ~/.local/src/smartvillage-operator
kubectl apply -k kustomize/samples/kubernetes/
```

Test the orion-ld entity API to see the smart data models in the Context Broker: 

```bash
kubectl run --image=registry.access.redhat.com/ubi8/ubi --rm -it -- bash
yum install -y jq
curl http://orion-ld:1026/v2/entities -H "Fiware-Service: smarttrafficlights" -H "Fiware-ServicePath: /Sweden/Veberod/CityCenter" | jq
```

# Installation on Red Hat MicroShift

- [Install Red Hat MicroShift following the official documentation here](https://access.redhat.com/documentation/en-us/red_hat_build_of_microshift). 
- Make sure you have the `oc` command in your terminal after installation of MicroShift. 
- Make sure microshift is running: `systemctl status microshift`. 
- Watch the logs for MicroShift if you find any problems: `journalctl -fu microshift`
- Make sure your computer has an actual ethernet connection and not WIFI for MicroShift to work. 

## Create a new namespace in MicroShift for the Smart Village Operator and application. 

```bash
oc create namespace smartvillage
```

## Configure the new namespace as the current context
```bash
oc config set-context --current --namespace=smartvillage
```

## Install the required AMQ Broker Operator bundle

```bash
cd ~/.local/src/smartvillage-operator
oc apply -k kustomize/operators/amq-broker-in-namespace/
```

## Deploy the operator into the namespace

```bash
cd ~/.local/src/smartvillage-operator
make deploy
```

## View the logs of the operator

```bash
oc logs -n smartvillage-operator-system deployment/smartvillage-operator-controller-manager -f
```

## Deploy the FIWARE components into the namespace

This will install the following applications: 

- An Edge version of the Red Hat AMQ Broker for AMQP and MQTT protocols
- A FIWARE Orion-LD Context Broker for smart device entity data
- An IoT Agent JSON for receiving AMQP and MQTT messages and updating the Context Broker
- The Smarta Byar Smart Village Sync microservice, for sending context broker subscription data to the Smart Village application. 

```bash
cd ~/.local/src/smartvillage-operator
oc apply -k kustomize/overlays/microshift/
```

## Optional: Deploy sample Smart Data Models into the namespace

Some sample TrafficFlowObserved Smart Data Models are provided, 
as well as an Orion-LD Smart Village Sync microservice. 
These will automatically be sent by MQTT to the IoT Agent JSON, 
and into the Orion-LD Context broker. A subscription is set up
that will publish to the Orion-LD Smart Village Sync service. 
The Orion-LD Smart Village Sync is for publishing securely 
device entity data to the Smart Village platform in the cloud. 

```bash
cd ~/.local/src/smartvillage-operator
oc apply -k kustomize/samples/microshift/
```

### Configure SSO for the Orion-LD Smart Village Sync

To connect successfully to the Smart Village platform, 
you will need a valid CLIENT_ID and CLIENT_SECRET configured to a 
Red Hat Single Sign On server, which is provided by the Smart Village app. 

Create a keycloak-client-secret-smartvillage secret on MicroShift. 

```yaml
kind: Secret
apiVersion: v1
metadata:
  name: keycloak-client-secret-smartvillage
stringData:
  CLIENT_ID: smartvillage
  CLIENT_SECRET: ...
type: Opaque
```

# Install Smart Village Operator CRDS without deploying the operator

You can run the same ansible roles that the operator uses without deploying the operator. 
You will need to set the following ansible variables: 

- ` -e crd_path=~/.local/src/smartabyar-smartvillage/openshift/kustomize/overlays/nerc-ocp-prod/smartabyarsmartvillages/smartvillage/smartabyarsmartvillage.yaml` to point to the `SmartaByarSmartVillage` instance you wish to deploy. 
` ` -e ansible_operator_meta_namespace=smart-village-faeeb6c` the namespace where you wish to deploy the resources. 

For example: 

`ansible-playbook apply-smartabyarsmartvillage.yaml -e crd_path=~/.local/src/smartabyar-smartvillage/openshift/kustomize/overlays/nerc-ocp-prod/smartabyarsmartvillages/smartvillage/smartabyarsmartvillage.yaml -e ansible_operator_meta_namespace=smart-village-faeeb6c`

# How the operator was initialized

```bash
operator-sdk init --plugins=ansible --domain computate.org
```

# Build and deploy the operator to an OpenShift environment
```bash
oc login ...
make docker-build docker-push deploy && oc -n smartvillage-operator-system delete pod -l 'control-plane=controller-manager'
```

## Initialize TrafficFlowObserved model

```bash
operator-sdk create api --group smartvillage --version v1 --kind TrafficFlowObserved --generate-role
ansible-playbook write-smart-data-model-templates.yaml -e ENTITY_TYPE=TrafficFlowObserved
```

## Initialize CrowdFlowObserved model

```bash
operator-sdk create api --group smartvillage --version v1 --kind CrowdFlowObserved --generate-role
ansible-playbook write-smart-data-model-templates.yaml -e ENTITY_TYPE=CrowdFlowObserved
```

## Initialize SmartTrafficLight model

```bash
operator-sdk create api --group smartvillage --version v1 --kind SmartTrafficLight --generate-role
ansible-playbook write-smart-data-model-templates.yaml -e ENTITY_TYPE=SmartTrafficLight
```

## Initialize OrionLDContextBroker model

```bash
operator-sdk create api --group smartvillage --version v1 --kind OrionLDContextBroker --generate-role
ansible-playbook write-smart-data-model-templates.yaml -e ENTITY_TYPE=OrionLDContextBroker
```

## Initialize ScorpioBroker model

```bash
operator-sdk create api --group smartvillage --version v1 --kind ScorpioBroker --generate-role
ansible-playbook write-smart-data-model-templates.yaml -e ENTITY_TYPE=ScorpioBroker
```

## Initialize IoTAgentJson model

```bash
operator-sdk create api --group smartvillage --version v1 --kind IoTAgentJson --generate-role
ansible-playbook write-smart-data-model-templates.yaml -e ENTITY_TYPE=IoTAgentJson
```

## Initialize EdgeAmqBroker model

```bash
operator-sdk create api --group smartvillage --version v1 --kind EdgeAmqBroker --generate-role
ansible-playbook write-smart-data-model-templates.yaml -e ENTITY_TYPE=EdgeAmqBroker
```

## Initialize SmartaByarSmartVillage model

```bash
operator-sdk create api --group smartvillage --version v1 --kind SmartaByarSmartVillage --generate-role
ansible-playbook write-smart-data-model-templates.yaml -e ENTITY_TYPE=SmartaByarSmartVillage
```

## Initialize TrafficSimulation model

```bash
operator-sdk create api --group smartvillage --version v1 --kind TrafficSimulation --generate-role
ansible-playbook write-smart-data-model-templates.yaml -e ENTITY_TYPE=TrafficSimulation
```

- Edit the newly generated vars values file: `smartvillage-operator/roles/smart-data-model-vars/vars/TrafficSimulation.yaml`. 
- Re-run the playbook to regenerate the latest model. 

```bash
ansible-playbook write-smart-data-model-templates.yaml -e ENTITY_TYPE=TrafficSimulation
```

- Increment the VERSION in the smartvillage-operator/Makefile
- Build and deploy the new version of the operator

```bash
make docker-build docker-push deploy && oc -n smartvillage-operator-system delete pod -l 'control-plane=controller-manager'
```

- View the logs of the operator

```bash
kubectl logs -n smartvillage-operator-system deployment/smartvillage-operator-controller-manager -f
```

## Initialize EdgeMongoDB model

```bash
operator-sdk create api --group smartvillage --version v1 --kind EdgeMongoDB --generate-role
ansible-playbook write-smart-data-model-templates.yaml -e ENTITY_TYPE=EdgeMongoDB
```

- Edit the newly generated vars values file: `smartvillage-operator/roles/smart-data-model-vars/vars/EdgeMongoDB.yaml`. 
- Re-run the playbook to regenerate the latest model. 

```bash
ansible-playbook write-smart-data-model-templates.yaml -e ENTITY_TYPE=EdgeMongoDB
```

- Increment the VERSION in the smartvillage-operator/Makefile
- Build and deploy the new version of the operator

```bash
make docker-build docker-push deploy && oc -n smartvillage-operator-system delete pod -l 'control-plane=controller-manager'
```

- View the logs of the operator

```bash
oc logs -n smartvillage-operator-system deployment/smartvillage-operator-controller-manager -f
```

## Initialize EdgePostgres model

```bash
operator-sdk create api --group smartvillage --version v1 --kind EdgePostgres --generate-role
ansible-playbook write-smart-data-model-templates.yaml -e ENTITY_TYPE=EdgePostgres
```

- Edit the newly generated vars values file: `smartvillage-operator/roles/smart-data-model-vars/vars/EdgePostgres.yaml`. 
- Re-run the playbook to regenerate the latest model. 

```bash
ansible-playbook write-smart-data-model-templates.yaml -e ENTITY_TYPE=EdgePostgres
```

- Increment the VERSION in the smartvillage-operator/Makefile
- Build and deploy the new version of the operator

```bash
make docker-build docker-push deploy && oc -n smartvillage-operator-system delete pod -l 'control-plane=controller-manager'
```

- View the logs of the operator

```bash
oc logs -n smartvillage-operator-system deployment/smartvillage-operator-controller-manager -f
```

## Initialize EdgeKafka model

```bash
operator-sdk create api --group smartvillage --version v1 --kind EdgeKafka --generate-role
ansible-playbook write-smart-data-model-templates.yaml -e ENTITY_TYPE=EdgeKafka
```

- Edit the newly generated vars values file: `smartvillage-operator/roles/smart-data-model-vars/vars/EdgeKafka.yaml`. 
- Re-run the playbook to regenerate the latest model. 

```bash
ansible-playbook write-smart-data-model-templates.yaml -e ENTITY_TYPE=EdgeKafka
```

- Increment the VERSION in the smartvillage-operator/Makefile
- Build and deploy the new version of the operator

```bash
make docker-build docker-push deploy && oc -n smartvillage-operator-system delete pod -l 'control-plane=controller-manager'
```

- View the logs of the operator

```bash
oc logs -n smartvillage-operator-system deployment/smartvillage-operator-controller-manager -f
```

# Install the latest AMQ Broker on MicroShift manually

Follow the instructions in the docs [Deploying AMQ Broker on OpenShift Container Platform using the AMQ Broker Operator](https://access.redhat.com/documentation/en-us/red_hat_amq_broker/7.11/html/deploying_amq_broker_on_openshift/deploying-broker-on-ocp-using-operator_broker-ocp)


```bash
cd ~/Downloads/amq-broker-operator-7.11.0-ocp-install-examples/deploy/
oc create namespace smartvillage
oc config set-context --current --namespace=smartvillage
oc apply -f service_account.yaml
oc apply -f role.yaml
oc apply -f role_binding.yaml
oc apply -f election_role.yaml
oc apply -f election_role_binding.yaml
oc apply -f crds/broker_activemqartemis_crd.yaml
oc apply -f crds/broker_activemqartemisaddress_crd.yaml
oc apply -f crds/broker_activemqartemisscaledown_crd.yaml
oc apply -f crds/broker_activemqartemissecurity_crd.yaml
oc apply -f operator.yaml
```

# Install kubectl command

https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/

# OpenShift Local Deployment

- Install the Edge AMQ Broker for MQTT and AMQP messaging. 

```bash
oc apply -k ~/.local/src/smartabyar-smartvillage/openshift/kustomize/overlays/local/edgeamqbrokers/
# Finishes in about 32 seconds
```

- Install the Orion-LD Context Broker and MongoDB, to receive device entity data and activate NGSI-LD APIs. 

```bash
oc apply -k ~/.local/src/smartabyar-smartvillage/openshift/kustomize/overlays/local/orionldcontextbrokers/
# Finishes in about 51 seconds
```

- Install the IoT Agent JSON, to receive MQTT or AMQP device data as JSON. 

```bash
oc apply -k ~/.local/src/smartabyar-smartvillage/openshift/kustomize/overlays/local/iotagentjsons/
# Finishes in about 15 seconds
```

- Install the Smarta Byar Smart Village platform, to receive context broker subscription data and enable data science APIs. 

```bash
oc apply -k ~/.local/src/smartabyar-smartvillage/openshift/kustomize/overlays/local/smartabyarsmartvillages/
# Finishes in about 240 seconds
```

- Install a TrafficFlowObserved Smart Data Model entity, to integrate it with the Iot Agent, Context Broker, and Smart Village application. 

```bash
oc apply -k ~/.local/src/smartabyar-smartvillage/openshift/kustomize/overlays/local/trafficflowobserveds/
# Finishes in about 15 seconds
```

# Operator Developer Prerequisites

## Install kubernetes.core Ansible Galaxy Collection

```bash
pip3 install kubernetes jmespath paho-mqtt
ansible-galaxy collection install kubernetes.core ansible.utils
```

### Upgrade kubernetes.core Ansible Galaxy Collection if necessary

```bash
ansible-galaxy collection install kubernetes.core -U
```

