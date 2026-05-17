function Get-PolicyTypeFromCmdlet {
    <#
    .SYNOPSIS
        Derives the policy type name used in assignments from a cmdlet name.
    .DESCRIPTION
        Strips the "Get-Cs" prefix (and optionally "Online") to produce the
        policy type key used in UserAssignments and GroupAssignments.
    .EXAMPLE
        Get-PolicyTypeFromCmdlet -CmdletName 'Get-CsTeamsMeetingPolicy'
        # Returns: TeamsMeetingPolicy
    #>
    param([Parameter(Mandatory)][string]$CmdletName)

    $CmdletName -replace '^Get-Cs', ''
}

function Get-PolicyUserCounts {
    <#
    .SYNOPSIS
        Counts distinct users per (PolicyType, PolicyName) and computes Global remainder.
    .DESCRIPTION
        Builds a hashtable keyed by PolicyType, each containing a hashtable of
        PolicyName -> user count.  The 'Global' entry is computed as
        TotalUsers minus the sum of all explicit assignments for that type.
        Group assignment counts are included as well.
    #>
    param(
        [object[]]$UserAssignments,
        [int]$TotalUsers,
        [object[]]$GroupAssignments
    )

    $result = @{}

    # Types that are meta/noise and should not be included in user counts
    $skipTypes = @('EffectivePolicyAssignments', 'TeamsUpgradePolicyIsReadOnly', 'TeamsVerticalPackagePolicy')

    # -- Direct user assignments: count distinct users per (PolicyType, PolicyName) --
    if ($UserAssignments -and $UserAssignments.Count -gt 0) {
        $grouped = $UserAssignments | Where-Object { $_.PolicyType -notin $skipTypes } | Group-Object -Property PolicyType
        foreach ($typeGroup in $grouped) {
            $policyType = $typeGroup.Name
            if (-not $result.ContainsKey($policyType)) {
                $result[$policyType] = @{}
            }

            $byPolicy = $typeGroup.Group | Group-Object -Property PolicyName
            foreach ($policyGroup in $byPolicy) {
                $policyName = $policyGroup.Name
                $distinctUsers = @($policyGroup.Group |
                    Select-Object -ExpandProperty UserPrincipalName -Unique).Count

                if ($result[$policyType].ContainsKey($policyName)) {
                    $result[$policyType][$policyName] += $distinctUsers
                }
                else {
                    $result[$policyType][$policyName] = $distinctUsers
                }
            }
        }
    }

    # -- Group assignments: mark as existing; estimate minimum count --
    if ($GroupAssignments -and $GroupAssignments.Count -gt 0) {
        foreach ($ga in $GroupAssignments) {
            $policyType = $ga.PolicyType
            $policyName = $ga.PolicyName
            if (-not $policyType -or -not $policyName) { continue }

            if (-not $result.ContainsKey($policyType)) {
                $result[$policyType] = @{}
            }
            # If this tier wasn't seen in direct assignments, mark it as group-assigned
            # with a minimum count of 1 so it appears in reporting and affects Global remainder
            if (-not $result[$policyType].ContainsKey($policyName)) {
                $result[$policyType][$policyName] = 1
            }
        }
    }

    # -- Compute Global remainder for each PolicyType --
    foreach ($policyType in @($result.Keys)) {
        $explicitSum = 0
        foreach ($key in @($result[$policyType].Keys)) {
            if ($key -ne 'Global') {
                $explicitSum += $result[$policyType][$key]
            }
        }
        $globalCount = $TotalUsers - $explicitSum
        if ($globalCount -lt 0) { $globalCount = 0 }
        $result[$policyType]['Global'] = $globalCount
    }

    $result
}

