function Export-RecordSet {
    <#
    .SYNOPSIS
        Exports a set of records to both raw JSON and flattened CSV.
    #>
    param(
        [Parameter(Mandatory)][string]$Name,
        [object[]]$Records = @(),
        [Parameter(Mandatory)][string]$RawDir,
        [Parameter(Mandatory)][string]$FlatDir
    )

    $safeName = ($Name -replace '[^a-zA-Z0-9\-_\.]', '_')
    $jsonPath = Join-Path $RawDir  "$safeName.json"
    $csvPath  = Join-Path $FlatDir "$safeName.csv"

    $materialized = @($Records | ForEach-Object { $_ | Select-Object * })

    $materialized | ConvertTo-Json -Depth 20 | Set-Content -Path $jsonPath -Encoding UTF8

    if ($materialized.Count -gt 0) {
        $materialized |
            ForEach-Object { ConvertTo-FlatObject -InputObject $_ } |
            Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
    }
    else {
        @([pscustomobject]@{ Notice = 'No data returned' }) |
            Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
    }

    [pscustomobject]@{
        Name     = $Name
        Count    = $materialized.Count
        JsonPath = $jsonPath
        CsvPath  = $csvPath
    }
}

function Export-DefaultPolicies {
    <#
    .SYNOPSIS
        Filters a record set to only the Global (org-wide default) policy row.
    #>
    param(
        [Parameter(Mandatory)][object[]]$Records
    )

    $global = $Records | Where-Object {
        ($_.Identity -eq 'Global') -or
        ($_.Identity -like '*:Global') -or
        ($_.Identity -like 'Tag:Global')
    }

    if ($global) { @($global) } else { @() }
}

function Get-GlobalPolicyRow {
    <#
    .SYNOPSIS
        Returns the Global policy row from a set of policy records.
    .DESCRIPTION
        Finds records with Identity matching 'Global' patterns.
        Warns if multiple Global rows are found and returns the first.
    #>
    param([Parameter(Mandatory)][AllowEmptyCollection()][object[]]$Records)

    $globalRows = @($Records | Where-Object {
        ($_.Identity -eq 'Global') -or
        ($_.Identity -like '*:Global') -or
        ($_.Identity -like 'Tag:Global')
    })

    if ($globalRows.Count -gt 1) {
        Write-Warning "Multiple Global rows found ($($globalRows.Count)). Using first match: $($globalRows[0].Identity)"
    }

    $globalRows | Select-Object -First 1
}

function Export-ManifestFile {
    <#
    .SYNOPSIS
        Writes the manifest CSV and output README.
    #>
    param(
        [Parameter(Mandatory)][object[]]$Manifest,
        [Parameter(Mandatory)][string]$OutDir
    )

    $manifestPath = Join-Path $OutDir 'manifest.csv'
    $Manifest | Export-Csv -Path $manifestPath -NoTypeInformation -Encoding UTF8

    $readmePath = Join-Path $OutDir 'README.txt'
    @"
Teams Policy & Configuration Export
====================================
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

Folders:
  raw-json/    Full structured JSON export per cmdlet
  flat-csv/    Flattened CSV export per cmdlet (for Excel and diffing)
  manifest.csv Inventory of all exported cmdlets with status and file paths

Excel:
  TeamsPolicies.xlsx   Formatted workbook with all policies, defaults highlighting, and assignments

Notes:
  - The 'Global' identity row in each policy is the org-wide default.
  - Non-default values are highlighted in yellow in the Excel report.
  - DirectUserPolicyAssignments contains per-user direct assignments.
  - GroupPolicyAssignments contains group-based policy assignments.
  - For a single user's effective policy, use: Get-CsUserPolicyAssignment -Identity user@domain
"@ | Set-Content -Path $readmePath -Encoding UTF8

    Write-StepLog "Manifest written to $manifestPath"
}

Export-ModuleMember -Function @(
    'Export-RecordSet',
    'Export-DefaultPolicies',
    'Get-GlobalPolicyRow',
    'Export-ManifestFile'
)
