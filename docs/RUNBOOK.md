# Operational Runbook

Step-by-step procedures for common operations with the Teams Policy Export tool. Follow these when running exports, preparing for meetings, and handling the output.

---

## Table of Contents

- [Pre-Meeting Checklist](#pre-meeting-checklist)
- [Running a Full Export](#running-a-full-export)
- [Running an Excel-Only Regeneration](#running-an-excel-only-regeneration)
- [Working with the Decision Sheet in a Meeting](#working-with-the-decision-sheet-in-a-meeting)
- [Post-Meeting: Processing Decisions](#post-meeting-processing-decisions)
- [Scheduling Regular Exports](#scheduling-regular-exports)
- [Handling Authentication Issues](#handling-authentication-issues)
- [Comparing Two Exports](#comparing-two-exports)
- [Partial / Scoped Exports](#partial--scoped-exports)

---

## Pre-Meeting Checklist

Do this **the day before** a stakeholder policy review meeting:

### 1. Verify Your Permissions

Open PowerShell and test your connection:

```powershell
Connect-MicrosoftTeams
Get-CsTeamsMeetingPolicy | Select-Object -First 1
Disconnect-MicrosoftTeams
```

If either command fails, check that your account has Teams Administrator or Global Administrator rights.

### 2. Update the Configuration (if needed)

If there are new policies to review or recommendations have changed:

- Edit `Config/ImportantPolicies.psd1` to add/update recommendations (see [CONFIGURATION.md](CONFIGURATION.md))
- Edit `Config/FriendlyNames.psd1` if you need better labels for any settings
- Edit `Config/PolicyCategories.psd1` if new cmdlets need to be categorized

### 3. Run the Full Export

```powershell
cd C:\path\to\teamsexport
.\Export-TeamsPolicies.ps1 -IncludeAssignments
```

This typically takes 5-15 minutes depending on tenant size.

### 4. Verify the Output

Open the generated `TeamsPolicies.xlsx` and check:

- [ ] Overview sheet shows expected categories and counts
- [ ] "Drifted from Rec." numbers look reasonable
- [ ] All Decisions sheet has the DECISION column (yellow, empty)
- [ ] Category detail sheets show per-tier columns
- [ ] User Impact sheet shows user distribution (only if `-IncludeAssignments` was used)

### 5. Distribute the File

Share the Excel file with meeting participants ahead of time so they can review. Consider adding a note like:

> Please review the "All Decisions" sheet before the meeting. Focus on rows where the Risk column says "High" and where the Current Global differs from the Recommendation (shown in red).

---

## Running a Full Export

### Standard Export (Policies Only)

Use this when you just need the policy configuration without user assignment data:

```powershell
cd C:\path\to\teamsexport
.\Export-TeamsPolicies.ps1
```

**What happens:**
1. Browser popup for sign-in
2. Discovers ~78 cmdlets
3. Exports each to JSON + CSV
4. Generates Excel workbook
5. Disconnects from Teams

**Time:** 2-5 minutes

**Output:** `Teams-Policy-Export-YYYYMMDD-HHmmss/`

### Full Export with User Assignments

Use this when you need to know how many users are affected by each policy:

```powershell
.\Export-TeamsPolicies.ps1 -IncludeAssignments
```

**Additional steps:**
- Retrieves all users from the tenant (batched processing)
- Normalizes user-policy assignments
- Creates user summary data
- Retrieves group-based assignments

**Time:** 5-15 minutes for a 2,000-user tenant. 30+ minutes for large tenants.

### Full Export with Custom Output Location

```powershell
.\Export-TeamsPolicies.ps1 -IncludeAssignments -OutDir C:\Exports\TeamsPolicyReview-April2026
```

### Full Export on a Remote Server (SSH/headless)

```powershell
.\Export-TeamsPolicies.ps1 -IncludeAssignments -AuthMethod DeviceCode
```

The script will display something like:

```
  Device Code Authentication
  A code will be displayed. Open https://microsoft.com/devicelogin and enter it.

To sign in, use a web browser to open the page https://microsoft.com/devicelogin and
enter the code ABCDE1234 to authenticate.
```

Open the URL on any device (phone, other computer), enter the code, and sign in. The script will continue automatically after authentication.

### Defaults-Only Export

Use this to capture just the Global (org-wide default) policy values:

```powershell
.\Export-TeamsPolicies.ps1 -DefaultsOnly
```

This is useful for:
- Creating a baseline snapshot
- Comparing what the defaults are without noise from custom tiers
- Quick exports when you only care about the org-wide settings

---

## Running an Excel-Only Regeneration

Use this when you have already run a full export and want to regenerate the Excel workbook with updated config files -- without reconnecting to Teams.

### When to Use This

- You updated `Config/ImportantPolicies.psd1` with new recommendations
- You added friendly names to `Config/FriendlyNames.psd1`
- You reorganized categories in `Config/PolicyCategories.psd1`
- You added or removed property exclusions
- You want to tweak the output without waiting for a full re-export

### Steps

1. Find the path of your previous export. It should contain a `manifest.csv` file:

```powershell
# Check the folder exists and has the right files
Get-ChildItem .\Teams-Policy-Export-20260309-143000\
```

You should see `manifest.csv`, `raw-json/`, `flat-csv/`, and possibly an old `TeamsPolicies.xlsx`.

2. Run the regeneration:

```powershell
.\Export-TeamsPolicies.ps1 -ExcelOnly -OutDir .\Teams-Policy-Export-20260309-143000
```

3. The old `TeamsPolicies.xlsx` in that folder is replaced with the new one.

**Time:** A few seconds.

**Important:** The `-ExcelOnly` flag requires that the output directory already has a `manifest.csv` and JSON files from a previous full export. If those are missing, you will get an error.

---

## Working with the Decision Sheet in a Meeting

### Before the Meeting

1. Open `TeamsPolicies.xlsx` in Excel (desktop version recommended for best formatting).
2. Go to the **Overview** sheet for the agenda. Note which categories have the most drift.
3. Navigate to the **All Decisions** sheet.

### During the Meeting

#### Start with Overview (2 minutes)

Open the **Overview** sheet. Review the executive summary metrics in the top-right:
- **Action Items** tells you how many decisions are needed today
- **Already Aligned** shows how much is already correct
- Use the **Quick Links** row to jump to "Action Required" or "All Decisions"

#### Work through Action Required first

The **Action Required** sheet shows only the settings that need attention, sorted by priority score (highest first). This is your meeting agenda.

For each row:
1. Review the **Setting** name and the **Why** column for context
2. Compare **Current Global** against **Recommendation** and **MS Default**
3. Check **Users on Global** to understand impact scope
4. Fill in the **DECISION** column using the dropdown (includes "Keep" + valid values)
5. Add rationale in the **Notes** column

#### Then review All Decisions for completeness

Switch to **All Decisions** for the full picture. The first four columns (Priority, Risk, Setting, DECISION) are frozen and always visible. Settings already aligned with recommendations are highlighted in green -- skip these unless you want to discuss them.

Decisions you enter that differ from the current value appear in **green bold** so you can quickly spot what will change.

#### Working with Category Sheets

If the group needs more detail about a specific area, switch to the relevant category sheet (e.g., "Meetings"). These sheets show per-tier columns so you can see the value across all tiers (Global, Restricted, IT-Department, etc.). A comment on the DECISION header reminds you to enter decisions in "All Decisions" for consistency.

#### Tips for Efficient Meetings

- Start with Overview for context, then go straight to Action Required
- The priority score guides discussion order -- highest priority items first
- Green cells in Current Global mean "already aligned" -- no action needed
- Red cells mean "drifted from recommendation" -- discuss these
- Use the **Why** column to understand reasoning without looking up docs
- Save the file frequently during the meeting

### After the Meeting

Save the file with decisions filled in. This becomes the decision record. See the next section for post-meeting steps.

---

## Post-Meeting: Processing Decisions

### 1. Save the Completed Workbook

Save the Excel file with all DECISION and Notes columns filled in. Consider renaming it to indicate it contains decisions:

```
TeamsPolicies-Decisions-20260415.xlsx
```

### 2. Apply Decisions Automatically

The tool has a built-in `-ApplyDecisions` mode that reads your completed Excel and generates the correct `Set-Cs*` commands. There are three approaches, from safest to most direct:

#### Option A: Generate a Script (Recommended)

This is the **safest approach** -- it creates a standalone `.ps1` script that you can review, modify, and run when ready:

```powershell
.\Export-TeamsPolicies.ps1 -ApplyDecisions .\TeamsPolicies-Decisions-20260415.xlsx -GenerateScript
```

This produces:
- A **change report** (text file) summarizing what will change, risk levels, and user impact
- A **PowerShell script** (`Apply-PolicyDecisions-YYYYMMDD-HHmmss.ps1`) with all `Set-Cs*` commands

Review the generated script, then run it:

```powershell
# Preview first (WhatIf mode)
.\Apply-PolicyDecisions-20260415-100000.ps1 -WhatIf

# Apply for real
.\Apply-PolicyDecisions-20260415-100000.ps1
```

#### Option B: Dry Run (Preview Only)

See what would change without connecting to Teams or modifying anything:

```powershell
.\Export-TeamsPolicies.ps1 -ApplyDecisions .\TeamsPolicies-Decisions-20260415.xlsx -DryRun
```

This displays a change report and shows what each command would do, without executing anything.

#### Option C: Direct Apply (Advanced)

Apply changes directly to the tenant. This will prompt for confirmation before each change:

```powershell
.\Export-TeamsPolicies.ps1 -ApplyDecisions .\TeamsPolicies-Decisions-20260415.xlsx
```

The tool will:
1. Connect to Teams (prompts for authentication)
2. Show a full change report
3. Apply each `Set-Cs*` command with confirmation prompts
4. Save an audit log of all changes

**What the tool handles automatically:**
- Maps `Get-Cs*` cmdlets to the correct `Set-Cs*` equivalents
- Converts string values to the right types (`"True"` becomes `$true`, numbers become integers)
- Skips rows where DECISION is "Keep" or matches the current value
- Groups multiple property changes into a single `Set-Cs*` call per cmdlet
- Flags high-risk changes in the change report

### 3. Manual Implementation (Alternative)

If you prefer to build commands manually, the key columns in the All Decisions sheet are:

- **Cmdlet** -- tells you which `Set-Cs*` cmdlet to use (replace `Get-Cs` with `Set-Cs`)
- **Property** -- the parameter name to change
- **DECISION** -- the new value to set

Example: If the decision for `AllowCloudRecording` in `Get-CsTeamsMeetingPolicy` is "True":

```powershell
Set-CsTeamsMeetingPolicy -Identity Global -AllowCloudRecording $true
```

### 4. Schedule a Follow-Up Export

After implementing changes, run another full export to verify:

```powershell
.\Export-TeamsPolicies.ps1 -IncludeAssignments
```

Compare the new "Drifted from Rec." counts on the Overview sheet. They should be lower than before.

---

## Scheduling Regular Exports

### Option 1: Windows Task Scheduler

Create a scheduled task that runs the export weekly or monthly:

1. Open Task Scheduler
2. Create a new task
3. Set the trigger (e.g., every Monday at 6:00 AM)
4. Set the action:

   - **Program:** `powershell.exe`
   - **Arguments:** `-ExecutionPolicy Bypass -File "C:\path\to\teamsexport\Export-TeamsPolicies.ps1" -IncludeAssignments -OutDir "C:\Exports\Teams-Weekly"`

**Important:** Scheduled tasks run non-interactively, so you cannot use browser-based authentication. You need to either:
- Use `-AuthMethod DeviceCode` and pre-authenticate
- Set up certificate-based authentication for the MicrosoftTeams module (see the MicrosoftTeams module documentation for `Connect-MicrosoftTeams -CertificateThumbprint`)

### Option 2: Simple Script Wrapper

Create a wrapper script that runs the export and moves the output to a shared location:

```powershell
# Weekly-Export.ps1
$exportDir = "C:\Exports\Teams-$(Get-Date -Format 'yyyy-MM-dd')"
& "C:\path\to\teamsexport\Export-TeamsPolicies.ps1" `
    -IncludeAssignments `
    -OutDir $exportDir `
    -AuthMethod DeviceCode

# Copy to shared drive
Copy-Item -Path "$exportDir\TeamsPolicies.xlsx" `
    -Destination "\\server\share\Teams-Policy-Reports\"
```

### Recommended Schedule

| Frequency | When | Use Case |
|---|---|---|
| Weekly | Normal operations, tracking gradual changes |
| Before meetings | Run the day before any policy review meeting |
| After changes | Run after implementing policy changes to verify |
| Monthly | Minimum for audit/compliance purposes |

---

## Handling Authentication Issues

### Interactive Authentication Fails

**Symptom:** Browser opens but sign-in does not complete, or you get an "access denied" error.

**Solutions:**

1. Verify your account has the right role:
   ```powershell
   # After connecting, check if basic commands work
   Connect-MicrosoftTeams
   Get-CsTeamsMeetingPolicy -Identity Global
   ```

2. Try clearing cached credentials:
   ```powershell
   # Disconnect any existing session
   Disconnect-MicrosoftTeams

   # Clear token cache
   Clear-MicrosoftTeamsInteractiveLogin

   # Try again
   .\Export-TeamsPolicies.ps1
   ```

3. If your organization requires MFA, the interactive login should handle it automatically. If it does not, try device code:
   ```powershell
   .\Export-TeamsPolicies.ps1 -AuthMethod DeviceCode
   ```

### Device Code Authentication Fails

**Symptom:** Code is displayed but entering it at https://microsoft.com/devicelogin fails.

**Solutions:**

1. Make sure you are entering the code at `https://microsoft.com/devicelogin` (not a different URL)
2. The code expires after 15 minutes. If it expired, stop the script (Ctrl+C) and restart
3. Make sure you sign in with the admin account, not your personal Microsoft account

### Session Expires Mid-Export

**Symptom:** The export starts fine but fails partway through with an authentication error.

**Solutions:**

1. Run without `-IncludeAssignments` first (faster, less likely to timeout):
   ```powershell
   .\Export-TeamsPolicies.ps1
   ```

2. If you need assignments, try a smaller user set:
   ```powershell
   .\Export-TeamsPolicies.ps1 -IncludeAssignments -UserResultSize 10000
   ```

3. Check if your organization has a conditional access policy that limits session duration

### Connecting from a Different Network / VPN

Some organizations restrict Teams admin access to specific networks. If you get connectivity errors:

1. Make sure you are on the corporate network or VPN
2. Check if your firewall allows outbound connections to `*.microsoftonline.com` and `*.microsoft.com`
3. Try from a different machine on the same network

---

## Comparing Two Exports

To see what changed between two exports, you can compare the flat CSV files.

### Quick Comparison in PowerShell

```powershell
# Compare the Global row of a specific policy between two exports
$old = Import-Csv ".\Teams-Policy-Export-20260301\flat-csv\Get-CsTeamsMeetingPolicy.csv" |
    Where-Object { $_.Identity -eq 'Global' }
$new = Import-Csv ".\Teams-Policy-Export-20260315\flat-csv\Get-CsTeamsMeetingPolicy.csv" |
    Where-Object { $_.Identity -eq 'Global' }

# Find properties that changed
$old.PSObject.Properties | ForEach-Object {
    $propName = $_.Name
    $oldVal = $_.Value
    $newVal = $new.$propName
    if ($oldVal -ne $newVal) {
        [pscustomobject]@{
            Property = $propName
            OldValue = $oldVal
            NewValue = $newVal
        }
    }
} | Format-Table
```

### Comparing Excel Reports

Open both Excel files side by side and compare the Overview sheet "Drifted from Rec." columns to see if drift is increasing or decreasing.

---

## Partial / Scoped Exports

### Export Without Excel

If you only need the raw data (JSON and CSV) and want to skip the Excel generation:

```powershell
.\Export-TeamsPolicies.ps1 -SkipExcel
```

This is faster and does not require the ImportExcel module.

### Export Only Defaults

If you only care about the org-wide default settings:

```powershell
.\Export-TeamsPolicies.ps1 -DefaultsOnly
```

This filters every policy to just the Global row, giving you a clean baseline view.

### Regenerate Just the Excel

If you already have the raw data and only want a new Excel file (with updated config):

```powershell
.\Export-TeamsPolicies.ps1 -ExcelOnly -OutDir .\Teams-Policy-Export-20260309-143000
```

---

## Related Documentation

- **[../README.md](../README.md)** -- Main tool documentation, all parameters, and output structure
- **[CONFIGURATION.md](CONFIGURATION.md)** -- How to customize baselines, friendly names, and categories
- **[ARCHITECTURE.md](ARCHITECTURE.md)** -- Technical details about how the tool works internally
