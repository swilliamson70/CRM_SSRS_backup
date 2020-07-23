DECLARE 
	@p_StartDate date
	, @p_EndDate date
	, @p_stateList varchar(10) = 'B823CFDA-A383-E911-80D7-0A253F89019C'
	, @p_zipcodeList varchar(9) = '74464'
	, @p_county varchar(120)-- not found in CRM data entry in person, prospect pages
	, @p_cityname varchar(120) = 'Tah' -- dnu/ too expensive
	, @p_veteran varchar(1)-- not found in CRM data entry
	, @p_household_ind varchar(1) -- APRXREF_HOUSEHOLD_IND -- flag on xref rec linking people at same address
									-- at same address and other than married, why exclude?
									-- at same address and married/partnered then primary spouse only flag is same condition

	, @p_include_deceased varchar(1) = 'Y' -- y/n
	, @p_primary_spouse_only varchar(1) = 'N' -- y/n
	, @p_gift_capacity varchar(99)
	, @p_wealth_engine_des varchar(1)
	, @p_donor_cats varchar(99) -- aldc / alumni degree completion, alum - degreed slumna/us
	, @p_exclusion_codes varchar(3) -- ams, nak
	, @p_mail_codes varchar(99) -- ack - acknowledgements/reminders, acl -alumni/club chapter mailings
	, @p_special_purpose_types varchar(99) -- nsueg - nsu employee giving design, nsuin - nsu support interest
	, @p_special_purpose_groups varchar(99) -- acaff - academic affaris, admn - administration
	, @p_activities varchar(99) -- adplc - president's leadership class, 
	, @p_activity_years varchar(4) -- list of years
	, @p_leadership_roles varchar(99) -- stvlead
	, @p_academic_years varchar(4) -- list of years
	, @p_majors varchar(99) -- 0000 - undeclared, 1100 - business admin
	, @p_degrees varchar(99) -- a - associates, aa - associates in arts
	;

SELECT
	cb.contactid
	, CASE
		WHEN cb.elcn_dateofdeath IS NULL THEN 'N'
		ELSE 'Y'
	END DECEASED_IND
	, cb.elcn_dateofbirth DATE_OF_BIRTH
	, cb.elcn_PrimaryID pidm
	, cb.datatel_EnterpriseSystemId ID
	, cb.fullname Primary_Name
	, pfn.elcn_firstname PREF_FIRST_NAME
	, cb.lastname Last_Name
	, maiden.elcn_lastname MAIDEN_NAME
	, elcn_anonymitytypeBase.elcn_type anonymityType
	, cb.elcn_LargestContributionAmount Largest_Contribution_Amount
	, cb.elcn_LastContributionDate
	, cb.elcn_totalGiving Lifetime_Giving
	, cb.elcn_primaryconstituentaffiliationid
INTO
	#temp_const
FROM(
	SELECT 
		ContactBase.*
	FROM
		contactbase
	WHERE
		fullname not like '%DO%NOT%USE'
		AND (@p_include_deceased = 'Y' 
			OR elcn_dateofdeath is null)
		AND statuscode = 1
	) CB
	LEFT JOIN(
		SELECT TOP 1
			pnb.elcn_personid
			, pnb.elcn_firstname
		FROM 
			elcn_personnameBase pnb
		WHERE
			pnb.elcn_nametype = 'EBC22907-A5CB-4270-8947-C5381D1ECC54' /*Preferred First Name*/
			AND pnb.elcn_EndDate IS NULL
			AND pnb.statuscode = 1
		ORDER BY pnb.ModifiedOn
	) PFN ON cb.contactid = pfn.elcn_personid
	LEFT JOIN(
		SELECT TOP 1
			pnb.elcn_personid 
			, pnb.elcn_lastname
		FROM 
			elcn_personnameBase pnb
		WHERE 
			pnb.elcn_nametype = '29C69522-08C1-48E3-A030-F417A0E741C0' /*Maiden Name*/
			AND pnb.elcn_EndDate IS NULL
			AND pnb.statuscode = 1
		ORDER BY pnb.ModifiedOn 
	) MAIDEN ON cb.contactid = maiden.elcn_personid
	LEFT JOIN elcn_anonymitytypebase 
		ON cb.elcn_AnonymityTypeId = elcn_anonymitytypeBase.elcn_anonymitytypeId
;
CREATE NONCLUSTERED INDEX INDX_TMP_ID ON #temp_const (contactid);

SELECT 
	cpb.elcn_personId
	, CASE cpb.elcn_ContactRestrictionId 
		WHEN '8872A718-5472-40C4-82C7-DB72FC4CE5A6' THEN /*Exclude*/
			CASE cpb.elcn_ContactPreferenceTypeId 
				WHEN '112A7585-A2D9-E911-80D8-0A253F89019C' THEN /*Communications*/
					CASE cpb.elcn_MethodofContact 
						WHEN 344220001 THEN 'NPH' /*Phone*/ --	NPH - No Phone
						WHEN 344220000 THEN 'NMC' /*Letter*/ --	NMC - No Mail Contact
						WHEN 344220002 THEN 'NEM' /*Email*/ --	NEM - No E-mail
					END
				WHEN 'e4e02dc6-3314-e511-9431-005056804b43' THEN  /*Solicitations*/
					CASE cpb.elcn_MethodofContact 
						WHEN 344220006 THEN 'NDN' /*All*/ --	NDN - No Donation Solicitations
					END
				WHEN '76EA8AA5-2F36-4E8E-BFB2-490677DCF4B4' THEN /*Global Restriction*/
					CASE cpb.elcn_MethodofContact 
						WHEN 344220006 THEN 'NOC' /*All*/ --	NOC - No Contact
					END
				WHEN 'EE8CE7BD-9CB8-E911-80D8-0A253F89019C' THEN /*Alumni / Club Chapter Mailings*/
					CASE cpb.elcn_MethodofContact 
						WHEN 344220000 THEN 'NAM' /*Letter*/ --	NAM - No Alumni Association Mailings
					END
				WHEN 'DEE02DC6-3314-E511-9431-005056804B43' THEN /*Acknowledgements*/
					CASE cpb.elcn_MethodofContact 
						WHEN 344220000 THEN 'NAK' /*Letter*/	 --	NAK - No Acknowledgement Letters
					END
			END 
		WHEN '3E4E206F-9EB8-E911-80D8-0A253F89019C' THEN /*No Third Party Solicitataions*/
				'NTP' /*All*/ --	NTP - No Third Party Solicitations
	END AS EXCLUSION
