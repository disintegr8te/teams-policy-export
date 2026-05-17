<#
    Properties to exclude from decision/comparison sheets.
    These are metadata, internal identifiers, or non-actionable fields
    that add noise without decision value.

    Wrapped in a hashtable because Import-PowerShellDataFile requires it.
    Access via: $config.Exclusions
#>
@{
    Exclusions = @(
        # -- Identity & metadata --------------------------------------------------
        'Identity'
        'Description'

        # -- Complex / nested objects (not useful in flat comparison) --------------
        'AllowedExternalDomains'
        'BlockedExternalDomains'
        'AllowedStreamingMediaInput'
        'BlockedAnonymousJoinClientTypes'

        # -- Internal message identifiers -----------------------------------------
        'RecordingAndTranscriptionCustomMessageIdentifier'

        # -- App list details (handled separately in app permission sheets) -------
        'DefaultCatalogApps'
        'GlobalCatalogApps'
        'PrivateCatalogApps'
        'AppPresetList'
        'AppPresetMeetingList'
        'PinnedAppBarApps'
        'PinnedMessageBarApps'
        'PinnedCalendarBarApps'

        # -- Pop-out app paths (rarely configured, implementation detail) ---------
        'PopoutAppPathForIncomingPstnCalls'

        # -- Deprecated / transitional fields -------------------------------------
        'EnableXmppAccess'

        # -- Licensing info (read-only, not a policy decision) --------------------
        'LicensingConfiguration'

        # -- Meeting invite language list (complex, handled separately) ------------
        'MeetingInviteLanguages'

        # -- Template content blobs (deep nested objects) -------------------------
        'MeetingTemplates'
        'HiddenMeetingTemplates'
        'TeamTemplates'
        'HiddenTeamTemplates'

        # -- Numeric IDs with no decision value -----------------------------------
        'CommunicationWithExternalOrgs'

        # -- Internal config/schema objects -----------------------------------------
        'Key'
        'ConfigMetadata'
        'ConfigId'
        'Element'
        'XsAnyElements'
        'XsAnyAttributes'
        'MsftInternalProcessingMode'
        'Anchor'

        # -- Complex domain/resource lists (not useful in flat comparison) ---------
        'AllowedDomains'
        'BlockedDomains'
        'AllowedTrialTenantDomains'
        'AllowedAcsResources'
        'BlockedTenants'
        'BlockedUsers'
        'AllowedDialOutExternalDomains'
        'EmergencyNumbers'
        'ExtendedNotifications'
        'ComplianceRecordingApplications'
        'OnlinePstnUsages'
        'RouteType'

        # -- App/resource list objects (handled in app permission sheets) ----------
        'AdditionalCustomizationApps'
        'PinnedCallingBarApps'
        'AppIds'

        # -- Network topology objects (infrastructure, not policy decisions) -------
        'NetworkRegions'
        'NetworkSites'
        'PostalCodes'
        'Subnets'

        # -- Port/range settings (infrastructure, not policy decisions) -----------
        'ClientAppSharingPort'
        'ClientAppSharingPortRange'
        'ClientAudioPort'
        'ClientAudioPortRange'
        'ClientVideoPort'
        'ClientVideoPortRange'

        # -- URL/text fields (tenant-specific config, not defaults) ---------------
        'HelpURL'
        'LegalURL'
        'LogoURL'
        'SupportURL'
        'CustomFooterText'
        'EnhancedEmergencyServiceDisclaimer'
        'ShiftNoticeMessageCustom'

        # -- Email configuration (tenant-specific) --------------------------------
        'SendEmailFromAddress'
        'SendEmailFromDisplayName'
        'SendEmailFromOverride'

        # -- Resource/media IDs (tenant-specific config) --------------------------
        'AudioFileId'
        'StreamingSourceUrl'
        'StreamingSourceAuthType'
        'CustomBanner'
        'CustomPromptsPackageId'
        'BranchApplianceFqdns'
        'ResourceAccount'
        'Devices'
        'NotificationDialOutNumber'
        'NotificationGroup'

        # -- Voicemail audio files (tenant-specific) ------------------------------
        'PostambleAudioFile'
        'PreambleAudioFile'
        'PrimarySystemPromptLanguage'
        'SecondarySystemPromptLanguage'

        # -- Template/package metadata --------------------------------------------
        'TeamsMeetingTemplates'
        'HiddenTemplates'
        'Name'
        'PackageType'
        'Policies'
        'RecommendationType'
        'SchemaVersion'

        # -- Branding media objects -----------------------------------------------
        'MeetingBackgroundImages'
        'MeetingBrandingThemes'
        'NdiAssuranceSlateImages'
        'DefaultTheme'

        # -- Education-specific fields (not applicable to most orgs) ----------------
        'MakeCodeEnabledType'
        'ParentDigestEnabledType'
        'TurnItInApiKey'
        'TurnItInApiUrl'
        'TurnItInEnabledType'
        'EduGenerativeAIEnhancements'
        'ParentGuardianPreferredContactMethod'
        'UpdateParentInformation'

        # -- Internal/read-only fields --------------------------------------------
        'Status'
        'Action'
        'RestrictedSenderList'
        'DisabledInProductMessages'
        'SuggestedPresetTags'
        'AreaCode'

        # -- Reserved for internal Microsoft use ----------------------------------
        'AllowCortanaAmbientListening'
        'AllowCortanaInContextSuggestions'
        'ThreadedChannelCreation'

        # -- Deprecated / SfB migration / obsolete --------------------------------
        'MigrateServiceNumbersOnCrossForestMove'
        'AutomaticallyReplaceAcpProvider'
        'UseUniqueConferenceIds'
        'IncludeTollFreeNumberInMeetingInvites'
        'EnableDialOutJoinConfirmation'
        'AllowFederatedUsersToDialOutToSelf'
        'AllowFederatedUsersToDialOutToThirdParty'
        'EnableLegacyClientInterop'
        'MeetingMigrationEnabled'

        # -- Update scheduling (only relevant when AllowManagedUpdates=true) ------
        'UpdateDayOfWeek'
        'UpdateTime'
        'UpdateTimeOfDay'

        # -- Phone number lists (tenant-specific) ---------------------------------
        'MeetingInvitePhoneNumbers'

        # -- Undocumented / internal properties -----------------------------------
        'ExtendedWorkInfoInPeopleSearch'
        'CallingSpendUserLimit'

        # -- Additional internal/infrastructure identifiers ----------------------
        'Id'
        'Authority'
        'AuthorityId'
        'Class'
    )
}
