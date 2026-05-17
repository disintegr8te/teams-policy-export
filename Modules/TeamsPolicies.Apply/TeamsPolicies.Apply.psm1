# --- Import shared utilities -------------------------------------------------

$utilitiesPath = Join-Path $PSScriptRoot '..\TeamsPolicies.Utilities\TeamsPolicies.Utilities.psm1'
if ((Test-Path $utilitiesPath) -and -not (Get-Command Write-StepLog -ErrorAction SilentlyContinue)) {
    Import-Module $utilitiesPath -Global
}

# --- Load cmdlet mapping ----------------------------------------------------

$script:CmdletMapping = @{}
$mappingPath = Join-Path $PSScriptRoot '..\..\Config\CmdletMapping.psd1'
if (Test-Path $mappingPath) {
    $script:CmdletMapping = Import-PowerShellDataFile $mappingPath
}

# --- Functions --------------------------------------------------------------

function Import-DecisionSheet {
    <#
    .SYNOPSIS
        Reads the Excel file's "All Decisions" sheet and returns structured decision objects.
    .DESCRIPTION
        Uses the ImportExcel module to read the workbook, parses the DECISION column,
        skips rows where DECISION is empty, and returns objects with cmdlet, property,
        current value, decision value, category, setting, and notes.
    .PARAMETER Path
        Path to the Excel file containing stakeholder decisions.
    .PARAMETER SheetName
        Name of the worksheet to read. Defaults to 'All Decisions'.
    .EXAMPLE
        Import-DecisionSheet -Path .\TeamsPolicies.xlsx
    #>
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string]$Path,

        [string]$SheetName = 'All Decisions'
    )

    Write-StepLog "Reading decisions from '$SheetName' in: $Path"

    if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
        throw "ImportExcel module not found. Install with: Install-Module ImportExcel -Scope CurrentUser -Force"
    }

    Import-Module ImportExcel -ErrorAction Stop

    $rows = Import-Excel -Path $Path -WorksheetName $SheetName -ErrorAction Stop

    if (-not $rows -or $rows.Count -eq 0) {
        Write-StepLog "No rows found in sheet '$SheetName'." -Level Warning
        return @()
    }

    Write-StepLog "Read $($rows.Count) rows from '$SheetName'."

    $decisions = [System.Collections.Generic.List[object]]::new()
    $skipped   = 0

    foreach ($row in $rows) {
        $decisionRaw = $null
        if ($row.PSObject.Properties['DECISION']) {
            $decisionRaw = $row.DECISION
        }

        # Skip rows with no decision
        if ([string]::IsNullOrWhiteSpace($decisionRaw)) {
            $skipped++
            continue
        }

        $decisionValue = ([string]$decisionRaw).Trim()

        # Extract row fields with safe property access
        $cmdlet       = $(if ($row.PSObject.Properties['Cmdlet'])          { [string]$row.Cmdlet }          else { '' })
        $property     = $(if ($row.PSObject.Properties['Property'])        { [string]$row.Property }        else { '' })
        $currentValue = $(if ($row.PSObject.Properties['Current Global'])  { [string]$row.'Current Global' } else { '' })
        $category     = $(if ($row.PSObject.Properties['Category'])        { [string]$row.Category }        else { '' })
        $setting      = $(if ($row.PSObject.Properties['Setting'])         { [string]$row.Setting }         else { '' })
        $riskLevel    = $(if ($row.PSObject.Properties['Risk'])            { [string]$row.Risk }            else { '' })
        $usersOnGlob  = $(if ($row.PSObject.Properties['Users on Global']) { $row.'Users on Global' }       else { 0 })
        $usersOnOther = $(if ($row.PSObject.Properties['Users on Other'])  { $row.'Users on Other' }        else { 0 })
        $notes        = $(if ($row.PSObject.Properties['Notes'])           { [string]$row.Notes }           else { '' })

        # Skip if essential fields are missing
        if ([string]::IsNullOrWhiteSpace($cmdlet) -or [string]::IsNullOrWhiteSpace($property)) {
            Write-StepLog "Skipping row with missing Cmdlet/Property: Setting='$setting'" -Level Warning
            $skipped++
            continue
        }

        # Handle "Keep" decision (no change needed)
        $isKeep = $decisionValue -eq 'Keep'

        # Check if decision equals current value (no change needed)
        $isNoChange = (-not $isKeep) -and ($decisionValue -eq $currentValue)

        $decisions.Add([pscustomobject][ordered]@{
            Cmdlet        = $cmdlet
            Property      = $property
            CurrentValue  = $currentValue
            DecisionValue = $decisionValue
            Category      = $category
            Setting       = $setting
            RiskLevel     = $riskLevel
            UsersOnGlobal = $usersOnGlob
            UsersOnOther  = $usersOnOther
            Notes         = $notes
            IsKeep        = $isKeep
            IsNoChange    = $isNoChange
        })
    }

    Write-StepLog "Parsed $($decisions.Count) decisions ($skipped rows skipped -- no decision)."

    @($decisions)
}

