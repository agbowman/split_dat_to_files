CREATE PROGRAM bed_ens_mic_report_loinc:dba
 SET modify = predeclare
 RECORD reply(
   1 success[*]
     2 bedrock_row_id = i4
     2 concept_ident_mic_rpt_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE return_value = f8 WITH protect, noconstant(0.0)
 DECLARE failed = c1 WITH protect, noconstant("N")
 DECLARE concept_cki = vc WITH protect, noconstant("")
 DECLARE loinc_id = f8 WITH protect, noconstant(0.0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE error_code = i4 WITH protect, noconstant(0)
 DECLARE dup_found_flag = i2 WITH protect, noconstant(0)
 DECLARE x = i4 WITH protect, noconstant(0)
 DECLARE count = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE active_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE inactive_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"INACTIVE"))
 DECLARE loinc = c6 WITH protect, constant("LOINC!")
 SET reply->status_data.status = "F"
 FOR (x = 1 TO size(request->codes,5))
   IF ((request->codes[x].ignore_ind=1))
    SET concept_cki = " "
   ELSEIF (substring(1,6,request->codes[x].concept_cki)=loinc)
    SET concept_cki = request->codes[x].concept_cki
   ELSE
    SET concept_cki = concat(loinc,request->codes[x].concept_cki)
   ENDIF
   SET dup_found_flag = 0
   SELECT INTO "nl:"
    FROM concept_ident_mic_rpt cimr
    PLAN (cimr
     WHERE (cimr.service_resource_cd=request->codes[x].service_resource_cd)
      AND (cimr.task_cd=request->codes[x].task_cd)
      AND (cimr.catalog_cd=request->codes[x].catalog_cd)
      AND (cimr.source_cd=request->codes[x].source_cd)
      AND (cimr.concept_type_flag=request->codes[x].concept_type_flag)
      AND (cimr.org_class_flag=request->codes[x].org_class_flag)
      AND cimr.active_ind=1
      AND cimr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND cimr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND ((cimr.concept_ident_mic_rpt_id+ 0) != request->codes[x].concept_ident_mic_rpt_id))
    DETAIL
     IF ((request->codes[x].ignore_ind=cimr.ignore_ind)
      AND trim(concept_cki)=trim(cimr.concept_cki))
      dup_found_flag = 1, return_value = cimr.concept_ident_mic_rpt_id
     ELSE
      dup_found_flag = 2
     ENDIF
    WITH nocounter
   ;end select
   IF (dup_found_flag=0)
    IF ((request->codes[x].concept_ident_mic_rpt_id > 0.0))
     SELECT INTO "nl:"
      FROM concept_ident_mic_rpt cimr
      PLAN (cimr
       WHERE (cimr.concept_ident_mic_rpt_id=request->codes[x].concept_ident_mic_rpt_id))
      WITH nocounter, forupdate(cimr)
     ;end select
     IF (curqual=0)
      SET failed = "Y"
      SET error_msg = "Failed to lock cimr row for update."
      GO TO exit_script
     ENDIF
     UPDATE  FROM concept_ident_mic_rpt cimr
      SET cimr.active_ind = 0, cimr.active_status_cd = inactive_cd, cimr.end_effective_dt_tm =
       cnvtdatetime(curdate,curtime3),
       cimr.active_status_dt_tm = cnvtdatetime(curdate,curtime3), cimr.active_status_prsnl_id =
       reqinfo->updt_id, cimr.updt_applctx = reqinfo->updt_applctx,
       cimr.updt_cnt = (cimr.updt_cnt+ 1), cimr.updt_dt_tm = cnvtdatetime(curdate,curtime3), cimr
       .updt_id = reqinfo->updt_id,
       cimr.updt_task = reqinfo->updt_task
      PLAN (cimr
       WHERE (cimr.concept_ident_mic_rpt_id=request->codes[x].concept_ident_mic_rpt_id))
      WITH nocounter
     ;end update
     SET error_code = error(error_msg,1)
     IF (error_code > 0)
      SET failed = "Y"
      GO TO exit_script
     ENDIF
    ENDIF
    IF (((size(trim(request->codes[x].concept_cki)) > 0) OR ((request->codes[x].ignore_ind=1))) )
     SELECT INTO "nl:"
      y = seq(pathnet_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       loinc_id = cnvtreal(y)
      WITH format, counter
     ;end select
     INSERT  FROM concept_ident_mic_rpt cimr
      SET cimr.active_ind = 1, cimr.active_status_cd = active_cd, cimr.active_status_dt_tm =
       cnvtdatetime(curdate,curtime3),
       cimr.active_status_prsnl_id = reqinfo->updt_id, cimr.beg_effective_dt_tm = cnvtdatetime(
        curdate,curtime3), cimr.catalog_cd = request->codes[x].catalog_cd,
       cimr.concept_cki = concept_cki, cimr.concept_ident_mic_rpt_id = loinc_id, cimr
       .concept_type_flag = request->codes[x].concept_type_flag,
       cimr.end_effective_dt_tm = cnvtdatetime("31 DEC 2100 00:00"), cimr.ignore_ind = request->
       codes[x].ignore_ind, cimr.org_class_flag = request->codes[x].org_class_flag,
       cimr.service_resource_cd = request->codes[x].service_resource_cd, cimr.source_cd = request->
       codes[x].source_cd, cimr.task_cd = request->codes[x].task_cd,
       cimr.updt_applctx = reqinfo->updt_applctx, cimr.updt_cnt = 0, cimr.updt_dt_tm = cnvtdatetime(
        curdate,curtime3),
       cimr.updt_id = reqinfo->updt_id, cimr.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     SET error_code = error(error_msg,1)
     IF (error_code > 0)
      SET failed = "Y"
      GO TO exit_script
     ENDIF
     SET return_value = loinc_id
    ENDIF
   ELSEIF (dup_found_flag=2)
    SET failed = "P"
   ENDIF
   IF (dup_found_flag != 2)
    SET count = (count+ 1)
    IF (mod(count,10)=1)
     SET stat = alterlist(reply->success,(count+ 9))
    ENDIF
    SET reply->success[count].bedrock_row_id = request->codes[x].bedrock_row_id
    SET reply->success[count].concept_ident_mic_rpt_id = return_value
   ENDIF
 ENDFOR
 SET stat = alterlist(reply->success,count)
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = error_msg
 ELSEIF (failed="P")
  SET reply->status_data.status = "P"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET reqinfo->commit_ind = 1
 SET modify = nopredeclare
END GO
