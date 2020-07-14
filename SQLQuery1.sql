--declare @p_donationYear int

--select  * from elcn_contributiondonor cd
--where year(cd.elcn_ContributionDate) =  @p_donationYear

--select elcn_placeofworkid, elcn_name from elcn_placeofwork;
/*elcn_placeofworkid	elcn_name
5ECCD46A-675A-EA11-80DA-0AF42F5ED16C	Academic Affairs
60CCD46A-675A-EA11-80DA-0AF42F5ED16C	Administration
6CCCD46A-675A-EA11-80DA-0AF42F5ED16C	Alumni/Development
62CCD46A-675A-EA11-80DA-0AF42F5ED16C	Athletics
64CCD46A-675A-EA11-80DA-0AF42F5ED16C	Auxiliary Services
66CCD46A-675A-EA11-80DA-0AF42F5ED16C	Award Winner / Hall of Fame
9181D4D4-A383-E911-80D7-0A253F89019C	Branch Office
6ACCD46A-675A-EA11-80DA-0AF42F5ED16C	Business Affairs
68CCD46A-675A-EA11-80DA-0AF42F5ED16C	Business and Technology
9081D4D4-A383-E911-80D7-0A253F89019C	Corporate Headquarters
6ECCD46A-675A-EA11-80DA-0AF42F5ED16C	Education
70CCD46A-675A-EA11-80DA-0AF42F5ED16C	Enrollment Management
7CCCD46A-675A-EA11-80DA-0AF42F5ED16C	Facilities Managment
9281D4D4-A383-E911-80D7-0A253F89019C	Home Office
72CCD46A-675A-EA11-80DA-0AF42F5ED16C	Honors Program
74CCD46A-675A-EA11-80DA-0AF42F5ED16C	Information Technology Service
76CCD46A-675A-EA11-80DA-0AF42F5ED16C	Liberal Arts
78CCD46A-675A-EA11-80DA-0AF42F5ED16C	Library
7ACCD46A-675A-EA11-80DA-0AF42F5ED16C	Optometry
7ECCD46A-675A-EA11-80DA-0AF42F5ED16C	President's Leadership Class
80CCD46A-675A-EA11-80DA-0AF42F5ED16C	Safety Services
82CCD46A-675A-EA11-80DA-0AF42F5ED16C	Science and Health Professions
84CCD46A-675A-EA11-80DA-0AF42F5ED16C	Special Projects
86CCD46A-675A-EA11-80DA-0AF42F5ED16C	Student Affairs
88CCD46A-675A-EA11-80DA-0AF42F5ED16C	Student Services
8ACCD46A-675A-EA11-80DA-0AF42F5ED16C	Unaffiliated
8CCCD46A-675A-EA11-80DA-0AF42F5ED16C	University Relations
*/

DECLARE @p_StartDate date = '01-JAN-2019'
	, @p_EndDate date = '31-DEC-2019';
-- >> Gift in Kind
SELECT
	contactbase.datatel_EnterpriseSystemId bannerid
	, gik.SUM_P
from contactbase
	left join(
		SELECT * 
			--elcn_contributiondonorBase.elcn_person
			--, SUM(elcn_contributiondonorBase.elcn_Amount) SUM_P
		FROM
			elcn_contributiondonorBase

			JOIN elcn_contribution  
				ON elcn_contributiondonorBase.elcn_contribution = elcn_contribution.elcn_contributionId
		WHERE
			--elcn_contributiondonorBase.elcn_person = cb.ContactId
			elcn_contribution.statuscode = 1
--			AND elcn_contributiondonorbase.elcn_capitalcampaignid = 'DAEC9C0E-032F-44DB-8F23-4E5DA992781E' /*ENSURING Our Future*/
--			AND elcn_contributioncategoryid in ('0725BFE3-4182-E911-80D9-0A4D82C48A30' /*Gift-In-Kind Gift*/
--												,'67FED408-4282-E911-80D9-0A4D82C48A30') /*Gift-In-Kind Payment*/
--
--			AND elcn_contribution.elcn_contributionType IN (344220000, -- Gift
--															344220001, -- Pledge
--															344220004, -- Matching Gift
--															344220005) -- Bequest Expectancy
			and elcn_contributiondonorBase.elcn_ContributionDate BETWEEN @p_StartDate AND @p_EndDate
		--GROUP BY elcn_contributiondonorBase.elcn_person
) GIK ON contactbase.contactid = gik.elcn_person 
where contactbase.datatel_EnterpriseSystemId = 'N00119775'
;

--select * from elcn_contributiondonorbase; --elcn_CapitalCampaignId = 9E2AD114-D338-EA11-80D9-0A253F89019C
--select elcn_capitalcampaignid,elcn_name from elcn_capitalcampaign; -- where elcn_capitalcampaignid = '9E2AD114-D338-EA11-80D9-0A253F89019C';
/*elcn_capitalcampaignid	elcn_name
842746E8-D238-EA11-80D9-0A253F89019C	Annual Fund
DA10F3AB-47DB-4051-86B3-E0583D6FB611	Cappi Wadley R and T Center
C4B5B8FA-D238-EA11-80D9-0A253F89019C	CrowdFunding
9E2AD114-D338-EA11-80D9-0A253F89019C	Employee Giving
79E6B242-D338-EA11-80D9-0A253F89019C	End of Year
DAEC9C0E-032F-44DB-8F23-4E5DA992781E	ENSURING Our Future
57AAE304-4178-4AB5-A1C9-80EBC18CD5DF	Gifts In Anticip New Campaign
25F4B9F3-3D93-468B-B41C-47AC8351E662	NSU OCO - Embrace the Vision
CF0C641A-A01A-4779-A355-2B062669FDE8	Pr-Banner Campaign
5DEAE671-F302-4EFB-A100-83A8D7C40DA7	Second Century Campaign
C3846459-D338-EA11-80D9-0A253F89019C	Show Your GRADitude*/

