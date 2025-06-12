CREATE PROGRAM cp_delete_chart_format:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE failed = c1
 DECLARE found = i2
 SET failed = "S"
 UPDATE  FROM chart_format cf
  SET cf.active_ind = 0, cf.active_status_cd = reqdata->inactive_status_cd, cf.active_status_prsnl_id
    = reqinfo->updt_id,
   cf.updt_cnt = (cf.updt_cnt+ 1), cf.updt_dt_tm = cnvtdatetime(curdate,curtime), cf.updt_id =
   reqinfo->updt_id,
   cf.updt_applctx = reqinfo->updt_applctx, cf.updt_task = reqinfo->updt_task
  WHERE (cf.chart_format_id=request->chart_format_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM format_org_reltn f
  WHERE (f.chart_format_id=request->chart_format_id)
   AND f.active_ind=1
  DETAIL
   found = 1
  WITH nocounter
 ;end select
 IF (found=1)
  UPDATE  FROM format_org_reltn f
   SET f.active_ind = 0, f.active_status_cd = reqdata->inactive_status_cd, f.active_status_prsnl_id
     = reqinfo->updt_id,
    f.updt_cnt = (f.updt_cnt+ 1), f.updt_dt_tm = cnvtdatetime(curdate,curtime), f.updt_id = reqinfo->
    updt_id,
    f.updt_applctx = reqinfo->updt_applctx, f.updt_task = reqinfo->updt_task
   WHERE (f.chart_format_id=request->chart_format_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed != "S")
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "Z"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
