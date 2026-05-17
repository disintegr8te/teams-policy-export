<#
    Maps Get-Cs* cmdlets to their corresponding Set-Cs* cmdlets for applying
    policy decisions back to the tenant.

    Most follow the simple pattern of replacing "Get-" with "Set-", but this
    explicit mapping allows overrides where the pattern differs or where a
    Set cmdlet does not exist.

    Source: PolicyCategories.psd1 (78 cmdlets across 8 categories)
#>
@{
    # -- Meetings --------------------------------------------------------------
    'Get-CsOnlineAudioConferencingRoutingPolicy'         = 'Set-CsOnlineAudioConferencingRoutingPolicy'
    'Get-CsOnlineDialinConferencingPolicy'               = 'Set-CsOnlineDialinConferencingPolicy'
    'Get-CsOnlineDialinConferencingTenantConfiguration'  = 'Set-CsOnlineDialinConferencingTenantConfiguration'
    'Get-CsOnlineDialInConferencingTenantSettings'       = 'Set-CsOnlineDialInConferencingTenantSettings'
    'Get-CsTeamsAudioConferencingCustomPromptsConfiguration' = 'Set-CsTeamsAudioConferencingCustomPromptsConfiguration'
    'Get-CsTeamsAudioConferencingPolicy'                 = 'Set-CsTeamsAudioConferencingPolicy'
    'Get-CsTeamsEventsPolicy'                            = 'Set-CsTeamsEventsPolicy'
    'Get-CsTeamsMeetingBroadcastConfiguration'           = 'Set-CsTeamsMeetingBroadcastConfiguration'
    'Get-CsTeamsMeetingBroadcastPolicy'                  = 'Set-CsTeamsMeetingBroadcastPolicy'
    'Get-CsTeamsMeetingConfiguration'                    = 'Set-CsTeamsMeetingConfiguration'
    'Get-CsTeamsMeetingPolicy'                           = 'Set-CsTeamsMeetingPolicy'
    'Get-CsTeamsMeetingBrandingPolicy'                   = 'Set-CsTeamsMeetingBrandingPolicy'

    # -- Messaging -------------------------------------------------------------
    'Get-CsTeamsMessagingConfiguration'                  = 'Set-CsTeamsMessagingConfiguration'
    'Get-CsTeamsMessagingPolicy'                         = 'Set-CsTeamsMessagingPolicy'

    # -- Calling & Voice -------------------------------------------------------
    'Get-CsOnlineDialOutPolicy'                          = 'Set-CsOnlineDialOutPolicy'
    'Get-CsOnlineVoicemailPolicy'                        = 'Set-CsOnlineVoicemailPolicy'
    'Get-CsOnlineVoiceRoutingPolicy'                     = 'Set-CsOnlineVoiceRoutingPolicy'
    'Get-CsTeamsCallHoldPolicy'                          = 'Set-CsTeamsCallHoldPolicy'
    'Get-CsTeamsCallingPolicy'                           = 'Set-CsTeamsCallingPolicy'
    'Get-CsTeamsCallParkPolicy'                          = 'Set-CsTeamsCallParkPolicy'
    'Get-CsTeamsCarrierEmergencyCallRoutingPolicy'       = 'Set-CsTeamsCarrierEmergencyCallRoutingPolicy'
    'Get-CsTeamsEmergencyCallingPolicy'                  = 'Set-CsTeamsEmergencyCallingPolicy'
    'Get-CsTeamsEmergencyCallRoutingPolicy'              = 'Set-CsTeamsEmergencyCallRoutingPolicy'
    'Get-CsTeamsSharedCallingRoutingPolicy'              = 'Set-CsTeamsSharedCallingRoutingPolicy'
    'Get-CsTeamsSurvivableBranchAppliancePolicy'         = 'Set-CsTeamsSurvivableBranchAppliancePolicy'
    'Get-CsTeamsVoiceApplicationsPolicy'                 = 'Set-CsTeamsVoiceApplicationsPolicy'

    # -- Teams & Channels ------------------------------------------------------
    'Get-CsTeamsChannelsPolicy'                          = 'Set-CsTeamsChannelsPolicy'
    'Get-CsTeamsFeedbackPolicy'                          = 'Set-CsTeamsFeedbackPolicy'
    'Get-CsTeamsFilesPolicy'                             = 'Set-CsTeamsFilesPolicy'
    'Get-CsTeamsNotificationAndFeedsPolicy'              = 'Set-CsTeamsNotificationAndFeedsPolicy'
    'Get-CsTeamsShiftsAppPolicy'                         = 'Set-CsTeamsShiftsAppPolicy'
    'Get-CsTeamsShiftsPolicy'                            = 'Set-CsTeamsShiftsPolicy'
    'Get-CsTeamsTargetingPolicy'                         = 'Set-CsTeamsTargetingPolicy'
    'Get-CsTeamsTemplatePermissionPolicy'                = 'Set-CsTeamsTemplatePermissionPolicy'
    'Get-CsTeamsUpdateManagementPolicy'                  = 'Set-CsTeamsUpdateManagementPolicy'
    'Get-CsTeamsUpgradeConfiguration'                    = 'Set-CsTeamsUpgradeConfiguration'
    'Get-CsTeamsUpgradePolicy'                           = 'Set-CsTeamsUpgradePolicy'

    # -- Apps & Permissions ----------------------------------------------------
    'Get-CsApplicationAccessPolicy'                      = 'Set-CsApplicationAccessPolicy'
    'Get-CsTeamsAppPermissionPolicy'                     = 'Set-CsTeamsAppPermissionPolicy'
    'Get-CsTeamsAppSetupPolicy'                          = 'Set-CsTeamsAppSetupPolicy'
    'Get-CsTeamsCortanaPolicy'                           = 'Set-CsTeamsCortanaPolicy'
    'Get-CsTeamsEducationAssignmentsAppPolicy'           = 'Set-CsTeamsEducationAssignmentsAppPolicy'
    'Get-CsTeamsEducationConfiguration'                  = 'Set-CsTeamsEducationConfiguration'
    'Get-CsTeamsVirtualAppointmentsPolicy'               = 'Set-CsTeamsVirtualAppointmentsPolicy'
    'Get-CsTeamsWorkLoadPolicy'                          = 'Set-CsTeamsWorkLoadPolicy'

    # -- External & Guests -----------------------------------------------------
    'Get-CsExternalAccessPolicy'                         = 'Set-CsExternalAccessPolicy'
    'Get-CsTeamsAcsFederationConfiguration'              = 'Set-CsTeamsAcsFederationConfiguration'
    'Get-CsTeamsExternalAccessConfiguration'             = 'Set-CsTeamsExternalAccessConfiguration'
    'Get-CsTeamsGuestCallingConfiguration'               = 'Set-CsTeamsGuestCallingConfiguration'
    'Get-CsTeamsGuestMeetingConfiguration'               = 'Set-CsTeamsGuestMeetingConfiguration'
    'Get-CsTeamsGuestMessagingConfiguration'             = 'Set-CsTeamsGuestMessagingConfiguration'
    'Get-CsTeamsMultiTenantOrganizationConfiguration'    = 'Set-CsTeamsMultiTenantOrganizationConfiguration'
    'Get-CsTenantFederationConfiguration'                = 'Set-CsTenantFederationConfiguration'

    # -- Security & Compliance -------------------------------------------------
    'Get-CsTeamsAIPolicy'                                = 'Set-CsTeamsAIPolicy'
    'Get-CsTeamsComplianceRecordingPolicy'               = 'Set-CsTeamsComplianceRecordingPolicy'
    'Get-CsTeamsEnhancedEncryptionPolicy'                = 'Set-CsTeamsEnhancedEncryptionPolicy'
    'Get-CsTeamsMediaLoggingPolicy'                      = 'Set-CsTeamsMediaLoggingPolicy'
    'Get-CsTeamsRecordingRollOutPolicy'                  = 'Set-CsTeamsRecordingRollOutPolicy'
    'Get-CsTeamsWorkLocationDetectionPolicy'             = 'Set-CsTeamsWorkLocationDetectionPolicy'

    # -- Devices & Client ------------------------------------------------------
    'Get-CsTeamsBYODAndDesksPolicy'                      = 'Set-CsTeamsBYODAndDesksPolicy'
    'Get-CsTeamsClientConfiguration'                     = 'Set-CsTeamsClientConfiguration'
    'Get-CsTeamsIPPhonePolicy'                           = 'Set-CsTeamsIPPhonePolicy'
    'Get-CsTeamsMediaConnectivityPolicy'                 = 'Set-CsTeamsMediaConnectivityPolicy'
    'Get-CsTeamsMobilityPolicy'                          = 'Set-CsTeamsMobilityPolicy'
    'Get-CsTeamsNetworkRoamingPolicy'                    = 'Set-CsTeamsNetworkRoamingPolicy'
    'Get-CsTeamsRoomVideoTeleConferencingPolicy'         = 'Set-CsTeamsRoomVideoTeleConferencingPolicy'
    'Get-CsTeamsSipDevicesConfiguration'                 = 'Set-CsTeamsSipDevicesConfiguration'
    'Get-CsTeamsVdiPolicy'                               = 'Set-CsTeamsVdiPolicy'
    'Get-CsTeamsVideoInteropServicePolicy'               = 'Set-CsTeamsVideoInteropServicePolicy'

    # -- Other -------------------------------------------------------------------
    'Get-CsTenantNetworkConfiguration'                     = 'Set-CsTenantNetworkConfiguration'

    # -- No Set- equivalent (read-only / meta cmdlets) -------------------------
    # These are excluded from the mapping because they have no Set- counterpart:
    #   Get-CsTeamsFirstPartyMeetingTemplateConfiguration  (read-only)
    #   Get-CsTeamsMeetingTemplateConfiguration            (read-only)
    #   Get-CsTeamsMeetingTemplatePermissionPolicy         (read-only templates)
    #   Get-CsTeamsPersonalAttendantPolicy                 (no Set- available)
    #   Get-CsTeamsRemoteLogCollectionConfiguration        (no Set- available)
    #   Get-CsPolicyPackage                                (meta/governance)
    #   Get-CsTenantLicensingConfiguration                 (read-only)
}
