
# Visualizing open source Smart Village data in the New England Research Cloud
## Brought to you by the Smarta Byar Smart Village Community FIWARE iHub
## Written by Christopher Tate

- Red Hat Principal Software Engineer in Red Hat Research
- Creator of the Smart Village Operator and Smart Village Platform
- Architect of the Red Hat Social Innovation Program
- Founder of the Smarta Byar Smart Village Community FIWARE Innovation Hub
- Principal Software Engineer for the New England Research Cloud

## Using the New England Research Cloud OpenShift Environment

Log into the New England Research Cloud OpenShift Environment here [https://console.apps.shift.nerc.mghpcc.org](https://console.apps.shift.nerc.mghpcc.org). 

### Download the oc command
- Click the
<img src="pictures/10000201000000180000001946A6B15A7F8D3A9C.png" />
button in the top right of OpenShift container.

- Click
<img src="pictures/100002010000010400000025591A5F602949BE11.png" />.
- Click the download link for your operating system.

<img src="pictures/1000020100000168000000AC979C70CCF932ABC5.png" />
- You'll need to extract the `oc` command and place it in your path,
for example in a `bin` directory in your `$HOME` directory.

```bash
mkdir -p ~/bin
tar xvf ~/Downloads/oc.tar -C ~/bin/
```

### Log into the OpenShift CLI in your terminal

<img src="pictures/10000201000000DA000000A925DC020844A89E01.png" />
- Click your username in the top right corner of OpenShift.
- Click
<img src="pictures/10000201000000BD00000025748AE357F93DE9CB.png" />.
- Click
<img src="pictures/10000201000000740000002333EFEF0BE6991D9D.png" />.
- Click
<img src="pictures/100002010000006A000000156B50A1A3B5B867E3.png" />.
- Copy the line to the clipboard that looks like this:

<img src="pictures/100002010000024F0000004C0CDBE88B1D849CC9.png" />
- Paste the command into your terminal to log in to OpenShift in the terminal.

<img src="pictures/10000201000003AC000000BE7CE02563432523F1.png" />

### Grant default service account edit role in namespace

To grant the default service account edit role privileges, you will use
either your own terminal where you have logged in to OpenShift, or use
the built-in OpenShift Terminal. We will grant edit privileges on the
default service account, as well as edit privileges on roles and
rolebindings in the namespace so that the default service account can
deploy resources in your namespace.

```
oc create rolebinding sumo-edit --clusterrole=edit \
  --serviceaccount=smart-village-faeeb6c:sumo

oc create role sumo-edit-rolebindings \
  --verb=get,list,watch,create,update,patch,delete \
  --resource=roles,rolebindings

oc create rolebinding sumo-edit-rolebindings --role=sumo-edit-rolebindings \
  --serviceaccount=smart-village-faeeb6c:sumo
```

# OpenShift AI

## Set up an OpenShift AI Workbench

### Accessing OpenShift AI

In the OpenShift Console, click on the apps button
<img src="pictures/100002010000003000000024AAAC041571052865.png" />
at the top,

then click
<img src="pictures/100002010000012600000028AA3F546B7EAF857C.png" />
to log into OpenShift AI.

Click the button to
<img src="pictures/10000201000000A000000020B028AB197DEBE3A3.png" />.

Log into OpenShift AI by clicking on the
<img src="pictures/100002010000006C0000001DABF5B58FF6B1D253.png" />
button.

Once you are in OpenShift AI, click on the menu button
<img src="pictures/100002010000002E000000216426608B65255A13.png" />,
then click
<img src="pictures/10000201000000B200000027F58611BB363F3154.png" />.

Then click on the name of your data science project,
for  our project it's `smart-village-faeeb6c`.

### Create a new OpenShift AI Workbench

To create a new workbench, click
<img src="pictures/100002010000009100000021A1D82C0B6349F1C3.png" />.

To stay consistent with the rest of the course, enter the workbench name
“sumo”
<img src="pictures/1000020100000043000000446EA181997A7346B6.png" />.

For Image selection, choose “Minimal Python”
<img src="pictures/100002010000007B0000003FA29A900E8890D587.png" />.

You can leave the rest of the fields as the default. At the very bottom,
click
<img src="pictures/1000020100000091000000211148800178F97C50.png" />.

After a minute or two, you should see the workbench change from
<img src="pictures/10000201000000460000002FDF0FBBBC61A6E1C5.png" />
to
<img src="pictures/100002010000003A00000030BD8223197D20CCFD.png" />.

### Access your OpenShift AI Workbench

In OpenShift AI, click on the
<img src="pictures/100002010000004200000023E46306A5CE3ADC98.png" />
link to open your new OpenShift AI Workbench.

Log into OpenShift AI by clicking on the
<img src="pictures/100002010000006C0000001DABF5B58FF6B1D253.png" />
button.

You will need to authorize yourself access to your workbench. Click
<img src="pictures/10000201000000CD0000001AA11D3D36B96FAA42.png" />.

## Using an OpenShift AI Smart Village SUMO Workbench

### Using a Workbench Terminal to load course resources

You will want to open a Terminal inside your OpenShift AI Workbench to
load the course resources. There are many ways to open a terminal, but
here is one that always works.

At the top, click
<img src="pictures/100002010000002300000017A7751A2F8CB5671D.png" />
→
<img src="pictures/100002010000002800000016B63989EE943480F7.png" />
→
<img src="pictures/100002010000004D00000018604E6A830090C94F.png" />.

### Clone the smartabyar-smartvillage-sandbox-course course

With git, clone the course materials to the default home directory
(/opt/app-root/src) of your workbench.

```bash
git clone https://github.com/smartabyar-smartvillage/smartabyar-smartvillage-sandbox-course.git ~/smartabyar-smartvillage-sandbox-course
```

It will ask you to enter your username and password. This is where you
enter your GitHub username, and the token value you copied from GitHub
earlier. The git credential.helper store should remember your password.

### Clone the smartvillage-operator

We will be using the open source smartvillage-operator to set up the
rest of the course.

In your Workbench Terminal, clone the smartvillage-operator into your
workbench with this command.

```bash
git clone https://github.com/smartabyar-smartvillage/smartvillage-operator.git ~/smartvillage-operator
```

### Open the course Jupyter Notebook

A Jupyter Notebook is an interactive, online notebook, and the rest of
the course be found in the Jupter Notebook. Here is how to find the
course Jupyter Notebook.

- In your workbench, make sure your left sidebar is open. If it’s not,
press \[ Ctrl \] + \[ b \].
- Navigate to `smartabyar-smartvillage-sandbox-course`. 
- Open the first Notebook [01-install-prerequisites.ipynb](01-install-prerequisites.ipynb) and follow the instructions from there. 

## Run the Smart Village Platform in trafficsimulation

```bash
(cd ~/smartabyar-smartvillage && env CONFIG_PATH=$HOME/smartabyar-smartvillage/config/smartabyar-smartvillage.yml mvn exec:java -Dexec.mainClass="org.computate.smartvillage.enus.vertx.MainVerticle")
```

## Install all the Smart Data Models and index in Solr

```bash
ansible-playbook ~/smartvillage-operator/clone-smart-model-data.yml -e SOLR_BASE_URL="http://solr:8983"
```

## Watch Smarta Byar Smart Village code serviceaccount

```bash
env SITE_NAME=smartabyar-smartvillage SITE_PATH=$HOME/smartabyar-smartvillage COMPUTATE_SRC=$HOME/computate SITE_LANG=enUS $HOME/computate/bin/enUS/watch.sh
```


#















































# Clone the smartabyar-smartvillage project

```bash
install -d ~/.local/src/smartabyar-smartvillage
git clone git@github.com:computate-org/smartabyar-smartvillage.git ~/.local/src/smartabyar-smartvillage
```

# Clone the smartvillage-operator project

```bash
install -d ~/.local/src/smartvillage-operator
git clone git@github.com:computate-org/smartvillage-operator.git ~/.local/src/smartvillage-operator
```

# Apply the kustomize base resources

```bash
oc apply -k kustomize/overlays/nerc-ocp-prod/base/
```

# Run the Postgres Ansible Operator

```bash
ansible-playbook ~/.local/src/smartvillage-operator/apply-edgepostgres.yaml -e crd_path=~/.local/src/smartvillage-operator/kustomize/overlays/nerc-ocp-prod/ansible/edgepostgress/postgres/edgepostgres.yaml
```

# Run the Zookeeper Ansible Operator

```bash
ansible-playbook ~/.local/src/smartvillage-operator/apply-edgezookeeper.yaml -e crd_path=~/.local/src/smartvillage-operator/kustomize/overlays/nerc-ocp-prod/ansible/edgezookeepers/default/edgezookeeper.yaml
```

# Apply the Solr resources

```bash
oc apply -k kustomize/overlays/nerc-ocp-prod/app/solr/
```

# Run the Solr Ansible Operator

```bash
ansible-playbook ~/.local/src/smartvillage-operator/apply-edgesolr.yaml -e crd_path=~/.local/src/smartvillage-operator/kustomize/overlays/nerc-ocp-prod/ansible/edgesolrs/default/edgesolr.yaml
```

# Apply the Red Hat SSO resources

```bash
oc apply -k kustomize/overlays/nerc-ocp-prod/app/sso/
```

# Run the Smart Village Ansible Operator

```bash
ansible-playbook ~/.local/src/smartvillage-operator/apply-smartabyarsmartvillage.yaml -e crd_path=~/.local/src/smartvillage-operator/kustomize/overlays/nerc-ocp-prod/ansible/smartabyarsmartvillages/smartvillage/smartabyarsmartvillage.yaml
```

# Run the Ansible Playbook to install a TrafficSimulation

```bash
ansible-playbook apply-trafficsimulation.yaml -e crd_path=kustomize/overlays/nerc-ocp-prod/trafficsimulations/veberod-intersection-1/trafficsimulation.yaml
```
