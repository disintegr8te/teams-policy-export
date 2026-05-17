BeforeAll {
    Import-Module (Join-Path $PSScriptRoot '../Modules/TeamsPolicies.Utilities/TeamsPolicies.Utilities.psm1') -Force
    Import-Module (Join-Path $PSScriptRoot '../Modules/TeamsPolicies.Assignments/TeamsPolicies.Assignments.psm1') -Force
}

Describe 'ConvertTo-NormalizedAssignments' {
    It 'Normalizes user policy properties into rows' {
        $users = [System.Collections.Generic.List[object]]::new()
        $users.Add([pscustomobject]@{
            DisplayName       = 'Alice'
            UserPrincipalName = 'alice@contoso.com'
            Identity          = 'alice-id'
            TeamsMeetingPolicy    = 'AllOn'
            TeamsMessagingPolicy  = 'Custom1'
        })

        $rows = ConvertTo-NormalizedAssignments -Users $users
        $rows.Count | Should -Be 2
        $rows[0].PolicyType | Should -Match 'Policy'
        $rows[0].DisplayName | Should -Be 'Alice'
    }

    It 'Skips null/empty policy values' {
        $users = [System.Collections.Generic.List[object]]::new()
        $users.Add([pscustomobject]@{
            DisplayName       = 'Bob'
            UserPrincipalName = 'bob@contoso.com'
            Identity          = 'bob-id'
            TeamsMeetingPolicy    = 'Global'
            TeamsCallingPolicy    = $null
            SomethingElse         = 'not-a-policy'
        })

        $rows = ConvertTo-NormalizedAssignments -Users $users
        $rows.Count | Should -Be 1
        $rows[0].PolicyName | Should -Be 'Global'
    }
}

Describe 'ConvertTo-UserPolicySummaryRow' {
    It 'Creates a summary row with policy columns' {
        $user = [pscustomobject]@{
            DisplayName              = 'Carol'
            UserPrincipalName        = 'carol@contoso.com'
            Identity                 = 'carol-id'
            TeamsUpgradeEffectiveMode = 'TeamsOnly'
            EnterpriseVoiceEnabled    = $true
            TeamsMeetingPolicy        = 'RestrictedMeetings'
            TeamsMessagingPolicy      = $null
        }

        $row = ConvertTo-UserPolicySummaryRow -User $user
        $row.DisplayName | Should -Be 'Carol'
        $row.TeamsMeetingPolicy | Should -Be 'RestrictedMeetings'
        $row.PSObject.Properties.Name | Should -Not -Contain 'TeamsMessagingPolicy'
    }
}
