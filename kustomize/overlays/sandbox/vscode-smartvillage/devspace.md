

## Grant the default service account edit privileges in your namespace. 

```bash
SERVICE_ACCOUNT=$(oc get sa -l controller.devfile.io/devworkspace_name=quarkus-quickstart  --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')
oc create rolebinding $SERVICE_ACCOUNT-edit --clusterrole=edit --serviceaccount=$(oc get project -o jsonpath={.items[0].metadata.name}):$SERVICE_ACCOUNT
oc create role $SERVICE_ACCOUNT-edit-rolebindings --verb=get,list,watch,create,update,patch,delete --resource=roles,rolebindings
oc create rolebinding $SERVICE_ACCOUNT-edit-rolebindings --role=$SERVICE_ACCOUNT-edit-rolebindings --serviceaccount=$(oc get project -o jsonpath={.items[0].metadata.name}):$SERVICE_ACCOUNT
```

## Set up a new Python virtualenv

```bash
virtualenv /projects/python
source /projects/python/bin/activate
```

## Install the latest Ansible

```bash
pip install setuptools_rust wheel
pip install --upgrade pip
pip install ansible kubernetes openshift jmespath --upgrade
```

## Update the Ansible Galaxy collections for kubernetes.core

```bash
ansible-galaxy collection install kubernetes.core -U
```

# Setup the project

## Setup the directory for the project and clone the git repository into it 

```bash
git clone https://github.com/computate-org/smartabyar-smartvillage.git /projects/smartabyar-smartvillage
```

- Right-click on the Explorer and select "Add Folder to Workspace..."
- Select /projects/smartabyar-smartvillage/
- Click [ OK ]

```bash
ansible-playbook /projects/smartabyar-smartvillage/install.yml -e SYSTEMD_ENABLED=false
```

## Install the MongoDB NOSQL Database in the OpenShift Developer Sandbox

```bash
ansible-playbook /projects/smartvillage-operator/apply-edgemongodb.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=/projects/smartvillage-operator/kustomize/overlays/sandbox/edgemongodbs/mongodb/edgemongodb.yaml

oc get pod -l app.kubernetes.io/instance=mongodb -w
oc logs -l app.kubernetes.io/instance=mongodb -f
```

## Install the RabbitMQ in the OpenShift Developer Sandbox

```bash
ansible-playbook /projects/smartvillage-operator/apply-edgerabbitmq.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=/projects/smartvillage-operator/kustomize/overlays/sandbox/edgerabbitmqs/rabbitmq/edgerabbitmq.yaml

oc get pod -l app.kubernetes.io/name=rabbitmq -w
oc logs -l app.kubernetes.io/name=rabbitmq -f
```

## Install postgres in the OpenShift Developer Sandbox

```bash
oc create configmap smartvillage-db-create --from-file /projects/smartabyar-smartvillage/src/main/resources/sql/db-create.sql

ansible-playbook /projects/smartvillage-operator/apply-edgepostgres.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=/projects/smartvillage-operator/kustomize/overlays/sandbox/edgepostgress/postgres/edgepostgres.yaml
```

You should see a play recap that has failed. 
This is expected because the postgres pod is barely getting created. 
The final tasks in the playbook expect the database create SQL scripts to be run for the smartvillage application in postgres.  
Retry the playbook once the postgres pod is running. 

```bash
ansible-playbook /projects/smartvillage-operator/apply-edgepostgres.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=/projects/smartvillage-operator/kustomize/overlays/sandbox/edgepostgress/postgres/edgepostgres.yaml

oc get pod -l app=postgres -w
oc logs -l app=postgres -f
```

## Install the NGSI-LD Context Broker in the OpenShift Developer Sandbox

```bash
ansible-playbook /projects/smartvillage-operator/apply-orionldcontextbroker.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=/projects/smartvillage-operator/kustomize/overlays/sandbox/orionldcontextbrokers/orion-ld/orionldcontextbroker.yaml

oc get pod -l app.kubernetes.io/instance=orion-ld -w
oc logs -l app.kubernetes.io/instance=orion-ld -f
```

## Install the IoT Agent JSON in the OpenShift Developer Sandbox

```bash
ansible-playbook /projects/smartvillage-operator/apply-iotagentjson.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=/projects/smartvillage-operator/kustomize/overlays/sandbox/iotagentjsons/iotagent-json/iotagentjson.yaml

oc get pod -l app.kubernetes.io/instance=iotagent-json -w
oc logs -l app.kubernetes.io/instance=iotagent-json -f
```

