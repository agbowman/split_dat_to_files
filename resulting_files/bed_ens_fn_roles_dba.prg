CREATE PROGRAM bed_ens_fn_roles:dba
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
 SET prv_code_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=16409
   AND cv.active_ind=1
   AND cv.cdf_meaning="PRVRELN"
  DETAIL
   prv_code_value = cv.code_value
  WITH nocounter
 ;end select
 SET group_cnt = size(request->trlist,5)
 SET role_cnt = size(request->role_list,5)
 FOR (y = 1 TO group_cnt)
   FOR (x = 1 TO role_cnt)
     IF ((request->role_list[x].action_flag=1))
      SET tracking_ref_id = 0.0
      SELECT INTO "NL"
       FROM track_reference tr
       WHERE (tr.tracking_group_cd=request->trlist[y].code_value)
        AND (tr.display=request->role_list[x].display)
       DETAIL
        tracking_ref_id = tr.tracking_ref_id
       WITH nocounter
      ;end select
      IF (curqual=0)
       INSERT  FROM track_reference tr
        SET tr.tracking_ref_id = seq(reference_seq,nextval), tr.tracking_group_cd = request->trlist[y
         ].code_value, tr.tracking_ref_type_cd = prv_code_value,
         tr.assoc_code_value = 0.0, tr.active_ind = 1, tr.description =
         IF ((request->role_list[x].description=" ")) request->role_list[x].display
         ELSE request->role_list[x].description
         ENDIF
         ,
         tr.display = request->role_list[x].display, tr.display_key = cnvtupper(cnvtalphanum(request
           ->role_list[x].display)), tr.ref_color = " ",
         tr.ref_icon = 0.0, tr.overdue_interval = 0.0, tr.overdue_color = " ",
         tr.overdue_icon = 0.0, tr.critical_color = " ", tr.critical_icon = 0.0,
         tr.critical_interval = 0.0, tr.default_ind = 0.0, tr.complete_ind = 0.0,
         tr.critical_blink_ind = 0.0, tr.overdue_blink_ind = 0.0, tr.updt_dt_tm = cnvtdatetime(
          curdate,curtime3),
         tr.updt_id = reqinfo->updt_id, tr.updt_task = reqinfo->updt_task, tr.updt_cnt = 0,
         tr.updt_applctx = reqinfo->updt_applctx
        WITH nocounter
       ;end insert
      ELSE
       UPDATE  FROM track_reference tr
        SET tr.active_ind = 1, tr.updt_dt_tm = cnvtdatetime(curdate,curtime3), tr.updt_id = reqinfo->
         updt_id,
         tr.updt_task = reqinfo->updt_task, tr.updt_cnt = (tr.updt_cnt+ 1), tr.updt_applctx = reqinfo
         ->updt_applctx
        WHERE tr.tracking_ref_id=tracking_ref_id
       ;end update
      ENDIF
     ELSEIF ((request->role_list[x].action_flag=2))
      UPDATE  FROM track_reference tr
       SET tr.description =
        IF ((request->role_list[x].description=" ")) request->role_list[x].display
        ELSE request->role_list[x].description
        ENDIF
        , tr.display = request->role_list[x].display, tr.display_key = cnvtupper(cnvtalphanum(request
          ->role_list[x].display)),
        tr.active_ind = 1, tr.updt_dt_tm = cnvtdatetime(curdate,curtime3), tr.updt_id = reqinfo->
        updt_id,
        tr.updt_task = reqinfo->updt_task, tr.updt_cnt = (tr.updt_cnt+ 1), tr.updt_applctx = reqinfo
        ->updt_applctx
       WHERE (tr.tracking_ref_id=request->role_list[x].tracking_ref_id)
      ;end update
     ELSEIF ((request->role_list[x].action_flag=3))
      UPDATE  FROM track_reference tr
       SET tr.active_ind = 0, tr.updt_dt_tm = cnvtdatetime(curdate,curtime3), tr.updt_id = reqinfo->
        updt_id,
        tr.updt_task = reqinfo->updt_task, tr.updt_cnt = (tr.updt_cnt+ 1), tr.updt_applctx = reqinfo
        ->updt_applctx
       WHERE (tr.tracking_ref_id=request->role_list[x].tracking_ref_id)
       WITH nocounter
      ;end update
     ENDIF
   ENDFOR
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_FN_ROLES","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
