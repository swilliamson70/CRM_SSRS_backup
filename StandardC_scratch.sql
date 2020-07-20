 select * from stringmapbase;
 
 select * from elcn_constituenttypebase;
 select elcn_primaryconstituentaffiliationid from contactbase ;---cb.cb.elcn_primaryconstituentaffiliationid

 select * from elcn_constituentaffiliationBase; -- elcn_name 'Friend' elcn_ClassYear, elcn_CollegeId
 		SELECT 
			elcn_constituenttypeBase.*,
			filteredstringmap.value  
		FROM
			elcn_constituenttypeBase
			JOIN filteredstringmap
				ON elcn_constituenttypeBase.elcn_category = filteredstringmap.attributevalue 

				AND FilteredViewName = 'Filteredelcn_constituenttype'
				AND attributeName = 'elcn_category'

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
SFML	Single Formal Salutation	Formal Salutation	1972C46B-462D-E411-9415-005056804B43
SFME	Single Formal (envelope)	Mailing Name	0F72C46B-462D-E411-9415-005056804B43
CMFE	Combined Formal (envelope)	Joint Mailing Name	1172C46B-462D-E411-9415-005056804B43
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
;
select * from elcn_stateprovinceBase;

select * from elcn_addressBase;
select * from elcn_addressBase where elcn_postalcode like '74464'+'%';

select * from Filteredstringmap sm
where-- sm.FilteredViewName = 'Filteredelcn_contactpreferencetype'
value like 'Com%'
--AND attributeName = 'elcn_contactpreferencetype' 
--and attributevalue = 344220000
;
select elcn_contactrestrictionid,elcn_name from elcn_contactrestrictionBase
where elcn_contactrestrictionid = '8872A718-5472-40C4-82C7-DB72FC4CE5A6'
select elcn_contactpreferencetypeid ,elcn_type from elcn_contactpreferencetypebase
where elcn_contactpreferencetypeid = 'e4e02dc6-3314-e511-9431-005056804b43'
;
SELECT COUNT(*) FROM elcn_contactpreferenceBase cpb
		WHERE cpb.elcn_ContactRestrictionId = '404E206F-9EB8-E911-80D8-0A253F89019C' /*Donation Anonymous*/
		--AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
		--AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/
		--AND cpb.elcn_personId = cb.ContactId
;
select * from elcn_anonymitytypeBase;

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
where elcn_personid = '4651BF09-A860-48C0-846C-1590D5B2F152'
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
;
select * from #temp_ratings ;
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
/*
	(CASE WHEN(
		SELECT COUNT(*) FROM elcn_contactpreferenceBase cpb
		WHERE cpb.elcn_ContactPreferenceTypeId = 'e4e02dc6-3314-e511-9431-005056804b43' /*Solicitations*/
		AND cpb.elcn_ContactRestrictionId = '8872A718-5472-40C4-82C7-DB72FC4CE5A6' /*Exclude*/
		AND (cpb.elcn_RestrictionLiftDate < CURRENT_TIMESTAMP OR cpb.elcn_RestrictionLiftDate IS NULL)
		AND cpb.elcn_ContactPreferenceStatusId = '378DE114-EB09-E511-943C-0050568068B7' /*Current*/
		AND cpb.elcn_MethodofContact = 344220006 /*All*/
		AND cpb.elcn_personId = cb.ContactId
		) > 0 THEN 'NTP' ELSE NULL END) AS NTP,

*/
-->> MAIL CODES
select * from elcn_communicationlistmemberBase
join contactbase
on elcn_communicationlistmemberBase.elcn_contact = contactbase.contactid
where elcn_CommunicationListID = '20271E62-5741-EA11-80D9-0A253F89019C'
and lastname = 'Foreman';

select * from elcn_communicationlistBase -- elcn_name = Presidents Christmas Card List_P elcn_communicationslistid = 20271E62-5741-EA11-80D9-0A253F89019C

-->> Membership

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
	--elcn_membershiplevelid, 9B3592D4-249A-474A-AE24-328CAE05B127 -- membership level designation base
	--elcn_membershipprogramid, 7B18FD29-B194-454E-B08C-8BEF85103417 -- memebership program base
	--elcn_membershipstatusid, 378DE114-EB09-E511-943C-0050568068B7 --
	--elcn_primaryMemberPersonId = contactid
where elcn_PrimaryMemberPersonId = 'E9397505-12EC-42DD-94D3-DC5F3E089E80'



