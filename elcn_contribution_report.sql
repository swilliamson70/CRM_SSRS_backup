SELECT
/*
Report opens with Report Filtering Criteria for Designation > Designation Type and Contribtion
Then presents parameter block for parms
*/

	CRMAF_Filteredelcn_contributiondonor.createdby
  , CRMAF_Filteredelcn_contributiondonor.createdbyname
  , CRMAF_Filteredelcn_contributiondonor.createdbyyominame
  , CRMAF_Filteredelcn_contributiondonor.createdon
  , CRMAF_Filteredelcn_contributiondonor.createdonutc
  , CRMAF_Filteredelcn_contributiondonor.createdonbehalfby
  , CRMAF_Filteredelcn_contributiondonor.createdonbehalfbyname
  , CRMAF_Filteredelcn_contributiondonor.createdonbehalfbyyominame
  , CRMAF_Filteredelcn_contributiondonor.elcn_amount
  , CRMAF_Filteredelcn_contributiondonor.elcn_amount_base
  , CRMAF_Filteredelcn_contributiondonor.elcn_appealcommunicationactivityid
  , CRMAF_Filteredelcn_contributiondonor.elcn_appealcommunicationactivityidname
  , CRMAF_Filteredelcn_contributiondonor.elcn_associationtypeid
  , CRMAF_Filteredelcn_contributiondonor.elcn_associationtypeidname
  , CRMAF_Filteredelcn_contributiondonor.elcn_campaignid
  , CRMAF_Filteredelcn_contributiondonor.elcn_campaignidname
  , CRMAF_Filteredelcn_contributiondonor.elcn_capitalcampaignid
  , CRMAF_Filteredelcn_contributiondonor.elcn_capitalcampaignidname
  , CRMAF_Filteredelcn_contributiondonor.elcn_classyear
  , CRMAF_Filteredelcn_contributiondonor.elcn_constituenttypeid
  , CRMAF_Filteredelcn_contributiondonor.elcn_constituenttypeidname
  , CRMAF_Filteredelcn_contributiondonor.elcn_contribution
  , CRMAF_Filteredelcn_contributiondonor.elcn_contributiondonorid
  , CRMAF_Filteredelcn_contributiondonor.elcn_contributionname
  , CRMAF_Filteredelcn_contributiondonor.elcn_contributionnumber
  , CRMAF_Filteredelcn_contributiondonor.elcn_credit2
  , CRMAF_Filteredelcn_contributiondonor.elcn_credit2_base
  , CRMAF_Filteredelcn_contributiondonor.elcn_designation
  , CRMAF_Filteredelcn_contributiondonor.elcn_designationname
  , CRMAF_Filteredelcn_contributiondonor.elcn_matchcredit
  , CRMAF_Filteredelcn_contributiondonor.elcn_matchcredit_base
  , CRMAF_Filteredelcn_contributiondonor.elcn_matchexpectancyid
  , CRMAF_Filteredelcn_contributiondonor.elcn_matchexpectancyidname
  , CRMAF_Filteredelcn_contributiondonor.elcn_name
  , CRMAF_Filteredelcn_contributiondonor.elcn_organization
  , CRMAF_Filteredelcn_contributiondonor.elcn_organizationname
  , CRMAF_Filteredelcn_contributiondonor.elcn_organizationyominame
  , CRMAF_Filteredelcn_contributiondonor.elcn_person
  , CRMAF_Filteredelcn_contributiondonor.elcn_personname
  , CRMAF_Filteredelcn_contributiondonor.elcn_personyominame
  , CRMAF_Filteredelcn_contributiondonor.elcn_recognitioncredit
  , CRMAF_Filteredelcn_contributiondonor.elcn_recognitioncredit_base
  , CRMAF_Filteredelcn_contributiondonor.elcn_softcredit
  , CRMAF_Filteredelcn_contributiondonor.elcn_softcredit_base
  , CRMAF_Filteredelcn_contributiondonor.exchangerate
  , CRMAF_Filteredelcn_contributiondonor.importsequencenumber
  , CRMAF_Filteredelcn_contributiondonor.modifiedby
  , CRMAF_Filteredelcn_contributiondonor.modifiedbyname
  , CRMAF_Filteredelcn_contributiondonor.modifiedbyyominame
  , CRMAF_Filteredelcn_contributiondonor.modifiedon
  , CRMAF_Filteredelcn_contributiondonor.modifiedonutc
  , CRMAF_Filteredelcn_contributiondonor.modifiedonbehalfby
  , CRMAF_Filteredelcn_contributiondonor.modifiedonbehalfbyname
  , CRMAF_Filteredelcn_contributiondonor.modifiedonbehalfbyyominame
  , CRMAF_Filteredelcn_contributiondonor.overriddencreatedon
  , CRMAF_Filteredelcn_contributiondonor.overriddencreatedonutc
  , CRMAF_Filteredelcn_contributiondonor.ownerid
  , CRMAF_Filteredelcn_contributiondonor.owneriddsc
  , CRMAF_Filteredelcn_contributiondonor.owneridname
  , CRMAF_Filteredelcn_contributiondonor.owneridtype
  , CRMAF_Filteredelcn_contributiondonor.owneridyominame
  , CRMAF_Filteredelcn_contributiondonor.owningbusinessunit
  , CRMAF_Filteredelcn_contributiondonor.owningteam
  , CRMAF_Filteredelcn_contributiondonor.owninguser
  , CRMAF_Filteredelcn_contributiondonor.statuscode
  , CRMAF_Filteredelcn_contributiondonor.statuscodename
  , CRMAF_Filteredelcn_contributiondonor.timezoneruleversionnumber
  , CRMAF_Filteredelcn_contributiondonor.transactioncurrencyid
  , CRMAF_Filteredelcn_contributiondonor.transactioncurrencyidname
  , CRMAF_Filteredelcn_contributiondonor.utcconversiontimezonecode
  , CRMAF_Filteredelcn_contributiondonor.versionnumber
  , CRMAF_Filteredelcn_contributiondonor.crm_moneyformatstring
  , CRMAF_Filteredelcn_contributiondonor.crm_priceformatstring
  , Filteredelcn_contribution.elcn_contributionid
  , Filteredelcn_contribution.elcn_contributiontype
  , Filteredelcn_contribution.elcn_contributiontypename
  , Filteredelcn_contribution.elcn_contributionsessionid
  , Filteredelcn_contribution.elcn_contributionsessionidname
  , Filteredelcn_contribution.elcn_contributiondate
  , Filteredelcn_contribution.elcn_anonymitytypeid
  , Filteredelcn_contribution.elcn_anonymitytypeidname
  , Filteredelcn_anonymitytype.elcn_anonymityaction
  , Filteredelcn_anonymitytype.elcn_anonymityactionname
  , Filteredelcn_contribution.statecode     AS elcn_contribution_statecode
  , Filteredelcn_contribution.statecodename AS elcn_contribution_statecodename
  , Filteredelcn_contribution.createdbyname AS elcn_contribution_createdbyname
  , Filteredelcn_contributionsession.elcn_sessionnumber
  , Filteredelcn_designationtype.elcn_type                               AS elcn_designationtype
  , Filteredelcn_pledgestatus.elcn_name                                  AS elcn_pledgestatus_elcn_name
  , Filteredelcn_plannedgiftstatus.elcn_name                             AS elcn_plannedgiftstatus_elcn_name
  , Filteredelcn_recurringgiftstatus.elcn_name                           AS elcn_recurringgiftstatus_elcn_name
  , Filteredelcn_designation.elcn_sortname                               AS elcn_designation_elcn_sortname
  , ISNULL(FilteredContact.elcn_sortname, FilteredAccount.elcn_sortname) AS donor_sortname
  , Filteredelcn_contribution.elcn_contributioncategoryid
  , Filteredelcn_contribution.elcn_contributioncategoryidname
  , Filteredelcn_contributioncategory.elcn_contributioncategorygroupidname
  , Filteredelcn_contributioncategory.elcn_contributioncategorygroupid
  , Filteredelcn_contributionsession.elcn_overridefeeddateutc
