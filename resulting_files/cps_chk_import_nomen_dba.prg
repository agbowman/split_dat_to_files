CREATE PROGRAM cps_chk_import_nomen:dba
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET insert_string = fillstring(100," ")
 SET insert_string =
 "This is a test string to check to see if the Nomenclature has updated completely."
 SET next_code = 0.0
 SET nom_id = 0.0
 EXECUTE cps_next_nom_seq
 IF (curqual > 0)
  SET nom_id = next_code
  CALL echo(build("nom_id = ",nom_id))
 ELSE
  CALL echo("error in genetaing new id")
  GO TO next_item
 ENDIF
 INSERT  FROM nomenclature n
  SET n.nomenclature_id = nom_id, n.principle_type_cd = 0, n.updt_cnt = 0,
   n.updt_dt_tm = cnvtdatetime(curdate,curtime3), n.updt_id = 0.0, n.updt_task = 0.0,
   n.updt_applctx = 0.0, n.active_ind = 1, n.active_status_cd = 0,
   n.active_status_dt_tm = cnvtdatetime(curdate,curtime3), n.active_status_prsnl_id = 0.0, n
   .beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
   n.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), n.contributor_system_cd = 0, n.source_string
    = insert_string,
   n.source_identifier = " ", n.string_identifier = " ", n.string_status_cd = 0,
   n.term_id = 0, n.language_cd = 0, n.source_vocabulary_cd = 0,
   n.nom_ver_grp_id = nom_id, n.data_status_cd = 0, n.data_status_prsnl_id = 0.0,
   n.data_status_dt_tm = cnvtdatetime("31-DEC-2100"), n.short_string = " ", n.mnemonic = " ",
   n.concept_identifier = " ", n.concept_source_cd = 0, n.string_source_cd = 0
  WITH check, nocounter
 ;end insert
 IF (curqual <= 0)
  SET ierrcode = error(serrmsg,1)
  CALL echo(build("Error message: ",ierrcode),1)
  CALL echo(build("Error message: ",serrmsg),1)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg = concat("FAILURE on Import "," ",format(cnvtdatetime(curdate,
     curtime3),"mm/dd/yy hh:mm;;q"))
 ELSE
  SET request->setup_proc[1].success_ind = 1
  SET request->setup_proc[1].error_msg = concat("Successful Import "," ",format(cnvtdatetime(curdate,
     curtime3),"mm/dd/yy hh:mm;;q"))
  CALL echo(build("Success message: ",request->setup_proc[1].error_msg),1)
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
 DELETE  FROM nomenclature n
  PLAN (n
   WHERE n.nomenclature_id=nom_id)
  WITH check, nocounter
 ;end delete
 COMMIT
END GO
