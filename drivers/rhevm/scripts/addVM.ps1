param([string]$scriptsDir,
        [string]$username,
        [string]$password,
        [string]$domain,
        [string]$templateId,
        [string]$name,
        [string]$storageId)
# Get the common functions
. "$scriptsDir\common.ps1"
verifyLogin $username $password $domain
$templ = get-template $templateId
beginOutput
add-vm -TemplateObject $templ -Name $name -StorageDomainId $storageId
endOutput