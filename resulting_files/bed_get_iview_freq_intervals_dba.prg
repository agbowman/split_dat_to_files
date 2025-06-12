CREATE PROGRAM bed_get_iview_freq_intervals:dba
 FREE SET reply
 RECORD reply(
   1 positions[*]
     2 code_value = f8
     2 display = vc
     2 mean = vc
     2 frequency_intervals[*]
       3 code_value = f8
       3 display = vc
       3 mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET pcnt = 0
 SELECT INTO "nl:"
  FROM working_view_freq_interval w,
   code_value cv1,
   code_value cv2
  PLAN (w)
   JOIN (cv1
   WHERE cv1.code_value=w.position_cd
    AND cv1.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=w.working_view_interval_cd
    AND cv2.active_ind=1)
  ORDER BY w.position_cd
  HEAD w.position_cd
   pcnt = (pcnt+ 1), stat = alterlist(reply->positions,pcnt), reply->positions[pcnt].code_value = w
   .position_cd,
   reply->positions[pcnt].display = cv1.display, reply->positions[pcnt].mean = cv1.cdf_meaning, fcnt
    = 0
  DETAIL
   fcnt = (fcnt+ 1), stat = alterlist(reply->positions[pcnt].frequency_intervals,fcnt), reply->
   positions[pcnt].frequency_intervals[fcnt].code_value = w.working_view_interval_cd,
   reply->positions[pcnt].frequency_intervals[fcnt].display = cv2.display, reply->positions[pcnt].
   frequency_intervals[fcnt].mean = cv2.cdf_meaning
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
