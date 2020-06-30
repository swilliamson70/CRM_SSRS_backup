select * from elcn_designationBase;
/*elcn_designationpurpose
elcn_DesignationStatusId
elcn_designationtype
elcn_FundingGoal_Progress
*/

select * from elcn_financialawardrecipientBase;
/*elcn_financialawardrecipientId	014B971E-DE33-4105-9991-0003F0147317
CreatedOn	59:00.0
CreatedBy	A0F01E52-9E83-E911-80D7-0A253F89019C
ModifiedOn	59:00.0
ModifiedBy	A0F01E52-9E83-E911-80D7-0A253F89019C
CreatedOnBehalfBy	NULL
ModifiedOnBehalfBy	NULL
OwnerId	A0F01E52-9E83-E911-80D7-0A253F89019C
OwnerIdType	8
OwningBusinessUnit	FDCE1E52-9E83-E911-80D7-0A253F89019C
statecode	0
statuscode	1
VersionNumber	0x0000000000AFADEA
ImportSequenceNumber	NULL
OverriddenCreatedOn	NULL
TimeZoneRuleVersionNumber	0
UTCConversionTimeZoneCode	NULL
elcn_name	Megan Grace Weaver
elcn_AwardAmount	1200
TransactionCurrencyId	170B069B-9E83-E911-80D7-0A253F89019C
ExchangeRate	1
elcn_awardamount_Base	1200
elcn_AwardedDate	59:00.0
elcn_AwardPeriodIntegrationId	NULL
elcn_AwardTerm	Fall 2011
elcn_CollegeId	NULL
elcn_DepartmentId	NULL
elcn_DivisionId	NULL
elcn_FinancialAwardId	7AF5BDBA-482E-4ADE-AC20-389296EDB73D
elcn_PersonId	628417C4-5657-4517-AF3F-7543EA9AD902 --Weaver
elcn_StatusId	NULL
elcn_stewardshipintegrationid	NULL
elcn_studentfinaidawardintegrationid	NULL
*/
select * from contactbase where contactid = '628417C4-5657-4517-AF3F-7543EA9AD902';

select * from elcn_financialawardbase where elcn_financialawardid = '7AF5BDBA-482E-4ADE-AC20-389296EDB73D';
/*elcn_financialawardId	7AF5BDBA-482E-4ADE-AC20-389296EDB73D
CreatedOn	59:00.0
CreatedBy	A0F01E52-9E83-E911-80D7-0A253F89019C
ModifiedOn	59:00.0
ModifiedBy	A0F01E52-9E83-E911-80D7-0A253F89019C
CreatedOnBehalfBy	NULL
ModifiedOnBehalfBy	NULL
OwnerId	A0F01E52-9E83-E911-80D7-0A253F89019C
OwnerIdType	8
OwningBusinessUnit	FDCE1E52-9E83-E911-80D7-0A253F89019C
statecode	0
statuscode	1
VersionNumber	0x0000000000AFAC67
ImportSequenceNumber	NULL
OverriddenCreatedOn	NULL
TimeZoneRuleVersionNumber	NULL
UTCConversionTimeZoneCode	NULL
elcn_name	PLC Scholarship
elcn_DesignationId	5E991903-460E-4990-BE98-794B2A28DDD0
elcn_EndDate	NULL
elcn_financialaidfundintegrationid	ac1fb8fa-41b1-42d2-b10a-1b59cde440a6
elcn_FinancialAwardTypeId	9E8E25ED-A383-E911-80D7-0A253F89019C
elcn_NumberofRecipients	00:00.0
elcn_ShortDescription	PLC Scholarship
elcn_StartDate	NULL
*/
/*
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
*/

SELECT
	db.elcn_code DESIGNATION,
	db.elcn_name DESIGNATION_NAME,
	donor.datatel_EnterpriseSystemId ADADESG_ID,
	donor.elcn_SortName,
	--casualjoint_salu.elcn_personid,
	casualjoint_salu.elcn_formattedname,
	mailingjoint_salu.elcn_formattedname,
	ab.elcn_street1 MAILING_STREET1,
	ab.elcn_City	MAILING_CITY,
	spb.elcn_Abbreviation as State_Province,
	ab.elcn_postalcode AS Postal_Code,
	dcb.Datatel_name as Nation

FROM elcn_financialawardbase FAB
	LEFT JOIN elcn_financialawardrecipientBase FARB
		ON fab.elcn_financialawardId = farb.elcn_FinancialAwardId
	LEFT JOIN elcn_designationBase DB
		ON fab.elcn_DesignationId = db.elcn_designationid
	LEFT JOIN contactbase scholar
		ON farb.elcn_personid = scholar.contactid
	LEFT JOIN elcn_designationrelationshipBase DRB
		ON fab.elcn_designationid = drb.elcn_designationid 
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
where
	--farb.elcn_personid = '628417C4-5657-4517-AF3F-7543EA9AD902'
	--db.elcn_code = 'SCH0001'
	--farb.elcn_awardterm like '%2019%'
	scholar.fullname like 'Riley Kay Hughes'
