<#
    Optional: Known default policy values for offline comparison.

    Use this file when you need to compare against a baseline without
    connecting to a "clean" tenant. The primary comparison method is
    runtime detection of the Global (Identity='Global') row.

    Format:
    @{
        'Get-CsTeamsMeetingPolicy' = @{
            AllowChannelMeetingScheduling = $true
            AllowMeetNow                  = $true
            # ...
        }
    }
#>
@{
    # Populated by running: .\Export-TeamsPolicies.ps1 -DefaultsOnly
    # against a tenant with unmodified default policies.
}
