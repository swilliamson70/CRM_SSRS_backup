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
	, dcb.Datatel_abbreviation	Nation
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
	elcn_organizationid, 
	CASE elcn_typeid 
		WHEN '1172C46B-462D-E411-9415-005056804B43' THEN 'CIFE'
		WHEN '0F72C46B-462D-E411-9415-005056804B43' THEN 'SIFE'
		WHEN '1B72C46B-462D-E411-9415-005056804B43' THEN 'SIFL'
		WHEN '89799F16-C4E8-4269-B409-5756998F193F' THEN 'CIFL'
	END AS SALU_CODE,
	elcn_formattedname,
	ROW_NUMBER() OVER (PARTITION BY elcn_personid, elcn_organizationid, elcn_typeid ORDER BY elcn_locked DESC, modifiedon DESC) RN
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
	entity_guid
	, entity_type
	, fy
	, SUM(elcn_amount) sum_giving
	, SUM(elcn_PresentValue) sum_aux
	, SUM(elcn_softcredit) sum_soft
	, SUM(gik_amount) sum_gik
	, SUM(elcn_CampaignValue) sum_campaign_value 
INTO
	#temp_contributions
FROM(
	SELECT 
		COALESCE(cdb.elcn_person,cdb.elcn_organization) entity_guid 
		, CASE 
			WHEN cdb.elcn_person IS NOT NULL THEN
				'P'
			ELSE 'O'
		END entity_type
		, DATEPART(YYYY,contrib.elcn_contributiondate) fy 
		, COALESCE(contrib.elcn_amount,0) elcn_amount
		, COALESCE(contrib.elcn_PresentValue,0) elcn_PresentValue
		, COALESCE(cdb.elcn_softcredit,0) elcn_softcredit
		, COALESCE(cpb.elcn_amount,0) gik_amount
		, COALESCE(cdb.elcn_CampaignValue,0) elcn_campaignvalue 

	FROM
		elcn_contribution contrib
		LEFT JOIN elcn_contributiondonorbase cdb
			ON contrib.elcn_contributionid = cdb.elcn_contribution
			AND DATEPART(YYYY,contrib.elcn_contributiondate) = @p_fy
			AND contrib.statuscode = 1
			AND contrib.elcn_contributiontype IN
				(344220000--	Gift
				--,344220001--	Pledge
				,344220002--	Recurring Gift
				,344220003--	Pledge Payment
				,344220004--	Matching Gift
				--,344220005--	Bequest Expectancy
				,344220006--	Bequest Payment
				,344220007--	Dues Payment
				)
		--LEFT JOIN elcn_contributiongivingcodeBase cgcb
		--	ON contrib.elcn_contributionid = cgcb.elcn_ContributionID
		--LEFT JOIN elcn_givingcodebase gcb
		--	ON cgcb.elcn_GivingCodeID = gcb.elcn_GivingCodeId

		LEFT join elcn_contributionpaymentBase cpb
			ON cdb.elcn_contribution = cpb.elcn_ContributionId
			AND cpb.elcn_PaymentTypeId = 'DD70C09D-3F30-E411-941D-0050568068B8'
	) T
GROUP BY 	entity_guid, entity_type, fy

;
--select * from #temp_contributions where entity_guid = '39ECA8AD-7F6A-464E-A328-C9BA7810D281';
CREATE NONCLUSTERED INDEX INDX_TMP_ID ON #temp_contributions (entity_guid);

SELECT

-->> Gifts v 1 - Tax Letters Report
--Entity UID
	contrib.entity_guid
	, contrib.Entity_Type
	--, cb.contactid
	--, onb.elcn_OrganizationId
	--, ntb.elcn_nametypeid 
	--, aib.elcn_OrganizationId
	--, cabo.elcn_OrganizationId
	--, ctbo.elcn_constituenttypeID 

--Deceased Status
	, CASE
		WHEN cb.elcn_PersonStatusId IN ('CF133D0E-4205-4EC8-B3D1-799074F7A72D',
									'57B3E088-CDD5-4808-9D53-5F530BDCD320',
									'233C10DC-B283-4C57-866C-52138BF01CEB') 
			THEN 'Y'
		ELSE 'N'
	END Deceased_Status
--ID
	, COALESCE(cb.datatel_EnterpriseSystemId,aib.elcn_idnumber) Banner_ID
	
--Name
	, COALESCE(cb.FullName, onb.elcn_name) Full_Name

--Donor Category
	, COALESCE(ctb.elcn_type,ctbo.elcn_type) Donor_Category

--Preferred Full Saluation
	, COALESCE(cife_salu.elcn_formattedname,sife_salu.elcn_formattedname,
			cife_salu_org.elcn_formattedname,sife_salu_org.elcn_formattedname) Preferred_Long_Salutation

--Preferred Short Salutation
	, COALESCE(cifl_salu.elcn_formattedname,sifl_salu.elcn_formattedname,
			cifl_salu_org.elcn_formattedname,sifl_salu_org.elcn_formattedname) Preferred_Short_Salutation


--Address Type
	, COALESCE(atb.elcn_type, atbo.elcn_type) Preferred_Address_Type
--Street 1
	, COALESCE(addresses.Street_Line1, addresses_org.Street_Line1) Street_Line1
--Street 2
	, COALESCE(addresses.Street_Line2, addresses_org.Street_Line2) Street_Line2
--City
	, COALESCE(addresses.City, addresses_org.City) City
--State
	, COALESCE(addresses.State_Province, addresses_org.State_Province) State_Province
