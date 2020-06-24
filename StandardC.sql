/*
IF OBJECT_ID('tempdb..#temp_membership') IS NOT NULL DROP TABLE #temp_membership
GO

SELECT
	e.elcn_PersonID,
	e.elcn_educationid,
	d.elcn_code DEGREE,
	d.elcn_Name AS Degree_Name,
	e.elcn_DegreeYear Degree_Year,
	ib.elcn_name AS Institution_Name,
	alb.elcn_name as Academic_Level,
	cb.elcn_name AS College,
	apb.elcn_name AS Academic_Program,
	(
		Select TOP 1 mb.elcn_name FROM elcn_education_elcn_majorBase emb
		INNER JOIN elcn_majorBase mb ON mb.elcn_majorId = emb.elcn_majorid
		Where emb.elcn_educationid = e.elcn_educationId
	) AS Major,
	ROW_NUMBER() OVER(PARTITION BY e.elcn_personId 
					--ORDER BY e.elcn_institutionpreferred DESC, e.createdon ASC) as rank_no
					ORDER BY e.elcn_DegreeYear DESC) AS RANK_NO
INTO #temp_education
FROM dbo.elcn_educationBase e
	INNER JOIN elcn_degreeBase d on d.elcn_degreeId = e.elcn_DegreeId
	INNER JOIN elcn_institutionBase ib on ib.elcn_institutionId = e.elcn_InstitutionId
	LEFT OUTER JOIN elcn_academiclevelBase alb ON alb.elcn_academiclevelId = e.elcn_academicLevel
	LEFT OUTER JOIN elcn_collegeBase cb on cb.elcn_collegeid = e.elcn_collegeId

	LEFT OUTER JOIN elcn_academicprogramBase apb ON apb.elcn_academicprogramId = e.elcn_academicprogramId 
WHERE e.statuscode = 1

CREATE NONCLUSTERED INDEX INDX_TMP_EDUCATION_RANKS ON #temp_education (elcn_personId)

Select * from #temp_education where elcn_personid = '9749076E-AF8D-4CB7-8C13-207DB8881012' order by 1

IF OBJECT_ID('tempdb..#temp_aprsalu') IS NOT NULL DROP TABLE #temp_aprsalu
GO

	select 
		elcn_personid,
		CASE elcn_typeid 
			WHEN '1172C46B-462D-E411-9415-005056804B43' THEN 'CIFE'
			WHEN '0F72C46B-462D-E411-9415-005056804B43' THEN 'SIFE'
			WHEN '1B72C46B-462D-E411-9415-005056804B43' THEN 'SIFL'
			WHEN '89799F16-C4E8-4269-B409-5756998F193F' THEN 'CIFL'
			ELSE cast(elcn_typeid as varchar(40))
		END AS SALU_CODE,
		/*max(elcn_formattedname)*/ elcn_formattedname
	INTO
		#temp_aprsalu
	FROM
		elcn_formattednamebase
	WHERE
		elcn_typeid in ('1172C46B-462D-E411-9415-005056804B43', -- Joint Mailing Name (CIFE)
			    		 '0F72C46B-462D-E411-9415-005056804B43', --Mailing Name (SIFE)
	     				 '1B72C46B-462D-E411-9415-005056804B43', --Casual Salutation (SIFL)
		    			 '89799F16-C4E8-4269-B409-5756998F193F') --Casual Joint Saluation (CIFL)
		--AND elcn_personid = 'E9397505-12EC-42DD-94D3-DC5F3E089E80'
--	group by elcn_personid
;
CREATE NONCLUSTERED INDEX INDX_TMP_ID_SALU ON #temp_aprsalu (elcn_personId,salu_code);


--select * from #temp_aprsalu where elcn_personid = 'E9397505-12EC-42DD-94D3-DC5F3E089E80'
---------------
select distinct 
	elcn_person personid,
	datepart(YYYY,elcn_ContributionDate)givingyear,
	datepart(YYYY,elcn_ContributionDate) -1 prevyear
into #temp_dontations
from elcn_contributiondonorBase 
--where elcn_person = 'E9397505-12EC-42DD-94D3-DC5F3E089E80'
;
CREATE NONCLUSTERED INDEX INDX_TMP_ID_YEAR ON #temp_donations (personId,givingyear desc);


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
	-- membership name
	--elcn_membershipBase.elcn_MembershipLevelId , -- 9B3592D4-249A-474A-AE24-328CAE05B127
	elcn_membershipprogramlevelbase.elcn_name ,
	
	-- membership status
	--elcn_membershipBase.elcn_MembershipStatusId ,  --378DE114-EB09-E511-943C-0050568068B7
	elcn_statusbase.elcn_name status,

	-- membership number
	elcn_membershipBase.elcn_MembershipNumber , --7701
	
	-- expiration date
	CONVERT(DATE, elcn_membershipBase.elcn_ExpireDate) elcn_ExpireDate  -- null
