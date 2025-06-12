CREATE PROGRAM dcp_add_comp_group_action
 SET modify = predeclare
 DECLARE comp_group_action_count = i2 WITH constant(value(size(request->compgroupactionlist,5)))
 DECLARE currdttm = dq8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 DECLARE cfailed = c1 WITH noconstant("F")
 DECLARE isubeventstatuscount = i4 WITH protect, noconstant(0)
 DECLARE isubeventstatussize = i4 WITH protect, noconstant(value(size(reply->status_data.
    subeventstatus,5)))
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errcnt = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant(" ")
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 IF (comp_group_action_count > 0)
  INSERT  FROM act_pw_comp_g_action apcga,
    (dummyt d  WITH seq = value(comp_group_action_count))
   SET apcga.act_pw_comp_g_action_id = request->compgroupactionlist[d.seq].act_pw_comp_g_action_id,
    apcga.act_pw_comp_g_id = request->compgroupactionlist[d.seq].act_pw_comp_g_id, apcga
    .act_pw_comp_id = request->compgroupactionlist[d.seq].act_pw_comp_id,
    apcga.sequence = request->compgroupactionlist[d.seq].sequence, apcga.type_flag = request->
    compgroupactionlist[d.seq].type_flag, apcga.prsnl_id = request->compgroupactionlist[d.seq].
    provider_id,
    apcga.reason_cd = request->compgroupactionlist[d.seq].reason_cd, apcga.reason_comment = trim(
     request->compgroupactionlist[d.seq].reason_comment), apcga.action_tz = request->
    compgroupactionlist[d.seq].action_tz,
    apcga.action_dt_tm = cnvtdatetime(currdttm), apcga.updt_dt_tm = cnvtdatetime(currdttm), apcga
    .updt_id = reqinfo->updt_id,
    apcga.updt_task = reqinfo->updt_task, apcga.updt_cnt = 0, apcga.updt_applctx = reqinfo->
    updt_applctx
   PLAN (d)
    JOIN (apcga)
   WITH nocounter
  ;end insert
  IF (curqual=0)
   CALL report_failure("INSERT","F","DCP_ADD_COMP_GROUP_ACTION",
    "Failed to insert a new row into ACT_PW_COMP_G_ACTION table")
   GO TO exit_script
  ENDIF
 ENDIF
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   SET cfailed = "T"
   SET isubeventstatuscount = (isubeventstatuscount+ 1)
   IF (isubeventstatuscount > isubeventstatussize)
    SET isubeventstatussize = (isubeventstatussize+ 1)
    SET stat = alterlist(reply->status_data.subeventstatus,isubeventstatussize)
   ENDIF
   SET reply->status_data.subeventstatus[isubeventstatuscount].operationname = trim(opname)
   SET reply->status_data.subeventstatus[isubeventstatuscount].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[isubeventstatuscount].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[isubeventstatuscount].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 SET errcode = error(errmsg,0)
 WHILE (errcode != 0
  AND errcnt <= 50)
   SET errcnt = (errcnt+ 1)
   CALL report_failure("CCL ERROR","F","DCP_ADD_COMP_GROUP_ACTION",errmsg)
   SET errcode = error(errmsg,0)
 ENDWHILE
 IF (cfailed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 DECLARE last_mod = c3 WITH protect, constant(fillstring(3,"000"))
 DECLARE mod_date = c30 WITH protect, constant(fillstring(30,"April 8, 2013"))
END GO
