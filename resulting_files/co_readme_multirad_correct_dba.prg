CREATE PROGRAM co_readme_multirad_correct:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed:  Starting script dcp_readme_multirad_correct..."
 DECLARE errmsg = vc WITH public, noconstant(" ")
 DECLARE errcode = i4 WITH public, noconstant(0)
 FREE RECORD multirad_ra_recs_short
 RECORD multirad_ra_recs_short(
   1 list[*]
     2 risk_adjustment_id = f8
 )
 DECLARE index = i4 WITH noconstant(0)
 DECLARE size_multirad_ra_recs = i4 WITH noconstant(0)
 DECLARE chronic_health_ce_ind_exists = i2 WITH noconstant(0)
 DECLARE chronic_health_ce_ind = i2 WITH noconstant(0)
 SELECT INTO "nl:"
  rad.risk_adjustment_id
  FROM risk_adjustment ra,
   risk_adjustment_day rad,
   person p,
   encounter e
  PLAN (ra
   WHERE ra.active_ind=1
    AND ra.icu_disch_dt_tm <= cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (rad
   WHERE rad.risk_adjustment_id=ra.risk_adjustment_id
    AND rad.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=ra.encntr_id
    AND e.active_ind=1)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
  GROUP BY p.name_first, p.name_last, ra.encntr_id,
   rad.risk_adjustment_id, rad.cc_day
  HAVING count(*) > 1
  ORDER BY rad.risk_adjustment_id, rad.cc_day
  HEAD REPORT
   cnt = 0
  HEAD rad.risk_adjustment_id
   cnt = (cnt+ 1), stat = alterlist(multirad_ra_recs_short->list,cnt), multirad_ra_recs_short->list[
   cnt].risk_adjustment_id = rad.risk_adjustment_id
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,1)
 IF (errcode != 0)
  SET readme_data->status = "F"
  SET readme_data->message = errmsg
  GO TO exit_script
 ELSE
  SET readme_data->status = "S"
 ENDIF
 SET size_multirad_ra_recs = size(multirad_ra_recs_short->list,5)
 SELECT INTO "nl:"
  FROM user_tab_columns
  WHERE table_name="RISK_ADJUSTMENT"
   AND column_name="CHRONIC_HEALTH_CE_IND"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET chronic_health_ce_ind_exists = 2
 ENDIF
 SET errcode = error(errmsg,1)
 IF (errcode != 0)
  SET readme_data->status = "F"
  SET readme_data->message = errmsg
  GO TO exit_script
 ELSE
  SET readme_data->status = "S"
 ENDIF
 FOR (index = 1 TO size_multirad_ra_recs)
   FREE RECORD dcp_upd_risk_adjustment_rep
   RECORD dcp_upd_risk_adjustment_req(
     1 risk_adjustment_id = f8
     1 adm_data_changed_ind = i2
     1 person_id = f8
     1 encntr_id = f8
     1 dialysis_ind = i2
     1 admitsource_flag = i2
     1 icu_admit_dt_tm = dq8
     1 hosp_admit_dt_tm = dq8
     1 admission_icu = vc
     1 admission_icu_cd = f8
     1 med_service_cd = f8
     1 admitdiagnosis = vc
     1 thrombolytics_ind = i2
     1 aids_ind = i2
     1 hepaticfailure_ind = i2
     1 lymphoma_ind = i2
     1 metastaticcancer_ind = i2
     1 leukemia_ind = i2
     1 immunosuppression_ind = i2
     1 cirrhosis_ind = i2
     1 electivesurgery_ind = i2
     1 readmit_ind = i2
     1 ima_ind = i2
     1 midur_ind = i2
     1 ventday1_ind = i2
     1 oobventday1_ind = i2
     1 oobintubday1_ind = i2
     1 diabetes_ind = i2
     1 var03hspxlos = f8
     1 ejectfx = f8
     1 admit_source = vc
     1 body_system = vc
     1 xfer_within_48hr_ind = i2
     1 readmit_within_24hr_ind = i2
     1 ami_location = vc
     1 ptca_device = vc
     1 sv_graft_ind = i2
     1 mi_within_6mo_ind = i2
     1 cc_during_stay_ind = i2
     1 time_at_source = i4
     1 copd_flag = i2
     1 copd_ind = i2
     1 chronic_health_unavail_ind = i2
     1 chronic_health_none_ind = i2
     1 nbr_grafts_performed = i4
     1 adm_doc_id = f8
     1 risk_adjustment_day_id = f8
     1 daily_data_changed_ind = i2
     1 cc_day = i4
     1 cc_beg_dt_tm = dq8
     1 cc_end_dt_tm = dq8
     1 intubated_ind = i2
     1 vent_ind = i2
     1 eyes = i4
     1 motor = i4
     1 verbal = i4
     1 meds_ind = i2
     1 urine = f8
     1 urine_actual = f8
     1 wbc = f8
     1 wbc_ce_id = f8
     1 temp = f8
     1 temp_ce_id = f8
     1 resp = f8
     1 resp_ce_id = f8
     1 sodium = f8
     1 sodium_ce_id = f8
     1 heartrate = f8
     1 heartrate_ce_id = f8
     1 meanbp = f8
     1 ph = f8
     1 ph_ce_id = f8
     1 hematocrit = f8
     1 hematocrit_ce_id = f8
     1 creatinine = f8
     1 creatinine_ce_id = f8
     1 albumin = f8
     1 albumin_ce_id = f8
     1 pao2 = f8
     1 pao2_ce_id = f8
     1 pco2 = f8
     1 pco2_ce_id = f8
     1 bun = f8
     1 bun_ce_id = f8
     1 glucose = f8
     1 glucose_ce_id = f8
     1 bilirubin = f8
     1 bilirubin_ce_id = f8
     1 potassium = f8
     1 potassium_ce_id = f8
     1 fio2 = f8
     1 fio2_ce_id = f8
     1 activetx_ind = i2
     1 vent_today_ind = i2
     1 pa_line_today_ind = i2
     1 disch_data_changed_ind = i2
     1 icu_disch_dt_tm = dq8
     1 diedinhospital_ind = i2
     1 diedinicu_ind = i2
     1 event_data_changed_ind = i2
     1 discharge_location_cd = f8
     1 selist[*]
       2 risk_adjustment_event_id = f8
       2 sentinel_event_category_cd = f8
       2 beg_effective_dt_tm = dq8
       2 end_effective_dt_tm = dq8
       2 sentinel_event_code_cd = f8
       2 sentinel_event_unit = f8
       2 preventable_ind = i2
       2 consequential_ind = i2
       2 sentinel_event_comment = vc
     1 tiss_data_changed_ind = i2
     1 tisslist[*]
       2 risk_adj_tiss_id = f8
       2 beg_effective_dt_tm = dq8
       2 end_effective_dt_tm = dq8
       2 tiss_meaning = vc
     1 carry_over_flags = i4
   )
   FREE RECORD dcp_upd_risk_adjustment_rep
   RECORD dcp_upd_risk_adjustment_rep(
     1 risk_adjustment_id = f8
     1 risk_adjustment_day_id = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = vc
         3 operationstatus = c1
         3 targetobjectname = vc
         3 targetobjectvalue = vc
   )
   SELECT INTO "nl:"
    FROM risk_adjustment ra,
     code_value cv
    PLAN (ra
     WHERE (ra.risk_adjustment_id=multirad_ra_recs_short->list[index].risk_adjustment_id))
     JOIN (cv
     WHERE cv.code_value=ra.admit_icu_cd)
    DETAIL
     dcp_upd_risk_adjustment_req->risk_adjustment_id = ra.risk_adjustment_id,
     dcp_upd_risk_adjustment_req->adm_data_changed_ind = 1, dcp_upd_risk_adjustment_req->person_id =
     ra.person_id,
     dcp_upd_risk_adjustment_req->encntr_id = ra.encntr_id, dcp_upd_risk_adjustment_req->dialysis_ind
      = ra.dialysis_ind, dcp_upd_risk_adjustment_req->admitsource_flag = ra.admitsource_flag,
     dcp_upd_risk_adjustment_req->icu_admit_dt_tm = cnvtdatetime(ra.icu_admit_dt_tm),
     dcp_upd_risk_adjustment_req->icu_disch_dt_tm = cnvtdatetime(ra.icu_disch_dt_tm),
     dcp_upd_risk_adjustment_req->hosp_admit_dt_tm = cnvtdatetime(ra.hosp_admit_dt_tm),
     dcp_upd_risk_adjustment_req->admission_icu = cv.display, dcp_upd_risk_adjustment_req->
     admission_icu_cd = ra.admit_icu_cd, dcp_upd_risk_adjustment_req->med_service_cd = ra
     .med_service_cd,
     dcp_upd_risk_adjustment_req->admitdiagnosis = ra.admit_diagnosis, dcp_upd_risk_adjustment_req->
     thrombolytics_ind = ra.thrombolytics_ind, dcp_upd_risk_adjustment_req->aids_ind = ra.aids_ind,
     dcp_upd_risk_adjustment_req->hepaticfailure_ind = ra.hepaticfailure_ind,
     dcp_upd_risk_adjustment_req->lymphoma_ind = ra.lymphoma_ind, dcp_upd_risk_adjustment_req->
     metastaticcancer_ind = ra.metastaticcancer_ind,
     dcp_upd_risk_adjustment_req->leukemia_ind = ra.leukemia_ind, dcp_upd_risk_adjustment_req->
     immunosuppression_ind = ra.immunosuppression_ind, dcp_upd_risk_adjustment_req->cirrhosis_ind =
     ra.cirrhosis_ind,
     dcp_upd_risk_adjustment_req->electivesurgery_ind = ra.electivesurgery_ind,
     dcp_upd_risk_adjustment_req->readmit_ind = ra.readmit_ind, dcp_upd_risk_adjustment_req->ima_ind
      = ra.ima_ind,
     dcp_upd_risk_adjustment_req->midur_ind = ra.midur_ind, dcp_upd_risk_adjustment_req->diabetes_ind
      = ra.diabetes_ind, dcp_upd_risk_adjustment_req->var03hspxlos = ra.var03hspxlos_value,
     dcp_upd_risk_adjustment_req->ejectfx = ra.ejectfx_fraction, dcp_upd_risk_adjustment_req->
     admit_source = ra.admit_source, dcp_upd_risk_adjustment_req->body_system = ra.body_system,
     dcp_upd_risk_adjustment_req->xfer_within_48hr_ind = ra.xfer_within_48hr_ind,
     dcp_upd_risk_adjustment_req->readmit_within_24hr_ind = ra.readmit_within_24hr_ind,
     dcp_upd_risk_adjustment_req->ami_location = ra.ami_location,
     dcp_upd_risk_adjustment_req->ptca_device = ra.ptca_device, dcp_upd_risk_adjustment_req->
     sv_graft_ind = ra.sv_graft_ind, dcp_upd_risk_adjustment_req->mi_within_6mo_ind = ra
     .mi_within_6mo_ind,
     dcp_upd_risk_adjustment_req->cc_during_stay_ind = ra.cc_during_stay_ind,
     dcp_upd_risk_adjustment_req->time_at_source = ra.hrs_at_source, dcp_upd_risk_adjustment_req->
     copd_flag = ra.copd_flag,
     dcp_upd_risk_adjustment_req->copd_ind = ra.copd_ind, dcp_upd_risk_adjustment_req->
     chronic_health_unavail_ind = ra.chronic_health_unavail_ind, dcp_upd_risk_adjustment_req->
     chronic_health_none_ind = ra.chronic_health_none_ind,
     dcp_upd_risk_adjustment_req->nbr_grafts_performed = ra.nbr_grafts_performed,
     dcp_upd_risk_adjustment_req->adm_doc_id = ra.adm_doc_id, dcp_upd_risk_adjustment_req->
     diedinhospital_ind = ra.diedinhospital_ind,
     dcp_upd_risk_adjustment_req->diedinicu_ind = ra.diedinicu_ind, dcp_upd_risk_adjustment_req->
     discharge_location_cd = ra.discharge_location_cd
    WITH nocounter
   ;end select
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    SET readme_data->status = "F"
    SET readme_data->message = errmsg
    GO TO exit_script
   ELSE
    SET readme_data->status = "S"
   ENDIF
   EXECUTE dcp_upd_risk_adjustment  WITH replace("REQUEST","DCP_UPD_RISK_ADJUSTMENT_REQ"), replace(
    "REPLY","DCP_UPD_RISK_ADJUSTMENT_REP")
   IF ((dcp_upd_risk_adjustment_rep->status_data.status != "S"))
    SET readme_data->status = "F"
    SET readme_data->message = "Error updating: dcp_upd_risk_adjustment"
    GO TO exit_script
   ELSE
    IF (chronic_health_ce_ind_exists=2)
     SET chronic_health_ce_ind = 0
     SELECT INTO "nl:"
      FROM risk_adjustment ra
      WHERE (ra.risk_adjustment_id=dcp_upd_risk_adjustment_req->risk_adjustment_id)
      DETAIL
       chronic_health_ce_ind = ra.chronic_health_ce_ind
      WITH nocounter
     ;end select
     SET errcode = error(errmsg,1)
     IF (errcode != 0)
      SET readme_data->status = "F"
      SET readme_data->message = errmsg
      GO TO exit_script
     ENDIF
     UPDATE  FROM risk_adjustment ra
      SET ra.chronic_health_ce_ind = chronic_health_ce_ind, ra.updt_dt_tm = cnvtdatetime(curdate,
        curtime3), ra.updt_cnt = (ra.updt_cnt+ 1),
       ra.updt_id = reqinfo->updt_id, ra.updt_task = reqinfo->updt_task, ra.updt_applctx = reqinfo->
       updt_applctx
      WHERE (ra.risk_adjustment_id=dcp_upd_risk_adjustment_rep->risk_adjustment_id)
      WITH nocounter
     ;end update
     SET errcode = error(errmsg,1)
     IF (errcode != 0)
      SET readme_data->status = "F"
      SET readme_data->message = errmsg
      GO TO exit_script
     ELSE
      SET readme_data->status = "S"
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF ((readme_data->status="S"))
  SET readme_data->message = "Readme succeeded"
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