select * from elcn_membershipmemberBase where elcn_personid = 'E9397505-12EC-42DD-94D3-DC5F3E089E80';
/* contains:
elcn_PersonId
elcn_MembershipId



select * from elcn_membershipprogramlevelBase;--where elcn_membershipprogramlevelid = '9B3592D4-249A-474A-AE24-328CAE05B127';
-- contains elcn_name 'ALUMN - NSU Alumni Association - Life Single Membership'
-- elcn_leveltype = 184AB2B6-5E0A-4999-AAA8-84679BCCF1C0
-- elcn_membershipprogram = 7B18FD29-B194-454E-B08C-8BEF85103417

select * from elcn_membershipleveldesignationbase;
--elcn_name	elcn_Designation	elcn_MembershipLevelAllocation	elcn_MembershipProgramLevel
--WON - Women of Northeastern - Recent Grad Women of Northeast - General Fund	2DB0E898-CF43-4F62-86CA-41B47B8642F8	100	14E51B3A-3396-4851-8644-5018A188C748


select * from elcn_membershipprogramleveltype where elcn_membershipprogramleveltypeId = '9B3592D4-249A-474A-AE24-328CAE05B127'
*/
--NEED 
select top 1
-- membership name
--elcn_membershipBase.elcn_MembershipLevelId , -- 9B3592D4-249A-474A-AE24-328CAE05B127
elcn_membershipprogramlevelbase.elcn_name ,
-- membership status
--elcn_membershipBase.elcn_MembershipStatusId ,  --378DE114-EB09-E511-943C-0050568068B7
elcn_statusbase.elcn_name ,
-- membership number
elcn_membershipBase.elcn_MembershipNumber , --7701
-- expiration date
isnull(elcn_membershipBase.elcn_ExpireDate,'31-DEC-2999')  -- null
from elcn_membershipBase
	join elcn_membershipprogramlevelbase
		on elcn_membershipBase.elcn_MembershipLevelId = elcn_membershipprogramlevelid
	join elcn_statusbase
		on elcn_membershipBase.elcn_MembershipStatusId  = elcn_statusid
where elcn_PrimaryMemberPersonId = 'E9397505-12EC-42DD-94D3-DC5F3E089E80'
and			(	elcn_membershipBase.elcn_name not like 'FAN%'
				AND elcn_membershipBase.elcn_name not like 'WON%'
			) 
ORDER BY ISNULL(elcn_membershipBase.elcn_expiredate,'31-DEC-2999') DESC;

select elcn_membershipprogramlevelid,elcn_name  from elcn_membershipprogramlevelbase
where elcn_name like 'WON%'--elcn_membershipprogramlevelid = '9B3592D4-249A-474A-AE24-328CAE05B127';

select * from elcn_statusbase where elcn_statusid = '378DE114-EB09-E511-943C-0050568068B7';

select getdate()

-->> EMAIL

select * from elcn_emailaddressbase
where elcn_personid = 'E9397505-12EC-42DD-94D3-DC5F3E089E80'
--and elcn_preferred = 1
and statuscode = 1
and elcn_typeid = 'CD0141A1-A383-E911-80D7-0A253F89019C' -- personal?
select elcn_emailaddresstypeid, elcn_type from elcn_emailaddresstypebase
/*elcn_emailaddresstypeid	elcn_type
CC0141A1-A383-E911-80D7-0A253F89019C	Business
CD0141A1-A383-E911-80D7-0A253F89019C	Personal
31292157-E075-4E85-9204-1CCEDEC9DBF9	Other Email
F523FC9B-5370-46F3-9242-263411E73043	Yellow - Waiting Authorization
A4B7A0CC-0DFF-4069-8337-6571B94CA5BD	Alumni Email
26E175F1-4286-4B7E-9CE9-F2E383D58EFD	Northeastern State University Email
*/
select * from elcn_statusbase where elcn_statusid = '050FE7CB-5508-E511-943C-0050568068B7'
/*

elcn_EmailAddressStatusId
378DE114-EB09-E511-943C-0050568068B7 -- current
050FE7CB-5508-E511-943C-0050568068B7 -- past
*/
SELECT elcn_personid, elcn_ratingtypeid, [Value], [Level], [Score]
--INTO #temp_ratings
FROM(
	SELECT
		elcn_ratingBase.elcn_ratingDescription , --for each 'Value'/'Score'/'Level' columns
		elcn_ratingBase.elcn_personid, -- grouped by person UID for person rows
		elcn_ratingBase.elcn_ratingtypeid, -- then by ratingtype UID for rating company
		elcn_ratingBase.elcn_ratingvalue -- for aggr count this - data
	FROM
		elcn_ratingBase
) T PIVOT
(	
	MAX(elcn_ratingvalue)
	FOR elcn_ratingDescription  IN
	([Value], [Level], [Score]) 
) PVT
;


select  
	elcn_personid,
	Preferred,
	Business,
	Personal,
	Other,
	Yellow,
	Alumni,
	NSU

