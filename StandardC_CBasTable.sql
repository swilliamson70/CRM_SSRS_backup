DECLARE 
                 
	 @p_stateList uniqueidentifier = 'E323CFDA-A383-E911-80D7-0A253F89019C' -- TX 'C823CFDA-A383-E911-80D7-0A253F89019C' -- KS 'DC23CFDA-A383-E911-80D7-0A253F89019C' -- ok
	, @p_zipcodeList varchar(9) = '74331'
	, @p_county varchar(120)-- not found in CRM data entry in person, prospect pages
	, @p_cityname varchar(120) = 'Tah' -- dnu/ too expensive
	, @p_veteran varchar(1)-- not found in CRM data entry
	, @p_household_ind varchar(1) -- APRXREF_HOUSEHOLD_IND -- flag on xref rec linking people at same address
									-- at same address and other than married, why exclude?
									-- at same address and married/partnered then primary spouse only flag is same condition

	, @p_include_deceased varchar(1) = 'Y' -- y/n
	, @p_primary_spouse_only varchar(1) = 'Y' -- y/n
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
	, @p_ignore_activities varchar(1) = 'Y'
	, @p_ignore_academic_years varchar(1) = 'Y'
	;
/*
WITH W_CONTACTID_LIST AS(
	SELECT 
		contactid
	FROM
		contactbase
	WHERE
		(@p_primary_spouse_only = 'N'
		OR NOT EXISTS ( 
				SELECT	
					1 X
				FROM
					elcn_personalrelationshipBase prb
				WHERE
					(prb.elcn_Person1Id = contactbase.contactid 
						OR prb.elcn_Person2Id = contactbase.contactid)
					AND prb.elcn_PrimarySpouseId <> contactbase.contactid 
					AND prb.elcn_RelationshipType1Id IN ( '42295D4F-A6EE-E411-942F-005056804B43', 
														'4F665855-A3B8-E911-80D8-0A253F89019C',
														'62295D4F-A6EE-E411-942F-005056804B43',
														'43665855-A3B8-E911-80D8-0A253F89019C')	
					AND elcn_EndDate is null
					AND statuscode = 1
			)
		) AND(
			@p_include_deceased = 'Y'
			OR contactbase.elcn_dateofdeath IS NULL
		)
)
*/
DECLARE @p_StartDate date, @p_EndDate date;
SELECT
	cb.contactid
	, CASE
		WHEN elcn_PersonStatusId IN ('CF133D0E-4205-4EC8-B3D1-799074F7A72D',
									'57B3E088-CDD5-4808-9D53-5F530BDCD320',
									'233C10DC-B283-4C57-866C-52138BF01CEB') 
			THEN 'Y'
		ELSE 'N'
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
			OR elcn_PersonStatusId not in ('CF133D0E-4205-4EC8-B3D1-799074F7A72D',
											'57B3E088-CDD5-4808-9D53-5F530BDCD320',
											'233C10DC-B283-4C57-866C-52138BF01CEB')
			)
		AND statuscode = 1
		--AND contactbase.contactid in (SELECT contactid from w_contactid_list)
	) CB
	LEFT JOIN(
		SELECT TOP 1
			pnb.elcn_personid
			, pnb.elcn_firstname
		FROM 
			elcn_personnameBase pnb
		WHERE
			pnb.elcn_nametype = 'EBC22907-A5CB-4270-8947-C5381D1ECC54' 
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
			pnb.elcn_nametype = '29C69522-08C1-48E3-A030-F417A0E741C0' 
			AND pnb.elcn_EndDate IS NULL
			AND pnb.statuscode = 1
		ORDER BY pnb.ModifiedOn 
	) MAIDEN ON cb.contactid = maiden.elcn_personid
	LEFT JOIN elcn_anonymitytypebase 
		ON cb.elcn_AnonymityTypeId = elcn_anonymitytypeBase.elcn_anonymitytypeId
