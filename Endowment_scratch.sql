select su.domainname, su.fullname
from systemuserbase su
where su.domainname = 'willi204@nsuok.edu'
;

SELECT column_name,ordinal_position,column_default,is_nullable,data_type,character_maximum_length,CHARACTER_OCTET_LENGTH,numeric_precision,numeric_precision_radix,numeric_scale
		FROM 	INFORMATION_SCHEMA.COLUMNS
		where upper(column_name) like '%MARKET%'
order by 3,4;

select * from elcn_endowmentvaluation

--select * from elcn_designationBase;
/*elcn_designationpurpose
elcn_DesignationStatusId
elcn_designationtype
elcn_FundingGoal_Progress
*/

--select * from elcn_financialawardrecipientBase;
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
--select * from contactbase where contactid = '628417C4-5657-4517-AF3F-7543EA9AD902';

--select * from elcn_financialawardbase where elcn_financialawardid = '7AF5BDBA-482E-4ADE-AC20-389296EDB73D';
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
select * from elcn_designationbase where elcn_designationid = '3A7A2CC7-B94B-4230-BF4D-712D5A496AD5';

select * from elcn_designationrelationshipBase;





/*
	



where
	--farb.elcn_personid = '628417C4-5657-4517-AF3F-7543EA9AD902'
	--db.elcn_code = 'SCH0001'
	--farb.elcn_awardterm like '%2019%'
	scholar.fullname like 'Riley Kay Hughes'
*/

;


/*
select * from contactbase cb where cb.datatel_EnterpriseSystemId = 'N00139546';
select * from elcn_formattednamebase where elcn_personid = '96806BFE-DDA7-44D4-BDF8-4E884BFBA9CF';	

select aab.* from contactbase cb
	LEFT JOIN elcn_addressassociationBase aab ON aab.elcn_personId = cb.ContactId --AND aab.elcn_Preferred =1
	LEFT OUTER JOIN elcn_addressBase ab ON ab.elcn_addressId = aab.elcn_AddressId
where contactid = '96806BFE-DDA7-44D4-BDF8-4E884BFBA9CF'
and elcn_addresstypeid = 'CC535A28-13DE-42F4-B60C-EAFC70983281' -- CC535A28-13DE-42F4-B60C-EAFC70983281;
select elcn_addresstypeid, elcn_type  from elcn_addresstype;
select * from elcn_statusbase where elcn_statusid = '378DE114-EB09-E511-943C-0050568068B7';



-->> DESIGNATION_COMMENT
select * from AnnotationBase where notetext like 'Established in November 2018%'; -- ObjectId FC011202-C1CE-4C68-A3B5-B2783DB4AACA

select * from elcn_designationBase-- where elcn_designationid = 'FC011202-C1CE-4C68-A3B5-B2783DB4AACA';

select db.elcn_code,db.elcn_name,db.elcn_designationstatusid,elcn_statusbase.elcn_name status, db.elcn_designationtype, destype.elcn_type
from elcn_designationBase db
	join elcn_statusbase 
		on elcn_designationstatusid = elcn_statusid
		and elcn_designationstatusid = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/
	join elcn_designationtypebase destype
		on db.elcn_designationtype = elcn_designationtypeid 
		and db.elcn_designationtype = '0030E543-A0B8-E911-80D8-0A253F89019C' /*Endowed Program*/
order by 1;
select * from elcn_designationtypebase;
select * from elcn_designationrelationshipBase

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


*/

--select elcn_financialawardtypeid, elcn_name from elcn_financialawardtype;
/*elcn_financialawardtypeid	elcn_name
9F8E25ED-A383-E911-80D7-0A253F89019C	Grant
7A533A03-B9E8-4808-A5BF-BE0FEE8149A3	Loan
9E8E25ED-A383-E911-80D7-0A253F89019C	Scholarship
4C7E43B6-2203-4677-A70D-0846EE33CFA9	Work
*/

--select * from elcn_designation where elcn_account2 is not null elcn_designationid = '3A7A2CC7-B94B-4230-BF4D-712D5A496AD5';

/*exec sp_columns elcn_endowmentvaluation
elcn_designationIdName
ModifiedByName
ModifiedByYomiName
CreatedByName
CreatedByYomiName
CreatedOnBehalfByName
CreatedOnBehalfByYomiName
ModifiedOnBehalfByName
ModifiedOnBehalfByYomiName
TransactionCurrencyIdName
OwnerId
OwnerIdName
OwnerIdYomiName
OwnerIdDsc
OwnerIdType
OwningUser
OwningTeam
elcn_endowmentvaluationId
CreatedOn
CreatedBy
ModifiedOn
ModifiedBy
CreatedOnBehalfBy
ModifiedOnBehalfBy
OwningBusinessUnit
statecode
statuscode
VersionNumber
ImportSequenceNumber
OverriddenCreatedOn
TimeZoneRuleVersionNumber
UTCConversionTimeZoneCode
elcn_name
elcn_bookvalue
TransactionCurrencyId
ExchangeRate
elcn_bookvalue_Base
elcn_designationId
elcn_distributeiIncome
elcn_distributeiincome_Base
elcn_fiscalyear
elcn_marketvalue
elcn_marketvalue_Base
elcn_shares
elcn_valuationdate*/

select * from datatel_countrybase;


select * from elcn_addressassociationbase
where elcn_personid  = '1D4F208E-FFF6-4C2B-8223-1FA93D529BF0'
and elcn_AddressStatusId = '378DE114-EB09-E511-943C-0050568068B7' -- current 
;
select * from elcn_addresstypeBase -- home, mailing
--where elcn_addresstypeid in ('1FCAAA59-DD18-E611-8187-064A033FBA9D','DED8E027-5925-4115-9E91-E040BA082EF4');

where elcn_addresstypeid = 'CC535A28-13DE-42F4-B60C-EAFC70983281';

select * from elcn_designationrelationshipBase;
select * from elcn_designationrelationshiptypebase;

