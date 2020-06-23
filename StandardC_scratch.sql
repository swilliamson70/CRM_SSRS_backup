 select * from stringmapbase;
 
 select * from elcn_constituenttypebase

 select * from entity where name like 'elcn%' order by name 

 select * from StringMap where stringmapid = '1972C46B-462D-E411-9415-005056804B43'--Base
 select * from elcn_nametypebase

 select * from contactbase where elcn_dateofdeath is null
 and contactbase.datatel_EnterpriseSystemId = 'N00142649'

 select * from elcn_formattednameBase --typeid = 1972C46B-462D-E411-9415-005056804B43

 select elcn_type, elcn_formattednametypeid from elcn_formattednametype-- where elcn_formattednametypeId = '1972C46B-462D-E411-9415-005056804B43'
 select elcn_type, elcn_formattednametypeid from elcn_formattednametype where elcn_formattednametypeId = '1172C46B-462D-E411-9415-005056804B43'
 /*
ATVSALU								elcn_formattednametype.elcn_type	.elcn_formattednametypeid
CFML	Combined Formal Salutation	
SFML	Single Formal Salutation	
SFME	Single Formal (envelope)
CMFE	Combined Formal (envelope)
CFE2	Combined Formal Ln 2
CIFE*	Combined Informal (envelope)	Formal Joint Salutation	- A335568A-ECCC-46A4-A229-36D71DBCFCA6
SIFE*	Single Informal (envelope)		Mailing Name - 0F72C46B-462D-E411-9415-005056804B43
SIFL*	Single Informal Salutation		Casual Salutation - 1B72C46B-462D-E411-9415-005056804B43
CIFL*	Combined Informal Salutation	Casual Joint Salutation - 89799F16-C4E8-4269-B409-5756998F193F
*/
DROP TABLE #temp_aprsalu

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

select top 1 * from #temp_aprsalu aprsalu
where aprsalu.elcn_personid = '35787CAF-99A2-4220-87F8-000ADD5ACC43'
AND aprsalu.salu_code IN ('CIFE','SIFE')
ORDER BY CASE WHEN aprsalu.salu_code = 'CIFE' THEN 1 ELSE 2 END

select * from (
/*	select 
		elcn_personid,
		CASE elcn_typeid 
			WHEN 'A335568A-ECCC-46A4-A229-36D71DBCFCA6' THEN 'CIFE'
			WHEN '0F72C46B-462D-E411-9415-005056804B43' THEN 'SIFE'
			WHEN '1B72C46B-462D-E411-9415-005056804B43' THEN 'SIFL'
			WHEN '89799F16-C4E8-4269-B409-5756998F193F' THEN 'CIFL'
			ELSE null 
		END AS SALU_CODE,
		elcn_formattedname
	FROM
		elcn_formattednamebase
	WHERE
		elcn_typeid in ('A335568A-ECCC-46A4-A229-36D71DBCFCA6', --Formal Join Saluatation (CIFE)
			    		 '0F72C46B-462D-E411-9415-005056804B43', --Mailing Name (SIFE)
	     				 '1B72C46B-462D-E411-9415-005056804B43', --Casual Salutation (SIFL)
		    			 '89799F16-C4E8-4269-B409-5756998F193F') --Casual Joint Saluation (CIFL)
	--and elcn_personid = '582AA755-941B-4E7A-97F2-0004FF6B645C'
	--select elcn_type, elcn_formattednametypeid from elcn_formattednametype
*/
	SELECT * from #temp_aprsalu
) t
	PIVOT(
		MAX(elcn_formattedname)
		FOR salu_code IN
			([CIFE],[SIFE],[CIFL],[SIFL])
		) as pt

select * from filteredstringmap where FilteredViewName = 'Filteredelcn_constituenttype' and attributeName = 'elcn_category' order by 1

		SELECT 
			elcn_constituenttypeBase.*,
			filteredstringmap.Value  THE_CENTER,
			filteredstringmap.*
		FROM
			elcn_constituenttypeBase
			JOIN filteredstringmap
				ON elcn_constituenttypeBase.elcn_category = filteredstringmap.attributevalue 
				AND FilteredViewName  = 'Filteredelcn_constituenttype'
				AND attributeName = 'elcn_category'
				and attributevalue = 344220000
		where elcn_constituenttypeid = '23AC35BB-A383-E911-80D7-0A253F89019C' -- value = 'Alum'


select * from filteredstringmap sm
where sm.FilteredViewName = 'Filteredelcn_constituenttype'
AND attributeName = 'elcn_category'
and attributevalue = 344220000

select * from elcn_stateprovinceBase