## Install zookeeper in the OpenShift Developer Sandbox

```bash
ansible-playbook /projects/smartvillage-operator/apply-edgezookeeper.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=/projects/smartvillage-operator/kustomize/overlays/sandbox/edgezookeepers/default/edgezookeeper.yaml

oc get pod -l app=zookeeper -w
oc logs -l app=zookeeper -f
```

## Install solr in the OpenShift Developer Sandbox

```bash
oc apply -k kustomize/overlays/sandbox/edgesolrs/default/configmaps/

ansible-playbook /projects/smartvillage-operator/apply-edgesolr.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=/projects/smartvillage-operator/kustomize/overlays/sandbox/edgesolrs/default/edgesolrs/default/edgesolr.yaml

oc get pod -l app=solr -w
oc logs -l app=solr -f
```

## Install the SmartaByarSmartVillage in the OpenShift Developer Sandbox

```bash
ansible-playbook /projects/smartvillage-operator/apply-smartabyarsmartvillage.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=/projects/smartvillage-operator/kustomize/overlays/sandbox/smartabyarsmartvillages/smartvillage/smartabyarsmartvillage.yaml
```

## Install the Traffic Flow Observed JSON in the OpenShift Developer Sandbox

```bash
ansible-playbook /projects/smartvillage-operator/apply-trafficflowobserved.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=/projects/smartvillage-operator/kustomize/overlays/sandbox/trafficflowobserveds/sweden-veberod-1-lakaregatan-ne/trafficflowobserved.yaml
```

```bash
ansible-playbook /projects/smartvillage-operator/apply-trafficflowobserved.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=/projects/smartvillage-operator/kustomize/overlays/sandbox/trafficflowobserveds/sweden-veberod-1-sjobovagen-se/trafficflowobserved.yaml
```

## Install the Crowd Flow Observed JSON in the OpenShift Developer Sandbox

```bash
ansible-playbook /projects/smartvillage-operator/apply-crowdflowobserved.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=/projects/smartvillage-operator/kustomize/overlays/sandbox/crowdflowobserveds/sweden-veberod-1-sjobovagen-se-dorrodsvagen-sw/crowdflowobserved.yaml
```

```bash
ansible-playbook /projects/smartvillage-operator/apply-crowdflowobserved.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=/projects/smartvillage-operator/kustomize/overlays/sandbox/crowdflowobserveds/sweden-veberod-1-dorrodsvagen-ne-sjobovagen-se/crowdflowobserved.yaml
```

```bash
ansible-playbook /projects/smartvillage-operator/apply-crowdflowobserved.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=/projects/smartvillage-operator/kustomize/overlays/sandbox/crowdflowobserveds/sweden-veberod-1-sjobovagen-nw-lakaregatan-ne/crowdflowobserved.yaml
```

```bash
ansible-playbook /projects/smartvillage-operator/apply-crowdflowobserved.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=/projects/smartvillage-operator/kustomize/overlays/sandbox/crowdflowobserveds/sweden-veberod-1-lakaregatan-sw-sjobovagen-nw/crowdflowobserved.yaml
```

```bash
ansible-playbook /projects/smartvillage-operator/apply-crowdflowobserved.yaml \
  -e ansible_operator_meta_namespace=$(oc get project -o jsonpath={.items[0].metadata.name}) \
  -e crd_path=/projects/smartvillage-operator/kustomize/overlays/sandbox/crowdflowobserveds/sweden-veberod-1-sjobovagen-se-dorrodsvagen-sw/crowdflowobserved.yaml
```























