
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

- In the terminal, run these commands to grant access to your pods and other namespace resources

```bash
SERVICE_ACCOUNT=python
oc create rolebinding $SERVICE_ACCOUNT-edit --clusterrole=edit --serviceaccount=$(oc get project -o jsonpath={.items[0].metadata.name}):$SERVICE_ACCOUNT
oc create role $SERVICE_ACCOUNT-edit-rolebindings --verb=get,list,watch,create,update,patch,delete --resource=roles,rolebindings
oc create rolebinding $SERVICE_ACCOUNT-edit-rolebindings --role=$SERVICE_ACCOUNT-edit-rolebindings --serviceaccount=$(oc get project -o jsonpath={.items[0].metadata.name}):$SERVICE_ACCOUNT
```

# Create a new OpenShift AI Minimal Python Workbench

- In the Red Hat OpenShift Developer Sandbox, click on the apps button with 9 squares at the top, and select "Red Hat OpenShift Data Science". 
- Log in with [ Dev Sandbox ]
- Click [ Data Science Projects ]
- Click on your data science project, but make sure it's running first
- Click [ Create workbench ]
  - Name: python
  - Image selection: Minimal Python
  - Click [ Create workbench ]
- When your workbench is running after a minute, click on the "Open" link
- Log in with [ Dev Sandbox ]

## Set up git credentials

```bash
git config --global user.email '...'
git config --global user.name '...'
git config --global credential.helper store
```

# Install prerequisite helm binary

