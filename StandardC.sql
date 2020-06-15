IF OBJECT_ID('tempdb..#temp_education') IS NOT NULL DROP TABLE #temp_education
GO

SELECT
	e.elcn_PersonID,
	e.elcn_educationid,
	d.elcn_Name AS Degree_name,
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
					ORDER BY e.elcn_institutionpreferred DESC, e.createdon ASC) as rank_no
INTO #temp_education
FROM dbo.elcn_educationBase e
	INNER JOIN elcn_degreeBase d on d.elcn_degreeId = e.elcn_DegreeId
	INNER JOIN elcn_institutionBase ib on ib.elcn_institutionId = e.elcn_InstitutionId
	LEFT OUTER JOIN elcn_academiclevelBase alb ON alb.elcn_academiclevelId = e.elcn_academicLevel
	LEFT OUTER JOIN elcn_collegeBase cb on cb.elcn_collegeid = e.elcn_collegeId

	LEFT OUTER JOIN elcn_academicprogramBase apb ON apb.elcn_academicprogramId = e.elcn_academicprogramId 
WHERE e.statuscode = 1

CREATE NONCLUSTERED INDEX INDX_TMP_EDUCATION_RANKS ON #temp_education (elcn_personId)

--Select * from #temp_education order by 1

	select 
		elcn_personid,
		CASE elcn_typeid 
			WHEN 'A335568A-ECCC-46A4-A229-36D71DBCFCA6' THEN 'CIFE'
			WHEN '0F72C46B-462D-E411-9415-005056804B43' THEN 'SIFE'
			WHEN '1B72C46B-462D-E411-9415-005056804B43' THEN 'SIFL'
			WHEN '89799F16-C4E8-4269-B409-5756998F193F' THEN 'CIFL'
			ELSE null 
		END AS SALU_CODE,
		max(elcn_formattedname) elcn_formattedname
	INTO
		#temp_aprsalu
	FROM
		elcn_formattednamebase
	WHERE
		elcn_typeid in ('A335568A-ECCC-46A4-A229-36D71DBCFCA6', --Formal Join Saluatation (CIFE)
			    		 '0F72C46B-462D-E411-9415-005056804B43', --Mailing Name (SIFE)
	     				 '1B72C46B-462D-E411-9415-005056804B43', --Casual Salutation (SIFL)
		    			 '89799F16-C4E8-4269-B409-5756998F193F') --Casual Joint Saluation (CIFL)
	group by elcn_personid,elcn_typeid

CREATE NONCLUSTERED INDEX INDX_TMP_ID_SALU ON #temp_aprsalu (elcn_personId,salu_code)


---------------

SELECT
	cb.ContactId,
	
	CASE
		WHEN cb.elcn_dateofdeath IS NULL THEN 'N' -- not dead
		ELSE 'Y'
	END			AS		DECEASED_IND,
	cb.elcn_dateofbirth		DATE_OF_BIRTH,
	cb.elcn_PrimaryID	ID,

	cb.fullname as Primary_Name, -- NAME
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

	(
		SELECT TOP 1
			elcn_formattedname
		FROM
			#temp_aprsalu salu
		WHERE
			cb.contactid = salu.elcn_personid 
			AND salu.salu_code IN ('CIFE','SIFE')
		ORDER BY CASE WHEN salu.salu_code = 'CIFE' THEN 1 ELSE 2 END
	) AS PREFERRED_FULL_W_SALUTATION,

	/*
PREFERRED_SHORT_W_SALUTATION

SIFE
SIFL
PREF_DONOR_CATEGORY
PREF_DONOR_CATEGORY_DESC
STREET_LINE1
STREET_LINE2
CITY
STATE_PROVINCE
POSTAL_CODE
COUNTY
NATION
ADDRESS_TYPE
NPH
NOC
NMC
NEM
NAM
NDN
NAK
NTP
AMS
MAIL_CODES
RATING_TYPE1
RATING_AMOUNT1
RATING1
RATING_LEVEL1
RATING_TYPE2
RATING_AMOUNT2
RATING2
RATING_LEVEL2
RATING_TYPE3
RATING_AMOUNT3
RATING3
RATING_LEVEL3
TOTAL_NO_GIFTS
HIGH_GIFT_AMT
LAST_GIFT_DATE
JFSG_ESTIMATED_CAPACITY
DED_AMT_W_YTD_1
DED_AMT_W_YTD_2
DED_AMT_W_YTD_3
DED_AMT_W_YTD_4
LONGEST_CONS_YEARS_GIVEN
RECENT_CONSECUTIVE_YEARS
MEMBERSHIP_NAME
MEMBERSHIP_STATUS
MEMBERSHIP_NUMBER
EXPIRATION_DATE
WON_MEMBERSHIP_NAME
WON_MEMBERSHIP_STATUS
WON_MEMBERSHIP_NUMBER
WON_EXPIRATION_DATE
FAN_MEMBERSHIP_NAME
FAN_MEMBERSHIP_STATUS
FAN_MEMBERSHIP_NUMBER
FAN_EXPIRATION_DATE
EMAIL_PREFERRED_ADDRESS
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
TOTAL_PLEDGE_PAYMENTS1
LIFE_TOTAL_GIVING
LIFE_TOTAL_GIVING_AUX

FISCAL_YEAR1
TOTAL_GIVING1
ANNUAL_HOUSEHOLD_GIVING
LIFETIME_HOUSEHOLD_GIVING
RELATION_SOURCE
RELATION_SOURCE_DESC
COMBINED_MAILING_PRIORITY
COMBINED_MAILING_PRIORITY_DESC
HOUSEHOLD_IND
DATE_RANGE_TOTAL_GIVING
DATE_RANGE_TOTAL_AUX_AMT
DEGREE_1
DEGREE_DESC_1
MAJOR_1
MAJOR_DESC_1
DEGREE_YEAR_1
DEGREE_2
DEGREE_DESC_2
MAJOR_2
MAJOR_DESC_2
DEGREE_YEAR_2
DEGREE_3
DEGREE_DESC_3
MAJOR_3
MAJOR_DESC_3
DEGREE_YEAR_3
SPEC_PURPOSE_TYPE
SPEC_PURPOSE_TYPE_DESC
SPEC_PURPOSE_GROUP
SPEC_PURPOSE_GROUP_DESC
EMPLOYER
POSITION
VETERAN_IND
GURIDEN_DESC
ACTIVITIES
*/




