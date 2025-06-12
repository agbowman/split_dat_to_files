CREATE PROGRAM cco_upd_von_data:dba
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
 DECLARE temp_mom_name = vc WITH noconstant(fillstring(30," ")), protect
 DECLARE temp_reg_dt_tm = q8
 DECLARE next_network_id = f8 WITH noconstant(0.0), public
 DECLARE event_count = i4 WITH noconstant(0), protect
 DECLARE birth_defect_event_cd = f8 WITH noconstant(- (1.0)), protect
 DECLARE bad_cki_cnt = i2 WITH noconstant(0), protect
 DECLARE bad_cki_string = vc WITH noconstant(fillstring(600," ")), protect
 DECLARE last_rec_status_flag = i2 WITH noconstant(- (1)), protect
 DECLARE last_extract_status_flag = i2 WITH noconstant(- (1)), protect
 DECLARE new_rec_status_flag = i2 WITH noconstant(- (1)), protect
 DECLARE new_extract_status_flag = i2 WITH noconstant(- (1)), protect
 DECLARE last_extract_dt_tm = q8
 RECORD coe_data(
   1 record_status_flag = i2
   1 gender_flag = i2
   1 final_disposition_flag = i2
   1 readmission_disposition_flag = i2
   1 diedinicu_ind = i2
   1 von_transfer_flag = i2
   1 mothers_name = vc
   1 mothers_ethnicity = i2
   1 mothers_race = i2
   1 hosp_admit_dt_tm = dq8
   1 icu_admit_dt_tm = dq8
   1 final_disch_dt_tm = dq8
   1 initial_disch_dt_tm = dq8
   1 diedindelroom_ind = i2
   1 cco_source_app_cd = f8
   1 patient_identifier = f8
   1 encntr_id = f8
   1 person_id = f8
 )
 DECLARE eval_special_event(p_event_string,_event_pos,p_event_cd,p_loop_size) = c1 WITH protect
 DECLARE eval_birth_defects(p_event_string,_event_pos,p_event_cd,p_loop_size) = c1 WITH protect
 DECLARE initialize(p1) = null WITH protect
 DECLARE get_cco_record(p1) = c WITH protect
 DECLARE update_cco_encntr(p1) = c WITH protect
 DECLARE prepare_event_list(p1) = c WITH protect
 DECLARE check_cco_event(p1,p2) = f8 WITH protect
 DECLARE insert_cco_event(p1,p2,p3,p4,p5,
  p6) = f8 WITH protect
 DECLARE update_cco_event(p1,p2,p3) = c WITH protect
 DECLARE get_splice_section(p_string,spot) = vc WITH protect
 DECLARE write_birth_defect_long_text(p1) = c WITH protect
 DECLARE meaning_code(p1,p1) = f8 WITH protect
 DECLARE insert_new_cco_encntr(p1) = c WITH protect
 DECLARE resolve_status_flags(p_rec_status_flag) = null WITH protect
 CALL initialize("")
 IF (get_cco_record("")="Y")
  CALL resolve_status_flags(request->record_status_flag)
  CALL update_cco_encntr("")
  IF (success_flag="Y")
   CALL prepare_event_list("")
  ENDIF
 ENDIF
 IF (success_flag="N")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = fail_string
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSEIF (bad_cki_cnt > 0)
  SET reply->status_data.subeventstatus[1].targetobjectvalue = bad_cki_string
  SET reply->status_data.status = "P"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Success"
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
 GO TO 9999_exit_program
 SUBROUTINE initialize(junk)
   SET success_flag = "N"
   SET fail_string = "UNABLE TO WRITE/UPDATE VON INFORMATION"
   SET reply->cco_encntr_id = - (1.0)
   SET reply->network_id = - (1.0)
   SET reply->person_id = - (1.0)
   SET reply->encntr_id = - (1.0)
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
 SUBROUTINE resolve_status_flags(p_rec_status_flag)
  SET new_extract_status_flag = 0
  IF (last_extract_status_flag=1)
   IF (p_rec_status_flag IN (1, 2))
    SET new_rec_status_flag = 2
   ELSE
    SET new_rec_status_flag = 3
   ENDIF
  ELSE
   SET new_rec_status_flag = p_rec_status_flag
  ENDIF
 END ;Subroutine
 SUBROUTINE get_cco_record(p1)
  SELECT INTO "nl:"
   FROM cco_encounter coe,
    person p,
    encounter e
   PLAN (coe
    WHERE (coe.cco_encounter_id=request->cco_encntr_id)
     AND coe.active_ind=1)
    JOIN (p
    WHERE p.person_id=coe.person_id
     AND p.active_ind=1)
    JOIN (e
    WHERE e.encntr_id=coe.encntr_id
     AND e.active_ind=1)
   DETAIL
    reply->cco_encntr_id = coe.cco_encounter_id, reply->person_id = coe.person_id, reply->encntr_id
     = coe.encntr_id,
    reply->network_id = coe.patient_identifier, last_rec_status_flag = coe.record_status_flag,
    last_extract_status_flag = coe.extract_flag,
    last_extract_dt_tm = coe.extract_dt_tm, coe_data->record_status_flag = coe.record_status_flag,
    coe_data->gender_flag = coe.gender_flag,
    coe_data->final_disposition_flag = coe.final_disposition_flag, coe_data->
    readmission_disposition_flag = coe.readmission_disposition_flag, coe_data->diedinicu_ind = coe
    .diedinicu_ind,
    coe_data->von_transfer_flag = coe.von_transfer_flag, coe_data->mothers_name = coe.mothers_name,
    coe_data->mothers_ethnicity = coe.mothers_ethnicity,
    coe_data->mothers_race = coe.mothers_race, coe_data->hosp_admit_dt_tm = cnvtdatetime(coe
     .hosp_admit_dt_tm), coe_data->icu_admit_dt_tm = cnvtdatetime(coe.icu_admit_dt_tm),
    coe_data->final_disch_dt_tm = cnvtdatetime(coe.final_disch_dt_tm), coe_data->initial_disch_dt_tm
     = cnvtdatetime(coe.initial_disch_dt_tm), coe_data->diedindelroom_ind = coe.diedindelroom_ind,
    coe_data->cco_source_app_cd = coe.cco_source_app_cd, coe_data->patient_identifier = coe
    .patient_identifier, coe_data->encntr_id = coe.encntr_id,
    coe_data->person_id = coe.person_id
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL echo("UNABLE TO FIND COE RECORD")
   SET success_flag = "N"
   SET fail_string = "UNABLE TO LOCATE EXISTING CCO_ENCOUNTER RECORD"
   RETURN("N")
  ELSE
   SET success_flag = "Y"
   RETURN("Y")
  ENDIF
 END ;Subroutine
 SUBROUTINE insert_new_cco_encntr("")
   DECLARE new_seq_id = f8 WITH noconstant(0.0), protect
   SELECT INTO "nl:"
    j = seq(carenet_seq,nextval)
    FROM dual
    DETAIL
     new_seq_id = cnvtreal(j),
     CALL echo(build("IN DETAIL,j=",j,"new_seq_id=",new_seq_id))
    WITH format, nocounter
   ;end select
   IF (new_seq_id <= 0.0)
    SET fail_string = "UNABLE TO GET NEW ID FROM CARENET SEQUENCE"
    SET success_flag = "N"
   ELSE
    INSERT  FROM cco_encounter coe
     SET coe.cco_encounter_id = new_seq_id, coe.active_ind = 1, coe.record_status_flag =
      new_rec_status_flag,
      coe.extract_flag = new_extract_status_flag, coe.extract_dt_tm = last_extract_dt_tm, coe
      .gender_flag = request->sex_ind,
      coe.final_disposition_flag = request->ultimate_disposition_flag, coe
      .readmission_disposition_flag = request->disp_after_readmit_flag, coe.diedinicu_ind = request->
      diedwithin_12hours_ind,
      coe.von_transfer_flag = request->von_transfer_ind, coe.mothers_name = request->mother_name, coe
      .mothers_ethnicity = request->maternal_ethnicity_flag,
      coe.mothers_race = request->maternal_race_flag, coe.hosp_admit_dt_tm = cnvtdatetime(request->
       hosp_admit_dt_tm), coe.icu_admit_dt_tm = cnvtdatetime(request->hosp_admit_dt_tm),
      coe.final_disch_dt_tm = cnvtdatetime(request->discharge_final_dt_tm), coe.initial_disch_dt_tm
       = cnvtdatetime(request->discharge_initial_dt_tm), coe.diedindelroom_ind = request->
      died_in_delivery_ind,
      coe.cco_source_app_cd = coe_data->cco_source_app_cd, coe.patient_identifier = coe_data->
      patient_identifier, coe.encntr_id = coe_data->encntr_id,
      coe.person_id = coe_data->person_id, coe.icu_disch_dt_tm = cnvtdatetime("31-DEC-2100 00:00"),
      coe.admitsource_flag = - (1),
      coe.admit_age = 0, coe.admit_diagnosis = 0, coe.admit_icu_cd = 0.0,
      coe.admit_source = - (1), coe.adm_doc_id = 0.0, coe.aids_ind = 0,
      coe.ami_location = 0, coe.bed_count = 0, coe.body_system = 0,
      coe.cc_during_stay_ind = - (1), coe.chronic_health_none_ind = - (1), coe
      .chronic_health_unavail_ind = - (1),
      coe.cirrhosis_ind = - (1), coe.copd_flag = - (1), coe.copd_ind = - (1),
      coe.diabetes_ind = - (1), coe.dialysis_ind = - (1), coe.diedinhospital_ind = - (1),
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
      coe.updt_id = reqinfo->updt_id, coe.updt_task = reqinfo->updt_task, coe.updt_applctx = reqinfo
      ->updt_applctx,
      coe.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL echo("INSERT NEW ROW FAILED TO SAVE")
     SET fail_string = "ERROR CREATING NEW CCO_ENCNTR RECORD"
     SET success_falg = "N"
    ELSE
     SET success_flag = "Y"
     UPDATE  FROM cco_encounter coe
      SET coe.active_ind = 0, coe.updt_dt_tm = cnvtdatetime(curdate,curtime3), coe.updt_id = reqinfo
       ->updt_id,
       coe.updt_task = reqinfo->updt_task, coe.updt_applctx = reqinfo->updt_applctx, coe.updt_cnt = (
       coe.updt_cnt+ 1)
      WHERE (coe.cco_encounter_id=request->cco_encntr_id)
       AND coe.active_ind=1
      WITH nocounter
     ;end update
     IF (curqual=0)
      CALL echo("ERROR INACTIVATING OLD CCO_ENCOUNTER TABLE RECORD")
      SET fail_string = "ERROR INACTIVATING OLD CCO_ENCOUNTER TABLE RECORD"
      SET success_flag = "N"
     ENDIF
    ENDIF
   ENDIF
   RETURN(value(success_flag))
 END ;Subroutine
 SUBROUTINE update_cco_encntr(p1)
   UPDATE  FROM cco_encounter coe
    SET coe.record_status_flag = new_rec_status_flag, coe.extract_flag = new_extract_status_flag, coe
     .gender_flag = request->sex_ind,
     coe.final_disposition_flag = request->ultimate_disposition_flag, coe
     .readmission_disposition_flag = request->disp_after_readmit_flag, coe.diedinicu_ind = request->
     diedwithin_12hours_ind,
     coe.von_transfer_flag = request->von_transfer_ind, coe.mothers_name = request->mother_name, coe
     .mothers_ethnicity = request->maternal_ethnicity_flag,
     coe.mothers_race = request->maternal_race_flag, coe.hosp_admit_dt_tm = cnvtdatetime(request->
      hosp_admit_dt_tm), coe.icu_admit_dt_tm = cnvtdatetime(request->hosp_admit_dt_tm),
     coe.final_disch_dt_tm = cnvtdatetime(request->discharge_final_dt_tm), coe.initial_disch_dt_tm =
     cnvtdatetime(request->discharge_initial_dt_tm), coe.diedindelroom_ind = request->
     died_in_delivery_ind,
     coe.updt_dt_tm = cnvtdatetime(curdate,curtime3), coe.updt_id = reqinfo->updt_id, coe.updt_task
      = reqinfo->updt_task,
     coe.updt_applctx = reqinfo->updt_applctx, coe.updt_cnt = (coe.updt_cnt+ 1)
    WHERE (coe.cco_encounter_id=request->cco_encntr_id)
     AND coe.active_ind=1
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL echo("ERROR UPDATING CCO_ENCOUNTER TABLE")
    SET fail_string = "ERROR UPDATING CCO_ENCOUNTER TABLE"
    SET success_flag = "N"
   ELSE
    CALL echo("good update")
    SET success_flag = "Y"
   ENDIF
   RETURN(value(success_flag))
 END ;Subroutine
 SUBROUTINE prepare_event_list(p1)
   DECLARE cki_code_value = f8 WITH noconstant(0.0), private
   DECLARE list_size = i4 WITH noconstant(0), private
   DECLARE p_event_tag = vc WITH noconstant(fillstring(50," ")), private
   DECLARE p_found_event_id = f8 WITH noconstant(0.0), private
   DECLARE cki_loop_cnt = i2 WITH protect
   SET list_size = size(request->event_list,5)
   FOR (cki_loop_cnt = 1 TO list_size)
    SET cki_code_value = uar_get_code_by_cki(nullterm(request->event_list[cki_loop_cnt].cki))
    IF (cki_code_value > 0.0)
     IF ((request->event_list[cki_loop_cnt].cki="CKI.EC!8102"))
      CALL eval_special_event(request->event_list[cki_loop_cnt].stringvalue,cki_loop_cnt,
       cki_code_value,5)
     ELSEIF ((request->event_list[cki_loop_cnt].cki="MUL.ORD!d00777"))
      CALL eval_special_event(request->event_list[cki_loop_cnt].stringvalue,cki_loop_cnt,
       cki_code_value,3)
     ELSEIF ((request->event_list[cki_loop_cnt].cki="CKI.EC!8399"))
      CALL eval_birth_defects(request->event_list[cki_loop_cnt].stringvalue,cki_loop_cnt,
       cki_code_value,6)
     ELSEIF ((request->event_list[cki_loop_cnt].cki="CKI.EC!3333"))
      CALL eval_special_event(request->event_list[cki_loop_cnt].stringvalue,cki_loop_cnt,
       cki_code_value,3)
     ELSEIF ((request->event_list[cki_loop_cnt].cki="CKI.EC!8127"))
      CALL eval_special_event(request->event_list[cki_loop_cnt].stringvalue,cki_loop_cnt,
       cki_code_value,2)
     ELSEIF ((request->event_list[cki_loop_cnt].cki="CKI.EC!8381"))
      CALL eval_special_event(request->event_list[cki_loop_cnt].stringvalue,cki_loop_cnt,
       cki_code_value,4)
     ELSEIF ((request->event_list[cki_loop_cnt].cki="CKI.EC!4051"))
      CALL eval_special_event(request->event_list[cki_loop_cnt].stringvalue,cki_loop_cnt,
       cki_code_value,2)
     ELSE
      SET p_found_event_id = check_cco_event(reply->person_id,cki_code_value,1)
      IF ((request->event_list[cki_loop_cnt].datatype="VC"))
       SET p_event_tag = request->event_list[cki_loop_cnt].stringvalue
      ELSEIF ((request->event_list[cki_loop_cnt].datatype="DT"))
       SET p_event_tag = format(request->event_list[cki_loop_cnt].datevalue,"@LONGDATETIME")
      ELSE
       SET p_event_tag = cnvtstring(request->event_list[cki_loop_cnt].numericvalue)
      ENDIF
      IF (p_found_event_id > 0)
       CALL update_cco_event(p_found_event_id,p_event_tag,1)
      ELSE
       CALL insert_cco_event(reply->encntr_id,reply->person_id,cki_code_value,p_event_tag,curdate,
        1)
      ENDIF
     ENDIF
    ELSE
     SET bad_cki_cnt = (bad_cki_cnt+ 1)
     IF (bad_cki_cnt=1)
      SET bad_cki_string = build("CKIs NOT MAPPED ARE:",request->event_list[cki_loop_cnt].cki)
     ELSE
      SET bad_cki_string = build(bad_cki_string,",",request->event_list[cki_loop_cnt].cki)
     ENDIF
    ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE get_splice_section(p_string,p_spot)
   DECLARE temp_comma = i2 WITH noconstant(0), protect
   DECLARE last_comma = i2 WITH noconstant(0), protect
   DECLARE this_comma = i2 WITH noconstant(0), protect
   DECLARE field_size = i2 WITH noconstant(0), protect
   DECLARE start_pos = i2 WITH noconstant(0), protect
   DECLARE cnt = i2 WITH protect
   SET this_comma = findstring(",",p_string,0,0)
   IF (this_comma < 1)
    CALL echo("no commas, return full string")
    RETURN(p_string)
   ELSE
    IF (p_spot=1)
     CALL echo(build("will return=",substring(0,(this_comma - 1),p_string)))
     RETURN(substring(0,(this_comma - 1),p_string))
    ELSE
     SET last_comma = 0
     FOR (cnt = 1 TO (p_spot - 1))
      SET temp_comma = findstring(",",p_string,(last_comma+ 1),0)
      SET last_comma = temp_comma
     ENDFOR
     SET start_pos = (last_comma+ 1)
     SET this_comma = findstring(",",p_string,start_pos,0)
     IF (this_comma=0)
      SET this_comma = last_comma
      SET field_size = (textlen(p_string) - last_comma)
     ELSE
      SET field_size = ((this_comma - last_comma) - 1)
     ENDIF
     IF (field_size < 1)
      RETURN("-1")
     ELSE
      CALL echo(build("going to return=",substring(start_pos,field_size,p_string)))
      RETURN(substring(start_pos,field_size,p_string))
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE eval_birth_defects(p_event_string,p_event_pos,p_event_cd,p_loop_size)
   DECLARE array_size = i2 WITH noconstant(0), protect
   DECLARE loop_cnt = i2 WITH noconstant(0), protect
   DECLARE p_found_event_id = f8 WITH noconstant(0.0), protect
   DECLARE element_value = vc WITH noconstant("         "), protect
   DECLARE bd_long_text_id = f8 WITH noconstant(- (1.0)), protect
   FOR (loop_cnt = 1 TO p_loop_size)
     SET p_found_event_id = check_cco_event(reply->person_id,p_event_cd,loop_cnt)
     SET element_value = get_splice_section(p_event_string,loop_cnt)
     IF (p_found_event_id > 0)
      CALL update_cco_event(p_found_event_id,element_value,loop_cnt)
      IF (loop_cnt=1)
       SET birth_defect_event_cd = p_found_event_id
      ENDIF
     ELSE
      IF (loop_cnt=1)
       SET birth_defect_event_cd = insert_cco_event(reply->encntr_id,reply->person_id,p_event_cd,
        element_value,curdate,
        loop_cnt)
      ELSE
       CALL insert_cco_event(reply->encntr_id,reply->person_id,p_event_cd,element_value,curdate,
        loop_cnt)
      ENDIF
     ENDIF
   ENDFOR
   IF (birth_defect_event_cd > 0)
    SELECT INTO "nl:"
     FROM long_text lt
     WHERE lt.parent_entity_name="CCO_EVENT"
      AND lt.parent_entity_id=birth_defect_event_cd
      AND lt.active_ind=1
     DETAIL
      bd_long_text_id = lt.long_text_id
     WITH nocounter
    ;end select
    IF (bd_long_text_id > 0)
     UPDATE  FROM long_text lt
      SET lt.long_text = request->birth_defect_description, lt.updt_cnt = (lt.updt_cnt+ 1), lt
       .updt_dt_tm = cnvtdatetime(curdate,curtime3)
      WHERE lt.long_text_id=bd_long_text_id
       AND lt.parent_entity_name="CCO_EVENT"
       AND lt.parent_entity_id=birth_defect_event_cd
       AND lt.active_ind=1
      WITH nocounter
     ;end update
    ELSE
     SELECT INTO "nl:"
      j = seq(long_data_seq,nextval)
      FROM dual
      DETAIL
       bd_long_text_id = cnvtreal(j),
       CALL echo(build("IN DETAIL,j=",j,"new_seq_id=",bd_long_text_id))
      WITH format, nocounter
     ;end select
     IF (bd_long_text_id <= 0.0)
      CALL echo("ERROR GETTING NEXTVAL FROM LONG_DATA_SEQ")
      CALL echo(build("new_seq_id=",bd_long_text_id))
      SET success_flag = "N"
      SET fail_string = "ERROR GETTING NEXTVAL FROM LONG_DATA_SEQ"
      RETURN(- (1.0))
     ELSE
      INSERT  FROM long_text lt
       SET lt.long_text_id = bd_long_text_id, lt.long_text = request->birth_defect_description, lt
        .parent_entity_name = "CCO_EVENT",
        lt.parent_entity_id = birth_defect_event_cd, lt.active_ind = 1, lt.active_status_dt_tm =
        cnvtdatetime(curdate,curtime3),
        lt.updt_applctx = reqinfo->updt_applctx, lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(
         curdate,curtime3),
        lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE eval_special_event(p_event_string,p_event_pos,p_event_cd,p_loop_size)
   DECLARE array_size = i2 WITH noconstant(0), protect
   DECLARE loop_cnt = i2 WITH noconstant(0), protect
   DECLARE p_found_event_id = f8 WITH noconstant(0.0), protect
   DECLARE element_value = vc WITH noconstant("         "), protect
   FOR (loop_cnt = 1 TO p_loop_size)
     SET p_found_event_id = check_cco_event(reply->person_id,p_event_cd,loop_cnt)
     SET element_value = get_splice_section(p_event_string,loop_cnt)
     IF (p_found_event_id > 0)
      CALL update_cco_event(p_found_event_id,element_value,loop_cnt)
     ELSE
      CALL insert_cco_event(reply->encntr_id,reply->person_id,p_event_cd,element_value,curdate,
       loop_cnt)
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE check_cco_event(p_person_id,p_event_code,p_seq_num)
   DECLARE my_return_value = f8 WITH noconstant(0.0), protect
   SELECT INTO "nl:"
    FROM cco_event cev
    WHERE cev.person_id=p_person_id
     AND cev.event_cd=p_event_code
     AND cev.clinical_seq=p_seq_num
     AND cev.active_ind=1
    DETAIL
     my_return_value = cev.cco_event_id, found_event_tag = cev.event_tag
    WITH nocounter
   ;end select
   RETURN(my_return_value)
 END ;Subroutine
 SUBROUTINE insert_cco_event(p_encntr_id,p_person_id,p_event_cd,p_event_value,p_event_dt_tm,p_seq_num
  )
   DECLARE new_seq_id = f8 WITH noconstant(0.0), protect
   SELECT INTO "nl:"
    j = seq(carenet_seq,nextval)
    FROM dual
    DETAIL
     new_seq_id = cnvtreal(j),
     CALL echo(build("IN DETAIL,j=",j,"new_seq_id=",new_seq_id))
    WITH format, nocounter
   ;end select
   IF (new_seq_id <= 0.0)
    CALL echo("ERROR GETTING NEXTVAL FROM CARENET_SEQ")
    CALL echo(build("new_seq_id=",new_seq_id))
    SET success_flag = "N"
    SET fail_string = "ERROR GETTING NEXTVAL FROM CARENET_SEQ"
    RETURN(- (1.0))
   ELSE
    CALL echo("going to insert a row")
    INSERT  FROM cco_event cev
     SET cev.active_ind = 1, cev.active_status_cd = reqdata->active_status_cd, cev
      .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
      cev.active_status_prsnl_id = reqinfo->updt_id, cev.cco_event_id = new_seq_id, cev
      .clinical_event_id = 0.0,
      cev.clinical_seq = p_seq_num, cev.encntr_id = p_encntr_id, cev.event_cd = p_event_cd,
      cev.event_tag = p_event_value, cev.person_id = p_person_id, cev.publish_flag = 1,
      cev.result_status_cd = 0.0, cev.updt_applctx = reqinfo->updt_applctx, cev.updt_cnt = 0,
      cev.updt_dt_tm = cnvtdatetime(curdate,curtime3), cev.updt_id = reqinfo->updt_id, cev.updt_task
       = reqinfo->updt_task,
      cev.valid_from_dt_tm = cnvtdatetime(curdate,curtime3), cev.valid_until_dt_tm = cnvtdatetime(
       "31-DEC-2100,00:00:00"), cev.view_level = 1
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL echo(build("FAIL added event="))
     SET success_flag = "F"
     SET fail_string = "UNABLE TO INSERT CCO_EVENT ROW"
     RETURN(- (1.0))
    ELSE
     CALL echo(build("SUCCESS added event=",p_event_value))
     SET success_flag = "S"
     SET fail_string = "Success"
     RETURN(new_seq_id)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE update_cco_event(p_upd_event_id,p_event_value,p_seq_num)
   DECLARE old_value = vc WITH protect
   DECLARE found_it = i2 WITH noconstant(- (1)), protect
   SELECT INTO "nl:"
    FROM cco_event cev
    WHERE cev.cco_event_id=p_upd_event_id
     AND cev.clinical_seq=p_seq_num
     AND cev.active_ind=1
    DETAIL
     found_it = 1, old_value = cev.event_tag
    WITH nocounter
   ;end select
   IF (found_it=1
    AND trim(old_value) != trim(p_event_value))
    CALL echo("in UPDATE_CC_EVENT")
    UPDATE  FROM cco_event cev
     SET cev.event_tag = p_event_value, cev.updt_applctx = reqinfo->updt_applctx, cev.updt_cnt = (cev
      .updt_cnt+ 1),
      cev.updt_dt_tm = cnvtdatetime(curdate,curtime3), cev.updt_id = reqinfo->updt_id, cev.updt_task
       = reqinfo->updt_task
     WHERE cev.cco_event_id=p_upd_event_id
      AND cev.clinical_seq=p_seq_num
      AND cev.active_ind=1
     WITH nocounter
    ;end update
    IF (curqual=0)
     CALL echo("error updating CEV_EVENT")
     SET success_flag = "F"
     SET fail_string = "UNABLE TO UPDATE CCO_EVENT ROW"
    ELSE
     CALL echo(build("successful update of",p_event_value))
    ENDIF
   ELSE
    CALL echo("no need to update, since value is the same	")
   ENDIF
 END ;Subroutine
#9999_exit_program
END GO
