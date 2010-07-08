param([string]$scriptsDir,
        [string]$username,
        [string]$password,
        [string]$domain,
        [string]$id)
# Get the common functions
. "$scriptsDir\common.ps1"
verifyLogin $username $password $domain
# The AppliacationList causes the YAML pain, so Omit it
stop-vm $id | format-list -Property $VM_PROPERTY_LIST
beginOutput
start-vm $id | format-list -Property $VM_PROPERTY_LIST
endOutput