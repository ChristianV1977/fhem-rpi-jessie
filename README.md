[![](https://images.microbadger.com/badges/image/vcrhome/fhem-rpi-jessie.svg)](https://microbadger.com/images/vcrhome/fhem-rpi-jessie "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/vcrhome/fhem-rpi-jessie.svg)](https://microbadger.com/images/vcrhome/fhem-rpi-jessie "Get your own version badge on microbadger.com")

## Docker Container for FHEM House-Automation-System - Full install Version 5.8
With some extras: DBlog, WiringPI, WiringPI2, PiLight, RCswitch, Whatsapp with yowsup and MySensors Gateway (IRQ Pin 15)
Ready for firmware flashing (avrdude installed)

Timezone is set to Europe/Berlin with NTP support.

Started and Controlled over Supervisord on Port 9001 (user:admin pass:admin).



Website: http://www.fhem.de

### Features
* volume /opt/fhem/config
* Imagemagic
* Python - yowsup for whatsapp client
* Open-SSH daemon
* Exposed ports: 2222/SSH, 7072 Fhem-raw, 8083-8085 Fhem Web, 9001 supervisord
* cron daemon / at
* NFS client and autofs /net
* ssh root password: fhem!
* USB tools for CUL hardware

### Run:
    docker run -d --name fhem --cap-add SYS_ADMIN -p 7072:7072 -p 8083:8083 -p 8084:8084 -p 8085:8085 -p 2222:2222 -p 9001:9001 vcrhome/fhem-rpi-jessie
   
If NFS mount fails run with `--privileged` switch.

    docker run -d --name fhem --privileged -p 7072:7072 -p 8083:8083 -p 8084:8084 -p 8085:8085 -p 2222:2222  vcrhome/fhem-rpi-jessie

### Run with volume on host:

    docker run -d --name fhem --cap-add SYS_ADMIN -v /var/fhemdocker/fhem:/opt/fhem/config -p 7072:7072 -p 8083:8083 -p 8084:8084 -p 8085:8085 -p 2222:2222 -p 9001:9001 vcrhome/fhem-rpi-jessie

If using host volumes (ie. /opt/fhem/config) initial config will be installed but only if the host directory is empty.
The WiringPI, PiLight and MySensors Gateway needes "--device /dev/mem:/dev/mem --privileged"
additional for PiLight us "--device /dev/lirc0:/dev/lirc0"

Using  usb  needs to add the device to the run command.  Check usb devices on the host with ` lsusb `.

` lsusb -v | grep -E '\<(Bus|iProduct|bDeviceClass|bDeviceProtocol)' 2>/dev/null `

Add for example: `  --device=/dev/bus/usb/001/002 ` .


### Commands:
##### Running containers:
    docker ps
##### Attach shell to container with:
    docker exec -it ContainerID /bin/bash
##### Stop FHEM inside container
    supervisorctl stop fhem
##### Start FHEM inside container
    supervisorctl start fhem
    
#### GUI FHEM:
    http://ipaddress:8083

#### GUI supervisord:
    http://ipaddress:9001


 
