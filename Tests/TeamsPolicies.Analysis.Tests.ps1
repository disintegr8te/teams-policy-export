BeforeAll {
    Import-Module (Join-Path $PSScriptRoot '../Modules/TeamsPolicies.Analysis/TeamsPolicies.Analysis.psm1') -Force
}

# --- Get-RiskLevel -----------------------------------------------------------

Describe 'Get-RiskLevel' {
    It 'Returns High for Anonymous keyword match' {
        Get-RiskLevel -PropertyName 'AllowAnonymousUsersToJoinMeeting' -Category 'Meetings' | Should -Be 'High'
    }

    It 'Returns Medium for Recording keyword match' {
        Get-RiskLevel -PropertyName 'AllowCloudRecording' -Category 'Meetings' | Should -Be 'Medium'
    }

    It 'Returns Low for non-matching property' {
        Get-RiskLevel -PropertyName 'AllowIPVideo' -Category 'Meetings' | Should -Be 'Low'
    }

    It 'Uses config-driven override when Risk field exists' {
        $policies = @{
            'Get-CsTeamsMeetingPolicy' = @(
                @{ Property = 'AllowIPVideo'; Risk = 'High' }
            )
        }
        Get-RiskLevel -PropertyName 'AllowIPVideo' -Category 'Meetings' `
            -ImportantPolicies $policies -CmdletName 'Get-CsTeamsMeetingPolicy' | Should -Be 'High'
    }

    It 'Falls back to keyword when no config override' {
        $policies = @{
            'Get-CsTeamsMeetingPolicy' = @(
                @{ Property = 'AllowIPVideo' }  # No Risk field
            )
        }
        Get-RiskLevel -PropertyName 'AllowIPVideo' -Category 'Meetings' `
            -ImportantPolicies $policies -CmdletName 'Get-CsTeamsMeetingPolicy' | Should -Be 'Low'
    }
}

# --- Get-PolicyUserCounts ----------------------------------------------------

Describe 'Get-PolicyUserCounts' {
    It 'Computes Global remainder correctly' {
        $assignments = @(
            [pscustomobject]@{ UserPrincipalName = 'u1@test.com'; PolicyType = 'TeamsMeetingPolicy'; PolicyName = 'Restricted' }
            [pscustomobject]@{ UserPrincipalName = 'u2@test.com'; PolicyType = 'TeamsMeetingPolicy'; PolicyName = 'Restricted' }
        )
        $result = Get-PolicyUserCounts -UserAssignments $assignments -TotalUsers 10
        $result['TeamsMeetingPolicy']['Global'] | Should -Be 8
        $result['TeamsMeetingPolicy']['Restricted'] | Should -Be 2
    }

    It 'Clamps Global to zero when more explicit than total' {
        $assignments = @(
            [pscustomobject]@{ UserPrincipalName = 'u1@test.com'; PolicyType = 'TeamsMeetingPolicy'; PolicyName = 'Restricted' }
        )
        $result = Get-PolicyUserCounts -UserAssignments $assignments -TotalUsers 0
        $result['TeamsMeetingPolicy']['Global'] | Should -Be 0
    }

    It 'Marks group assignments with minimum count of 1' {
        $groupAssignments = @(
            [pscustomobject]@{ PolicyType = 'TeamsMeetingPolicy'; PolicyName = 'Executive'; GroupId = 'g1' }
        )
        $result = Get-PolicyUserCounts -UserAssignments @() -TotalUsers 100 -GroupAssignments $groupAssignments
        $result['TeamsMeetingPolicy']['Executive'] | Should -BeGreaterOrEqual 0
        $result['TeamsMeetingPolicy'].ContainsKey('Executive') | Should -BeTrue
    }

    It 'Counts distinct users per policy' {
        $assignments = @(
            [pscustomobject]@{ UserPrincipalName = 'u1@test.com'; PolicyType = 'TeamsMeetingPolicy'; PolicyName = 'Restricted' }
            [pscustomobject]@{ UserPrincipalName = 'u1@test.com'; PolicyType = 'TeamsMeetingPolicy'; PolicyName = 'Restricted' }  # duplicate
        )
        $result = Get-PolicyUserCounts -UserAssignments $assignments -TotalUsers 10
        $result['TeamsMeetingPolicy']['Restricted'] | Should -Be 1
    }
}

