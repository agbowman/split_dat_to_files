CREATE PROGRAM bbt_get_dispense_info:dba
 RECORD reply(
   1 person_id = f8
   1 pd_updt_cnt = i4
   1 dispense_qty = i4
   1 dispense_device_id = f8
   1 dispense_device_mean = c12
   1 dispense_cooler_id = f8
   1 dispense_cooler_disp = c40
   1 dispense_cooler_desc = c60
   1 dispense_cooler_mean = c12
   1 dispense_cooler_text = c40
   1 crossmatch_exp_dt_tm = dq8
   1 person_comments_ind = i2
   1 dispense_unknown_pat_ind = i2
   1 dispense_unknown_pat_text = c50
   1 transfer_smo_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE interface_device_flag = i2 WITH protect, noconstant(0)
 DECLARE transfer_reason_cs = i4 WITH protect, constant(1617)
 DECLARE sys_moveoutcd = f8 WITH protect, constant(uar_get_code_by("MEANING",transfer_reason_cs,
   "SYS_MOVEOUT"))
 DECLARE sys_emeroutcd = f8 WITH protect, constant(uar_get_code_by("MEANING",transfer_reason_cs,
   "SYS_EMEROUT"))
 DECLARE sys_transoutcd = f8 WITH protect, constant(uar_get_code_by("MEANING",transfer_reason_cs,
   "SYS_TRANSOUT"))
 SET reply->status_data.status = "S"
 SELECT INTO "nl:"
  pd.product_id, pd.product_event_id, pd.person_id,
  pd.updt_cnt, pd.cur_dispense_qty, device_mean = uar_get_code_meaning(i.device_type_cd)
  FROM patient_dispense pd,
   dummyt d,
   bb_inv_device i
  PLAN (pd
   WHERE (pd.product_event_id=request->product_event_id)
    AND (pd.product_id=request->product_id))
   JOIN (d)
   JOIN (i
   WHERE i.bb_inv_device_id IN (pd.device_id, pd.dispense_cooler_id)
    AND i.active_ind=1)
  DETAIL
   reply->person_id = pd.person_id, reply->pd_updt_cnt = pd.updt_cnt, reply->dispense_qty = pd
   .cur_dispense_qty,
   reply->dispense_device_id = pd.device_id, reply->dispense_device_mean = device_mean, reply->
   dispense_cooler_id = pd.dispense_cooler_id,
   reply->dispense_cooler_text = pd.dispense_cooler_text, reply->dispense_unknown_pat_ind = pd
   .unknown_patient_ind, reply->dispense_unknown_pat_text = pd.unknown_patient_text,
   interface_device_flag = i.interface_flag
  WITH nocounter, outerjoin = d
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSEIF ((request->xmatch_event_id > 0))
  SELECT INTO "nl"
   xm.product_event_id, xm.crossmatch_exp_dt_tm
   FROM crossmatch xm
   WHERE (xm.product_event_id=request->xmatch_event_id)
   DETAIL
    reply->crossmatch_exp_dt_tm = xm.crossmatch_exp_dt_tm
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 SET reply->person_comments_ind = 0
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SELECT INTO "nl"
   b.bb_comment_id
   FROM blood_bank_comment b
   WHERE (b.person_id=reply->person_id)
    AND (reply->person_id > 0.0)
    AND b.active_ind=1
   DETAIL
    reply->person_comments_ind = 1,
    CALL echo(b.bb_comment_id)
   WITH nocounter
  ;end select
 ENDIF
 CALL echo(build("Is the device interfaced?: ",interface_device_flag))
 IF (interface_device_flag > 0
  AND (((sys_emeroutcd+ sys_transoutcd)+ sys_moveoutcd) > 0))
  SELECT INTO "nl:"
   pe.event_dt_tm
   FROM bb_device_transfer t,
    product_event pe
   PLAN (t
    WHERE (t.product_id=request->product_id)
     AND t.reason_cd IN (sys_emeroutcd, sys_transoutcd, sys_moveoutcd))
    JOIN (pe
    WHERE pe.product_event_id=t.product_event_id
     AND (pe.event_dt_tm >
    (SELECT
     pe_pd.event_dt_tm
     FROM product_event pe_pd
     WHERE (pe_pd.product_id=request->product_id)
      AND (pe_pd.product_event_id=request->product_event_id))))
   ORDER BY pe.product_id, pe.event_dt_tm DESC
   HEAD pe.product_id
    reply->transfer_smo_dt_tm = pe.event_dt_tm
   WITH nocounter
  ;end select
 ENDIF
END GO
