CREATE PROGRAM afc_upt_price_sched:dba
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
 ENDIF
 DECLARE action_begin = i4
 DECLARE action_end = i4
 SET action_begin = 1
 SET action_end = request->price_sched_qual
 SET reply->price_sched_qual = request->price_sched_qual
 SET reply->status_data.status = "F"
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE inactive_code = f8
 DECLARE active_code = f8
 DECLARE cnt = i4
 SET code_set = 48
 SET cdf_meaning = "INACTIVE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,inactive_code)
 IF (stat > 0)
  SET failed = true
  SET reply->status_data.status = "F"
  GO TO check_error
 ENDIF
 SET code_set = 48
 SET cdf_meaning = "ACTIVE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,active_code)
 IF (stat > 0)
  EXECUTE then
  SET failed = true
  SET reply->status_data.status = "F"
  GO TO check_error
 ENDIF
 SET table_name = "PRICE_SCHED"
 CALL echo("price sched update request")
 CALL echorecord(request)
 CALL echo("action end")
 CALL echo(action_end)
 CALL upt_price_sched(action_begin,action_end)
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
 SUBROUTINE upt_price_sched(upt_begin,upt_end)
   FOR (x = upt_begin TO upt_end)
     SET cur_updt_cnt[value(upt_end)] = 0
     SET count1 = 0
     SELECT INTO "nl:"
      p.*
      FROM price_sched p,
       (dummyt d  WITH seq = value(upt_end))
      PLAN (d)
       JOIN (p
       WHERE (p.price_sched_id=request->price_sched[d.seq].price_sched_id))
      HEAD REPORT
       count1 = 0
      DETAIL
       count1 += 1, cur_updt_cnt[count1] = p.updt_cnt
      WITH forupdate(p)
     ;end select
     IF (count1 != upt_end)
      SET failed = lock_error
      RETURN
     ENDIF
     UPDATE  FROM price_sched p,
       (dummyt d  WITH seq = 1)
      SET p.seq = 1, p.price_sched_desc = nullcheck(p.price_sched_desc,request->price_sched[x].
        price_sched_desc,
        IF ((request->price_sched[x].price_sched_desc="")) 0
        ELSE 1
        ENDIF
        ), p.warning_dt_tm = nullcheck(p.warning_dt_tm,cnvtdatetime(request->price_sched[x].
         warning_dt_tm),
        IF ((request->price_sched[x].warning_dt_tm=0)) 0
        ELSE 1
        ENDIF
        ),
       p.warning_prsnl_id = nullcheck(p.warning_prsnl_id,request->price_sched[x].warning_prsnl_id,
        IF ((request->price_sched[x].warning_prsnl_id=0)) 0
        ELSE 1
        ENDIF
        ), p.warning_type_cd = nullcheck(p.warning_type_cd,request->price_sched[x].warning_type_cd,
        IF ((request->price_sched[x].warning_type_cd=0)) 0
        ELSE 1
        ENDIF
        ), p.beg_effective_dt_tm = nullcheck(p.beg_effective_dt_tm,cnvtdatetime(concat(format(request
           ->price_sched[x].beg_effective_dt_tm,"DD-MMM-YYYY;;D"),"00:00:00.00")),
        IF ((request->price_sched[x].beg_effective_dt_tm=0)) 0
        ELSE 1
        ENDIF
        ),
       p.end_effective_dt_tm = nullcheck(p.end_effective_dt_tm,cnvtdatetime(concat(format(request->
           price_sched[x].end_effective_dt_tm,"DD-MMM-YYYY;;D"),"23:59:59.99")),
        IF ((request->price_sched[x].end_effective_dt_tm=0)) 0
        ELSE 1
        ENDIF
        ), p.active_status_cd =
       IF ((request->price_sched[x].active_ind=1)) active_code
       ELSE inactive_code
       ENDIF
       , p.active_status_prsnl_id = nullcheck(p.active_status_prsnl_id,request->price_sched[x].
        active_status_prsnl_id,
        IF ((request->price_sched[x].active_status_prsnl_id=0)) 0
        ELSE 1
        ENDIF
        ),
       p.active_status_dt_tm = nullcheck(p.active_status_dt_tm,cnvtdatetime(request->price_sched[x].
         active_status_dt_tm),
        IF ((request->price_sched[x].active_status_dt_tm=0)) 0
        ELSE 1
        ENDIF
        ), p.active_ind = request->price_sched[x].active_ind, p.updt_cnt = (cur_updt_cnt[d.seq]+ 1),
       p.updt_dt_tm = cnvtdatetime(curdate,curtime), p.updt_id = reqinfo->updt_id, p.updt_applctx =
       reqinfo->updt_applctx,
       p.updt_task = reqinfo->updt_task, p.pharm_ind = request->price_sched[x].pharm_ind, p
       .formula_type_flg = request->price_sched[x].formula_type_flg,
       p.markup_level_flg = request->price_sched[x].markup_level_flg, p.apply_svc_fee_ind = request->
       price_sched[x].apply_svc_fee_ind, p.cost_basis_cd = request->price_sched[x].cost_basis_cd,
       p.price_sched_short_desc = request->price_sched[x].price_sched_short_desc, p.pharm_type_cd =
       request->price_sched[x].pharm_type_cd, p.range_type_cd = request->price_sched[x].range_type_cd,
       p.round_up = request->price_sched[x].round_up, p.min_price = request->price_sched[x].min_price,
       p.standard_sched_ind = request->price_sched[x].standard_sched_ind,
       p.self_pay_ind =
       IF ((request->price_sched[x].self_pay_ind_ind=1)) request->price_sched[x].self_pay_ind
       ELSE p.self_pay_ind
       ENDIF
       , p.compliance_check_ind =
       IF ((request->price_sched[x].rate_structure_ind=1)) request->price_sched[x].
        compliance_check_ind
       ELSE p.compliance_check_ind
       ENDIF
       , p.rounding_rate_flag =
       IF ((request->price_sched[x].rate_structure_ind=1)) request->price_sched[x].rounding_rate_flag
       ELSE p.rounding_rate_flag
       ENDIF
       ,
       p.conversion_factor_cd =
       IF ((request->price_sched[x].rate_structure_ind=1)) request->price_sched[x].
        conversion_factor_cd
       ELSE p.conversion_factor_cd
       ENDIF
       , p.operating_margin_pct =
       IF ((request->price_sched[x].rate_structure_ind=1)) request->price_sched[x].
        operating_margin_pct
       ELSE p.operating_margin_pct
       ENDIF
       , p.apply_markup_to_flag =
       IF (validate(request->price_sched.apply_markup_to_flag)=1) request->price_sched[x].
        apply_markup_to_flag
       ELSE p.apply_markup_to_flag
       ENDIF
      PLAN (d)
       JOIN (p
       WHERE (p.price_sched_id=request->price_sched[x].price_sched_id))
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = update_error
      CALL echo("update_error")
      RETURN
     ELSE
      SET stat = alterlist(reply->price_sched,x)
      SET reply->price_sched[x].price_sched_id = request->price_sched[x].price_sched_id
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
