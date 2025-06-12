CREATE PROGRAM bbt_get_emerg_dis_corr:dba
 RECORD reply(
   1 dispense_updt_cnt = i4
   1 product_event_id = f8
   1 product_event_updt_cnt = i4
   1 unknown_patient_text = c50
   1 bb_id_nbr = c20
   1 dispense_dt_tm = dq8
   1 orig_updt_dt_tm = dq8
   1 orig_updt_id = f8
   1 orig_updt_task = i4
   1 orig_updt_applctx = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT
  IF (validate(request->submitted_product_event_id,0) > 0)
   PLAN (p
    WHERE (p.product_id=request->product_id)
     AND (p.product_event_id=request->submitted_product_event_id)
     AND p.active_ind=1
     AND p.person_id=0
     AND p.unknown_patient_ind=1
     AND p.unknown_patient_text != null)
    JOIN (pe
    WHERE pe.product_event_id=p.product_event_id)
  ELSE
   PLAN (p
    WHERE (p.product_id=request->product_id)
     AND p.active_ind=1
     AND p.person_id=0
     AND p.unknown_patient_ind=1
     AND p.unknown_patient_text != null)
    JOIN (pe
    WHERE pe.product_event_id=p.product_event_id)
  ENDIF
  INTO "nl:"
  p.*
  FROM patient_dispense p,
   product_event pe
  DETAIL
   reply->dispense_updt_cnt = p.updt_cnt, reply->unknown_patient_text = p.unknown_patient_text, reply
   ->product_event_id = p.product_event_id,
   reply->bb_id_nbr = p.bb_id_nbr, reply->dispense_dt_tm = pe.event_dt_tm, reply->
   product_event_updt_cnt = pe.updt_cnt,
   reply->orig_updt_dt_tm = p.updt_dt_tm, reply->orig_updt_id = p.updt_id, reply->orig_updt_task = p
   .updt_task,
   reply->orig_updt_applctx = p.updt_applctx
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
