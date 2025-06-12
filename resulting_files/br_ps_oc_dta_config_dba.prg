CREATE PROGRAM br_ps_oc_dta_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_ps_oc_dta_config.prg> script"
 RECORD requestin(
   1 list_0[*]
     2 concept_cki = vc
     2 assay_mnemonic = vc
 )
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET orc
 RECORD orc(
   1 catalog_cd = f8
   1 dta_list[*]
     2 task_assay_cd = f8
 )
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 SET dtacount = 0
 SET dtalistcount = 0
 SET last_concept_cki = fillstring(40," ")
 SET orc_cnt = size(requestin->list_0,5)
 SET i = 0
 SET stat = alterlist(orc->dta_list,5)
 SET dtacount = 0
 SET dtalistcount = 0
 FOR (x = 1 TO orc_cnt)
   IF ((requestin->list_0[x].concept_cki > "   *"))
    IF (last_concept_cki > "   *")
     SET stat = alterlist(orc->dta_list,dtacount)
     FOR (i = 1 TO dtacount)
      SELECT INTO "NL:"
       FROM br_auto_oc_dta baoc
       WHERE (baoc.catalog_cd=orc->catalog_cd)
        AND (baoc.task_assay_cd=orc->dta_list[i].task_assay_cd)
      ;end select
      IF (curqual=0)
       IF ((orc->catalog_cd > 0.0)
        AND (orc->dta_list[i].task_assay_cd > 0.0))
        INSERT  FROM br_auto_oc_dta b
         SET b.catalog_cd = orc->catalog_cd, b.task_assay_cd = orc->dta_list[i].task_assay_cd, b
          .sequence = i,
          b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
          reqinfo->updt_task,
          b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
         WITH nocounter
        ;end insert
        SET errcode = error(errmsg,0)
        IF (errcode > 0)
         ROLLBACK
         SET readme_data->status = "F"
         SET readme_data->message = concat("Readme Failed: Inserting into br_auto_oc_dta: ",errmsg)
         GO TO exit_script
        ELSE
         COMMIT
        ENDIF
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
    SET last_concept_cki = requestin->list_0[x].concept_cki
    SET stat = alterlist(orc->dta_list,0)
    SET stat = alterlist(orc->dta_list,5)
    SET dtacount = 0
    SET dtalistcount = 0
    SELECT INTO "NL:"
     FROM br_auto_order_catalog oc
     WHERE (oc.concept_cki=requestin->list_0[x].concept_cki)
     DETAIL
      orc->catalog_cd = oc.catalog_cd
     WITH nocounter
    ;end select
    SET dtacount = (dtacount+ 1)
    SET dtalistcount = (dtalistcount+ 1)
    SELECT INTO "NL:"
     FROM br_auto_dta dta
     WHERE (dta.mnemonic=requestin->list_0[x].assay_mnemonic)
     DETAIL
      orc->dta_list[dtacount].task_assay_cd = dta.task_assay_cd
     WITH nocounter
    ;end select
   ELSE
    SET dtacount = (dtacount+ 1)
    SET dtalistcount = (dtalistcount+ 1)
    IF (dtalistcount > 5)
     SET stat = alterlist(orc->dta_list,(dtacount+ 5))
     SET dtalistcount = 1
    ENDIF
    SELECT INTO "NL:"
     FROM br_auto_dta dta
     WHERE (dta.mnemonic=requestin->list_0[x].assay_mnemonic)
     DETAIL
      orc->dta_list[dtacount].task_assay_cd = dta.task_assay_cd
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 SET stat = alterlist(orc->dta_list,dtacount)
 FOR (i = 1 TO dtacount)
  SELECT INTO "NL:"
   FROM br_auto_oc_dta baoc
   WHERE (baoc.catalog_cd=orc->catalog_cd)
    AND (baoc.task_assay_cd=orc->dta_list[i].task_assay_cd)
  ;end select
  IF (curqual=0)
   IF ((orc->catalog_cd > 0.0)
    AND (orc->dta_list[i].task_assay_cd > 0.0))
    INSERT  FROM br_auto_oc_dta b
     SET b.catalog_cd = orc->catalog_cd, b.task_assay_cd = orc->dta_list[i].task_assay_cd, b.sequence
       = i,
      b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
      reqinfo->updt_task,
      b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
     WITH nocounter
    ;end insert
    SET errcode = error(errmsg,0)
    IF (errcode > 0)
     ROLLBACK
     SET readme_data->status = "F"
     SET readme_data->message = concat("Readme Failed: Inserting into br_auto_dta: ",errmsg)
     GO TO exit_script
    ELSE
     COMMIT
    ENDIF
   ENDIF
  ENDIF
 ENDFOR
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_ps_oc_dta_config.prg> script"
#exit_script
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