FROM(
	SELECT
		--elcn_typeid,
		case elcn_typeid
			WHEN 'CC0141A1-A383-E911-80D7-0A253F89019C' THEN 'Business'
			WHEN 'CD0141A1-A383-E911-80D7-0A253F89019C' THEN 'Personal'
			WHEN '31292157-E075-4E85-9204-1CCEDEC9DBF9'	THEN 'Other'
			WHEN 'F523FC9B-5370-46F3-9242-263411E73043' THEN 'Yellow ' -- Waiting Authorization
			WHEN 'A4B7A0CC-0DFF-4069-8337-6571B94CA5BD'	THEN 'Alumni'
			WHEN '26E175F1-4286-4B7E-9CE9-F2E383D58EFD'	THEN 'NSU'
			ELSE 'Unknown'
		END AS emailtype,
		elcn_personid,
		elcn_email
	FROM
		elcn_emailaddressbase
	WHERE
		statuscode = 1
	UNION ALL 
	SELECT
		'Preferred',
		elcn_personid,
		elcn_email
	FROM
		elcn_emailaddressbase
	WHERE
		statuscode =1 
		AND elcn_preferred = 1

)T PIVOT 
(	MAX(elcn_email)
	FOR emailtype 
	IN ([Preferred], [Business], [Personal], [Other], [Yellow], [Alumni], [NSU])
)PVT

--->> TELEPHONE

select * from elcn_phonebase;
SELECT
elcn_personid, --guid 
elcn_phonenumber, --phone number
--elcn_PhoneStatusId, --378DE114-EB09-E511-943C-0050568068B7
--elcn_phonetype, --CE0141A1-A383-E911-80D7-0A253F89019C
elcn_phonetypebase.elcn_type ,
elcn_preferred -- 0/1
from elcn_phonebase
join elcn_phonetypebase
	on elcn_phonebase.elcn_phonetype = elcn_phonetypebase.elcn_phonetypeid  
where elcn_personid = 'E9397505-12EC-42DD-94D3-DC5F3E089E80' and
 --elcn_phonetypeid = '5613F262-9B96-48EC-A58E-97E7C333C46F' and
 elcn_phonebase.statuscode = 1
 and elcn_phonestatusid = '378DE114-EB09-E511-943C-0050568068B7' -- Current
;
select elcn_phonetypeid, elcn_type from elcn_phonetypebase
where elcn_phonetypeid = 'CE0141A1-A383-E911-80D7-0A253F89019C'; --elcn_type = 'Home'
/*
CE0141A1-A383-E911-80D7-0A253F89019C	Home PR?
CF0141A1-A383-E911-80D7-0A253F89019C	Business B1
D00141A1-A383-E911-80D7-0A253F89019C	Seasonal
D10141A1-A383-E911-80D7-0A253F89019C	Mobile
D20141A1-A383-E911-80D7-0A253F89019C	Personal Fax
D30141A1-A383-E911-80D7-0A253F89019C	Business Fax
D40141A1-A383-E911-80D7-0A253F89019C	Unknown
713162A7-F7EB-49E9-99D9-33602354A5AE	Cell CL
79AA3970-32B1-4887-AA07-49668AA3F433	Business 2
5613F262-9B96-48EC-A58E-97E7C333C46F	Current 
A8A03280-5DEF-4F90-90E2-B75D8635F289	Yellow - Waiting Authorization

STVTELE: 
PR	Permanent
EC	Emergency Contact
YW	Yellow - Waiting Authorization
B1	Business 1
B2	Business 2
CB	Campus Broken Arrow
CL	Cell
CM	Campus Muskogee
CT	Campus Tahlequah
CU	Current
P1	Parent 1
P2	Parent 2
SE	Seasonal
FX	Fax
FAX	Fax
*/
select * from elcn_statusbase where elcn_statusid = '378DE114-EB09-E511-943C-0050568068B7'; --elcn_name = Current


-->> life total giving aux
-- total of fair market value of all contributions except dues payments
select top 1 * from elcn_contribution;
select * from elcn_contributionbase
where elcn_contributionnumber = 139856;
/*elcn_amount_Base = 500
elcn_AmountPaid 0
elcn_amountpaid_base 0
elcn_CharitableAmount 358
elcn_charitableamount_Base 358
elcn_TotalPremiumFairMarketValue 142
elcn_totalpremiumfairmarketvalue_Base 142
elcn_comments = 'Emerald Experience'
elcn_contributionCategoryId 3A0E5F1A-A483-E911-80D7-0A253F89019C
elcn_contributiondate datetime
elcn_contributionNumber
elcn_contributiontype 344220000
*/

select top 1 elcn_contributiondonorbase.elcn_name, elcn_contribution.elcn_TotalPremiumFairMarketValue from 
			elcn_contributiondonorBase
			JOIN elcn_contribution  
				ON elcn_contributiondonorBase.elcn_contribution = elcn_contribution.elcn_contributionId

