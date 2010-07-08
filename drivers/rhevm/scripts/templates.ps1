param([string]$scriptsDir,
        [string]$username,
        [string]$password,
        [string]$domain)
# Get the common functions
. "$scriptsDir\common.ps1"
verifyLogin $username $password $domain
beginOutput
select-template *
endOutput