function ConvertTo-FriendlyNameAlgorithmic {
    <#
    .SYNOPSIS
        Converts a PascalCase property name to a human-readable string.
    .EXAMPLE
        ConvertTo-FriendlyNameAlgorithmic -PropertyName 'AllowAnonymousUsersToJoinMeeting'
        # Returns: Allow anonymous users to join meeting
    #>
    param([Parameter(Mandatory)][string]$PropertyName)

    # Known acronyms to keep together
    $acronyms = @('IP','URL','AI','VDI','NDI','PSTN','SIP','QnA','BYOD',
                   'MES','ERP','CAD','DLP','SSO','MFA','API','SDK','CDN',
                   'PTZ','SMS','CART','HDMI','USB')

    $name = $PropertyName

    # Protect known acronyms by temporarily replacing them
    $replacements = @{}
    foreach ($acr in ($acronyms | Sort-Object -Property Length -Descending)) {
        if ($name -cmatch $acr) {
            $placeholder = "__ACR_${acr}__"
            $replacements[$placeholder] = $acr
            $name = $name -creplace $acr, $placeholder
        }
    }

    # Insert spaces around placeholders so they become separate words
    $name = $name -creplace '([a-z\d])(__ACR_)', '$1 $2'
    $name = $name -creplace '(__ACR_[A-Z]+__)([A-Za-z])', '$1 $2'

    # Insert space before uppercase letters that follow a lowercase letter or digit
    $name = $name -creplace '([a-z\d])([A-Z])', '$1 $2'
    # Insert space before uppercase letter followed by uppercase then lowercase (e.g. "ABc" -> "A Bc")
    $name = $name -creplace '([A-Z]+)([A-Z][a-z])', '$1 $2'

    # Restore acronyms
    foreach ($key in $replacements.Keys) {
        $name = $name -replace [regex]::Escape($key), $replacements[$key]
    }

    # Lowercase everything except first character and acronyms
    $words = $name -split '\s+'
    $result = @()
    for ($i = 0; $i -lt $words.Count; $i++) {
        $word = $words[$i]
        if ($word -cin $acronyms) {
            $result += $word
        }
        elseif ($i -eq 0) {
            $result += $word.Substring(0,1).ToUpper() + $word.Substring(1).ToLower()
        }
        else {
            $result += $word.ToLower()
        }
    }

    ($result -join ' ')
}

function Get-FriendlySettingName {
    <#
    .SYNOPSIS
        Resolves a human-readable name for a policy property using a three-tier lookup.
    .DESCRIPTION
        1. Check ImportantPolicies for a Label matching CmdletName + PropertyName
        2. Check FriendlyNames hashtable for "$CmdletName.$PropertyName"
        3. Fall back to ConvertTo-FriendlyNameAlgorithmic
    #>
    param(
        [Parameter(Mandatory)][string]$CmdletName,
        [Parameter(Mandatory)][string]$PropertyName,
        [hashtable]$ImportantPolicies,
        [hashtable]$FriendlyNames
    )

    # Tier 1: ImportantPolicies label
    if ($ImportantPolicies -and $ImportantPolicies.ContainsKey($CmdletName)) {
        $entries = $ImportantPolicies[$CmdletName]
        foreach ($entry in $entries) {
            if ($entry.Property -eq $PropertyName -and $entry.Label) {
                return $entry.Label
            }
        }
    }

    # Tier 2: FriendlyNames hashtable
    $lookupKey = "$CmdletName.$PropertyName"
    if ($FriendlyNames -and $FriendlyNames.ContainsKey($lookupKey)) {
        return $FriendlyNames[$lookupKey]
    }

    # Tier 3: Algorithmic conversion
    ConvertTo-FriendlyNameAlgorithmic -PropertyName $PropertyName
}

