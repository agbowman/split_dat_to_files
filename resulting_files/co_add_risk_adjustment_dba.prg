CREATE PROGRAM co_add_risk_adjustment:dba
 RECORD reply(
   1 reclist[*]
     2 risk_adjustment_id = f8
     2 encntr_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET serrmsg = fillstring(132," ")
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
 CALL echorecord(request)
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
  SET reply->status_data.subeventstatus[1].targetobjectname = "co_add_risk_adjustment"
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
   SET request->reclist[n].risk_adjustment_id = t_sequences->qual[n].seq_id
 ENDFOR
 INSERT  FROM risk_adjustment ra,
   (dummyt d  WITH seq = value(req_size))
  SET ra.admitsource_flag = request->reclist[d.seq].admitsource_flag, ra.admit_age = request->
   reclist[d.seq].admit_age, ra.admit_diagnosis = request->reclist[d.seq].admit_diagnosis,
   ra.admit_icu_cd = request->reclist[d.seq].admit_icu_cd, ra.admit_source = request->reclist[d.seq].
   admit_source, ra.adm_doc_id = request->reclist[d.seq].adm_doc_id,
   ra.aids_ind = request->reclist[d.seq].aids_ind, ra.ami_location = request->reclist[d.seq].
   ami_location, ra.bed_count = request->reclist[d.seq].bed_count,
   ra.body_system = request->reclist[d.seq].body_system, ra.cc_during_stay_ind = request->reclist[d
   .seq].cc_during_stay_ind, ra.chronic_health_none_ind = request->reclist[d.seq].
   chronic_health_none_ind,
   ra.chronic_health_unavail_ind = request->reclist[d.seq].chronic_health_unavail_ind, ra
   .cirrhosis_ind = request->reclist[d.seq].cirrhosis_ind, ra.copd_flag = request->reclist[d.seq].
   copd_flag,
   ra.copd_ind = request->reclist[d.seq].copd_ind, ra.diabetes_ind = request->reclist[d.seq].
   diabetes_ind, ra.dialysis_ind = request->reclist[d.seq].dialysis_ind,
   ra.diedinhospital_ind = request->reclist[d.seq].diedinhospital_ind, ra.diedinicu_ind = request->
   reclist[d.seq].diedinicu_ind, ra.discharge_location_cd = request->reclist[d.seq].
   discharge_location_cd,
   ra.disease_category_cd = request->reclist[d.seq].disease_category_cd, ra.ejectfx_fraction =
   request->reclist[d.seq].ejectfx_fraction, ra.electivesurgery_ind = request->reclist[d.seq].
   electivesurgery_ind,
   ra.encntr_id = request->reclist[d.seq].encntr_id, ra.gender_flag = request->reclist[d.seq].
   gender_flag, ra.hepaticfailure_ind = request->reclist[d.seq].hepaticfailure_ind,
   ra.hosp_admit_dt_tm = cnvtdatetime(request->reclist[d.seq].hosp_admit_dt_tm), ra.hrs_at_source =
   request->reclist[d.seq].hrs_at_source, ra.icu_admit_dt_tm = cnvtdatetime(request->reclist[d.seq].
    icu_admit_dt_tm),
   ra.icu_disch_dt_tm = cnvtdatetime(request->reclist[d.seq].icu_disch_dt_tm), ra.ima_ind = request->
   reclist[d.seq].ima_ind, ra.immunosuppression_ind = request->reclist[d.seq].immunosuppression_ind,
   ra.leukemia_ind = request->reclist[d.seq].leukemia_ind, ra.lymphoma_ind = request->reclist[d.seq].
   lymphoma_ind, ra.med_service_cd = request->reclist[d.seq].med_service_cd,
   ra.metastaticcancer_ind = request->reclist[d.seq].metastaticcancer_ind, ra.midur_ind = request->
   reclist[d.seq].midur_ind, ra.mi_within_6mo_ind = request->reclist[d.seq].mi_within_6mo_ind,
   ra.nbr_grafts_performed = request->reclist[d.seq].nbr_grafts_performed, ra.person_id = request->
   reclist[d.seq].person_id, ra.ptca_device = request->reclist[d.seq].ptca_device,
   ra.readmit_ind = request->reclist[d.seq].readmit_ind, ra.readmit_within_24hr_ind = request->
   reclist[d.seq].readmit_within_24hr_ind, ra.region_flag = request->reclist[d.seq].region_flag,
   ra.risk_adjustment_id = request->reclist[d.seq].risk_adjustment_id, ra.sv_graft_ind = request->
   reclist[d.seq].sv_graft_ind, ra.teach_type_flag = request->reclist[d.seq].teach_type_flag,
   ra.therapy_level = request->reclist[d.seq].therapy_level, ra.thrombolytics_ind = request->reclist[
   d.seq].thrombolytics_ind, ra.xfer_within_48hr_ind = request->reclist[d.seq].xfer_within_48hr_ind,
   ra.var03hspxlos_value = request->reclist[d.seq].var03hspxlos_value, ra.active_ind = 1, ra
   .active_status_cd = reqdata->active_status_cd,
   ra.active_status_dt_tm = cnvtdatetime(curdate,curtime3), ra.active_status_prsnl_id = reqinfo->
   updt_id, ra.valid_from_dt_tm = cnvtdatetime(request->reclist[d.seq].valid_from_dt_tm),
   ra.valid_until_dt_tm = cnvtdatetime(request->reclist[d.seq].valid_until_dt_tm), ra.updt_dt_tm =
   cnvtdatetime(curdate,curtime3), ra.updt_cnt = 0,
   ra.updt_id = reqinfo->updt_id, ra.updt_task = reqinfo->updt_task, ra.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d)
   JOIN (ra)
  WITH nocounter
 ;end insert
 CALL echo(build("curqual = ",curqual))
 IF (curqual=req_size)
  SET reply->status_data.status = "S"
  SET stat = alterlist(reply->reclist,curqual)
  FOR (i = 1 TO req_size)
   SET reply->reclist[i].risk_adjustment_id = request->reclist[i].risk_adjustment_id
   SET reply->reclist[i].encntr_id = request->reclist[i].encntr_id
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
