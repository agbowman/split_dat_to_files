CREATE PROGRAM bed_ens_os_notes:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp_seq
 RECORD temp_seq(
   1 sequences[*]
     2 cur_sequence = i4
     2 new_sequence = i4
     2 update_ind = i2
 )
 FREE SET temp_note
 RECORD temp_note(
   1 notes[*]
     2 lt_id = f8
 )
 DECLARE outbuf = vc
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET note_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6030
   AND cv.cdf_meaning="NOTE"
   AND cv.active_ind=1
  DETAIL
   note_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET note_cnt = size(request->notes,5)
 FOR (x = 1 TO note_cnt)
   IF ((request->notes[x].action_flag=2))
    SET os_cnt = size(request->notes[x].order_sets,5)
    FOR (y = 1 TO os_cnt)
      SET cnt = 0
      SELECT INTO "nl:"
       FROM cs_component cc,
        long_text lt
       PLAN (cc
        WHERE (cc.catalog_cd=request->notes[x].order_sets[y].code_value)
         AND cc.comp_type_cd=note_code_value)
        JOIN (lt
        WHERE lt.long_text_id=cc.long_text_id)
       HEAD REPORT
        cnt = 0, list_cnt = 0, stat = alterlist(temp_note->notes,10)
       DETAIL
        outbuf = lt.long_text
        IF ((outbuf=request->notes[x].cur_text))
         cnt = (cnt+ 1), list_cnt = (list_cnt+ 1)
         IF (list_cnt > 10)
          stat = alterlist(temp_note->notes,(cnt+ 10)), list_cnt = 1
         ENDIF
         temp_note->notes[cnt].lt_id = lt.long_text_id
        ENDIF
       FOOT REPORT
        stat = alterlist(temp_note->notes,cnt)
       WITH nocounter, rdbarrayfetch = 1
      ;end select
      IF (cnt > 0)
       SET ierrcode = 0
       UPDATE  FROM long_text lt,
         (dummyt d  WITH seq = cnt)
        SET lt.long_text = request->notes[x].new_text, lt.updt_applctx = reqinfo->updt_applctx, lt
         .updt_cnt = (lt.updt_cnt+ 1),
         lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_id = reqinfo->updt_id, lt.updt_task
          = reqinfo->updt_task
        PLAN (d)
         JOIN (lt
         WHERE (lt.long_text_id=temp_note->notes[d.seq].lt_id))
        WITH nocounter
       ;end update
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET error_flag = "Y"
        SET reply->error_msg = concat("Unable to update order set note on ","the long_text table: ",
         serrmsg)
        GO TO exit_script
       ENDIF
      ENDIF
    ENDFOR
   ELSEIF ((request->notes[x].action_flag=3))
    SET os_cnt = size(request->notes[x].order_sets,5)
    FOR (y = 1 TO os_cnt)
      SET cnt = 0
      SELECT INTO "nl:"
       FROM cs_component cc,
        long_text lt
       PLAN (cc
        WHERE (cc.catalog_cd=request->notes[x].order_sets[y].code_value)
         AND cc.comp_type_cd=note_code_value)
        JOIN (lt
        WHERE lt.long_text_id=cc.long_text_id)
       HEAD REPORT
        cnt = 0, list_cnt = 0, stat = alterlist(temp_note->notes,10)
       DETAIL
        outbuf = lt.long_text
        IF ((outbuf=request->notes[x].cur_text))
         cnt = (cnt+ 1), list_cnt = (list_cnt+ 1)
         IF (list_cnt > 10)
          stat = alterlist(temp_note->notes,(cnt+ 10)), list_cnt = 1
         ENDIF
         temp_note->notes[cnt].lt_id = lt.long_text_id
        ENDIF
       FOOT REPORT
        stat = alterlist(temp_note->notes,cnt)
       WITH nocounter, rdbarrayfetch = 1
      ;end select
      IF (cnt > 0)
       SET ierrcode = 0
       DELETE  FROM long_text lt,
         (dummyt d  WITH seq = cnt)
        SET lt.seq = 1
        PLAN (d)
         JOIN (lt
         WHERE (lt.long_text_id=temp_note->notes[d.seq].lt_id))
        WITH nocounter
       ;end delete
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET error_flag = "Y"
        SET reply->error_msg = concat("Unable to delete note on ","the long_text table: ",serrmsg)
        GO TO exit_script
       ENDIF
       SET ierrcode = 0
       DELETE  FROM cs_component cc,
         (dummyt d  WITH seq = cnt)
        SET cc.seq = 1
        PLAN (d)
         JOIN (cc
         WHERE (cc.long_text_id=temp_note->notes[d.seq].lt_id)
          AND cc.comp_type_cd=note_code_value)
        WITH nocounter
       ;end delete
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET error_flag = "Y"
        SET reply->error_msg = concat("Unable to delete note on ","the cs_component table: ",serrmsg)
        GO TO exit_script
       ENDIF
      ENDIF
      SET cnt = 0
      SELECT INTO "nl:"
       FROM cs_component cc
       PLAN (cc
        WHERE (cc.catalog_cd=request->notes[x].order_sets[y].code_value))
       ORDER BY cc.comp_seq
       HEAD REPORT
        cnt = 0, list_cnt = 0, stat = alterlist(temp_seq->sequences,10)
       DETAIL
        cnt = (cnt+ 1), list_cnt = (list_cnt+ 1)
        IF (list_cnt > 10)
         stat = alterlist(temp_seq->sequences,(cnt+ 10)), list_cnt = 1
        ENDIF
        temp_seq->sequences[cnt].cur_sequence = cc.comp_seq
       FOOT REPORT
        stat = alterlist(temp_seq->sequences,cnt)
       WITH nocounter
      ;end select
      SET update_seq_ind = 0
      FOR (a = 1 TO cnt)
       IF (a=1)
        IF ((temp_seq->sequences[a].cur_sequence > 1))
         SET temp_seq->sequences[a].new_sequence = 1
         SET temp_seq->sequences[a].update_ind = 1
         SET upd_seq = 1
         SET update_seq_ind = 1
        ELSE
         SET prev_seq = temp_seq->sequences[a].cur_sequence
        ENDIF
       ELSE
        IF (update_seq_ind=1)
         SET upd_seq = (upd_seq+ 1)
         SET temp_seq->sequences[a].new_sequence = upd_seq
         SET temp_seq->sequences[a].update_ind = 1
        ELSEIF ((prev_seq != (temp_seq->sequences[a].cur_sequence+ 1)))
         SET temp_seq->sequences[a].new_sequence = (prev_seq+ 1)
         SET temp_seq->sequences[a].update_ind = 1
         SET upd_seq = (prev_seq+ 1)
         SET update_seq_ind = 1
        ELSE
         SET prev_seq = temp_seq->sequences[a].cur_sequence
        ENDIF
       ENDIF
       IF ((temp_seq->sequences[a].update_ind=1))
        SET ierrcode = 0
        UPDATE  FROM cs_component cc
         SET cc.comp_seq = temp_seq->sequences[a].new_sequence, cc.updt_applctx = reqinfo->
          updt_applctx, cc.updt_cnt = (cc.updt_cnt+ 1),
          cc.updt_dt_tm = cnvtdatetime(curdate,curtime3), cc.updt_id = reqinfo->updt_id, cc.updt_task
           = reqinfo->updt_task
         PLAN (cc
          WHERE (cc.catalog_cd=request->notes[x].order_sets[y].code_value)
           AND (cc.comp_seq=temp_seq->sequences[a].cur_sequence))
         WITH nocounter
        ;end update
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET error_flag = "Y"
         SET reply->error_msg = concat("Unable to re-sequence order set on ",
          "the cs_component table: ",serrmsg)
         GO TO exit_script
        ENDIF
       ENDIF
      ENDFOR
    ENDFOR
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
