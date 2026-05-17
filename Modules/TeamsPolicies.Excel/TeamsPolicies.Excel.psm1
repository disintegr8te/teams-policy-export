function New-PolicyExcelReport {
    <#
    .SYNOPSIS
        Generates a stakeholder-ready Excel workbook for policy decision meetings.
    .DESCRIPTION
        Creates a workbook with:
        - Overview sheet with executive summary
        - All Decisions sheet (one row per setting, with Decision/Notes columns)
        - Category detail sheets (Meetings, Messaging, etc.) with per-tier breakdown
        - User Impact sheet showing policy assignment distribution
    #>
    param(
        [Parameter(Mandatory)][string]$OutputPath,
        [Parameter(Mandatory)][hashtable]$PolicyData,
        [hashtable]$GlobalRows = @{},
        [hashtable]$ImportantPolicies = @{},
        [hashtable]$PolicyCategories = @{},
        [hashtable]$FriendlyNames = @{},
        [string[]]$PropertyExclusions = @(),
        [hashtable]$PolicyUserCounts = @{},
        [int]$TotalUsers = 0,
        [object[]]$UserAssignments,
        [object[]]$GroupAssignments,
        [Parameter(Mandatory)][object[]]$Manifest
    )

    $excelPath = Join-Path $OutputPath 'TeamsPolicies.xlsx'

    # Remove existing file to start clean
    if (Test-Path $excelPath) { Remove-Item $excelPath -Force }

    Write-StepLog "Generating stakeholder Excel report: $excelPath"

    # --- Build decision rows via analysis module ---
    $decisionRows = Build-DecisionRows `
        -PolicyData $PolicyData `
        -GlobalRows $GlobalRows `
        -ImportantPolicies $ImportantPolicies `
        -PolicyCategories $PolicyCategories `
        -FriendlyNames $FriendlyNames `
        -PropertyExclusions $PropertyExclusions `
        -PolicyUserCounts $PolicyUserCounts `
        -TotalUsers $TotalUsers

    Write-StepLog "Built $($decisionRows.Count) decision rows across all categories."

    # --- 1. Overview sheet ---
    Add-OverviewSheet -ExcelPath $excelPath -DecisionRows $decisionRows `
        -Manifest $Manifest -TotalUsers $TotalUsers -PolicyCategories $PolicyCategories

    # --- 1.5. Action Required sheet ---
    Add-ActionRequiredSheet -ExcelPath $excelPath -DecisionRows $decisionRows -PolicyData $PolicyData

    # --- 2. All Decisions sheet ---
    Add-AllDecisionsSheet -ExcelPath $excelPath -DecisionRows $decisionRows -PolicyData $PolicyData

    # --- 3. Category detail sheets ---
    $categories = $decisionRows | Select-Object -ExpandProperty Category -Unique | Sort-Object
    foreach ($cat in $categories) {
        $catRows = @($decisionRows | Where-Object { $_.Category -eq $cat })
        Add-CategorySheet -ExcelPath $excelPath -Category $cat -Rows $catRows `
            -PolicyData $PolicyData -GlobalRows $GlobalRows `
            -PolicyUserCounts $PolicyUserCounts -PolicyCategories $PolicyCategories `
            -FriendlyNames $FriendlyNames -ImportantPolicies $ImportantPolicies `
            -PropertyExclusions $PropertyExclusions -TotalUsers $TotalUsers
    }

    # --- 4. User Impact sheet ---
    Add-UserImpactSheet -ExcelPath $excelPath `
        -PolicyUserCounts $PolicyUserCounts `
        -GroupAssignments $GroupAssignments `
        -TotalUsers $TotalUsers

    Write-StepLog "Excel report complete: $excelPath"
    $excelPath
}