Download the latest [helm binary here](https://github.com/helm/helm/releases), I recommend the Linux amd64 binary if you are on a Linux x86_64 system. 

```bash
curl https://get.helm.sh/helm-v3.13.2-linux-amd64.tar.gz -o /tmp/helm-v3.13.2-linux-amd64.tar.gz
mkdir -p ~/.local/opt/helm/ ~/.local/bin/
tar xvf /tmp/helm-v3.13.2-linux-amd64.tar.gz --strip-components=1 -C ~/.local/opt/helm/
cp ~/.local/opt/helm/helm ~/.local/bin/
```

## Set up a new Python virtualenv

```bash
pip install virtualenv
virtualenv ~/python
echo "source ~/python/bin/activate" | tee -a ~/.bashrc
source ~/.bashrc
```

## Install the latest Ansible

```bash
pip install setuptools_rust wheel
pip install --upgrade pip
pip install ansible kubernetes openshift jmespath --upgrade
```

# Setup the project

## Setup the directory for the project and clone the git repository into it 

```bash
git clone https://github.com/computate-org/smartabyar-smartvillage.git ~/smartabyar-smartvillage
```

## Setup a directory for Ansible roles and clone the Ansible role to install the project

```bash
mkdir -p ~/.ansible/roles/
git clone https://github.com/computate-org/computate_project.git ~/.ansible/roles/computate.computate_project
```

## Run the Ansible Playbook to install the project

```bash
ansible-playbook ~/smartabyar-smartvillage/install.yml -e SYSTEMD_ENABLED=false
```

## Install the MongoDB NOSQL Database in the OpenShift Developer Sandbox

```bash
ansible-playbook ~/smartvillage-operator/apply-edgemongodb.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=~/smartvillage-operator/kustomize/overlays/sandbox/edgemongodbs/mongodb/edgemongodb.yaml

oc get pod -l app.kubernetes.io/instance=mongodb -w
oc logs -l app.kubernetes.io/instance=mongodb -f
```

## Install the RabbitMQ in the OpenShift Developer Sandbox

```bash
ansible-playbook ~/smartvillage-operator/apply-edgerabbitmq.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=~/smartvillage-operator/kustomize/overlays/sandbox/edgerabbitmqs/rabbitmq/edgerabbitmq.yaml

oc get pod -l app.kubernetes.io/name=rabbitmq -w
oc logs -l app.kubernetes.io/name=rabbitmq -f
```

## Install postgres in the OpenShift Developer Sandbox

```bash
oc create configmap smartvillage-db-create --from-file ~/smartabyar-smartvillage/src/main/resources/sql/db-create.sql

ansible-playbook ~/smartvillage-operator/apply-edgepostgres.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=~/smartvillage-operator/kustomize/overlays/sandbox/edgepostgress/postgres/edgepostgres.yaml
```

You should see a play recap that has failed. 
This is expected because the postgres pod is barely getting created. 
The final tasks in the playbook expect the database create SQL scripts to be run for the smartvillage application in postgres.  
Retry the playbook once the postgres pod is running. 

```bash
ansible-playbook ~/smartvillage-operator/apply-edgepostgres.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=~/smartvillage-operator/kustomize/overlays/sandbox/edgepostgress/postgres/edgepostgres.yaml

oc get pod -l app=postgres -w
oc logs -l app=postgres -f
```

## Install the scorpiobroker Context Broker in the OpenShift Developer Sandbox

```bash
ansible-playbook ~/smartvillage-operator/apply-scorpiobroker.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=~/smartvillage-operator/kustomize/overlays/sandbox/scorpiobrokers/scorpiobroker/scorpiobroker.yaml

oc -n orion-ld get pod -l app=scorpiobroker -w
oc -n orion-ld logs -l app=scorpiobroker -f
```

## Install the IoT Agent JSON in the OpenShift Developer Sandbox

```bash
ansible-playbook ~/smartvillage-operator/apply-iotagentjson.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=~/smartvillage-operator/kustomize/overlays/sandbox/iotagentjsons/iotagent-json/iotagentjson.yaml

oc get pod -l app.kubernetes.io/instance=iotagent-json -w
oc logs -l app.kubernetes.io/instance=iotagent-json -f
```

## Install zookeeper in the OpenShift Developer Sandbox

```bash
ansible-playbook ~/smartvillage-operator/apply-edgezookeeper.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=~/smartvillage-operator/kustomize/overlays/sandbox/edgezookeepers/default/edgezookeeper.yaml

oc get pod -l app=zookeeper -w
oc logs -l app=zookeeper -f
```

## Install solr in the OpenShift Developer Sandbox

```bash
oc apply -k ~/smartvillage-operator/kustomize/overlays/sandbox/edgesolrs/default/configmaps/

ansible-playbook ~/smartvillage-operator/apply-edgesolr.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=~/smartvillage-operator/kustomize/overlays/sandbox/edgesolrs/default/edgesolrs/default/edgesolr.yaml

oc get pod -l app=solr -w
oc logs -l app=solr -f
```

## Install the SmartaByarSmartVillage in the OpenShift Developer Sandbox

```bash
ansible-playbook ~/smartvillage-operator/apply-smartabyarsmartvillage.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=~/smartvillage-operator/kustomize/overlays/sandbox/smartabyarsmartvillages/smartvillage/smartabyarsmartvillage.yaml
```

## Install the Traffic Flow Observed JSON in the OpenShift Developer Sandbox

```bash
ansible-playbook ~/smartvillage-operator/apply-trafficflowobserved.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=~/smartvillage-operator/kustomize/overlays/sandbox/trafficflowobserveds/sweden-veberod-1-lakaregatan-ne/trafficflowobserved.yaml
```

```bash
ansible-playbook ~/smartvillage-operator/apply-trafficflowobserved.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=~/smartvillage-operator/kustomize/overlays/sandbox/trafficflowobserveds/sweden-veberod-1-sjobovagen-se/trafficflowobserved.yaml
```

## Install the Crowd Flow Observed JSON in the OpenShift Developer Sandbox

```bash
ansible-playbook ~/smartvillage-operator/apply-crowdflowobserved.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=~/smartvillage-operator/kustomize/overlays/sandbox/crowdflowobserveds/sweden-veberod-1-sjobovagen-se-dorrodsvagen-sw/crowdflowobserved.yaml
```

```bash
ansible-playbook ~/smartvillage-operator/apply-crowdflowobserved.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=~/smartvillage-operator/kustomize/overlays/sandbox/crowdflowobserveds/sweden-veberod-1-dorrodsvagen-ne-sjobovagen-se/crowdflowobserved.yaml
```

```bash
ansible-playbook ~/smartvillage-operator/apply-crowdflowobserved.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=~/smartvillage-operator/kustomize/overlays/sandbox/crowdflowobserveds/sweden-veberod-1-sjobovagen-nw-lakaregatan-ne/crowdflowobserved.yaml
```

```bash
ansible-playbook ~/smartvillage-operator/apply-crowdflowobserved.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=~/smartvillage-operator/kustomize/overlays/sandbox/crowdflowobserveds/sweden-veberod-1-lakaregatan-sw-sjobovagen-nw/crowdflowobserved.yaml
```

```bash
ansible-playbook ~/smartvillage-operator/apply-crowdflowobserved.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=~/smartvillage-operator/kustomize/overlays/sandbox/crowdflowobserveds/sweden-veberod-1-sjobovagen-se-dorrodsvagen-sw/crowdflowobserved.yaml
```
