CREATE PROGRAM cv_import_dta:dba
 RECORD nomen(
   1 qual_nomen[*]
     2 nomenclature_id = f8
     2 mnemonic = vc
 )
 RECORD acts(
   1 qual_acts[*]
     2 act_id = f8
     2 act_description = vc
 )
 RECORD result(
   1 qual_result[*]
     2 result_type_cd = f8
     2 display_key = vc
 )
 RECORD bb_result(
   1 qual_bb_result[*]
     2 bb_result_processing_cd = f8
     2 display_key = vc
 )
 RECORD rad(
   1 qual_rad[*]
     2 rad_section_type_cd = f8
     2 display_key = vc
 )
 RECORD sex(
   1 qual_sex[*]
     2 sex_cd = f8
     2 display_key = vc
 )
 RECORD agefrom(
   1 qual_agefrom[*]
     2 age_from_units_cd = f8
     2 display_key = vc
 )
 RECORD ageto(
   1 qual_ageto[*]
     2 age_to_units_cd = f8
     2 display_key = vc
 )
 RECORD specimen(
   1 qual_specimen[*]
     2 specimen_type_cd = f8
     2 display_key = vc
 )
 RECORD service(
   1 qual_service[*]
     2 service_resource_cd = f8
     2 display_key = vc
 )
 RECORD species(
   1 qual_species[*]
     2 species_cd = f8
     2 display_key = vc
 )
 RECORD encntr(
   1 qual_encntr[*]
     2 encntr_type_cd = f8
     2 display_key = vc
 )
 RECORD units(
   1 qual_units[*]
     2 units_cd = f8
     2 display_key = vc
 )
 RECORD unitsind(
   1 qual_unitsind[*]
     2 use_units_ind = f8
     2 display_key = vc
 )
 RECORD resultproc(
   1 qual_resultproc[*]
     2 result_process_cd = f8
     2 display_key = vc
 )
 SET seq1 = 0
 SET reference_range_id = 0
 SET units1 = fillstring(12," ")
 SET mins = 0
 SET nums = 0
 SET task_assay_cd = 0.0
 SET orcid = 0
 SET name_error = "F"
 SET dup_oef = "F"
 SET oef_error = "F"
 SET ref_error = "F"
 SET oeactcode = 0
 SET oenomencode = 0
 SET oeresultcode = 0
 SET oebbresultcode = 0
 SET oeradcode = 0
 SET oesexcode = 0
 SET oeagefromcode = 0
 SET oeagetocode = 0
 SET oespecimencode = 0
 SET oeservicecode = 0
 SET oespeciescode = 0
 SET oeencntrcode = 0
 SET oeunitscode = 0
 SET oeunitsindcode = 0
 SET oeresultproccode = 0
 SET formname = fillstring(12," ")
 SET event_cd = 0
 SET temp_task_description = fillstring(100," ")
 SET temp_event_cd = 0
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET reqinfo->updt_applctx = 1
 SET reqinfo->updt_task = 1
 SET reqinfo->commit_ind = 1
 SET code_value = 0.0
 SET code_set = 400
 SET cdf_meaning = "PTCARE"
 EXECUTE cpm_get_cd_for_cdf
 SET source_vocab_cd = code_value
 SET code_value = 0.0
 SET code_set = 401
 SET cdf_meaning = "ALPHA RESPON"
 EXECUTE cpm_get_cd_for_cdf
 SET alpha_cd = code_value
 SET code_value = 0.0
 SET code_set = 8
 SET cdf_meaning = "AUTH"
 EXECUTE cpm_get_cd_for_cdf
 SET reqdata->data_status_cd = code_value
 SET code_value = 0.0
 SET code_set = 48
 SET cdf_meaning = "ACTIVE"
 EXECUTE cpm_get_cd_for_cdf
 SET reqdata->active_status_cd = code_value
 SET code_value = 0.0
 SET code_set = 48
 SET cdf_meaning = "INACTIVE"
 EXECUTE cpm_get_cd_for_cdf
 SET reqdata->inactive_status_cd = code_value
 SET rvar = 0
 SELECT INTO "cv_import_dta.log"
  rvar
  HEAD REPORT
   curdate"dd-mmm-yyyy;;d", "-", curtime"hh:mm;;m",
   col + 1, "DTA Entry Import Log"
  DETAIL
   col 0
  WITH nocounter, format = variable, noformfeed,
   maxcol = 132, maxrow = 1
 ;end select
 SET num_nomen_codes = 0
 SELECT INTO "nl:"
  n.nomenclature_id
  FROM nomenclature n
  WHERE n.principle_type_cd=alpha_cd
   AND n.source_vocabulary_cd=source_vocab_cd
   AND n.active_ind=1
   AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  ORDER BY n.mnemonic
  DETAIL
   num_nomen_codes = (num_nomen_codes+ 1)
   IF (num_nomen_codes > size(nomen->qual_nomen,5))
    stat = alterlist(nomen->qual_nomen,(num_nomen_codes+ 5))
   ENDIF
   nomen->qual_nomen[num_nomen_codes].nomenclature_id = n.nomenclature_id, nomen->qual_nomen[
   num_nomen_codes].mnemonic = n.mnemonic
  WITH nocounter
 ;end select
 SET stat = alterlist(nomen->qual_nomen,num_nomen_codes)
 SET num_act_codes = 0
 SELECT INTO "nl:"
  ca.code_value
  FROM code_value ca
  WHERE ca.code_set=106
  DETAIL
   num_act_codes = (num_act_codes+ 1)
   IF (num_act_codes > size(acts->qual_acts,5))
    stat = alterlist(acts->qual_acts,(num_act_codes+ 10))
   ENDIF
   acts->qual_acts[num_act_codes].act_id = ca.code_value, acts->qual_acts[num_act_codes].
   act_description = ca.display_key
  WITH nocounter
 ;end select
 SET stat = alterlist(acts->qual_acts,num_act_codes)
 SET num_result_codes = 0
 SELECT INTO "nl:"
  ca.code_value
  FROM code_value ca
  WHERE ca.code_set=289
  DETAIL
   num_result_codes = (num_result_codes+ 1)
   IF (num_result_codes > size(result->qual_result,5))
    stat = alterlist(result->qual_result,(num_result_codes+ 10))
   ENDIF
   result->qual_result[num_result_codes].result_type_cd = ca.code_value, result->qual_result[
   num_result_codes].display_key = ca.display_key
  WITH nocounter
 ;end select
 SET stat = alterlist(result->qual_result,num_result_codes)
 SET num_bbresult_codes = 0
 SELECT INTO "nl:"
  ca.code_value
  FROM code_value ca
  WHERE ca.code_set=1636
  DETAIL
   num_bbresult_codes = (num_bbresult_codes+ 1)
   IF (num_bbresult_codes > size(bb_result->qual_bb_result,5))
    stat = alterlist(bb_result->qual_bb_result,(num_bbresult_codes+ 10))
   ENDIF
   bb_result->qual_bb_result[num_bbresult_codes].bb_result_processing_cd = ca.code_value, bb_result->
   qual_bb_result[num_bbresult_codes].display_key = ca.display_key
  WITH nocounter
 ;end select
 SET stat = alterlist(bb_result->qual_bb_result,num_bbresult_codes)
 SET num_rad_codes = 0
 SELECT INTO "nl:"
  ca.code_value
  FROM code_value ca
  WHERE ca.code_set=14286
  DETAIL
   num_rad_codes = (num_rad_codes+ 1)
   IF (num_rad_codes > size(rad->qual_rad,5))
    stat = alterlist(rad->qual_rad,(num_rad_codes+ 10))
   ENDIF
   rad->qual_rad[num_rad_codes].rad_section_type_cd = ca.code_value, rad->qual_rad[num_rad_codes].
   display_key = ca.display_key
  WITH nocounter
 ;end select
 SET stat = alterlist(rad->qual_rad,num_rad_codes)
 SET num_sex_codes = 0
 SELECT INTO "nl:"
  ca.code_value
  FROM code_value ca
  WHERE ca.code_set=57
  DETAIL
   num_sex_codes = (num_sex_codes+ 1)
   IF (num_sex_codes > size(sex->qual_sex,5))
    stat = alterlist(sex->qual_sex,(num_sex_codes+ 10))
   ENDIF
   sex->qual_sex[num_sex_codes].sex_cd = ca.code_value, sex->qual_sex[num_sex_codes].display_key = ca
   .display_key
  WITH nocounter
 ;end select
 SET stat = alterlist(sex->qual_sex,num_sex_codes)
 SET num_agefrom_codes = 0
 SELECT INTO "nl:"
  ca.code_value
  FROM code_value ca
  WHERE ca.code_set=340
  DETAIL
   num_agefrom_codes = (num_agefrom_codes+ 1)
   IF (num_agefrom_codes > size(agefrom->qual_agefrom,5))
    stat = alterlist(agefrom->qual_agefrom,(num_agefrom_codes+ 10))
   ENDIF
   agefrom->qual_agefrom[num_agefrom_codes].age_from_units_cd = ca.code_value, agefrom->qual_agefrom[
   num_agefrom_codes].display_key = ca.display_key
  WITH nocounter
 ;end select
 SET stat = alterlist(agefrom->qual_agefrom,num_agefrom_codes)
 SET num_ageto_codes = 0
 SELECT INTO "nl:"
  ca.code_value
  FROM code_value ca
  WHERE ca.code_set=340
  DETAIL
   num_ageto_codes = (num_ageto_codes+ 1)
   IF (num_ageto_codes > size(ageto->qual_ageto,5))
    stat = alterlist(ageto->qual_ageto,(num_ageto_codes+ 10))
   ENDIF
   ageto->qual_ageto[num_ageto_codes].age_to_units_cd = ca.code_value, ageto->qual_ageto[
   num_ageto_codes].display_key = ca.display_key
  WITH nocounter
 ;end select
 SET stat = alterlist(ageto->qual_ageto,num_ageto_codes)
 SET num_specimen_codes = 0
 SELECT INTO "nl:"
  ca.code_value
  FROM code_value ca
  WHERE ca.code_set=2052
  DETAIL
   num_specimen_codes = (num_specimen_codes+ 1)
   IF (num_specimen_codes > size(specimen->qual_specimen,5))
    stat = alterlist(specimen->qual_specimen,(num_specimen_codes+ 10))
   ENDIF
   specimen->qual_specimen[num_specimen_codes].specimen_type_cd = ca.code_value, specimen->
   qual_specimen[num_specimen_codes].display_key = ca.display_key
  WITH nocounter
 ;end select
 SET stat = alterlist(specimen->qual_specimen,num_specimen_codes)
 SET num_service_codes = 0
 SELECT INTO "nl:"
  ca.code_value
  FROM code_value ca
  WHERE ca.code_set=221
  DETAIL
   num_service_codes = (num_service_codes+ 1)
   IF (num_service_codes > size(service->qual_service,5))
    stat = alterlist(service->qual_service,(num_service_codes+ 10))
   ENDIF
   service->qual_service[num_service_codes].service_resource_cd = ca.code_value, service->
   qual_service[num_service_codes].display_key = ca.display_key
  WITH nocounter
 ;end select
 SET stat = alterlist(service->qual_service,num_service_codes)
 SET num_species_codes = 0
 SELECT INTO "nl:"
  ca.code_value
  FROM code_value ca
  WHERE ca.code_set=226
  DETAIL
   num_species_codes = (num_species_codes+ 1)
   IF (num_species_codes > size(species->qual_species,5))
    stat = alterlist(species->qual_species,(num_species_codes+ 10))
   ENDIF
   species->qual_species[num_species_codes].species_cd = ca.code_value, species->qual_species[
   num_species_codes].display_key = ca.display_key
  WITH nocounter
 ;end select
 SET stat = alterlist(species->qual_species,num_species_codes)
 SET num_encntr_codes = 0
 SELECT INTO "nl:"
  ca.code_value
  FROM code_value ca
  WHERE ca.code_set=71
  DETAIL
   num_encntr_codes = (num_encntr_codes+ 1)
   IF (num_encntr_codes > size(encntr->qual_encntr,5))
    stat = alterlist(encntr->qual_encntr,(num_encntr_codes+ 10))
   ENDIF
   encntr->qual_encntr[num_encntr_codes].encntr_type_cd = ca.code_value, encntr->qual_encntr[
   num_encntr_codes].display_key = ca.display_key
  WITH nocounter
 ;end select
 SET stat = alterlist(encntr->qual_encntr,num_encntr_codes)
 SET num_unitsind_codes = 0
 SELECT INTO "nl:"
  ca.code_value
  FROM code_value ca
  WHERE ca.code_set=54
  DETAIL
   num_unitsind_codes = (num_unitsind_codes+ 1)
   IF (num_unitsind_codes > size(unitsind->qual_unitsind,5))
    stat = alterlist(unitsind->qual_unitsind,(num_unitsind_codes+ 10))
   ENDIF
   unitsind->qual_unitsind[num_unitsind_codes].use_units_ind = ca.code_value, unitsind->
   qual_unitsind[num_unitsind_codes].display_key = ca.display_key
  WITH nocounter
 ;end select
 SET stat = alterlist(unitsind->qual_unitsind,num_unitsind_codes)
 SET num_resultproc_codes = 0
 SELECT INTO "nl:"
  ca.code_value
  FROM code_value ca
  WHERE ca.code_set=1902
  DETAIL
   num_resultproc_codes = (num_resultproc_codes+ 1)
   IF (num_resultproc_codes > size(resultproc->qual_resultproc,5))
    stat = alterlist(resultproc->qual_resultproc,(num_resultproc_codes+ 10))
   ENDIF
   resultproc->qual_resultproc[num_resultproc_codes].result_process_cd = ca.code_value, resultproc->
   qual_resultproc[num_resultproc_codes].display_key = ca.display_key
  WITH nocounter
 ;end select
 SET stat = alterlist(resultproc->qual_resultproc,num_resultproc_codes)
 SET numrows = size(requestin->list_0,5)
 SET lvar = 1
 SET tvar = 0
 WHILE (lvar <= numrows)
   IF ((((requestin->list_0[lvar].dta_mnemonic=" ")
    AND (requestin->list_0[lvar].mnemonic=" ")) OR (((trim(requestin->list_0[lvar].dta_mnemonic)=
   "discrete_task_assay") OR (((trim(requestin->list_0[lvar].dta_mnemonic)="dta_mnemonic") OR (trim(
    requestin->list_0[lvar].dta_mnemonic)="DTA Mnemonic")) )) )) )
    SET lvar = (lvar+ 1)
   ELSE
    SET oefid = 0
    SET dup_oef = "F"
    SET dup_dta = "F"
    SET status = "F"
    IF ((requestin->list_0[lvar].dta_mnemonic > " "))
     SET task_assay_cd = 0.0
    ENDIF
    CALL checkdup(lvar,oefid)
    IF (dup_oef="F"
     AND (requestin->list_0[lvar].dta_mnemonic > " "))
     CALL createdta(lvar,oefid)
     IF ((((requestin->list_0[lvar].min_digits > " ")) OR ((((requestin->list_0[lvar].max_digits >
     " ")) OR ((requestin->list_0[lvar].min_decimal_places > " ")
      AND task_assay_cd > 0
      AND status="S")) )) )
      CALL createmap(lvar,oefid)
     ENDIF
     IF (task_assay_cd > 0
      AND status="S")
      CALL createref(lvar,oefid)
      SET seq1 = 1
      IF (reference_range_id > 0.0)
       CALL createalpha(lvar,seq1)
      ENDIF
     ENDIF
    ELSE
     IF ((((requestin->list_0[lvar].min_digits > " ")) OR ((((requestin->list_0[lvar].max_digits >
     " ")) OR ((requestin->list_0[lvar].min_decimal_places > " ")
      AND task_assay_cd > 0.0)) )) )
      CALL createmap(lvar,oefid)
     ENDIF
     IF ((((requestin->list_0[lvar].sex_cd > "")) OR ((((requestin->list_0[lvar].age_from_minutes >
     "")) OR ((((requestin->list_0[lvar].age_from_units_cd > "")) OR ((((requestin->list_0[lvar].
     age_to_minutes > "")) OR ((((requestin->list_0[lvar].age_to_units_cd > "")) OR ((((requestin->
     list_0[lvar].gestational_ind > "")) OR ((((requestin->list_0[lvar].specimen_type_cd > "")) OR (
     (((requestin->list_0[lvar].service_resource_cd > "")) OR ((((requestin->list_0[lvar].species_cd
      > "")) OR ((((requestin->list_0[lvar].encntr_type_cd > "")) OR ((((requestin->list_0[lvar].
     normal_low > "")) OR ((((requestin->list_0[lvar].normal_high > "")) OR ((((requestin->list_0[
     lvar].critical_low > "")) OR ((((requestin->list_0[lvar].critical_high > "")) OR ((((requestin->
     list_0[lvar].sensitive_low > "")) OR ((((requestin->list_0[lvar].sensitive_high > "")) OR ((((
     requestin->list_0[lvar].linear_low > "")) OR ((((requestin->list_0[lvar].linear_high > "")) OR (
     (((requestin->list_0[lvar].feasible_low > "")) OR ((((requestin->list_0[lvar].feasible_high > ""
     )) OR ((((requestin->list_0[lvar].units_cd > "")) OR ((requestin->list_0[lvar].mins_back > "")
      AND task_assay_cd > 0.0)) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )
      SET ref_error = "F"
      IF (ref_error="F")
       CALL createref(lvar,oefid)
       SET seq1 = 1
      ELSE
       CALL logadddta(6,reference_range_id,lvar)
      ENDIF
     ENDIF
     IF ((requestin->list_0[lvar].mnemonic > " ")
      AND reference_range_id > 0.0)
      CALL createalpha(lvar,seq1)
      SET seq1 = (seq1+ 1)
     ENDIF
    ENDIF
    SET lvar = (lvar+ 1)
   ENDIF
 ENDWHILE
 GO TO enditnow
 SUBROUTINE checkdup(lvar1,oefid1)
   SET uactcode = trim(cnvtupper(requestin->list_0[lvar1].activity_type_cd))
   SET x = 1
   WHILE (x <= num_act_codes
    AND cnvtupper(acts->qual_acts[x].act_description) != uactcode)
     SET x = (x+ 1)
   ENDWHILE
   IF (x <= num_act_codes)
    IF ((acts->qual_acts[x].act_description > " "))
     SET oeactcode = acts->qual_acts[x].act_id
    ENDIF
   ELSE
    CALL logoeferror(2,lvar1)
    SET oeactcode = 0
    IF (uactcode > " "
     AND (requestin->list_0[lvar1].dta_mnemonic > " "))
     SET dup_oef = "T"
    ENDIF
   ENDIF
   SET num_dupes = 0
   SELECT INTO "nl:"
    FROM discrete_task_assay dta
    WHERE dta.mnemonic_key_cap=trim(cnvtupper(requestin->list_0[lvar1].dta_mnemonic))
     AND oeactcode=dta.activity_type_cd
    DETAIL
     num_dupes = (num_dupes+ 1), dup_oef = "T", dup_dta = "T",
     task_assay_cd = dta.task_assay_cd
    WITH nocounter
   ;end select
   SET oef_error_type = 0
   SET unomencode = trim(cnvtupper(requestin->list_0[lvar1].mnemonic))
   SET x = 1
   WHILE (x <= num_nomen_codes
    AND cnvtupper(nomen->qual_nomen[x].mnemonic) != unomencode)
     SET x = (x+ 1)
   ENDWHILE
   IF (x <= num_nomen_codes)
    IF ((nomen->qual_nomen[x].mnemonic > " "))
     SET oenomencode = nomen->qual_nomen[x].nomenclature_id
    ENDIF
   ELSE
    IF (unomencode > " ")
     CALL logoeferror(1,lvar1)
     SET dup_oef = "T"
    ENDIF
    SET oenomencode = 0
   ENDIF
   SET uresultcode = trim(cnvtupper(requestin->list_0[lvar1].default_result_type_cd))
   SET x = 1
   WHILE (x <= num_result_codes
    AND cnvtupper(result->qual_result[x].display_key) != uresultcode)
     SET x = (x+ 1)
   ENDWHILE
   IF (x <= num_result_codes)
    IF ((result->qual_result[x].display_key > " "))
     SET oeresultcode = result->qual_result[x].result_type_cd
    ENDIF
   ELSE
    CALL logoeferror(3,lvar1)
    SET oeresultcode = 0
    IF (uresultcode > " "
     AND (requestin->list_0[lvar1].dta_mnemonic > " "))
     SET dup_oef = "T"
    ENDIF
   ENDIF
   IF (trim(requestin->list_0[lvar1].event_cd) > ""
    AND dup_oef="F")
    SET event_cd = 0
    SET event_cnt = 0
    SELECT INTO "nl:"
     FROM v500_event_code v
     WHERE cnvtupper(v.event_cd_disp)=trim(cnvtupper(requestin->list_0[lvar1].event_cd))
     DETAIL
      event_cnt = (event_cnt+ 1), event_cd = v.event_cd
     WITH nocounter
    ;end select
    IF (event_cd=0)
     SET temp_task_description = trim(requestin->list_0[lvar1].event_cd)
     SET temp_event_cd = 0
     EXECUTE tsk_post_event_code
     SET event_cd = temp_event_cd
    ENDIF
   ENDIF
   SET ubbresultcode = trim(cnvtupper(requestin->list_0[lvar1].bb_result_processing_cd))
   SET x = 1
   WHILE (x <= num_bbresult_codes
    AND cnvtupper(bb_result->qual_bb_result[x].display_key) != ubbresultcode)
     SET x = (x+ 1)
   ENDWHILE
   IF (x <= num_bbresult_codes)
    IF ((bb_result->qual_bb_result[x].display_key > " "))
     SET oebbresultcode = bb_result->qual_bb_result[x].bb_result_processing_cd
    ENDIF
   ELSE
    IF (ubbresultcode > " ")
     CALL logoeferror(4,lvar1)
    ENDIF
    SET oebbresultcode = 0
   ENDIF
   SET uradcode = trim(cnvtupper(requestin->list_0[lvar1].rad_section_type_cd))
   SET x = 1
   WHILE (x <= num_rad_codes
    AND cnvtupper(rad->qual_rad[x].display_key) != uradcode)
     SET x = (x+ 1)
   ENDWHILE
   IF (x <= num_rad_codes)
    IF ((rad->qual_rad[x].display_key > " "))
     SET oeradcode = rad->qual_rad[x].rad_section_type_cd
    ENDIF
   ELSE
    IF (uradcode > " ")
     CALL logoeferror(5,lvar1)
    ENDIF
    SET oeradcode = 0
   ENDIF
   SET usexcode = trim(cnvtupper(requestin->list_0[lvar1].sex_cd))
   SET x = 1
   WHILE (x <= num_sex_codes
    AND trim(sex->qual_sex[x].display_key) != trim(usexcode))
     SET x = (x+ 1)
   ENDWHILE
   IF (x <= num_sex_codes)
    IF ((sex->qual_sex[x].display_key > " "))
     SET oesexcode = sex->qual_sex[x].sex_cd
    ENDIF
   ELSE
    IF (usexcode > " ")
     CALL logoeferror(6,lvar1)
    ENDIF
    SET oesexcode = 0
   ENDIF
   SET uagefromcode = trim(cnvtupper(requestin->list_0[lvar1].age_from_units_cd))
   SET x = 1
   WHILE (x <= num_agefrom_codes
    AND cnvtupper(agefrom->qual_agefrom[x].display_key) != uagefromcode)
     SET x = (x+ 1)
   ENDWHILE
   IF (x <= num_agefrom_codes)
    IF ((agefrom->qual_agefrom[x].display_key > " "))
     SET oeagefromcode = agefrom->qual_agefrom[x].age_from_units_cd
    ENDIF
   ELSE
    IF (uagefromcode > " ")
     CALL logoeferror(7,lvar1)
    ENDIF
    SET oeagefromcode = 0
   ENDIF
   SET uagetocode = trim(cnvtupper(requestin->list_0[lvar1].age_to_units_cd))
   SET x = 1
   WHILE (x <= num_ageto_codes
    AND cnvtupper(ageto->qual_ageto[x].display_key) != uagetocode)
     SET x = (x+ 1)
   ENDWHILE
   IF (x <= num_ageto_codes)
    IF ((ageto->qual_ageto[x].display_key > " "))
     SET oeagetocode = ageto->qual_ageto[x].age_to_units_cd
    ENDIF
   ELSE
    IF (uagetocode > " ")
     CALL logoeferror(8,lvar1)
    ENDIF
    SET oeagetocode = 0
   ENDIF
   SET uspecimencode = trim(cnvtupper(requestin->list_0[lvar1].specimen_type_cd))
   SET x = 1
   WHILE (x <= num_specimen_codes
    AND cnvtupper(specimen->qual_specimen[x].display_key) != uspecimencode)
     SET x = (x+ 1)
   ENDWHILE
   IF (x <= num_specimen_codes)
    IF ((specimen->qual_specimen[x].display_key > " "))
     SET oespecimencode = specimen->qual_specimen[x].specimen_type_cd
    ENDIF
   ELSE
    IF (uspecimencode > " ")
     CALL logoeferror(9,lvar1)
    ENDIF
    SET oespecimencode = 0
   ENDIF
   SET uservicecode = trim(cnvtupper(requestin->list_0[lvar1].service_resource_cd))
   SET x = 1
   WHILE (x <= num_service_codes
    AND cnvtupper(service->qual_service[x].display_key) != uservicecode)
     SET x = (x+ 1)
   ENDWHILE
   IF (x <= num_service_codes)
    IF ((service->qual_service[x].display_key > " "))
     SET oeservicecode = service->qual_service[x].service_resource_cd
    ENDIF
   ELSE
    IF (uservicecode > " ")
     CALL logoeferror(10,lvar1)
    ENDIF
    SET oeservicecode = 0
   ENDIF
   SET uspeciescode = trim(cnvtupper(requestin->list_0[lvar1].species_cd))
   SET x = 1
   WHILE (x <= num_species_codes
    AND cnvtupper(species->qual_species[x].display_key) != uspeciescode)
     SET x = (x+ 1)
   ENDWHILE
   IF (x <= num_species_codes)
    IF ((species->qual_species[x].display_key > " "))
     SET oespeciescode = species->qual_species[x].species_cd
    ENDIF
   ELSE
    IF (uspeciescode > " ")
     CALL logoeferror(11,lvar1)
    ENDIF
    SET oespeciescode = 0
   ENDIF
   SET uencntrcode = trim(cnvtupper(requestin->list_0[lvar1].encntr_type_cd))
   SET x = 1
   WHILE (x <= num_encntr_codes
    AND cnvtupper(encntr->qual_encntr[x].display_key) != uencntrcode)
     SET x = (x+ 1)
   ENDWHILE
   IF (x <= num_encntr_codes)
    IF ((encntr->qual_encntr[x].display_key > " "))
     SET oeencntrcode = encntr->qual_encntr[x].encntr_type_cd
    ENDIF
   ELSE
    IF (uencntrcode > " ")
     CALL logoeferror(12,lvar1)
    ENDIF
    SET oeencntrcode = 0
   ENDIF
   SET uunitsindcode = trim(cnvtupper(requestin->list_0[lvar1].units_cd))
   SET x = 1
   WHILE (x <= num_unitsind_codes
    AND (unitsind->qual_unitsind[x].display_key != uunitsindcode))
     SET x = (x+ 1)
   ENDWHILE
   IF (x <= num_unitsind_codes)
    IF (cnvtupper(unitsind->qual_unitsind[x].display_key) > " ")
     SET oeunitsindcode = unitsind->qual_unitsind[x].use_units_ind
    ENDIF
   ELSE
    IF (uunitsindcode > " ")
     CALL logoeferror(13,lvar1)
    ENDIF
    SET oeunitsindcode = 0
   ENDIF
   SET uresultproccode = trim(cnvtupper(requestin->list_0[lvar1].result_process_cd))
   SET x = 1
   WHILE (x <= num_resultproc_codes
    AND cnvtupper(resultproc->qual_resultproc[x].display_key) != uresultproccode)
     SET x = (x+ 1)
   ENDWHILE
   IF (x <= num_resultproc_codes)
    IF ((resultproc->qual_resultproc[x].display_key > " "))
     SET oeresultproccode = resultproc->qual_resultproc[x].result_process_cd
    ENDIF
   ELSE
    IF (uresultproccode > " ")
     CALL logoeferror(14,lvar1)
    ENDIF
    SET oeresultproccode = 0
   ENDIF
 END ;Subroutine
 SUBROUTINE createdta(tvar2,oefid2)
   SET oef_error = "F"
   SET oef_error_type = 0
   SET oefid1 = 0
   SET status = " "
   FREE SET reply
   RECORD reply(
     1 qual[1]
       2 mnemonic = c50
       2 task_assay_cd = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c15
         3 operationstatus = c1
         3 targetobjectname = c15
         3 targetobjectvalue = vc
     1 exception_data[1]
       2 dup_ind = i2
       2 mnemonic = c50
   )
   FREE SET request
   RECORD request(
     1 qual[1]
       2 mnemonic = c50
       2 description = c100
       2 activity_type_cd = f8
       2 event_cd = f8
       2 default_result_type_cd = f8
       2 bb_result_processing_cd = f8
       2 rad_section_type_cd = f8
       2 strt_assay_id = f8
       2 code_set = i4
       2 beg_effective_dt_tm = dq8
       2 end_effective_dt_tm = dq8
       2 cki = vc
   )
   SET request->qual[1].mnemonic = trim(requestin->list_0[tvar2].dta_mnemonic)
   SET request->qual[1].description = trim(requestin->list_0[tvar2].description)
   SET request->qual[1].activity_type_cd = oeactcode
   SET request->qual[1].default_result_type_cd = oeresultcode
   SET request->qual[1].bb_result_processing_cd = oebbresultcode
   SET request->qual[1].rad_section_type_cd = oeradcode
   SET request->qual[1].code_set = cnvtreal(requestin->list_0[tvar2].code_set)
   SET request->qual[1].event_cd = event_cd
   SET request->qual[1].cki = trim(requestin->list_0[tvar2].cki)
   EXECUTE orm_add_discrete_assay_import
   SET task_assay_cd = reply->qual[1].task_assay_cd
   SET status = reply->status_data.status
   IF (task_assay_cd > 0
    AND status="S")
    CALL logadddta(1,task_assay_cd,lvar)
   ELSE
    CALL logadddta(4,"Failed",lvar)
   ENDIF
 END ;Subroutine
 SUBROUTINE createmap(tvar2,oefid2)
   SET oef_error = "F"
   SET oef_error_type = 0
   SET oefid1 = 0
   FREE SET request
   RECORD request(
     1 task_assay_cd = f8
     1 qual[1]
       2 service_resource_cd = f8
       2 result_entry_format = i4
       2 max_digits = i4
       2 min_digits = i4
       2 min_decimal_places = i4
       2 end_effective_dt_tm = dq8
   )
   FREE SET reply
   RECORD reply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c15
         3 operationstatus = c1
         3 targetobjectname = c15
         3 targetobjectvalue = vc
   )
   SET request->task_assay_cd = task_assay_cd
   SET request->qual[1].service_resource_cd = oeservicecode
   SET request->qual[1].result_entry_format = 0
   SET request->qual[1].end_effective_dt_tm = 0
   SET request->qual[1].max_digits = cnvtint(requestin->list_0[tvar2].max_digits)
   SET request->qual[1].min_digits = cnvtint(requestin->list_0[tvar2].min_digits)
   SET request->qual[1].min_decimal_places = cnvtint(requestin->list_0[tvar2].min_decimal_places)
   EXECUTE orc_add_data_map
   COMMIT
 END ;Subroutine
 SUBROUTINE createref(tvar2,oefid2)
   SET oef_error = "F"
   SET oef_error_type = 0
   SET oefid1 = 0
   SET reference_range_id = 0
   FREE SET reply
   RECORD reply(
     1 qual[1]
       2 task_assay_cd = f8
       2 service_resource_cd = f8
       2 reference_range_factor_id = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c15
         3 operationstatus = c1
         3 targetobjectname = c15
         3 targetobjectvalue = vc
   )
   FREE SET request
   RECORD request(
     1 qual[1]
       2 encntr_type_cd = f8
       2 task_assay_cd = f8
       2 service_resource_cd = f8
       2 species_cd = f8
       2 organism_cd = f8
       2 sex_cd = f8
       2 age_from_units_cd = f8
       2 age_from_minutes = i4
       2 age_to_units_cd = f8
       2 age_to_minutes = i4
       2 specimen_type_cd = f8
       2 patient_condition_cd = f8
       2 default_result = f8
       2 def_result_ind = i2
       2 review_ind = i2
       2 review_low = f8
       2 review_high = f8
       2 sensitive_ind = i2
       2 sensitive_low = f8
       2 sensitive_high = f8
       2 normal_ind = i2
       2 normal_low = f8
       2 normal_high = f8
       2 critical_ind = i2
       2 critical_low = f8
       2 critical_high = f8
       2 delta_check_type_cd = f8
       2 delta_chk_flag = i2
       2 delta_lvl_flag = i2
       2 delta_minutes = f8
       2 delta_value = f8
       2 unknown_age_ind = i2
       2 gestational_ind = i2
       2 precedence_sequence = i4
       2 resource_ref_flag = i2
       2 feasible_ind = i2
       2 feasible_low = f8
       2 feasible_high = f8
       2 linear_ind = i2
       2 linear_low = f8
       2 linear_high = f8
       2 dilute_ind = i2
       2 mins_back = f8
       2 units_cd = f8
       2 alpha_cnt = i4
       2 alpha[1]
         3 active_ind = i2
         3 use_units_ind = i2
         3 nomenclature_id = f8
         3 result_process_cd = f8
         3 default_ind = i2
         3 sequence = i4
         3 description = vc
         3 reference_ind = i2
   )
   SET request->qual[1].encntr_type_cd = oeencntrcode
   SET request->qual[1].task_assay_cd = task_assay_cd
   SET request->qual[1].service_resource_cd = oeservicecode
   SET request->qual[1].species_cd = oespeciescode
   SET request->qual[1].organism_cd = 0
   SET request->qual[1].sex_cd = oesexcode
   SET request->qual[1].age_from_units_cd = oeagefromcode
   SET request->qual[1].age_from_minutes = cnvtint(requestin->list_0[tvar2].age_from_minutes)
   SET request->qual[1].age_to_units_cd = oeagetocode
   SET request->qual[1].age_to_minutes = cnvtint(requestin->list_0[tvar2].age_to_minutes)
   SET request->qual[1].specimen_type_cd = oespecimencode
   SET request->qual[1].patient_condition_cd = 0
   SET request->qual[1].default_result = 0
   SET request->qual[1].def_result_ind = 0
   SET request->qual[1].review_ind = 0
   SET request->qual[1].review_low = 0
   SET request->qual[1].review_high = 0
   IF (cnvtint(requestin->list_0[tvar2].sensitive_low) > 0
    AND cnvtint(requestin->list_0[tvar2].sensitive_high) > 0)
    SET request->qual[1].sensitive_ind = 3
   ELSEIF (cnvtint(requestin->list_0[tvar2].sensitive_high) > 0)
    SET request->qual[1].sensitive_ind = 2
   ELSEIF (cnvtint(requestin->list_0[tvar2].sensitive_low) > 0)
    SET request->qual[1].sensitive_ind = 1
   ELSE
    SET request->qual[1].sensitive_ind = 0
   ENDIF
   SET request->qual[1].sensitive_low = cnvtint(requestin->list_0[tvar2].sensitive_low)
   SET request->qual[1].sensitive_high = cnvtint(requestin->list_0[tvar2].sensitive_high)
   IF (cnvtint(requestin->list_0[tvar2].normal_low) > 0
    AND cnvtint(requestin->list_0[tvar2].normal_high) > 0)
    SET request->qual[1].normal_ind = 3
   ELSEIF (cnvtint(requestin->list_0[tvar2].normal_high) > 0)
    SET request->qual[1].normal_ind = 2
   ELSEIF (cnvtint(requestin->list_0[tvar2].normal_low) > 0)
    SET request->qual[1].normal_ind = 1
   ELSE
    SET request->qual[1].normal_ind = 0
   ENDIF
   SET request->qual[1].normal_low = cnvtint(requestin->list_0[tvar2].normal_low)
   SET request->qual[1].normal_high = cnvtint(requestin->list_0[tvar2].normal_high)
   IF (cnvtint(requestin->list_0[tvar2].critical_low) > 0
    AND cnvtint(requestin->list_0[tvar2].critical_high) > 0)
    SET request->qual[1].critical_ind = 3
   ELSEIF (cnvtint(requestin->list_0[tvar2].critical_high) > 0)
    SET request->qual[1].critical_ind = 2
   ELSEIF (cnvtint(requestin->list_0[tvar2].critical_low) > 0)
    SET request->qual[1].critical_ind = 1
   ELSE
    SET request->qual[1].critical_ind = 0
   ENDIF
   SET request->qual[1].critical_low = cnvtint(requestin->list_0[tvar2].critical_low)
   SET request->qual[1].critical_high = cnvtint(requestin->list_0[tvar2].critical_high)
   SET request->qual[1].delta_check_type_cd = 0
   SET request->qual[1].delta_chk_flag = 0
   SET request->qual[1].delta_lvl_flag = 0
   SET request->qual[1].delta_minutes = 0
   SET request->qual[1].delta_value = 0
   SET request->qual[1].unknown_age_ind = 0
   IF (trim(cnvtupper(requestin->list_0[tvar2].gestational_ind))="Y")
    SET request->qual[1].gestational_ind = 1
   ELSE
    SET request->qual[1].gestational_ind = 0
   ENDIF
   SET request->qual[1].precedence_sequence = 0
   SET request->qual[1].resource_ref_flag = 0
   IF (cnvtint(requestin->list_0[tvar2].feasible_low) > 0
    AND cnvtint(requestin->list_0[tvar2].feasible_high) > 0)
    SET request->qual[1].feasible_ind = 3
   ELSEIF (cnvtint(requestin->list_0[tvar2].feasible_high) > 0)
    SET request->qual[1].feasible_ind = 2
   ELSEIF (cnvtint(requestin->list_0[tvar2].feasible_low) > 0)
    SET request->qual[1].feasible_ind = 1
   ELSE
    SET request->qual[1].feasible_ind = 0
   ENDIF
   SET request->qual[1].feasible_low = cnvtint(requestin->list_0[tvar2].feasible_low)
   SET request->qual[1].feasible_high = cnvtint(requestin->list_0[tvar2].feasible_high)
   IF (cnvtint(requestin->list_0[tvar2].linear_low) > 0
    AND cnvtint(requestin->list_0[tvar2].linear_high) > 0)
    SET request->qual[1].linear_ind = 3
   ELSEIF (cnvtint(requestin->list_0[tvar2].linear_high) > 0)
    SET request->qual[1].linear_ind = 2
   ELSEIF (cnvtint(requestin->list_0[tvar2].linear_low) > 0)
    SET request->qual[1].linear_ind = 1
   ELSE
    SET request->qual[1].linear_ind = 0
   ENDIF
   SET request->qual[1].linear_low = cnvtint(requestin->list_0[tvar2].linear_low)
   SET request->qual[1].linear_high = cnvtint(requestin->list_0[tvar2].linear_high)
   SET request->qual[1].dilute_ind = 0
   IF (cnvtupper(requestin->list_0[tvar2].lookback_units)="")
    SET units1 = "N"
   ELSE
    SET units1 = cnvtupper(requestin->list_0[tvar2].lookback_units)
   ENDIF
   SET nums = cnvtreal(trim(requestin->list_0[tvar2].mins_back))
   SET mins = 0
   IF (units1="MINUTE")
    SET mins = nums
   ELSEIF (units1="HOUR")
    SET mins = (nums * 60.0)
   ELSEIF (units1="DAY")
    SET mins = ((nums * 60.0) * 24.0)
   ELSEIF (units1="WEEK")
    SET mins = (((nums * 60.0) * 24.0) * 7.0)
   ELSEIF (units1="MON")
    SET mins = (((nums * 60.0) * 24.0) * 30.0)
   ELSEIF (units1="YEAR")
    SET mins = (((nums * 60.0) * 24.0) * 365.25)
   ENDIF
   SET request->qual[1].mins_back = mins
   SET request->qual[1].units_cd = oeunitsindcode
   SET request->qual[1].alpha_cnt = 0
   EXECUTE orc_add_ref_range
   SET reference_range_id = reply->qual[1].reference_range_factor_id
   IF (reference_range_id > 0)
    CALL logadddta(2,reference_range_id,lvar)
   ELSE
    CALL logadddta(5,"Failed",lvar)
   ENDIF
 END ;Subroutine
 SUBROUTINE checkref(tvar2)
   SET ref_error = "F"
   SET gestational_ind = 0
   SET units = fillstring(12," ")
   SET nums = 0
   SET mins = 0
   SET num_dupes = 0
   SET units1 = trim(cnvtupper(requestin->list_0[tvar2].lookback_units))
   SET nums = cnvtreal(trim(requestin->list_0[tvar2].mins_back))
   IF (units1="MINUTE")
    SET mins = nums
   ELSEIF (units1="HOUR")
    SET mins = (nums * 60.0)
   ELSEIF (units1="DAY")
    SET mins = ((nums * 60.0) * 24.0)
   ELSEIF (units1="WEEK")
    SET mins = (((nums * 60.0) * 24.0) * 7.0)
   ELSEIF (units1="MON")
    SET mins = (((nums * 60.0) * 24.0) * 30.0)
   ELSEIF (units1="YEAR")
    SET mins = (((nums * 60.0) * 24.0) * 365.25)
   ENDIF
   CALL echo(build("Nums = ",mins))
   IF (((trim(cnvtupper(requestin->list_0[tvar2].gestational_ind))="Y") OR (trim(requestin->list_0[
    tvar2].gestational_ind)="1")) )
    SET gestational_ind = 1
   ELSE
    SET gestational_ind = 0
   ENDIF
   CALL echo(build("Gest = ",gestational_ind))
   CALL echo(build("task cd = ",task_assay_cd))
   CALL echo(build("encnter = ",oeencntrcode))
   CALL echo(build("service = ",oeservicecode))
   CALL echo(build("species = ",oespeciescode))
   CALL echo(build("sex = ",oesexcode))
   CALL echo(build("age from = ",oeagefromcode))
   CALL echo(build("age min =",cnvtint(requestin->list_0[tvar2].age_from_minutes)))
   CALL echo(build("age to =",oeagetocode))
   CALL echo(build("age to min=",cnvtint(requestin->list_0[tvar2].age_to_minutes)))
   CALL echo(build("spec = ",oespecimencode))
   CALL echo(build("units = ",oeunitscode))
   SELECT INTO "nl:"
    FROM reference_range_factor r
    WHERE r.task_assay_cd=task_assay_cd
     AND r.encntr_type_cd=oeencntrcode
     AND r.service_resource_cd=oeservicecode
     AND r.species_cd=oespeciescode
     AND r.sex_cd=oesexcode
     AND r.age_from_units_cd=oeagefromcode
     AND r.age_from_minutes=cnvtint(requestin->list_0[tvar2].age_from_minutes)
     AND r.age_to_units_cd=oeagetocode
     AND r.age_to_minutes=cnvtint(requestin->list_0[tvar2].age_to_minutes)
     AND r.specimen_type_cd=oespecimencode
     AND r.sensitive_low=cnvtint(requestin->list_0[tvar2].sensitive_low)
     AND r.sensitive_high=cnvtint(requestin->list_0[tvar2].sensitive_high)
     AND r.normal_low=cnvtint(requestin->list_0[tvar2].normal_low)
     AND r.normal_high=cnvtint(requestin->list_0[tvar2].normal_high)
     AND r.critical_low=cnvtint(requestin->list_0[tvar2].critical_low)
     AND r.critical_high=cnvtint(requestin->list_0[tvar2].critical_high)
     AND r.feasible_low=cnvtint(requestin->list_0[tvar2].feasible_low)
     AND r.feasible_high=cnvtint(requestin->list_0[tvar2].feasible_high)
     AND r.linear_low=cnvtint(requestin->list_0[tvar2].linear_low)
     AND r.linear_high=cnvtint(requestin->list_0[tvar2].linear_high)
     AND r.units_cd=oeunitsindcode
     AND r.gestational_ind=gestational_ind
     AND r.mins_back=mins
    DETAIL
     num_dupes = (num_dupes+ 1), ref_error = "T",
     CALL echo(build("ref_error = ",ref_error))
    WITH nocounter
   ;end select
   CALL echo(build("ref_error2 = ",ref_error))
 END ;Subroutine
 SUBROUTINE createalpha(tvar2,seq2)
   SET oef_error = "F"
   SET oef_error_type = 0
   SET oefid1 = 0
   FREE SET request
   RECORD request(
     1 qual[1]
       2 nomenclature_id = f8
       2 reference_range_factor_id = f8
       2 sequence = i4
       2 use_units_ind = i2
       2 result_process_cd = f8
       2 default_ind = i2
       2 active_ind = i2
       2 description = vc
       2 reference_ind = i2
       2 multi_alpha_sort_order = i4
       2 result_value = f8
   )
   SET request->qual[1].nomenclature_id = oenomencode
   SET request->qual[1].reference_range_factor_id = reference_range_id
   SET request->qual[1].sequence = seq2
   IF (trim(cnvtupper(requestin->list_0[tvar2].use_units_ind)) > "Y")
    SET request->qual[1].use_units_ind = 1
   ELSE
    SET request->qual[1].use_units_ind = 0
   ENDIF
   SET request->qual[1].result_process_cd = oeresultproccode
   IF (trim(cnvtupper(requestin->list_0[tvar2].default_ind))="Y")
    SET request->qual[1].default_ind = 1
   ELSE
    SET request->qual[1].default_ind = 0
   ENDIF
   SET request->qual[1].active_ind = 1
   SET request->qual[1].description = trim(requestin->list_0[tvar2].mnemonic)
   IF (((trim(cnvtupper(requestin->list_0[tvar2].reference_ind))="Y") OR (trim(requestin->list_0[
    tvar2].reference_ind)="1")) )
    SET request->qual[1].reference_ind = 1
   ELSE
    SET request->qual[1].reference_ind = 0
   ENDIF
   SET request->qual[1].multi_alpha_sort_order = cnvtint(requestin->list_0[tvar2].
    multi_alpha_sort_order)
   SET request->qual[1].result_value = cnvtreal(requestin->list_0[tvar2].result_value)
   EXECUTE orc_add_alpha_responses
   COMMIT
 END ;Subroutine
 SUBROUTINE logoeferror(etype,evar)
   SELECT INTO "cv_import_dta.log"
    evar
    HEAD REPORT
     nomenname = concat(trim(requestin->list_0[evar].mnemonic),"                         "), actname
      = concat(trim(requestin->list_0[evar].activity_type_cd),"            "), resultname = concat(
      trim(requestin->list_0[evar].default_result_type_cd),"            "),
     bbresultname = concat(trim(requestin->list_0[evar].bb_result_processing_cd),"            "),
     radname = concat(trim(requestin->list_0[evar].rad_section_type_cd),"            "), sexname =
     concat(trim(requestin->list_0[evar].sex_cd),"            "),
     agefromname = concat(trim(requestin->list_0[evar].age_from_units_cd),"            "), agetoname
      = concat(trim(requestin->list_0[evar].age_to_units_cd),"            "), specimenname = concat(
      trim(requestin->list_0[evar].specimen_type_cd),"            "),
     servicename = concat(trim(requestin->list_0[evar].service_resource_cd),"            "),
     speciesname = concat(trim(requestin->list_0[evar].species_cd),"            "), encntrname =
     concat(trim(requestin->list_0[evar].encntr_type_cd),"            "),
     unitsname = concat(trim(requestin->list_0[evar].units_cd),"            "), resultprocname =
     concat(trim(requestin->list_0[evar].result_process_cd),"            ")
    DETAIL
     IF (etype=1)
      row + 1, col 0, "Invalid nomenclature mnemonic: ",
      nomenname, row + 1, col 0,
      "Row #: ", evar
     ENDIF
     IF (etype=2)
      row + 1, col 0, "Invalid activity type : ",
      actname, row + 1, col 0,
      "Row #: ", evar
     ENDIF
     IF (etype=3)
      row + 1, col 0, "Invalid result type: ",
      resultname, row + 1, col 0,
      "Row #: ", evar
     ENDIF
     IF (etype=4)
      row + 1, col 0, "Invalid bbresult type: ",
      bbresultname, row + 1, col 0,
      "Row #: ", evar
     ENDIF
     IF (etype=5)
      row + 1, col 0, "Invalid rad type: ",
      radname, row + 1, col 0,
      "Row #: ", evar
     ENDIF
     IF (etype=6)
      row + 1, col 0, "Invalid sex type: ",
      sexname, row + 1, col 0,
      "Row #: ", evar
     ENDIF
     IF (etype=7)
      row + 1, col 0, "Invalid age from type: ",
      agefromname, row + 1, col 0,
      "Row #: ", evar
     ENDIF
     IF (etype=8)
      row + 1, col 0, "Invalid age to type: ",
      agetoname, row + 1, col 0,
      "Row #: ", evar
     ENDIF
     IF (etype=9)
      row + 1, col 0, "Invalid specimen type: ",
      specimenname, row + 1, col 0,
      "Row #: ", evar
     ENDIF
     IF (etype=10)
      row + 1, col 0, "Invalid service type: ",
      servicename, row + 1, col 0,
      "Row #: ", evar
     ENDIF
     IF (etype=11)
      row + 1, col 0, "Invalid species type: ",
      speciesname, row + 1, col 0,
      "Row #: ", evar
     ENDIF
     IF (etype=12)
      row + 1, col 0, "Invalid encntr type: ",
      encntrname, row + 1, col 0,
      "Row #: ", evar
     ENDIF
     IF (etype=13)
      row + 1, col 0, "Invalid units type: ",
      unitsname, row + 1, col 0,
      "Row #: ", evar
     ENDIF
     IF (etype=14)
      row + 1, col 0, "Invalid result process type: ",
      resultprocname, row + 1, col 0,
      "Row #: ", evar
     ENDIF
    WITH nocounter, append, format = variable,
     noformfeed, maxcol = 132, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE logadddta(zvar,fldname,evar3)
   SELECT INTO "orm_import_dta.log"
    evar3
    HEAD REPORT
     col 0
    DETAIL
     IF (zvar=1)
      row + 1, col 0, "Successfully added DTA: ",
      fldname, row + 1, col 0,
      "Row #: ", evar3
     ENDIF
     IF (zvar=2)
      row + 1, col 0, "Successfully added reference range: ",
      fldname, row + 1, col 0,
      "Row #: ", evar3
     ENDIF
     IF (zvar=3)
      row + 1, col 0, "Duplicate DTA mnemonic, already exists: ",
      fldname, row + 1, col 0,
      "Row #: ", evar3
     ENDIF
     IF (zvar=4)
      row + 1, col 0, "Unable to add DTA: ",
      fldname, row + 1, col 0,
      "Row #: ", evar3
     ENDIF
     IF (zvar=5)
      row + 1, col 0, "Unable to add reference : ",
      col + 1, fldname, row + 1,
      col 0, "Row #: ", evar3
     ENDIF
     IF (zvar=6)
      row + 1, col 0, "Duplicate found!! Unable to add reference range: ",
      col + 1, fldname, row + 1,
      col 0, "Row #: ", evar3
     ENDIF
    WITH nocounter, append, format = variable,
     noformfeed, maxcol = 132, maxrow = 1
   ;end select
 END ;Subroutine
#enditnow
 COMMIT
 CALL echorecord(requestin,"cer_temp:cvrecord.dat")
END GO
