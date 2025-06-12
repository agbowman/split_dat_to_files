CREATE PROGRAM bhs_provider_dept_lookup:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter Provider Name (Case sensitive):" = "*"
  WITH outdev, s_search_name
 DECLARE ms_search_name = vc WITH protect, noconstant(" ")
 DECLARE ms_temp = vc WITH protect, noconstant(" ")
 SET ms_temp = trim(value( $S_SEARCH_NAME),3)
 SET ms_search_name = concat(cnvtupper(substring(1,1,ms_temp)),substring(2,(size(ms_temp) - 1),
   ms_temp),"*")
 CALL echo(build("ms_search_name: ",ms_search_name))
 SELECT INTO value( $OUTDEV)
  p.provider_name, p.person_id, p.title,
  p.dept, p.status, p.sms_alias
  FROM bhs_provider_dept p
  WHERE p.provider_name=patstring(ms_search_name)
  ORDER BY p.provider_name
  WITH nocounter, format
 ;end select
#exit_script
END GO