select * from elcn_addressBase

select * from Filteredstringmap sm
where-- sm.FilteredViewName = 'Filteredelcn_contactpreferencetype'
value like 'Com%'
--AND attributeName = 'elcn_contactpreferencetype' 
--and attributevalue = 344220000
select elcn_contactrestrictionid,elcn_name from elcn_contactrestrictionBase
where elcn_contactrestrictionid = '8872A718-5472-40C4-82C7-DB72FC4CE5A6'
select elcn_contactpreferencetypeid ,elcn_type from elcn_contactpreferencetypebase
where elcn_contactpreferencetypeid = 'e4e02dc6-3314-e511-9431-005056804b43'

SELECT COUNT(*) FROM elcn_contactpreferenceBase cpb
		WHERE cpb.elcn_ContactRestrictionId = '404E206F-9EB8-E911-80D8-0A253F89019C' /*Donation Anonymous*/
		--AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
		--AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/
		--AND cpb.elcn_personId = cb.ContactId

select * from elcn_anonymitytypeBase

-----RATINGS
select elcn_ratingtypeid, elcn_type from elcn_ratingtypeBase
--elcn_ratingtypeid						elcn_type
--7E5F41F7-09D6-4239-966B-30FA9E269654	Company Reported Gift High/Low
--13EB58C1-A1EC-4F7F-8110-94D89CB87C88	Donor Reported Gift High/Low
--DCF14682-200D-413D-8CF1-14763573AFD0	Electronic Screening
--8D090596-4C4B-402B-BAA9-7F6F29412F00	Institution Capacity
--3DE9ACBB-37E5-45AF-8902-2314FC2A9538	iWave Pro Score
--E9D59D78-5F3C-474E-B8D0-B3A3863DCC75	iWave RFM Score
--1BB294D5-53D7-4815-8963-096802773E6D	JF Smith Group Top 500
--ED5B6EEF-4798-44F9-878C-CA21057C1B72	JFSG Est Capacity-DonorSearch
--616FC3AD-4EFE-4A8D-8B8C-398E418C01F2	Major Donor
--FB0883AA-9F3F-4A6A-A620-DE19329DAFB1	Overall Capacity
--E3BEAD84-B077-422D-BB5E-4E922AB28CB2	Peer Screening 
--F8E708B8-A856-420C-BD63-084EA523FED1	Planned Gift Donor
--804EA5EB-5609-4853-87DA-5D1277DA3F3D	Solicitor
--EAFFBBAC-B98F-462A-8EDE-7E9BFEDFC70F	Staff Screening
--BB1F7DA4-82F7-4457-A6F1-44E3D4508000	Wealth Engine Giving Capacity
--50F8230E-88F1-430A-9D2F-C370FDC81EE5	Wealth Engine P2G Score
--238FFF39-4AC4-4C0A-8C72-5201655E76A1	WealthEngine Screening

select * --elcn_personid, elcn_name, elcn_ratingvalue 
from elcn_ratingBase where elcn_personid = 'E9397505-12EC-42DD-94D3-DC5F3E089E80' and
 elcn_ratingtypeid = 'BB1F7DA4-82F7-4457-A6F1-44E3D4508000' --'1BB294D5-53D7-4815-8963-096802773E6D' --'3DE9ACBB-37E5-45AF-8902-2314FC2A9538' --
--and elcn_RatingDescription = 'Score' -- Wealth Engine Giving Capacity 
and statuscode =1
order by elcn_personid, elcn_ratingtypeid

select * --elcn_personid, elcn_name, elcn_ratingvalue 
from elcn_ratingBase 
where elcn_personid = 'E9397505-12EC-42DD-94D3-DC5F3E089E80' and
 elcn_ratingtypeid = '50F8230E-88F1-430A-9D2F-C370FDC81EE5' -- Wealth Engine P2G Score  
 --and elcn_RatingDescription = 'Score'
and statuscode =1
order by elcn_ratingvalue
--elcn_ratingValue
--rating type 1 was wegif info, type 2 was p2g info -- elcn_ratingtypeid
select * from elcn_ratingtypeBase
--Wealth Engine Giving Capacity = 'BB1F7DA4-82F7-4457-A6F1-44E3D4508000'
--Wealth Engine P2G Score = '50F8230E-88F1-430A-9D2F-C370FDC81EE5'
;

		SELECT
			elcn_ratingBase.elcn_personid, 
			elcn_ratingBase.elcn_name,
			elcn_ratingBase.elcn_ratingDescription, 
			elcn_ratingBase.elcn_ratingvalue,
			elcn_ratingtypeBase.elcn_ratingtypeid, 
			elcn_ratingtypeBase.elcn_type
		FROM
			elcn_ratingBase
			JOIN elcn_ratingtypeBase
				ON  elcn_ratingBase.elcn_ratingtypeid = elcn_ratingtypeBase.elcn_ratingtypeid
