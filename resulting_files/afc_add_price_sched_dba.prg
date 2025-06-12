CREATE PROGRAM afc_add_price_sched:dba
 CALL echo("*****PM_HEADER_CCL.inc - 668615****")
 IF ((validate(gen_nbr_error,- (9))=- (9)))
  DECLARE gen_nbr_error = i2 WITH constant(3)
 ENDIF
 IF ((validate(insert_error,- (9))=- (9)))
  DECLARE insert_error = i2 WITH constant(4)
 ENDIF
 IF ((validate(update_error,- (9))=- (9)))
  DECLARE update_error = i2 WITH constant(5)
 ENDIF
 IF ((validate(replace_error,- (9))=- (9)))
  DECLARE replace_error = i2 WITH constant(6)
 ENDIF
 IF ((validate(delete_error,- (9))=- (9)))
  DECLARE delete_error = i2 WITH constant(7)
 ENDIF
 IF ((validate(undelete_error,- (9))=- (9)))
  DECLARE undelete_error = i2 WITH constant(8)
 ENDIF
 IF ((validate(remove_error,- (9))=- (9)))
  DECLARE remove_error = i2 WITH constant(9)
 ENDIF
 IF ((validate(attribute_error,- (9))=- (9)))
  DECLARE attribute_error = i2 WITH constant(10)
 ENDIF
 IF ((validate(lock_error,- (9))=- (9)))
  DECLARE lock_error = i2 WITH constant(11)
 ENDIF
 IF ((validate(none_found,- (9))=- (9)))
  DECLARE none_found = i2 WITH constant(12)
 ENDIF
 IF ((validate(select_error,- (9))=- (9)))
  DECLARE select_error = i2 WITH constant(13)
 ENDIF
 IF ((validate(add_history_error,- (9))=- (9)))
  DECLARE add_history_error = i2 WITH constant(14)
 ENDIF
 IF ((validate(transaction_error,- (9))=- (9)))
  DECLARE transaction_error = i2 WITH constant(15)
 ENDIF
 IF ((validate(none_found_ft,- (9))=- (9)))
  DECLARE none_found_ft = i2 WITH constant(16)
 ENDIF
 IF ((validate(failed,- (9))=- (9)))
  DECLARE failed = i2 WITH noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH noconstant("")
  SET table_name = fillstring(50," ")
 ENDIF
 IF (validate(reply->status_data.status,"Z")="Z")
  CALL echo("Inside add price sched")
  CALL echorecord(request)
  RECORD reply(
    1 price_sched_qual = i2
    1 price_sched[*]
      2 price_sched_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
  SET action_begin = 1
  SET action_end = request->price_sched_qual
  SET reply->price_sched_qual = request->price_sched_qual
 ENDIF
 SET reply->status_data.status = "F"
 SET table_name = "PRICE_SCHED"
 CALL add_price_sched(action_begin,action_end)
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
 SUBROUTINE add_price_sched(add_begin,add_end)
   FOR (x = add_begin TO add_end)
     DECLARE code_set = i4
     DECLARE cdf_meaning = c12
     DECLARE active_code = f8
     SET code_set = 48
     SET cdf_meaning = "ACTIVE"
     DECLARE codecnt = i4
     SET codecnt = 1
     IF ((request->price_sched[x].active_status_cd=0))
      SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,codecnt,active_code)
     ENDIF
     SET new_nbr = 0.0
     SELECT INTO "nl:"
      y = seq(price_sched_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       new_nbr = cnvtreal(y)
      WITH format, counter
     ;end select
     IF (curqual=0)
      CALL echo("number generation error")
      SET failed = gen_nbr_error
      RETURN
     ELSE
      SET request->price_sched[x].price_sched_id = new_nbr
     ENDIF
     CALL echo("add_price_sched")
     CALL echorecord(request)
     INSERT  FROM price_sched p
      SET p.price_sched_id = new_nbr, p.price_sched_desc = request->price_sched[x].price_sched_desc,
       p.create_dt_tm = cnvtdatetime(sysdate),
       p.create_prsnl_id = reqinfo->updt_id, p.warning_dt_tm =
       IF ((request->price_sched[x].warning_dt_tm <= 0)) null
       ELSE cnvtdatetime(request->price_sched[x].warning_dt_tm)
       ENDIF
       , p.warning_prsnl_id =
       IF ((request->price_sched[x].warning_prsnl_id=0)) 0
       ELSE request->price_sched[x].warning_prsnl_id
       ENDIF
       ,
       p.warning_type_cd =
       IF ((request->price_sched[x].warning_type_cd=0)) 0
       ELSE request->price_sched[x].warning_type_cd
       ENDIF
       , p.beg_effective_dt_tm =
       IF ((request->price_sched[x].beg_effective_dt_tm <= 0)) cnvtdatetime(concat(format(curdate,
           "DD-MMM-YYYY;;D")," 00:00:00.00"))
       ELSE cnvtdatetime(request->price_sched[x].beg_effective_dt_tm)
       ENDIF
       , p.end_effective_dt_tm =
       IF ((request->price_sched[x].end_effective_dt_tm <= 0)) cnvtdatetime("31-dec-2100 23:59:59.99"
         )
       ELSE cnvtdatetime(request->price_sched[x].end_effective_dt_tm)
       ENDIF
       ,
       p.active_ind =
       IF ((request->price_sched[x].active_ind_ind=false)) true
       ELSE request->price_sched[x].active_ind
       ENDIF
       , p.active_status_cd =
       IF ((request->price_sched[x].active_status_cd=0)) active_code
       ELSE request->price_sched[x].active_status_cd
       ENDIF
       , p.active_status_prsnl_id =
       IF ((request->price_sched[x].active_status_prsnl_id=0)) reqinfo->updt_id
       ELSE request->price_sched[x].active_status_prsnl_id
       ENDIF
       ,
       p.active_status_dt_tm =
       IF ((request->price_sched[x].active_status_dt_tm <= 0)) cnvtdatetime(sysdate)
       ELSE cnvtdatetime(request->price_sched[x].active_status_dt_tm)
       ENDIF
       , p.updt_cnt = 0, p.updt_dt_tm = cnvtdatetime(sysdate),
       p.updt_id = reqinfo->updt_id, p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->
       updt_task,
       p.pharm_ind = request->price_sched[x].pharm_ind, p.formula_type_flg = request->price_sched[x].
       formula_type_flg, p.markup_level_flg = request->price_sched[x].markup_level_flg,
       p.apply_svc_fee_ind = request->price_sched[x].apply_svc_fee_ind, p.cost_basis_cd = request->
       price_sched[x].cost_basis_cd, p.price_sched_short_desc = request->price_sched[x].
       price_sched_short_desc,
       p.pharm_type_cd = request->price_sched[x].pharm_type_cd, p.range_type_cd = request->
       price_sched[x].range_type_cd, p.round_up = request->price_sched[x].round_up,
       p.min_price = request->price_sched[x].min_price, p.standard_sched_ind = request->price_sched[x
       ].standard_sched_ind, p.self_pay_ind = request->price_sched[x].self_pay_ind,
       p.compliance_check_ind =
       IF ((request->price_sched[x].rate_structure_ind=1)) request->price_sched[x].
        compliance_check_ind
       ELSE 0
       ENDIF
       , p.rounding_rate_flag =
       IF ((request->price_sched[x].rate_structure_ind=1)) request->price_sched[x].rounding_rate_flag
       ELSE 0
       ENDIF
       , p.conversion_factor_cd =
       IF ((request->price_sched[x].rate_structure_ind=1)) request->price_sched[x].
        conversion_factor_cd
       ELSE 0.0
       ENDIF
       ,
       p.operating_margin_pct =
       IF ((request->price_sched[x].rate_structure_ind=1)) request->price_sched[x].
        operating_margin_pct
       ELSE 0.0
       ENDIF
       , p.apply_markup_to_flag =
       IF (validate(request->price_sched.apply_markup_to_flag)=1) request->price_sched[x].
        apply_markup_to_flag
       ELSE 0.0
       ENDIF
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET failed = insert_error
      CALL echo("Insert Error")
      RETURN
     ELSE
      SET stat = alterlist(reply->price_sched,x)
      SET reply->price_sched[x].price_sched_id = request->price_sched[x].price_sched_id
      CALL echo("Insert Successful!")
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