--Zip
	, COALESCE(addresses.Postal_Code, addresses_org.Postal_Code) Postal_Code
	, COALESCE(addresses.Nation, addresses_org.Nation) Nation

--Annual individual giving
	, COALESCE(contrib.sum_campaign_value,0) Annual_Individual_Giving
	--, contrib.*

--Relation Source
	, spouse_p.FullName Spouse

--Relation Source Desc
	, prt.elcn_type Relationship_Type

--Combined Mailing Priority
--Combined Mailing Priority Desc
	, CASE spouse_link.elcn_jointmailing 
		WHEN 1 THEN 'Y'
		ELSE null
	END Joint_Mailing
	, CASE spouse_p.elcn_persontype
		WHEN 344220000 THEN 'Constituent'
		WHEN 344220001 THEN 'Non-constituent'
	END Spouse_Status

FROM(
		SELECT
			entity_guid
			, entity_type 
			, sum_giving
			, sum_aux
			, sum_soft
			, sum_campaign_value
		FROM 
			#temp_contributions
		WHERE
			sum_campaign_value > 0
	) contrib

--Person Info
	LEFT JOIN contactbase cb
		ON contrib.entity_guid = cb.contactid
		AND contrib.entity_type = 'P'

	LEFT JOIN elcn_constituentaffiliationBase cab 
		ON cb.elcn_primaryconstituentaffiliationid = cab.elcn_constituentaffiliationId
		AND cab.elcn_Primary = 1
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
	LEFT JOIN #temp_addresses ADDRESSES -- state filtered
		ON aab.elcn_AddressId = addresses.elcn_addressId  
	LEFT JOIN elcn_addresstypeBase ATB 
		ON  aab.elcn_AddressTypeId = atb.elcn_addresstypeId

--Organization Info
	LEFT JOIN elcn_organizationNameBase onb
		ON contrib.entity_guid = onb.elcn_OrganizationId
		AND contrib.entity_type = 'O'
		AND onb.elcn_NameTypeId = '9BDBA895-7C2D-4D68-A57E-0298A833BA90' -- Primary

	LEFT JOIN elcn_alternateidbase aib
		ON onb.elcn_OrganizationId = aib.elcn_OrganizationId
		AND elcn_AlternateIDTypeId = 'D5FA6330-624A-E511-9433-005056804B43'

	LEFT JOIN elcn_constituentaffiliationBase cabo 
		ON contrib.entity_guid = cabo.elcn_OrganizationId
		AND contrib.entity_type = 'O'
		AND cabo.elcn_primary = 1
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

		) CTBO ON cabo.elcn_ConstituentTypeId = ctbo.elcn_constituenttypeID 

	LEFT JOIN(
		SELECT
			elcn_organizationid
			, elcn_formattedname
		FROM
			#temp_aprsalu salu
		WHERE
			salu.salu_code = 'CIFE'
			AND salu.rn = 1
		) CIFE_SALU_ORG
			ON contrib.entity_guid = cife_salu_org.elcn_organizationid
			AND contrib.entity_type = 'O'
	LEFT JOIN(
		SELECT
			elcn_organizationid
			, elcn_formattedname
		FROM
			#temp_aprsalu salu
		WHERE
			salu.salu_code = 'SIFE'
			AND salu.rn = 1
		) SIFE_SALU_ORG
			ON contrib.entity_guid = sife_salu_org.elcn_organizationid 
			AND contrib.entity_type = 'O'
	LEFT JOIN(
		SELECT 
			elcn_organizationid
			, elcn_formattedname
		FROM
			#temp_aprsalu salu
		WHERE
			salu.salu_code = 'CIFL'
			AND salu.rn = 1
		) CIFL_SALU_ORG
			ON contrib.entity_guid = cifl_salu_org.elcn_organizationid
			AND contrib.entity_type = 'O'
	LEFT JOIN(
		SELECT 
			elcn_organizationid
			, elcn_formattedname
		FROM
			#temp_aprsalu salu
		WHERE
			salu.salu_code = 'SIFL'
			AND salu.rn = 1
		) SIFL_SALU_ORG 
			ON contrib.entity_guid = sifl_salu_org.elcn_organizationid 
			AND contrib.entity_type = 'O'

	LEFT JOIN(
		SELECT 
			aab.*
			,ROW_NUMBER() OVER (PARTITION BY elcn_organizationid 
								ORDER BY CASE WHEN sb.elcn_name = 'Current' THEN 1 ELSE 2 END, 
									aab.elcn_preferred DESC, 
									COALESCE(aab.elcn_enddate,'12/31/2999') DESC) RN
		FROM 
			elcn_addressassociationBase AAB
			JOIN elcn_statusbase SB
				ON aab.elcn_AddressStatusId = elcn_statusid
		) AABO 
		ON contrib.entity_guid = aabo.elcn_organizationId
		AND aabo.rn = 1
	LEFT JOIN #temp_addresses ADDRESSES_ORG -- state filtered
		ON aabo.elcn_AddressId = addresses_org.elcn_addressId  
	LEFT JOIN elcn_addresstypeBase ATBO 
		ON  aabo.elcn_AddressTypeId = atbo.elcn_addresstypeId

--WHERE 
	--contrib.entity_guid = '39ECA8AD-7F6A-464E-A328-C9BA7810D281'
--	OR cb.datatel_EnterpriseSystemId = 'N00167236'
--	COALESCE(cb.datatel_EnterpriseSystemId,aib.elcn_idnumber) = 'N00001730'
;
--select * from #temp_aprsalu where elcn_organizationid = 'BDCC8178-6808-47E6-BFB0-1DD74F1BFFC8'
