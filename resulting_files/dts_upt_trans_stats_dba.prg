CREATE PROGRAM dts_upt_trans_stats:dba
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
    1 dts_trans_stats_qual = i2
    1 dts_trans_stats[1]
      2 dts_trans_stats_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  SET action_begin = 1
  SET action_end = request->dts_trans_stats_qual
  SET reply->dts_trans_stats_qual = request->dts_trans_stats_qual
 ENDIF
 SET reply->status_data.status = "F"
 SET table_name = "DTS_TRANS_STATS"
 CALL upt_dts_trans_stats(action_begin,action_end)
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
 SUBROUTINE upt_dts_trans_stats(upt_begin,upt_end)
  CALL echo("Entered subroutine upt_dts_trans_stats...")
  FOR (x = upt_begin TO upt_end)
    SET blank_date = cnvtdatetime("01-JAN-1800 00:00:00.00")
    SET count1 = 0
    SET active_status_code = 0
    SELECT INTO "nl:"
     d.*
     FROM dts_trans_stats d
     WHERE (d.dts_trans_stats_id=request->dts_trans_stats[x].dts_trans_stats_id)
     HEAD REPORT
      count1 = 0
     DETAIL
      count1 += 1
      IF ((request->dts_trans_stats[x].active_status_cd > 0))
       active_status_code = d.active_status_cd
      ENDIF
     WITH forupdate(d)
    ;end select
    IF (curqual=0)
     CALL echo("Update failure...")
     SET failed = lock_error
     RETURN
    ENDIF
    UPDATE  FROM dts_trans_stats d
     SET d.encntr_id = request->dts_trans_stats[x].encntr_id, d.subject_line = request->
      dts_trans_stats[x].subject_line, d.application_mode_cd = request->dts_trans_stats[x].
      application_mode_cd,
      d.transaction_type_cd = request->dts_trans_stats[x].transaction_type_cd, d.dictation_dt_tm =
      cnvtdatetime(request->dts_trans_stats[x].dictation_dt_tm), d.dictation_tz = request->
      dts_trans_stats[x].dictation_tz,
      d.event_id = request->dts_trans_stats[x].event_id, d.trans_prsnl_id = request->dts_trans_stats[
      x].trans_prsnl_id, d.author_prsnl_id = request->dts_trans_stats[x].author_prsnl_id,
      d.patient_id = request->dts_trans_stats[x].patient_id, d.event_cd = request->dts_trans_stats[x]
      .event_cd, d.char_cnt = request->dts_trans_stats[x].char_cnt,
      d.char_wo_cnt = request->dts_trans_stats[x].char_wo_cnt, d.word_cnt = request->dts_trans_stats[
      x].word_cnt, d.line_cnt = request->dts_trans_stats[x].line_cnt,
      d.page_cnt = request->dts_trans_stats[x].page_cnt, d.bytes_cnt = request->dts_trans_stats[x].
      bytes_cnt, d.orig_char_cnt = request->dts_trans_stats[x].orig_char_cnt,
      d.orig_char_wo_cnt = request->dts_trans_stats[x].orig_char_wo_cnt, d.orig_word_cnt = request->
      dts_trans_stats[x].orig_word_cnt, d.orig_line_cnt = request->dts_trans_stats[x].orig_line_cnt,
      d.orig_page_cnt = request->dts_trans_stats[x].orig_page_cnt, d.orig_bytes_cnt = request->
      dts_trans_stats[x].orig_bytes_cnt, d.char_per_word = request->dts_trans_stats[x].char_per_word,
      d.words_per_sentence = request->dts_trans_stats[x].words_per_sentence, d.sentences_per_para =
      request->dts_trans_stats[x].sentences_per_para, d.start_trans_dt_tm = cnvtdatetime(request->
       dts_trans_stats[x].start_trans_dt_tm),
      d.start_trans_tz = request->dts_trans_stats[x].start_trans_tz, d.end_trans_dt_tm = cnvtdatetime
      (request->dts_trans_stats[x].end_trans_dt_tm), d.end_trans_tz = request->dts_trans_stats[x].
      end_trans_tz,
      d.edit_trans_tm = request->dts_trans_stats[x].edit_trans_tm, d.result_status_cd = request->
      dts_trans_stats[x].result_status_cd, d.doc_name = request->dts_trans_stats[x].doc_name,
      d.active_status_cd = nullcheck(d.active_status_cd,request->dts_trans_stats[x].active_status_cd,
       IF ((request->dts_trans_stats[x].active_status_cd=active_status_code)) 0
       ELSE 1
       ENDIF
       ), d.updt_cnt = (d.updt_cnt+ 1), d.updt_dt_tm = cnvtdatetime(sysdate),
      d.updt_id = reqinfo->updt_id, d.updt_applctx = reqinfo->updt_applctx, d.updt_task = reqinfo->
      updt_task
     WHERE (d.dts_trans_stats_id=request->dts_trans_stats[x].dts_trans_stats_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = update_error
     RETURN
    ELSE
     CALL echo("Success updating...")
     SET reply->dts_trans_stats[x].dts_trans_stats_id = request->dts_trans_stats[x].
     dts_trans_stats_id
    ENDIF
  ENDFOR
 END ;Subroutine
#end_program
END GO
