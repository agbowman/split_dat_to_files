CREATE PROGRAM co_add_risk_adjustment_day:dba
 RECORD reply(
   1 reclist[*]
     2 risk_adjustment_day_id = f8
     2 risk_adjustment_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE serrmsg = c256 WITH public, noconstant("")
 SET serrmsg = fillstring(256," ")
 SET reply->status_data.status = "F"
 SET failure = "F"
 DECLARE sfailed = c2 WITH private, noconstant("S")
 DECLARE req_size = i4 WITH public, noconstant(size(request->reclist,5))
 DECLARE n = i4 WITH public, noconstant(0)
 FREE RECORD m_dm2_seq_stat
 RECORD m_dm2_seq_stat(
   1 n_status = i4
   1 s_error_msg = vc
 ) WITH protect
 FREE RECORD t_sequences
 RECORD t_sequences(
   1 qual[*]
     2 seq_id = f8
 )
 EXECUTE dm2_dar_get_bulk_seq "t_sequences->qual", req_size, "seq_id",
 1, "carenet_seq"
 IF ((m_dm2_seq_stat->n_status != 1))
  CALL echo("ERROR encountered in DM2_DAR_GET_BULK_SEQ.")
  CALL echo(m_dm2_seq_stat->s_error_msg)
  SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "co_add_risk_adjustment_day"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = m_dm2_seq_stat->s_error_msg
  GO TO exit_script
 ENDIF
 IF (size(t_sequences->qual,5) != req_size)
  SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "co_add_risk_adjustment_day"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Error in fetching database table sequence identifiers"
  GO TO exit_script
 ENDIF
 FOR (n = 1 TO req_size)
   SET request->reclist[n].risk_adjustment_day_id = t_sequences->qual[n].seq_id
 ENDFOR
 INSERT  FROM risk_adjustment_day rad,
   (dummyt d  WITH seq = value(req_size))
  SET rad.activetx_ind = request->reclist[d.seq].activetx_ind, rad.albumin_ce_id = request->reclist[d
   .seq].albumin_ce_id, rad.apache_iii_score = request->reclist[d.seq].apache_iii_score,
   rad.apache_ii_score = request->reclist[d.seq].apache_ii_score, rad.aps_day1 = request->reclist[d
   .seq].aps_day1, rad.aps_score = request->reclist[d.seq].aps_score,
   rad.aps_yesterday = request->reclist[d.seq].aps_yesterday, rad.bilirubin_ce_id = request->reclist[
   d.seq].bilirubin_ce_id, rad.bun_ce_id = request->reclist[d.seq].bun_ce_id,
   rad.cc_beg_dt_tm = cnvtdatetime(request->reclist[d.seq].cc_beg_dt_tm), rad.cc_day = request->
   reclist[d.seq].cc_day, rad.cc_end_dt_tm = cnvtdatetime(request->reclist[d.seq].cc_end_dt_tm),
   rad.creatinine_ce_id = request->reclist[d.seq].creatinine_ce_id, rad.eyes_ce_id = request->
   reclist[d.seq].eyes_ce_id, rad.fio2_ce_id = request->reclist[d.seq].fio2_ce_id,
   rad.glucose_ce_id = request->reclist[d.seq].glucose_ce_id, rad.heartrate_ce_id = request->reclist[
   d.seq].heartrate_ce_id, rad.hematocrit_ce_id = request->reclist[d.seq].hematocrit_ce_id,
   rad.intubated_ce_id = request->reclist[d.seq].intubated_ce_id, rad.intubated_ind = request->
   reclist[d.seq].intubated_ind, rad.mean_blood_pressure = request->reclist[d.seq].
   mean_blood_pressure,
   rad.meds_ce_id = request->reclist[d.seq].meds_ce_id, rad.meds_ind = request->reclist[d.seq].
   meds_ind, rad.motor_ce_id = request->reclist[d.seq].motor_ce_id,
   rad.outcome_status = request->reclist[d.seq].outcome_status, rad.pao2_ce_id = request->reclist[d
   .seq].pao2_ce_id, rad.pa_line_today_ind = request->reclist[d.seq].pa_line_today_ind,
   rad.pco2_ce_id = request->reclist[d.seq].pco2_ce_id, rad.phys_res_pts = request->reclist[d.seq].
   phys_res_pts, rad.ph_ce_id = request->reclist[d.seq].ph_ce_id,
   rad.potassium_ce_id = request->reclist[d.seq].potassium_ce_id, rad.resp_ce_id = request->reclist[d
   .seq].resp_ce_id, rad.risk_adjustment_id = request->reclist[d.seq].risk_adjustment_id,
   rad.risk_adjustment_day_id = request->reclist[d.seq].risk_adjustment_day_id, rad.sodium_ce_id =
   request->reclist[d.seq].sodium_ce_id, rad.temp_ce_id = request->reclist[d.seq].temp_ce_id,
   rad.urine_24hr_output = request->reclist[d.seq].urine_24hr_output, rad.urine_output = request->
   reclist[d.seq].urine_output, rad.vent_ind = request->reclist[d.seq].vent_ind,
   rad.vent_today_ind = request->reclist[d.seq].vent_today_ind, rad.verbal_ce_id = request->reclist[d
   .seq].verbal_ce_id, rad.wbc_ce_id = request->reclist[d.seq].wbc_ce_id,
   rad.worst_albumin_result = request->reclist[d.seq].worst_albumin_result, rad
   .worst_bilirubin_result = request->reclist[d.seq].worst_bilirubin_result, rad.worst_bun_result =
   request->reclist[d.seq].worst_bun_result,
   rad.worst_creatinine_result = request->reclist[d.seq].worst_creatinine_result, rad
   .worst_fio2_result = request->reclist[d.seq].worst_fio2_result, rad.worst_gcs_eye_score = request
   ->reclist[d.seq].worst_gcs_eye_score,
   rad.worst_gcs_motor_score = request->reclist[d.seq].worst_gcs_motor_score, rad
   .worst_gcs_verbal_score = request->reclist[d.seq].worst_gcs_verbal_score, rad.worst_glucose_result
    = request->reclist[d.seq].worst_glucose_result,
   rad.worst_heart_rate = request->reclist[d.seq].worst_heart_rate, rad.worst_hematocrit = request->
   reclist[d.seq].worst_hematocrit, rad.worst_pao2_result = request->reclist[d.seq].worst_pao2_result,
   rad.worst_pco2_result = request->reclist[d.seq].worst_pco2_result, rad.worst_ph_result = request->
   reclist[d.seq].worst_ph_result, rad.worst_potassium_result = request->reclist[d.seq].
   worst_potassium_result,
   rad.worst_resp_result = request->reclist[d.seq].worst_resp_result, rad.worst_sodium_result =
   request->reclist[d.seq].worst_sodium_result, rad.worst_temp = request->reclist[d.seq].worst_temp,
   rad.worst_wbc_result = request->reclist[d.seq].worst_wbc_result, rad.active_ind = 1, rad
   .active_status_cd = reqdata->active_status_cd,
   rad.active_status_dt_tm = cnvtdatetime(curdate,curtime3), rad.active_status_prsnl_id = reqinfo->
   updt_id, rad.valid_from_dt_tm = cnvtdatetime(request->reclist[d.seq].valid_from_dt_tm),
   rad.valid_until_dt_tm = cnvtdatetime(request->reclist[d.seq].valid_until_dt_tm), rad.updt_dt_tm =
   cnvtdatetime(curdate,curtime3), rad.updt_cnt = 0,
   rad.updt_id = reqinfo->updt_id, rad.updt_task = reqinfo->updt_task, rad.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d)
   JOIN (rad)
  WITH nocounter
 ;end insert
 CALL echo(build("curqual = ",curqual))
 IF (curqual=req_size)
  SET reply->status_data.status = "S"
  SET stat = alterlist(reply->reclist,curqual)
  FOR (i = 1 TO req_size)
   SET reply->reclist[i].risk_adjustment_day_id = request->reclist[i].risk_adjustment_day_id
   SET reply->reclist[i].risk_adjustment_id = request->reclist[i].risk_adjustment_id
  ENDFOR
  SET failure = "S"
 ENDIF
#exit_script
 IF (failure="F")
  SET reply->status_data.status = "F"
  SET stat = alterlist(reply->reclist,0)
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
