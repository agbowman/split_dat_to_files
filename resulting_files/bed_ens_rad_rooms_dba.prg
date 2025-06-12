CREATE PROGRAM bed_ens_rad_rooms:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET tot_count = 0
 SET sr_cnt = 0
 SET tot_count = size(request->oc_list,5)
 FOR (x = 1 TO tot_count)
  IF ((request->oc_list[x].action_flag=1))
   INSERT  FROM br_order_catalog b
    SET b.catalog_cd = request->oc_list[x].code_value, b.report_req_ind = request->oc_list[x].
     report_req_ind, b.multi_seg_ind = request->oc_list[x].multi_seg_ind,
     b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
     reqinfo->updt_task,
     b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to insert ",cnvtstring(request->oc_list[x].code_value),
     " into the br_order_catalog table.")
    GO TO exit_script
   ENDIF
  ELSEIF ((request->oc_list[x].action_flag=2))
   UPDATE  FROM br_order_catalog b
    SET b.report_req_ind = request->oc_list[x].report_req_ind, b.multi_seg_ind = request->oc_list[x].
     multi_seg_ind, b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_cnt = (b.updt_cnt+ 1),
     b.updt_applctx = reqinfo->updt_applctx
    WHERE (b.catalog_cd=request->oc_list[x].code_value)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to update ",cnvtstring(request->oc_list[x].code_value),
     " into the br_order_catalog table.")
    GO TO exit_script
   ENDIF
  ELSEIF ((request->oc_list[x].action_flag=3))
   DELETE  FROM br_order_catalog b
    WHERE (b.catalog_cd=request->oc_list[x].code_value)
    WITH nocounter
   ;end delete
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to delete ",cnvtstring(request->oc_list[x].code_value),
     " into the br_order_catalog table.")
    GO TO exit_script
   ENDIF
   DELETE  FROM br_oc_rad_room b
    WHERE (b.catalog_cd=request->oc_list[x].code_value)
    WITH nocounter
   ;end delete
  ENDIF
  IF ((request->oc_list[x].action_flag != 3))
   SET sr_cnt = size(request->oc_list[x].sr_list,5)
   FOR (y = 1 TO sr_cnt)
     IF ((request->oc_list[x].sr_list[y].action_flag=1))
      INSERT  FROM br_oc_rad_room b
       SET b.catalog_cd = request->oc_list[x].code_value, b.service_resource_cd = request->oc_list[x]
        .sr_list[y].code_value, b.status = request->oc_list[x].sr_list[y].status,
        b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
        reqinfo->updt_task,
        b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat("Unable to insert ",cnvtstring(request->oc_list[x].code_value),
        " into the br_oc_rad_room table with ",cnvtstring(request->oc_list[x].sr_list[y].code_value),
        " .")
       GO TO exit_script
      ENDIF
     ELSEIF ((request->oc_list[x].sr_list[y].action_flag=2))
      UPDATE  FROM br_oc_rad_room b
       SET b.status = request->oc_list[x].sr_list[y].status, b.updt_dt_tm = cnvtdatetime(curdate,
         curtime3), b.updt_id = reqinfo->updt_id,
        b.updt_task = reqinfo->updt_task, b.updt_cnt = (b.updt_cnt+ 1), b.updt_applctx = reqinfo->
        updt_applctx
       WHERE (b.catalog_cd=request->oc_list[x].code_value)
        AND (b.service_resource_cd=request->oc_list[x].sr_list[y].code_value)
      ;end update
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat("Unable to update ",cnvtstring(request->oc_list[x].code_value),
        " into the br_oc_rad_room table with ",cnvtstring(request->oc_list[x].sr_list[y].code_value),
        " .")
       GO TO exit_script
      ENDIF
     ELSEIF ((request->oc_list[x].sr_list[y].action_flag=3))
      DELETE  FROM br_oc_rad_room b
       WHERE (b.catalog_cd=request->oc_list[x].code_value)
        AND (b.service_resource_cd=request->oc_list[x].sr_list[y].code_value)
       WITH nocounter
      ;end delete
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat("Unable to delete ",cnvtstring(request->oc_list[x].code_value),
        " into the br_oc_rad_room table with ",cnvtstring(request->oc_list[x].sr_list[y].code_value),
        " .")
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
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_RAD_ROOMS","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
