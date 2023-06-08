
# Prerequisites

## Install kubernetes.core Ansible Galaxy Collection

```bash
pip3 install kubernetes jmespath paho-mqtt
ansible-galaxy collection install kubernetes.core ansible.utils
```

### Upgrade kubernetes.core Ansible Galaxy Collection if necessary

```bash
ansible-galaxy collection install kubernetes.core -U
```

# Clone the Smart Village Operator

Create a directory for the Smart Village Operator source code: 


```bash
mkdir ~/.local/src
```

Clone the Smart Village Operator source code: 

```bash
git clone git@github.com:computate-org/smartvillage-operator.git ~/.local/src/smartvillage-operator
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
oc apply -k kustomize/bundles/amq-broker/
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
make docker-build docker-push deploy
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

