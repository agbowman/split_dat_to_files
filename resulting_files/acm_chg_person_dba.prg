CREATE PROGRAM acm_chg_person:dba
 IF (validate(false,0)=0
  AND validate(false,1)=1)
  DECLARE false = i2 WITH public, constant(0)
 ENDIF
 IF (validate(true,0)=0
  AND validate(true,1)=1)
  DECLARE true = i2 WITH public, constant(1)
 ENDIF
 IF (validate(gen_nbr_error,0)=0
  AND validate(gen_nbr_error,1)=1)
  DECLARE gen_nbr_error = i2 WITH public, constant(3)
 ENDIF
 IF (validate(insert_error,0)=0
  AND validate(insert_error,1)=1)
  DECLARE insert_error = i2 WITH public, constant(4)
 ENDIF
 IF (validate(update_error,0)=0
  AND validate(update_error,1)=1)
  DECLARE update_error = i2 WITH public, constant(5)
 ENDIF
 IF (validate(replace_error,0)=0
  AND validate(replace_error,1)=1)
  DECLARE replace_error = i2 WITH public, constant(6)
 ENDIF
 IF (validate(delete_error,0)=0
  AND validate(delete_error,1)=1)
  DECLARE delete_error = i2 WITH public, constant(7)
 ENDIF
 IF (validate(undelete_error,0)=0
  AND validate(undelete_error,1)=1)
  DECLARE undelete_error = i2 WITH public, constant(8)
 ENDIF
 IF (validate(remove_error,0)=0
  AND validate(remove_error,1)=1)
  DECLARE remove_error = i2 WITH public, constant(9)
 ENDIF
 IF (validate(attribute_error,0)=0
  AND validate(attribute_error,1)=1)
  DECLARE attribute_error = i2 WITH public, constant(10)
 ENDIF
 IF (validate(lock_error,0)=0
  AND validate(lock_error,1)=1)
  DECLARE lock_error = i2 WITH public, constant(11)
 ENDIF
 IF (validate(none_found,0)=0
  AND validate(none_found,1)=1)
  DECLARE none_found = i2 WITH public, constant(12)
 ENDIF
 IF (validate(select_error,0)=0
  AND validate(select_error,1)=1)
  DECLARE select_error = i2 WITH public, constant(13)
 ENDIF
 IF (validate(update_cnt_error,0)=0
  AND validate(update_cnt_error,1)=1)
  DECLARE update_cnt_error = i2 WITH public, constant(14)
 ENDIF
 IF (validate(not_found,0)=0
  AND validate(not_found,1)=1)
  DECLARE not_found = i2 WITH public, constant(15)
 ENDIF
 IF (validate(inactivate_error,0)=0
  AND validate(inactivate_error,1)=1)
  DECLARE inactivate_error = i2 WITH public, constant(17)
 ENDIF
 IF (validate(activate_error,0)=0
  AND validate(activate_error,1)=1)
  DECLARE activate_error = i2 WITH public, constant(18)
 ENDIF
 IF (validate(uar_error,0)=0
  AND validate(uar_error,1)=1)
  DECLARE uar_error = i2 WITH public, constant(20)
 ENDIF
 IF (validate(duplicate_error,- (1)) != 21)
  DECLARE duplicate_error = i2 WITH protect, noconstant(21)
 ENDIF
 IF (validate(ccl_error,- (1)) != 22)
  DECLARE ccl_error = i2 WITH protect, noconstant(22)
 ENDIF
 IF (validate(execute_error,- (1)) != 23)
  DECLARE execute_error = i2 WITH protect, noconstant(23)
 ENDIF
 DECLARE failed = i2 WITH protect, noconstant(false)
 DECLARE table_name = vc WITH protect, noconstant(" ")
 DECLARE call_echo_ind = i2 WITH protect, noconstant(0)
 DECLARE pmhc_contributory_system_cd = f8 WITH protect, noconstant(0.0)
 DECLARE t1 = i4 WITH noconstant(0), protect
 DECLARE t2 = i4 WITH noconstant(0), protect
 DECLARE max_val = i4 WITH noconstant(200), protect
 DECLARE t_val = i4 WITH noconstant(xref->chg_cnt), protect
 DECLARE f_val = i4 WITH noconstant(1), protect
 DECLARE idx = i4 WITH noconstant(0), protect
 DECLARE chg_cnt = i4 WITH noconstant(xref->chg_cnt), protect
 DECLARE index = i4 WITH protect, noconstant(0)
 DECLARE active_status_prsnl_id = f8 WITH protect, noconstant(0.0)
 DECLARE active_status_dt_tm = f8 WITH protect, noconstant(0.0)
 FOR (index = 1 TO xref->chg_cnt)
   SET reply->person_qual[xref->chg[index].idx].status = 0
 ENDFOR
 IF (t_val <= max_val)
  SET max_val = t_val
  CALL getexistingrows(max_val)
 ELSE
  SET t_val = max_val
  WHILE (chg_cnt > 0)
    CALL getexistingrows(max_val)
    SET chg_cnt -= max_val
    SET f_val = (t_val+ 1)
    IF (chg_cnt > max_val)
     SET t_val += max_val
    ELSE
     SET t_val += chg_cnt
    ENDIF
  ENDWHILE
 ENDIF
 UPDATE  FROM (dummyt d  WITH seq = value(xref->chg_cnt)),
   person p
  SET p.person_id = acm_request->person_qual[xref->chg[d.seq].idx].person_id, p.autopsy_cd =
   acm_request->person_qual[xref->chg[d.seq].idx].autopsy_cd, p.beg_effective_dt_tm = cnvtdatetime(
    acm_request->person_qual[xref->chg[d.seq].idx].beg_effective_dt_tm),
   p.birth_dt_cd = acm_request->person_qual[xref->chg[d.seq].idx].birth_dt_cd, p.birth_dt_tm =
   IF ((acm_request->person_qual[xref->chg[d.seq].idx].birth_dt_tm > 0)) cnvtdatetime(acm_request->
     person_qual[xref->chg[d.seq].idx].birth_dt_tm)
   ELSE null
   ENDIF
   , p.cause_of_death = acm_request->person_qual[xref->chg[d.seq].idx].cause_of_death,
   p.cause_of_death_cd = acm_request->person_qual[xref->chg[d.seq].idx].cause_of_death_cd, p
   .citizenship_cd = acm_request->person_qual[xref->chg[d.seq].idx].citizenship_cd, p
   .conception_dt_tm =
   IF ((acm_request->person_qual[xref->chg[d.seq].idx].conception_dt_tm > 0)) cnvtdatetime(
     acm_request->person_qual[xref->chg[d.seq].idx].conception_dt_tm)
   ELSE null
   ENDIF
   ,
   p.confid_level_cd = acm_request->person_qual[xref->chg[d.seq].idx].confid_level_cd, p
   .contributor_system_cd =
   IF ((acm_request->person_qual[xref->chg[d.seq].idx].contributor_system_cd > 0.0)) acm_request->
    person_qual[xref->chg[d.seq].idx].contributor_system_cd
   ELSE pmhc_contributory_system_cd
   ENDIF
   , p.deceased_cd = acm_request->person_qual[xref->chg[d.seq].idx].deceased_cd,
   p.deceased_dt_tm =
   IF ((acm_request->person_qual[xref->chg[d.seq].idx].deceased_dt_tm > 0)) cnvtdatetime(acm_request
     ->person_qual[xref->chg[d.seq].idx].deceased_dt_tm)
   ELSE null
   ENDIF
   , p.deceased_source_cd = acm_request->person_qual[xref->chg[d.seq].idx].deceased_source_cd, p
   .end_effective_dt_tm = cnvtdatetime(acm_request->person_qual[xref->chg[d.seq].idx].
    end_effective_dt_tm),
   p.ethnic_grp_cd = acm_request->person_qual[xref->chg[d.seq].idx].ethnic_grp_cd, p.ft_entity_id =
   acm_request->person_qual[xref->chg[d.seq].idx].ft_entity_id, p.ft_entity_name = acm_request->
   person_qual[xref->chg[d.seq].idx].ft_entity_name,
   p.language_cd = acm_request->person_qual[xref->chg[d.seq].idx].language_cd, p.language_dialect_cd
    = acm_request->person_qual[xref->chg[d.seq].idx].language_dialect_cd, p.last_encntr_dt_tm =
   IF ((acm_request->person_qual[xref->chg[d.seq].idx].last_encntr_dt_tm > 0)) cnvtdatetime(
     acm_request->person_qual[xref->chg[d.seq].idx].last_encntr_dt_tm)
   ELSE null
   ENDIF
   ,
   p.marital_type_cd = acm_request->person_qual[xref->chg[d.seq].idx].marital_type_cd, p
   .military_base_location = acm_request->person_qual[xref->chg[d.seq].idx].military_base_location, p
   .military_rank_cd = acm_request->person_qual[xref->chg[d.seq].idx].military_rank_cd,
   p.military_service_cd = acm_request->person_qual[xref->chg[d.seq].idx].military_service_cd, p
   .mother_maiden_name = acm_request->person_qual[xref->chg[d.seq].idx].mother_maiden_name, p
   .name_first = acm_request->person_qual[xref->chg[d.seq].idx].name_first,
   p.name_first_key = trim(cnvtupper(cnvtalphanum(acm_request->person_qual[xref->chg[d.seq].idx].
      name_first)),3), p.name_first_phonetic = acm_request->person_qual[xref->chg[d.seq].idx].
   name_first_phonetic, p.name_first_synonym_id = acm_request->person_qual[xref->chg[d.seq].idx].
   name_first_synonym_id,
   p.name_full_formatted = acm_request->person_qual[xref->chg[d.seq].idx].name_full_formatted, p
   .name_last = acm_request->person_qual[xref->chg[d.seq].idx].name_last, p.name_last_key = trim(
    cnvtupper(cnvtalphanum(acm_request->person_qual[xref->chg[d.seq].idx].name_last)),3),
   p.name_last_phonetic = acm_request->person_qual[xref->chg[d.seq].idx].name_last_phonetic, p
   .name_middle = acm_request->person_qual[xref->chg[d.seq].idx].name_middle, p.name_middle_key =
   trim(cnvtupper(cnvtalphanum(acm_request->person_qual[xref->chg[d.seq].idx].name_middle)),3),
   p.name_phonetic = acm_request->person_qual[xref->chg[d.seq].idx].name_phonetic, p.nationality_cd
    = acm_request->person_qual[xref->chg[d.seq].idx].nationality_cd, p.person_type_cd = acm_request->
   person_qual[xref->chg[d.seq].idx].person_type_cd,
   p.race_cd = acm_request->person_qual[xref->chg[d.seq].idx].race_cd, p.religion_cd = acm_request->
   person_qual[xref->chg[d.seq].idx].religion_cd, p.sex_age_change_ind = acm_request->person_qual[
   xref->chg[d.seq].idx].sex_age_change_ind,
   p.sex_cd = acm_request->person_qual[xref->chg[d.seq].idx].sex_cd, p.species_cd = acm_request->
   person_qual[xref->chg[d.seq].idx].species_cd, p.vet_military_status_cd = acm_request->person_qual[
   xref->chg[d.seq].idx].vet_military_status_cd,
   p.vip_cd = acm_request->person_qual[xref->chg[d.seq].idx].vip_cd, p.birth_tz =
   IF ((acm_request->person_qual[xref->chg[d.seq].idx].birth_tz > 0)) acm_request->person_qual[xref->
    chg[d.seq].idx].birth_tz
   ELSE curtimezoneapp
   ENDIF
   , p.abs_birth_dt_tm =
   IF ((acm_request->person_qual[xref->chg[d.seq].idx].birth_dt_tm != 0))
    IF (curutc)
     IF ((acm_request->person_qual[xref->chg[d.seq].idx].birth_tz <= 0)) datetimezone(acm_request->
       person_qual[xref->chg[d.seq].idx].birth_dt_tm,curtimezoneapp)
     ELSE datetimezone(acm_request->person_qual[xref->chg[d.seq].idx].birth_dt_tm,acm_request->
       person_qual[xref->chg[d.seq].idx].birth_tz)
     ENDIF
    ELSE cnvtdatetime(acm_request->person_qual[xref->chg[d.seq].idx].birth_dt_tm)
    ENDIF
   ELSE null
   ENDIF
   ,
   p.birth_prec_flag = acm_request->person_qual[xref->chg[d.seq].idx].birth_prec_flag, p.age_at_death
    = acm_request->person_qual[xref->chg[d.seq].idx].age_at_death, p.age_at_death_unit_cd =
   acm_request->person_qual[xref->chg[d.seq].idx].age_at_death_unit_cd,
   p.age_at_death_prec_mod_flag = acm_request->person_qual[xref->chg[d.seq].idx].
   age_at_death_prec_mod_flag, p.deceased_tz = acm_request->person_qual[xref->chg[d.seq].idx].
   deceased_tz, p.deceased_dt_tm_prec_flag = acm_request->person_qual[xref->chg[d.seq].idx].
   deceased_dt_tm_prec_flag,
   p.active_ind = acm_request->person_qual[xref->chg[d.seq].idx].active_ind, p.active_status_cd =
   acm_request->person_qual[xref->chg[d.seq].idx].active_status_cd, p.active_status_prsnl_id =
   active_status_prsnl_id,
   p.active_status_dt_tm = cnvtdatetime(active_status_dt_tm), p.updt_cnt = (p.updt_cnt+ 1), p
   .updt_dt_tm = cnvtdatetime(sysdate),
   p.updt_id = reqinfo->updt_id, p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->
   updt_task
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=acm_request->person_qual[xref->chg[d.seq].idx].person_id))
  WITH nocounter, status(reply->person_qual[xref->chg[d.seq].idx].status)
 ;end update
 FOR (index = 1 TO xref->chg_cnt)
   IF ((reply->person_qual[xref->chg[index].idx].status != 1))
    SET failed = update_error
    SET table_name = "PERSON"
    GO TO exit_script
   ENDIF
 ENDFOR
 IF (acm_hist_ind=1)
  EXECUTE acm_chg_person_hist
  IF ((reply->status_data.status="F"))
   SET failed = true
   GO TO exit_script
  ENDIF
 ENDIF
 SUBROUTINE getexistingrows(x)
   SELECT INTO "nl:"
    FROM person p
    WHERE expand(t1,f_val,t_val,p.person_id,acm_request->person_qual[xref->chg[t1].idx].person_id,
     max_val)
    DETAIL
     t2 = locateval(t1,f_val,t_val,p.person_id,acm_request->person_qual[xref->chg[t1].idx].person_id,
      max_val), idx = xref->chg[t2].idx
     IF ((((p.updt_cnt=acm_request->person_qual[idx].updt_cnt)) OR ((acm_request->force_updt_ind=1)
     )) )
      reply->person_qual[idx].status = - (1), reply->person_qual[idx].person_id = acm_request->
      person_qual[idx].person_id
     ELSE
      failed = update_cnt_error
     ENDIF
     chg_str = acm_request->person_qual[idx].chg_str
     IF (findstring("AUTOPSY_CD,",chg_str)=0)
      acm_request->person_qual[idx].autopsy_cd = p.autopsy_cd
     ENDIF
     IF (findstring("BEG_EFFECTIVE_DT_TM,",chg_str)=0)
      acm_request->person_qual[idx].beg_effective_dt_tm = p.beg_effective_dt_tm
     ENDIF
     IF (findstring("BIRTH_DT_CD,",chg_str)=0)
      acm_request->person_qual[idx].birth_dt_cd = p.birth_dt_cd
     ENDIF
     IF (findstring("BIRTH_DT_TM,",chg_str)=0)
      acm_request->person_qual[idx].birth_dt_tm = p.birth_dt_tm
     ENDIF
     IF (findstring("CAUSE_OF_DEATH,",chg_str)=0)
      acm_request->person_qual[idx].cause_of_death = p.cause_of_death
     ENDIF
     IF (findstring("CAUSE_OF_DEATH_CD,",chg_str)=0)
      acm_request->person_qual[idx].cause_of_death_cd = p.cause_of_death_cd
     ENDIF
     IF (findstring("CITIZENSHIP_CD,",chg_str)=0)
      acm_request->person_qual[idx].citizenship_cd = p.citizenship_cd
     ENDIF
     IF (findstring("CONCEPTION_DT_TM,",chg_str)=0)
      acm_request->person_qual[idx].conception_dt_tm = p.conception_dt_tm
     ENDIF
     IF (findstring("CONFID_LEVEL_CD,",chg_str)=0)
      acm_request->person_qual[idx].confid_level_cd = p.confid_level_cd
     ENDIF
     IF (findstring("CONTRIBUTOR_SYSTEM_CD,",chg_str)=0)
      acm_request->person_qual[idx].contributor_system_cd = p.contributor_system_cd
     ENDIF
     IF (findstring("DECEASED_CD,",chg_str)=0)
      acm_request->person_qual[idx].deceased_cd = p.deceased_cd
     ENDIF
     IF (findstring("DECEASED_DT_TM,",chg_str)=0)
      acm_request->person_qual[idx].deceased_dt_tm = p.deceased_dt_tm
     ENDIF
     IF (findstring("DECEASED_SOURCE_CD,",chg_str)=0)
      acm_request->person_qual[idx].deceased_source_cd = p.deceased_source_cd
     ENDIF
     IF (findstring("END_EFFECTIVE_DT_TM,",chg_str)=0)
      acm_request->person_qual[idx].end_effective_dt_tm = p.end_effective_dt_tm
     ENDIF
     IF (findstring("ETHNIC_GRP_CD,",chg_str)=0)
      acm_request->person_qual[idx].ethnic_grp_cd = p.ethnic_grp_cd
     ENDIF
     IF (findstring("FT_ENTITY_ID,",chg_str)=0)
      acm_request->person_qual[idx].ft_entity_id = p.ft_entity_id
     ENDIF
     IF (findstring("FT_ENTITY_NAME,",chg_str)=0)
      acm_request->person_qual[idx].ft_entity_name = p.ft_entity_name
     ENDIF
     IF (findstring("LANGUAGE_CD,",chg_str)=0)
      acm_request->person_qual[idx].language_cd = p.language_cd
     ENDIF
     IF (findstring("LANGUAGE_DIALECT_CD,",chg_str)=0)
      acm_request->person_qual[idx].language_dialect_cd = p.language_dialect_cd
     ENDIF
     IF (findstring("LAST_ENCNTR_DT_TM,",chg_str)=0)
      acm_request->person_qual[idx].last_encntr_dt_tm = p.last_encntr_dt_tm
     ENDIF
     IF (findstring("MARITAL_TYPE_CD,",chg_str)=0)
      acm_request->person_qual[idx].marital_type_cd = p.marital_type_cd
     ENDIF
     IF (findstring("MILITARY_BASE_LOCATION,",chg_str)=0)
      acm_request->person_qual[idx].military_base_location = p.military_base_location
     ENDIF
     IF (findstring("MILITARY_RANK_CD,",chg_str)=0)
      acm_request->person_qual[idx].military_rank_cd = p.military_rank_cd
     ENDIF
     IF (findstring("MILITARY_SERVICE_CD,",chg_str)=0)
      acm_request->person_qual[idx].military_service_cd = p.military_service_cd
     ENDIF
     IF (findstring("MOTHER_MAIDEN_NAME,",chg_str)=0)
      acm_request->person_qual[idx].mother_maiden_name = p.mother_maiden_name
     ENDIF
     IF (findstring("NAME_FIRST,",chg_str) != 0
      AND findstring("NAME_LAST,",chg_str) != 0)
      acm_request->person_qual[idx].name_last_phonetic = soundex(cnvtupper(trim(acm_request->
         person_qual[idx].name_last))), acm_request->person_qual[idx].name_first_phonetic = soundex(
       cnvtupper(trim(acm_request->person_qual[idx].name_first))), acm_request->person_qual[idx].
      name_phonetic = soundex(cnvtupper(concat(trim(acm_request->person_qual[idx].name_last),trim(
          acm_request->person_qual[idx].name_first))))
     ELSEIF (findstring("NAME_FIRST,",chg_str) != 0
      AND findstring("NAME_LAST,",chg_str)=0)
      acm_request->person_qual[idx].name_last = p.name_last, acm_request->person_qual[idx].
      name_last_phonetic = p.name_last_phonetic, acm_request->person_qual[idx].name_first_phonetic =
      soundex(cnvtupper(trim(acm_request->person_qual[idx].name_first))),
      acm_request->person_qual[idx].name_phonetic = soundex(cnvtupper(concat(trim(p.name_last),trim(
          acm_request->person_qual[idx].name_first))))
     ELSEIF (findstring("NAME_FIRST,",chg_str)=0
      AND findstring("NAME_LAST,",chg_str) != 0)
      acm_request->person_qual[idx].name_first = p.name_first, acm_request->person_qual[idx].
      name_first_phonetic = p.name_first_phonetic, acm_request->person_qual[idx].name_last_phonetic
       = soundex(cnvtupper(trim(acm_request->person_qual[idx].name_last))),
      acm_request->person_qual[idx].name_phonetic = soundex(cnvtupper(concat(trim(acm_request->
          person_qual[idx].name_last),trim(p.name_first))))
     ELSEIF (findstring("NAME_FIRST,",chg_str)=0
      AND findstring("NAME_LAST,",chg_str)=0)
      acm_request->person_qual[idx].name_first = p.name_first, acm_request->person_qual[idx].
      name_last = p.name_last, acm_request->person_qual[idx].name_last_phonetic = p
      .name_last_phonetic,
      acm_request->person_qual[idx].name_first_phonetic = p.name_first_phonetic, acm_request->
      person_qual[idx].name_phonetic = p.name_phonetic
     ENDIF
     IF (findstring("NAME_FIRST_SYNONYM_ID,",chg_str)=0)
      acm_request->person_qual[idx].name_first_synonym_id = p.name_first_synonym_id
     ENDIF
     IF (findstring("NAME_FULL_FORMATTED,",chg_str)=0)
      acm_request->person_qual[idx].name_full_formatted = p.name_full_formatted
     ENDIF
     IF (findstring("NAME_MIDDLE,",chg_str)=0)
      acm_request->person_qual[idx].name_middle = p.name_middle
     ENDIF
     IF (findstring("NATIONALITY_CD,",chg_str)=0)
      acm_request->person_qual[idx].nationality_cd = p.nationality_cd
     ENDIF
     IF (findstring("PERSON_TYPE_CD,",chg_str)=0)
      acm_request->person_qual[idx].person_type_cd = p.person_type_cd
     ENDIF
     IF (findstring("RACE_CD,",chg_str)=0)
      acm_request->person_qual[idx].race_cd = p.race_cd
     ENDIF
     IF (findstring("RELIGION_CD,",chg_str)=0)
      acm_request->person_qual[idx].religion_cd = p.religion_cd
     ENDIF
     IF (findstring("SEX_AGE_CHANGE_IND,",chg_str)=0)
      acm_request->person_qual[idx].sex_age_change_ind = p.sex_age_change_ind
     ENDIF
     IF (findstring("SEX_CD,",chg_str)=0)
      acm_request->person_qual[idx].sex_cd = p.sex_cd
     ENDIF
     IF (findstring("SPECIES_CD,",chg_str)=0)
      acm_request->person_qual[idx].species_cd = p.species_cd
     ENDIF
     IF (findstring("VET_MILITARY_STATUS_CD,",chg_str)=0)
      acm_request->person_qual[idx].vet_military_status_cd = p.vet_military_status_cd
     ENDIF
     IF (findstring("VIP_CD,",chg_str)=0)
      acm_request->person_qual[idx].vip_cd = p.vip_cd
     ENDIF
     IF (findstring("BIRTH_TZ,",chg_str)=0)
      acm_request->person_qual[idx].birth_tz = p.birth_tz
     ENDIF
     IF (findstring("ABS_BIRTH_DT_TM,",chg_str)=0)
      acm_request->person_qual[idx].abs_birth_dt_tm = p.abs_birth_dt_tm
     ENDIF
     IF (findstring("BIRTH_PREC_FLAG,",chg_str)=0)
      acm_request->person_qual[idx].birth_prec_flag = p.birth_prec_flag
     ENDIF
     IF (findstring("AGE_AT_DEATH,",chg_str)=0)
      acm_request->person_qual[idx].age_at_death = p.age_at_death
     ENDIF
     IF (findstring("AGE_AT_DEATH_UNIT_CD,",chg_str)=0)
      acm_request->person_qual[idx].age_at_death_unit_cd = p.age_at_death_unit_cd
     ENDIF
     IF (findstring("AGE_AT_DEATH_PREC_MOD_FLAG,",chg_str)=0)
      acm_request->person_qual[idx].age_at_death_prec_mod_flag = p.age_at_death_prec_mod_flag
     ENDIF
     IF (findstring("DECEASED_TZ,",chg_str)=0)
      acm_request->person_qual[idx].deceased_tz = p.deceased_tz
     ENDIF
     IF (findstring("DECEASED_DT_TM_PREC_FLAG,",chg_str)=0)
      acm_request->person_qual[idx].deceased_dt_tm_prec_flag = p.deceased_dt_tm_prec_flag
     ENDIF
     IF (findstring("ACTIVE_IND,",chg_str)=0)
      acm_request->person_qual[idx].active_ind = p.active_ind
     ENDIF
     IF (findstring("ACTIVE_STATUS_CD,",chg_str)=0)
      acm_request->person_qual[idx].active_status_cd = p.active_status_cd
     ENDIF
     IF (((findstring("ACTIVE_IND,",chg_str) != 0) OR (findstring("ACTIVE_STATUS_CD,",chg_str) != 0
     )) )
      active_status_prsnl_id = reqinfo->updt_id, active_status_dt_tm = cnvtdatetime(sysdate)
     ELSE
      active_status_prsnl_id = p.active_status_prsnl_id, active_status_dt_tm = cnvtdatetime(p
       .active_status_dt_tm)
     ENDIF
    WITH nocounter, forupdatewait(p), time = 5
   ;end select
   IF (failed)
    SET table_name = "PERSON"
    GO TO exit_script
   ENDIF
   FOR (index = f_val TO t_val)
     IF ((reply->person_qual[xref->chg[index].idx].status=0))
      SET failed = select_error
      SET table_name = "PERSON"
      GO TO exit_script
     ENDIF
   ENDFOR
 END ;Subroutine
