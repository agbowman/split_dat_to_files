CREATE PROGRAM bed_get_sch_sel_appt_types:dba
 FREE SET reply
 RECORD reply(
   1 departments[*]
     2 code_value = f8
     2 appt_types[*]
       3 appt_type_id = f8
       3 code_value = f8
       3 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET dcnt = 0
 SET dcnt = size(request->departments,5)
 IF (dcnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->departments,dcnt)
 FOR (x = 1 TO dcnt)
   SET reply->departments[x].code_value = request->departments[x].code_value
   SET cnt = 0
   IF ((request->orders_based_ind=1))
    SELECT INTO "nl:"
     FROM sch_appt_loc s,
      code_value c,
      sch_order_appt a
     PLAN (s
      WHERE (s.location_cd=reply->departments[x].code_value)
       AND s.active_ind=1)
      JOIN (c
      WHERE c.code_value=s.appt_type_cd
       AND c.active_ind=1)
      JOIN (a
      WHERE a.appt_type_cd=s.appt_type_cd
       AND a.active_ind=1)
     ORDER BY c.display
     HEAD c.display
      cnt = (cnt+ 1), stat = alterlist(reply->departments[x].appt_types,cnt), reply->departments[x].
      appt_types[cnt].code_value = s.appt_type_cd,
      reply->departments[x].appt_types[cnt].display = c.display
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM sch_appt_loc s,
      code_value c
     PLAN (s
      WHERE (s.location_cd=reply->departments[x].code_value)
       AND s.active_ind=1)
      JOIN (c
      WHERE c.code_value=s.appt_type_cd
       AND c.active_ind=1
       AND  NOT ( EXISTS (
      (SELECT
       a.appt_type_cd
       FROM sch_order_appt a
       WHERE a.appt_type_cd=c.code_value))))
     ORDER BY c.display
     HEAD c.display
      cnt = (cnt+ 1), stat = alterlist(reply->departments[x].appt_types,cnt), reply->departments[x].
      appt_types[cnt].code_value = s.appt_type_cd,
      reply->departments[x].appt_types[cnt].display = c.display
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 CALL echorecord(reply)
#exit_script
 SET reply->status_data.status = "S"
END GO
