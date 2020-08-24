select * from contactbase
where datatel_EnterpriseSystemId = 'N00119604'; -- 'Dr. Deborah Landry' '21F60CA1-95A8-4F92-87A2-E817F4B7B46F'

select * from elcn_contributiondonorbase cdb
join elcn_contributionBase cb
	on cdb.elcn_contribution = cb.elcn_contributionid
where elcn_person = '21F60CA1-95A8-4F92-87A2-E817F4B7B46F'

;
--elcn_contributiontype = 344220003

select * from elcn_paymenttypeBase; -- 'DD70C09D-3F30-E411-941D-0050568068B8' Gift-in-kind
select * from elcn_contributionpaymentBase;
select cdb.* from elcn_contributiondonorbase cdb
	join elcn_contributionpaymentBase cpb
		ON cdb.elcn_contribution = cpb.elcn_ContributionId
		AND cpb.elcn_PaymentTypeId = 'DD70C09D-3F30-E411-941D-0050568068B8'
where cdb.elcn_person = '21F60CA1-95A8-4F92-87A2-E817F4B7B46F'
; 

select * from elcn_communicationactivityBase; -- cdb.elcn_appealcommunitionactivityid 16FD5630-A073-4C4E-ADDD-2F1D2689F556
-- cdb.elcn_ContributionNumber 77693
select * from elcn_contributionBase where elcn_contributionnumber = 77693;

select top 1 * from elcn_contributiongivingcodebase; -- pk elcn_contributiongivingcodeid - elcn_givingcodeid , elcn_givingcodetypeid 29B872F0-402C-49AC-B2EC-0A4DE0345A5D 5FC954A3-A1D9-E911-80D8-0A253F89019C
select * from elcn_GivingCodeBase where elcn_givingcodeid = '29B872F0-402C-49AC-B2EC-0A4DE0345A5D'; -- elcn_name Giving Vehicle - Payroll Deduction Check
select * from elcn_givingcodetypebase where elcn_givingcodetypeid = '5FC954A3-A1D9-E911-80D8-0A253F89019C'; -- elcn_name = Payroll Deduction
--cdb.contribution - 71B0F1AC-33E9-4F7E-BCDD-9B2BFDB30C8F

select * from elcn_communicationactivityBase;
select * from elcn_designationbase;
select * from elcn_contributiongivingcodeBase;
select * from elcn_contributioncategoryBase;

select * from elcn_personalrelationshiptype;

select * from elcn_constituenttypeBase;

declare @p_fy int = 2019;
SELECT
	cdb.elcn_person
	, gcb.elcn_Name Gift_Vehicle
	, DATEPART(YYYY,contrib.elcn_contributiondate) fy
	, SUM(COALESCE(contrib.elcn_amount,0)) sum_giving
	, SUM(COALESCE(contrib.elcn_PresentValue,0)) sum_aux
	, SUM(COALESCE(cdb.elcn_softcredit,0)) sum_soft
	, SUM(COALESCE(cpb.elcn_amount,0)) sum_gik

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
WHERE cdb.elcn_person IS NOT NULL
GROUP BY cdb.elcn_person, gcb.elcn_Name, DATEPART(YYYY,contrib.elcn_contributiondate) 
;
select cdb.* from elcn_contributiondonorbase cdb

/*GIK-	join elcn_contributionpaymentBase cpb
		ON cdb.elcn_contribution = cpb.elcn_ContributionId
		AND cpb.elcn_PaymentTypeId = 'DD70C09D-3F30-E411-941D-0050568068B8'
where cdb.elcn_person = '21F60CA1-95A8-4F92-87A2-E817F4B7B46F'
*/
select * from elcn_contributionpaymentBase;

select * from contactbase; --elcn_PersonType 344220000
select * from stringmap where attributename like '%Person%';
select * from filteredstringmap sm
where sm.FilteredViewName = 'Filteredcontactbase'
AND attributeName = 'elcn_category'
and attributevalue = 344220000

select * from elcn_organizationnameBase
where elcn_name like 'PCTH%'; -- elcn_OrganizationId = 'BDCC8178-6808-47E6-BFB0-1DD74F1BFFC8'

