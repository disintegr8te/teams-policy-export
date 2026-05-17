# Configuration Guide

This guide explains each configuration file in the `Config/` directory and how to customize them for your organization.

All configuration files use the PowerShell Data File format (`.psd1`). These are plain text files that define hashtables and arrays. You can edit them in any text editor, but Visual Studio Code with the PowerShell extension gives you syntax highlighting.

---

## Table of Contents

- [Overview of Config Files](#overview-of-config-files)
- [ImportantPolicies.psd1 -- Baseline Recommendations](#importantpoliciespsd1----baseline-recommendations)
- [FriendlyNames.psd1 -- Human-Readable Labels](#friendlynamespsd1----human-readable-labels)
- [PolicyCategories.psd1 -- Grouping Cmdlets into Categories](#policycategoriespsd1----grouping-cmdlets-into-categories)
- [PropertyExclusions.psd1 -- Hiding Noise Fields](#propertyexclusionspsd1----hiding-noise-fields)
- [PolicyDefaults.psd1 -- Offline Baseline Comparison](#policydefaultspsd1----offline-baseline-comparison)
- [Testing Your Changes](#testing-your-changes)

---

## Overview of Config Files

| File | Purpose | Impact on Excel |
|---|---|---|
| `ImportantPolicies.psd1` | Defines recommended values, MS defaults, labels, risk overrides, and per-tier expected values | Populates the "MS Default", "Recommendation", drift highlighting, and risk classification |
| `FriendlyNames.psd1` | Maps PowerShell property names to readable labels | Controls the "Setting" column text in the decision sheets |
| `PolicyCategories.psd1` | Groups cmdlets into logical categories (Meetings, Messaging, etc.) | Determines the category sheets and the Overview breakdown |
| `PropertyExclusions.psd1` | Lists properties to skip entirely | Removes noise rows from decision sheets (Identity, metadata, etc.) |
| `PolicyDefaults.psd1` | Optional offline defaults for comparison when not connected | Currently unused by the main report; available for custom scripts |

---

## ImportantPolicies.psd1 -- Baseline Recommendations

This is the most important config file. It tells the tool what each setting should be, what Microsoft recommends, and what value you expect for each policy tier.

### Structure

The file is a hashtable where each key is a cmdlet name, and the value is an array of setting entries:

```powershell
@{
    'Get-CsTeamsMeetingPolicy' = @(
        @{
            Property         = 'AllowCloudRecording'
            Label            = 'Cloud Recording'
            Slide            = 6
            Category         = 'Meeting Policies'
            Recommendation   = 'ALLOW for most users. Block for Restricted tier.'
            MSRecommendation = 'DEFAULT: True. MS recommends enabling.'
            ExpectedValues   = @{
                'General' = 'True'
                'Restricted' = 'False'
                'IT-Department' = 'True'
                'Admin' = 'True'
            }
        }
        # ... more settings
    )
}
```

### Fields Explained

| Field | Required | Description |
|---|---|---|
| `Property` | Yes | The exact PowerShell property name (e.g., `AllowCloudRecording`). Must match what the cmdlet returns. |
| `Label` | Yes | A short friendly name shown in the "Setting" column. Overrides FriendlyNames.psd1 for this property. |
| `Risk` | No | Explicit risk classification: `'High'`, `'Medium'`, or `'Low'`. Overrides the keyword-based heuristic in `Get-RiskLevel`. Use this when the automatic classification is wrong for a setting. See [Risk Overrides](#risk-overrides) below. |
| `Slide` | No | Reference to a source document slide number. For your own tracking -- not shown in Excel. |
| `Category` | No | Category label for your reference. The actual category used in the Excel comes from PolicyCategories.psd1. |
| `Recommendation` | Yes | Your organization's recommendation text. Shown in the "Recommendation" column. If this contains a specific value (like "True" or "EveryoneInCompany"), the Excel uses the `ExpectedValues.General` tier for the recommendation column value. |
| `MSRecommendation` | Yes | Microsoft's official guidance. If this contains `DEFAULT: somevalue`, the tool extracts `somevalue` and puts it in the "MS Default" column. |
| `ExpectedValues` | No | A hashtable mapping policy tier names to expected values. Keys must match the Identity names of your custom policies (e.g., `General`, `Restricted`, `IT-Department`). |

### How to Add a New Setting

Suppose you want to track `AllowBreakoutRooms` in the meeting policy:

1. Open `Config/ImportantPolicies.psd1`.
2. Find the `'Get-CsTeamsMeetingPolicy'` section.
3. Add a new entry inside the `@(...)` array:

```powershell
        @{
            Property         = 'AllowBreakoutRooms'
            Label            = 'Breakout Rooms'
            Slide            = 0
            Category         = 'Meeting Policies'
            Recommendation   = 'ALLOW for all users. Useful for workshop-style meetings.'
            MSRecommendation = 'DEFAULT: True. MS recommends enabling for interactive sessions.'
            ExpectedValues   = @{
                'General' = 'True'
                'Restricted' = 'False'
                'IT-Department' = 'True'
                'Admin' = 'True'
            }
        }
```

4. Save the file.
5. Regenerate the Excel to see your changes:

```powershell
.\Export-TeamsPolicies.ps1 -ExcelOnly -OutDir .\Teams-Policy-Export-20260309-143000
```

### How to Add a New Cmdlet

If you want to add recommendations for a cmdlet that is not already in the file (e.g., `Get-CsTeamsCallingPolicy`), add a new top-level key:

```powershell
@{
    # ... existing entries ...

    'Get-CsTeamsCallingPolicy' = @(
        @{
            Property         = 'AllowPrivateCalling'
            Label            = 'Private Calling'
            Slide            = 0
            Category         = 'Calling'
            Recommendation   = 'ALLOW for all users.'
            MSRecommendation = 'DEFAULT: True.'
            ExpectedValues   = @{
                'General' = 'True'
                'Restricted' = 'False'
            }
        }
    )
}
```

### Risk Overrides

By default, the tool assigns risk levels using keyword pattern matching (e.g., properties containing "Anonymous" or "External" are flagged as High). The `Risk` field lets you override this for any setting where the heuristic is wrong.

**When to add a Risk override:**

- A setting is classified Low but has significant security impact (e.g., `AllowIPVideo` controls video in meetings -- should be High, not Low)
- A setting is classified High but is actually low-impact in your environment
- You want consistent risk classification for all settings in a cmdlet

**Example: Adding Risk overrides**

```powershell
@{
    'Get-CsTeamsMeetingPolicy' = @(
        @{
            Property         = 'AllowIPVideo'
            Label            = 'IP Video'
            Risk             = 'High'      # Override: keyword heuristic says Low
            Recommendation   = 'ALLOW for General, block for Restricted.'
            MSRecommendation = 'DEFAULT: True.'
            ExpectedValues   = @{ 'General' = 'True'; 'Restricted' = 'False' }
        }
        @{
            Property         = 'AllowSmartCompose'
            Label            = 'Smart Compose'
            Risk             = 'Medium'    # Override: keyword heuristic says Low
            Recommendation   = 'ALLOW for productivity.'
            MSRecommendation = 'DEFAULT: True.'
            ExpectedValues   = @{ 'General' = 'True' }
        }
    )
}
```

The Risk field accepts: `'High'`, `'Medium'`, or `'Low'`. If omitted, the keyword-based heuristic is used. Currently ~44 settings have explicit Risk overrides. The risk level feeds into the Priority score that determines sort order in the decision sheets.

### Tips

- The `MSRecommendation` field should contain `DEFAULT: value` somewhere in the text for the tool to extract the MS default value. The pattern matched is `DEFAULT:` followed by the value up to the next period.
- The `ExpectedValues.General` tier is used as the display value in the "Recommendation" column. If you only have one expected value, use `'General'` as the key.
- For tenant-wide configurations that only have a Global row (no custom tiers), use `'_Global'` as the key in ExpectedValues.

---

## FriendlyNames.psd1 -- Human-Readable Labels

This file maps `CmdletName.PropertyName` pairs to readable labels. These appear in the "Setting" column of the Excel report.

### Structure

```powershell
@{
    'Get-CsTeamsMeetingPolicy.AllowCloudRecording'    = 'Cloud recording'
    'Get-CsTeamsMeetingPolicy.AllowTranscription'      = 'Transcription'
    'Get-CsTeamsMessagingPolicy.AllowGiphy'            = 'GIFs (Giphy)'
    # ...
}
```

### How Names Are Resolved (Priority Order)

The tool uses a three-tier lookup to find the friendly name for any setting:

1. **ImportantPolicies.psd1** -- If the setting has a `Label` defined in ImportantPolicies, that is used first.
2. **FriendlyNames.psd1** -- If no ImportantPolicies label exists, this file is checked.
3. **Algorithmic conversion** -- If neither file has a match, the tool converts PascalCase to spaced words automatically (e.g., `AllowAnonymousUsersToJoinMeeting` becomes "Allow anonymous users to join meeting").

### How to Add a Friendly Name

1. Find the PowerShell property name you want to label. You can look in the raw JSON files or the flat CSVs for exact names.
2. Add a line to the file using the format `'CmdletName.PropertyName' = 'Your Label'`:

```powershell
    'Get-CsTeamsCallingPolicy.AllowVoicemail' = 'Voicemail access'
```

3. Save and regenerate the Excel:

```powershell
.\Export-TeamsPolicies.ps1 -ExcelOnly -OutDir .\Teams-Policy-Export-20260309-143000
```

### When to Use This File vs. ImportantPolicies

- Use **FriendlyNames.psd1** when you just want to rename a setting in the spreadsheet.
- Use **ImportantPolicies.psd1** when you also want to define recommendations, MS defaults, and expected values per tier.

If a setting appears in both, the ImportantPolicies label takes priority.

---

## PolicyCategories.psd1 -- Grouping Cmdlets into Categories

This file organizes the 70-80 Teams cmdlets into logical groups. Each group becomes a category in the Overview sheet and gets its own detail sheet in the Excel workbook.

### Structure

```powershell
@{
    'Meetings' = @(
        'Get-CsTeamsMeetingPolicy'
        'Get-CsTeamsMeetingBroadcastPolicy'
        'Get-CsTeamsMeetingConfiguration'
        'Get-CsTeamsEventsPolicy'
        # ... more meeting-related cmdlets
    )

    'Messaging' = @(
        'Get-CsTeamsMessagingPolicy'
        'Get-CsTeamsMessagingConfiguration'
    )

    # ... more categories
}
```

### The Eight Default Categories

| Category | What It Covers |
|---|---|
| Meetings | Meeting policies, broadcast/live events, audio conferencing, events, templates |
| Messaging | Messaging policy and configuration |
| Calling & Voice | Calling, voicemail, voice routing, emergency, call park/hold |
| Teams & Channels | Channels policy, upgrade settings, shifts, notifications, feedback |
| Apps & Permissions | App permission, app setup, Cortana, education, virtual appointments |
| External & Guests | External access, federation, guest calling/meeting/messaging config |
| Security & Compliance | Encryption, compliance recording, AI policy, media logging |
| Devices & Client | IP phones, BYOD, VDI, client config, mobility, SIP devices |

### Auto-Categorization of New Cmdlets

If the MicrosoftTeams module adds new cmdlets that are not listed in any category, the tool automatically places them in an "Other" category. You will see a log message like:

```
[09:15:23] 3 cmdlets auto-categorized as 'Other'.
```

To assign them properly, add them to the relevant category array in this file.

### How to Create a New Category

Add a new key to the hashtable with an array of cmdlet names:

```powershell
    'Compliance & Legal' = @(
        'Get-CsTeamsComplianceRecordingPolicy'
        'Get-CsTeamsEnhancedEncryptionPolicy'
    )
```

Remember to remove those cmdlets from their original category to avoid duplication.

### How to Move a Cmdlet Between Categories

Find the cmdlet name in the file, cut it from one category's array, and paste it into another. Each cmdlet should appear in exactly one category.

---

## PropertyExclusions.psd1 -- Hiding Noise Fields

This file lists property names that should be excluded from the decision sheets. These are typically metadata fields, internal identifiers, or complex nested objects that do not represent actionable policy decisions.

### Structure

```powershell
@{
    Exclusions = @(
        'Identity'
        'Description'
        'AllowedExternalDomains'
        'BlockedExternalDomains'
        'MsftInternalProcessingMode'
        # ... more properties
    )
}
```

### When to Add an Exclusion

Add a property to this list when:

- It is a system-generated ID (like `ConfigId`, `Anchor`, `Key`)
- It contains complex nested objects that do not display well in a flat row (like `MeetingTemplates`)
- It is deprecated (like `EnableXmppAccess`)
- It is informational but not a decision point (like `LicensingConfiguration`)

### How to Add an Exclusion

1. Open `Config/PropertyExclusions.psd1`.
2. Add the property name as a string in the `Exclusions` array:

```powershell
        # My custom exclusions
        'SomeNoisyField'
        'AnotherMetadataProperty'
```

3. Save and regenerate the Excel.

### How to Un-Exclude a Property

If you removed a property you actually want to see, simply delete it from the list and regenerate.

**Note:** Exclusions apply globally across all cmdlets. If a property name appears in multiple cmdlets and you only want to hide it from one, you cannot do that with this file -- you would need to modify the Analysis module logic.

---

## PolicyDefaults.psd1 -- Offline Baseline Comparison

This is an optional file for storing known default policy values. It is not actively used by the main report generation -- the tool gets the actual Global row from your tenant at runtime.

### When You Might Use It

- You want to compare against a clean tenant baseline without connecting
- You are building offline analysis tools that reference known defaults
- You want to track what Microsoft's defaults were at a specific point in time

### How to Populate It

Run an export against a tenant with unmodified default policies:

```powershell
.\Export-TeamsPolicies.ps1 -DefaultsOnly -OutDir .\Baseline
```

Then manually copy values from the resulting JSON files into this file:

```powershell
@{
    'Get-CsTeamsMeetingPolicy' = @{
        AllowChannelMeetingScheduling = $true
        AllowMeetNow                  = $true
        AllowCloudRecording           = $true
        # ...
    }
}
```

---

## Testing Your Changes

After editing any config file, use the `-ExcelOnly` flag to quickly regenerate the Excel from an existing export without reconnecting to Teams:

```powershell
.\Export-TeamsPolicies.ps1 -ExcelOnly -OutDir .\Teams-Policy-Export-20260309-143000
```

This takes just a few seconds and lets you verify your changes in the spreadsheet.

### Common Mistakes

**Syntax errors in .psd1 files:** If you get a red error about `Import-PowerShellDataFile`, you likely have a syntax issue. Common problems:

- Missing closing `@)` or `@}` brackets
- Trailing comma after the last item in an array (PowerShell does not allow this in data files)
- Using `$true`/`$false` inside string values (use the strings `'True'`/`'False'` instead for ExpectedValues)
- Forgetting the `=` between a key and its value

**Property name typo:** If a property name in ImportantPolicies.psd1 does not exactly match the PowerShell property, the recommendation will not show up. Check the raw JSON files for exact property names.

**Cmdlet name typo:** If a cmdlet name in PolicyCategories.psd1 does not match a discovered cmdlet, it will be silently ignored. The cmdlet will show up in "Other" if it exists but is not in any category.

---

## Related Documentation

- **[../README.md](../README.md)** -- Main tool documentation and quick start
- **[ARCHITECTURE.md](ARCHITECTURE.md)** -- How the config files are loaded and used internally
- **[RUNBOOK.md](RUNBOOK.md)** -- Operational procedures for running exports