INTO #temp_membership
FROM
	elcn_membershipBase
	JOIN elcn_membershipprogramlevelbase
		ON elcn_membershipBase.elcn_MembershipLevelId = elcn_membershipprogramlevelid
		--AND (	elcn_membershipBase.elcn_ExpireDate is null
		--	OR	elcn_membershipBase.elcn_ExpireDate > getdate()
		--	)
	JOIN elcn_statusbase
		ON elcn_membershipBase.elcn_MembershipStatusId  = elcn_statusid

--where elcn_PrimaryMemberPersonId = 'E9397505-12EC-42DD-94D3-DC5F3E089E80'
;
CREATE NONCLUSTERED INDEX INDX_TMP_ID_MEMBERSHIP ON #temp_membership (elcn_primarymemberpersonid);

*/--
--------------T O P 
--
--
--

with w_get_consec_years AS ( -- (PersonId, GivingYear, prevyear, yearchain, consecyears) 
--anchor 
	select personid,
		givingyear,
		prevyear,
		1 consecyears
	from #temp_dontations
	--where givingyear = 2018 << datepart(YYYY, @p_EndDate) 
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
			-- and cte.givingyear between datepart(YYYY,@p_StartDate) and datepart(YYYY, @p_EndDate)
--termination

),
	w_get_longest_consec_years AS ( -- (PersonId, GivingYear, prevyear, yearchain, consecyears) 
--anchor 
	select personid,
		givingyear,
		prevyear,
		1 consecyears
	from #temp_dontations
	--where givingyear = 2018 << datepart(YYYY, @p_EndDate) 
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
--select * from w_get_consec_years 
--order by personid,givingyear desc;

SELECT
	cb.ContactId,
	
	CASE
		WHEN cb.elcn_dateofdeath IS NULL THEN 'N' -- not dead
		ELSE 'Y'
	END			AS		DECEASED_IND,
	cb.elcn_dateofbirth		DATE_OF_BIRTH,
	cb.elcn_PrimaryID	pidm,
	cb.datatel_EnterpriseSystemId ID,
	cb.fullname as Primary_Name, -- NAME

	( --- Brad's - not in standard c proc. Keep?
		SELECT TOP 1
		pnb.elcn_firstname
		FROM elcn_personnameBase pnb
		WHERE pnb.elcn_nametype = 'EBC22907-A5CB-4270-8947-C5381D1ECC54' /*Preferred First Name*/
		AND pnb.elcn_EndDate IS NULL
		AND pnb.statuscode =1
		AND pnb.elcn_personid = cb.contactid
		ORDER BY pnb.CreatedOn
	) AS Preferred_First_Name,

	cb.lastname as Last_Name, -- PREF_LAST_NAME

	(
		SELECT TOP 1
		pnb.elcn_lastname
		FROM elcn_personnameBase pnb
		WHERE pnb.elcn_nametype = '29C69522-08C1-48E3-A030-F417A0E741C0' /*Maiden Name*/
		AND pnb.elcn_EndDate IS NULL
		AND pnb.statuscode = 1
		AND pnb.elcn_personid = cb.contactid
		ORDER BY pnb.CreatedOn
	) AS MAIDEN_LAST_NAME,

/*	(
		SELECT TOP 1
			elcn_formattedname
		FROM
			#temp_aprsalu salu
		WHERE
			cb.contactid = salu.elcn_personid 
			AND salu.salu_code IN ('CIFE','SIFE')
		ORDER BY CASE WHEN salu.salu_code = 'CIFE' THEN 1 ELSE 2 END
	) AS PREFERRED_FULL_W_SALUTATION,
*/
	COALESCE(cife_salu.elcn_formattedname,sife_salu.elcn_formattedname) PREFERRED_FULL_W_SALUTATION,
	
/*	(
		SELECT TOP 1
			elcn_formattedname
		FROM
			#temp_aprsalu salu
		WHERE
			cb.contactid = salu.elcn_personid 
			AND salu.salu_code IN ('CIFL','SIFL')
		ORDER BY CASE WHEN salu.salu_code = 'CIFL' THEN 1 ELSE 2 END
	) AS PREFERRED_SHORT_W_SALUTATION,
*/
	COALESCE(cifl_salu.elcn_formattedname,sifl_salu.elcn_formattedname) PREFERRED_SHORT_W_SALUTATION,
	sife_salu.elcn_formattedname SIFE,
	sifl_salu.elcn_formattedname SIFL,

	ctb.value	Primary_Constituent_Type, -- PREF_DONOR_CATEGORY
	ctb.elcn_type AS Primary_Constituent_Desc, -- PREF_DONOR_CATEGORY_DESC

	ab.elcn_street1 AS Street_Line1,
	ab.elcn_street2 AS Street_Line2,
	ab.elcn_City AS City,
	spb.elcn_Abbreviation as State_Province,
	ab.elcn_postalcode AS Postal_Code,
	ab.elcn_county	County,
	dcb.Datatel_name as Nation,
	atb.elcn_type AS Preferred_Address_Type, --ADDRESS_TYPE

-- Exclusion categories in ATVEXCL
--	NPH - No Phone
	(CASE WHEN(
		SELECT COUNT(*) FROM elcn_contactpreferenceBase cpb
		WHERE cpb.elcn_ContactPreferenceTypeId = '112A7585-A2D9-E911-80D8-0A253F89019C' /*Communications*/
		AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6' /*Exclude*/
		AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
		AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/
		AND cpb.elcn_MethodofContact = 344220001 /*Phone*/
		AND cpb.elcn_personId = cb.ContactId
		) > 0 THEN 'NPH' ELSE NULL END) AS NPH,

--	NOC - No Contact
	(CASE WHEN(
		SELECT COUNT(*) FROM elcn_contactpreferenceBase cpb
		WHERE cpb.elcn_ContactPreferenceTypeId = '76EA8AA5-2F36-4E8E-BFB2-490677DCF4B4' /*Global Restriction*/
		AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6' /*Exclude*/
		AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
		AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/
		AND cpb.elcn_MethodofContact = 344220006 /*All*/
		AND cpb.elcn_personId = cb.ContactId
		) > 0 THEN 'NOC' ELSE NULL END) AS NOC,

--	NMC - No Mail Contact
	(CASE WHEN(
		SELECT COUNT(*) FROM elcn_contactpreferenceBase cpb
		WHERE cpb.elcn_ContactPreferenceTypeId = '112A7585-A2D9-E911-80D8-0A253F89019C' /*Communications*/
		AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6' /*Exclude*/
		AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
		AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/
		AND cpb.elcn_MethodofContact = 344220000 /*Letter*/
		AND cpb.elcn_personId = cb.ContactId
		) > 0 THEN 'NMC' ELSE NULL END) AS NMC,

--	NEM - No E-mail
	(CASE WHEN(
		SELECT COUNT(*) FROM elcn_contactpreferenceBase cpb
		WHERE cpb.elcn_ContactPreferenceTypeId = '112A7585-A2D9-E911-80D8-0A253F89019C' /*Communications*/
		AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6' /*Exclude*/
		AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
		AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/
		AND cpb.elcn_MethodofContact = 344220002 /*Email*/
		AND cpb.elcn_personId = cb.ContactId
		) > 0 THEN 'NEM' ELSE NULL END) AS NEM,

--	NAM - No Alumni Association Mailings
	(CASE WHEN(
		SELECT COUNT(*) FROM elcn_contactpreferenceBase cpb
		WHERE cpb.elcn_ContactPreferenceTypeId = 'EE8CE7BD-9CB8-E911-80D8-0A253F89019C' /*Alumni / Club Chapter Mailings*/
		AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6' /*Exclude*/
		AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
		AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/
		AND cpb.elcn_MethodofContact = 344220000 /*Letter*/
		AND cpb.elcn_personId = cb.ContactId
		) > 0 THEN 'NAM' ELSE NULL END) AS NAM,


--	NDN - No Donation Solicitations
	(CASE WHEN(
		SELECT COUNT(*) FROM elcn_contactpreferenceBase cpb
		WHERE cpb.elcn_ContactPreferenceTypeId = 'e4e02dc6-3314-e511-9431-005056804b43' /*Solicitations*/
		AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6' /*Exclude*/
		AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
		AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/
		AND cpb.elcn_MethodofContact = 344220006 /*All*/
		AND cpb.elcn_personId = cb.ContactId
		) > 0 THEN 'NDN' ELSE NULL END) AS NDN,

--	NAK - No Acknowledgement Letters
	(CASE WHEN(
		SELECT COUNT(*) FROM elcn_contactpreferenceBase cpb
		WHERE cpb.elcn_ContactPreferenceTypeId = 'DEE02DC6-3314-E511-9431-005056804B43' /*Acknowledgements*/
		AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6' /*Exclude*/
		AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
		AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/
		AND cpb.elcn_MethodofContact = 344220000 /*Letter*/
		AND cpb.elcn_personId = cb.ContactId
		) > 0 THEN 'NAK' ELSE NULL END) AS NAK,

--	NTP - No Third Party Solicitations
	(CASE WHEN(
		SELECT COUNT(*) FROM elcn_contactpreferenceBase cpb
		WHERE cpb.elcn_ContactPreferenceTypeId = 'e4e02dc6-3314-e511-9431-005056804b43' /*Solicitations*/
		AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6' /*Exclude*/
		AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
		AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/
		AND cpb.elcn_MethodofContact = 344220006 /*All*/
		AND cpb.elcn_personId = cb.ContactId
		) > 0 THEN 'NTP' ELSE NULL END) AS NTP,


--	AMS - Donation Anonymous - 6/18 no one has an anon restriction
/*	(CASE WHEN(
		SELECT COUNT(*) FROM elcn_contactpreferenceBase cpb
		WHERE cpb.elcn_ContactRestrictionId = '404E206F-9EB8-E911-80D8-0A253F89019C' /*Donation Anonymous*/
		AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
		AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/
		AND cpb.elcn_personId = cb.ContactId
		) > 0 THEN 'AMS' ELSE NULL END) AS AMS
