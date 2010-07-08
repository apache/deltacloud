$DELIM_BEGIN="<_OUTPUT>"
$DELIM_END="</_OUTPUT>"
$VM_PROPERTY_LIST="VmId", "Name", "Description", "TemplateId", "Domain", "Status", "OperatingSystem"
function beginOutput {
    echo $DELIM_BEGIN
}

function endOutput {
    echo $DELIM_END
}

function verifyLogin {
    param($username, $password, $domain)
    Login-User $username $password $domain
}

