<#
.SYNOPSIS
    Exports Microsoft Teams policies, configurations, and assignments to JSON, CSV, and Excel.
    Optionally applies stakeholder decisions from a completed Excel workbook.
.DESCRIPTION
    Discovers all Get-CsTeams* policy/configuration cmdlets from the MicrosoftTeams module,
    exports each to raw JSON and flattened CSV, then generates a stakeholder-ready Excel workbook
    with category grouping, decision columns, user impact analysis, and recommendations.

    After a stakeholder meeting, use -ApplyDecisions to read decisions from the completed Excel
    and either generate a review script (-GenerateScript) or apply changes directly.
.PARAMETER OutDir
    Output directory. Defaults to a timestamped folder in the current directory.
.PARAMETER IncludeAssignments
    Include per-user direct assignments and group-based policy assignments.
.PARAMETER UserResultSize
    Maximum number of users to retrieve for assignments. Default: 500000.
.PARAMETER BatchSize
    Number of users to process per batch (controls memory usage). Default: 5000.
.PARAMETER DefaultsOnly
    Export only the Global (org-wide default) policy rows.
.PARAMETER SkipExcel
    Skip Excel workbook generation; produce only raw JSON and flat CSV.
.PARAMETER ExcelOnly
    Regenerate Excel from an existing raw export directory (no Teams connection needed).
.PARAMETER AuthMethod
    Authentication method: 'Interactive' (default, browser popup) or 'DeviceCode'
    (enter code at https://microsoft.com/devicelogin -- works in headless/SSH sessions).
.PARAMETER ApplyDecisions
    Path to an Excel file with completed DECISION column. Reads decisions and applies
    them to the tenant's Global policies. Use with -GenerateScript for the safest approach.
.PARAMETER GenerateScript
    When used with -ApplyDecisions, generates a standalone .ps1 script instead of
    applying changes directly. The admin can review and run the script manually.
.PARAMETER DryRun
    When used with -ApplyDecisions, shows what would change without applying (WhatIf mode).
.EXAMPLE
    .\Export-TeamsPolicies.ps1
.EXAMPLE
    .\Export-TeamsPolicies.ps1 -IncludeAssignments
.EXAMPLE
    .\Export-TeamsPolicies.ps1 -DefaultsOnly
.EXAMPLE
    .\Export-TeamsPolicies.ps1 -ExcelOnly -OutDir .\Teams-Policy-Export-20260309-143000
.EXAMPLE
    .\Export-TeamsPolicies.ps1 -ApplyDecisions .\TeamsPolicies.xlsx -GenerateScript
.EXAMPLE
    .\Export-TeamsPolicies.ps1 -ApplyDecisions .\TeamsPolicies.xlsx -DryRun
.EXAMPLE
    .\Export-TeamsPolicies.ps1 -ApplyDecisions .\TeamsPolicies.xlsx
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$OutDir = (Join-Path -Path (Get-Location) -ChildPath ("Teams-Policy-Export-{0}" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))),
    [switch]$IncludeAssignments,
    [int]$UserResultSize = 500000,
    [int]$BatchSize = 5000,
    [switch]$DefaultsOnly,
    [switch]$SkipExcel,
    [switch]$ExcelOnly,
    [ValidateSet('Interactive','DeviceCode')]
    [string]$AuthMethod = 'Interactive',

    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$ApplyDecisions,

    [switch]$GenerateScript,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$ProgressPreference    = 'SilentlyContinue'

# --- Import modules -----------------------------------------------------------

$modulesDir = Join-Path $PSScriptRoot 'Modules'

Import-Module (Join-Path $modulesDir 'TeamsPolicies.Utilities/TeamsPolicies.Utilities.psm1') -Force
Import-Module (Join-Path $modulesDir 'TeamsPolicies.Discovery/TeamsPolicies.Discovery.psm1') -Force
Import-Module (Join-Path $modulesDir 'TeamsPolicies.Export/TeamsPolicies.Export.psm1')       -Force
Import-Module (Join-Path $modulesDir 'TeamsPolicies.Analysis/TeamsPolicies.Analysis.psm1')   -Force
Import-Module (Join-Path $modulesDir 'TeamsPolicies.Excel/TeamsPolicies.Excel.psm1')         -Force
Import-Module (Join-Path $modulesDir 'TeamsPolicies.Assignments/TeamsPolicies.Assignments.psm1') -Force
Import-Module (Join-Path $modulesDir 'TeamsPolicies.Apply/TeamsPolicies.Apply.psm1')             -Force

