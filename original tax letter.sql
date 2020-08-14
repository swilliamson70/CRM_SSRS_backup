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
		AND elcn_personid = 'E9397505-12EC-42DD-94D3-DC5F3E089E80'
	--group by elcn_personid
;




select
        CASE
		WHEN cb.elcn_dateofdeath IS NULL THEN 'N' -- not dead
		ELSE 'Y'
		END	AS DECEASED_IND, --Deceased_Status
		
		cb.datatel_EnterpriseSystemId as ID,--ID

        cb.fullname as Full_Name,  --NAME  
		ctb.value	Primary_Constituent_Type, --donor_category
        COALESCE(cife_salu.elcn_formattedname,sife_salu.elcn_formattedname) as Preferred_Full_Salutation,--preferred_full_salutation 
        COALESCE(cifl_salu.elcn_formattedname,sifl_salu.elcn_formattedname) as Preferred_Short_Salutation,--preferred_short_salutation 
		atb.elcn_type AS Preferred_Address_Type, --address_type
        ab.elcn_street1 AS Street_Line1, --street_line1
        ab.elcn_street2 AS Street_Line2, --street_line2
        ab.elcn_City AS City, --city 
        spb.elcn_Abbreviation as State_Province, --state
        ab.elcn_postalcode AS Zip_Code,--zip_code

        --annual_hh_giving
        --prev_yr_annual_hh_giving
        --prev_yr_annual_hh_aux_giving
        --prev_yr_annual_hh_soft_giving

---------------

		--hh_gik
		(select  
				coalesce(gift1.g1sum,0) --+ coalesce(gift2.g2sum,0) --summ 
		 from (
				select cdb.elcn_person
					 , sum(cdb.elcn_amount) g1sum 
				from elcn_contributiondonorbase cdb
				join elcn_contributionbase contb 
					on cdb.elcn_contribution = contb.elcn_contributionid 
				where 
					contb.elcn_contributioncategoryid = '0725BFE3-4182-E911-80D9-0A4D82C48A30' /*Gift-In-Kind Gift*/
						and cdb.elcn_contributiondate between '01-JAN-2019' and '31-DEC-2019' --@parm_DT_Gift_Start and @parm_DT_Gift_End
						and cdb.elcn_person = cb.contactid 
				group by cdb.elcn_person) gift1	
/*				
		left join elcn_personalrelationshipBase prb
			on gift1.elcn_person = prb.elcn_Person1Id
			and prb.elcn_EndDate is null
			
			

		-->>-- and add a date check for enddate is either null or > systemdate

		left join(select 
					cdb.elcn_person
				  , sum(cdb.elcn_amount) g2sum 
				  from elcn_contributiondonorbase cdb
				  join elcn_contributionbase cb 
					  on cdb.elcn_contribution = cb.elcn_contributionid 

				  where 
					  cb.elcn_contributioncategoryid = '0725BFE3-4182-E911-80D9-0A4D82C48A30' /*Gift-In-Kind Gift*/
--readd?	AND elcn_contributiondonorbase.elcn_capitalcampaignid = 'DAEC9C0E-032F-44DB-8F23-4E5DA992781E' /*ENSURING Our Future*/
					  and cdb.elcn_contributiondate between '01-JAN-2019' and '31-DEC-2019' --@parm_DT_Gift_Start and @parm_DT_Gift_End
				  group by 
					  cdb.elcn_person) gift2
			on prb.elcn_Person2Id = gift2.elcn_person

		join contactbase cb
			on gift1.elcn_person = cb.ContactId
			and gift2.elcn_person = cdb.elcn_person
*/ 
		/*where cb.datatel_EnterpriseSystemId = 'N00036268'*/ ) as Summ,

