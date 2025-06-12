CREATE PROGRAM bed_ens_oc_dta_ps:dba
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
   1 auto_catalog_cd = f8
   1 dta_list[*]
     2 task_assay_cd = f8
 )
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 DECLARE error_msg = vc
 SET dtacount = 0
 SET dtalistcount = 0
 SET last_concept_cki = fillstring(40," ")
 SET orc_cnt = size(requestin->list_0,5)
 SET active_code_value = 0.0
 SET i = 0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="ACTIVE"
   AND cv.active_ind=1
  DETAIL
   active_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET stat = alterlist(orc->dta_list,5)
 SET dtacount = 0
 SET dtalistcount = 0
 FOR (x = 1 TO orc_cnt)
   IF ((requestin->list_0[x].concept_cki > "   *"))
    IF (last_concept_cki > "   *")
     SET stat = alterlist(orc->dta_list,dtacount)
     CALL echorecord(orc)
     FOR (i = 1 TO dtacount)
      INSERT  FROM br_auto_oc_dta b
       SET b.catalog_cd = orc->catalog_cd, b.task_assay_cd = orc->dta_list[i].task_assay_cd, b
        .sequence = i,
        b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
        reqinfo->updt_task,
        b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat("Unable to insert orderable ",trim(requestin->list_0[x].
         primary_mnemonic)," with assay ",trim(requestin->list_0[x].assay_mnemonic),
        " into br_auto_oc_dta table.")
       GO TO exit_script
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
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to get the catalog_cd for orderable ",trim(requestin->list_0[x].
       primary_mnemonic))
     GO TO exit_script
    ENDIF
    SET dtacount = (dtacount+ 1)
    SET dtalistcount = (dtalistcount+ 1)
    SELECT INTO "NL:"
     FROM br_auto_dta dta
     WHERE (dta.mnemonic=requestin->list_0[x].assay_mnemonic)
     DETAIL
      orc->dta_list[dtacount].task_assay_cd = dta.task_assay_cd
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to get the task_assay_cd for assay. ",trim(requestin->list_0[x].
       assay_mnemonic)," for orderable ",trim(requestin->list_0[x].primary_mnemonic))
     GO TO exit_script
    ENDIF
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
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to get the task_assay_cd for assay. ",trim(requestin->list_0[x].
       assay_mnemonic)," for orderable ",trim(requestin->list_0[x].primary_mnemonic))
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 SET stat = alterlist(orc->dta_list,dtacount)
 FOR (i = 1 TO dtacount)
  INSERT  FROM br_auto_oc_dta b
   SET b.catalog_cd = orc->catalog_cd, b.task_assay_cd = orc->dta_list[i].task_assay_cd, b.sequence
     = i,
    b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
    reqinfo->updt_task,
    b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET error_flag = "Y"
   SET error_msg = concat("Unable to insert orderable ",trim(requestin->list_0[x].primary_mnemonic),
    " with assay ",trim(requestin->list_0[x].assay_mnemonic)," into br_auto_oc_dta table.")
   GO TO exit_script
  ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  CALL echo(error_msg)
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_OC_DTA_PS","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
