CREATE PROGRAM br_run_ps_oc:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting <br_run_ps_oc.prg> script"
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 SELECT INTO "NL:"
  FROM br_name_value b
  WHERE b.br_nv_key1="UK_ORDERS_LOADED"
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Selecting from br_name_value: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (curqual > 0)
  SET readme_data->status = "S"
  SET readme_data->message = "Readme Auto-success: UK readme has already run."
  GO TO exit_script
 ENDIF
 SET language_log = fillstring(5," ")
 SET language_log = cnvtupper(logical("CCL_LANG"))
 IF (language_log=" ")
  SET language_log = cnvtupper(logical("LANG"))
  IF (language_log IN (" ", "C"))
   SET language_log = "EN_US"
  ENDIF
 ENDIF
 FREE SET tempc
 RECORD tempc(
   1 concepts[40]
     2 old_concept_cki = vc
     2 new_concept_cki = vc
 )
 SET tempc->concepts[1].new_concept_cki = "CERNER!AJpB0gEM+Fzsa4HxCqIGfQ"
 SET tempc->concepts[1].old_concept_cki = "CERNER!AJpB0gEM+Fzsa4H2CqIGfQ"
 SET tempc->concepts[2].new_concept_cki = "CERNER!AJpB0gEM+Fzsa4H9CqIGfQ"
 SET tempc->concepts[2].old_concept_cki = "CERNER!AJpB0gEM+Fzsa4ICCqIGfQ"
 SET tempc->concepts[3].new_concept_cki = "CERNER!AJpB0gEM+Fzsa4IJCqIGfQ"
 SET tempc->concepts[3].old_concept_cki = "CERNER!AJpB0gEM+Fzsa4IOCqIGfQ"
 SET tempc->concepts[4].new_concept_cki = "CERNER!AJpB0gEM+Fzsa4IVCqIGfQ"
 SET tempc->concepts[4].old_concept_cki = "CERNER!AJpB0gEM+Fzsa4IaCqIGfQ"
 SET tempc->concepts[5].new_concept_cki = "CERNER!AJpB0gEM+Fzsa4IhCqIGfQ"
 SET tempc->concepts[5].old_concept_cki = "CERNER!AJpB0gEM+Fzsa4ImCqIGfQ"
 SET tempc->concepts[6].new_concept_cki = "CERNER!AJpB0gEM+Fzsa4ItCqIGfQ"
 SET tempc->concepts[6].old_concept_cki = "CERNER!AJpB0gEM+Fzsa4IyCqIGfQ"
 SET tempc->concepts[7].new_concept_cki = "CERNER!AJpB0gEM+Fzsa4I5CqIGfQ"
 SET tempc->concepts[7].old_concept_cki = "CERNER!AJpB0gEM+Fzsa4I+CqIGfQ"
 SET tempc->concepts[8].new_concept_cki = "CERNER!AJpB0gEM+Fzsa4JFCqIGfQ"
 SET tempc->concepts[8].old_concept_cki = "CERNER!AJpB0gEM+Fzsa4JKCqIGfQ"
 SET tempc->concepts[9].new_concept_cki = "CERNER!AJpB0gEM+Fzsa4JRCqIGfQ"
 SET tempc->concepts[9].old_concept_cki = "CERNER!AJpB0gEM+Fzsa4JWCqIGfQ"
 SET tempc->concepts[10].new_concept_cki = "CERNER!AJpB0gEM+Fzsa4KZCqIGfQ"
 SET tempc->concepts[10].old_concept_cki = "CERNER!AJpB0gEM+Fzsa4KeCqIGfQ"
 SET tempc->concepts[11].new_concept_cki = "CERNER!AJpB0gEM+Fzsa4LJCqIGfQ"
 SET tempc->concepts[11].old_concept_cki = "CERNER!AJpB0gEM+Fzsa4LOCqIGfQ"
 SET tempc->concepts[12].new_concept_cki = "CERNER!AJpB0gEM+Fzsa4L5CqIGfQ"
 SET tempc->concepts[12].old_concept_cki = "CERNER!AJpB0gEM+Fzsa4L+CqIGfQ"
 SET tempc->concepts[13].new_concept_cki = "CERNER!AJpB0gEM+Fzsa4MFCqIGfQ"
 SET tempc->concepts[13].old_concept_cki = "CERNER!AJpB0gEM+Fzsa4MKCqIGfQ"
 SET tempc->concepts[14].new_concept_cki = "CERNER!AJpB0gEM+Fzsa4MRCqIGfQ"
 SET tempc->concepts[14].old_concept_cki = "CERNER!AJpB0gEM+Fzsa4MWCqIGfQ"
 SET tempc->concepts[15].new_concept_cki = "CERNER!AJpB0gEM+Fzsa4MrCqIGfQ"
 SET tempc->concepts[15].old_concept_cki = "CERNER!AJpB0gEM+Fzsa4MwCqIGfQ"
 SET tempc->concepts[16].new_concept_cki = "CERNER!AJpB0gEM+Fzsa4KlCqIGfQ"
 SET tempc->concepts[16].old_concept_cki = "CERNER!AJpB0gEM+Fzsa4KqCqIGfQ"
 SET tempc->concepts[17].new_concept_cki = "CERNER!AJpB0gEM+Fzsa4MdCqIGfQ"
 SET tempc->concepts[17].old_concept_cki = "CERNER!AJpB0gEM+Fzsa4MiCqIGfQ"
 SET tempc->concepts[18].new_concept_cki = "CERNER!AGbaLAEL/AZAS4EFCqIGfQ "
 SET tempc->concepts[18].old_concept_cki = "CERNER!AHi9DQEEYz0/zINzn4waeg"
 SET tempc->concepts[19].new_concept_cki = "CERNER!AfxL7AENb0gCCYAhCqIGfA"
 SET tempc->concepts[19].old_concept_cki = "CERNER!AfxL7AENb0gCCYAmCqIGfA"
 SET tempc->concepts[20].new_concept_cki = "CERNER!AJpB0gEM+Fzsa4JdCqIGfQ"
 SET tempc->concepts[20].old_concept_cki = "CERNER!AJpB0gEM+Fzsa4JiCqIGfQ"
 SET tempc->concepts[21].new_concept_cki = "CERNER!AJpB0gEM+Fzsa4JpCqIGfQ"
 SET tempc->concepts[21].old_concept_cki = "CERNER!AJpB0gEM+Fzsa4JuCqIGfQ"
 SET tempc->concepts[22].new_concept_cki = "CERNER!AJpB0gEM+Fzsa4J1CqIGfQ"
 SET tempc->concepts[22].old_concept_cki = "CERNER!AJpB0gEM+Fzsa4J6CqIGfQ"
 SET tempc->concepts[23].new_concept_cki = "CERNER!AJpB0gEM+Fzsa4KBCqIGfQ"
 SET tempc->concepts[23].old_concept_cki = "CERNER!AJpB0gEM+Fzsa4KGCqIGfQ"
 SET tempc->concepts[24].new_concept_cki = "CERNER!AJpB0gEM+Fzsa4KNCqIGfQ"
 SET tempc->concepts[24].old_concept_cki = "CERNER!AJpB0gEM+Fzsa4KSCqIGfQ"
 SET tempc->concepts[25].new_concept_cki = "CERNER!AJpB0gEM+Fzsa4KxCqIGfQ"
 SET tempc->concepts[25].old_concept_cki = "CERNER!AJpB0gEM+Fzsa4K2CqIGfQ"
 SET tempc->concepts[26].new_concept_cki = "CERNER!AfxL7AENb0gCCYAsCqIGfA"
 SET tempc->concepts[26].old_concept_cki = "CERNER!AfxL7AENb0gCCYAxCqIGfA"
 SET tempc->concepts[27].new_concept_cki = "CERNER!AfxL7AENb0gCCYAACqIGfA"
 SET tempc->concepts[27].old_concept_cki = "CERNER!AfxL7AENb0gCCYAFCqIGfA"
 SET tempc->concepts[28].new_concept_cki = "CERNER!AJpB0gEM+Fzsa4LVCqIGfQ"
 SET tempc->concepts[28].old_concept_cki = "CERNER!AJpB0gEM+Fzsa4LaCqIGfQ"
 SET tempc->concepts[29].new_concept_cki = "CERNER!AJpB0gEM+Fzsa4LhCqIGfQ"
 SET tempc->concepts[29].old_concept_cki = "CERNER!AJpB0gEM+Fzsa4LmCqIGfQ"
 SET tempc->concepts[30].new_concept_cki = "CERNER!AJpB0gEM+Fzsa4NPCqIGfQ"
 SET tempc->concepts[30].old_concept_cki = "CERNER!AJpB0gEM+Fzsa4NUCqIGfQ"
 SET tempc->concepts[31].new_concept_cki = "CERNER!AJpB0gEM+Fzsa4M3CqIGfQ"
 SET tempc->concepts[31].old_concept_cki = "CERNER!AJpB0gEM+Fzsa4M8CqIGfQ"
 SET tempc->concepts[32].new_concept_cki = "CERNER!AJpB0gEM+Fzsa4NDCqIGfQ"
 SET tempc->concepts[32].old_concept_cki = "CERNER!AJpB0gEM+Fzsa4NICqIGfQ"
 SET tempc->concepts[33].new_concept_cki = "CERNER!AJpB0gEM+Fzsa4NnCqIGfQ"
 SET tempc->concepts[33].old_concept_cki = "CERNER!AJpB0gEM+Fzsa4NsCqIGfQ"
 SET tempc->concepts[34].new_concept_cki = "CERNER!AJpB0gEM+Fzsa4NzCqIGfQ"
 SET tempc->concepts[34].old_concept_cki = "CERNER!AJpB0gEM+Fzsa4N4CqIGfQ"
 SET tempc->concepts[35].new_concept_cki = "CERNER!AJpB0gEM+Fzsa4OXCqIGfQ"
 SET tempc->concepts[35].old_concept_cki = "CERNER!AJpB0gEM+Fzsa4OcCqIGfQ"
 SET tempc->concepts[36].new_concept_cki = "CERNER!AJpB0gEM+Fzsa4N/CqIGfQ"
 SET tempc->concepts[36].old_concept_cki = "CERNER!AJpB0gEM+Fzsa4OECqIGfQ"
 SET tempc->concepts[37].new_concept_cki = "CERNER!AJpB0gEM+Fzsa4OLCqIGfQ"
 SET tempc->concepts[37].old_concept_cki = "CERNER!AJpB0gEM+Fzsa4OQCqIGfQ"
 SET tempc->concepts[38].new_concept_cki = "CERNER!AJpB0gEM+Fzsa4K9CqIGfQ"
 SET tempc->concepts[38].old_concept_cki = "CERNER!AJpB0gEM+Fzsa4LCCqIGfQ"
 SET tempc->concepts[39].new_concept_cki = "CERNER!AJpB0gEM+Fzsa4NbCqIGfQ"
 SET tempc->concepts[39].old_concept_cki = "CERNER!AJpB0gEM+Fzsa4NgCqIGfQ"
 SET tempc->concepts[40].new_concept_cki = "CERNER!AfxL7AENb0gCCal2CqIGfA"
 SET tempc->concepts[40].old_concept_cki = "CERNER!AHi9DQD9dnCFDJO0n4waeg"
 UPDATE  FROM br_auto_order_catalog b,
   (dummyt d  WITH seq = 40)
  SET b.concept_cki = tempc->concepts[d.seq].new_concept_cki, b.updt_dt_tm = cnvtdatetime(curdate,
    curtime3), b.updt_id = reqinfo->updt_id,
   b.updt_task = reqinfo->updt_task, b.updt_cnt = (b.updt_cnt+ 1), b.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d)
   JOIN (b
   WHERE (b.concept_cki=tempc->concepts[d.seq].old_concept_cki))
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Updating old CKI numbers: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 DELETE  FROM br_auto_order_catalog b
  WHERE ((b.concept_cki="  *") OR (b.concept_cki=null))
  WITH nocounter
 ;end delete
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Deleting from br_auto_order_catalog: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 DELETE  FROM br_auto_order_catalog b
  WHERE b.concept_cki="CERNER!ADN4jQEB/mnFuIYQn4waeg"
  WITH nocounter
 ;end delete
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Deleting from br_auto_order_catalog: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 DELETE  FROM br_auto_order_catalog b
  WHERE b.concept_cki="CERNER!AHi9DQD9dnCFDJekn4waeg"
  WITH nocounter
 ;end delete
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Deleting from br_auto_order_catalog: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 DELETE  FROM br_auto_oc_synonym b
  WHERE b.synonym_id > 0
  WITH nocounter
 ;end delete
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Deleting from br_auto_oc_synonym: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 DELETE  FROM br_other_names
  WHERE parent_entity_id > 0.0
  WITH nocounter
 ;end delete
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Deleting from br_other_names: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 DELETE  FROM br_other_names
  WHERE parent_entity_id=0.0
  WITH nocounter
 ;end delete
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Deleting from br_other_names: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 DELETE  FROM br_auto_oc_dta
  WHERE task_assay_cd > 0
  WITH nocounter
 ;end delete
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Deleting from br_auto_oc_dta: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 DELETE  FROM br_auto_oc_dta
  WHERE catalog_cd > 0
  WITH nocounter
 ;end delete
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Deleting from br_auto_oc_dta: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "NL:"
  FROM br_auto_order_catalog oc1,
   br_auto_order_catalog oc2
  PLAN (oc1
   WHERE oc1.concept_cki="CERNER!AHi9DQD9dnCFDI6Mn4waeg")
   JOIN (oc2
   WHERE oc1.concept_cki=oc2.concept_cki
    AND oc1.catalog_cd != oc2.catalog_cd)
  WITH nocounter
 ;end select
 SET del_code_value = 0.0
 IF (curqual > 1)
  SELECT INTO "NL:"
   FROM br_auto_order_catalog oc1
   WHERE oc1.concept_cki="CERNER!AHi9DQD9dnCFDI6Mn4waeg"
    AND  NOT ( EXISTS (
   (SELECT
    os2.catalog_cd
    FROM br_auto_oc_synonym os2
    WHERE os2.catalog_cd=oc1.catalog_cd)))
   DETAIL
    del_code_value = oc1.catalog_cd
   WITH nocounter
  ;end select
  IF (del_code_value > 0)
   DELETE  FROM br_auto_order_catalog
    WHERE catalog_cd=del_code_value
    WITH nocounter
   ;end delete
  ENDIF
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Readme Failed: Deleting from br_auto_order_catalog: ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
 DELETE  FROM br_auto_order_catalog b
  WHERE b.concept_cki="CPT*"
  WITH nocounter
 ;end delete
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Deleting from br_auto_order_catalog: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 DELETE  FROM br_auto_order_catalog b
  WHERE b.concept_cki="CERNER!AHi9DQD9dnCFDJBon4waeg"
  WITH nocounter
 ;end delete
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Deleting from br_auto_order_catalog: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 DELETE  FROM br_auto_order_catalog b
  WHERE b.concept_cki="CERNER!AHi9DQD9dnCFDJhgn4waeg"
  WITH nocounter
 ;end delete
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Readme Failed: Deleting from br_auto_order_catalog: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "NL:"
  FROM br_oc_work b
  WHERE b.match_orderable_cd > 0
  WITH nocounter
 ;end select
 IF (curqual=0
  AND language_log != "EN_AU"
  AND language_log != "EN_CD"
  AND language_log != "EN_US")
  SELECT INTO "NL:"
   FROM br_name_value b
   WHERE b.br_nv_key1="DEL_BR_AUTO_OC"
   WITH nocounter
  ;end select
  IF (curqual=0)
   INSERT  FROM br_name_value b
    SET b.br_name_value_id = seq(bedrock_seq,nextval), b.br_nv_key1 = "DEL_BR_AUTO_OC", b.br_value =
     " ",
     b.br_name = " ", b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
     b.updt_task = reqinfo->updt_task, b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    SET readme_data->status = "F"
    SET readme_data->message = concat("Failed: Updating br_name_value for DEL_BR_AUTO_OC:",errmsg)
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
   DELETE  FROM br_auto_order_catalog b
    WHERE b.catalog_cd > 0
    WITH nocounter
   ;end delete
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Readme Failed: Deleting from br_auto_order_catalog: ",errmsg)
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
   DELETE  FROM br_auto_oc_synonym b
    WHERE b.catalog_cd > 0
    WITH nocounter
   ;end delete
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Readme Failed: Deleting from br_auto_oc_synonym: ",errmsg)
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
   DELETE  FROM br_auto_dta b
    WHERE b.task_assay_cd > 0
    WITH nocounter
   ;end delete
   SET errcode = error(errmsg,0)
   IF (errcode > 0)
    ROLLBACK
    SET readme_data->status = "F"
    SET readme_data->message = concat("Readme Failed: Deleting from br_auto_dta: ",errmsg)
    GO TO exit_script
   ELSE
    COMMIT
   ENDIF
  ENDIF
  DELETE  FROM br_auto_order_catalog b
   WHERE b.concept_cki="CERNER!AfxL7AELtlzibITQCqIGfA"
   WITH nocounter
  ;end delete
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Readme Failed: Deleting from br_auto_order_catalog: ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
  SET readme_data->status = "S"
  SET readme_data->message = "Readme Succeeded: <br_ps_oc_config.prg> script"
 ELSE
  EXECUTE dm_dbimport "cer_install:ps_oc.csv", "br_ps_oc_config", 5000
 ENDIF
 IF ((readme_data->status="S"))
  DELETE  FROM br_auto_order_catalog b
   WHERE  NOT ( EXISTS (
   (SELECT
    b2.catalog_cd
    FROM br_auto_oc_synonym b2
    WHERE b2.catalog_cd=b.catalog_cd)))
    AND  NOT ( EXISTS (
   (SELECT
    b3.match_orderable_cd
    FROM br_oc_work b3
    WHERE b3.match_orderable_cd=b.catalog_cd)))
   WITH nocounter
  ;end delete
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   ROLLBACK
   SET readme_data->status = "F"
   SET readme_data->message = concat("Readme Failed: Deleting from br_auto_order_catalog: ",errmsg)
   GO TO exit_script
  ELSE
   COMMIT
  ENDIF
 ENDIF
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
