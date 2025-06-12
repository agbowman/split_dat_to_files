CREATE PROGRAM bed_get_cki_client_info:dba
 FREE SET reply
 RECORD reply(
   1 qual[*]
     2 data_type_id = f8
     2 data_type_name = vc
     2 data_type_mean = vc
     2 load_dt_tm = dq8
     2 lock_ind = i2
     2 export_ind = i2
     2 updt_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM br_cki_client_info bcci,
   br_cki_data_type bcdt
  PLAN (bcci
   WHERE (bcci.client_id=request->client_id))
   JOIN (bcdt
   WHERE bcdt.data_type_id=bcci.data_type_id)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->qual,cnt), reply->qual[cnt].data_type_id = bcci
   .data_type_id,
   reply->qual[cnt].data_type_name = bcdt.data_type_name, reply->qual[cnt].data_type_mean = bcdt
   .data_type_meaning, reply->qual[cnt].load_dt_tm = bcci.load_dt_tm,
   reply->qual[cnt].lock_ind = bcci.lock_ind, reply->qual[cnt].export_ind = bcci.export_ind, reply->
   qual[cnt].updt_dt_tm = bcci.updt_dt_tm
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = "Y"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
