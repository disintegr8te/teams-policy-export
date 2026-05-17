<#
    Maps each cmdlet from the Teams policy export to one of 8 logical categories.
    Used by the Excel rework to group policy sheets by functional area.

    Source: manifest.csv from a typical Teams export (78 cmdlets)
#>
@{
    # -- 1. Meetings ----------------------------------------------------------
    # Meeting policies, broadcast/live events, audio conferencing, events,
    # meeting templates, meeting branding, meeting configuration
    'Meetings' = @(
        'Get-CsOnlineAudioConferencingRoutingPolicy'
        'Get-CsOnlineDialinConferencingPolicy'
        'Get-CsOnlineDialinConferencingTenantConfiguration'
        'Get-CsOnlineDialInConferencingTenantSettings'
        'Get-CsTeamsAudioConferencingCustomPromptsConfiguration'
        'Get-CsTeamsAudioConferencingPolicy'
        'Get-CsTeamsEventsPolicy'
        'Get-CsTeamsFirstPartyMeetingTemplateConfiguration'
        'Get-CsTeamsMeetingBrandingPolicy'
        'Get-CsTeamsMeetingBroadcastConfiguration'
        'Get-CsTeamsMeetingBroadcastPolicy'
        'Get-CsTeamsMeetingConfiguration'
        'Get-CsTeamsMeetingPolicy'
        'Get-CsTeamsMeetingTemplateConfiguration'
        'Get-CsTeamsMeetingTemplatePermissionPolicy'
    )

    # -- 2. Messaging ---------------------------------------------------------
    # Messaging policy and messaging configuration
    'Messaging' = @(
        'Get-CsTeamsMessagingConfiguration'
        'Get-CsTeamsMessagingPolicy'
    )

    # -- 3. Calling & Voice ---------------------------------------------------
    # Calling, voicemail, voice routing, dial-out, call hold/park, emergency,
    # shared calling, voice applications, personal attendant, survivable branch
    'Calling & Voice' = @(
        'Get-CsOnlineDialOutPolicy'
        'Get-CsOnlineVoicemailPolicy'
        'Get-CsOnlineVoiceRoutingPolicy'
        'Get-CsTeamsCallHoldPolicy'
        'Get-CsTeamsCallingPolicy'
        'Get-CsTeamsCallParkPolicy'
        'Get-CsTeamsCarrierEmergencyCallRoutingPolicy'
        'Get-CsTeamsEmergencyCallingPolicy'
        'Get-CsTeamsEmergencyCallRoutingPolicy'
        'Get-CsTeamsPersonalAttendantPolicy'
        'Get-CsTeamsSharedCallingRoutingPolicy'
        'Get-CsTeamsSurvivableBranchAppliancePolicy'
        'Get-CsTeamsVoiceApplicationsPolicy'
    )

    # -- 4. Teams & Channels --------------------------------------------------
    # Channels policy, upgrade, template permissions, targeting, shifts,
    # feedback, notifications, update management, files
    'Teams & Channels' = @(
        'Get-CsTeamsChannelsPolicy'
        'Get-CsTeamsFeedbackPolicy'
        'Get-CsTeamsFilesPolicy'
        'Get-CsTeamsNotificationAndFeedsPolicy'
        'Get-CsTeamsShiftsAppPolicy'
        'Get-CsTeamsShiftsPolicy'
        'Get-CsTeamsTargetingPolicy'
        'Get-CsTeamsTemplatePermissionPolicy'
        'Get-CsTeamsUpdateManagementPolicy'
        'Get-CsTeamsUpgradeConfiguration'
        'Get-CsTeamsUpgradePolicy'
    )

    # -- 5. Apps & Permissions ------------------------------------------------
    # App permission, app setup, workload, cortana, education, virtual
    # appointments, application access
    'Apps & Permissions' = @(
        'Get-CsApplicationAccessPolicy'
        'Get-CsTeamsAppPermissionPolicy'
        'Get-CsTeamsAppSetupPolicy'
        'Get-CsTeamsCortanaPolicy'
        'Get-CsTeamsEducationAssignmentsAppPolicy'
        'Get-CsTeamsEducationConfiguration'
        'Get-CsTeamsVirtualAppointmentsPolicy'
        'Get-CsTeamsWorkLoadPolicy'
    )

    # -- 6. External & Guests ------------------------------------------------
    # External access, tenant federation, external access config, guest
    # calling/meeting/messaging config, ACS federation, multi-tenant org
    'External & Guests' = @(
        'Get-CsExternalAccessPolicy'
        'Get-CsTeamsAcsFederationConfiguration'
        'Get-CsTeamsExternalAccessConfiguration'
        'Get-CsTeamsGuestCallingConfiguration'
        'Get-CsTeamsGuestMeetingConfiguration'
        'Get-CsTeamsGuestMessagingConfiguration'
        'Get-CsTeamsMultiTenantOrganizationConfiguration'
        'Get-CsTenantFederationConfiguration'
    )

    # -- 7. Security & Compliance ---------------------------------------------
    # Enhanced encryption, compliance recording, AI policy, media logging,
    # recording rollout, work location detection
    'Security & Compliance' = @(
        'Get-CsTeamsAIPolicy'
        'Get-CsTeamsComplianceRecordingPolicy'
        'Get-CsTeamsEnhancedEncryptionPolicy'
        'Get-CsTeamsMediaLoggingPolicy'
        'Get-CsTeamsRecordingRollOutPolicy'
        'Get-CsTeamsTenantAbuseConfiguration'
        'Get-CsTeamsWorkLocationDetectionPolicy'
    )

    # -- 8. Devices & Client --------------------------------------------------
    # IP phone, BYOD/desks, VDI, client config, SIP devices, mobility,
    # room video, media connectivity, network roaming, remote log collection,
    # video interop
    'Devices & Client' = @(
        'Get-CsTeamsBYODAndDesksPolicy'
        'Get-CsTeamsClientConfiguration'
        'Get-CsTeamsIPPhonePolicy'
        'Get-CsTeamsMediaConnectivityPolicy'
        'Get-CsTeamsMobilityPolicy'
        'Get-CsTeamsNetworkRoamingPolicy'
        'Get-CsTeamsRemoteLogCollectionConfiguration'
        'Get-CsTeamsRoomVideoTeleConferencingPolicy'
        'Get-CsTeamsSipDevicesConfiguration'
        'Get-CsTeamsVdiPolicy'
        'Get-CsTeamsVideoInteropServicePolicy'
    )
}

# -- Uncategorized (auto-assigned to "Other") --------------------------------
# The following cmdlets from the manifest do not fit the above 8 categories
# and will be auto-categorized as "Other" at runtime:
#   Get-CsPolicyPackage              -- policy package definitions (meta/governance)
#   Get-CsTeamsMigrationConfiguration -- migration settings (one-time/transitional)
#   Get-CsTenantLicensingConfiguration -- licensing info (read-only/informational)
#   Get-CsTenantMigrationConfiguration -- tenant migration (one-time/transitional)
#   Get-CsTenantNetworkConfiguration   -- network topology (infrastructure)
