CREATE PROGRAM afc_rpt_ta:dba
 RECORD reply(
   1 ta_qual = i2
   1 ta_recs[*]
     2 ta_charge_event_id = f8
     2 ta_ordered_dt_tm = dq8
     2 ta_collected_dt_tm = dq8
     2 ta_verified_dt_tm = dq8
     2 ta_complete_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET rn_dt = curdate
 SET start_dt = cnvtdatetime(concat(format(rn_dt,"DD-MMM-YYYY;;D")," 00:00:00.00"))
 SET end_dt = cnvtdatetime(concat(format(rn_dt,"DD-MMM-YYYY;;D")," 23:59:59.99"))
 SET ta_ordered_cd = 0.0
 SET ta_collected_cd = 0.0
 SET ta_verified_cd = 0.0
 SET ta_complete_cd = 0.0
 SET true = 1
 SET false = 0
 SELECT INTO "nl:"
  a.code_value
  FROM code_value a
  WHERE a.code_set=13029
   AND a.cdf_meaning="ORDERED"
   AND a.active_ind=1
  DETAIL
   ta_ordered_cd = a.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  a.code_value
  FROM code_value a
  WHERE a.code_set=13029
   AND a.cdf_meaning="COLLECTED"
   AND a.active_ind=1
  DETAIL
   ta_collected_cd = a.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  a.code_value
  FROM code_value a
  WHERE a.code_set=13029
   AND a.cdf_meaning="VERIFIED"
   AND a.active_ind=1
  DETAIL
   ta_verified_cd = a.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  a.code_value
  FROM code_value a
  WHERE a.code_set=13029
   AND a.cdf_meaning="COMPLETE"
   AND a.active_ind=1
  DETAIL
   ta_complete_cd = a.code_value
  WITH nocounter
 ;end select
 SET count1 = 0
 SET reply->status_data.status = "Z"
 SELECT INTO "nl:"
  c.charge_event_id, c.ceact_dt_tm
  FROM charge_event_act c
  WHERE cea_type_cd=ta_ordered_cd
   AND c.ceact_dt_tm >= cnvtdatetime(start_dt)
   AND c.ceact_dt_tm <= cnvtdatetime(end_dt)
  DETAIL
   count1 = (count1+ 1), stat = alterlist(reply->ta_recs,count1), reply->ta_recs[count1].
   ta_charge_event_id = c.charge_event_id,
   reply->ta_recs[count1].ta_ordered_dt_tm = c.ceact_dt_tm
  WITH nocounter
 ;end select
 SET reply->ta_qual = count1
 SELECT INTO "nl:"
  c.ceact_dt_tm
  FROM charge_event_act c,
   (dummyt d1  WITH seq = value(count1))
  PLAN (d1)
   JOIN (c
   WHERE c.cea_type_cd=ta_collected_cd
    AND (c.charge_event_id=reply->ta_recs[d1.seq].ta_charge_event_id))
  DETAIL
   reply->ta_recs[d1.seq].ta_collected_dt_tm = c.ceact_dt_tm
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.ceact_dt_tm
  FROM charge_event_act c,
   (dummyt d1  WITH seq = value(count1))
  PLAN (d1)
   JOIN (c
   WHERE c.cea_type_cd=ta_verified_cd
    AND (c.charge_event_id=reply->ta_recs[d1.seq].ta_charge_event_id))
  DETAIL
   reply->ta_recs[d1.seq].ta_verified_dt_tm = c.ceact_dt_tm
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.ceact_dt_tm
  FROM charge_event_act c,
   (dummyt d1  WITH seq = value(count1))
  PLAN (d1)
   JOIN (c
   WHERE c.cea_type_cd=ta_complete_cd
    AND (c.charge_event_id=reply->ta_recs[d1.seq].ta_charge_event_id))
  DETAIL
   reply->ta_recs[d1.seq].ta_complete_dt_tm = c.ceact_dt_tm
  WITH nocounter
 ;end select
 SELECT
  odt = format(cnvtdatetime(reply->ta_recs[d1.seq].ta_ordered_dt_tm),"MMDD HH:MM;;D"), reply->
  ta_recs[d1.seq].ta_collected_dt_tm, reply->ta_recs[d1.seq].ta_verified_dt_tm,
  reply->ta_recs[d1.seq].ta_complete_dt_tm
  FROM (dummyt d1  WITH seq = value(count1))
  WITH nocounter
 ;end select
#end_program
 SET count1 = 1
END GO
