CREATE PROGRAM cs54audit2:dba
 SELECT
  cve.code_value, display = uar_get_code_display(cve.code_value), unit = substring(1,6,cve
   .field_value),
  update_name = substring(1,30,p.name_full_formatted), cve.updt_dt_tm"mm/dd/yyyy hh:mm;;d"
  FROM code_value_extension cve,
   person p
  PLAN (cve
   WHERE cve.code_set=54
    AND cve.updt_dt_tm > cnvtdatetime((curdate - 3),curtime))
   JOIN (p
   WHERE cve.updt_id=p.person_id)
  ORDER BY cve.updt_dt_tm DESC
 ;end select
END GO
