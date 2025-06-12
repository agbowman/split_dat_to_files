CREATE PROGRAM dcp_get_wv_freq_intervals:dba
 SET modify = predeclare
 RECORD reply(
   1 wv_intervals[*]
     2 working_view_interval_cd = f8
     2 working_view_interval_disp = c40
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
  FROM working_view_freq_interval wvfi,
   code_value cv
  PLAN (wvfi
   WHERE (wvfi.position_cd=request->position_cd))
   JOIN (cv
   WHERE cv.code_value=wvfi.working_view_interval_cd)
  ORDER BY cv.collation_seq
  DETAIL
   counter = (counter+ 1)
   IF (mod(counter,10)=1)
    stat = alterlist(reply->wv_intervals,(counter+ 9))
   ENDIF
   reply->wv_intervals[counter].working_view_interval_cd = wvfi.working_view_interval_cd
  FOOT REPORT
   stat = alterlist(reply->wv_intervals,counter)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
