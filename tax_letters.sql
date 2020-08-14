DECLARE @p_fy int = '2019';

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
--WHERE
	--ab.elcn_StateProvinceId in (@p_stateList)
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

SELECT
	cdb.elcn_person
	--, gcb.elcn_Name Gift_Vehicle
	, DATEPART(YYYY,contrib.elcn_contributiondate) fy
	, SUM(COALESCE(contrib.elcn_amount,0)) sum_giving
	, SUM(COALESCE(contrib.elcn_PresentValue,0)) sum_aux
	, SUM(COALESCE(cdb.elcn_softcredit,0)) sum_soft
	, SUM(COALESCE(cpb.elcn_amount,0)) sum_gik

INTO
	#temp_contributions
FROM
	elcn_contributionBase contrib
	LEFT JOIN elcn_contributiondonorbase cdb
		ON contrib.elcn_contributionid = cdb.elcn_contribution
		AND DATEPART(YYYY,contrib.elcn_contributiondate) between @p_fy -1 and @p_fy

	LEFT JOIN elcn_contributiongivingcodeBase cgcb
		ON contrib.elcn_contributionid = cgcb.elcn_ContributionID
	LEFT JOIN elcn_givingcodebase gcb
		ON cgcb.elcn_GivingCodeID = gcb.elcn_GivingCodeId
    LEFT join elcn_contributionpaymentBase cpb
		ON cdb.elcn_contribution = cpb.elcn_ContributionId
		AND cpb.elcn_PaymentTypeId = 'DD70C09D-3F30-E411-941D-0050568068B8'
WHERE 
	cdb.elcn_person IS NOT NULL
GROUP BY 
	cdb.elcn_person, DATEPART(YYYY,contrib.elcn_contributiondate) 
;
CREATE NONCLUSTERED INDEX INDX_TMP_ID ON #temp_contributions (elcn_person);

SELECT

-->> Gifts v 1 - Tax Letters Report
--Entity UID
	cb.contactid

--Deceased Status
	, CASE
		WHEN cb.elcn_PersonStatusId IN ('CF133D0E-4205-4EC8-B3D1-799074F7A72D',
									'57B3E088-CDD5-4808-9D53-5F530BDCD320',
									'233C10DC-B283-4C57-866C-52138BF01CEB') 
			THEN 'Y'
		ELSE 'N'
	END Deceased_Status
--ID
	, cb.datatel_EnterpriseSystemId Banner_ID	
--Name
	, cb.FullName

--Donor Category
	, ctb.elcn_type Donor_Category

--Preferred Full Saluation
	, COALESCE(cife_salu.elcn_formattedname,sife_salu.elcn_formattedname) Preferred_Long_Salutation
--Preferred Short Salutation
	, COALESCE(cifl_salu.elcn_formattedname,sifl_salu.elcn_formattedname) Preferred_Short_Salutation

--Address Type
	, atb.elcn_type Preferred_Address_Type
--Street 1
	, addresses.Street_Line1
--Street 2
	, addresses.Street_Line2
--City
	, addresses.City
--State
	, addresses.State_Province
--Zip
	, addresses.Postal_Code
--	, addresses.County
	, addresses.Nation

--Annual HH Giving
	, COALESCE(this_year.sum_giving,0) + COALESCE(spouse_this_year.sum_giving,0) Annual_HH_Giving

--Prev Yr Annual HH Giving
	, COALESCE(last_year.sum_giving,0) + COALESCE(spouse_last_year.sum_giving,0) Prev_Yr_Annual_HH_Giving

--Prev Yr Annual HH Aux Giving
	, COALESCE(last_year.sum_aux,0) + COALESCE(spouse_last_year.sum_aux,0) Prev_Yr_Annual_HH_Aux_Giving

--Prev Yr Annual HH Soft Giving
	, COALESCE(last_year.sum_soft,0) + COALESCE(spouse_last_year.sum_soft,0) Prev_Yr_Annual_HH_Soft_Giving

--HH GIK
	, COALESCE(this_year.sum_gik,0) + COALESCE(spouse_this_year.sum_gik,0) HH_GIK

--Relation Source
	, spouse_p.FullName Relation
--Relation Source Desc
	, prt.elcn_type Relationship

--Combined Mailing Priority
--Combined Mailing Priority Desc
	, CASE spouse_link.elcn_jointmailing 
		WHEN 1 THEN 'Y'
		ELSE null
	END Joint_Mailing

