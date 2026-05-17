BeforeAll {
    Import-Module (Join-Path $PSScriptRoot '../Modules/TeamsPolicies.Utilities/TeamsPolicies.Utilities.psm1') -Force
    Import-Module (Join-Path $PSScriptRoot '../Modules/TeamsPolicies.Apply/TeamsPolicies.Apply.psm1') -Force
}

# --- ConvertTo-PolicyValue --------------------------------------------------

Describe 'ConvertTo-PolicyValue' {
    It 'Converts "True" to boolean $true' {
        ConvertTo-PolicyValue -Value 'True' | Should -Be $true
        ConvertTo-PolicyValue -Value 'True' | Should -BeOfType [bool]
    }

    It 'Converts "False" to boolean $false' {
        ConvertTo-PolicyValue -Value 'False' | Should -Be $false
        ConvertTo-PolicyValue -Value 'False' | Should -BeOfType [bool]
    }

    It 'Converts integer strings to [int]' {
        ConvertTo-PolicyValue -Value '42' | Should -Be 42
        ConvertTo-PolicyValue -Value '42' | Should -BeOfType [int]
    }

    It 'Converts zero to [int]' {
        ConvertTo-PolicyValue -Value '0' | Should -Be 0
        ConvertTo-PolicyValue -Value '0' | Should -BeOfType [int]
    }

    It 'Converts negative numbers to [int]' {
        ConvertTo-PolicyValue -Value '-1' | Should -Be -1
        ConvertTo-PolicyValue -Value '-1' | Should -BeOfType [int]
    }

    It 'Returns enum strings as-is' {
        ConvertTo-PolicyValue -Value 'EveryoneInCompany' | Should -Be 'EveryoneInCompany'
        ConvertTo-PolicyValue -Value 'EveryoneInCompany' | Should -BeOfType [string]
    }

    It 'Returns "Enabled" as string' {
        ConvertTo-PolicyValue -Value 'Enabled' | Should -Be 'Enabled'
    }

    It 'Returns "Disabled" as string' {
        ConvertTo-PolicyValue -Value 'Disabled' | Should -Be 'Disabled'
    }

    It 'Returns "EntireScreen" as string' {
        ConvertTo-PolicyValue -Value 'EntireScreen' | Should -Be 'EntireScreen'
    }
}

# --- ConvertTo-PolicyCommands -----------------------------------------------