where elcn_personid = 'E9397505-12EC-42DD-94D3-DC5F3E089E80' and
 elcn_ratingtypeBase.elcn_ratingtypeid = '50F8230E-88F1-430A-9D2F-C370FDC81EE5'
 ;
 select elcn_personid, elcn_ratingtypeid, [Value], [Level], [Score]
 from(
 SELECT
	elcn_ratingBase.elcn_ratingDescription ,
	elcn_ratingBase.elcn_personid,
	elcn_ratingBase.elcn_ratingtypeid,
	elcn_ratingBase.elcn_ratingvalue

FROM
	elcn_ratingBase
--	JOIN elcn_ratingtypeBase
	--	ON elcn_ratingbase.elcn_ratingtypeid = elcn_ratingtypebase.elcn_ratingtypeid
--where elcn_ratingtypeid = '50F8230E-88F1-430A-9D2F-C370FDC81EE5' and
--	elcn_personid = '65127707-8B2D-4AF6-B485-0022DB82F0B0'
--order by 1
) T pivot
(
	MAX(elcn_ratingvalue)
	FOR elcn_ratingDescription  IN
	([Value], [Level], [Score]) 
) PVT


		SELECT
			ratings.elcn_personid,
			ratings.elcn_ratingtypeid,
			elcn_ratingtypeBase.elcn_type RATING_TYPE,
			ratings.value RATING_VALUE,
			ratings.level RATING_LEVEL,
			ratings.score RATING_SCORE
		FROM 
			elcn_ratingtypeBase
			LEFT JOIN #temp_ratings ratings
				ON ratings.elcn_ratingtypeid = elcn_ratingtypebase.elcn_ratingtypeid
				AND ratings.elcn_ratingtypeid = '3DE9ACBB-37E5-45AF-8902-2314FC2A9538'







select * from filteredstringmap where filteredviewname = 'Filteredelcn_contribution' and attributename = 'elcn_contributiontype'
select elcn_type, elcn_donorassociationtypeid from elcn_donorassociationtypeBase

select * from elcn_contributionBase
where elcn_person = 'E9397505-12EC-42DD-94D3-DC5F3E089E80'

----JFSG_ESTIMATED_CAPACITY
select * --elcn_personid, elcn_name, elcn_ratingvalue 
from elcn_ratingBase 
where elcn_personid in ( 'E9397505-12EC-42DD-94D3-DC5F3E089E80', --Raymond Ford
						'9749076E-AF8D-4CB7-8C13-207DB8881012') -- Robyn Ford
and
 elcn_ratingtypeid = 'ED5B6EEF-4798-44F9-878C-CA21057C1B72' 
 --and elcn_RatingDescription = 'Value'
and statuscode =1
order by elcn_ratingvalue

select *
from elcn_ratingBase
where elcn_personid = '9749076E-AF8D-4CB7-8C13-207DB8881012'

select datepart(YYYY,sysdatetime())

select * from elcn_degreeBase
select * from elcn_academiclevelBase
select * from elcn_majorbase
select * from elcn_education_elcn_major
drop table #donations
select distinct 
	elcn_person personid,
	datepart(YYYY,elcn_ContributionDate)givingyear,
	datepart(YYYY,elcn_ContributionDate) -1 prevyear
into #temp_dontations
from elcn_contributiondonorBase 
--where elcn_person = 'E9397505-12EC-42DD-94D3-DC5F3E089E80'

CREATE NONCLUSTERED INDEX INDX_TMP_ID_YEAR ON #temp_donations (personId,givingyear desc);
--

with w_get_consec_years AS ( -- (PersonId, GivingYear, prevyear, yearchain, consecyears) 
--anchor 
	select personid,
		givingyear,
		prevyear,
		1 consecyears
	from #temp_dontations
	--where givingyear = 2018
--recusive memeber
	union all
	select d.personid,
	d.givingyear,
	d.prevyear,
	cte.consecyears +1 consecyears
	from #temp_dontations d 
		inner join w_get_consec_years cte
			on cte.personid = d.personid
			and d.givingyear -1 = cte.givingyear
--termination

)
select * from w_get_consec_years 
order by personid,givingyear desc

select distinct 
	elcn_person personid,
	datepart(YYYY,elcn_ContributionDate)givingyear,
	datepart(YYYY,elcn_ContributionDate) -1 prevyear,
	null consecyears
