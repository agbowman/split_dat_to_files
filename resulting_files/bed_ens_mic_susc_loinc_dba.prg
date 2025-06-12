CREATE PROGRAM bed_ens_mic_susc_loinc:dba
 SET modify = predeclare
 RECORD reply(
   1 success[*]
     2 bedrock_row_id = i4
     2 concept_ident_mic_susc_id = f8
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
    FROM concept_ident_mic_susc cims
    PLAN (cims
     WHERE (cims.antibiotic_cd=request->codes[x].antibiotic_cd)
      AND (cims.method_cd=request->codes[x].method_cd)
      AND (cims.concept_type_flag=request->codes[x].concept_type_flag)
      AND cims.active_ind=1
      AND cims.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND cims.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND ((cims.concept_ident_mic_susc_id+ 0) != request->codes[x].concept_ident_mic_susc_id))
    DETAIL
     IF ((request->codes[x].ignore_ind=cims.ignore_ind)
      AND trim(concept_cki)=trim(cims.concept_cki))
      dup_found_flag = 1, return_value = cims.concept_ident_mic_susc_id
     ELSE
      dup_found_flag = 2
     ENDIF
    WITH nocounter
   ;end select
   IF (dup_found_flag=0)
    IF ((request->codes[x].concept_ident_mic_susc_id > 0.0))
     SELECT INTO "nl:"
      FROM concept_ident_mic_susc cims
      PLAN (cims
       WHERE (cims.concept_ident_mic_susc_id=request->codes[x].concept_ident_mic_susc_id))
      WITH nocounter, forupdate(cims)
     ;end select
     IF (curqual=0)
      SET failed = "Y"
      SET error_msg = "Failed to lock cims row for update."
      GO TO exit_script
     ENDIF
     UPDATE  FROM concept_ident_mic_susc cims
      SET cims.active_ind = 0, cims.active_status_cd = inactive_cd, cims.end_effective_dt_tm =
       cnvtdatetime(curdate,curtime3),
       cims.active_status_dt_tm = cnvtdatetime(curdate,curtime3), cims.active_status_prsnl_id =
       reqinfo->updt_id, cims.updt_applctx = reqinfo->updt_applctx,
       cims.updt_cnt = (cims.updt_cnt+ 1), cims.updt_dt_tm = cnvtdatetime(curdate,curtime3), cims
       .updt_id = reqinfo->updt_id,
       cims.updt_task = reqinfo->updt_task
      PLAN (cims
       WHERE (cims.concept_ident_mic_susc_id=request->codes[x].concept_ident_mic_susc_id))
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
     INSERT  FROM concept_ident_mic_susc cims
      SET cims.active_ind = 1, cims.active_status_cd = active_cd, cims.active_status_dt_tm =
       cnvtdatetime(curdate,curtime3),
       cims.active_status_prsnl_id = reqinfo->updt_id, cims.antibiotic_cd = request->codes[x].
       antibiotic_cd, cims.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
       cims.concept_cki = concept_cki, cims.concept_ident_mic_susc_id = loinc_id, cims
       .concept_type_flag = request->codes[x].concept_type_flag,
       cims.end_effective_dt_tm = cnvtdatetime("31 DEC 2100 00:00"), cims.ignore_ind = request->
       codes[x].ignore_ind, cims.method_cd = request->codes[x].method_cd,
       cims.updt_applctx = reqinfo->updt_applctx, cims.updt_cnt = 0, cims.updt_dt_tm = cnvtdatetime(
        curdate,curtime3),
       cims.updt_id = reqinfo->updt_id, cims.updt_task = reqinfo->updt_task
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
    SET reply->success[count].concept_ident_mic_susc_id = return_value
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
