### k8s node setup script

This repository contains a shell script that automates the setup of a Kubernetes node using `Cri-O` as the CRI. The script performs the necessary steps to configure the node and install the required dependencies.

### Prerequisites

Before running the script, make sure you have met the following requirements:

1. A Linux-based operating system (e.g., Ubuntu, CentOS) on the target node.
2. Root or sudo access on the target node.
3. Internet connectivity on the target node to download necessary packages.

### Usage

1. Clone this repository to the target node:
`git clone https://github.com/imad-elbouhati/k8s-node-setup-script.git`

2. Change into the project directory:
`cd k8s-node-setup-script`

3. Make the script executable:
`chmod +x init_nodes.sh`

4. Run the script with root or sudo privileges:
`sudo ./init_nodes.sh`

