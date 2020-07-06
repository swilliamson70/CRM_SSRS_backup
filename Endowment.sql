
SELECT 
	elcn_personid,
	CASE elcn_typeid 
		WHEN '1172C46B-462D-E411-9415-005056804B43' THEN 'CIFE' /*Formal Joint Salutation*/
		WHEN '0F72C46B-462D-E411-9415-005056804B43' THEN 'SIFE'
		WHEN '1B72C46B-462D-E411-9415-005056804B43' THEN 'SIFL'
		WHEN '89799F16-C4E8-4269-B409-5756998F193F' THEN 'CIFL'
		ELSE cast(elcn_typeid as varchar(40))
	END AS SALU_CODE,
	elcn_formattedname
INTO
	#temp_aprsalu
FROM
	elcn_formattednamebase
WHERE
	elcn_typeid in ('1172C46B-462D-E411-9415-005056804B43', -- Joint Mailing Name (CIFE)
			    		'0F72C46B-462D-E411-9415-005056804B43', --Mailing Name (SIFE)
	     				'1B72C46B-462D-E411-9415-005056804B43', --Casual Salutation (SIFL)
		    			'89799F16-C4E8-4269-B409-5756998F193F') --Casual Joint Saluation (CIFL)
;
CREATE NONCLUSTERED INDEX INDX_TMP_ID_SALU ON #temp_aprsalu (elcn_personId,salu_code);

--with temp_designation as
--	(
		SELECT 
			elcn_designationId
			, statuscode
			, elcn_name
			,elcn_account
			,elcn_code
			,elcn_description
			,elcn_DesignationStatusId
			,elcn_enddate
			, SUBSTRING(
				--string
				SUBSTRING(elcn_account,6,DATALENGTH(elcn_account)), --elcn_account minus ^| coas character ^| so substr starts with acci_code
				--start position
				CHARINDEX('^|',SUBSTRING( elcn_account,6,DATALENGTH(elcn_account) ) ) +2, -- first delimiter of substring (start of fund_code)
				--number of characters
				CHARINDEX('^|',SUBSTRING(elcn_account,6,DATALENGTH(elcn_account)) ,2) -- second delimiter (end position of fund_code)
					- (CHARINDEX('^|',SUBSTRING(elcn_account,6,DATALENGTH(elcn_account)) ) +2) -- minus starting position of fund_code string
			) FUND
		INTO
			#temp_designation
		FROM
			elcn_designationBase 
		WHERE
			elcn_designationstatusid = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/ 
			--AND elcn_designationtype NOT IN ( '6638512F-80B8-E911-80D8-0A253F89019C',  /*Membership Dues*/
			--								'FA2FE543-A0B8-E911-80D8-0A253F89019C', /*Current Restricted*/
			--								'F82FE543-A0B8-E911-80D8-0A253F89019C', /*Plant / Building*/
			--								'FE2FE543-A0B8-E911-80D8-0A253F89019C') /*Unrestricted*/
			--							--'0030E543-A0B8-E911-80D8-0A253F89019C' /*Endowed Program*/
--	) 
;
CREATE NONCLUSTERED INDEX INDX_TMP_ID ON #temp_designation (elcn_designationId);

DECLARE @p_year nvarchar(4) = '2019';

SELECT
	db.elcn_code					AS	Designation
	, db.elcn_name						Designation_Name
--	,  destype.elcn_type
	--, elcn_designationtype -- GUID
	--, db.elcn_designationid 
--	, fab.elcn_DesignationId
	, donor.datatel_EnterpriseSystemId	Designation_Contact_ID
	, donor.elcn_SortName				Designation_Contact_Name
--	, casualjoint_salu.elcn_personid
	, casualjoint_salu.elcn_formattedname	MAILING_First_Name
	, mailingjoint_salu.elcn_formattedname	MAILING_Full_Name
	, ab.elcn_street1					MAILING_Street_1
	, ab.elcn_street2					MAILING_Street_2
	, ab.elcn_City						MAILING_City
	, spb.elcn_Abbreviation				MAILING_State
	, ab.elcn_postalcode				MAILING_Postal_Code
	, dcb.Datatel_abbreviation			MAILING_Nation
	, scholar.fullname					Scholar_Name
	, scholar.elcn_SortName				Scholar_Sort_Name
	, notes.notetext					Designation_Comment
	, farb.elcn_AwardTerm				Award_Term
	, farb.elcn_awardamount_Base		Award_Amount
