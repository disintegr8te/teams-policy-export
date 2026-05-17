<#
    Friendly (human-readable) names for CmdletName.PropertyName pairs.
    Used by the Excel rework to label columns/rows in decision sheets.

    Covers all properties from key cmdlets:
        Get-CsTeamsMeetingPolicy, Get-CsTeamsMessagingPolicy,
        Get-CsTeamsCallingPolicy, Get-CsExternalAccessPolicy,
        Get-CsTeamsChannelsPolicy
    Plus labels already defined in ImportantPolicies.psd1.
#>
@{
    # ===========================================================================
    # Get-CsTeamsMeetingPolicy
    # ===========================================================================
    'Get-CsTeamsMeetingPolicy.AllowChannelMeetingScheduling'          = 'Channel meeting scheduling'
    'Get-CsTeamsMeetingPolicy.AllowMeetNow'                           = 'Meet Now in channels'
    'Get-CsTeamsMeetingPolicy.AllowPrivateMeetNow'                    = 'Private Meet Now'
    'Get-CsTeamsMeetingPolicy.MeetingChatEnabledType'                 = 'Meeting chat'
    'Get-CsTeamsMeetingPolicy.AllowExternalNonTrustedMeetingChat'     = 'Chat with untrusted external users'
    'Get-CsTeamsMeetingPolicy.CopyRestriction'                        = 'Copy restriction for meeting chat'
    'Get-CsTeamsMeetingPolicy.LiveCaptionsEnabledType'                = 'Live captions'
    'Get-CsTeamsMeetingPolicy.DesignatedPresenterRoleMode'            = 'Default presenter role'
    'Get-CsTeamsMeetingPolicy.AllowIPAudio'                           = 'IP audio in meetings'
    'Get-CsTeamsMeetingPolicy.AllowIPVideo'                           = 'IP video in meetings'
    'Get-CsTeamsMeetingPolicy.AllowEngagementReport'                  = 'Engagement report'
    'Get-CsTeamsMeetingPolicy.AllowTrackingInReport'                  = 'Attendee tracking in report'
    'Get-CsTeamsMeetingPolicy.IPAudioMode'                            = 'IP audio mode'
    'Get-CsTeamsMeetingPolicy.IPVideoMode'                            = 'IP video mode'
    'Get-CsTeamsMeetingPolicy.AllowAnonymousUsersToDialOut'           = 'Anonymous users can dial out'
    'Get-CsTeamsMeetingPolicy.AllowAnonymousUsersToStartMeeting'      = 'Anonymous users can start meeting'
    'Get-CsTeamsMeetingPolicy.AllowAnonymousUsersToJoinMeeting'       = 'Anonymous join'
    'Get-CsTeamsMeetingPolicy.BlockedAnonymousJoinClientTypes'        = 'Blocked anonymous join clients'
    'Get-CsTeamsMeetingPolicy.AllowedStreamingMediaInput'             = 'Allowed streaming media input'
    'Get-CsTeamsMeetingPolicy.ExplicitRecordingConsent'               = 'Explicit recording consent'
    'Get-CsTeamsMeetingPolicy.EnableRecordingAndTranscriptionCustomMessage' = 'Custom recording/transcription message'
    'Get-CsTeamsMeetingPolicy.RecordingAndTranscriptionCustomMessageIdentifier' = 'Recording custom message ID'
    'Get-CsTeamsMeetingPolicy.AllowLocalRecording'                    = 'Local recording'
    'Get-CsTeamsMeetingPolicy.AutoRecording'                          = 'Auto-recording'
    'Get-CsTeamsMeetingPolicy.ParticipantNameChange'                  = 'Participant name change'
    'Get-CsTeamsMeetingPolicy.AllowPrivateMeetingScheduling'          = 'Private meeting scheduling'
    'Get-CsTeamsMeetingPolicy.AutoAdmittedUsers'                      = 'Lobby bypass / auto-admit'
    'Get-CsTeamsMeetingPolicy.AllowCloudRecording'                    = 'Cloud recording'
    'Get-CsTeamsMeetingPolicy.SetRecordingAndTranscriptOwnership'     = 'Recording ownership'
    'Get-CsTeamsMeetingPolicy.AllowRecordingStorageOutsideRegion'     = 'Recording storage outside region'
    'Get-CsTeamsMeetingPolicy.RecordingStorageMode'                   = 'Recording storage location'
    'Get-CsTeamsMeetingPolicy.AllowOutlookAddIn'                      = 'Outlook add-in'
    'Get-CsTeamsMeetingPolicy.AllowPowerPointSharing'                 = 'PowerPoint sharing'
    'Get-CsTeamsMeetingPolicy.AllowParticipantGiveRequestControl'     = 'Participant give/request control'
    'Get-CsTeamsMeetingPolicy.AllowExternalParticipantGiveRequestControl' = 'External participant give/request control'
    'Get-CsTeamsMeetingPolicy.AllowSharedNotes'                       = 'Shared notes'
    'Get-CsTeamsMeetingPolicy.AllowWhiteboard'                        = 'Whiteboard'
    'Get-CsTeamsMeetingPolicy.AllowTranscription'                     = 'Transcription'
    'Get-CsTeamsMeetingPolicy.AllowNetworkConfigurationSettingsLookup' = 'Network config settings lookup'
    'Get-CsTeamsMeetingPolicy.MediaBitRateKb'                         = 'Media bitrate (Kbps)'
    'Get-CsTeamsMeetingPolicy.ScreenSharingMode'                      = 'Screen sharing mode'
    'Get-CsTeamsMeetingPolicy.AllowMultipleScreenshare'               = 'Multiple screen share'
    'Get-CsTeamsMeetingPolicy.VideoFiltersMode'                       = 'Video filters / backgrounds'
    'Get-CsTeamsMeetingPolicy.AllowPSTNUsersToBypassLobby'            = 'PSTN users bypass lobby'
    'Get-CsTeamsMeetingPolicy.AllowOrganizersToOverrideLobbySettings' = 'Organizers override lobby settings'
    'Get-CsTeamsMeetingPolicy.PreferredMeetingProviderForIslandsMode' = 'Preferred meeting provider (Islands)'
    'Get-CsTeamsMeetingPolicy.AllowNDIStreaming'                      = 'NDI streaming'
    'Get-CsTeamsMeetingPolicy.SpeakerAttributionMode'                 = 'Speaker attribution'
    'Get-CsTeamsMeetingPolicy.EnrollUserOverride'                     = 'Voice profile enrollment'
    'Get-CsTeamsMeetingPolicy.RoomAttributeUserOverride'              = 'Room attribute user override'
    'Get-CsTeamsMeetingPolicy.StreamingAttendeeMode'                  = 'Streaming attendee mode'
    'Get-CsTeamsMeetingPolicy.AttendeeIdentityMasking'                = 'Attendee identity masking'
    'Get-CsTeamsMeetingPolicy.AllowBreakoutRooms'                     = 'Breakout rooms'
    'Get-CsTeamsMeetingPolicy.TeamsCameraFarEndPTZMode'               = 'Far-end camera control (PTZ)'
    'Get-CsTeamsMeetingPolicy.AllowMeetingReactions'                  = 'Meeting reactions'
    'Get-CsTeamsMeetingPolicy.AllowMeetingRegistration'               = 'Meeting registration'
    'Get-CsTeamsMeetingPolicy.WhoCanRegister'                         = 'Who can register for meetings'
    'Get-CsTeamsMeetingPolicy.AllowScreenContentDigitization'         = 'Screen content digitization'
    'Get-CsTeamsMeetingPolicy.AllowCarbonSummary'                     = 'Carbon summary'
    'Get-CsTeamsMeetingPolicy.RoomPeopleNameUserOverride'             = 'Room people name override'
    'Get-CsTeamsMeetingPolicy.AllowMeetingCoach'                      = 'Meeting coach / speaker coach'
    'Get-CsTeamsMeetingPolicy.NewMeetingRecordingExpirationDays'      = 'Recording expiration (days)'
    'Get-CsTeamsMeetingPolicy.LiveStreamingMode'                      = 'Live streaming mode'
    'Get-CsTeamsMeetingPolicy.MeetingInviteLanguages'                 = 'Meeting invite languages'
    'Get-CsTeamsMeetingPolicy.ChannelRecordingDownload'               = 'Channel recording download'
    'Get-CsTeamsMeetingPolicy.AllowCartCaptionsScheduling'            = 'CART captions scheduling'
    'Get-CsTeamsMeetingPolicy.AllowTasksFromTranscript'               = 'Tasks from transcript'
    'Get-CsTeamsMeetingPolicy.InfoShownInReportMode'                  = 'Info shown in attendance report'
    'Get-CsTeamsMeetingPolicy.LiveInterpretationEnabledType'          = 'Live interpretation'
    'Get-CsTeamsMeetingPolicy.QnAEngagementMode'                      = 'Q&A in meetings'
    'Get-CsTeamsMeetingPolicy.AllowImmersiveView'                     = 'Immersive view (Together mode)'
    'Get-CsTeamsMeetingPolicy.AllowAvatarsInGallery'                  = 'Avatars in gallery'
    'Get-CsTeamsMeetingPolicy.AllowAnnotations'                       = 'Annotations on shared content'
    'Get-CsTeamsMeetingPolicy.AllowDocumentCollaboration'             = 'Document collaboration'
    'Get-CsTeamsMeetingPolicy.AllowWatermarkForScreenSharing'         = 'Watermark on screen sharing'
    'Get-CsTeamsMeetingPolicy.AllowWatermarkForCameraVideo'           = 'Watermark on camera video'
    'Get-CsTeamsMeetingPolicy.AllowWatermarkCustomizationForCameraVideo' = 'Custom watermark for camera'
    'Get-CsTeamsMeetingPolicy.WatermarkForCameraVideoOpacity'         = 'Camera watermark opacity'
    'Get-CsTeamsMeetingPolicy.WatermarkForCameraVideoPattern'         = 'Camera watermark pattern'
    'Get-CsTeamsMeetingPolicy.AllowWatermarkCustomizationForScreenSharing' = 'Custom watermark for screen share'
    'Get-CsTeamsMeetingPolicy.WatermarkForScreenSharingOpacity'       = 'Screen share watermark opacity'
    'Get-CsTeamsMeetingPolicy.WatermarkForScreenSharingPattern'       = 'Screen share watermark pattern'
    'Get-CsTeamsMeetingPolicy.WatermarkForAnonymousUsers'             = 'Watermark for anonymous users'
    'Get-CsTeamsMeetingPolicy.DetectSensitiveContentDuringScreenSharing' = 'Detect sensitive content in screen share'
    'Get-CsTeamsMeetingPolicy.AudibleRecordingNotification'           = 'Audible recording notification'
    'Get-CsTeamsMeetingPolicy.ConnectToMeetingControls'               = 'Connect to meeting controls'
    'Get-CsTeamsMeetingPolicy.Copilot'                                = 'Copilot in meetings'
    'Get-CsTeamsMeetingPolicy.AutomaticallyStartCopilot'              = 'Auto-start Copilot'
    'Get-CsTeamsMeetingPolicy.VoiceIsolation'                         = 'Voice isolation'
    'Get-CsTeamsMeetingPolicy.ExternalMeetingJoin'                    = 'Join external meetings'
    'Get-CsTeamsMeetingPolicy.ContentSharingInExternalMeetings'       = 'Content sharing in external meetings'
    'Get-CsTeamsMeetingPolicy.AllowedUsersForMeetingDetails'          = 'Who can see meeting details'
    'Get-CsTeamsMeetingPolicy.SmsNotifications'                       = 'SMS notifications for meetings'
    'Get-CsTeamsMeetingPolicy.CaptchaVerificationForMeetingJoin'      = 'CAPTCHA for meeting join'
    'Get-CsTeamsMeetingPolicy.UsersCanAdmitFromLobby'                 = 'Who can admit from lobby'
    'Get-CsTeamsMeetingPolicy.LobbyChat'                              = 'Lobby chat'
    'Get-CsTeamsMeetingPolicy.BackroomChat'                           = 'Backroom / green room chat'
    'Get-CsTeamsMeetingPolicy.AnonymousUserAuthenticationMethod'      = 'Anonymous user authentication'
    'Get-CsTeamsMeetingPolicy.NoiseSuppressionForDialInParticipants'  = 'Noise suppression for dial-in'
    'Get-CsTeamsMeetingPolicy.RealTimeText'                           = 'Real-time text'
    'Get-CsTeamsMeetingPolicy.AIInterpreter'                          = 'AI interpreter'
    'Get-CsTeamsMeetingPolicy.VoiceSimulationInInterpreter'           = 'Voice simulation in interpreter'
    'Get-CsTeamsMeetingPolicy.ParticipantSlideControl'                = 'Participant slide control'
    'Get-CsTeamsMeetingPolicy.PasscodeComplexity'                     = 'Meeting passcode complexity'

    # ===========================================================================
    # Get-CsTeamsMessagingPolicy
    # ===========================================================================
    'Get-CsTeamsMessagingPolicy.AllowUrlPreviews'                     = 'URL previews in chat'
    'Get-CsTeamsMessagingPolicy.AllowOwnerDeleteMessage'              = 'Owners can delete messages'
    'Get-CsTeamsMessagingPolicy.AllowUserEditMessage'                 = 'Edit sent messages'
    'Get-CsTeamsMessagingPolicy.AllowUserDeleteMessage'               = 'Delete sent messages'
    'Get-CsTeamsMessagingPolicy.UsersCanDeleteBotMessages'            = 'Delete bot messages'
    'Get-CsTeamsMessagingPolicy.AllowUserDeleteChat'                  = 'Delete entire chat'
    'Get-CsTeamsMessagingPolicy.AllowUserChat'                        = 'User chat'
    'Get-CsTeamsMessagingPolicy.AllowRemoveUser'                      = 'Remove user from chat'
    'Get-CsTeamsMessagingPolicy.AllowGiphy'                           = 'GIFs (Giphy)'
    'Get-CsTeamsMessagingPolicy.GiphyRatingType'                      = 'Giphy content rating'
    'Get-CsTeamsMessagingPolicy.AllowGiphyDisplay'                    = 'Giphy display in picker'
    'Get-CsTeamsMessagingPolicy.AllowPasteInternetImage'              = 'Paste internet images'
    'Get-CsTeamsMessagingPolicy.AllowMemes'                           = 'Memes'
    'Get-CsTeamsMessagingPolicy.AllowImmersiveReader'                 = 'Immersive reader'
    'Get-CsTeamsMessagingPolicy.AllowStickers'                        = 'Stickers'
    'Get-CsTeamsMessagingPolicy.AllowUserTranslation'                 = 'Message translation'
    'Get-CsTeamsMessagingPolicy.ReadReceiptsEnabledType'              = 'Read receipts'
    'Get-CsTeamsMessagingPolicy.AllowPriorityMessages'                = 'Urgent / priority messages'
    'Get-CsTeamsMessagingPolicy.AllowSmartReply'                      = 'Smart reply suggestions'
    'Get-CsTeamsMessagingPolicy.AllowSmartCompose'                    = 'Smart compose (text predictions)'
    'Get-CsTeamsMessagingPolicy.ChannelsInChatListEnabledType'        = 'Channels in chat list'
    'Get-CsTeamsMessagingPolicy.AudioMessageEnabledType'              = 'Audio messages'
    'Get-CsTeamsMessagingPolicy.ChatPermissionRole'                   = 'Chat permission role'
    'Get-CsTeamsMessagingPolicy.AllowFullChatPermissionUserToDeleteAnyMessage' = 'Full-permission user delete any message'
    'Get-CsTeamsMessagingPolicy.AllowFluidCollaborate'                = 'Loop components in chat'
    'Get-CsTeamsMessagingPolicy.AllowVideoMessages'                   = 'Video messages'
    'Get-CsTeamsMessagingPolicy.AllowCommunicationComplianceEndUserReporting' = 'Communication compliance reporting'
    'Get-CsTeamsMessagingPolicy.AllowChatWithGroup'                   = 'Group chat'
    'Get-CsTeamsMessagingPolicy.AllowSecurityEndUserReporting'        = 'Security end-user reporting'
    'Get-CsTeamsMessagingPolicy.InOrganizationChatControl'            = 'In-org chat control'
    'Get-CsTeamsMessagingPolicy.AllowGroupChatJoinLinks'              = 'Group chat join links'
    'Get-CsTeamsMessagingPolicy.CreateCustomEmojis'                   = 'Create custom emoji'
    'Get-CsTeamsMessagingPolicy.UseB2BInvitesToAddExternalUsers'      = 'B2B invites for external users'
    'Get-CsTeamsMessagingPolicy.AllowProactiveSummaries'              = 'Proactive chat summaries'
    'Get-CsTeamsMessagingPolicy.DeleteCustomEmojis'                   = 'Delete custom emoji'
    'Get-CsTeamsMessagingPolicy.AutoShareFilesInExternalChats'        = 'Auto-share files in external chats'
    'Get-CsTeamsMessagingPolicy.DesignerForBackgroundsAndImages'      = 'Designer for backgrounds/images'
    'Get-CsTeamsMessagingPolicy.AllowCustomGroupChatAvatars'          = 'Custom group chat avatars'

    # ===========================================================================
    # Get-CsTeamsCallingPolicy
    # ===========================================================================
    'Get-CsTeamsCallingPolicy.AllowPrivateCalling'                    = 'Private calling'
    'Get-CsTeamsCallingPolicy.AllowWebPSTNCalling'                    = 'Web PSTN calling'
    'Get-CsTeamsCallingPolicy.AllowSIPDevicesCalling'                 = 'SIP device calling'
    'Get-CsTeamsCallingPolicy.AllowVoicemail'                         = 'Voicemail'
    'Get-CsTeamsCallingPolicy.AllowCallGroups'                        = 'Call groups'
    'Get-CsTeamsCallingPolicy.AllowDelegation'                        = 'Call delegation'
    'Get-CsTeamsCallingPolicy.AllowCallForwardingToUser'              = 'Call forwarding to user'
    'Get-CsTeamsCallingPolicy.AllowCallForwardingToPhone'             = 'Call forwarding to phone'
    'Get-CsTeamsCallingPolicy.PreventTollBypass'                      = 'Prevent toll bypass'
    'Get-CsTeamsCallingPolicy.BusyOnBusyEnabledType'                  = 'Busy on busy'
    'Get-CsTeamsCallingPolicy.MusicOnHoldEnabledType'                  = 'Music on hold'
    'Get-CsTeamsCallingPolicy.AllowCloudRecordingForCalls'            = 'Cloud recording for calls'
    'Get-CsTeamsCallingPolicy.ExplicitRecordingConsent'               = 'Explicit recording consent'
    'Get-CsTeamsCallingPolicy.EnableRecordingAndTranscriptionCustomMessage' = 'Custom recording message'
    'Get-CsTeamsCallingPolicy.RecordingAndTranscriptionCustomMessageIdentifier' = 'Recording custom message ID'
    'Get-CsTeamsCallingPolicy.AllowTranscriptionForCalling'           = 'Transcription for calls'
    'Get-CsTeamsCallingPolicy.PopoutForIncomingPstnCalls'             = 'Pop-out for incoming PSTN calls'
    'Get-CsTeamsCallingPolicy.PopoutAppPathForIncomingPstnCalls'      = 'Pop-out app path for PSTN calls'
    'Get-CsTeamsCallingPolicy.LiveCaptionsEnabledTypeForCalling'      = 'Live captions for calls'
    'Get-CsTeamsCallingPolicy.AutoAnswerEnabledType'                   = 'Auto-answer'
    'Get-CsTeamsCallingPolicy.SpamFilteringEnabledType'                = 'Spam filtering'
    'Get-CsTeamsCallingPolicy.CallRecordingExpirationDays'            = 'Call recording expiration (days)'
    'Get-CsTeamsCallingPolicy.AllowCallRedirect'                      = 'Call redirect'
    'Get-CsTeamsCallingPolicy.InboundPstnCallRoutingTreatment'        = 'Inbound PSTN call routing'
    'Get-CsTeamsCallingPolicy.InboundFederatedCallRoutingTreatment'   = 'Inbound federated call routing'
    'Get-CsTeamsCallingPolicy.EnableWebPstnMediaBypass'               = 'Web PSTN media bypass'
    'Get-CsTeamsCallingPolicy.EnableSpendLimits'                      = 'Calling spend limits'
    'Get-CsTeamsCallingPolicy.CallingSpendUserLimit'                  = 'Calling spend user limit'
    'Get-CsTeamsCallingPolicy.Copilot'                                = 'Copilot in calls'
    'Get-CsTeamsCallingPolicy.ShowTeamsCallsInCallLog'                = 'Show Teams calls in call log'
    'Get-CsTeamsCallingPolicy.RealTimeText'                           = 'Real-time text in calls'
    'Get-CsTeamsCallingPolicy.AIInterpreter'                          = 'AI interpreter in calls'
    'Get-CsTeamsCallingPolicy.VoiceSimulationInInterpreter'           = 'Voice simulation in calls'
    'Get-CsTeamsCallingPolicy.ReportCall'                             = 'Report a call'

    # ===========================================================================
    # Get-CsExternalAccessPolicy
    # ===========================================================================
    'Get-CsExternalAccessPolicy.AllowedExternalDomains'               = 'Allowed external domains'
    'Get-CsExternalAccessPolicy.BlockedExternalDomains'               = 'Blocked external domains'
    'Get-CsExternalAccessPolicy.EnableFederationAccess'               = 'External access (federation)'
    'Get-CsExternalAccessPolicy.EnableXmppAccess'                     = 'XMPP access'
    'Get-CsExternalAccessPolicy.EnablePublicCloudAudioVideoAccess'    = 'Public cloud audio/video'
    'Get-CsExternalAccessPolicy.EnableTeamsSmsAccess'                 = 'Teams SMS access'
    'Get-CsExternalAccessPolicy.EnableOutsideAccess'                  = 'Outside access'
    'Get-CsExternalAccessPolicy.EnableAcsFederationAccess'            = 'ACS federation access'
    'Get-CsExternalAccessPolicy.EnableTeamsConsumerAccess'            = 'Teams consumer (personal) access'
    'Get-CsExternalAccessPolicy.EnableTeamsConsumerInbound'           = 'Teams consumer inbound'
    'Get-CsExternalAccessPolicy.RestrictTeamsConsumerAccessToExternalUserProfiles' = 'Restrict consumer access to external profiles'
    'Get-CsExternalAccessPolicy.FederatedBilateralChats'              = 'Federated bilateral chats'
    'Get-CsExternalAccessPolicy.CommunicationWithExternalOrgs'        = 'Communication with external orgs'

    # ===========================================================================
    # Get-CsTeamsChannelsPolicy
    # ===========================================================================
    'Get-CsTeamsChannelsPolicy.AllowOrgWideTeamCreation'              = 'Create org-wide teams'
    'Get-CsTeamsChannelsPolicy.EnablePrivateTeamDiscovery'            = 'Discover private teams'
    'Get-CsTeamsChannelsPolicy.AllowPrivateChannelCreation'           = 'Create private channels'
    'Get-CsTeamsChannelsPolicy.AllowSharedChannelCreation'            = 'Create shared channels'
    'Get-CsTeamsChannelsPolicy.AllowChannelSharingToExternalUser'     = 'Share channels with external users'
    'Get-CsTeamsChannelsPolicy.AllowUserToParticipateInExternalSharedChannel' = 'Join external shared channels'
    'Get-CsTeamsChannelsPolicy.ThreadedChannelCreation'               = 'Threaded channel creation'

    # ===========================================================================
    # Additional cmdlets from ImportantPolicies.psd1
    # ===========================================================================

    # Get-CsTeamsAppPermissionPolicy
    'Get-CsTeamsAppPermissionPolicy.DefaultCatalogAppsType'           = 'Microsoft apps permission'
    'Get-CsTeamsAppPermissionPolicy.GlobalCatalogAppsType'            = 'Third-party apps permission'
    'Get-CsTeamsAppPermissionPolicy.PrivateCatalogAppsType'           = 'Custom (LOB) apps permission'

    # Get-CsTeamsMeetingBroadcastPolicy
    'Get-CsTeamsMeetingBroadcastPolicy.AllowBroadcastScheduling'      = 'Live events scheduling'

    # Get-CsTeamsGuestCallingConfiguration
    'Get-CsTeamsGuestCallingConfiguration.AllowPrivateCalling'        = 'Guest private calling'

    # Get-CsTeamsGuestMeetingConfiguration
    'Get-CsTeamsGuestMeetingConfiguration.ScreenSharingMode'          = 'Guest screen sharing'
    'Get-CsTeamsGuestMeetingConfiguration.AllowIPVideo'               = 'Guest video in meetings'

    # Get-CsTeamsGuestMessagingConfiguration
    'Get-CsTeamsGuestMessagingConfiguration.AllowUserChat'            = 'Guest chat'
    'Get-CsTeamsGuestMessagingConfiguration.AllowUserDeleteChat'      = 'Guest delete chat'

    # Get-CsTeamsMessagingConfiguration
    'Get-CsTeamsMessagingConfiguration.Storyline'                     = 'Storyline feed'

    # ===========================================================================
    # Cmdlets in PolicyCategories but NOT in ImportantPolicies
    # ===========================================================================

    # Get-CsApplicationAccessPolicy
    'Get-CsApplicationAccessPolicy.AppIds'                           = 'Allowed application IDs'

    # Get-CsOnlineVoiceRoutingPolicy
    'Get-CsOnlineVoiceRoutingPolicy.OnlinePstnUsages'               = 'PSTN usages'
    'Get-CsOnlineVoiceRoutingPolicy.RouteType'                      = 'Voice route type'

    # Get-CsTeamsCallHoldPolicy
    'Get-CsTeamsCallHoldPolicy.AudioFileId'                         = 'Hold music audio file'
    'Get-CsTeamsCallHoldPolicy.StreamingSourceUrl'                  = 'Hold music streaming URL'
    'Get-CsTeamsCallHoldPolicy.StreamingSourceAuthType'             = 'Streaming auth type'

    # Get-CsTeamsSharedCallingRoutingPolicy
    'Get-CsTeamsSharedCallingRoutingPolicy.EmergencyNumbers'        = 'Shared calling emergency numbers'
    'Get-CsTeamsSharedCallingRoutingPolicy.ResourceAccount'         = 'Shared calling resource account'

    # Get-CsTeamsSurvivableBranchAppliancePolicy
    'Get-CsTeamsSurvivableBranchAppliancePolicy.BranchApplianceFqdns' = 'SBA appliance FQDNs'

    # Get-CsTeamsTemplatePermissionPolicy
    'Get-CsTeamsTemplatePermissionPolicy.HiddenTemplates'           = 'Hidden team templates'

    # Get-CsTeamsMeetingTemplatePermissionPolicy
    'Get-CsTeamsMeetingTemplatePermissionPolicy.HiddenMeetingTemplates' = 'Hidden meeting templates'

    # Get-CsTeamsEducationAssignmentsAppPolicy
    'Get-CsTeamsEducationAssignmentsAppPolicy.ParentDigestEnabledType' = 'Parent digest notifications'
    'Get-CsTeamsEducationAssignmentsAppPolicy.MakeCodeEnabledType'  = 'MakeCode integration'
    'Get-CsTeamsEducationAssignmentsAppPolicy.TurnItInEnabledType'  = 'Turnitin integration'
    'Get-CsTeamsEducationAssignmentsAppPolicy.TurnItInApiUrl'       = 'Turnitin API URL'
    'Get-CsTeamsEducationAssignmentsAppPolicy.TurnItInApiKey'       = 'Turnitin API key'

    # Get-CsTeamsSipDevicesConfiguration
    'Get-CsTeamsSipDevicesConfiguration.BulkSignIn'                 = 'SIP device bulk sign-in'

    # Get-CsTeamsRemoteLogCollectionConfiguration
    'Get-CsTeamsRemoteLogCollectionConfiguration.Devices'           = 'Remote log collection devices'

    # Get-CsOnlineAudioConferencingRoutingPolicy
    'Get-CsOnlineAudioConferencingRoutingPolicy.OnlinePstnUsages'   = 'Audio conferencing PSTN usages'
    'Get-CsOnlineAudioConferencingRoutingPolicy.RouteType'          = 'Audio conferencing route type'

    # Get-CsTenantNetworkConfiguration
    'Get-CsTenantNetworkConfiguration.NetworkRegions'               = 'Network regions'
    'Get-CsTenantNetworkConfiguration.NetworkSites'                 = 'Network sites'
    'Get-CsTenantNetworkConfiguration.Subnets'                      = 'Network subnets'
    'Get-CsTenantNetworkConfiguration.PostalCodes'                  = 'Network postal codes'

    # Get-CsTeamsTenantAbuseConfiguration
    'Get-CsTeamsTenantAbuseConfiguration.BlockedTenants'            = 'Blocked tenants (abuse)'
    'Get-CsTeamsTenantAbuseConfiguration.LowSeatLimit'              = 'Low seat limit threshold'
    'Get-CsTeamsTenantAbuseConfiguration.TrialTenantValidation'     = 'Trial tenant validation'
    'Get-CsTeamsTenantAbuseConfiguration.SkipValidation'            = 'Skip abuse validation'
    'Get-CsTeamsTenantAbuseConfiguration.CreateThreadThresholdPerSeat' = 'Thread creation limit per seat'
    'Get-CsTeamsTenantAbuseConfiguration.AddMemberThresholdPerSeat' = 'Member add limit per seat'
    'Get-CsTeamsTenantAbuseConfiguration.SendMessageThresholdPerSeat' = 'Message send limit per seat'
    'Get-CsTeamsTenantAbuseConfiguration.CreateThreadThresholdForTrialTenants' = 'Thread creation limit (trial)'
    'Get-CsTeamsTenantAbuseConfiguration.AddMemberThresholdForTrialTenants' = 'Member add limit (trial)'
    'Get-CsTeamsTenantAbuseConfiguration.SendMessageThresholdForTrialTenants' = 'Message send limit (trial)'
}
