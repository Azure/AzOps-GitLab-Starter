try {
    $credential = New-Object PSCredential -ArgumentList $env:ARM_CLIENT_ID, (ConvertTo-SecureString -String $env:ARM_CLIENT_SECRET -AsPlainText -Force)
    Connect-AzAccount -TenantId $env:ARM_TENANT_ID -ServicePrincipal -Credential $credential -SubscriptionId $env:ARM_SUBSCRIPTION_ID -ErrorAction Stop
} catch {
    throw "Cannot connect to Azure - please verify credentials and variables"
}
