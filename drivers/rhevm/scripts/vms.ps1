param([string]$scriptsDir,
        [string]$username,
        [string]$password,
        [string]$domain)
# Get the common functions
. "$scriptsDir\common.ps1"
verifyLogin $username $password $domain
beginOutput
# The AppliacationList causes the YAML pain, so Omit it
select-vm * | format-list -Property "VmId", "Name", "Description", "TemplateId", "Domain", "Status", "OperatingSystem"
endOutput