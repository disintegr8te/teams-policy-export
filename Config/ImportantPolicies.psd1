# ==========================================================================
# Important Policies — Baseline Recommendations
# ==========================================================================
# This file defines recommended values for key Teams policy settings.
# Customize the recommendations, expected values, and risk levels
# to match your organization's security and compliance requirements.
#
# See docs/CONFIGURATION.md for field documentation.
# ==========================================================================
@{
    # ==========================================================================
    # Teams & Channels Policy
    # ==========================================================================
    'Get-CsTeamsChannelsPolicy' = @(
        @{ Property = 'AllowOrgWideTeamCreation'; Label = 'Create a Team (org-wide)'; Slide = 5; Category = 'Teams Policies'
            Recommendation   = 'RESTRICT. Controlled team creation prevents sprawl in large multi-site organizations.'
            MSRecommendation = 'DEFAULT: True. MS recommends evaluating per org size. For large enterprises, restrict and use governance policies.'
            ExpectedValues = @{ 'General' = 'False'; 'Restricted' = 'False'; 'IT-Department' = 'True'; 'Admin' = 'True' } }
        @{ Property = 'AllowPrivateChannelCreation'; Label = 'Create Private Channels'; Slide = 5; Category = 'Teams Policies'
            Recommendation   = 'ALLOW for most users. Private channels enable cross-department project collaboration while keeping sensitive data scoped.'
            MSRecommendation = 'DEFAULT: True. MS recommends enabling by default. Private channels provide confidentiality for sensitive discussions within a team.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False'; 'IT-Department' = 'True'; 'Admin' = 'True' } }
        @{ Property = 'AllowSharedChannelCreation'; Label = 'Create Shared Channels'; Slide = 5; Category = 'Teams Policies'
            Recommendation   = 'ALLOW for General+. Shared channels are critical for cross-department and external collaboration without full guest access.'
            MSRecommendation = 'DEFAULT: True. MS recommends enabling for secure B2B collaboration. Shared channels use Azure AD direct connect.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False'; 'IT-Department' = 'True'; 'Admin' = 'True' } }
        @{ Property = 'EnablePrivateTeamDiscovery'; Label = 'Discover Private Teams'; Slide = 5; Category = 'Teams Policies'
            Recommendation   = 'RESTRICT to IT/Admin only. With multiple business units and sensitive R&D, private team discovery should be limited.'
            MSRecommendation = 'DEFAULT: False. MS keeps this disabled by default for privacy. Users find teams through search, invites, or org directory.'
            ExpectedValues = @{ 'General' = 'False'; 'Restricted' = 'False'; 'IT-Department' = 'True'; 'Admin' = 'True' } }
        @{ Property = 'AllowChannelSharingToExternalUser'; Label = 'Share Channels Externally'; Slide = 5; Category = 'Teams Policies'
            Recommendation   = 'ALLOW. Enables cross-org shared channels with suppliers and customers.'
            MSRecommendation = 'DEFAULT: True. MS allows sharing channels to external users by default.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False' } }
        @{ Property = 'AllowUserToParticipateInExternalSharedChannel'; Label = 'Join External Shared Channels'; Slide = 5; Category = 'Teams Policies'
            Recommendation   = 'ALLOW. Users need to join shared channels from partner organizations.'
            MSRecommendation = 'DEFAULT: True. MS allows participation in external shared channels by default.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False' } }
    )

    # ==========================================================================
    # Meeting Policy
    # ==========================================================================
    'Get-CsTeamsMeetingPolicy' = @(
        # --- Recording & Transcription ---
        @{ Property = 'AllowCloudRecording'; Label = 'Cloud Recording'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW for most users. Essential for multi-timezone org where async meeting review is critical.'
            MSRecommendation = 'DEFAULT: True. MS recommends enabling. Recordings support compliance, accessibility, and knowledge sharing.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False'; 'IT-Department' = 'True'; 'Admin' = 'True' } }
        @{ Property = 'AllowTranscription'; Label = 'Transcription'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW for most users. Transcription supports multilingual workforce in international organizations.'
            MSRecommendation = 'DEFAULT: True. MS recommends enabling alongside cloud recording. Supports accessibility and searchable content.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False'; 'IT-Department' = 'True'; 'Admin' = 'True' } }
        @{ Property = 'AllowLocalRecording'; Label = 'Local Recording'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'BLOCK. Local recordings bypass cloud DLP policies. Sensitive data should stay in managed storage.'
            MSRecommendation = 'DEFAULT: False. MS disables local recording by default. Cloud recording is the recommended approach for compliance.'
            ExpectedValues = @{ 'General' = 'False'; 'Restricted' = 'False'; 'IT-Department' = 'False'; 'Admin' = 'False' } }
        @{ Property = 'AutoRecording'; Label = 'Auto Recording'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DISABLED for most users. Enable selectively for compliance-critical meetings only.'
            MSRecommendation = 'DEFAULT: False. MS disables by default. Auto-recording starts recording when the meeting begins without user action.'
            ExpectedValues = @{ 'General' = 'False'; 'Restricted' = 'False'; 'IT-Department' = 'False'; 'Admin' = 'False' } }
        @{ Property = 'RecordingStorageMode'; Label = 'Recording Storage'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DEFAULT (OneDrive). Ensures recordings are stored in managed M365 storage with DLP policies applied.'
            MSRecommendation = 'DEFAULT: OneDriveForBusiness. MS stores recordings in OneDrive/SharePoint by default. Standard compliance policies apply.'
            ExpectedValues = @{ 'General' = 'OneDriveForBusiness'; 'Restricted' = 'OneDriveForBusiness' } }
        @{ Property = 'AllowRecordingStorageOutsideRegion'; Label = 'Recording Storage Outside Region'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW. Organizations with international presence need flexible storage for multi-geo recordings.'
            MSRecommendation = 'DEFAULT: False. MS keeps recordings in-region by default. Enable for multi-geo organizations.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False' } }
        @{ Property = 'ExplicitRecordingConsent'; Label = 'Explicit Recording Consent'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ENABLE. Required for GDPR compliance in EU operations.'
            MSRecommendation = 'DEFAULT: Disabled. MS disables by default. Required in jurisdictions with two-party consent laws.'
            ExpectedValues = @{ 'General' = 'Enabled'; 'Restricted' = 'Enabled' } }
        @{ Property = 'ChannelRecordingDownload'; Label = 'Channel Recording Download'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW. Teams should be able to download their own meeting recordings for offline review.'
            MSRecommendation = 'DEFAULT: Allow. MS allows channel recording download by default.'
            ExpectedValues = @{ 'General' = 'Allow'; 'Restricted' = 'Block' } }
        @{ Property = 'NewMeetingRecordingExpirationDays'; Label = 'Recording Expiration (days)'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'SET TO 120 days. Balances storage costs with knowledge retention needs across global org.'
            MSRecommendation = 'DEFAULT: 120. MS defaults to 120-day auto-expiration. Set to -1 for no expiration.'
            ExpectedValues = @{ 'General' = '120'; 'Restricted' = '60' } }
        @{ Property = 'AudibleRecordingNotification'; Label = 'Audible Recording Notification'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ENABLE. Required for meeting recording consent transparency.'
            MSRecommendation = 'DEFAULT: DualTone. MS plays a dual-tone audible notification when recording starts.'
            ExpectedValues = @{ 'General' = 'DualTone'; 'Restricted' = 'DualTone' } }
        @{ Property = 'SetRecordingAndTranscriptOwnership'; Label = 'Recording Ownership'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DISABLED. Use RecordingRollOutPolicy for ownership control instead.'
            MSRecommendation = 'DEFAULT: Disabled. MS disables transcript/recording ownership override by default.'
            ExpectedValues = @{ 'General' = 'Disabled' } }
        @{ Property = 'EnableRecordingAndTranscriptionCustomMessage'; Label = 'Custom Recording Message'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DISABLED unless custom GDPR notice is needed.'
            MSRecommendation = 'DEFAULT: False. MS disables custom recording messages by default.'
            ExpectedValues = @{ 'General' = 'False' } }
        @{ Property = 'AllowTasksFromTranscript'; Label = 'Tasks from Transcript'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW. Useful productivity feature for action item tracking after meetings.'
            MSRecommendation = 'DEFAULT: True. MS enables task extraction from transcripts by default.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False' } }

        # --- Chat & Collaboration ---
        @{ Property = 'MeetingChatEnabledType'; Label = 'Meeting Chat'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ENABLE for all non-restricted users. Essential for sharing links, documents, and action items.'
            MSRecommendation = 'DEFAULT: Enabled. MS recommends Enabled for collaboration. Options: Enabled, EnabledExceptAnonymous, Limited, Disabled.'
            ExpectedValues = @{ 'General' = 'Enabled'; 'Restricted' = 'Disabled'; 'IT-Department' = 'Enabled'; 'Admin' = 'Enabled' } }
        @{ Property = 'AllowMeetingReactions'; Label = 'Reactions'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW. Low-risk engagement feature for company-wide town halls.'
            MSRecommendation = 'DEFAULT: True. MS recommends enabling. Reactions improve engagement and provide non-verbal feedback.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False'; 'IT-Department' = 'True'; 'Admin' = 'True' } }
        @{ Property = 'AllowAnnotations'; Label = 'Annotations'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW. Useful for engineering discussions and document review.'
            MSRecommendation = 'DEFAULT: True. MS enables annotations by default. Allows participants to annotate shared content.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False' } }
        @{ Property = 'AllowSharedNotes'; Label = 'Shared Notes'; Slide = 6; Category = 'Meeting Policies'; Risk = 'Medium'
            Recommendation   = 'ALLOW. Collaborative note-taking supports meeting documentation.'
            MSRecommendation = 'DEFAULT: True. MS enables shared notes by default.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False' } }
        @{ Property = 'AllowWhiteboard'; Label = 'Whiteboard'; Slide = 6; Category = 'Meeting Policies'; Risk = 'Medium'
            Recommendation   = 'ALLOW. Useful for engineering design discussions and process flow mapping.'
            MSRecommendation = 'DEFAULT: True. MS recommends enabling. Data stored in OneDrive with standard compliance policies.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False'; 'IT-Department' = 'True'; 'Admin' = 'True' } }
        @{ Property = 'QnAEngagementMode'; Label = 'Q&A in Meetings'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ENABLE. Useful for structured feedback in large cross-department meetings.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables Q&A engagement in meetings by default.'
            ExpectedValues = @{ 'General' = 'Enabled'; 'Restricted' = 'Disabled' } }
        @{ Property = 'LobbyChat'; Label = 'Lobby Chat'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ENABLE. Allows waiting participants to communicate before being admitted.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables lobby chat by default.'
            ExpectedValues = @{ 'General' = 'Enabled'; 'Restricted' = 'Disabled' } }
        @{ Property = 'AllowDocumentCollaboration'; Label = 'Document Collaboration'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW. Enables real-time document collaboration during meetings.'
            MSRecommendation = 'DEFAULT: True. MS enables document collaboration in meetings by default.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False' } }
        @{ Property = 'AllowEngagementReport'; Label = 'Engagement Report'; Slide = 6; Category = 'Meeting Policies'; Risk = 'Medium'
            Recommendation   = 'ALLOW. Organizers need attendance/engagement data for training and all-hands tracking.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables engagement reports by default for organizers.'
            ExpectedValues = @{ 'General' = 'Enabled'; 'Restricted' = 'Disabled' } }

        # --- Join & Lobby ---
        @{ Property = 'AllowAnonymousUsersToJoinMeeting'; Label = 'Anonymous Join'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'BLOCK for General/Restricted. HIGH RISK for sensitive IP. Only Admin tier should allow for external demos.'
            MSRecommendation = 'DEFAULT: True. CISA BASELINE: False. MS enables by default but CISA recommends disabling.'
            ExpectedValues = @{ 'General' = 'False'; 'Restricted' = 'False'; 'IT-Department' = 'False'; 'Admin' = 'True' } }
        @{ Property = 'AllowAnonymousUsersToStartMeeting'; Label = 'Anonymous Users Start Meeting'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'BLOCK. Anonymous users should never be able to start a meeting.'
            MSRecommendation = 'DEFAULT: False. MS disables by default. Anonymous users must wait for authenticated organizer.'
            ExpectedValues = @{ 'General' = 'False'; 'Restricted' = 'False' } }
        @{ Property = 'AllowAnonymousUsersToDialOut'; Label = 'Anonymous Dial-Out'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'BLOCK. Prevents toll fraud risk from anonymous participants.'
            MSRecommendation = 'DEFAULT: False. MS disables anonymous dial-out by default.'
            ExpectedValues = @{ 'General' = 'False'; 'Restricted' = 'False' } }
        @{ Property = 'AutoAdmittedUsers'; Label = 'Lobby Bypass'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'TIERED. General: org-only. Restricted: OrganizerOnly. Admin: Everyone for external-facing meetings.'
            MSRecommendation = 'DEFAULT: EveryoneInCompany. MS recommends EveryoneInCompany as balanced default.'
            ExpectedValues = @{ 'General' = 'EveryoneInCompany'; 'Restricted' = 'OrganizerOnly'; 'IT-Department' = 'EveryoneInCompanyAndFederated'; 'Admin' = 'Everyone' } }
        @{ Property = 'AllowPSTNUsersToBypassLobby'; Label = 'PSTN Bypass Lobby'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'BLOCK. Phone dial-in users should go through lobby for security.'
            MSRecommendation = 'DEFAULT: False. MS sends PSTN users to lobby by default.'
            ExpectedValues = @{ 'General' = 'False'; 'Restricted' = 'False' } }
        @{ Property = 'AllowOrganizersToOverrideLobbySettings'; Label = 'Organizer Override Lobby'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW. Gives organizers flexibility for specific meeting needs.'
            MSRecommendation = 'DEFAULT: False. MS does not allow organizer override of lobby settings by default.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False' } }
        @{ Property = 'UsersCanAdmitFromLobby'; Label = 'Who Can Admit from Lobby'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'OrganizerAndCoOrganizersAndPresenters for General. Restricts lobby admission authority.'
            MSRecommendation = 'DEFAULT: OrganizerAndCoOrganizersAndPresenters. MS allows organizers, co-organizers, and presenters to admit.'
            ExpectedValues = @{ 'General' = 'OrganizerAndCoOrganizersAndPresenters'; 'Restricted' = 'OrganizerAndCoOrganizers' } }
        @{ Property = 'CaptchaVerificationForMeetingJoin'; Label = 'CAPTCHA for Meeting Join'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ENABLE for anonymous users. Prevents bot-based meeting disruption.'
            MSRecommendation = 'DEFAULT: NotRequired. MS does not require CAPTCHA by default.'
            ExpectedValues = @{ 'General' = 'AnonymousUsersAndUntrustedOrganizations' } }
        @{ Property = 'ExternalMeetingJoin'; Label = 'External Meeting Join'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW. Needed for cross-company collaboration with suppliers and customers.'
            MSRecommendation = 'DEFAULT: EnabledForAnyone. MS allows joining external meetings by default.'
            ExpectedValues = @{ 'General' = 'EnabledForAnyone'; 'Restricted' = 'Disabled' } }
        @{ Property = 'AnonymousUserAuthenticationMethod'; Label = 'Anonymous Auth Method'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DEFAULT. OneTimePasscode provides basic verification for anonymous users.'
            MSRecommendation = 'DEFAULT: OneTimePasscode. MS uses one-time passcode for anonymous join verification.'
            ExpectedValues = @{ 'General' = 'OneTimePasscode' } }

        # --- Scheduling ---
        @{ Property = 'AllowChannelMeetingScheduling'; Label = 'Channel Meeting Scheduling'; Slide = 5; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW. Enables quick ad-hoc channel meetings for cross-site engineering troubleshooting.'
            MSRecommendation = 'DEFAULT: True. MS recommends enabling. Channel meetings keep context within the team.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False'; 'IT-Department' = 'True'; 'Admin' = 'True' } }
        @{ Property = 'AllowMeetNow'; Label = 'Meet Now'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW. Ad-hoc meetings are essential for fast-paced operational support.'
            MSRecommendation = 'DEFAULT: True. MS enables Meet Now by default.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False' } }
        @{ Property = 'AllowPrivateMeetNow'; Label = 'Private Meet Now'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW. Enables quick 1:1 or small group calls.'
            MSRecommendation = 'DEFAULT: True. MS enables private Meet Now by default.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False' } }
        @{ Property = 'AllowPrivateMeetingScheduling'; Label = 'Private Meeting Scheduling'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW. Standard scheduling capability needed by all users.'
            MSRecommendation = 'DEFAULT: True. MS enables private meeting scheduling by default.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'True' } }
        @{ Property = 'AllowOutlookAddIn'; Label = 'Outlook Add-in'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW. Most users schedule meetings from Outlook.'
            MSRecommendation = 'DEFAULT: True. MS enables the Teams Meeting add-in for Outlook by default.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'True' } }
        @{ Property = 'AllowMeetingRegistration'; Label = 'Meeting Registration'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW. Useful for webinars and structured events.'
            MSRecommendation = 'DEFAULT: True. MS enables meeting registration by default.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False' } }
        @{ Property = 'WhoCanRegister'; Label = 'Who Can Register'; Slide = 6; Category = 'Meeting Policies'; Risk = 'Medium'
            Recommendation   = 'Everyone for external-facing events.'
            MSRecommendation = 'DEFAULT: Everyone. MS allows both internal and external registrations by default.'
            ExpectedValues = @{ 'General' = 'Everyone'; 'Restricted' = 'EveryoneInCompany' } }

        # --- Sharing & Content ---
        @{ Property = 'ScreenSharingMode'; Label = 'Screen Share'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'EntireScreen for most. SingleApplication for Restricted to prevent accidental data exposure.'
            MSRecommendation = 'DEFAULT: EntireScreen. MS default allows full desktop sharing.'
            ExpectedValues = @{ 'General' = 'EntireScreen'; 'Restricted' = 'SingleApplication'; 'IT-Department' = 'EntireScreen'; 'Admin' = 'EntireScreen' } }
        @{ Property = 'AllowIPVideo'; Label = 'IP Video'; Slide = 6; Category = 'Meeting Policies'; Risk = 'High'
            Recommendation   = 'ALLOW. Video is essential for effective remote collaboration.'
            MSRecommendation = 'DEFAULT: True. MS enables IP video by default.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'True' } }
        @{ Property = 'AllowIPAudio'; Label = 'IP Audio'; Slide = 6; Category = 'Meeting Policies'; Risk = 'High'
            Recommendation   = 'ALLOW. Core meeting functionality.'
            MSRecommendation = 'DEFAULT: True. MS enables IP audio by default.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'True' } }
        @{ Property = 'IPVideoMode'; Label = 'IP Video Mode'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DEFAULT. EnabledOutgoingIncoming for full bidirectional video.'
            MSRecommendation = 'DEFAULT: EnabledOutgoingIncoming. Full bidirectional video enabled by default.'
            ExpectedValues = @{ 'General' = 'EnabledOutgoingIncoming' } }
        @{ Property = 'IPAudioMode'; Label = 'IP Audio Mode'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DEFAULT. EnabledOutgoingIncoming for full bidirectional audio.'
            MSRecommendation = 'DEFAULT: EnabledOutgoingIncoming. Full bidirectional audio enabled by default.'
            ExpectedValues = @{ 'General' = 'EnabledOutgoingIncoming' } }
        @{ Property = 'AllowPowerPointSharing'; Label = 'PowerPoint Sharing'; Slide = 6; Category = 'Meeting Policies'; Risk = 'Medium'
            Recommendation   = 'ALLOW. Standard presentation capability needed across all tiers.'
            MSRecommendation = 'DEFAULT: True. MS enables PowerPoint Live sharing by default.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'True' } }
        @{ Property = 'AllowParticipantGiveRequestControl'; Label = 'Participant Give/Request Control'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW. Needed for collaborative sessions and remote support.'
            MSRecommendation = 'DEFAULT: True. MS allows participants to give and request control by default.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False' } }
        @{ Property = 'AllowExternalParticipantGiveRequestControl'; Label = 'External Give/Request Control'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'BLOCK for most. External participants should not control shared content by default.'
            MSRecommendation = 'DEFAULT: False. MS blocks external participant control by default.'
            ExpectedValues = @{ 'General' = 'False'; 'Restricted' = 'False' } }
        @{ Property = 'AllowMultipleScreenshare'; Label = 'Multiple Screen Share'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW. Useful for side-by-side comparisons in engineering reviews.'
            MSRecommendation = 'DEFAULT: True. MS enables multiple concurrent screen shares by default.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False' } }
        @{ Property = 'ContentSharingInExternalMeetings'; Label = 'Content Sharing in External Meetings'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW. Needed for collaboration with external partners.'
            MSRecommendation = 'DEFAULT: Enabled. MS allows content sharing in external meetings by default.'
            ExpectedValues = @{ 'General' = 'Enabled'; 'Restricted' = 'Disabled' } }
        @{ Property = 'AllowNDIStreaming'; Label = 'NDI Streaming'; Slide = 6; Category = 'Meeting Policies'; Risk = 'High'
            Recommendation   = 'BLOCK. NDI streaming is a specialized broadcast feature. Not needed for standard use.'
            MSRecommendation = 'DEFAULT: False. MS disables NDI streaming by default.'
            ExpectedValues = @{ 'General' = 'False'; 'Restricted' = 'False' } }
        @{ Property = 'AllowScreenContentDigitization'; Label = 'Screen Content Digitization'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'BLOCK for Restricted. Prevents screenshot/capture of sensitive content.'
            MSRecommendation = 'DEFAULT: True. MS allows screen content digitization by default.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False' } }
        @{ Property = 'CopyRestriction'; Label = 'Copy Restriction'; Slide = 6; Category = 'Meeting Policies'; Risk = 'High'
            Recommendation   = 'KEEP DEFAULT (True) for General. Disable for Restricted to prevent copying of sensitive content.'
            MSRecommendation = 'DEFAULT: True. MS enables copy restriction (allows copying) by default.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False' } }
        @{ Property = 'DetectSensitiveContentDuringScreenSharing'; Label = 'Detect Sensitive Content'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ENABLE. Helps prevent accidental sharing of sensitive data during screen sharing.'
            MSRecommendation = 'DEFAULT: True. MS enables sensitive content detection by default.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'True' } }

        # --- Watermarks & Security ---
        @{ Property = 'AllowWatermarkForCameraVideo'; Label = 'Watermark Camera Video'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW for Restricted tier. Deters unauthorized recording of sensitive content.'
            MSRecommendation = 'DEFAULT: False. MS disables watermarks by default. Enable for E2EE or sensitive meetings.'
            ExpectedValues = @{ 'General' = 'False'; 'Restricted' = 'True' } }
        @{ Property = 'AllowWatermarkForScreenSharing'; Label = 'Watermark Screen Sharing'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW for Restricted tier. Deters screenshots of sensitive shared content.'
            MSRecommendation = 'DEFAULT: False. MS disables screen sharing watermarks by default.'
            ExpectedValues = @{ 'General' = 'False'; 'Restricted' = 'True' } }
        @{ Property = 'AllowWatermarkCustomizationForCameraVideo'; Label = 'Custom Camera Watermark'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DEFAULT. Standard watermark is sufficient.'
            MSRecommendation = 'DEFAULT: False. MS does not enable custom watermarks by default.'
            ExpectedValues = @{ 'General' = 'False' } }
        @{ Property = 'AllowWatermarkCustomizationForScreenSharing'; Label = 'Custom Screen Watermark'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DEFAULT. Standard watermark is sufficient.'
            MSRecommendation = 'DEFAULT: False. MS does not enable custom screen watermarks by default.'
            ExpectedValues = @{ 'General' = 'False' } }
        @{ Property = 'WatermarkForAnonymousUsers'; Label = 'Watermark for Anonymous'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: SameAsOtherParticipants. MS applies the same watermark settings to anonymous users.'
            ExpectedValues = @{ 'General' = 'SameAsOtherParticipants' } }

        # --- Presenter & Controls ---
        @{ Property = 'DesignatedPresenterRoleMode'; Label = 'Default Presenter Role'; Slide = 6; Category = 'Meeting Policies'; Risk = 'Medium'
            Recommendation   = 'KEEP DEFAULT. EveryoneUserOverride lets organizers choose per meeting.'
            MSRecommendation = 'DEFAULT: EveryoneUserOverride. Everyone is a presenter by default but organizers can change.'
            ExpectedValues = @{ 'General' = 'EveryoneUserOverride'; 'Restricted' = 'OrganizerOnlyUserOverride' } }
        @{ Property = 'AllowBreakoutRooms'; Label = 'Breakout Rooms'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW. Useful for workshops, training, and working sessions.'
            MSRecommendation = 'DEFAULT: True. MS enables breakout rooms by default.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False' } }
        @{ Property = 'ParticipantNameChange'; Label = 'Participant Name Change'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'BLOCK. Prevents identity spoofing in meetings.'
            MSRecommendation = 'DEFAULT: False. MS does not allow participants to change display name by default.'
            ExpectedValues = @{ 'General' = 'False'; 'Restricted' = 'False' } }
        @{ Property = 'ConnectToMeetingControls'; Label = 'Connect to Meeting Controls'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables connect to meeting controls by default.'
            ExpectedValues = @{ 'General' = 'Enabled' } }
        @{ Property = 'ParticipantSlideControl'; Label = 'Participant Slide Control'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW. Enables participants to navigate shared slides independently.'
            MSRecommendation = 'DEFAULT: True. MS enables participant slide control by default.'
            ExpectedValues = @{ 'General' = 'True' } }

        # --- Copilot & AI ---
        @{ Property = 'Copilot'; Label = 'Copilot in Meetings'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ENABLE with transcript. Valuable AI productivity feature for meeting summaries.'
            MSRecommendation = 'DEFAULT: EnabledWithTranscript. MS enables Copilot with transcript by default for licensed users.'
            ExpectedValues = @{ 'General' = 'EnabledWithTranscript'; 'Restricted' = 'Disabled' } }
        @{ Property = 'AutomaticallyStartCopilot'; Label = 'Auto-Start Copilot'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DISABLED. Let users choose when to activate Copilot.'
            MSRecommendation = 'DEFAULT: Disabled. MS does not auto-start Copilot by default.'
            ExpectedValues = @{ 'General' = 'Disabled' } }
        @{ Property = 'AllowCarbonSummary'; Label = 'Carbon Summary'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW. AI-powered meeting summaries improve productivity.'
            MSRecommendation = 'DEFAULT: True. MS enables carbon summaries by default.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False' } }
        @{ Property = 'AllowMeetingCoach'; Label = 'Meeting Coach'; Slide = 6; Category = 'Meeting Policies'; Risk = 'Medium'
            Recommendation   = 'ALLOW. AI-powered speaking feedback helps presenters improve.'
            MSRecommendation = 'DEFAULT: True. MS enables meeting coach by default.'
            ExpectedValues = @{ 'General' = 'True' } }

        # --- Captions & Accessibility ---
        @{ Property = 'LiveCaptionsEnabledType'; Label = 'Live Captions'; Slide = 6; Category = 'Meeting Policies'; Risk = 'High'
            Recommendation   = 'ENABLE. Essential for accessibility and multilingual workforce.'
            MSRecommendation = 'DEFAULT: DisabledUserOverride. Users can enable live captions themselves.'
            ExpectedValues = @{ 'General' = 'DisabledUserOverride' } }
        @{ Property = 'LiveInterpretationEnabledType'; Label = 'Live Interpretation'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ENABLE. Supports multilingual meetings in international organizations.'
            MSRecommendation = 'DEFAULT: DisabledUserOverride. Users can enable live interpretation themselves.'
            ExpectedValues = @{ 'General' = 'DisabledUserOverride' } }
        @{ Property = 'AllowCartCaptionsScheduling'; Label = 'CART Captions'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW. Supports accessibility for hearing-impaired employees.'
            MSRecommendation = 'DEFAULT: DisabledUserOverride. Organizers can enable CART captions per meeting.'
            ExpectedValues = @{ 'General' = 'DisabledUserOverride' } }
        @{ Property = 'RealTimeText'; Label = 'Real-Time Text'; Slide = 6; Category = 'Meeting Policies'; Risk = 'High'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables real-time text by default for accessibility.'
            ExpectedValues = @{ 'General' = 'Enabled' } }
        @{ Property = 'SpeakerAttributionMode'; Label = 'Speaker Attribution'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ENABLE. Improves transcript readability by identifying speakers.'
            MSRecommendation = 'DEFAULT: EnabledUserOverride. Users can enable speaker attribution.'
            ExpectedValues = @{ 'General' = 'EnabledUserOverride' } }
        @{ Property = 'NoiseSuppressionForDialInParticipants'; Label = 'Noise Suppression Dial-In'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DEFAULT. Noise suppression improves audio quality.'
            MSRecommendation = 'DEFAULT: MicrosoftDefault. MS uses its own noise suppression defaults for dial-in participants.'
            ExpectedValues = @{ 'General' = 'MicrosoftDefault' } }
        @{ Property = 'VoiceIsolation'; Label = 'Voice Isolation'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ENABLE. Important for environments with background noise.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables voice isolation by default.'
            ExpectedValues = @{ 'General' = 'Enabled' } }

        # --- Video & Visual ---
        @{ Property = 'VideoFiltersMode'; Label = 'Video Filters'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW all filters including background blur. Important for privacy.'
            MSRecommendation = 'DEFAULT: AllFilters. MS enables all video filters by default.'
            ExpectedValues = @{ 'General' = 'AllFilters' } }
        @{ Property = 'AllowAvatarsInGallery'; Label = 'Avatars in Gallery'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW. Alternative to camera for bandwidth-constrained locations.'
            MSRecommendation = 'DEFAULT: True. MS enables avatars by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'AllowImmersiveView'; Label = 'Immersive View'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW. Virtual layouts for meetings.'
            MSRecommendation = 'DEFAULT: True. MS enables immersive view by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'AllowExternalNonTrustedMeetingChat'; Label = 'External Non-Trusted Chat'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'BLOCK. Reduces risk from unknown external organizations.'
            MSRecommendation = 'DEFAULT: False. MS blocks chat from non-trusted external users by default.'
            ExpectedValues = @{ 'General' = 'False'; 'Restricted' = 'False' } }

        # --- Streaming & Broadcast ---
        @{ Property = 'LiveStreamingMode'; Label = 'Live Streaming'; Slide = 6; Category = 'Meeting Policies'; Risk = 'Medium'
            Recommendation   = 'BLOCK for most users. Only IT/Admin for controlled broadcasts.'
            MSRecommendation = 'DEFAULT: Disabled. MS disables live streaming by default.'
            ExpectedValues = @{ 'General' = 'Disabled'; 'Admin' = 'Enabled' } }
        @{ Property = 'StreamingAttendeeMode'; Label = 'Streaming Attendee Mode'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Disabled. MS disables streaming attendee mode by default.'
            ExpectedValues = @{ 'General' = 'Disabled' } }

        # --- Miscellaneous ---
        @{ Property = 'AllowTrackingInReport'; Label = 'Tracking in Report'; Slide = 6; Category = 'Meeting Policies'; Risk = 'Medium'
            Recommendation   = 'ALLOW. Enables attendance tracking for compliance and training meetings.'
            MSRecommendation = 'DEFAULT: True. MS enables tracking in attendance reports by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'InfoShownInReportMode'; Label = 'Info Shown in Report'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: FullInformation. MS shows full information in reports by default.'
            ExpectedValues = @{ 'General' = 'FullInformation' } }
        @{ Property = 'SmsNotifications'; Label = 'SMS Notifications'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables SMS meeting notifications by default.'
            ExpectedValues = @{ 'General' = 'Enabled' } }
        @{ Property = 'PreferredMeetingProviderForIslandsMode'; Label = 'Preferred Meeting Provider'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'TeamsAndSfb. Standard for orgs that have completed SfB migration.'
            MSRecommendation = 'DEFAULT: TeamsAndSfb. MS defaults to Teams and Skype for Business.'
            ExpectedValues = @{ 'General' = 'TeamsAndSfb' } }
        @{ Property = 'AllowNetworkConfigurationSettingsLookup'; Label = 'Network Config Lookup'; Slide = 6; Category = 'Meeting Policies'; Risk = 'Medium'
            Recommendation   = 'ALLOW. Enables Teams to optimize media quality based on network configuration.'
            MSRecommendation = 'DEFAULT: False. MS disables network config lookup by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'EnrollUserOverride'; Label = 'Enroll User Override'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Disabled. MS disables user enrollment override by default.'
            ExpectedValues = @{ 'General' = 'Disabled' } }
        @{ Property = 'RoomAttributeUserOverride'; Label = 'Room Attribute Override'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Off. MS disables room attribute user override by default.'
            ExpectedValues = @{ 'General' = 'Off' } }
        @{ Property = 'RoomPeopleNameUserOverride'; Label = 'Room People Name Override'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Off. MS disables room people name override by default.'
            ExpectedValues = @{ 'General' = 'Off' } }
        @{ Property = 'TeamsCameraFarEndPTZMode'; Label = 'Camera Far-End PTZ'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Disabled. MS disables far-end camera PTZ control by default.'
            ExpectedValues = @{ 'General' = 'Disabled' } }
        @{ Property = 'AttendeeIdentityMasking'; Label = 'Attendee Identity Masking'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Disabled. MS does not mask attendee identity by default.'
            ExpectedValues = @{ 'General' = 'Disabled' } }
        @{ Property = 'BackroomChat'; Label = 'Backroom Chat'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW. Enables presenters to have private chat during meetings.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables backroom chat by default.'
            ExpectedValues = @{ 'General' = 'Enabled' } }
        @{ Property = 'PasscodeComplexity'; Label = 'Passcode Complexity'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Default. MS uses the Default passcode complexity level.'
            ExpectedValues = @{ 'General' = 'Default' } }
        @{ Property = 'AIInterpreter'; Label = 'AI Interpreter'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ENABLE. Valuable for multilingual meetings in international organizations.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables AI interpreter by default.'
            ExpectedValues = @{ 'General' = 'Enabled'; 'Restricted' = 'Disabled' } }
        @{ Property = 'VoiceSimulationInInterpreter'; Label = 'Voice Simulation in Interpreter'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Disabled. MS disables voice simulation in interpreter by default.'
            ExpectedValues = @{ 'General' = 'Disabled' } }
        @{ Property = 'AllowedUsersForMeetingDetails'; Label = 'Meeting Details Visibility'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DEFAULT. Users who bypass lobby can see meeting details.'
            MSRecommendation = 'DEFAULT: UsersAllowedToByPassTheLobby. Only users who bypass the lobby see meeting info on the join screen.'
            ExpectedValues = @{ 'General' = 'UsersAllowedToByPassTheLobby' } }
        @{ Property = 'MediaBitRateKb'; Label = 'Media Bitrate (Kb)'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DEFAULT 50000 Kb/s.'
            MSRecommendation = 'DEFAULT: 50000. MS sets 50 Mbps max media bitrate for meetings by default.'
            ExpectedValues = @{ 'General' = '50000' } }
        @{ Property = 'WatermarkForCameraVideoOpacity'; Label = 'Camera Watermark Opacity'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: 100. MS uses fully opaque (100) watermarks on camera video.'
            ExpectedValues = @{ 'General' = '100' } }
        @{ Property = 'WatermarkForCameraVideoPattern'; Label = 'Camera Watermark Pattern'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: SingleLine. MS uses single-line watermark pattern on camera video.'
            ExpectedValues = @{ 'General' = 'SingleLine' } }
        @{ Property = 'WatermarkForScreenSharingOpacity'; Label = 'Screen Watermark Opacity'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: 100. MS uses fully opaque (100) watermarks on screen sharing.'
            ExpectedValues = @{ 'General' = '100' } }
        @{ Property = 'WatermarkForScreenSharingPattern'; Label = 'Screen Watermark Pattern'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: SingleLine. MS uses single-line watermark pattern on screen sharing.'
            ExpectedValues = @{ 'General' = 'SingleLine' } }
    )

    # ==========================================================================
    # Messaging Policy
    # ==========================================================================
    'Get-CsTeamsMessagingPolicy' = @(
        @{ Property = 'AllowUserEditMessage'; Label = 'Edit Sent Messages'; Slide = 7; Category = 'Messaging Policies'
            Recommendation   = 'ALLOW. Standard collaboration feature. Block for Restricted where audit trail matters.'
            MSRecommendation = 'DEFAULT: True. MS recommends enabling. Edited messages show an "Edited" indicator.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False'; 'IT-Department' = 'True'; 'Admin' = 'True' } }
        @{ Property = 'AllowUserDeleteMessage'; Label = 'Delete Sent Messages'; Slide = 7; Category = 'Messaging Policies'; Risk = 'High'
            Recommendation   = 'ALLOW. Block for Restricted where message retention matters for compliance.'
            MSRecommendation = 'DEFAULT: True. MS recommends enabling. Retention policies in Purview still capture deleted content.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False'; 'IT-Department' = 'True'; 'Admin' = 'True' } }
        @{ Property = 'AllowOwnerDeleteMessage'; Label = 'Owners Can Delete Messages'; Slide = 7; Category = 'Messaging Policies'
            Recommendation   = 'ALLOW. Team owners need moderation capability across shared channels.'
            MSRecommendation = 'DEFAULT: False. MS disables by default. Enable per-org for moderation needs.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'True'; 'IT-Department' = 'True'; 'Admin' = 'True' } }
        @{ Property = 'AllowGiphy'; Label = 'GIFs'; Slide = 7; Category = 'Messaging Policies'; Risk = 'Medium'
            Recommendation   = 'ALLOW with Strict rating. Light engagement tool. Block for Restricted.'
            MSRecommendation = 'DEFAULT: True. MS enables with Moderate rating by default.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False'; 'IT-Department' = 'True'; 'Admin' = 'True' } }
        @{ Property = 'GiphyRatingType'; Label = 'Giphy Rating'; Slide = 7; Category = 'Messaging Policies'; Risk = 'Medium'
            Recommendation   = 'STRICT. Professional environment warrants strict content filtering.'
            MSRecommendation = 'DEFAULT: Moderate. MS sets Moderate rating by default. Strict recommended for professional environments.'
            ExpectedValues = @{ 'General' = 'Strict'; 'Restricted' = 'Strict' } }
        @{ Property = 'AllowStickers'; Label = 'Stickers'; Slide = 7; Category = 'Messaging Policies'
            Recommendation   = 'ALLOW for General/IT/Admin. Block for operational channels.'
            MSRecommendation = 'DEFAULT: True. MS recommends enabling. Low compliance risk.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False'; 'IT-Department' = 'True'; 'Admin' = 'True' } }
        @{ Property = 'AllowMemes'; Label = 'Memes'; Slide = 7; Category = 'Messaging Policies'
            Recommendation   = 'ALLOW for General/IT/Admin. Keep operational channels professional.'
            MSRecommendation = 'DEFAULT: True. MS enables by default.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False'; 'IT-Department' = 'True'; 'Admin' = 'True' } }
        @{ Property = 'AllowUserDeleteChat'; Label = 'Remove Chat for User'; Slide = 7; Category = 'Messaging Policies'; Risk = 'High'
            Recommendation   = 'BLOCK. Chat deletion conflicts with data retention/compliance requirements.'
            MSRecommendation = 'DEFAULT: True. MS enables by default. Retention policies still capture content.'
            ExpectedValues = @{ 'General' = 'False'; 'Restricted' = 'True' } }
        @{ Property = 'AllowPriorityMessages'; Label = 'Urgent/Priority Messages'; Slide = 7; Category = 'Messaging Policies'
            Recommendation   = 'ALLOW. Critical -- operational issues need immediate attention across time zones.'
            MSRecommendation = 'DEFAULT: True. MS recommends enabling. Priority messages notify every 2 min for 20 min.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False'; 'IT-Department' = 'True'; 'Admin' = 'True' } }
        @{ Property = 'AllowUserChat'; Label = 'User Chat'; Slide = 7; Category = 'Messaging Policies'; Risk = 'High'
            Recommendation   = 'ALLOW. Core messaging functionality.'
            MSRecommendation = 'DEFAULT: True. MS enables user chat by default.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'True' } }
        @{ Property = 'AllowUrlPreviews'; Label = 'URL Previews'; Slide = 7; Category = 'Messaging Policies'; Risk = 'Medium'
            Recommendation   = 'ALLOW. Helps users preview shared links without clicking.'
            MSRecommendation = 'DEFAULT: True. MS enables URL previews by default.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'True' } }
        @{ Property = 'AllowSmartReply'; Label = 'Smart Reply'; Slide = 7; Category = 'Messaging Policies'; Risk = 'Medium'
            Recommendation   = 'ALLOW. AI-suggested replies speed up routine communications.'
            MSRecommendation = 'DEFAULT: True. MS enables smart reply by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'AllowSmartCompose'; Label = 'Smart Compose'; Slide = 7; Category = 'Messaging Policies'; Risk = 'Medium'
            Recommendation   = 'ALLOW. AI writing assistance improves communication quality.'
            MSRecommendation = 'DEFAULT: True. MS enables smart compose by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'ReadReceiptsEnabledType'; Label = 'Read Receipts'; Slide = 7; Category = 'Messaging Policies'
            Recommendation   = 'ALLOW user override. Read receipts useful but privacy-sensitive.'
            MSRecommendation = 'DEFAULT: UserPreference. MS lets users control read receipts. Options: Everyone, UserPreference, None.'
            ExpectedValues = @{ 'General' = 'UserPreference' } }
        @{ Property = 'AllowImmersiveReader'; Label = 'Immersive Reader'; Slide = 7; Category = 'Messaging Policies'
            Recommendation   = 'ALLOW. Accessibility tool for reading assistance.'
            MSRecommendation = 'DEFAULT: True. MS enables Immersive Reader by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'AllowUserTranslation'; Label = 'Message Translation'; Slide = 7; Category = 'Messaging Policies'; Risk = 'Medium'
            Recommendation   = 'ALLOW. Essential for multilingual workforce in international organizations.'
            MSRecommendation = 'DEFAULT: True. MS enables inline message translation by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'AllowVideoMessages'; Label = 'Video Messages'; Slide = 7; Category = 'Messaging Policies'
            Recommendation   = 'ALLOW. Short video messages useful for visual communication.'
            MSRecommendation = 'DEFAULT: True. MS enables video messages in chat by default.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False' } }
        @{ Property = 'AudioMessageEnabledType'; Label = 'Audio Messages'; Slide = 7; Category = 'Messaging Policies'
            Recommendation   = 'ALLOW. Voice messages useful for frontline workers and mobile users.'
            MSRecommendation = 'DEFAULT: ChatsAndChannels. MS enables audio messages in chats and channels.'
            ExpectedValues = @{ 'General' = 'ChatsAndChannels' } }
        @{ Property = 'AllowGiphyDisplay'; Label = 'Giphy Display'; Slide = 7; Category = 'Messaging Policies'
            Recommendation   = 'ALLOW when Giphy is allowed.'
            MSRecommendation = 'DEFAULT: True. MS enables Giphy display by default.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False' } }
        @{ Property = 'AllowFluidCollaborate'; Label = 'Fluid / Loop Components'; Slide = 7; Category = 'Messaging Policies'; Risk = 'Medium'
            Recommendation   = 'ALLOW. Loop components enable real-time collaborative editing in chat.'
            MSRecommendation = 'DEFAULT: True. MS enables Fluid/Loop components by default.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False' } }
        @{ Property = 'AllowChatWithGroup'; Label = 'Group Chat'; Slide = 7; Category = 'Messaging Policies'
            Recommendation   = 'ALLOW. Group chat is essential for team collaboration.'
            MSRecommendation = 'DEFAULT: True. MS enables group chat by default.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'True' } }
        @{ Property = 'AllowGroupChatJoinLinks'; Label = 'Group Chat Join Links'; Slide = 7; Category = 'Messaging Policies'
            Recommendation   = 'ALLOW. Enables easy joining of group conversations.'
            MSRecommendation = 'DEFAULT: True. MS enables group chat join links by default.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False' } }
        @{ Property = 'AllowRemoveUser'; Label = 'Remove User from Chat'; Slide = 7; Category = 'Messaging Policies'; Risk = 'High'
            Recommendation   = 'ALLOW. Chat owners need to manage participants.'
            MSRecommendation = 'DEFAULT: True. MS allows removing users from chats by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'AllowPasteInternetImage'; Label = 'Paste Internet Images'; Slide = 7; Category = 'Messaging Policies'
            Recommendation   = 'ALLOW. Standard communication feature.'
            MSRecommendation = 'DEFAULT: True. MS allows pasting internet images by default.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False' } }
        @{ Property = 'AllowCustomGroupChatAvatars'; Label = 'Custom Group Chat Avatars'; Slide = 7; Category = 'Messaging Policies'
            Recommendation   = 'ALLOW. Low-risk personalization feature.'
            MSRecommendation = 'DEFAULT: True. MS enables custom group chat avatars by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'CreateCustomEmojis'; Label = 'Create Custom Emojis'; Slide = 7; Category = 'Messaging Policies'
            Recommendation   = 'ALLOW. Enables team-specific emojis for engagement.'
            MSRecommendation = 'DEFAULT: True. MS enables custom emoji creation by default.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False' } }
        @{ Property = 'DeleteCustomEmojis'; Label = 'Delete Custom Emojis'; Slide = 7; Category = 'Messaging Policies'
            Recommendation   = 'ALLOW. Users should be able to manage their own custom emojis.'
            MSRecommendation = 'DEFAULT: False. MS does not allow deleting custom emojis by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'AllowSecurityEndUserReporting'; Label = 'Security Reporting'; Slide = 7; Category = 'Messaging Policies'; Risk = 'High'
            Recommendation   = 'ENABLE. Users should be able to report suspicious messages.'
            MSRecommendation = 'DEFAULT: True. MS enables security end-user reporting by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'AllowCommunicationComplianceEndUserReporting'; Label = 'Compliance Reporting'; Slide = 7; Category = 'Messaging Policies'; Risk = 'High'
            Recommendation   = 'ENABLE. Supports compliance incident reporting.'
            MSRecommendation = 'DEFAULT: True. MS enables communication compliance end-user reporting by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'ChannelsInChatListEnabledType'; Label = 'Channels in Chat List'; Slide = 7; Category = 'Messaging Policies'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: DisabledUserOverride. Users can choose to show channels in their chat list.'
            ExpectedValues = @{ 'General' = 'DisabledUserOverride' } }
        @{ Property = 'AllowFullChatPermissionUserToDeleteAnyMessage'; Label = 'Full Permission Delete'; Slide = 7; Category = 'Messaging Policies'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: False. MS does not allow full-permission users to delete any message by default.'
            ExpectedValues = @{ 'General' = 'False' } }
        @{ Property = 'InOrganizationChatControl'; Label = 'In-Org Chat Control'; Slide = 7; Category = 'Messaging Policies'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables in-organization chat control by default.'
            ExpectedValues = @{ 'General' = 'Enabled' } }
        @{ Property = 'AllowProactiveSummaries'; Label = 'Proactive Summaries'; Slide = 7; Category = 'Messaging Policies'
            Recommendation   = 'ALLOW. AI-powered chat summaries improve productivity.'
            MSRecommendation = 'DEFAULT: True. MS enables proactive summaries by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'DesignerForBackgroundsAndImages'; Label = 'Designer Backgrounds'; Slide = 7; Category = 'Messaging Policies'
            Recommendation   = 'ALLOW. AI background generation is a low-risk feature.'
            MSRecommendation = 'DEFAULT: True. MS enables Designer for backgrounds by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'ChatPermissionRole'; Label = 'Chat Permission Role'; Slide = 7; Category = 'Messaging Policies'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Restricted. MS uses restricted chat permissions by default.'
            ExpectedValues = @{ 'General' = 'Restricted' } }
        @{ Property = 'UsersCanDeleteBotMessages'; Label = 'Delete Bot Messages'; Slide = 7; Category = 'Messaging Policies'
            Recommendation   = 'ALLOW. Users should be able to clean up bot messages.'
            MSRecommendation = 'DEFAULT: False. MS does not allow users to delete bot messages by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'AutoShareFilesInExternalChats'; Label = 'Auto Share Files External'; Slide = 7; Category = 'Messaging Policies'
            Recommendation   = 'BLOCK. Prevent automatic file sharing with external parties.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables auto file sharing in external chats by default.'
            ExpectedValues = @{ 'General' = 'Disabled'; 'Restricted' = 'Disabled' } }
        @{ Property = 'UseB2BInvitesToAddExternalUsers'; Label = 'B2B Invites for External'; Slide = 7; Category = 'Messaging Policies'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: True. MS uses B2B invites to add external users by default.'
            ExpectedValues = @{ 'General' = 'True' } }
    )

    # ==========================================================================
    # Calling Policy
    # ==========================================================================
    'Get-CsTeamsCallingPolicy' = @(
        @{ Property = 'AllowPrivateCalling'; Label = 'Private Calling'; Slide = 0; Category = 'Calling & Voice'; Risk = 'High'
            Recommendation   = 'ALLOW. Core calling feature for all users.'
            MSRecommendation = 'DEFAULT: True. MS enables private calling by default.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'True' } }
        @{ Property = 'AllowVoicemail'; Label = 'Voicemail'; Slide = 0; Category = 'Calling & Voice'; Risk = 'High'
            Recommendation   = 'ALLOW. Standard voicemail for missed calls.'
            MSRecommendation = 'DEFAULT: UserOverride. MS allows users to manage voicemail settings.'
            ExpectedValues = @{ 'General' = 'UserOverride' } }
        @{ Property = 'AllowCallGroups'; Label = 'Call Groups'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ALLOW. Enables ring groups for team-based call handling.'
            MSRecommendation = 'DEFAULT: True. MS enables call groups by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'AllowDelegation'; Label = 'Call Delegation'; Slide = 0; Category = 'Calling & Voice'; Risk = 'Medium'
            Recommendation   = 'ALLOW. Executive assistants need to manage calls on behalf of leaders.'
            MSRecommendation = 'DEFAULT: True. MS enables call delegation by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'AllowCallForwardingToUser'; Label = 'Forward to User'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ALLOW. Standard call forwarding capability.'
            MSRecommendation = 'DEFAULT: True. MS enables call forwarding to users by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'AllowCallForwardingToPhone'; Label = 'Forward to Phone'; Slide = 0; Category = 'Calling & Voice'; Risk = 'Medium'
            Recommendation   = 'ALLOW. Important for mobile workers and remote staff.'
            MSRecommendation = 'DEFAULT: True. MS enables call forwarding to phone by default.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False' } }
        @{ Property = 'PreventTollBypass'; Label = 'Prevent Toll Bypass'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ENABLE. Prevents toll fraud by routing PSTN calls through operator.'
            MSRecommendation = 'DEFAULT: False. MS does not prevent toll bypass by default.'
            ExpectedValues = @{ 'General' = 'False' } }
        @{ Property = 'BusyOnBusyEnabledType'; Label = 'Busy on Busy'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP DEFAULT. Users can manage their own busy behavior.'
            MSRecommendation = 'DEFAULT: Disabled. MS disables busy-on-busy by default. Options: Disabled, Enabled, Unanswered.'
            ExpectedValues = @{ 'General' = 'Disabled' } }
        @{ Property = 'MusicOnHoldEnabledType'; Label = 'Music on Hold'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ENABLE. Professional experience for callers on hold.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables music on hold by default.'
            ExpectedValues = @{ 'General' = 'Enabled' } }
        @{ Property = 'AllowCloudRecordingForCalls'; Label = 'Call Recording'; Slide = 0; Category = 'Calling & Voice'; Risk = 'High'
            Recommendation   = 'ALLOW. Useful for quality assurance and compliance documentation.'
            MSRecommendation = 'DEFAULT: True. MS enables cloud recording for calls by default.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False' } }
        @{ Property = 'AllowTranscriptionForCalling'; Label = 'Call Transcription'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ALLOW. Supports compliance and multilingual workforce.'
            MSRecommendation = 'DEFAULT: True. MS enables call transcription by default.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False' } }
        @{ Property = 'SpamFilteringEnabledType'; Label = 'Spam Filtering'; Slide = 0; Category = 'Calling & Voice'; Risk = 'High'
            Recommendation   = 'ENABLE. Reduces spam/robocall interruptions.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables spam filtering by default.'
            ExpectedValues = @{ 'General' = 'Enabled' } }
        @{ Property = 'AllowCallRedirect'; Label = 'Call Redirect'; Slide = 0; Category = 'Calling & Voice'; Risk = 'Medium'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Disabled. MS disables call redirect by default.'
            ExpectedValues = @{ 'General' = 'Disabled' } }
        @{ Property = 'AllowWebPSTNCalling'; Label = 'Web PSTN Calling'; Slide = 0; Category = 'Calling & Voice'; Risk = 'Medium'
            Recommendation   = 'ALLOW. Enables calling from Teams web client.'
            MSRecommendation = 'DEFAULT: True. MS enables web PSTN calling by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'AllowSIPDevicesCalling'; Label = 'SIP Device Calling'; Slide = 0; Category = 'Calling & Voice'; Risk = 'High'
            Recommendation   = 'ENABLE for users with SIP devices. Disabled by default.'
            MSRecommendation = 'DEFAULT: False. MS disables SIP device calling by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'Copilot'; Label = 'Copilot in Calls'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ENABLE for licensed users.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables Copilot for calls by default.'
            ExpectedValues = @{ 'General' = 'Enabled'; 'Restricted' = 'Disabled' } }
        @{ Property = 'LiveCaptionsEnabledTypeForCalling'; Label = 'Live Captions for Calls'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ALLOW user override. Accessibility feature.'
            MSRecommendation = 'DEFAULT: DisabledUserOverride. Users can enable live captions for calls.'
            ExpectedValues = @{ 'General' = 'DisabledUserOverride' } }
        @{ Property = 'AutoAnswerEnabledType'; Label = 'Auto Answer'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP DISABLED. Auto-answer should only be used on shared devices.'
            MSRecommendation = 'DEFAULT: Disabled. MS disables auto-answer by default.'
            ExpectedValues = @{ 'General' = 'Disabled' } }
        @{ Property = 'RealTimeText'; Label = 'Real-Time Text'; Slide = 0; Category = 'Calling & Voice'; Risk = 'High'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables real-time text in calls by default.'
            ExpectedValues = @{ 'General' = 'Enabled' } }
        @{ Property = 'CallRecordingExpirationDays'; Label = 'Call Recording Expiration'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'SET TO 60 days for call recordings.'
            MSRecommendation = 'DEFAULT: 60. MS defaults to 60-day expiration for call recordings.'
            ExpectedValues = @{ 'General' = '60' } }
        @{ Property = 'ReportCall'; Label = 'Report a Call'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ENABLE. Users should be able to report spam/fraud calls.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables call reporting by default.'
            ExpectedValues = @{ 'General' = 'Enabled' } }
        @{ Property = 'AIInterpreter'; Label = 'AI Interpreter (Calls)'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ENABLE. Valuable for multilingual calls in international organizations.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables AI interpreter for calls by default.'
            ExpectedValues = @{ 'General' = 'Enabled' } }
        @{ Property = 'ExplicitRecordingConsent'; Label = 'Explicit Recording Consent (Calls)'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ENABLE. Required for GDPR compliance in EU operations.'
            MSRecommendation = 'DEFAULT: Disabled. MS disables explicit recording consent for calls by default.'
            ExpectedValues = @{ 'General' = 'Enabled' } }
        @{ Property = 'InboundFederatedCallRoutingTreatment'; Label = 'Inbound Federated Call Routing'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: RegularIncoming. MS routes inbound federated calls as regular incoming calls.'
            ExpectedValues = @{ 'General' = 'RegularIncoming' } }
        @{ Property = 'InboundPstnCallRoutingTreatment'; Label = 'Inbound PSTN Call Routing'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: RegularIncoming. MS routes inbound PSTN calls as regular incoming calls.'
            ExpectedValues = @{ 'General' = 'RegularIncoming' } }
        @{ Property = 'VoiceSimulationInInterpreter'; Label = 'Voice Simulation in Interpreter (Calls)'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP DISABLED.'
            MSRecommendation = 'DEFAULT: Disabled. MS disables voice simulation in interpreter for calls.'
            ExpectedValues = @{ 'General' = 'Disabled' } }
        @{ Property = 'EnableSpendLimits'; Label = 'Call Spend Limits'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP DISABLED unless PSTN cost control needed.'
            MSRecommendation = 'DEFAULT: False. MS disables call spend limits by default.'
            ExpectedValues = @{ 'General' = 'False' } }
        @{ Property = 'PopoutForIncomingPstnCalls'; Label = 'Popout for PSTN Calls'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP DISABLED.'
            MSRecommendation = 'DEFAULT: Disabled. MS disables popout for incoming PSTN calls by default.'
            ExpectedValues = @{ 'General' = 'Disabled' } }
        @{ Property = 'EnableWebPstnMediaBypass'; Label = 'Web PSTN Media Bypass'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP DISABLED.'
            MSRecommendation = 'DEFAULT: False. MS disables web PSTN media bypass by default.'
            ExpectedValues = @{ 'General' = 'False' } }
        @{ Property = 'ShowTeamsCallsInCallLog'; Label = 'Show Calls in Call Log'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: True. Teams calls appear in the user call log by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'EnableRecordingAndTranscriptionCustomMessage'; Label = 'Custom Recording Message (Calls)'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP DISABLED.'
            MSRecommendation = 'DEFAULT: False. MS disables custom recording/transcription messages for calls.'
            ExpectedValues = @{ 'General' = 'False' } }
    )

    # ==========================================================================
    # App Permissions Policy
    # ==========================================================================
    'Get-CsTeamsAppPermissionPolicy' = @(
        @{ Property = 'DefaultCatalogAppsType'; Label = 'Microsoft Apps'; Slide = 8; Category = 'App Permissions'
            Recommendation   = 'ALLOW. Microsoft first-party apps are pre-vetted and essential.'
            MSRecommendation = 'DEFAULT: AllowedAppList. MS recommends allowing all Microsoft apps by default.'
            ExpectedValues = @{ 'General' = 'AllowedAppList'; 'Restricted' = 'AllowedAppList' } }
        @{ Property = 'GlobalCatalogAppsType'; Label = 'Third-party Apps'; Slide = 8; Category = 'App Permissions'
            Recommendation   = 'CURATED allow-list for General. BLOCK for Restricted. Third-party apps pose data exfiltration risk.'
            MSRecommendation = 'DEFAULT: AllowedAppList. MS enables all third-party by default but recommends restricting for enterprise.'
            ExpectedValues = @{ 'General' = 'AllowedAppList'; 'Restricted' = 'BlockedAppList' } }
        @{ Property = 'PrivateCatalogAppsType'; Label = 'Custom Apps'; Slide = 8; Category = 'App Permissions'
            Recommendation   = 'BLOCK for General/Restricted. Custom apps should be IT-vetted. Allow for IT/Admin/TechTeam.'
            MSRecommendation = 'DEFAULT: AllowedAppList. MS enables custom apps by default. Restrict for non-developer users.'
            ExpectedValues = @{ 'General' = 'BlockedAppList'; 'Restricted' = 'BlockedAppList'; 'IT-Department' = 'AllowedAppList' } }
    )

    # ==========================================================================
    # App Setup Policy
    # ==========================================================================
    'Get-CsTeamsAppSetupPolicy' = @(
        @{ Property = 'AllowSideLoading'; Label = 'App Sideloading'; Slide = 8; Category = 'App Permissions'
            Recommendation   = 'BLOCK for General/Restricted. Only IT/Admin should sideload apps.'
            MSRecommendation = 'DEFAULT: True. MS enables sideloading by default in the Global policy.'
            ExpectedValues = @{ 'General' = 'False'; 'Restricted' = 'False'; 'IT-Department' = 'True' } }
        @{ Property = 'AllowUserPinning'; Label = 'User App Pinning'; Slide = 8; Category = 'App Permissions'
            Recommendation   = 'ALLOW. Users should be able to pin their frequently used apps.'
            MSRecommendation = 'DEFAULT: True. MS enables user app pinning by default.'
            ExpectedValues = @{ 'General' = 'True' } }
    )

    # ==========================================================================
    # External Access Policy
    # ==========================================================================
    'Get-CsExternalAccessPolicy' = @(
        @{ Property = 'EnableFederationAccess'; Label = 'External Access (Federation)'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'ALLOW. Organizations with external collaboration needs should enable federation.'
            MSRecommendation = 'DEFAULT: False. MS disables in the Global policy by default.'
            ExpectedValues = @{ 'General' = 'True'; 'Restricted' = 'False'; 'IT-Department' = 'True'; 'Admin' = 'True' } }
        @{ Property = 'EnableTeamsConsumerAccess'; Label = 'Teams Consumer Access'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'BLOCK. Consumer accounts should not access corporate environment.'
            MSRecommendation = 'DEFAULT: True. MS enables Teams consumer access by default.'
            ExpectedValues = @{ 'General' = 'False'; 'Restricted' = 'False' } }
        @{ Property = 'EnableTeamsConsumerInbound'; Label = 'Teams Consumer Inbound'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'BLOCK. Prevent consumer users from initiating contact.'
            MSRecommendation = 'DEFAULT: True. MS allows inbound Teams consumer communication by default.'
            ExpectedValues = @{ 'General' = 'False'; 'Restricted' = 'False' } }
        @{ Property = 'EnableTeamsSmsAccess'; Label = 'Teams SMS Access'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: True. MS enables Teams SMS access by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'EnableOutsideAccess'; Label = 'Outside Access (Skype)'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'KEEP DISABLED. Legacy Skype feature not needed.'
            MSRecommendation = 'DEFAULT: False. MS disables outside access by default.'
            ExpectedValues = @{ 'General' = 'False' } }
        @{ Property = 'EnablePublicCloudAudioVideoAccess'; Label = 'Public Cloud A/V'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'KEEP DISABLED. Legacy Skype A/V feature.'
            MSRecommendation = 'DEFAULT: False. MS disables public cloud audio/video access by default.'
            ExpectedValues = @{ 'General' = 'False' } }
        @{ Property = 'EnableAcsFederationAccess'; Label = 'ACS Federation Access'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: True. MS enables ACS federation access in external access policy by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'FederatedBilateralChats'; Label = 'Federated Bilateral Chats'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'KEEP DISABLED.'
            MSRecommendation = 'DEFAULT: False. MS disables bilateral chat restriction by default.'
            ExpectedValues = @{ 'General' = 'False' } }
        @{ Property = 'RestrictTeamsConsumerAccessToExternalUserProfiles'; Label = 'Restrict Consumer Profiles'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: False. MS does not restrict consumer access to external profiles by default.'
            ExpectedValues = @{ 'General' = 'False' } }
    )

    # ==========================================================================
    # Tenant Federation Configuration
    # ==========================================================================
    'Get-CsTenantFederationConfiguration' = @(
        @{ Property = 'AllowFederatedUsers'; Label = 'Allow Federated Users'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'ALLOW. Required for external Teams-to-Teams communication.'
            MSRecommendation = 'DEFAULT: True. MS enables federation with other Teams organizations by default.'
            ExpectedValues = @{ '_Global' = 'True' } }
        @{ Property = 'AllowTeamsConsumer'; Label = 'Allow Teams Consumer'; Slide = 10; Category = 'External & Guests'; Risk = 'High'
            Recommendation   = 'BLOCK. Consumer Teams accounts should not have access to corporate environment.'
            MSRecommendation = 'DEFAULT: True. MS enables Teams consumer communication by default.'
            ExpectedValues = @{ '_Global' = 'False' } }
        @{ Property = 'AllowTeamsConsumerInbound'; Label = 'Teams Consumer Inbound'; Slide = 10; Category = 'External & Guests'; Risk = 'High'
            Recommendation   = 'BLOCK. Prevent consumer account users from initiating contact.'
            MSRecommendation = 'DEFAULT: True. MS allows inbound Teams consumer communication by default.'
            ExpectedValues = @{ '_Global' = 'False' } }
        @{ Property = 'TreatDiscoveredPartnersAsUnverified'; Label = 'Treat Partners as Unverified'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: False. MS trusts discovered partners by default.'
            ExpectedValues = @{ '_Global' = 'False' } }
        @{ Property = 'SharedSipAddressSpace'; Label = 'Shared SIP Address Space'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'KEEP DEFAULT. Only needed for hybrid SfB deployments.'
            MSRecommendation = 'DEFAULT: False. MS disables shared SIP address space by default.'
            ExpectedValues = @{ '_Global' = 'False' } }
        @{ Property = 'RestrictTeamsConsumerToExternalUserProfiles'; Label = 'Restrict Consumer Profiles'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: False. MS does not restrict consumer profiles by default.'
            ExpectedValues = @{ '_Global' = 'False' } }
        @{ Property = 'BlockAllSubdomains'; Label = 'Block All Subdomains'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'KEEP DISABLED. Subdomain blocking is too aggressive for global operations.'
            MSRecommendation = 'DEFAULT: False. MS does not block subdomains by default.'
            ExpectedValues = @{ '_Global' = 'False' } }
        @{ Property = 'AllowTeamsSms'; Label = 'Teams SMS'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: True. MS enables Teams SMS by default.'
            ExpectedValues = @{ '_Global' = 'True' } }
        @{ Property = 'ExternalAccessWithTrialTenants'; Label = 'External Access Trial Tenants'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'KEEP BLOCKED. Prevent federation with trial-only tenants.'
            MSRecommendation = 'DEFAULT: Blocked. MS blocks external access with trial tenants.'
            ExpectedValues = @{ '_Global' = 'Blocked' } }
        @{ Property = 'DomainBlockingForMDOAdminsInTeams'; Label = 'MDO Domain Blocking'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables Defender for Office domain blocking in Teams.'
            ExpectedValues = @{ '_Global' = 'Enabled' } }
        @{ Property = 'SecurityTeamAllowBlockListDelegation'; Label = 'Security Block List Delegation'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Disabled. MS does not delegate block list editing to security teams by default.'
            ExpectedValues = @{ '_Global' = 'Disabled' } }
    )

    # ==========================================================================
    # Guest Configurations
    # ==========================================================================
    'Get-CsTeamsGuestMessagingConfiguration' = @(
        @{ Property = 'AllowUserChat'; Label = 'Guest Can Use Chat'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'ALLOW. Guests need chat for project collaboration.'
            MSRecommendation = 'DEFAULT: True. MS recommends enabling for guest collaboration.'
            ExpectedValues = @{ '_Global' = 'True' } }
        @{ Property = 'AllowUserDeleteChat'; Label = 'Guest Delete Chat'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'ALLOW. Low risk -- retention policies still capture content.'
            MSRecommendation = 'DEFAULT: True. MS enables by default. Cosmetic deletion only.'
            ExpectedValues = @{ '_Global' = 'True' } }
        @{ Property = 'AllowUserEditMessage'; Label = 'Guest Edit Messages'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'ALLOW. Standard editing capability for guest users.'
            MSRecommendation = 'DEFAULT: True. MS enables guest message editing by default.'
            ExpectedValues = @{ '_Global' = 'True' } }
        @{ Property = 'AllowUserDeleteMessage'; Label = 'Guest Delete Messages'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'ALLOW. Standard message management for guest users.'
            MSRecommendation = 'DEFAULT: True. MS enables guest message deletion by default.'
            ExpectedValues = @{ '_Global' = 'True' } }
        @{ Property = 'AllowGiphy'; Label = 'Guest GIFs'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'ALLOW with Strict rating.'
            MSRecommendation = 'DEFAULT: True. MS enables Giphy for guests by default.'
            ExpectedValues = @{ '_Global' = 'True' } }
        @{ Property = 'GiphyRatingType'; Label = 'Guest Giphy Rating'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'STRICT. Keep professional.'
            MSRecommendation = 'DEFAULT: Moderate. MS sets Moderate rating for guests by default.'
            ExpectedValues = @{ '_Global' = 'Strict' } }
        @{ Property = 'AllowMemes'; Label = 'Guest Memes'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'ALLOW.'
            MSRecommendation = 'DEFAULT: True. MS enables memes for guests by default.'
            ExpectedValues = @{ '_Global' = 'True' } }
        @{ Property = 'AllowStickers'; Label = 'Guest Stickers'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'ALLOW.'
            MSRecommendation = 'DEFAULT: True. MS enables stickers for guests by default.'
            ExpectedValues = @{ '_Global' = 'True' } }
        @{ Property = 'AllowImmersiveReader'; Label = 'Guest Immersive Reader'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'ALLOW. Accessibility feature.'
            MSRecommendation = 'DEFAULT: True. MS enables Immersive Reader for guests by default.'
            ExpectedValues = @{ '_Global' = 'True' } }
        @{ Property = 'UsersCanDeleteBotMessages'; Label = 'Guest Delete Bot Messages'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: False. MS does not allow guests to delete bot messages by default.'
            ExpectedValues = @{ '_Global' = 'False' } }
    )

    'Get-CsTeamsGuestMeetingConfiguration' = @(
        @{ Property = 'ScreenSharingMode'; Label = 'Guest Screen Share'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'ALLOW EntireScreen. Guests need to share technical screens in project meetings.'
            MSRecommendation = 'DEFAULT: EntireScreen. MS allows full desktop sharing for guests.'
            ExpectedValues = @{ '_Global' = 'EntireScreen' } }
        @{ Property = 'AllowIPVideo'; Label = 'Guest Video'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'ALLOW. Video essential for remote collaboration.'
            MSRecommendation = 'DEFAULT: True. MS enables video for guests by default.'
            ExpectedValues = @{ '_Global' = 'True' } }
        @{ Property = 'AllowMeetNow'; Label = 'Guest Meet Now'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'ALLOW. Guests need ad-hoc meeting capability.'
            MSRecommendation = 'DEFAULT: True. MS enables Meet Now for guests by default.'
            ExpectedValues = @{ '_Global' = 'True' } }
        @{ Property = 'AllowTranscription'; Label = 'Guest Transcription'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'ALLOW. Supports accessibility.'
            MSRecommendation = 'DEFAULT: True. MS enables transcription for guests by default.'
            ExpectedValues = @{ '_Global' = 'True' } }
        @{ Property = 'LiveCaptionsEnabledType'; Label = 'Guest Live Captions'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'ALLOW user override.'
            MSRecommendation = 'DEFAULT: DisabledUserOverride. Guests can manually enable live captions.'
            ExpectedValues = @{ '_Global' = 'DisabledUserOverride' } }
        @{ Property = 'AllowExternalParticipantGiveRequestControl'; Label = 'Guest External Control'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: True. MS allows external participants to give/request control for guests.'
            ExpectedValues = @{ '_Global' = 'True' } }
        @{ Property = 'AllowMultipleScreenshare'; Label = 'Guest Multiple Screen Share'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: True. MS enables multiple screen sharing for guests.'
            ExpectedValues = @{ '_Global' = 'True' } }
        @{ Property = 'AllowParticipantGiveRequestControl'; Label = 'Guest Give/Request Control'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: True. MS allows guests to give and request control.'
            ExpectedValues = @{ '_Global' = 'True' } }
    )

    'Get-CsTeamsGuestCallingConfiguration' = @(
        @{ Property = 'AllowPrivateCalling'; Label = 'Guest Private Calling'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'ALLOW. Guests need Teams calls for urgent support issues.'
            MSRecommendation = 'DEFAULT: True. MS enables private calling for guests by default.'
            ExpectedValues = @{ '_Global' = 'True' } }
    )

    # ==========================================================================
    # Live Events / Broadcast Policy
    # ==========================================================================
    'Get-CsTeamsMeetingBroadcastPolicy' = @(
        @{ Property = 'AllowBroadcastScheduling'; Label = 'Live Events'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'BLOCK for General/Restricted. ALLOW for IT/Admin for controlled broadcasts.'
            MSRecommendation = 'DEFAULT: True. MS enables live event scheduling by default.'
            ExpectedValues = @{ 'General' = 'False'; 'Restricted' = 'False'; 'IT-Department' = 'True'; 'Admin' = 'True' } }
        @{ Property = 'AllowBroadcastTranscription'; Label = 'Broadcast Transcription'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW for IT/Admin. Transcription for live event attendees.'
            MSRecommendation = 'DEFAULT: False. MS disables broadcast transcription by default.'
            ExpectedValues = @{ 'General' = 'False'; 'IT-Department' = 'True'; 'Admin' = 'True' } }
        @{ Property = 'BroadcastAttendeeVisibilityMode'; Label = 'Broadcast Attendee Visibility'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Everyone. MS allows everyone to watch broadcast events by default.'
            ExpectedValues = @{ 'General' = 'Everyone' } }
        @{ Property = 'BroadcastRecordingMode'; Label = 'Broadcast Recording'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DEFAULT. Let organizers decide.'
            MSRecommendation = 'DEFAULT: UserOverride. MS lets organizers choose whether to record broadcast events.'
            ExpectedValues = @{ 'General' = 'UserOverride' } }
    )

    # ==========================================================================
    # Events Policy (Webinars/Townhalls)
    # ==========================================================================
    'Get-CsTeamsEventsPolicy' = @(
        @{ Property = 'AllowWebinars'; Label = 'Webinars'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW. Webinars useful for customer-facing events and training.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables webinars by default.'
            ExpectedValues = @{ 'General' = 'Enabled'; 'Restricted' = 'Disabled' } }
        @{ Property = 'AllowTownhalls'; Label = 'Town Halls'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW for Admin/IT only. Town halls for company-wide events.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables town halls by default.'
            ExpectedValues = @{ 'General' = 'Disabled'; 'IT-Department' = 'Enabled'; 'Admin' = 'Enabled' } }
        @{ Property = 'AllowEmailEditing'; Label = 'Event Email Editing'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW. Organizers should customize event communications.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables event email editing by default.'
            ExpectedValues = @{ 'General' = 'Enabled' } }
        @{ Property = 'EventAccessType'; Label = 'Event Access Type'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'Everyone for external-facing events.'
            MSRecommendation = 'DEFAULT: Everyone. MS allows everyone access to events by default.'
            ExpectedValues = @{ 'General' = 'Everyone'; 'Restricted' = 'EveryoneInCompanyExcludingGuests' } }
        @{ Property = 'UseMicrosoftECDN'; Label = 'Microsoft eCDN'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP ENABLED. Reduces bandwidth for large events across global offices.'
            MSRecommendation = 'DEFAULT: True. MS enables Microsoft eCDN by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'AllowEventIntegrations'; Label = 'Event Integrations'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW. Enables integration tab for event organizers.'
            MSRecommendation = 'DEFAULT: True. MS enables event integrations by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'AllowedQuestionTypesInRegistrationForm'; Label = 'Registration Questions'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DEFAULT. Allow all question types for flexible registration.'
            MSRecommendation = 'DEFAULT: AllQuestions. MS allows custom, standard, and required questions by default.'
            ExpectedValues = @{ 'General' = 'AllQuestions' } }
        @{ Property = 'AllowedTownhallTypesForRecordingPublish'; Label = 'Townhall Recording Publish'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Everyone. MS allows recording publish for all townhall types.'
            ExpectedValues = @{ 'General' = 'Everyone' } }
        @{ Property = 'AllowedWebinarTypesForRecordingPublish'; Label = 'Webinar Recording Publish'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Everyone. MS allows recording publish for all webinar types.'
            ExpectedValues = @{ 'General' = 'Everyone' } }
        @{ Property = 'BackroomChat'; Label = 'Backroom Chat'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW. Event organizers and presenters need private coordination.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables backroom chat for event organizers by default.'
            ExpectedValues = @{ 'General' = 'Enabled' } }
        @{ Property = 'BroadcastPremiumApps'; Label = 'Broadcast Premium Apps'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW. Enables Polls and other attendee-facing apps in events.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables broadcast premium apps by default.'
            ExpectedValues = @{ 'General' = 'Enabled' } }
        @{ Property = 'HighBitrateForTownhall'; Label = 'High Bitrate Townhall'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DISABLED. Standard bitrate sufficient for most events.'
            MSRecommendation = 'DEFAULT: Disabled. MS disables high-bitrate streaming for town halls.'
            ExpectedValues = @{ 'General' = 'Disabled' } }
        @{ Property = 'ImmersiveEvents'; Label = 'Immersive Events'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW. Enables immersive event experiences.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables immersive events by default.'
            ExpectedValues = @{ 'General' = 'Enabled' } }
        @{ Property = 'RecordingForTownhall'; Label = 'Townhall Recording'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW. Recording needed for async review of company-wide events.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables recording for town halls by default.'
            ExpectedValues = @{ 'General' = 'Enabled' } }
        @{ Property = 'RecordingForWebinar'; Label = 'Webinar Recording'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW. Recording needed for webinar replays.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables recording for webinars by default.'
            ExpectedValues = @{ 'General' = 'Enabled' } }
        @{ Property = 'TownhallChatExperience'; Label = 'Townhall Chat'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DEFAULT. Optimized chat for large audiences.'
            MSRecommendation = 'DEFAULT: Optimized. MS uses optimized chat experience for town halls.'
            ExpectedValues = @{ 'General' = 'Optimized' } }
        @{ Property = 'TownhallEventAttendeeAccess'; Label = 'Townhall Attendee Access'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'Everyone for company-wide events accessible to external stakeholders.'
            MSRecommendation = 'DEFAULT: Everyone. MS allows all identity types to attend town halls.'
            ExpectedValues = @{ 'General' = 'Everyone' } }
        @{ Property = 'TownhallMaxResolution'; Label = 'Townhall Max Resolution'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: MicrosoftManaged. MS manages resolution based on network assessment.'
            ExpectedValues = @{ 'General' = 'MicrosoftManaged' } }
        @{ Property = 'TranscriptionForTownhall'; Label = 'Townhall Transcription'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW. Supports accessibility and multilingual workforce.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables transcription for town halls by default.'
            ExpectedValues = @{ 'General' = 'Enabled' } }
        @{ Property = 'TranscriptionForWebinar'; Label = 'Webinar Transcription'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW. Supports accessibility and content search.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables transcription for webinars by default.'
            ExpectedValues = @{ 'General' = 'Enabled' } }
        @{ Property = 'ExternalPresenterJoinVerification'; Label = 'External Presenter Verification'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP ENABLED. External presenters should verify identity.'
            MSRecommendation = 'DEFAULT: Enabled. MS requires external presenter verification by default.'
            ExpectedValues = @{ 'General' = 'Enabled' } }
        @{ Property = 'Registration'; Label = 'Event Registration'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'ALLOW.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables event registration by default.'
            ExpectedValues = @{ 'General' = 'Enabled' } }
    )

    # ==========================================================================
    # Enhanced Encryption Policy
    # ==========================================================================
    'Get-CsTeamsEnhancedEncryptionPolicy' = @(
        @{ Property = 'CallingEndtoEndEncryptionEnabledType'; Label = 'E2EE for Calls'; Slide = 0; Category = 'Security & Compliance'
            Recommendation   = 'ALLOW user override for Restricted tier. E2EE for sensitive 1:1 calls.'
            MSRecommendation = 'DEFAULT: Disabled. MS disables E2EE for calls by default. Enabling disables some features.'
            ExpectedValues = @{ 'General' = 'Disabled'; 'Restricted' = 'DisabledUserOverride' } }
        @{ Property = 'MeetingEndToEndEncryption'; Label = 'E2EE for Meetings'; Slide = 0; Category = 'Security & Compliance'
            Recommendation   = 'ALLOW user override for Restricted tier. E2EE for sensitive meetings.'
            MSRecommendation = 'DEFAULT: Disabled. MS disables E2EE for meetings by default. Enabling disables recording and some features.'
            ExpectedValues = @{ 'General' = 'Disabled'; 'Restricted' = 'DisabledUserOverride' } }
    )

    # ==========================================================================
    # AI Policy
    # ==========================================================================
    'Get-CsTeamsAIPolicy' = @(
        @{ Property = 'EnrollFace'; Label = 'Enroll Face'; Slide = 0; Category = 'Security & Compliance'
            Recommendation   = 'ALLOW user override. Enables face recognition for meeting features.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables face enrollment by default.'
            ExpectedValues = @{ 'General' = 'Enabled'; 'Restricted' = 'Disabled' } }
        @{ Property = 'EnrollVoice'; Label = 'Enroll Voice'; Slide = 0; Category = 'Security & Compliance'
            Recommendation   = 'ALLOW user override. Enables voice recognition for speaker attribution.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables voice enrollment by default.'
            ExpectedValues = @{ 'General' = 'Enabled'; 'Restricted' = 'Disabled' } }
        @{ Property = 'SpeakerAttributionForBYOD'; Label = 'Speaker Attribution BYOD'; Slide = 0; Category = 'Security & Compliance'
            Recommendation   = 'ALLOW. Improves transcript accuracy for BYOD users.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables speaker attribution for BYOD by default.'
            ExpectedValues = @{ 'General' = 'Enabled' } }
        @{ Property = 'PassiveVoiceEnrollment'; Label = 'Passive Voice Enrollment'; Slide = 0; Category = 'Security & Compliance'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables passive voice enrollment by default.'
            ExpectedValues = @{ 'General' = 'Enabled' } }
    )

    # ==========================================================================
    # Voicemail Policy
    # ==========================================================================
    'Get-CsOnlineVoicemailPolicy' = @(
        @{ Property = 'EnableTranscription'; Label = 'Voicemail Transcription'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ENABLE. Transcriptions help users quickly review voicemail without listening.'
            MSRecommendation = 'DEFAULT: True. MS enables voicemail transcription by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'ShareData'; Label = 'Share Voicemail Data'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP DEFAULT. Allows MS to improve transcription quality.'
            MSRecommendation = 'DEFAULT: Defer. MS defers to tenant-level data sharing preference.'
            ExpectedValues = @{ 'General' = 'Defer' } }
        @{ Property = 'EnableTranscriptionProfanityMasking'; Label = 'Profanity Masking'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ENABLE. Professional environment should mask profanity.'
            MSRecommendation = 'DEFAULT: False. MS does not mask profanity in voicemail transcription by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'EnableEditingCallAnswerRulesSetting'; Label = 'Edit Call Answer Rules'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ALLOW. Users should manage their own voicemail routing.'
            MSRecommendation = 'DEFAULT: True. MS allows users to edit call answer rules by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'EnableTranscriptionTranslation'; Label = 'Transcription Translation'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ENABLE. Valuable for multilingual workforce.'
            MSRecommendation = 'DEFAULT: True. MS enables voicemail transcription translation by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'MaximumRecordingLength'; Label = 'Max Voicemail Length'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP DEFAULT 5 minutes.'
            MSRecommendation = 'DEFAULT: 00:05:00. MS sets 5-minute max voicemail recording by default.'
            ExpectedValues = @{ 'General' = '00:05:00' } }
        @{ Property = 'PreamblePostambleMandatory'; Label = 'Mandatory Preamble/Postamble'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP DISABLED.'
            MSRecommendation = 'DEFAULT: False. MS does not require preamble/postamble audio by default.'
            ExpectedValues = @{ 'General' = 'False' } }
    )

    # ==========================================================================
    # Client Configuration
    # ==========================================================================
    'Get-CsTeamsClientConfiguration' = @(
        @{ Property = 'AllowEmailIntoChannel'; Label = 'Email to Channel'; Slide = 0; Category = 'Devices & Client'
            Recommendation   = 'ALLOW. Enables forwarding emails to Teams channels for collaboration.'
            MSRecommendation = 'DEFAULT: True. MS enables email-to-channel by default.'
            ExpectedValues = @{ '_Global' = 'True' } }
        @{ Property = 'AllowDropBox'; Label = 'Dropbox Integration'; Slide = 0; Category = 'Devices & Client'
            Recommendation   = 'BLOCK. Use OneDrive/SharePoint for file storage. Third-party cloud storage poses data residency risks.'
            MSRecommendation = 'DEFAULT: True. MS enables Dropbox integration by default.'
            ExpectedValues = @{ '_Global' = 'False' } }
        @{ Property = 'AllowBox'; Label = 'Box Integration'; Slide = 0; Category = 'Devices & Client'
            Recommendation   = 'BLOCK. Same rationale as Dropbox.'
            MSRecommendation = 'DEFAULT: True. MS enables Box integration by default.'
            ExpectedValues = @{ '_Global' = 'False' } }
        @{ Property = 'AllowGoogleDrive'; Label = 'Google Drive Integration'; Slide = 0; Category = 'Devices & Client'
            Recommendation   = 'BLOCK. Same rationale as Dropbox.'
            MSRecommendation = 'DEFAULT: True. MS enables Google Drive integration by default.'
            ExpectedValues = @{ '_Global' = 'False' } }
        @{ Property = 'AllowShareFile'; Label = 'Citrix ShareFile'; Slide = 0; Category = 'Devices & Client'
            Recommendation   = 'BLOCK. Same rationale as Dropbox.'
            MSRecommendation = 'DEFAULT: True. MS enables ShareFile integration by default.'
            ExpectedValues = @{ '_Global' = 'False' } }
        @{ Property = 'AllowEgnyte'; Label = 'Egnyte Integration'; Slide = 0; Category = 'Devices & Client'
            Recommendation   = 'BLOCK. Same rationale as Dropbox.'
            MSRecommendation = 'DEFAULT: True. MS enables Egnyte integration by default.'
            ExpectedValues = @{ '_Global' = 'False' } }
        @{ Property = 'AllowOrganizationTab'; Label = 'Organization Tab'; Slide = 0; Category = 'Devices & Client'
            Recommendation   = 'ALLOW. Org chart helps users find colleagues across departments and sites.'
            MSRecommendation = 'DEFAULT: True. MS enables the Organization tab by default.'
            ExpectedValues = @{ '_Global' = 'True' } }
        @{ Property = 'AllowGuestUser'; Label = 'Allow Guest Users'; Slide = 10; Category = 'Devices & Client'
            Recommendation   = 'ALLOW. Guest access essential for external collaboration.'
            MSRecommendation = 'DEFAULT: True. MS enables guest user access by default.'
            ExpectedValues = @{ '_Global' = 'True' } }
        @{ Property = 'AllowScopedPeopleSearchandAccess'; Label = 'Scoped People Search'; Slide = 0; Category = 'Devices & Client'
            Recommendation   = 'KEEP DISABLED. Information barriers not needed for most organizations.'
            MSRecommendation = 'DEFAULT: False. MS disables scoped directory search by default. Enable for information barrier scenarios.'
            ExpectedValues = @{ '_Global' = 'False' } }
        @{ Property = 'AllowResourceAccountSendMessage'; Label = 'Resource Account Messages'; Slide = 0; Category = 'Devices & Client'; Risk = 'High'
            Recommendation   = 'ALLOW. Needed for auto-attendant and call queue notifications.'
            MSRecommendation = 'DEFAULT: True. MS allows resource account messaging by default.'
            ExpectedValues = @{ '_Global' = 'True' } }
        @{ Property = 'AllowRoleBasedChatPermissions'; Label = 'Role-Based Chat Permissions'; Slide = 0; Category = 'Devices & Client'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: False. MS disables role-based chat permissions by default.'
            ExpectedValues = @{ '_Global' = 'False' } }
        @{ Property = 'AllowSkypeBusinessInterop'; Label = 'Skype for Business Interop'; Slide = 0; Category = 'Devices & Client'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: True. MS enables SfB interop by default.'
            ExpectedValues = @{ '_Global' = 'True' } }
        @{ Property = 'ContentPin'; Label = 'Content Pin Mode'; Slide = 0; Category = 'Devices & Client'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: RequiredOutsideScheduleMeeting. MS requires PIN for content access outside scheduled meetings.'
            ExpectedValues = @{ '_Global' = 'RequiredOutsideScheduleMeeting' } }
        @{ Property = 'ResourceAccountContentAccess'; Label = 'Resource Account Content'; Slide = 0; Category = 'Devices & Client'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: NoAccess. MS gives resource accounts no content access by default.'
            ExpectedValues = @{ '_Global' = 'NoAccess' } }
        @{ Property = 'UseUnifiedDomain'; Label = 'Unified Domain'; Slide = 0; Category = 'Devices & Client'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: MicrosoftDefault. MS controls unified domain rollout.'
            ExpectedValues = @{ '_Global' = 'MicrosoftDefault' } }
    )

    # ==========================================================================
    # Mobility Policy
    # ==========================================================================
    'Get-CsTeamsMobilityPolicy' = @(
        @{ Property = 'IPVideoMobileMode'; Label = 'Mobile Video'; Slide = 0; Category = 'Devices & Client'
            Recommendation   = 'ALLOW. Mobile video essential for frontline workers and remote collaboration.'
            MSRecommendation = 'DEFAULT: AllNetworks. MS enables mobile video on all networks by default.'
            ExpectedValues = @{ 'General' = 'AllNetworks' } }
        @{ Property = 'IPAudioMobileMode'; Label = 'Mobile Audio'; Slide = 0; Category = 'Devices & Client'
            Recommendation   = 'ALLOW. Core calling on mobile.'
            MSRecommendation = 'DEFAULT: AllNetworks. MS enables mobile audio on all networks by default.'
            ExpectedValues = @{ 'General' = 'AllNetworks' } }
        @{ Property = 'MobileDialerPreference'; Label = 'Mobile Dialer Preference'; Slide = 0; Category = 'Devices & Client'
            Recommendation   = 'KEEP DEFAULT. Let users choose their preferred dialer.'
            MSRecommendation = 'DEFAULT: Teams. MS defaults to Teams as the mobile dialer.'
            ExpectedValues = @{ 'General' = 'Teams' } }
        @{ Property = 'LinksInTeams'; Label = 'Links in Teams Mobile'; Slide = 0; Category = 'Devices & Client'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: OfferBrowserOptions. MS shows browser choice options in Teams Mobile.'
            ExpectedValues = @{ 'General' = 'OfferBrowserOptions' } }
    )

    # ==========================================================================
    # IP Phone Policy
    # ==========================================================================
    'Get-CsTeamsIPPhonePolicy' = @(
        @{ Property = 'SignInMode'; Label = 'Phone Sign-In Mode'; Slide = 0; Category = 'Devices & Client'; Risk = 'Medium'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: UserSignIn. MS defaults to user sign-in mode for IP phones.'
            ExpectedValues = @{ 'General' = 'UserSignIn' } }
        @{ Property = 'AllowHomeScreen'; Label = 'Home Screen'; Slide = 0; Category = 'Devices & Client'
            Recommendation   = 'ALLOW.'
            MSRecommendation = 'DEFAULT: EnabledUserOverride. Users can configure their phone home screen.'
            ExpectedValues = @{ 'General' = 'EnabledUserOverride' } }
        @{ Property = 'AllowBetterTogether'; Label = 'Better Together'; Slide = 0; Category = 'Devices & Client'
            Recommendation   = 'ENABLE. Pairs desk phone with PC Teams client for better experience.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables Better Together pairing by default.'
            ExpectedValues = @{ 'General' = 'Enabled' } }
        @{ Property = 'AllowHotDesking'; Label = 'Hot Desking'; Slide = 0; Category = 'Devices & Client'
            Recommendation   = 'KEEP ENABLED. Supports shared workspaces and kiosk devices.'
            MSRecommendation = 'DEFAULT: True. MS enables hot desking by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'HotDeskingIdleTimeoutInMinutes'; Label = 'Hot Desking Idle Timeout'; Slide = 0; Category = 'Devices & Client'
            Recommendation   = 'KEEP DEFAULT 5 minutes.'
            MSRecommendation = 'DEFAULT: 5. MS logs out hot-desking users after 5 minutes idle.'
            ExpectedValues = @{ 'General' = '5' } }
        @{ Property = 'SearchOnCommonAreaPhoneMode'; Label = 'CAP Search Mode'; Slide = 0; Category = 'Devices & Client'; Risk = 'Medium'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables contact search on common area phones.'
            ExpectedValues = @{ 'General' = 'Enabled' } }
    )

    # ==========================================================================
    # VDI Policy
    # ==========================================================================
    'Get-CsTeamsVdiPolicy' = @(
        @{ Property = 'DisableCallsAndMeetings'; Label = 'Disable Calls/Meetings VDI'; Slide = 0; Category = 'Devices & Client'
            Recommendation   = 'KEEP DISABLED. VDI users should have full calling/meeting capabilities.'
            MSRecommendation = 'DEFAULT: False. MS enables calls and meetings in VDI by default.'
            ExpectedValues = @{ 'General' = 'False' } }
        @{ Property = 'DisableAudioVideoInCallsAndMeetings'; Label = 'Disable A/V in VDI'; Slide = 0; Category = 'Devices & Client'
            Recommendation   = 'KEEP DISABLED. VDI users need audio/video.'
            MSRecommendation = 'DEFAULT: False. MS enables audio/video in VDI by default.'
            ExpectedValues = @{ 'General' = 'False' } }
        @{ Property = 'VDI2Optimization'; Label = 'VDI 2.0 Optimization'; Slide = 0; Category = 'Devices & Client'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables VDI 2.0 optimization by default.'
            ExpectedValues = @{ 'General' = 'Enabled' } }
    )

    # ==========================================================================
    # Feedback Policy
    # ==========================================================================
    'Get-CsTeamsFeedbackPolicy' = @(
        @{ Property = 'UserInitiatedMode'; Label = 'User Feedback Mode'; Slide = 0; Category = 'Teams & Channels'
            Recommendation   = 'ALLOW. User feedback helps improve Teams experience.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables user-initiated feedback by default.'
            ExpectedValues = @{ 'General' = 'Enabled' } }
        @{ Property = 'ReceiveSurveysMode'; Label = 'Receive Surveys'; Slide = 0; Category = 'Teams & Channels'
            Recommendation   = 'ALLOW. Surveys help MS improve Teams.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables survey prompts by default.'
            ExpectedValues = @{ 'General' = 'Enabled' } }
        @{ Property = 'AllowScreenshotCollection'; Label = 'Screenshot Collection'; Slide = 0; Category = 'Teams & Channels'
            Recommendation   = 'BLOCK. Prevent accidental sharing of sensitive screen content with MS.'
            MSRecommendation = 'DEFAULT: False. MS disables screenshot collection in feedback by default.'
            ExpectedValues = @{ 'General' = 'False' } }
        @{ Property = 'AllowEmailCollection'; Label = 'Email Collection'; Slide = 0; Category = 'Teams & Channels'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: False. MS disables email collection in feedback by default.'
            ExpectedValues = @{ 'General' = 'False' } }
        @{ Property = 'AllowLogCollection'; Label = 'Log Collection'; Slide = 0; Category = 'Teams & Channels'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: False. MS disables log collection in feedback by default.'
            ExpectedValues = @{ 'General' = 'False' } }
        @{ Property = 'EnableFeatureSuggestions'; Label = 'Feature Suggestions'; Slide = 0; Category = 'Teams & Channels'
            Recommendation   = 'ALLOW.'
            MSRecommendation = 'DEFAULT: True. MS enables feature suggestion prompts by default.'
            ExpectedValues = @{ 'General' = 'True' } }
    )

    # ==========================================================================
    # Update Management Policy
    # ==========================================================================
    'Get-CsTeamsUpdateManagementPolicy' = @(
        @{ Property = 'AllowManagedUpdates'; Label = 'Managed Updates'; Slide = 0; Category = 'Teams & Channels'
            Recommendation   = 'ENABLE. IT should control Teams client update rollout.'
            MSRecommendation = 'DEFAULT: False. MS does not enable managed updates by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'AllowPreview'; Label = 'Preview Updates'; Slide = 0; Category = 'Teams & Channels'
            Recommendation   = 'BLOCK for General. Allow for IT only.'
            MSRecommendation = 'DEFAULT: False. MS disables preview updates by default.'
            ExpectedValues = @{ 'General' = 'False'; 'IT-Department' = 'True' } }
        @{ Property = 'AllowPublicPreview'; Label = 'Public Preview'; Slide = 0; Category = 'Teams & Channels'
            Recommendation   = 'BLOCK for General. Allow for IT for early testing.'
            MSRecommendation = 'DEFAULT: FollowOfficePreview. MS follows Office preview settings by default.'
            ExpectedValues = @{ 'General' = 'Disabled'; 'IT-Department' = 'FollowOfficePreview' } }
        @{ Property = 'UseNewTeamsClient'; Label = 'Use New Teams Client'; Slide = 0; Category = 'Teams & Channels'
            Recommendation   = 'ENABLE. New Teams client is mandatory going forward.'
            MSRecommendation = 'DEFAULT: MicrosoftChoice. MS controls rollout by default.'
            ExpectedValues = @{ 'General' = 'MicrosoftChoice' } }
        @{ Property = 'BlockLegacyAuthorization'; Label = 'Block Legacy Auth'; Slide = 0; Category = 'Teams & Channels'
            Recommendation   = 'ENABLE. Block legacy auth for security.'
            MSRecommendation = 'DEFAULT: False. MS does not block legacy authorization by default.'
            ExpectedValues = @{ 'General' = 'True' } }
    )

    # ==========================================================================
    # Upgrade Policy
    # ==========================================================================
    'Get-CsTeamsUpgradePolicy' = @(
        @{ Property = 'Mode'; Label = 'Upgrade Mode'; Slide = 0; Category = 'Teams & Channels'
            Recommendation   = 'TeamsOnly. Organizations should target TeamsOnly mode.'
            MSRecommendation = 'DEFAULT: TeamsOnly. MS defaults to TeamsOnly for cloud-native tenants.'
            ExpectedValues = @{ 'General' = 'TeamsOnly' } }
        @{ Property = 'NotifySfbUsers'; Label = 'Notify SfB Users'; Slide = 0; Category = 'Teams & Channels'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: False. MS does not notify SfB users by default in TeamsOnly mode.'
            ExpectedValues = @{ 'General' = 'False' } }
    )

    # ==========================================================================
    # Files Policy
    # ==========================================================================
    'Get-CsTeamsFilesPolicy' = @(
        @{ Property = 'NativeFileEntryPoints'; Label = 'Native File Entry Points'; Slide = 0; Category = 'Teams & Channels'
            Recommendation   = 'ENABLE. Allows native file browsing in Teams.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables native file entry points by default.'
            ExpectedValues = @{ 'General' = 'Enabled' } }
        @{ Property = 'SPChannelFilesTab'; Label = 'SharePoint Channel Files'; Slide = 0; Category = 'Teams & Channels'
            Recommendation   = 'ENABLE. SharePoint integration for channel files.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables SharePoint channel files tab by default.'
            ExpectedValues = @{ 'General' = 'Enabled' } }
        @{ Property = 'FileSharingInChatswithExternalUsers'; Label = 'File Sharing External Chats'; Slide = 0; Category = 'Teams & Channels'
            Recommendation   = 'BLOCK. Prevent file sharing with external users in chat.'
            MSRecommendation = 'DEFAULT: Disabled. MS disables file sharing in chats with external users.'
            ExpectedValues = @{ 'General' = 'Disabled' } }
    )

    # ==========================================================================
    # Compliance Recording Policy
    # ==========================================================================
    'Get-CsTeamsComplianceRecordingPolicy' = @(
        @{ Property = 'Enabled'; Label = 'Compliance Recording'; Slide = 0; Category = 'Security & Compliance'
            Recommendation   = 'KEEP DISABLED unless regulatory requirement. Enable for specific compliance scenarios.'
            MSRecommendation = 'DEFAULT: False. MS disables compliance recording by default. Requires a certified recording partner.'
            ExpectedValues = @{ 'General' = 'False' } }
        @{ Property = 'WarnUserOnRemoval'; Label = 'Warn on Recording Removal'; Slide = 0; Category = 'Security & Compliance'
            Recommendation   = 'ENABLE if compliance recording is active.'
            MSRecommendation = 'DEFAULT: True. MS warns users when compliance recording is removed.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'CustomPromptsEnabled'; Label = 'Custom Prompts'; Slide = 0; Category = 'Security & Compliance'
            Recommendation   = 'KEEP DISABLED.'
            MSRecommendation = 'DEFAULT: False. MS disables compliance recording custom prompts by default.'
            ExpectedValues = @{ 'General' = 'False' } }
        @{ Property = 'DisableComplianceRecordingAudioNotificationForCalls'; Label = 'Disable Recording Audio Notification'; Slide = 0; Category = 'Security & Compliance'
            Recommendation   = 'KEEP DISABLED. Users should hear recording notifications.'
            MSRecommendation = 'DEFAULT: False. MS plays audio notification for compliance-recorded calls.'
            ExpectedValues = @{ 'General' = 'False' } }
        @{ Property = 'RecordReroutedCalls'; Label = 'Record Rerouted Calls'; Slide = 0; Category = 'Security & Compliance'
            Recommendation   = 'KEEP DISABLED unless compliance requires it.'
            MSRecommendation = 'DEFAULT: False. MS does not record rerouted calls by default.'
            ExpectedValues = @{ 'General' = 'False' } }
    )

    # ==========================================================================
    # Work Location Detection
    # ==========================================================================
    'Get-CsTeamsWorkLocationDetectionPolicy' = @(
        @{ Property = 'EnableWorkLocationDetection'; Label = 'Work Location Detection'; Slide = 0; Category = 'Security & Compliance'
            Recommendation   = 'ENABLE. Helps with hybrid work tracking across offices.'
            MSRecommendation = 'DEFAULT: False. MS disables work location detection by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'UserSettingsDefault'; Label = 'Work Location User Settings'; Slide = 0; Category = 'Security & Compliance'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Disabled. MS disables user work location settings by default.'
            ExpectedValues = @{ 'General' = 'Disabled' } }
    )

    # ==========================================================================
    # Media Logging Policy
    # ==========================================================================
    'Get-CsTeamsMediaLoggingPolicy' = @(
        @{ Property = 'AllowMediaLogging'; Label = 'Media Logging'; Slide = 0; Category = 'Security & Compliance'
            Recommendation   = 'ENABLE. Helps IT diagnose call quality issues.'
            MSRecommendation = 'DEFAULT: Disabled. MS disables media logging in the Global policy by default.'
            ExpectedValues = @{ 'General' = 'Enabled' } }
    )

    # ==========================================================================
    # Recording RollOut Policy
    # ==========================================================================
    'Get-CsTeamsRecordingRollOutPolicy' = @(
        @{ Property = 'MeetingRecordingOwnership'; Label = 'Recording Ownership'; Slide = 0; Category = 'Security & Compliance'
            Recommendation   = 'MeetingOrganizer. Organizer should own recordings.'
            MSRecommendation = 'DEFAULT: MeetingOrganizer. MS assigns recording ownership to the meeting organizer.'
            ExpectedValues = @{ 'General' = 'MeetingOrganizer' } }
    )

    # ==========================================================================
    # Call Park Policy
    # ==========================================================================
    'Get-CsTeamsCallParkPolicy' = @(
        @{ Property = 'AllowCallPark'; Label = 'Call Park'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ALLOW. Call park useful for reception and shared phone environments.'
            MSRecommendation = 'DEFAULT: True. MS enables call park by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'ParkTimeoutSeconds'; Label = 'Park Timeout (seconds)'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP DEFAULT 300 seconds.'
            MSRecommendation = 'DEFAULT: 300. MS sets 5-minute timeout for parked calls.'
            ExpectedValues = @{ 'General' = '300' } }
        @{ Property = 'PickupRangeStart'; Label = 'Park Pickup Range Start'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: 10. MS starts call park pickup codes at 10.'
            ExpectedValues = @{ 'General' = '10' } }
        @{ Property = 'PickupRangeEnd'; Label = 'Park Pickup Range End'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: 99. MS ends call park pickup codes at 99.'
            ExpectedValues = @{ 'General' = '99' } }
    )

    # ==========================================================================
    # Notification & Feeds Policy
    # ==========================================================================
    'Get-CsTeamsNotificationAndFeedsPolicy' = @(
        @{ Property = 'SuggestedFeedsEnabledType'; Label = 'Suggested Feeds'; Slide = 0; Category = 'Teams & Channels'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: EnabledUserOverride. Users can control suggested feeds.'
            ExpectedValues = @{ 'General' = 'EnabledUserOverride' } }
        @{ Property = 'TrendingFeedsEnabledType'; Label = 'Trending Feeds'; Slide = 0; Category = 'Teams & Channels'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: EnabledUserOverride. Users can control trending feeds.'
            ExpectedValues = @{ 'General' = 'EnabledUserOverride' } }
    )

    # ==========================================================================
    # Network Roaming Policy
    # ==========================================================================
    'Get-CsTeamsNetworkRoamingPolicy' = @(
        @{ Property = 'AllowIPVideo'; Label = 'Video on Roaming'; Slide = 0; Category = 'Devices & Client'
            Recommendation   = 'ALLOW. Video should work on all networks.'
            MSRecommendation = 'DEFAULT: True. MS enables IP video for roaming users by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'MediaBitRateKb'; Label = 'Media Bitrate (Kb)'; Slide = 0; Category = 'Devices & Client'
            Recommendation   = 'KEEP DEFAULT 50000 Kb/s.'
            MSRecommendation = 'DEFAULT: 50000. MS sets 50 Mbps max media bitrate by default.'
            ExpectedValues = @{ 'General' = '50000' } }
    )

    # ==========================================================================
    # Cortana Policy
    # ==========================================================================
    'Get-CsTeamsCortanaPolicy' = @(
        @{ Property = 'CortanaVoiceInvocationMode'; Label = 'Cortana Voice'; Slide = 0; Category = 'Apps & Permissions'
            Recommendation   = 'KEEP DEFAULT. Cortana voice invocation available for hands-free scenarios.'
            MSRecommendation = 'DEFAULT: WakeWordPushToTalkUserOverride. MS enables Cortana with wake word and push-to-talk by default.'
            ExpectedValues = @{ 'General' = 'WakeWordPushToTalkUserOverride' } }
        @{ Property = 'AllowCortanaVoiceInvocation'; Label = 'Cortana Voice Invocation'; Slide = 0; Category = 'Apps & Permissions'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: False. MS disables direct Cortana voice invocation by default.'
            ExpectedValues = @{ 'General' = 'False' } }
    )

    # ==========================================================================
    # Shifts Policies
    # ==========================================================================
    'Get-CsTeamsShiftsPolicy' = @(
        @{ Property = 'EnableScheduleOwnerPermissions'; Label = 'Schedule Owner Permissions'; Slide = 0; Category = 'Teams & Channels'
            Recommendation   = 'ENABLE. Shift managers need to manage schedules for production teams.'
            MSRecommendation = 'DEFAULT: False. MS disables schedule owner permissions by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'AccessType'; Label = 'Shifts Access Type'; Slide = 0; Category = 'Teams & Channels'
            Recommendation   = 'UnrestrictedAccess_TeamsApp for all users.'
            MSRecommendation = 'DEFAULT: UnrestrictedAccess_TeamsApp. MS allows unrestricted Shifts access by default.'
            ExpectedValues = @{ 'General' = 'UnrestrictedAccess_TeamsApp' } }
        @{ Property = 'AccessGracePeriodMinutes'; Label = 'Shifts Access Grace Period'; Slide = 0; Category = 'Teams & Channels'
            Recommendation   = 'KEEP DEFAULT 15 minutes.'
            MSRecommendation = 'DEFAULT: 15. MS allows 15-minute grace period for shift start/end.'
            ExpectedValues = @{ 'General' = '15' } }
        @{ Property = 'ShiftNoticeFrequency'; Label = 'Off-Shift Notice Frequency'; Slide = 0; Category = 'Teams & Channels'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Always. MS shows off-shift warning dialog every time.'
            ExpectedValues = @{ 'General' = 'Always' } }
        @{ Property = 'ShiftNoticeMessageType'; Label = 'Off-Shift Message Type'; Slide = 0; Category = 'Teams & Channels'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: DefaultMessage. MS uses the default off-shift warning message.'
            ExpectedValues = @{ 'General' = 'DefaultMessage' } }
    )

    'Get-CsTeamsShiftsAppPolicy' = @(
        @{ Property = 'AllowTimeClockLocationDetection'; Label = 'Time Clock Location'; Slide = 0; Category = 'Teams & Channels'
            Recommendation   = 'ENABLE. Important for sites to track clock-in location.'
            MSRecommendation = 'DEFAULT: False. MS disables time clock location detection by default.'
            ExpectedValues = @{ 'General' = 'True' } }
    )

    # ==========================================================================
    # Targeting Policy (Tags)
    # ==========================================================================
    'Get-CsTeamsTargetingPolicy' = @(
        @{ Property = 'CustomTagsMode'; Label = 'Custom Tags'; Slide = 0; Category = 'Teams & Channels'
            Recommendation   = 'ALLOW. Custom tags help organize teams across departments and sites.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables custom tags by default.'
            ExpectedValues = @{ 'General' = 'Enabled' } }
        @{ Property = 'ShiftBackedTagsMode'; Label = 'Shift-Backed Tags'; Slide = 0; Category = 'Teams & Channels'
            Recommendation   = 'ENABLE. Auto-generates tags from Shifts schedules for production teams.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables shift-backed tags by default.'
            ExpectedValues = @{ 'General' = 'Enabled' } }
        @{ Property = 'AutomaticTagsMode'; Label = 'Automatic Tags'; Slide = 0; Category = 'Teams & Channels'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables automatic tags by default.'
            ExpectedValues = @{ 'General' = 'Enabled' } }
        @{ Property = 'ManageTagsPermissionMode'; Label = 'Manage Tags Permission'; Slide = 0; Category = 'Teams & Channels'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: MicrosoftDefault. MS uses its own default for tag management permissions.'
            ExpectedValues = @{ 'General' = 'MicrosoftDefault' } }
        @{ Property = 'TeamOwnersEditWhoCanManageTagsMode'; Label = 'Team Owners Edit Tag Permissions'; Slide = 0; Category = 'Teams & Channels'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Enabled. MS lets team owners override tenant tag management settings.'
            ExpectedValues = @{ 'General' = 'Enabled' } }
    )

    # ==========================================================================
    # External Access Configuration
    # ==========================================================================
    'Get-CsTeamsExternalAccessConfiguration' = @(
        @{ Property = 'BlockExternalUserAccess'; Label = 'Block External Access'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'KEEP DISABLED. External access needed for customer/supplier collaboration.'
            MSRecommendation = 'DEFAULT: False. MS does not block external user access by default.'
            ExpectedValues = @{ '_Global' = 'False' } }
    )

    # ==========================================================================
    # ACS Federation
    # ==========================================================================
    'Get-CsTeamsAcsFederationConfiguration' = @(
        @{ Property = 'EnableAcsUsers'; Label = 'ACS Users'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'KEEP DISABLED unless specific ACS integration needed.'
            MSRecommendation = 'DEFAULT: False. MS disables Azure Communication Services federation by default.'
            ExpectedValues = @{ '_Global' = 'False' } }
        @{ Property = 'RequireAcsFederationForMeeting'; Label = 'Require ACS for Meetings'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'KEEP DISABLED.'
            MSRecommendation = 'DEFAULT: False. MS does not require ACS federation for meetings.'
            ExpectedValues = @{ '_Global' = 'False' } }
        @{ Property = 'HideBannerForAllowedAcsUsers'; Label = 'Hide ACS Banner'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: False. MS shows the ACS user banner by default.'
            ExpectedValues = @{ '_Global' = 'False' } }
        @{ Property = 'LabelForAllowedAcsUsers'; Label = 'ACS User Label'; Slide = 10; Category = 'External & Guests'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: False. MS does not label allowed ACS users by default.'
            ExpectedValues = @{ '_Global' = 'False' } }
    )

    # ==========================================================================
    # Workload Policy
    # ==========================================================================
    'Get-CsTeamsWorkLoadPolicy' = @(
        @{ Property = 'AllowCalling'; Label = 'Allow Calling Workload'; Slide = 0; Category = 'Apps & Permissions'
            Recommendation   = 'ALLOW. Core calling feature.'
            MSRecommendation = 'DEFAULT: True. MS enables calling workload by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'AllowMeeting'; Label = 'Allow Meeting Workload'; Slide = 0; Category = 'Apps & Permissions'
            Recommendation   = 'ALLOW. Core meeting feature.'
            MSRecommendation = 'DEFAULT: True. MS enables meeting workload by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'AllowMessaging'; Label = 'Allow Messaging Workload'; Slide = 0; Category = 'Apps & Permissions'
            Recommendation   = 'ALLOW. Core messaging feature.'
            MSRecommendation = 'DEFAULT: True. MS enables messaging workload by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'AllowCallingPinned'; Label = 'Calling Pinned to Nav'; Slide = 0; Category = 'Apps & Permissions'
            Recommendation   = 'ALLOW.'
            MSRecommendation = 'DEFAULT: True. MS pins calling to the navigation bar by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'AllowMeetingPinned'; Label = 'Meetings Pinned to Nav'; Slide = 0; Category = 'Apps & Permissions'
            Recommendation   = 'ALLOW.'
            MSRecommendation = 'DEFAULT: True. MS pins meetings to the navigation bar by default.'
            ExpectedValues = @{ 'General' = 'True' } }
        @{ Property = 'AllowMessagingPinned'; Label = 'Messaging Pinned to Nav'; Slide = 0; Category = 'Apps & Permissions'
            Recommendation   = 'ALLOW.'
            MSRecommendation = 'DEFAULT: True. MS pins messaging to the navigation bar by default.'
            ExpectedValues = @{ 'General' = 'True' } }
    )

    # ==========================================================================
    # DEVICES & CLIENT
    # ==========================================================================
    'Get-CsTeamsMeetingConfiguration' = @(
        @{ Property = 'DisableAnonymousJoin'; Label = 'Disable Anonymous Join (Tenant)'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DISABLED. Anonymous join controlled per-policy, not tenant-wide.'
            MSRecommendation = 'DEFAULT: False. MS allows anonymous join at tenant level by default.'
            ExpectedValues = @{ '_Global' = 'False' } }
        @{ Property = 'ClientMediaPortRangeEnabled'; Label = 'Custom Media Port Ranges'; Slide = 0; Category = 'Devices & Client'
            Recommendation   = 'KEEP DISABLED unless QoS required.'
            MSRecommendation = 'DEFAULT: False. MS uses dynamic ports (1024-65535) by default.'
            ExpectedValues = @{ '_Global' = 'False' } }
        @{ Property = 'EnableQoS'; Label = 'QoS Marking'; Slide = 0; Category = 'Devices & Client'
            Recommendation   = 'ENABLE for better call quality across global offices.'
            MSRecommendation = 'DEFAULT: False. MS disables QoS marking by default.'
            ExpectedValues = @{ '_Global' = 'True' } }
        @{ Property = 'DisableAppInteractionForAnonymousUsers'; Label = 'Disable Apps for Anonymous'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DISABLED. Anonymous users can interact with meeting apps.'
            MSRecommendation = 'DEFAULT: False. MS allows anonymous app interaction by default.'
            ExpectedValues = @{ '_Global' = 'False' } }
        @{ Property = 'FeedbackSurveyForAnonymousUsers'; Label = 'Anonymous Feedback Survey'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Enabled. MS shows feedback surveys to anonymous participants.'
            ExpectedValues = @{ '_Global' = 'Enabled' } }
        @{ Property = 'LimitPresenterRolePermissions'; Label = 'Limit Presenter Permissions'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: False. MS does not limit presenter role permissions by default.'
            ExpectedValues = @{ '_Global' = 'False' } }
    )

    # ==========================================================================
    # SECURITY & COMPLIANCE
    # ==========================================================================
    'Get-CsTeamsMessagingConfiguration' = @(
        @{ Property = 'ContentBasedPhishingCheck'; Label = 'Phishing Detection'; Slide = 0; Category = 'Security & Compliance'
            Recommendation   = 'KEEP ENABLED. Critical security feature.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables content-based phishing detection in Teams messages.'
            ExpectedValues = @{ '_Global' = 'Enabled' } }
        @{ Property = 'CustomEmojis'; Label = 'Custom Emojis (Tenant)'; Slide = 7; Category = 'Messaging Policies'
            Recommendation   = 'KEEP ENABLED.'
            MSRecommendation = 'DEFAULT: True. MS enables custom emojis and reactions tenant-wide.'
            ExpectedValues = @{ '_Global' = 'True' } }
        @{ Property = 'EnableInOrganizationChatControl'; Label = 'In-Org Chat Control (Tenant)'; Slide = 7; Category = 'Messaging Policies'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: False. MS does not enable in-organization chat control at tenant level by default.'
            ExpectedValues = @{ '_Global' = 'False' } }
        @{ Property = 'EnableVideoMessageCaptions'; Label = 'Video Message Captions'; Slide = 7; Category = 'Messaging Policies'
            Recommendation   = 'KEEP ENABLED. Accessibility feature.'
            MSRecommendation = 'DEFAULT: True. MS enables closed captions for video clips by default.'
            ExpectedValues = @{ '_Global' = 'True' } }
        @{ Property = 'FileTypeCheck'; Label = 'File Type Detection'; Slide = 0; Category = 'Security & Compliance'
            Recommendation   = 'KEEP ENABLED. Critical security feature.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables weaponizable file type detection in Teams.'
            ExpectedValues = @{ '_Global' = 'Enabled' } }
        @{ Property = 'MessagingNotes'; Label = 'Messaging Notes (Copilot)'; Slide = 7; Category = 'Messaging Policies'
            Recommendation   = 'KEEP ENABLED.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables Copilot-powered messaging notes by default.'
            ExpectedValues = @{ '_Global' = 'Enabled' } }
        @{ Property = 'ReportIncorrectSecurityDetections'; Label = 'Report False Positives'; Slide = 0; Category = 'Security & Compliance'
            Recommendation   = 'KEEP ENABLED.'
            MSRecommendation = 'DEFAULT: Enabled. MS lets users report incorrect security detections.'
            ExpectedValues = @{ '_Global' = 'Enabled' } }
        @{ Property = 'Storyline'; Label = 'Storyline'; Slide = 7; Category = 'Messaging Policies'
            Recommendation   = 'KEEP ENABLED.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables Storyline feature by default.'
            ExpectedValues = @{ '_Global' = 'Enabled' } }
        @{ Property = 'UrlReputationCheck'; Label = 'URL Reputation Check'; Slide = 0; Category = 'Security & Compliance'
            Recommendation   = 'KEEP ENABLED. Critical security feature.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables malicious URL detection in Teams messages.'
            ExpectedValues = @{ '_Global' = 'Enabled' } }
    )

    # ==========================================================================
    # CALLING & VOICE
    # ==========================================================================
    'Get-CsTeamsEmergencyCallingPolicy' = @(
        @{ Property = 'ExternalLocationLookupMode'; Label = 'External Location Lookup'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP DISABLED unless remote emergency addresses needed.'
            MSRecommendation = 'DEFAULT: Disabled. MS disables external location lookup for emergency calls.'
            ExpectedValues = @{ 'General' = 'Disabled' } }
        @{ Property = 'NotificationMode'; Label = 'Emergency Notification Mode'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'CONFIGURE. Set appropriate notification for security desk.'
            MSRecommendation = 'DEFAULT: NotificationOnly. MS sends chat-only notification for emergency calls by default.'
            ExpectedValues = @{ 'General' = 'NotificationOnly' } }
    )

    # ==========================================================================
    # CALLING & VOICE
    # ==========================================================================
    'Get-CsTeamsAudioConferencingPolicy' = @(
        @{ Property = 'AllowTollFreeDialin'; Label = 'Toll-Free Dial-In'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ALLOW. Provides cost-free join option for meeting participants.'
            MSRecommendation = 'DEFAULT: True. MS allows toll-free dial-in by default.'
            ExpectedValues = @{ 'General' = 'True' } }
    )

    # ==========================================================================
    # CALLING & VOICE
    # ==========================================================================
    'Get-CsOnlineDialInConferencingTenantSettings' = @(
        @{ Property = 'EnableEntryExitNotifications'; Label = 'Entry/Exit Notifications'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP ENABLED.'
            MSRecommendation = 'DEFAULT: True. MS enables conference entry/exit notifications.'
            ExpectedValues = @{ '_Global' = 'True' } }
        @{ Property = 'EntryExitAnnouncementsType'; Label = 'Entry/Exit Announcement Type'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: ToneOnly. MS uses tones only (not recorded names) for entry/exit.'
            ExpectedValues = @{ '_Global' = 'ToneOnly' } }
        @{ Property = 'EnableNameRecording'; Label = 'Name Recording'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP ENABLED.'
            MSRecommendation = 'DEFAULT: True. MS enables name recording for conference participants.'
            ExpectedValues = @{ '_Global' = 'True' } }
        @{ Property = 'PinLength'; Label = 'Organizer PIN Length'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: 5. MS uses 5-digit PINs for meeting organizers.'
            ExpectedValues = @{ '_Global' = '5' } }
        @{ Property = 'MaskPstnNumbersType'; Label = 'Mask PSTN Numbers'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: MaskedForExternalUsers. MS masks PSTN numbers for external users only.'
            ExpectedValues = @{ '_Global' = 'MaskedForExternalUsers' } }
        @{ Property = 'AllowPSTNOnlyMeetingsByDefault'; Label = 'PSTN-Only Meetings'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP DISABLED.'
            MSRecommendation = 'DEFAULT: False. MS does not allow PSTN-only meetings by default.'
            ExpectedValues = @{ '_Global' = 'False' } }
        @{ Property = 'AutomaticallyMigrateUserMeetings'; Label = 'Auto-Migrate Meetings'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP ENABLED.'
            MSRecommendation = 'DEFAULT: True. MS auto-migrates meetings when conferencing settings change.'
            ExpectedValues = @{ '_Global' = 'True' } }
        @{ Property = 'AutomaticallySendEmailsToUsers'; Label = 'Auto-Send Emails'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP ENABLED.'
            MSRecommendation = 'DEFAULT: True. MS auto-sends emails when dial-in settings change.'
            ExpectedValues = @{ '_Global' = 'True' } }
        @{ Property = 'DynamicCallerIdMode'; Label = 'Dynamic Caller ID'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: MicrosoftDefault. MS manages dynamic caller ID by default.'
            ExpectedValues = @{ '_Global' = 'MicrosoftDefault' } }
    )

    # ==========================================================================
    # TEAMS & CHANNELS
    # ==========================================================================
    'Get-CsTeamsUpgradeConfiguration' = @(
        @{ Property = 'BlockLegacyAuthorization'; Label = 'Block Legacy Auth (Upgrade)'; Slide = 0; Category = 'Security & Compliance'
            Recommendation   = 'ENABLE. Block legacy auth for security.'
            MSRecommendation = 'DEFAULT: False. MS does not block legacy authorization by default.'
            ExpectedValues = @{ '_Global' = 'True' } }
        @{ Property = 'DownloadTeams'; Label = 'Auto-Download Teams'; Slide = 0; Category = 'Teams & Channels'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: True. MS auto-downloads Teams on Windows clients.'
            ExpectedValues = @{ '_Global' = 'True' } }
        @{ Property = 'SfBMeetingJoinUx'; Label = 'SfB Meeting Join UX'; Slide = 0; Category = 'Teams & Channels'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: NativeLimitedClient. MS uses native limited client for SfB meeting join.'
            ExpectedValues = @{ '_Global' = 'NativeLimitedClient' } }
    )

    # ==========================================================================
    # CALLING & VOICE
    # ==========================================================================
    'Get-CsTeamsVoiceApplicationsPolicy' = @(
        @{ Property = 'AllowAutoAttendantBusinessHoursGreetingChange'; Label = 'AA Business Hours Greeting'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ALLOW for authorized users managing auto-attendants.'
            MSRecommendation = 'DEFAULT: AuthorizedOnly. MS restricts to authorized users by default.'
            ExpectedValues = @{ 'General' = 'AuthorizedOnly' } }
        @{ Property = 'AllowAutoAttendantBusinessHoursRoutingChange'; Label = 'AA Business Hours Routing'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ALLOW for authorized users.'
            MSRecommendation = 'DEFAULT: AuthorizedOnly. MS restricts to authorized users by default.'
            ExpectedValues = @{ 'General' = 'AuthorizedOnly' } }
        @{ Property = 'AllowAutoAttendantAfterHoursGreetingChange'; Label = 'AA After Hours Greeting'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ALLOW for authorized users.'
            MSRecommendation = 'DEFAULT: AuthorizedOnly. MS restricts to authorized users by default.'
            ExpectedValues = @{ 'General' = 'AuthorizedOnly' } }
        @{ Property = 'AllowAutoAttendantAfterHoursRoutingChange'; Label = 'AA After Hours Routing'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ALLOW for authorized users.'
            MSRecommendation = 'DEFAULT: AuthorizedOnly. MS restricts to authorized users by default.'
            ExpectedValues = @{ 'General' = 'AuthorizedOnly' } }
        @{ Property = 'AllowAutoAttendantHolidayGreetingChange'; Label = 'AA Holiday Greeting'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ALLOW for authorized users.'
            MSRecommendation = 'DEFAULT: AuthorizedOnly. MS restricts to authorized users by default.'
            ExpectedValues = @{ 'General' = 'AuthorizedOnly' } }
        @{ Property = 'AllowAutoAttendantHolidayRoutingChange'; Label = 'AA Holiday Routing'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ALLOW for authorized users.'
            MSRecommendation = 'DEFAULT: AuthorizedOnly. MS restricts to authorized users by default.'
            ExpectedValues = @{ 'General' = 'AuthorizedOnly' } }
        @{ Property = 'AllowAutoAttendantHolidaysChange'; Label = 'AA Holidays Config'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ALLOW for authorized users.'
            MSRecommendation = 'DEFAULT: AuthorizedOnly. MS restricts to authorized users by default.'
            ExpectedValues = @{ 'General' = 'AuthorizedOnly' } }
        @{ Property = 'AllowAutoAttendantLanguageChange'; Label = 'AA Language'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ALLOW for authorized users.'
            MSRecommendation = 'DEFAULT: AuthorizedOnly. MS restricts to authorized users by default.'
            ExpectedValues = @{ 'General' = 'AuthorizedOnly' } }
        @{ Property = 'AllowAutoAttendantTimeZoneChange'; Label = 'AA Time Zone'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ALLOW for authorized users.'
            MSRecommendation = 'DEFAULT: AuthorizedOnly. MS restricts to authorized users by default.'
            ExpectedValues = @{ 'General' = 'AuthorizedOnly' } }
        @{ Property = 'AllowCallQueueAgentOptChange'; Label = 'CQ Agent Opt-In/Out'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ALLOW for authorized users.'
            MSRecommendation = 'DEFAULT: AuthorizedOnly. MS restricts to authorized users by default.'
            ExpectedValues = @{ 'General' = 'AuthorizedOnly' } }
        @{ Property = 'AllowCallQueueConferenceModeChange'; Label = 'CQ Conference Mode'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ALLOW for authorized users.'
            MSRecommendation = 'DEFAULT: AuthorizedOnly. MS restricts to authorized users by default.'
            ExpectedValues = @{ 'General' = 'AuthorizedOnly' } }
        @{ Property = 'AllowCallQueueLanguageChange'; Label = 'CQ Language'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ALLOW for authorized users.'
            MSRecommendation = 'DEFAULT: AuthorizedOnly. MS restricts to authorized users by default.'
            ExpectedValues = @{ 'General' = 'AuthorizedOnly' } }
        @{ Property = 'AllowCallQueueMembershipChange'; Label = 'CQ Membership'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ALLOW for authorized users.'
            MSRecommendation = 'DEFAULT: AuthorizedOnly. MS restricts to authorized users by default.'
            ExpectedValues = @{ 'General' = 'AuthorizedOnly' } }
        @{ Property = 'AllowCallQueueMusicOnHoldChange'; Label = 'CQ Music on Hold'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ALLOW for authorized users.'
            MSRecommendation = 'DEFAULT: AuthorizedOnly. MS restricts to authorized users by default.'
            ExpectedValues = @{ 'General' = 'AuthorizedOnly' } }
        @{ Property = 'AllowCallQueueNoAgentSharedVoicemailGreetingChange'; Label = 'CQ No Agent VM Greeting'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ALLOW for authorized users.'
            MSRecommendation = 'DEFAULT: AuthorizedOnly. MS restricts to authorized users by default.'
            ExpectedValues = @{ 'General' = 'AuthorizedOnly' } }
        @{ Property = 'AllowCallQueueNoAgentsRoutingChange'; Label = 'CQ No Agents Routing'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ALLOW for authorized users.'
            MSRecommendation = 'DEFAULT: AuthorizedOnly. MS restricts to authorized users by default.'
            ExpectedValues = @{ 'General' = 'AuthorizedOnly' } }
        @{ Property = 'AllowCallQueueOptOutChange'; Label = 'CQ Opt-Out Config'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ALLOW for authorized users.'
            MSRecommendation = 'DEFAULT: AuthorizedOnly. MS restricts to authorized users by default.'
            ExpectedValues = @{ 'General' = 'AuthorizedOnly' } }
        @{ Property = 'AllowCallQueueOverflowRoutingChange'; Label = 'CQ Overflow Routing'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ALLOW for authorized users.'
            MSRecommendation = 'DEFAULT: AuthorizedOnly. MS restricts to authorized users by default.'
            ExpectedValues = @{ 'General' = 'AuthorizedOnly' } }
        @{ Property = 'AllowCallQueueOverflowSharedVoicemailGreetingChange'; Label = 'CQ Overflow VM Greeting'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ALLOW for authorized users.'
            MSRecommendation = 'DEFAULT: AuthorizedOnly. MS restricts to authorized users by default.'
            ExpectedValues = @{ 'General' = 'AuthorizedOnly' } }
        @{ Property = 'AllowCallQueuePresenceBasedRoutingChange'; Label = 'CQ Presence Routing'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ALLOW for authorized users.'
            MSRecommendation = 'DEFAULT: AuthorizedOnly. MS restricts to authorized users by default.'
            ExpectedValues = @{ 'General' = 'AuthorizedOnly' } }
        @{ Property = 'AllowCallQueueRoutingMethodChange'; Label = 'CQ Routing Method'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ALLOW for authorized users.'
            MSRecommendation = 'DEFAULT: AuthorizedOnly. MS restricts to authorized users by default.'
            ExpectedValues = @{ 'General' = 'AuthorizedOnly' } }
        @{ Property = 'AllowCallQueueTimeoutRoutingChange'; Label = 'CQ Timeout Routing'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ALLOW for authorized users.'
            MSRecommendation = 'DEFAULT: AuthorizedOnly. MS restricts to authorized users by default.'
            ExpectedValues = @{ 'General' = 'AuthorizedOnly' } }
        @{ Property = 'AllowCallQueueTimeoutSharedVoicemailGreetingChange'; Label = 'CQ Timeout VM Greeting'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ALLOW for authorized users.'
            MSRecommendation = 'DEFAULT: AuthorizedOnly. MS restricts to authorized users by default.'
            ExpectedValues = @{ 'General' = 'AuthorizedOnly' } }
        @{ Property = 'AllowCallQueueWelcomeGreetingChange'; Label = 'CQ Welcome Greeting'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ALLOW for authorized users.'
            MSRecommendation = 'DEFAULT: AuthorizedOnly. MS restricts to authorized users by default.'
            ExpectedValues = @{ 'General' = 'AuthorizedOnly' } }
        @{ Property = 'CallQueueAgentMonitorMode'; Label = 'CQ Agent Monitor Mode'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Disabled. MS disables call queue agent monitoring by default.'
            ExpectedValues = @{ 'General' = 'Disabled' } }
        @{ Property = 'CallQueueAgentMonitorNotificationMode'; Label = 'CQ Monitor Notification'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Disabled. MS disables agent monitor notifications by default.'
            ExpectedValues = @{ 'General' = 'Disabled' } }
        @{ Property = 'HistoricalAgentMetricsPermission'; Label = 'Historical Agent Metrics'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ALLOW for authorized users.'
            MSRecommendation = 'DEFAULT: AuthorizedOnly. MS restricts historical agent metrics by default.'
            ExpectedValues = @{ 'General' = 'AuthorizedOnly' } }
        @{ Property = 'HistoricalAutoAttendantMetricsPermission'; Label = 'Historical AA Metrics'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ALLOW for authorized users.'
            MSRecommendation = 'DEFAULT: AuthorizedOnly. MS restricts historical AA metrics by default.'
            ExpectedValues = @{ 'General' = 'AuthorizedOnly' } }
        @{ Property = 'HistoricalCallQueueMetricsPermission'; Label = 'Historical CQ Metrics'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ALLOW for authorized users.'
            MSRecommendation = 'DEFAULT: AuthorizedOnly. MS restricts historical CQ metrics by default.'
            ExpectedValues = @{ 'General' = 'AuthorizedOnly' } }
        @{ Property = 'RealTimeAgentMetricsPermission'; Label = 'Real-Time Agent Metrics'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ALLOW for authorized users.'
            MSRecommendation = 'DEFAULT: AuthorizedOnly. MS restricts real-time agent metrics by default.'
            ExpectedValues = @{ 'General' = 'AuthorizedOnly' } }
        @{ Property = 'RealTimeAutoAttendantMetricsPermission'; Label = 'Real-Time AA Metrics'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ALLOW for authorized users.'
            MSRecommendation = 'DEFAULT: AuthorizedOnly. MS restricts real-time AA metrics by default.'
            ExpectedValues = @{ 'General' = 'AuthorizedOnly' } }
        @{ Property = 'RealTimeCallQueueMetricsPermission'; Label = 'Real-Time CQ Metrics'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'ALLOW for authorized users.'
            MSRecommendation = 'DEFAULT: AuthorizedOnly. MS restricts real-time CQ metrics by default.'
            ExpectedValues = @{ 'General' = 'AuthorizedOnly' } }
    )

    # ==========================================================================
    # CALLING & VOICE
    # ==========================================================================
    'Get-CsOnlineDialOutPolicy' = @(
        @{ Property = 'AllowPSTNConferencingDialOutType'; Label = 'PSTN Conference Dial-Out'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: InternationalAndDomestic. MS allows international and domestic dial-out.'
            ExpectedValues = @{ 'General' = 'InternationalAndDomestic' } }
        @{ Property = 'AllowPSTNOutboundCallingType'; Label = 'PSTN Outbound Calling'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: InternationalAndDomestic. MS allows international and domestic outbound calls.'
            ExpectedValues = @{ 'General' = 'InternationalAndDomestic' } }
    )

    # ==========================================================================
    # CALLING & VOICE
    # ==========================================================================
    'Get-CsOnlineDialinConferencingPolicy' = @(
        @{ Property = 'AllowService'; Label = 'Dial-In Conferencing Service'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP ENABLED.'
            MSRecommendation = 'DEFAULT: True. MS enables the dial-in conferencing service by default.'
            ExpectedValues = @{ 'General' = 'True' } }
    )

    # ==========================================================================
    # MEETING POLICIES
    # ==========================================================================
    'Get-CsTeamsMeetingBrandingPolicy' = @(
        @{ Property = 'EnableMeetingBackgroundImages'; Label = 'Meeting Background Images'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: False. MS disables custom meeting background images by default.'
            ExpectedValues = @{ 'General' = 'False' } }
        @{ Property = 'EnableMeetingOptionsThemeOverride'; Label = 'Meeting Theme Override'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: False. MS disables meeting options theme override by default.'
            ExpectedValues = @{ 'General' = 'False' } }
        @{ Property = 'EnableNdiAssuranceSlate'; Label = 'NDI Assurance Slate'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: False. MS disables NDI assurance slate by default.'
            ExpectedValues = @{ 'General' = 'False' } }
        @{ Property = 'RequireBackgroundEffect'; Label = 'Require Background Effect'; Slide = 6; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: False. MS does not require background effects by default.'
            ExpectedValues = @{ 'General' = 'False' } }
    )

    # ==========================================================================
    # CALLING & VOICE
    # ==========================================================================
    'Get-CsTeamsPersonalAttendantPolicy' = @(
        @{ Property = 'PersonalAttendant'; Label = 'Personal Attendant'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Disabled. MS disables personal attendant by default.'
            ExpectedValues = @{ 'General' = 'Disabled' } }
        @{ Property = 'AutomaticRecording'; Label = 'PA Auto Recording'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Disabled. MS disables automatic recording for personal attendant.'
            ExpectedValues = @{ 'General' = 'Disabled' } }
        @{ Property = 'AutomaticTranscription'; Label = 'PA Auto Transcription'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Disabled. MS disables automatic transcription for personal attendant.'
            ExpectedValues = @{ 'General' = 'Disabled' } }
        @{ Property = 'CalendarBookings'; Label = 'PA Calendar Bookings'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Disabled. MS disables calendar bookings for personal attendant.'
            ExpectedValues = @{ 'General' = 'Disabled' } }
        @{ Property = 'CallScreening'; Label = 'PA Call Screening'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Disabled. MS disables call screening for personal attendant.'
            ExpectedValues = @{ 'General' = 'Disabled' } }
        @{ Property = 'InboundFederatedCalls'; Label = 'PA Federated Calls'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Disabled. MS disables federated call handling for personal attendant.'
            ExpectedValues = @{ 'General' = 'Disabled' } }
        @{ Property = 'InboundInternalCalls'; Label = 'PA Internal Calls'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Disabled. MS disables internal call handling for personal attendant.'
            ExpectedValues = @{ 'General' = 'Disabled' } }
        @{ Property = 'InboundPSTNCalls'; Label = 'PA PSTN Calls'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Disabled. MS disables PSTN call handling for personal attendant.'
            ExpectedValues = @{ 'General' = 'Disabled' } }
    )

    # ==========================================================================
    # DEVICES & CLIENT
    # ==========================================================================
    'Get-CsTeamsBYODAndDesksPolicy' = @(
        @{ Property = 'DeviceDataCollection'; Label = 'BYOD Data Collection'; Slide = 0; Category = 'Devices & Client'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables device data collection for BYOD by default.'
            ExpectedValues = @{ 'General' = 'Enabled' } }
    )

    # ==========================================================================
    # DEVICES & CLIENT
    # ==========================================================================
    'Get-CsTeamsVideoInteropServicePolicy' = @(
        @{ Property = 'Enabled'; Label = 'VTC Interop Enabled'; Slide = 0; Category = 'Devices & Client'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: False. MS disables video teleconference interop by default.'
            ExpectedValues = @{ 'General' = 'False' } }
        @{ Property = 'ProviderName'; Label = 'VTC Provider'; Slide = 0; Category = 'Devices & Client'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: (empty). No VTC interop provider configured by default.'
            ExpectedValues = @{ 'General' = '' } }
    )

    # ==========================================================================
    # DEVICES & CLIENT
    # ==========================================================================
    'Get-CsTeamsRoomVideoTeleConferencingPolicy' = @(
        @{ Property = 'Enabled'; Label = 'Room VTC Enabled'; Slide = 0; Category = 'Devices & Client'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: False. MS disables room VTC by default.'
            ExpectedValues = @{ 'General' = 'False' } }
        @{ Property = 'PlaceExternalCalls'; Label = 'Room VTC External Calls'; Slide = 0; Category = 'Devices & Client'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: False. MS disables external VTC calls by default.'
            ExpectedValues = @{ 'General' = 'False' } }
        @{ Property = 'PlaceInternalCalls'; Label = 'Room VTC Internal Calls'; Slide = 0; Category = 'Devices & Client'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: False. MS disables internal VTC calls by default.'
            ExpectedValues = @{ 'General' = 'False' } }
        @{ Property = 'ReceiveExternalCalls'; Label = 'Room VTC Receive External'; Slide = 0; Category = 'Devices & Client'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: False. MS disables receiving external VTC calls by default.'
            ExpectedValues = @{ 'General' = 'False' } }
        @{ Property = 'ReceiveInternalCalls'; Label = 'Room VTC Receive Internal'; Slide = 0; Category = 'Devices & Client'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: False. MS disables receiving internal VTC calls by default.'
            ExpectedValues = @{ 'General' = 'False' } }
    )

    # ==========================================================================
    # SECURITY & COMPLIANCE
    # ==========================================================================
    'Get-CsTeamsMultiTenantOrganizationConfiguration' = @(
        @{ Property = 'CopilotFromHomeTenant'; Label = 'Copilot from Home Tenant'; Slide = 0; Category = 'Security & Compliance'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: False. MS disables cross-tenant Copilot access by default.'
            ExpectedValues = @{ '_Global' = 'False' } }
    )

    # ==========================================================================
    # CALLING & VOICE
    # ==========================================================================
    'Get-CsTeamsVirtualAppointmentsPolicy' = @(
        @{ Property = 'EnableSmsNotifications'; Label = 'Virtual Appointment SMS'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: True. MS enables SMS notifications for virtual appointments.'
            ExpectedValues = @{ 'General' = 'True' } }
    )

    # ==========================================================================
    # MEETING POLICIES
    # ==========================================================================
    'Get-CsTeamsMeetingBroadcastConfiguration' = @(
        @{ Property = 'AllowSdnProviderForBroadcastMeeting'; Label = 'SDN for Broadcast'; Slide = 0; Category = 'Meeting Policies'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: False. MS disables SDN provider for broadcast meetings by default.'
            ExpectedValues = @{ '_Global' = 'False' } }
    )

    # ==========================================================================
    # CALLING & VOICE
    # ==========================================================================
    'Get-CsTeamsEmergencyCallRoutingPolicy' = @(
        @{ Property = 'AllowEnhancedEmergencyServices'; Label = 'Enhanced Emergency Services'; Slide = 0; Category = 'Calling & Voice'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: False. MS disables enhanced emergency services by default.'
            ExpectedValues = @{ 'General' = 'False' } }
    )

    # ==========================================================================
    # DEVICES & CLIENT
    # ==========================================================================
    'Get-CsTeamsMediaConnectivityPolicy' = @(
        @{ Property = 'DirectConnection'; Label = 'Media Direct Connection'; Slide = 0; Category = 'Devices & Client'
            Recommendation   = 'KEEP DEFAULT.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables direct media connectivity by default.'
            ExpectedValues = @{ 'General' = 'Enabled' } }
    )

    'Get-CsTeamsSipDevicesConfiguration' = @(
        @{ Property = 'BulkSignIn'; Label = 'Bulk Sign-In'; Slide = 0; Category = 'Devices & Client'; Risk = 'Medium'
            Recommendation   = 'REVIEW. Controls bulk sign-in capability for SIP devices.'
            MSRecommendation = 'DEFAULT: Enabled. MS enables bulk sign-in by default for device provisioning.'
            ExpectedValues = @{ 'General' = 'Enabled' } }
    )
}
