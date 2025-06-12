CREATE PROGRAM ams_lab_modify_orderable:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Logical/Path:" = "",
  "Filename:" = ""
  WITH outdev, filepath, filename
 DECLARE errornum = i4
 DECLARE fpath = vc
 DECLARE fname = vc
 SET errornum = 0
 SET fpath = ""
 SET fname = ""
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = - (1)
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET failed = exe_error
  SET serrmsg = "User must be a Cerner AMS Associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 FREE RECORD request_500010
 FREE RECORD reply_500010
 RECORD request_500010(
   1 catalog_cd = f8
 )
 RECORD reply_500010(
   1 ic_auto_verify_flag = i2
   1 discern_auto_verify_flag = i2
   1 modifiable_flag = i2
   1 dcp_clin_cat_cd = f8
   1 catalog_cd = f8
   1 consent_form_ind = i2
   1 active_ind = i2
   1 catalog_type_cd = f8
   1 catalog_type_disp = vc
   1 meaning = vc
   1 activity_type_cd = f8
   1 activity_subtype_cd = f8
   1 requisition_format_cd = f8
   1 requisition_routing_cd = f8
   1 inst_restriction_ind = i2
   1 schedule_ind = i2
   1 description = vc
   1 iv_ingredient_ind = i2
   1 print_req_ind = i2
   1 oe_format_id = f8
   1 orderable_type_flag = i2
   1 complete_upon_order_ind = i2
   1 quick_chart_ind = i2
   1 comment_template_flag = i2
   1 prep_info_flag = i2
   1 bill_only_ind = i2
   1 dup_checking_ind = i2
   1 order_review_ind = i2
   1 cont_order_method_flag = i2
   1 consent_form_format_cd = f8
   1 consent_form_routing_cd = f8
   1 medication_ind = i2
   1 build_medication_ind = i2
   1 dc_display_days = i4
   1 dc_interaction_days = i4
   1 gcr_name = vc
   1 orc_text_exists = i2
   1 orc_text = vc
   1 text_updt_cnt = i4
   1 updt_cnt = i4
   1 auto_cancel_ind = i2
   1 stop_type_cd = f8
   1 stop_duration = i2
   1 stop_duration_unit_cd = f8
   1 form_level = i4
   1 form_id = f8
   1 disable_order_comment_ind = i2
   1 vetting_approval_flag = i2
   1 dept_disp_name = vc
   1 qual_mnemonic[*]
     2 synonym_id = f8
     2 mnemonic = vc
     2 virtual_view = vc
     2 health_plan_view = vc
     2 concentration_strength = f8
     2 concentration_strength_unit_cd = f8
     2 concentration_volume = f8
     2 concentration_volume_unit_cd = f8
     2 oe_format_id = f8
     2 mnemonic_type_cd = f8
     2 rx_mask = i4
     2 active_ind = i2
     2 ing_rate_conversion_ind = i2
     2 witness_flag = i2
     2 order_sentence_id = f8
     2 orderable_type_flag = i2
     2 hide_flag = i2
     2 updt_cnt = i4
     2 ref_text_mask = i4
     2 qual_facility[*]
       3 facility_cd = f8
     2 high_alert_ind = i2
     2 high_alert_long_text_id = f8
     2 high_alert_long_text = vc
     2 high_alert_notify_ind = i2
     2 intermittent_ind = i2
     2 display_additives_first_ind = i2
     2 rounding_rule_cd = f8
     2 ign_hide_flag = i2
     2 lock_target_dose_ind = i2
     2 max_final_dose = f8
     2 max_final_dose_unit_cd = f8
     2 max_dose_calc_bsa_value = f8
     2 preferred_dose_flag = i2
   1 qual_review[*]
     2 action_type_cd = f8
     2 action_type_disp = c40
     2 action_type_mean = c12
     2 nurse_review_flag = i2
     2 doctor_cosign_flag = i2
     2 rx_verify_flag = i2
     2 updt_cnt = i4
   1 dup_cnt = i2
   1 qual_dup[*]
   1 entity_cnt = i4
   1 qual_entity[*]
   1 qual_therapeutic_category[*]
   1 status_data
     2 status = c1
     2 subeventstatus[*]
 )
 FREE RECORD request_500107
 FREE RECORD reply_500107
 RECORD request_500107(
   1 catalog_cd = f8
   1 dcp_clin_cat_cd = f8
   1 catalog_type_cd = f8
   1 oe_format_id = f8
   1 activity_type_cd = f8
   1 activity_subtype_cd = f8
   1 orderable_type_flag = i2
   1 syn_add_cnt = i4
   1 add_qual[*]
     2 synonym_id = f8
     2 mnemonic = vc
     2 rx_mask = i4
     2 virtual_view = vc
     2 health_plan_view = vc
     2 mnemonic_type_cd = f8
     2 order_sentence_id = f8
     2 hide_flag = i2
     2 ing_rate_conversion_ind = i2
     2 active_ind = i2
     2 ref_text_mask = i4
     2 oe_format_id = f8
     2 concentration_strength = f8
     2 concentration_strength_unit_cd = f8
     2 concentration_volume = f8
     2 concentration_volume_unit_cd = f8
     2 witness_flag = i2
     2 qual_facility[*]
       3 facility_cd = f8
     2 high_alert_ind = i2
     2 high_alert_long_text = vc
     2 high_alert_notify_ind = i2
     2 intermittent_ind = i2
     2 display_additives_first_ind = i2
     2 rounding_rule_cd = f8
     2 ign_hide_flag = i2
     2 lock_target_dose_ind = i2
     2 max_final_dose = f8
     2 max_final_dose_unit_cd = f8
     2 max_dose_calc_bsa_value = f8
     2 preferred_dose_flag = i2
   1 syn_upd_cnt = i4
   1 upd_qual[*]
     2 synonym_id = f8
     2 rx_mask = i4
     2 mnemonic = vc
     2 virtual_view = vc
     2 health_plan_view = vc
     2 mnemonic_type_cd = f8
     2 order_sentence_id = f8
     2 ing_rate_conversion_ind = i2
     2 active_ind = i2
     2 hide_flag = i2
     2 updt_cnt = i4
     2 ref_text_mask = i4
     2 oe_format_id = f8
     2 concentration_strength = f8
     2 concentration_strength_unit_cd = f8
     2 concentration_volume = f8
     2 concentration_volume_unit_cd = f8
     2 witness_flag = i2
     2 qual_facility_add[*]
       3 facility_cd = f8
     2 qual_facility_remove[*]
       3 facility_cd = f8
     2 high_alert_ind = i2
     2 high_alert_long_text_id = f8
     2 high_alert_long_text = vc
     2 high_alert_notify_ind = i2
     2 intermittent_ind = i2
     2 display_additives_first_ind = i2
     2 rounding_rule_cd = f8
     2 ign_hide_flag = i2
     2 lock_target_dose_ind = i2
     2 preferred_dose_flag = i2
     2 max_final_dose = f8
     2 max_final_dose_unit_cd = f8
     2 max_dose_calc_bsa_value = f8
   1 syn_del_cnt = i4
   1 del_qual[*]
     2 synonym_id = f8
   1 therapeutic_category_qual[*]
     2 short_description = vc
 )
 RECORD reply_500107(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD record_csv
 RECORD record_csv(
   1 line[*]
     2 synonym = vc
     2 list_synonym[*]
       3 synonym_type = vc
       3 active = i2
       3 hide = i2
     2 status = i2
 )
 SET fpath = trim( $FILEPATH)
 SET fname = trim( $FILENAME)
 IF (((textlen(fname)=0) OR (textlen(fpath)=0)) )
  SET blank = 1
  GO TO exit_script
 ENDIF
 DEFINE rtl3 concat(fpath,":",fname)
 CALL echo("File found")
 SELECT INTO "nl:"
  r.line
  FROM rtl3t r
  HEAD REPORT
   line = 0, count = 0, l1 = 0
  HEAD r.line
   line = (line+ 1)
   IF (mod(count,10)=0)
    stat = alterlist(record_csv->line,(count+ 10))
   ENDIF
   line1 = r.line
   IF (mod(l1,10)=0)
    stat = alterlist(record_csv->line[count].list_synonym,(l1+ 10))
   ENDIF
   IF (count=0
    AND line != 1)
    count = (count+ 1), l1 = (l1+ 1), record_csv->line[count].synonym = trim(piece(line1,",",1,"")),
    record_csv->line[count].list_synonym[l1].synonym_type = trim(piece(line1,",",2,""))
    IF (cnvtupper(trim(piece(line1,",",3,"")))="ACTIVE")
     record_csv->line[count].list_synonym[l1].active = 1, record_csv->line[count].list_synonym[l1].
     hide = 0
    ELSEIF (cnvtupper(trim(piece(line1,",",3,"")))="HIDE")
     record_csv->line[count].list_synonym[l1].active = 0, record_csv->line[count].list_synonym[l1].
     hide = 1
    ELSEIF (cnvtupper(trim(piece(line1,",",3,"")))="ACTIVE/HIDE")
     record_csv->line[count].list_synonym[l1].active = 1, record_csv->line[count].list_synonym[l1].
     hide = 1
    ELSEIF (cnvtupper(trim(piece(line1,",",3,"")))="")
     record_csv->line[count].list_synonym[l1].active = 0, record_csv->line[count].list_synonym[l1].
     hide = 0
    ENDIF
    record_csv->line[count].status = 0
   ELSEIF (line != 1)
    IF (trim(piece(line1,",",1,""))="")
     l1 = (l1+ 1), record_csv->line[count].list_synonym[l1].synonym_type = trim(piece(line1,",",2,"")
      )
     IF (cnvtupper(trim(piece(line1,",",3,"")))="ACTIVE")
      record_csv->line[count].list_synonym[l1].active = 1, record_csv->line[count].list_synonym[l1].
      hide = 0
     ELSEIF (cnvtupper(trim(piece(line1,",",3,"")))="HIDE")
      record_csv->line[count].list_synonym[l1].active = 0, record_csv->line[count].list_synonym[l1].
      hide = 1
     ELSEIF (cnvtupper(trim(piece(line1,",",3,"")))="ACTIVE/HIDE")
      record_csv->line[count].list_synonym[l1].active = 1, record_csv->line[count].list_synonym[l1].
      hide = 1
     ELSEIF (cnvtupper(trim(piece(line1,",",3,"")))="")
      record_csv->line[count].list_synonym[l1].active = 0, record_csv->line[count].list_synonym[l1].
      hide = 0
     ENDIF
    ELSE
     stat = alterlist(record_csv->line[count].list_synonym,l1), count = (count+ 1), l1 = 1,
     record_csv->line[count].synonym = trim(piece(line1,",",1,"")), record_csv->line[count].
     list_synonym[l1].synonym_type = trim(piece(line1,",",2,""))
     IF (cnvtupper(trim(piece(line1,",",3,"")))="ACTIVE")
      record_csv->line[count].list_synonym[l1].active = 1, record_csv->line[count].list_synonym[l1].
      hide = 0
     ELSEIF (cnvtupper(trim(piece(line1,",",3,"")))="HIDE")
      record_csv->line[count].list_synonym[l1].active = 0, record_csv->line[count].list_synonym[l1].
      hide = 1
     ELSEIF (cnvtupper(trim(piece(line1,",",3,"")))="ACTIVE/HIDE")
      record_csv->line[count].list_synonym[l1].active = 1, record_csv->line[count].list_synonym[l1].
      hide = 1
     ELSEIF (cnvtupper(trim(piece(line1,",",3,"")))="")
      record_csv->line[count].list_synonym[l1].active = 0, record_csv->line[count].list_synonym[l1].
      hide = 0
     ENDIF
     record_csv->line[count].status = 0
    ENDIF
    record_csv->line[count].status = 0
   ENDIF
  FOOT REPORT
   stat = alterlist(record_csv->line,count), stat = alterlist(record_csv->line[count].list_synonym,l1
    )
  WITH format, separator = " ", nocounter
 ;end select
 FOR (i = 1 TO size(record_csv->line,5))
   SET c1 = 0
   SET c2 = 0
   SET errornum = 0
   SET cnt = 0
   FOR (j = 1 TO size(record_csv->line[i].list_synonym,5))
     IF (mod(c1,10)=0)
      SET stat = alterlist(request_500010->qual,(c1+ 10))
     ENDIF
     SET c1 = (c1+ 1)
     IF (j=1)
      SET request_500010->catalog_cd = uar_get_code_by("DISPLAY",200,trim(record_csv->line[i].synonym
        ))
     ENDIF
   ENDFOR
   SET stat = alterlist(request_500010->qual,c1)
   SET stat = tdbexecute(500000,500010,500010,"REC",request_500010,
    "REC",reply_500010)
   IF ((reply_500010->status_data[1].status != "S"))
    SET record_csv->line[i].status = 1
    SET errornum = 1
   ENDIF
   IF (errornum != 1)
    FOR (j = 1 TO size(record_csv->line[i].list_synonym,5))
      IF (mod(c2,10)=0)
       SET stat = alterlist(request_500107->qual,(c2+ 10))
      ENDIF
      SET c2 = (c2+ 1)
      IF (j=1)
       SET request_500107->catalog_cd = reply_500010->catalog_cd
       SET request_500107->dcp_clin_cat_cd = reply_500010->dcp_clin_cat_cd
       SET request_500107->catalog_type_cd = reply_500010->catalog_type_cd
       SET request_500107->oe_format_id = reply_500010->oe_format_id
       SET request_500107->activity_type_cd = reply_500010->activity_type_cd
       SET request_500107->activity_subtype_cd = reply_500010->activity_subtype_cd
       SET request_500107->orderable_type_flag = reply_500010->orderable_type_flag
      ENDIF
      SET syn_type = uar_get_code_by("DISPLAY",6011,record_csv->line[i].list_synonym[j].synonym_type)
      SET pos = locateval(0,1,size(reply_500010->qual_mnemonic,5),syn_type,reply_500010->
       qual_mnemonic[num].mnemonic_type_cd)
      SET request_500107->upd_qual[j].synonym_id = reply_500010->qual_mnemonic[pos].synonym_id
      SET request_500107->upd_qual[j].rx_mask = reply_500010->qual_mnemonic[pos].rx_mask
      SET request_500107->upd_qual[j].mnemonic = reply_500010->qual_mnemonic[pos].mnemonic
      SET request_500107->upd_qual[j].virtual_view = reply_500010->qual_mnemonic[pos].virtual_view
      SET request_500107->upd_qual[j].health_plan_view = reply_500010->qual_mnemonic[pos].
      health_plan_view
      SET request_500107->upd_qual[j].mnemonic_type_cd = reply_500010->qual_mnemonic[pos].
      mnemonic_type_cd
      SET request_500107->upd_qual[j].order_sentence_id = reply_500010->qual_mnemonic[pos].
      order_sentence_id
      SET request_500107->upd_qual[j].ing_rate_conversion_ind = reply_500010->qual_mnemonic[pos].
      ing_rate_conversion_ind
      SET request_500107->upd_qual[j].active_ind = record_csv->line[i].list_synonym[j].active
      SET request_500107->upd_qual[j].hide_flag = record_csv->line[i].list_synonym[j].hide
      SET request_500107->upd_qual[j].updt_cnt = 1
      SET request_500107->upd_qual[j].ref_text_mask = reply_500010->qual_mnemonic[pos].ref_text_mask
      SET request_500107->upd_qual[j].oe_format_id = reply_500010->qual_mnemonic[pos].oe_format_id
      SET request_500107->upd_qual[j].concentration_strength = reply_500010->qual_mnemonic[pos].
      concentration_strength
      SET request_500107->upd_qual[j].concentration_strength_unit_cd = reply_500010->qual_mnemonic[
      pos].concentration_strength_unit_cd
      SET request_500107->upd_qual[j].concentration_volume = reply_500010->qual_mnemonic[pos].
      concentration_volume
      SET request_500107->upd_qual[j].concentration_volume_unit_cd = reply_500010->qual_mnemonic[pos]
      .concentration_volume_unit_cd
      SET request_500107->upd_qual[j].witness_flag = reply_500010->qual_mnemonic[pos].witness_flag
      SET request_500107->upd_qual[j].high_alert_ind = reply_500010->qual_mnemonic[pos].
      high_alert_ind
      SET request_500107->upd_qual[j].high_alert_long_text_id = reply_500010->qual_mnemonic[pos].
      high_alert_long_text_id
      SET request_500107->upd_qual[j].high_alert_long_text = reply_500010->qual_mnemonic[pos].
      high_alert_long_text
      SET request_500107->upd_qual[j].high_alert_notify_ind = reply_500010->qual_mnemonic[pos].
      high_alert_notify_ind
      SET request_500107->upd_qual[j].intermittent_ind = reply_500010->qual_mnemonic[pos].
      intermittent_ind
      SET request_500107->upd_qual[j].display_additives_first_ind = reply_500010->qual_mnemonic[pos].
      display_additives_first_ind
      SET request_500107->upd_qual[j].rounding_rule_cd = reply_500010->qual_mnemonic[pos].
      rounding_rule_cd
      SET request_500107->upd_qual[j].ign_hide_flag = reply_500010->qual_mnemonic[pos].ign_hide_flag
      SET request_500107->upd_qual[j].lock_target_dose_ind = reply_500010->qual_mnemonic[pos].
      lock_target_dose_ind
      SET request_500107->upd_qual[j].preferred_dose_flag = reply_500010->qual_mnemonic[pos].
      preferred_dose_flag
      SET request_500107->upd_qual[j].max_final_dose = reply_500010->qual_mnemonic[pos].
      max_final_dose
      SET request_500107->upd_qual[j].max_final_dose_unit_cd = reply_500010->qual_mnemonic[pos].
      max_final_dose_unit_cd
      SET request_500107->upd_qual[j].max_dose_calc_bsa_value = reply_500010->qual_mnemonic[pos].
      max_dose_calc_bsa_value
      SET cnt = (cnt+ 1)
    ENDFOR
    SET request_500107->syn_upd_cnt = cnt
    SET stat = alterlist(request_500107->upd_qual,c2)
    SET stat = tdbexecute(500000,500043,500107,"REC",request_500107,
     "REC",reply_500107)
    IF ((reply_951010->status_data[1].status != "S"))
     SET record_csv->line[i].status = 2
     SET errornum = 1
    ENDIF
   ENDIF
 ENDFOR
 SET outputfile = build("cer_print:ams_lab_modify_ord_",format(cnvtdatetime(curdate,curtime3),
   "dd_mmm_yyyy_HH_MM;;Q"),".csv")
 SELECT INTO value(outputfile)
  status = record_csv->line[d1.seq].status, synonym = record_csv->line[d1.seq].synonym
  FROM (dummyt d1  WITH seq = value(size(record_csv->line,5)))
  WITH nocounter, separator = ", ", format
 ;end select
 SELECT INTO  $OUTDEV
  output = build("Output has been generated to: ",outputfile)
  FROM dummyt d
  WITH nocounter, format, separator = " "
 ;end select
 SELECT INTO  $OUTDEV
  output = build("Output has been generated to: ",outputfile)
  FROM dummyt d
  WITH maxrec = 1
 ;end select
#exit_script
 IF (failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (failed != exe_error)
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
 IF (blank=1)
  SELECT INTO value( $OUTDEV)
   output = build("Please enter the filepath/filename correctly")
   FROM dummyt d
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
END GO
