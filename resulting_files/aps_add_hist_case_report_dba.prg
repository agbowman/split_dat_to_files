CREATE PROGRAM aps_add_hist_case_report:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 report_id = f8
   1 status_cd = f8
   1 status_disp = c40
 )
#script
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET report_id = 0.0
 SET status_cd = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=1305
   AND cv.cdf_meaning="VERIFIED"
  DETAIL
   status_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  seq_nbr = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   reply->report_id = seq_nbr
  WITH format, counter
 ;end select
 IF (curqual=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 INSERT  FROM case_report cr
  SET cr.report_id = reply->report_id, cr.case_id = request->case_id, cr.event_id = request->event_id,
   cr.catalog_cd = request->catalog_cd, cr.report_sequence = request->report_sequence, cr
   .status_prsnl_id = request->status_prsnl_id,
   cr.status_dt_tm =
   IF ((request->status_dt_tm > 0)) cnvtdatetime(request->status_dt_tm)
   ELSE null
   ENDIF
   , cr.status_cd = status_cd, cr.updt_dt_tm = cnvtdatetime(curdate,curtime),
   cr.updt_id = reqinfo->updt_id, cr.updt_task = reqinfo->updt_task, cr.updt_applctx = reqinfo->
   updt_applctx,
   cr.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
  SET reply->status_cd = 0
  SET reply->status_disp = ""
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