function ConvertTo-PolicyCommands {
    <#
    .SYNOPSIS
        Converts decision objects to Set-Cs* command objects grouped by cmdlet.
    .DESCRIPTION
        Maps Get-Cs* cmdlets to their Set-Cs* equivalents, groups changes by cmdlet,
        handles type conversion, and returns structured command objects.
    .PARAMETER Decisions
        Array of decision objects from Import-DecisionSheet.
    .PARAMETER CmdletMapping
        Optional hashtable mapping Get-Cs* to Set-Cs*. If not provided, uses the
        module-level mapping loaded from Config/CmdletMapping.psd1.
    .EXAMPLE
        $decisions | ConvertTo-PolicyCommands
    #>
    param(
        [Parameter(Mandatory)]
        [object[]]$Decisions,

        [hashtable]$CmdletMapping
    )

    if (-not $CmdletMapping) {
        $CmdletMapping = $script:CmdletMapping
    }

    # Filter to only actionable decisions (not Keep, not already matching current)
    $actionable = @($Decisions | Where-Object { -not $_.IsKeep -and -not $_.IsNoChange })

    if ($actionable.Count -eq 0) {
        Write-StepLog "No actionable changes found (all decisions are Keep or already match current)."
        return @()
    }

    Write-StepLog "Converting $($actionable.Count) actionable decisions to policy commands."

    # Group by Get-Cs* cmdlet
    $grouped = $actionable | Group-Object -Property Cmdlet

    $commands = [System.Collections.Generic.List[object]]::new()

    foreach ($group in $grouped) {
        $getCmdlet = $group.Name

        # Resolve Set- cmdlet
        $setCmdlet = $null
        if ($CmdletMapping -and $CmdletMapping.ContainsKey($getCmdlet)) {
            $setCmdlet = $CmdletMapping[$getCmdlet]
        }
        else {
            # Fall back to simple Get- -> Set- replacement
            $setCmdlet = $getCmdlet -replace '^Get-', 'Set-'
        }

        # Build parameters hashtable
        $parameters       = [ordered]@{}
        $affectedSettings = [System.Collections.Generic.List[string]]::new()

        foreach ($decision in $group.Group) {
            $convertedValue = ConvertTo-PolicyValue -Value $decision.DecisionValue
            $parameters[$decision.Property] = $convertedValue
            $affectedSettings.Add("$($decision.Setting) ($($decision.Property))")
        }

        # Add Identity parameter for Global policy
        $parameters['Identity'] = 'Global'

        $commands.Add([pscustomobject][ordered]@{
            GetCmdlet        = $getCmdlet
            SetCmdlet        = $setCmdlet
            Parameters       = $parameters
            AffectedSettings = @($affectedSettings)
            Category         = ($group.Group | Select-Object -First 1).Category
        })
    }

    Write-StepLog "Generated $($commands.Count) Set-Cs* commands."

    @($commands)
}