*/
--->> ATVEXCL/Legacy codes spreadsheet

	cb.anonymityType Anonymity_Type,
	--'?' Mail_Codes,  -- 86'ed per Molly

--->> RATINGS

	ratings1.rating_type RATING_TYPE1,
	ratings1.rating_score RATING_AMOUNT1,
	ratings1.rating_value RATING1,
	ratings1.rating_level RATING_LEVEL1,

	ratings2.rating_type RATING_TYPE2,
	ratings2.rating_score RATING_AMOUNT2,
	ratings2.rating_value RATING2,
	ratings2.rating_level RATING_LEVEL2,
	
	null RATING_TYPE3,
	null RATING_AMOUNT3,
	null RATING3,
	null RATING_LEVEL3,


	(
		SELECT
			COUNT(elcn_RecognitionCredit)
		FROM
			elcn_contributiondonorBase
			JOIN elcn_contribution  
				ON elcn_contributiondonorBase.elcn_contribution = elcn_contribution.elcn_contributionId
		WHERE
			elcn_contributiondonorBase.elcn_person = cb.ContactId
			AND elcn_contribution.statuscode = 1
			AND elcn_contribution.elcn_contributionType IN (344220000, -- Gift
															344220001, -- Pledge
															344220004, -- Matching Gift
															344220005) -- Bequest Expectancy
			--and elcn_contributiondonorBase.elcn_ContributionDate BETWEEN @p_StartDate AND @p_EndDate
		) Lifetime_Number_of_Gifts, --TOTAL_NO_GIFTS

	cb.elcn_LargestContributionAmount Largest_Contribution_Amount, -- HIGH_GIFT_AMT
	CONVERT(VARCHAR,cb.elcn_LastContributionDate,101) Last_Contibution_Date, -- LAST_GIFT_DATE 12/30/2006 format

	jfsg_est_cap.elcn_ratingvalue JFSG_Estimated_Capacity,

	(
		SELECT
			SUM(elcn_RecognitionCredit)
		FROM
			elcn_contributiondonorBase
			JOIN elcn_contribution  
				ON elcn_contributiondonorBase.elcn_contribution = elcn_contribution.elcn_contributionId
		WHERE
			elcn_contributiondonorBase.elcn_person = cb.ContactId
			AND elcn_contribution.statuscode = 1
			AND elcn_contribution.elcn_contributionType IN (344220000, -- Gift
															344220001, -- Pledge
															344220004, -- Matching Gift
															344220005) -- Bequest Expectancy
			and datepart(YYYY,elcn_contributiondonorBase.elcn_ContributionDate) = datepart(YYYY,sysdatetime())
	) Gifts_YTD,  

	(
		SELECT
			SUM(elcn_RecognitionCredit)
		FROM
			elcn_contributiondonorBase
			JOIN elcn_contribution  
				ON elcn_contributiondonorBase.elcn_contribution = elcn_contribution.elcn_contributionId
		WHERE
			elcn_contributiondonorBase.elcn_person = cb.ContactId
			AND elcn_contribution.statuscode = 1
			AND elcn_contribution.elcn_contributionType IN (344220000, -- Gift
															344220001, -- Pledge
															344220004, -- Matching Gift
															344220005) -- Bequest Expectancy
			and datepart(YYYY,elcn_contributiondonorBase.elcn_ContributionDate) = datepart(YYYY,sysdatetime()) -1
	) Gifts_Year2,
	(
		SELECT
			SUM(elcn_RecognitionCredit)
		FROM
			elcn_contributiondonorBase
			JOIN elcn_contribution  
				ON elcn_contributiondonorBase.elcn_contribution = elcn_contribution.elcn_contributionId
		WHERE
			elcn_contributiondonorBase.elcn_person = cb.ContactId
			AND elcn_contribution.statuscode = 1
			AND elcn_contribution.elcn_contributionType IN (344220000, -- Gift
															344220001, -- Pledge
															344220004, -- Matching Gift
															344220005) -- Bequest Expectancy
			and datepart(YYYY,elcn_contributiondonorBase.elcn_ContributionDate) = datepart(YYYY,sysdatetime()) -2
	) Gifts_Year3,
	(
		SELECT
			SUM(elcn_RecognitionCredit)
		FROM
			elcn_contributiondonorBase
			JOIN elcn_contribution  
				ON elcn_contributiondonorBase.elcn_contribution = elcn_contribution.elcn_contributionId
		WHERE
			elcn_contributiondonorBase.elcn_person = cb.ContactId
			AND elcn_contribution.statuscode = 1
			AND elcn_contribution.elcn_contributionType IN (344220000, -- Gift
															344220001, -- Pledge
															344220004, -- Matching Gift
															344220005) -- Bequest Expectancy
			and datepart(YYYY,elcn_contributiondonorBase.elcn_ContributionDate) = datepart(YYYY,sysdatetime()) -3
	) Gifts_Year4,

	longest_consec.longest_consec_years  LONGEST_CONS_YEARS_GIVEN,
	consec.consecyears RECENT_CONSECUTIVE_YEARS,

	gen_membership.elcn_name MEMBERSHIP_NAME,
	gen_membership.status MEMBERSHIP_STATUS,
	gen_membership.elcn_membershipnumber MEMBERSHIP_NUMBER,
	gen_membership.elcn_expiredate EXPIRATION_DATE,

	won_membership.elcn_name WON_MEMBERSHIP_NAME,
	won_membership.status WON_MEMBERSHIP_STATUS,
	won_membership.elcn_membershipnumber WON_MEMBERSHIP_NUMBER,
	won_membership.elcn_expiredate	WON_EXPIRATION_DATE,

	fan_membership.elcn_name FAN_MEMBERSHIP_NAME,
	fan_membership.status FAN_MEMBERSHIP_STATUS,
	fan_membership.elcn_membershipnumber FAN_MEMBERSHIP_NUMBER,
	fan_membership.elcn_expiredate FAN_EXPIRATION_DATE,

	eab.elcn_name EMAIL_PREFERRED_ADDRESS,
