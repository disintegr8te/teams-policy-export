function Test-CanRunWithoutMandatoryParams {
    <#
    .SYNOPSIS
        Checks if a cmdlet has at least one parameter set with no mandatory parameters.
    #>
    param([Parameter(Mandatory)][System.Management.Automation.CommandInfo]$Command)

    foreach ($set in $Command.ParameterSets) {
        $mandatory = @(
            $set.Parameters | Where-Object {
                $_.IsMandatory -and $_.Name -notin @(
                    'Verbose','Debug','ErrorAction','WarningAction','InformationAction',
                    'ErrorVariable','WarningVariable','InformationVariable','OutVariable',
                    'OutBuffer','PipelineVariable','ProgressAction'
                )
            }
        )
        if ($mandatory.Count -eq 0) { return $true }
    }
    return $false
}

function ConvertTo-FlatObject {
    <#
    .SYNOPSIS
        Recursively flattens a nested PSObject into a single-level ordered hashtable.
    #>
    param(
        [Parameter(Mandatory)][AllowNull()][object]$InputObject,
        [string]$Prefix = ''
    )

    $flat = [ordered]@{}

    if ($null -eq $InputObject) {
        return [pscustomobject]$flat
    }

    foreach ($prop in $InputObject.PSObject.Properties) {
        $name  = $(if ([string]::IsNullOrWhiteSpace($Prefix)) { $prop.Name } else { "$Prefix.$($prop.Name)" })
        $value = $prop.Value

        if ($null -eq $value) {
            $flat[$name] = $null
            continue
        }

        if (
            $value -is [string] -or $value -is [char] -or $value -is [bool] -or
            $value -is [byte] -or $value -is [int16] -or $value -is [int32] -or
            $value -is [int64] -or $value -is [decimal] -or $value -is [double] -or
            $value -is [single] -or $value -is [datetime] -or $value -is [guid]
        ) {
            $flat[$name] = $value
            continue
        }

        if ($value -is [System.Collections.IDictionary]) {
            foreach ($key in $value.Keys) {
                $flat["$name.$key"] = $value[$key]
            }
            continue
        }

        if ($value -is [System.Collections.IEnumerable] -and -not ($value -is [string])) {
            $items = @($value)
            if ($items.Count -eq 0) {
                $flat[$name] = ''
            }
            elseif (@($items | Where-Object { $_ -isnot [string] -and $_ -isnot [ValueType] }).Count -gt 0) {
                $flat[$name] = ($items | ConvertTo-Json -Depth 20 -Compress)
            }
            else {
                $flat[$name] = ($items | ForEach-Object { [string]$_ }) -join ' | '
            }
            continue
        }

        $nested = ConvertTo-FlatObject -InputObject ($value | Select-Object *) -Prefix $name
        foreach ($nestedProp in $nested.PSObject.Properties) {
            $flat[$nestedProp.Name] = $nestedProp.Value
        }
    }

    [pscustomobject]$flat
}

function New-ManifestEntry {
    <#
    .SYNOPSIS
        Creates a standardized manifest entry for tracking export results.
    #>
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Kind,
        [Parameter(Mandatory)][ValidateSet('OK','Failed')][string]$Status,
        [int]$Count = 0,
        [string]$JsonPath,
        [string]$CsvPath,
        [string]$Error
    )

    [pscustomobject]@{
        Name      = $Name
        Kind      = $Kind
        Status    = $Status
        Count     = $Count
        JsonPath  = $JsonPath
        CsvPath   = $CsvPath
        Error     = $Error
        Timestamp = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
    }
}

function Write-StepLog {
    <#
    .SYNOPSIS
        Writes a timestamped log message to the console.
    #>
    param(
        [Parameter(Mandatory)][string]$Message,
        [ValidateSet('Info','Warning','Error')][string]$Level = 'Info'
    )

    $ts = Get-Date -Format 'HH:mm:ss'
    switch ($Level) {
        'Info'    { Write-Host "[$ts] $Message" }
        'Warning' { Write-Warning "[$ts] $Message" }
        'Error'   { Write-Host "[$ts] ERROR: $Message" -ForegroundColor Red }
    }
}

function Get-SafeSheetName {
    <#
    .SYNOPSIS
        Converts a cmdlet name to a valid Excel sheet name (max 31 chars).
    #>
    param([Parameter(Mandatory)][string]$Name)

    $short = $Name -replace '^Get-Cs', ''
    if ($short.Length -gt 31) {
        $short = $short -replace 'Policy$', 'Pol'
        $short = $short -replace 'Configuration$', 'Cfg'
    }
    if ($short.Length -gt 31) {
        $short = $short.Substring(0, 31)
    }
    $short
}

Export-ModuleMember -Function @(
    'Test-CanRunWithoutMandatoryParams',
    'ConvertTo-FlatObject',
    'New-ManifestEntry',
    'Write-StepLog',
    'Get-SafeSheetName'
)
