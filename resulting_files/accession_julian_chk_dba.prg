CREATE PROGRAM accession_julian_chk:dba
 SET txt = fillstring(200," ")
 SET success = 1
 SET format_cd = 0
 SELECT INTO "nl:"
  c.*
  FROM code_value c
  WHERE c.code_set=2057
   AND c.cdf_meaning="JULIANDATE"
   AND c.active_ind=1
  WITH nocounter
 ;end select
 IF (curqual > 1)
  SET success = 0
  SET txt = "Multiple Julan Date Accession Formats Exist On Code Set 2057"
  GO TO exit_script
 ENDIF
 SET format_cd = 0
 SELECT INTO "nl:"
  c.*
  FROM code_value c
  WHERE c.code_set=2057
   AND c.cdf_meaning="JULIANDATE"
   AND c.active_ind=1
  DETAIL
   format_cd = c.code_value
  WITH nocounter
 ;end select
 IF (format_cd > 0)
  SET success = 0
  SET txt = "Julian Date Accession Format defined on CODE SET 2057."
 ELSE
  SET success = 1
  SET txt = "Julian date accession format (CODE SET 2057) does not exist"
 ENDIF
#exit_script
 IF (validate(request,0))
  SET request->setup_proc[1].success_ind = success
  SET request->setup_proc[1].error_msg = txt
  EXECUTE dm_add_upt_setup_proc_log
 ELSE
  CALL echo(build(txt," (status: ",success,")"))
 ENDIF
END GO
