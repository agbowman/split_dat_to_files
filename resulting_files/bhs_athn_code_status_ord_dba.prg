CREATE PROGRAM bhs_athn_code_status_ord:dba
 DECLARE ord_status_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",6004,"ORDERED"))
 DECLARE clin_cat_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",16389,"CONDITION"))
 DECLARE act_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",106,"CODESTATUS"))
 IF (( $3 != 0))
  SET where_params = build(" (O.ENCNTR_ID =", $3," OR O.ENCNTR_ID=0) AND O.PERSON_ID=", $2)
 ELSE
  SET where_params = build(" O.PERSON_ID =", $2)
 ENDIF
 DECLARE cnt = i4
 SET cnt = 0
 FREE RECORD order_list
 RECORD order_list(
   1 qual[*]
     2 order_id = vc
     2 catalog_cd = vc
     2 catalog_disp = vc
     2 catalog_mean = vc
     2 order_catalog_synonym_id = vc
     2 format_id = vc
     2 hnaorder_mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 mnemonic = vc
     2 ordered_datetime = vc
     2 ordered_timezone = vc
     2 start_datetime = vc
     2 startdate_timezone = vc
     2 order_status_cd = vc
     2 order_status_mean = vc
     2 order_status_disp = vc
     2 clinical_displayline = vc
     2 catalog_type_cd = vc
     2 catalog_type_mean = vc
     2 catalog_type_disp = vc
     2 activity_type_cd = vc
     2 activity_type_mean = vc
     2 activity_type_disp = vc
     2 clinical_category_cd = vc
     2 clinical_category_mean = vc
     2 clinical_category_disp = vc
     2 order_catalog_cki = vc
     2 department_status_cd = f8
     2 department_status_mean = vc
     2 department_status_disp = vc
     2 departmental_displayline = vc
 )
 SELECT DISTINCT INTO "NL:"
  o.order_id
  FROM orders o,
   order_action oa,
   order_catalog oc
  PLAN (o
   WHERE parser(where_params)
    AND o.dcp_clin_cat_cd=clin_cat_cd
    AND o.order_status_cd=ord_status_cd
    AND o.activity_type_cd=act_type_cd
    AND o.template_order_flag IN (0, 1, 6, 7))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_type_cd=2534.00)
   JOIN (oc
   WHERE oc.catalog_cd=o.catalog_cd)
  ORDER BY o.order_id DESC
  HEAD o.order_id
   cnt += 1, stat = alterlist(order_list->qual,cnt), order_list->qual[cnt].order_id = cnvtstring(o
    .order_id),
   order_list->qual[cnt].order_catalog_synonym_id = cnvtstring(o.synonym_id), order_list->qual[cnt].
   catalog_cd = cnvtstring(o.catalog_cd), order_list->qual[cnt].catalog_disp = uar_get_code_display(o
    .catalog_cd),
   order_list->qual[cnt].format_id = cnvtstring(o.oe_format_id), order_list->qual[cnt].
   hnaorder_mnemonic = trim(o.hna_order_mnemonic,3), order_list->qual[cnt].ordered_as_mnemonic = trim
   (o.ordered_as_mnemonic,3),
   order_list->qual[cnt].mnemonic = trim(o.hna_order_mnemonic,3), order_list->qual[cnt].
   ordered_datetime = format(o.orig_order_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"), order_list->qual[cnt].
   ordered_timezone = substring(21,3,datetimezoneformat(o.orig_order_dt_tm,o.orig_order_tz,
     "MM/dd/yyyy hh:mm:ss ZZZ",curtimezonedef)),
   order_list->qual[cnt].start_datetime = format(o.current_start_dt_tm,"MM/DD/YYYY HH:MM:SS;;D"),
   order_list->qual[cnt].startdate_timezone = substring(21,3,datetimezoneformat(o.current_start_dt_tm,
     o.current_start_tz,"MM/dd/yyyy hh:mm:ss ZZZ",curtimezonedef)), order_list->qual[cnt].
   order_status_cd = cnvtstring(o.order_status_cd),
   order_list->qual[cnt].order_status_disp = uar_get_code_display(o.order_status_cd), order_list->
   qual[cnt].order_status_mean = uar_get_code_meaning(o.order_status_cd), order_list->qual[cnt].
   clinical_displayline = trim(o.clinical_display_line,3),
   order_list->qual[cnt].catalog_type_cd = cnvtstring(o.catalog_type_cd), order_list->qual[cnt].
   catalog_type_disp = uar_get_code_display(o.catalog_type_cd), order_list->qual[cnt].
   catalog_type_mean = uar_get_code_meaning(o.catalog_type_cd),
   order_list->qual[cnt].activity_type_cd = cnvtstring(o.activity_type_cd), order_list->qual[cnt].
   activity_type_disp = uar_get_code_display(o.activity_type_cd), order_list->qual[cnt].
   activity_type_mean = uar_get_code_meaning(o.activity_type_cd),
   order_list->qual[cnt].clinical_category_cd = cnvtstring(o.dcp_clin_cat_cd), order_list->qual[cnt].
   clinical_category_disp = uar_get_code_display(o.dcp_clin_cat_cd), order_list->qual[cnt].
   clinical_category_mean = uar_get_code_meaning(o.dcp_clin_cat_cd),
   order_list->qual[cnt].department_status_cd = o.dept_status_cd, order_list->qual[cnt].
   department_status_disp = uar_get_code_display(o.dept_status_cd), order_list->qual[cnt].
   department_status_mean = uar_get_code_meaning(o.dept_status_cd),
   order_list->qual[cnt].departmental_displayline = trim(o.order_detail_display_line,3)
  WITH time = 60, maxrec = 1
 ;end select
#exit_script
 SET _memory_reply_string = cnvtrectojson(order_list)
 FREE RECORD order_list
END GO
