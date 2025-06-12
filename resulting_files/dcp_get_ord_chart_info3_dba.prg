CREATE PROGRAM dcp_get_ord_chart_info3:dba
 SET modify = predeclare
 FREE SET reply
 RECORD reply(
   1 qual[*]
     2 order_id = f8
     2 catalog_type_cd = f8
     2 catalog_type_disp = c40
     2 catalog_type_mean = c12
     2 med_order_type_cd = f8
     2 orig_ord_as_flag = i2
     2 activity_type_cd = f8
     2 activity_type_disp = c40
     2 catalog_cd = f8
     2 catalog_disp = c40
     2 catalog_mean = c12
     2 person_id = f8
     2 encntr_id = f8
     2 dcp_clin_cat_cd = f8
     2 dcp_clin_cat_disp = c40
     2 order_status_cd = f8
     2 order_status_disp = c40
     2 incomplete_order_ind = i2
     2 dept_status_cd = f8
     2 dept_status_disp = c40
     2 order_mnemonic = vc
     2 hna_order_mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 orig_order_dt_tm = dq8
     2 orig_order_tz = i4
     2 last_update_provider_id = f8
     2 template_order_id = f8
     2 template_order_flag = i2
     2 synonym_id = f8
     2 order_detail_display_line = vc
     2 clinical_display_line = vc
     2 oe_format_id = f8
     2 constant_ind = i2
     2 prn_ind = i2
     2 need_rx_verify_ind = i2
     2 need_rx_clin_review_flag = i2
     2 need_nurse_review_ind = i2
     2 need_doctor_cosign_ind = i2
     2 current_start_dt_tm = dq8
     2 current_start_tz = i4
     2 projected_stop_dt_tm = dq8
     2 projected_stop_tz = i4
     2 stop_type_cd = f8
     2 suspend_ind = i2
     2 suspend_effective_dt_tm = dq8
     2 resume_ind = i2
     2 resume_effective_dt_tm = dq8
     2 discontinue_ind = i2
     2 discontinue_effective_dt_tm = dq8
     2 discontinue_effective_tz = i4
     2 discontinue_type_cd = f8
     2 last_updt_cnt = i4
     2 last_action_seq = i4
     2 ref_text_mask = i4
     2 orderable_type_flag = i2
     2 interval_ind = i2
     2 hide_flag = i2
     2 comment_type_mask = i4
     2 cki = vc
     2 freq_type_flag = i2
     2 ingredient_ind = i2
     2 rx_mask = i4
     2 order_comment_ind = i2
     2 updt_id = f8
     2 cs_order_id = f8
     2 cs_flag = f8
     2 communication_type_cd = f8
     2 action_personnel_id = f8
     2 order_provider_id = f8
     2 accession_id = f8
     2 accession = vc
     2 accession_format = vc
     2 activity_subtype_cd = f8
     2 cancel_communication_type_cd = f8
     2 bill_only_ind = i2
     2 updt_dt_tm = dq8
     2 status_dt_tm = dq8
     2 last_ingred_action_sequence = i4
     2 comments[*]
       3 type = f8
       3 text = vc
       3 updt_id = f8
       3 updt_dt_tm = dq8
     2 detqual[*]
       3 oe_field_display_value = vc
       3 label_text = vc
       3 group_seq = i4
       3 field_seq = i4
       3 oe_field_meaning = c25
       3 oe_field_id = f8
       3 oe_field_dt_tm = dq8
       3 oe_field_tz = i4
       3 oe_field_meaning_id = f8
       3 oe_field_value = f8
     2 renew_ind = i2
     2 entity_activity_updt_cnt = i4
     2 entity_activity_updt_dt_tm = dq8
     2 event_cd = f8
     2 template_order_action_sequence = i4
     2 template_order_status = f8
     2 last_template_order_action_seq = i4
     2 ingred_list[*]
       3 order_mnemonic = vc
       3 ordered_as_mnemonic = vc
       3 order_detail_display_line = vc
       3 synonym_id = f8
       3 catalog_cd = f8
       3 volume_value = f8
       3 volume_unit_cd = f8
       3 volume_unit_disp = vc
       3 strength_value = f8
       3 strength_unit_cd = f8
       3 strength_unit_disp = vc
       3 freetext_dose = vc
       3 frequency_cd = f8
       3 frequency_disp = vc
       3 comp_sequence = i4
       3 ingredient_type_flag = i2
       3 iv_seq = i4
       3 hna_order_mnemonic = vc
       3 dose_quantity = f8
       3 dose_quantity_unit = f8
       3 event_cd = f8
       3 normalized_rate = f8
       3 normalized_rate_unit_cd = f8
       3 concentration = f8
       3 concentration_unit_cd = f8
       3 include_in_total_volume_flag = i2
       3 ingredient_source_flag = i2
       3 titrateable_flag = i2
       3 clinically_significant_flag = i2
       3 ordered_dose_value = f8
       3 ordered_dose_unit_cd = f8
       3 autoprog_syn_ind = i2
       3 autoprogramming_id = f8
       3 adjusted_patient_weight = f8
       3 adjusted_patient_weight_cd = f8
       3 adjusted_patient_height = f8
       3 adjusted_patient_height_cd = f8
       3 final_dose = f8
       3 final_dose_unit_cd = f8
       3 actual_final_dose = f8
       3 actual_final_dose_unit_cd = f8
     2 protocol_order_id = f8
     2 last_core_action_seq = i4
     2 dosing_method_flag = i2
     2 template_dose_seq = i4
     2 ingredient_action_sequence = i4
     2 core_group_last_action_seq = i4
     2 last_template_core_action_seq = i4
     2 applicable_fields_bit = i4
     2 finished_bags_cnt = i4
     2 total_bags_nbr = i4
     2 pathway_group_nbr = f8
     2 pathway_id = f8
     2 pathway_type_cd = f8
     2 pathway_sequence = i4
     2 pathway_description = vc
     2 updated_to_verified_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE count1 = i4 WITH noconstant(0)
 DECLARE ingred_cnt = i4 WITH noconstant(0)
 DECLARE detail_cnt = i4 WITH noconstant(0)
 DECLARE comment_cnt = i4 WITH noconstant(0)
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 DECLARE admin_note_mask = i4 WITH constant(128)
 DECLARE bfoundnextcoreaction = i2 WITH private, noconstant(0)
 DECLARE binvalidtype = i2 WITH private, noconstant(0)
 DECLARE ndiluentcount = i4 WITH private, noconstant(0)
 DECLARE nadditivecount = i4 WITH private, noconstant(0)
 DECLARE badditivesfirst = i2 WITH private, noconstant(0)
 SET reply->status_data.status = "F"
 DECLARE new_action_type_cd = f8 WITH constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE modify_status_cd = f8 WITH constant(uar_get_code_by("MEANING",6003,"MODIFY"))
 DECLARE group_class_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"GRP"))
 DECLARE order_comment_cd = f8 WITH constant(uar_get_code_by("MEANING",14,"ORD COMMENT"))
 DECLARE admin_note_cd = f8 WITH constant(uar_get_code_by("MEANING",14,"RNADMINNOTE"))
 DECLARE ordered_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE inprocess_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"INPROCESS"))
 DECLARE susp_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"SUSPENDED"))
 DECLARE disc_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"DISCONTINUED"))
 DECLARE canceled_cd = f8 WITH constant(uar_get_code_by("MEANING",6004,"CANCELED"))
 DECLARE ivsequence_cd = f8 WITH constant(uar_get_code_by("MEANING",30183,"IVSEQUENCE"))
 DECLARE expand_index = i4 WITH noconstant(0)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE ord_idx = i4 WITH noconstant(0)
 DECLARE tmp_ord_idx = i4 WITH noconstant(0)
 DECLARE locate_idx = i4 WITH noconstant(0)
 DECLARE populateingredientdetails(qualindex=i4) = null
 DECLARE itf_invalid = i4 WITH constant(0)
 DECLARE itf_medication = i4 WITH constant(1)
 DECLARE itf_base = i4 WITH constant(2)
 DECLARE itf_additive = i4 WITH constant(3)
 DECLARE itf_compound_parent = i4 WITH constant(4)
 DECLARE itf_compound_child = i4 WITH constant(5)
 DECLARE csf_not_set = i4 WITH constant(0)
 DECLARE csf_not_significant = i4 WITH constant(1)
 DECLARE csf_significant = i4 WITH constant(2)
 DECLARE everybag_cd = f8 WITH constant(uar_get_code_by("MEANING",4004,"EVERYBAG"))
 DECLARE type_med_cd = f8 WITH constant(uar_get_code_by("MEANING",18309,"MED"))
 DECLARE type_int_cd = f8 WITH constant(uar_get_code_by("MEANING",18309,"INTERMITTENT"))
 DECLARE appendmnemonicanddose(nqual=i4,ningredient=i4,bfrequency=i2) = null
 DECLARE countingredienttypes(nqual=i4,ningredient=i4) = null
 DECLARE formatnumber(nvalue=f8) = vc
 DECLARE generateordermnemonic(nqual=i4) = null
 DECLARE getdosedisplay(nqual=i4,ningredient=i4,bfrequency=i2) = vc
 DECLARE prepareclinicallysigdiluents(nqual=i4) = null
 DECLARE setcontinuousivmnemonic(nqual=i4,ningredient=i4) = null
 DECLARE setintermittentmnemonic(nqual=i4,ningredient=i4) = null
 DECLARE setmedicationmnemonic(nqual=i4,ningredient=i4) = null
 DECLARE setmnemonictoingredient(nqual=i4,ningredient=i4) = null
 SUBROUTINE countingredienttypes(nqual,ningredient)
  IF ((reply->qual[nqual].ingred_list[ningredient].clinically_significant_flag=csf_significant)
   AND (reply->qual[nqual].ingred_list[ningredient].ingredient_type_flag=itf_base))
   SET ndiluentcount = (ndiluentcount+ 1)
  ELSEIF ((((reply->qual[nqual].ingred_list[ningredient].ingredient_type_flag=itf_medication)) OR ((
  reply->qual[nqual].ingred_list[ningredient].ingredient_type_flag=itf_additive))) )
   SET nadditivecount = (nadditivecount+ 1)
  ENDIF
  IF ((reply->qual[d.seq].ingred_list[ingred_cnt].ingredient_type_flag=itf_invalid))
   SET binvalidtype = 1
  ENDIF
 END ;Subroutine
 SUBROUTINE generateordermnemonic(nqual)
   IF ((reply->qual[nqual].med_order_type_cd != 0.0))
    SET reply->qual[nqual].order_mnemonic = ""
    SET reply->qual[nqual].hna_order_mnemonic = ""
    SET reply->qual[nqual].ordered_as_mnemonic = ""
    IF ((reply->qual[nqual].med_order_type_cd=type_med_cd))
     CALL setmedicationmnemonic(nqual)
    ELSEIF ((reply->qual[nqual].med_order_type_cd=type_int_cd))
     CALL setintermittentmnemonic(nqual)
    ELSE
     CALL setcontinuousivmnemonic(nqual)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE prepareclinicallysigdiluents(nqual)
   DECLARE bfound = i2 WITH private, noconstant(0)
   DECLARE bisset = i2 WITH private, noconstant(0)
   DECLARE nindex = i4 WITH private, noconstant(0)
   FOR (nindex = 1 TO ingred_cnt BY 1)
     IF ((reply->qual[nqual].ingred_list[nindex].ingredient_type_flag=itf_base))
      SET bfound = 1
      IF ((((reply->qual[nqual].ingred_list[nindex].clinically_significant_flag=csf_significant)) OR
      ((reply->qual[nqual].ingred_list[nindex].clinically_significant_flag=csf_not_significant))) )
       SET bisset = 1
      ENDIF
     ENDIF
   ENDFOR
   IF (bfound=1
    AND bisset=0)
    FOR (nindex = 1 TO ingred_cnt BY 1)
      IF ((reply->qual[nqual].ingred_list[nindex].ingredient_type_flag=itf_base))
       SET reply->qual[nqual].ingred_list[nindex].clinically_significant_flag = csf_significant
      ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE formatnumber(nvalue)
   RETURN(format(round(nvalue,4),"########.####;T(1)"))
 END ;Subroutine
 SUBROUTINE getdosedisplay(nqual,ningredient,bfrequency)
   DECLARE sreturn = vc WITH private, noconstant("")
   IF ((reply->qual[nqual].ingred_list[ningredient].strength_value > 0.0)
    AND (reply->qual[nqual].ingred_list[ningredient].strength_unit_cd > 0.0))
    SET sreturn = concat(formatnumber(reply->qual[nqual].ingred_list[ningredient].strength_value)," ",
     trim(uar_get_code_display(reply->qual[nqual].ingred_list[ningredient].strength_unit_cd),3))
   ELSEIF ((reply->qual[nqual].ingred_list[ningredient].volume_value > 0.0)
    AND (reply->qual[nqual].ingred_list[ningredient].volume_unit_cd > 0.0))
    SET sreturn = concat(formatnumber(reply->qual[nqual].ingred_list[ningredient].volume_value)," ",
     trim(uar_get_code_display(reply->qual[nqual].ingred_list[ningredient].volume_unit_cd),3))
   ELSEIF ((reply->qual[nqual].ingred_list[ningredient].freetext_dose != ""))
    SET sreturn = reply->qual[nqual].ingred_list[ningredient].freetext_dose
   ENDIF
   IF ((reply->qual[nqual].ingred_list[ningredient].normalized_rate_unit_cd > 0.0)
    AND (reply->qual[nqual].ingred_list[ningredient].titrateable_flag > 0))
    SET sreturn = concat(sreturn," [",formatnumber(reply->qual[nqual].ingred_list[ningredient].
      normalized_rate)," ",trim(uar_get_code_display(reply->qual[nqual].ingred_list[ningredient].
       normalized_rate_unit_cd),3),
     "]")
   ENDIF
   IF (bfrequency=1
    AND (reply->qual[nqual].ingred_list[ningredient].frequency_cd > 0.0)
    AND (reply->qual[nqual].ingred_list[ningredient].frequency_cd != everybag_cd)
    AND sreturn != "")
    SET sreturn = concat(sreturn," ",trim(uar_get_code_display(reply->qual[nqual].ingred_list[
       ningredient].frequency_cd),3))
   ENDIF
   RETURN(sreturn)
 END ;Subroutine
 SUBROUTINE setmnemonictoingredient(nqual,ningredient)
   SET reply->qual[nqual].order_mnemonic = reply->qual[nqual].ingred_list[ningredient].order_mnemonic
   SET reply->qual[nqual].hna_order_mnemonic = reply->qual[nqual].ingred_list[ningredient].
   hna_order_mnemonic
   SET reply->qual[nqual].ordered_as_mnemonic = reply->qual[nqual].ingred_list[ningredient].
   ordered_as_mnemonic
 END ;Subroutine
 SUBROUTINE setmedicationmnemonic(nqual)
  DECLARE nindex = i4 WITH private, noconstant(0)
  FOR (nindex = 1 TO ingred_cnt BY 1)
    IF (((((binvalidtype=1) OR ((reply->qual[nqual].ingred_list[nindex].ingredient_type_flag=
    itf_invalid))) ) OR (binvalidtype=0
     AND (((reply->qual[nqual].ingred_list[nindex].ingredient_type_flag=itf_medication)) OR ((((reply
    ->qual[nqual].ingred_list[nindex].ingredient_type_flag=itf_additive)) OR ((reply->qual[nqual].
    ingred_list[nindex].ingredient_type_flag=itf_compound_parent))) )) )) )
     CALL setmnemonictoingredient(nqual,nindex)
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE appendmnemonicanddose(nqual,ningredient,bfrequency)
   DECLARE sdose = vc WITH private, noconstant("")
   SET sdose = getdosedisplay(nqual,ningredient,bfrequency)
   IF ((reply->qual[nqual].order_mnemonic != ""))
    SET reply->qual[nqual].order_mnemonic = concat(reply->qual[nqual].order_mnemonic," +")
   ENDIF
   SET reply->qual[nqual].order_mnemonic = trim(concat(reply->qual[nqual].order_mnemonic," ",reply->
     qual[nqual].ingred_list[ningredient].order_mnemonic," ",sdose),3)
   IF ((reply->qual[nqual].hna_order_mnemonic != ""))
    SET reply->qual[nqual].hna_order_mnemonic = concat(reply->qual[nqual].hna_order_mnemonic," +")
   ENDIF
   SET reply->qual[nqual].hna_order_mnemonic = trim(concat(reply->qual[nqual].hna_order_mnemonic," ",
     reply->qual[nqual].ingred_list[ningredient].hna_order_mnemonic," ",sdose),3)
   IF ((reply->qual[nqual].ordered_as_mnemonic != ""))
    SET reply->qual[nqual].ordered_as_mnemonic = concat(reply->qual[nqual].ordered_as_mnemonic," +")
   ENDIF
   SET reply->qual[nqual].ordered_as_mnemonic = trim(concat(reply->qual[nqual].ordered_as_mnemonic,
     " ",reply->qual[nqual].ingred_list[ningredient].ordered_as_mnemonic," ",sdose),3)
 END ;Subroutine
 SUBROUTINE setintermittentmnemonic(nqual)
  DECLARE nindex = i4 WITH private, noconstant(0)
  IF (binvalidtype=1)
   FOR (nindex = ingred_cnt TO 1 BY - (1))
     IF ((reply->qual[nqual].ingred_list[nindex].ingredient_type_flag=itf_additive))
      CALL appendmnemonicanddose(nqual,nindex,0)
     ENDIF
   ENDFOR
   FOR (nindex = 1 TO ingred_cnt BY 1)
     IF ((reply->qual[nqual].ingred_list[nindex].ingredient_type_flag != itf_additive))
      CALL appendmnemonicanddose(nqual,nindex,0)
     ENDIF
   ENDFOR
  ELSE
   IF (nadditivecount=0)
    IF (ndiluentcount > 1)
     FOR (nindex = 1 TO ingred_cnt BY 1)
       IF ((reply->qual[nqual].ingred_list[nindex].ingredient_type_flag=itf_base)
        AND (reply->qual[nqual].ingred_list[nindex].clinically_significant_flag=csf_significant))
        CALL appendmnemonicanddose(nqual,nindex,0)
       ENDIF
     ENDFOR
    ELSEIF (ndiluentcount=1)
     FOR (nindex = 1 TO ingred_cnt BY 1)
       IF ((reply->qual[nqual].ingred_list[nindex].ingredient_type_flag=itf_base))
        CALL setmnemonictoingredient(nqual,nindex)
       ENDIF
     ENDFOR
    ELSE
     FOR (nindex = 1 TO ingred_cnt BY 1)
       IF ((((reply->qual[nqual].ingred_list[nindex].ingredient_type_flag=itf_medication)) OR ((((
       reply->qual[nqual].ingred_list[nindex].ingredient_type_flag=itf_additive)) OR ((reply->qual[
       nqual].ingred_list[nindex].ingredient_type_flag=itf_compound_parent))) )) )
        CALL setmnemonictoingredient(nqual,nindex)
       ENDIF
     ENDFOR
    ENDIF
   ELSEIF (nadditivecount=1)
    FOR (nindex = 1 TO ingred_cnt BY 1)
      IF ((((reply->qual[nqual].ingred_list[nindex].ingredient_type_flag=itf_additive)) OR ((reply->
      qual[nqual].ingred_list[nindex].ingredient_type_flag=itf_medication))) )
       CALL setmnemonictoingredient(nqual,nindex)
      ENDIF
    ENDFOR
    IF (ndiluentcount > 0)
     FOR (nindex = 1 TO ingred_cnt BY 1)
       IF ((reply->qual[nqual].ingred_list[nindex].ingredient_type_flag=itf_base)
        AND (reply->qual[nqual].ingred_list[nindex].clinically_significant_flag=csf_significant))
        CALL appendmnemonicanddose(nqual,nindex,0)
       ENDIF
     ENDFOR
    ENDIF
   ELSE
    FOR (nindex = 1 TO ingred_cnt BY 1)
      IF ((reply->qual[nqual].ingred_list[nindex].ingredient_type_flag=itf_additive))
       CALL appendmnemonicanddose(nqual,nindex,0)
      ENDIF
    ENDFOR
    IF (ndiluentcount > 0)
     FOR (nindex = 1 TO ingred_cnt BY 1)
       IF ((reply->qual[nqual].ingred_list[nindex].ingredient_type_flag=itf_base)
        AND (reply->qual[nqual].ingred_list[nindex].clinically_significant_flag=csf_significant))
        CALL appendmnemonicanddose(nqual,nindex,0)
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE setcontinuousivmnemonic(nqual)
   DECLARE nindex = i4 WITH private, noconstant(0)
   DECLARE ntoken = i4 WITH private, noconstant(0)
   DECLARE nanchor = i4 WITH private, noconstant(0)
   CALL prepareclinicallysigdiluents(nqual)
   IF (binvalidtype=1)
    FOR (nindex = 1 TO ingred_cnt BY 1)
      IF ((reply->qual[nqual].ingred_list[nindex].titrateable_flag=1))
       IF (nanchor=0)
        FOR (ntoken = 1 TO ingred_cnt BY 1)
          IF ((reply->qual[nqual].ingred_list[ntoken].normalized_rate_unit_cd > 0.0))
           SET nanchor = ntoken
          ENDIF
        ENDFOR
       ENDIF
       SET badditivesfirst = 1
      ENDIF
    ENDFOR
    IF (badditivesfirst=1)
     IF (nanchor > 0
      AND (reply->qual[nqual].ingred_list[nanchor].ingredient_type_flag=itf_additive))
      CALL appendmnemonicanddose(nqual,nanchor,1)
     ENDIF
     FOR (nindex = 1 TO ingred_cnt BY 1)
       IF (nindex != nanchor
        AND (reply->qual[nqual].ingred_list[nindex].ingredient_type_flag=itf_additive))
        CALL appendmnemonicanddose(nqual,nindex,1)
       ENDIF
     ENDFOR
     IF (nanchor > 0
      AND (reply->qual[nqual].ingred_list[nanchor].ingredient_type_flag=itf_base))
      CALL appendmnemonicanddose(nqual,nanchor,0)
     ENDIF
     FOR (nindex = 1 TO ingred_cnt BY 1)
       IF (nindex != nanchor
        AND (reply->qual[nqual].ingred_list[nindex].ingredient_type_flag=itf_base))
        CALL appendmnemonicanddose(nqual,nindex,0)
       ENDIF
     ENDFOR
     IF (nanchor > 0
      AND (reply->qual[nqual].ingred_list[nanchor].ingredient_type_flag != itf_base)
      AND (reply->qual[nqual].ingred_list[nanchor].ingredient_type_flag != itf_additive))
      CALL appendmnemonicanddose(nqual,nanchor,1)
     ENDIF
     FOR (nindex = 1 TO ingred_cnt BY 1)
       IF (nindex != nanchor
        AND (reply->qual[nqual].ingred_list[nindex].ingredient_type_flag != itf_base)
        AND (reply->qual[nqual].ingred_list[nindex].ingredient_type_flag != itf_additive))
        CALL appendmnemonicanddose(nqual,nindex,1)
       ENDIF
     ENDFOR
    ELSE
     IF (nanchor > 0
      AND (reply->qual[nqual].ingred_list[nanchor].ingredient_type_flag=itf_base))
      CALL appendmnemonicanddose(nqual,nanchor,0)
     ENDIF
     FOR (nindex = 1 TO ingred_cnt BY 1)
       IF (nindex != nanchor
        AND (reply->qual[nqual].ingred_list[nindex].ingredient_type_flag=itf_base))
        CALL appendmnemonicanddose(nqual,nindex,0)
       ENDIF
     ENDFOR
     IF (nanchor > 0
      AND (reply->qual[nqual].ingred_list[nanchor].ingredient_type_flag=itf_additive))
      CALL appendmnemonicanddose(nqual,nanchor,1)
     ENDIF
     FOR (nindex = 1 TO ingred_cnt BY 1)
       IF (nindex != nanchor
        AND (reply->qual[nqual].ingred_list[nindex].ingredient_type_flag=itf_additive))
        CALL appendmnemonicanddose(nqual,nindex,1)
       ENDIF
     ENDFOR
     IF (nanchor > 0
      AND (reply->qual[nqual].ingred_list[nanchor].ingredient_type_flag != itf_base)
      AND (reply->qual[nqual].ingred_list[nanchor].ingredient_type_flag != itf_additive))
      CALL appendmnemonicanddose(nqual,nanchor,1)
     ENDIF
     FOR (nindex = 1 TO ingred_cnt BY 1)
       IF (nindex != nanchor
        AND (reply->qual[nqual].ingred_list[nindex].ingredient_type_flag != itf_base)
        AND (reply->qual[nqual].ingred_list[nindex].ingredient_type_flag != itf_additive))
        CALL appendmnemonicanddose(nqual,nindex,1)
       ENDIF
     ENDFOR
    ENDIF
   ELSE
    FOR (nindex = 1 TO ingred_cnt BY 1)
      IF ((reply->qual[nqual].ingred_list[nindex].titrateable_flag=1))
       SET badditivesfirst = 2
      ENDIF
    ENDFOR
    IF (badditivesfirst=2)
     FOR (nindex = 1 TO ingred_cnt BY 1)
       IF ((reply->qual[nqual].ingred_list[nindex].normalized_rate_unit_cd > 0.0))
        SET nanchor = nindex
       ENDIF
     ENDFOR
     IF (nanchor > 0
      AND (reply->qual[nqual].ingred_list[nanchor].ingredient_type_flag=itf_additive))
      CALL appendmnemonicanddose(nqual,nanchor,1)
     ENDIF
     FOR (nindex = 1 TO ingred_cnt BY 1)
       IF (nindex != nanchor
        AND (reply->qual[nqual].ingred_list[nindex].ingredient_type_flag=itf_additive))
        CALL appendmnemonicanddose(nqual,nindex,1)
       ENDIF
     ENDFOR
     IF (nanchor > 0
      AND (reply->qual[nqual].ingred_list[nanchor].ingredient_type_flag=itf_base))
      CALL appendmnemonicanddose(nqual,nanchor,0)
     ENDIF
     FOR (nindex = 1 TO ingred_cnt BY 1)
       IF (nindex != nanchor
        AND (reply->qual[nqual].ingred_list[nindex].ingredient_type_flag=itf_base))
        CALL appendmnemonicanddose(nqual,nindex,0)
       ENDIF
     ENDFOR
    ELSE
     IF (badditivesfirst=1)
      FOR (nindex = 1 TO ingred_cnt BY 1)
        IF ((reply->qual[nqual].ingred_list[nindex].ingredient_type_flag=itf_additive))
         CALL appendmnemonicanddose(nqual,nindex,1)
        ENDIF
      ENDFOR
      FOR (nindex = 1 TO ingred_cnt BY 1)
        IF ((reply->qual[nqual].ingred_list[nindex].ingredient_type_flag=itf_base))
         CALL appendmnemonicanddose(nqual,nindex,0)
        ENDIF
      ENDFOR
     ELSE
      FOR (nindex = 1 TO ingred_cnt BY 1)
        IF ((reply->qual[nqual].ingred_list[nindex].ingredient_type_flag=itf_base))
         CALL appendmnemonicanddose(nqual,nindex,0)
        ENDIF
      ENDFOR
      FOR (nindex = 1 TO ingred_cnt BY 1)
        IF ((reply->qual[nqual].ingred_list[nindex].ingredient_type_flag=itf_additive))
         CALL appendmnemonicanddose(nqual,nindex,1)
        ENDIF
      ENDFOR
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(request->orders,5))),
   orders o,
   orders ot,
   order_action oa,
   code_value_event_r cve,
   order_catalog oc,
   order_iv_info oiv
  PLAN (d)
   JOIN (o
   WHERE (o.order_id=request->orders[d.seq].order_id))
   JOIN (oa
   WHERE oa.order_id=o.order_id)
   JOIN (ot
   WHERE ot.order_id=outerjoin(o.template_order_id))
   JOIN (cve
   WHERE cve.parent_cd=outerjoin(o.catalog_cd))
   JOIN (oc
   WHERE oc.catalog_cd=outerjoin(o.catalog_cd))
   JOIN (oiv
   WHERE oiv.order_id=outerjoin(o.order_id))
  ORDER BY o.order_id, oa.action_sequence
  HEAD o.order_id
   count1 = (count1+ 1), stat = alterlist(reply->qual,count1), reply->qual[count1].order_id = o
   .order_id,
   reply->qual[count1].catalog_type_cd = o.catalog_type_cd, reply->qual[count1].med_order_type_cd = o
   .med_order_type_cd, reply->qual[count1].orig_ord_as_flag = o.orig_ord_as_flag,
   reply->qual[count1].activity_type_cd = o.activity_type_cd, reply->qual[count1].catalog_cd = o
   .catalog_cd, reply->qual[count1].person_id = o.person_id,
   reply->qual[count1].encntr_id = o.encntr_id, reply->qual[count1].dcp_clin_cat_cd = o
   .dcp_clin_cat_cd, reply->qual[count1].order_status_cd = o.order_status_cd,
   reply->qual[count1].incomplete_order_ind = o.incomplete_order_ind, reply->qual[count1].
   dept_status_cd = o.dept_status_cd, reply->qual[count1].order_mnemonic = o.order_mnemonic,
   reply->qual[count1].hna_order_mnemonic = o.hna_order_mnemonic, reply->qual[count1].
   ordered_as_mnemonic = o.ordered_as_mnemonic, reply->qual[count1].orig_order_dt_tm = cnvtdatetime(o
    .orig_order_dt_tm),
   reply->qual[count1].orig_order_tz = o.orig_order_tz, reply->qual[count1].last_update_provider_id
    = o.last_update_provider_id, reply->qual[count1].template_order_id = ot.order_id,
   reply->qual[count1].template_order_flag = o.template_order_flag, reply->qual[count1].synonym_id =
   o.synonym_id, reply->qual[count1].order_detail_display_line = o.order_detail_display_line,
   reply->qual[count1].clinical_display_line = o.clinical_display_line, reply->qual[count1].
   oe_format_id = o.oe_format_id, reply->qual[count1].constant_ind = o.constant_ind,
   reply->qual[count1].prn_ind = o.prn_ind, reply->qual[count1].need_rx_verify_ind = o
   .need_rx_verify_ind, reply->qual[count1].need_rx_clin_review_flag = o.need_rx_clin_review_flag,
   reply->qual[count1].need_nurse_review_ind = o.need_nurse_review_ind, reply->qual[count1].
   need_doctor_cosign_ind = o.need_doctor_cosign_ind, reply->qual[count1].current_start_dt_tm =
   cnvtdatetime(o.current_start_dt_tm),
   reply->qual[count1].current_start_tz = o.current_start_tz, reply->qual[count1].
   projected_stop_dt_tm = cnvtdatetime(o.projected_stop_dt_tm), reply->qual[count1].projected_stop_tz
    = o.projected_stop_tz,
   reply->qual[count1].stop_type_cd = o.stop_type_cd, reply->qual[count1].suspend_ind = o.suspend_ind,
   reply->qual[count1].suspend_effective_dt_tm = cnvtdatetime(o.suspend_effective_dt_tm),
   reply->qual[count1].resume_ind = o.resume_ind, reply->qual[count1].resume_effective_dt_tm =
   cnvtdatetime(o.resume_effective_dt_tm), reply->qual[count1].discontinue_ind = o.discontinue_ind,
   reply->qual[count1].discontinue_effective_dt_tm = cnvtdatetime(o.discontinue_effective_dt_tm),
   reply->qual[count1].discontinue_effective_tz = o.discontinue_effective_tz, reply->qual[count1].
   discontinue_type_cd = o.discontinue_type_cd,
   reply->qual[count1].last_updt_cnt = o.updt_cnt, reply->qual[count1].dosing_method_flag = o
   .dosing_method_flag, reply->qual[count1].template_dose_seq = o.template_dose_sequence,
   reply->qual[count1].applicable_fields_bit = oiv.applicable_fields_bit, reply->qual[count1].
   finished_bags_cnt = oiv.finished_bags_cnt, reply->qual[count1].total_bags_nbr = oiv.total_bags_nbr,
   reply->qual[count1].updated_to_verified_flag = 0
   IF ((request->orders[d.seq].action_seq=0))
    reply->qual[count1].last_action_seq = o.last_action_sequence
   ELSE
    reply->qual[count1].last_action_seq = request->orders[d.seq].action_seq
   ENDIF
   reply->qual[count1].ref_text_mask = o.ref_text_mask, reply->qual[count1].orderable_type_flag = o
   .orderable_type_flag, reply->qual[count1].interval_ind = o.interval_ind,
   reply->qual[count1].hide_flag = o.hide_flag
   IF (o.template_order_id != 0)
    reply->qual[count1].comment_type_mask = bor(o.comment_type_mask,ot.comment_type_mask)
   ELSE
    reply->qual[count1].comment_type_mask = o.comment_type_mask
   ENDIF
   reply->qual[count1].cki = o.cki, reply->qual[count1].freq_type_flag = o.freq_type_flag, reply->
   qual[count1].ingredient_ind = o.ingredient_ind,
   reply->qual[count1].rx_mask = o.rx_mask, reply->qual[count1].order_comment_ind = o
   .order_comment_ind, reply->qual[count1].updt_id = o.updt_id,
   reply->qual[count1].cs_order_id = o.cs_order_id, reply->qual[count1].cs_flag = o.cs_flag, reply->
   qual[count1].activity_subtype_cd = oc.activity_subtype_cd,
   reply->qual[count1].bill_only_ind = oc.bill_only_ind, reply->qual[count1].updt_dt_tm = o
   .updt_dt_tm, reply->qual[count1].status_dt_tm = o.status_dt_tm,
   reply->qual[count1].last_ingred_action_sequence = o.last_ingred_action_sequence, reply->qual[
   count1].event_cd = cve.event_cd, reply->qual[count1].protocol_order_id = o.protocol_order_id,
   reply->qual[count1].last_core_action_seq = o.last_core_action_sequence, done = 0
   IF ((((ordered_cd=reply->qual[count1].order_status_cd)) OR ((((inprocess_cd=reply->qual[count1].
   order_status_cd)) OR ((susp_cd=reply->qual[count1].order_status_cd))) )) )
    IF ((reply->qual[count1].discontinue_ind > 0))
     IF ((cnvtdatetime(curdate,curtime3) >= reply->qual[count1].discontinue_effective_dt_tm))
      reply->qual[count1].order_status_cd = disc_cd, done = 1
     ENDIF
    ENDIF
    IF (done=0)
     IF ((reply->qual[count1].suspend_ind > 0))
      IF ((cnvtdatetime(curdate,curtime3) >= reply->qual[count1].suspend_effective_dt_tm))
       IF ((reply->qual[count1].resume_ind > 0))
        IF ((cnvtdatetime(curdate,curtime3) >= reply->qual[count1].resume_effective_dt_tm))
         reply->qual[count1].suspend_ind = 0, reply->qual[count1].suspend_effective_dt_tm = null,
         reply->qual[count1].resume_ind = 0,
         reply->qual[count1].resume_effective_dt_tm = null, reply->qual[count1].order_status_cd =
         ordered_cd
        ELSE
         reply->qual[count1].order_status_cd = susp_cd
        ENDIF
       ELSE
        reply->qual[count1].order_status_cd = susp_cd
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF ((reply->qual[count1].need_rx_clin_review_flag=0))
    reply->qual[count1].need_rx_clin_review_flag = rxverifymapping(reply->qual[count1].
     need_rx_verify_ind)
   ENDIF
   IF (o.template_order_id != 0)
    reply->qual[count1].template_order_action_sequence = o.template_core_action_sequence, reply->
    qual[count1].core_group_last_action_seq = o.template_core_action_sequence, reply->qual[count1].
    last_template_core_action_seq = ot.last_core_action_sequence,
    reply->qual[count1].template_order_status = ot.order_status_cd, reply->qual[count1].
    last_ingred_action_sequence = ot.last_ingred_action_sequence, reply->qual[count1].ingredient_ind
     = ot.ingredient_ind,
    reply->qual[count1].need_nurse_review_ind = ot.need_nurse_review_ind, reply->qual[count1].
    need_doctor_cosign_ind = ot.need_doctor_cosign_ind, reply->qual[count1].
    last_template_order_action_seq = ot.last_action_sequence
   ENDIF
  DETAIL
   IF (oa.action_sequence=1)
    reply->qual[count1].communication_type_cd = oa.communication_type_cd, reply->qual[count1].
    order_provider_id = oa.order_provider_id, reply->qual[count1].action_personnel_id = oa
    .action_personnel_id
   ENDIF
   IF (oa.order_status_cd=canceled_cd)
    reply->qual[count1].cancel_communication_type_cd = oa.communication_type_cd
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM act_pw_comp apc,
   pathway pw
  PLAN (apc
   WHERE expand(idx,1,count1,apc.parent_entity_id,evaluate(reply->qual[idx].template_order_id,0.0,
     reply->qual[idx].order_id,reply->qual[idx].template_order_id))
    AND apc.parent_entity_id != 0.0
    AND apc.active_ind=1
    AND apc.parent_entity_name="ORDERS")
   JOIN (pw
   WHERE pw.pathway_id=apc.pathway_id
    AND pw.pathway_type_cd=ivsequence_cd)
  DETAIL
   ord_idx = locateval(idx,1,count1,apc.parent_entity_id,reply->qual[idx].order_id)
   IF (ord_idx > 0)
    locate_idx = ord_idx
   ELSE
    tmp_ord_idx = locateval(idx,1,count1,apc.parent_entity_id,reply->qual[idx].template_order_id)
    IF (tmp_ord_idx > 0)
     locate_idx = tmp_ord_idx
    ENDIF
   ENDIF
   IF (locate_idx > 0)
    reply->qual[locate_idx].pathway_id = apc.pathway_id, reply->qual[locate_idx].pathway_type_cd = pw
    .pathway_type_cd, reply->qual[locate_idx].pathway_group_nbr = pw.pw_group_nbr,
    reply->qual[locate_idx].pathway_sequence = apc.sequence, reply->qual[locate_idx].
    pathway_description = pw.description
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(count1)),
   order_action oa
  PLAN (d)
   JOIN (oa
   WHERE (oa.order_id=reply->qual[d.seq].template_order_id)
    AND (oa.action_sequence > reply->qual[d.seq].core_group_last_action_seq))
  ORDER BY d.seq, oa.action_sequence
  HEAD d.seq
   bfoundnextcoreaction = 0
  DETAIL
   IF ((reply->qual[d.seq].template_order_id > 0.0))
    IF (bfoundnextcoreaction=0
     AND oa.core_ind=0)
     reply->qual[d.seq].core_group_last_action_seq = oa.action_sequence
    ELSEIF (oa.core_ind=1)
     bfoundnextcoreaction = 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF ((request->details_flag != 0))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(count1)),
    order_detail od,
    oe_format_fields off
   PLAN (d)
    JOIN (od
    WHERE (od.order_id=reply->qual[d.seq].order_id)
     AND (od.action_sequence=
    (SELECT
     max(od2.action_sequence)
     FROM order_detail od2
     WHERE od2.order_id=od.order_id
      AND od2.oe_field_id=od.oe_field_id
      AND (od2.action_sequence <= reply->qual[d.seq].last_action_seq)))
     AND ((od.oe_field_meaning_id+ 0) != 125)
     AND ((od.oe_field_meaning_id+ 0) != 2071))
    JOIN (off
    WHERE (off.oe_format_id=reply->qual[d.seq].oe_format_id)
     AND ((off.action_type_cd+ 0)=new_action_type_cd)
     AND ((off.oe_field_id+ 0)=od.oe_field_id))
   ORDER BY d.seq, od.order_id, od.oe_field_id,
    od.detail_sequence
   HEAD d.seq
    detail_cnt = 0
   DETAIL
    detail_cnt = (detail_cnt+ 1), stat = alterlist(reply->qual[d.seq].detqual,detail_cnt)
    IF (od.oe_field_display_value > " ")
     reply->qual[d.seq].detqual[detail_cnt].oe_field_display_value = od.oe_field_display_value
    ENDIF
    IF (od.oe_field_dt_tm_value > null)
     reply->qual[d.seq].detqual[detail_cnt].oe_field_dt_tm = od.oe_field_dt_tm_value
    ENDIF
    reply->qual[d.seq].detqual[detail_cnt].oe_field_tz = od.oe_field_tz, reply->qual[d.seq].detqual[
    detail_cnt].oe_field_id = od.oe_field_id, reply->qual[d.seq].detqual[detail_cnt].oe_field_meaning
     = od.oe_field_meaning,
    reply->qual[d.seq].detqual[detail_cnt].label_text = off.label_text, reply->qual[d.seq].detqual[
    detail_cnt].group_seq = off.group_seq, reply->qual[d.seq].detqual[detail_cnt].field_seq = off
    .field_seq,
    reply->qual[d.seq].detqual[detail_cnt].oe_field_meaning_id = od.oe_field_meaning_id, reply->qual[
    d.seq].detqual[detail_cnt].oe_field_value = od.oe_field_value
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(count1)),
    order_detail od,
    oe_format_fields off
   PLAN (d)
    JOIN (od
    WHERE (od.order_id=reply->qual[d.seq].template_order_id)
     AND (od.action_sequence=
    (SELECT
     max(od2.action_sequence)
     FROM order_detail od2
     WHERE od2.order_id=od.order_id
      AND od2.oe_field_id=od.oe_field_id
      AND (od2.action_sequence <= reply->qual[d.seq].core_group_last_action_seq)))
     AND ((od.oe_field_meaning_id+ 0) != 125)
     AND ((od.oe_field_meaning_id+ 0) != 2071)
     AND  NOT (expand(expand_index,1,size(reply->qual[d.seq].detqual,5),od.oe_field_id,reply->qual[d
     .seq].detqual[expand_index].oe_field_id)))
    JOIN (off
    WHERE (off.oe_format_id=reply->qual[d.seq].oe_format_id)
     AND ((off.action_type_cd+ 0)=new_action_type_cd)
     AND ((off.oe_field_id+ 0)=od.oe_field_id))
   ORDER BY d.seq, od.order_id, od.oe_field_id,
    od.detail_sequence
   HEAD d.seq
    detail_cnt = size(reply->qual[d.seq].detqual,5)
   DETAIL
    detail_cnt = (detail_cnt+ 1), stat = alterlist(reply->qual[d.seq].detqual,detail_cnt)
    IF (od.oe_field_display_value > " ")
     reply->qual[d.seq].detqual[detail_cnt].oe_field_display_value = od.oe_field_display_value
    ENDIF
    IF (od.oe_field_dt_tm_value > null)
     reply->qual[d.seq].detqual[detail_cnt].oe_field_dt_tm = od.oe_field_dt_tm_value
    ENDIF
    reply->qual[d.seq].detqual[detail_cnt].oe_field_tz = od.oe_field_tz, reply->qual[d.seq].detqual[
    detail_cnt].oe_field_id = od.oe_field_id, reply->qual[d.seq].detqual[detail_cnt].oe_field_meaning
     = od.oe_field_meaning,
    reply->qual[d.seq].detqual[detail_cnt].label_text = off.label_text, reply->qual[d.seq].detqual[
    detail_cnt].group_seq = off.group_seq, reply->qual[d.seq].detqual[detail_cnt].field_seq = off
    .field_seq,
    reply->qual[d.seq].detqual[detail_cnt].oe_field_meaning_id = od.oe_field_meaning_id, reply->qual[
    d.seq].detqual[detail_cnt].oe_field_value = od.oe_field_value
   WITH nocounter
  ;end select
  IF ((request->synonym_data_flag=0))
   SELECT INTO "nl:"
    oi.order_id, oi.dose_calculator_long_text_id, oi.comp_sequence
    FROM (dummyt d  WITH seq = value(count1)),
     order_ingredient oi,
     code_value_event_r cver,
     order_ingredient_dose oid,
     long_text lt
    PLAN (d)
     JOIN (oi
     WHERE oi.order_id=evaluate(reply->qual[d.seq].template_order_id,0.0,reply->qual[d.seq].order_id,
      reply->qual[d.seq].template_order_id)
      AND  NOT (oi.ingredient_type_flag IN (itf_compound_child))
      AND (oi.action_sequence=
     (SELECT
      max(oi2.action_sequence)
      FROM order_ingredient oi2
      WHERE oi2.order_id=oi.order_id
       AND oi2.action_sequence <= evaluate(reply->qual[d.seq].template_order_id,0.0,reply->qual[d.seq
       ].last_action_seq,reply->qual[d.seq].core_group_last_action_seq))))
     JOIN (cver
     WHERE cver.parent_cd=outerjoin(oi.catalog_cd))
     JOIN (oid
     WHERE oid.order_id=outerjoin(oi.order_id)
      AND oid.action_sequence=outerjoin(oi.action_sequence)
      AND oid.comp_sequence=outerjoin(oi.comp_sequence)
      AND oid.dose_sequence=outerjoin(reply->qual[d.seq].template_dose_seq))
     JOIN (lt
     WHERE lt.long_text_id=outerjoin(oi.dose_calculator_long_text_id))
    ORDER BY d.seq, oi.comp_sequence, oi.action_sequence DESC
    HEAD d.seq
     binvalidtype = 0, ndiluentcount = 0, nadditivecount = 0,
     badditivesfirst = 0, ingred_cnt = 0, reply->qual[d.seq].ingredient_action_sequence = oi
     .action_sequence
    HEAD oi.comp_sequence
     ingred_cnt = (ingred_cnt+ 1)
     IF (ingred_cnt > size(reply->qual[d.seq].ingred_list,5))
      stat = alterlist(reply->qual[d.seq].ingred_list,(ingred_cnt+ 5))
     ENDIF
     reply->qual[d.seq].ingred_list[ingred_cnt].titrateable_flag = - (1), reply->qual[d.seq].
     ingred_list[ingred_cnt].autoprog_syn_ind = - (1), reply->qual[d.seq].ingred_list[ingred_cnt].
     autoprogramming_id = - (1)
     IF (validate(lt.long_text))
      reply->qual[d.seq].ingred_list[ingred_cnt].adjusted_patient_weight = cnvtreal(substring((
        findstring('<adjustedweight type="double">',cnvtlower(lt.long_text))+ 30),(findstring(
         "</adjustedweight>",cnvtlower(lt.long_text)) - (findstring('<adjustedweight type="double">',
         cnvtlower(lt.long_text))+ 30)),lt.long_text)), reply->qual[d.seq].ingred_list[ingred_cnt].
      adjusted_patient_weight_cd = cnvtreal(substring((findstring(
         '<adjustedweightunitcd type="double">',cnvtlower(lt.long_text))+ 36),(findstring(
         "</adjustedweightunitcd>",cnvtlower(lt.long_text)) - (findstring(
         '<adjustedweightunitcd type="double">',cnvtlower(lt.long_text))+ 36)),lt.long_text)), reply
      ->qual[d.seq].ingred_list[ingred_cnt].adjusted_patient_height = cnvtreal(substring((findstring(
         '<height type="double">',cnvtlower(lt.long_text))+ 22),(findstring("</height>",cnvtlower(lt
          .long_text)) - (findstring('<height type="double">',cnvtlower(lt.long_text))+ 22)),lt
        .long_text)),
      reply->qual[d.seq].ingred_list[ingred_cnt].adjusted_patient_height_cd = cnvtreal(substring((
        findstring('<heightunitcd type="double">',cnvtlower(lt.long_text))+ 28),(findstring(
         "</heightunitcd>",cnvtlower(lt.long_text)) - (findstring('<heightunitcd type="double">',
         cnvtlower(lt.long_text))+ 28)),lt.long_text)), reply->qual[d.seq].ingred_list[ingred_cnt].
      final_dose = cnvtreal(substring((findstring('<finaldose type="double">',cnvtlower(lt.long_text)
         )+ 25),(findstring("</finaldose>",cnvtlower(lt.long_text)) - (findstring(
         '<finaldose type="double">',cnvtlower(lt.long_text))+ 25)),lt.long_text)), reply->qual[d.seq
      ].ingred_list[ingred_cnt].final_dose_unit_cd = cnvtreal(substring((findstring(
         '<finaldoseunitcd type="double">',cnvtlower(lt.long_text))+ 31),(findstring(
         "</finaldoseunitcd>",cnvtlower(lt.long_text)) - (findstring(
         '<finaldoseunitcd type="double">',cnvtlower(lt.long_text))+ 31)),lt.long_text)),
      reply->qual[d.seq].ingred_list[ingred_cnt].actual_final_dose = cnvtreal(substring((findstring(
         '<actualfinaldose type="double">',cnvtlower(lt.long_text))+ 31),(findstring(
         "</actualfinaldose>",cnvtlower(lt.long_text)) - (findstring(
         '<actualfinaldose type="double">',cnvtlower(lt.long_text))+ 31)),lt.long_text)), reply->
      qual[d.seq].ingred_list[ingred_cnt].actual_final_dose_unit_cd = cnvtreal(substring((findstring(
         '<actualfinaldoseunitcd type="double">',cnvtlower(lt.long_text))+ 37),(findstring(
         "</actualfinaldoseunitcd>",cnvtlower(lt.long_text)) - (findstring(
         '<actualfinaldoseunitcd type="double">',cnvtlower(lt.long_text))+ 37)),lt.long_text))
     ENDIF
     CALL populateingredientdetails(d.seq),
     CALL countingredienttypes(d.seq,ingred_cnt)
    FOOT  d.seq
     CALL generateordermnemonic(d.seq), stat = alterlist(reply->qual[d.seq].ingred_list,ingred_cnt)
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    oi.order_id, oi.dose_calculator_long_text_id, oi.comp_sequence
    FROM (dummyt d  WITH seq = value(count1)),
     order_ingredient oi,
     code_value_event_r cver,
     order_catalog_synonym ocatsyn,
     order_ingredient_dose oid,
     order_ingredient oi_ap,
     order_catalog_synonym ocatsyn_ap,
     long_text lt
    PLAN (d)
     JOIN (oi
     WHERE oi.order_id=evaluate(reply->qual[d.seq].template_order_id,0.0,reply->qual[d.seq].order_id,
      reply->qual[d.seq].template_order_id)
      AND  NOT (oi.ingredient_type_flag IN (itf_compound_child))
      AND (oi.action_sequence=
     (SELECT
      max(oi2.action_sequence)
      FROM order_ingredient oi2
      WHERE oi2.order_id=oi.order_id
       AND oi2.action_sequence <= evaluate(reply->qual[d.seq].template_order_id,0.0,reply->qual[d.seq
       ].last_action_seq,reply->qual[d.seq].core_group_last_action_seq))))
     JOIN (cver
     WHERE cver.parent_cd=outerjoin(oi.catalog_cd))
     JOIN (ocatsyn
     WHERE ocatsyn.synonym_id=oi.synonym_id)
     JOIN (oid
     WHERE oid.order_id=outerjoin(oi.order_id)
      AND oid.action_sequence=outerjoin(oi.action_sequence)
      AND oid.comp_sequence=outerjoin(oi.comp_sequence)
      AND oid.dose_sequence=outerjoin(reply->qual[d.seq].template_dose_seq))
     JOIN (oi_ap
     WHERE oi_ap.order_id=outerjoin(oi.order_id)
      AND oi_ap.action_sequence=outerjoin(1)
      AND oi_ap.catalog_cd=outerjoin(oi.catalog_cd))
     JOIN (ocatsyn_ap
     WHERE ocatsyn_ap.synonym_id=outerjoin(oi_ap.synonym_id)
      AND ocatsyn_ap.active_ind=outerjoin(1))
     JOIN (lt
     WHERE lt.long_text_id=outerjoin(oi.dose_calculator_long_text_id))
    ORDER BY d.seq, oi.comp_sequence, oi.action_sequence DESC
    HEAD d.seq
     binvalidtype = 0, ndiluentcount = 0, nadditivecount = 0,
     badditivesfirst = 0, ingred_cnt = 0, reply->qual[d.seq].ingredient_action_sequence = oi
     .action_sequence
    HEAD oi.comp_sequence
     ingred_cnt = (ingred_cnt+ 1)
     IF (ingred_cnt > size(reply->qual[d.seq].ingred_list,5))
      stat = alterlist(reply->qual[d.seq].ingred_list,(ingred_cnt+ 5))
     ENDIF
     reply->qual[d.seq].ingred_list[ingred_cnt].titrateable_flag = ocatsyn
     .ingredient_rate_conversion_ind,
     CALL populateingredientdetails(d.seq)
     IF (ocatsyn_ap.synonym_id > 0)
      reply->qual[d.seq].ingred_list[ingred_cnt].autoprog_syn_ind = ocatsyn_ap.autoprog_syn_ind
      IF (ocatsyn_ap.autoprog_syn_ind=1)
       reply->qual[d.seq].ingred_list[ingred_cnt].autoprogramming_id = oi_ap.synonym_id
      ELSE
       reply->qual[d.seq].ingred_list[ingred_cnt].autoprogramming_id = oi_ap.catalog_cd
      ENDIF
     ELSE
      reply->qual[d.seq].ingred_list[ingred_cnt].autoprog_syn_ind = ocatsyn.autoprog_syn_ind
      IF (ocatsyn.autoprog_syn_ind=1)
       reply->qual[d.seq].ingred_list[ingred_cnt].autoprogramming_id = oi.synonym_id
      ELSE
       reply->qual[d.seq].ingred_list[ingred_cnt].autoprogramming_id = oi.catalog_cd
      ENDIF
     ENDIF
     IF (validate(lt.long_text))
      reply->qual[d.seq].ingred_list[ingred_cnt].adjusted_patient_weight = cnvtreal(substring((
        findstring('<adjustedweight type="double">',cnvtlower(lt.long_text))+ 30),(findstring(
         "</adjustedweight>",cnvtlower(lt.long_text)) - (findstring('<adjustedweight type="double">',
         cnvtlower(lt.long_text))+ 30)),lt.long_text)), reply->qual[d.seq].ingred_list[ingred_cnt].
      adjusted_patient_weight_cd = cnvtreal(substring((findstring(
         '<adjustedweightunitcd type="double">',cnvtlower(lt.long_text))+ 36),(findstring(
         "</adjustedweightunitcd>",cnvtlower(lt.long_text)) - (findstring(
         '<adjustedweightunitcd type="double">',cnvtlower(lt.long_text))+ 36)),lt.long_text)), reply
      ->qual[d.seq].ingred_list[ingred_cnt].adjusted_patient_height = cnvtreal(substring((findstring(
         '<height type="double">',cnvtlower(lt.long_text))+ 22),(findstring("</height>",cnvtlower(lt
          .long_text)) - (findstring('<height type="double">',cnvtlower(lt.long_text))+ 22)),lt
        .long_text)),
      reply->qual[d.seq].ingred_list[ingred_cnt].adjusted_patient_height_cd = cnvtreal(substring((
        findstring('<heightunitcd type="double">',cnvtlower(lt.long_text))+ 28),(findstring(
         "</heightunitcd>",cnvtlower(lt.long_text)) - (findstring('<heightunitcd type="double">',
         cnvtlower(lt.long_text))+ 28)),lt.long_text)), reply->qual[d.seq].ingred_list[ingred_cnt].
      final_dose = cnvtreal(substring((findstring('<finaldose type="double">',cnvtlower(lt.long_text)
         )+ 25),(findstring("</finaldose>",cnvtlower(lt.long_text)) - (findstring(
         '<finaldose type="double">',cnvtlower(lt.long_text))+ 25)),lt.long_text)), reply->qual[d.seq
      ].ingred_list[ingred_cnt].final_dose_unit_cd = cnvtreal(substring((findstring(
         '<finaldoseunitcd type="double">',cnvtlower(lt.long_text))+ 31),(findstring(
         "</finaldoseunitcd>",cnvtlower(lt.long_text)) - (findstring(
         '<finaldoseunitcd type="double">',cnvtlower(lt.long_text))+ 31)),lt.long_text)),
      reply->qual[d.seq].ingred_list[ingred_cnt].actual_final_dose = cnvtreal(substring((findstring(
         '<actualfinaldose type="double">',cnvtlower(lt.long_text))+ 31),(findstring(
         "</actualfinaldose>",cnvtlower(lt.long_text)) - (findstring(
         '<actualfinaldose type="double">',cnvtlower(lt.long_text))+ 31)),lt.long_text)), reply->
      qual[d.seq].ingred_list[ingred_cnt].actual_final_dose_unit_cd = cnvtreal(substring((findstring(
         '<actualfinaldoseunitcd type="double">',cnvtlower(lt.long_text))+ 37),(findstring(
         "</actualfinaldoseunitcd>",cnvtlower(lt.long_text)) - (findstring(
         '<actualfinaldoseunitcd type="double">',cnvtlower(lt.long_text))+ 37)),lt.long_text))
     ENDIF
     CALL countingredienttypes(d.seq,ingred_cnt)
     IF (ocatsyn.display_additives_first_ind=1)
      badditivesfirst = 1
     ENDIF
    FOOT  d.seq
     CALL generateordermnemonic(d.seq), stat = alterlist(reply->qual[d.seq].ingred_list,ingred_cnt)
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF ((request->comment_flag != 0))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(count1)),
    order_comment oc,
    long_text lt
   PLAN (d)
    JOIN (oc
    WHERE oc.order_id=evaluate(reply->qual[d.seq].template_order_id,0.0,reply->qual[d.seq].order_id,
     reply->qual[d.seq].template_order_id)
     AND oc.comment_type_cd != admin_note_cd
     AND (oc.action_sequence=
    (SELECT
     max(oc2.action_sequence)
     FROM order_comment oc2
     WHERE oc2.order_id=evaluate(reply->qual[d.seq].template_order_id,0.0,reply->qual[d.seq].order_id,
      reply->qual[d.seq].template_order_id)
      AND oc2.comment_type_cd=oc.comment_type_cd
      AND oc2.action_sequence <= evaluate(reply->qual[d.seq].template_order_id,0.0,reply->qual[d.seq]
      .last_action_seq,reply->qual[d.seq].core_group_last_action_seq))))
    JOIN (lt
    WHERE lt.long_text_id=oc.long_text_id
     AND lt.active_ind=1)
   ORDER BY d.seq, oc.order_id, oc.comment_type_cd
   HEAD d.seq
    comment_cnt = 0
   DETAIL
    comment_cnt = (comment_cnt+ 1), stat = alterlist(reply->qual[d.seq].comments,comment_cnt), reply
    ->qual[d.seq].comments[comment_cnt].type = oc.comment_type_cd,
    reply->qual[d.seq].comments[comment_cnt].text = lt.long_text, reply->qual[d.seq].comments[
    comment_cnt].updt_id = oc.updt_id, reply->qual[d.seq].comments[comment_cnt].updt_dt_tm = oc
    .updt_dt_tm
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(count1)),
    order_comment oc,
    long_text lt
   PLAN (d)
    JOIN (oc
    WHERE oc.order_id=evaluate(reply->qual[d.seq].protocol_order_id,0.0,evaluate(reply->qual[d.seq].
      template_order_id,0.0,reply->qual[d.seq].order_id,reply->qual[d.seq].template_order_id),reply->
     qual[d.seq].protocol_order_id)
     AND oc.comment_type_cd=admin_note_cd
     AND (oc.action_sequence=
    (SELECT
     max(oc2.action_sequence)
     FROM order_comment oc2
     WHERE oc2.order_id=evaluate(reply->qual[d.seq].protocol_order_id,0.0,evaluate(reply->qual[d.seq]
       .template_order_id,0.0,reply->qual[d.seq].order_id,reply->qual[d.seq].template_order_id),reply
      ->qual[d.seq].protocol_order_id)
      AND oc2.comment_type_cd=admin_note_cd)))
    JOIN (lt
    WHERE lt.long_text_id=oc.long_text_id
     AND lt.active_ind=1)
   ORDER BY d.seq, oc.order_id, oc.comment_type_cd
   HEAD d.seq
    comment_cnt = size(reply->qual[d.seq].comments,5), reply->qual[d.seq].comment_type_mask = bor(
     reply->qual[d.seq].comment_type_mask,admin_note_mask)
   DETAIL
    comment_cnt = (comment_cnt+ 1), stat = alterlist(reply->qual[d.seq].comments,comment_cnt), reply
    ->qual[d.seq].comments[comment_cnt].type = oc.comment_type_cd,
    reply->qual[d.seq].comments[comment_cnt].text = lt.long_text, reply->qual[d.seq].comments[
    comment_cnt].updt_id = oc.updt_id, reply->qual[d.seq].comments[comment_cnt].updt_dt_tm = oc
    .updt_dt_tm
   WITH nocounter
  ;end select
 ENDIF
 SUBROUTINE rxverifymapping(verifyind)
   DECLARE verified = i2 WITH protect, constant(0)
   DECLARE needs_review = i2 WITH protect, constant(1)
   DECLARE rejected = i2 WITH protect, constant(2)
   DECLARE clinreviewflag_needs_review = i2 WITH protect, constant(1)
   DECLARE clinreviewflag_reviewed = i2 WITH protect, constant(2)
   DECLARE clinreviewflag_rejected = i2 WITH protect, constant(3)
   CASE (verifyind)
    OF verified:
     RETURN(clinreviewflag_reviewed)
    OF needs_review:
     RETURN(clinreviewflag_needs_review)
    OF rejected:
     RETURN(clinreviewflag_rejected)
   ENDCASE
   RETURN(clinreviewflag_needs_review)
 END ;Subroutine
 SUBROUTINE populateingredientdetails(qualindex)
   SET reply->qual[qualindex].ingred_list[ingred_cnt].order_mnemonic = oi.order_mnemonic
   SET reply->qual[qualindex].ingred_list[ingred_cnt].ordered_as_mnemonic = oi.ordered_as_mnemonic
   SET reply->qual[qualindex].ingred_list[ingred_cnt].synonym_id = oi.synonym_id
   SET reply->qual[qualindex].ingred_list[ingred_cnt].catalog_cd = oi.catalog_cd
   SET reply->qual[qualindex].ingred_list[ingred_cnt].frequency_cd = oi.freq_cd
   SET reply->qual[qualindex].ingred_list[ingred_cnt].comp_sequence = oi.comp_sequence
   SET reply->qual[qualindex].ingred_list[ingred_cnt].ingredient_type_flag = oi.ingredient_type_flag
   SET reply->qual[qualindex].ingred_list[ingred_cnt].iv_seq = oi.iv_seq
   SET reply->qual[qualindex].ingred_list[ingred_cnt].hna_order_mnemonic = oi.hna_order_mnemonic
   SET reply->qual[qualindex].ingred_list[ingred_cnt].event_cd = cver.event_cd
   SET reply->qual[qualindex].ingred_list[ingred_cnt].normalized_rate = oi.normalized_rate
   SET reply->qual[qualindex].ingred_list[ingred_cnt].normalized_rate_unit_cd = oi
   .normalized_rate_unit_cd
   SET reply->qual[qualindex].ingred_list[ingred_cnt].concentration = oi.concentration
   SET reply->qual[qualindex].ingred_list[ingred_cnt].concentration_unit_cd = oi
   .concentration_unit_cd
   SET reply->qual[qualindex].ingred_list[ingred_cnt].clinically_significant_flag = oi
   .clinically_significant_flag
   SET reply->qual[qualindex].ingred_list[ingred_cnt].include_in_total_volume_flag = oi
   .include_in_total_volume_flag
   SET reply->qual[qualindex].ingred_list[ingred_cnt].ingredient_source_flag = oi
   .ingredient_source_flag
   IF (oid.order_ingredient_dose_id > 0)
    SET reply->qual[qualindex].ingred_list[ingred_cnt].volume_value = oid.volume_dose_value
    SET reply->qual[qualindex].ingred_list[ingred_cnt].volume_unit_cd = oid.volume_dose_unit_cd
    SET reply->qual[qualindex].ingred_list[ingred_cnt].strength_value = oid.strength_dose_value
    SET reply->qual[qualindex].ingred_list[ingred_cnt].strength_unit_cd = oid.strength_dose_unit_cd
    SET reply->qual[qualindex].ingred_list[ingred_cnt].ordered_dose_value = oid.ordered_dose_value
    SET reply->qual[qualindex].ingred_list[ingred_cnt].ordered_dose_unit_cd = oid
    .ordered_dose_unit_cd
    IF (oid.strength_dose_value_display != "")
     SET reply->qual[qualindex].ingred_list[ingred_cnt].order_detail_display_line = oid
     .strength_dose_value_display
    ELSEIF (oid.volume_dose_value_display != "")
     SET reply->qual[qualindex].ingred_list[ingred_cnt].order_detail_display_line = oid
     .volume_dose_value_display
    ELSEIF (oid.ordered_dose_value_display != "")
     SET reply->qual[qualindex].ingred_list[ingred_cnt].order_detail_display_line = oid
     .ordered_dose_value_display
    ENDIF
   ELSE
    SET reply->qual[qualindex].ingred_list[ingred_cnt].volume_value = oi.volume
    SET reply->qual[qualindex].ingred_list[ingred_cnt].volume_unit_cd = oi.volume_unit
    SET reply->qual[qualindex].ingred_list[ingred_cnt].strength_value = oi.strength
    SET reply->qual[qualindex].ingred_list[ingred_cnt].strength_unit_cd = oi.strength_unit
    SET reply->qual[qualindex].ingred_list[ingred_cnt].ordered_dose_value = oi.ordered_dose
    SET reply->qual[qualindex].ingred_list[ingred_cnt].ordered_dose_unit_cd = oi.ordered_dose_unit_cd
    SET reply->qual[qualindex].ingred_list[ingred_cnt].freetext_dose = oi.freetext_dose
    SET reply->qual[qualindex].ingred_list[ingred_cnt].dose_quantity = oi.dose_quantity
    SET reply->qual[qualindex].ingred_list[ingred_cnt].dose_quantity_unit = oi.dose_quantity_unit
    SET reply->qual[qualindex].ingred_list[ingred_cnt].order_detail_display_line = oi
    .order_detail_display_line
   ENDIF
 END ;Subroutine
 IF (count1 > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET last_mod = "020"
 SET mod_date = "10/26/2015"
 SET modify = nopredeclare
END GO
