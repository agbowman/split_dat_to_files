CREATE PROGRAM cps_get_orders_by_encntr:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
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
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 RECORD reply(
   1 last_updt_dt_tm = dq8
   1 qual_cnt = i4
   1 qual[*]
     2 order_id = f8
     2 encntr_id = f8
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 catalog_type_disp = c40
     2 catalog_type_mean = c40
     2 contributor_system_cd = f8
     2 order_status_cd = f8
     2 order_status_disp = c40
     2 order_status_mean = c40
     2 order_mnemonic = vc
     2 generic_mnemonic = vc
     2 hna_order_mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 last_action_sequence = i4
     2 activity_type_cd = f8
     2 activity_type_disp = c40
     2 activity_type_mean = c40
     2 activity_subtype_cd = f8
     2 orig_order_dt_tm = dq8
     2 orig_order_tz = i4
     2 last_update_provider_id = f8
     2 provider_full_name = vc
     2 template_order_id = f8
     2 template_order_flag = i2
     2 synonym_id = f8
     2 group_order_id = f8
     2 group_order_flag = i2
     2 link_order_id = f8
     2 link_order_flag = i2
     2 suspend_ind = i2
     2 order_detail_display_line = vc
     2 oe_format_id = f8
     2 iv_ind = i2
     2 constant_ind = i2
     2 prn_ind = i2
     2 order_comment_ind = i2
     2 need_rx_verify_ind = i2
     2 need_nurse_review_ind = i2
     2 need_doctor_cosign_ind = i2
     2 current_start_dt_tm = dq8
     2 current_start_tz = i4
     2 projected_stop_dt_tm = dq8
     2 projected_stop_tz = i4
     2 suspend_effective_dt_tm = dq8
     2 suspend_effective_tz = i4
     2 resume_ind = i2
     2 resume_effective_dt_tm = dq8
     2 resume_effective_tz = i4
     2 discontinue_ind = i2
     2 discontinue_effective_dt_tm = dq8
     2 discontinue_effective_tz = i4
     2 cs_order_id = f8
     2 cs_flag = i2
     2 last_updt_cnt = i4
     2 orig_ord_as_flag = i2
     2 dept_status_cd = f8
     2 ref_text_mask = i4
     2 cki = vc
     2 synonym_cki = vc
     2 dup_checking_ind = i2
     2 incomplete_order_ind = i2
     2 last_action_type_cd = f8
     2 last_action_type_disp = c40
     2 last_action_type_mean = c12
     2 disable_order_comment_ind = i2
     2 mnemonic_type_cd = f8
     2 need_physician_validate_ind = i2
     2 med_order_type_cd = f8
     2 additive_count_for_ivpb = i4
     2 communication_type_cd = f8
     2 dispensed_by_pharmacy_ind = i2
     2 processed_by_pharmacy_ind = i2
     2 lost_dispense_record_ind = i2
     2 requisition_format_cd = f8
     2 requisition_object_name = vc
     2 organization_id = f8
     2 simplified_display_line = vc
     2 action_dt_tm = dq8
     2 action_tz = i4
     2 compound_ind = i2
   1 retail_order_qual[*]
     2 order_id = f8
     2 encntr_id = f8
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 catalog_type_disp = c40
     2 catalog_type_mean = c40
     2 contributor_system_cd = f8
     2 order_status_cd = f8
     2 order_status_disp = c40
     2 order_status_mean = c40
     2 order_mnemonic = vc
     2 generic_mnemonic = vc
     2 hna_order_mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 last_action_sequence = i4
     2 activity_type_cd = f8
     2 activity_type_disp = c40
     2 activity_type_mean = c40
     2 activity_subtype_cd = f8
     2 orig_order_dt_tm = dq8
     2 orig_order_tz = i4
     2 last_update_provider_id = f8
     2 provider_full_name = vc
     2 template_order_id = f8
     2 template_order_flag = i2
     2 synonym_id = f8
     2 group_order_id = f8
     2 group_order_flag = i2
     2 link_order_id = f8
     2 link_order_flag = i2
     2 suspend_ind = i2
     2 order_detail_display_line = vc
     2 oe_format_id = f8
     2 iv_ind = i2
     2 constant_ind = i2
     2 prn_ind = i2
     2 order_comment_ind = i2
     2 need_rx_verify_ind = i2
     2 need_nurse_review_ind = i2
     2 need_doctor_cosign_ind = i2
     2 current_start_dt_tm = dq8
     2 current_start_tz = i4
     2 projected_stop_dt_tm = dq8
     2 projected_stop_tz = i4
     2 suspend_effective_dt_tm = dq8
     2 suspend_effective_tz = i4
     2 resume_ind = i2
     2 resume_effective_dt_tm = dq8
     2 resume_effective_tz = i4
     2 discontinue_ind = i2
     2 discontinue_effective_dt_tm = dq8
     2 discontinue_effective_tz = i4
     2 cs_order_id = f8
     2 cs_flag = i2
     2 last_updt_cnt = i4
     2 orig_ord_as_flag = i2
     2 dept_status_cd = f8
     2 ref_text_mask = i4
     2 cki = vc
     2 synonym_cki = vc
     2 dup_checking_ind = i2
     2 incomplete_order_ind = i2
     2 last_action_type_cd = f8
     2 last_action_type_disp = c40
     2 last_action_type_mean = c12
     2 disable_order_comment_ind = i2
     2 mnemonic_type_cd = f8
     2 need_physician_validate_ind = i2
     2 med_order_type_cd = f8
     2 additive_count_for_ivpb = i4
     2 communication_type_cd = f8
     2 dispensed_by_pharmacy_ind = i2
     2 processed_by_pharmacy_ind = i2
     2 lost_dispense_record_ind = i2
     2 requisition_format_cd = f8
     2 requisition_object_name = vc
     2 organization_id = f8
     2 simplified_display_line = vc
     2 action_dt_tm = dq8
     2 action_tz = i4
     2 compound_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET hupdt_dt_tm = cnvtdatetime("01-jan-1800 00:00:00")
 IF ((request->updt_dt_tm > 0))
  SET tupdt_dt_tm = request->updt_dt_tm
 ELSE
  SET tupdt_dt_tm = cnvtdatetime("01-jan-1800 00:00:00")
 ENDIF
 IF ((request->days_back > 0))
  SET torig_order_dt_tm = datetimeadd(cnvtdatetime(curdate,curtime3),(request->days_back * - (1)))
 ELSE
  SET torig_order_dt_tm = cnvtdatetime("01-jan-1800 00:00:00")
 ENDIF
 SET dvar = 0
 SET count1 = 0
 SET count2 = 0
 SET count3 = 0
 SET disc_count = 0
 DECLARE ivpb_ind = i2 WITH protect, noconstant(0)
 SET failed = false
 SET reply->status_data.status = "F"
 DECLARE ordered_cd = f8 WITH public, noconstant(0.0)
 DECLARE inprocess_cd = f8 WITH public, noconstant(0.0)
 DECLARE disc_cd = f8 WITH public, noconstant(0.0)
 DECLARE susp_cd = f8 WITH public, noconstant(0.0)
 DECLARE pharmacy_cd = f8 WITH public, noconstant(0.0)
 DECLARE ivpb_cd = f8 WITH public, noconstant(0.0)
 DECLARE iv_cd = f8 WITH public, noconstant(0.0)
 DECLARE rx_mnemonic_cd = f8 WITH public, noconstant(0.0)
 DECLARE retail_order_cnt = i4 WITH public, noconstant(0)
 DECLARE cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE code_set = i4 WITH public, noconstant(0)
 DECLARE num1 = i4
 DECLARE num2 = i4
 DECLARE num3 = i4
 DECLARE num4 = i4
 DECLARE ingcnt = i4 WITH protect, noconstant(0)
 DECLARE orderedasmnemonic = vc WITH protect
 DECLARE hnaordermnemonic = vc WITH protect
 DECLARE volumestring = vc WITH protect
 DECLARE strengthstring = vc WITH protect
 DECLARE retail_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE order_mnemonic_size = i4 WITH protect, noconstant(0)
 DECLARE iv_mnemonic_size = i4 WITH protect, noconstant(0)
 DECLARE mnem_size = i4 WITH protect, noconstant(0)
 DECLARE additive = i2 WITH protect, constant(3)
 DECLARE compound_parent = i2 WITH protect, constant(4)
 DECLARE compound_child = i2 WITH protect, constant(5)
 SET code_set = 6004
 SET cdf_meaning = "ORDERED"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,ordered_cd)
 IF (ordered_cd < 1)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "Invalid code_value for cdf_meaning ",trim(cdf_meaning)," in code_set ",trim(cnvtstring(code_set))
   )
  GO TO exit_script
 ENDIF
 SET cdf_meaning = "DISCONTINUED"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,disc_cd)
 IF (disc_cd < 1)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "Invalid code_value for cdf_meaning ",trim(cdf_meaning)," in code_set ",trim(cnvtstring(code_set))
   )
  GO TO exit_script
 ENDIF
 SET cdf_meaning = "SUSPENDED"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,susp_cd)
 IF (susp_cd < 1)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "Invalid code_value for cdf_meaning ",trim(cdf_meaning)," in code_set ",trim(cnvtstring(code_set))
   )
  GO TO exit_script
 ENDIF
 SET cdf_meaning = "INPROCESS"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,inprocess_cd)
 IF (inprocess_cd < 1)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "Invalid code_value for cdf_meaning ",trim(cdf_meaning)," in code_set ",trim(cnvtstring(code_set))
   )
  GO TO exit_script
 ENDIF
 SET code_set = 6000
 SET cdf_meaning = "PHARMACY"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,pharmacy_cd)
 IF (pharmacy_cd < 1)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "Invalid code_value for cdf_meaning ",trim(cdf_meaning)," in code_set ",trim(cnvtstring(code_set))
   )
  GO TO exit_script
 ENDIF
 SET code_set = 18309
 SET cdf_meaning = "INTERMITTENT"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,ivpb_cd)
 IF (ivpb_cd < 1)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "Invalid code_value for cdf_meaning ",trim(cdf_meaning)," in code_set ",trim(cnvtstring(code_set))
   )
  GO TO exit_script
 ENDIF
 SET cdf_meaning = "IV"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,iv_cd)
 IF (iv_cd < 1)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "Invalid code_value for cdf_meaning ",trim(cdf_meaning)," in code_set ",trim(cnvtstring(code_set))
   )
  GO TO exit_script
 ENDIF
 SET code_set = 4500
 SET cdf_meaning = "RETAIL"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,retail_type_cd)
 IF (retail_type_cd < 1)
  SELECT INTO "nl:"
   cv.code_value
   FROM code_value cv
   WHERE cv.code_set=code_set
    AND cv.cdf_meaning=cdf_meaning
   DETAIL
    retail_type_cd = cv.code_value
   WITH nocounter
  ;end select
  IF (retail_type_cd < 1)
   SET failed = select_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
    "Invalid code_value for cdf_meaning ",trim(cdf_meaning)," in code_set ",trim(cnvtstring(code_set)
     ))
   GO TO exit_script
  ENDIF
 ENDIF
 SET code_set = 6011
 SET cdf_meaning = "RXMNEMONIC"
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,rx_mnemonic_cd)
 IF (rx_mnemonic_cd < 1)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "Invalid code_value for cdf_meaning ",trim(cdf_meaning)," in code_set ",trim(cnvtstring(code_set))
   )
  GO TO exit_script
 ENDIF
 SET hide_volume_dose_ind = request->hide_volume_dose_ind
 DECLARE retail_schema_ind = i2
 RANGE OF od IS order_dispense
 SET retail_schema_ind = validate(od.parent_order_id)
 FREE RANGE od
 IF (retail_schema_ind=1)
  IF ((request->cat_type_qual > 0))
   IF ((request->status_qual > 0))
    CALL echo("**** STATUS and CATALOG - Retail ****")
    CALL get_orders_by_cat_stat_cd_retail(dvar)
   ELSE
    CALL echo("**** CATALOG - Retail ****")
    CALL get_orders_by_cat_type_retail(dvar)
   ENDIF
  ELSE
   IF ((request->status_qual > 0))
    CALL echo("**** STATUS - Retail ****")
    CALL get_orders_by_status_cd_retail(dvar)
   ELSE
    CALL echo("**** PERSON - Retail ****")
    CALL get_orders_retail(dvar)
   ENDIF
  ENDIF
  IF ((request->get_retail_ind=1))
   CALL echo("**** RETAIL ORDERS ****")
   CALL get_retail_orders(dvar)
  ENDIF
 ELSE
  IF ((request->cat_type_qual > 0))
   IF ((request->status_qual > 0))
    CALL echo("**** STATUS and CATALOG ****")
    CALL get_orders_by_cat_stat_cd(dvar)
   ELSE
    CALL echo("**** CATALOG ****")
    CALL get_orders_by_cat_type(dvar)
   ENDIF
  ELSE
   IF ((request->status_qual > 0))
    CALL echo("**** STATUS ****")
    CALL get_orders_by_status_cd(dvar)
   ELSE
    CALL echo("**** PERSON ****")
    CALL get_orders(dvar)
   ENDIF
  ENDIF
 ENDIF
 IF (ierrcode > 0)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ORDERS"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
 ENDIF
 SET orderloc = 0
 SET startloc = 0
 CALL echo(
  "Checking and building hna_order_mnemonic(s) and ordered_as_mnemonic(s) for non-retail orders...")
 SELECT INTO "nl:"
  FROM order_ingredient oi
  WHERE expand(num4,1,value(size(reply->qual,5)),oi.order_id,reply->qual[num4].order_id,
   oi.action_sequence,reply->qual[num4].last_action_sequence)
  ORDER BY oi.order_id
  HEAD oi.order_id
   IF (iv_mnemonic_size=0)
    iv_mnemonic_size = (size(oi.hna_order_mnemonic,3) - 1)
   ENDIF
   orderedasmnemonic = "", hnaordermnemonic = "", volumestring = "",
   strengthstring = "", ingcnt = 0, ivpb_ind = false,
   orderloc = locateval(startloc,1,value(size(reply->qual,5)),oi.order_id,reply->qual[startloc].
    order_id,
    oi.action_sequence,reply->qual[startloc].last_action_sequence)
   IF (orderloc > 0)
    IF ((reply->qual[orderloc].iv_ind=1))
     CALL echo(build("hna_order_mnemonic: ",reply->qual[orderloc].hna_order_mnemonic)),
     CALL echo(build("ordered_as_mnemonic: ",reply->qual[orderloc].ordered_as_mnemonic)),
     CALL echo(build("iv_ind = ",reply->qual[orderloc].iv_ind)),
     CALL echo(build("hna_order_mnemonic size: ",size(reply->qual[orderloc].hna_order_mnemonic,1))),
     CALL echo(build("ordered_as_mnemonic size: ",size(reply->qual[orderloc].ordered_as_mnemonic,1)))
    ENDIF
    IF ((reply->qual[orderloc].med_order_type_cd=ivpb_cd))
     ivpb_ind = true
    ENDIF
   ENDIF
  DETAIL
   IF (orderloc > 0)
    IF ((reply->qual[orderloc].iv_ind=1))
     volumestring = "", strengthstring = "", ingcnt = (ingcnt+ 1)
     IF (oi.strength > 0)
      strengthstring = trim(concat(trim(format(oi.strength,"##########.##########;t(1)"),3)," ",trim(
         uar_get_code_display(oi.strength_unit))))
     ENDIF
     CALL echo(build("Ingredient Strength: ",strengthstring))
     IF (oi.volume > 0)
      volumestring = trim(concat(trim(format(oi.volume,"##########.##########;t(1)"),3)," ",trim(
         uar_get_code_display(oi.volume_unit))))
     ENDIF
     CALL echo(build("Ingredient Volume: ",volumestring)), mnem_size = size(trim(oi
       .ordered_as_mnemonic),1)
     IF (orderedasmnemonic="")
      IF (mnem_size >= iv_mnemonic_size
       AND substring((mnem_size - 3),mnem_size,oi.ordered_as_mnemonic) != "...")
       orderedasmnemonic = concat(trim(oi.ordered_as_mnemonic),"...")
      ELSE
       orderedasmnemonic = trim(oi.ordered_as_mnemonic)
      ENDIF
     ELSE
      IF (mnem_size >= iv_mnemonic_size
       AND substring((mnem_size - 3),mnem_size,oi.ordered_as_mnemonic) != "...")
       orderedasmnemonic = concat(trim(orderedasmnemonic)," + ",trim(oi.ordered_as_mnemonic),"...")
      ELSE
       orderedasmnemonic = concat(trim(orderedasmnemonic)," + ",trim(oi.ordered_as_mnemonic))
      ENDIF
     ENDIF
     orderedasmnemonic = concat(trim(orderedasmnemonic)," ",strengthstring)
     IF (((hide_volume_dose_ind=0) OR (strengthstring <= ""))
      AND volumestring > "")
      orderedasmnemonic = concat(trim(orderedasmnemonic)," ",volumestring)
     ENDIF
     mnem_size = size(trim(oi.hna_order_mnemonic),1)
     IF (hnaordermnemonic="")
      IF (mnem_size >= iv_mnemonic_size
       AND substring((mnem_size - 3),mnem_size,oi.hna_order_mnemonic) != "...")
       hnaordermnemonic = concat(trim(oi.hna_order_mnemonic),"...")
      ELSE
       hnaordermnemonic = trim(oi.hna_order_mnemonic)
      ENDIF
     ELSE
      IF (mnem_size >= iv_mnemonic_size
       AND substring((mnem_size - 3),mnem_size,oi.hna_order_mnemonic) != "...")
       hnaordermnemonic = concat(trim(hnaordermnemonic)," + ",trim(oi.hna_order_mnemonic),"...")
      ELSE
       hnaordermnemonic = concat(trim(hnaordermnemonic)," + ",trim(oi.hna_order_mnemonic))
      ENDIF
     ENDIF
     hnaordermnemonic = concat(trim(hnaordermnemonic)," ",strengthstring)
     IF (((hide_volume_dose_ind=0) OR (strengthstring <= ""))
      AND volumestring > "")
      hnaordermnemonic = concat(trim(hnaordermnemonic)," ",volumestring)
     ENDIF
    ENDIF
    IF (ivpb_ind=true
     AND oi.ingredient_type_flag=additive)
     reply->qual[orderloc].additive_count_for_ivpb = (reply->qual[orderloc].additive_count_for_ivpb+
     1)
    ENDIF
    IF (((oi.ingredient_type_flag=compound_parent) OR (oi.ingredient_type_flag=compound_child)) )
     reply->qual[orderloc].compound_ind = true
    ENDIF
   ENDIF
  FOOT  oi.order_id
   IF (orderloc > 0)
    IF ((reply->qual[orderloc].iv_ind=1))
     CALL echo(build("Ingredient count: ",ingcnt)),
     CALL echo(build("New hna_order_mnemonic length: ",size(hnaordermnemonic,1))),
     CALL echo(build("New hna_order_mnemonic: ",hnaordermnemonic)),
     CALL echo(build("New ordered_as_mnemonic length: ",size(orderedasmnemonic,1))),
     CALL echo(build("New ordered_as_mnemonic: ",orderedasmnemonic)), reply->qual[orderloc].
     hna_order_mnemonic = hnaordermnemonic,
     reply->qual[orderloc].ordered_as_mnemonic = orderedasmnemonic
    ENDIF
    IF ((reply->qual[orderloc].additive_count_for_ivpb > 1))
     reply->qual[orderloc].iv_ind = true
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (retail_order_cnt > 0)
  CALL echo(
   "Checking and building hna_order_mnemonic(s) and ordered_as_mnemonic(s) for retail orders...")
  SELECT INTO "nl:"
   FROM order_ingredient oi
   WHERE expand(num4,1,value(size(reply->retail_order_qual,5)),oi.order_id,reply->retail_order_qual[
    num4].order_id,
    oi.action_sequence,reply->retail_order_qual[num4].last_action_sequence)
   ORDER BY oi.order_id
   HEAD oi.order_id
    orderedasmnemonic = "", hnaordermnemonic = "", volumestring = "",
    strengthstring = "", ingcnt = 0, ivpb_ind = false
    IF (iv_mnemonic_size=0)
     iv_mnemonic_size = (size(oi.hna_order_mnemonic,3) - 1)
    ENDIF
    orderloc = locateval(startloc,1,value(size(reply->retail_order_qual,5)),oi.order_id,reply->
     retail_order_qual[startloc].order_id,
     oi.action_sequence,reply->retail_order_qual[startloc].last_action_sequence)
    IF (orderloc > 0)
     IF ((reply->retail_order_qual[orderloc].iv_ind=1))
      CALL echo(build("hna_order_mnemonic: ",reply->retail_order_qual[orderloc].hna_order_mnemonic)),
      CALL echo(build("ordered_as_mnemonic: ",reply->retail_order_qual[orderloc].ordered_as_mnemonic)
      ),
      CALL echo(build("iv_ind = ",reply->retail_order_qual[orderloc].iv_ind)),
      CALL echo(build("hna_order_mnemonic size: ",size(reply->retail_order_qual[orderloc].
        hna_order_mnemonic,1))),
      CALL echo(build("ordered_as_mnemonic size: ",size(reply->retail_order_qual[orderloc].
        ordered_as_mnemonic,1)))
     ENDIF
     IF ((reply->retail_order_qual[orderloc].med_order_type_cd=ivpb_cd))
      ivpb_ind = true
     ENDIF
    ENDIF
   DETAIL
    IF (orderloc > 0)
     IF ((reply->retail_order_qual[orderloc].iv_ind=1))
      volumestring = "", strengthstring = "", ingcnt = (ingcnt+ 1)
      IF (oi.strength > 0)
       strengthstring = trim(concat(trim(format(oi.strength,"##########.##########;t(1)"),3)," ",trim
         (uar_get_code_display(oi.strength_unit))))
      ENDIF
      CALL echo(build("Ingredient Strength: ",strengthstring))
      IF (oi.volume > 0)
       volumestring = trim(concat(trim(format(oi.volume,"##########.##########;t(1)"),3)," ",trim(
          uar_get_code_display(oi.volume_unit))))
      ENDIF
      CALL echo(build("Ingredient Volume: ",volumestring)), mnem_size = size(trim(oi
        .ordered_as_mnemonic),1)
      IF (orderedasmnemonic="")
       IF (mnem_size >= iv_mnemonic_size
        AND substring((mnem_size - 3),mnem_size,oi.ordered_as_mnemonic) != "...")
        orderedasmnemonic = concat(trim(oi.ordered_as_mnemonic),"...")
       ELSE
        orderedasmnemonic = trim(oi.ordered_as_mnemonic)
       ENDIF
      ELSE
       IF (mnem_size >= iv_mnemonic_size
        AND substring((mnem_size - 3),mnem_size,oi.ordered_as_mnemonic) != "...")
        orderedasmnemonic = concat(trim(orderedasmnemonic)," + ",trim(oi.ordered_as_mnemonic),"...")
       ELSE
        orderedasmnemonic = concat(trim(orderedasmnemonic)," + ",trim(oi.ordered_as_mnemonic))
       ENDIF
      ENDIF
      orderedasmnemonic = concat(trim(orderedasmnemonic)," ",strengthstring)
      IF (((hide_volume_dose_ind=0) OR (strengthstring <= ""))
       AND volumestring > "")
       orderedasmnemonic = concat(trim(orderedasmnemonic)," ",volumestring)
      ENDIF
      mnem_size = size(trim(oi.hna_order_mnemonic),1)
      IF (hnaordermnemonic="")
       IF (mnem_size >= iv_mnemonic_size
        AND substring((mnem_size - 3),mnem_size,oi.hna_order_mnemonic) != "...")
        hnaordermnemonic = concat(trim(oi.hna_order_mnemonic),"...")
       ELSE
        hnaordermnemonic = trim(oi.hna_order_mnemonic)
       ENDIF
      ELSE
       IF (mnem_size >= iv_mnemonic_size
        AND substring((mnem_size - 3),mnem_size,oi.hna_order_mnemonic) != "...")
        hnaordermnemonic = concat(trim(hnaordermnemonic)," + ",trim(oi.hna_order_mnemonic),"...")
       ELSE
        hnaordermnemonic = concat(trim(hnaordermnemonic)," + ",trim(oi.hna_order_mnemonic))
       ENDIF
      ENDIF
      hnaordermnemonic = concat(trim(hnaordermnemonic)," ",strengthstring)
      IF (((hide_volume_dose_ind=0) OR (strengthstring <= ""))
       AND volumestring > "")
       hnaordermnemonic = concat(trim(hnaordermnemonic)," ",volumestring)
      ENDIF
     ENDIF
     IF (ivpb_ind=true
      AND oi.ingredient_type_flag=additive)
      reply->retail_order_qual[orderloc].additive_count_for_ivpb = (reply->retail_order_qual[orderloc
      ].additive_count_for_ivpb+ 1)
     ENDIF
     IF (((oi.ingredient_type_flag=compound_parent) OR (oi.ingredient_type_flag=compound_child)) )
      reply->retail_order_qual[orderloc].compound_ind = true
     ENDIF
    ENDIF
   FOOT  oi.order_id
    IF (orderloc > 0)
     IF ((reply->retail_order_qual[orderloc].iv_ind=1))
      CALL echo(build("Ingredient count: ",ingcnt)),
      CALL echo(build("New hna_order_mnemonic length: ",size(hnaordermnemonic,1))),
      CALL echo(build("New hna_order_mnemonic: ",hnaordermnemonic)),
      CALL echo(build("New ordered_as_mnemonic length: ",size(orderedasmnemonic,1))),
      CALL echo(build("New ordered_as_mnemonic: ",orderedasmnemonic)), reply->retail_order_qual[
      orderloc].hna_order_mnemonic = hnaordermnemonic,
      reply->retail_order_qual[orderloc].ordered_as_mnemonic = orderedasmnemonic
     ENDIF
     IF ((reply->retail_order_qual[orderloc].additive_count_for_ivpb > 1))
      reply->retail_order_qual[orderloc].iv_ind = true
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 GO TO exit_script
 SUBROUTINE get_orders_by_cat_type_retail(lvar)
   SELECT
    IF ((request->encntr_qual > 0))
     FROM orders o,
      person p,
      order_catalog oc,
      order_catalog_synonym ocs,
      order_action oa,
      order_dispense od,
      encounter e
     PLAN (o
      WHERE expand(num1,1,request->encntr_qual,o.encntr_id,request->encntr[num1].encntr_id)
       AND (o.person_id=request->person_id)
       AND expand(num2,1,request->cat_type_qual,(o.catalog_type_cd+ 0),request->cat_type[num2].
       cat_type_cd)
       AND ((((o.catalog_type_cd+ 0)=pharmacy_cd)
       AND ((o.template_order_flag+ 0) IN (0, 1, 5))) OR (((o.catalog_type_cd+ 0) != pharmacy_cd)))
       AND ((o.active_ind+ 0)=1)
       AND ((o.updt_dt_tm+ 0) >= cnvtdatetime(tupdt_dt_tm))
       AND ((o.orig_order_dt_tm+ 0) >= cnvtdatetime(torig_order_dt_tm))
       AND (( NOT ( EXISTS (
      (SELECT
       od2.order_id
       FROM order_dispense od2
       WHERE od2.order_id=o.order_id
        AND od2.pharm_type_cd=retail_type_cd)))) OR (o.orig_ord_as_flag != 1)) )
      JOIN (e
      WHERE o.encntr_id=e.encntr_id)
      JOIN (p
      WHERE p.person_id=o.last_update_provider_id)
      JOIN (oc
      WHERE oc.catalog_cd=o.catalog_cd)
      JOIN (ocs
      WHERE ocs.synonym_id=o.synonym_id)
      JOIN (oa
      WHERE oa.order_id=o.order_id
       AND oa.action_sequence=o.last_action_sequence)
      JOIN (od
      WHERE outerjoin(o.order_id)=od.parent_order_id)
    ELSE
     FROM orders o,
      person p,
      order_catalog oc,
      order_catalog_synonym ocs,
      order_action oa,
      order_dispense od,
      encounter e
     PLAN (o
      WHERE (o.person_id=request->person_id)
       AND expand(num2,1,request->cat_type_qual,(o.catalog_type_cd+ 0),request->cat_type[num2].
       cat_type_cd)
       AND ((o.catalog_type_cd=pharmacy_cd
       AND o.template_order_flag IN (0, 1, 5)) OR (o.catalog_type_cd != pharmacy_cd))
       AND ((o.active_ind+ 0)=1)
       AND ((o.updt_dt_tm+ 0) >= cnvtdatetime(tupdt_dt_tm))
       AND ((o.orig_order_dt_tm+ 0) >= cnvtdatetime(torig_order_dt_tm))
       AND (( NOT ( EXISTS (
      (SELECT
       od2.order_id
       FROM order_dispense od2
       WHERE od2.order_id=o.order_id
        AND od2.pharm_type_cd=retail_type_cd)))) OR (o.orig_ord_as_flag != 1)) )
      JOIN (e
      WHERE o.encntr_id=e.encntr_id)
      JOIN (p
      WHERE p.person_id=o.last_update_provider_id)
      JOIN (oc
      WHERE oc.catalog_cd=o.catalog_cd)
      JOIN (ocs
      WHERE ocs.synonym_id=o.synonym_id)
      JOIN (oa
      WHERE oa.order_id=o.order_id
       AND oa.action_sequence=o.last_action_sequence)
      JOIN (od
      WHERE outerjoin(o.order_id)=od.parent_order_id)
    ENDIF
    INTO "nl:"
    o.order_id, sort_parent = od.parent_order_id
    ORDER BY o.order_id, sort_parent, od.fill_nbr DESC
    HEAD REPORT
     count1 = 0, stat = alterlist(reply->qual,10)
     IF (order_mnemonic_size=0)
      order_mnemonic_size = (size(o.hna_order_mnemonic,3) - 1)
     ENDIF
    HEAD o.order_id
     count1 = (count1+ 1)
     IF (mod(count1,10)=1
      AND count1 != 1)
      stat = alterlist(reply->qual,(count1+ 9))
     ENDIF
     IF (datetimediff(o.updt_dt_tm,tupdt_dt_tm) > 0)
      hupdt_dt_tm = cnvtdatetime(o.updt_dt_tm)
     ENDIF
     CALL fill_reply(dvar)
    HEAD sort_parent
     IF (sort_parent > 0)
      IF (o.person_id != od.person_id)
       reply->qual[count1].lost_dispense_record_ind = 1
      ELSE
       reply->qual[count1].processed_by_pharmacy_ind = 1
       IF ((od.fill_nbr > - (1)))
        reply->qual[count1].dispensed_by_pharmacy_ind = 1
       ENDIF
      ENDIF
     ENDIF
     done = 0
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
    FOOT REPORT
     reply->last_updt_dt_tm = hupdt_dt_tm, reply->qual_cnt = count1, stat = alterlist(reply->qual,
      count1)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE get_orders_retail(lvar)
   SELECT
    IF ((request->encntr_qual > 0))
     FROM orders o,
      person p,
      order_catalog oc,
      order_catalog_synonym ocs,
      order_action oa,
      order_dispense od,
      encounter e
     PLAN (o
      WHERE (o.person_id=request->person_id)
       AND expand(num1,1,request->encntr_qual,o.encntr_id,request->encntr[num1].encntr_id)
       AND ((((o.catalog_type_cd+ 0)=pharmacy_cd)
       AND ((o.template_order_flag+ 0) IN (0, 1, 5))) OR (((o.catalog_type_cd+ 0) != pharmacy_cd)))
       AND ((o.active_ind+ 0)=1)
       AND ((o.updt_dt_tm+ 0) >= cnvtdatetime(tupdt_dt_tm))
       AND ((o.orig_order_dt_tm+ 0) >= cnvtdatetime(torig_order_dt_tm))
       AND (( NOT ( EXISTS (
      (SELECT
       od2.order_id
       FROM order_dispense od2
       WHERE od2.order_id=o.order_id
        AND od2.pharm_type_cd=retail_type_cd)))) OR (o.orig_ord_as_flag != 1)) )
      JOIN (e
      WHERE o.encntr_id=e.encntr_id)
      JOIN (p
      WHERE p.person_id=o.last_update_provider_id)
      JOIN (oc
      WHERE oc.catalog_cd=o.catalog_cd)
      JOIN (ocs
      WHERE ocs.synonym_id=o.synonym_id)
      JOIN (oa
      WHERE oa.order_id=o.order_id
       AND oa.action_sequence=o.last_action_sequence)
      JOIN (od
      WHERE outerjoin(o.order_id)=od.parent_order_id
       AND outerjoin(retail_type_cd)=od.pharm_type_cd)
    ELSE
     FROM orders o,
      person p,
      order_catalog oc,
      order_catalog_synonym ocs,
      order_action oa,
      order_dispense od,
      encounter e
     PLAN (o
      WHERE (o.person_id=request->person_id)
       AND ((((o.catalog_type_cd+ 0)=pharmacy_cd)
       AND ((o.template_order_flag+ 0) IN (0, 1, 5))) OR (((o.catalog_type_cd+ 0) != pharmacy_cd)))
       AND ((o.active_ind+ 0)=1)
       AND ((o.updt_dt_tm+ 0) >= cnvtdatetime(tupdt_dt_tm))
       AND ((o.orig_order_dt_tm+ 0) >= cnvtdatetime(torig_order_dt_tm))
       AND (( NOT ( EXISTS (
      (SELECT
       od2.order_id
       FROM order_dispense od2
       WHERE od2.order_id=o.order_id
        AND od2.pharm_type_cd=retail_type_cd)))) OR (o.orig_ord_as_flag != 1)) )
      JOIN (e
      WHERE o.encntr_id=e.encntr_id)
      JOIN (p
      WHERE p.person_id=o.last_update_provider_id)
      JOIN (oc
      WHERE oc.catalog_cd=o.catalog_cd)
      JOIN (ocs
      WHERE ocs.synonym_id=o.synonym_id)
      JOIN (oa
      WHERE oa.order_id=o.order_id
       AND oa.action_sequence=o.last_action_sequence)
      JOIN (od
      WHERE outerjoin(o.order_id)=od.parent_order_id
       AND outerjoin(retail_type_cd)=od.pharm_type_cd)
    ENDIF
    INTO "nl:"
    o.order_id, sort_parent = od.parent_order_id
    ORDER BY o.order_id, sort_parent, od.fill_nbr DESC
    HEAD REPORT
     count1 = 0, stat = alterlist(reply->qual,10)
     IF (order_mnemonic_size=0)
      order_mnemonic_size = (size(o.hna_order_mnemonic,3) - 1)
     ENDIF
    HEAD o.order_id
     count1 = (count1+ 1)
     IF (mod(count1,10)=1
      AND count1 != 1)
      stat = alterlist(reply->qual,(count1+ 9))
     ENDIF
     IF (datetimediff(o.updt_dt_tm,tupdt_dt_tm) > 0)
      hupdt_dt_tm = cnvtdatetime(o.updt_dt_tm)
     ENDIF
     CALL fill_reply(dvar)
    HEAD sort_parent
     IF (sort_parent > 0)
      IF (od.person_id != o.person_id)
       reply->qual[count1].lost_dispense_record_ind = 1
      ELSE
       reply->qual[count1].processed_by_pharmacy_ind = 1
       IF ((od.fill_nbr > - (1)))
        reply->qual[count1].dispensed_by_pharmacy_ind = 1
       ENDIF
      ENDIF
     ENDIF
    FOOT REPORT
     reply->last_updt_dt_tm = hupdt_dt_tm, reply->qual_cnt = count1, stat = alterlist(reply->qual,
      count1)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE get_orders_by_cat_stat_cd_retail(lvar)
   SELECT
    IF ((request->encntr_qual > 0))
     FROM orders o,
      person p,
      order_catalog oc,
      order_catalog_synonym ocs,
      order_action oa,
      order_dispense od,
      encounter e
     PLAN (o
      WHERE (o.person_id=request->person_id)
       AND expand(num3,1,request->status_qual,(o.order_status_cd+ 0),request->status_list[num3].
       status_cd)
       AND expand(num2,1,request->cat_type_qual,(o.catalog_type_cd+ 0),request->cat_type[num2].
       cat_type_cd)
       AND ((o.catalog_type_cd=pharmacy_cd
       AND o.template_order_flag IN (0, 1, 5)) OR (o.catalog_type_cd != pharmacy_cd))
       AND expand(num1,1,request->encntr_qual,o.encntr_id,request->encntr[num1].encntr_id)
       AND ((o.active_ind+ 0)=1)
       AND ((o.updt_dt_tm+ 0) >= cnvtdatetime(tupdt_dt_tm))
       AND ((o.orig_order_dt_tm+ 0) >= cnvtdatetime(torig_order_dt_tm))
       AND (( NOT ( EXISTS (
      (SELECT
       od2.order_id
       FROM order_dispense od2
       WHERE od2.order_id=o.order_id
        AND od2.pharm_type_cd=retail_type_cd)))) OR (o.orig_ord_as_flag != 1)) )
      JOIN (e
      WHERE o.encntr_id=e.encntr_id)
      JOIN (p
      WHERE p.person_id=o.last_update_provider_id)
      JOIN (oc
      WHERE oc.catalog_cd=o.catalog_cd)
      JOIN (ocs
      WHERE ocs.synonym_id=o.synonym_id)
      JOIN (oa
      WHERE oa.order_id=o.order_id
       AND oa.action_sequence=o.last_action_sequence)
      JOIN (od
      WHERE outerjoin(o.order_id)=od.parent_order_id
       AND outerjoin(retail_type_cd)=od.pharm_type_cd)
    ELSE
     FROM orders o,
      person p,
      order_catalog oc,
      order_catalog_synonym ocs,
      order_action oa,
      order_dispense od,
      encounter e
     PLAN (o
      WHERE (o.person_id=request->person_id)
       AND expand(num3,1,request->status_qual,(o.order_status_cd+ 0),request->status_list[num3].
       status_cd)
       AND expand(num2,1,request->cat_type_qual,(o.catalog_type_cd+ 0),request->cat_type[num2].
       cat_type_cd)
       AND ((o.catalog_type_cd=pharmacy_cd
       AND o.template_order_flag IN (0, 1, 5)) OR (o.catalog_type_cd != pharmacy_cd))
       AND ((o.active_ind+ 0)=1)
       AND ((o.updt_dt_tm+ 0) >= cnvtdatetime(tupdt_dt_tm))
       AND ((o.orig_order_dt_tm+ 0) >= cnvtdatetime(torig_order_dt_tm))
       AND (( NOT ( EXISTS (
      (SELECT
       od2.order_id
       FROM order_dispense od2
       WHERE od2.order_id=o.order_id
        AND od2.pharm_type_cd=retail_type_cd)))) OR (o.orig_ord_as_flag != 1)) )
      JOIN (e
      WHERE o.encntr_id=e.encntr_id)
      JOIN (p
      WHERE p.person_id=o.last_update_provider_id)
      JOIN (oc
      WHERE oc.catalog_cd=o.catalog_cd)
      JOIN (ocs
      WHERE ocs.synonym_id=o.synonym_id)
      JOIN (oa
      WHERE oa.order_id=o.order_id
       AND oa.action_sequence=o.last_action_sequence)
      JOIN (od
      WHERE outerjoin(o.order_id)=od.parent_order_id
       AND outerjoin(retail_type_cd)=od.pharm_type_cd)
    ENDIF
    INTO "nl:"
    o.order_id, sort_parent = od.parent_order_id
    ORDER BY o.order_id, sort_parent, od.fill_nbr DESC
    HEAD REPORT
     count1 = 0, stat = alterlist(reply->qual,10)
     IF (order_mnemonic_size=0)
      order_mnemonic_size = (size(o.hna_order_mnemonic,3) - 1)
     ENDIF
    HEAD o.order_id
     count1 = (count1+ 1)
     IF (mod(count1,10)=1
      AND count1 != 1)
      stat = alterlist(reply->qual,(count1+ 9))
     ENDIF
     IF (datetimediff(o.updt_dt_tm,tupdt_dt_tm) > 0)
      hupdt_dt_tm = cnvtdatetime(o.updt_dt_tm)
     ENDIF
     CALL fill_reply(dvar)
    HEAD sort_parent
     IF (sort_parent > 0)
      IF (o.person_id != od.person_id)
       reply->qual[count1].lost_dispense_record_ind = 1
      ELSE
       reply->qual[count1].processed_by_pharmacy_ind = 1
       IF ((od.fill_nbr > - (1)))
        reply->qual[count1].dispensed_by_pharmacy_ind = 1
       ENDIF
      ENDIF
     ENDIF
     done = 0
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
    FOOT REPORT
     reply->last_updt_dt_tm = hupdt_dt_tm, reply->qual_cnt = count1, stat = alterlist(reply->qual,
      count1)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE get_orders_by_status_cd_retail(lvar)
   SELECT
    IF ((request->encntr_qual > 0))
     FROM orders o,
      person p,
      order_catalog oc,
      order_catalog_synonym ocs,
      order_action oa,
      order_dispense od,
      encounter e
     PLAN (o
      WHERE (o.person_id=request->person_id)
       AND expand(num3,1,request->status_qual,(o.order_status_cd+ 0),request->status_list[num3].
       status_cd)
       AND ((o.catalog_type_cd+ 0)=pharmacy_cd)
       AND ((((o.template_order_flag+ 0) IN (0, 1, 5))) OR (((o.catalog_type_cd+ 0) != pharmacy_cd)
      ))
       AND expand(num1,1,request->encntr_qual,o.encntr_id,request->encntr[num1].encntr_id)
       AND ((o.active_ind+ 0)=1)
       AND ((o.updt_dt_tm+ 0) >= cnvtdatetime(tupdt_dt_tm))
       AND ((o.orig_order_dt_tm+ 0) >= cnvtdatetime(torig_order_dt_tm))
       AND (( NOT ( EXISTS (
      (SELECT
       od2.order_id
       FROM order_dispense od2
       WHERE od2.order_id=o.order_id
        AND od2.pharm_type_cd=retail_type_cd)))) OR (o.orig_ord_as_flag != 1)) )
      JOIN (e
      WHERE o.encntr_id=e.encntr_id)
      JOIN (p
      WHERE p.person_id=o.last_update_provider_id)
      JOIN (oc
      WHERE oc.catalog_cd=o.catalog_cd)
      JOIN (ocs
      WHERE ocs.synonym_id=o.synonym_id)
      JOIN (oa
      WHERE oa.order_id=o.order_id
       AND oa.action_sequence=o.last_action_sequence)
      JOIN (od
      WHERE outerjoin(o.order_id)=od.parent_order_id
       AND outerjoin(retail_type_cd)=od.pharm_type_cd)
    ELSE
     FROM orders o,
      person p,
      order_catalog oc,
      order_catalog_synonym ocs,
      order_action oa,
      order_dispense od,
      encounter e
     PLAN (o
      WHERE (o.person_id=request->person_id)
       AND expand(num3,1,request->status_qual,(o.order_status_cd+ 0),request->status_list[num3].
       status_cd)
       AND o.catalog_type_cd=pharmacy_cd
       AND ((((o.template_order_flag+ 0) IN (0, 1, 5))) OR (o.catalog_type_cd != pharmacy_cd))
       AND ((o.active_ind+ 0)=1)
       AND ((o.updt_dt_tm+ 0) >= cnvtdatetime(tupdt_dt_tm))
       AND ((o.orig_order_dt_tm+ 0) >= cnvtdatetime(torig_order_dt_tm))
       AND (( NOT ( EXISTS (
      (SELECT
       od2.order_id
       FROM order_dispense od2
       WHERE od2.order_id=o.order_id
        AND od2.pharm_type_cd=retail_type_cd)))) OR (o.orig_ord_as_flag != 1)) )
      JOIN (e
      WHERE o.encntr_id=e.encntr_id)
      JOIN (p
      WHERE p.person_id=o.last_update_provider_id)
      JOIN (oc
      WHERE oc.catalog_cd=o.catalog_cd)
      JOIN (ocs
      WHERE ocs.synonym_id=o.synonym_id)
      JOIN (oa
      WHERE oa.order_id=o.order_id
       AND oa.action_sequence=o.last_action_sequence)
      JOIN (od
      WHERE outerjoin(o.order_id)=od.parent_order_id
       AND outerjoin(retail_type_cd)=od.pharm_type_cd)
    ENDIF
    INTO "nl:"
    o.order_id, sort_parent = od.parent_order_id
    ORDER BY o.order_id, sort_parent, od.fill_nbr DESC
    HEAD REPORT
     count1 = 0, stat = alterlist(reply->qual,10)
     IF (order_mnemonic_size=0)
      order_mnemonic_size = (size(o.hna_order_mnemonic,3) - 1)
     ENDIF
    HEAD o.order_id
     count1 = (count1+ 1)
     IF (mod(count1,10)=1
      AND count1 != 1)
      stat = alterlist(reply->qual,(count1+ 9))
     ENDIF
     IF (datetimediff(o.updt_dt_tm,tupdt_dt_tm) > 0)
      hupdt_dt_tm = cnvtdatetime(o.updt_dt_tm)
     ENDIF
     CALL fill_reply(dvar)
    HEAD sort_parent
     IF (sort_parent > 0)
      IF (o.person_id != od.person_id)
       reply->qual[count1].lost_dispense_record_ind = 1
      ELSE
       reply->qual[count1].processed_by_pharmacy_ind = 1
       IF ((od.fill_nbr > - (1)))
        reply->qual[count1].dispensed_by_pharmacy_ind = 1
       ENDIF
      ENDIF
     ENDIF
     done = 0
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
    FOOT REPORT
     reply->last_updt_dt_tm = hupdt_dt_tm, reply->qual_cnt = count1, stat = alterlist(reply->qual,
      count1)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE get_retail_orders(lvar)
   SELECT
    IF ((request->encntr_qual > 0))
     FROM order_dispense od,
      orders o,
      person p,
      order_catalog oc,
      order_catalog_synonym ocs,
      order_action oa,
      encounter e
     PLAN (od
      WHERE (od.person_id=request->person_id)
       AND expand(num1,1,request->encntr_qual,od.encntr_id,request->encntr[num1].encntr_id))
      JOIN (o
      WHERE o.order_id=od.order_id
       AND ((((od.parent_order_id+ 0)=0)) OR (((od.parent_order_id+ 0) > 0)
       AND ((o.person_id+ 0) != (od.person_id+ 0))))
       AND ((((o.catalog_type_cd+ 0)=pharmacy_cd)
       AND ((o.template_order_flag+ 0) IN (0, 1, 5))) OR (((o.catalog_type_cd+ 0) != pharmacy_cd)))
       AND ((o.active_ind+ 0)=1)
       AND ((o.updt_dt_tm+ 0) >= cnvtdatetime(tupdt_dt_tm))
       AND ((o.orig_order_dt_tm+ 0) >= cnvtdatetime(torig_order_dt_tm)))
      JOIN (e
      WHERE o.encntr_id=e.encntr_id)
      JOIN (p
      WHERE p.person_id=o.last_update_provider_id)
      JOIN (oc
      WHERE oc.catalog_cd=o.catalog_cd)
      JOIN (ocs
      WHERE ocs.synonym_id=o.synonym_id)
      JOIN (oa
      WHERE oa.order_id=o.order_id
       AND oa.action_sequence=o.last_action_sequence)
    ELSE
     FROM order_dispense od,
      orders o,
      person p,
      order_catalog oc,
      order_catalog_synonym ocs,
      order_action oa,
      encounter e
     PLAN (od
      WHERE (od.person_id=request->person_id)
       AND od.pharm_type_cd=retail_type_cd)
      JOIN (o
      WHERE o.order_id=od.order_id
       AND ((((od.parent_order_id+ 0)=0)) OR (((od.parent_order_id+ 0) > 0)
       AND o.person_id != od.person_id))
       AND ((((o.catalog_type_cd+ 0)=pharmacy_cd)
       AND ((o.template_order_flag+ 0) IN (0, 1, 5))) OR (((o.catalog_type_cd+ 0) != pharmacy_cd)))
       AND ((o.active_ind+ 0)=1)
       AND ((o.updt_dt_tm+ 0) >= cnvtdatetime(tupdt_dt_tm))
       AND ((o.orig_order_dt_tm+ 0) >= cnvtdatetime(torig_order_dt_tm)))
      JOIN (e
      WHERE o.encntr_id=e.encntr_id)
      JOIN (p
      WHERE p.person_id=o.last_update_provider_id)
      JOIN (oc
      WHERE oc.catalog_cd=o.catalog_cd)
      JOIN (ocs
      WHERE ocs.synonym_id=o.synonym_id)
      JOIN (oa
      WHERE oa.order_id=o.order_id
       AND oa.action_sequence=o.last_action_sequence)
    ENDIF
    INTO "nl:"
    o.order_id, sort_parent = od.parent_order_id
    ORDER BY o.order_id, sort_parent, od.fill_nbr DESC
    HEAD REPORT
     count1 = 0, retail_order_cnt = 0, stat = alterlist(reply->retail_order_qual,10)
     IF (order_mnemonic_size=0)
      order_mnemonic_size = (size(o.hna_order_mnemonic,3) - 1)
     ENDIF
    HEAD o.order_id
     count1 = (count1+ 1)
     IF (mod(count1,10)=1
      AND count1 != 1)
      stat = alterlist(reply->retail_order_qual,(count1+ 9))
     ENDIF
     CALL echo(build("size of array: ",size(reply->retail_order_qual,5)))
     IF (datetimediff(o.updt_dt_tm,tupdt_dt_tm) > 0)
      hupdt_dt_tm = cnvtdatetime(o.updt_dt_tm)
     ENDIF
     CALL fill_retail_reply(dvar)
    FOOT REPORT
     reply->last_updt_dt_tm = hupdt_dt_tm, stat = alterlist(reply->retail_order_qual,count1)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE get_orders_by_cat_type(lvar)
   SELECT
    IF ((request->encntr_qual > 0))
     FROM orders o,
      person p,
      order_catalog oc,
      order_catalog_synonym ocs,
      order_action oa,
      encounter e
     PLAN (o
      WHERE expand(num1,1,request->encntr_qual,o.encntr_id,request->encntr[num1].encntr_id)
       AND (o.person_id=request->person_id)
       AND expand(num2,1,request->cat_type_qual,(o.catalog_type_cd+ 0),request->cat_type[num2].
       cat_type_cd)
       AND ((((o.catalog_type_cd+ 0)=pharmacy_cd)
       AND ((o.template_order_flag+ 0) IN (0, 1, 5))) OR (((o.catalog_type_cd+ 0) != pharmacy_cd)))
       AND ((o.active_ind+ 0)=1)
       AND ((o.updt_dt_tm+ 0) >= cnvtdatetime(tupdt_dt_tm))
       AND ((o.orig_order_dt_tm+ 0) >= cnvtdatetime(torig_order_dt_tm)))
      JOIN (e
      WHERE o.encntr_id=e.encntr_id)
      JOIN (p
      WHERE p.person_id=o.last_update_provider_id)
      JOIN (oc
      WHERE oc.catalog_cd=o.catalog_cd)
      JOIN (ocs
      WHERE ocs.synonym_id=o.synonym_id)
      JOIN (oa
      WHERE oa.order_id=o.order_id
       AND oa.action_sequence=o.last_action_sequence)
    ELSE
     FROM orders o,
      person p,
      order_catalog oc,
      order_catalog_synonym ocs,
      order_action oa,
      encounter e
     PLAN (o
      WHERE (o.person_id=request->person_id)
       AND expand(num2,1,request->cat_type_qual,(o.catalog_type_cd+ 0),request->cat_type[num2].
       cat_type_cd)
       AND ((o.catalog_type_cd=pharmacy_cd
       AND o.template_order_flag IN (0, 1, 5)) OR (o.catalog_type_cd != pharmacy_cd))
       AND ((o.active_ind+ 0)=1)
       AND ((o.updt_dt_tm+ 0) >= cnvtdatetime(tupdt_dt_tm))
       AND ((o.orig_order_dt_tm+ 0) >= cnvtdatetime(torig_order_dt_tm)))
      JOIN (e
      WHERE o.encntr_id=e.encntr_id)
      JOIN (p
      WHERE p.person_id=o.last_update_provider_id)
      JOIN (oc
      WHERE oc.catalog_cd=o.catalog_cd)
      JOIN (ocs
      WHERE ocs.synonym_id=o.synonym_id)
      JOIN (oa
      WHERE oa.order_id=o.order_id
       AND oa.action_sequence=o.last_action_sequence)
    ENDIF
    INTO "nl:"
    o.order_id
    HEAD REPORT
     count1 = 0, stat = alterlist(reply->qual,10)
     IF (order_mnemonic_size=0)
      order_mnemonic_size = (size(o.hna_order_mnemonic,3) - 1)
     ENDIF
    HEAD o.order_id
     count1 = (count1+ 1)
     IF (mod(count1,10)=1
      AND count1 != 1)
      stat = alterlist(reply->qual,(count1+ 9))
     ENDIF
     IF (datetimediff(o.updt_dt_tm,tupdt_dt_tm) > 0)
      hupdt_dt_tm = cnvtdatetime(o.updt_dt_tm)
     ENDIF
     CALL fill_reply(dvar), done = 0
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
    FOOT REPORT
     reply->last_updt_dt_tm = hupdt_dt_tm, reply->qual_cnt = count1, stat = alterlist(reply->qual,
      count1)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE get_orders(lvar)
   SELECT
    IF ((request->encntr_qual > 0))
     FROM orders o,
      person p,
      order_catalog oc,
      order_catalog_synonym ocs,
      order_action oa,
      encounter e
     PLAN (o
      WHERE (o.person_id=request->person_id)
       AND expand(num1,1,request->encntr_qual,o.encntr_id,request->encntr[num1].encntr_id)
       AND ((((o.catalog_type_cd+ 0)=pharmacy_cd)
       AND ((o.template_order_flag+ 0) IN (0, 1, 5))) OR (((o.catalog_type_cd+ 0) != pharmacy_cd)))
       AND ((o.active_ind+ 0)=1)
       AND ((o.updt_dt_tm+ 0) >= cnvtdatetime(tupdt_dt_tm))
       AND ((o.orig_order_dt_tm+ 0) >= cnvtdatetime(torig_order_dt_tm)))
      JOIN (e
      WHERE o.encntr_id=e.encntr_id)
      JOIN (p
      WHERE p.person_id=o.last_update_provider_id)
      JOIN (oc
      WHERE oc.catalog_cd=o.catalog_cd)
      JOIN (ocs
      WHERE ocs.synonym_id=o.synonym_id)
      JOIN (oa
      WHERE oa.order_id=o.order_id
       AND oa.action_sequence=o.last_action_sequence)
     ORDER BY o.order_id, o.person_id, o.encntr_id
    ELSE
     FROM orders o,
      person p,
      order_catalog oc,
      order_catalog_synonym ocs,
      order_action oa,
      encounter e
     PLAN (o
      WHERE (o.person_id=request->person_id)
       AND ((((o.catalog_type_cd+ 0)=pharmacy_cd)
       AND ((o.template_order_flag+ 0) IN (0, 1, 5))) OR (((o.catalog_type_cd+ 0) != pharmacy_cd)))
       AND ((o.active_ind+ 0)=1)
       AND ((o.updt_dt_tm+ 0) >= cnvtdatetime(tupdt_dt_tm))
       AND ((o.orig_order_dt_tm+ 0) >= cnvtdatetime(torig_order_dt_tm)))
      JOIN (e
      WHERE o.encntr_id=e.encntr_id)
      JOIN (p
      WHERE p.person_id=o.last_update_provider_id)
      JOIN (oc
      WHERE oc.catalog_cd=o.catalog_cd)
      JOIN (ocs
      WHERE ocs.synonym_id=o.synonym_id)
      JOIN (oa
      WHERE oa.order_id=o.order_id
       AND oa.action_sequence=o.last_action_sequence)
    ENDIF
    INTO "nl:"
    o.order_id
    HEAD REPORT
     count1 = 0, stat = alterlist(reply->qual,10)
     IF (order_mnemonic_size=0)
      order_mnemonic_size = (size(o.hna_order_mnemonic,3) - 1)
     ENDIF
    HEAD o.order_id
     count1 = (count1+ 1)
     IF (mod(count1,10)=1
      AND count1 != 1)
      stat = alterlist(reply->qual,(count1+ 9))
     ENDIF
     IF (datetimediff(o.updt_dt_tm,tupdt_dt_tm) > 0)
      hupdt_dt_tm = cnvtdatetime(o.updt_dt_tm)
     ENDIF
     CALL fill_reply(dvar), done = 0
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
    FOOT REPORT
     reply->last_updt_dt_tm = hupdt_dt_tm, reply->qual_cnt = count1, stat = alterlist(reply->qual,
      count1)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE get_orders_by_cat_stat_cd(lvar)
   SELECT
    IF ((request->encntr_qual > 0))
     FROM orders o,
      person p,
      order_catalog oc,
      order_catalog_synonym ocs,
      order_action oa,
      encounter e
     PLAN (o
      WHERE (o.person_id=request->person_id)
       AND expand(num3,1,request->status_qual,(o.order_status_cd+ 0),request->status_list[num3].
       status_cd)
       AND expand(num2,1,request->cat_type_qual,(o.catalog_type_cd+ 0),request->cat_type[num2].
       cat_type_cd)
       AND ((((o.catalog_type_cd+ 0)=pharmacy_cd)
       AND o.template_order_flag IN (0, 1, 5)) OR (((o.catalog_type_cd+ 0) != pharmacy_cd)))
       AND expand(num1,1,request->encntr_qual,o.encntr_id,request->encntr[num1].encntr_id)
       AND ((o.active_ind+ 0)=1)
       AND ((o.updt_dt_tm+ 0) >= cnvtdatetime(tupdt_dt_tm))
       AND ((o.orig_order_dt_tm+ 0) >= cnvtdatetime(torig_order_dt_tm)))
      JOIN (e
      WHERE o.encntr_id=e.encntr_id)
      JOIN (p
      WHERE p.person_id=o.last_update_provider_id)
      JOIN (oc
      WHERE oc.catalog_cd=o.catalog_cd)
      JOIN (ocs
      WHERE ocs.synonym_id=o.synonym_id)
      JOIN (oa
      WHERE oa.order_id=o.order_id
       AND oa.action_sequence=o.last_action_sequence)
    ELSE
     FROM orders o,
      person p,
      order_catalog oc,
      order_catalog_synonym ocs,
      order_action oa,
      encounter e
     PLAN (o
      WHERE (o.person_id=request->person_id)
       AND expand(num3,1,request->status_qual,(o.order_status_cd+ 0),request->status_list[num3].
       status_cd)
       AND expand(num2,1,request->cat_type_qual,o.catalog_type_cd,request->cat_type[num2].cat_type_cd
       )
       AND ((o.catalog_type_cd=pharmacy_cd
       AND o.template_order_flag IN (0, 1, 5)) OR (o.catalog_type_cd != pharmacy_cd))
       AND ((o.active_ind+ 0)=1)
       AND ((o.updt_dt_tm+ 0) >= cnvtdatetime(tupdt_dt_tm))
       AND ((o.orig_order_dt_tm+ 0) >= cnvtdatetime(torig_order_dt_tm)))
      JOIN (e
      WHERE o.encntr_id=e.encntr_id)
      JOIN (p
      WHERE p.person_id=o.last_update_provider_id)
      JOIN (oc
      WHERE oc.catalog_cd=o.catalog_cd)
      JOIN (ocs
      WHERE ocs.synonym_id=o.synonym_id)
      JOIN (oa
      WHERE oa.order_id=o.order_id
       AND oa.action_sequence=o.last_action_sequence)
    ENDIF
    INTO "nl:"
    o.order_id
    HEAD REPORT
     count1 = 0, stat = alterlist(reply->qual,10)
     IF (order_mnemonic_size=0)
      order_mnemonic_size = (size(o.hna_order_mnemonic,3) - 1)
     ENDIF
    HEAD o.order_id
     count1 = (count1+ 1)
     IF (mod(count1,10)=1
      AND count1 != 1)
      stat = alterlist(reply->qual,(count1+ 9))
     ENDIF
     IF (datetimediff(o.updt_dt_tm,tupdt_dt_tm) > 0)
      hupdt_dt_tm = cnvtdatetime(o.updt_dt_tm)
     ENDIF
     CALL fill_reply(dvar), done = 0
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
    FOOT REPORT
     reply->last_updt_dt_tm = hupdt_dt_tm, reply->qual_cnt = count1, stat = alterlist(reply->qual,
      count1)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE get_orders_by_status_cd(lvar)
   SELECT
    IF ((request->encntr_qual > 0))
     FROM orders o,
      person p,
      order_catalog oc,
      order_catalog_synonym ocs,
      order_action oa,
      encounter e
     PLAN (o
      WHERE (o.person_id=request->person_id)
       AND expand(num3,1,request->status_qual,(o.order_status_cd+ 0),request->status_list[num3].
       status_cd)
       AND o.catalog_type_cd=pharmacy_cd
       AND ((((o.template_order_flag+ 0) IN (0, 1, 5))) OR (o.catalog_type_cd != pharmacy_cd))
       AND expand(num1,1,request->encntr_qual,o.encntr_id,request->encntr[num1].encntr_id)
       AND ((o.active_ind+ 0)=1)
       AND ((o.updt_dt_tm+ 0) >= cnvtdatetime(tupdt_dt_tm))
       AND ((o.orig_order_dt_tm+ 0) >= cnvtdatetime(torig_order_dt_tm)))
      JOIN (e
      WHERE o.encntr_id=e.encntr_id)
      JOIN (p
      WHERE p.person_id=o.last_update_provider_id)
      JOIN (oc
      WHERE oc.catalog_cd=o.catalog_cd)
      JOIN (ocs
      WHERE ocs.synonym_id=o.synonym_id)
      JOIN (oa
      WHERE oa.order_id=o.order_id
       AND oa.action_sequence=o.last_action_sequence)
    ELSE
     FROM orders o,
      person p,
      order_catalog oc,
      order_catalog_synonym ocs,
      order_action oa,
      encounter e
     PLAN (o
      WHERE (o.person_id=request->person_id)
       AND expand(num3,1,request->status_qual,o.order_status_cd,request->status_list[num3].status_cd)
       AND o.catalog_type_cd=pharmacy_cd
       AND ((((o.template_order_flag+ 0) IN (0, 1, 5))) OR (o.catalog_type_cd != pharmacy_cd))
       AND ((o.active_ind+ 0)=1)
       AND ((o.updt_dt_tm+ 0) >= cnvtdatetime(tupdt_dt_tm))
       AND ((o.orig_order_dt_tm+ 0) >= cnvtdatetime(torig_order_dt_tm)))
      JOIN (e
      WHERE o.encntr_id=e.encntr_id)
      JOIN (p
      WHERE p.person_id=o.last_update_provider_id)
      JOIN (oc
      WHERE oc.catalog_cd=o.catalog_cd)
      JOIN (ocs
      WHERE ocs.synonym_id=o.synonym_id)
      JOIN (oa
      WHERE oa.order_id=o.order_id
       AND oa.action_sequence=o.last_action_sequence)
    ENDIF
    INTO "nl:"
    o.order_id
    HEAD REPORT
     count1 = 0, stat = alterlist(reply->qual,10)
     IF (order_mnemonic_size=0)
      order_mnemonic_size = (size(o.hna_order_mnemonic,3) - 1)
     ENDIF
    HEAD o.order_id
     count1 = (count1+ 1)
     IF (mod(count1,10)=1
      AND count1 != 1)
      stat = alterlist(reply->qual,(count1+ 9))
     ENDIF
     IF (datetimediff(o.updt_dt_tm,tupdt_dt_tm) > 0)
      hupdt_dt_tm = cnvtdatetime(o.updt_dt_tm)
     ENDIF
     CALL fill_reply(dvar), done = 0
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
    FOOT REPORT
     reply->last_updt_dt_tm = hupdt_dt_tm, reply->qual_cnt = count1, stat = alterlist(reply->qual,
      count1)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE fill_reply(lvar)
   SET reply->qual[count1].order_id = o.order_id
   SET reply->qual[count1].encntr_id = o.encntr_id
   SET reply->qual[count1].organization_id = e.organization_id
   SET reply->qual[count1].catalog_cd = o.catalog_cd
   SET reply->qual[count1].catalog_type_cd = o.catalog_type_cd
   SET reply->qual[count1].order_status_cd = o.order_status_cd
   SET mnem_size = size(trim(o.order_mnemonic),1)
   IF (mnem_size >= order_mnemonic_size
    AND substring((mnem_size - 3),mnem_size,o.order_mnemonic) != "...")
    SET reply->qual[count1].order_mnemonic = concat(trim(o.order_mnemonic),"...")
   ELSE
    SET reply->qual[count1].order_mnemonic = o.order_mnemonic
   ENDIF
   SET mnem_size = size(trim(o.hna_order_mnemonic),1)
   IF (mnem_size >= order_mnemonic_size
    AND substring((mnem_size - 3),mnem_size,o.hna_order_mnemonic) != "...")
    SET reply->qual[count1].hna_order_mnemonic = concat(trim(o.hna_order_mnemonic),"...")
   ELSE
    SET reply->qual[count1].hna_order_mnemonic = o.hna_order_mnemonic
   ENDIF
   SET reply->qual[count1].last_action_sequence = o.last_action_sequence
   SET reply->qual[count1].activity_type_cd = o.activity_type_cd
   SET reply->qual[count1].orig_order_dt_tm = cnvtdatetime(o.orig_order_dt_tm)
   SET reply->qual[count1].orig_order_tz = o.orig_order_tz
   SET reply->qual[count1].order_detail_display_line = o.clinical_display_line
   SET reply->qual[count1].simplified_display_line = o.simplified_display_line
   SET reply->qual[count1].oe_format_id = o.oe_format_id
   SET reply->qual[count1].last_update_provider_id = o.last_update_provider_id
   SET reply->qual[count1].template_order_id = o.template_order_id
   SET reply->qual[count1].template_order_flag = o.template_order_flag
   SET reply->qual[count1].synonym_id = o.synonym_id
   SET reply->qual[count1].group_order_id = o.group_order_id
   SET reply->qual[count1].group_order_flag = o.group_order_flag
   SET reply->qual[count1].contributor_system_cd = o.contributor_system_cd
   SET reply->qual[count1].link_order_flag = o.link_order_flag
   SET reply->qual[count1].link_order_id = o.link_order_id
   SET reply->qual[count1].suspend_ind = o.suspend_ind
   SET reply->qual[count1].constant_ind = o.constant_ind
   SET reply->qual[count1].prn_ind = o.prn_ind
   SET reply->qual[count1].order_comment_ind = o.order_comment_ind
   SET reply->qual[count1].need_rx_verify_ind = o.need_rx_verify_ind
   SET reply->qual[count1].need_nurse_review_ind = o.need_nurse_review_ind
   SET reply->qual[count1].need_doctor_cosign_ind = o.need_doctor_cosign_ind
   SET reply->qual[count1].current_start_dt_tm = cnvtdatetime(o.current_start_dt_tm)
   SET reply->qual[count1].current_start_tz = o.current_start_tz
   SET reply->qual[count1].projected_stop_dt_tm = cnvtdatetime(o.projected_stop_dt_tm)
   SET reply->qual[count1].projected_stop_tz = o.projected_stop_tz
   SET reply->qual[count1].suspend_effective_dt_tm = cnvtdatetime(o.suspend_effective_dt_tm)
   SET reply->qual[count1].suspend_effective_tz = o.suspend_effective_tz
   SET reply->qual[count1].resume_ind = o.resume_ind
   SET reply->qual[count1].resume_effective_dt_tm = cnvtdatetime(o.resume_effective_dt_tm)
   SET reply->qual[count1].resume_effective_tz = o.resume_effective_tz
   SET reply->qual[count1].discontinue_ind = o.discontinue_ind
   SET reply->qual[count1].discontinue_effective_dt_tm = cnvtdatetime(o.discontinue_effective_dt_tm)
   SET reply->qual[count1].discontinue_effective_tz = o.discontinue_effective_tz
   SET reply->qual[count1].cs_order_id = o.cs_order_id
   SET reply->qual[count1].cs_flag = o.cs_flag
   SET reply->qual[count1].last_updt_cnt = o.updt_cnt
   SET reply->qual[count1].orig_ord_as_flag = o.orig_ord_as_flag
   SET reply->qual[count1].provider_full_name = p.name_full_formatted
   SET reply->qual[count1].dept_status_cd = o.dept_status_cd
   SET reply->qual[count1].ref_text_mask = oc.ref_text_mask
   SET reply->qual[count1].incomplete_order_ind = o.incomplete_order_ind
   SET reply->qual[count1].last_action_type_cd = oa.action_type_cd
   SET reply->qual[count1].disable_order_comment_ind = oc.disable_order_comment_ind
   SET reply->qual[count1].cki = oc.cki
   SET reply->qual[count1].dup_checking_ind = oc.dup_checking_ind
   SET reply->qual[count1].mnemonic_type_cd = ocs.mnemonic_type_cd
   SET reply->qual[count1].activity_subtype_cd = ocs.activity_subtype_cd
   SET reply->qual[count1].synonym_cki = ocs.cki
   SET reply->qual[count1].need_physician_validate_ind = o.need_physician_validate_ind
   SET reply->qual[count1].med_order_type_cd = o.med_order_type_cd
   SET reply->qual[count1].communication_type_cd = oa.communication_type_cd
   IF (trim(cnvtupper(o.hna_order_mnemonic))=trim(cnvtupper(o.ordered_as_mnemonic))
    AND ocs.mnemonic_type_cd != rx_mnemonic_cd)
    SET reply->qual[count1].ordered_as_mnemonic = ocs.mnemonic
   ELSE
    SET mnem_size = size(trim(o.ordered_as_mnemonic),1)
    IF (mnem_size >= order_mnemonic_size
     AND substring((mnem_size - 3),mnem_size,o.ordered_as_mnemonic) != "...")
     SET reply->qual[count1].ordered_as_mnemonic = concat(trim(o.ordered_as_mnemonic),"...")
    ELSE
     SET reply->qual[count1].ordered_as_mnemonic = o.ordered_as_mnemonic
    ENDIF
   ENDIF
   IF (o.med_order_type_cd=iv_cd)
    SET reply->qual[count1].iv_ind = true
   ENDIF
   SET reply->qual[count1].requisition_format_cd = oc.requisition_format_cd
   SET reply->qual[count1].requisition_object_name = uar_get_code_meaning(oc.requisition_format_cd)
   SET reply->qual[count1].action_dt_tm = cnvtdatetime(oa.action_dt_tm)
   SET reply->qual[count1].action_tz = oa.action_tz
 END ;Subroutine
 SUBROUTINE fill_retail_reply(lvar)
   SET retail_order_cnt = (retail_order_cnt+ 1)
   SET reply->retail_order_qual[count1].order_id = o.order_id
   SET reply->retail_order_qual[count1].encntr_id = o.encntr_id
   SET reply->retail_order_qual[count1].organization_id = e.organization_id
   SET reply->retail_order_qual[count1].catalog_cd = o.catalog_cd
   SET reply->retail_order_qual[count1].catalog_type_cd = o.catalog_type_cd
   SET reply->retail_order_qual[count1].order_status_cd = o.order_status_cd
   SET mnem_size = size(trim(o.order_mnemonic),1)
   IF (mnem_size >= order_mnemonic_size
    AND substring((mnem_size - 3),mnem_size,o.order_mnemonic) != "...")
    SET reply->retail_order_qual[count1].order_mnemonic = concat(trim(o.order_mnemonic),"...")
   ELSE
    SET reply->retail_order_qual[count1].order_mnemonic = o.order_mnemonic
   ENDIF
   SET mnem_size = size(trim(o.hna_order_mnemonic),1)
   IF (mnem_size >= order_mnemonic_size
    AND substring((mnem_size - 3),mnem_size,o.hna_order_mnemonic) != "...")
    SET reply->retail_order_qual[count1].hna_order_mnemonic = concat(trim(o.hna_order_mnemonic),"..."
     )
   ELSE
    SET reply->retail_order_qual[count1].hna_order_mnemonic = o.hna_order_mnemonic
   ENDIF
   SET reply->retail_order_qual[count1].last_action_sequence = o.last_action_sequence
   SET reply->retail_order_qual[count1].activity_type_cd = o.activity_type_cd
   SET reply->retail_order_qual[count1].orig_order_dt_tm = cnvtdatetime(o.orig_order_dt_tm)
   SET reply->retail_order_qual[count1].orig_order_tz = o.orig_order_tz
   SET reply->retail_order_qual[count1].order_detail_display_line = o.clinical_display_line
   SET reply->retail_order_qual[count1].simplified_display_line = o.simplified_display_line
   SET reply->retail_order_qual[count1].oe_format_id = o.oe_format_id
   SET reply->retail_order_qual[count1].last_update_provider_id = o.last_update_provider_id
   SET reply->retail_order_qual[count1].template_order_id = o.template_order_id
   SET reply->retail_order_qual[count1].template_order_flag = o.template_order_flag
   SET reply->retail_order_qual[count1].synonym_id = o.synonym_id
   SET reply->retail_order_qual[count1].group_order_id = o.group_order_id
   SET reply->retail_order_qual[count1].group_order_flag = o.group_order_flag
   SET reply->retail_order_qual[count1].contributor_system_cd = o.contributor_system_cd
   SET reply->retail_order_qual[count1].link_order_flag = o.link_order_flag
   SET reply->retail_order_qual[count1].link_order_id = o.link_order_id
   SET reply->retail_order_qual[count1].suspend_ind = o.suspend_ind
   SET reply->retail_order_qual[count1].constant_ind = o.constant_ind
   SET reply->retail_order_qual[count1].prn_ind = o.prn_ind
   SET reply->retail_order_qual[count1].order_comment_ind = o.order_comment_ind
   SET reply->retail_order_qual[count1].need_rx_verify_ind = o.need_rx_verify_ind
   SET reply->retail_order_qual[count1].need_nurse_review_ind = o.need_nurse_review_ind
   SET reply->retail_order_qual[count1].need_doctor_cosign_ind = o.need_doctor_cosign_ind
   SET reply->retail_order_qual[count1].current_start_dt_tm = cnvtdatetime(o.current_start_dt_tm)
   SET reply->retail_order_qual[count1].current_start_tz = o.current_start_tz
   SET reply->retail_order_qual[count1].projected_stop_dt_tm = cnvtdatetime(o.projected_stop_dt_tm)
   SET reply->retail_order_qual[count1].projected_stop_tz = o.projected_stop_tz
   SET reply->retail_order_qual[count1].suspend_effective_dt_tm = cnvtdatetime(o
    .suspend_effective_dt_tm)
   SET reply->retail_order_qual[count1].suspend_effective_tz = o.suspend_effective_tz
   SET reply->retail_order_qual[count1].resume_ind = o.resume_ind
   SET reply->retail_order_qual[count1].resume_effective_dt_tm = cnvtdatetime(o
    .resume_effective_dt_tm)
   SET reply->retail_order_qual[count1].resume_effective_tz = o.resume_effective_tz
   SET reply->retail_order_qual[count1].discontinue_ind = o.discontinue_ind
   SET reply->retail_order_qual[count1].discontinue_effective_dt_tm = cnvtdatetime(o
    .discontinue_effective_dt_tm)
   SET reply->retail_order_qual[count1].discontinue_effective_tz = o.discontinue_effective_tz
   SET reply->retail_order_qual[count1].cs_order_id = o.cs_order_id
   SET reply->retail_order_qual[count1].cs_flag = o.cs_flag
   SET reply->retail_order_qual[count1].last_updt_cnt = o.updt_cnt
   SET reply->retail_order_qual[count1].orig_ord_as_flag = o.orig_ord_as_flag
   SET reply->retail_order_qual[count1].provider_full_name = p.name_full_formatted
   SET reply->retail_order_qual[count1].dept_status_cd = o.dept_status_cd
   SET reply->retail_order_qual[count1].ref_text_mask = o.ref_text_mask
   SET reply->retail_order_qual[count1].incomplete_order_ind = o.incomplete_order_ind
   SET reply->retail_order_qual[count1].last_action_type_cd = oa.action_type_cd
   SET reply->retail_order_qual[count1].disable_order_comment_ind = oc.disable_order_comment_ind
   SET reply->retail_order_qual[count1].cki = oc.cki
   SET reply->retail_order_qual[count1].dup_checking_ind = oc.dup_checking_ind
   SET reply->retail_order_qual[count1].mnemonic_type_cd = ocs.mnemonic_type_cd
   SET reply->retail_order_qual[count1].activity_subtype_cd = ocs.activity_subtype_cd
   SET reply->retail_order_qual[count1].synonym_cki = ocs.cki
   SET reply->retail_order_qual[count1].need_physician_validate_ind = o.need_physician_validate_ind
   SET reply->retail_order_qual[count1].med_order_type_cd = o.med_order_type_cd
   SET reply->retail_order_qual[count1].communication_type_cd = oa.communication_type_cd
   IF (trim(cnvtupper(o.hna_order_mnemonic))=trim(cnvtupper(o.ordered_as_mnemonic))
    AND ocs.mnemonic_type_cd != rx_mnemonic_cd)
    SET reply->retail_order_qual[count1].ordered_as_mnemonic = ocs.mnemonic
   ELSE
    SET mnem_size = size(trim(o.ordered_as_mnemonic),1)
    IF (mnem_size >= order_mnemonic_size
     AND substring((mnem_size - 3),mnem_size,o.ordered_as_mnemonic) != "...")
     SET reply->retail_order_qual[count1].ordered_as_mnemonic = concat(trim(o.ordered_as_mnemonic),
      "...")
    ELSE
     SET reply->retail_order_qual[count1].ordered_as_mnemonic = o.ordered_as_mnemonic
    ENDIF
   ENDIF
   IF (o.med_order_type_cd=iv_cd)
    SET reply->retail_order_qual[count1].iv_ind = true
   ENDIF
   SET reply->retail_order_qual[count1].action_dt_tm = cnvtdatetime(oa.action_dt_tm)
   SET reply->retail_order_qual[count1].action_tz = oa.action_tz
 END ;Subroutine
#exit_script
 IF (failed=false)
  IF ((((reply->qual_cnt > 0)) OR (retail_order_cnt > 0)) )
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
 SET script_version = "034"
END GO
