CREATE PROGRAM cps_upt_spclty_disp_cntl:dba
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
    1 spclty_disp_cntl_qual = i2
    1 spclty_disp_cntl[10]
      2 spclty_disp_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  SET action_begin = 1
  SET action_end = request->spclty_disp_cntl_qual
  SET reply->spclty_disp_cntl_qual = request->spclty_disp_cntl_qual
 ENDIF
 SET reply->status_data.status = "F"
 SET table_name = "SPCLTY_DISP_CNTL"
 CALL upt_spclty_disp_cntl(action_begin,action_end)
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
 SUBROUTINE upt_spclty_disp_cntl(upt_begin,upt_end)
   FOR (x = upt_begin TO upt_end)
     SET blank_date = cnvtdatetime("01-JAN-1800 00:00:00.00")
     SET count1 = 0
     SET active_status_code = 0.0
     SELECT INTO "nl:"
      s.*
      FROM spclty_disp_cntl s
      WHERE (s.spclty_disp_id=request->spclty_disp_cntl[x].spclty_disp_id)
      HEAD REPORT
       count1 = 0
      DETAIL
       count1 += 1
       IF ((request->spclty_disp_cntl[x].active_status_cd > 0))
        active_status_code = s.active_status_cd
       ENDIF
      WITH forupdate(s)
     ;end select
     IF (curqual=0)
      SET failed = lock_error
      RETURN
     ENDIF
     UPDATE  FROM spclty_disp_cntl s
      SET s.specialty_cd = evaluate(request->spclty_disp_cntl[x].specialty_cd,0.0,s.specialty_cd,- (
        1.0),0.0,
        request->spclty_disp_cntl[x].specialty_cd), s.speclty_parent_cd = evaluate(request->
        spclty_disp_cntl[x].speclty_parent_cd,0.0,s.speclty_parent_cd,- (1.0),0.0,
        request->spclty_disp_cntl[x].speclty_parent_cd), s.active_ind = nullcheck(s.active_ind,
        request->spclty_disp_cntl[x].active_ind,
        IF ((request->spclty_disp_cntl[x].active_ind_ind=false)) 0
        ELSE 1
        ENDIF
        ),
       s.active_status_cd = nullcheck(s.active_status_cd,request->spclty_disp_cntl[x].
        active_status_cd,
        IF ((request->spclty_disp_cntl[x].active_status_cd=active_status_code)) 0
        ELSE 1
        ENDIF
        ), s.active_status_prsnl_id = nullcheck(s.active_status_prsnl_id,reqinfo->updt_id,
        IF ((request->spclty_disp_cntl[x].active_status_cd=active_status_code)) 0
        ELSE 1
        ENDIF
        ), s.active_status_dt_tm = nullcheck(s.active_status_dt_tm,cnvtdatetime(sysdate),
        IF ((request->spclty_disp_cntl[x].active_status_cd=active_status_code)) 0
        ELSE 1
        ENDIF
        ),
       s.updt_cnt = (s.updt_cnt+ 1), s.updt_dt_tm = cnvtdatetime(sysdate), s.updt_id = reqinfo->
       updt_id,
       s.updt_applctx = reqinfo->updt_applctx, s.updt_task = reqinfo->updt_task
      WHERE (s.spclty_disp_id=request->spclty_disp_cntl[x].spclty_disp_id)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = update_error
      RETURN
     ELSE
      SET reply->spclty_disp_cntl[x].spclty_disp_id = request->spclty_disp_cntl[x].spclty_disp_id
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
