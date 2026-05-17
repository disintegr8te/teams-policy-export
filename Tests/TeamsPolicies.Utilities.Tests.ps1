BeforeAll {
    Import-Module (Join-Path $PSScriptRoot '../Modules/TeamsPolicies.Utilities/TeamsPolicies.Utilities.psm1') -Force
}

Describe 'ConvertTo-FlatObject' {
    It 'Flattens a simple object' {
        $obj = [pscustomobject]@{ Name = 'Test'; Value = 42 }
        $flat = ConvertTo-FlatObject -InputObject $obj
        $flat.Name | Should -Be 'Test'
        $flat.Value | Should -Be 42
    }

    It 'Flattens nested objects with prefix' {
        $obj = [pscustomobject]@{
            Name   = 'Policy1'
            Config = [pscustomobject]@{ Setting1 = $true; Setting2 = 'abc' }
        }
        $flat = ConvertTo-FlatObject -InputObject $obj
        $flat.Name | Should -Be 'Policy1'
        $flat.'Config.Setting1' | Should -Be $true
        $flat.'Config.Setting2' | Should -Be 'abc'
    }

    It 'Handles null input' {
        $flat = ConvertTo-FlatObject -InputObject $null
        $flat | Should -BeOfType [pscustomobject]
    }

    It 'Joins simple arrays with pipe separator' {
        $obj = [pscustomobject]@{ Tags = @('a', 'b', 'c') }
        $flat = ConvertTo-FlatObject -InputObject $obj
        $flat.Tags | Should -Be 'a | b | c'
    }

    It 'Serializes complex arrays as JSON' {
        $obj = [pscustomobject]@{
            Items = @(
                [pscustomobject]@{ X = 1 },
                [pscustomobject]@{ X = 2 }
            )
        }
        $flat = ConvertTo-FlatObject -InputObject $obj
        $flat.Items | Should -Match '"X"'
    }

    It 'Flattens dictionaries' {
        $obj = [pscustomobject]@{ Map = @{ Key1 = 'Val1'; Key2 = 'Val2' } }
        $flat = ConvertTo-FlatObject -InputObject $obj
        $flat.'Map.Key1' | Should -Be 'Val1'
        $flat.'Map.Key2' | Should -Be 'Val2'
    }
}

Describe 'Test-CanRunWithoutMandatoryParams' {
    It 'Returns true for Get-Date (no mandatory params)' {
        $cmd = Get-Command Get-Date
        Test-CanRunWithoutMandatoryParams -Command $cmd | Should -Be $true
    }
}

Describe 'Get-SafeSheetName' {
    It 'Strips Get-Cs prefix' {
        Get-SafeSheetName -Name 'Get-CsTeamsMeetingPolicy' | Should -Be 'TeamsMeetingPolicy'
    }

    It 'Truncates long names' {
        (Get-SafeSheetName -Name 'Get-CsTeamsComplianceRecordingPolicy').Length | Should -BeLessOrEqual 31
    }
}

Describe 'New-ManifestEntry' {
    It 'Creates a valid manifest entry' {
        $entry = New-ManifestEntry -Name 'Test' -Kind 'Policy' -Status 'OK' -Count 5
        $entry.Name | Should -Be 'Test'
        $entry.Kind | Should -Be 'Policy'
        $entry.Status | Should -Be 'OK'
        $entry.Count | Should -Be 5
        $entry.Timestamp | Should -Not -BeNullOrEmpty
    }
}
