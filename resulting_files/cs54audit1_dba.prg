CREATE PROGRAM cs54audit1:dba
 SELECT
  cv.code_value, cv.display, update_name = substring(1,30,p.name_full_formatted),
  cv.updt_dt_tm"mm/dd/yyyy hh:mm;;d"
  FROM code_value cv,
   person p
  PLAN (cv
   WHERE cv.code_set=54
    AND cv.updt_dt_tm > cnvtdatetime((curdate - 3),curtime))
   JOIN (p
   WHERE cv.updt_id=p.person_id)
  ORDER BY cv.updt_dt_tm DESC
 ;end select
END GO