;
CREATE NONCLUSTERED INDEX INDX_TMP_ID ON #temp_const (contactid);

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
	ab.elcn_addressId 
	, ab.elcn_street1  Street_Line1
	, ab.elcn_street2  Street_Line2
	, ab.elcn_City  City
	, spb.elcn_stateprovinceId 
	, spb.elcn_Abbreviation  State_Province
	, ab.elcn_postalcode  Postal_Code
	, ab.elcn_county	County
	, dcb.Datatel_name	Nation
INTO
	#temp_addresses
FROM
	elcn_addressBase AB
	JOIN elcn_stateprovinceBase SPB
		ON spb.elcn_stateprovinceId = ab.elcn_StateProvinceId
	JOIN Datatel_countryBase DCB
		ON dcb.Datatel_countryId = ab.elcn_country		
WHERE
	ab.elcn_StateProvinceId in (@p_stateList)
;
CREATE NONCLUSTERED INDEX INDX_TMP_ADDRID ON #temp_addresses (elcn_addressId);

SELECT 
	elcn_personid,
	CASE elcn_typeid 
		WHEN '1172C46B-462D-E411-9415-005056804B43' THEN 'CIFE'
		WHEN '0F72C46B-462D-E411-9415-005056804B43' THEN 'SIFE'
		WHEN '1B72C46B-462D-E411-9415-005056804B43' THEN 'SIFL'
		WHEN '89799F16-C4E8-4269-B409-5756998F193F' THEN 'CIFL'
	END AS SALU_CODE,
	elcn_formattedname,
	ROW_NUMBER() OVER (PARTITION BY elcn_personid, elcn_typeid ORDER BY elcn_locked DESC, modifiedon DESC) RN
INTO
	#temp_aprsalu
FROM
	elcn_formattednamebase
WHERE
	elcn_typeid in ('1172C46B-462D-E411-9415-005056804B43',  
			    		'0F72C46B-462D-E411-9415-005056804B43',  
	     				'1B72C46B-462D-E411-9415-005056804B43', 
		    			'89799F16-C4E8-4269-B409-5756998F193F')  
	AND elcn_enddate IS NULL
;
CREATE NONCLUSTERED INDEX INDX_TMP_ID_SALU ON #temp_aprsalu (elcn_personId,salu_code,rn);

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
	WHERE
		elcn_ratingtypeid in	('88C5BD4A-BF21-4635-B8BB-EBE956F2E5BD'
								,'1BB294D5-53D7-4815-8963-096802773E6D'
								,'3DE9ACBB-37E5-45AF-8902-2314FC2A9538')
) T PIVOT
(	
	MAX(elcn_ratingvalue)
	FOR elcn_ratingDescription  IN
	([Value], [Level], [Score]) 
) PVT
;
CREATE NONCLUSTERED INDEX INDX_TMP_ID_RATINGTYPE ON #temp_ratings (elcn_personid, elcn_ratingtypeid);

SELECT
	mb.elcn_PrimaryMemberPersonId
	, mpl.elcn_name
	, sb.elcn_name status_desc
	, mb.elcn_MembershipNumber  --7701
	, CONVERT(DATE, mb.elcn_ExpireDate) elcn_ExpireDate  -- null
	, ROW_NUMBER() OVER (PARTITION BY mb.elcn_PrimaryMemberPersonId, mpl.elcn_name
				ORDER BY COALESCE(mb.elcn_expiredate,'31-DEC-2999') DESC) rn
INTO 
	#temp_membership
FROM
	elcn_membershipBase MB
	JOIN elcn_membershipprogramlevelbase MPL
		ON mb.elcn_MembershipLevelId = mpl.elcn_membershipprogramlevelId
	JOIN elcn_statusbase SB
		ON mb.elcn_MembershipStatusId  = sb.elcn_statusid
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
			WHEN 'F523FC9B-5370-46F3-9242-263411E73043' THEN 'Yellow ' 
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
		AND	elcn_EmailAddressStatusId = '378DE114-EB09-E511-943C-0050568068B7'
										
	UNION ALL 
	SELECT
		'Preferred',
		elcn_personid,
		elcn_email
	FROM
		elcn_emailaddressbase
	WHERE
		statuscode =1 
		AND	elcn_EmailAddressStatusId = '378DE114-EB09-E511-943C-0050568068B7' 
		AND elcn_preferred = 1

)T PIVOT 
(	MAX(elcn_email)
	FOR emailtype 
	IN ([Preferred], [Business], [Personal], [Other], [Yellow], [Alumni], [NSU])
)PVT;