#exit_script
 IF (failed)
  SET reply->status_data.status = "F"
  IF (failed != true
   AND failed != false)
   IF ((validate(pm_subeventstatus_sub_,- (99))=- (99)))
    DECLARE pm_subeventstatus_sub_ = i2 WITH public, constant(1)
    SUBROUTINE (s_next_subeventstatus(s_null=i4) =i4)
      DECLARE s_stat = i4 WITH private, noconstant(0)
      DECLARE stx1 = i4 WITH private, noconstant(size(reply->status_data.subeventstatus,5))
      IF ((((reply->status_data.subeventstatus[stx1].operationname > " ")) OR ((((reply->status_data.
      subeventstatus[stx1].operationstatus > " ")) OR ((((reply->status_data.subeventstatus[stx1].
      targetobjectname > " ")) OR ((reply->status_data.subeventstatus[stx1].targetobjectvalue > " ")
      )) )) )) )
       SET stx1 += 1
       SET s_stat = alter(reply->status_data.subeventstatus,stx1)
      ENDIF
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE (s_add_subeventstatus(s_oname=vc,s_ostatus=c1,s_tname=vc,s_tvalue=vc) =i4)
      DECLARE stx1 = i4 WITH private, noconstant(s_next_subeventstatus(1))
      SET reply->status_data.subeventstatus[stx1].operationname = s_oname
      SET reply->status_data.subeventstatus[stx1].operationstatus = s_ostatus
      SET reply->status_data.subeventstatus[stx1].targetobjectname = s_tname
      SET reply->status_data.subeventstatus[stx1].targetobjectvalue = s_tvalue
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE (s_add_subeventstatus_cclerr(s_null=i4) =i4)
      DECLARE serrmsg = vc WITH private, noconstant("")
      DECLARE ierrcode = i4 WITH private, noconstant(1)
      WHILE (ierrcode)
       SET ierrcode = error(serrmsg,0)
       IF (ierrcode)
        CALL s_add_subeventstatus("CCLERR","F",trim(curprog),serrmsg)
       ENDIF
      ENDWHILE
      RETURN(1)
    END ;Subroutine
    SUBROUTINE (s_log_subeventstatus(s_null=i4) =i4)
      DECLARE wi = i4 WITH protect, noconstant(0)
      DECLARE s_curprog = vc WITH protect, constant(curprog)
      FOR (wi = 1 TO size(reply->status_data.subeventstatus,5))
        CALL s_sch_msgview(s_curprog,nullterm(build(reply->status_data.subeventstatus[wi].
           operationname,",",reply->status_data.subeventstatus[wi].operationstatus,",",reply->
           status_data.subeventstatus[wi].targetobjectname,
           ",",reply->status_data.subeventstatus[wi].targetobjectvalue)),0)
      ENDFOR
    END ;Subroutine
    SUBROUTINE (s_clear_subeventstatus(s_null=i4) =i4)
      SET stat = alter(reply->status_data.subeventstatus,1)
      SET reply->status_data.subeventstatus[1].operationname = ""
      SET reply->status_data.subeventstatus[1].operationstatus = ""
      SET reply->status_data.subeventstatus[1].targetobjectname = ""
      SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
    END ;Subroutine
    SUBROUTINE (s_sch_msgview(t_event=vc,t_message=vc,t_log_level=i4) =i2)
     IF (t_event > " "
      AND t_log_level BETWEEN 0 AND 4
      AND t_message > " ")
      DECLARE hlog = i4 WITH protect, noconstant(0)
      DECLARE hstat = i4 WITH protect, noconstant(0)
      CALL uar_syscreatehandle(hlog,hstat)
      IF (hlog != 0)
       CALL uar_sysevent(hlog,t_log_level,nullterm(t_event),nullterm(t_message))
       CALL uar_sysdestroyhandle(hlog)
      ENDIF
     ENDIF
     RETURN(1)
    END ;Subroutine
   ENDIF
   CASE (failed)
    OF lock_error:
     CALL s_add_subeventstatus("LOCK","F",trim(curprog),table_name)
    OF select_error:
     CALL s_add_subeventstatus("SELECT","F",trim(curprog),table_name)
    OF update_error:
     CALL s_add_subeventstatus("UPDATE","F",trim(curprog),table_name)
    OF insert_error:
     CALL s_add_subeventstatus("INSERT","F",trim(curprog),table_name)
    OF gen_nbr_error:
     CALL s_add_subeventstatus("GEN_NBR","F",trim(curprog),table_name)
    OF replace_error:
     CALL s_add_subeventstatus("REPLACE","F",trim(curprog),table_name)
    OF delete_error:
     CALL s_add_subeventstatus("DELETE","F",trim(curprog),table_name)
    OF undelete_error:
     CALL s_add_subeventstatus("UNDELETE","F",trim(curprog),table_name)
    OF remove_error:
     CALL s_add_subeventstatus("REMOVE","F",trim(curprog),table_name)
    OF attribute_error:
     CALL s_add_subeventstatus("ATTRIBUTE","F",trim(curprog),table_name)
    OF none_found:
     CALL s_add_subeventstatus("NONE_FOUND","F",trim(curprog),table_name)
    OF update_cnt_error:
     CALL s_add_subeventstatus("UPDATE_CNT","F",trim(curprog),table_name)
    OF not_found:
     CALL s_add_subeventstatus("NOT_FOUND","F",trim(curprog),table_name)
    OF inactivate_error:
     CALL s_add_subeventstatus("INACTIVATE","F",trim(curprog),table_name)
    OF activate_error:
     CALL s_add_subeventstatus("ACTIVATE","F",trim(curprog),table_name)
    OF uar_error:
     CALL s_add_subeventstatus("UAR_ERROR","F",trim(curprog),table_name)
    OF execute_error:
     CALL s_add_subeventstatus("EXECUTE","F",trim(curprog),table_name)
    OF duplicate_error:
     CALL s_add_subeventstatus("DUPLICATE","F",trim(curprog),table_name)
    OF ccl_error:
     CALL s_add_subeventstatus("CCLERROR","F",trim(curprog),table_name)
    ELSE
     CALL s_add_subeventstatus("UNKNOWN","F",trim(curprog),table_name)
   ENDCASE
   SET reqinfo->commit_ind = false
   CALL s_add_subeventstatus_cclerr(1)
   CALL s_log_subeventstatus(1)
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
