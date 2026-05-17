function Get-TeamsPolicyCmdlets {
    <#
    .SYNOPSIS
        Discovers all exportable Teams policy/configuration cmdlets from the MicrosoftTeams module.
    .DESCRIPTION
        Filters cmdlets by include/exclude regex patterns and ensures they can run without mandatory parameters.
    #>
    param(
        [string[]]$IncludePatterns = @(
            '^Get-CsTeams.*Policy$',
            '^Get-CsTeams.*Configuration$',
            '^Get-CsTeamsMeetingBroadcastPolicy$',
            '^Get-CsTeamsEventsPolicy$',
            '^Get-CsOnline.*Policy$',
            '^Get-CsOnlineDialInConferencingTenantConfiguration$',
            '^Get-CsOnlineDialInConferencingTenantSettings$',
            '^Get-CsTenant.*Configuration$',
            '^Get-CsExternalAccessPolicy$',
            '^Get-CsApplicationAccessPolicy$',
            '^Get-CsPolicyPackage$'
        ),
        [string[]]$ExcludePatterns = @(
            '^Get-CsUserPolicyAssignment$',
            '^Get-CsOnlineUser$',
            '^Get-CsGroupPolicyAssignment$'
        )
    )

    $commands = Get-Command -Module MicrosoftTeams -CommandType Cmdlet, Function |
        Where-Object {
            $name = $_.Name
            (($IncludePatterns | Where-Object { $name -match $_ }).Count -gt 0) -and
            (($ExcludePatterns | Where-Object { $name -match $_ }).Count -eq 0) -and
            (Test-CanRunWithoutMandatoryParams -Command $_)
        } |
        Sort-Object Name -Unique

    $commands
}

function Invoke-PolicyCmdletSafe {
    <#
    .SYNOPSIS
        Invokes a Teams cmdlet with error handling. Returns a result object.
    #>
    param(
        [Parameter(Mandatory)][string]$CmdletName
    )

    try {
        Write-StepLog "Exporting $CmdletName..."
        $data = @(& $CmdletName -ErrorAction Stop)
        [pscustomobject]@{
            Success = $true
            Data    = $data
            Error   = $null
        }
    }
    catch {
        Write-StepLog "$CmdletName failed: $($_.Exception.Message)" -Level Warning
        [pscustomobject]@{
            Success = $false
            Data    = @()
            Error   = $_.Exception.Message
        }
    }
}

Export-ModuleMember -Function @(
    'Get-TeamsPolicyCmdlets',
    'Invoke-PolicyCmdletSafe'
)