INTO
	#temp_exclusions
FROM
	elcn_contactpreferenceBase CPB
WHERE 
	(cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
	AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/
;
CREATE NONCLUSTERED INDEX INDX_TMP_ID ON #temp_exclusions (elcn_personid);

SELECT
	e.elcn_PersonID,
	e.elcn_educationid,
	d.elcn_code DEGREE,
	d.elcn_Name AS Degree_Name,
	e.elcn_DegreeYear Degree_Year,
	(
		Select TOP 1 mb.elcn_name FROM elcn_education_elcn_majorBase emb
		INNER JOIN elcn_majorBase mb ON mb.elcn_majorId = emb.elcn_majorid
		Where emb.elcn_educationid = e.elcn_educationId
	) AS Major,
	ROW_NUMBER() OVER(PARTITION BY e.elcn_personId 
					ORDER BY e.elcn_DegreeYear DESC) AS RANK_NO
INTO 
	#temp_education
FROM 
	dbo.elcn_educationBase e
	JOIN elcn_degreeBase d on d.elcn_degreeId = e.elcn_DegreeId
WHERE e.statuscode = 1
;
CREATE NONCLUSTERED INDEX INDX_TMP_EDUCATION_RANKS ON #temp_education (elcn_personId);

SELECT 
	elcn_personid,
	CASE elcn_typeid 
		WHEN '1172C46B-462D-E411-9415-005056804B43' THEN 'CIFE'
		WHEN '0F72C46B-462D-E411-9415-005056804B43' THEN 'SIFE'
		WHEN '1B72C46B-462D-E411-9415-005056804B43' THEN 'SIFL'
		WHEN '89799F16-C4E8-4269-B409-5756998F193F' THEN 'CIFL'
		ELSE cast(elcn_typeid as varchar(40))
	END AS SALU_CODE,
	elcn_formattedname,
	elcn_locked, 
	modifiedon 
INTO
	#temp_aprsalu
FROM
	elcn_formattednamebase
WHERE
	elcn_typeid in ('1172C46B-462D-E411-9415-005056804B43', -- Joint Mailing Name (CIFE)
			    		'0F72C46B-462D-E411-9415-005056804B43', --Mailing Name (SIFE)
	     				'1B72C46B-462D-E411-9415-005056804B43', --Casual Salutation (SIFL)
		    			'89799F16-C4E8-4269-B409-5756998F193F') --Casual Joint Saluation (CIFL)
	AND (elcn_enddate >= SYSDATETIME() 
		OR elcn_enddate IS NULL)
;
CREATE NONCLUSTERED INDEX INDX_TMP_ID_SALU ON #temp_aprsalu (elcn_personId,salu_code);

SELECT DISTINCT  
	elcn_person personid,
	datepart(YYYY,elcn_ContributionDate)givingyear,
	datepart(YYYY,elcn_ContributionDate) -1 prevyear
INTO
	#temp_dontations
FROM
	elcn_contributiondonorBase 
;

SELECT elcn_personid, elcn_ratingtypeid, [Value], [Level], [Score]
INTO #temp_ratings
FROM(
	SELECT
		elcn_ratingBase.elcn_ratingDescription ,
		elcn_ratingBase.elcn_personid,
		elcn_ratingBase.elcn_ratingtypeid,
		elcn_ratingBase.elcn_ratingvalue
	FROM
		elcn_ratingBase
) T PIVOT
(	
	MAX(elcn_ratingvalue)
	FOR elcn_ratingDescription  IN
	([Value], [Level], [Score]) 
) PVT
;
CREATE NONCLUSTERED INDEX INDX_TMP_ID_RATINGTYPE ON #temp_ratings (elcn_personid, elcn_ratingtypeid);

SELECT
	elcn_PrimaryMemberPersonId, 
	elcn_membershipprogramlevelbase.elcn_name ,
	elcn_statusbase.elcn_name status,
	elcn_membershipBase.elcn_MembershipNumber , --7701
	CONVERT(DATE, elcn_membershipBase.elcn_ExpireDate) elcn_ExpireDate  -- null
INTO #temp_membership
FROM
	elcn_membershipBase
	JOIN elcn_membershipprogramlevelbase
		ON elcn_membershipBase.elcn_MembershipLevelId = elcn_membershipprogramlevelid
	JOIN elcn_statusbase
		ON elcn_membershipBase.elcn_MembershipStatusId  = elcn_statusid
;
CREATE NONCLUSTERED INDEX INDX_TMP_ID_MEMBERSHIP ON #temp_membership (elcn_primarymemberpersonid);

SELECT  
	elcn_personid,
	Preferred,
	Business,
	Personal,
	Other,
	Yellow,
	Alumni,
	NSU
INTO 
	#temp_email_slot
FROM(
	SELECT
		case elcn_typeid
			WHEN 'CC0141A1-A383-E911-80D7-0A253F89019C' THEN 'Business'
			WHEN 'CD0141A1-A383-E911-80D7-0A253F89019C' THEN 'Personal'
			WHEN '31292157-E075-4E85-9204-1CCEDEC9DBF9'	THEN 'Other'
			WHEN 'F523FC9B-5370-46F3-9242-263411E73043' THEN 'Yellow ' -- Waiting Authorization
			WHEN 'A4B7A0CC-0DFF-4069-8337-6571B94CA5BD'	THEN 'Alumni'
			WHEN '26E175F1-4286-4B7E-9CE9-F2E383D58EFD'	THEN 'NSU'
			ELSE 'Unknown'
		END AS emailtype,
		elcn_personid,
		elcn_email
	FROM
		elcn_emailaddressbase
	WHERE
		statuscode = 1
		AND	elcn_EmailAddressStatusId = '378DE114-EB09-E511-943C-0050568068B7' -- current
										-- 050FE7CB-5508-E511-943C-0050568068B7 -- past
	UNION ALL 
	SELECT
		'Preferred',
		elcn_personid,
		elcn_email
	FROM
		elcn_emailaddressbase
	WHERE
		statuscode =1 
		AND	elcn_EmailAddressStatusId = '378DE114-EB09-E511-943C-0050568068B7' -- current
		AND elcn_preferred = 1

)T PIVOT 
(	MAX(elcn_email)
	FOR emailtype 
	IN ([Preferred], [Business], [Personal], [Other], [Yellow], [Alumni], [NSU])
)PVT;

CREATE NONCLUSTERED INDEX INDX_TMP_ID ON #temp_email_slot (elcn_personid);

-->> Phone
SELECT
	elcn_personid, --guid 
	elcn_phonenumber, --phone number
	elcn_type,
	elcn_preferred -- 0/1
INTO #temp_phone
FROM(
	SELECT 
		elcn_personid
		, elcn_phonenumber
		, elcn_phonetypeBase.elcn_type
		, elcn_preferred
		, ROW_NUMBER() OVER (PARTITION BY elcn_personid, elcn_phonetypebase.elcn_type
								ORDER BY elcn_preferred DESC) RN
	FROM
		elcn_phonebase
		JOIN elcn_phonetypebase
			ON elcn_phonebase.elcn_phonetype = elcn_phonetypebase.elcn_phonetypeid  
			AND elcn_phonebase.elcn_phonestatusid = '378DE114-EB09-E511-943C-0050568068B7' -- Current
			AND elcn_phonebase.statuscode = 1
	) PHONES 
WHERE
	RN = 1 
CREATE NONCLUSTERED INDEX INDX_TMP_ID ON #temp_phone (elcn_personid);

with w_get_consec_years AS ( 
--anchor 
	select personid,
		givingyear,
		prevyear,
		1 consecyears
	from #temp_dontations
--recusive memeber
	union all
	select d.personid,
	d.givingyear,
	d.prevyear,
	cte.consecyears +1 consecyears
	from #temp_dontations d 
		inner join w_get_consec_years cte
			on cte.personid = d.personid
			and d.givingyear -1 = cte.givingyear
--termination
),
	w_get_longest_consec_years AS ( 
--anchor 
	select personid,
		givingyear,
		prevyear,
		1 consecyears
	from #temp_dontations
--recusive memeber
	union all
	select d.personid,
	d.givingyear,
	d.prevyear,
	cte.consecyears +1 consecyears
	from #temp_dontations d 
		inner join w_get_consec_years cte
			on cte.personid = d.personid
			and d.givingyear -1 = cte.givingyear
--termination
)

SELECT
	const.ContactId
	, const.deceased_ind 
	, const.date_of_birth 
	, const.pidm
	, const.id
	, const.Primary_Name
	, const.pref_first_name Preferred_First_Name
	, const.Last_Name
	, const.maiden_name
	, COALESCE(cife_salu.elcn_formattedname,sife_salu.elcn_formattedname) PREFERRED_FULL_W_SALUTATION
	, COALESCE(cifl_salu.elcn_formattedname,sifl_salu.elcn_formattedname) PREFERRED_SHORT_W_SALUTATION
	, sife_salu.elcn_formattedname SIFE
	, sifl_salu.elcn_formattedname SIFL
	, ctb.value	Primary_Constituent_Type -- PREF_DONOR_CATEGORY
	, ctb.elcn_type AS Primary_Constituent_Desc -- PREF_DONOR_CATEGORY_DESC
	, ab.elcn_street1 AS Street_Line1
	, ab.elcn_street2 AS Street_Line2
	, ab.elcn_City AS City
	, spb.elcn_Abbreviation as State_Province
	, ab.elcn_postalcode AS Postal_Code
	, ab.elcn_county	County
	, dcb.Datatel_name as Nation
	, atb.elcn_type AS Preferred_Address_Type --ADDRESS_TYPE


-- Exclusion categories in ATVEXCL
--	NPH - No Phone
	--, (CASE WHEN(
	--	SELECT COUNT(*) FROM elcn_contactpreferenceBase cpb
	--	WHERE cpb.elcn_ContactPreferenceTypeId = '112A7585-A2D9-E911-80D8-0A253F89019C' /*Communications*/
	--	AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6' /*Exclude*/
	--	AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
	--	AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/
	--	AND cpb.elcn_MethodofContact = 344220001 /*Phone*/
	--	AND cpb.elcn_personId = const.ContactId
	--	) > 0 THEN 'NPH' ELSE NULL END) AS NPH
	, exclusions.NPH
--	NOC - No Contact
	--, (CASE WHEN(
	--	SELECT COUNT(*) FROM elcn_contactpreferenceBase cpb
	--	WHERE cpb.elcn_ContactPreferenceTypeId = '76EA8AA5-2F36-4E8E-BFB2-490677DCF4B4' /*Global Restriction*/
	--	AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6' /*Exclude*/
	--	AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
	--	AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/
	--	AND cpb.elcn_MethodofContact = 344220006 /*All*/
	--	AND cpb.elcn_personId = const.ContactId
	--	) > 0 THEN 'NOC' ELSE NULL END) AS NOC
	, exclusions.NOC
--	NMC - No Mail Contact
	--, (CASE WHEN(
	--	SELECT COUNT(*) FROM elcn_contactpreferenceBase cpb
	--	WHERE cpb.elcn_ContactPreferenceTypeId = '112A7585-A2D9-E911-80D8-0A253F89019C' /*Communications*/
	--	AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6' /*Exclude*/
	--	AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
	--	AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/
	--	AND cpb.elcn_MethodofContact = 344220000 /*Letter*/
	--	AND cpb.elcn_personId = const.ContactId
	--	) > 0 THEN 'NMC' ELSE NULL END) AS NMC
	, exclusions.NMC
--	NEM - No E-mail
	--, (CASE WHEN(
	--	SELECT COUNT(*) FROM elcn_contactpreferenceBase cpb
	--	WHERE cpb.elcn_ContactPreferenceTypeId = '112A7585-A2D9-E911-80D8-0A253F89019C' /*Communications*/
	--	AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6' /*Exclude*/
	--	AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
	--	AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/
	--	AND cpb.elcn_MethodofContact = 344220002 /*Email*/
	--	AND cpb.elcn_personId = const.ContactId
	--	) > 0 THEN 'NEM' ELSE NULL END) AS NEM
	, exclusions.NEM		
--	NAM - No Alumni Association Mailings
	--, (CASE WHEN(
	--	SELECT COUNT(*) FROM elcn_contactpreferenceBase cpb
	--	WHERE cpb.elcn_ContactPreferenceTypeId = 'EE8CE7BD-9CB8-E911-80D8-0A253F89019C' /*Alumni / Club Chapter Mailings*/
	--	AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6' /*Exclude*/
	--	AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
	--	AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/
	--	AND cpb.elcn_MethodofContact = 344220000 /*Letter*/
	--	AND cpb.elcn_personId = const.ContactId
	--	) > 0 THEN 'NAM' ELSE NULL END) AS NAM
	, exclusions.NAM

--	NDN - No Donation Solicitations
	--, (CASE WHEN(
	--	SELECT COUNT(*) FROM elcn_contactpreferenceBase cpb
	--	WHERE cpb.elcn_ContactPreferenceTypeId = 'e4e02dc6-3314-e511-9431-005056804b43' /*Solicitations*/
	--	AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6' /*Exclude*/
	--	AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
	--	AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/
	--	AND cpb.elcn_MethodofContact = 344220006 /*All*/
	--	AND cpb.elcn_personId = const.ContactId
	--	) > 0 THEN 'NDN' ELSE NULL END) AS NDN
	, exclusions.NDN
--	NAK - No Acknowledgement Letters
	--, (CASE WHEN(
	--	SELECT COUNT(*) FROM elcn_contactpreferenceBase cpb
	--	WHERE cpb.elcn_ContactPreferenceTypeId = 'DEE02DC6-3314-E511-9431-005056804B43' /*Acknowledgements*/
	--	AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6' /*Exclude*/
	--	AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
	--	AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/
	--	AND cpb.elcn_MethodofContact = 344220000 /*Letter*/
	--	AND cpb.elcn_personId = const.ContactId
	--	) > 0 THEN 'NAK' ELSE NULL END) AS NAK
	, exclusions.NAK
--	NTP - No Third Party Solicitations
	--, (CASE WHEN(
	--	SELECT COUNT(*) FROM elcn_contactpreferenceBase cpb
	--	WHERE cpb.elcn_ContactPreferenceTypeId = 'e4e02dc6-3314-e511-9431-005056804b43' /*Solicitations*/
	--	AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6' /*Exclude*/
	--	AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
	--	AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/
	--	AND cpb.elcn_MethodofContact = 344220006 /*All*/
	--	AND cpb.elcn_personId = const.ContactId
	--	) > 0 THEN 'NTP' ELSE NULL END) AS NTP
	, exclusions.NTP
	, const.anonymityType Anonymity_Type

--->> RATINGS
	, jfsg_est_cap.value JFSG_Estimated_Capacity
	, ratings1.rating_type RATING_TYPE1
	, ratings1.rating_score RATING_AMOUNT1
	, ratings1.rating_value RATING1
	, ratings1.rating_level RATING_LEVEL1
	, ratings2.rating_type RATING_TYPE2
	, ratings2.rating_score RATING_AMOUNT2
	, ratings2.rating_value RATING2
	, ratings2.rating_level RATING_LEVEL2
	, null RATING_TYPE3
	, null RATING_AMOUNT3
	, null RATING3
	, null RATING_LEVEL3

	, (
		SELECT
			COUNT(elcn_RecognitionCredit)
		FROM
			elcn_contributiondonorBase
			JOIN elcn_contribution  
				ON elcn_contributiondonorBase.elcn_contribution = elcn_contribution.elcn_contributionId
		WHERE
			elcn_contributiondonorBase.elcn_person = const.ContactId
			AND elcn_contribution.statuscode = 1
			AND elcn_contribution.elcn_contributionType IN (344220000, -- Gift
															344220001, -- Pledge
															344220004, -- Matching Gift
															344220005) -- Bequest Expectancy
			and elcn_contributiondonorBase.elcn_ContributionDate BETWEEN @p_StartDate AND @p_EndDate
		) Lifetime_Number_of_Gifts --TOTAL_NO_GIFTS

	, const.Largest_Contribution_Amount -- HIGH_GIFT_AMT
	, CONVERT(VARCHAR,const.elcn_LastContributionDate,101) Last_Contibution_Date -- LAST_GIFT_DATE 12/30/2006 format

	, (
		SELECT
			SUM(elcn_RecognitionCredit)
		FROM
			elcn_contributiondonorBase
			JOIN elcn_contribution  
				ON elcn_contributiondonorBase.elcn_contribution = elcn_contribution.elcn_contributionId
		WHERE
			elcn_contributiondonorBase.elcn_person = const.ContactId
			AND elcn_contribution.statuscode = 1
			AND elcn_contribution.elcn_contributionType IN (344220000, -- Gift
															344220001, -- Pledge
															344220004, -- Matching Gift
															344220005) -- Bequest Expectancy
			and datepart(YYYY,elcn_contributiondonorBase.elcn_ContributionDate) = datepart(YYYY,sysdatetime())
	) Gifts_YTD  

	, (
		SELECT
			SUM(elcn_RecognitionCredit)
		FROM
			elcn_contributiondonorBase
			JOIN elcn_contribution  
				ON elcn_contributiondonorBase.elcn_contribution = elcn_contribution.elcn_contributionId
		WHERE
			elcn_contributiondonorBase.elcn_person = const.ContactId
			AND elcn_contribution.statuscode = 1
			AND elcn_contribution.elcn_contributionType IN (344220000, -- Gift
															344220001, -- Pledge
															344220004, -- Matching Gift
															344220005) -- Bequest Expectancy
			and datepart(YYYY,elcn_contributiondonorBase.elcn_ContributionDate) = datepart(YYYY,sysdatetime()) -1
	) Gifts_Year2

	, (
		SELECT
			SUM(elcn_RecognitionCredit)
		FROM
			elcn_contributiondonorBase
			JOIN elcn_contribution  
				ON elcn_contributiondonorBase.elcn_contribution = elcn_contribution.elcn_contributionId
		WHERE
			elcn_contributiondonorBase.elcn_person = const.ContactId
			AND elcn_contribution.statuscode = 1
			AND elcn_contribution.elcn_contributionType IN (344220000, -- Gift
															344220001, -- Pledge
															344220004, -- Matching Gift
															344220005) -- Bequest Expectancy
			and datepart(YYYY,elcn_contributiondonorBase.elcn_ContributionDate) = datepart(YYYY,sysdatetime()) -2
	) Gifts_Year3

	, (
		SELECT
			SUM(elcn_RecognitionCredit)
		FROM
			elcn_contributiondonorBase
			JOIN elcn_contribution  
				ON elcn_contributiondonorBase.elcn_contribution = elcn_contribution.elcn_contributionId
		WHERE
			elcn_contributiondonorBase.elcn_person = const.ContactId
			AND elcn_contribution.statuscode = 1
			AND elcn_contribution.elcn_contributionType IN (344220000, -- Gift
															344220001, -- Pledge
															344220004, -- Matching Gift
															344220005) -- Bequest Expectancy
			and datepart(YYYY,elcn_contributiondonorBase.elcn_ContributionDate) = datepart(YYYY,sysdatetime()) -3
	) Gifts_Year4
	
	, longest_consec.longest_consec_years  LONGEST_CONS_YEARS_GIVEN
	, consec.consecyears RECENT_CONSECUTIVE_YEARS

	, gen_membership.elcn_name MEMBERSHIP_NAME
	, gen_membership.status MEMBERSHIP_STATUS
	, gen_membership.elcn_membershipnumber MEMBERSHIP_NUMBER
	, gen_membership.elcn_expiredate EXPIRATION_DATE

	, won_membership.elcn_name WON_MEMBERSHIP_NAME
	, won_membership.status WON_MEMBERSHIP_STATUS
	, won_membership.elcn_membershipnumber WON_MEMBERSHIP_NUMBER
	, won_membership.elcn_expiredate	WON_EXPIRATION_DATE

	, fan_membership.elcn_name FAN_MEMBERSHIP_NAME
	, fan_membership.status FAN_MEMBERSHIP_STATUS
	, fan_membership.elcn_membershipnumber FAN_MEMBERSHIP_NUMBER
	, fan_membership.elcn_expiredate FAN_EXPIRATION_DATE

	, eab.elcn_name EMAIL_PREFERRED_ADDRESS
	, email_slot.personal PERS_EMAIL
	, email_slot.nsu NSU_EMAIL
	, email_slot.alumni AL_EMAIL
	, email_slot.business BUS_EMAIL


	, homephone.elcn_phonenumber Home_Phome --PR_PHONE_NUMBER
	, CASE homephone.elcn_preferred
		WHEN 1 then 'Y'
		ELSE null
	END Home_Phone_Preferred --PR_PRIMARY_IND
	, cellphone.elcn_phonenumber CL_PHONE_NUMBER
	, CASE cellphone.elcn_preferred 
		WHEN 1 then 'Y' 
		ELSE null
	END Cell_Preferred --CL_PRIMARY_IND
	, busphone.elcn_phonenumber Business_Phone --B1_PHONE_NUMBER
	, CASE busphone.elcn_preferred
		WHEN 1 then 'Y'
		ELSE null
	END Business_Phone_Preferred --B1_PRIMARY_IND

--TOTAL_PLEDGE_PAYMENTS1
	, (
		SELECT
			SUM(elcn_contributionBase.elcn_Amount)
		FROM
			elcn_contribution --PAYMENT
			JOIN elcn_contributiondonorBase 
				ON elcn_contribution.elcn_contributionId = elcn_contributiondonorBase.elcn_contribution
			JOIN elcn_contributionBase --PLEDGE
				ON elcn_contribution.elcn_PaymentforContribution = elcn_contributionBase.elcn_contributionId
		WHERE
			elcn_contributiondonorBase.elcn_person = const.ContactId
			AND elcn_contributionBase.statuscode = 1
			AND elcn_contribution.elcn_contributionType = 344220003 -- Pledge Payment
			AND elcn_contributiondonorBase.elcn_AssociationTypeId = '36FA0E30-6248-E411-941F-0050568068B8' -- Primary only, If incl Spouse, would need to include Group/Joint
	) Lifetime_Pledge_Payments --Total Pledge Payments
	
	, (
		SELECT
			SUM(elcn_contributionBase.elcn_Amount)
		FROM
			elcn_contribution --PAYMENT
			JOIN elcn_contributiondonorBase 
				ON elcn_contribution.elcn_contributionId = elcn_contributiondonorBase.elcn_contribution
			JOIN elcn_contributionBase --PLEDGE
				ON elcn_contribution.elcn_PaymentforContribution = elcn_contributionBase.elcn_contributionId
		WHERE
			elcn_contributiondonorBase.elcn_person = const.ContactId
			AND elcn_contributionBase.statuscode = 1
			AND elcn_contribution.elcn_contributionType = 344220003 -- Pledge Payment
			AND elcn_contributiondonorBase.elcn_ContributionDate BETWEEN @p_StartDate AND @p_EndDate
			AND elcn_contributiondonorBase.elcn_AssociationTypeId = '36FA0E30-6248-E411-941F-0050568068B8' -- Primary only, If incl Spouse, would need to include Group/Joint
	) Total_Pledge_Payments --Total Pledge Payments

-- LIFE_TOTAL_GIVING
	, const.Lifetime_Giving
-- TOTAL_GIVING1
	, ( 
		SELECT
			SUM(elcn_RecognitionCredit)
		FROM
			elcn_contributiondonorBase
			JOIN elcn_contribution  
				ON elcn_contributiondonorBase.elcn_contribution = elcn_contribution.elcn_contributionId
		WHERE
			elcn_contributiondonorBase.elcn_person = const.ContactId
			AND elcn_contribution.statuscode = 1
			AND elcn_contribution.elcn_contributionType IN (344220000, -- Gift
															344220001, -- Pledge
															344220004, -- Matching Gift
															344220005) -- Bequest Expectancy
			and elcn_contributiondonorBase.elcn_ContributionDate BETWEEN @p_StartDate AND @p_EndDate
	) Total_Giving

	, (
		SELECT
			SUM(elcn_contribution.elcn_TotalPremiumFairMarketValue)
		FROM
			elcn_contributiondonorBase
			JOIN elcn_contribution  
				ON elcn_contributiondonorBase.elcn_contribution = elcn_contribution.elcn_contributionId
		WHERE
			elcn_contributiondonorbase.elcn_person = const.ContactId
			AND elcn_contribution.statuscode = 1
			AND elcn_contribution.elcn_contributionType IN (344220000, -- Gift
															344220001, -- Pledge
															344220004, -- Matching Gift
															344220005) -- Bequest Expectancy
	) Lifetime_Premiums

-- LIFE_TOTAL_GIVING_AUX -- total of fair market value of all contributions except dues payments
	, (
		SELECT
			SUM(elcn_contribution.elcn_TotalPremiumFairMarketValue)
		FROM
			elcn_contributiondonorBase
			JOIN elcn_contribution  
				ON elcn_contributiondonorBase.elcn_contribution = elcn_contribution.elcn_contributionId
		WHERE
			elcn_contributiondonorbase.elcn_person = const.ContactId
			AND elcn_contribution.statuscode = 1
			AND elcn_contribution.elcn_contributionType IN (344220000, -- Gift
															344220001, -- Pledge
															344220004, -- Matching Gift
															344220005) -- Bequest Expectancy
			and elcn_contributiondonorBase.elcn_ContributionDate BETWEEN @p_StartDate AND @p_EndDate
	) Total_Premiums

	, (
		SELECT
			SUM(elcn_contribution.elcn_marketValue)
		FROM
			elcn_contributiondonorBase
			JOIN elcn_contribution  
				ON elcn_contributiondonorBase.elcn_contribution = elcn_contribution.elcn_contributionId
		WHERE
			elcn_contributiondonorBase.elcn_person = const.ContactId
			AND elcn_contribution.statuscode = 1
			AND elcn_contribution.elcn_contributionType IN (344220000, -- Gift
															344220001, -- Pledge
															344220004, -- Matching Gift
															344220005) -- Bequest Expectancy
			
	) Lifetime_Fair_Market_Value--Total Lifetime FMV

	, (
		SELECT
			SUM(elcn_contribution.elcn_marketValue)
		FROM
			elcn_contributiondonorBase
			JOIN elcn_contribution  
				ON elcn_contributiondonorBase.elcn_contribution = elcn_contribution.elcn_contributionId
		WHERE
			elcn_contributiondonorBase.elcn_person = const.ContactId
			AND elcn_contribution.statuscode = 1
			AND elcn_contribution.elcn_contributionType IN (344220000, -- Gift
															344220001, -- Pledge
															344220004, -- Matching Gift
															344220005) -- Bequest Expectancy
			and elcn_contributiondonorBase.elcn_ContributionDate BETWEEN @p_StartDate AND @p_EndDate
	) Total_Fair_Market_Value --Total Fair Market Value (For given date range)

/**************************
ANNUAL_HOUSEHOLD_GIVING -- Householding tools in CRM 3.0
LIFETIME_HOUSEHOLD_GIVING -- Householding tools in CRM 3.0
**************************/

--RELATION_SOURCE_DESC
	, prt.elcn_type	Relationship
	, spouse_p.fullname Relation_Name

--COMBINED_MAILING_PRIORITY
	, CASE spouse_link.elcn_jointmailing 
		WHEN 1 THEN 'Y'
		ELSE null
	END Joint_Mailing

	, edu_1.Degree Degree1_Degree
	, edu_1.Degree_Name AS Degree1_Degree_Desc
	, edu_1.Major AS Degree1_Major
	, edu_1.Degree_Year Degree1_Degree_Year

	, edu_2.Degree Degree2_Degree
	, edu_2.Degree_Name AS Degree2_Degree_Desc
	, edu_2.Major AS Degree2_Major
	, edu_2.Degree_Year Degree2_Degree_Year

	, edu_3.Degree Degree3_Degree
	, edu_3.Degree_Name AS Degree3_Degree_Desc
	, edu_3.Major AS Degree3_Major
	, edu_3.Degree_Year Degree3_Degree_Year

	, elcn_OrganizationIdName EMPLOYER
	, elcn_JobTitle POSITION
	, elcn_BusinessRelationshipStatusIdName Status
	, activities.alist ACTIVITIES
--;select *
FROM
	#temp_const CONST

	JOIN elcn_addressassociationBase aab 
		ON aab.elcn_personId = const.ContactId 
		AND aab.elcn_Preferred =1

	JOIN elcn_addressBase AB
		ON ab.elcn_addressId = aab.elcn_AddressId
		AND LEFT(ab.elcn_postalcode,5) IN (@p_zipcodeList)

	JOIN elcn_stateprovinceBase spb 
		ON spb.elcn_stateprovinceId = ab.elcn_StateProvinceId 

--AND spb.elcn_stateprovinceId IN (@p_stateList)
	JOIN Datatel_countryBase dcb 
		ON dcb.Datatel_countryId = ab.elcn_country

	JOIN elcn_addresstypeBase atb 
		ON atb.elcn_addresstypeId = aab.elcn_AddressTypeId

	LEFT JOIN elcn_personalrelationshipBase SPOUSE_LINK -- includes elcn_jointmailing
		ON spouse_link.elcn_Person1Id = const.ContactId
			AND spouse_link.elcn_RelationshipType1ID IN ( '42295D4F-A6EE-E411-942F-005056804B43' , /*Spouse*/
														'4F665855-A3B8-E911-80D8-0A253F89019C', /*Spouse / Partner*/
														'62295D4F-A6EE-E411-942F-005056804B43', /*Domestic Partner*/
														'43665855-A3B8-E911-80D8-0A253F89019C')	/*Life Partner*/
			AND spouse_link.elcn_EndDate is null
			AND spouse_link.statuscode = 1
	LEFT JOIN elcn_personalrelationshiptype prt 
		ON spouse_link.elcn_RelationshipType1Id  = prt.elcn_personalrelationshiptypeid 
	LEFT JOIN ContactBase spouse_p 
		ON spouse_p.ContactId = spouse_link.elcn_Person2Id

	LEFT JOIN(
		SELECT *
		FROM(
			SELECT 
				elcn_personid
				, exclusion
				--, rn = DENSE_RANK() OVER (PARTITION BY elcn_personid, exclusion ORDER BY exclusion)
			FROM
				#temp_exclusions) T
		PIVOT(
			MAX(exclusion)
			FOR exclusion IN ([NPH],[NMC],[NEM],[NDN],[NTP],[NOC],[NAM],[NAK]) 
		) PVT
	) EXCLUSIONS ON const.contactid = exclusions.elcn_PersonId

	LEFT JOIN elcn_constituentaffiliationBase cab 
		ON cab.elcn_constituentaffiliationId = const.elcn_primaryconstituentaffiliationid

	LEFT JOIN(
		SELECT 
			elcn_constituenttypeBase.*,
			filteredstringmap.value  
		FROM
			elcn_constituenttypeBase
			JOIN filteredstringmap
				ON elcn_constituenttypeBase.elcn_category = filteredstringmap.attributevalue 

				AND FilteredViewName = 'Filteredelcn_constituenttype'
				AND attributeName = 'elcn_category'

		) ctb ON ctb.elcn_constituenttypeID = cab.elcn_ConstituentTypeId

	LEFT JOIN(
		SELECT
			elcn_personid,
			elcn_formattedname,
			ROW_NUMBER() OVER (PARTITION BY elcn_personid ORDER BY elcn_locked DESC, modifiedon DESC) RN
		FROM
			#temp_aprsalu salu
		WHERE
			salu.salu_code = 'CIFE'
		) CIFE_SALU 
			ON const.contactid = cife_salu.elcn_personid
			AND cife_salu.rn = 1
	LEFT JOIN(
		SELECT
			elcn_personid,
			elcn_formattedname,
			ROW_NUMBER() OVER (PARTITION BY elcn_personid ORDER BY elcn_locked DESC, modifiedon DESC) RN
		FROM
			#temp_aprsalu salu
		WHERE
			salu.salu_code = 'SIFE'
		) SIFE_SALU 
			ON const.contactid = sife_salu.elcn_personid
			AND sife_salu.rn = 1
	LEFT JOIN(
		SELECT 
			elcn_personid,
			elcn_formattedname,
			ROW_NUMBER() OVER (PARTITION BY elcn_personid ORDER BY elcn_locked DESC, modifiedon DESC) RN
		FROM
			#temp_aprsalu salu
		WHERE
			salu.salu_code = 'CIFL'
		) CIFL_SALU 
			ON const.contactid = cifl_salu.elcn_personid
			AND cifl_salu.rn = 1
	LEFT JOIN(
		SELECT 
			elcn_personid,
			elcn_formattedname,
			ROW_NUMBER() OVER (PARTITION BY elcn_personid ORDER BY elcn_locked DESC, modifiedon DESC) RN
		FROM
			#temp_aprsalu salu
		WHERE
			salu.salu_code = 'SIFL'
		) SIFL_SALU 
			ON const.contactid = sifl_salu.elcn_personid
			AND sifl_salu.rn = 1

	LEFT JOIN #temp_education edu_1 
		ON edu_1.elcn_PersonId = const.ContactID 
		AND edu_1.rank_no = 1
	LEFT JOIN #temp_education edu_2 
		ON edu_2.elcn_PersonId = const.ContactID 
		AND edu_2.rank_no = 2
	LEFT JOIN #temp_education edu_3 
		ON edu_3.elcn_PersonId = const.ContactID 
		AND edu_3.rank_no = 3

	LEFT JOIN(
		SELECT
			personid,
			MAX(consecyears) consecyears 
		FROM
			w_get_consec_years
		GROUP BY personid
		)CONSEC ON const.contactid = consec.personid 
	LEFT JOIN(
		SELECT
			personid,
			MAX(consecyears) LONGEST_CONSEC_YEARS
		FROM
			w_get_longest_consec_years
		GROUP BY personid
		)LONGEST_CONSEC on const.contactid = longest_consec.personid

	LEFT JOIN(
		SELECT
			tr.elcn_personid
			, tr.Value 
		FROM
			#temp_ratings TR
		WHERE
			elcn_ratingtypeid =  '88C5BD4A-BF21-4635-B8BB-EBE956F2E5BD' -- JFSG Est Capacity-DonorSearch
	) JFSG_EST_CAP ON const.ContactId = jfsg_est_cap.elcn_personid  

	LEFT JOIN(
		SELECT
			tr.elcn_personid 
			, 'JF Smith Group Top 500' RATING_TYPE
			, tr.value RATING_VALUE
			, tr.level RATING_LEVEL
			, tr.score RATING_SCORE
		FROM
			#temp_ratings TR
		WHERE	
			elcn_ratingtypeid = '1BB294D5-53D7-4815-8963-096802773E6D'  -- JF Smith Group Top 500			 		
		)RATINGS1 ON const.contactid = ratings1.elcn_personid  

	LEFT JOIN(
		SELECT
			tr.elcn_personid
			, 'iWave Pro Score' RATING_TYPE
			, tr.value RATING_VALUE
			, tr.level RATING_LEVEL
			, tr.score RATING_SCORE
		FROM
			#temp_ratings TR
		WHERE	
			elcn_ratingtypeid = '3DE9ACBB-37E5-45AF-8902-2314FC2A9538' -- iWave Pro Score
		)RATINGS2 ON const.contactid = ratings2.elcn_personid  

	LEFT JOIN( -- general membership
		SELECT
			elcn_PrimaryMemberPersonId,
			elcn_name,
			status,
			elcn_membershipnumber,
			elcn_expiredate,
			ROW_NUMBER() OVER (PARTITION BY elcn_PrimaryMemberPersonId
				ORDER BY ISNULL(elcn_expiredate,'31-DEC-2999') DESC) rn
		FROM
			#temp_membership
		WHERE
			(	elcn_name not like 'FAN%'
				AND elcn_name not like 'WON%'
			) 		
	) GEN_MEMBERSHIP ON const.contactid = gen_membership.elcn_PrimaryMemberPersonId
		AND gen_membership.rn = 1

	LEFT JOIN( -- Future Alumni Network (FAN) membership
		SELECT
			elcn_PrimaryMemberPersonId,
			elcn_name,
			status,
			elcn_membershipnumber,
			elcn_expiredate,
			ROW_NUMBER() OVER (PARTITION BY elcn_PrimaryMemberPersonId
				ORDER BY ISNULL(elcn_expiredate,'31-DEC-2999') DESC) rn
		FROM
			#temp_membership
		WHERE
			elcn_name like 'FAN%'
	) FAN_MEMBERSHIP ON const.contactid = fan_membership.elcn_PrimaryMemberPersonId
			AND fan_membership.rn = 1

	LEFT JOIN( -- Women of Northeastern (WON) membership
		SELECT
			elcn_PrimaryMemberPersonId,
			elcn_name,
			status,
			elcn_membershipnumber,
			elcn_expiredate,
			ROW_NUMBER() OVER (PARTITION BY elcn_PrimaryMemberPersonId
				ORDER BY ISNULL(elcn_expiredate,'31-DEC-2999') DESC) rn
		FROM
			#temp_membership
		WHERE
			elcn_name like 'WON%'
	) WON_MEMBERSHIP ON const.contactid = won_membership.elcn_PrimaryMemberPersonId
			AND won_membership.rn = 1

	LEFT JOIN elcn_emailaddressbase eab
		ON eab.elcn_personid = const.contactid 
		AND eab.elcn_preferred = 1

	LEFT JOIN #temp_email_slot email_slot
		ON const.contactid = email_slot.elcn_personid

	LEFT JOIN(
		SELECT
			elcn_personid, 
			elcn_phonenumber, 
			elcn_type , -- 'Home' etc
			elcn_preferred -- 0/1
		FROM
			#temp_phone
		WHERE
			elcn_type = 'Home'
		)HOMEPHONE ON const.contactid = homephone.elcn_personid

	LEFT JOIN(
		SELECT
			elcn_personid,
			elcn_phonenumber, 
			elcn_type ,
			elcn_preferred 
		FROM
			#temp_phone
		WHERE
			elcn_type = 'Cell'
		)CELLPHONE ON const.contactid = cellphone.elcn_personid

	LEFT JOIN(
		SELECT
			elcn_personid, 
			elcn_phonenumber,
			elcn_type , 
			elcn_preferred 
		FROM
			#temp_phone
		WHERE
			elcn_type = 'Business'
		)BUSPHONE ON const.contactid = busphone.elcn_personid

	LEFT JOIN(
		SELECT
			elcn_personid,
			elcn_JobTitle, 
			elcn_OrganizationIdName,
			elcn_BusinessRelationshipStatusIdName
		FROM 
			elcn_businessrelationship
		WHERE
			elcn_PrimaryEmployer = 1
			AND statuscode =1

	)JOB ON const.contactid = job.elcn_personid 
	LEFT JOIN(
		SELECT
			elcn_personid,
			STRING_AGG(ib.elcn_name + ' (' + sb.elcn_name + ')', ';') AS ALIST
		FROM
			elcn_involvementBase ib 
			JOIN elcn_statusbase sb 
				ON ib.elcn_InvolvementStatusId = sb.elcn_statusid
		GROUP BY elcn_personid
	)ACTIVITIES ON const.contactid = activities.elcn_personid 		
WHERE	
	(
		@p_primary_spouse_only = 'N' -- include everyone
		OR (spouse_link.elcn_person1id IS NOT NULL -- they have a relationship
			AND const.contactid = spouse_link.elcn_primaryspouseid) --and this person is primary
	)

--and const.Primary_Name like '%Mutzig%'
;