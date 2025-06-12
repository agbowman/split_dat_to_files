CREATE PROGRAM afc_upt_charge_event:dba
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
    1 charge_event_qual = i2
    1 charge_event[10]
      2 charge_event_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
  SET action_begin = 1
  SET action_end = request->charge_event_qual
  SET reply->charge_event_qual = request->charge_event_qual
 ENDIF
 SET reply->status_data.status = "F"
 SET table_name = "CHARGE_EVENT"
 CALL upt_charge_event(action_begin,action_end)
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
 SUBROUTINE upt_charge_event(upt_begin,upt_end)
   FOR (x = upt_begin TO upt_end)
     SET cur_updt_cnt[value(upt_end)] = 0
     SET count1 = 0
     SELECT INTO "nl:"
      c.*
      FROM charge_event c,
       (dummyt d  WITH seq = value(upt_end))
      PLAN (d)
       JOIN (c
       WHERE (c.charge_event_id=request->charge_event[d.seq].charge_event_id))
      HEAD REPORT
       count1 = 0
      DETAIL
       count1 += 1, cur_updt_cnt[count1] = c.updt_cnt
      WITH forupdate(c)
     ;end select
     IF (count1 != upt_end)
      SET failed = lock_error
      RETURN
     ENDIF
     UPDATE  FROM charge_event c,
       (dummyt d  WITH seq = 1)
      SET c.seq = 1, c.ext_m_event_id = nullcheck(c.ext_m_event_id,request->charge_event[x].
        ext_master_event_id,
        IF ((request->charge_event[x].ext_master_event_id=0)) 0
        ELSE 1
        ENDIF
        ), c.ext_m_event_cont_cd = nullcheck(c.ext_m_event_cont_cd,request->charge_event[x].
        ext_master_event_cont_cd,
        IF ((request->charge_event[x].ext_master_event_cont_cd=0)) 0
        ELSE 1
        ENDIF
        ),
       c.ext_m_reference_id = nullcheck(c.ext_m_reference_id,request->charge_event[x].
        ext_master_reference_id,
        IF ((request->charge_event[x].ext_master_reference_id=0)) 0
        ELSE 1
        ENDIF
        ), c.ext_m_reference_cont_cd = nullcheck(c.ext_m_reference_cont_cd,request->charge_event[x].
        ext_master_reference_cont_cd,
        IF ((request->charge_event[x].ext_master_reference_cont_cd=0)) 0
        ELSE 1
        ENDIF
        ), c.ext_p_event_id = nullcheck(c.ext_p_event_id,request->charge_event[x].ext_parent_event_id,
        IF ((request->charge_event[x].ext_parent_event_id=0)) 0
        ELSE 1
        ENDIF
        ),
       c.ext_p_event_cont_cd = nullcheck(c.ext_p_event_cont_cd,request->charge_event[x].
        ext_parent_event_cont_cd,
        IF ((request->charge_event[x].ext_parent_event_cont_cd=0)) 0
        ELSE 1
        ENDIF
        ), c.ext_p_reference_id = nullcheck(c.ext_p_reference_id,request->charge_event[x].
        ext_parent_reference_id,
        IF ((request->charge_event[x].ext_parent_reference_id=0)) 0
        ELSE 1
        ENDIF
        ), c.ext_p_reference_cont_cd = nullcheck(c.ext_p_reference_cont_cd,request->charge_event[x].
        ext_parent_reference_cont_cd,
        IF ((request->charge_event[x].ext_parent_reference_cont_cd=0)) 0
        ELSE 1
        ENDIF
        ),
       c.ext_i_event_id = nullcheck(c.ext_i_event_id,request->charge_event[x].ext_item_event_id,
        IF ((request->charge_event[x].ext_item_event_id=0)) 0
        ELSE 1
        ENDIF
        ), c.ext_i_event_cont_cd = nullcheck(c.ext_i_event_cont_cd,request->charge_event[x].
        ext_item_event_cont_cd,
        IF ((request->charge_event[x].ext_item_event_cont_cd=0)) 0
        ELSE 1
        ENDIF
        ), c.ext_i_reference_id = nullcheck(c.ext_i_reference_id,request->charge_event[x].
        ext_item_reference_id,
        IF ((request->charge_event[x].ext_item_reference_id=0)) 0
        ELSE 1
        ENDIF
        ),
       c.ext_i_reference_cont_cd = nullcheck(c.ext_i_reference_cont_cd,request->charge_event[x].
        ext_item_reference_cont_cd,
        IF ((request->charge_event[x].ext_item_reference_cont_cd=0)) 0
        ELSE 1
        ENDIF
        ), c.charge_type_cd = nullcheck(c.charge_type_cd,request->charge_event[x].charge_type_cd,
        IF ((request->charge_event[x].charge_type_cd=0)) 0
        ELSE 1
        ENDIF
        ), c.charge_dt_tm = nullcheck(c.charge_dt_tm,cnvtdatetime(request->charge_event[x].
         charge_dt_tm),
        IF ((request->charge_event[x].charge_dt_tm=0)) 0
        ELSE 1
        ENDIF
        ),
       c.event_id = nullcheck(c.event_id,request->charge_event[x].event_id,
        IF ((request->charge_event[x].event_id=0)) 0
        ELSE 1
        ENDIF
        ), c.order_id = nullcheck(c.order_id,request->charge_event[x].order_id,
        IF ((request->charge_event[x].order_id=0)) 0
        ELSE 1
        ENDIF
        ), c.person_id = nullcheck(c.person_id,request->charge_event[x].person_id,
        IF ((request->charge_event[x].person_id=0)) 0
        ELSE 1
        ENDIF
        ),
       c.encntr_id = nullcheck(c.encntr_id,request->charge_event[x].encntr_id,
        IF ((request->charge_event[x].encntr_id=0)) 0
        ELSE 1
        ENDIF
        ), c.location_cd = nullcheck(c.location_cd,request->charge_event[x].location_cd,
        IF ((request->charge_event[x].location_cd=0)) 0
        ELSE 1
        ENDIF
        ), c.order_priority_cd = nullcheck(c.order_priority_cd,request->charge_event[x].
        order_priority_cd,
        IF ((request->charge_event[x].order_priority_cd=0)) 0
        ELSE 1
        ENDIF
        ),
       c.rpt_priority_cd = nullcheck(c.rpt_priority_cd,request->charge_event[x].rpt_priority_cd,
        IF ((request->charge_event[x].rpt_priority_cd=0)) 0
        ELSE 1
        ENDIF
        ), c.admit_type_cd = nullcheck(c.admit_type_cd,request->charge_event[x].admit_type_cd,
        IF ((request->charge_event[x].admit_type_cd=0)) 0
        ELSE 1
        ENDIF
        ), c.quantity = nullcheck(c.quantity,request->charge_event[x].quantity,
        IF ((request->charge_event[x].quantity=0)) 0
        ELSE 1
        ENDIF
        ),
       c.result = nullcheck(c.result,request->charge_event[x].result,
        IF ((request->charge_event[x].result="")) 0
        ELSE 1
        ENDIF
        ), c.elapsed_time = nullcheck(c.elapsed_time,request->charge_event[x].elapsed_time,
        IF ((request->charge_event[x].elapsed_time=0)) 0
        ELSE 1
        ENDIF
        ), c.unit_type = nullcheck(c.unit_type,request->charge_event[x].unit_type,
        IF ((request->charge_event[x].unit_type=0)) 0
        ELSE 1
        ENDIF
        ),
       c.research_cd = nullcheck(c.research_cd,request->charge_event[x].research_cd,
        IF ((request->charge_event[x].research_cd=0)) 0
        ELSE 1
        ENDIF
        ), c.accession_nbr = nullcheck(c.accession_nbr,request->charge_event[x].accession_nbr,
        IF ((request->charge_event[x].accession_nbr="")) 0
        ELSE 1
        ENDIF
        ), c.beg_effective_dt_tm = nullcheck(c.beg_effective_dt_tm,cnvtdatetime(request->
         charge_event[x].beg_effective_dt_tm),
        IF ((request->charge_event[x].beg_effective_dt_tm=0)) 0
        ELSE 1
        ENDIF
        ),
       c.end_effective_dt_tm = nullcheck(c.end_effective_dt_tm,cnvtdatetime(request->charge_event[x].
         end_effective_dt_tm),
        IF ((request->charge_event[x].end_effective_dt_tm=0)) 0
        ELSE 1
        ENDIF
        ), c.active_status_cd = nullcheck(c.active_status_cd,request->charge_event[x].
        active_status_cd,
        IF ((request->charge_event[x].active_status_cd=0)) 0
        ELSE 1
        ENDIF
        ), c.active_status_prsnl_id = nullcheck(c.active_status_prsnl_id,request->charge_event[x].
        active_status_prsnl_id,
        IF ((request->charge_event[x].active_status_prsnl_id=0)) 0
        ELSE 1
        ENDIF
        ),
       c.active_status_dt_tm = nullcheck(c.active_status_dt_tm,cnvtdatetime(request->charge_event[x].
         active_status_dt_tm),
        IF ((request->charge_event[x].active_status_dt_tm=0)) 0
        ELSE 1
        ENDIF
        ), c.updt_cnt = (cur_updt_cnt[d.seq]+ 1), c.updt_dt_tm = cnvtdatetime(sysdate),
       c.updt_id = reqinfo->updt_id, c.updt_applctx = reqinfo->updt_applctx, c.updt_task = reqinfo->
       updt_task,
       c.process_flg =
       IF ((request->charge_event[x].process_flg=0)) c.process_flg
       ELSE request->charge_event[x].process_flg
       ENDIF
      PLAN (d)
       JOIN (c
       WHERE (c.charge_event_id=request->charge_event[x].charge_event_id))
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = update_error
      RETURN
     ELSE
      SET reply->charge_event[x].charge_event_id = request->charge_event[x].charge_event_id
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