```bash
(cd /projects/computate && mvn clean install)

## Run the Ansible Galaxy roles to install the complete project locally. 

```bash
ansible-playbook ~/.ansible/roles/computate.computate_project/install.yml -e SITE_NAME=computate-search -e ENABLE_CODE_GENERATION_SERVICE=true
ansible-playbook ~/.ansible/roles/computate.computate_project/install.yml -e SITE_NAME=computate-vertx -e ENABLE_CODE_GENERATION_SERVICE=true
ansible-playbook ~/.ansible/roles/computate.computate_project/install.yml -e SITE_NAME=smartvillage-platform -e ENABLE_CODE_GENERATION_SERVICE=true
ansible-playbook ~/.ansible/roles/computate.computate_project/install.yml -e SITE_NAME=smartabyar-smartvillage -e ENABLE_CODE_GENERATION_SERVICE=true
```

## Running the project build and test suite

The smartabyar-smartvillage project uses Maven to build and test the software. 
You can run the build and test suite with this command: 

```
cd /projects/smartabyar-smartvillage
mvn clean install
```

## Running the project install to override secret variables

You can also inject your own secret variables with an Ansible Vault into the project install automation if you want to override any values. 

Here is an example of creating a vault directory and creating a new vault, it will ask for a password. 
Be sure to not commit your vault to source control, it should be ignored by default in the .gitignore file that is created in the project. 

```bash
install -d /projects/smartabyar-smartvillage-ansible/vault
ansible-vault create /projects/smartabyar-smartvillage-ansible/vault/$USER-local
```

You can edit the vault, it will ask for the password. 

```bash
ansible-vault edit /projects/smartabyar-smartvillage-ansible/vault/$USER-local
```

You can then run the project install automation again with the secrets in the vault, it will ask for the password. 

```bash
ansible-playbook ~/.ansible/roles/computate.computate_project/install.yml -e SITE_NAME=smartabyar-smartvillage -e ENABLE_CODE_GENERATION_SERVICE=true -e @/projects/smartabyar-smartvillage-ansible/vault/$USER-local --vault-id @prompt
```

# Configure Eclipse IDE 

You can download Eclipse Installer here: 

https://www.eclipse.org/downloads/packages/

After you download the Eclipse installer, create a directory for it and extract it with this command: 

```bash
install -d ~/.local/opt/eclipse-installer
tar xvf ~/Downloads/eclipse-inst-jre-linux64.tar.gz -C ~/.local/opt/eclipse-installer --strip-components=1
```

Now run the Eclipse installer: 

```bash
~/.local/opt/eclipse-installer/eclipse-inst
```

- Select [ Eclipse IDE for Java Developers ]
- I recommend installing Eclipse in the following subdirectory of your home directory: .local/opt/eclipse
- Click [ Accept Now ] for the User Agreement

When you run Eclipse Studio, I suggest you create your workspace here: /projects

## Install these update sites: 

In Eclipse, go to Help -> Install New Software...

Add these update sites and install these useful plugins: 

### Vrapper Vim Plugin
- http://vrapper.sourceforge.net/update-site/stable
    - Choose the "Vrapper" plugin if you want to be able to edit code with Vim commands
    - Vrapper keys to unbind in Window -> Preferences -> General -> Keys: 
        - ctrl+d, ctrl+u, ctrl+r, shift+ctrl+v, alt+v
    - Vrapper keys to set: 
        - and search for "Vrapper" and set the keys to alt+v

### DevStyle for dark theme

- http://www.genuitec.com/updates/devstyle/ci/
    - Choose "DevStyle Features" for themes

### YAML Editor

- http://www.genuitec.com/updates/devstyle/ci/
    - Choose "DevStyle Features" for themes

## Import the smartabyar-smartvillage project into Eclipse

* In Eclipse, go to File -> Import...
* Select Maven -> Existing Maven Projects
* Click [ Next > ]
* Browse to the directory: /projects/smartabyar-smartvillage
* Click [ Finish ]

## Setup a Eclipse Debug/Run configuration to generate the OpenAPI 3 spec and the SQL create and drop scripts in smartabyar-smartvillage

* In Eclipse, go to File -> Debug Configurations...
* Right click on Java Application -> New Configuration
* Name: smartabyar-smartvillage-OpenAPIGenerator
* Project: smartabyar-smartvillage
* Main class: org.computate.smartvillage.enus.vertx.MainVerticle

### In the Environment tab

Setup the following variables to setup the Vert.x verticle. 

* CONFIG_PATH: /projects/smartabyar-smartvillage/config/smartabyar-smartvillage.yml
* RUN_OPENAPI3_GENERATOR: true
* RUN_SQL_GENERATOR: true
* RUN_FIWARE_GENERATOR: true

Click [ Apply ] and [ Debug ] to debug the generation of the OpenAPI Spec src/main/resources/webroot and the SQL create and drop scripts in src/main/resources/sql. 

## Setup a Eclipse Debug/Run configuration to run and debug smartabyar-smartvillage

* In Eclipse, go to File -> Debug Configurations...
* Right click on Java Application -> New Configuration
* Name: smartabyar-smartvillage
* Project: smartabyar-smartvillage
* Main class: org.computate.smartvillage.enus.vertx.MainVerticle

### In the "Arguments" tab

Setup the following VM arguments to disable caching for easier web development: 

```
-DfileResolverCachingEnabled=false -Dvertx.disableFileCaching=true
```

### In the Environment tab

Setup the following variables to setup the Vert.x verticle. 

* CONFIG_PATH: /projects/smartabyar-smartvillage/config/smartabyar-smartvillage.yml
* VERTXWEB_ENVIRONMENT: dev

Click [ Apply ] and [ Debug ] to debug the application. 

# Deploy smartabyar-smartvillage to OpenShift with Ansible

To deploy smartabyar-smartvillage to OpenShift with Ansible, you will want to follow the instructions to install Ansible on your system first above "Install Ansible dependencies on Linux". 

## Setup ~/.ansible/roles directory

A default place to install Ansible roles from Ansible Galaxy is in ~/.ansible/roles. Make sure this directory exists: 

```bash
install -d ~/.ansible/roles
```

## Clone the Ansible roles for deploying the applications to OpenShift

```bash
git clone git@github.com:computate-org/computate_postgres_openshift.git ~/.ansible/roles/computate.computate_postgres_openshift
git clone git@github.com:computate-org/computate_zookeeper_openshift.git ~/.ansible/roles/computate.computate_zookeeper_openshift
git clone git@github.com:computate-org/computate_solr_openshift.git ~/.ansible/roles/computate.computate_solr_openshift
git clone git@github.com:computate-org/computate_project_openshift.git ~/.ansible/roles/computate.computate_project_openshift
```

## Create an ansible vault for your OpenShift.

You can create and edit an encrypted ansible vault with a password for the host secrets for your shared OpenShift inventory to deploy smartabyar-smartvillage.
It will have you create a password when you save the file for the first time, like using vim to exit. 

```bash
install -d /projects/smartabyar-smartvillage-ansible
install -d /projects/smartabyar-smartvillage-ansible/vault/$USER-staging/vault
ansible-vault create /projects/smartabyar-smartvillage-ansible/vault/$USER-staging/vault
ansible-vault edit /projects/smartabyar-smartvillage-ansible/vault/$USER-staging/vault
```

Here is an example of a vault that I have used to deploy the smartabyar-smartvillage application. 
You will want to update these values to reflect your OpenShift environment, like the REDHAT_OPENSHIFT_TOKEN which you will need to obtain after logging into OpenShift. 
Or the REDHAT_OPENSHIFT_STORAGE_CLASS_NAME which might be different than gp2 for you. 
If so, try creating a persistent volume in the UI to figure out a good storage class for your environment: 

```yaml
SITE_NAME: smartabyar-smartvillage