/*
PERS_EMAIL
NSU_EMAIL
AL_EMAIL
BUS_EMAIL
PR_PHONE_NUMBER
PR_PRIMARY_IND
CL_PHONE_NUMBER
CL_PRIMARY_IND
B1_PHONE_NUMBER
B1_PRIMARY_IND


*******************/
--TOTAL_PLEDGE_PAYMENTS1
/*
	(cb.elcn_totalpledges - cb.elcn_TotalPledgesOutstanding) Total_Lifetime_Pladge_Payments, --Total Lifetime Pladge Payments

	(
		SELECT
			SUM(elcn_RecognitionCredit)
		FROM
			elcn_contributiondonorBase
			JOIN elcn_contribution  
				ON elcn_contributiondonorBase.elcn_contribution = elcn_contribution.elcn_contributionId
		WHERE
			elcn_contributiondonorBase.elcn_person = cb.ContactId
			AND elcn_contribution.statuscode = 1
			AND elcn_contribution.elcn_contributionType IN (344220001) -- Pledge
			--and elcn_contributiondonorBase.elcn_ContributionDate BETWEEN @p_StartDate AND @p_EndDate
	) Pledges_For_Period,

*/
	(
		SELECT
			SUM(elcn_contributionBase.elcn_Amount)
		FROM
			elcn_contribution --PAYMENT
			JOIN elcn_contributiondonorBase 
				ON elcn_contribution.elcn_contributionId = elcn_contributiondonorBase.elcn_contribution
			JOIN elcn_contributionBase --PLEDGE
				ON elcn_contribution.elcn_PaymentforContribution = elcn_contributionBase.elcn_contributionId
		WHERE
			elcn_contributiondonorBase.elcn_person = cb.ContactId
			AND elcn_contributionBase.statuscode = 1
			AND elcn_contribution.elcn_contributionType = 344220003 -- Pledge Payment
			--AND elcn_contributiondonorBase.elcn_ContributionDate BETWEEN @p_StartDate AND @p_EndDate
			AND elcn_contributiondonorBase.elcn_AssociationTypeId = '36FA0E30-6248-E411-941F-0050568068B8' -- Primary only, If incl Spouse, would need to include Group/Joint
	) Total_Pledge_Payments, --Total Pledge Payments


