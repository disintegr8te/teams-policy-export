BeforeAll {
    Import-Module (Join-Path $PSScriptRoot '../Modules/TeamsPolicies.Utilities/TeamsPolicies.Utilities.psm1') -Force
    Import-Module (Join-Path $PSScriptRoot '../Modules/TeamsPolicies.Export/TeamsPolicies.Export.psm1') -Force
}

Describe 'Export-DefaultPolicies' {
    It 'Filters to Global identity' {
        $records = @(
            [pscustomobject]@{ Identity = 'Global'; Setting = 'A' },
            [pscustomobject]@{ Identity = 'Tag:Custom1'; Setting = 'B' }
        )
        $defaults = Export-DefaultPolicies -Records $records
        $defaults.Count | Should -Be 1
        $defaults[0].Identity | Should -Be 'Global'
    }

    It 'Matches Tag:Global identity' {
        $records = @(
            [pscustomobject]@{ Identity = 'Tag:Global'; Setting = 'A' },
            [pscustomobject]@{ Identity = 'Tag:Custom1'; Setting = 'B' }
        )
        $defaults = Export-DefaultPolicies -Records $records
        $defaults.Count | Should -Be 1
    }

    It 'Returns empty for no Global row' {
        $records = @(
            [pscustomobject]@{ Identity = 'Custom1'; Setting = 'A' }
        )
        $defaults = Export-DefaultPolicies -Records $records
        $defaults.Count | Should -Be 0
    }
}

Describe 'Get-GlobalPolicyRow' {
    It 'Returns the Global row' {
        $records = @(
            [pscustomobject]@{ Identity = 'Global'; Value = 1 },
            [pscustomobject]@{ Identity = 'Custom'; Value = 2 }
        )
        $global = Get-GlobalPolicyRow -Records $records
        $global.Identity | Should -Be 'Global'
        $global.Value | Should -Be 1
    }
}

Describe 'Export-RecordSet' {
    It 'Exports JSON and CSV files' {
        $testDir = Join-Path $TestDrive 'raw'
        $flatDir = Join-Path $TestDrive 'flat'
        New-Item $testDir, $flatDir -ItemType Directory -Force | Out-Null

        $records = @([pscustomobject]@{ Name = 'Test'; Value = 42 })
        $result = Export-RecordSet -Name 'TestExport' -Records $records -RawDir $testDir -FlatDir $flatDir

        $result.Count | Should -Be 1
        Test-Path $result.JsonPath | Should -Be $true
        Test-Path $result.CsvPath  | Should -Be $true
    }

    It 'Handles empty record set' {
        $testDir = Join-Path $TestDrive 'raw2'
        $flatDir = Join-Path $TestDrive 'flat2'
        New-Item $testDir, $flatDir -ItemType Directory -Force | Out-Null

        $result = Export-RecordSet -Name 'EmptyExport' -Records @() -RawDir $testDir -FlatDir $flatDir
        $result.Count | Should -Be 0
        Test-Path $result.CsvPath | Should -Be $true
    }
}
