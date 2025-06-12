CREATE PROGRAM cps_chk_snm2_fix_str:dba
 SET code_value = 0.0
 SET code_set = 400
 SET cdf_meaning = "SNM2"
 EXECUTE cpm_get_cd_for_cdf
 SET source_vocab_cd = code_value
 IF (code_value < 1)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = concat(
   "FAILURE : Could not find Code_Value for SNM2 on Code_Set 400 ",format(cnvtdatetime(curdate,
     curtime3),"dd-mmm-yyyy hh:mm;;q"))
  GO TO exit_script
 ENDIF
 SET ver_nbr = 0.0
 SELECT INTO "nl:"
  cve.code_value
  FROM code_value_extension cve
  PLAN (cve
   WHERE cve.code_value=source_vocab_cd
    AND cve.field_name="VERSION")
  DETAIL
   ver_nbr = cnvtreal(cve.field_value)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  IF (ver_nbr >= 1998)
   SET success = true
   SET request->setup_proc[1].success_ind = 1
   SET request->setup_proc[1].error_msg = concat("SUCCESS : Modifying SNM2 Source_Strings   ",format(
     cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm;;q"))
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  n.nomenclature_id
  FROM nomenclature n
  PLAN (n
   WHERE n.string_identifier="S0740894"
    AND n.source_vocabulary_cd=source_vocab_cd
    AND n.source_string=concat("Supervisor and general foreman, ",
    "manufacturing and installation of electrical and ","electronic equipment")
    AND n.active_ind > 0
    AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET success = true
 ELSE
  SET success = true
 ENDIF
 IF (success=false)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = concat("FAILURE : Modifying SNM2 Source_Strings   ",format(
    cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm;;q"))
 ELSE
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = concat("SUCCESS : Modifying SNM2 Source_Strings   ",format(
    cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm;;q"))
 ENDIF
#exit_script
 EXECUTE dm_add_upt_setup_proc_log
END GO