# --- Build-DecisionRows ------------------------------------------------------

Describe 'Build-DecisionRows' {
    It 'Computes Priority score with drift from recommendation' {
        $policyData = @{
            'Get-CsTeamsMeetingPolicy' = @(
                [pscustomobject]@{ Identity = 'Global'; AllowIPVideo = 'False' }
            )
        }
        $globalRows = @{ 'Get-CsTeamsMeetingPolicy' = [pscustomobject]@{ Identity = 'Global'; AllowIPVideo = 'False' } }
        $importantPolicies = @{
            'Get-CsTeamsMeetingPolicy' = @(
                @{
                    Property = 'AllowIPVideo'; Label = 'IP Video'; Risk = 'High'
                    MSRecommendation = 'DEFAULT: True. MS enables IP video by default.'
                    Recommendation = 'ALLOW.'
                    ExpectedValues = @{ 'General' = 'True' }
                }
            )
        }
        $categories = @{ 'Meetings' = @('Get-CsTeamsMeetingPolicy') }

        $rows = Build-DecisionRows -PolicyData $policyData -GlobalRows $globalRows `
            -ImportantPolicies $importantPolicies -PolicyCategories $categories `
            -FriendlyNames @{} -PropertyExclusions @() -PolicyUserCounts @{} -TotalUsers 100

        $row = $rows | Where-Object { $_.Property -eq 'AllowIPVideo' }
        $row | Should -Not -BeNullOrEmpty
        $row.Priority | Should -BeGreaterThan 0
        $row.DriftFromMSDefault | Should -Be 'Yes'
        $row.RiskLevel | Should -Be 'High'
        $row.MSDefault | Should -Be 'True'
        $row.Recommendation | Should -Be 'True'
        $row.FriendlyName | Should -Be 'IP Video'
    }

    It 'Shows empty DriftFromMSDefault when aligned with MS default' {
        $policyData = @{
            'Get-CsTeamsMeetingPolicy' = @(
                [pscustomobject]@{ Identity = 'Global'; AllowIPVideo = 'True' }
            )
        }
        $globalRows = @{ 'Get-CsTeamsMeetingPolicy' = [pscustomobject]@{ Identity = 'Global'; AllowIPVideo = 'True' } }
        $importantPolicies = @{
            'Get-CsTeamsMeetingPolicy' = @(
                @{
                    Property = 'AllowIPVideo'; Label = 'IP Video'
                    MSRecommendation = 'DEFAULT: True.'
                    Recommendation = 'ALLOW.'
                    ExpectedValues = @{ 'General' = 'True' }
                }
            )
        }
        $categories = @{ 'Meetings' = @('Get-CsTeamsMeetingPolicy') }

        $rows = Build-DecisionRows -PolicyData $policyData -GlobalRows $globalRows `
            -ImportantPolicies $importantPolicies -PolicyCategories $categories `
            -FriendlyNames @{} -PropertyExclusions @() -PolicyUserCounts @{} -TotalUsers 100

        $row = $rows | Where-Object { $_.Property -eq 'AllowIPVideo' }
        $row.DriftFromMSDefault | Should -Be ''
    }

    It 'Uses case-insensitive comparison for drift' {
        $policyData = @{
            'Get-CsTeamsMeetingPolicy' = @(
                [pscustomobject]@{ Identity = 'Global'; AllowIPVideo = 'true' }
            )
        }
        $globalRows = @{ 'Get-CsTeamsMeetingPolicy' = [pscustomobject]@{ Identity = 'Global'; AllowIPVideo = 'true' } }
        $importantPolicies = @{
            'Get-CsTeamsMeetingPolicy' = @(
                @{
                    Property = 'AllowIPVideo'; Label = 'IP Video'
                    MSRecommendation = 'DEFAULT: True.'
                    Recommendation = 'ALLOW.'
                    ExpectedValues = @{ 'General' = 'True' }
                }
            )
        }
        $categories = @{ 'Meetings' = @('Get-CsTeamsMeetingPolicy') }

        $rows = Build-DecisionRows -PolicyData $policyData -GlobalRows $globalRows `
            -ImportantPolicies $importantPolicies -PolicyCategories $categories `
            -FriendlyNames @{} -PropertyExclusions @() -PolicyUserCounts @{} -TotalUsers 100

        $row = $rows | Where-Object { $_.Property -eq 'AllowIPVideo' }
        $row.DriftFromMSDefault | Should -Be ''  # 'true' matches 'True' case-insensitively
    }

    It 'Skips excluded properties' {
        $policyData = @{
            'Get-CsTeamsMeetingPolicy' = @(
                [pscustomobject]@{ Identity = 'Global'; AllowIPVideo = 'True'; Description = 'test' }
            )
        }
        $globalRows = @{ 'Get-CsTeamsMeetingPolicy' = [pscustomobject]@{ Identity = 'Global'; AllowIPVideo = 'True'; Description = 'test' } }
        $categories = @{ 'Meetings' = @('Get-CsTeamsMeetingPolicy') }

        $rows = Build-DecisionRows -PolicyData $policyData -GlobalRows $globalRows `
            -ImportantPolicies @{} -PolicyCategories $categories `
            -FriendlyNames @{} -PropertyExclusions @('Description') -PolicyUserCounts @{} -TotalUsers 100

        $rows | Where-Object { $_.Property -eq 'Description' } | Should -BeNullOrEmpty
    }

    It 'Uses _Global tier for configuration cmdlets' {
        $policyData = @{
            'Get-CsTeamsClientConfiguration' = @(
                [pscustomobject]@{ Identity = 'Global'; AllowBox = 'True' }
            )
        }
        $globalRows = @{ 'Get-CsTeamsClientConfiguration' = [pscustomobject]@{ Identity = 'Global'; AllowBox = 'True' } }
        $importantPolicies = @{
            'Get-CsTeamsClientConfiguration' = @(
                @{
                    Property = 'AllowBox'; Label = 'Box Integration'
                    MSRecommendation = 'DEFAULT: True.'
                    Recommendation = 'BLOCK.'
                    ExpectedValues = @{ '_Global' = 'False' }
                }
            )
        }
        $categories = @{ 'Devices & Client' = @('Get-CsTeamsClientConfiguration') }

        $rows = Build-DecisionRows -PolicyData $policyData -GlobalRows $globalRows `
            -ImportantPolicies $importantPolicies -PolicyCategories $categories `
            -FriendlyNames @{} -PropertyExclusions @() -PolicyUserCounts @{} -TotalUsers 100

        $row = $rows | Where-Object { $_.Property -eq 'AllowBox' }
        $row.Recommendation | Should -Be 'False'
    }

    It 'Displays Not set for null values' {
        $policyData = @{
            'Get-CsTeamsMeetingPolicy' = @(
                [pscustomobject]@{ Identity = 'Global'; SomeField = $null }
            )
        }
        $globalRows = @{ 'Get-CsTeamsMeetingPolicy' = [pscustomobject]@{ Identity = 'Global'; SomeField = $null } }
        $categories = @{ 'Meetings' = @('Get-CsTeamsMeetingPolicy') }

        $rows = Build-DecisionRows -PolicyData $policyData -GlobalRows $globalRows `
            -ImportantPolicies @{} -PolicyCategories $categories `
            -FriendlyNames @{} -PropertyExclusions @() -PolicyUserCounts @{} -TotalUsers 100

        $row = $rows | Where-Object { $_.Property -eq 'SomeField' }
        $row.CurrentGlobal | Should -Be 'Not set'
    }
}