function Add-OverviewSheet {
    <#
    .SYNOPSIS
        Executive summary sheet for meeting opener.
    #>
    param(
        [Parameter(Mandatory)][string]$ExcelPath,
        [Parameter(Mandatory)][object[]]$DecisionRows,
        [Parameter(Mandatory)][object[]]$Manifest,
        [int]$TotalUsers,
        [hashtable]$PolicyCategories
    )

    $okCount = ($Manifest | Where-Object Status -eq 'OK').Count
    $failedCount = ($Manifest | Where-Object Status -eq 'Failed').Count

    # Build per-category summary
    $categories = $DecisionRows | Select-Object -ExpandProperty Category -Unique | Sort-Object
    $overviewData = foreach ($cat in $categories) {
        $catRows = @($DecisionRows | Where-Object { $_.Category -eq $cat })
        # "Attention Needed" = settings where current Global differs from recommendation
        $driftCount = @($catRows | Where-Object { $_.Recommendation -ne '' -and -not (Test-SemanticEqual -Value1 $_.CurrentGlobal -Value2 $_.Recommendation) }).Count
        $highRisk = @($catRows | Where-Object { $_.RiskLevel -eq 'High' }).Count

        $medRisk = @($catRows | Where-Object { $_.RiskLevel -eq 'Medium' }).Count

        [pscustomobject][ordered]@{
            'Category'                = $cat
            'Settings'                = $catRows.Count
            'With Recommendation'     = @($catRows | Where-Object { $_.Recommendation -ne '' }).Count
            'No Recommendation'       = @($catRows | Where-Object { $_.Recommendation -eq '' }).Count
            'Drifted from Rec.'       = $driftCount
            'High Risk Settings'      = $highRisk
            'Medium Risk Settings'    = $medRisk
            'Go To Sheet'             = $cat
        }
    }

    # Compute executive summary metrics
    $decisionsNeeded = @($DecisionRows | Where-Object {
        ($_.Recommendation -ne '' -and
            -not (Test-SemanticEqual -Value1 $_.CurrentGlobal -Value2 $_.Recommendation)) -or
        ($_.RiskLevel -eq 'High' -and $_.Recommendation -eq '')
    }).Count
    $alreadyAligned = @($DecisionRows | Where-Object {
        $_.Recommendation -ne '' -and
        (Test-SemanticEqual -Value1 $_.CurrentGlobal -Value2 $_.Recommendation)
    }).Count
    $highRiskTotal = @($DecisionRows | Where-Object { $_.RiskLevel -eq 'High' }).Count
    $mediumRiskTotal = @($DecisionRows | Where-Object { $_.RiskLevel -eq 'Medium' }).Count

    # Add totals row
    $overviewData = @($overviewData) + @([pscustomobject][ordered]@{
        'Category'                = 'TOTAL'
        'Settings'                = $DecisionRows.Count
        'With Recommendation'     = @($DecisionRows | Where-Object { $_.Recommendation -ne '' }).Count
        'No Recommendation'       = @($DecisionRows | Where-Object { $_.Recommendation -eq '' }).Count
        'Drifted from Rec.'       = @($DecisionRows | Where-Object { $_.Recommendation -ne '' -and -not (Test-SemanticEqual -Value1 $_.CurrentGlobal -Value2 $_.Recommendation) }).Count
        'High Risk Settings'      = @($DecisionRows | Where-Object { $_.RiskLevel -eq 'High' }).Count
        'Medium Risk Settings'    = @($DecisionRows | Where-Object { $_.RiskLevel -eq 'Medium' }).Count
        'Go To Sheet'             = ''
    })

    $pkg = $overviewData | Export-Excel -Path $ExcelPath `
        -WorksheetName 'Overview' `
        -BoldTopRow `
        -AutoSize `
        -FreezeTopRow `
        -TableName 'Overview' `
        -TableStyle 'Medium2' `
        -StartRow 8 `
        -PassThru

    $ws = $pkg.Workbook.Worksheets['Overview']

    # Header information block
    $ws.Cells['A1'].Value = 'MS Teams Policy Review -- Decision Workbook'
    $ws.Cells['A1'].Style.Font.Size = 16
    $ws.Cells['A1'].Style.Font.Bold = $true

    $ws.Cells['A3'].Value = 'Tenant:'
    $ws.Cells['B3'].Value = '(see tenant connection)'
    $ws.Cells['A4'].Value = 'Export Date:'
    $ws.Cells['B4'].Value = (Get-Date -Format 'yyyy-MM-dd HH:mm')
    $ws.Cells['A5'].Value = 'Total Users:'
    $ws.Cells['B5'].Value = $TotalUsers
    $ws.Cells['A6'].Value = 'Policies Exported:'
    $ws.Cells['B6'].Value = "$okCount OK, $failedCount failed"

    $ws.Cells['D3'].Value = 'Action Items:'
    $ws.Cells['E3'].Value = $decisionsNeeded
    $ws.Cells['D4'].Value = 'Already Aligned:'
    $ws.Cells['E4'].Value = $alreadyAligned
    $ws.Cells['D5'].Value = 'High Risk:'
    $ws.Cells['E5'].Value = $highRiskTotal
    $ws.Cells['D6'].Value = 'Medium Risk:'
    $ws.Cells['E6'].Value = $mediumRiskTotal

    $ws.Cells['A3'].Style.Font.Bold = $true
    $ws.Cells['A4'].Style.Font.Bold = $true
    $ws.Cells['A5'].Style.Font.Bold = $true
    $ws.Cells['A6'].Style.Font.Bold = $true
    $ws.Cells['D3'].Style.Font.Bold = $true
    $ws.Cells['D4'].Style.Font.Bold = $true
    $ws.Cells['D5'].Style.Font.Bold = $true
    $ws.Cells['D6'].Style.Font.Bold = $true

    # Color action items red if > 0
    if ($decisionsNeeded -gt 0) {
        $ws.Cells['E3'].Style.Font.Color.SetColor([System.Drawing.Color]::FromArgb(156, 0, 6))
        $ws.Cells['E3'].Style.Font.Bold = $true
    }
    # Color aligned green
    if ($alreadyAligned -gt 0) {
        $ws.Cells['E4'].Style.Font.Color.SetColor([System.Drawing.Color]::FromArgb(0, 112, 60))
    }

    # Color the High Risk column (column 6 after adding No Recommendation)
    if ($ws.Dimension) {
        $lastRow = $ws.Dimension.End.Row
        for ($r = 9; $r -le $lastRow; $r++) {
            $val = $ws.Cells[$r, 6].Value
            if ($val -and [int]$val -gt 0) {
                $ws.Cells[$r, 6].Style.Font.Color.SetColor([System.Drawing.Color]::FromArgb(156, 0, 6))
                $ws.Cells[$r, 6].Style.Font.Bold = $true
            }
        }

        # Bold the totals row
        $totalsRow = $lastRow
        for ($c = 1; $c -le 8; $c++) {
            $ws.Cells[$totalsRow, $c].Style.Font.Bold = $true
        }

        # Add hyperlinks to category sheets
        $goToCol = 8  # "Go To Sheet" is column 8
        for ($r = 9; $r -le ($lastRow - 1); $r++) {  # Skip totals row
            $sheetName = $ws.Cells[$r, $goToCol].Text
            if ($sheetName -and $sheetName -ne '' -and $sheetName -ne 'TOTAL') {
                $linkSheet = $sheetName
                if ($linkSheet.Length -gt 31) { $linkSheet = $linkSheet.Substring(0, 31) }
                $ws.Cells[$r, $goToCol].Hyperlink = New-Object -TypeName OfficeOpenXml.ExcelHyperLink -ArgumentList ("'$linkSheet'!A1", $sheetName)
                $ws.Cells[$r, $goToCol].Style.Font.Color.SetColor([System.Drawing.Color]::Blue)
                $ws.Cells[$r, $goToCol].Style.Font.UnderLine = $true
            }
        }

        # Quick Links to key sheets
        $ws.Cells['A7'].Value = 'Quick Links:'
        $ws.Cells['A7'].Style.Font.Bold = $true
        $ws.Cells['B7'].Value = 'Action Required'
        $ws.Cells['B7'].Hyperlink = New-Object -TypeName OfficeOpenXml.ExcelHyperLink -ArgumentList ("'Action Required'!A1", 'Action Required')
        $ws.Cells['B7'].Style.Font.Color.SetColor([System.Drawing.Color]::Blue)
        $ws.Cells['B7'].Style.Font.UnderLine = $true
        $ws.Cells['C7'].Value = 'All Decisions'
        $ws.Cells['C7'].Hyperlink = New-Object -TypeName OfficeOpenXml.ExcelHyperLink -ArgumentList ("'All Decisions'!A1", 'All Decisions')
        $ws.Cells['C7'].Style.Font.Color.SetColor([System.Drawing.Color]::Blue)
        $ws.Cells['C7'].Style.Font.UnderLine = $true
    }

    Close-ExcelPackage $pkg
}