(
	SELECT TOP 1
	pnb.elcn_firstname
	FROM elcn_personnameBase pnb
	WHERE pnb.elcn_nametype = 'EBC22907-A5CB-4270-8947-C5381D1ECC54' /*Preferred First Name*/
	AND pnb.elcn_EndDate IS NULL
	AND pnb.statuscode =1
	AND pnb.elcn_personid = cb.contactid
	ORDER BY pnb.CreatedOn
) AS Preferred_First_Name,

cb.SpousesName as Spouse_Name,

spouse_p.elcn_PrimaryID AS Constituent_Spouse_Primary_ID,

ctb.elcn_type AS Primary_Constituent_Type,

(SELECT e.elcn_email FROM elcn_emailaddressBase e where e.elcn_emailaddressId = cb.elcn_preferredemailaddress) AS Preferred_Email_Address,
ab.elcn_street1 AS Street_Line_1,
ab.elcn_street2 AS Street_Line_2,
ab.elcn_City AS City,
spb.elcn_Abbreviation as [State],
ab.elcn_postalcode AS Postal_Code,
dcb.Datatel_name as Country_Name,
atb.elcn_type AS Preferred_Address_Type,
	(CASE WHEN(
		SELECT COUNT(*) FROM elcn_contactpreferenceBase cpb
		WHERE cpb.elcn_ContactPreferenceTypeId = 'DEE02DC6-3314-E511-9431-005056804B43' /*Acknowledgements*/
		AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6' /*Exclude*/
		AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
		AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/
		AND cpb.elcn_MethodofContact = 344220000 /*Letter*/
		AND cpb.elcn_personId = cb.ContactId
		) > 0 THEN 'NAK' ELSE NULL END) AS NAK,
	(CASE WHEN(
		SELECT COUNT(*) FROM elcn_contactpreferenceBase cpb
		WHERE cpb.elcn_ContactPreferenceTypeId = '76EA8AA5-2F36-4E8E-BFB2-490677DCF4B4' /*Global Restriction*/
		AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6' /*Exclude*/
		AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
		AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/
		AND cpb.elcn_MethodofContact = 344220006 /*All*/
		AND cpb.elcn_personId = cb.ContactId
		) > 0 THEN 'NOC' ELSE NULL END) AS NOC,
	(CASE WHEN(
		SELECT COUNT(*) FROM elcn_contactpreferenceBase cpb
		WHERE cpb.elcn_ContactPreferenceTypeId = 'e4e02dc6-3314-e511-9431-005056804b43' /*Solicitations*/
		AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6' /*Exclude*/
		AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
		AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/
		AND cpb.elcn_MethodofContact = 344220006 /*All*/
		AND cpb.elcn_personId = cb.ContactId
		) > 0 THEN 'NDN' ELSE NULL END) AS NDN,
	(CASE WHEN(
		SELECT COUNT(*) FROM elcn_contactpreferenceBase cpb
		WHERE cpb.elcn_ContactPreferenceTypeId = '112A7585-A2D9-E911-80D8-0A253F89019C' /*Communications*/
		AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6' /*Exclude*/
		AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
		AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/
		AND cpb.elcn_MethodofContact = 344220002 /*Email*/
		AND cpb.elcn_personId = cb.ContactId
		) > 0 THEN 'NEM' ELSE NULL END) AS NEM,
	(CASE WHEN(
		SELECT COUNT(*) FROM elcn_contactpreferenceBase cpb
		WHERE cpb.elcn_ContactPreferenceTypeId = '112A7585-A2D9-E911-80D8-0A253F89019C' /*Communications*/
		AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6' /*Exclude*/
		AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
		AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/
		AND cpb.elcn_MethodofContact = 344220000 /*Letter*/
		AND cpb.elcn_personId = cb.ContactId
		) > 0 THEN 'NMC' ELSE NULL END) AS NMC,
	(CASE WHEN(
		SELECT COUNT(*) FROM elcn_contactpreferenceBase cpb
		WHERE cpb.elcn_ContactPreferenceTypeId = '112A7585-A2D9-E911-80D8-0A253F89019C' /*Communications*/
		AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6' /*Exclude*/
		AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
		AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/
		AND cpb.elcn_MethodofContact = 344220001 /*Phone*/
		AND cpb.elcn_personId = cb.ContactId
		) > 0 THEN 'NPH' ELSE NULL END) AS NPH,
	(CASE WHEN(
		SELECT COUNT(*) FROM elcn_contactpreferenceBase cpb
		WHERE cpb.elcn_ContactPreferenceTypeId = 'e4e02dc6-3314-e511-9431-005056804b43' /*Solicitations*/
		AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6' /*Exclude*/
		AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
		AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/
		AND cpb.elcn_MethodofContact = 344220006 /*All*/
		AND cpb.elcn_personId = cb.ContactId
		) > 0 THEN 'NTP' ELSE NULL END) AS NTP,