-- LIFE_TOTAL_GIVING
	cb.elcn_totalGiving Total_Lifetime_Giving,

-- LIFE_TOTAL_GIVING_AUX -- total of fair market value of all contributions except dues payments

-- FISCAL_YEAR1

-- TOTAL_GIVING1
	( 
		SELECT
			SUM(elcn_RecognitionCredit)
		FROM
			elcn_contributiondonorBase
			JOIN elcn_contribution  
				ON elcn_contributiondonorBase.elcn_contribution = elcn_contribution.elcn_contributionId
		WHERE
			elcn_contributiondonorBase.elcn_person = cb.ContactId
			AND elcn_contribution.statuscode = 1
			AND elcn_contribution.elcn_contributionType IN (344220000, -- Gift
															344220001, -- Pledge
															344220004, -- Matching Gift
															344220005) -- Bequest Expectancy
			--and elcn_contributiondonorBase.elcn_ContributionDate BETWEEN @p_StartDate AND @p_EndDate
	) Total_Giving_For_Period,

	(
		SELECT
			SUM(elcn_contribution.elcn_marketValue)
		FROM
			elcn_contributiondonorBase
			JOIN elcn_contribution  
				ON elcn_contributiondonorBase.elcn_contribution = elcn_contribution.elcn_contributionId
		WHERE
			elcn_contributiondonorBase.elcn_person = cb.ContactId
			AND elcn_contribution.statuscode = 1
			AND elcn_contribution.elcn_contributionType IN (344220000, -- Gift
															344220001, -- Pledge
															344220004, -- Matching Gift
															344220005) -- Bequest Expectancy
			--and elcn_contributiondonorBase.elcn_ContributionDate BETWEEN @p_StartDate AND @p_EndDate
	) Total_Fair_Market_Value, --Total Fair Market Value (For given date range)

	(
		SELECT
			SUM(elcn_contribution.elcn_marketValue)
		FROM
			elcn_contributiondonorBase
			JOIN elcn_contribution  
				ON elcn_contributiondonorBase.elcn_contribution = elcn_contribution.elcn_contributionId
		WHERE
			elcn_contributiondonorBase.elcn_person = cb.ContactId
			AND elcn_contribution.statuscode = 1
			AND elcn_contribution.elcn_contributionType IN (344220000, -- Gift
															344220001, -- Pledge
															344220004, -- Matching Gift
															344220005) -- Bequest Expectancy
			
	) Total_Lifetime_Fair_Market_Value,--Total Lifetime Fair Market Value