function Get-RiskLevel {
    <#
    .SYNOPSIS
        Returns a risk level (High, Medium, Low) based on property name patterns.
    .DESCRIPTION
        First checks ImportantPolicies config for a Risk override for this
        cmdlet+property. If none found, falls back to keyword pattern matching.
    #>
    param(
        [Parameter(Mandatory)][string]$PropertyName,
        [string]$Category,
        [hashtable]$ImportantPolicies,
        [string]$CmdletName
    )

    # Config-driven override
    if ($ImportantPolicies -and $CmdletName -and $ImportantPolicies.ContainsKey($CmdletName)) {
        foreach ($entry in $ImportantPolicies[$CmdletName]) {
            if ($entry.Property -eq $PropertyName -and $entry.Risk) {
                return $entry.Risk
            }
        }
    }

    $highPatterns = @('Anonymous','Federation','External','ScreenSharing',
                      'AutoAdmit','Guest','Lobby')
    $mediumPatterns = @('Recording','Transcription','Delete','Priority',
                        'Broadcast','CatalogApps','Encryption')

    foreach ($pattern in $highPatterns) {
        if ($PropertyName -match $pattern) { return 'High' }
    }
    foreach ($pattern in $mediumPatterns) {
        if ($PropertyName -match $pattern) { return 'Medium' }
    }

    'Low'
}

function Get-SettingValueDistribution {
    <#
    .SYNOPSIS
        Produces a human-readable breakdown of setting values across policy tiers
        weighted by user counts.
    .DESCRIPTION
        Returns a string like "True (8,350 users) / False (24 users)".
    #>
    param(
        [Parameter(Mandatory)][string]$CmdletName,
        [Parameter(Mandatory)][string]$PropertyName,
        [hashtable]$PolicyData,
        [hashtable]$PolicyUserCounts
    )

    $policyType = Get-PolicyTypeFromCmdlet -CmdletName $CmdletName

    if (-not $PolicyData.ContainsKey($CmdletName)) { return '' }
    $records = $PolicyData[$CmdletName]
    if (-not $records -or $records.Count -eq 0) { return '' }

    $tierCounts = $(if ($PolicyUserCounts -and $PolicyUserCounts.ContainsKey($policyType)) {
        $PolicyUserCounts[$policyType]
    } else { @{} })

    # Build value -> total user count mapping
    $valueCounts = @{}
    foreach ($record in $records) {
        $value = $null
        if ($record.PSObject.Properties[$PropertyName]) {
            $value = $record.$PropertyName
        }
        $valueStr = $(if ($null -eq $value) { 'Not set' } else { [string]$value })

        # Determine policy name from Identity
        $identity = ''
        if ($record.PSObject.Properties['Identity']) {
            $identity = [string]$record.Identity
        }

        # Normalise identity to match PolicyUserCounts keys
        $policyName = $identity -replace '^Tag:', ''
        if ($policyName -eq 'Global' -or $policyName -like '*:Global') {
            $policyName = 'Global'
        }

        $userCount = 0
        if ($tierCounts.ContainsKey($policyName)) {
            $userCount = $tierCounts[$policyName]
        }

        if ($valueCounts.ContainsKey($valueStr)) {
            $valueCounts[$valueStr] += $userCount
        }
        else {
            $valueCounts[$valueStr] = $userCount
        }
    }

    # Format output sorted by user count descending
    $parts = @()
    $sorted = $valueCounts.GetEnumerator() | Sort-Object -Property Value -Descending
    foreach ($kv in $sorted) {
        $formattedCount = '{0:N0}' -f $kv.Value
        $parts += "$($kv.Key) ($formattedCount users)"
    }

    $parts -join ' / '
}

function Get-ValidSettingValues {
    <#
    .SYNOPSIS
        Inspects all values across all policy tiers for a property and returns
        the set of valid values if they form a small enumeration.
    .DESCRIPTION
        If all values are True/False, returns @('True','False').
        If there are <= 10 distinct enum values, returns them sorted.
        Otherwise returns $null (no dropdown).
    #>
    param(
        [Parameter(Mandatory)][string]$CmdletName,
        [Parameter(Mandatory)][string]$PropertyName,
        [hashtable]$PolicyData
    )

    if (-not $PolicyData.ContainsKey($CmdletName)) { return $null }
    $records = $PolicyData[$CmdletName]
    if (-not $records -or $records.Count -eq 0) { return $null }

    $values = @()
    foreach ($record in $records) {
        if ($record.PSObject.Properties[$PropertyName]) {
            $val = $record.$PropertyName
            if ($null -ne $val) {
                $values += [string]$val
            }
        }
    }

    $distinct = @($values | Sort-Object -Unique)
    if ($distinct.Count -eq 0) { return $null }

    # Check for boolean pattern
    $boolSet = @('True','False')
    $isBool = ($distinct | Where-Object { $_ -notin $boolSet }).Count -eq 0
    if ($isBool) { return @('True','False') }

    # Small enum set
    if ($distinct.Count -le 10) { return $distinct }

    $null
}

