CREATE PROGRAM afc_upt_bce_event_log:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 bce_event_log_qual = i2
    1 bce_event_log[*]
      2 bce_event_log_id = f8
    1 new_batch_num = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
  SET action_begin = 1
  SET action_end = request->bce_event_log_qual
  SET reply->bce_event_log_qual = request->bce_event_log_qual
 ENDIF
 SET reply->status_data.status = "F"
 SET table_name = "BCE_EVENT_LOG"
 CALL upt_bce_event_log(action_begin,action_end)
 IF (failed != false)
  GO TO check_error
 ENDIF
#check_error
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  CASE (failed)
   OF gen_nbr_error:
    SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR"
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   OF replace_error:
    SET reply->status_data.subeventstatus[1].operationname = "REPLACE"
   OF delete_error:
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
   OF undelete_error:
    SET reply->status_data.subeventstatus[1].operationname = "UNDELETE"
   OF remove_error:
    SET reply->status_data.subeventstatus[1].operationname = "REMOVE"
   OF attribute_error:
    SET reply->status_data.subeventstatus[1].operationname = "ATTRIBUTE"
   OF lock_error:
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
 ENDIF
 GO TO end_program
 SUBROUTINE upt_bce_event_log(upt_begin,upt_end)
   FOR (x = upt_begin TO upt_end)
     SET blank_date = cnvtdatetime("01-JAN-1800 00:00:00.00")
     SET count1 = 0
     SET active_status_code = 0
     SELECT INTO "nl:"
      b.*
      FROM bce_event_log b
      WHERE (b.bce_event_log_id=request->bce_event_log[x].bce_event_log_id)
      HEAD REPORT
       count1 = 0
      DETAIL
       count1 = (count1+ 1), active_status_code = b.active_status_cd
      WITH forupdate(b)
     ;end select
     IF (curqual=0)
      SET failed = lock_error
      RETURN
     ENDIF
     UPDATE  FROM bce_event_log b
      SET b.batch_num = evaluate(request->bce_event_log[x].batch_num,0.0,b.batch_num,- (1.0),0.0,
        request->bce_event_log[x].batch_num), b.ext_master_event_id = evaluate(request->
        bce_event_log[x].ext_master_event_id,0.0,b.ext_master_event_id,- (1.0),0.0,
        request->bce_event_log[x].ext_master_event_id), b.person_id = evaluate(request->
        bce_event_log[x].person_id,0.0,b.person_id,- (1.0),0.0,
        request->bce_event_log[x].person_id),
       b.encntr_id = evaluate(request->bce_event_log[x].encntr_id,0.0,b.encntr_id,- (1.0),0.0,
        request->bce_event_log[x].encntr_id), b.perf_loc_cd = evaluate(request->bce_event_log[x].
        perf_loc_cd,0.0,b.perf_loc_cd,- (1.0),0.0,
        request->bce_event_log[x].perf_loc_cd), b.ren_phys_id = evaluate(request->bce_event_log[x].
        ren_phys_id,0.0,b.ren_phys_id,- (1.0),0.0,
        request->bce_event_log[x].ren_phys_id),
       b.ord_phys_id = evaluate(request->bce_event_log[x].ord_phys_id,0.0,b.ord_phys_id,- (1.0),0.0,
        request->bce_event_log[x].ord_phys_id), b.ref_phys_id = evaluate(request->bce_event_log[x].
        ref_phys_id,0.0,b.ref_phys_id,- (1.0),0.0,
        request->bce_event_log[x].ref_phys_id), b.accession = evaluate(request->bce_event_log[x].
        accession," ",b.accession,'""',null,
        request->bce_event_log[x].accession),
       b.bill_item_id = evaluate(request->bce_event_log[x].bill_item_id,0.0,b.bill_item_id,- (1.0),
        0.0,
        request->bce_event_log[x].bill_item_id), b.charge_description = evaluate(request->
        bce_event_log[x].charge_description," ",b.charge_description,'""',null,
        request->bce_event_log[x].charge_description), b.service_dt_tm = evaluate(request->
        bce_event_log[x].service_dt_tm,0.0,b.service_dt_tm,blank_date,null,
        cnvtdatetime(request->bce_event_log[x].service_dt_tm)),
       b.quantity = evaluate(request->bce_event_log[x].quantity,0.0,b.quantity,- (1.0),0.0,
        request->bce_event_log[x].quantity), b.diag_code1 = evaluate(request->bce_event_log[x].
        diag_code1," ",b.diag_code1,'""',null,
        request->bce_event_log[x].diag_code1), b.diag_code1_desc = evaluate(request->bce_event_log[x]
        .diag_code1_desc," ",b.diag_code1_desc,'""',null,
        request->bce_event_log[x].diag_code1_desc),
       b.diag_code2 = evaluate(request->bce_event_log[x].diag_code2," ",b.diag_code2,'""',null,
        request->bce_event_log[x].diag_code2), b.diag_code2_desc = evaluate(request->bce_event_log[x]
        .diag_code2_desc," ",b.diag_code2_desc,'""',null,
        request->bce_event_log[x].diag_code2_desc), b.diag_code3 = evaluate(request->bce_event_log[x]
        .diag_code3," ",b.diag_code3,'""',null,
        request->bce_event_log[x].diag_code3),
       b.diag_code3_desc = evaluate(request->bce_event_log[x].diag_code3_desc," ",b.diag_code3_desc,
        '""',null,
        request->bce_event_log[x].diag_code3_desc), b.diag_code4 = evaluate(request->bce_event_log[x]
        .diag_code4," ",b.diag_code4,'""',null,
        request->bce_event_log[x].diag_code4), b.diag_code4_desc = evaluate(request->bce_event_log[x]
        .diag_code4_desc," ",b.diag_code4_desc,'""',null,
        request->bce_event_log[x].diag_code4_desc),
       b.diag_code5 = evaluate(request->bce_event_log[x].diag_code5," ",b.diag_code5,'""',null,
        request->bce_event_log[x].diag_code5), b.diag_code5_desc = evaluate(request->bce_event_log[x]
        .diag_code5_desc," ",b.diag_code5_desc,'""',null,
        request->bce_event_log[x].diag_code5_desc), b.diag_code6 = evaluate(request->bce_event_log[x]
        .diag_code6," ",b.diag_code6,'""',null,
        request->bce_event_log[x].diag_code6),
       b.diag_code6_desc = evaluate(request->bce_event_log[x].diag_code6_desc," ",b.diag_code6_desc,
        '""',null,
        request->bce_event_log[x].diag_code6_desc), b.diag_code7 = evaluate(request->bce_event_log[x]
        .diag_code7," ",b.diag_code7,'""',null,
        request->bce_event_log[x].diag_code7), b.diag_code7_desc = evaluate(request->bce_event_log[x]
        .diag_code7_desc," ",b.diag_code7_desc,'""',null,
        request->bce_event_log[x].diag_code7_desc),
       b.abn_status_cd = evaluate(request->bce_event_log[x].abn_status_cd,0.0,b.abn_status_cd,- (1.0),
        0.0,
        request->bce_event_log[x].abn_status_cd), b.price = evaluate(request->bce_event_log[x].price,
        0.0,b.price,- (1.0),0.0,
        request->bce_event_log[x].price), b.epsdt_ind = evaluate(request->bce_event_log[x].epsdt_ind,
        0,b.epsdt_ind,1,request->bce_event_log[x].epsdt_ind,
        b.epsdt_ind),
       b.code_modifier1_cd = evaluate(request->bce_event_log[x].code_modifier1_cd,0.0,b
        .code_modifier1_cd,- (1.0),0.0,
        request->bce_event_log[x].code_modifier1_cd), b.code_modifier2_cd = evaluate(request->
        bce_event_log[x].code_modifier2_cd,0.0,b.code_modifier2_cd,- (1.0),0.0,
        request->bce_event_log[x].code_modifier2_cd), b.code_modifier3_cd = evaluate(request->
        bce_event_log[x].code_modifier3_cd,0.0,b.code_modifier3_cd,- (1.0),0.0,
        request->bce_event_log[x].code_modifier3_cd),
       b.code_modifier4_cd = evaluate(request->bce_event_log[x].code_modifier4_cd,0.0,b
        .code_modifier4_cd,- (1.0),0.0,
        request->bce_event_log[x].code_modifier4_cd), b.reason_comment = evaluate(request->
        bce_event_log[x].reason_comment," ",b.reason_comment,'""',null,
        request->bce_event_log[x].reason_comment), b.reason_cd = evaluate(request->bce_event_log[x].
        reason_cd,0.0,b.reason_cd,- (1.0),0.0,
        request->bce_event_log[x].reason_cd),
       b.charge_type_cd = evaluate(request->bce_event_log[x].charge_type_cd,0.0,b.charge_type_cd,- (
        1.0),0.0,
        request->bce_event_log[x].charge_type_cd), b.institution_cd = evaluate(request->
        bce_event_log[x].institution_cd,0.0,b.institution_cd,- (1.0),0.0,
        request->bce_event_log[x].institution_cd), b.department_cd = evaluate(request->bce_event_log[
        x].department_cd,0.0,b.department_cd,- (1.0),0.0,
        request->bce_event_log[x].department_cd),
       b.section_cd = evaluate(request->bce_event_log[x].section_cd,0.0,b.section_cd,- (1.0),0.0,
        request->bce_event_log[x].section_cd), b.subsection_cd = evaluate(request->bce_event_log[x].
        subsection_cd,0.0,b.subsection_cd,- (1.0),0.0,
        request->bce_event_log[x].subsection_cd), b.level5_cd = evaluate(request->bce_event_log[x].
        level5_cd,0.0,b.level5_cd,- (1.0),0.0,
        request->bce_event_log[x].level5_cd),
       b.submit_ind = evaluate(request->bce_event_log[x].submit_ind,0,b.submit_ind,1,request->
        bce_event_log[x].submit_ind,
        b.submit_ind), b.misc_ind = evaluate(request->bce_event_log[x].misc_ind,0,b.misc_ind,1,
        request->bce_event_log[x].misc_ind,
        b.misc_ind), b.active_ind = nullcheck(b.active_ind,request->bce_event_log[x].active_ind,
        IF ((request->bce_event_log[x].active_ind=false)) 0
        ELSE 1
        ENDIF
        ),
       b.mode_ind = evaluate(request->bce_event_log[x].mode_ind,0,b.mode_ind,1,request->
        bce_event_log[x].mode_ind,
        b.mode_ind), b.bill_code_txt = evaluate(request->bce_event_log[x].bill_code_txt," ",b
        .bill_code_txt,'""',null,
        request->bce_event_log[x].bill_code_txt), b.batch_alias = evaluate(request->bce_event_log[x].
        batch_alias," ",b.batch_alias,'""',null,
        request->bce_event_log[x].batch_alias),
       b.batch_description = evaluate(request->bce_event_log[x].batch_description," ",b
        .batch_description,'""',null,
        request->bce_event_log[x].batch_description), b.batch_dt_tm = evaluate(request->
        bce_event_log[x].batch_dt_tm,0.0,b.batch_dt_tm,blank_date,cnvtdatetime(curdate,curtime3),
        cnvtdatetime(request->bce_event_log[x].batch_dt_tm)), b.active_status_cd = active_status_cd,
       b.active_status_prsnl_id = reqinfo->updt_id, b.active_status_dt_tm = cnvtdatetime(curdate,
        curtime3), b.updt_cnt = (b.updt_cnt+ 1),
       b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_applctx =
       reqinfo->updt_applctx,
       b.updt_task = reqinfo->updt_task
      WHERE (b.bce_event_log_id=request->bce_event_log[x].bce_event_log_id)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = update_error
      RETURN
     ELSE
      SET stat = alterlist(reply->bce_event_log,x)
      SET reply->bce_event_log[x].bce_event_log_id = request->bce_event_log[x].bce_event_log_id
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