order by scholar.lastname, scholar.firstname, scholar.MiddleName 
;


select * from contactbase cb where cb.datatel_EnterpriseSystemId = 'N00139546';
select * from elcn_formattednamebase where elcn_personid = '96806BFE-DDA7-44D4-BDF8-4E884BFBA9CF';	

select aab.* from contactbase cb
	LEFT JOIN elcn_addressassociationBase aab ON aab.elcn_personId = cb.ContactId --AND aab.elcn_Preferred =1
	LEFT OUTER JOIN elcn_addressBase ab ON ab.elcn_addressId = aab.elcn_AddressId
where contactid = '96806BFE-DDA7-44D4-BDF8-4E884BFBA9CF'
and elcn_addresstypeid = 'CC535A28-13DE-42F4-B60C-EAFC70983281' -- CC535A28-13DE-42F4-B60C-EAFC70983281;
select elcn_addresstypeid, elcn_type  from elcn_addresstype;
select * from elcn_statusbase where elcn_statusid = '378DE114-EB09-E511-943C-0050568068B7';

-->> DESIGNATION (adbdesg_desg)
select elcn_code from elcn_designationBase;

-->> DESIGNATION_NAME (adbdesg_name)
select elcn_name from elcn_designationBase;

-->> ADADESG_ID

-->> ADADESG_NAME
-->> MAILING_First Name
-->> MAILING_Full Name
-->> MAILING_STREET1
-->> MAILING_CITY
-->> MAILING_STATE
-->> MAILING_POSTAL_CODE
-->> MAILING_NATION
-->> Scholars Name
-->> SHOLARSHIP_AWARDED_TO
-->> DESIGNATION_COMMENT
-->> AID_YEAR
-->> AWARD_AMOUNT
-->> FUND

select substring(elcn_account,6,datalength(elcn_account)) val
	, charindex('^|',substring(elcn_account,6,datalength(elcn_account)) ) +2 startpos 
	, charindex('^|',substring(elcn_account,6,datalength(elcn_account)) ,2) 
	- (charindex('^|',substring(elcn_account,6,datalength(elcn_account)) ) +2) endpos 

, substring(substring(elcn_account,6,datalength(elcn_account)), --elcn_account minus ^| coas character ^| so substr starts with acci_code
	charindex('^|',substring(elcn_account,6,datalength(elcn_account)) ) +2-- startpos first delimiter of substring (start of fund_code)
	, charindex('^|',substring(elcn_account,6,datalength(elcn_account)) ,2) -- second delimiter (end position of fund_code)
	- (charindex('^|',substring(elcn_account,6,datalength(elcn_account)) ) +2) -- minus starting position of fund_code string
	) mystring
from elcn_designationBase;
/*elcn_name = Debbie Morgan PLC Scholarship
elcn_account ^|F^|^|E30025^|PL0025^|410110^|116000^|^|^|^|^|^| *** ^|^|E30025^|PL0025^|410110^|116000^|^|^|^|^|^|
1st Delimiter ^| 1-2
coas - 1 character 3
2nd Delimiter ^| 4-5
adbdesg_acci_code 6- (all null in Banner)
3rdDelimiter ^|
adbdesg_fund_code
adbdesg_orgn_code
adbdesg_acct_code
adbdesg_prog_code
adbdesg_actv_code
adbdesg_locn_code

!ISNULL(adbdesg_coas_code) ? (GLDelimiter + adbdesg_coas_code + GLDelimiter + (!ISNULL(adbdesg_acci_code) ? adbdesg_acci_code + GLDelimiter : GLDelimiter) + (!ISNULL(adbdesg_fund_code) ? adbdesg_fund_code + GLDelimiter : GLDelimiter) + (!ISNULL(adbdesg_orgn_code) ? adbdesg_orgn_code + GLDelimiter : GLDelimiter) + (!ISNULL(adbdesg_acct_code) ? adbdesg_acct_code + GLDelimiter : GLDelimiter) + (!ISNULL(adbdesg_prog_code) ? adbdesg_prog_code + GLDelimiter : GLDelimiter) + (!ISNULL(adbdesg_actv_code) ? adbdesg_actv_code + GLDelimiter : GLDelimiter) + (!ISNULL(adbdesg_locn_code) ? adbdesg_locn_code + GLDelimiter : GLDelimiter) + GLDelimiter + GLDelimiter + GLDelimiter) : adbdesg_gl_no_credit
*/

-->> FISCAL_YEAR
-->> GIFT_REVENUE_SCH
-->> GIFT_REVENUE_PROG
-->> GIFT_REVENUE_CAP_PROJ
-->> MARKET_VALUE_END_BAL
-->> MARKET_VALUE_BEG_BAL
-->> BEGINNING_BALANCE
-->> INVESTMENT_INCOME
-->> INTEREST_INCOME
-->> INCOME_TRANSFER
-->> Total Income 
-->> Ending Balance
-->> Ending Market Value 
-->> Total Gift Revenue