/**************************
ANNUAL_HOUSEHOLD_GIVING -- Householding tools in CRM 3.0
LIFETIME_HOUSEHOLD_GIVING -- Householding tools in CRM 3.0
**************************/

/*

RELATION_SOURCE
RELATION_SOURCE_DESC
COMBINED_MAILING_PRIORITY
COMBINED_MAILING_PRIORITY_DESC
HOUSEHOLD_IND
DATE_RANGE_TOTAL_GIVING
DATE_RANGE_TOTAL_AUX_AMT

*/
	edu_1.Degree Degree, --DEGREE_1
	edu_1.Degree_Name AS Degree1_Degree,--DEGREE_DESC_1
	--MAJOR_1 -- program codes are not mapped from APRAMAJ
	edu_1.Major AS Degree1_Major, --MAJOR_DESC_1
	edu_1.Degree_Year Degree1_Degree_Year, --DEGREE_YEAR_1

	edu_2.Degree Degree, --DEGREE_2
	edu_2.Degree_Name AS Degree2_Degree,--DEGREE_DESC_2
--MAJOR_2
	edu_2.Major AS Degree2_Major,--MAJOR_DESC_2
	edu_2.Degree_Year Degree2_Degree_Year, --DEGREE_YEAR_2

	edu_3.Degree Degree,--DEGREE_3
	edu_3.Degree_Name AS Degree3_Degree,--DEGREE_DESC_3
--MAJOR_3
	edu_3.Major AS Degree3_Major,--MAJOR_DESC_3
	edu_3.Degree_Year Degree3_Degree_Year --DEGREE_YEAR_3



--edu_1.Academic_Level AS Degree1_Academic_Level,
--edu_2.Academic_Level AS Degree2_Academic_Level,
--edu_3.Academic_Level AS Degree3_Academic_Level,

--edu_1.College AS Degree1_College,
--edu_2.College AS Degree2_College,
--edu_3.College AS Degree3_College,

--edu_1.Academic_Program AS Degree1_Acadmic_Program,
--edu_2.Academic_Program AS Degree2_Acadmic_Program,
--edu_3.Academic_Program AS Degree3_Acadmic_Program

