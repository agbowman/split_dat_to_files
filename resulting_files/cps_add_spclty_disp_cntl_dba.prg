CREATE PROGRAM cps_add_spclty_disp_cntl:dba
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
 CALL add_spclty_disp_cntl(action_begin,action_end)
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
 SUBROUTINE add_spclty_disp_cntl(add_begin,add_end)
   FOR (x = add_begin TO add_end)
     SET blank_date = cnvtdatetime("01-JAN-1800 00:00:00.00")
     SET active_code = 0.0
     IF ((request->spclty_disp_cntl[x].active_status_cd=0))
      SET stat = uar_get_meaning_by_codeset(48,"ACTIVE",1,active_code)
     ENDIF
     SET new_nbr = 0.0
     SELECT INTO "nl:"
      y = seq(health_plan_seq,nextval)
      FROM dual
      DETAIL
       new_nbr = cnvtreal(y)
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET failed = gen_nbr_error
      RETURN
     ELSE
      SET request->spclty_disp_cntl[x].spclty_disp_id = new_nbr
     ENDIF
     INSERT  FROM spclty_disp_cntl s
      SET s.spclty_disp_id = new_nbr, s.specialty_cd =
       IF ((request->spclty_disp_cntl[x].specialty_cd <= 0)) 0
       ELSE request->spclty_disp_cntl[x].specialty_cd
       ENDIF
       , s.speclty_parent_cd =
       IF ((request->spclty_disp_cntl[x].speclty_parent_cd <= 0)) 0
       ELSE request->spclty_disp_cntl[x].speclty_parent_cd
       ENDIF
       ,
       s.active_ind =
       IF ((request->spclty_disp_cntl[x].active_ind_ind=false)) true
       ELSE request->spclty_disp_cntl[x].active_ind
       ENDIF
       , s.active_status_cd =
       IF ((request->spclty_disp_cntl[x].active_status_cd=0)) active_code
       ELSE request->spclty_disp_cntl[x].active_status_cd
       ENDIF
       , s.active_status_prsnl_id = reqinfo->updt_id,
       s.active_status_dt_tm = cnvtdatetime(sysdate), s.updt_cnt = 0, s.updt_dt_tm = cnvtdatetime(
        sysdate),
       s.updt_id = reqinfo->updt_id, s.updt_applctx = reqinfo->updt_applctx, s.updt_task = reqinfo->
       updt_task
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET failed = insert_error
      RETURN
     ELSE
      SET reply->spclty_disp_cntl[x].spclty_disp_id = request->spclty_disp_cntl[x].spclty_disp_id
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
