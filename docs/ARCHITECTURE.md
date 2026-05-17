# Architecture Guide

This document provides a technical deep-dive into how the Teams Policy Export tool works internally. Read this if you need to understand the code well enough to modify it, debug issues, or extend its capabilities.

For configuration changes that do not require code changes, see [CONFIGURATION.md](CONFIGURATION.md).

---

## Table of Contents

- [Module Dependency Diagram](#module-dependency-diagram)
- [Data Flow: End to End](#data-flow-end-to-end)
- [Module Reference](#module-reference)
  - [TeamsPolicies.Utilities](#teamspolicitiesutilities)
  - [TeamsPolicies.Discovery](#teamspolicitiesdiscovery)
  - [TeamsPolicies.Export](#teamspolicitiesexport)
  - [TeamsPolicies.Assignments](#teamspolicitiesassignments)
  - [TeamsPolicies.Analysis](#teamspolicitiesanalysis)
  - [TeamsPolicies.Excel](#teamspolicitiesexcel)
- [How Drift Detection Works](#how-drift-detection-works)
- [How User Impact Analysis Works](#how-user-impact-analysis-works)
- [How Friendly Name Resolution Works](#how-friendly-name-resolution-works)
- [How Risk Levels Are Assigned](#how-risk-levels-are-assigned)
- [How Excel Formatting Works](#how-excel-formatting-works)
- [Testing](#testing)

---

## Module Dependency Diagram

The modules have a layered dependency structure. Higher modules depend on lower ones, but never the reverse.

```
+-----------------------------------------------------------+
|                    Export-TeamsPolicies.ps1                |
|                    (Main orchestrator)                     |
+---+--------+--------+-----------+----------+--------------+
    |        |        |           |          |
    v        v        v           v          v
+------+ +------+ +--------+ +--------+ +-------+
| Util | | Disc | | Export  | | Assign | | Analy |
+------+ +------+ +--------+ +--------+ +-------+
    ^        |        |                      |
    |        v        |                      v
    +--- uses Util    |                  +-------+
         for          |                  | Excel |
         safe-invoke  |                  +-------+
                      |                      |
                      +---- uses Util -------+
                            for flattening
```

**Key dependency facts:**

- **Utilities** is a leaf module with no dependencies on other custom modules. Every other module uses it.
- **Discovery** depends on Utilities (for `Test-CanRunWithoutMandatoryParams`).
- **Export** depends on Utilities (for `ConvertTo-FlatObject`, `New-ManifestEntry`).
- **Assignments** depends on Utilities (for `Write-StepLog`).
- **Analysis** depends on nothing directly but receives data from all of the above.
- **Excel** depends on the `ImportExcel` external module and calls Analysis functions to build decision rows.

---

## Data Flow: End to End

Here is what happens when you run `.\Export-TeamsPolicies.ps1 -IncludeAssignments`, step by step:

### Phase 1: Setup

```
1. Import all 6 custom modules from Modules/
2. Validate MicrosoftTeams and ImportExcel modules are installed
3. Import MicrosoftTeams module
4. Load config files from Config/
   - ImportantPolicies.psd1  -> $importantPolicies hashtable
   - PolicyCategories.psd1   -> $policyCategories hashtable
   - FriendlyNames.psd1      -> $friendlyNames hashtable
   - PropertyExclusions.psd1 -> $propertyExclusions string array
5. Create output directories: OutDir/raw-json/, OutDir/flat-csv/
```

### Phase 2: Connect and Discover

```
6. Connect-MicrosoftTeams (Interactive or DeviceCode)
7. Get-TeamsPolicyCmdlets discovers ~78 exportable cmdlets by:
   a. Querying all commands in the MicrosoftTeams module
   b. Matching against include patterns (Get-CsTeams*Policy, Get-CsOnline*Policy, etc.)
   c. Excluding known problem cmdlets (Get-CsUserPolicyAssignment, Get-CsOnlineUser, etc.)
   d. Filtering out cmdlets with mandatory parameters (they cannot be run without arguments)
```

### Phase 3: Export Policies

```
8. For each discovered cmdlet:
   a. Invoke-PolicyCmdletSafe runs it inside try/catch
   b. If -DefaultsOnly, filter records to Global row only
   c. Export-RecordSet writes:
      - raw-json/{CmdletName}.json  (full structured JSON)
      - flat-csv/{CmdletName}.csv   (flattened with ConvertTo-FlatObject)
   d. Get-GlobalPolicyRow extracts the Global row for later analysis
   e. A manifest entry is created (OK or Failed, with counts and paths)
9. All records are stored in $policyData hashtable keyed by cmdlet name
10. All Global rows stored in $globalRows hashtable keyed by cmdlet name
```

### Phase 4: Export Assignments (if -IncludeAssignments)

```
11. Get-UserPolicyAssignments:
    a. Calls Get-CsOnlineUser with -ResultSize parameter
    b. Processes users in batches of $BatchSize
    c. Each batch: ConvertTo-NormalizedAssignments produces
       (User, PolicyType, PolicyName) rows
    d. Rows are streamed to a temp CSV to avoid holding all in memory
    e. Returns total user count and CSV path

12. Get-UserPolicyAssignmentsSummary:
    a. Same batched approach but produces one row per user
    b. Adds all *Policy properties as columns dynamically

13. Get-GroupAssignments:
    a. Calls Get-CsGroupPolicyAssignment
    b. Returns group-based policy assignments
```

### Phase 5: Analysis and Excel

```
14. Auto-categorize uncategorized cmdlets into "Other"
15. Get-PolicyUserCounts computes per-tier user counts:
    a. Groups UserAssignments by (PolicyType, PolicyName)
    b. Counts distinct users per group
    c. Computes Global remainder = TotalUsers - sum of explicit assignments
    d. Incorporates GroupAssignments

16. New-PolicyExcelReport builds the workbook:
    a. Build-DecisionRows generates one row per setting with all analysis
    b. Add-OverviewSheet: executive summary with metrics and quick links
    c. Add-ActionRequiredSheet: filtered to drifted / high-risk items only
    d. Add-AllDecisionsSheet: flat decision table sorted by Priority
    e. Add-CategorySheet (per category): detailed tier-by-tier comparison
    f. Add-UserImpactSheet: user distribution across tiers

17. Disconnect-MicrosoftTeams
18. Print summary
```

### ExcelOnly Mode

When you run with `-ExcelOnly`, phases 2-4 are skipped entirely. Instead:

```
1. Load manifest.csv from the specified OutDir
2. Re-read JSON files for OK policy/configuration entries
3. Re-extract Global rows from JSON
4. Re-load assignment data from JSON (if present)
5. Jump directly to Phase 5 (Analysis and Excel)
```

This is fast because it avoids all Teams API calls.

---

## Module Reference

### TeamsPolicies.Utilities

**Location:** `Modules/TeamsPolicies.Utilities/TeamsPolicies.Utilities.psm1`

Shared helper functions used by every other module.

| Function | Purpose |
|---|---|
| `Write-StepLog` | Writes timestamped log messages to the console. Supports Info, Warning, and Error levels. All modules call this for consistent logging. |
| `ConvertTo-FlatObject` | Recursively flattens a nested PSObject into a single-level ordered hashtable. Handles nested objects (with dot-notation keys), dictionaries, simple arrays (joined with ` \| `), and complex arrays (serialized to JSON). This is the core function that makes CSV export possible. |
| `New-ManifestEntry` | Creates a standardized manifest entry PSObject with Name, Kind, Status, Count, JsonPath, CsvPath, Error, and Timestamp fields. |
| `Test-CanRunWithoutMandatoryParams` | Checks if a cmdlet has at least one parameter set with no mandatory parameters (excluding common parameters like `-Verbose`). Used by Discovery to filter out cmdlets that cannot be invoked without arguments. |
| `Get-SafeSheetName` | Converts a cmdlet name to a valid Excel sheet name (max 31 characters) by stripping the `Get-Cs` prefix and abbreviating `Policy`/`Configuration` suffixes if needed. |

### TeamsPolicies.Discovery

**Location:** `Modules/TeamsPolicies.Discovery/TeamsPolicies.Discovery.psm1`

Finds and invokes Teams policy cmdlets.

| Function | Purpose |
|---|---|
| `Get-TeamsPolicyCmdlets` | Discovers all exportable cmdlets from the MicrosoftTeams module. Uses configurable include patterns (like `^Get-CsTeams.*Policy$`) and exclude patterns (like `^Get-CsUserPolicyAssignment$`). Only returns cmdlets that pass the `Test-CanRunWithoutMandatoryParams` check. Typically discovers 70-80 cmdlets. |
| `Invoke-PolicyCmdletSafe` | Wraps a cmdlet invocation in try/catch. Returns a result object with `Success` (bool), `Data` (array of results), and `Error` (exception message if failed). This prevents one failing cmdlet from stopping the entire export. |

**Include patterns (defaults):**

```
^Get-CsTeams.*Policy$
^Get-CsTeams.*Configuration$
^Get-CsTeamsMeetingBroadcastPolicy$
^Get-CsTeamsEventsPolicy$
^Get-CsOnline.*Policy$
^Get-CsOnlineDialInConferencingTenantConfiguration$
^Get-CsOnlineDialInConferencingTenantSettings$
^Get-CsTenant.*Configuration$
^Get-CsExternalAccessPolicy$
^Get-CsApplicationAccessPolicy$
^Get-CsPolicyPackage$
```

### TeamsPolicies.Export

**Location:** `Modules/TeamsPolicies.Export/TeamsPolicies.Export.psm1`

Handles writing data to files and extracting the Global policy row.

| Function | Purpose |
|---|---|
| `Export-RecordSet` | Takes a name and array of records, writes them to both JSON (raw, depth 20) and CSV (flattened via `ConvertTo-FlatObject`). Returns a result object with Count, JsonPath, and CsvPath. Handles empty record sets by writing a "No data returned" placeholder. |
| `Export-DefaultPolicies` | Filters a record array to only the Global (org-wide default) row. Matches `Identity` values of `'Global'`, `'*:Global'`, or `'Tag:Global'`. |
| `Get-GlobalPolicyRow` | Similar to `Export-DefaultPolicies` but returns just the first matching Global row (not an array). Used to extract the Global row for comparison in the analysis phase. |
| `Export-ManifestFile` | Writes `manifest.csv` and `README.txt` to the output directory. The manifest is the authoritative record of what was exported. |

### TeamsPolicies.Assignments

**Location:** `Modules/TeamsPolicies.Assignments/TeamsPolicies.Assignments.psm1`

Retrieves per-user and group policy assignments with memory-efficient batching.

| Function | Purpose |
|---|---|
| `Get-UserPolicyAssignments` | Retrieves all users via `Get-CsOnlineUser` and processes them in batches. Each batch is normalized into (User, PolicyType, PolicyName) rows and appended to a temp CSV. This streaming approach keeps memory proportional to `BatchSize`, not total tenant size. Returns total user count and the CSV path. |
| `Get-UserPolicyAssignmentsSummary` | Similar batched processing but produces one row per user with all policy properties as columns. Better for overview/pivot tables. |
| `ConvertTo-NormalizedAssignments` | Takes a list of user objects, iterates their `*Policy` properties, and produces one row per (user, policy) pair. Skips null/empty values. This is the core normalization function. |
| `ConvertTo-UserPolicySummaryRow` | Converts a single `CsOnlineUser` object to a compact row with DisplayName, UPN, Identity, TeamsUpgradeMode, EnterpriseVoice, and all non-null `*Policy` properties as individual columns. |
| `Get-GroupAssignments` | Retrieves group-based policy assignments via `Get-CsGroupPolicyAssignment`. Simple wrapper with error handling. |

**Batching design:** The MicrosoftTeams module's `Get-CsOnlineUser` does not support reliable paging (Top/Skip). Instead, the script calls it once with `-ResultSize` and processes the pipeline output in chunks using a buffer list. When the buffer reaches `BatchSize`, it is processed and cleared.

### TeamsPolicies.Analysis

**Location:** `Modules/TeamsPolicies.Analysis/TeamsPolicies.Analysis.psm1`

The analytical engine that computes drift, risk, user impact, and builds the decision rows.

| Function | Purpose |
|---|---|
| `Get-PolicyTypeFromCmdlet` | Strips `Get-Cs` from a cmdlet name to produce the policy type key (e.g., `Get-CsTeamsMeetingPolicy` becomes `TeamsMeetingPolicy`). This key matches what appears in user assignment data. |
| `Get-PolicyUserCounts` | Builds a nested hashtable: `PolicyType -> PolicyName -> UserCount`. Counts distinct users per (type, name) from UserAssignments data. Computes the Global remainder (TotalUsers minus explicitly assigned users). Incorporates GroupAssignments without inflating counts (records existence only). |
| `ConvertTo-FriendlyNameAlgorithmic` | Converts PascalCase property names to readable strings. Handles known acronyms (IP, URL, AI, PSTN, SIP, etc.) by keeping them uppercase. Inserts spaces before uppercase transitions. |
| `Get-FriendlySettingName` | Three-tier lookup: (1) ImportantPolicies label, (2) FriendlyNames hashtable, (3) algorithmic conversion. See [How Friendly Name Resolution Works](#how-friendly-name-resolution-works). |
| `Get-RiskLevel` | Assigns High/Medium/Low risk based on property name patterns. See [How Risk Levels Are Assigned](#how-risk-levels-are-assigned). |
| `Get-SettingValueDistribution` | For a given setting, looks at every policy tier's value and the user count on that tier. Produces a readable string like `"True (8,350 users) / False (24 users)"`. |
| `Get-ValidSettingValues` | Inspects all values across policy tiers. If all values are True/False, returns those as valid dropdown options. If there are 10 or fewer distinct values, returns them as an enum set. Used for Excel data validation dropdowns. |
| `Build-DecisionRows` | The main analysis function. Iterates every category, cmdlet, and property to produce one PSCustomObject per setting with: Category, FriendlyName, Property, Cmdlet, MSDefault, DriftFromMSDefault, CurrentGlobal, Recommendation, RiskLevel, Priority, UsersOnGlobal, UsersOnOther, ValueBreakdown, Decision (empty), Notes (empty), RecommendationDetail. Uses case-insensitive comparisons for all drift detection. |
| `Build-CategoryDetailRows` | Similar to `Build-DecisionRows` but adds a dynamic column for each custom policy tier, allowing side-by-side comparison across all tiers within a category. |

### TeamsPolicies.Excel

**Location:** `Modules/TeamsPolicies.Excel/TeamsPolicies.Excel.psm1`

Generates the multi-sheet Excel workbook using the ImportExcel module.

| Function | Purpose |
|---|---|
| `New-PolicyExcelReport` | Main entry point. Orchestrates the workbook creation: calls `Build-DecisionRows`, then creates each sheet in order (Overview, Action Required, All Decisions, category sheets, User Impact). Removes any existing file first. Returns the Excel file path. |
| `Add-OverviewSheet` | Creates the executive summary. Computes per-category statistics (total settings, recommendations count, drift count, high-risk count, medium-risk count, no-recommendation count). Adds executive summary metrics (Action Items, Already Aligned, High Risk, Medium Risk) in cells D3:E6. Adds hyperlink quick links to Action Required, All Decisions, and User Impact sheets. |
| `Add-ActionRequiredSheet` | Filters decision rows to only those needing attention: drifted from recommendation OR high-risk without guidance. Sorted by Priority descending. Same formatting as All Decisions but focused on actionable items for meetings. |
| `Add-AllDecisionsSheet` | Creates the flat decision table with columns ordered: Priority, Risk, Setting, DECISION, Notes, then detail columns. Freezes header row + first 4 columns. Applies smart data validation dropdowns (enum values from `Get-ValidSettingValues`, not just True/False). Highlights drift in red, aligned settings in green, and DECISION values that differ from current in green bold. |
| `Add-CategorySheet` | Creates per-category detail sheets. Collects all custom tier names, adds a column for each. Highlights tier values that differ from Global. Adds a comment on the DECISION header directing users to enter decisions in All Decisions for consistency. |
| `Add-UserImpactSheet` | Shows user distribution. Applies conditional formatting for assignment method (blue for inherited, green for group). |
| `Add-DataSheet` | Generic helper that adds a simple formatted data sheet with table styling, auto-filter, and freeze panes. |

---

## How Drift Detection Works

Drift detection is how the tool identifies settings where your current configuration differs from the recommendation.

### In the All Decisions Sheet

For each row, the tool compares two values:

1. **Current Global** -- the actual value of the Global (default) policy in your tenant
2. **Recommendation** -- the `ExpectedValues.General` value from `ImportantPolicies.psd1`

If the Recommendation column is not empty AND Current Global does not match it, the Current Global cell gets a red background with dark red text. This visual flag means "this setting needs attention."

```
Logic (in Add-AllDecisionsSheet):
  if Recommendation is not empty AND Current Global != Recommendation:
      Color Current Global cell red
```

### In the Category Detail Sheets

Two types of drift are highlighted:

1. **Global vs. Recommendation** (same as All Decisions) -- Current Global cell turns red.
2. **Tier vs. Global** -- If a custom tier (e.g., Restricted, IT-Department) has a different value than Global, the tier cell gets a light yellow background with red text. This shows where custom tiers intentionally override the default.

### In the Overview Sheet

The "Drifted from Rec." column counts how many settings in each category have drift (Recommendation is not empty AND Current Global differs from Recommendation). This gives a quick per-category health check.

---

## How User Impact Analysis Works

User impact analysis answers: "How many users are affected by each policy setting?"

### Counting Users per Policy Tier

The `Get-PolicyUserCounts` function in the Analysis module builds counts:

1. **Direct assignments:** Groups the normalized UserAssignments data by (PolicyType, PolicyName) and counts distinct users per group.
2. **Group assignments:** Records which (PolicyType, PolicyName) pairs have group assignments, but does not inflate user counts (the actual group member count is not available from the Teams API).
3. **Global remainder:** For each PolicyType, the number of users on the Global policy is computed as `TotalUsers - sum of all explicitly assigned users`.

### How This Appears in the Excel

- **All Decisions sheet:** "Users on Global" shows how many users inherit the default. "Users on Other" shows how many have explicit assignments.
- **Value Breakdown column:** Shows the full distribution, e.g., `"True (8,350 users) / False (24 users)"`. This is computed by `Get-SettingValueDistribution`, which maps each tier's setting value to its user count.
- **User Impact sheet:** Shows every (PolicyType, PolicyName) combination with user count and percentage.
- **Category detail sheets:** Each tier column header includes the user count.

### Skipped Policy Types

Some "policy types" are not real policies but metadata properties. These are excluded from user counts:

- `EffectivePolicyAssignments`
- `TeamsUpgradePolicyIsReadOnly`
- `TeamsVerticalPackagePolicy`

---

## How Friendly Name Resolution Works

When the tool needs a human-readable label for a property, it uses a three-tier lookup:

```
Input: CmdletName = 'Get-CsTeamsMeetingPolicy', PropertyName = 'AllowCloudRecording'

Tier 1: Check ImportantPolicies[$CmdletName] for an entry where Property == $PropertyName
         -> If found and has a Label, return Label
         -> Found: 'Cloud Recording'  --> RETURN

Tier 2: Check FriendlyNames["$CmdletName.$PropertyName"]
         -> Key: 'Get-CsTeamsMeetingPolicy.AllowCloudRecording'
         -> If found, return the value
         -> 'Cloud recording'  --> RETURN (but Tier 1 already matched)

Tier 3: ConvertTo-FriendlyNameAlgorithmic('AllowCloudRecording')
         -> Insert spaces: 'Allow Cloud Recording'
         -> Lowercase non-first words: 'Allow cloud recording'
         -> RETURN
```

The algorithmic converter handles known acronyms by temporarily replacing them during the PascalCase splitting, so `AllowNDIStreaming` becomes "Allow NDI streaming" (not "Allow N D I streaming").

**Known acronyms:** IP, URL, AI, VDI, NDI, PSTN, SIP, QnA, BYOD, MES, ERP, CAD, DLP, SSO, MFA, API, SDK, CDN, PTZ, SMS, CART, HDMI, USB.

---

## How Risk Levels Are Assigned

The `Get-RiskLevel` function uses a two-tier approach:

### Tier 1: Config-Driven Overrides

If a property has a `Risk` field in `ImportantPolicies.psd1`, that value is used directly. This allows precise control over risk classification for settings where the keyword heuristic is wrong. Currently ~44 entries have explicit Risk overrides.

Example in ImportantPolicies.psd1:
```powershell
@{ Property = 'AllowIPVideo'; Label = 'IP Video'; Risk = 'High'; ... }
```

### Tier 2: Keyword Pattern Matching (Fallback)

If no config override exists, the function falls back to keyword matching:

**High Risk** -- properties containing: Anonymous, Federation, External, ScreenSharing, AutoAdmit, Guest, Lobby

**Medium Risk** -- properties containing: Recording, Transcription, Delete, Priority, Broadcast, CatalogApps, Encryption

**Low Risk** -- everything else.

### Priority Score

In addition to risk level, each setting gets a **Priority score** (0-90) computed in `Build-DecisionRows`:

| Factor | Points |
|---|---|
| High risk | +30 |
| Medium risk | +15 |
| Drifted from recommendation (case-insensitive) | +40 |
| Drifted from MS default | +10 |
| Users affected (UsersOnGlobal > 0) | +5 |
| No guidance yet (empty recommendation) | +5 |

The Priority score drives sort order in All Decisions and Action Required sheets, putting the most important decisions at the top of the meeting agenda.

---

## How Excel Formatting Works

The Excel module uses the `ImportExcel` PowerShell module, which wraps the EPPlus .NET library. Here is how the formatting pipeline works:

### Table Creation

Each sheet starts with `Export-Excel` which creates an Excel table with:
- **BoldTopRow** -- header row in bold
- **AutoSize** -- columns auto-fit to content width
- **FreezeTopRow** or **FreezeTopRowFirstColumn** -- keeps headers visible while scrolling
- **AutoFilter** -- adds dropdown filters to each column header
- **TableStyle** -- applies a preset style (Medium2 for overview, Medium4 for decisions, Medium6 for details)

### Post-Processing

After the initial table is created, the function gets back an `ExcelPackage` object (via `-PassThru`) and applies custom formatting:

1. **Find columns by header name** -- the code scans row 1 to build a `$headerMap` of column name to column index. This makes the formatting resilient to column order changes.

2. **DECISION column** -- gets a yellow fill (`#FFF2CC`), orange header (`#FFC000`), and a width of 20.

3. **Drift highlighting** -- loops through data rows comparing Current Global to Recommendation. Mismatches get red fill (`#FFC7CE`) and dark red text (`#9C0006`).

4. **Tier value highlighting** (category sheets) -- loops through tier columns comparing each value to the Global column. Differences get light yellow fill (`#FFFFCC`) and red text.

5. **Data validation dropdowns** -- for True/False settings, an Excel data validation list is added to the DECISION cell, so the user can pick from a dropdown instead of typing.

6. **Conditional text rules** -- `New-ConditionalText` applies rules that color "High" in red and "Medium" in yellow across the Risk column.

### Color Reference

| RGB | Hex | Usage |
|---|---|---|
| 255, 199, 206 | `#FFC7CE` | Red background for drift / high risk |
| 156, 0, 6 | `#9C0006` | Dark red text for drift / high risk |
| 255, 242, 204 | `#FFF2CC` | Yellow background for DECISION cells and medium risk |
| 127, 96, 0 | `#7F6000` | Dark yellow text for medium risk |
| 255, 192, 0 | `#FFC000` | Orange background for DECISION header |
| 255, 255, 204 | `#FFFFCC` | Light yellow for tier value differences |
| 198, 239, 206 | `#C6EFCE` | Green background for aligned settings (Current Global matches Recommendation) |
| 0, 97, 0 | `#006100` | Dark green text for aligned settings and DECISION values that change current |
| 180, 198, 231 | `#B4C6E7` | Blue background for tier column headers |
| 217, 226, 243 | `#D9E2F3` | Light blue for "Default (inherited)" assignment |
| 226, 239, 218 | `#E2EFDA` | Light green for "Group" assignment |

---

## Testing

### Test Structure

Tests are in the `Tests/` directory and use the Pester framework. Currently 62 tests across 4 files.

| File | What It Tests |
|---|---|
| `TeamsPolicies.Utilities.Tests.ps1` | `ConvertTo-FlatObject` (simple, nested, null, arrays, dictionaries), `Test-CanRunWithoutMandatoryParams`, `Get-SafeSheetName`, `New-ManifestEntry` |
| `TeamsPolicies.Export.Tests.ps1` | `Export-DefaultPolicies` (Global filtering), `Get-GlobalPolicyRow`, `Export-RecordSet` (JSON/CSV creation, empty sets) |
| `TeamsPolicies.Assignments.Tests.ps1` | `ConvertTo-NormalizedAssignments` (normalization, null handling), `ConvertTo-UserPolicySummaryRow` (compact row generation) |
| `TeamsPolicies.Analysis.Tests.ps1` | `Get-RiskLevel` (config override, keyword matching, defaults), `Get-PolicyUserCounts` (Global remainder, group assignments), `Build-DecisionRows` (priority scoring, drift detection, case-insensitive comparison, null display), `ConvertTo-FriendlyNameAlgorithmic` (PascalCase splitting, acronym handling) |

### Running Tests

```powershell
# Run all tests
Invoke-Pester -Path .\Tests\ -Output Detailed

# Run a specific test file
Invoke-Pester -Path .\Tests\TeamsPolicies.Analysis.Tests.ps1 -Output Detailed
```

### What Is Not Tested

The Discovery and Excel modules are not covered by unit tests because:

- **Discovery** requires a live MicrosoftTeams module connection
- **Excel** requires the ImportExcel module and produces binary output that is hard to assert against

---

## Related Documentation

- **[../README.md](../README.md)** -- Main tool documentation, parameter reference, and quick start
- **[CONFIGURATION.md](CONFIGURATION.md)** -- How to customize the config files
- **[RUNBOOK.md](RUNBOOK.md)** -- Operational guide for running exports and using the output
