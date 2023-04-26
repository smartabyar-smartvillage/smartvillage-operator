
# Prerequisites

## Install kubernetes.core Ansible Galaxy Collection

```bash
ansible-galaxy collection install kubernetes.core
```

### Upgrade kubernetes.core Ansible Galaxy Collection if necessary

```bash
ansible-galaxy collection install kubernetes.core -U
```

# How the operator was initialized

```bash
operator-sdk init --plugins=ansible --domain computate.org
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

## Initialize SmartaByarSmartVillage model

```bash
operator-sdk create api --group smartvillage --version v1 --kind SmartaByarSmartVillage --generate-role
ansible-playbook write-smart-data-model-templates.yaml -e ENTITY_TYPE=SmartaByarSmartVillage
```

## Initialize OrionLDContextBroker model

```bash
operator-sdk create api --group smartvillage --version v1 --kind OrionLDContextBroker --generate-role
ansible-playbook write-smart-data-model-templates.yaml -e ENTITY_TYPE=OrionLDContextBroker
```

# Build and deploy the operator to an OpenShift environment
```bash
oc login ...
make docker-build docker-push deploy
```