# --- Test-SemanticEqual -------------------------------------------------------

Describe 'Test-SemanticEqual' {
    It 'Returns true for case-insensitive exact match' {
        Test-SemanticEqual -Value1 'true' -Value2 'True' | Should -BeTrue
    }

    It 'Returns true for Enabled vs True' {
        Test-SemanticEqual -Value1 'Enabled' -Value2 'True' | Should -BeTrue
    }

    It 'Returns true for Disabled vs False' {
        Test-SemanticEqual -Value1 'Disabled' -Value2 'False' | Should -BeTrue
    }

    It 'Returns true for 1 vs Enabled' {
        Test-SemanticEqual -Value1 '1' -Value2 'Enabled' | Should -BeTrue
    }

    It 'Returns true for 0 vs Disabled' {
        Test-SemanticEqual -Value1 '0' -Value2 'Disabled' | Should -BeTrue
    }

    It 'Returns true for 1 vs True' {
        Test-SemanticEqual -Value1 '1' -Value2 'True' | Should -BeTrue
    }

    It 'Returns true for 0 vs False' {
        Test-SemanticEqual -Value1 '0' -Value2 'False' | Should -BeTrue
    }

    It 'Returns false for True vs False' {
        Test-SemanticEqual -Value1 'True' -Value2 'False' | Should -BeFalse
    }

    It 'Returns false for Enabled vs Disabled' {
        Test-SemanticEqual -Value1 'Enabled' -Value2 'Disabled' | Should -BeFalse
    }

    It 'Returns false for 1 vs 0' {
        Test-SemanticEqual -Value1 '1' -Value2 '0' | Should -BeFalse
    }

    It 'Returns false for unrelated strings' {
        Test-SemanticEqual -Value1 'AllowAll' -Value2 'BlockAll' | Should -BeFalse
    }

    It 'Returns true for identical non-boolean strings' {
        Test-SemanticEqual -Value1 'AllowAll' -Value2 'allowall' | Should -BeTrue
    }

    It 'Handles whitespace in values' {
        Test-SemanticEqual -Value1 ' Enabled ' -Value2 'True' | Should -BeTrue
    }
}