--NPH
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
					AND cpb.elcn_personId = cb.ContactId
				)
			) IS NOT NULL THEN 'NPH' END AS NPH 
--NOC
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
					AND cpb.elcn_personId = cb.ContactId
				)
			) IS NOT NULL THEN 'NOC' END AS NOC 
--NMC
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
					AND cpb.elcn_personId = cb.ContactId
				)
			) IS NOT NULL THEN 'NMC' END AS NMC 
--NEM
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
					AND cpb.elcn_personId = cb.ContactId
				)
			) IS NOT NULL THEN 'NEM' END AS NEM 
--NAM
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
					AND cpb.elcn_personId = cb.ContactId
				)
			) IS NOT NULL THEN 'NAM' END AS NAM 
--NDN
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
					AND cpb.elcn_personId = cb.ContactId
				)
			) IS NOT NULL THEN 'NDN' END AS NDN 
--NAK
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
					AND cpb.elcn_personId = cb.ContactId
				)
			) IS NOT NULL THEN 'NAK' END AS NAK
--NTP
	, CASE WHEN(
			SELECT 1 X
			WHERE EXISTS(
				SELECT cpb.elcn_ContactPreferenceTypeId
				FROM elcn_contactpreferenceBase cpb
				WHERE 
		 			cpb.elcn_ContactRestrictionId = '3E4E206F-9EB8-E911-80D8-0A253F89019C' 
 					AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
					AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' 
					AND cpb.elcn_personId = cb.ContactId
				)
			) IS NOT NULL THEN 'NTP' END AS NTP

--Gift Vehicle
--Gift Vehicle Desc
--	, contrib.Gift_Vehicle


--end of report
--select * from #temp_contributions where elcn_person = '626F9310-DC46-4E08-9EA7-A6BA8D2DE65B';

FROM(
	SELECT DISTINCT 
		#temp_contributions.elcn_person
	FROM 
		#temp_contributions
	WHERE
		fy = @p_fy 
	)contrib

	LEFT JOIN(
		SELECT
			elcn_person
			, sum_giving
			, sum_aux
			, sum_soft
			, sum_gik
		FROM #temp_contributions
		WHERE fy = @p_fy
	) this_year
		ON contrib.elcn_person = this_year.elcn_person

	LEFT JOIN(
		SELECT
			elcn_person
			, sum_giving
			, sum_aux
			, sum_soft
			, sum_gik
		FROM #temp_contributions
		WHERE fy = @p_fy -1
	) last_year
		ON contrib.elcn_person = last_year.elcn_person

	LEFT JOIN contactbase cb
		on contrib.elcn_person = cb.contactid
	LEFT JOIN elcn_constituentaffiliationBase cab 
		ON cb.elcn_primaryconstituentaffiliationid = cab.elcn_constituentaffiliationId 
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
			elcn_personid
			, elcn_formattedname
		FROM
			#temp_aprsalu salu
		WHERE
			salu.salu_code = 'CIFE'
			AND salu.rn = 1
		) CIFE_SALU 
			ON cb.contactid = cife_salu.elcn_personid
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
			ON cb.contactid = sife_salu.elcn_personid
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
			ON cb.contactid = cifl_salu.elcn_personid
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
			ON cb.contactid = sifl_salu.elcn_personid

	LEFT JOIN elcn_personalrelationshipBase SPOUSE_LINK 
		ON cb.ContactId = spouse_link.elcn_Person1Id
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

	LEFT JOIN(
		SELECT
			elcn_person
			, sum_giving
			, sum_aux
			, sum_soft
			, sum_gik
		FROM #temp_contributions
		WHERE fy = @p_fy
	) spouse_this_year
		ON spouse_link.elcn_Person2Id = spouse_this_year.elcn_person

	LEFT JOIN(
		SELECT
			elcn_person
			, sum_giving
			, sum_aux
			, sum_soft
			, sum_gik
		FROM #temp_contributions
		WHERE fy = @p_fy -1
	) spouse_last_year
		ON spouse_link.elcn_Person2Id = spouse_last_year.elcn_person

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
		ON cb.ContactId = aab.elcn_personId
		AND aab.rn = 1
	JOIN #temp_addresses ADDRESSES -- state filtered
		ON aab.elcn_AddressId = addresses.elcn_addressId  
	LEFT JOIN elcn_addresstypeBase ATB 
		ON  aab.elcn_AddressTypeId = atb.elcn_addresstypeId