;
--->> RELATIONSHIPS

select --prb.*, 
cb1.FullName, prb.elcn_JointMailing, prb.elcn_PrimarySpouseId, prb.elcn_person1id, prb.elcn_person2id,
cb2.FullName,
elcn_ReciprocalRelationshipId, prt.elcn_type 
from elcn_personalrelationshipBase prb
join contactbase cb1 on prb.elcn_person1id = cb1.contactid 
left join contactbase cb2 on prb.elcn_person2id = cb2.contactid 

left join elcn_personalrelationshiptype prt on elcn_RelationshipType1Id  = elcn_personalrelationshiptypeid 
--where elcn_person1id = 'E9397505-12EC-42DD-94D3-DC5F3E089E80';
where elcn_RelationshipType1Id = '4A295D4F-A6EE-E411-942F-005056804B43'
and prb.statuscode = 1;


select contactid, cb.lastname, firstname, fullname, cb.datatel_EnterpriseSystemId, statuscode    from contactbase cb where datatel_EnterpriseSystemId is null-- where fullname = 'Aaron Aaron';


select * from contact where elcn_sortname like '%KEELAN%' ;--contactid = '4770AA6C-F5D9-42F1-A42A-0276683582FD';
/*elcn_PrimarySpouseId 6F9A8948-F7F6-4177-992A-91C5765FC3A6
elcn_ReciprocalRelationshipId 179C114E-4A5E-4307-A685-A9BB43A53A49
elcn_RelationshipType1Id 4F665855-A3B8-E911-80D8-0A253F89019C
elcn_RelationshipType2Id 4F665855-A3B8-E911-80D8-0A253F89019C
*/


select elcn_personalrelationshiptypeid, elcn_type from elcn_personalrelationshiptype
where elcn_personalrelationshiptypeid = '4F665855-A3B8-E911-80D8-0A253F89019C' ;--spouse/partner
/*elcn_personalrelationshiptypeid	elcn_type
A012E0B9-2906-E511-9430-005056804B43	Advisee
27005FC3-2906-E511-9430-005056804B43	Attorney
56295D4F-A6EE-E411-942F-005056804B43	Aunt/Uncle
149A78D8-2906-E511-9430-005056804B43	Business Associate
31665855-A3B8-E911-80D8-0A253F89019C	Business Partner
4C295D4F-A6EE-E411-942F-005056804B43	Child
35665855-A3B8-E911-80D8-0A253F89019C	Child-In-Law
27299DCB-2906-E511-9430-005056804B43	Client
7666C0DE-2906-E511-9430-005056804B43	Coach
DAF5578E-2906-E511-9430-005056804B43	Colleague
82B9D605-2A06-E511-9430-005056804B43	College Advisor
290B05F3-7929-E511-9445-0050568046F2	Cousin
39665855-A3B8-E911-80D8-0A253F89019C	Deceased Spouse/Partner
62295D4F-A6EE-E411-942F-005056804B43	Domestic Partner
3848E79E-4B7F-4CAC-83C7-D8562CADBAD9	Ex-Domestic Partner
48295D4F-A6EE-E411-942F-005056804B43	Ex-Spouse
B10E6EAF-2906-E511-9430-005056804B43	Financial Advisor
3B665855-A3B8-E911-80D8-0A253F89019C	Former Life Partner
3D665855-A3B8-E911-80D8-0A253F89019C	Former Spouse / Partner
5C295D4F-A6EE-E411-942F-005056804B43	Friend
50295D4F-A6EE-E411-942F-005056804B43	Grandchild
4E295D4F-A6EE-E411-942F-005056804B43	Grandparent
3848E79E-4B7F-4CAC-83C6-D8562CADBAD9	Late Domestic Partner
44295D4F-A6EE-E411-942F-005056804B43	Late Spouse
43665855-A3B8-E911-80D8-0A253F89019C	Life Partner
58295D4F-A6EE-E411-942F-005056804B43	Niece/Nephew
4A295D4F-A6EE-E411-942F-005056804B43	Parent
49665855-A3B8-E911-80D8-0A253F89019C	Parent-In-Law
5BE8BB7B-B836-E511-9433-005056804B43	Personal Contact
124E11E9-2906-E511-9430-005056804B43	Player
467B34EF-2906-E511-9430-005056804B43	Professor
63D8939B-2906-E511-9430-005056804B43	Referral
D0C44EA3-2906-E511-9430-005056804B43	Referred By
4B665855-A3B8-E911-80D8-0A253F89019C	Roommate
52295D4F-A6EE-E411-942F-005056804B43	Sibling
42295D4F-A6EE-E411-942F-005056804B43	Spouse
4F665855-A3B8-E911-80D8-0A253F89019C	Spouse / Partner
55665855-A3B8-E911-80D8-0A253F89019C	Step Sibling
60295D4F-A6EE-E411-942F-005056804B43	Stepchild
5E295D4F-A6EE-E411-942F-005056804B43	Stepparent
2F597DF5-2906-E511-9430-005056804B43	Student
3848E79E-4B7F-4CAC-83C5-D8562CADBAD9	Surviving Domestic Partner
46295D4F-A6EE-E411-942F-005056804B43	Surviving Spouse
57665855-A3B8-E911-80D8-0A253F89019C	Widow/Widower


--NEED 
--RELATION_SOURCE - not needed
--RELATION_SOURCE_DESC
	elcn_personalrelationshiptype.elcn_type

--COMBINED_MAILING_PRIORITY
--COMBINED_MAILING_PRIORITY_DESC
	elcn_personalrelationshipbase.elcn_JointMailing

--HOUSEHOLD_IND -- not mapped

*/
select * /*distinct elcn_BusinessRelationshipTypeIdName*/ from elcn_businessrelationship
where  elcn_personid = 'E9397505-12EC-42DD-94D3-DC5F3E089E80' and
  elcn_BusinessRelationshipTypeId ='7CCE6614-A483-E911-80D7-0A253F89019C'