# --- Validate prerequisites ---------------------------------------------------

# ApplyDecisions with -GenerateScript or -DryRun only needs ImportExcel, not MicrosoftTeams
$needsTeamsModule = -not $ApplyDecisions -or (-not $GenerateScript -and -not $DryRun)

if ($needsTeamsModule) {
    if (-not (Get-Module -ListAvailable -Name MicrosoftTeams)) {
        throw "MicrosoftTeams module not found. Install with: Install-Module MicrosoftTeams -Scope CurrentUser -Force -AllowClobber"
    }
    Import-Module MicrosoftTeams -ErrorAction Stop
    $moduleVersion = (Get-Module MicrosoftTeams | Sort-Object Version -Descending | Select-Object -First 1).Version.ToString()
    Write-StepLog "MicrosoftTeams module version: $moduleVersion"
}

if (-not $SkipExcel -or $ApplyDecisions) {
    if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
        throw "ImportExcel module not found. Install with: Install-Module ImportExcel -Scope CurrentUser -Force"
    }
    Import-Module ImportExcel -ErrorAction Stop
}

# --- Load configuration files ------------------------------------------------

$configDir = Join-Path $PSScriptRoot 'Config'

# Important policies (organization baseline)
$importantPolicies = @{}
$importantPoliciesPath = Join-Path $configDir 'ImportantPolicies.psd1'
if (Test-Path $importantPoliciesPath) {
    # Use scriptblock evaluation instead of Import-PowerShellDataFile to avoid
    # AST node count limits with large config files (>280 policy entries).
    $tokens = $null; $parseErrors = $null
    [System.Management.Automation.Language.Parser]::ParseFile(
        (Resolve-Path $importantPoliciesPath).Path, [ref]$tokens, [ref]$parseErrors) | Out-Null
    if ($parseErrors.Count -gt 0) {
        Write-StepLog "Parse errors in ImportantPolicies.psd1 -- skipping." -Level Warning
    } else {
        $importantPolicies = & ([scriptblock]::Create((Get-Content $importantPoliciesPath -Raw)))
        $totalImportant = ($importantPolicies.Values | ForEach-Object { $_.Count } | Measure-Object -Sum).Sum
        Write-StepLog "Loaded $totalImportant important policy settings from organization baseline."
    }
}

# Policy categories (grouping cmdlets into logical areas)
$policyCategories = @{}
$policyCategoriesPath = Join-Path $configDir 'PolicyCategories.psd1'
if (Test-Path $policyCategoriesPath) {
    $policyCategories = Import-PowerShellDataFile $policyCategoriesPath
    Write-StepLog "Loaded $($policyCategories.Count) policy categories."
}

# Friendly names (human-readable property names)
$friendlyNames = @{}
$friendlyNamesPath = Join-Path $configDir 'FriendlyNames.psd1'
if (Test-Path $friendlyNamesPath) {
    $friendlyNames = Import-PowerShellDataFile $friendlyNamesPath
    Write-StepLog "Loaded $($friendlyNames.Count) friendly name overrides."
}

# Property exclusions (metadata fields to skip)
$propertyExclusions = @()
$propertyExclusionsPath = Join-Path $configDir 'PropertyExclusions.psd1'
if (Test-Path $propertyExclusionsPath) {
    $exclData = Import-PowerShellDataFile $propertyExclusionsPath
    $propertyExclusions = @($exclData.Exclusions)
    Write-StepLog "Loaded $($propertyExclusions.Count) property exclusions."
}

# --- ApplyDecisions mode: read Excel decisions and apply/generate script -----

