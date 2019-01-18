## OpenPLC - IEC 61131-3 compatible open source PLC

Made for [netPI](https://www.netiot.com/netpi/), the Raspberry Pi 3B Architecture based industrial suited Open Edge Connectivity Ecosystem

### Debian with OpenPLC V3 runtime, SSH server and user root

The image provided hereunder deploys a container with OpenPLC V3 runtime and adapted hardware layer for netPI. OpenPLC is a completely free and standardized software basis to create programmable logic controllers. The editor that comes extra lets you program in the languages Ladder Diagram (LD), Instruction List (IL), Structured Text (ST), Function Block Diagram (FBD) and Sequential Function Chart (SFC) in accordance with the IEC 61131-3.

Base of this image builds [debian](https://www.balena.io/docs/reference/base-images/base-images/) with enabled [SSH](https://en.wikipedia.org/wiki/Secure_Shell), created user 'root' and peinstalled OpenPLC_v3 project from [here](https://github.com/thiagoralves/OpenPLC_v3) with modified /webserver/core/hardware_layers/raspberrpi.cpp file to fit the netPI hardware (gpio interface).

Using OpenPLC works in conjunction with a [PLCOpen Editor](http://www.openplcproject.com/plcopen-editor) that lets you writing PLC programs offline to import them into the runtime. This tool has to be installed under Linux or Windows separately.

Additional information about the OpenPLC project can be retrieved [here](http://www.openplcproject.com/).

Questions can be directed to the [official OpenPLC forum](https://openplc.discussion.community/)

#### Container prerequisites

##### Port mapping

For remote login (not necessary for default usage) to the container across SSH the container's SSH port `22` needs to be mapped to any free netPI host port.

To allow the access to the OpenPLC web interface over a web browser the container TCP port `8080` needs to be exposed to any free netPI host port.

By default OpenPLC supports Modbus TCP server functionality using the default port `502`. This port should be exposed to netPI host port `502` (be compatible with standard Modbus TCP clients).

##### Privileged mode

Only the privileged mode option lifts the enforced container limitations to allow usage of all host features in a container.

##### Host device

To grant access to the gpio interface the `/dev/gpiomem` host device needs to be exposed to the container. This gives you access to netPI's GPIO pins to plug in module such as NIOT-E-NPIX-4DI4DO for example.

#### Getting started

STEP 1. Open netPI's landing page under `https://<netpi's ip address>`.

STEP 2. Click the Docker tile to open the [Portainer.io](http://portainer.io/) Docker management user interface.

STEP 3. Enter the following parameters under **Containers > Add Container**

* **Image**: `hilschernetpi/netpi-openplc`

* **Port mapping**: `Host "22" (any unused one) -> Container "22"` 
                    `Host "8080" (any unused one) -> Container "8080"` 
                    `Host "502" -> Container "502"` 

* **Restart policy"** : `always`

* **Runtime > Devices > add device**: `Host "/dev/gpiomem" -> Container "/dev/gpiomem"`

* **Runtime > Privileged mode** : `On`

STEP 4. Press the button **Actions > Start/Deploy container**

Pulling the image may take a while (5-10mins). Sometimes it takes so long that a time out is indicated. In this case repeat the **Actions > Start/Deploy container** action.

#### Accessing

The container starts an SSH server as well as the OpenPLC runtime automatically when started. 

Just in case your want to open a terminal connection to it with an SSH client such as [putty](http://www.putty.org/) using netPI's IP address at your mapped port 22. Use the credentials `root` as user and `root` as password when asked and you are logged in as root user `root`.

The default usage is interacting with the OpenPLC runtime across its web GUI using a web browser. To access the web GUI use http://<netpi's ip address>:<your mapped port 8080>) e.g. http://192.168.0.1:8080

##### OpenPLC runtime

Enter the default user and password `openplc` when asked during your web login. (The password can be changed or new users be added in the `Settings` menu pane later).

Setup the embedded Modbus TCP server. This allows you to exchange some data with a Modbus TCP client. 

STEP 1: Click `Slave Devices` in the left menu pane

STEP 2: Click `Add new device`

STEP 3: Choose `Generic Modbus TCP Device`, slave ID 0 and the IP address 127.0.0.1 at port 502. 

STEP 4: Set the IO data sizes to default address 0 and length 8 and then click `Save device`

STEP 5: Click `Programs` and then `Browse...` and choose the test program `netPI_Test.st` from the [github project](https://github.com/Hilscher/netPI-openplc/sample) and then click `Upload Program`.

STEP 6: Return to the Dashboard and click `Hardware` and choose `Raspberry Pi` in the drop down box and then click `Save Changes`. The version of the `Raspberry Pi` is adapted to netPI's available IOs provided in case a NIOT-E-NPIX-4DI4DO module is used in its extension slot

STEP 7: Return to the Dashboard and click `Start PLC` to the left to start the PLC

The test PLC program sets the Discrete Input Register 0 to value 1 (%IX0.0 := TRUE) and increments an integer value at Input Register 0 (%IW0 := %IW0 +1).

##### Modbus Client

We recommend to use [Modbus Master Simulator(windows)](http://en.radzio.dxp.pl/modbus-master-simulator/) for a test.

STEP 1: Click `File\new`

STEP 2: Set `Device ID` to 0, choose `Input registers`

STEP 3: Click `Connection\Settings`

STEP 4: Choose `Modbus TCP` and enter netPI's IP address as IP address at port 502 and click `OK`

STEP 5: Click `Connection\Connect`

STEP 6: Watch the value incrementing at address 0

##### OpenPLC Editor

Install the editor either under Windows or Linux and load the sample project.

STEP 1: Click `File\Open` and load in the `netPI_Test.xml` from the [github project](https://github.com/Hilscher/netPI-openplc/sample)

STEP 2: Make your edits in the project

STEP 3: Click `File\Save` to save the project again

STEP 4: Click `Generate Program` to generate a new .st file you can load into your OpenPLC runtime

##### Digital IO using NIOT-E-NPIX-4DI4DO module

netPI can be extended physically by advanced network modules using its bottom slot. One of these modules is the 4 Digital Input/Output module NIOT-E-NPIX-4DI4DO. For this module the hardware layer `Raspberry Pi` was adapted to fit the 4DI/4DO pinout of this module.

Access the 4 digital inputs at the addresses %IX0.0, %IX0.1, %IX0.2 and %IX0.3 and the 4 digital outputs at %QX0.0, %QX0.1, %QX0.2 and %QX0.3 in your project.

#### Automated build

The project complies with the scripting based [Dockerfile](https://docs.docker.com/engine/reference/builder/) method to build the image output file. Using this method is a precondition for an [automated](https://docs.docker.com/docker-hub/builds/) web based build process on DockerHub platform.

DockerHub web platform is x86 CPU based, but an ARM CPU coded output file is needed for Raspberry systems. This is why the Dockerfile includes the [balena](https://balena.io/blog/building-arm-containers-on-any-x86-machine-even-dockerhub/) steps.

#### License

View the license information for the software in the project. As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).
As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.

[![N|Solid](http://www.hilscher.com/fileadmin/templates/doctima_2013/resources/Images/logo_hilscher.png)](http://www.hilscher.com)  Hilscher Gesellschaft fuer Systemautomation mbH  www.hilscher.com
