CREATE PROGRAM bed_ens_os_sections:dba
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
 )
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET section_code_value = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6030
   AND cv.cdf_meaning="LABEL"
   AND cv.active_ind=1
  DETAIL
   section_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET sec_cnt = size(request->sections,5)
 FOR (x = 1 TO sec_cnt)
   IF ((request->sections[x].action_flag=2))
    SET os_cnt = size(request->sections[x].order_sets,5)
    IF (os_cnt > 0)
     SET ierrcode = 0
     UPDATE  FROM cs_component cc,
       (dummyt d  WITH seq = os_cnt)
      SET cc.comp_label = request->sections[x].new_name, cc.updt_applctx = reqinfo->updt_applctx, cc
       .updt_cnt = (cc.updt_cnt+ 1),
       cc.updt_dt_tm = cnvtdatetime(curdate,curtime3), cc.updt_id = reqinfo->updt_id, cc.updt_task =
       reqinfo->updt_task
      PLAN (d)
       JOIN (cc
       WHERE (cc.comp_label=request->sections[x].cur_name)
        AND (cc.catalog_cd=request->sections[x].order_sets[d.seq].code_value)
        AND cc.comp_type_cd=section_code_value)
      WITH nocounter
     ;end update
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET reply->error_msg = concat("Unable to update order set section on ",
       "the cs_component table: ",serrmsg)
      GO TO exit_script
     ENDIF
    ENDIF
   ELSEIF ((request->sections[x].action_flag=3))
    SET cnt = 0
    SET os_cnt = size(request->sections[x].order_sets,5)
    FOR (y = 1 TO os_cnt)
      DELETE  FROM cs_component cc
       WHERE (cc.catalog_cd=request->sections[x].order_sets[y].code_value)
        AND (cc.comp_label=request->sections[x].cur_name)
        AND cc.comp_type_cd=section_code_value
       WITH nocounter
      ;end delete
      IF (curqual=0)
       SET error_flag = "Y"
       SET reply->error_msg = concat("Unable to delete section: ",trim(request->sections[x].cur_name),
        " for order set: ",trim(cnvtstring(request->sections[x].order_sets[y].code_value)),
        " on the cs_component table")
       GO TO exit_script
      ENDIF
      SET cnt = 0
      SELECT INTO "nl:"
       FROM cs_component cc
       PLAN (cc
        WHERE (cc.catalog_cd=request->sections[x].order_sets[y].code_value))
       ORDER BY cc.comp_seq
       HEAD REPORT
        cnt = 0, list_cnt = 0, stat = alterlist(temp_seq->sequences,10)
       DETAIL
        cnt = (cnt+ 1), list_cnt = (list_cnt+ 1)
        IF (list_cnt > 10)
         stat = alterlist(temp_seq->sequences,(cnt+ 10)), list_cnt = 1
        ENDIF
        temp_seq->sequences[cnt].cur_sequence = cc.comp_seq, temp_seq->sequences[cnt].new_sequence =
        (cnt - 1)
       FOOT REPORT
        stat = alterlist(temp_seq->sequences,cnt)
       WITH nocounter
      ;end select
      IF (cnt > 0)
       SET ierrcode = 0
       UPDATE  FROM cs_component cc,
         (dummyt d  WITH seq = cnt)
        SET cc.comp_seq = temp_seq->sequences[d.seq].new_sequence, cc.updt_applctx = reqinfo->
         updt_applctx, cc.updt_cnt = (cc.updt_cnt+ 1),
         cc.updt_dt_tm = cnvtdatetime(curdate,curtime3), cc.updt_id = reqinfo->updt_id, cc.updt_task
          = reqinfo->updt_task
        PLAN (d)
         JOIN (cc
         WHERE (cc.catalog_cd=request->sections[x].order_sets[y].code_value)
          AND (cc.comp_seq=temp_seq->sequences[d.seq].cur_sequence))
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