CREATE NONCLUSTERED INDEX INDX_TMP_ID ON #temp_email_slot (elcn_personid);

SELECT
	elcn_personid, 
	elcn_phonenumber, 
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
			AND elcn_phonebase.elcn_phonestatusid = '378DE114-EB09-E511-943C-0050568068B7' 
			AND elcn_phonebase.statuscode = 1
	) PHONES 
WHERE
	RN = 1 
CREATE NONCLUSTERED INDEX INDX_TMP_ID ON #temp_phone (elcn_personid);

SELECT 
	elcn_personid
	, elcn_name
	, STRING_AGG(ayear,',') AYEARS
INTO
	#temp_activities
FROM(
	SELECT 
		ib.elcn_personid
		, ib.elcn_name
		, COALESCE(ib.elcn_ClassYear, ib.elcn_EndYear, 'UNK') AYEAR
	FROM 
		elcn_involvementBase IB
	ORDER BY
		elcn_personid
		, elcn_name 
		, COALESCE(ib.elcn_ClassYear, ib.elcn_EndYear, 'UNK')
		OFFSET 0 ROWS
	) ACTIVITIES 
GROUP BY
	elcn_personid,elcn_name
ORDER BY 
	elcn_personid,elcn_name
;
CREATE NONCLUSTERED INDEX INDX_TMP_ID ON #temp_activities (elcn_personid);

SELECT
	elcn_person
	, [0] YTD
	, [1] Year1
	, [2] Year2
	, [3] Year3
	, [4] Year4
INTO
	#temp_recognitioncredit
FROM
	(
	SELECT
		cdb.elcn_person 
		, cdb.elcn_RecognitionCredit
		, datepart(YYYY,@p_EndDate) - datepart(YYYY,cdb.elcn_ContributionDate) contrib_year
	FROM
		elcn_contributiondonorBase cdb
		JOIN elcn_contribution contrib 
			ON cdb.elcn_contribution = contrib.elcn_contributionId
	WHERE
		cdb.elcn_person = '9D67DD91-B3CA-4AA7-BFCC-49BEE53AF420' --const.ContactId
		AND contrib.statuscode = 1
		AND contrib.elcn_contributionType IN (344220000, 
											  344220001, 
											  344220004,
											  344220005)
		AND cdb.elcn_ContributionDate <= @p_EndDate

	)T PIVOT
	(	SUM(elcn_recognitioncredit)
		FOR contrib_year
		IN ([0], [1], [2], [3], [4])
	)PVT;

CREATE NONCLUSTERED INDEX INDX_TMP_ID ON #temp_recognitioncredit (elcn_person);

SELECT DISTINCT  
	elcn_person personid,
	datepart(YYYY,elcn_ContributionDate)givingyear
INTO
	#temp_dontations
FROM
	elcn_contributiondonorBase
WHERE 
	elcn_ContributionDate <= @p_EndDate
;