FROM
	Filteredelcn_contributiondonor AS CRMAF_Filteredelcn_contributiondonor
	INNER JOIN
		Filteredelcn_contribution
		ON
			CRMAF_Filteredelcn_contributiondonor.elcn_contribution = Filteredelcn_contribution.elcn_contributionid
	LEFT OUTER JOIN
		Filteredelcn_contributionsession
		ON
			Filteredelcn_contribution.elcn_contributionsessionid = Filteredelcn_contributionsession.elcn_contributionsessionid
	LEFT OUTER JOIN
		Filteredelcn_anonymitytype
		ON
			Filteredelcn_contribution.elcn_anonymitytypeid = Filteredelcn_anonymitytype.elcn_anonymitytypeid
	LEFT OUTER JOIN
		Filteredelcn_pledgestatus
		ON
			Filteredelcn_contribution.elcn_pledgestatusid = Filteredelcn_pledgestatus.elcn_pledgestatusid
	LEFT OUTER JOIN
		Filteredelcn_plannedgiftstatus
		ON
			Filteredelcn_contribution.elcn_plannedgiftstatusid = Filteredelcn_plannedgiftstatus.elcn_plannedgiftstatusid
	LEFT OUTER JOIN
		Filteredelcn_recurringgiftstatus
		ON
			Filteredelcn_contribution.elcn_recurringgiftstatusid = Filteredelcn_recurringgiftstatus.elcn_recurringgiftstatusid
	INNER JOIN
		Filteredelcn_designation
		ON
			CRMAF_Filteredelcn_contributiondonor.elcn_designation = Filteredelcn_designation.elcn_designationid
	INNER JOIN
		Filteredelcn_contributioncategory
		ON
			Filteredelcn_contribution.elcn_contributioncategoryid = Filteredelcn_contributioncategory.elcn_contributioncategoryid
	LEFT OUTER JOIN
		Filteredelcn_designationtype
		ON
			Filteredelcn_designation.elcn_designationtype = Filteredelcn_designationtype.elcn_designationtypeid
	LEFT OUTER JOIN
		FilteredContact
		ON
			CRMAF_Filteredelcn_contributiondonor.elcn_person = FilteredContact.contactid
	LEFT OUTER JOIN
		FilteredAccount
		ON
			CRMAF_Filteredelcn_contributiondonor.elcn_organization = FilteredAccount.accountid
