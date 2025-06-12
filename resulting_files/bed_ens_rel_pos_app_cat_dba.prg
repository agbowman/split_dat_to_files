CREATE PROGRAM bed_ens_rel_pos_app_cat:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET rel_cnt = size(request->rel_list,5)
 SET a_cnt = 0
 FOR (x = 1 TO rel_cnt)
  SET a_cnt = size(request->rel_list[x].alist,5)
  FOR (y = 1 TO a_cnt)
    IF ((request->rel_list[x].alist[y].action_flag=1))
     SET new_id = 0.0
     SELECT INTO "NL:"
      j = seq(reference_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       new_id = cnvtreal(j)
      WITH format, counter
     ;end select
     INSERT  FROM application_group ap
      SET ap.application_group_id = new_id, ap.position_cd = request->rel_list[x].position_code_value,
       ap.app_group_cd = request->rel_list[x].alist[y].app_group_code_value,
       ap.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), ap.end_effective_dt_tm = cnvtdatetime
       ("31-DEC-2100"), ap.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       ap.updt_id = reqinfo->updt_id, ap.updt_task = reqinfo->updt_task, ap.updt_cnt = 0,
       ap.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "F"
      SET error_msg = concat("Error adding relationship to application_group for position ",
       cnvtstring(request->rel_list[x].position_code_value)," and application group ",cnvtstring(
        request->rel_list[x].alist[y].app_group_code_value),".")
      GO TO exit_script
     ENDIF
    ELSEIF ((request->rel_list[x].alist[y].action_flag=3))
     DELETE  FROM application_group ap
      WHERE (ap.position_cd=request->rel_list[x].position_code_value)
       AND (ap.app_group_cd=request->rel_list[x].alist[y].app_group_code_value)
      WITH nocounter
     ;end delete
     IF (curqual=0)
      SET error_flag = "F"
      SET error_msg = concat("Error deleting relationship to application_group for position ",
       cnvtstring(request->rel_list[x].position_code_value)," and application group ",cnvtstring(
        request->rel_list[x].alist[y].app_group_code_value),".")
      GO TO exit_script
     ENDIF
    ENDIF
  ENDFOR
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_REL_POS_APP_CAT","  >> ERROR MSG: ",
   error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
