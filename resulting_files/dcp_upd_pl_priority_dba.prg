CREATE PROGRAM dcp_upd_pl_priority:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE g_failed = c1 WITH public, noconstant("F")
 DECLARE x = i4 WITH public, noconstant(0)
 DECLARE cur_updt_cnt = i4 WITH public, noconstant(0)
 DECLARE tmp_priority_id = f8 WITH public, noconstant(0.0)
 SET reply->status_data.status = "F"
 IF ((request->priority < 0))
  DELETE  FROM dcp_pl_prioritization pp
   WHERE (pp.patient_list_id=request->patient_list_id)
    AND (pp.person_id=request->person_id)
   WITH nocounter
  ;end delete
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dcp_pl_prioritization pp
  WHERE (pp.patient_list_id=request->patient_list_id)
   AND (pp.person_id=request->person_id)
   AND pp.remove_ind != 1
  DETAIL
   cur_updt_cnt = pp.updt_cnt
  WITH nocounter, forupdate(pp)
 ;end select
 IF (curqual=0)
  CALL echo("Lock row for update failed since curqual = 0")
  SET g_failed = "T"
 ENDIF
 IF (g_failed="F")
  UPDATE  FROM dcp_pl_prioritization pp
   SET pp.priority = request->priority, pp.updt_applctx = reqinfo->updt_applctx, pp.updt_cnt = (pp
    .updt_cnt+ 1),
    pp.updt_dt_tm = cnvtdatetime(curdate,curtime3), pp.updt_id = reqinfo->updt_id, pp.updt_task =
    reqinfo->updt_task
   WHERE (pp.patient_list_id=request->patient_list_id)
    AND (pp.person_id=request->person_id)
    AND pp.remove_ind != 1
   WITH nocounter
  ;end update
 ENDIF
 IF (g_failed="T")
  INSERT  FROM dcp_pl_prioritization pp
   SET pp.priority_id = seq(dcp_patient_list_seq,nextval), pp.priority = request->priority, pp
    .person_id = request->person_id,
    pp.patient_list_id = request->patient_list_id, pp.updt_applctx = reqinfo->updt_applctx, pp
    .updt_cnt = 0,
    pp.updt_dt_tm = cnvtdatetime(curdate,curtime3), pp.updt_id = reqinfo->updt_id, pp.updt_task =
    reqinfo->updt_task
   WITH nocounter
  ;end insert
  IF (curqual != 0)
   SET g_failed = "F"
  ENDIF
 ENDIF
#exit_script
 IF (g_failed="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