Describe 'ConvertTo-PolicyCommands' {
    BeforeAll {
        $testMapping = @{
            'Get-CsTeamsMeetingPolicy'    = 'Set-CsTeamsMeetingPolicy'
            'Get-CsTeamsMessagingPolicy'   = 'Set-CsTeamsMessagingPolicy'
            'Get-CsTeamsCallingPolicy'     = 'Set-CsTeamsCallingPolicy'
        }
    }

    It 'Maps Get-Cs* to Set-Cs* cmdlet names' {
        $decisions = @(
            [pscustomobject]@{
                Cmdlet = 'Get-CsTeamsMeetingPolicy'; Property = 'AllowCloudRecording'
                CurrentValue = 'False'; DecisionValue = 'True'; Category = 'Meetings'
                Setting = 'Cloud Recording'; RiskLevel = 'Medium'; UsersOnGlobal = 1000
                UsersOnOther = 50; Notes = ''; IsKeep = $false; IsNoChange = $false
            }
        )

        $commands = ConvertTo-PolicyCommands -Decisions $decisions -CmdletMapping $testMapping
        $commands.Count | Should -Be 1
        $commands[0].SetCmdlet | Should -Be 'Set-CsTeamsMeetingPolicy'
    }

    It 'Falls back to Get- to Set- replacement for unknown cmdlets' {
        $decisions = @(
            [pscustomobject]@{
                Cmdlet = 'Get-CsTeamsNewPolicy'; Property = 'SomeProp'
                CurrentValue = 'Old'; DecisionValue = 'New'; Category = 'Other'
                Setting = 'Some Setting'; RiskLevel = 'Low'; UsersOnGlobal = 100
                UsersOnOther = 0; Notes = ''; IsKeep = $false; IsNoChange = $false
            }
        )

        $commands = ConvertTo-PolicyCommands -Decisions $decisions -CmdletMapping @{}
        $commands[0].SetCmdlet | Should -Be 'Set-CsTeamsNewPolicy'
    }

    It 'Groups multiple changes for the same cmdlet' {
        $decisions = @(
            [pscustomobject]@{
                Cmdlet = 'Get-CsTeamsMeetingPolicy'; Property = 'AllowCloudRecording'
                CurrentValue = 'False'; DecisionValue = 'True'; Category = 'Meetings'
                Setting = 'Cloud Recording'; RiskLevel = 'Medium'; UsersOnGlobal = 1000
                UsersOnOther = 50; Notes = ''; IsKeep = $false; IsNoChange = $false
            },
            [pscustomobject]@{
                Cmdlet = 'Get-CsTeamsMeetingPolicy'; Property = 'AllowTranscription'
                CurrentValue = 'False'; DecisionValue = 'True'; Category = 'Meetings'
                Setting = 'Transcription'; RiskLevel = 'Medium'; UsersOnGlobal = 1000
                UsersOnOther = 50; Notes = ''; IsKeep = $false; IsNoChange = $false
            }
        )

        $commands = ConvertTo-PolicyCommands -Decisions $decisions -CmdletMapping $testMapping
        $commands.Count | Should -Be 1
        $commands[0].Parameters.Count | Should -Be 3  # 2 properties + Identity
        $commands[0].Parameters['AllowCloudRecording'] | Should -Be $true
        $commands[0].Parameters['AllowTranscription'] | Should -Be $true
        $commands[0].Parameters['Identity'] | Should -Be 'Global'
    }

    It 'Skips Keep decisions' {
        $decisions = @(
            [pscustomobject]@{
                Cmdlet = 'Get-CsTeamsMeetingPolicy'; Property = 'AllowCloudRecording'
                CurrentValue = 'True'; DecisionValue = 'Keep'; Category = 'Meetings'
                Setting = 'Cloud Recording'; RiskLevel = 'Medium'; UsersOnGlobal = 1000
                UsersOnOther = 50; Notes = ''; IsKeep = $true; IsNoChange = $false
            }
        )

        $commands = ConvertTo-PolicyCommands -Decisions $decisions -CmdletMapping $testMapping
        $commands.Count | Should -Be 0
    }

    It 'Skips decisions where value already matches current' {
        $decisions = @(
            [pscustomobject]@{
                Cmdlet = 'Get-CsTeamsMeetingPolicy'; Property = 'AllowCloudRecording'
                CurrentValue = 'True'; DecisionValue = 'True'; Category = 'Meetings'
                Setting = 'Cloud Recording'; RiskLevel = 'Medium'; UsersOnGlobal = 1000
                UsersOnOther = 50; Notes = ''; IsKeep = $false; IsNoChange = $true
            }
        )

        $commands = ConvertTo-PolicyCommands -Decisions $decisions -CmdletMapping $testMapping
        $commands.Count | Should -Be 0
    }

    It 'Converts boolean string values in parameters' {
        $decisions = @(
            [pscustomobject]@{
                Cmdlet = 'Get-CsTeamsMeetingPolicy'; Property = 'AllowCloudRecording'
                CurrentValue = 'False'; DecisionValue = 'True'; Category = 'Meetings'
                Setting = 'Cloud Recording'; RiskLevel = 'Medium'; UsersOnGlobal = 1000
                UsersOnOther = 50; Notes = ''; IsKeep = $false; IsNoChange = $false
            }
        )

        $commands = ConvertTo-PolicyCommands -Decisions $decisions -CmdletMapping $testMapping
        $commands[0].Parameters['AllowCloudRecording'] | Should -BeOfType [bool]
        $commands[0].Parameters['AllowCloudRecording'] | Should -Be $true
    }

    It 'Preserves enum string values in parameters' {
        $decisions = @(
            [pscustomobject]@{
                Cmdlet = 'Get-CsTeamsMeetingPolicy'; Property = 'AutoAdmittedUsers'
                CurrentValue = 'Everyone'; DecisionValue = 'EveryoneInCompany'; Category = 'Meetings'
                Setting = 'Lobby Bypass'; RiskLevel = 'High'; UsersOnGlobal = 1000
                UsersOnOther = 50; Notes = ''; IsKeep = $false; IsNoChange = $false
            }
        )

        $commands = ConvertTo-PolicyCommands -Decisions $decisions -CmdletMapping $testMapping
        $commands[0].Parameters['AutoAdmittedUsers'] | Should -Be 'EveryoneInCompany'
        $commands[0].Parameters['AutoAdmittedUsers'] | Should -BeOfType [string]
    }

    It 'Returns AffectedSettings list' {
        $decisions = @(
            [pscustomobject]@{
                Cmdlet = 'Get-CsTeamsMeetingPolicy'; Property = 'AllowCloudRecording'
                CurrentValue = 'False'; DecisionValue = 'True'; Category = 'Meetings'
                Setting = 'Cloud Recording'; RiskLevel = 'Medium'; UsersOnGlobal = 1000
                UsersOnOther = 50; Notes = ''; IsKeep = $false; IsNoChange = $false
            }
        )

        $commands = ConvertTo-PolicyCommands -Decisions $decisions -CmdletMapping $testMapping
        $commands[0].AffectedSettings.Count | Should -Be 1
        $commands[0].AffectedSettings[0] | Should -BeLike '*Cloud Recording*'
    }
}