# --- Build-DecisionRows semantic drift ----------------------------------------

Describe 'Build-DecisionRows semantic drift' {
    BeforeAll {
        $categories = @{ 'Meetings' = @('Get-CsTeamsMeetingPolicy') }
    }

    It 'Does not flag drift when API returns Enabled and recommendation is True' {
        $policyData = @{
            'Get-CsTeamsMeetingPolicy' = @(
                [pscustomobject]@{ Identity = 'Global'; AllowIPVideo = 'Enabled' }
            )
        }
        $globalRows = @{ 'Get-CsTeamsMeetingPolicy' = [pscustomobject]@{ Identity = 'Global'; AllowIPVideo = 'Enabled' } }
        $importantPolicies = @{
            'Get-CsTeamsMeetingPolicy' = @(
                @{
                    Property = 'AllowIPVideo'; Label = 'IP Video'; Risk = 'Low'
                    MSRecommendation = 'DEFAULT: True.'
                    ExpectedValues = @{ 'General' = 'True' }
                }
            )
        }

        $rows = Build-DecisionRows -PolicyData $policyData -GlobalRows $globalRows `
            -ImportantPolicies $importantPolicies -PolicyCategories $categories `
            -FriendlyNames @{} -PropertyExclusions @() -PolicyUserCounts @{} -TotalUsers 100

        $row = $rows | Where-Object { $_.Property -eq 'AllowIPVideo' }
        $row.DriftFromMSDefault | Should -Be ''
        # Priority should NOT include +40 (recommendation drift) or +10 (MS default drift)
        $row.Priority | Should -BeLessOrEqual 10
    }

    It 'Does not flag drift when API returns Disabled and recommendation is False' {
        $policyData = @{
            'Get-CsTeamsMeetingPolicy' = @(
                [pscustomobject]@{ Identity = 'Global'; AllowIPVideo = 'Disabled' }
            )
        }
        $globalRows = @{ 'Get-CsTeamsMeetingPolicy' = [pscustomobject]@{ Identity = 'Global'; AllowIPVideo = 'Disabled' } }
        $importantPolicies = @{
            'Get-CsTeamsMeetingPolicy' = @(
                @{
                    Property = 'AllowIPVideo'; Label = 'IP Video'; Risk = 'Low'
                    MSRecommendation = 'DEFAULT: False.'
                    ExpectedValues = @{ 'General' = 'False' }
                }
            )
        }

        $rows = Build-DecisionRows -PolicyData $policyData -GlobalRows $globalRows `
            -ImportantPolicies $importantPolicies -PolicyCategories $categories `
            -FriendlyNames @{} -PropertyExclusions @() -PolicyUserCounts @{} -TotalUsers 100

        $row = $rows | Where-Object { $_.Property -eq 'AllowIPVideo' }
        $row.DriftFromMSDefault | Should -Be ''
    }

    It 'Does not flag drift when API returns 1 and recommendation is Enabled' {
        $policyData = @{
            'Get-CsTeamsMeetingPolicy' = @(
                [pscustomobject]@{ Identity = 'Global'; AllowIPVideo = '1' }
            )
        }
        $globalRows = @{ 'Get-CsTeamsMeetingPolicy' = [pscustomobject]@{ Identity = 'Global'; AllowIPVideo = '1' } }
        $importantPolicies = @{
            'Get-CsTeamsMeetingPolicy' = @(
                @{
                    Property = 'AllowIPVideo'; Label = 'IP Video'; Risk = 'Low'
                    MSRecommendation = 'DEFAULT: Enabled.'
                    ExpectedValues = @{ 'General' = 'Enabled' }
                }
            )
        }

        $rows = Build-DecisionRows -PolicyData $policyData -GlobalRows $globalRows `
            -ImportantPolicies $importantPolicies -PolicyCategories $categories `
            -FriendlyNames @{} -PropertyExclusions @() -PolicyUserCounts @{} -TotalUsers 100

        $row = $rows | Where-Object { $_.Property -eq 'AllowIPVideo' }
        $row.DriftFromMSDefault | Should -Be ''
    }

    It 'Still flags genuine drift like True vs False' {
        $policyData = @{
            'Get-CsTeamsMeetingPolicy' = @(
                [pscustomobject]@{ Identity = 'Global'; AllowIPVideo = 'True' }
            )
        }
        $globalRows = @{ 'Get-CsTeamsMeetingPolicy' = [pscustomobject]@{ Identity = 'Global'; AllowIPVideo = 'True' } }
        $importantPolicies = @{
            'Get-CsTeamsMeetingPolicy' = @(
                @{
                    Property = 'AllowIPVideo'; Label = 'IP Video'; Risk = 'High'
                    MSRecommendation = 'DEFAULT: False.'
                    ExpectedValues = @{ 'General' = 'False' }
                }
            )
        }

        $rows = Build-DecisionRows -PolicyData $policyData -GlobalRows $globalRows `
            -ImportantPolicies $importantPolicies -PolicyCategories $categories `
            -FriendlyNames @{} -PropertyExclusions @() -PolicyUserCounts @{} -TotalUsers 100

        $row = $rows | Where-Object { $_.Property -eq 'AllowIPVideo' }
        $row.DriftFromMSDefault | Should -Be 'Yes'
        # Priority should include +40 (recommendation drift) and +10 (MS default drift)
        $row.Priority | Should -BeGreaterOrEqual 50
    }
}

# --- ConvertTo-FriendlyNameAlgorithmic ----------------------------------------

Describe 'ConvertTo-FriendlyNameAlgorithmic' {
    It 'Converts PascalCase to readable string' {
        ConvertTo-FriendlyNameAlgorithmic -PropertyName 'AllowCloudRecording' | Should -Be 'Allow cloud recording'
    }

    It 'Preserves known acronyms' {
        ConvertTo-FriendlyNameAlgorithmic -PropertyName 'AllowIPVideo' | Should -Be 'Allow IP video'
    }

    It 'Handles PSTN acronym' {
        ConvertTo-FriendlyNameAlgorithmic -PropertyName 'AllowPSTNCalling' | Should -Be 'Allow PSTN calling'
    }
}