DECLARE @p_fy int = 2019;
SELECT
	entity_guid
	, entity_type
	, fy
	, SUM(elcn_amount) sum_giving
	, SUM(elcn_PresentValue) sum_aux
	, SUM(elcn_softcredit) sum_soft
	, SUM(gik_amount) sum_gik
	, SUM(elcn_CampaignValue) sum_campaign_value 

--INTO
--	#temp_contributions
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
		elcn_contributionBase contrib
		LEFT JOIN elcn_contributiondonorbase cdb
			ON contrib.elcn_contributionid = cdb.elcn_contribution
			AND DATEPART(YYYY,contrib.elcn_contributiondate) = @p_fy

		LEFT JOIN elcn_contributiongivingcodeBase cgcb
			ON contrib.elcn_contributionid = cgcb.elcn_ContributionID
		LEFT JOIN elcn_givingcodebase gcb
			ON cgcb.elcn_GivingCodeID = gcb.elcn_GivingCodeId
		LEFT join elcn_contributionpaymentBase cpb
			ON cdb.elcn_contribution = cpb.elcn_ContributionId
			AND cpb.elcn_PaymentTypeId = 'DD70C09D-3F30-E411-941D-0050568068B8'
	WHERE 
		cdb.elcn_organization = 'BDCC8178-6808-47E6-BFB0-1DD74F1BFFC8'
	) T
GROUP BY 
	entity_guid, entity_type, fy  
;

select * from elcn_contributiondonorbase where elcn_organization = 'BDCC8178-6808-47E6-BFB0-1DD74F1BFFC8';
select * from elcn_contributiondonorbase where elcn_person is null;
select * from elcn_organizationnameBase onb where onb.elcn_OrganizationId = '0BF8B929-FF31-443E-B7C4-0D8C3A8BE8BF';
select * from elcn_nametypeBase where elcn_NameTypeId = '9BDBA895-7C2D-4D68-A57E-0298A833BA90';

select * from elcn_organizationnameBase onb 
join elcn_nametypeBase ntb on onb.elcn_NameTypeId = ntb.elcn_nametypeid --'9BDBA895-7C2D-4D68-A57E-0298A833BA90';
	LEFT JOIN elcn_alternateidbase aib
		ON onb.elcn_OrganizationId = aib.elcn_OrganizationId
		AND elcn_AlternateIDTypeId = 'D5FA6330-624A-E511-9433-005056804B43'
where onb.elcn_OrganizationId = '0BF8B929-FF31-443E-B7C4-0D8C3A8BE8BF'
and ntb.elcn_nametypeid = '9BDBA895-7C2D-4D68-A57E-0298A833BA90';

select * from elcn_constituentaffiliationBase cabo 
		where  cabo.elcn_OrganizationId = '0BF8B929-FF31-443E-B7C4-0D8C3A8BE8BF';
		

select * from elcn_alternateidBase where elcn_OrganizationId = '540C5752-1D11-4A4D-9E88-0B06847F7CF5';

select 
COALESCE(cdb.elcn_person,cdb.elcn_organization) entity_guid
, contrib.elcn_contributiontype
, contrib.*
,'+++' filler1
,cdb.*
,'+++' filler2
--,cgcb.*

from 		elcn_contribution contrib
		LEFT JOIN elcn_contributiondonorbase cdb
			ON contrib.elcn_contributionid = cdb.elcn_contribution
			AND DATEPART(YYYY,contrib.elcn_contributiondate) = 2019
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

where cdb.elcn_person = '39ECA8AD-7F6A-464E-A328-C9BA7810D281'

/*elcn_contributiongivingcodeId
F22FA9F1-3F67-4235-A767-D63495631DDC
B455085D-1441-46CB-AA8E-E1A5DA951F5F*/

--select distinct attributevalue, value from stringmap where attributename = 'elcn_contributiontype' order by 1;
/*
344220000	Gift
344220001	Pledge
344220002	Recurring Gift
344220003	Pledge Payment
344220004	Matching Gift
344220005	Bequest Expectancy
344220006	Bequest Payment
344220007	Dues Payment
*/
;

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
			AND DATEPART(YYYY,contrib.elcn_contributiondate) = 2019
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
	where 
	COALESCE(cdb.elcn_person,cdb.elcn_organization) = '39ECA8AD-7F6A-464E-A328-C9BA7810D281'
