CREATE PROGRAM dcp_add_timescales_info:dba
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
 DECLARE failed = vc WITH protect, noconstant("F")
 DECLARE timeid = f8 WITH protect, noconstant(0.0)
 DECLARE qual_cnt = i4 WITH protect, noconstant(size(request->qual,5))
 SELECT INTO "nl:"
  nextseqnum = seq(reference_seq,nextval)"##################;rp0"
  FROM dual
  DETAIL
   timeid = cnvtreal(nextseqnum)
  WITH format, nocounter
 ;end select
 INSERT  FROM time_scale ts,
   (dummyt d  WITH seq = value(qual_cnt))
  SET ts.time_scale_id = timeid, ts.time_scale_name = request->qual[d.seq].time_scale_name, ts
   .time_scale_name_key = cnvtalphanum(cnvtupper(request->qual[d.seq].time_scale_name)),
   ts.time_scale_type_flag = request->qual[d.seq].time_scale_type_flag, ts.interval_units_cd =
   request->qual[d.seq].interval_units_cd, ts.interval_length = request->qual[d.seq].interval_length,
   ts.nbr_of_intervals = request->qual[d.seq].nbr_of_intervals, ts.time_scale_start_tm = cnvtdatetime
   (request->qual[d.seq].time_scale_start_tm), ts.time_scale_start_tm_long = request->qual[d.seq].
   time_scale_start_tm_long,
   ts.interval_label_flag = request->qual[d.seq].interval_label_flag, ts.updt_dt_tm = cnvtdatetime(
    curdate,curtime), ts.updt_id = reqinfo->updt_id,
   ts.updt_task = reqinfo->updt_task, ts.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (ts)
  WITH counter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "time_scale table"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "UNABLE TO INSERT"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 SET modify = nopredeclare
END GO
