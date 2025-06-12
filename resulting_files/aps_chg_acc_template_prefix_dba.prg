CREATE PROGRAM aps_chg_acc_template_prefix:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET cur_updt_cnt2[100] = 0
 SET debug = 0
 IF (debug=1)
  CALL echo("")
  CALL echo(build("Num to Add :",request->add_cnt))
  CALL echo(build("Num to Chg :",request->change_cnt))
  CALL echo(build("Num to Rmv :",request->remove_cnt))
 ENDIF
 IF ((request->remove_cnt > 0))
  DELETE  FROM ap_prefix_accn_template_r apatr,
    (dummyt d  WITH seq = value(request->remove_cnt))
   SET apatr.template_cd = request->remove_qual[d.seq].template_cd
   PLAN (d)
    JOIN (apatr
    WHERE (apatr.template_cd=request->remove_qual[d.seq].template_cd)
     AND (apatr.prefix_id=request->remove_qual[d.seq].prefix_id))
   WITH nocounter
  ;end delete
  IF ((curqual != request->remove_cnt))
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "Delete"
   SET reply->status_data.subeventstatus[1].targetobjectname = "ap_prefix_accn_template_r"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build("number_to_del: ",remove_cnt)
   IF (debug=1)
    CALL echo("Error: Delete didn't work!")
    CALL echo(build("Number_To_Del :",request->remove_cnt))
    CALL echo(build("Curqual :",curqual))
   ENDIF
   ROLLBACK
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->add_cnt > 0))
  INSERT  FROM ap_prefix_accn_template_r apatr,
    (dummyt d  WITH seq = value(request->add_cnt))
   SET apatr.template_cd = request->add_qual[d.seq].template_cd, apatr.prefix_id = request->add_qual[
    d.seq].prefix_id, apatr.default_ind = 0,
    apatr.updt_cnt = 0, apatr.updt_dt_tm = cnvtdatetime(curdate,curtime3), apatr.updt_id = reqinfo->
    updt_id,
    apatr.updt_task = reqinfo->updt_task, apatr.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (apatr)
   WITH nocounter
  ;end insert
  IF (curqual != value(request->add_cnt))
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "Insert"
   SET reply->status_data.subeventstatus[1].targetobjectname = "ap_prefix_accn_template_r"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build("number_to_add: ",request->
    add_cnt)
   IF (debug=1)
    CALL echo("Error: New template_detail insert failed!")
    CALL echo(build("Curqual :",curqual))
   ENDIF
   ROLLBACK
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->change_cnt > 0))
  SELECT INTO "nl:"
   apatr.template_cd
   FROM ap_prefix_accn_template_r apatr,
    (dummyt d  WITH seq = value(request->change_cnt))
   PLAN (d)
    JOIN (apatr
    WHERE (apatr.template_cd=request->change_qual[d.seq].template_cd)
     AND (apatr.prefix_id=request->change_qual[d.seq].prefix_id))
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1), cur_updt_cnt2[count1] = apatr.updt_cnt
   WITH nocounter, forupdate(apatr)
  ;end select
  IF ((count1 != request->change_cnt))
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "Lock"
   SET reply->status_data.subeventstatus[1].targetobjectname = "ap_prefix_accn_template_r"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build("number_to_chg: ",request->
    change_cnt)
   IF (debug=1)
    CALL echo("Error1: Template_detail lock failed!")
    CALL echo(build("Count1 :",count1))
    CALL echo(build("Chg_Detail_Cnt :",request->change_cnt))
    FOR (x = 1 TO count1)
      CALL echo(build("Template_Detail_Id :",request->change_qual[x].template_cd,"_",request->
        change_qual[x].prefix_id))
    ENDFOR
   ENDIF
   ROLLBACK
   GO TO exit_script
  ENDIF
  FOR (xx = 1 TO request->change_cnt)
    IF ((request->change_qual[xx].updt_cnt != cur_updt_cnt2[xx]))
     SET stat = alter(reply->status_data.subeventstatus,1)
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].operationname = "lock"
     SET reply->status_data.subeventstatus[1].targetobjectname = "ap_prefix_accn_template_r"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = build("number_to_chg: ",request->
      change_cnt)
     IF (debug=1)
      CALL echo("Error2: Template_detail lock failed!")
     ENDIF
     ROLLBACK
     GO TO exit_script
    ENDIF
  ENDFOR
  UPDATE  FROM ap_prefix_accn_template_r apatr,
    (dummyt d  WITH seq = value(request->change_cnt))
   SET apatr.default_ind = request->change_qual[d.seq].default_ind, apatr.updt_cnt = (apatr.updt_cnt
    + 1), apatr.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    apatr.updt_id = reqinfo->updt_id, apatr.updt_task = reqinfo->updt_task, apatr.updt_applctx =
    reqinfo->updt_applctx
   PLAN (d)
    JOIN (apatr
    WHERE (apatr.template_cd=request->change_qual[d.seq].template_cd)
     AND (apatr.prefix_id=request->change_qual[d.seq].prefix_id))
   WITH nocounter
  ;end update
  IF ((curqual != request->change_cnt))
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "Update"
   SET reply->status_data.subeventstatus[1].targetobjectname = "ap_prefix_accn_template_r"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build("number_to_chg: ",request->
    change_cnt)
   IF (debug=1)
    CALL echo("Error: Template_detail update failed!")
   ENDIF
   ROLLBACK
   GO TO exit_script
  ENDIF
 ENDIF
 COMMIT
 SET reply->status_data.status = "S"
 GO TO exit_script
#exit_script
 IF (debug=1)
  CALL echo("Script Completed!")
  CALL echo(build("Status :",reply->status_data.status))
 ENDIF
END GO