and elcn_BusinessRelationshipStatusId = '558DE114-EB09-E511-943C-0050568068B7'
--elcn_JobTitle = Pilot/Instructor, Pilot Simulator
--elcn_OrganizationIdName =US Air Force/American Airlines
--elcn_BusinessRelationshipStatusIdName = Retired

select elcn_businessrelationshiptypeid,elcn_type from elcn_businessrelationshiptype
where elcn_businessrelationshiptypeid = '7CCE6614-A483-E911-80D7-0A253F89019C' -- employee

select * from elcn_statusbase where elcn_statusid = '558DE114-EB09-E511-943C-0050568068B7' --retired


-->> Involvement (Activities)

select * from elcn_involvementbase i where elcn_personid = 'E9397505-12EC-42DD-94D3-DC5F3E089E80'

select elcn_personid, string_agg(ib.elcn_name + ' (' + sb.elcn_name + ')', ';') as activity from elcn_involvementBase ib 
	join elcn_statusbase sb on ib.elcn_InvolvementStatusId = sb.elcn_statusid

where ib.elcn_personid = 'E9397505-12EC-42DD-94D3-DC5F3E089E80'
	group by elcn_personid 
select * from elcn_statusbase where elcn_statusid = '378DE114-EB09-E511-943C-0050568068B7' -- elcn_name = current
select * from elcn_involvementactivity;
select top 5 elcn_involvementactivityid, elcn_name  from elcn_involvementactivityBase; -- activiies 
/*elcn_involvementactivityid	elcn_name
1E045733-25CB-4F13-AE19-98F14F6B95E2	1958 Football Team
BA888E82-9AA2-40EA-93B5-087FA9600AF1	1963 Football Team
A3A35777-9E7E-4E91-8D4E-2BBEBAF84A86	1994 Nat'l Champ Football Team
E7DB033D-40AF-469F-9720-E4C8E0878667	1994 PLC Freshman Class
561CAE7F-6787-460C-8E98-19B746BAB64B	9/11 Day of Service*/

select  * from elcn_contributiondonor
where datepart(YYYY,elcn_ContributionDate) =  @donationYear ;




select count(*) from Contactbase where datatel_enterprisesystemid is null --20846
select count(*) from ContactBase --105850

;

UPDATE su

SET su.domainname = 'sql\nsudevuser'

SELECT su.domainname, su.fullname
--select * 
FROM systemuserbase su

WHERE su.domainname = 'willi204@nsuok.edu'
order by 1;
update su
set su.domainname = 'sql\nsudevuser'
--select su.domainname, su.fullname
from systemuserbase su
where su.domainname = 'turnerm@nsuok.edu'
;
select * from INFORMATION_SCHEMA.Tables where table_name like 'Filtered%';

drop table #temp_phone;
SELECT
	elcn_personid, --guid 
	elcn_phonenumber, --phone number
	elcn_type,
	elcn_preferred -- 0/1
INTO #temp_phone
FROM(
	SELECT 
		elcn_personid
		, elcn_phonenumber
		, elcn_phonetypeBase.elcn_type
		, elcn_preferred
		, ROW_NUMBER() OVER (PARTITION BY elcn_personid, elcn_phonetypebase.elcn_type
								ORDER BY elcn_preferred DESC) RN
	FROM
		elcn_phonebase
		JOIN elcn_phonetypebase
			ON elcn_phonebase.elcn_phonetype = elcn_phonetypebase.elcn_phonetypeid  
			AND elcn_phonebase.elcn_phonestatusid = '378DE114-EB09-E511-943C-0050568068B7' -- Current
			AND elcn_phonebase.statuscode = 1
	) PHONES 
