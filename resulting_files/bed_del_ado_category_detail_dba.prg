CREATE PROGRAM bed_del_ado_category_detail:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET error_flag = "N"
 FREE RECORD del_temp
 RECORD del_temp(
   1 details[*]
     2 detail_id = f8
     2 options[*]
       3 option_id = f8
       3 ord_list[*]
         4 ord_list_id = f8
 )
 DECLARE scenario_mean = vc
 IF (size(request->categories,5) > 0)
  SELECT INTO "nl:"
   FROM br_ado_topic_scenario s
   PLAN (s
    WHERE (s.br_ado_topic_scenario_id=request->topic_scenario_id))
   DETAIL
    scenario_mean = s.scenario_mean
   WITH nocounter
  ;end select
  FOR (c = 1 TO size(request->categories,5))
   SELECT INTO "nl:"
    FROM br_ado_detail d
    PLAN (d
     WHERE (d.facility_cd=request->facility_code_value)
      AND d.scenario_mean=scenario_mean
      AND (d.br_ado_category_id=request->categories[c].category_id))
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET cnt = 0
    SELECT INTO "nl:"
     FROM br_ado_detail d,
      br_ado_option o,
      br_ado_ord_list ol
     PLAN (d
      WHERE d.scenario_mean=scenario_mean
       AND (d.facility_cd=request->facility_code_value)
       AND (d.br_ado_category_id=request->categories[c].category_id))
      JOIN (o
      WHERE o.br_ado_detail_id=d.br_ado_detail_id)
      JOIN (ol
      WHERE ol.br_ado_option_id=o.br_ado_option_id)
     ORDER BY d.br_ado_detail_id, o.br_ado_option_id, ol.br_ado_ord_list_id
     HEAD d.br_ado_detail_id
      cnt = (cnt+ 1), ocnt = 0, stat = alterlist(del_temp->details,cnt),
      del_temp->details[cnt].detail_id = d.br_ado_detail_id
     HEAD o.br_ado_option_id
      ocnt = (ocnt+ 1), olcnt = 0, stat = alterlist(del_temp->details[cnt].options,ocnt),
      del_temp->details[cnt].options[ocnt].option_id = o.br_ado_option_id
     HEAD ol.br_ado_ord_list_id
      olcnt = (olcnt+ 1), stat = alterlist(del_temp->details[cnt].options[ocnt].ord_list,olcnt),
      del_temp->details[cnt].options[ocnt].ord_list[olcnt].ord_list_id = ol.br_ado_ord_list_id
     WITH nocounter
    ;end select
    CALL echorecord(del_temp)
    SET c_cnt = size(del_temp->details,5)
    FOR (x = 1 TO c_cnt)
      SET op_cnt = size(del_temp->details[x].options,5)
      FOR (y = 1 TO op_cnt)
        SET ol_cnt = size(del_temp->details[x].options[y].ord_list,5)
        FOR (z = 1 TO ol_cnt)
          DELETE  FROM br_ado_ord_list ol
           WHERE (ol.br_ado_ord_list_id=del_temp->details[x].options[y].ord_list[z].ord_list_id)
           WITH nocounter
          ;end delete
          SET ierrcode = error(serrmsg,1)
          IF (ierrcode > 0)
           SET error_flag = "Y"
           SET reply->status_data.subeventstatus[1].targetobjectname = "Error on OrdList Delete"
           SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
           GO TO exit_script
          ENDIF
        ENDFOR
        DELETE  FROM br_ado_option o
         WHERE (o.br_ado_option_id=del_temp->details[x].options[y].option_id)
         WITH nocounter
        ;end delete
        SET ierrcode = error(serrmsg,1)
        IF (ierrcode > 0)
         SET error_flag = "Y"
         SET reply->status_data.subeventstatus[1].targetobjectname = "Error on Option Delete"
         SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
         GO TO exit_script
        ENDIF
      ENDFOR
      DELETE  FROM br_ado_detail d
       WHERE (d.br_ado_detail_id=del_temp->details[x].detail_id)
       WITH nocounter
      ;end delete
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET error_flag = "Y"
       SET reply->status_data.subeventstatus[1].targetobjectname = "Error on Detail Delete"
       SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
       GO TO exit_script
      ENDIF
    ENDFOR
   ENDIF
  ENDFOR
 ENDIF
#exit_script
 IF (error_flag="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