if ($ApplyDecisions) {
    Write-StepLog "ApplyDecisions mode: reading decisions from $ApplyDecisions"

    # 1. Import decisions from the Excel sheet
    $decisions = Import-DecisionSheet -Path $ApplyDecisions

    if ($decisions.Count -eq 0) {
        Write-StepLog "No decisions found in the workbook. Nothing to apply."
        return
    }

    # 2. Show the change report
    $reportPath = Join-Path (Split-Path $ApplyDecisions -Parent) ("ChangeReport-{0}.txt" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
    New-PolicyChangeReport -Decisions $decisions -OutputPath $reportPath

    # 3. Convert decisions to policy commands
    $policyCommands = ConvertTo-PolicyCommands -Decisions $decisions

    if ($policyCommands.Count -eq 0) {
        Write-StepLog "No actionable changes to apply (all decisions are Keep or already match current values)."
        return
    }

    # 4. Either generate script or apply changes
    if ($GenerateScript) {
        # Safest approach: generate a standalone .ps1 script for review
        $scriptPath = Join-Path (Split-Path $ApplyDecisions -Parent) ("Apply-PolicyDecisions-{0}.ps1" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
        Export-PolicyScript -Commands $policyCommands -Decisions $decisions `
            -OutputPath $scriptPath -SourceExcel $ApplyDecisions

        Write-Host ''
        Write-StepLog "Script generated. Review it, then run:"
        Write-StepLog "  .\$(Split-Path $scriptPath -Leaf) -WhatIf    # preview changes"
        Write-StepLog "  .\$(Split-Path $scriptPath -Leaf)             # apply changes"
    }
    else {
        # Direct apply mode -- requires Teams connection
        if (-not $DryRun) {
            # Verify Teams connection for live apply
            Import-Module MicrosoftTeams -ErrorAction Stop
            Write-StepLog "Connecting to Microsoft Teams ($AuthMethod)..."
            if ($AuthMethod -eq 'DeviceCode') {
                Connect-MicrosoftTeams -UseDeviceAuthentication
            }
            else {
                Connect-MicrosoftTeams
            }
        }

        $auditLogPath = Join-Path (Split-Path $ApplyDecisions -Parent) ("PolicyChanges-Audit-{0}.log" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))

        if ($DryRun) {
            Write-StepLog "DryRun mode: showing what would change (WhatIf)."
            $results = Invoke-PolicyDecisions -Commands $policyCommands `
                -AuditLogPath $auditLogPath -WhatIf
        }
        else {
            $results = Invoke-PolicyDecisions -Commands $policyCommands `
                -AuditLogPath $auditLogPath -Force -Confirm
        }

        # Summary
        Write-Host ''
        Write-StepLog "Apply complete."
        $successCount = @($results | Where-Object Status -eq 'Success').Count
        $failedCount  = @($results | Where-Object Status -eq 'Failed').Count
        $skippedCount = @($results | Where-Object Status -eq 'Skipped').Count
        Write-StepLog "  Success: $successCount  |  Failed: $failedCount  |  Skipped: $skippedCount"
        Write-StepLog "  Audit log: $auditLogPath"
        Write-StepLog "  Change report: $reportPath"

        # Cleanup
        if (-not $DryRun) {
            try { Disconnect-MicrosoftTeams | Out-Null } catch { }
        }
    }

    return
}

# --- Directory setup ----------------------------------------------------------

$rawDir  = Join-Path $OutDir 'raw-json'
$flatDir = Join-Path $OutDir 'flat-csv'
New-Item -ItemType Directory -Path $rawDir, $flatDir -Force | Out-Null

# --- ExcelOnly mode: regenerate from existing export --------------------------

if ($ExcelOnly) {
    Write-StepLog "ExcelOnly mode: regenerating Excel from $OutDir"

    $manifestPath = Join-Path $OutDir 'manifest.csv'
    if (-not (Test-Path $manifestPath)) {
        throw "No manifest.csv found in $OutDir. Run a full export first."
    }

    $manifest   = Import-Csv $manifestPath
    $policyData = @{}
    $globalRows = @{}

    foreach ($entry in ($manifest | Where-Object { $_.Status -eq 'OK' -and $_.Kind -in @('Policy','Configuration') })) {
        $jsonPath = $entry.JsonPath
        if (Test-Path $jsonPath) {
            $records = Get-Content $jsonPath -Raw | ConvertFrom-Json
            $policyData[$entry.Name] = @($records)
            $globalRow = Get-GlobalPolicyRow -Records @($records)
            if ($globalRow) { $globalRows[$entry.Name] = $globalRow }
        }
    }

    # Load assignment data if present
    $userAssignments  = $null
    $groupAssignments = $null
    $userEntry  = $manifest | Where-Object { $_.Name -eq 'UserAssignments' -and $_.Status -eq 'OK' }
    $groupEntry = $manifest | Where-Object { $_.Name -eq 'GroupPolicyAssignments' -and $_.Status -eq 'OK' }
    if ($userEntry -and (Test-Path $userEntry.JsonPath)) {
        $userAssignments = Get-Content $userEntry.JsonPath -Raw | ConvertFrom-Json
    }
    if ($groupEntry -and (Test-Path $groupEntry.JsonPath)) {
        $groupAssignments = Get-Content $groupEntry.JsonPath -Raw | ConvertFrom-Json
    }

    # Compute total users from manifest Count field (set during export)
    $totalUsers = 0
    $userManifestEntry = $manifest | Where-Object { $_.Name -eq 'UserAssignments' -and $_.Status -eq 'OK' }
    if ($userManifestEntry) {
        $totalUsers = [int]$userManifestEntry.Count
    }
    elseif ($userAssignments) {
        $totalUsers = @($userAssignments | Select-Object -ExpandProperty UserPrincipalName -Unique).Count
    }

    # Auto-categorize cmdlets not in PolicyCategories
    $allCategorized = @()
    foreach ($key in $policyCategories.Keys) { $allCategorized += $policyCategories[$key] }
    $uncategorized = @($policyData.Keys | Where-Object { $_ -notin $allCategorized })
    if ($uncategorized.Count -gt 0) {
        $policyCategories['Other'] = $uncategorized
        Write-StepLog "$($uncategorized.Count) cmdlets auto-categorized as 'Other'."
    }

    # Compute user counts
    $policyUserCounts = Get-PolicyUserCounts `
        -UserAssignments $userAssignments `
        -TotalUsers $totalUsers `
        -GroupAssignments $groupAssignments

    $excelPath = New-PolicyExcelReport `
        -OutputPath $OutDir `
        -PolicyData $policyData `
        -GlobalRows $globalRows `
        -ImportantPolicies $importantPolicies `
        -PolicyCategories $policyCategories `
        -FriendlyNames $friendlyNames `
        -PropertyExclusions $propertyExclusions `
        -PolicyUserCounts $policyUserCounts `
        -TotalUsers $totalUsers `
        -UserAssignments $userAssignments `
        -GroupAssignments $groupAssignments `
        -Manifest $manifest

    Write-StepLog "Excel regenerated: $excelPath"
    return
}

# --- Connect to Teams ---------------------------------------------------------

Write-StepLog "Connecting to Microsoft Teams ($AuthMethod)..."
if ($AuthMethod -eq 'DeviceCode') {
    Write-Host ''
    Write-Host '  Device Code Authentication' -ForegroundColor Cyan
    Write-Host '  A code will be displayed. Open https://microsoft.com/devicelogin and enter it.' -ForegroundColor Cyan
    Write-Host ''
    Connect-MicrosoftTeams -UseDeviceAuthentication
}
else {
    Connect-MicrosoftTeams
}

# --- Discover cmdlets ---------------------------------------------------------

$commands = Get-TeamsPolicyCmdlets
Write-StepLog "Discovered $($commands.Count) exportable cmdlets."

# --- Export policies and configurations ---------------------------------------

$manifest    = [System.Collections.Generic.List[object]]::new()
$policyData  = @{}
$globalRows  = @{}

foreach ($cmd in $commands) {
    $result = Invoke-PolicyCmdletSafe -CmdletName $cmd.Name
    $kind   = $(if ($cmd.Name -like '*Policy') { 'Policy' } else { 'Configuration' })

    if ($result.Success) {
        $records = $result.Data

        # DefaultsOnly: filter to Global row only
        if ($DefaultsOnly) {
            $records = Export-DefaultPolicies -Records $records
        }

        $export = Export-RecordSet -Name $cmd.Name -Records $records -RawDir $rawDir -FlatDir $flatDir

        # Stash data and Global row for Excel
        $policyData[$cmd.Name] = $records
        $globalRow = Get-GlobalPolicyRow -Records $result.Data  # always from full set
        if ($globalRow) { $globalRows[$cmd.Name] = $globalRow }

        $manifest.Add((New-ManifestEntry -Name $cmd.Name -Kind $kind -Status 'OK' `
            -Count $export.Count -JsonPath $export.JsonPath -CsvPath $export.CsvPath))
    }
    else {
        $manifest.Add((New-ManifestEntry -Name $cmd.Name -Kind $kind -Status 'Failed' `
            -Error $result.Error))
    }
}

# --- Export assignments -------------------------------------------------------

$userAssignments  = $null
$userSummary      = $null
$groupAssignments = $null
$totalUsers       = 0

if ($IncludeAssignments) {
    # Normalized user assignments (one row per user-policy pair)
    try {
        $assignResult = Get-UserPolicyAssignments -ResultSize $UserResultSize -BatchSize $BatchSize -TempDir $flatDir
        $totalUsers = $assignResult.TotalUsers

        # Read back the normalized CSV for Excel
        if (Test-Path $assignResult.CsvPath) {
            $userAssignments = Import-Csv $assignResult.CsvPath
        }

        # Also get the summary view (one row per user, policies as columns)
        $userSummary = Get-UserPolicyAssignmentsSummary -ResultSize $UserResultSize -BatchSize $BatchSize

        $export = Export-RecordSet -Name 'UserAssignments' -Records @($userAssignments) -RawDir $rawDir -FlatDir $flatDir
        $manifest.Add((New-ManifestEntry -Name 'UserAssignments' -Kind 'Assignments' -Status 'OK' `
            -Count $assignResult.TotalUsers -JsonPath $export.JsonPath -CsvPath $export.CsvPath))

        if ($userSummary.Count -gt 0) {
            $summaryExport = Export-RecordSet -Name 'UserSummary' -Records $userSummary -RawDir $rawDir -FlatDir $flatDir
            $manifest.Add((New-ManifestEntry -Name 'UserSummary' -Kind 'Assignments' -Status 'OK' `
                -Count $userSummary.Count -JsonPath $summaryExport.JsonPath -CsvPath $summaryExport.CsvPath))
        }
    }
    catch {
        $manifest.Add((New-ManifestEntry -Name 'UserAssignments' -Kind 'Assignments' -Status 'Failed' `
            -Error $_.Exception.Message))
        Write-StepLog "User assignments export failed: $($_.Exception.Message)" -Level Warning
    }

    # Group assignments
    try {
        $groupAssignments = Get-GroupAssignments
        $export = Export-RecordSet -Name 'GroupPolicyAssignments' -Records @($groupAssignments) -RawDir $rawDir -FlatDir $flatDir
        $manifest.Add((New-ManifestEntry -Name 'GroupPolicyAssignments' -Kind 'Assignments' -Status 'OK' `
            -Count $export.Count -JsonPath $export.JsonPath -CsvPath $export.CsvPath))
    }
    catch {
        $manifest.Add((New-ManifestEntry -Name 'GroupPolicyAssignments' -Kind 'Assignments' -Status 'Failed' `
            -Error $_.Exception.Message))
    }
}

# --- Write manifest ----------------------------------------------------------

Export-ManifestFile -Manifest @($manifest) -OutDir $OutDir

# --- Auto-categorize uncategorized cmdlets ------------------------------------

$allCategorized = @()
foreach ($key in $policyCategories.Keys) { $allCategorized += $policyCategories[$key] }
$uncategorized = @($policyData.Keys | Where-Object { $_ -notin $allCategorized })
if ($uncategorized.Count -gt 0) {
    $policyCategories['Other'] = $uncategorized
    Write-StepLog "$($uncategorized.Count) cmdlets auto-categorized as 'Other'."
}

# --- Compute user impact analysis ---------------------------------------------

$policyUserCounts = Get-PolicyUserCounts `
    -UserAssignments $userAssignments `
    -TotalUsers $totalUsers `
    -GroupAssignments $groupAssignments

# --- Generate Excel workbook -------------------------------------------------

if (-not $SkipExcel) {
    $excelPath = New-PolicyExcelReport `
        -OutputPath $OutDir `
        -PolicyData $policyData `
        -GlobalRows $globalRows `
        -ImportantPolicies $importantPolicies `
        -PolicyCategories $policyCategories `
        -FriendlyNames $friendlyNames `
        -PropertyExclusions $propertyExclusions `
        -PolicyUserCounts $policyUserCounts `
        -TotalUsers $totalUsers `
        -UserAssignments $userAssignments `
        -GroupAssignments $groupAssignments `
        -Manifest @($manifest)

    Write-StepLog "Excel report: $excelPath"
}

# --- Cleanup ------------------------------------------------------------------

try { Disconnect-MicrosoftTeams | Out-Null } catch { }

# --- Summary ------------------------------------------------------------------

$okCount     = ($manifest | Where-Object Status -eq 'OK').Count
$failedCount = ($manifest | Where-Object Status -eq 'Failed').Count

Write-Host ''
Write-StepLog "Export complete."
Write-StepLog "  Output:  $OutDir"
Write-StepLog "  Success: $okCount  |  Failed: $failedCount"
if ($totalUsers -gt 0) { Write-StepLog "  Users:   $totalUsers" }
if ($DefaultsOnly) { Write-StepLog "  Mode: Defaults only (Global policies)" }
if (-not $SkipExcel) { Write-StepLog "  Excel:   $(Join-Path $OutDir 'TeamsPolicies.xlsx')" }
