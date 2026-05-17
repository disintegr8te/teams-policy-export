function Get-UserPolicyAssignments {
    <#
    .SYNOPSIS
        Retrieves user policy assignments in batches for large tenant support.
    .DESCRIPTION
        Processes users in configurable batches to keep memory usage proportional
        to batch size rather than total tenant size.
    #>
    param(
        [int]$ResultSize = 500000,
        [int]$BatchSize  = 5000,
        [string]$TempDir
    )

    Write-StepLog "Retrieving user policy assignments (ResultSize=$ResultSize, BatchSize=$BatchSize)..."

    $tempCsvPath = Join-Path $TempDir 'UserAssignments_temp.csv'
    $totalUsers  = 0
    $firstBatch  = $true

    # Get-CsOnlineUser doesn't support Top/Skip consistently across module versions.
    # Use -ResultSize with a single call, then process the pipeline in chunks.
    $userBuffer = [System.Collections.Generic.List[object]]::new()

    Get-CsOnlineUser -ResultSize $ResultSize | ForEach-Object {
        $userBuffer.Add($_)

        if ($userBuffer.Count -ge $BatchSize) {
            $rows = ConvertTo-NormalizedAssignments -Users $userBuffer
            if ($rows.Count -gt 0) {
                if ($firstBatch) {
                    $rows | Export-Csv -Path $tempCsvPath -NoTypeInformation -Encoding UTF8
                    $firstBatch = $false
                }
                else {
                    $rows | Export-Csv -Path $tempCsvPath -NoTypeInformation -Encoding UTF8 -Append
                }
            }
            $totalUsers += @($userBuffer | Where-Object {
                @($_.PSObject.Properties | Where-Object { $_.Name -match 'Policy' -and $null -ne $_.Value -and [string]$_.Value -ne '' }).Count -gt 0
            }).Count
            Write-StepLog "  Processed $totalUsers users..."
            $userBuffer.Clear()
        }
    }

    # Flush remaining users
    if ($userBuffer.Count -gt 0) {
        $rows = ConvertTo-NormalizedAssignments -Users $userBuffer
        if ($rows.Count -gt 0) {
            if ($firstBatch) {
                $rows | Export-Csv -Path $tempCsvPath -NoTypeInformation -Encoding UTF8
            }
            else {
                $rows | Export-Csv -Path $tempCsvPath -NoTypeInformation -Encoding UTF8 -Append
            }
        }
        $totalUsers += @($userBuffer | Where-Object {
            @($_.PSObject.Properties | Where-Object { $_.Name -match 'Policy' -and $null -ne $_.Value -and [string]$_.Value -ne '' }).Count -gt 0
        }).Count
    }

    Write-StepLog "User policy assignments complete: $totalUsers users processed."

    [pscustomobject]@{
        TotalUsers = $totalUsers
        CsvPath    = $tempCsvPath
    }
}

function Get-UserPolicyAssignmentsSummary {
    <#
    .SYNOPSIS
        Retrieves a compact per-user summary with all policy properties as columns.
        Better for overview sheets. Uses batched processing for large tenants.
    #>
    param(
        [int]$ResultSize = 500000,
        [int]$BatchSize  = 5000
    )

    Write-StepLog "Retrieving user policy summary (ResultSize=$ResultSize)..."

    $allRows   = [System.Collections.Generic.List[object]]::new()
    $buffer    = [System.Collections.Generic.List[object]]::new()
    $processed = 0

    Get-CsOnlineUser -ResultSize $ResultSize | ForEach-Object {
        $buffer.Add($_)

        if ($buffer.Count -ge $BatchSize) {
            foreach ($u in $buffer) {
                $allRows.Add((ConvertTo-UserPolicySummaryRow -User $u))
            }
            $processed += $buffer.Count
            Write-StepLog "  Summarized $processed users..."
            $buffer.Clear()
        }
    }

    # Flush
    foreach ($u in $buffer) {
        $allRows.Add((ConvertTo-UserPolicySummaryRow -User $u))
    }
    $processed += $buffer.Count

    Write-StepLog "User summary complete: $processed users."
    @($allRows)
}

function ConvertTo-UserPolicySummaryRow {
    <#
    .SYNOPSIS
        Converts a single CsOnlineUser object to a compact summary row.
    #>
    param([Parameter(Mandatory)][object]$User)

    $row = [ordered]@{
        DisplayName       = $User.DisplayName
        UserPrincipalName = $User.UserPrincipalName
        Identity          = $User.Identity
        TeamsUpgradeMode  = $User.TeamsUpgradeEffectiveMode
        EnterpriseVoice   = $User.EnterpriseVoiceEnabled
    }

    # Add all *Policy properties dynamically
    $User.PSObject.Properties |
        Where-Object { $_.Name -match 'Policy' -and $null -ne $_.Value -and [string]$_.Value -ne '' } |
        Sort-Object Name |
        ForEach-Object { $row[$_.Name] = [string]$_.Value }

    [pscustomobject]$row
}

function ConvertTo-NormalizedAssignments {
    <#
    .SYNOPSIS
        Explodes user objects into normalized (User, PolicyType, PolicyName) rows.
        One row per user-policy pair, making the data filterable and pivot-friendly.
    #>
    param(
        [Parameter(Mandatory)][System.Collections.Generic.List[object]]$Users
    )

    $rows = [System.Collections.Generic.List[object]]::new()

    foreach ($u in $Users) {
        $policyProps = @(
            $u.PSObject.Properties |
            Where-Object {
                $_.Name -match 'Policy' -and
                $null -ne $_.Value -and
                [string]$_.Value -ne ''
            } |
            Sort-Object Name
        )

        foreach ($pp in $policyProps) {
            $rows.Add([pscustomobject]@{
                DisplayName       = $u.DisplayName
                UserPrincipalName = $u.UserPrincipalName
                Identity          = $u.Identity
                PolicyType        = $pp.Name
                PolicyName        = [string]$pp.Value
            })
        }
    }

    @($rows)
}

function Get-GroupAssignments {
    <#
    .SYNOPSIS
        Retrieves group-based policy assignments with error handling.
    #>
    try {
        Write-StepLog "Retrieving group policy assignments..."
        $result = @(Get-CsGroupPolicyAssignment -ErrorAction Stop)
        Write-StepLog "Group assignments retrieved: $($result.Count) entries."
        $result
    }
    catch {
        Write-StepLog "Group assignments failed: $($_.Exception.Message)" -Level Warning
        throw
    }
}

Export-ModuleMember -Function @(
    'Get-UserPolicyAssignments',
    'Get-UserPolicyAssignmentsSummary',
    'ConvertTo-NormalizedAssignments',
    'ConvertTo-UserPolicySummaryRow',
    'Get-GroupAssignments'
)