REDHAT_OPENSHIFT_HOST: https://api.rh-us-east-1.openshift.com
REDHAT_OPENSHIFT_TOKEN: OcrtrXzKNKVj0riR2FvfqORgGfnURx98G8zRPd2MUvs
REDHAT_OPENSHIFT_NAMESPACE: rh-impact
REDHAT_OPENSHIFT_STORAGE_CLASS_NAME: gp2

POSTGRES_DB_NAME: sampledb
POSTGRES_DB_USER: computate
POSTGRES_DB_PASSWORD: qVTaaa23aIkLmw
POSTGRES_VOLUME_SIZE: 1Gi
POSTGRES_STORAGE_CLASS_NAME: "{{ REDHAT_OPENSHIFT_STORAGE_CLASS_NAME }}"

ZOOKEEPER_VOLUME_SIZE: 1Gi
ZOOKEEPER_STORAGE_CLASS_NAME: "{{ REDHAT_OPENSHIFT_STORAGE_CLASS_NAME }}"

SOLR_VOLUME_SIZE: 2Gi
SOLR_STORAGE_CLASS_NAME: "{{ REDHAT_OPENSHIFT_STORAGE_CLASS_NAME }}"

AUTH_REALM: SMARTVILLAGE
AUTH_CLIENT: smartvillage
AUTH_SECRET: ...
AUTH_HOST_NAME: sso.computate.org
AUTH_PORT: 443
AUTH_SSL: true
AUTH_TOKEN_URI: "/auth/realms/SMARTVILLAGE/protocol/openid-connect/token"
```

## Run the Ansible automation to deploy the applications to OpenShift

```bash

ansible-playbook --vault-id @prompt -e @/projects/smartabyar-smartvillage-ansible/vault/$USER-staging/vault ~/.ansible/roles/computate.computate_postgres_openshift/install.yml -e SITE_NAME=smartabyar-smartvillage

ansible-playbook --vault-id @prompt -e @/projects/smartabyar-smartvillage-ansible/vault/$USER-staging/vault ~/.ansible/roles/computate.computate_zookeeper_openshift/install.yml -e SITE_NAME=smartabyar-smartvillage