function ConvertTo-PolicyValue {
    <#
    .SYNOPSIS
        Converts a string decision value to the appropriate PowerShell type.
    .DESCRIPTION
        Handles boolean strings, integers, and enum/string values.
    .PARAMETER Value
        The string value to convert.
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Value
    )

    # Boolean conversion
    if ($Value -eq 'True')  { return $true }
    if ($Value -eq 'False') { return $false }

    # Integer conversion
    $intVal = 0
    if ([int]::TryParse($Value, [ref]$intVal)) {
        return $intVal
    }

    # Long conversion for large numbers
    $longVal = [long]0
    if ([long]::TryParse($Value, [ref]$longVal)) {
        return $longVal
    }

    # Return as string (enum values like 'Enabled', 'EveryoneInCompany', etc.)
    $Value
}

function New-PolicyChangeReport {
    <#
    .SYNOPSIS
        Generates a human-readable change report from decision data.
    .DESCRIPTION
        Shows what will change, what stays the same, risk levels, and user impact.
        Can output to console or save to a file.
    .PARAMETER Decisions
        Array of decision objects from Import-DecisionSheet.
    .PARAMETER OutputPath
        Optional path to save the report as a text file.
    .EXAMPLE
        New-PolicyChangeReport -Decisions $decisions
    .EXAMPLE
        New-PolicyChangeReport -Decisions $decisions -OutputPath .\change-report.txt
    #>
    param(
        [Parameter(Mandatory)]
        [object[]]$Decisions,

        [string]$OutputPath
    )

    $changes  = @($Decisions | Where-Object { -not $_.IsKeep -and -not $_.IsNoChange })
    $keeps    = @($Decisions | Where-Object { $_.IsKeep })
    $noChange = @($Decisions | Where-Object { $_.IsNoChange })

    $highRisk   = @($changes | Where-Object { $_.RiskLevel -eq 'High' })
    $mediumRisk = @($changes | Where-Object { $_.RiskLevel -eq 'Medium' })
    $lowRisk    = @($changes | Where-Object { $_.RiskLevel -eq 'Low' })

    $report = [System.Text.StringBuilder]::new()

    [void]$report.AppendLine('=' * 72)
    [void]$report.AppendLine('  TEAMS POLICY CHANGE REPORT')
    [void]$report.AppendLine("  Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
    [void]$report.AppendLine('=' * 72)
    [void]$report.AppendLine()

    # -- Summary --
    [void]$report.AppendLine('SUMMARY')
    [void]$report.AppendLine('-' * 40)
    [void]$report.AppendLine("  Total decisions:        $($Decisions.Count)")
    [void]$report.AppendLine("  Settings to CHANGE:     $($changes.Count)")
    [void]$report.AppendLine("  Settings to KEEP:       $($keeps.Count)")
    [void]$report.AppendLine("  Already matching:       $($noChange.Count)")
    [void]$report.AppendLine()

    # -- Risk breakdown --
    if ($changes.Count -gt 0) {
        [void]$report.AppendLine('RISK BREAKDOWN (changes only)')
        [void]$report.AppendLine('-' * 40)
        [void]$report.AppendLine("  High risk:    $($highRisk.Count)")
        [void]$report.AppendLine("  Medium risk:  $($mediumRisk.Count)")
        [void]$report.AppendLine("  Low risk:     $($lowRisk.Count)")
        [void]$report.AppendLine()
    }

    # -- High risk details --
    if ($highRisk.Count -gt 0) {
        [void]$report.AppendLine('HIGH RISK CHANGES (review carefully)')
        [void]$report.AppendLine('-' * 72)
        foreach ($d in $highRisk) {
            [void]$report.AppendLine("  [$($d.Category)] $($d.Setting)")
            [void]$report.AppendLine("    Property:  $($d.Property)")
            [void]$report.AppendLine("    Cmdlet:    $($d.Cmdlet)")
            [void]$report.AppendLine("    Current:   $($d.CurrentValue)  -->  New: $($d.DecisionValue)")
            [void]$report.AppendLine("    Users on Global: $($d.UsersOnGlobal)  |  Users on Other: $($d.UsersOnOther)")
            if ($d.Notes) { [void]$report.AppendLine("    Notes:     $($d.Notes)") }
            [void]$report.AppendLine()
        }
    }

    # -- All changes by category --
    if ($changes.Count -gt 0) {
        [void]$report.AppendLine('ALL CHANGES BY CATEGORY')
        [void]$report.AppendLine('-' * 72)

        $byCategory = $changes | Group-Object -Property Category | Sort-Object Name
        foreach ($catGroup in $byCategory) {
            [void]$report.AppendLine()
            [void]$report.AppendLine("  [$($catGroup.Name)] ($($catGroup.Count) changes)")
            foreach ($d in $catGroup.Group) {
                $riskTag = $(if ($d.RiskLevel -eq 'High') { ' ** HIGH **' } elseif ($d.RiskLevel -eq 'Medium') { ' * MED *' } else { '' })
                [void]$report.AppendLine("    - $($d.Setting): $($d.CurrentValue) --> $($d.DecisionValue)$riskTag")
            }
        }
        [void]$report.AppendLine()
    }

    # -- Kept settings --
    if ($keeps.Count -gt 0) {
        [void]$report.AppendLine('SETTINGS KEPT (explicit Keep decision)')
        [void]$report.AppendLine('-' * 40)
        foreach ($d in $keeps) {
            [void]$report.AppendLine("  [$($d.Category)] $($d.Setting) = $($d.CurrentValue)")
        }
        [void]$report.AppendLine()
    }

    # -- Already matching --
    if ($noChange.Count -gt 0) {
        [void]$report.AppendLine('ALREADY MATCHING (decision = current value)')
        [void]$report.AppendLine('-' * 40)
        foreach ($d in $noChange) {
            [void]$report.AppendLine("  [$($d.Category)] $($d.Setting) = $($d.CurrentValue)")
        }
        [void]$report.AppendLine()
    }

    [void]$report.AppendLine('=' * 72)
    [void]$report.AppendLine('  END OF REPORT')
    [void]$report.AppendLine('=' * 72)

    $reportText = $report.ToString()

    # Output to console
    Write-Host $reportText

    # Save to file if requested
    if ($OutputPath) {
        $reportText | Set-Content -Path $OutputPath -Encoding UTF8
        Write-StepLog "Change report saved to: $OutputPath"
    }

    $reportText
}

function Invoke-PolicyDecisions {
    <#
    .SYNOPSIS
        Applies policy decisions to the Teams tenant.
    .DESCRIPTION
        Executes Set-Cs* commands based on decisions from the Excel sheet.
        Defaults to -WhatIf mode for safety. Supports -Confirm for interactive approval.
        Logs all changes and returns a results object.
    .PARAMETER Commands
        Array of command objects from ConvertTo-PolicyCommands.
    .PARAMETER AuditLogPath
        Path to save the audit log. Defaults to a timestamped file in the current directory.
    .PARAMETER Force
        Skip the WhatIf default and apply changes directly (still respects -Confirm).
    .EXAMPLE
        $commands | Invoke-PolicyDecisions -WhatIf
    .EXAMPLE
        $commands | Invoke-PolicyDecisions -Force -Confirm
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory)]
        [object[]]$Commands,

        [string]$AuditLogPath,

        [switch]$Force
    )

    if (-not $AuditLogPath) {
        $AuditLogPath = Join-Path (Get-Location) ("PolicyChanges-Audit-{0}.log" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
    }

    $results = [System.Collections.Generic.List[object]]::new()
    $auditLog = [System.Collections.Generic.List[string]]::new()

    [void]$auditLog.Add("# Teams Policy Change Audit Log")
    [void]$auditLog.Add("# Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
    [void]$auditLog.Add("# User: $([System.Environment]::UserName)")
    [void]$auditLog.Add("# Computer: $([System.Environment]::MachineName)")
    [void]$auditLog.Add("#" + ('-' * 70))
    [void]$auditLog.Add("")

    $totalChanges = ($Commands | ForEach-Object { $_.AffectedSettings.Count } | Measure-Object -Sum).Sum
    Write-StepLog "Applying $totalChanges setting changes across $($Commands.Count) cmdlets..."

    # Default to WhatIf unless -Force is specified
    $isWhatIf = -not $Force
    if ($isWhatIf -and -not $WhatIfPreference) {
        Write-StepLog "Running in WhatIf mode (default safe mode). Use -Force to apply changes."
    }

    foreach ($cmd in $Commands) {
        $setCmdlet  = $cmd.SetCmdlet
        $parameters = $cmd.Parameters

        # Build parameter string for logging
        $paramParts = @()
        foreach ($key in $parameters.Keys) {
            $val = $parameters[$key]
            if ($val -is [bool]) {
                $paramParts += "-$key `$$val"
            }
            else {
                $paramParts += "-$key '$val'"
            }
        }
        $paramString = $paramParts -join ' '
        $commandString = "$setCmdlet $paramString"

        [void]$auditLog.Add("Command: $commandString")
        [void]$auditLog.Add("  Category: $($cmd.Category)")
        [void]$auditLog.Add("  Affected: $($cmd.AffectedSettings -join '; ')")

        $description = "Apply $($cmd.AffectedSettings.Count) changes via $setCmdlet"

        if ($PSCmdlet.ShouldProcess($description, $commandString, 'Apply Teams Policy Change')) {
            try {
                Write-StepLog "Executing: $setCmdlet ..."

                # Build the splat hashtable with proper types
                $splat = @{}
                foreach ($key in $parameters.Keys) {
                    $splat[$key] = $parameters[$key]
                }

                & $setCmdlet @splat -ErrorAction Stop

                Write-StepLog "  SUCCESS: $setCmdlet"
                [void]$auditLog.Add("  Result: SUCCESS")
                [void]$auditLog.Add("  Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")

                $results.Add([pscustomobject][ordered]@{
                    Cmdlet   = $setCmdlet
                    Status   = 'Success'
                    Settings = $cmd.AffectedSettings
                    Error    = $null
                })
            }
            catch {
                $errorMsg = $_.Exception.Message
                Write-StepLog "  FAILED: $setCmdlet -- $errorMsg" -Level Error
                [void]$auditLog.Add("  Result: FAILED")
                [void]$auditLog.Add("  Error: $errorMsg")
                [void]$auditLog.Add("  Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")

                $results.Add([pscustomobject][ordered]@{
                    Cmdlet   = $setCmdlet
                    Status   = 'Failed'
                    Settings = $cmd.AffectedSettings
                    Error    = $errorMsg
                })
            }
        }
        else {
            [void]$auditLog.Add("  Result: SKIPPED (WhatIf or user declined)")
            [void]$auditLog.Add("  Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")

            $results.Add([pscustomobject][ordered]@{
                Cmdlet   = $setCmdlet
                Status   = 'Skipped'
                Settings = $cmd.AffectedSettings
                Error    = $null
            })
        }

        [void]$auditLog.Add("")
    }

    # Write audit log (bypass WhatIf so the log is always persisted)
    [System.IO.File]::WriteAllLines($AuditLogPath, [string[]]$auditLog, [System.Text.UTF8Encoding]::new($false))
    Write-StepLog "Audit log saved to: $AuditLogPath"

    # Summary
    $successCount = @($results | Where-Object Status -eq 'Success').Count
    $failedCount  = @($results | Where-Object Status -eq 'Failed').Count
    $skippedCount = @($results | Where-Object Status -eq 'Skipped').Count

    Write-StepLog "Results: $successCount succeeded, $failedCount failed, $skippedCount skipped."

    @($results)
}

function Export-PolicyScript {
    <#
    .SYNOPSIS
        Generates a standalone .ps1 script with all Set-Cs* commands.
    .DESCRIPTION
        Instead of direct execution, outputs a PowerShell script file containing
        all policy change commands. The script includes a -WhatIf parameter,
        metadata header, and comments for each change. This is the safest
        approach for production use.
    .PARAMETER Commands
        Array of command objects from ConvertTo-PolicyCommands.
    .PARAMETER Decisions
        Array of decision objects from Import-DecisionSheet (used for metadata).
    .PARAMETER OutputPath
        Path to save the generated script. Defaults to a timestamped file.
    .PARAMETER SourceExcel
        Path to the source Excel file (included in the script header for reference).
    .EXAMPLE
        Export-PolicyScript -Commands $commands -Decisions $decisions -OutputPath .\Apply-Decisions.ps1
    #>
    param(
        [Parameter(Mandatory)]
        [object[]]$Commands,

        [object[]]$Decisions,

        [string]$OutputPath,

        [string]$SourceExcel
    )

    if (-not $OutputPath) {
        $OutputPath = Join-Path (Get-Location) ("Apply-PolicyDecisions-{0}.ps1" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
    }

    $totalChanges = ($Commands | ForEach-Object { $_.AffectedSettings.Count } | Measure-Object -Sum).Sum

    $script = [System.Text.StringBuilder]::new()

    # -- Header --
    [void]$script.AppendLine('<#')
    [void]$script.AppendLine('.SYNOPSIS')
    [void]$script.AppendLine('    Apply Teams policy decisions to the Global (org-wide default) policies.')
    [void]$script.AppendLine('.DESCRIPTION')
    [void]$script.AppendLine('    This script was auto-generated from stakeholder decisions in an Excel workbook.')
    [void]$script.AppendLine("    It applies $totalChanges setting changes across $($Commands.Count) cmdlets.")
    [void]$script.AppendLine('    Review all commands below before running. Use -WhatIf to preview changes.')
    [void]$script.AppendLine('.PARAMETER WhatIf')
    [void]$script.AppendLine('    Preview changes without applying them.')
    [void]$script.AppendLine('.NOTES')
    [void]$script.AppendLine("    Source Excel:  $SourceExcel")
    [void]$script.AppendLine("    Generated:     $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
    [void]$script.AppendLine("    Generated by:  $([System.Environment]::UserName)")
    [void]$script.AppendLine("    Machine:       $([System.Environment]::MachineName)")
    [void]$script.AppendLine('#>')
    [void]$script.AppendLine('param(')
    [void]$script.AppendLine('    [switch]$WhatIf')
    [void]$script.AppendLine(')')
    [void]$script.AppendLine('')
    [void]$script.AppendLine('$ErrorActionPreference = ''Continue''')
    [void]$script.AppendLine('')

    # -- Prerequisites check --
    [void]$script.AppendLine('# -- Prerequisites --------------------------------------------------------')
    [void]$script.AppendLine('if (-not (Get-Module -Name MicrosoftTeams)) {')
    [void]$script.AppendLine('    Write-Host "MicrosoftTeams module not loaded. Attempting import..." -ForegroundColor Yellow')
    [void]$script.AppendLine('    Import-Module MicrosoftTeams -ErrorAction Stop')
    [void]$script.AppendLine('}')
    [void]$script.AppendLine('')
    [void]$script.AppendLine('# Verify connection (a simple cmdlet call that requires auth)')
    [void]$script.AppendLine('try {')
    [void]$script.AppendLine('    $null = Get-CsTenant -ErrorAction Stop')
    [void]$script.AppendLine('    Write-Host "Connected to Teams." -ForegroundColor Green')
    [void]$script.AppendLine('}')
    [void]$script.AppendLine('catch {')
    [void]$script.AppendLine('    Write-Host "Not connected to Teams. Please run Connect-MicrosoftTeams first." -ForegroundColor Red')
    [void]$script.AppendLine('    return')
    [void]$script.AppendLine('}')
    [void]$script.AppendLine('')

    # -- WhatIf handling --
    [void]$script.AppendLine('$whatIfParam = @{}')
    [void]$script.AppendLine('if ($WhatIf) {')
    [void]$script.AppendLine('    $whatIfParam = @{ WhatIf = $true }')
    [void]$script.AppendLine('    Write-Host "Running in WhatIf mode -- no changes will be applied." -ForegroundColor Cyan')
    [void]$script.AppendLine('}')
    [void]$script.AppendLine('else {')
    [void]$script.AppendLine('    Write-Host "APPLYING CHANGES to Global policies. Press Ctrl+C within 5 seconds to abort." -ForegroundColor Yellow')
    [void]$script.AppendLine('    Start-Sleep -Seconds 5')
    [void]$script.AppendLine('}')
    [void]$script.AppendLine('')

    # -- Results tracking --
    [void]$script.AppendLine('$results = @()')
    [void]$script.AppendLine('')

    # -- Commands --
    $cmdIndex = 0
    foreach ($cmd in $Commands) {
        $cmdIndex++
        [void]$script.AppendLine("# -- $cmdIndex. $($cmd.SetCmdlet) ($($cmd.Category)) --")
        [void]$script.AppendLine("# Affected settings:")
        foreach ($setting in $cmd.AffectedSettings) {
            [void]$script.AppendLine("#   - $setting")
        }

        # Build the splat
        [void]$script.AppendLine('try {')

        $splatLines = [System.Collections.Generic.List[string]]::new()
        foreach ($key in $cmd.Parameters.Keys) {
            $val = $cmd.Parameters[$key]
            if ($val -is [bool]) {
                $splatLines.Add("        $key = `$$($val.ToString().ToLower())")
            }
            elseif ($val -is [int] -or $val -is [long]) {
                $splatLines.Add("        $key = $val")
            }
            else {
                $escapedVal = ([string]$val) -replace "'", "''"
                $splatLines.Add("        $key = '$escapedVal'")
            }
        }

        [void]$script.AppendLine('    $params = @{')
        [void]$script.AppendLine(($splatLines -join "`n"))
        [void]$script.AppendLine('    }')
        [void]$script.AppendLine("    $($cmd.SetCmdlet) @params @whatIfParam -ErrorAction Stop")
        [void]$script.AppendLine("    Write-Host '  OK: $($cmd.SetCmdlet)' -ForegroundColor Green")
        [void]$script.AppendLine("    `$results += [pscustomobject]@{ Cmdlet = '$($cmd.SetCmdlet)'; Status = 'Success'; Error = `$null }")
        [void]$script.AppendLine('}')
        [void]$script.AppendLine('catch {')
        [void]$script.AppendLine("    Write-Host '  FAILED: $($cmd.SetCmdlet) -- ' `$_.Exception.Message -ForegroundColor Red")
        [void]$script.AppendLine("    `$results += [pscustomobject]@{ Cmdlet = '$($cmd.SetCmdlet)'; Status = 'Failed'; Error = `$_.Exception.Message }")
        [void]$script.AppendLine('}')
        [void]$script.AppendLine('')
    }

    # -- Summary --
    [void]$script.AppendLine('# -- Summary --------------------------------------------------------------')
    [void]$script.AppendLine('Write-Host ""')
    [void]$script.AppendLine('Write-Host "Policy Application Complete" -ForegroundColor Cyan')
    [void]$script.AppendLine('$ok     = @($results | Where-Object Status -eq ''Success'').Count')
    [void]$script.AppendLine('$failed = @($results | Where-Object Status -eq ''Failed'').Count')
    [void]$script.AppendLine('Write-Host "  Success: $ok  |  Failed: $failed"')
    [void]$script.AppendLine('if ($failed -gt 0) {')
    [void]$script.AppendLine('    Write-Host "Failed commands:" -ForegroundColor Red')
    [void]$script.AppendLine('    $results | Where-Object Status -eq ''Failed'' | Format-Table -AutoSize')
    [void]$script.AppendLine('}')

    $scriptText = $script.ToString()
    $scriptText | Set-Content -Path $OutputPath -Encoding UTF8

    Write-StepLog "Policy script generated: $OutputPath"
    Write-StepLog "  $totalChanges setting changes across $($Commands.Count) cmdlets."
    Write-StepLog "  Review the script, then run: .\$(Split-Path $OutputPath -Leaf) -WhatIf"

    $OutputPath
}

# --- Export ------------------------------------------------------------------

Export-ModuleMember -Function @(
    'Import-DecisionSheet',
    'ConvertTo-PolicyCommands',
    'ConvertTo-PolicyValue',
    'New-PolicyChangeReport',
    'Invoke-PolicyDecisions',
    'Export-PolicyScript'
)
