param (
    [ValidateSet("Validate","Push","Pull","Pull-Complete")]
    [string]$Action = '',
    $Body = ''
)
# Import config
Import-PSFConfig -Path settings.json -Schema MetaJson -EnableException

if ($Action -in 'Push','Validate') {
    Initialize-AzOpsEnvironment
    $diff = Get-Content -Path /tmp/diff.txt
}

function Invoke-GitLabRequest {
    param (
        [ValidateSet("POST","PUT")]
        $Method = '',
        $Body,
        $Path
    )
    # Validate that token exists
    if (-not $env:CI_CD_TOKEN) {
        throw "Cannot find CI_CD_TOKEN for the project"
    }

    # Create base request
    $gitLabrequest = @{
        Headers = @{
            'PRIVATE-TOKEN' = $($env:CI_CD_TOKEN)
        }
        Method = $Method
        Uri = "https://$($env:CI_SERVER_HOST)/api/v4/projects/$($env:CI_PROJECT_ID){0}" -f $Path
    }
    if ($Body) {
        $gitLabrequest.Body = @{
            body = $Body
        }
    }
    Invoke-RestMethod @gitLabrequest
}

switch ($Action) {
    'Validate' {
        if (Test-Path -Path "/tmp/diffdeletedfiles.txt") {
            $diffdeletedfiles = Get-Content -Path /tmp/diffdeletedfiles.txt
            Invoke-AzOpsPush -ChangeSet $diff -DeleteSetContents $diffdeletedfiles -WhatIf
        }
        else {
            Invoke-AzOpsPush -ChangeSet $diff -WhatIf
        }
        Get-Job | Remove-Job -Force

        Invoke-GitLabRequest -Method POST -Body (Get-Content -Raw /tmp/OUTPUT.md) -Path "/merge_requests/$($env:CI_MERGE_REQUEST_IID)/notes"
    }
    'Push' {
        if (Test-Path -Path "/tmp/diffdeletedfiles.txt") {
            $diffdeletedfiles = Get-Content -Path /tmp/diffdeletedfiles.txt
            Invoke-AzOpsPush -ChangeSet $diff -DeleteSetContents $diffdeletedfiles
        }
        else {
            Invoke-AzOpsPush -ChangeSet $diff
        }
        Get-Job | Remove-Job -Force
    }
    'Pull' {
        Invoke-AzOpsPull -Rebuild
        Get-Job | Remove-Job -Force
    }
    'Pull-Complete' {
        # Create merge request
        $mergeReq = Invoke-GitLabRequest -Method POST -Path "/merge_requests?source_branch=$($env:branch)&target_branch=$($env:CI_DEFAULT_BRANCH)&title=$($env:pull_request)"
        Start-Sleep 10
        # Auto approve merge request
        Invoke-GitLabRequest -Method POST -Path "/merge_requests/$($mergeReq.iid)/approve"
        # Auto accept merge request
        Invoke-GitLabRequest -Method PUT -Path "/merge_requests/$($mergeReq.iid)/merge?should_remove_source_branch=true&squash=true&squash_commit_message=Pull_from_Azure_to_automated_branch"
    }
}