ansible-playbook --vault-id @prompt -e @/projects/smartabyar-smartvillage-ansible/vault/$USER-staging/vault ~/.ansible/roles/computate.computate_solr_openshift/install.yml -e SITE_NAME=smartabyar-smartvillage

ansible-playbook --vault-id @prompt -e @/projects/smartabyar-smartvillage-ansible/vault/$USER-staging/vault ~/.ansible/roles/computate.computate_project_openshift/install.yml -e SITE_NAME=smartabyar-smartvillage
```

## How to run the application as a Podman container

### Install the prerequiste packages for buildah and podman

```bash
pkcon install -y buildah
pkcon install -y podman
```

### Build the container with podman

```bash
cd /projects/smartabyar-smartvillage
podman build -t computateorg/smartabyar-smartvillage:latest .
```

### Push the container up to quay.io
```bash
podman login quay.io
podman push computateorg/smartabyar-smartvillage:latest quay.io/computateorg/smartabyar-smartvillage:latest
```

## How the base classes for this project were created

```bash
ansible-playbook -e @/projects/smartabyar-smartvillage/local/ansible_install_vars.yml /projects/computate-org/vertx_project.yml
```

# Load a new map traffic data into SUMO

```bash
cd ~/.local/share/sumo/data
env LD_LIBRARY_PATH=~/.local/lib:~/.local/lib64 "SUMO_HOME=$HOME/.local/share/sumo" python ~/.local/share/sumo/tools/osmWebWizard.py
```

# Export SUMO vehicle coordinate data

```bash
env LD_LIBRARY_PATH=~/.local/lib:~/.local/lib64 "SUMO_HOME=$HOME/.local/share/sumo" SUMO_HOME=~/.local/share/sumo sumo --fcd-output ~/.local/share/sumo/data/veberod/veberod-fcd.xml -c ~/.local/share/sumo/data/veberod/veberod.sumocfg --fcd-output.geo -b 10 -e 360 --step-length 0.1
```

# Export SUMO full data

```bash
env LD_LIBRARY_PATH=~/.local/lib:~/.local/lib64 "SUMO_HOME=$HOME/.local/share/sumo" SUMO_HOME=~/.local/share/sumo sumo --full-output ~/.local/share/sumo/data/veberod/veberod-full.xml -c ~/.local/share/sumo/data/veberod/veberod.sumocfg --fcd-output.geo -b 10 -e 360 --step-length 0.1
```

# Convert X,Y coordinates to geo coordinates with python

The Veberod_intersection.net.xml contains data about traffic lights like the x/y position. 

```xml
<junction id="267701936" type="traffic_light" x="220.61" y="853.48" 
```

To convert the x/y position, use python: 

```bash
pip install pyproj sumolib
python
>>> import sumolib
>>> net = sumolib.net.readNet('/home/ctate/.local/src/TLC/TLC_sumo/Veberod_intersection.net.xml')
>>> print(net.convertXY2LonLat(220.61,853.48))
(13.49260653795143, 55.633791753658265)
```

# Run SUMO with Traci TCP server

```bash
env SUMO_HOME=/home/ctate/.local/share/sumo LD_LIBRARY_PATH=/home/ctate/.local/lib:~/.local/lib64 /home/ctate/.local/bin/sumo-gui --remote-port 8813 --num-clients 1 --start
```

## Python interact with the Traci TCP server

```bash
cd ~/.local/share/sumo/tools
```

```python
import traci
conn = traci.connect()
conn.simulationStep()
conn.simulationStep()
conn.simulationStep()
```

# Get the AUTH_CLIENTS as JSON for OpenShift deployment

Install jq

```bash
pkcon install -y jq
```

Install yq

```bash
curl https://github.com/mikefarah/yq/releases/download/v4.40.2/yq_linux_amd64.tar.gz -o ~/Downloads/yq_linux_amd64.tar.gz
install -d ~/.local/opt/yq/
tar xvf ~/Downloads/yq_linux_amd64.tar.gz -C ~/.local/opt/yq/
mv ~/.local/opt/yq/yq_linux_amd64 ~/.local/bin/yq
```

Run the command

```bash
yq -o json '.AUTH_CLIENTS' /projects/smartabyar-smartvillage/config/smartabyar-smartvillage.yml | jq -c
```

# Restart a workbench

## Set up a new Python virtualenv

```bash
source /projects/python/bin/activate
```