--	, farb.elcn_FinancialAwardId
--	, db.elcn_account
	--'?' NF_Code,
	, db.fund							Fund
	--, db.elcn_account 

	--, edval.elcn_designationid edval_designationid
	, edval.elcn_shares					Shares
	, edval.elcn_bookvalue_Base			Book_Value
	, edval.elcn_distributeiincome_Base	Distributed_Income
	, edval.elcn_marketvalue_Base		Market_Value
	, edval.elcn_fiscalyear				Foundation_Fiscal_Year
	, edval.elcn_valuationdate			Valuation_Date

--select * 
FROM
-->> Designation information
	(select * from #temp_designation
	 where SUBSTRING(fund,1,1) = 'E') DB 
	LEFT JOIN elcn_designationrelationshipBase DRB
		ON db.elcn_designationid = drb.elcn_designationid
	LEFT JOIN annotationbase NOTES
		ON drb.elcn_designationrelationshipId = notes.ObjectId

-->> Donor Information
	LEFT JOIN contactbase DONOR
		ON drb.elcn_personid = donor.contactid
	LEFT JOIN #temp_aprsalu CASUALJOINT_SALU
		ON  donor.contactid = casualjoint_salu.elcn_personid
		AND casualjoint_salu.salu_code = 'CIFL'
	LEFT JOIN #temp_aprsalu MAILINGJOINT_SALU
		ON  donor.contactid = mailingjoint_salu.elcn_personid
		AND mailingjoint_salu.salu_code = 'CIFE'
	LEFT JOIN elcn_addressassociationBase aab 
		ON aab.elcn_personId = donor.ContactId 
		AND aab.elcn_addresstypeid = 'CC535A28-13DE-42F4-B60C-EAFC70983281' /* Mailing */
		AND elcn_AddressStatusId = '378DE114-EB09-E511-943C-0050568068B7' /* Current */
	LEFT JOIN elcn_addressBase ab 
		ON ab.elcn_addressId = aab.elcn_AddressId
	LEFT JOIN elcn_stateprovinceBase spb 
		ON spb.elcn_stateprovinceId = ab.elcn_StateProvinceId
	LEFT JOIN Datatel_countryBase dcb 
		ON dcb.Datatel_countryId = ab.elcn_country
		
-->> Scholar Information
	LEFT JOIN elcn_financialawardbase FAB
		ON db.elcn_designationid = fab.elcn_DesignationId
	LEFT JOIN elcn_financialawardrecipientBase FARB
		ON fab.elcn_financialawardId = farb.elcn_FinancialAwardId
		AND TRIM(farb.elcn_AwardTerm) like ('%'+@p_year) -- ('Summer 2019','Fall 2019','Spring 2020')
	LEFT JOIN contactbase SCHOLAR
		ON drb.elcn_personid = scholar.contactid

-->> Endowment Values
	LEFT JOIN(
		SELECT 
			elcn_endowmentvaluationId
			, ImportSequenceNumber
			, elcn_bookvalue_Base
			, elcn_designationId
			, elcn_distributeiincome_Base
			, TRY_CAST(YEAR(elcn_fiscalyear) AS varchar) elcn_fiscalyear
			, elcn_marketvalue_Base
			, elcn_shares
			, FORMAT(elcn_valuationdate,'MM/dd/yyyy') elcn_valuationdate
			
			, ROW_NUMBER() OVER (PARTITION BY elcn_designationId ORDER BY elcn_valuationdate DESC) RN
		FROM
			elcn_endowmentvaluation
		WHERE
			statuscode = 1
			and elcn_fiscalyear = @p_year
	) EDVAL ON db.elcn_designationid = edval.elcn_designationId
		AND edval.rn = 1 -- Most recent valuation

order by db.elcn_code;