WHERE
	RN = 1
	and elcn_personid = '2854C1AE-700C-42CD-A6E5-8ACA7A3113D3'
; 

CREATE NONCLUSTERED INDEX INDX_TMP_ID ON #temp_phone (elcn_personid);

select * from #temp_phone where elcn_personid = '2854C1AE-700C-42CD-A6E5-8ACA7A3113D3';
select * from elcn_phonebase where elcn_personid = '2854C1AE-700C-42CD-A6E5-8ACA7A3113D3';
select * from contactbase where contactbase.datatel_EnterpriseSystemId = 'N00161700';

select * from elcn_businessrelationship;

		SELECT
			elcn_personid,
			elcn_JobTitle, 
			elcn_OrganizationIdName,
			elcn_BusinessRelationshipStatusIdName
		FROM 
			elcn_businessrelationship
		WHERE
			elcn_PrimaryEmployer = 1
			AND statuscode =1
			and elcn_personid = '40B0FE36-B4B5-4771-B2F9-057A477E0DE6'
;
SELECT 
	elcn_personid,
	CASE elcn_typeid 
		WHEN '1172C46B-462D-E411-9415-005056804B43' THEN 'CIFE'
		WHEN '0F72C46B-462D-E411-9415-005056804B43' THEN 'SIFE'
		WHEN '1B72C46B-462D-E411-9415-005056804B43' THEN 'SIFL'
		WHEN '89799F16-C4E8-4269-B409-5756998F193F' THEN 'CIFL'
		ELSE cast(elcn_typeid as varchar(40))
	END AS SALU_CODE,
	elcn_formattedname
--INTO
--	#temp_aprsalu
FROM
	elcn_formattednamebase
WHERE
	elcn_typeid in ('1172C46B-462D-E411-9415-005056804B43', -- Joint Mailing Name (CIFE)
			    		'0F72C46B-462D-E411-9415-005056804B43', --Mailing Name (SIFE)
	     				'1B72C46B-462D-E411-9415-005056804B43', --Casual Salutation (SIFL)
		    			'89799F16-C4E8-4269-B409-5756998F193F') --Casual Joint Saluation (CIFL)
	AND (elcn_enddate >= SYSDATETIME() 
		OR elcn_enddate IS NULL)
and elcn_personid = '6F06C4ED-9CF8-4E34-96A2-6208165D44FA'
ORDER BY elcn_personid, elcn_typeid, elcn_locked desc, modifiedon desc
;
select * from elcn_formattednamebase 
where elcn_personid = '6F06C4ED-9CF8-4E34-96A2-6208165D44FA'
--and elcn_typeid = '0F72C46B-462D-E411-9415-005056804B43'
;
SELECT
	elcn_PrimaryMemberPersonId, 
	elcn_membershipprogramlevelbase.elcn_name ,
	elcn_statusbase.elcn_name status,
	elcn_membershipBase.elcn_MembershipNumber , --7701
	CONVERT(DATE, elcn_membershipBase.elcn_ExpireDate) elcn_ExpireDate  -- null
INTO #temp_membership
FROM
	elcn_membershipBase
	JOIN elcn_membershipprogramlevelbase
		ON elcn_membershipBase.elcn_MembershipLevelId = elcn_membershipprogramlevelid
	JOIN elcn_statusbase
		ON elcn_membershipBase.elcn_MembershipStatusId  = elcn_statusid
;
CREATE NONCLUSTERED INDEX INDX_TMP_ID_MEMBERSHIP ON #temp_membership (elcn_primarymemberpersonid);
		SELECT
			elcn_PrimaryMemberPersonId,
			elcn_name,
			status,
			elcn_membershipnumber,
			elcn_expiredate,
			ROW_NUMBER() OVER (PARTITION BY elcn_PrimaryMemberPersonId 
				ORDER BY ISNULL(elcn_expiredate,'31-DEC-2999') DESC) rn
		FROM
			#temp_membership
		WHERE
			(	elcn_name not like 'FAN%'
				AND elcn_name not like 'WON%'
			) 
			and elcn_primarymemberpersonid = '55A718A1-0FE8-4274-94CC-D30FB4A63853'
