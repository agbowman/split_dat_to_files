CREATE PROGRAM afc_add_bce_event_log:dba
 SET afc_add_bce_event_log = "323720.FT.013"
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
 IF ((request->bce_event_log[1].mode_ind=1)
  AND action_begin=1)
  SELECT INTO "nl:"
   y = seq(bce_batch_num_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    default_mode_batch_number = cnvtreal(y)
   WITH format, counter
  ;end select
 ELSEIF ((request->bce_event_log[1].mode_ind=1))
  SET default_mode_batch_number = reply->new_batch_num
 ENDIF
 DECLARE active_code = f8
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 SET code_set = 48
 SET cdf_meaning = "ACTIVE"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,active_code)
 CALL add_bce_event_log(action_begin,action_end)
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
 SUBROUTINE add_bce_event_log(add_begin,add_end)
   FOR (x = add_begin TO add_end)
     SET blank_date = cnvtdatetime("01-JAN-1800 00:00:00.00")
     SET new_nbr = 0.0
     SELECT INTO "nl:"
      y = seq(bce_event_log_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       new_nbr = cnvtreal(y)
      WITH format, counter
     ;end select
     CALL echo(build("new_nbr is ",new_nbr))
     IF (curqual=0)
      SET failed = gen_nbr_error
      RETURN
     ELSE
      SET request->bce_event_log[x].bce_event_log_id = new_nbr
     ENDIF
     INSERT  FROM bce_event_log b
      SET b.bce_event_log_id = new_nbr, b.batch_num =
       IF ((request->bce_event_log[x].mode_ind=1)) default_mode_batch_number
       ELSEIF ((request->bce_event_log[x].batch_num <= 0)) 0
       ELSE request->bce_event_log[x].batch_num
       ENDIF
       , b.ext_master_event_id =
       IF ((request->bce_event_log[x].ext_master_event_id <= 0)) 0
       ELSE request->bce_event_log[x].ext_master_event_id
       ENDIF
       ,
       b.person_id =
       IF ((request->bce_event_log[x].person_id <= 0)) 0
       ELSE request->bce_event_log[x].person_id
       ENDIF
       , b.encntr_id =
       IF ((request->bce_event_log[x].encntr_id <= 0)) 0
       ELSE request->bce_event_log[x].encntr_id
       ENDIF
       , b.perf_loc_cd =
       IF ((request->bce_event_log[x].perf_loc_cd <= 0)) 0
       ELSE request->bce_event_log[x].perf_loc_cd
       ENDIF
       ,
       b.ren_phys_id =
       IF ((request->bce_event_log[x].ren_phys_id <= 0)) 0
       ELSE request->bce_event_log[x].ren_phys_id
       ENDIF
       , b.ord_phys_id =
       IF ((request->bce_event_log[x].ord_phys_id <= 0)) 0
       ELSE request->bce_event_log[x].ord_phys_id
       ENDIF
       , b.ref_phys_id =
       IF ((request->bce_event_log[x].ref_phys_id <= 0)) 0
       ELSE request->bce_event_log[x].ref_phys_id
       ENDIF
       ,
       b.accession =
       IF ((request->bce_event_log[x].accession='""')) null
       ELSE request->bce_event_log[x].accession
       ENDIF
       , b.bill_item_id =
       IF ((request->bce_event_log[x].bill_item_id <= 0)) 0
       ELSE request->bce_event_log[x].bill_item_id
       ENDIF
       , b.charge_description =
       IF ((request->bce_event_log[x].charge_description='""')) null
       ELSE request->bce_event_log[x].charge_description
       ENDIF
       ,
       b.service_dt_tm =
       IF ((((request->bce_event_log[x].service_dt_tm <= 0)) OR ((request->bce_event_log[x].
       service_dt_tm=blank_date))) ) null
       ELSE cnvtdatetime(request->bce_event_log[x].service_dt_tm)
       ENDIF
       , b.quantity =
       IF ((request->bce_event_log[x].quantity <= 0)) 0
       ELSE request->bce_event_log[x].quantity
       ENDIF
       , b.diag_code1 =
       IF ((request->bce_event_log[x].diag_code1='""')) null
       ELSE request->bce_event_log[x].diag_code1
       ENDIF
       ,
       b.diag_code1_desc =
       IF ((request->bce_event_log[x].diag_code1_desc='""')) null
       ELSE request->bce_event_log[x].diag_code1_desc
       ENDIF
       , b.diag_code2 =
       IF ((request->bce_event_log[x].diag_code2='""')) null
       ELSE request->bce_event_log[x].diag_code2
       ENDIF
       , b.diag_code2_desc =
       IF ((request->bce_event_log[x].diag_code2_desc='""')) null
       ELSE request->bce_event_log[x].diag_code2_desc
       ENDIF
       ,
       b.diag_code3 =
       IF ((request->bce_event_log[x].diag_code3='""')) null
       ELSE request->bce_event_log[x].diag_code3
       ENDIF
       , b.diag_code3_desc =
       IF ((request->bce_event_log[x].diag_code3_desc='""')) null
       ELSE request->bce_event_log[x].diag_code3_desc
       ENDIF
       , b.diag_code4 =
       IF ((request->bce_event_log[x].diag_code4='""')) null
       ELSE request->bce_event_log[x].diag_code4
       ENDIF
       ,
       b.diag_code4_desc =
       IF ((request->bce_event_log[x].diag_code4_desc='""')) null
       ELSE request->bce_event_log[x].diag_code4_desc
       ENDIF
       , b.diag_code5 =
       IF ((request->bce_event_log[x].diag_code5='""')) null
       ELSE request->bce_event_log[x].diag_code5
       ENDIF
       , b.diag_code5_desc =
       IF ((request->bce_event_log[x].diag_code5_desc='""')) null
       ELSE request->bce_event_log[x].diag_code5_desc
       ENDIF
       ,
       b.diag_code6 =
       IF ((request->bce_event_log[x].diag_code6='""')) null
       ELSE request->bce_event_log[x].diag_code6
       ENDIF
       , b.diag_code6_desc =
       IF ((request->bce_event_log[x].diag_code6_desc='""')) null
       ELSE request->bce_event_log[x].diag_code6_desc
       ENDIF
       , b.diag_code7 =
       IF ((request->bce_event_log[x].diag_code7='""')) null
       ELSE request->bce_event_log[x].diag_code7
       ENDIF
       ,
       b.diag_code7_desc =
       IF ((request->bce_event_log[x].diag_code7_desc='""')) null
       ELSE request->bce_event_log[x].diag_code7_desc
       ENDIF
       , b.abn_status_cd =
       IF ((request->bce_event_log[x].abn_status_cd <= 0)) 0
       ELSE request->bce_event_log[x].abn_status_cd
       ENDIF
       , b.price =
       IF ((request->bce_event_log[x].price <= 0)) 0
       ELSE request->bce_event_log[x].price
       ENDIF
       ,
       b.epsdt_ind =
       IF ((request->bce_event_log[x].epsdt_ind=false)) null
       ELSE request->bce_event_log[x].epsdt_ind
       ENDIF
       , b.code_modifier1_cd =
       IF ((request->bce_event_log[x].code_modifier1_cd <= 0)) 0
       ELSE request->bce_event_log[x].code_modifier1_cd
       ENDIF
       , b.code_modifier2_cd =
       IF ((request->bce_event_log[x].code_modifier2_cd <= 0)) 0
       ELSE request->bce_event_log[x].code_modifier2_cd
       ENDIF
       ,
       b.code_modifier3_cd =
       IF ((request->bce_event_log[x].code_modifier3_cd <= 0)) 0
       ELSE request->bce_event_log[x].code_modifier3_cd
       ENDIF
       , b.code_modifier4_cd =
       IF ((request->bce_event_log[x].code_modifier4_cd <= 0)) 0
       ELSE request->bce_event_log[x].code_modifier4_cd
       ENDIF
       , b.reason_comment =
       IF ((request->bce_event_log[x].reason_comment='""')) null
       ELSE request->bce_event_log[x].reason_comment
       ENDIF
       ,
       b.reason_cd =
       IF ((request->bce_event_log[x].reason_cd <= 0)) 0
       ELSE request->bce_event_log[x].reason_cd
       ENDIF
       , b.charge_type_cd =
       IF ((request->bce_event_log[x].charge_type_cd <= 0)) 0
       ELSE request->bce_event_log[x].charge_type_cd
       ENDIF
       , b.institution_cd =
       IF ((request->bce_event_log[x].institution_cd <= 0)) 0
       ELSE request->bce_event_log[x].institution_cd
       ENDIF
       ,
       b.department_cd =
       IF ((request->bce_event_log[x].department_cd <= 0)) 0
       ELSE request->bce_event_log[x].department_cd
       ENDIF
       , b.section_cd =
       IF ((request->bce_event_log[x].section_cd <= 0)) 0
       ELSE request->bce_event_log[x].section_cd
       ENDIF
       , b.subsection_cd =
       IF ((request->bce_event_log[x].subsection_cd <= 0)) 0
       ELSE request->bce_event_log[x].subsection_cd
       ENDIF
       ,
       b.level5_cd =
       IF ((request->bce_event_log[x].level5_cd <= 0)) 0
       ELSE request->bce_event_log[x].level5_cd
       ENDIF
       , b.submit_ind =
       IF ((request->bce_event_log[x].submit_ind=false)) null
       ELSE request->bce_event_log[x].submit_ind
       ENDIF
       , b.misc_ind =
       IF ((request->bce_event_log[x].misc_ind=false)) null
       ELSE request->bce_event_log[x].misc_ind
       ENDIF
       ,
       b.active_ind =
       IF ((request->bce_event_log[x].active_ind=false)) true
       ELSE request->bce_event_log[x].active_ind
       ENDIF
       , b.mode_ind = request->bce_event_log[x].mode_ind, b.bill_code_txt =
       IF ((request->bce_event_log[x].bill_code_txt='""')) null
       ELSE request->bce_event_log[x].bill_code_txt
       ENDIF
       ,
       b.batch_alias_key =
       IF ((request->bce_event_log[x].batch_alias='""')) ""
       ELSE cnvtupper(cnvtalphanum(request->bce_event_log[x].batch_alias))
       ENDIF
       , b.batch_alias =
       IF ((request->bce_event_log[x].batch_alias='""')) ""
       ELSE request->bce_event_log[x].batch_alias
       ENDIF
       , b.batch_description =
       IF ((request->bce_event_log[x].batch_description='""')) ""
       ELSE request->bce_event_log[x].batch_description
       ENDIF
       ,
       b.batch_dt_tm =
       IF ((((request->bce_event_log[x].batch_dt_tm <= 0)) OR ((request->bce_event_log[x].batch_dt_tm
       =blank_date))) ) cnvtdatetime(curdate,curtime3)
       ELSE cnvtdatetime(request->bce_event_log[x].batch_dt_tm)
       ENDIF
       , b.active_status_cd = active_code, b.active_status_prsnl_id = reqinfo->updt_id,
       b.active_status_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_cnt = 0, b.updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       b.updt_id = reqinfo->updt_id, b.updt_applctx = reqinfo->updt_applctx, b.updt_task = reqinfo->
       updt_task
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET failed = insert_error
      RETURN
     ELSE
      SET stat = alterlist(reply->bce_event_log,x)
      SET reply->bce_event_log[x].bce_event_log_id = request->bce_event_log[x].bce_event_log_id
      IF ((request->bce_event_log[x].mode_ind=1)
       AND action_begin=1)
       SET reply->new_batch_num = default_mode_batch_number
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
