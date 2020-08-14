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