# --- Import-DecisionSheet (mock data) ---------------------------------------

Describe 'Import-DecisionSheet' {
    BeforeAll {
        # We need ImportExcel for these tests; skip if not available
        $hasImportExcel = $null -ne (Get-Module -ListAvailable -Name ImportExcel)
    }

    It 'Requires a valid file path' {
        { Import-DecisionSheet -Path 'C:\nonexistent\file.xlsx' } | Should -Throw
    }

    It 'Parses decisions from an Excel file' -Skip:(-not $hasImportExcel) {
        # Create a test Excel file
        $testPath = Join-Path $TestDrive 'test-decisions.xlsx'

        $data = @(
            [pscustomobject]@{
                Category = 'Meetings'; Setting = 'Cloud Recording'; Property = 'AllowCloudRecording'
                Cmdlet = 'Get-CsTeamsMeetingPolicy'; 'MS Default' = 'True'; 'Current Global' = 'False'
                Recommendation = 'True'; Risk = 'Medium'; 'Users on Global' = 1000
                'Users on Other' = 50; DECISION = 'True'; Notes = 'Enable for all'
            },
            [pscustomobject]@{
                Category = 'Meetings'; Setting = 'Transcription'; Property = 'AllowTranscription'
                Cmdlet = 'Get-CsTeamsMeetingPolicy'; 'MS Default' = 'True'; 'Current Global' = 'True'
                Recommendation = 'True'; Risk = 'Medium'; 'Users on Global' = 1000
                'Users on Other' = 50; DECISION = ''; Notes = ''
            },
            [pscustomobject]@{
                Category = 'Meetings'; Setting = 'Lobby Bypass'; Property = 'AutoAdmittedUsers'
                Cmdlet = 'Get-CsTeamsMeetingPolicy'; 'MS Default' = 'EveryoneInCompany'
                'Current Global' = 'Everyone'; Recommendation = 'EveryoneInCompany'; Risk = 'High'
                'Users on Global' = 1000; 'Users on Other' = 50; DECISION = 'Keep'; Notes = ''
            }
        )

        $data | Export-Excel -Path $testPath -WorksheetName 'All Decisions'

        $decisions = Import-DecisionSheet -Path $testPath
        $decisions.Count | Should -Be 2  # One skipped (empty DECISION)

        $trueDecision = $decisions | Where-Object { $_.Property -eq 'AllowCloudRecording' }
        $trueDecision.DecisionValue | Should -Be 'True'
        $trueDecision.IsKeep | Should -Be $false

        $keepDecision = $decisions | Where-Object { $_.Property -eq 'AutoAdmittedUsers' }
        $keepDecision.DecisionValue | Should -Be 'Keep'
        $keepDecision.IsKeep | Should -Be $true
    }

    It 'Flags decisions that match current value as IsNoChange' -Skip:(-not $hasImportExcel) {
        $testPath = Join-Path $TestDrive 'test-nochange.xlsx'

        $data = @(
            [pscustomobject]@{
                Category = 'Meetings'; Setting = 'Recording'; Property = 'AllowCloudRecording'
                Cmdlet = 'Get-CsTeamsMeetingPolicy'; 'MS Default' = 'True'
                'Current Global' = 'True'; Recommendation = 'True'; Risk = 'Medium'
                'Users on Global' = 1000; 'Users on Other' = 50; DECISION = 'True'; Notes = ''
            }
        )

        $data | Export-Excel -Path $testPath -WorksheetName 'All Decisions'

        $decisions = Import-DecisionSheet -Path $testPath
        $decisions.Count | Should -Be 1
        $decisions[0].IsNoChange | Should -Be $true
    }
}

