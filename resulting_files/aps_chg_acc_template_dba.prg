CREATE PROGRAM aps_chg_acc_template:dba
 RECORD reply(
   1 updt_cnt = i4
   1 template_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD aptemp(
   1 details[*]
     2 parent_entity_name = c30
 )
 DECLARE scase_priority = c16 WITH protect, constant("CASE_PRIORITY")
 DECLARE sreq_physician = c16 WITH protect, constant("REQ_PHYSICIAN")
 DECLARE sresp_pathologist = c16 WITH protect, constant("RESP_PATHOLOGIST")
 DECLARE sresp_resident = c16 WITH protect, constant("RESP_RESIDENT")
 DECLARE scopyto_physician = c16 WITH protect, constant("COPYTO_PHYSICIAN")
 DECLARE sspecimen_code = c16 WITH protect, constant("SPECIMEN_CODE")
 DECLARE sspec_adequacy = c16 WITH protect, constant("SPEC_ADEQUACY")
 DECLARE sspec_fixative = c16 WITH protect, constant("SPEC_FIXATIVE")
 DECLARE sspec_priority = c16 WITH protect, constant("SPEC_PRIORITY")
 DECLARE scode_value = c30 WITH protect, constant("CODE_VALUE")
 DECLARE sprsnl = c30 WITH protect, constant("PRSNL")
 DECLARE sparentname = c30 WITH protect, noconstant("")
 DECLARE next_seq_nbr = f8 WITH protect, noconstant(0.0)
#script
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET cur_updt_cnt = 0
 SET count1 = 0
 SET cur_updt_cnt2[100] = 0
 SET number_to_del = 0
 SET debug = 0
 IF (debug=1)
  CALL echo("")
  CALL echo(build("Template :",request->name,"->",request->template_cd))
  CALL echo(build("Num to Add :",request->add_detail_cnt))
  CALL echo(build("Num to Chg :",request->chg_detail_cnt))
 ENDIF
 SELECT INTO "nl:"
  cv.description
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=16689
    AND cnvtupper(request->name)=cnvtupper(cv.description)
    AND (request->template_cd != cv.code_value))
  DETAIL
   reply->updt_cnt = cv.updt_cnt, request->updt_cnt = reply->updt_cnt, reply->template_cd = cv
   .code_value
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "P"
  IF (debug=1)
   CALL echo("Error: Existing template by that name!")
  ENDIF
  GO TO exit_script
 ENDIF
 IF ((request->template_cd=0.00))
  SELECT INTO "nl:"
   seq_nbr = seq(reference_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    request->template_cd = cnvtreal(seq_nbr)
   WITH format, counter
  ;end select
  IF (curqual=0)
   GO TO seq_failed
  ENDIF
  INSERT  FROM code_value cv
   SET cv.code_set = 16689, cv.code_value = request->template_cd, cv.description = request->name,
    cv.display = request->name, cv.display_key = cnvtupper(cnvtalphanum(request->name)), cv
    .updt_dt_tm = cnvtdatetime(curdate,curtime),
    cv.updt_id = reqinfo->updt_id, cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->
    updt_applctx,
    cv.active_ind = request->active_ind, cv.updt_cnt = 0, cv.active_dt_tm = cnvtdatetime(curdate,
     curtime),
    cv.active_type_cd =
    IF ((request->active_ind=1)) reqdata->active_status_cd
    ELSE reqdata->inactive_status_cd
    ENDIF
    , cv.data_status_cd = reqdata->data_status_cd, cv.data_status_dt_tm = cnvtdatetime(curdate,
     curtime),
    cv.data_status_prsnl_id = reqinfo->updt_id
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "Insert"
   SET reply->status_data.subeventstatus[1].targetobjectname = "code_value"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build("template_cd: ",request->
    template_cd)
   IF (debug=1)
    CALL echo("Error: New template insert failed!")
   ENDIF
   ROLLBACK
   GO TO exit_script
  ENDIF
 ELSE
  IF ((request->action_flag="c"))
   SELECT INTO "nl:"
    cv.description
    FROM code_value cv
    WHERE (cv.code_value=request->template_cd)
    DETAIL
     cur_updt_cnt = cv.updt_cnt
    WITH nocounter, forupdate(cv)
   ;end select
   IF (curqual=0)
    SET stat = alter(reply->status_data.subeventstatus,1)
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].operationname = "Lock"
    SET reply->status_data.subeventstatus[1].targetobjectname = "code_value"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = build("template_cd: ",request->
     template_cd)
    IF (debug=1)
     CALL echo("Error: Lock Code_Value failed!")
    ENDIF
    ROLLBACK
    GO TO exit_script
   ENDIF
   IF ((request->updt_cnt != cur_updt_cnt))
    SET stat = alter(reply->status_data.subeventstatus,1)
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].operationname = "VerifyChg"
    SET reply->status_data.subeventstatus[1].targetobjectname = "code_value"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = build("template_cd: ",request->
     template_cd)
    IF (debug=1)
     CALL echo("Error: Template updt_cnt is off!")
    ENDIF
    ROLLBACK
    GO TO exit_script
   ENDIF
   IF ((request->active_ind=0))
    SELECT INTO "nl:"
     aatd.detail_name
     FROM ap_prefix_accn_template_r apatr
     WHERE (apatr.template_cd=request->template_cd)
     HEAD REPORT
      number_to_del = 0
     DETAIL
      number_to_del = (number_to_del+ 1)
     WITH nocounter
    ;end select
    IF (debug=1)
     CALL echo(build("Number_To_Del :",number_to_del))
    ENDIF
    DELETE  FROM ap_prefix_accn_template_r apatr,
      (dummyt d  WITH seq = value(number_to_del))
     SET apatr.template_cd = request->template_cd
     PLAN (d)
      JOIN (apatr
      WHERE (apatr.template_cd=request->template_cd))
     WITH nocounter
    ;end delete
    IF (curqual != number_to_del)
     SET stat = alter(reply->status_data.subeventstatus,1)
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].operationname = "Delete"
     SET reply->status_data.subeventstatus[1].targetobjectname = "ap_prefix_accn_template_r"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = build("number_to_del: ",
      number_to_del)
     IF (debug=1)
      CALL echo("Error: Delete didn't work!")
      CALL echo(build("Number_To_Del :",number_to_del))
      CALL echo(build("Curqual :",curqual))
     ENDIF
     ROLLBACK
     GO TO exit_script
    ENDIF
   ENDIF
   UPDATE  FROM code_value cv
    SET cv.description = request->name, cv.display = request->name, cv.display_key = cnvtupper(
      cnvtalphanum(request->name)),
     cv.active_ind = request->active_ind, cv.updt_cnt = (cv.updt_cnt+ 1), cv.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     cv.updt_id = reqinfo->updt_id, cv.updt_task = reqinfo->updt_task, cv.updt_applctx = reqinfo->
     updt_applctx,
     cv.active_dt_tm = cnvtdatetime(curdate,curtime), cv.active_type_cd =
     IF ((request->active_ind=1)) reqdata->active_status_cd
     ELSE reqdata->inactive_status_cd
     ENDIF
     , cv.data_status_cd = reqdata->data_status_cd,
     cv.data_status_dt_tm = cnvtdatetime(curdate,curtime), cv.data_status_prsnl_id = reqinfo->updt_id
    WHERE (cv.code_value=request->template_cd)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET stat = alter(reply->status_data.subeventstatus,1)
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].operationname = "Update"
    SET reply->status_data.subeventstatus[1].targetobjectname = "code_value"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = build("template_cd: ",request->
     template_cd)
    IF (debug=1)
     CALL echo("Error: Template update failed!")
    ENDIF
    ROLLBACK
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 IF ((request->copyto_flag="c")
  AND (request->add_detail_cnt > 0)
  AND (request->chg_detail_cnt=0))
  SELECT INTO "nl:"
   aatd.detail_name
   FROM ap_accn_template_detail aatd
   WHERE (aatd.template_cd=request->template_cd)
    AND aatd.detail_name="COPYTO_PHYSICIAN"
   HEAD REPORT
    number_to_del = 0
   DETAIL
    number_to_del = (number_to_del+ 1)
   WITH nocounter
  ;end select
  IF (debug=1)
   CALL echo(build("Number_To_Del :",number_to_del))
  ENDIF
  DELETE  FROM ap_accn_template_detail aatd,
    (dummyt d  WITH seq = value(number_to_del))
   SET aatd.template_cd = request->template_cd
   PLAN (d)
    JOIN (aatd
    WHERE (aatd.template_cd=request->template_cd)
     AND aatd.detail_name="COPYTO_PHYSICIAN")
   WITH nocounter
  ;end delete
  IF (curqual != number_to_del)
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "Delete"
   SET reply->status_data.subeventstatus[1].targetobjectname = "ap_accn_template_detail"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build("number_to_del: ",number_to_del
    )
   IF (debug=1)
    CALL echo("Error: Delete didn't work!")
    CALL echo(build("Number_To_Del :",number_to_del))
    CALL echo(build("Curqual :",curqual))
   ENDIF
   ROLLBACK
   GO TO exit_script
  ENDIF
 ENDIF
 SET cur_qual_cnt = 0
 FOR (x = 1 TO request->add_detail_cnt)
   SET next_seq_nbr = 0.0
   SELECT INTO "nl:"
    seq_nbr = seq(reference_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     next_seq_nbr = cnvtreal(seq_nbr)
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    GO TO seq_failed
   ENDIF
   IF (debug=1)
    CALL echo(build("Next_Seq_Nbr :",next_seq_nbr))
   ENDIF
   IF ((request->add_detail_qual[x].detail_name IN (scase_priority, sspecimen_code, sspec_adequacy,
   sspec_fixative, sspec_priority)))
    SET sparentname = scode_value
   ELSEIF ((request->add_detail_qual[x].detail_name IN (sreq_physician, sresp_pathologist,
   sresp_resident, scopyto_physician)))
    SET sparentname = sprsnl
   ELSE
    SET sparentname = " "
   ENDIF
   INSERT  FROM ap_accn_template_detail aatd
    SET aatd.template_detail_id = next_seq_nbr, aatd.template_cd = request->template_cd, aatd
     .detail_name = request->add_detail_qual[x].detail_name,
     aatd.detail_flag = request->add_detail_qual[x].detail_flag, aatd.detail_id = request->
     add_detail_qual[x].detail_id, aatd.parent_entity_name = sparentname,
     aatd.carry_forward_ind = request->add_detail_qual[x].carry_forward_ind, aatd
     .carry_forward_spec_ind = request->add_detail_qual[x].carry_forward_spec_ind, aatd.updt_cnt = 0,
     aatd.updt_dt_tm = cnvtdatetime(curdate,curtime3), aatd.updt_id = reqinfo->updt_id, aatd
     .updt_task = reqinfo->updt_task,
     aatd.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual != 1)
    SET stat = alter(reply->status_data.subeventstatus,1)
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].operationname = "Insert"
    SET reply->status_data.subeventstatus[1].targetobjectname = "ap_accn_template_detail"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = build("number_to_add: ",request->
     add_detail_cnt)
    IF (debug=1)
     CALL echo("Error: New template_detail insert failed!")
     CALL echo(build("Next_Seq_Nbr :",next_seq_nbr))
     CALL echo(build("Curqual :",curqual))
    ENDIF
    ROLLBACK
    GO TO exit_script
   ELSE
    SET cur_qual_cnt = (cur_qual_cnt+ curqual)
    CALL echo(build("Cur_Qual_Cnt :",cur_qual_cnt))
    CALL echo(build("X :",x))
   ENDIF
 ENDFOR
 IF ((cur_qual_cnt != request->add_detail_cnt))
  SET stat = alter(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "Insert"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ap_accn_template_detail"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = build("number_to_add: ",request->
   add_detail_cnt)
  IF (debug=1)
   CALL echo("Error: New template_detail insert failed!")
   CALL echo(build("Cur_Qual_Cnt :",cur_qual_cnt))
  ENDIF
  ROLLBACK
  GO TO exit_script
 ENDIF
 IF ((request->chg_detail_cnt > 0))
  SELECT INTO "nl:"
   aatd.template_detail_id
   FROM ap_accn_template_detail aatd,
    (dummyt d  WITH seq = value(request->chg_detail_cnt))
   PLAN (d)
    JOIN (aatd
    WHERE (aatd.template_detail_id=request->chg_detail_qual[d.seq].template_detail_id))
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1), cur_updt_cnt2[count1] = aatd.updt_cnt
   WITH nocounter, forupdate(aatd)
  ;end select
  IF ((count1 != request->chg_detail_cnt))
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "Lock"
   SET reply->status_data.subeventstatus[1].targetobjectname = "ap_accn_template_detail"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build("number_to_chg: ",request->
    chg_detail_cnt)
   IF (debug=1)
    CALL echo("Error1: Template_detail lock failed!")
    CALL echo(build("Count1 :",count1))
    CALL echo(build("Chg_Detail_Cnt :",request->chg_detail_cnt))
    FOR (x = 1 TO count1)
      CALL echo(build("Template_Detail_Id :",request->chg_detail_qual[x].template_detail_id,"_",
        request->chg_detail_qual[x].detail_name))
    ENDFOR
   ENDIF
   ROLLBACK
   GO TO exit_script
  ENDIF
  SET stat = alterlist(aptemp->details,request->chg_detail_cnt)
  FOR (xx = 1 TO request->chg_detail_cnt)
   IF ((request->chg_detail_qual[xx].updt_cnt != cur_updt_cnt2[xx]))
    SET stat = alter(reply->status_data.subeventstatus,1)
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].operationname = "lock"
    SET reply->status_data.subeventstatus[1].targetobjectname = "ap_accn_template_detail"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = build("number_to_chg: ",request->
     chg_detail_cnt)
    IF (debug=1)
     CALL echo("Error2: Template_detail lock failed!")
    ENDIF
    ROLLBACK
    GO TO exit_script
   ENDIF
   IF ((request->chg_detail_qual[xx].detail_name IN (scase_priority, sspecimen_code, sspec_adequacy,
   sspec_fixative, sspec_priority)))
    SET aptemp->details[xx].parent_entity_name = scode_value
   ELSEIF ((request->chg_detail_qual[xx].detail_name IN (sreq_physician, sresp_pathologist,
   sresp_resident, scopyto_physician)))
    SET aptemp->details[xx].parent_entity_name = sprsnl
   ELSE
    SET aptemp->details[xx].parent_entity_name = " "
   ENDIF
  ENDFOR
  UPDATE  FROM ap_accn_template_detail aatd,
    (dummyt d  WITH seq = value(request->chg_detail_cnt))
   SET aatd.detail_name = request->chg_detail_qual[d.seq].detail_name, aatd.detail_flag = request->
    chg_detail_qual[d.seq].detail_flag, aatd.detail_id = request->chg_detail_qual[d.seq].detail_id,
    aatd.parent_entity_name = aptemp->details[d.seq].parent_entity_name, aatd.carry_forward_ind =
    request->chg_detail_qual[d.seq].carry_forward_ind, aatd.carry_forward_spec_ind = request->
    chg_detail_qual[d.seq].carry_forward_spec_ind,
    aatd.updt_cnt = (aatd.updt_cnt+ 1), aatd.updt_dt_tm = cnvtdatetime(curdate,curtime3), aatd
    .updt_id = reqinfo->updt_id,
    aatd.updt_task = reqinfo->updt_task, aatd.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (aatd
    WHERE (aatd.template_detail_id=request->chg_detail_qual[d.seq].template_detail_id)
     AND (aatd.template_cd=request->template_cd))
   WITH nocounter
  ;end update
  IF ((curqual != request->chg_detail_cnt))
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "Update"
   SET reply->status_data.subeventstatus[1].targetobjectname = "ap_accn_template_detail"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build("number_to_chg: ",request->
    chg_detail_cnt)
   IF (debug=1)
    CALL echo("Error: Template_detail update failed!")
   ENDIF
   ROLLBACK
   GO TO exit_script
  ENDIF
 ENDIF
 COMMIT
 SET reply->template_cd = request->template_cd
 SET reply->updt_cnt = request->updt_cnt
 SET reply->status_data.status = "S"
 GO TO exit_script
#seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "nextval"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHNET_SEQ"
 IF (debug=1)
  CALL echo("Error: Seq failed!")
 ENDIF
 GO TO exit_script
#exit_script
 IF (debug=1)
  CALL echo("Script Completed!")
  CALL echo(build("Status :",reply->status_data.status))
 ENDIF
 FREE SET aptemp
END GO
