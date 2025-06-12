CREATE PROGRAM dcp_get_appointment_dt_tm:dba
 RECORD reply(
   1 appointment_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE cstatus = c1 WITH protect, noconstant("Z")
 DECLARE req_appt_id = f8 WITH protect, constant(validate(request->appointment_id,0.0))
 DECLARE req_order_id = f8 WITH protect, constant(validate(request->order_id,0.0))
 IF (req_appt_id <= 0.0)
  SET cstatus = "F"
  GO TO exit_script
 ENDIF
 IF (req_order_id <= 0.0)
  SET cstatus = "F"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM sch_appt s,
   sch_event_attach se
  PLAN (se
   WHERE se.sch_event_id=req_appt_id
    AND se.order_id=req_order_id)
   JOIN (s
   WHERE s.sch_event_id=se.sch_event_id
    AND s.primary_role_ind=1)
  DETAIL
   cstatus = "S", reply->appointment_dt_tm = s.beg_dt_tm
 ;end select
#exit_script
 SET reply->status_data.status = cstatus
END GO