--->> ATVEXCL/Legacy codes spreadsheet

edu_1.Degree_Name AS Degree1_Degree,
edu_2.Degree_Name AS Degree2_Degree,
edu_3.Degree_Name AS Degree3_Degree,

edu_1.Major AS Degree1_Major, 
edu_2.Major AS Degree2_Major,
edu_3.Major AS Degree3_Major,

edu_1.Academic_Level AS Degree1_Academic_Level,
edu_2.Academic_Level AS Degree2_Academic_Level,
edu_3.Academic_Level AS Degree3_Academic_Level,

edu_1.College AS Degree1_College,
edu_2.College AS Degree2_College,
edu_3.College AS Degree3_College,

edu_1.Academic_Program AS Degree1_Acadmic_Program,
edu_2.Academic_Program AS Degree2_Acadmic_Program,
edu_3.Academic_Program AS Degree3_Acadmic_Program

--select *
FROM ContactBase cb
LEFT JOIN elcn_personalrelationshipBase spouse_r ON spouse_r.elcn_Person1Id = cb.ContactId
		AND spouse_r.elcn_RelationshipType1ID = '4F665855-A3B8-E911-80D8-0a253F89019C' /*Spouse / Partner */
		AND spouse_r.statuscode = 1
LEFT JOIN ContactBase spouse_p ON spouse_p.ContactId = spouse_r.elcn_Person2Id
INNER JOIN elcn_constituentaffiliationBase cab ON cab.elcn_constituentaffiliationId = cb.elcn_primaryconstituentaffiliationid
LEFT OUTER JOIN elcn_constituenttypeBase ctb ON ctb.elcn_constituenttypeID = cab.elcn_ConstituentTypeId
LEFT OUTER JOIN elcn_addressassociationBase aab ON aab.elcn_personId = cb.ContactId AND aab.elcn_Preferred =1
LEFT OUTER JOIN elcn_addressBase ab ON ab.elcn_addressId = aab.elcn_AddressId
LEFT OUTER JOIN elcn_stateprovinceBase spb ON spb.elcn_stateprovinceId = ab.elcn_country
LEFT OUTER JOIN Datatel_countryBase dcb ON dcb.Datatel_countryId = ab.elcn_country
LEFT OUTER JOIN elcn_addresstypeBase atb ON atb.elcn_addresstypeId = aab.elcn_AddressTypeId
LEFT OUTER JOIN #temp_education edu_1 on edu_1.elcn_PersonId = cb.ContactID and edu_1.rank_no = 1
LEFT OUTER JOIN #temp_education edu_2 on edu_2.elcn_PersonId = cb.ContactID and edu_2.rank_no = 1
LEFT OUTER JOIN #temp_education edu_3 on edu_3.elcn_PersonId = cb.ContactID and edu_3.rank_no = 1
WHERE
cb.statuscode =1
and cb.fullname like 'Robert%Sanders'
EF350F86-1561-47D1-85ED-FC295CBDD9C5