# --- New-PolicyChangeReport ------------------------------------------------

Describe 'New-PolicyChangeReport' {
    It 'Generates a report with correct counts' {
        $decisions = @(
            [pscustomobject]@{
                Cmdlet = 'Get-CsTeamsMeetingPolicy'; Property = 'AllowCloudRecording'
                CurrentValue = 'False'; DecisionValue = 'True'; Category = 'Meetings'
                Setting = 'Cloud Recording'; RiskLevel = 'Medium'; UsersOnGlobal = 1000
                UsersOnOther = 50; Notes = ''; IsKeep = $false; IsNoChange = $false
            },
            [pscustomobject]@{
                Cmdlet = 'Get-CsTeamsMeetingPolicy'; Property = 'AllowTranscription'
                CurrentValue = 'True'; DecisionValue = 'Keep'; Category = 'Meetings'
                Setting = 'Transcription'; RiskLevel = 'Medium'; UsersOnGlobal = 1000
                UsersOnOther = 50; Notes = ''; IsKeep = $true; IsNoChange = $false
            },
            [pscustomobject]@{
                Cmdlet = 'Get-CsTeamsMeetingPolicy'; Property = 'AllowReactions'
                CurrentValue = 'True'; DecisionValue = 'True'; Category = 'Meetings'
                Setting = 'Reactions'; RiskLevel = 'Low'; UsersOnGlobal = 1000
                UsersOnOther = 50; Notes = ''; IsKeep = $false; IsNoChange = $true
            }
        )

        $report = New-PolicyChangeReport -Decisions $decisions
        $report | Should -BeLike '*Settings to CHANGE:     1*'
        $report | Should -BeLike '*Settings to KEEP:       1*'
        $report | Should -BeLike '*Already matching:       1*'
    }

    It 'Saves report to file when OutputPath specified' {
        $decisions = @(
            [pscustomobject]@{
                Cmdlet = 'Get-CsTeamsMeetingPolicy'; Property = 'AllowCloudRecording'
                CurrentValue = 'False'; DecisionValue = 'True'; Category = 'Meetings'
                Setting = 'Cloud Recording'; RiskLevel = 'High'; UsersOnGlobal = 1000
                UsersOnOther = 50; Notes = ''; IsKeep = $false; IsNoChange = $false
            }
        )

        $reportPath = Join-Path $TestDrive 'test-report.txt'
        New-PolicyChangeReport -Decisions $decisions -OutputPath $reportPath

        Test-Path $reportPath | Should -Be $true
        $content = Get-Content $reportPath -Raw
        $content | Should -BeLike '*HIGH RISK CHANGES*'
    }
}

# --- Export-PolicyScript ----------------------------------------------------