function Add-AllDecisionsSheet {
    <#
    .SYNOPSIS
        Master flat decision sheet -- one row per setting, designed for the stakeholder meeting.
    #>
    param(
        [Parameter(Mandatory)][string]$ExcelPath,
        [Parameter(Mandatory)][object[]]$DecisionRows,
        [hashtable]$PolicyData = @{}
    )

    if ($DecisionRows.Count -eq 0) { return }

    # Build display rows (select and rename columns for clarity)
    $displayRows = foreach ($row in $DecisionRows) {
        [pscustomobject][ordered]@{
            'Priority'             = $row.Priority
            'Risk'                 = $row.RiskLevel
            'Setting'              = $row.FriendlyName
            'DECISION'             = ''
            'Notes'                = ''
            'Category'             = $row.Category
            'Current Global'       = $row.CurrentGlobal
            'Recommendation'       = $row.Recommendation
            'Why'                  = $row.RecommendationDetail
            'MS Default'           = $row.MSDefault
            'Changed from Default' = $(if ($row.DriftFromMSDefault) { $row.DriftFromMSDefault } else { '' })
            'Users on Global'      = $row.UsersOnGlobal
            'Users on Other'       = $row.UsersOnOther
            'Value Breakdown'      = $row.ValueBreakdown
            'Property'             = $row.Property
            'Cmdlet'               = $row.Cmdlet
        }
    }

    $displayRows = @($displayRows | Sort-Object -Property { [int]$_.Priority } -Descending)

    $conditions = @(
        New-ConditionalText -Text 'High'   -BackgroundColor '#FFC7CE' -ConditionalTextColor '#9C0006'
        New-ConditionalText -Text 'Medium' -BackgroundColor '#FFF2CC' -ConditionalTextColor '#7F6000'
    )

    $pkg = $displayRows | Export-Excel -Path $ExcelPath `
        -WorksheetName 'All Decisions' `
        -BoldTopRow `
        -AutoSize `
        -AutoFilter `
        -TableName 'AllDecisions' `
        -TableStyle 'Medium4' `
        -ConditionalText $conditions `
        -Append `
        -PassThru

    $ws = $pkg.Workbook.Worksheets['All Decisions']

    # Freeze row 1 (header) + columns 1-4 (Priority, Risk, Setting, DECISION)
    $ws.View.FreezePanes(2, 5)

    if ($ws -and $ws.Dimension) {
        $lastRow = $ws.Dimension.End.Row
        $lastCol = $ws.Dimension.End.Column

        # Header is row 1, data starts at row 2
        $headerRow = 1
        $dataStart = 2

        # Find key columns by header name
        $decisionCol = $null
        $notesCol = $null
        $recCol = $null
        $curCol = $null
        $msDefCol = $null
        $propCol = $null
        $cmdletCol = $null
        for ($c = 1; $c -le $lastCol; $c++) {
            $header = $ws.Cells[$headerRow, $c].Text
            switch ($header) {
                'DECISION'       { $decisionCol = $c }
                'Notes'          { $notesCol = $c }
                'Recommendation' { $recCol = $c }
                'Current Global' { $curCol = $c }
                'MS Default'     { $msDefCol = $c }
                'Property'       { $propCol = $c }
                'Cmdlet'         { $cmdletCol = $c }
            }
        }

        # Add priority legend as comment on header cell
        if ($ws.Cells[1, 1].Text -eq 'Priority') {
            $ws.Cells[1, 1].AddComment('Priority Score (0-90): Risk (+30 High/+15 Med) + Drift from Rec (+40) + Drift from Default (+10) + Users affected (+5) + No guidance (+5)', 'System')
        }

        # Style DECISION column: yellow background, wider
        if ($decisionCol) {
            $ws.Column($decisionCol).Width = 20
            for ($r = $dataStart; $r -le $lastRow; $r++) {
                $ws.Cells[$r, $decisionCol].Style.Fill.PatternType = [OfficeOpenXml.Style.ExcelFillStyle]::Solid
                $ws.Cells[$r, $decisionCol].Style.Fill.BackgroundColor.SetColor([System.Drawing.Color]::FromArgb(255, 242, 204))
                $ws.Cells[$r, $decisionCol].Style.Border.BorderAround([OfficeOpenXml.Style.ExcelBorderStyle]::Thin, [System.Drawing.Color]::FromArgb(191, 191, 191))
            }
            # Bold header
            $ws.Cells[$headerRow, $decisionCol].Style.Fill.PatternType = [OfficeOpenXml.Style.ExcelFillStyle]::Solid
            $ws.Cells[$headerRow, $decisionCol].Style.Fill.BackgroundColor.SetColor([System.Drawing.Color]::FromArgb(255, 192, 0))
            $ws.Cells[$headerRow, $decisionCol].Style.Font.Bold = $true
        }

        # Style Notes column: wider
        if ($notesCol) {
            $ws.Column($notesCol).Width = 30
        }

        # Highlight rows where Current Global differs from Recommendation (red) or matches (green)
        if ($recCol -and $curCol) {
            for ($r = $dataStart; $r -le $lastRow; $r++) {
                $rec = $ws.Cells[$r, $recCol].Text
                $cur = $ws.Cells[$r, $curCol].Text
                if ($rec -ne '') {
                    if (Test-SemanticEqual -Value1 $cur -Value2 $rec) {
                        # Aligned — green
                        $ws.Cells[$r, $curCol].Style.Fill.PatternType = [OfficeOpenXml.Style.ExcelFillStyle]::Solid
                        $ws.Cells[$r, $curCol].Style.Fill.BackgroundColor.SetColor([System.Drawing.Color]::FromArgb(198, 239, 206))
                        $ws.Cells[$r, $curCol].Style.Font.Color.SetColor([System.Drawing.Color]::FromArgb(0, 97, 0))
                    } else {
                        # Drifted — red
                        $ws.Cells[$r, $curCol].Style.Fill.PatternType = [OfficeOpenXml.Style.ExcelFillStyle]::Solid
                        $ws.Cells[$r, $curCol].Style.Fill.BackgroundColor.SetColor([System.Drawing.Color]::FromArgb(255, 199, 206))
                        $ws.Cells[$r, $curCol].Style.Font.Color.SetColor([System.Drawing.Color]::FromArgb(156, 0, 6))
                    }
                }
            }
        }

        # Highlight DECISION cells that represent a change from current
        if ($decisionCol -and $curCol) {
            for ($r = $dataStart; $r -le $lastRow; $r++) {
                $dec = $ws.Cells[$r, $decisionCol].Text
                $cur = $ws.Cells[$r, $curCol].Text
                if ($dec -ne '' -and $dec -ne 'Keep' -and $dec -ne $cur) {
                    $ws.Cells[$r, $decisionCol].Style.Font.Color.SetColor([System.Drawing.Color]::FromArgb(0, 112, 60))
                    $ws.Cells[$r, $decisionCol].Style.Font.Bold = $true
                }
            }
        }

        # Add data validation dropdowns for all settings
        if ($decisionCol -and $cmdletCol) {
            for ($r = $dataStart; $r -le $lastRow; $r++) {
                $cmdletName = $ws.Cells[$r, $cmdletCol].Text
                $propName = $ws.Cells[$r, $propCol].Text

                $validValues = Get-ValidSettingValues -CmdletName $cmdletName -PropertyName $propName -PolicyData $PolicyData
                if ($validValues) {
                    # Excel limits data validation lists to 255 characters total
                    $listString = (@('Keep') + @($validValues)) -join ','
                    if ($listString.Length -gt 255) {
                        Write-StepLog "Skipping dropdown for row $r ($propName): validation list is $($listString.Length) chars (max 255)" -Level Warning
                        continue
                    }
                    try {
                        $cell = $ws.Cells[$r, $decisionCol]
                        $validation = $ws.DataValidations.AddListValidation($cell.Address)
                        $validation.Formula.Values.Add('Keep')
                        foreach ($v in $validValues) {
                            $validation.Formula.Values.Add($v)
                        }
                        $validation.ShowErrorMessage = $false
                    }
                    catch {
                        Write-StepLog "Failed to add dropdown for row $r ($propName): $_" -Level Warning
                    }
                }
            }
        }

        # Set explicit column widths for readability
        for ($c = 1; $c -le $lastCol; $c++) {
            $h = $ws.Cells[1, $c].Text
            switch ($h) {
                'Priority'        { $ws.Column($c).Width = 9 }
                'Risk'            { $ws.Column($c).Width = 9 }
                'Setting'         { $ws.Column($c).Width = 35 }
                'DECISION'        { } # Already set to 20
                'Notes'           { } # Already set to 30
                'Category'        { $ws.Column($c).Width = 22 }
                'Why'             { $ws.Column($c).Width = 45 }
                'Value Breakdown' { $ws.Column($c).Width = 35 }
                'Property'        { $ws.Column($c).Width = 30 }
                'Cmdlet'          { $ws.Column($c).Width = 30 }
            }
        }
    }

    Close-ExcelPackage $pkg
}

function Add-ActionRequiredSheet {
    <#
    .SYNOPSIS
        Shows only settings that need attention: drifted from recommendation or high-risk with no recommendation.
    #>
    param(
        [Parameter(Mandatory)][string]$ExcelPath,
        [Parameter(Mandatory)][object[]]$DecisionRows,
        [hashtable]$PolicyData = @{}
    )

    # Filter to actionable rows: drifted from recommendation, or high risk with no recommendation
    $actionRows = @($DecisionRows | Where-Object {
        ($_.Recommendation -ne '' -and
            -not (Test-SemanticEqual -Value1 $_.CurrentGlobal -Value2 $_.Recommendation)) -or
        ($_.RiskLevel -eq 'High' -and $_.Recommendation -eq '')
    } | Sort-Object -Property { [int]$_.Priority } -Descending)

    if ($actionRows.Count -eq 0) { return }

    $displayRows = foreach ($row in $actionRows) {
        [pscustomobject][ordered]@{
            'Priority'             = $row.Priority
            'Category'             = $row.Category
            'Setting'              = $row.FriendlyName
            'Property'             = $row.Property
            'Risk'                 = $row.RiskLevel
            'MS Default'           = $row.MSDefault
            'Current Global'       = $row.CurrentGlobal
            'Recommendation'       = $row.Recommendation
            'Why'                  = $row.RecommendationDetail
            'Users on Global'      = $row.UsersOnGlobal
            'Users on Other'       = $row.UsersOnOther
            'Value Breakdown'      = $row.ValueBreakdown
            'DECISION'             = ''
            'Notes'                = ''
            'Cmdlet'               = $row.Cmdlet
        }
    }

    $conditions = @(
        New-ConditionalText -Text 'High'   -BackgroundColor '#FFC7CE' -ConditionalTextColor '#9C0006'
        New-ConditionalText -Text 'Medium' -BackgroundColor '#FFF2CC' -ConditionalTextColor '#7F6000'
    )

    $pkg = $displayRows | Export-Excel -Path $ExcelPath `
        -WorksheetName 'Action Required' `
        -BoldTopRow -AutoSize -FreezeTopRowFirstColumn -AutoFilter `
        -TableName 'ActionRequired' -TableStyle 'Medium3' `
        -ConditionalText $conditions -Append -PassThru

    $ws = $pkg.Workbook.Worksheets['Action Required']
    if ($ws -and $ws.Dimension) {
        $lastRow = $ws.Dimension.End.Row
        $lastCol = $ws.Dimension.End.Column

        # Build header map for column lookup
        $decisionCol = $null
        $propCol = $null
        $cmdletCol = $null
        for ($c = 1; $c -le $lastCol; $c++) {
            $h = $ws.Cells[1, $c].Text
            switch ($h) {
                'DECISION' {
                    $decisionCol = $c
                    $ws.Column($c).Width = 20
                    for ($r = 2; $r -le $lastRow; $r++) {
                        $ws.Cells[$r, $c].Style.Fill.PatternType = [OfficeOpenXml.Style.ExcelFillStyle]::Solid
                        $ws.Cells[$r, $c].Style.Fill.BackgroundColor.SetColor([System.Drawing.Color]::FromArgb(255, 242, 204))
                    }
                    $ws.Cells[1, $c].Style.Fill.PatternType = [OfficeOpenXml.Style.ExcelFillStyle]::Solid
                    $ws.Cells[1, $c].Style.Fill.BackgroundColor.SetColor([System.Drawing.Color]::FromArgb(255, 192, 0))
                    $ws.Cells[1, $c].Style.Font.Bold = $true
                }
                'Notes'    { $ws.Column($c).Width = 30 }
                'Property' { $propCol = $c }
                'Cmdlet'   { $cmdletCol = $c }
            }
        }

        # Add data validation dropdowns for DECISION column
        if ($decisionCol -and $cmdletCol -and $propCol) {
            for ($r = 2; $r -le $lastRow; $r++) {
                $cmdletName = $ws.Cells[$r, $cmdletCol].Text
                $propName = $ws.Cells[$r, $propCol].Text

                $validValues = Get-ValidSettingValues -CmdletName $cmdletName -PropertyName $propName -PolicyData $PolicyData
                if ($validValues) {
                    # Excel limits data validation lists to 255 characters total
                    $listString = (@('Keep') + @($validValues)) -join ','
                    if ($listString.Length -gt 255) {
                        Write-StepLog "Skipping dropdown for Action Required row $r ($propName): validation list is $($listString.Length) chars (max 255)" -Level Warning
                        continue
                    }
                    try {
                        $cell = $ws.Cells[$r, $decisionCol]
                        $validation = $ws.DataValidations.AddListValidation($cell.Address)
                        $validation.Formula.Values.Add('Keep')
                        foreach ($v in $validValues) {
                            $validation.Formula.Values.Add($v)
                        }
                        $validation.ShowErrorMessage = $false
                    }
                    catch {
                        Write-StepLog "Failed to add dropdown for Action Required row $r ($propName): $_" -Level Warning
                    }
                }
            }
        }
    }

    Close-ExcelPackage $pkg
}

function Add-CategorySheet {
    <#
    .SYNOPSIS
        Creates a category detail sheet with per-policy-tier value columns.
    #>
    param(
        [Parameter(Mandatory)][string]$ExcelPath,
        [Parameter(Mandatory)][string]$Category,
        [Parameter(Mandatory)][object[]]$Rows,
        [Parameter(Mandatory)][hashtable]$PolicyData,
        [hashtable]$GlobalRows = @{},
        [hashtable]$PolicyUserCounts = @{},
        [hashtable]$PolicyCategories = @{},
        [hashtable]$FriendlyNames = @{},
        [hashtable]$ImportantPolicies = @{},
        [string[]]$PropertyExclusions = @(),
        [int]$TotalUsers = 0
    )

    $sheetName = $Category
    if ($sheetName.Length -gt 31) { $sheetName = $sheetName.Substring(0, 31) }

    # Collect all non-Global policy tiers for cmdlets in this category
    $cmdletsInCat = @()
    foreach ($key in $PolicyCategories.Keys) {
        if ($key -eq $Category) { $cmdletsInCat = @($PolicyCategories[$key]); break }
    }

    # Find all distinct custom tier names across cmdlets in this category
    $customTiers = [System.Collections.Generic.List[string]]::new()
    foreach ($cmd in $cmdletsInCat) {
        if (-not $PolicyData.ContainsKey($cmd)) { continue }
        foreach ($record in $PolicyData[$cmd]) {
            $id = ''
            if ($record.PSObject.Properties['Identity']) {
                $id = ([string]$record.Identity) -replace '^Tag:', ''
            }
            if ($id -ne 'Global' -and $id -ne '' -and $customTiers -notcontains $id) {
                $customTiers.Add($id)
            }
        }
    }
    $customTiers = @($customTiers | Sort-Object)

    # Build display rows with dynamic tier columns
    $displayRows = foreach ($row in $Rows) {
        $base = [ordered]@{
            'Setting'            = $row.FriendlyName
            'Property'           = $row.Property
            'Cmdlet'             = ($row.Cmdlet -replace '^Get-Cs', '')
            'MS Default'         = $row.MSDefault
            'Global (Current)'   = $row.CurrentGlobal
            'Recommendation'     = $row.Recommendation
            'Risk'               = $row.RiskLevel
        }

        # Add per-tier value columns
        foreach ($tier in $customTiers) {
            $tierVal = ''
            if ($PolicyData.ContainsKey($row.Cmdlet)) {
                $tierRecord = $PolicyData[$row.Cmdlet] | Where-Object {
                    $_.PSObject.Properties['Identity'] -and
                    (([string]$_.Identity -replace '^Tag:', '') -eq $tier)
                } | Select-Object -First 1
                if ($tierRecord -and $tierRecord.PSObject.Properties[$row.Property]) {
                    $tierVal = [string]$tierRecord.PSObject.Properties[$row.Property].Value
                }
            }
            $base["$tier"] = $tierVal
        }

        $base['Users on Global'] = $row.UsersOnGlobal
        $base['Users on Other']  = $row.UsersOnOther
        $base['DECISION']        = ''
        $base['Notes']           = ''

        [pscustomobject]$base
    }

    if ($displayRows.Count -eq 0) { return }

    $tableName = ($sheetName -replace '[^a-zA-Z0-9]', '') + 'Detail'

    $conditions = @(
        New-ConditionalText -Text 'High'   -BackgroundColor '#FFC7CE' -ConditionalTextColor '#9C0006'
        New-ConditionalText -Text 'Medium' -BackgroundColor '#FFF2CC' -ConditionalTextColor '#7F6000'
    )

    $pkg = $displayRows | Export-Excel -Path $ExcelPath `
        -WorksheetName $sheetName `
        -BoldTopRow `
        -AutoSize `
        -FreezeTopRowFirstColumn `
        -AutoFilter `
        -TableName $tableName `
        -TableStyle 'Medium6' `
        -ConditionalText $conditions `
        -Append `
        -PassThru

    $ws = $pkg.Workbook.Worksheets[$sheetName]

    if ($ws -and $ws.Dimension) {
        $lastRow = $ws.Dimension.End.Row
        $lastCol = $ws.Dimension.End.Column

        # Build header map
        $headerMap = @{}
        for ($c = 1; $c -le $lastCol; $c++) {
            $headerMap[$ws.Cells[1, $c].Text] = $c
        }

        # Style DECISION column
        if ($headerMap.ContainsKey('DECISION')) {
            $dc = $headerMap['DECISION']
            $ws.Column($dc).Width = 20
            for ($r = 2; $r -le $lastRow; $r++) {
                $ws.Cells[$r, $dc].Style.Fill.PatternType = [OfficeOpenXml.Style.ExcelFillStyle]::Solid
                $ws.Cells[$r, $dc].Style.Fill.BackgroundColor.SetColor([System.Drawing.Color]::FromArgb(255, 242, 204))
            }
            $ws.Cells[1, $dc].Style.Fill.PatternType = [OfficeOpenXml.Style.ExcelFillStyle]::Solid
            $ws.Cells[1, $dc].Style.Fill.BackgroundColor.SetColor([System.Drawing.Color]::FromArgb(255, 192, 0))
        }

        # Highlight tier columns where value differs from Global
        $globalCol = $headerMap['Global (Current)']
        foreach ($tier in $customTiers) {
            if (-not $headerMap.ContainsKey($tier)) { continue }
            $tc = $headerMap[$tier]
            # Color tier header
            $ws.Cells[1, $tc].Style.Fill.PatternType = [OfficeOpenXml.Style.ExcelFillStyle]::Solid
            $ws.Cells[1, $tc].Style.Fill.BackgroundColor.SetColor([System.Drawing.Color]::FromArgb(180, 198, 231))

            for ($r = 2; $r -le $lastRow; $r++) {
                $tierVal = $ws.Cells[$r, $tc].Text
                $gVal = $ws.Cells[$r, $globalCol].Text
                if ($tierVal -ne '' -and $tierVal -ne $gVal) {
                    $ws.Cells[$r, $tc].Style.Fill.PatternType = [OfficeOpenXml.Style.ExcelFillStyle]::Solid
                    $ws.Cells[$r, $tc].Style.Fill.BackgroundColor.SetColor([System.Drawing.Color]::FromArgb(255, 255, 204))
                    $ws.Cells[$r, $tc].Style.Font.Color.SetColor([System.Drawing.Color]::FromArgb(156, 0, 6))
                }
            }
        }

        # Highlight Current Global cells that differ from Recommendation
        if ($headerMap.ContainsKey('Recommendation') -and $globalCol) {
            $recCol = $headerMap['Recommendation']
            for ($r = 2; $r -le $lastRow; $r++) {
                $rec = $ws.Cells[$r, $recCol].Text
                $cur = $ws.Cells[$r, $globalCol].Text
                if ($rec -ne '' -and -not (Test-SemanticEqual -Value1 $cur -Value2 $rec)) {
                    $ws.Cells[$r, $globalCol].Style.Fill.PatternType = [OfficeOpenXml.Style.ExcelFillStyle]::Solid
                    $ws.Cells[$r, $globalCol].Style.Fill.BackgroundColor.SetColor([System.Drawing.Color]::FromArgb(255, 199, 206))
                    $ws.Cells[$r, $globalCol].Style.Font.Color.SetColor([System.Drawing.Color]::FromArgb(156, 0, 6))
                }
            }
        }

        # Notes column wider
        if ($headerMap.ContainsKey('Notes')) {
            $ws.Column($headerMap['Notes']).Width = 30
        }

        # Add note to DECISION header
        if ($headerMap.ContainsKey('DECISION')) {
            $dc = $headerMap['DECISION']
            $ws.Cells[1, $dc].AddComment('Enter decisions in the "All Decisions" sheet for consistency. Use this sheet for reference only.', 'System')
        }
    }

    Close-ExcelPackage $pkg
}

function Add-UserImpactSheet {
    <#
    .SYNOPSIS
        Shows user distribution across policy tiers.
    #>
    param(
        [Parameter(Mandatory)][string]$ExcelPath,
        [hashtable]$PolicyUserCounts = @{},
        [object[]]$GroupAssignments,
        [int]$TotalUsers = 0
    )

    $rows = [System.Collections.Generic.List[object]]::new()

    foreach ($policyType in ($PolicyUserCounts.Keys | Sort-Object)) {
        $tiers = $PolicyUserCounts[$policyType]
        foreach ($tierName in ($tiers.Keys | Sort-Object)) {
            $count = $tiers[$tierName]
            $pct = $(if ($TotalUsers -gt 0) { [math]::Round(($count / $TotalUsers) * 100, 1) } else { 0 })

            # Determine assignment method
            $method = $(if ($tierName -eq 'Global') { 'Default (inherited)' } else { 'Direct / Group' })

            # Find group name if applicable
            $groupInfo = ''
            if ($GroupAssignments) {
                $matching = @($GroupAssignments | Where-Object {
                    $_.PolicyType -eq $policyType -and $_.PolicyName -eq $tierName
                })
                if ($matching.Count -gt 0) {
                    $method = 'Group'
                    $groupInfo = ($matching | ForEach-Object { $_.GroupId }) -join ', '
                }
            }

            $rows.Add([pscustomobject][ordered]@{
                'Policy Type'       = $policyType
                'Policy Name'       = $tierName
                'Assignment'        = $method
                'User Count'        = $count
                'Percentage'        = "$pct%"
                'Group ID'          = $groupInfo
            })
        }
    }

    if ($rows.Count -eq 0) { return }

    $conditions = @(
        New-ConditionalText -Text 'Default (inherited)' -BackgroundColor '#D9E2F3' -ConditionalTextColor '#2F5496'
        New-ConditionalText -Text 'Group'               -BackgroundColor '#E2EFDA' -ConditionalTextColor '#375623'
    )

    $rows | Export-Excel -Path $ExcelPath `
        -WorksheetName 'User Impact' `
        -BoldTopRow `
        -AutoSize `
        -FreezeTopRow `
        -AutoFilter `
        -TableName 'UserImpact' `
        -TableStyle 'Medium2' `
        -ConditionalText $conditions `
        -Append
}

function Add-DataSheet {
    <#
    .SYNOPSIS
        Adds a simple formatted data sheet to the workbook.
    #>
    param(
        [Parameter(Mandatory)][string]$ExcelPath,
        [Parameter(Mandatory)][string]$SheetName,
        [Parameter(Mandatory)][object[]]$Data
    )

    if ($SheetName.Length -gt 31) {
        $SheetName = $SheetName.Substring(0, 31)
    }

    $Data | Export-Excel -Path $ExcelPath `
        -WorksheetName $SheetName `
        -BoldTopRow `
        -AutoSize `
        -FreezeTopRow `
        -AutoFilter `
        -TableName ($SheetName -replace '[^a-zA-Z0-9]', '') `
        -TableStyle 'Medium6' `
        -Append
}

Export-ModuleMember -Function @(
    'New-PolicyExcelReport',
    'Add-OverviewSheet',
    'Add-ActionRequiredSheet',
    'Add-AllDecisionsSheet',
    'Add-CategorySheet',
    'Add-UserImpactSheet',
    'Add-DataSheet'
)