into #dontations
from elcn_contributiondonorBase 
where elcn_person = 'E9397505-12EC-42DD-94D3-DC5F3E089E80'

with w_get_consec_years as (
--anchor 
	select  
		elcn_person personid,
		--datepart(YYYY,elcn_ContributionDate)givingyear,
		givingyear givingyear,
		--datepart(YYYY,elcn_ContributionDate) -1 prevyear, 
		givingyear-1 as prevyear,
		1 consecyears
	from (Select distinct elcn_person, datepart(YYYY,elcn_ContributionDate) givingyear From elcn_contributiondonorBase) cdb
	--where elcn_person = 'E9397505-12EC-42DD-94D3-DC5F3E089E80'
--recusive memeber
	union all
	select d.personid,
	d.givingyear,
	d.prevyear,
	cte.consecyears +1 consecyears
	from (Select distinct elcn_person, datepart(YYYY,elcn_ContributionDate) givingyear From elcn_contributiondonorBase) d 
		inner join w_get_consec_years cte
			on cte.personid = d.personid
			and d.givingyear -1 = cte.givingyear
--termination

)
select * from w_get_consec_years 
--where personid = 'E9397505-12EC-42DD-94D3-DC5F3E089E80'
where consecyears > 1
order by personid, givingyear desc;


select * from elcn_contactpreferencebase cpb
where statuscode = 1
--and cpb.elcn_ContactRestrictionId <> '8872A718-5472-40C4-82C7-DB72FC4CE5A6' /*Exclude*/
AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/

;

	(CASE WHEN(
		SELECT COUNT(*) FROM elcn_contactpreferenceBase cpb
		WHERE cpb.elcn_ContactPreferenceTypeId = 'e4e02dc6-3314-e511-9431-005056804b43' /*Solicitations*/
		AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6' /*Exclude*/
		AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
		AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/
		AND cpb.elcn_MethodofContact = 344220006 /*All*/
		AND cpb.elcn_personId = cb.ContactId
		) > 0 THEN 'NTP' ELSE NULL END) AS NTP,


-->> MAIL CODES
select * from elcn_communicationlistmemberBase
join contactbase
on elcn_communicationlistmemberBase.elcn_contact = contactbase.contactid
where elcn_CommunicationListID = '20271E62-5741-EA11-80D9-0A253F89019C'
and lastname = 'Foreman';

select * from elcn_communicationlistBase -- elcn_name = Presidents Christmas Card List_P elcn_communicationslistid = 20271E62-5741-EA11-80D9-0A253F89019C

-->> Membership name,status,number,exp date, won_x fields, fan_x fields 
/*--CRM Constituents > People > R Ford - Related Date > Memberships
-- name = 7701 - Raymond Ford
-- Membership level (Membership) = ALUM - NSU Alumni Association - Life SInge Membership
-- Membership Status (Membership) = Current
-- Start Date 11/8/2000
-- Expire Date = null
-- Dues 0
-- Outstanding Balance 0
-- ...

*/
select * from elcn_membershipbase 
	--elcn_membershipid, 
	--elcn_membershiplevelid, 9B3592D4-249A-474A-AE24-328CAE05B127 -- membership program level base
	--elcn_membershipprogramid, 7B18FD29-B194-454E-B08C-8BEF85103417
	--elcn_membershipstatusid, 378DE114-EB09-E511-943C-0050568068B7
	--elcn_primaryMemberPersonId = contactid
where elcn_PrimaryMemberPersonId = 'E9397505-12EC-42DD-94D3-DC5F3E089E80'

select * from elcn_membershipmemberBase;
/* contains:
elcn_PersonId
elcn_MembershipId


;
select * from elcn_membershipprogramlevelBase;--where elcn_membershipprogramlevelid = '9B3592D4-249A-474A-AE24-328CAE05B127';
-- contains elcn_name 'ALUMN - NSU Alumni Association - Life Single Membership'
-- elcn_leveltype = 184AB2B6-5E0A-4999-AAA8-84679BCCF1C0
-- elcn_membershipprogram = 7B18FD29-B194-454E-B08C-8BEF85103417

select * from elcn_membershipleveldesignationbase;
--elcn_name	elcn_Designation	elcn_MembershipLevelAllocation	elcn_MembershipProgramLevel
--WON - Women of Northeastern - Recent Grad Women of Northeast - General Fund	2DB0E898-CF43-4F62-86CA-41B47B8642F8	100	14E51B3A-3396-4851-8644-5018A188C748


select * from elcn_membershipprogramleveltype where elcn_membershipprogramleveltypeId = '9B3592D4-249A-474A-AE24-328CAE05B127'