CREATE PROGRAM cps_upt_hp_bnft_set_alias:dba
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
    1 hp_bnft_set_alias_qual = i2
    1 hp_bnft_set_alias[10]
      2 bnft_set_alias_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
  SET action_begin = 1
  SET action_end = request->hp_bnft_set_alias_qual
  SET reply->hp_bnft_set_alias_qual = request->hp_bnft_set_alias_qual
 ENDIF
 SET reply->status_data.status = "F"
 SET table_name = "HP_BNFT_SET_ALIAS"
 CALL upt_hp_bnft_set_alias(action_begin,action_end)
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
 SUBROUTINE upt_hp_bnft_set_alias(upt_begin,upt_end)
   FOR (x = upt_begin TO upt_end)
     SET cur_updt_cnt[value(upt_end)] = 0
     SET count1 = 0
     SET active_status_code = 0
     SET data_status_code = 0
     SELECT INTO "nl:"
      h.*
      FROM hp_bnft_set_alias h,
       (dummyt d  WITH seq = value(upt_end))
      PLAN (d)
       JOIN (h
       WHERE (h.bnft_set_alias_id=request->hp_bnft_set_alias[d.seq].bnft_set_alias_id))
      HEAD REPORT
       count1 = 0
      DETAIL
       count1 += 1, cur_updt_cnt[count1] = h.updt_cnt, active_status_code = h.active_status_cd,
       data_status_code = h.data_status_cd
      WITH forupdate(h)
     ;end select
     IF (count1 != upt_end)
      SET failed = lock_error
      RETURN
     ENDIF
     UPDATE  FROM hp_bnft_set_alias h,
       (dummyt d  WITH seq = 1)
      SET h.seq = 1, h.hp_bnft_set_id = nullcheck(h.hp_bnft_set_id,request->hp_bnft_set_alias[x].
        hp_bnft_set_id,
        IF ((request->hp_bnft_set_alias[x].hp_bnft_set_id=0)) 0
        ELSE 1
        ENDIF
        ), h.alias = nullcheck(h.alias,request->hp_bnft_set_alias[x].alias,1),
       h.beg_effective_dt_tm = nullcheck(h.beg_effective_dt_tm,cnvtdatetime(request->
         hp_bnft_set_alias[x].beg_effective_dt_tm),
        IF ((request->hp_bnft_set_alias[x].beg_effective_dt_tm=0)) 0
        ELSE 1
        ENDIF
        ), h.end_effective_dt_tm = nullcheck(h.end_effective_dt_tm,cnvtdatetime(request->
         hp_bnft_set_alias[x].end_effective_dt_tm),
        IF ((request->hp_bnft_set_alias[x].end_effective_dt_tm=0)) 0
        ELSE 1
        ENDIF
        ), h.contributor_system_cd = nullcheck(h.contributor_system_cd,request->hp_bnft_set_alias[x].
        contributor_system_cd,
        IF ((request->hp_bnft_set_alias[x].contributor_system_cd=0)) 0
        ELSE 1
        ENDIF
        ),
       h.data_status_cd = nullcheck(h.data_status_cd,request->hp_bnft_set_alias[x].data_status_cd,
        IF ((request->hp_bnft_set_alias[x].data_status_cd=data_status_code)) 0
        ELSE 1
        ENDIF
        ), h.data_status_prsnl_id = nullcheck(h.data_status_prsnl_id,reqinfo->updt_id,
        IF ((request->hp_bnft_set_alias[x].data_status_cd=data_status_code)) 0
        ELSE 1
        ENDIF
        ), h.data_status_dt_tm = nullcheck(h.data_status_dt_tm,cnvtdatetime(sysdate),
        IF ((request->hp_bnft_set_alias[x].data_status_cd=data_status_code)) 0
        ELSE 1
        ENDIF
        ),
       h.active_status_cd = nullcheck(h.active_status_cd,request->hp_bnft_set_alias[x].
        active_status_cd,
        IF ((request->hp_bnft_set_alias[x].active_status_cd=active_status_code)) 0
        ELSE 1
        ENDIF
        ), h.active_status_prsnl_id = nullcheck(h.active_status_prsnl_id,reqinfo->updt_id,
        IF ((request->hp_bnft_set_alias[x].active_status_cd=active_status_code)) 0
        ELSE 1
        ENDIF
        ), h.active_status_dt_tm = nullcheck(h.active_status_dt_tm,cnvtdatetime(sysdate),
        IF ((request->hp_bnft_set_alias[x].active_status_cd=active_status_code)) 0
        ELSE 1
        ENDIF
        ),
       h.updt_cnt = (cur_updt_cnt[d.seq]+ 1), h.updt_dt_tm = cnvtdatetime(sysdate), h.updt_id =
       reqinfo->updt_id,
       h.updt_applctx = reqinfo->updt_applctx, h.updt_task = reqinfo->updt_task
      PLAN (d)
       JOIN (h
       WHERE (h.bnft_set_alias_id=request->hp_bnft_set_alias[x].bnft_set_alias_id))
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = update_error
      RETURN
     ELSE
      SET reply->hp_bnft_set_alias[x].bnft_set_alias_id = request->hp_bnft_set_alias[x].
      bnft_set_alias_id
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
