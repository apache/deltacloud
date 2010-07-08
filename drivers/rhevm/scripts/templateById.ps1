param([string]$scriptsDir,
        [string]$username,
        [string]$password,
        [string]$domain,
        [string]$id)

# Get the common functions
. "$scriptsDir\common.ps1"
verifyLogin $username $password $domain
beginOutput
get-template $id
endOutput