with w_get_consec_years AS ( 
	select personid,
		givingyear,
		1 consecyears
	from #temp_dontations
	union all
	select d.personid,
	d.givingyear,
	cte.consecyears +1 consecyears
	from #temp_dontations d 
		join w_get_consec_years cte
			on cte.personid = d.personid
			and d.givingyear -1 = cte.givingyear
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

	, ctb.value	Primary_Constituent_Type 
	, ctb.elcn_type AS Primary_Constituent_Desc 

	, addresses.Street_Line1
	, addresses.Street_Line2
	, addresses.City
	, addresses.State_Province
	, addresses.Postal_Code
	, addresses.County
	, addresses.Nation

	, atb.elcn_type AS Preferred_Address_Type 

	, CASE WHEN(
			SELECT 1 X
			WHERE EXISTS(
				SELECT cpb.elcn_ContactPreferenceTypeId
				FROM elcn_contactpreferenceBase cpb
				WHERE 
					cpb.elcn_ContactPreferenceTypeId = '112A7585-A2D9-E911-80D8-0A253F89019C'
		 			AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6'
 					AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
					AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' 
					AND cpb.elcn_MethodofContact = 344220001
					AND cpb.elcn_personId = const.ContactId
				)
			) IS NOT NULL THEN 'NPH' END AS NPH 

	, CASE WHEN(
			SELECT 1 X
			WHERE EXISTS(
				SELECT cpb.elcn_ContactPreferenceTypeId
				FROM elcn_contactpreferenceBase cpb
				WHERE 
					cpb.elcn_ContactPreferenceTypeId =  '76EA8AA5-2F36-4E8E-BFB2-490677DCF4B4'
		 			AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6'
 					AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
					AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7'
					AND cpb.elcn_MethodofContact = 344220006
					AND cpb.elcn_personId = const.ContactId
				)
			) IS NOT NULL THEN 'NOC' END AS NOC 

	, CASE WHEN(
			SELECT 1 X
			WHERE EXISTS(
				SELECT cpb.elcn_ContactPreferenceTypeId
				FROM elcn_contactpreferenceBase cpb
				WHERE 
					cpb.elcn_ContactPreferenceTypeId =  '112A7585-A2D9-E911-80D8-0A253F89019C' 
		 			AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6' 
 					AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
					AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7'
					AND cpb.elcn_MethodofContact = 344220000 
					AND cpb.elcn_personId = const.ContactId
				)
			) IS NOT NULL THEN 'NMC' END AS NMC 

	, CASE WHEN(
			SELECT 1 X
			WHERE EXISTS(
				SELECT cpb.elcn_ContactPreferenceTypeId
				FROM elcn_contactpreferenceBase cpb
				WHERE 
					cpb.elcn_ContactPreferenceTypeId =  '112A7585-A2D9-E911-80D8-0A253F89019C' 
		 			AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6'
 					AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
					AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7'
					AND cpb.elcn_MethodofContact = 344220002 
					AND cpb.elcn_personId = const.ContactId
				)
			) IS NOT NULL THEN 'NEM' END AS NEM 

	, CASE WHEN(
			SELECT 1 X
			WHERE EXISTS(
				SELECT cpb.elcn_ContactPreferenceTypeId
				FROM elcn_contactpreferenceBase cpb
				WHERE 
					cpb.elcn_ContactPreferenceTypeId =  'EE8CE7BD-9CB8-E911-80D8-0A253F89019C' 
		 			AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6'
 					AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
					AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' 
					AND cpb.elcn_MethodofContact = 344220000
					AND cpb.elcn_personId = const.ContactId
				)
			) IS NOT NULL THEN 'NAM' END AS NAM 

	, CASE WHEN(
			SELECT 1 X
			WHERE EXISTS(
				SELECT cpb.elcn_ContactPreferenceTypeId
				FROM elcn_contactpreferenceBase cpb
				WHERE 
					cpb.elcn_ContactPreferenceTypeId = 'e4e02dc6-3314-e511-9431-005056804b43'
		 			AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6'
 					AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
					AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' 
					AND cpb.elcn_MethodofContact = 344220006 
					AND cpb.elcn_personId = const.ContactId
				)
			) IS NOT NULL THEN 'NDN' END AS NDN 

	, CASE WHEN(
			SELECT 1 X
			WHERE EXISTS(
				SELECT cpb.elcn_ContactPreferenceTypeId
				FROM elcn_contactpreferenceBase cpb
				WHERE 
					cpb.elcn_ContactPreferenceTypeId = 'DEE02DC6-3314-E511-9431-005056804B43' 
		 			AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6'
 					AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
					AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' 
					AND cpb.elcn_MethodofContact = 344220000 
					AND cpb.elcn_personId = const.ContactId
				)
			) IS NOT NULL THEN 'NAK' END AS NAK

	, CASE WHEN(
			SELECT 1 X
			WHERE EXISTS(
				SELECT cpb.elcn_ContactPreferenceTypeId
				FROM elcn_contactpreferenceBase cpb
				WHERE 
		 			cpb.elcn_ContactRestrictionId = '3E4E206F-9EB8-E911-80D8-0A253F89019C' 
 					AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
					AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' 
					AND cpb.elcn_personId = const.ContactId
				)
			) IS NOT NULL THEN 'NTP' END AS NTP

	, const.anonymityType Anonymity_Type

	, jfsg_est_cap.value JFSG_Estimated_Capacity
	, ratings1.rating_type RATING_TYPE1
	, ratings1.rating_score RATING_AMOUNT1
	, ratings1.rating_value RATING1
	, ratings1.rating_level RATING_LEVEL1
	, ratings2.rating_type RATING_TYPE2
	, ratings2.rating_score RATING_AMOUNT2
	, ratings2.rating_value RATING2
	, ratings2.rating_level RATING_LEVEL2

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
			AND elcn_contribution.elcn_contributionType IN (344220000, 
															344220001, 
															344220004, 
															344220005) 
			and elcn_contributiondonorBase.elcn_ContributionDate BETWEEN @p_StartDate AND @p_EndDate
		) Number_of_Gifts_For_Period

	, const.Largest_Contribution_Amount 
	, CONVERT(VARCHAR,const.elcn_LastContributionDate,101) Last_Contibution_Date 

	, recognitioncredit.YTD Gifts_YTD
	, recognitioncredit.Year1 Gifts_Year2
	, recognitioncredit.Year2 Gifts_Year3
	, recognitioncredit.Year3 Gifts_Year4
	
	, longest_consec.longest_consec_years  LONGEST_CONS_YEARS_GIVEN
	, consec.prev_consec_years RECENT_CONSECUTIVE_YEARS

	, gen_membership.elcn_name MEMBERSHIP_NAME
	, gen_membership.status_desc MEMBERSHIP_STATUS
	, gen_membership.elcn_membershipnumber MEMBERSHIP_NUMBER
	, gen_membership.elcn_expiredate EXPIRATION_DATE

	, won_membership.elcn_name WON_MEMBERSHIP_NAME
	, won_membership.status_desc WON_MEMBERSHIP_STATUS
	, won_membership.elcn_membershipnumber WON_MEMBERSHIP_NUMBER
	, won_membership.elcn_expiredate	WON_EXPIRATION_DATE

	, fan_membership.elcn_name FAN_MEMBERSHIP_NAME
	, fan_membership.status_desc FAN_MEMBERSHIP_STATUS
	, fan_membership.elcn_membershipnumber FAN_MEMBERSHIP_NUMBER
	, fan_membership.elcn_expiredate FAN_EXPIRATION_DATE

	, eab.elcn_name EMAIL_PREFERRED_ADDRESS
	, email_slot.personal PERS_EMAIL
	, email_slot.nsu NSU_EMAIL
	, email_slot.alumni AL_EMAIL
	, email_slot.business BUS_EMAIL

	, homephone.elcn_phonenumber Home_Phome 
	, CASE homephone.elcn_preferred
		WHEN 1 then 'Y'
		ELSE null
	END Home_Phone_Preferred 
	, cellphone.elcn_phonenumber CL_PHONE_NUMBER
	, CASE cellphone.elcn_preferred 
		WHEN 1 then 'Y' 
		ELSE null
	END Cell_Preferred 
	, busphone.elcn_phonenumber Business_Phone
	, CASE busphone.elcn_preferred
		WHEN 1 then 'Y'
		ELSE null
	END Business_Phone_Preferred 

	, lifetime_pledge.pledge_total Lifetime_Pledge_Payments 
	, period_pledge.pledge_total Total_Pledge_Payments 
	, const.Lifetime_Giving
	, period_totals.Total_Giving
	, lifetime_totals.Lifetime_Premiums
	, period_totals.Total_Premiums 
	, lifetime_totals.Lifetime_Fair_Market_Value
	, period_totals.Total_Fair_Market_Value 

	, prt.elcn_type	Relationship
	, spouse_p.fullname Relation_Name

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

	, job.elcn_OrganizationIdName EMPLOYER
	, job.elcn_JobTitle POSITION
	, job.elcn_BusinessRelationshipStatusIdName EMP_STATUS
	, activities.alist ACTIVITIES