/*
SPEC_PURPOSE_TYPE -- place of work 
SPEC_PURPOSE_TYPE_DESC
SPEC_PURPOSE_GROUP
SPEC_PURPOSE_GROUP_DESC
EMPLOYER
POSITION

VETERAN_IND
GURIDEN_DESC
ACTIVITIES







cb.SpousesName as Spouse_Name,

spouse_p.elcn_PrimaryID AS Constituent_Spouse_Primary_ID,



(SELECT e.elcn_email FROM elcn_emailaddressBase e where e.elcn_emailaddressId = cb.elcn_preferredemailaddress) AS Preferred_Email_Address,





*/
--select *
FROM(
	SELECT
		contactbase.*,
		elcn_anonymitytypeBase.elcn_type anonymityType
	FROM
		ContactBase
		LEFT JOIN elcn_anonymitytypebase on contactbase.elcn_AnonymityTypeId = elcn_anonymitytypeBase.elcn_anonymitytypeId
	) cb

	LEFT JOIN(
		SELECT
			elcn_personid, elcn_ratingvalue 
		FROM
			elcn_ratingBase 
		WHERE
			elcn_ratingtypeid =  'ED5B6EEF-4798-44F9-878C-CA21057C1B72' -- JFSG Est Capacity-DonorSearch
			AND elcn_RatingDescription = 'Value'
			AND statuscode =1
	) JFSG_EST_CAP ON cb.ContactId = jfsg_est_cap.elcn_personid  

LEFT JOIN elcn_personalrelationshipBase spouse_r ON spouse_r.elcn_Person1Id = cb.ContactId
		AND spouse_r.elcn_RelationshipType1ID = '4F665855-A3B8-E911-80D8-0a253F89019C' /*Spouse / Partner */
		AND spouse_r.statuscode = 1

LEFT JOIN ContactBase spouse_p ON spouse_p.ContactId = spouse_r.elcn_Person2Id

JOIN elcn_constituentaffiliationBase cab ON cab.elcn_constituentaffiliationId = cb.elcn_primaryconstituentaffiliationid

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

LEFT OUTER JOIN elcn_addressassociationBase aab ON aab.elcn_personId = cb.ContactId AND aab.elcn_Preferred =1

LEFT OUTER JOIN elcn_addressBase ab ON ab.elcn_addressId = aab.elcn_AddressId

