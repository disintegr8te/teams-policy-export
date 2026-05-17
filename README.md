# Teams Policy Export Tool

A PowerShell tool that exports your Microsoft Teams policies and configurations into structured files (JSON, CSV) and a formatted Excel workbook designed for stakeholder decision meetings.

**In plain terms:** This tool connects to your Microsoft 365 tenant, reads every Teams policy setting, and produces a spreadsheet that shows what is configured, what the recommended settings are, where your settings differ from recommendations, how many users are affected, and gives you columns to record decisions in meetings.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Parameters Reference](#parameters-reference)
- [Output Structure](#output-structure)
- [Understanding the Excel Report](#understanding-the-excel-report)
- [Troubleshooting](#troubleshooting)
- [Architecture Overview](#architecture-overview)
- [Further Reading](#further-reading)

---

## Prerequisites

### Software

| Requirement | Version | Why |
|---|---|---|
| PowerShell | 5.1 (Windows) or 7.2+ (cross-platform) | Runs the script |
| MicrosoftTeams module | Latest from PowerShell Gallery | Connects to Teams and reads policies |
| ImportExcel module | Latest from PowerShell Gallery | Generates the Excel workbook (not needed if you use `-SkipExcel`) |

### Permissions

You need **Teams Administrator** or **Global Administrator** rights in your Microsoft 365 tenant. If you only need to read policies (no user assignments), Teams Administrator is sufficient.

### Install the Required Modules

Open a PowerShell window and run:

```powershell
Install-Module MicrosoftTeams -Scope CurrentUser -Force -AllowClobber
Install-Module ImportExcel    -Scope CurrentUser -Force
```

To verify they are installed:

```powershell
Get-Module -ListAvailable -Name MicrosoftTeams
Get-Module -ListAvailable -Name ImportExcel
```

Both commands should return version information. If either returns nothing, the install did not work -- re-run the `Install-Module` command.

---

## Quick Start

### Step 1: Open PowerShell

Open a PowerShell window. Navigate to the folder where you cloned or unzipped this tool:

```powershell
cd C:\path\to\teamsexport
```

### Step 2: Run the Basic Export

```powershell
.\Export-TeamsPolicies.ps1
```

A browser window will pop up asking you to sign in. Use your admin account. The script will:

1. Connect to Microsoft Teams
2. Discover all available policy cmdlets (typically 70-80)
3. Export each one to JSON and CSV
4. Generate the Excel workbook
5. Disconnect from Teams

### Step 3: Find Your Output

When the script finishes, it prints the output path. Look for a folder named like:

```
Teams-Policy-Export-20260415-093000/
```

Open `TeamsPolicies.xlsx` inside that folder.

### Step 4: If You Are on a Remote/SSH Session

If you cannot open a browser (headless server, SSH session), use device code authentication:

```powershell
.\Export-TeamsPolicies.ps1 -AuthMethod DeviceCode
```

The script will display a code and a URL. Open https://microsoft.com/devicelogin on any device, enter the code, and sign in there.

---

## Parameters Reference

### `-OutDir` (string)

Where to save the output. Defaults to a timestamped folder in the current directory.

```powershell
# Save to a specific location
.\Export-TeamsPolicies.ps1 -OutDir C:\Exports\TeamsReview

# Default behavior creates: .\Teams-Policy-Export-20260415-093000\
.\Export-TeamsPolicies.ps1
```

### `-IncludeAssignments` (switch)

Adds per-user and group-based policy assignment data. This shows which users have which policies assigned, enabling the user impact analysis in the Excel report.

**Note:** This queries every user in the tenant, which can take several minutes for large organizations.

```powershell
.\Export-TeamsPolicies.ps1 -IncludeAssignments
```

### `-UserResultSize` (integer, default: 500000)

Maximum number of users to retrieve when `-IncludeAssignments` is used. You rarely need to change this unless your tenant has more than 500,000 users.

```powershell
.\Export-TeamsPolicies.ps1 -IncludeAssignments -UserResultSize 100000
```

### `-BatchSize` (integer, default: 5000)

How many users to process at a time in memory. Lower values use less memory but take longer. Increase if you have plenty of RAM and want faster processing.

```powershell
# Lower memory usage (slower)
.\Export-TeamsPolicies.ps1 -IncludeAssignments -BatchSize 1000

# Higher throughput (more memory)
.\Export-TeamsPolicies.ps1 -IncludeAssignments -BatchSize 10000
```

### `-DefaultsOnly` (switch)

Exports only the Global (org-wide default) policy row for each cmdlet. Useful for creating a baseline snapshot without all the custom policy tiers.

```powershell
.\Export-TeamsPolicies.ps1 -DefaultsOnly
```

### `-SkipExcel` (switch)

Produces only the raw JSON and CSV files without generating the Excel workbook. Useful if you just need the data for another tool or script.

```powershell
.\Export-TeamsPolicies.ps1 -SkipExcel
```

### `-ExcelOnly` (switch)

Regenerates the Excel workbook from an existing export directory. **Does not connect to Teams** -- works entirely from the previously exported JSON files. This is useful when you want to tweak the config files (friendly names, categories, etc.) and see the updated Excel without re-exporting.

You must pass `-OutDir` pointing to an existing export folder that contains a `manifest.csv`.

```powershell
.\Export-TeamsPolicies.ps1 -ExcelOnly -OutDir .\Teams-Policy-Export-20260309-143000
```

### `-AuthMethod` (string: `Interactive` or `DeviceCode`)

How to authenticate with Microsoft Teams.

- **Interactive** (default): Opens a browser window for sign-in. Use this when running on your own computer.
- **DeviceCode**: Displays a code to enter at https://microsoft.com/devicelogin. Use this for headless/remote/SSH sessions.

```powershell
.\Export-TeamsPolicies.ps1 -AuthMethod DeviceCode
```

### `-ApplyDecisions` (string: path to Excel file)

Reads a completed Excel workbook (with DECISION column filled in from a stakeholder meeting) and applies those decisions to the tenant's Global policies. Use with `-GenerateScript` or `-DryRun` for safety.

```powershell
# Safest: generate a reviewable script
.\Export-TeamsPolicies.ps1 -ApplyDecisions .\TeamsPolicies-Decisions.xlsx -GenerateScript

# Preview only (no changes made)
.\Export-TeamsPolicies.ps1 -ApplyDecisions .\TeamsPolicies-Decisions.xlsx -DryRun

# Direct apply (prompts for confirmation)
.\Export-TeamsPolicies.ps1 -ApplyDecisions .\TeamsPolicies-Decisions.xlsx
```

See [docs/RUNBOOK.md](docs/RUNBOOK.md#post-meeting-processing-decisions) for the full post-meeting workflow.

### `-GenerateScript` (switch)

Used with `-ApplyDecisions`. Instead of applying changes directly, generates a standalone `.ps1` script containing all `Set-Cs*` commands. You can review, edit, and run it on your own schedule.

### `-DryRun` (switch)

Used with `-ApplyDecisions`. Shows what would change without applying anything. No Teams connection needed.

---

## Output Structure

A successful run creates a folder with this structure:

```
Teams-Policy-Export-20260415-093000/
|
|-- TeamsPolicies.xlsx        The main deliverable -- formatted Excel workbook
|-- manifest.csv              Inventory of everything exported (status, counts, file paths)
|-- README.txt                Quick reference generated with each export
|
|-- raw-json/                 Full structured JSON, one file per cmdlet
|   |-- Get-CsTeamsMeetingPolicy.json
|   |-- Get-CsTeamsMessagingPolicy.json
|   |-- Get-CsTeamsCallingPolicy.json
|   |-- UserAssignments.json          (if -IncludeAssignments was used)
|   |-- GroupPolicyAssignments.json   (if -IncludeAssignments was used)
|   +-- ... (one per discovered cmdlet)
|
+-- flat-csv/                 Flattened CSV, one file per cmdlet
    |-- Get-CsTeamsMeetingPolicy.csv
    |-- Get-CsTeamsMessagingPolicy.csv
    +-- ...
```

### What Each File Is For

| File | When To Use It |
|---|---|
| `TeamsPolicies.xlsx` | Open this for meetings, reviews, and decisions. This is the primary output. |
| `manifest.csv` | Check this if you need to verify what exported successfully and what failed. |
| `raw-json/*.json` | Use these for scripting, automation, or feeding into other tools. Contains the full object structure. |
| `flat-csv/*.csv` | Use these for quick filtering in Excel or for diff comparisons between exports. Nested objects are flattened into dot-notation columns. |

---

## Understanding the Excel Report

The Excel workbook contains several sheets, each designed for a different purpose.

### Sheet: Overview

The first sheet you see. Provides an executive summary for the start of a meeting.

**Header block** (top-left): Tenant name, export date, total users, policies exported.

**Executive summary** (top-right): Key metrics at a glance:
- **Action Items** -- settings needing a decision (drifted or high-risk without guidance). Shown in red if > 0.
- **Already Aligned** -- settings where your current value matches the recommendation. Shown in green.
- **High Risk** / **Medium Risk** -- total counts across all categories.

**Quick Links** row: Clickable hyperlinks to "Action Required" and "All Decisions" sheets.

| Column | What It Shows |
|---|---|
| **Category** | Policy area (Meetings, Messaging, Calling & Voice, etc.) |
| **Settings** | Total number of settings in that category |
| **With Recommendation** | How many settings have a documented recommendation |
| **No Recommendation** | Settings with no guidance yet -- coverage gap indicator |
| **Drifted from Rec.** | How many settings where your current value differs from the recommendation |
| **High Risk Settings** | Count of settings flagged as high risk |
| **Medium Risk Settings** | Count of settings flagged as medium risk |
| **Go To Sheet** | Clickable hyperlink to the category detail sheet |

### Sheet: Action Required

**Start here during the meeting.** This sheet shows only settings that need attention: drifted from recommendation, or high-risk with no recommendation. Sorted by priority (highest first).

| Column | What It Shows |
|---|---|
| **Priority** | Computed score (0-90) combining risk level, drift, user impact, and coverage |
| **Category** | Policy area |
| **Setting** | Human-readable name |
| **Risk** | High, Medium, or Low |
| **MS Default** | Microsoft's default value |
| **Current Global** | Your tenant's current value |
| **Recommendation** | The recommended value |
| **Why** | Business reasoning behind the recommendation |
| **Users on Global** | Users affected by the Global policy value |
| **Users on Other** | Users on custom tiers |
| **Value Breakdown** | Per-tier value distribution with user counts |
| **DECISION** | *Fill this in during the meeting.* |
| **Notes** | *Meeting notes and rationale.* |

### Sheet: All Decisions

The complete flat list of every policy setting across all categories. Sorted by priority (highest first). The first four columns (Priority, Risk, Setting, DECISION) are frozen so they stay visible while scrolling.

| Column | What It Shows |
|---|---|
| **Priority** | Computed score (0-90). Hover over the header for the scoring formula. |
| **Risk** | High, Medium, or Low based on the security impact of the setting |
| **Setting** | Human-readable name (e.g., "Cloud recording" instead of `AllowCloudRecording`) |
| **DECISION** | *Empty -- fill this in during the meeting.* Dropdowns provided for boolean and enum settings (with "Keep" option). |
| **Notes** | *Empty -- add meeting notes, action items, or rationale here.* |
| **Category** | Which policy area this setting belongs to |
| **Current Global** | Your tenant's current value for the Global (default) policy |
| **Recommendation** | The recommended value for your organization |
| **Why** | Business reasoning behind the recommendation |
| **MS Default** | Microsoft's default value (extracted from recommendations) |
| **Changed from Default** | "Yes" if your current value differs from Microsoft's default |
| **Users on Global** | How many users are on the default policy (and thus affected by the Current Global value) |
| **Users on Other** | How many users have a custom policy assignment that overrides the Global |
| **Value Breakdown** | Shows the value for each policy tier and how many users are on it (e.g., "True (8,350 users) / False (24 users)") |
| **Property** | The actual PowerShell property name |
| **Cmdlet** | Which Teams cmdlet this comes from |

### Category Detail Sheets (e.g., Meetings, Messaging, Calling & Voice)

One sheet per policy category. Similar to All Decisions but adds a column for each custom policy tier, so you can see the value side-by-side across all tiers (Global, Restricted, IT-Department, Admin, etc.).

| Column | What It Shows |
|---|---|
| **Setting** | Human-readable setting name |
| **Property** | PowerShell property name |
| **Cmdlet** | Source cmdlet (with the `Get-Cs` prefix removed for brevity) |
| **MS Default** | Microsoft's default value |
| **Global (Current)** | Current value of the Global policy |
| **Recommendation** | Recommended value |
| **Risk** | High / Medium / Low |
| *tier name columns* | One column per custom policy tier (e.g., "Restricted", "IT-Department"), showing that tier's value |
| **Users on Global** | Users inheriting the Global default |
| **Users on Other** | Users assigned to a custom tier |
| **DECISION** | Fill in during meeting |
| **Notes** | Meeting notes |

### Sheet: User Impact

Shows how users are distributed across policy tiers for each policy type.

| Column | What It Shows |
|---|---|
| **Policy Type** | The type of policy (e.g., TeamsMeetingPolicy) |
| **Policy Name** | The specific tier (Global, Restricted, IT-Department, etc.) |
| **Assignment** | How users got this policy: "Default (inherited)" for Global, "Direct / Group" for custom, "Group" for group-assigned |
| **User Count** | Number of users on this policy tier |
| **Percentage** | What percentage of total users this represents |
| **Group ID** | If assigned via group, the Azure AD group ID |

### Color Legend

| Color | Where | Meaning |
|---|---|---|
| **Red background + dark red text** on Current Global | All Decisions, Category sheets | Your current value differs from the recommendation -- needs review |
| **Green background + green text** on Current Global | All Decisions | Your current value matches the recommendation -- already aligned |
| **Red background + dark red text** on Risk column | All Decisions, Category sheets | "High" risk setting |
| **Yellow background + dark text** on Risk column | All Decisions, Category sheets | "Medium" risk setting |
| **Yellow background** on DECISION column | All Decisions, Category sheets | This cell is waiting for your input |
| **Green bold text** on DECISION column | All Decisions | Decision entered that changes the current value |
| **Orange background** on DECISION header | All Decisions | Draws attention to the decision column |
| **Blue background** on tier column headers | Category sheets | Custom policy tier columns |
| **Light yellow + red text** in tier columns | Category sheets | Tier value differs from Global (i.e., this tier overrides the default) |
| **Light blue background** on Assignment column | User Impact | "Default (inherited)" -- users on the Global policy |
| **Light green background** on Assignment column | User Impact | "Group" assigned policy |
| **Bold dark red** on High Risk count | Overview | Categories with high-risk settings that need attention |

---

## Troubleshooting

### "MicrosoftTeams module not found"

You need to install the module first:

```powershell
Install-Module MicrosoftTeams -Scope CurrentUser -Force -AllowClobber
```

If you get a permissions error, make sure you are using `-Scope CurrentUser` (does not require admin rights on the machine).

### "ImportExcel module not found"

```powershell
Install-Module ImportExcel -Scope CurrentUser -Force
```

If you do not need the Excel report, you can skip it:

```powershell
.\Export-TeamsPolicies.ps1 -SkipExcel
```

### Authentication Fails / Browser Does Not Open

**On a remote or headless server:** Use device code authentication:

```powershell
.\Export-TeamsPolicies.ps1 -AuthMethod DeviceCode
```

**Browser opens but sign-in fails:** Make sure you are signing in with an account that has Teams Administrator or Global Administrator rights.

**Token expired mid-run:** The MicrosoftTeams module session can expire during long exports. If you see authentication errors partway through, try running with `-IncludeAssignments` disabled first (it is faster), then do a second run for assignments only.

### "No manifest.csv found in ..." (ExcelOnly mode)

You pointed `-OutDir` to a folder that does not contain a previous export. Make sure the path is correct and contains `manifest.csv`, `raw-json/`, and `flat-csv/`.

```powershell
# Check that the folder has the right contents
Get-ChildItem .\Teams-Policy-Export-20260309-143000\
```

### Some Cmdlets Show "Failed" in the Manifest

This is normal. Some cmdlets fail because:

- The feature is not licensed in your tenant (e.g., education policies in a non-education tenant)
- The cmdlet requires specific licensing (audio conferencing, calling plans)
- The cmdlet was deprecated in your version of the MicrosoftTeams module

The script continues past failures and reports them in `manifest.csv`. Check the `Error` column for details.

### The Script Takes a Long Time

**Without `-IncludeAssignments`:** A typical run exports 70-80 cmdlets and takes 2-5 minutes.

**With `-IncludeAssignments`:** Retrieving user data is the slow part. For a 2,000-user tenant, expect 5-10 minutes. For larger tenants (50,000+), it can take 30+ minutes. You can reduce `-UserResultSize` to export fewer users:

```powershell
# Only retrieve the first 10,000 users
.\Export-TeamsPolicies.ps1 -IncludeAssignments -UserResultSize 10000
```

### Excel File Is Too Large or Takes Long to Open

If your tenant has many custom policy tiers, the category sheets can get wide. Try opening the file in Excel desktop rather than Excel Online. If you only need the raw data, use the CSV files in `flat-csv/`.

---

## Architecture Overview

The tool is organized into a main script and six modules, each handling a specific part of the pipeline:

```
Export-TeamsPolicies.ps1          Main script -- orchestrates everything
        |
        |--- Config/                    Configuration files (baselines, categories, names)
        |       |-- ImportantPolicies.psd1     Recommended values per setting
        |       |-- PolicyCategories.psd1      Groups cmdlets into categories
        |       |-- FriendlyNames.psd1         Human-readable setting labels
        |       |-- PropertyExclusions.psd1    Noise fields to hide
        |       +-- PolicyDefaults.psd1        (Optional) offline defaults baseline
        |
        +--- Modules/
                |
                |-- Utilities     Shared helpers: logging, object flattening,
                |                 manifest entries, sheet name generation
                |
                |-- Discovery     Finds all Get-CsTeams* cmdlets in the
                |                 MicrosoftTeams module and invokes them safely
                |
                |-- Export        Saves data to JSON + CSV, filters Global rows,
                |                 writes the manifest file
                |
                |-- Assignments   Retrieves per-user and group policy assignments
                |                 using batched processing for large tenants
                |
                |-- Analysis      Computes user impact, risk levels, drift detection,
                |                 friendly names, value distributions, decision rows
                |
                +-- Excel         Builds the multi-sheet Excel workbook with
                                  formatting, conditional coloring, and dropdowns
```

### Data Flow

```
Microsoft Teams APIs
        |
        v
  [Discovery]  Discover cmdlets --> list of Get-Cs* commands
        |
        v
  [Discovery]  Invoke each cmdlet safely --> raw policy objects
        |
        v
  [Export]     Save to JSON + CSV, extract Global rows
        |
        v
  [Assignments]  (optional) Retrieve user + group assignments
        |
        v
  [Analysis]   Compute user counts, risk levels, drift,
               build decision rows with friendly names
        |
        v
  [Excel]      Generate workbook: Overview, All Decisions,
               Category sheets, User Impact
        |
        v
  TeamsPolicies.xlsx  <-- ready for the meeting
```

---

## Further Reading

- **[docs/CONFIGURATION.md](docs/CONFIGURATION.md)** -- How to customize the config files (add your own baselines, friendly names, categories)
- **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)** -- Technical deep-dive into how each module works
- **[docs/RUNBOOK.md](docs/RUNBOOK.md)** -- Step-by-step operational guide for running exports and using the output in meetings

---

## Running Tests

The project includes Pester tests for the core modules. To run them:

```powershell
# Install Pester if you don't have it
Install-Module Pester -Scope CurrentUser -Force -SkipPublisherCheck

# Run all tests
Invoke-Pester -Path .\Tests\ -Output Detailed
```

---

## License

Apache 2.0. See [LICENSE](LICENSE) for the full text.