------------------

		relationship.elcn_type as Relationship, --Relationship_source
		relationship.fullname as Relation_Name, --Relationship_source_desc

		CASE relationship.elcn_jointmailing 
				WHEN 1 THEN 'Y'

				ELSE null
			END as Joint_Mailing, --combined_mailing_priority

		--combined_mailing_priority_desc

        (CASE WHEN(
		SELECT COUNT(*) FROM elcn_contactpreferenceBase cpb
		WHERE cpb.elcn_ContactPreferenceTypeId = '112A7585-A2D9-E911-80D8-0A253F89019C' /*Communications*/
		AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6' /*Exclude*/
		AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
		AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/
		AND cpb.elcn_MethodofContact = 344220001 /*Phone*/
		AND cpb.elcn_personId = cb.ContactId
		) > 0 THEN 'NPH' ELSE NULL END) AS NPH, --nph

        (CASE WHEN(
		SELECT COUNT(*) FROM elcn_contactpreferenceBase cpb
		WHERE cpb.elcn_ContactPreferenceTypeId = '76EA8AA5-2F36-4E8E-BFB2-490677DCF4B4' /*Global Restriction*/
		AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6' /*Exclude*/
		AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
		AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/
		AND cpb.elcn_MethodofContact = 344220006 /*All*/
		AND cpb.elcn_personId = cb.ContactId
		) > 0 THEN 'NOC' ELSE NULL END) AS NOC, --noc

        (CASE WHEN(
		SELECT COUNT(*) FROM elcn_contactpreferenceBase cpb
		WHERE cpb.elcn_ContactPreferenceTypeId = '112A7585-A2D9-E911-80D8-0A253F89019C' /*Communications*/
		AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6' /*Exclude*/
		AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
		AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/
		AND cpb.elcn_MethodofContact = 344220000 /*Letter*/
		AND cpb.elcn_personId = cb.ContactId
		) > 0 THEN 'NMC' ELSE NULL END) AS NMC, --nmc

        (CASE WHEN(
		SELECT COUNT(*) FROM elcn_contactpreferenceBase cpb
		WHERE cpb.elcn_ContactPreferenceTypeId = '112A7585-A2D9-E911-80D8-0A253F89019C' /*Communications*/
		AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6' /*Exclude*/
		AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
		AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/
		AND cpb.elcn_MethodofContact = 344220002 /*Email*/
		AND cpb.elcn_personId = cb.ContactId
		) > 0 THEN 'NEM' ELSE NULL END) AS NEM, --nem

        (CASE WHEN(
		SELECT COUNT(*) FROM elcn_contactpreferenceBase cpb
		WHERE cpb.elcn_ContactPreferenceTypeId = 'EE8CE7BD-9CB8-E911-80D8-0A253F89019C' /*Alumni / Club Chapter Mailings*/
		AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6' /*Exclude*/
		AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
		AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/
		AND cpb.elcn_MethodofContact = 344220000 /*Letter*/
		AND cpb.elcn_personId = cb.ContactId
		) > 0 THEN 'NAM' ELSE NULL END) AS NAM, --nam

        (CASE WHEN(
		SELECT COUNT(*) FROM elcn_contactpreferenceBase cpb
		WHERE cpb.elcn_ContactPreferenceTypeId = 'e4e02dc6-3314-e511-9431-005056804b43' /*Solicitations*/
		AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6' /*Exclude*/
		AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
		AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/
		AND cpb.elcn_MethodofContact = 344220006 /*All*/
		AND cpb.elcn_personId = cb.ContactId
		) > 0 THEN 'NDN' ELSE NULL END) AS NDN, --ndn

        (CASE WHEN(
		SELECT COUNT(*) FROM elcn_contactpreferenceBase cpb
		WHERE cpb.elcn_ContactPreferenceTypeId = 'DEE02DC6-3314-E511-9431-005056804B43' /*Acknowledgements*/
		AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6' /*Exclude*/
		AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
		AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/
		AND cpb.elcn_MethodofContact = 344220000 /*Letter*/
		AND cpb.elcn_personId = cb.ContactId
		) > 0 THEN 'NAK' ELSE NULL END) AS NAK, --nak

        (CASE WHEN(
		SELECT COUNT(*) FROM elcn_contactpreferenceBase cpb
		WHERE cpb.elcn_ContactPreferenceTypeId = 'e4e02dc6-3314-e511-9431-005056804b43' /*Solicitations*/
		AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6' /*Exclude*/
		AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
		AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/
		AND cpb.elcn_MethodofContact = 344220006 /*All*/
		AND cpb.elcn_personId = cb.ContactId
		) > 0 THEN 'NTP' ELSE NULL END) AS NTP, --ntp

        --ded_amt_ytd_1
        --ded_amt_ytd_2
        --ded_amt_ytd_3
        --ded_amt_ytd_4

        elcn_contributiongivingcodeBase.elcn_Comments as Gift_Vehicle, --gift_vehicle 
		elcn_GivingCodeBase.elcn_Name as Gift_Vehicle_Desc--gift_vehicle_desc 
       
from(
	SELECT
		contactbase.*,
		elcn_anonymitytypeBase.elcn_type anonymityType
	FROM
		ContactBase
		LEFT JOIN elcn_anonymitytypebase on contactbase.elcn_AnonymityTypeId = elcn_anonymitytypeBase.elcn_anonymitytypeId
	) cb
 
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
			prb.elcn_person1id,
			prt.elcn_type,
			contactbase.fullname,
			elcn_JointMailing			
		FROM
			elcn_personalrelationshipBase prb
			LEFT JOIN elcn_personalrelationshiptype prt on elcn_RelationshipType1Id  = elcn_personalrelationshiptypeid 
			LEFT JOIN contactbase on prb.elcn_person2id = contactbase.contactid
		WHERE
			prb.statuscode = 1
		)RELATIONSHIP ON cb.contactid = relationship.elcn_person1id


LEFT OUTER JOIN elcn_addressassociationBase aab ON aab.elcn_personId = cb.ContactId AND aab.elcn_Preferred = 1

LEFT OUTER JOIN elcn_addresstypeBase atb ON atb.elcn_addresstypeId = aab.elcn_AddressTypeId   

LEFT OUTER JOIN elcn_addressBase ab ON ab.elcn_addressId = aab.elcn_AddressId

LEFT OUTER JOIN elcn_stateprovinceBase spb ON spb.elcn_stateprovinceId = ab.elcn_StateProvinceId

LEFT JOIN elcn_contributiongivingcodeBase on elcn_contributiongivingcodeBase.elcn_contributiongivingcodeId = cb.ContactId

LEFT JOIN elcn_GivingCodeBase on elcn_GivingCodeBase.elcn_GivingCodeId = cb.ContactId
where
cb.datatel_EnterpriseSystemId = 'N00092679'