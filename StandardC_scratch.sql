 select * from elcn_constituenttypebase

 select * from entity where name like 'elcn%' order by name 

 select * from StringMap where stringmapid = '1972C46B-462D-E411-9415-005056804B43'--Base
 select * from elcn_nametypebase

 select * from contactbase where elcn_dateofdeath is not null


 select * from elcn_formattednameBase --typeid = 1972C46B-462D-E411-9415-005056804B43

 select elcn_type, elcn_formattednametypeid from elcn_formattednametype-- where elcn_formattednametypeId = '1972C46B-462D-E411-9415-005056804B43'
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
