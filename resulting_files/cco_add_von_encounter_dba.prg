CREATE PROGRAM cco_add_von_encounter:dba
 RECORD reply(
   1 cco_encntr_id = f8
   1 network_id = f8
   1 person_id = f8
   1 encntr_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE fail_string = vc WITH noconstant(fillstring(200," ")), protect
 DECLARE success_flag = c1 WITH noconstant("N"), protect
 DECLARE new_seq_id = f8 WITH noconstant(0.0), protect
 DECLARE new_network_id = f8 WITH noconstant(0.0), protect
 DECLARE von_app_cd = f8 WITH noconstant(0.0), protect
 DECLARE initialize(junk) = null WITH protect
 DECLARE get_next_network_id(junk) = f8 WITH protect
 DECLARE get_next_seq_id(junk) = f8 WITH protect
 DECLARE insert_new_encounter(p_seq_id,p_person_id,p_encntr_id,p_network_id) = c1 WITH protect
 DECLARE meaning_code(mc_codeset,mc_meaning) = f8 WITH protect
 CALL initialize("")
 SET new_network_id = get_next_network_id("")
 IF (new_network_id > 0.0)
  SET new_seq_id = get_next_seq_id("")
  IF (new_seq_id > 0.0)
   CALL insert_new_encounter(new_seq_id,request->person_id,request->encntr_id,new_network_id)
  ELSE
   CALL echo("new_seq_id !> 0.0")
  ENDIF
 ENDIF
 IF (success_flag="N")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = fail_string
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  SET reply->cco_encntr_id = new_seq_id
  SET reply->encntr_id = request->encntr_id
  SET reply->person_id = request->person_id
  SET reply->network_id = new_network_id
 ENDIF
 CALL echorecord(reply)
 SUBROUTINE initialize(junk)
   SET success_flag = "N"
   SET fail_string = "UNABLE TO WRITE/UPDATE VON INFORMATION"
   SET reply->cco_encntr_id = - (1.0)
   SET reply->network_id = - (1.0)
   SET reply->person_id = - (1.0)
   SET reply->encntr_id = - (1.0)
   SET von_app_cd = meaning_code(400700,"VON")
 END ;Subroutine
 SUBROUTINE meaning_code(mc_codeset,mc_meaning)
   SET mc_code = 0.0
   SET mc_text = fillstring(12," ")
   SET mc_text = mc_meaning
   SET mc_stat = uar_get_meaning_by_codeset(mc_codeset,nullterm(mc_text),1,mc_code)
   IF (mc_code > 0.0)
    RETURN(mc_code)
   ELSE
    RETURN(- (1.0))
   ENDIF
 END ;Subroutine
 SUBROUTINE get_next_network_id(junk)
   DECLARE next_network_id = f8 WITH noconstant(0.0), protect
   DECLARE last_network_id = f8 WITH noconstant(0.0), protect
   SELECT INTO "nl:"
    coe.patient_identifier
    FROM cco_encounter coe
    WHERE coe.patient_identifier > 0.0
     AND coe.active_ind=1
    ORDER BY coe.patient_identifier DESC
    DETAIL
     last_network_id = coe.patient_identifier
    WITH maxrec = 1
   ;end select
   IF (last_network_id >= 0.0)
    SET next_network_id = (last_network_id+ 1)
   ELSE
    SET next_network_id = 1.0
   ENDIF
   RETURN(next_network_id)
 END ;Subroutine
 SUBROUTINE get_next_seq_id(junk)
   DECLARE next_seq_id = f8 WITH noconstant(0.0), protect
   SELECT INTO "nl:"
    j = seq(carenet_seq,nextval)
    FROM dual
    DETAIL
     next_seq_id = cnvtreal(j)
    WITH format, nocounter
   ;end select
   RETURN(next_seq_id)
 END ;Subroutine
 SUBROUTINE insert_new_encounter(p_seq_id,p_person_id,p_encntr_id,p_network_id)
   INSERT  FROM cco_encounter coe
    SET coe.cco_encounter_id = p_seq_id, coe.cco_source_app_cd = von_app_cd, coe.patient_identifier
      = p_network_id,
     coe.encntr_id = p_encntr_id, coe.person_id = p_person_id, coe.icu_disch_dt_tm = cnvtdatetime(
      "31-DEC-2100 00:00"),
     coe.final_disposition_flag = - (1), coe.diedinicu_ind = - (1), coe.extract_flag = 0,
     coe.final_disposition_flag = - (1), coe.final_disch_dt_tm = cnvtdatetime("31-DEC-2100 00:00"),
     coe.initial_disch_dt_tm = cnvtdatetime("31-DEC-2100 00:00"),
     coe.readmission_disposition_flag = - (1), coe.record_status_flag = 0, coe.von_transfer_flag =
     - (1),
     coe.diedindelroom_ind = - (1), coe.gender_flag = - (1), coe.mothers_ethnicity = - (1),
     coe.mothers_race = - (1), coe.admitsource_flag = - (1), coe.admit_age = 0,
     coe.admit_diagnosis = 0, coe.admit_icu_cd = 0.0, coe.admit_source = - (1),
     coe.adm_doc_id = 0.0, coe.aids_ind = 0, coe.ami_location = 0,
     coe.bed_count = 0, coe.body_system = 0, coe.cc_during_stay_ind = - (1),
     coe.chronic_health_none_ind = - (1), coe.chronic_health_unavail_ind = - (1), coe.cirrhosis_ind
      = - (1),
     coe.copd_flag = - (1), coe.copd_ind = - (1), coe.diabetes_ind = - (1),
     coe.dialysis_ind = - (1), coe.diedinhospital_ind = - (1), coe.diedinicu_ind = - (1),
     coe.disease_category_cd = 0.0, coe.ejectfx_fraction = - (1), coe.hepaticfailure_ind = - (1),
     coe.hrs_at_source = - (1), coe.ima_ind = - (1), coe.immunosuppression_ind = - (1),
     coe.leukemia_ind = - (1), coe.lymphoma_ind = - (1), coe.med_service_cd = 0.0,
     coe.metastaticcancer_ind = - (1), coe.midur_ind = - (1), coe.mi_within_6mo_ind = - (1),
     coe.nbr_grafts_performed = - (1), coe.ptca_device = - (1), coe.readmit_ind = - (1),
     coe.readmit_within_24hr_ind = - (1), coe.region_flag = - (1), coe.sv_graft_ind = - (1),
     coe.teach_type_flag = - (1), coe.therapy_level = - (1), coe.thrombolytics_ind = - (1),
     coe.valid_from_dt_tm = cnvtdatetime(curdate,curtime3), coe.valid_until_dt_tm = cnvtdatetime(
      "31-DEC-2100 00:00"), coe.var03hspxlos_value = 0,
     coe.xfer_within_48hr_ind = - (1), coe.active_ind = 1, coe.active_status_dt_tm = cnvtdatetime(
      curdate,curtime3),
     coe.active_status_prsnl_id = reqinfo->updt_id, coe.active_status_cd = reqdata->active_status_cd,
     coe.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     coe.updt_id = reqinfo->updt_id, coe.updt_task = reqinfo->updt_task, coe.updt_applctx = reqinfo->
     updt_applctx,
     coe.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET success_flag = "N"
    SET fail_string = "ERROR WRITING CCO_ENCOUNTER ROW."
   ELSE
    SET success_flag = "Y"
   ENDIF
   RETURN(success_flag)
 END ;Subroutine
END GO