FROM
	#temp_const CONST

	LEFT JOIN(
		SELECT 
			aab.*
			,ROW_NUMBER() OVER (PARTITION BY elcn_personID 
								ORDER BY CASE WHEN sb.elcn_name = 'Current' THEN 1 ELSE 2 END, 
									aab.elcn_preferred DESC, 
									COALESCE(aab.elcn_enddate,'12/31/2999') DESC) RN
		FROM 
			elcn_addressassociationBase AAB
			JOIN elcn_statusbase SB
				ON aab.elcn_AddressStatusId = elcn_statusid
		) AAB 
		ON const.ContactId = aab.elcn_personId
		AND aab.rn = 1
	JOIN #temp_addresses ADDRESSES -- state filtered
		ON aab.elcn_AddressId = addresses.elcn_addressId  
	LEFT JOIN elcn_addresstypeBase ATB 
		ON  aab.elcn_AddressTypeId = atb.elcn_addresstypeId

	LEFT JOIN(
		SELECT
			elcn_personid
			, elcn_formattedname
		FROM
			#temp_aprsalu salu
		WHERE
			salu.salu_code = 'CIFE'
			AND salu.rn = 1
		) CIFE_SALU 
			ON const.contactid = cife_salu.elcn_personid
	LEFT JOIN(
		SELECT
			elcn_personid
			, elcn_formattedname
		FROM
			#temp_aprsalu salu
		WHERE
			salu.salu_code = 'SIFE'
			AND salu.rn = 1
		) SIFE_SALU 
			ON const.contactid = sife_salu.elcn_personid
	LEFT JOIN(
		SELECT 
			elcn_personid
			, elcn_formattedname
		FROM
			#temp_aprsalu salu
		WHERE
			salu.salu_code = 'CIFL'
			AND salu.rn = 1
		) CIFL_SALU 
			ON const.contactid = cifl_salu.elcn_personid
	LEFT JOIN(
		SELECT 
			elcn_personid
			, elcn_formattedname
		FROM
			#temp_aprsalu salu
		WHERE
			salu.salu_code = 'SIFL'
			AND salu.rn = 1
		) SIFL_SALU 
			ON const.contactid = sifl_salu.elcn_personid

	LEFT JOIN elcn_constituentaffiliationBase cab 
		ON const.elcn_primaryconstituentaffiliationid = cab.elcn_constituentaffiliationId 
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

		) CTB ON cab.elcn_ConstituentTypeId = ctb.elcn_constituenttypeID  

	LEFT JOIN(
		SELECT
			tr.elcn_personid
			, tr.Value 
		FROM
			#temp_ratings TR
		WHERE
			elcn_ratingtypeid =  '88C5BD4A-BF21-4635-B8BB-EBE956F2E5BD' 
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
			elcn_ratingtypeid = '1BB294D5-53D7-4815-8963-096802773E6D'			 		
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
			elcn_ratingtypeid = '3DE9ACBB-37E5-45AF-8902-2314FC2A9538'
		)RATINGS2 ON const.contactid = ratings2.elcn_personid  

	LEFT JOIN #temp_recognitioncredit recognitioncredit
		ON const.ContactId = recognitioncredit.elcn_person

	LEFT JOIN(
		SELECT
			personid,
			consecyears PREV_CONSEC_YEARS
		FROM
			(
				SELECT 
					personid
					, givingyear
					, consecyears
					, ROW_NUMBER() OVER (PARTITION BY personid ORDER BY givingyear DESC, consecyears DESC) RN
				FROM
					w_get_consec_years
			) T
		WHERE 
			rn = 1
		)CONSEC ON const.contactid = consec.personid 
	LEFT JOIN(
		SELECT
			personid,
			MAX(consecyears) LONGEST_CONSEC_YEARS
		FROM
			w_get_consec_years
		GROUP BY personid
		)LONGEST_CONSEC on const.contactid = longest_consec.personid

	LEFT JOIN(
		SELECT
			elcn_PrimaryMemberPersonId
			, elcn_name
			, status_desc
			, elcn_membershipnumber
			, elcn_expiredate
		FROM
			#temp_membership
		WHERE
			(	elcn_name not like 'FAN%'
				AND elcn_name not like 'WON%'
			) AND rn = 1
	) GEN_MEMBERSHIP ON const.contactid = gen_membership.elcn_PrimaryMemberPersonId

	LEFT JOIN(
		SELECT
			elcn_PrimaryMemberPersonId
			, elcn_name
			, status_desc
			, elcn_membershipnumber
			, elcn_expiredate
		FROM
			#temp_membership
		WHERE
			elcn_name like 'FAN%'
			AND rn = 1
	) FAN_MEMBERSHIP ON const.contactid = fan_membership.elcn_PrimaryMemberPersonId

	LEFT JOIN(
		SELECT
			elcn_PrimaryMemberPersonId
			, elcn_name
			, status_desc
			, elcn_membershipnumber
			, elcn_expiredate
		FROM
			#temp_membership
		WHERE
			elcn_name like 'WON%'
	) WON_MEMBERSHIP ON const.contactid = won_membership.elcn_PrimaryMemberPersonId

	LEFT JOIN elcn_emailaddressbase eab
		ON  const.contactid = eab.elcn_personid 
		AND eab.elcn_preferred = 1

	LEFT JOIN #temp_email_slot email_slot
		ON const.contactid = email_slot.elcn_personid

	LEFT JOIN(
		SELECT
			elcn_personid, 
			elcn_phonenumber, 
			elcn_type , 
			elcn_preferred 
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
		    elcn_person 
			, SUM(elcn_contributionBase.elcn_Amount) pledge_total
		FROM
			elcn_contribution 
			JOIN elcn_contributiondonorBase 
				ON elcn_contribution.elcn_contributionId = elcn_contributiondonorBase.elcn_contribution
			JOIN elcn_contributionBase 
				ON elcn_contribution.elcn_PaymentforContribution = elcn_contributionBase.elcn_contributionId
		WHERE
			elcn_contributionBase.statuscode = 1
			AND elcn_contribution.elcn_contributionType = 344220003 
			AND elcn_contributiondonorBase.elcn_AssociationTypeId = '36FA0E30-6248-E411-941F-0050568068B8'
		GROUP BY elcn_person 
	) Lifetime_Pledge ON const.ContactId = Lifetime_Pledge.elcn_person
	
	LEFT JOIN(
		SELECT
			elcn_person
			, SUM(elcn_contributionBase.elcn_Amount) pledge_total
		FROM
			elcn_contribution 
			JOIN elcn_contributiondonorBase 
				ON elcn_contribution.elcn_contributionId = elcn_contributiondonorBase.elcn_contribution
			JOIN elcn_contributionBase 
				ON elcn_contribution.elcn_PaymentforContribution = elcn_contributionBase.elcn_contributionId
		WHERE
			elcn_contributionBase.statuscode = 1
			AND elcn_contribution.elcn_contributionType = 344220003 
			AND elcn_contributiondonorBase.elcn_ContributionDate BETWEEN @p_StartDate AND @p_EndDate
			AND elcn_contributiondonorBase.elcn_AssociationTypeId = '36FA0E30-6248-E411-941F-0050568068B8' 
		GROUP BY elcn_person 
	) period_pledge ON const.ContactId = period_pledge.elcn_person

	LEFT JOIN(
		SELECT DISTINCT 
			elcn_person
			, SUM(elcn_RecognitionCredit) Total_Giving
			, SUM(elcn_TotalPremiumFairMarketValue)  Total_Premiums
			, SUM(elcn_contribution.elcn_marketValue) Total_Fair_Market_Value
		FROM
			elcn_contributiondonorBase
			JOIN elcn_contribution  
				ON elcn_contributiondonorBase.elcn_contribution = elcn_contribution.elcn_contributionId
		WHERE
			elcn_contribution.statuscode = 1
			AND elcn_contribution.elcn_contributionType IN (344220000, 
															344220001, 
															344220004,
															344220005) 
			and elcn_contributiondonorBase.elcn_ContributionDate BETWEEN @p_StartDate AND @p_EndDate
		GROUP BY elcn_person 
			)period_totals ON const.ContactId = period_totals.elcn_person
	LEFT JOIN(
		SELECT DISTINCT 
			elcn_person
			, SUM(elcn_contribution.elcn_TotalPremiumFairMarketValue)  Lifetime_Premiums
			, SUM(elcn_contribution.elcn_marketValue)  Lifetime_Fair_Market_Value
		FROM
			elcn_contributiondonorBase
			JOIN elcn_contribution  
				ON elcn_contributiondonorBase.elcn_contribution = elcn_contribution.elcn_contributionId
		WHERE
		
			elcn_contribution.statuscode = 1
			AND elcn_contribution.elcn_contributionType IN (344220000, 
															344220001, 
															344220004, 
															344220005)
		GROUP BY 
			elcn_person 
		)lifetime_totals ON const.ContactID = lifetime_totals.elcn_person

	LEFT JOIN elcn_personalrelationshipBase SPOUSE_LINK 
		ON const.ContactId = spouse_link.elcn_Person1Id
			AND spouse_link.elcn_RelationshipType1ID IN ( '42295D4F-A6EE-E411-942F-005056804B43', 
														'4F665855-A3B8-E911-80D8-0A253F89019C',
														'62295D4F-A6EE-E411-942F-005056804B43',
														'43665855-A3B8-E911-80D8-0A253F89019C')	
			AND spouse_link.elcn_EndDate is null
			AND spouse_link.statuscode = 1
	LEFT JOIN elcn_personalrelationshiptype prt 
		ON spouse_link.elcn_RelationshipType1Id  = prt.elcn_personalrelationshiptypeid 
	LEFT JOIN ContactBase spouse_p 
		ON spouse_link.elcn_Person2Id = spouse_p.ContactId

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
			elcn_personid
			, STRING_AGG(acts.elcn_name + ' (' + acts.ayears + ')', '; ') ALIST
		FROM
			#temp_activities ACTS
		GROUP BY
			elcn_personid 
	)ACTIVITIES ON const.contactid = activities.elcn_personid
		
WHERE		
		EXISTS(
			SELECT
				ib.elcn_name 
			FROM
				elcn_involvementBase IB
			WHERE
				ib.elcn_personid = const.contactid
				AND ib.elcn_name in (@p_activities)						
			UNION
			SELECT
				1 x
			WHERE 
				@p_ignore_activities = 'Y'	
			)
	AND(
		EXISTS(
			SELECT 
				edu.Degree_Year
			FROM
				#temp_education edu
			WHERE
				edu.elcn_PersonId = const.contactid
				AND edu.Degree_Year in (@p_academic_years)
			UNION
			SELECT
				1 x
			WHERE
				@p_ignore_academic_years = 'Y'
		)
	)

--and const.Primary_Name like '%Mutzig%'
--and id in ('N00149607','N00148562','N00005419')
and const.ContactId = '9D67DD91-B3CA-4AA7-BFCC-49BEE53AF420'
;