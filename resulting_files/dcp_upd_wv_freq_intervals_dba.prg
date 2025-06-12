CREATE PROGRAM dcp_upd_wv_freq_intervals:dba
 SET modify = predeclare
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE log_status(operationname=vc,operationstatus=vc,targetobjectname=vc,targetobjectvalue=vc) =
 null
 DECLARE log_count = i4 WITH noconstant(0)
 SUBROUTINE log_status(operationname,operationstatus,targetobjectname,targetobjectvalue)
   IF ( NOT (validate(reply,0)))
    RETURN
   ENDIF
   SET log_count = size(reply->status_data.subeventstatus,5)
   IF (log_count=1)
    IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
     SET log_count = (log_count+ 1)
    ENDIF
   ELSE
    SET log_count = (log_count+ 1)
   ENDIF
   SET stat = alter(reply->status_data.subeventstatus,log_count)
   SET reply->status_data.subeventstatus[log_count].operationname = operationname
   SET reply->status_data.subeventstatus[log_count].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[log_count].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[log_count].targetobjectvalue = targetobjectvalue
 END ;Subroutine
 SET reply->status_data.status = "F"
 DECLARE err_msg = vc
 DECLARE number_of_frequencies = i4 WITH noconstant(0)
 DECLARE y = i4 WITH noconstant(0)
 DECLARE tmp_working_view_freq_interval_id = f8 WITH noconstant(0.0)
 DECLARE fail = c1 WITH noconstant("F")
 DELETE  FROM working_view_freq_interval wvfi
  WHERE (wvfi.position_cd=request->position_cd)
 ;end delete
 SET number_of_frequencies = size(request->wv_intervals,5)
 FOR (y = 1 TO number_of_frequencies)
   SELECT INTO "nl:"
   ;end select
   INSERT  FROM working_view_freq_interval wvfi
    SET wvfi.working_view_freq_interval_id = seq(carenet_seq,nextval), wvfi.position_cd = request->
     position_cd, wvfi.working_view_interval_cd = request->wv_intervals[y].wv_interval_cd,
     wvfi.updt_id = reqinfo->updt_id, wvfi.updt_dt_tm = cnvtdatetime(curdate,curtime3), wvfi
     .updt_task = reqinfo->updt_task,
     wvfi.updt_applctx = reqinfo->updt_applctx, wvfi.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET err_msg = "unable to insert into working_view_freq_interval table"
    SET failed = "T"
    CALL log_status("INSERT","F","WORKING_VIEW_FREQ_INTERVAL",err_msg)
    GO TO exit_script
   ENDIF
 ENDFOR
#exit_script
 IF (fail="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