Describe 'Export-PolicyScript' {
    It 'Generates a valid PowerShell script file' {
        $commands = @(
            [pscustomobject]@{
                GetCmdlet = 'Get-CsTeamsMeetingPolicy'
                SetCmdlet = 'Set-CsTeamsMeetingPolicy'
                Parameters = [ordered]@{
                    AllowCloudRecording = $true
                    AllowTranscription  = $true
                    Identity            = 'Global'
                }
                AffectedSettings = @('Cloud Recording (AllowCloudRecording)', 'Transcription (AllowTranscription)')
                Category = 'Meetings'
            }
        )

        $scriptPath = Join-Path $TestDrive 'test-apply.ps1'
        $result = Export-PolicyScript -Commands $commands -OutputPath $scriptPath -SourceExcel 'test.xlsx'

        Test-Path $result | Should -Be $true
        $content = Get-Content $result -Raw

        # Check for key elements
        $content | Should -BeLike '*Set-CsTeamsMeetingPolicy*'
        $content | Should -BeLike '*AllowCloudRecording*'
        $content | Should -BeLike '*AllowTranscription*'
        $content | Should -BeLike '*WhatIf*'
        $content | Should -BeLike '*test.xlsx*'
    }

    It 'Includes boolean values with $ prefix in generated script' {
        $commands = @(
            [pscustomobject]@{
                GetCmdlet = 'Get-CsTeamsMeetingPolicy'
                SetCmdlet = 'Set-CsTeamsMeetingPolicy'
                Parameters = [ordered]@{
                    AllowCloudRecording = $true
                    Identity            = 'Global'
                }
                AffectedSettings = @('Cloud Recording (AllowCloudRecording)')
                Category = 'Meetings'
            }
        )

        $scriptPath = Join-Path $TestDrive 'test-bool.ps1'
        Export-PolicyScript -Commands $commands -OutputPath $scriptPath

        $content = Get-Content $scriptPath -Raw
        $content | Should -BeLike '*$true*'
    }

    It 'Includes enum string values in quotes in generated script' {
        $commands = @(
            [pscustomobject]@{
                GetCmdlet = 'Get-CsTeamsMeetingPolicy'
                SetCmdlet = 'Set-CsTeamsMeetingPolicy'
                Parameters = [ordered]@{
                    AutoAdmittedUsers = 'EveryoneInCompany'
                    Identity          = 'Global'
                }
                AffectedSettings = @('Lobby Bypass (AutoAdmittedUsers)')
                Category = 'Meetings'
            }
        )

        $scriptPath = Join-Path $TestDrive 'test-enum.ps1'
        Export-PolicyScript -Commands $commands -OutputPath $scriptPath

        $content = Get-Content $scriptPath -Raw
        $content | Should -BeLike "*'EveryoneInCompany'*"
    }

    It 'Includes error handling in generated script' {
        $commands = @(
            [pscustomobject]@{
                GetCmdlet = 'Get-CsTeamsMeetingPolicy'
                SetCmdlet = 'Set-CsTeamsMeetingPolicy'
                Parameters = [ordered]@{ Identity = 'Global' }
                AffectedSettings = @('Test')
                Category = 'Meetings'
            }
        )

        $scriptPath = Join-Path $TestDrive 'test-errorhandling.ps1'
        Export-PolicyScript -Commands $commands -OutputPath $scriptPath

        $content = Get-Content $scriptPath -Raw
        $content | Should -BeLike '*try*'
        $content | Should -BeLike '*catch*'
        $content | Should -BeLike '*ErrorAction Stop*'
    }
}

# --- Invoke-PolicyDecisions (WhatIf behavior) ------------------------------

Describe 'Invoke-PolicyDecisions' {
    It 'Does not execute commands when WhatIf is active' {
        $commands = @(
            [pscustomobject]@{
                GetCmdlet = 'Get-CsTeamsMeetingPolicy'
                SetCmdlet = 'Set-CsTeamsMeetingPolicy'
                Parameters = [ordered]@{
                    AllowCloudRecording = $true
                    Identity            = 'Global'
                }
                AffectedSettings = @('Cloud Recording (AllowCloudRecording)')
                Category = 'Meetings'
            }
        )

        $auditPath = Join-Path $TestDrive 'audit-whatif.log'

        # Run with -WhatIf; should not throw even though Set-CsTeamsMeetingPolicy doesn't exist
        $results = Invoke-PolicyDecisions -Commands $commands -AuditLogPath $auditPath -WhatIf

        $results.Count | Should -Be 1
        $results[0].Status | Should -Be 'Skipped'

        # Audit log should exist
        Test-Path $auditPath | Should -Be $true
    }
}
