# zbx-hyperv (Updated for Zabbix 6.2)
PowerShell script for Zabbix to monitor Hyper-V servers, now updated for Zabbix version 6.2.

This project is a continuation and enhancement of the original "zbx-hyperv" script by @asand3r, which was designed for Zabbix 4.4. The original project provided the ability to perform Low-Level Discovery (LLD) of Hyper-V server VMs and retrieve their parameters, such as "Memory Assigned," "CPU Usage," "State," and more.

The original GitHub repository by @asand3r is no longer available (returns a 404 Not Found). However, this updated version maintains the same functionality while adding support for Zabbix 6.2 and its new features.

**Latest stable version:** 0.2.5 (original), updated for Zabbix 6.2.

__Please, read the updated [Requirements and Installation](https://github.com/HorselessName/hyperv-monitoring/wiki/Requirements-and-Installation) section in the Wiki before use.__

![Hyper-V Monitoring](https://pp.userapi.com/c831508/v831508836/1d54c4/aL5ve9-JYSc.jpg)
![Zabbix Monitoring](https://pp.userapi.com/c831508/v831508836/1d54ce/WtGekdXFRHk.jpg)

## Dependencies
 - PowerShell v3.0+

## Feautres  
**Low Level Discovery:**
 - [x] Virtual Machines
 - [x] Hyper-V Services

**Component status:**
 - [x] JSON for dependent items for VMs

## Supported arguments  
**-action**  
What we want to do - make LLD or get JSON with metric for dependent items (takes: lld, full)  
**-version**  
Print script version and exit.  

## Usage 
- LLD of virtual machines:
```powershell
PS C:\> .\zbx-hyperv.ps1 lld
{"data":[{"{#VM.NAME}":"vm01","{#VM.VERSION}":"5.0","{#VM.CLUSTERED}":1,"{#VM.HOST}":"hv01","{#VM.GEN}":2,"{#VM.ISREPLICA}":0}, ...}
```
- Request JSON with all VMs metrics:
```powershell
PS C:\> .\zbx-hyperv.ps1 full
{"vm01":{"IntSvcVer":"6.3.9600.18692","ReplMode":0,"Memory":4294967296,"ReplState":0,"NumaSockets":1,"Uptime":53505,"State":2,
"NumaNodes":1,"ReplHealth":0,"CPUUsage":0,"IntSvcState":0},...}
```

## Zabbix Templates
This repository includes a preconfigured Zabbix Template updated for version 6.2, building on the original template designed for Zabbix 4.0 and above. The updated template utilizes Low-Level Discovery (LLD) functionality to monitor Hyper-V servers and their VMs.

**Important:** This template is specifically designed for Zabbix 6.2 and is not compatible with earlier versions such as 3.0, 3.2, 3.4, or even 4.x. If you are using an older version of Zabbix, please refer to the original repository (if available) or consider upgrading to benefit from the latest features and improvements.

**Tested with**:  
Hyper-V on Windows Server 2012, 2012 R2 and 2016 and doesn't work with Hyper-V 2008 R2 and lower.