;
select elcn_RelationshipStatusIdName, elcn_personalrelationshiptypeid, elcn_type from elcn_personalrelationshiptype;
/*Current	290B05F3-7929-E511-9445-0050568046F2	Cousin
Current	42295D4F-A6EE-E411-942F-005056804B43	Spouse
Past	44295D4F-A6EE-E411-942F-005056804B43	Late Spouse
Past	46295D4F-A6EE-E411-942F-005056804B43	Surviving Spouse
Past	48295D4F-A6EE-E411-942F-005056804B43	Ex-Spouse
Current	4A295D4F-A6EE-E411-942F-005056804B43	Parent
Current	4C295D4F-A6EE-E411-942F-005056804B43	Child
Current	4E295D4F-A6EE-E411-942F-005056804B43	Grandparent
Current	50295D4F-A6EE-E411-942F-005056804B43	Grandchild
Current	52295D4F-A6EE-E411-942F-005056804B43	Sibling
Current	56295D4F-A6EE-E411-942F-005056804B43	Aunt/Uncle
Current	58295D4F-A6EE-E411-942F-005056804B43	Niece/Nephew
Current	5C295D4F-A6EE-E411-942F-005056804B43	Friend
Current	5E295D4F-A6EE-E411-942F-005056804B43	Stepparent
Current	60295D4F-A6EE-E411-942F-005056804B43	Stepchild
Current	62295D4F-A6EE-E411-942F-005056804B43	Domestic Partner
Current	DAF5578E-2906-E511-9430-005056804B43	Colleague
Current	63D8939B-2906-E511-9430-005056804B43	Referral
Current	D0C44EA3-2906-E511-9430-005056804B43	Referred By
Current	B10E6EAF-2906-E511-9430-005056804B43	Financial Advisor
Current	A012E0B9-2906-E511-9430-005056804B43	Advisee
Current	27005FC3-2906-E511-9430-005056804B43	Attorney
Current	27299DCB-2906-E511-9430-005056804B43	Client
Current	149A78D8-2906-E511-9430-005056804B43	Business Associate
Current	7666C0DE-2906-E511-9430-005056804B43	Coach
Current	124E11E9-2906-E511-9430-005056804B43	Player
Current	467B34EF-2906-E511-9430-005056804B43	Professor
Current	2F597DF5-2906-E511-9430-005056804B43	Student
Current	82B9D605-2A06-E511-9430-005056804B43	College Advisor
Current	5BE8BB7B-B836-E511-9433-005056804B43	Personal Contact
Current	31665855-A3B8-E911-80D8-0A253F89019C	Business Partner
Current	35665855-A3B8-E911-80D8-0A253F89019C	Child-In-Law
Past	39665855-A3B8-E911-80D8-0A253F89019C	Deceased Spouse/Partner
Past	3B665855-A3B8-E911-80D8-0A253F89019C	Former Life Partner
Past	3D665855-A3B8-E911-80D8-0A253F89019C	Former Spouse / Partner
Current	43665855-A3B8-E911-80D8-0A253F89019C	Life Partner
Current	49665855-A3B8-E911-80D8-0A253F89019C	Parent-In-Law
Current	4B665855-A3B8-E911-80D8-0A253F89019C	Roommate
Current	4F665855-A3B8-E911-80D8-0A253F89019C	Spouse / Partner
Current	55665855-A3B8-E911-80D8-0A253F89019C	Step Sibling
Past	57665855-A3B8-E911-80D8-0A253F89019C	Widow/Widower
Past	3848E79E-4B7F-4CAC-83C5-D8562CADBAD9	Surviving Domestic Partner
Past	3848E79E-4B7F-4CAC-83C6-D8562CADBAD9	Late Domestic Partner
Past	3848E79E-4B7F-4CAC-83C7-D8562CADBAD9	Ex-Domestic Partner*/
select * from elcn_personalrelationshipBase ;

SELECT 
	elcn_personid,
	CASE elcn_typeid 
		WHEN '1172C46B-462D-E411-9415-005056804B43' THEN 'CIFE'
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
	AND (elcn_enddate >= SYSDATETIME() 
		OR elcn_enddate IS NULL)
ORDER BY 
	elcn_personid, 
	elcn_typeid, 
	elcn_locked desc, 
	modifiedon desc
;
CREATE NONCLUSTERED INDEX INDX_TMP_ID_SALU ON #temp_aprsalu (elcn_personId,salu_code);

select * from elcn_formattednamebase;

select * from #temp_aprsalu where elcn_personid = 'F846C523-8AD2-4676-8B52-0000196F89FC';
SELECT TOP 1
			elcn_personid,
			elcn_formattedname
		FROM
			#temp_aprsalu salu
		WHERE
			salu.salu_code = 'SIFE'
			and elcn_personid = 'F846C523-8AD2-4676-8B52-0000196F89FC';

select * from INFORMATION_SCHEMA.TABLES  where upper(table_name) like '%FILTERED%' order by table_name;

select * from Filteredelcn_contribution;

-->> parms

select elcn_abbreviation+'-'+elcn_name state_val, elcn_stateprovinceId from elcn_stateprovinceBase
where elcn_Abbreviation = 'OK';