WHERE
	(
		Filteredelcn_contribution.statecode = 0
	)
	AND
	(
		Filteredelcn_anonymitytype.elcn_anonymityaction IS NULL
		OR Filteredelcn_anonymitytype.elcn_anonymityaction   <> 3
	)
	AND
	(
		Filteredelcn_contribution.elcn_contributiondate >= @StartDate
	)
	AND
	(
		Filteredelcn_contribution.elcn_contributiondate <= DATEADD(dd, 1, @EndDate)
	)
	AND
	(
		Filteredelcn_contribution.elcn_contributiontype IN (@ContributionType)
	)
	AND
	(
		Filteredelcn_contribution.elcn_contributioncategoryid IN (@ContributionCategory)
	)
	AND
	(
		Filteredelcn_contribution.elcn_plannedgiftstatusid     IS NULL
		OR @IncludeCanceledWrittenOff                                = 1
		OR @IncludeCanceledWrittenOff                                = 0
		AND Filteredelcn_plannedgiftstatus.elcn_iscanceledwrittenoff = 0
	)
	AND
	(
		Filteredelcn_contribution.elcn_pledgestatusid     IS NULL
		OR @IncludeCanceledWrittenOff                           = 1
		OR @IncludeCanceledWrittenOff                           = 0
		AND Filteredelcn_pledgestatus.elcn_iscanceledwrittenoff = 0
	)
	AND
	(
		Filteredelcn_contribution.elcn_recurringgiftstatusid     IS NULL
		OR @IncludeCanceledWrittenOff                                  = 1
		OR @IncludeCanceledWrittenOff                                  = 0
		AND Filteredelcn_recurringgiftstatus.elcn_iscanceledwrittenoff = 0
	)