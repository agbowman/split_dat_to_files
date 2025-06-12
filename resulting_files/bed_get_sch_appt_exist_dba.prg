CREATE PROGRAM bed_get_sch_appt_exist:dba
 FREE SET reply
 RECORD reply(
   1 departments[*]
     2 code_value = f8
     2 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SELECT INTO "nl:"
  FROM sch_appt_loc s,
   code_value c
  PLAN (s
   WHERE (s.appt_type_cd=request->appt_type_code_value)
    AND s.active_ind=1)
   JOIN (c
   WHERE c.code_value=s.location_cd
    AND c.active_ind=1)
  DETAIL
   IF ((s.location_cd != request->dept_code_value))
    cnt = (cnt+ 1), stat = alterlist(reply->departments,cnt), reply->departments[cnt].code_value = s
    .location_cd,
    reply->departments[cnt].display = c.display
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(reply)
#exit_script
 SET reply->status_data.status = "S"
END GO
