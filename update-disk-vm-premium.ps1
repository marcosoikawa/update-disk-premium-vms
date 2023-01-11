Write-Verbose "https://github.com/marcosoikawa/update-disk-premium-vms" -Verbose

# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process
# Connect to Azure with system-assigned managed identity
$AzureContext = (Connect-AzAccount -Identity).context
# set and store context
$AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext
# If you have multiple subscriptions, set the one to use
# Select-AzSubscription -SubscriptionId "<SUBSCRIPTIONID>"

Write-Verbose "Subscription to work against: $AzureContext.Subscription" -Verbose

$storageType = 'Premium_LRS'

# Name of the resource group that contains the VM
$rgName = 'Hiro-VMs'

Write-Verbose "Working on this Resrouce Group: $rgName" -Verbose

# Get all disks in the resource group of the VM
$vmDisks = Get-AzDisk -ResourceGroupName $rgName 

# For disks that belong to the selected VM, convert to Premium storage
foreach ($disk in $vmDisks)
{
    $diskName = $disk.Name
    Write-Verbose "Working on disk: $diskName" -Verbose
    $disk.Sku = [Microsoft.Azure.Management.Compute.Models.DiskSku]::new($storageType)
    $disk | Update-AzDisk
    Write-Verbose "Updated!" -Verbose
}
