CREATE PROGRAM ams_lab_create_orderable:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Logical/Path:" = "",
  "Filename:" = "",
  "Catalog Type" = 0,
  "Activity Type" = "",
  "Activity Sub Type" = 0
  WITH outdev, filepath, filename,
  catalogtype, activitytype, activitysubtype
 DECLARE c1 = i2
 DECLARE c2 = i2
 DECLARE c3 = i2
 DECLARE errornum = i4
 DECLARE dup_nbr = i2
 DECLARE fpath = vc
 DECLARE fname = vc
 DECLARE blank = i2
 SET c1 = 0
 SET c2 = 0
 SET c3 = 0
 SET errornum = 0
 SET dup_nbr = 0
 SET fpath = ""
 SET fname = ""
 SET blank = 0
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
 FREE RECORD request_500007
 FREE RECORD reply_500007
 RECORD request_500007(
   1 primary_mnemonic = c100
   1 qual[*]
     2 mnemonic = c100
     2 catalog_cd = f8
     2 mnemonic_type_cd = f8
 )
 RECORD reply_500007(
   1 dup_item_nbr = i2
   1 dup_synonym_id = f8
   1 dup_catalog_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD request_500009
 FREE RECORD reply_500009
 RECORD request_500009(
   1 stop_type_cd = f8
   1 stop_duration = i2
   1 stop_duration_unit_cd = f8
   1 ic_auto_verify_flag = i2
   1 discern_auto_verify_flag = i2
   1 ref_text_mask = i4
   1 cki = c255
   1 auto_cancel_ind = i2
   1 setup_time = i2
   1 cleanup_time = i2
   1 consent_form_ind = i2
   1 modifiable_flag = i2
   1 active_ind = i2
   1 catalog_type_cd = f8
   1 dcp_clin_cat_cd = f8
   1 activity_type_cd = f8
   1 activity_subtype_cd = f8
   1 requisition_format_cd = f8
   1 requisition_routing_cd = f8
   1 inst_restriction_ind = i2
   1 schedule_ind = i2
   1 description = c100
   1 iv_ingredient_ind = i2
   1 print_req_ind = i2
   1 oe_format_id = f8
   1 orderable_type_flag = i2
   1 complete_upon_order_ind = i2
   1 quick_chart_ind = i2
   1 comment_template_flag = i2
   1 prep_info_flag = i2
   1 dup_checking_ind = i2
   1 order_review_ind = i2
   1 bill_only_ind = i2
   1 cont_order_method_flag = i2
   1 consent_form_format_cd = f8
   1 consent_form_routing_cd = f8
   1 dc_display_days = i4
   1 dc_interaction_days = i4
   1 mdx_gcr_id = f8
   1 form_id = f8
   1 form_level = i4
   1 disable_order_comment_ind = i2
   1 orc_text = vc
   1 mnemonic_cnt = i4
   1 qual_mnemonic[*]
     2 mnemonic = c100
     2 cki = c255
     2 ref_text_mask = i4
     2 rx_mask = i4
     2 mnemonic_type_cd = f8
     2 order_sentence_id = f8
     2 active_ind = i2
     2 ing_rate_conversion_ind = i2
     2 orderable_type_flag = i2
     2 oe_format_id = f8
     2 hide_flag = i2
     2 virtual_view = vc
     2 concentration_strength = f8
     2 concentration_strength_unit_cd = f8
     2 concentration_volume = f8
     2 concentration_volume_unit_cd = f8
     2 health_plan_view = c255
     2 witness_flag = i2
     2 high_alert_ind = i2
     2 high_alert_long_text = vc
     2 high_alert_notify_ind = i2
     2 qual_facility[*]
       3 facility_cd = f8
     2 intermittent_ind = i2
     2 display_additives_first_ind = i2
     2 rounding_rule_cd = f8
     2 ign_hide_flag = i2
     2 lock_target_dose_ind = i2
     2 max_final_dose = f8
     2 max_final_dose_unit_cd = f8
     2 max_dose_calc_bsa_value = f8
     2 preferred_dose_flag = i2
   1 review_cnt = i4
   1 qual_review[*]
   1 surgical_proc_ind = i2
   1 def_proc_dur = i4
   1 def_wound_class_cd = f8
   1 def_case_level_cd = f8
   1 spec_req_ind = i2
   1 frozen_section_req_ind = i2
   1 def_anesth_type_cd = f8
   1 surg_specialty_id = f8
   1 dup_cnt = i4
   1 qual_dup[*]
   1 dept_disp_name = vc
   1 vetting_approval_flag = i2
 )
 RECORD reply_500009(
   1 ockey = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE RECORD request_951010
 FREE RECORD reply_951010
 RECORD request_951010(
   1 nbr_of_recs = i2
   1 qual[*]
     2 action = i2
     2 ext_id = f8
     2 ext_contributor_cd = f8
     2 parent_qual_ind = f8
     2 ext_owner_cd = f8
     2 ext_description = c100
     2 ext_short_desc = c50
     2 build_ind = i2
     2 careset_ind = i2
     2 workload_only_ind = i2
     2 child_qual = i2
     2 price_qual = i2
     2 prices[*]
     2 billcode_qual = i2
     2 billcodes[*]
     2 children[*]
       3 ext_id = f8
       3 ext_contributor_cd = f8
   1 logical_domain_id = f8
   1 logical_domain_enabled_ind = i2
 )
 RECORD reply_951010(
   1 bill_item_qual = i4
   1 bill_item[*]
     2 bill_item_id = f8
   1 qual[*]
     2 bill_item_id = f8
   1 price_sched_items_qual = i2
   1 price_sched_items[*]
   1 bill_item_modifier_qual = i2
   1 bill_item_modifier[*]
     2 bill_item_mod_id = f8
   1 actioncnt = i2
   1 actionlist[*]
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c20
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE RECORD record_csv
 RECORD record_csv(
   1 line[*]
     2 catalog_type = f8
     2 activity_type = f8
     2 activity_subtype = f8
     2 description = vc
     2 department_name = vc
     2 list_synonym[*]
       3 synonym_type = vc
       3 synonym = vc
       3 active = i2
       3 hide = i2
       3 order_format = vc
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
    count = (count+ 1), l1 = (l1+ 1), record_csv->line[count].catalog_type =  $CATALOGTYPE,
    record_csv->line[count].activity_type = uar_get_code_by("MEANING",106,trim( $ACTIVITYTYPE)),
    record_csv->line[count].activity_subtype =  $ACTIVITYSUBTYPE, record_csv->line[count].description
     = trim(piece(line1,",",1,"")),
    record_csv->line[count].department_name = trim(piece(line1,",",2,"")), record_csv->line[count].
    list_synonym[l1].synonym_type = trim(piece(line1,",",3,"")), record_csv->line[count].
    list_synonym[l1].synonym = trim(piece(line1,",",4,"")),
    record_csv->line[count].list_synonym[l1].active = cnvtint(trim(piece(line1,",",5,"0"))),
    record_csv->line[count].list_synonym[l1].hide = cnvtint(trim(piece(line1,",",6,"0"))), record_csv
    ->line[count].list_synonym[l1].order_format = trim(piece(line1,",",7,"")),
    record_csv->line[count].status = 0
   ELSEIF (line != 1)
    IF (trim(piece(line1,",",1,""))=""
     AND trim(piece(line1,",",2,""))="")
     l1 = (l1+ 1), record_csv->line[count].list_synonym[l1].synonym_type = trim(piece(line1,",",3,"")
      ), record_csv->line[count].list_synonym[l1].synonym = trim(piece(line1,",",4,"")),
     record_csv->line[count].list_synonym[l1].active = cnvtint(trim(piece(line1,",",5,"0"))),
     record_csv->line[count].list_synonym[l1].hide = cnvtint(trim(piece(line1,",",6,"0"))),
     record_csv->line[count].list_synonym[l1].order_format = trim(piece(line1,",",7,""))
    ELSE
     stat = alterlist(record_csv->line[count].list_synonym,l1), count = (count+ 1), l1 = 1
     IF (mod(l1,10)=1)
      stat = alterlist(record_csv->line[count].list_synonym,(l1+ 10))
     ENDIF
     record_csv->line[count].catalog_type =  $CATALOGTYPE, record_csv->line[count].activity_type =
     uar_get_code_by("MEANING",106,trim( $ACTIVITYTYPE)), record_csv->line[count].activity_subtype =
      $ACTIVITYSUBTYPE,
     record_csv->line[count].description = trim(piece(line1,",",1,"")), record_csv->line[count].
     department_name = trim(piece(line1,",",2,"")), record_csv->line[count].list_synonym[l1].
     synonym_type = trim(piece(line1,",",3,"")),
     record_csv->line[count].list_synonym[l1].synonym = trim(piece(line1,",",4,"")), record_csv->
     line[count].list_synonym[l1].active = cnvtint(trim(piece(line1,",",5,"0"))), record_csv->line[
     count].list_synonym[l1].hide = cnvtint(trim(piece(line1,",",6,"0"))),
     record_csv->line[count].list_synonym[l1].order_format = trim(piece(line1,",",7,""))
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
   SET c3 = 0
   SET errornum = 0
   SET dup_nbr = 0
   FOR (j = 1 TO size(record_csv->line[i].list_synonym,5))
     IF (mod(c1,10)=0)
      SET stat = alterlist(request_500007->qual,(c1+ 10))
     ENDIF
     SET c1 = (c1+ 1)
     IF (j=1)
      SET request_500007->primary_mnemonic = trim(record_csv->line[i].list_synonym[j].synonym)
     ENDIF
     SET request_500007->qual[c1].mnemonic = trim(record_csv->line[i].list_synonym[j].synonym)
     SET request_500007->qual[c1].mnemonic_type_cd = uar_get_code_by("DESCRIPTION",6011,trim(
       record_csv->line[i].list_synonym[j].synonym_type))
   ENDFOR
   SET stat = alterlist(request_500007->qual,c1)
   EXECUTE orm_check_synonym:dba  WITH replace("REQUEST",request_500007), replace("REPLY",
    reply_500007)
   SET dup_nbr = reply_500007->dup_item_nbr
   IF ((((reply_500007->dup_item_nbr=1)) OR ((reply_500007->status_data[1].status != "S"))) )
    SET record_csv->line[i].status = 1
    SET errornum = 1
   ENDIF
   IF (errornum != 1)
    FOR (j = 1 TO size(record_csv->line[i].list_synonym,5))
      IF (mod(c2,10)=0)
       SET stat = alterlist(request_500009->qual_mnemonic,(c2+ 10))
      ENDIF
      SET c2 = (c2+ 1)
      IF (j=1)
       SET request_500009->active_ind = record_csv->line[i].list_synonym[j].active
       SELECT
        formatid = oef.oe_format_id
        FROM order_entry_format oef
        WHERE oef.oe_format_name=trim(record_csv->line[i].list_synonym[j].order_format)
        HEAD oef.oe_format_id
         request_500009->oe_format_id = formatid
        WITH nocounter
       ;end select
      ENDIF
      SET request_500009->catalog_type_cd = record_csv->line[i].catalog_type
      SET request_500009->activity_type_cd = record_csv->line[i].activity_type
      SET request_500009->activity_subtype_cd = record_csv->line[i].activity_subtype
      SET request_500009->description = trim(record_csv->line[i].description)
      SET request_500009->dcp_clin_cat_cd = uar_get_code_by("DISPLAY_KEY",16389,"LABORATORY")
      SET request_500009->qual_mnemonic[c2].mnemonic = trim(record_csv->line[i].list_synonym[j].
       synonym)
      SET request_500009->qual_mnemonic[c2].mnemonic_type_cd = uar_get_code_by("DESCRIPTION",6011,
       trim(record_csv->line[i].list_synonym[j].synonym_type))
      SET request_500009->qual_mnemonic[c2].active_ind = record_csv->line[i].list_synonym[j].active
      SELECT
       formatid = oef.oe_format_id
       FROM order_entry_format oef
       WHERE (oef.oe_format_name=record_csv->line[i].list_synonym[j].order_format)
       HEAD oef.oe_format_id
        request_500009->qual_mnemonic[c2].oe_format_id = formatid
       WITH nocounter
      ;end select
      SET request_500009->qual_mnemonic[c2].hide_flag = record_csv->line[i].list_synonym[j].hide
      SET request_500009->dup_checking_ind = dup_nbr
      SET request_500009->dept_disp_name = record_csv->line[i].department_name
    ENDFOR
    SET request_500009->mnemonic_cnt = size(record_csv->line[i].list_synonym,5)
    SET request_500009->discern_auto_verify_flag = 0
    SET request_500009->ic_auto_verify_flag = 0
    SET stat = alterlist(request_500009->qual_mnemonic,c2)
    SET stat = tdbexecute(500000,500043,500009,"REC",request_500009,
     "REC",reply_500009)
    IF ((reply_500009->status_data[1].status != "S"))
     SET record_csv->line[i].status = 2
     SET errornum = 1
    ENDIF
    IF (errornum != 1)
     IF (mod(c3,10)=0)
      SET stat = alterlist(request_951010->qual,(c3+ 10))
     ENDIF
     SET c3 = (c3+ 1)
     SET request_951010->qual[c3].ext_short_desc = record_csv->line[i].list_synonym[1].synonym
     SET request_951010->nbr_of_recs = 1
     SET request_951010->qual[c3].ext_id = reply_500009->ockey
     SET request_951010->qual[c3].ext_contributor_cd = uar_get_code_by("DISPLAY_KEY",13016,"ORDCAT")
     SET request_951010->qual[c3].parent_qual_ind = 1
     SET request_951010->qual[c3].ext_owner_cd = record_csv->line[i].activity_type
     SET request_951010->qual[c3].ext_description = record_csv->line[i].description
     SET stat = alterlist(request_951010->qual,c3)
     SET stat = tdbexecute(500000,951002,951010,"REC",request_951010,
      "REC",reply_951010)
     IF ((reply_951010->status_data[1].status != "S"))
      SET record_csv->line[i].status = 3
      SET errornum = 1
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 SET outputfile = build("cer_print:ams_lab_create_ord_",format(cnvtdatetime(curdate,curtime3),
   "dd_mmm_yyyy_HH_MM;;Q"),".csv")
 SELECT INTO value(outputfile)
  status = record_csv->line[d1.seq].status, catalog_type = record_csv->line[d1.seq].catalog_type,
  activity_type = record_csv->line[d1.seq].activity_type,
  activity_subtype = record_csv->line[d1.seq].activity_subtype, description = trim(record_csv->line[
   d1.seq].description), department_name = record_csv->line[d1.seq].department_name
  FROM (dummyt d1  WITH seq = value(size(record_csv->line,5)))
  WITH nocounter, separator = ", ", format
 ;end select
 SELECT INTO  $OUTDEV
  output = build("Output has been generated to: ",outputfile)
  FROM dummyt d
  WITH nocounter, format, separator = " "
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