LEFT OUTER JOIN elcn_stateprovinceBase spb ON spb.elcn_stateprovinceId = ab.elcn_StateProvinceId
LEFT OUTER JOIN Datatel_countryBase dcb ON dcb.Datatel_countryId = ab.elcn_country
LEFT OUTER JOIN elcn_addresstypeBase atb ON atb.elcn_addresstypeId = aab.elcn_AddressTypeId
LEFT OUTER JOIN #temp_education edu_1 on edu_1.elcn_PersonId = cb.ContactID and edu_1.rank_no = 1
LEFT OUTER JOIN #temp_education edu_2 on edu_2.elcn_PersonId = cb.ContactID and edu_2.rank_no = 2
LEFT OUTER JOIN #temp_education edu_3 on edu_3.elcn_PersonId = cb.ContactID and edu_3.rank_no = 3
	LEFT JOIN(
		SELECT
			elcn_personid,
			elcn_formattedname
		FROM
			#temp_aprsalu salu
		WHERE
			--cb.contactid = salu.elcn_personid 
			salu.salu_code = 'CIFE'
		) CIFE_SALU ON cb.contactid = cife_salu.elcn_personid
	LEFT JOIN(
		SELECT
			elcn_personid,
			elcn_formattedname
		FROM
			#temp_aprsalu salu
		WHERE
			--cb.contactid = salu.elcn_personid 
			salu.salu_code = 'SIFE'
		) SIFE_SALU ON cb.contactid = sife_salu.elcn_personid
	LEFT JOIN(
		SELECT
			elcn_personid,
			elcn_formattedname
		FROM
			#temp_aprsalu salu
		WHERE
			--cb.contactid = salu.elcn_personid 
			salu.salu_code = 'CIFL'
		) CIFL_SALU ON cb.contactid = cifl_salu.elcn_personid
	LEFT JOIN(
		SELECT
			elcn_personid,
			elcn_formattedname
		FROM
			#temp_aprsalu salu
		WHERE
			--cb.contactid = salu.elcn_personid 
			salu.salu_code = 'SIFL'
		) SIFL_SALU ON cb.contactid = sifl_salu.elcn_personid

	LEFT JOIN(
		SELECT
			personid,
			MAX(consecyears) consecyears 
		FROM
			w_get_consec_years
		GROUP BY personid
		)CONSEC ON cb.contactid = consec.personid 
	LEFT JOIN(
		SELECT
			personid,
			MAX(consecyears) LONGEST_CONSEC_YEARS
		FROM
			w_get_longest_consec_years
		GROUP BY personid
		)LONGEST_CONSEC on cb.contactid = longest_consec.personid
	
	LEFT JOIN(
		SELECT
			contactbase.contactid, --ratings.elcn_personid,
			ratings.elcn_ratingtypeid,
			elcn_ratingtypeBase.elcn_type RATING_TYPE,
			ratings.value RATING_VALUE,
			ratings.level RATING_LEVEL,
			ratings.score RATING_SCORE
		FROM 
			contactbase 
				JOIN elcn_ratingtypebase 
					ON elcn_ratingtypeid = '1BB294D5-53D7-4815-8963-096802773E6D'  -- JF Smith Group Top 500			 
				LEFT JOIN #temp_ratings ratings
					ON ratings.elcn_ratingtypeid = elcn_ratingtypebase.elcn_ratingtypeid
					AND ratings.elcn_personid = contactbase.contactid
		)RATINGS1 ON cb.contactid = ratings1.contactid 


		LEFT JOIN(
		SELECT
			contactbase.contactid, --ratings.elcn_personid,
			ratings.elcn_ratingtypeid,
			elcn_ratingtypeBase.elcn_type RATING_TYPE,
			ratings.value RATING_VALUE,
			ratings.level RATING_LEVEL,
			ratings.score RATING_SCORE
		FROM
			contactbase 
				JOIN elcn_ratingtypebase 
					on elcn_ratingtypeid = '3DE9ACBB-37E5-45AF-8902-2314FC2A9538' -- iWave Pro Score
				LEFT JOIN #temp_ratings ratings
					ON ratings.elcn_ratingtypeid = elcn_ratingtypebase.elcn_ratingtypeid
					AND ratings.elcn_personid = contactbase.contactid
		)RATINGS2 ON cb.contactid = ratings2.contactid 

	LEFT JOIN( -- general membership
		SELECT
			elcn_PrimaryMemberPersonId,
			elcn_name,
			status,
			elcn_membershipnumber,
			elcn_expiredate,
			ROW_NUMBER() OVER (PARTITION BY elcn_PrimaryMemberPersonId,elcn_name 
				ORDER BY ISNULL(elcn_expiredate,'31-DEC-2999') DESC) rn
		FROM
			#temp_membership
		WHERE
			(	elcn_name not like 'FAN%'
				AND elcn_name not like 'WON%'
			) 
		
	) GEN_MEMBERSHIP ON cb.contactid = gen_membership.elcn_PrimaryMemberPersonId
			AND gen_membership.rn = 1

	LEFT JOIN( -- Future Alumni Network (FAN) membership
		SELECT
			elcn_PrimaryMemberPersonId,
			elcn_name,
			status,
			elcn_membershipnumber,
			elcn_expiredate,
			ROW_NUMBER() OVER (PARTITION BY elcn_PrimaryMemberPersonId,elcn_name 
				ORDER BY ISNULL(elcn_expiredate,'31-DEC-2999') DESC) rn
		FROM
			#temp_membership
		WHERE
			elcn_name like 'FAN%'
	) FAN_MEMBERSHIP ON cb.contactid = fan_membership.elcn_PrimaryMemberPersonId
			AND fan_membership.rn = 1

	LEFT JOIN( -- Women of Northeastern (WON) membership
		SELECT
			elcn_PrimaryMemberPersonId,
			elcn_name,
			status,
			elcn_membershipnumber,
			elcn_expiredate,
			ROW_NUMBER() OVER (PARTITION BY elcn_PrimaryMemberPersonId,elcn_name 
				ORDER BY ISNULL(elcn_expiredate,'31-DEC-2999') DESC) rn
		FROM
			#temp_membership
		WHERE
			elcn_name like 'WON%'
	) WON_MEMBERSHIP ON cb.contactid = won_membership.elcn_PrimaryMemberPersonId
			AND won_membership.rn = 1

	LEFT JOIN elcn_emailaddressbase eab
		ON eab.elcn_personid = cb.contactid 
		AND eab.elcn_preferred = 1

WHERE
cb.statuscode =1
--and cb.fullname like 'Robert C Sanders'
and cb.datatel_EnterpriseSystemId in ( 'N00156288', 'N00142649') --'N00018518'
--EF350F86-1561-47D1-85ED-FC295CBDD9C5
;
--select * from #temp_membership where elcn_primarymemberpersonid = 'E9397505-12EC-42DD-94D3-DC5F3E089E80';
