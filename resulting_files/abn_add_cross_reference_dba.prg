CREATE PROGRAM abn_add_cross_reference:dba
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
    1 abn_cross_reference_qual = i2
    1 abn_cross_reference[10]
      2 abn_cross_reference_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
  SET action_begin = 1
  SET action_end = request->abn_cross_reference_qual
  SET reply->abn_cross_reference_qual = request->abn_cross_reference_qual
 ENDIF
 SET action_insert = 1
 SET update_abn = 0
 SET reply->status_data.status = "F"
 SET table_name = "ABN_CROSS_REFERENCE"
 CALL add_abn_cross_reference(action_begin,action_end)
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
 SUBROUTINE add_abn_cross_reference(add_begin,add_end)
   FOR (x = add_begin TO add_end)
     SET action_insert = 1
     SET blank_date = cnvtdatetime("01-JAN-1800 00:00:00.00")
     SELECT INTO "nl:"
      FROM abn_cross_reference ac
      WHERE (ac.catalog_cd=request->abn_cross_reference[x].catalog_cd)
       AND (ac.cpt_nomen_id=request->abn_cross_reference[x].cpt_nomen_id)
       AND (ac.active_ind=request->abn_cross_reference[x].active_ind)
      DETAIL
       action_insert = 0, update_abn = ac.abn_cross_reference_id
      WITH nocounter
     ;end select
     IF (action_insert=1)
      DECLARE myseqnum = f8 WITH protect, noconstant(0.0)
      SELECT INTO "nl:"
       nextseqnum = seq(abn_sequence,nextval)
       FROM dual
       DETAIL
        myseqnum = nextseqnum
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET failed = gen_nbr_error
       RETURN
      ELSE
       SET request->abn_cross_reference[x].abn_cross_reference_id = myseqnum
      ENDIF
      INSERT  FROM abn_cross_reference a
       SET a.abn_cross_reference_id = myseqnum, a.catalog_cd =
        IF ((request->abn_cross_reference[x].catalog_cd <= 0)) 0
        ELSE request->abn_cross_reference[x].catalog_cd
        ENDIF
        , a.cpt_nomen_id =
        IF ((request->abn_cross_reference[x].cpt_nomen_id <= 0)) 0
        ELSE request->abn_cross_reference[x].cpt_nomen_id
        ENDIF
        ,
        a.beg_effective_dt_tm =
        IF ((request->abn_cross_reference[x].beg_effective_dt_tm <= 0)) cnvtdatetime(sysdate)
        ELSE cnvtdatetime(request->abn_cross_reference[x].beg_effective_dt_tm)
        ENDIF
        , a.end_effective_dt_tm =
        IF ((request->abn_cross_reference[x].end_effective_dt_tm <= 0)) cnvtdatetime(
          "31-DEC-2100 00:00:00.00")
        ELSE cnvtdatetime(request->abn_cross_reference[x].end_effective_dt_tm)
        ENDIF
        , a.active_ind =
        IF ((request->abn_cross_reference[x].active_ind_ind=false)) true
        ELSE request->abn_cross_reference[x].active_ind
        ENDIF
        ,
        a.active_status_cd =
        IF ((request->abn_cross_reference[x].active_status_cd=0)) reqdata->active_status_cd
        ELSE request->abn_cross_reference[x].active_status_cd
        ENDIF
        , a.active_status_prsnl_id = reqinfo->updt_id, a.active_status_dt_tm = cnvtdatetime(sysdate),
        a.updt_cnt = 0, a.updt_dt_tm = cnvtdatetime(sysdate), a.updt_id = reqinfo->updt_id,
        a.updt_applctx = reqinfo->updt_applctx, a.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
     ELSEIF (action_insert=0
      AND update_abn > 0)
      UPDATE  FROM abn_cross_reference a
       SET a.abn_cross_reference_id = update_abn, a.catalog_cd =
        IF ((request->abn_cross_reference[x].catalog_cd <= 0)) 0
        ELSE request->abn_cross_reference[x].catalog_cd
        ENDIF
        , a.cpt_nomen_id =
        IF ((request->abn_cross_reference[x].cpt_nomen_id <= 0)) 0
        ELSE request->abn_cross_reference[x].cpt_nomen_id
        ENDIF
        ,
        a.beg_effective_dt_tm =
        IF ((request->abn_cross_reference[x].beg_effective_dt_tm <= 0)) cnvtdatetime(sysdate)
        ELSE cnvtdatetime(request->abn_cross_reference[x].beg_effective_dt_tm)
        ENDIF
        , a.end_effective_dt_tm =
        IF ((request->abn_cross_reference[x].end_effective_dt_tm <= 0)) cnvtdatetime(
          "31-DEC-2100 00:00:00.00")
        ELSE cnvtdatetime(request->abn_cross_reference[x].end_effective_dt_tm)
        ENDIF
        , a.active_ind =
        IF ((request->abn_cross_reference[x].active_ind_ind=false)) true
        ELSE request->abn_cross_reference[x].active_ind
        ENDIF
        ,
        a.active_status_cd =
        IF ((request->abn_cross_reference[x].active_status_cd=0)) reqdata->active_status_cd
        ELSE request->abn_cross_reference[x].active_status_cd
        ENDIF
        , a.active_status_prsnl_id = reqinfo->updt_id, a.active_status_dt_tm = cnvtdatetime(sysdate),
        a.updt_cnt = 0, a.updt_dt_tm = cnvtdatetime(sysdate), a.updt_id = reqinfo->updt_id,
        a.updt_applctx = reqinfo->updt_applctx, a.updt_task = reqinfo->updt_task
       WHERE a.abn_cross_reference_id=update_abn
       WITH nocounter
      ;end update
     ENDIF
     IF (curqual=0)
      SET failed = insert_error
      RETURN
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
