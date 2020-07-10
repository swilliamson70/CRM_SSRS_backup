SELECT 	
contactid
,fullname
,birthdate
,birthdateutc
,elcn_dateofbirth
,elcn_dateofdeath
,elcn_primaryconstituentaffiliationid
,elcn_primaryconstituentaffiliationidname
FROM (select * from filteredcontact) AS CRMAF_Filteredcontact