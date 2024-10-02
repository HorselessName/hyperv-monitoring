<#
.SYNOPSIS
    Script for monitoring Hyper-V servers.

.DESCRIPTION
    Provides LLD for virtual machines on the server and can extract JSON with the found virtual machine parameters for dependent items.
    Works only with PowerShell 3.0 and above.

.PARAMETER Action
    Specifies what we want to do - perform LLD or get the full JSON with metrics.

.PARAMETER Version
    Display the version number and exit.

.EXAMPLE
    zbx-hyperv.ps1 lld
    {"data":[{"`{#VM.NAME`}`":"vm01","`{#VM.VERSION`}`":"5.0","`{#VM.CLUSTERED`}`":0,"`{#VM.HOST`}`":"hv01","`{#VM.GEN`}`":2,"`{#VM.ISREPLICA`}`":0}

.EXAMPLE
    zbx-hyperv.ps1 full
    {"vm01":{"IntegrationServicesState":"","MemoryAssigned":0,"IntegrationServicesVersion":"","NumaSockets":1,"Uptime":0,"State":3,
    "NumaNodes":1,"CPUUsage":0,"Status":"Operating normally","ReplicationHealth":0,"ReplicationState":0}, ...}

.NOTES
    Original Author: Katsuuki Alexander
    On GitHub: https://github.com/asand3r/ (Page Deleted)
	Adapted / Improved By: Raul Chiarella
	On GitHub: https://github.com/HorselessName
#>

Param (
    [switch]$version = $False,
    [Parameter(Position=0,Mandatory=$False)][string]$action
)

# Script version
$VERSION_NUM="0.2.4"
if ($version) {
    Write-Host $VERSION_NUM
    break
}

# Low-level discovery function
function Make-LLD() {
    $vms = Get-VM | Select-Object @{Name = "{#VM.NAME}"; e={$_.VMName}},
                                  @{Name = "{#VM.VERSION}"; e={$_.Version}},
                                  @{Name = "{#VM.CLUSTERED}"; e={[int]$_.IsClustered}},
                                  @{Name = "{#VM.HOST}"; e={$_.ComputerName}},
                                  @{Name = "{#VM.GEN}"; e={$_.Generation}},
                                  @{Name = "{#VM.ISREPLICA}"; e={[int]$_.ReplicationMode}},
                                  @{Name = "{#VM.NOTES}"; e={$_.Notes}},
                                  @{Name = "{#VM.IP}"; e={
                                      $ips = $_ | Get-VMNetworkAdapter | Select-Object -ExpandProperty IPAddresses
                                      $ips -join ", "
                                  }}
    return ConvertTo-Json @{"data" = [array]$vms} -Compress
}

# Function to generate JSON for dependent items
function Get-FullJSON() {
    $to_json = @{}

    # Mapping the Integration Services State to numeric values for easier processing in monitoring tools like Zabbix:
    $integrationSvcState = @{
        "Up to date" = 0;
        "Update required" = 1;
        "" = 2  # Represents an unknown or null state
    }

    # Iterate over all VMs and gather detailed metrics for each VM
    Get-VM -ErrorAction SilentlyContinue | ForEach-Object {
        $vm_data = [psobject]@{
            "State" = [int]$_.State;
            "Uptime" = [math]::Round($_.Uptime.TotalSeconds);
            "NumaNodes" = $_.NumaNodesCount;
            "NumaSockets" = $_.NumaSocketCount;
            "IntSvcVer" = [string]$_.IntegrationServicesVersion;
            "IntSvcState" = $integrationSvcState[$_.IntegrationServicesState];
            "CPUUsage" = $_.CPUUsage;
            "Memory" = $_.MemoryAssigned;
            "ReplMode" = [int]$_.ReplicationMode;
            "ReplState" = [int]$_.ReplicationState;
            "ReplHealth" = [int]$_.ReplicationHealth;
            "StopAction" = [int]$_.AutomaticStopAction;
            "StartAction" = [int]$_.AutomaticStartAction;
            "CritErrAction" = [int]$_.AutomaticCriticalErrorAction;
            "IsClustered" = [int]$_.IsClustered
        }

        $to_json += @{$_.VMName = $vm_data}
    }

    return ConvertTo-Json $to_json -Compress
}

# Main switch (toggle)
switch ($action) {
    "lld" {
        Write-Host $(Make-LLD)
    }
    "full" {
        Write-Host $(Get-FullJSON)
    }
    Default {Write-Host "Syntax error: Use 'lld' or 'full' as first argument"}
}
