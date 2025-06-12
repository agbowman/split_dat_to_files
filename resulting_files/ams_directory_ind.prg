CREATE PROGRAM ams_directory_ind
 EXECUTE ams_define_toolkit_common
 DECLARE script_name = vc WITH protect, constant("AMS_DIRECTORY_IND")
 SELECT DISTINCT INTO "ams_directory_ind.csv"
  associate_id = p.username, first_name = p.name_first, last_name = p.name_last,
  associate_name = p.name_full_formatted, e.directory_ind
  FROM prsnl p,
   person_name pn,
   ea_user e
  PLAN (p)
   JOIN (pn
   WHERE p.person_id=pn.person_id
    AND pn.name_title IN ("Cerner AMS", "Cerner IRC", "Cerner CommWx")
    AND pn.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (e
   WHERE p.username=e.username
    AND e.directory_ind IN (0, 1))
  ORDER BY p.username
  WITH separator = " ", format
 ;end select
 SET total_cnt = curqual
 CALL updtdminfo(script_name,cnvtreal(total_cnt))
 SET script_ver = "003  09/27/2016  SB8469 Distinct sort issue"
END GO