select * from elcn_stateprovincebase;

select * from cvt_stvcnty;
select * from INFORMATION_SCHEMA.TABLES  where upper(table_name) like '%STV%';

DECLARE 
	@p_StartDate date
	, @p_EndDate date
	, @p_stateList varchar(10) = 'B823CFDA-A383-E911-80D7-0A253F89019C'
	, @p_zipcodeList varchar(9) = '74464'
	, @p_cityname varchar(120) = 'Tah';
 

select *
FROM(
		SELECT
			contactbase.*,
			elcn_anonymitytypeBase.elcn_type anonymityType
		FROM
			ContactBase
			LEFT JOIN elcn_anonymitytypebase 
				ON contactbase.elcn_AnonymityTypeId = elcn_anonymitytypeBase.elcn_anonymitytypeId
		WHERE
			fullname not like '%DO%NOT%USE'
	) cb

	JOIN elcn_addressassociationBase aab 
		ON aab.elcn_personId = cb.ContactId 
		AND aab.elcn_Preferred =1
	JOIN elcn_addressBase ab 
		ON ab.elcn_addressId = aab.elcn_AddressId
		AND LEFT(ab.elcn_postalcode,5) IN (@p_zipcodeList)
		AND ab.elcn_city like (@p_cityname + '%')
	JOIN elcn_stateprovinceBase spb 
		ON spb.elcn_stateprovinceId = ab.elcn_StateProvinceId 
		--AND spb.elcn_stateprovinceId IN (@p_stateList)
	JOIN Datatel_countryBase dcb ON dcb.Datatel_countryId = ab.elcn_country
	JOIN elcn_addresstypeBase atb ON atb.elcn_addresstypeId = aab.elcn_AddressTypeId

-- filters
-- primary spouse for unmarried?
select * from contactbase where lastname  = 'Abbott' and firstname = 'Wyatt';  -- contactid = C1255100-DF2C-463D-8610-42191EFCADDB
select * from elcn_personalrelationshipbase where elcn_person1id = 'C1255100-DF2C-463D-8610-42191EFCADDB';
-- primary spouse 
select * from contactbase where datatel_EnterpriseSystemId = 'N00151626'; -- 59A3438D-F6CB-4B21-B502-00162DE2CA86 todd
select * from elcn_personalrelationshipbase where elcn_person1id = '59A3438D-F6CB-4B21-B502-00162DE2CA86';
select * from contactbase where contactid = 'ADF14682-B4D0-4600-9A5D-4AEB5F98E418'; --paula
select * from elcn_personalrelationshipbase where elcn_person1id = 'ADF14682-B4D0-4600-9A5D-4AEB5F98E418';

select 1 x  
where 
NOT EXISTS( 
-- check todd
					--SELECT -- excl non-prim spouse
					--	1 X
					--FROM
					--	elcn_personalrelationshipbase 
					--WHERE(
					--	elcn_person1id = '59A3438D-F6CB-4B21-B502-00162DE2CA86' --contactbase.contactid
					--	OR elcn_person2id = '59A3438D-F6CB-4B21-B502-00162DE2CA86' --contactbase.contactid
					--	) AND elcn_PrimarySpouseId = '59A3438D-F6CB-4B21-B502-00162DE2CA86' --contactbase.contactid
					--	AND elcn_RelationshipType1ID IN ( '42295D4F-A6EE-E411-942F-005056804B43' , /*Spouse*/
					--									'4F665855-A3B8-E911-80D8-0A253F89019C', /*Spouse / Partner*/
					--									'62295D4F-A6EE-E411-942F-005056804B43', /*Domestic Partner*/
					--									'43665855-A3B8-E911-80D8-0A253F89019C')	/*Life Partner*/
--check paula
					SELECT -- excl non-prim spouse
						1 X
					FROM
						elcn_personalrelationshipbase 
					WHERE(
						elcn_person1id = 'ADF14682-B4D0-4600-9A5D-4AEB5F98E418'--contactbase.contactid
						OR elcn_person2id = 'ADF14682-B4D0-4600-9A5D-4AEB5F98E418' --contactbase.contactid
						) AND elcn_PrimarySpouseId = 'ADF14682-B4D0-4600-9A5D-4AEB5F98E418' --contactbase.contactid
						AND elcn_RelationshipType1ID IN ( '42295D4F-A6EE-E411-942F-005056804B43' , /*Spouse*/
														'4F665855-A3B8-E911-80D8-0A253F89019C', /*Spouse / Partner*/
														'62295D4F-A6EE-E411-942F-005056804B43', /*Domestic Partner*/
														'43665855-A3B8-E911-80D8-0A253F89019C')	/*Life Partner*/
)