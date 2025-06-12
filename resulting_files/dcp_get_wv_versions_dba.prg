CREATE PROGRAM dcp_get_wv_versions:dba
 SET modify = predeclare
 RECORD reply(
   1 qual[*]
     2 working_view_id = f8
     2 version_num = i4
     2 current_working_view = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE counter = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM working_view wv
  WHERE (((wv.working_view_id=request->working_view_id)) OR ((wv.current_working_view=request->
  working_view_id)))
  ORDER BY wv.version_num DESC
  DETAIL
   counter = (counter+ 1)
   IF (mod(counter,10)=1)
    stat = alterlist(reply->qual,(counter+ 9))
   ENDIF
   reply->qual[counter].working_view_id = wv.working_view_id, reply->qual[counter].version_num = wv
   .version_num, reply->qual[counter].current_working_view = wv.current_working_view,
   reply->qual[counter].beg_effective_dt_tm = wv.beg_effective_dt_tm, reply->qual[counter].
   end_effective_dt_tm = wv.end_effective_dt_tm, reply->qual[counter].active_ind = wv.active_ind
  FOOT REPORT
   stat = alterlist(reply->qual,counter)
  WITH nocounter
 ;end select
 IF (counter=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
