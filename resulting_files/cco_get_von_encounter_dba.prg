CREATE PROGRAM cco_get_von_encounter:dba
 RECORD reply(
   1 new_data_ind = i2
   1 cco_encntr_id = f8
   1 person_id = f8
   1 encntr_id = f8
   1 network_id = f8
   1 hospital_num = vc
   1 record_status_flag = i2
   1 patient_name = vc
   1 patient_mrn = vc
   1 mother_name = vc
   1 birth_dt_tm = dq8
   1 hosp_admit_dt_tm = dq8
   1 died_in_delivery_ind = i2
   1 day28_dt = dq8
   1 week36_dt = dq8
   1 discharge_initial_dt_tm = dq8
   1 discharge_final_dt_tm = dq8
   1 sex_ind = i2
   1 birth_defect_description = vc
   1 maternal_ethnicity_flag = i2
   1 maternal_race_flag = i2
   1 diedwithin_12hours_ind = i2
   1 von_transfer_ind = i2
   1 disp_after_readmit_flag = i2
   1 ultimate_disposition_flag = i2
   1 event_list_cnt = i2
   1 event_list[*]
     2 cki = vc
     2 datatype = vc
     2 stringvalue = vc
     2 numericvalue = f8
     2 datevalue = dq8
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
 DECLARE e_mrn_cd = f8 WITH noconstant(0.0), protect
 DECLARE p_mrn_cd = f8 WITH noconstant(0.0), protect
 DECLARE cki_code_value = f8 WITH noconstant(0.0), protect
 DECLARE expired_cd = f8 WITH noconstant(0.0), protect
 DECLARE deceased_cd = f8 WITH noconstant(0.0), protect
 DECLARE reltn_type_cd = f8 WITH noconstant(0.0), protct
 DECLARE reltn_cd = f8 WITH noconstant(0.0), protct
 DECLARE inerror_cd = f8 WITH noconstant(0.0), protect
 DECLARE return_value = vc WITH noconstant(fillstring(200," ")), protect
 DECLARE return_num = f8 WITH noconstant(0.0), protect
 DECLARE return_date = q8 WITH protect
 DECLARE data_source = i2 WITH protect
 DECLARE coe_encntr_id = f8 WITH noconstant(0.0), protect
 DECLARE bad_cki_cnt = i2 WITH noconstant(0), protect
 DECLARE bad_cki_string = vc WITH noconstant(fillstring(800," ")), protect
 DECLARE initialize_data(junk) = null WITH protect
 DECLARE resolve_cco_encntr_id(p_person_id) = f8 WITH protect
 DECLARE read_patient_data(p_person_id,p_encntr_id) = c1 WITH protect
 DECLARE read_cco_enc_data(p_cco_encounter_id) = c1 WITH protect
 DECLARE read_mrn(p_person_id,p_encntr_id) = i2 WITH protect
 DECLARE meaning_code(mc_codeset,mc_meaning) = f8 WITH public
 DECLARE build_cki_list(junk) = c1 WITH protect
 DECLARE read_cco_event(junk) = null WITH protect
 DECLARE return_cev_string(p_person_id,p_event_cd) = vc WITH public
 DECLARE return_cev_number(p_person_id,p_event_cd) = f8 WITH public
 DECLARE return_cev_date(p_person_id,p_event_cd) = q8 WITH public
 DECLARE read_ce_event(p_person_id) = null WITH protect
 DECLARE return_ce_string(p_person_id,p_event_cd,p_beg_dt,p_end_dt) = vc WITH public
 DECLARE return_special_event(p_cki,p_person_id,p_event_cd,p_items) = vc WITH public
 DECLARE return_long_text(p_cki,p_person_id,p_event_cd) = vc WITH protect
 CALL initialize_data("")
 SET data_source = request->source_flag
 IF ((request->cco_encntr_id=- (1.0)))
  SET coe_encntr_id = resolve_cco_encntr_id(request->person_id)
 ELSE
  SET coe_encntr_id = request->cco_encntr_id
 ENDIF
 IF (read_patient_data(request->encntr_id)="N")
  GO TO 9999_exit_program
 ENDIF
 IF (coe_encntr_id > 0.0)
  IF (read_cco_enc_data(coe_encntr_id)="N")
   GO TO 9999_exit_program
  ENDIF
 ELSE
  SET data_source = 1
 ENDIF
 IF (read_mrn(reply->person_id,reply->encntr_id)=0)
  CALL echo("ERROR LOADING MRN")
 ENDIF
 IF (build_cki_list("")="N")
  GO TO 9999_exit_program
 ENDIF
 IF (data_source=0)
  CALL echo("gonna look for COE data")
  CALL read_cco_event("")
 ELSE
  CALL echo("gonna look for CE Data")
  CALL read_ce_event(reply->person_id)
 ENDIF
 GO TO 9999_exit_program
 SUBROUTINE initialize_data(junk)
   SET reply->status_data.status = "F"
   SET reply->new_data_ind = 0
   SET reply->cco_encntr_id = - (1.0)
   SET reply->encntr_id = - (1.0)
   SET reply->person_id = - (1.0)
   SET reply->network_id = - (1.0)
   SET reply->patient_name = fillstring(50," ")
   SET reply->mother_name = fillstring(50," ")
   SET reply->patient_mrn = fillstring(20," ")
   SET reply->birth_dt_tm = cnvtdatetime("31-DEC-2100")
   SET reply->hosp_admit_dt_tm = cnvtdatetime("31-DEC-2100")
   SET reply->hospital_num = ""
   SET reply->record_status_flag = - (1)
   SET reply->died_in_delivery_ind = - (1)
   SET reply->day28_dt = cnvtdatetime("31-DEC-2100")
   SET reply->week36_dt = cnvtdatetime("31-DEC-2100")
   SET reply->discharge_initial_dt_tm = cnvtdatetime("31-DEC-2100")
   SET reply->discharge_final_dt_tm = cnvtdatetime("31-DEC-2100")
   SET reply->von_transfer_ind = - (1)
   SET reply->ultimate_disposition_flag = - (1)
   SET reply->diedwithin_12hours_ind = - (1)
   SET reply->disp_after_readmit_flag = - (1)
   SET success_flag = "N"
   SET fail_string = "NO PATIENT LOADED"
   SET e_mrn_cd = meaning_code(319,"MRN")
   SET p_mrn_cd = meaning_code(4,"MRN")
   SET deceased_cd = meaning_code(19,"DECEASED")
   SET expired_cd = meaning_code(19,"EXPIRED")
   SET reltn_type_cd = meaning_code(351,"FAMILY")
   SET reltn_cd = meaning_code(40,"MOTHER")
   SET inerror_cd = meaning_code(8,"INERROR")
   SET data_source = - (1)
 END ;Subroutine
 SUBROUTINE resolve_cco_encntr_id(p_person_id)
   DECLARE found_id = f8 WITH noconstant(0.0), protect
   SELECT INTO "nl:"
    FROM cco_encounter coe
    WHERE coe.person_id=p_person_id
     AND coe.active_ind=1
    DETAIL
     found_id = coe.cco_encounter_id
    WITH nocounter
   ;end select
   RETURN(found_id)
 END ;Subroutine
 SUBROUTINE read_cco_enc_data(p_cco_encounter_id)
   SELECT INTO "nl:"
    FROM cco_encounter coe
    PLAN (coe
     WHERE coe.cco_encounter_id=p_cco_encounter_id
      AND coe.active_ind=1)
    DETAIL
     reply->cco_encntr_id = coe.cco_encounter_id, reply->died_in_delivery_ind = coe.diedindelroom_ind,
     reply->network_id = coe.patient_identifier,
     reply->mother_name = coe.mothers_name, reply->maternal_ethnicity_flag = coe.mothers_ethnicity,
     reply->maternal_race_flag = coe.mothers_race,
     reply->died_in_delivery_ind = coe.diedindelroom_ind, reply->discharge_final_dt_tm = coe
     .final_disch_dt_tm, reply->discharge_initial_dt_tm = coe.initial_disch_dt_tm,
     reply->record_status_flag = coe.record_status_flag, reply->sex_ind = coe.gender_flag, reply->
     diedwithin_12hours_ind = coe.diedinicu_ind,
     reply->von_transfer_ind = coe.von_transfer_flag, reply->ultimate_disposition_flag = coe
     .final_disposition_flag, reply->disp_after_readmit_flag = coe.readmission_disposition_flag
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET success_flag = "Y"
   ELSE
    SET success_flag = "N"
    SET fail_string = "FAILED TO LOAD VON ENCOUNTER DATA"
   ENDIF
   RETURN(success_flag)
 END ;Subroutine
 SUBROUTINE read_patient_data(p_encntr_id)
   SET fail_string = "UNABLE TO READ DATA FROM PERSON/ENCOUNTER TABLE"
   SET success_flag = "N"
   SELECT INTO "nl:"
    FROM encounter e,
     person p
    PLAN (e
     WHERE e.encntr_id=p_encntr_id
      AND e.active_ind=1)
     JOIN (p
     WHERE p.person_id=e.person_id
      AND p.active_ind=1)
    DETAIL
     reply->encntr_id = e.encntr_id, reply->person_id = p.person_id, reply->patient_name = p
     .name_full_formatted,
     reply->birth_dt_tm = p.birth_dt_tm, reply->hosp_admit_dt_tm = e.reg_dt_tm, reply->day28_dt =
     datetimeadd(p.birth_dt_tm,(28 - 1))
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET success_flag = "Y"
    SELECT INTO "nl:"
     FROM encounter e,
      risk_adjustment_ref rar
     PLAN (e
      WHERE (e.encntr_id=reply->encntr_id)
       AND e.active_ind=1)
      JOIN (rar
      WHERE rar.organization_id=e.organization_id
       AND rar.active_ind=1)
     DETAIL
      reply->hospital_num = rar.hospital_code
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET success_flag = "N"
     SET fail_string = "FAILED TO LOAD ORGANIZATION INFORMATION FROM RISK_ADJUSTMENT_REF"
    ENDIF
   ELSE
    SET success_flag = "N"
    SET fail_string = "FAILED TO LOAD PERSON,ENCOUNTER DATA"
   ENDIF
   RETURN(success_flag)
 END ;Subroutine
 SUBROUTINE read_mrn(p_person_id,p_encntr_id)
   SET found_mrn = 0
   SELECT INTO "nl:"
    FROM person_alias pa
    PLAN (pa
     WHERE pa.person_id=p_person_id
      AND pa.person_alias_type_cd=p_mrn_cd
      AND pa.active_ind=1
      AND pa.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
      AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    DETAIL
     reply->patient_mrn = cnvtalias(pa.alias,pa.alias_pool_cd), found_mrn = 1
    WITH nocounter
   ;end select
   IF (found_mrn=0)
    SELECT INTO "nl:"
     FROM encntr_alias ea
     PLAN (ea
      WHERE (ea.encntr_id=request->encntr_id)
       AND ea.encntr_alias_type_cd=e_mrn_cd
       AND ea.active_ind=1
       AND ea.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
       AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     DETAIL
      found_mrn = 1, reply->patient_mrn = cnvtalias(ea.alias,ea.alias_pool_cd)
     WITH nocounter
    ;end select
   ENDIF
   RETURN(found_mrn)
 END ;Subroutine
 SUBROUTINE read_cco_event(junk)
   DECLARE read_cnt = i2 WITH protect
   SET bad_cki_cnt = 0
   SET list_count = size(reply->event_list,5)
   SET cki_code_value = 0.0
   FOR (read_cnt = 1 TO list_count)
    SET cki_code_value = uar_get_code_by_cki(nullterm(reply->event_list[read_cnt].cki))
    IF (cki_code_value > 0.0)
     CALL echo(build("GOING TO QUERY FOR ITEM#",read_cnt,"cki=",reply->event_list[read_cnt].cki))
     IF ((reply->event_list[read_cnt].cki="CKI.EC!8102"))
      SET reply->event_list[read_cnt].stringvalue = return_special_event(reply->event_list[read_cnt].
       cki,reply->person_id,cki_code_value,5)
     ELSEIF ((reply->event_list[read_cnt].cki="MUL.ORD!d00777"))
      SET reply->event_list[read_cnt].stringvalue = return_special_event(reply->event_list[read_cnt].
       cki,reply->person_id,cki_code_value,3)
     ELSEIF ((reply->event_list[read_cnt].cki="CKI.EC!8399"))
      SET reply->event_list[read_cnt].stringvalue = return_special_event(reply->event_list[read_cnt].
       cki,reply->person_id,cki_code_value,6)
      SET reply->birth_defect_description = return_long_text(reply->event_list[read_cnt].cki,reply->
       person_id,cki_code_value)
     ELSEIF ((reply->event_list[read_cnt].cki="CKI.EC!3333"))
      SET reply->event_list[read_cnt].stringvalue = return_special_event(reply->event_list[read_cnt].
       cki,reply->person_id,cki_code_value,3)
     ELSEIF ((reply->event_list[read_cnt].cki="CKI.EC!8127"))
      SET reply->event_list[read_cnt].stringvalue = return_special_event(reply->event_list[read_cnt].
       cki,reply->person_id,cki_code_value,2)
     ELSEIF ((reply->event_list[read_cnt].cki="CKI.EC!8381"))
      SET reply->event_list[read_cnt].stringvalue = return_special_event(reply->event_list[read_cnt].
       cki,reply->person_id,cki_code_value,4)
     ELSEIF ((reply->event_list[read_cnt].cki="CKI.EC!4051"))
      SET reply->event_list[read_cnt].stringvalue = return_special_event(reply->event_list[read_cnt].
       cki,reply->person_id,cki_code_value,2)
     ELSEIF ((reply->event_list[read_cnt].datatype="VC"))
      SET reply->event_list[read_cnt].stringvalue = return_cev_string(reply->person_id,cki_code_value
       )
     ELSEIF ((reply->event_list[read_cnt].datatype IN ("F8", "I2", "I4")))
      SET reply->event_list[read_cnt].numericvalue = return_cev_number(reply->person_id,
       cki_code_value)
     ELSEIF ((reply->event_list[read_cnt].datatype="DQ"))
      SET reply->event_list[read_cnt].datevalue = return_cev_date(reply->person_id,cki_code_value)
     ELSE
      CALL echo("WE SHOULDN'T BE HERE")
     ENDIF
    ELSE
     CALL echo(build("CKI not mapped>",reply->event_list[read_cnt].cki))
     SET bad_cki_cnt = (bad_cki_cnt+ 1)
     IF (bad_cki_cnt=1)
      SET bad_cki_string = build("CKIs NOT MAPPED ARE:",reply->event_list[read_cnt].cki)
     ELSE
      SET bad_cki_string = build(bad_cki_string,",",reply->event_list[read_cnt].cki)
     ENDIF
    ENDIF
   ENDFOR
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
 SUBROUTINE build_cki_list(junk)
   DECLARE cki_cnt = i2 WITH noconstant(0), protect
   DECLARE tmpcnt = i2 WITH protect
   DECLARE ret_val = i2 WITH protect
   SET stat = alterlist(reply->event_list,100)
   SET cki_cnt = 1
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8089"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8090"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!7365"
   SET reply->event_list[cki_cnt].datatype = "F8"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8092"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8096"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8097"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!7215"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8098"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8099"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8100"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8101"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8102"
   SET reply->event_list[cki_cnt].datatype = "VC"
   SET reply->event_list[cki_cnt].stringvalue = ""
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8106"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "MUL.ORD!d00777"
   SET reply->event_list[cki_cnt].datatype = "VC"
   SET reply->event_list[cki_cnt].stringvalue = ""
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8399"
   SET reply->event_list[cki_cnt].datatype = "VC"
   SET reply->event_list[cki_cnt].stringvalue = ""
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8311"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET reply->event_list[cki_cnt].stringvalue = ""
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!6267"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8315"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8379"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!3333"
   SET reply->event_list[cki_cnt].datatype = "VC"
   SET reply->event_list[cki_cnt].stringvalue = ""
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8105"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!7676"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8103"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8380"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "MUL.ORD!d00039"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8381"
   SET reply->event_list[cki_cnt].datatype = "VC"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8385"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8386"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8387"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8388"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8389"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8312"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8392"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8394"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8396"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8397"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8398"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8128"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8127"
   SET reply->event_list[cki_cnt].datatype = "VC"
   SET reply->event_list[cki_cnt].stringvalue = ""
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8130"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!4051"
   SET reply->event_list[cki_cnt].datatype = "VC"
   SET reply->event_list[cki_cnt].stringvalue = ""
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8129"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8400"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!7672"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!7991"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8404"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8405"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8107"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8412"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8406"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8407"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8408"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8409"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8402"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8403"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET cki_cnt = (cki_cnt+ 1)
   SET reply->event_list[cki_cnt].cki = "CKI.EC!8108"
   SET reply->event_list[cki_cnt].datatype = "I2"
   SET stat = alterlist(reply->event_list,cki_cnt)
   SET reply->event_list_cnt = cki_cnt
   FOR (tempcnt = 1 TO cki_cnt)
     CALL echo(build("reply->event_list[tempcnt].cki=",reply->event_list[tempcnt].cki))
     CALL echo(build("uar_get_code_by_cki(reply->event_list[tempcnt].cki)=",uar_get_code_by_cki(reply
        ->event_list[tempcnt].cki)))
     CALL echo(build("uar_get_code_by_cki(nullterm(reply->event_list[tempcnt].cki))=",
       uar_get_code_by_cki(nullterm(reply->event_list[tempcnt].cki))))
     SET reply->event_list[tempcnt].numericvalue = - (1)
     SET reply->event_list[tempcnt].stringvalue = fillstring(30," ")
     SET reply->event_list[tempcnt].datevalue = cnvtdatetime("31-DEC-2100")
     IF ((reply->event_list[tempcnt].cki="CKI.EC!8102"))
      SET reply->event_list[tempcnt].stringvalue = "-1,-1,-1,-1,-1"
     ELSEIF ((reply->event_list[tempcnt].cki="MUL.ORD!d00777"))
      SET reply->event_list[tempcnt].stringvalue = "-1,-1,-1"
     ELSEIF ((reply->event_list[tempcnt].cki="CKI.EC!8399"))
      SET reply->event_list[tempcnt].stringvalue = "-1,-1,-1,-1,-1,-1"
     ELSEIF ((reply->event_list[tempcnt].cki="CKI.EC!3333"))
      SET reply->event_list[tempcnt].stringvalue = "-1,-1,-1"
     ELSEIF ((reply->event_list[tempcnt].cki="CKI.EC!8127"))
      SET reply->event_list[tempcnt].stringvalue = "-1,-1"
     ELSEIF ((reply->event_list[tempcnt].cki="CKI.EC!8381"))
      SET reply->event_list[tempcnt].stringvalue = "-1,-1,-1,-1"
     ELSEIF ((reply->event_list[tempcnt].cki="CKI.EC!4051"))
      SET reply->event_list[tempcnt].stringvalue = "-1,-1"
     ENDIF
   ENDFOR
   SET ret_val = size(reply->event_list,5)
   IF (ret_val != cki_cnt)
    SET success_flag = "N"
    SET fail_string = "CKI_LIST BUILD FAILED"
    RETURN("N")
   ELSE
    RETURN("Y")
   ENDIF
 END ;Subroutine
 SUBROUTINE return_cev_string(p_person_id,p_event_cd)
   SET return_string = fillstring(100," ")
   SELECT INTO "nl:"
    FROM cco_event cev
    PLAN (cev
     WHERE cev.person_id=p_person_id
      AND cev.event_cd=p_event_cd
      AND cev.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
      AND cev.view_level=1
      AND cev.publish_flag=1
      AND cev.result_status_cd != inerror_cd
      AND cev.active_ind=1)
    ORDER BY cnvtdatetime(cev.event_end_dt_tm) DESC
    DETAIL
     return_string = cev.event_tag
    WITH nocounter
   ;end select
   IF (curqual=0)
    RETURN(" ")
   ELSE
    RETURN(return_string)
   ENDIF
 END ;Subroutine
 SUBROUTINE return_cev_number(p_person_id,p_event_cd)
   DECLARE return_num = f8 WITH noconstant(- (1.0)), protect
   SELECT INTO "nl:"
    FROM cco_event cev
    PLAN (cev
     WHERE cev.person_id=p_person_id
      AND cev.event_cd=p_event_cd
      AND cev.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
      AND cev.view_level=1
      AND cev.publish_flag=1
      AND cev.result_status_cd != inerror_cd
      AND cev.active_ind=1)
    ORDER BY cnvtdatetime(cev.event_end_dt_tm) DESC
    DETAIL
     return_num = cnvtreal(cev.event_tag)
    WITH nocounter
   ;end select
   IF (curqual=0)
    RETURN(- (1.0))
   ELSE
    RETURN(return_num)
   ENDIF
 END ;Subroutine
 SUBROUTINE return_cev_date(p_person_id,p_event_cd)
  SELECT INTO "nl:"
   FROM cco_event cev
   PLAN (cev
    WHERE cev.person_id=p_person_id
     AND cev.event_cd=p_event_cd
     AND cev.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
     AND cev.view_level=1
     AND cev.publish_flag=1
     AND cev.result_status_cd != inerror_cd
     AND cev.active_ind=1)
   ORDER BY cnvtdatetime(cev.event_end_dt_tm) DESC
   DETAIL
    return_date = cnvtdatetime(cev.event_tag)
   WITH nocounter
  ;end select
  IF (curqual=0)
   RETURN(cnvtdatetime("31-DEC-2100"))
  ELSE
   RETURN(return_date)
  ENDIF
 END ;Subroutine
 SUBROUTINE read_ce_event(p_person_id)
   DECLARE read_ce_cnt = i2 WITH protect
   DECLARE cki_code_value = f8 WITH protect
   DECLARE done_gest_age = i2 WITH protect
   DECLARE gest_age = f8 WITH protect
   DECLARE gest_days = f8 WITH protect
   DECLARE loc_of_birth = vc WITH protect
   DECLARE moth_race_eth = vc WITH protect
   DECLARE done_num_inf = i2 WITH protect
   DECLARE mult_birth = i2 WITH protect
   DECLARE num_birth = i2 WITH protect
   DECLARE bday = q8 WITH protect
   DECLARE todaydt = q8 WITH protect
   DECLARE beg_day28_dt = q8 WITH protect
   DECLARE end_day28_dt = q8 WITH protect
   DECLARE surf_dt_tm = q8 WITH protect
   DECLARE enteral_feed = vc WITH protect
   DECLARE init_disp = vc WITH protect
   DECLARE tran_reason = vc WITH protect
   SET bday = cnvtdatetime(reply->birth_dt_tm)
   SET todaydt = cnvtdatetime(curdate,235999)
   SET beg_day28_dt = datetimeadd(cnvtdatetime(cnvtdate(bday),0),27)
   SET end_day28_dt = datetimeadd(cnvtdatetime(cnvtdate(bday),0),28)
   SET list_count = size(reply->event_list,5)
   SET cki_code_value = 0.0
   SET bad_cki_cnt = 0
   FOR (read_ce_cnt = 1 TO list_count)
     CALL echo("TOP OF READ_CE_EVENT")
     SET cki_code_value = uar_get_code_by_cki(nullterm(reply->event_list[read_ce_cnt].cki))
     IF (cki_code_value < 1.0)
      CALL echo(build("CKI not mapped>",reply->event_list[read_ce_cnt].cki))
      SET bad_cki_cnt = (bad_cki_cnt+ 1)
      IF (bad_cki_cnt=1)
       SET bad_cki_string = build("CKIs NOT MAPPED ARE:",reply->event_list[read_ce_cnt].cki)
      ELSE
       SET bad_cki_string = build(bad_cki_string,",",reply->event_list[read_ce_cnt].cki)
      ENDIF
     ELSE
      CALL echo(build("CKI MAPPED=",reply->event_list[read_ce_cnt].cki))
     ENDIF
     IF ((reply->event_list[read_ce_cnt].cki="CKI.EC!7365"))
      SET cki_code_value = uar_get_code_by_cki(nullterm(reply->event_list[read_ce_cnt].cki))
      IF (cki_code_value > 0)
       SET reply->event_list[read_ce_cnt].numericvalue = cnvtreal(return_ce_string(p_person_id,
         cki_code_value,bday,todaydt))
      ENDIF
     ELSEIF ((reply->event_list[read_ce_cnt].cki IN ("CKI.EC!8089", "CKI.EC!8090")))
      IF (done_gest_age=0)
       SET done_gest_age = 1
       SET cki_code_value = uar_get_code_by_cki(nullterm("CKI.EC!8089"))
       IF (cki_code_value > 0)
        SET gest_age = cnvtreal(return_ce_string(p_person_id,cki_code_value,bday,todaydt))
        IF (gest_age > 0)
         SET cki_code_value = uar_get_code_by_cki(nullterm("CKI.EC!8090"))
         IF (cki_code_value > 0)
          SET gest_days = cnvtreal(return_ce_string(p_person_id,cki_code_value,bday,todaydt))
         ENDIF
        ELSE
         SET cki_code_value = uar_get_code_by_cki(nullterm("CKI.EC!8091"))
         IF (cki_code_value > 0)
          SET gest_age = cnvtreal(return_ce_string(p_person_id,cki_code_value,bday,todaydt))
          SET gest_days = 0
         ENDIF
        ENDIF
       ENDIF
      ENDIF
      IF ((reply->event_list[read_ce_cnt].cki="CKI.EC!8089"))
       SET reply->event_list[read_ce_cnt].numericvalue = gest_age
      ELSE
       SET reply->event_list[read_ce_cnt].numericvalue = gest_days
      ENDIF
     ELSEIF ((reply->event_list[read_ce_cnt].cki="CKI.EC!8092"))
      SET cki_code_value = uar_get_code_by_cki(nullterm(reply->event_list[read_ce_cnt].cki))
      IF (cki_code_value > 0)
       IF (cnvtupper(return_ce_string(p_person_id,cki_code_value,bday,todaydt))="OUTBORN")
        SET reply->event_list[read_ce_cnt].numericvalue = 1
       ELSE
        SET reply->event_list[read_ce_cnt].numericvalue = 0
       ENDIF
      ENDIF
     ELSEIF ((reply->event_list[read_ce_cnt].cki="CKI.EC!8096"))
      SET cki_code_value = uar_get_code_by_cki(nullterm(reply->event_list[read_ce_cnt].cki))
      IF (cki_code_value > 0)
       IF (cnvtupper(return_ce_string(p_person_id,cki_code_value,bday,todaydt))="NO PRENATAL CARE")
        SET reply->event_list[read_ce_cnt].numericvalue = 0
       ELSE
        SET reply->event_list[read_ce_cnt].numericvalue = 1
       ENDIF
      ENDIF
     ELSEIF ((reply->event_list[read_ce_cnt].cki="CKI.EC!8097"))
      SET cki_code_value = uar_get_code_by_cki(nullterm(reply->event_list[read_ce_cnt].cki))
      IF (cki_code_value > 0)
       IF (cnvtupper(return_ce_string(p_person_id,cki_code_value,bday,todaydt)) IN (
       "CORTICOSTEROIDS IM OR IV", "BETAMETHASONE IM OR IV", "DEXAMETHASONE IM OR IV",
       "HYDROCORTISONE IM OR IV"))
        SET reply->event_list[read_ce_cnt].numericvalue = 1
       ELSE
        SET reply->event_list[read_ce_cnt].numericvalue = 0
       ENDIF
      ENDIF
     ELSEIF ((reply->event_list[read_ce_cnt].cki="CKI.EC!7215"))
      SET cki_code_value = uar_get_code_by_cki(nullterm(reply->event_list[read_ce_cnt].cki))
      IF (cki_code_value > 0)
       IF (cnvtupper(return_ce_string(p_person_id,cki_code_value,bday,todaydt))="C-SECTION")
        SET reply->event_list[read_ce_cnt].numericvalue = 0
       ELSE
        SET reply->event_list[read_ce_cnt].numericvalue = 1
       ENDIF
      ENDIF
     ELSEIF ((reply->event_list[read_ce_cnt].cki IN ("CKI.EC!8098", "CKI.EC!8099")))
      IF (done_num_inf=0)
       SET done_num_inf = 1
       SET cki_code_value = uar_get_code_by_cki(nullterm("CKI.EC!8098"))
       IF (cki_code_value > 0)
        IF (cnvtupper(return_ce_string(p_person_id,cki_code_value,bday,todaydt)) IN ("MULTIPLE BIRTH",
        "YES"))
         SET mult_birth = 1
         SET cki_code_value = uar_get_code_by_cki(nullterm("CKI.EC!8253"))
         IF (cki_code_value > 0)
          IF (return_ce_string(p_person_id,cki_code_value,bday,todaydt) != " ")
           SET num_birth = 2
          ELSE
           SET cki_code_value = uar_get_code_by_cki(nullterm("CKI.EC!8254"))
           IF (cki_code_value > 0)
            IF (return_ce_string(p_person_id,cki_code_value,bday,todaydt) != " ")
             SET num_birth = 3
            ELSE
             SET cki_code_value = uar_get_code_by_cki(nullterm("CKI.EC!8099"))
             SET num_birth = cnvtint(return_ce_string(p_person_id,cki_code_value,bday,todaydt))
            ENDIF
           ENDIF
          ENDIF
         ENDIF
        ELSE
         SET mult_birth = 0
         SET num_birth = 77
        ENDIF
       ENDIF
      ENDIF
      IF ((reply->event_list[read_ce_cnt].cki="CKI.EC!8098"))
       SET reply->event_list[read_ce_cnt].numericvalue = mult_birth
      ELSE
       SET reply->event_list[read_ce_cnt].numericvalue = num_birth
      ENDIF
     ELSEIF ((reply->event_list[read_ce_cnt].cki="CKI.EC!8100"))
      SET cki_code_value = uar_get_code_by_cki(nullterm(reply->event_list[read_ce_cnt].cki))
      IF (cki_code_value > 0)
       SET reply->event_list[read_ce_cnt].numericvalue = cnvtint(return_ce_string(p_person_id,
         cki_code_value,bday,todaydt))
      ENDIF
     ELSEIF ((reply->event_list[read_ce_cnt].cki="CKI.EC!8101"))
      SET cki_code_value = uar_get_code_by_cki(nullterm(reply->event_list[read_ce_cnt].cki))
      IF (cki_code_value > 0)
       SET reply->event_list[read_ce_cnt].numericvalue = cnvtint(return_ce_string(p_person_id,
         cki_code_value,bday,todaydt))
      ENDIF
     ELSEIF ((reply->event_list[read_ce_cnt].cki="CKI.EC!6267"))
      SET cki_code_value = uar_get_code_by_cki(nullterm("CKI.EC!6267"))
      IF (cki_code_value > 0)
       IF (return_ce_string(p_person_id,cki_code_value,beg_day28_dt,end_day28_dt) != " ")
        SET reply->event_list[read_ce_cnt].numericvalue = 1
       ELSE
        SET cki_code_value = uar_get_code_by_cki(nullterm("CKI.EC!3333"))
        IF (cki_code_value > 0)
         IF (return_ce_string(p_person_id,cki_code_value,beg_day28_dt,end_day28_dt) != " ")
          SET reply->event_list[read_ce_cnt].numericvalue = 1
         ELSE
          SET cki_code_value = uar_get_code_by_cki(nullterm("CKI.EC!8103"))
          IF (cki_code_value > 0)
           IF (return_ce_string(p_person_id,cki_code_value,beg_day28_dt,end_day28_dt) != " ")
            SET reply->event_list[read_ce_cnt].numericvalue = 1
           ELSE
            SET reply->event_list[read_ce_cnt].numericvalue = 9
           ENDIF
          ENDIF
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ELSEIF ((reply->event_list[read_ce_cnt].cki="CKI.EC!8106"))
      SET cki_code_value = uar_get_code_by_cki(nullterm(reply->event_list[read_ce_cnt].cki))
      IF (cki_code_value > 0)
       IF (cnvtupper(return_ce_string(p_person_id,cki_code_value,bday,todaydt)) IN ("YES",
       "SURFACTANT IN DELIVERY"))
        SET reply->event_list[read_ce_cnt].numericvalue = 1
       ELSE
        SET reply->event_list[read_ce_cnt].numericvalue = 0
       ENDIF
      ENDIF
     ELSEIF ((reply->event_list[read_ce_cnt].cki="CKI.EC!8128"))
      SET cki_code_value = uar_get_code_by_cki(nullterm(reply->event_list[read_ce_cnt].cki))
      IF (cki_code_value > 0)
       SET enteral_feed = cnvtupper(return_ce_string(p_person_id,cki_code_value,bday,todaydt))
       IF (enteral_feed=" ")
        SET reply->event_list[read_ce_cnt].numericvalue = - (1)
       ELSEIF (enteral_feed="NO ENTERAL FEEDING")
        SET reply->event_list[read_ce_cnt].numericvalue = 0
       ELSEIF (enteral_feed="HUMAN MILK ONLY")
        SET reply->event_list[read_ce_cnt].numericvalue = 1
       ELSEIF (enteral_feed="FORMULA ONLY")
        SET reply->event_list[read_ce_cnt].numericvalue = 2
       ELSEIF (enteral_feed IN ("HUMAN MILK WITH FORMULA", "HUMAN MILK WITH FORTIFIER"))
        SET reply->event_list[read_ce_cnt].numericvalue = 3
       ELSE
        SET reply->event_list[read_ce_cnt].numericvalue = 9
       ENDIF
      ENDIF
     ELSEIF ((reply->event_list[read_ce_cnt].cki="CKI.EC!8130"))
      SET cki_code_value = uar_get_code_by_cki(nullterm(reply->event_list[read_ce_cnt].cki))
      IF (cki_code_value > 0)
       SET init_disp = cnvtupper(return_ce_string(p_person_id,cki_code_value,bday,todaydt))
       IF (init_disp="HOME")
        SET reply->event_list[read_ce_cnt].numericvalue = 1
       ELSEIF (init_disp="OTHER HEALTHCARE FACILITY")
        SET reply->event_list[read_ce_cnt].numericvalue = 2
       ELSEIF (init_disp="DECEASED")
        SET reply->event_list[read_ce_cnt].numericvalue = 3
       ENDIF
      ENDIF
     ELSEIF ((reply->event_list[read_ce_cnt].cki="CKI.EC!8129"))
      SET cki_code_value = uar_get_code_by_cki(nullterm(reply->event_list[read_ce_cnt].cki))
      IF (cki_code_value > 0)
       SET tran_reason = return_ce_string(p_person_id,cki_code_value,bday,todaydt)
       IF (cnvtupper(tran_reason)="GROWTH/DISCHARGE PLANNING")
        SET reply->event_list[read_ce_cnt].numericvalue = 1
       ELSEIF (cnvtupper(tran_reason)="MEDICAL/DIAGNOSTIC SERVICES")
        SET reply->event_list[read_ce_cnt].numericvalue = 2
       ELSEIF (cnvtupper(tran_reason)="SURGERY")
        SET reply->event_list[read_ce_cnt].numericvalue = 3
       ELSEIF (cnvtupper(tran_reason)="CHRONIC CARE")
        SET reply->event_list[read_ce_cnt].numericvalue = 4
       ELSEIF (cnvtupper(tran_reason)="OTHER REASON FOR TRANSFER")
        SET reply->event_list[read_ce_cnt].numericvalue = 5
       ELSE
        SET reply->event_list[read_ce_cnt].numericvalue = - (1)
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   SET cki_code_value = uar_get_code_by_cki(nullterm("CKI.EC!8095"))
   IF (cki_code_value > 0)
    SET moth_race_eth = return_ce_string(p_person_id,cki_code_value,bday,todaydt)
    IF (cnvtupper(moth_race_eth)="HISPANIC")
     SET reply->maternal_ethnicity_flag = 1
    ENDIF
    IF (cnvtupper(moth_race_eth)="BLACK/AFRICAN")
     SET reply->maternal_race_flag = 1
    ELSEIF (cnvtupper(moth_race_eth) IN ("CAJUN", "CAUCASIAN", "FRENCH CANADIAN", "GREEK", "ITALIAN",
    "JEWISH", "MEDITERRANEAN"))
     SET reply->maternal_race_flag = 3
    ELSEIF (cnvtupper(moth_race_eth) IN ("ASIAN", "PACIFIC ISLANDER"))
     SET reply->maternal_race_flag = 4
    ELSEIF (cnvtupper(moth_race_eth)="NATIVE AMERICAN")
     SET reply->maternal_race_flag = 5
    ELSE
     SET reply->maternal_race_flag = 6
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE return_ce_string(p_person_id,p_event_cd,p_beg_dt,p_end_dt)
   DECLARE return_string = vc WITH protect
   SET return_string = fillstring(100," ")
   SELECT INTO "nl:"
    FROM clinical_event ce
    PLAN (ce
     WHERE ce.person_id=p_person_id
      AND ce.event_cd=p_event_cd
      AND ce.event_end_dt_tm >= cnvtdatetime(p_beg_dt)
      AND ce.event_end_dt_tm <= cnvtdatetime(p_end_dt)
      AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
      AND ce.view_level=1
      AND ce.publish_flag=1
      AND ce.result_status_cd != inerror_cd)
    ORDER BY cnvtdatetime(ce.event_end_dt_tm) DESC
    DETAIL
     return_string = ce.event_tag,
     CALL echo(build("found event=",return_string))
    WITH nocounter
   ;end select
   IF (curqual=0)
    RETURN(" ")
   ELSE
    RETURN(return_string)
   ENDIF
 END ;Subroutine
 SUBROUTINE return_special_event(p_cki,p_person_id,p_event_cd,p_items)
   DECLARE value_array[10] = i2 WITH protect
   DECLARE return_string = vc WITH noconstant(fillstring(30," ")), protect
   DECLARE cnt1 = i2 WITH protect
   DECLARE cnt2 = i2 WITH protect
   SET stat = initarray(value_array,- (1))
   IF (p_event_cd > 0)
    SELECT INTO "nl:"
     FROM cco_event cev
     PLAN (cev
      WHERE cev.person_id=p_person_id
       AND cev.event_cd=p_event_cd
       AND cev.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
       AND cev.view_level=1
       AND cev.publish_flag=1
       AND cev.result_status_cd != inerror_cd
       AND cev.active_ind=1
       AND cev.clinical_seq <= p_items
       AND cev.clinical_seq > 0)
     ORDER BY cnvtdatetime(cev.event_end_dt_tm) DESC
     DETAIL
      value_array[cev.clinical_seq] = cnvtint(cev.event_tag)
     WITH nocounter
    ;end select
   ENDIF
   FOR (cnt2 = 1 TO p_items)
    IF (cnt2 > 1)
     SET return_string = build(return_string,",")
    ENDIF
    SET return_string = build(return_string,cnvtstring(value_array[cnt2]))
   ENDFOR
   CALL echo(build("special return_String=",return_string))
   RETURN(return_string)
 END ;Subroutine
 SUBROUTINE return_long_text(p_cki,p_person_id,p_event_cd)
   CALL echo("top of LONG_TEXT SECTION")
   DECLARE lt_string = vc WITH noconstant(fillstring(255," ")), protect
   SELECT INTO "nl:"
    FROM cco_event cev,
     long_text lt
    PLAN (cev
     WHERE cev.person_id=p_person_id
      AND cev.event_cd=p_event_cd
      AND cev.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
      AND cev.view_level=1
      AND cev.publish_flag=1
      AND cev.result_status_cd != inerror_cd
      AND cev.active_ind=1
      AND cev.clinical_seq=1)
     JOIN (lt
     WHERE lt.parent_entity_id=cev.cco_event_id
      AND lt.parent_entity_name="CCO_EVENT"
      AND lt.active_ind=1)
    DETAIL
     CALL echo("got long text"),
     CALL echo(build("lt.long_text=",trim(substring(1,255,lt.long_text)))), lt_string = trim(
      substring(1,255,lt.long_text))
    WITH nocounter
   ;end select
   RETURN(lt_string)
 END ;Subroutine
#9999_exit_program
 IF (success_flag="N")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = fail_string
  SET reply->status_data.status = "F"
 ELSEIF (bad_cki_cnt > 0)
  SET reply->status_data.subeventstatus[1].targetobjectvalue = bad_cki_string
  SET reply->status_data.status = "P"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