--select * from elcn_contribution; -- elcn_ContributionCategoryId = '3A0E5F1A-A483-E911-80D7-0A253F89019C'
--select elcn_ContributionCategoryId,elcn_name from elcn_contributioncategory;-- where elcn_ContributionCategoryId = '3A0E5F1A-A483-E911-80D7-0A253F89019C';
/*elcn_ContributionCategoryId	elcn_name
D1214444-C30B-420D-A948-E363A4AC882C	Annual Fund Pledge
7A0FBA75-4082-E911-80D9-0A4D82C48A30	Bequest  Pledge
3F0E5F1A-A483-E911-80D7-0A253F89019C	Bequest Expectancy
4574EE5D-4082-E911-80D9-0A4D82C48A30	Bequest Gift
410E5F1A-A483-E911-80D7-0A253F89019C	Bequest Payment
6E15F096-4082-E911-80D9-0A4D82C48A30	Bequest Pledge Payment
A1FEC1BF-4082-E911-80D9-0A4D82C48A30	Charitable Gift Annuity
450E5F1A-A483-E911-80D7-0A253F89019C	Charitable Gift Annuity - Deferred
440E5F1A-A483-E911-80D7-0A253F89019C	Charitable Gift Annuity - Immediate
460E5F1A-A483-E911-80D7-0A253F89019C	Charitable Lead Trust
480E5F1A-A483-E911-80D7-0A253F89019C	Charitable Remainder Annuity Trust
4BFFB210-4182-E911-80D9-0A4D82C48A30	Charitable Remainder Trust
490E5F1A-A483-E911-80D7-0A253F89019C	Charitable Remainder Unitrust
92D9934B-4182-E911-80D9-0A4D82C48A30	Credit Card Pledge
5054B573-4182-E911-80D9-0A4D82C48A30	Donor Advised Fund Gift
4B0E5F1A-A483-E911-80D7-0A253F89019C	Dues Payment
45F3F4AC-4182-E911-80D9-0A4D82C48A30	Electronic Fund Transfer Pledge
0725BFE3-4182-E911-80D9-0A4D82C48A30	Gift-In-Kind Gift
67FED408-4282-E911-80D9-0A4D82C48A30	Gift-In-Kind Payment
B3550E39-4282-E911-80D9-0A4D82C48A30	IRA Gift
E27B1054-4282-E911-80D9-0A4D82C48A30	IRA Pledge Payment
420E5F1A-A483-E911-80D7-0A253F89019C	Life Income
6E4A2A9A-4282-E911-80D9-0A4D82C48A30	Life Insurance Policy
8C7561A7-4282-E911-80D9-0A4D82C48A30	Life Insurance Premium Pledge
3E0E5F1A-A483-E911-80D7-0A253F89019C	Match Expectancy Payment
16BD8B09-9DAD-4325-9FF4-2E028F646C90	Matching Gift
3A0E5F1A-A483-E911-80D7-0A253F89019C	Outright Gift
68CEAC0B-4382-E911-80D9-0A4D82C48A30	Payroll Deduction Gift
64B883FC-328D-4B8E-8F7E-E83AF27B36F9	Payroll Deduction Payment
A3646662-4382-E911-80D9-0A4D82C48A30	Payroll Deduction Pledge
603B8778-4382-E911-80D9-0A4D82C48A30	Payroll Deduction Recurring Gift Promise
34D84315-2283-E911-80DA-0A4D82C48A30	Planned/Deferred Gift Pledge
1946E490-4382-E911-80D9-0A4D82C48A30	Pledge
3C0E5F1A-A483-E911-80D7-0A253F89019C	Pledge Payment
470E5F1A-A483-E911-80D7-0A253F89019C	Pooled Income Fund
400E5F1A-A483-E911-80D7-0A253F89019C	Realized Bequest
3D0E5F1A-A483-E911-80D7-0A253F89019C	Recurring Gift
4C0E5F1A-A483-E911-80D7-0A253F89019C	Recurring Gift Payment
6DE1FA31-2283-E911-80DA-0A4D82C48A30	Recurring Gift Promise
430E5F1A-A483-E911-80D7-0A253F89019C	Retained Life Estate
71F6604D-2283-E911-80DA-0A4D82C48A30	Stocks/Security Gift
1E968F6E-2283-E911-80DA-0A4D82C48A30	Stocks/Security Payment
3B0E5F1A-A483-E911-80D7-0A253F89019C	Straight Pledge
4A0E5F1A-A483-E911-80D7-0A253F89019C	Testamentary Life Income Gift*/