function Test-SemanticEqual {
    <#
    .SYNOPSIS
        Compares two setting values for semantic equivalence.
    .DESCRIPTION
        Returns $true if the two values are semantically equivalent, handling
        the common Teams API mismatches where the API returns Enabled/Disabled
        or 0/1 while configuration files use True/False or Enabled/Disabled.

        Equivalence groups:
          True  = Enabled = 1
          False = Disabled = 0

        Comparison is case-insensitive.
    .EXAMPLE
        Test-SemanticEqual -Value1 'Enabled' -Value2 'True'   # $true
        Test-SemanticEqual -Value1 '0' -Value2 'Disabled'     # $true
        Test-SemanticEqual -Value1 'True' -Value2 'False'     # $false
    #>
    param(
        [Parameter(Mandatory)][string]$Value1,
        [Parameter(Mandatory)][string]$Value2
    )

    $v1 = $Value1.Trim()
    $v2 = $Value2.Trim()

    # Fast path: case-insensitive exact match
    if ([string]::Compare($v1, $v2, [StringComparison]::OrdinalIgnoreCase) -eq 0) {
        return $true
    }

    # Normalise each value to a canonical form within its equivalence group
    $truthy  = @('true', 'enabled', '1')
    $falsy   = @('false', 'disabled', '0')

    $canon1 = $null
    $canon2 = $null

    if ($v1.ToLower() -in $truthy)  { $canon1 = 'T' }
    elseif ($v1.ToLower() -in $falsy)  { $canon1 = 'F' }

    if ($v2.ToLower() -in $truthy)  { $canon2 = 'T' }
    elseif ($v2.ToLower() -in $falsy)  { $canon2 = 'F' }

    # If both values mapped to a canonical group, compare the groups
    if ($null -ne $canon1 -and $null -ne $canon2) {
        return $canon1 -eq $canon2
    }

    # Otherwise they are not equal (the fast-path already handled exact matches)
    $false
}

