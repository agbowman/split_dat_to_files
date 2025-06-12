CREATE PROGRAM bed_imp_oc_dta_work:dba
 FREE SET reply
 RECORD reply(
   1 dta_list[*]
     2 dta_id = f8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 DECLARE error_msg = vc
 DECLARE facility = vc
 SET oc_code_value = 0.0
 SET new_seq = 0
 SET new_dta_id = 0.0
 SET tot_dta_count = 0
 SET dta_count = 0
 SET minutes = 0
 SET stat = alterlist(reply->dta_list,100)
 SET rel_cnt = size(requestin->list_0,5)
 SET last_oc_mnemonic = fillstring(100," ")
 FOR (x = 1 TO rel_cnt)
   SET requestin->list_0[x].catalog_cd = replace(requestin->list_0[x].catalog_cd," * "," ")
   SET requestin->list_0[x].catalog_cd = replace(requestin->list_0[x].catalog_cd,"* "," ")
   SET requestin->list_0[x].catalog_cd = replace(requestin->list_0[x].catalog_cd," *"," ")
   SET requestin->list_0[x].catalog_cd = replace(requestin->list_0[x].catalog_cd,"*"," ")
   IF (validate(requestin->list_0[x].facility) > 0)
    SET facility = trim(requestin->list_0[x].facility)
   ELSE
    SET facility = " "
   ENDIF
   IF (last_oc_mnemonic != cnvtupper(trim(requestin->list_0[x].catalog_cd)))
    SET last_oc_mnemonic = cnvtupper(trim(requestin->list_0[x].catalog_cd))
    SET oc_code_value = 0.0
    SET new_seq = 0
    SELECT INTO "NL:"
     FROM br_oc_work b
     WHERE cnvtupper(b.org_short_name)=last_oc_mnemonic
      AND cnvtupper(b.facility)=cnvtupper(facility)
     DETAIL
      oc_code_value = b.oc_id
     WITH nocounter
    ;end select
   ENDIF
   IF (oc_code_value > 0)
    SET new_dta_id = 0.0
    SELECT INTO "NL:"
     FROM br_dta_work b
     WHERE cnvtupper(b.short_desc)=cnvtupper(trim(requestin->list_0[x].task_assay_cd))
      AND cnvtupper(b.facility)=cnvtupper(facility)
     DETAIL
      new_dta_id = b.dta_id,
      CALL echo(build("found dta ",trim(requestin->list_0[x].task_assay_cd),cnvtstring(b.dta_id)))
     WITH nocounter
    ;end select
    IF (curqual=0)
     SELECT INTO "NL:"
      j = seq(reference_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       new_dta_id = cnvtreal(j)
      WITH format, counter
     ;end select
     SET alias = fillstring(40," ")
     SET alias = validate(requestin->list_0[x].task_assay_nbr," ")
     INSERT  FROM br_dta_work b
      SET b.dta_id = new_dta_id, b.short_desc = trim(requestin->list_0[x].task_assay_cd), b.facility
        = facility,
       b.alias = trim(alias), b.status_ind = 0, b.match_dta_cd = 0.0,
       b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
       reqinfo->updt_task,
       b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=1)
      SET tot_dta_count = (tot_dta_count+ 1)
      SET dta_count = (dta_count+ 1)
      IF (dta_count > 100)
       SET stat = alterlist(reply->dta_list,(tot_dta_count+ 100))
       SET dta_count = 0
      ENDIF
      SET reply->dta_list[tot_dta_count].dta_id = new_dta_id
     ELSE
      SET error_flag = "Y"
      SET error_msg = concat("Unable to insert ",trim(requestin->list_0[x].task_assay_cd),
       "into br_dta_work.")
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
   IF (oc_code_value > 0
    AND new_dta_id > 0)
    SET minutes = cnvtint(validate(requestin->list_0[x].interval_minutes,0))
    CALL echo(build("x = ",cnvtstring(x),"oc = ",trim(requestin->list_0[x].catalog_cd)," dta = ",
      trim(requestin->list_0[x].task_assay_cd)))
    SELECT INTO "NL"
     FROM br_dta_relationship b
     WHERE b.oc_id=oc_code_value
      AND b.dta_id=new_dta_id
     WITH nocounter
    ;end select
    IF (curqual=0)
     IF ((requestin->list_0[x].sequence > " "))
      SET new_seq = cnvtint(requestin->list_0[x].sequence)
     ELSE
      SET new_seq = (new_seq+ 1)
     ENDIF
     INSERT  FROM br_dta_relationship b
      SET b.oc_id = oc_code_value, b.dta_id = new_dta_id, b.sequence = new_seq,
       b.repeat_ind =
       IF (((cnvtupper(requestin->list_0[x].repeat_ind)="Y") OR ((requestin->list_0[x].repeat_ind="1"
       ))) ) 1
       ELSE 0
       ENDIF
       , b.restrict_display_ind =
       IF (((cnvtupper(requestin->list_0[x].restrict_display_ind)="Y") OR ((requestin->list_0[x].
       restrict_display_ind="1"))) ) 1
       ELSE 0
       ENDIF
       , b.pending_ind =
       IF (((cnvtupper(requestin->list_0[x].pending_ind)="Y") OR ((requestin->list_0[x].pending_ind=
       "1"))) ) 1
       ELSE 0
       ENDIF
       ,
       b.interval_min = minutes, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->
       updt_id,
       b.updt_task = reqinfo->updt_task, b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
    ENDIF
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to insert oc = ",trim(requestin->list_0[x].catalog_cd),
      " with DTA = ",trim(requestin->list_0[x].task_assay_cd)," into br_dta_relationship.")
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 GO TO exit_script
#exit_script
 SET stat = alterlist(reply->dta_list,tot_dta_count)
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  CALL echo("**************************************************************")
  CALL echo("**************************************************************")
  CALL echo("*                                                            *")
  CALL echo("*  LEGACY ORDERS/DTA RELATIONSHIP FILE IMPORTED SUCCESSFULLY *")
  CALL echo("*                                                            *")
  CALL echo("**************************************************************")
  CALL echo("**************************************************************")
 ELSE
  CALL echo(error_msg)
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_IMP_OC_DTA_WORK","  >> ERROR MSG: ",error_msg
   )
  SET reqinfo->commit_ind = 0
  CALL echo("**************************************************************")
  CALL echo("**************************************************************")
  CALL echo("*                                                            *")
  CALL echo("*  LEGACY ORDERS/DTA RELATIONSHIP FILE IMPORT HAS FAILED     *")
  CALL echo("*  Do not run additional imports, contact the BEDROCK team   *")
  CALL echo("*                                                            *")
  CALL echo("**************************************************************")
  CALL echo("**************************************************************")
 ENDIF
END GO