function Build-DecisionRows {
    <#
    .SYNOPSIS
        Builds an array of decision-support rows, one per policy setting.
    .DESCRIPTION
        Iterates each category/cmdlet/property and produces a PSCustomObject
        with current values, recommendations, risk levels, and user-count breakdowns.
    #>
    param(
        [hashtable]$PolicyData,
        [hashtable]$GlobalRows,
        [hashtable]$ImportantPolicies,
        [hashtable]$PolicyCategories,
        [hashtable]$FriendlyNames,
        [string[]]$PropertyExclusions,
        [hashtable]$PolicyUserCounts,
        [int]$TotalUsers
    )

    $rows = @()

    foreach ($category in $PolicyCategories.Keys) {
        $cmdlets = $PolicyCategories[$category]
        if (-not $cmdlets) { continue }

        foreach ($cmdletName in $cmdlets) {
            if (-not $GlobalRows.ContainsKey($cmdletName)) { continue }
            $globalRow = $GlobalRows[$cmdletName]
            if (-not $globalRow) { continue }

            $policyType = Get-PolicyTypeFromCmdlet -CmdletName $cmdletName

            # Get user counts for this policy type
            $tierCounts = $(if ($PolicyUserCounts -and $PolicyUserCounts.ContainsKey($policyType)) {
                $PolicyUserCounts[$policyType]
            } else { @{} })

            $usersOnGlobal = $(if ($tierCounts.ContainsKey('Global')) { $tierCounts['Global'] } else { $TotalUsers })
            $usersOnOther  = $TotalUsers - $usersOnGlobal
            if ($usersOnOther -lt 0) { $usersOnOther = 0 }

            # Iterate properties of the Global row
            foreach ($prop in $globalRow.PSObject.Properties) {
                $propertyName = $prop.Name

                # Skip excluded properties
                if ($PropertyExclusions -and $propertyName -in $PropertyExclusions) { continue }

                $currentGlobal = $(if ($null -eq $prop.Value) { 'Not set' } else { [string]$prop.Value })

                $friendlyName = Get-FriendlySettingName `
                    -CmdletName $cmdletName `
                    -PropertyName $propertyName `
                    -ImportantPolicies $ImportantPolicies `
                    -FriendlyNames $FriendlyNames

                $riskLevel = Get-RiskLevel -PropertyName $propertyName -Category $category `
                    -ImportantPolicies $ImportantPolicies -CmdletName $cmdletName

                # Look up ImportantPolicies for defaults and recommendation
                $msDefault           = ''
                $recommendation      = ''
                $recommendationDetail = ''
                if ($ImportantPolicies -and $ImportantPolicies.ContainsKey($cmdletName)) {
                    $entries = $ImportantPolicies[$cmdletName]
                    foreach ($entry in $entries) {
                        if ($entry.Property -eq $propertyName) {
                            if ($entry.MSRecommendation) {
                                # Extract the default value from MSRecommendation text
                                if ($entry.MSRecommendation -match 'DEFAULT:\s*([^\.]+)') {
                                    $msDefault = ($Matches[1]).Trim()
                                }
                            }
                            if ($entry.Recommendation) {
                                $recommendationDetail = $entry.Recommendation
                            }
                            # Use the General tier expected value as recommendation
                            # (goal is one unified policy for all users)
                            # Fall back to _Global for configuration cmdlets with only a Global instance
                            if ($entry.ExpectedValues) {
                                if ($entry.ExpectedValues.ContainsKey('General')) {
                                    $recommendation = [string]$entry.ExpectedValues['General']
                                } elseif ($entry.ExpectedValues.ContainsKey('_Global')) {
                                    $recommendation = [string]$entry.ExpectedValues['_Global']
                                }
                            }
                            break
                        }
                    }
                }

                $valueBreakdown = Get-SettingValueDistribution `
                    -CmdletName $cmdletName `
                    -PropertyName $propertyName `
                    -PolicyData $PolicyData `
                    -PolicyUserCounts $PolicyUserCounts

                # Drift from MS default (case-insensitive, semantic-aware)
                $driftFromMSDefault = $(if ($msDefault -ne '' -and
                    -not (Test-SemanticEqual -Value1 $currentGlobal -Value2 $msDefault)) {
                    'Yes'
                } else { '' })

                # Compute priority score
                $priority = 0
                switch ($riskLevel) {
                    'High'   { $priority += 30 }
                    'Medium' { $priority += 15 }
                }
                # Drift from recommendation (case-insensitive, semantic-aware)
                if ($recommendation -ne '' -and
                    -not (Test-SemanticEqual -Value1 $currentGlobal -Value2 $recommendation)) {
                    $priority += 40
                }
                # Drift from MS default (case-insensitive, semantic-aware)
                if ($msDefault -ne '' -and
                    -not (Test-SemanticEqual -Value1 $currentGlobal -Value2 $msDefault)) {
                    $priority += 10
                }
                # Affects users
                if ($usersOnGlobal -gt 0) {
                    $priority += 5
                }
                # No guidance yet
                if ($recommendation -eq '') {
                    $priority += 5
                }

                $rows += [pscustomobject]@{
                    Category             = $category
                    FriendlyName         = $friendlyName
                    Property             = $propertyName
                    Cmdlet               = $cmdletName
                    MSDefault            = $msDefault
                    DriftFromMSDefault   = $driftFromMSDefault
                    CurrentGlobal        = $currentGlobal
                    Recommendation       = $recommendation
                    RiskLevel            = $riskLevel
                    Priority             = $priority
                    UsersOnGlobal        = $usersOnGlobal
                    UsersOnOther         = $usersOnOther
                    ValueBreakdown       = $valueBreakdown
                    Decision             = ''
                    Notes                = ''
                    RecommendationDetail = $recommendationDetail
                }
            }
        }
    }

    $rows
}

function Build-CategoryDetailRows {
    <#
    .SYNOPSIS
        Builds per-setting rows for a single category with dynamic per-tier value columns.
    .DESCRIPTION
        Similar to Build-DecisionRows but adds a column for each policy tier's value,
        allowing side-by-side comparison across all tiers in the category.
    #>
    param(
        [Parameter(Mandatory)][string]$Category,
        [string[]]$CmdletNames,
        [hashtable]$PolicyData,
        [hashtable]$GlobalRows,
        [hashtable]$ImportantPolicies,
        [hashtable]$FriendlyNames,
        [string[]]$PropertyExclusions,
        [hashtable]$PolicyUserCounts,
        [int]$TotalUsers
    )

    $rows = @()

    foreach ($cmdletName in $CmdletNames) {
        if (-not $GlobalRows.ContainsKey($cmdletName)) { continue }
        $globalRow = $GlobalRows[$cmdletName]
        if (-not $globalRow) { continue }

        $policyType = Get-PolicyTypeFromCmdlet -CmdletName $cmdletName

        # Collect all tier names and records for this cmdlet
        $allRecords = @()
        if ($PolicyData.ContainsKey($cmdletName)) {
            $allRecords = @($PolicyData[$cmdletName])
        }

        # Build ordered list of tier names from Identity
        $tierNames = @()
        foreach ($record in $allRecords) {
            $identity = ''
            if ($record.PSObject.Properties['Identity']) {
                $identity = [string]$record.Identity
            }
            $tierName = $identity -replace '^Tag:', ''
            $tierNames += $tierName
        }

        # Get user counts for this policy type
        $tierCounts = $(if ($PolicyUserCounts -and $PolicyUserCounts.ContainsKey($policyType)) {
            $PolicyUserCounts[$policyType]
        } else { @{} })

        # Iterate properties of the Global row
        foreach ($prop in $globalRow.PSObject.Properties) {
            $propertyName = $prop.Name

            if ($PropertyExclusions -and $propertyName -in $PropertyExclusions) { continue }

            $friendlyName = Get-FriendlySettingName `
                -CmdletName $cmdletName `
                -PropertyName $propertyName `
                -ImportantPolicies $ImportantPolicies `
                -FriendlyNames $FriendlyNames

            $riskLevel = Get-RiskLevel -PropertyName $propertyName -Category $Category

            # Base properties
            $rowData = [ordered]@{
                Category     = $Category
                FriendlyName = $friendlyName
                Property     = $propertyName
                Cmdlet       = $cmdletName
                RiskLevel    = $riskLevel
            }

            # Add a column for each tier
            foreach ($record in $allRecords) {
                $identity = ''
                if ($record.PSObject.Properties['Identity']) {
                    $identity = [string]$record.Identity
                }
                $tierName = $identity -replace '^Tag:', ''

                $value = $null
                if ($record.PSObject.Properties[$propertyName]) {
                    $value = $record.$propertyName
                }
                $valueStr = $(if ($null -eq $value) { 'Not set' } else { [string]$value })

                $userCount = 0
                if ($tierCounts.ContainsKey($tierName)) {
                    $userCount = $tierCounts[$tierName]
                }

                $columnName = "$tierName ($userCount users)"
                $rowData[$columnName] = $valueStr
            }

            $rows += [pscustomobject]$rowData
        }
    }

    $rows
}

Export-ModuleMember -Function @(
    'Get-PolicyTypeFromCmdlet',
    'Get-PolicyUserCounts',
    'ConvertTo-FriendlyNameAlgorithmic',
    'Get-FriendlySettingName',
    'Get-RiskLevel',
    'Get-SettingValueDistribution',
    'Get-ValidSettingValues',
    'Test-SemanticEqual',
    'Build-DecisionRows',
    'Build-CategoryDetailRows'
)
