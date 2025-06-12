CREATE PROGRAM bed_get_assay:dba
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 slist[*]
      2 active_ind = i2
      2 code_value = f8
      2 assay_list[*]
        3 active_ind = i2
        3 code_value = f8
        3 display = c50
        3 description = vc
        3 general_info
          4 result_type_code_value = f8
          4 result_type_display = c40
          4 result_type_mean = vc
          4 activity_type_code_value = f8
          4 activity_type_display = c40
          4 delta_check_ind = i2
          4 inter_data_check_ind = i2
          4 res_proc_type_code_value = f8
          4 res_proc_type_display = c40
          4 rad_section_type_code_value = f8
          4 rad_section_type_display = c40
          4 single_select_ind = i2
          4 io_flag = i2
          4 event
            5 code_value = f8
            5 display = vc
            5 es_hier_ind = i2
            5 event_cd_cki = vc
          4 concept
            5 concept_cki = vc
            5 concept_name = vc
            5 vocab_cd = f8
            5 vocab_disp = c40
            5 vocab_axis_cd = f8
            5 vocab_axis_disp = c40
            5 source_identifier = vc
          4 sci_notation_ind = i2
        3 data_map[*]
          4 active_ind = i2
          4 service_resource_code_value = f8
          4 service_resource_display = vc
          4 min_digits = i4
          4 max_digits = i4
          4 dec_place = i4
          4 data_map_type_flag = i2
        3 rr_list[*]
          4 active_ind = i2
          4 rrf_id = f8
          4 sequence = i4
          4 def_value = f8
          4 uom_code_value = f8
          4 uom_display = c40
          4 from_age = i4
          4 from_age_unit_code_value = f8
          4 from_age_unit_display = c40
          4 from_age_unit_mean = c12
          4 to_age = i4
          4 to_age_unit_code_value = f8
          4 to_age_unit_display = c40
          4 to_age_unit_mean = c12
          4 unknown_age_ind = i2
          4 sex_code_value = f8
          4 sex_display = c40
          4 sex_mean = c12
          4 specimen_type_code_value = f8
          4 specimen_type_display = c40
          4 service_resource_code_value = f8
          4 service_resource_display = c40
          4 ref_low = f8
          4 ref_high = f8
          4 ref_ind = i2
          4 crit_low = f8
          4 crit_high = f8
          4 crit_ind = i2
          4 review_low = f8
          4 review_high = f8
          4 review_ind = i2
          4 linear_low = f8
          4 linear_high = f8
          4 linear_ind = i2
          4 dilute_ind = i2
          4 feasible_low = f8
          4 feasible_high = f8
          4 feasible_ind = i2
          4 alpha_list[*]
            5 active_ind = i2
            5 nomenclature_id = f8
            5 sequence = i4
            5 source_string = c255
            5 short_string = c60
            5 mnemonic = c25
            5 default_ind = i2
            5 use_units_ind = i2
            5 reference_ind = i2
            5 result_process_code_value = f8
            5 result_process_display = c40
            5 result_process_description = c60
            5 result_value = f8
            5 truth_state_cd = f8
            5 truth_state_display = vc
            5 truth_state_mean = vc
            5 grid_display = i4
          4 rule_list[*]
            5 ref_range_notify_trig_id = f8
            5 trigger_name = vc
            5 trigger_seq_nbr = i4
          4 species
            5 code_value = f8
            5 display = vc
            5 meaning = vc
          4 adv_deltas[*]
            5 delta_ind = i2
            5 delta_low = f8
            5 delta_high = f8
            5 delta_check_type
              6 code_value = f8
              6 display = vc
              6 description = vc
              6 mean = vc
            5 delta_minutes = i4
            5 delta_value = f8
          4 delta_check_type
            5 code_value = f8
            5 display = vc
            5 description = vc
            5 mean = vc
          4 delta_minutes = i4
          4 delta_value = f8
          4 delta_chk_flag = i2
          4 service_resource_mean = vc
        3 equivalent_assay[*]
          4 active_ind = i2
          4 code_value = f8
          4 display = c40
        3 event
          4 code_value = f8
          4 display = vc
          4 es_hier_ind = i2
        3 source = i2
        3 equation[*]
          4 id = f8
          4 description = vc
          4 equation_description = vc
          4 age_from = f8
          4 age_from_units
            5 code_value = f8
            5 display = vc
            5 mean = vc
          4 age_to = f8
          4 age_to_units
            5 code_value = f8
            5 display = vc
            5 mean = vc
          4 sex
            5 code_value = f8
            5 display = vc
            5 mean = vc
          4 unknown_age_ind = i2
          4 default_ind = i2
          4 components[*]
            5 component_name = vc
            5 included_assay
              6 code_value = f8
              6 display = vc
              6 mean = vc
            5 constant_value = f8
            5 required_flag = i2
            5 look_time_direction_flag = i2
            5 time_window_back_minutes = i4
            5 time_window_minutes = i4
            5 value_unit
              6 code_value = f8
              6 display = vc
              6 mean = vc
            5 optional_value = f8
        3 dynamic_groups[*]
          4 doc_set_ref_id = f8
          4 description = vc
        3 dgroup_label_ind = i2
        3 lookback_minutes[*]
          4 type_code_value = f8
          4 type_display = vc
          4 type_mean = vc
          4 minutes_nbr = i4
        3 interpretations_ind = i2
        3 witness_required_ind = i2
        3 default_type_flag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 too_many_results_ind = i2
  ) WITH protect
 ENDIF
 DECLARE slist_count = i4 WITH protect
 DECLARE tot_slist = i4 WITH protect
 DECLARE rlist_count = i4 WITH protect
 DECLARE tot_rlist = i4 WITH protect
 DECLARE dlist_count = i4 WITH protect
 DECLARE tot_dlist = i4 WITH protect
 DECLARE alist_count = i4 WITH protect
 DECLARE tot_alist = i4 WITH protect
 DECLARE elist_count = i4 WITH protect
 DECLARE tot_elist = i4 WITH protect
 DECLARE arlist_count = i4 WITH protect
 DECLARE tot_arlist = i4 WITH protect
 DECLARE found = i4 WITH protect
 DECLARE start_total = i4 WITH protect
 DECLARE scnt = i4 WITH protect
 DECLARE acnt = i4 WITH protect
 DECLARE auto_client_id = f8 WITH protect
 DECLARE wcard = vc WITH protect
 DECLARE typescnt = i4 WITH protect
 DECLARE rec_cnt = i4 WITH protect
 DECLARE total_assays = i4 WITH protect
 DECLARE adlist_count = i4 WITH protect
 DECLARE tot_adlist = i4 WITH protect
 DECLARE fndtbl = i4 WITH protect
 SET reply->status_data.status = "F"
 SET slist_count = 0
 SET tot_slist = 0
 SET rlist_count = 0
 SET tot_rlist = 0
 SET dlist_count = 0
 SET tot_dlist = 0
 SET alist_count = 0
 SET tot_alist = 0
 SET elist_count = 0
 SET tot_elist = 0
 SET arlist_count = 0
 SET tot_arlist = 0
 SET found = 0
 SET start_total = 0
 SET scnt = 0
 SET acnt = 0
 SET auto_client_id = 0.0
 SELECT INTO "NL:"
  FROM br_client b
  DETAIL
   auto_client_id = b.autobuild_client_id
  WITH nocounter
 ;end select
 SET wcard = "*"
 DECLARE search_string = vc
 IF (trim(request->search_txt) > " ")
  IF ((request->search_type_flag="S"))
   SET search_string = concat(trim(cnvtupper(request->search_txt)),wcard)
  ELSE
   SET search_string = concat(wcard,trim(cnvtupper(request->search_txt)),wcard)
  ENDIF
 ELSE
  SET search_string = wcard
 ENDIF
 DECLARE name_parse = vc
 DECLARE name_parse_auto = vc
 SET name_parse = concat('dta.mnemonic_key_cap = "',search_string,'"')
 SET name_parse_auto = concat('cnvtupper(dta.mnemonic) = "',search_string,'"')
 IF (validate(request->result_type_code_value))
  IF ((request->result_type_code_value > 0))
   SET name_parse = build(name_parse," and dta.default_result_type_cd = ",request->
    result_type_code_value)
   SET name_parse_auto = build(name_parse_auto," and dta.result_type_cd = ",request->
    result_type_code_value)
  ENDIF
 ENDIF
 IF (validate(request->result_types))
  SET typescnt = size(request->result_types,5)
  IF (typescnt > 0)
   SET name_parse = build(name_parse," and dta.default_result_type_cd in (")
   FOR (x = 1 TO typescnt)
    SET name_parse = build(name_parse,request->result_types[x].code_value)
    IF (x=typescnt)
     SET name_parse = build(name_parse,")")
    ELSE
     SET name_parse = build(name_parse,",")
    ENDIF
   ENDFOR
  ENDIF
 ENDIF
 IF ((request->search_by=1)
  AND validate(request->activity_type_cd))
  IF ((request->activity_type_cd > 0.0))
   SET name_parse = build(name_parse," and dta.activity_type_cd+0 = request->activity_type_cd")
   SET name_parse_auto = build(name_parse_auto,
    " and dta.activity_type_cd+0 = request->activity_type_cd")
  ENDIF
 ENDIF
 SET stat = alterlist(reply->slist,50)
 SET rec_cnt = size(request->search_list,5)
 SET total_assays = 0
 FOR (x = 1 TO rec_cnt)
   SET slist_count = (slist_count+ 1)
   SET tot_slist = (tot_slist+ 1)
   IF (slist_count > 50)
    SET stat = alterlist(reply->slist,(tot_slist+ 50))
    SET slist_count = 1
   ENDIF
   IF ((request->search_by=1))
    SET alist_count = 0
    SET tot_alist = 0
    SELECT INTO "NL:"
     FROM orc_resource_list orl,
      profile_task_r ptr,
      discrete_task_assay dta,
      order_catalog oc,
      br_assay ba,
      code_value cv106,
      code_value cv289,
      code_value cv1636,
      code_value cv14286,
      code_value cv
     PLAN (orl
      WHERE (orl.service_resource_cd=request->search_list[x].code_value)
       AND orl.active_ind=1)
      JOIN (ptr
      WHERE ptr.catalog_cd=orl.catalog_cd
       AND ptr.active_ind=1)
      JOIN (oc
      WHERE oc.active_ind=1
       AND oc.catalog_cd=ptr.catalog_cd)
      JOIN (dta
      WHERE parser(name_parse)
       AND dta.active_ind=1
       AND dta.task_assay_cd=ptr.task_assay_cd)
      JOIN (cv106
      WHERE cv106.code_set=106
       AND cv106.active_ind=1
       AND cv106.code_value=dta.activity_type_cd)
      JOIN (cv289
      WHERE cv289.code_set=outerjoin(289)
       AND cv289.active_ind=outerjoin(1)
       AND cv289.code_value=outerjoin(dta.default_result_type_cd))
      JOIN (cv1636
      WHERE cv1636.code_set=outerjoin(1636)
       AND cv1636.active_ind=outerjoin(1)
       AND cv1636.code_value=outerjoin(dta.bb_result_processing_cd))
      JOIN (cv14286
      WHERE cv14286.code_set=outerjoin(14286)
       AND cv14286.active_ind=outerjoin(1)
       AND cv14286.code_value=outerjoin(dta.rad_section_type_cd))
      JOIN (cv
      WHERE cv.code_value=dta.event_cd)
      JOIN (ba
      WHERE ba.task_assay_cd=outerjoin(dta.task_assay_cd))
     ORDER BY orl.service_resource_cd, orl.catalog_cd, ptr.sequence
     HEAD orl.service_resource_cd
      reply->slist[tot_slist].code_value = orl.service_resource_cd, reply->slist[tot_slist].
      active_ind = orl.active_ind, stat = alterlist(reply->slist[tot_slist].assay_list,5)
     DETAIL
      found = 0
      FOR (i = 1 TO tot_alist)
        IF ((reply->slist[tot_slist].assay_list[i].code_value=dta.task_assay_cd))
         found = 1, i = (tot_alist+ 1)
        ENDIF
      ENDFOR
      IF (found=0)
       alist_count = (alist_count+ 1), tot_alist = (tot_alist+ 1)
       IF (alist_count > 5)
        stat = alterlist(reply->slist[tot_slist].assay_list,(tot_alist+ 5)), slist_count = 1
       ENDIF
       reply->slist[tot_slist].assay_list[tot_alist].active_ind = dta.active_ind, reply->slist[
       tot_slist].assay_list[tot_alist].code_value = dta.task_assay_cd, reply->slist[tot_slist].
       assay_list[tot_alist].display = dta.mnemonic,
       reply->slist[tot_slist].assay_list[tot_alist].description = dta.description, reply->slist[
       tot_slist].assay_list[tot_alist].general_info.result_type_code_value = dta
       .default_result_type_cd, reply->slist[tot_slist].assay_list[tot_alist].general_info.
       result_type_display = cv289.display,
       reply->slist[tot_slist].assay_list[tot_alist].general_info.result_type_mean = cv289
       .cdf_meaning, reply->slist[tot_slist].assay_list[tot_alist].general_info.
       activity_type_code_value = dta.activity_type_cd, reply->slist[tot_slist].assay_list[tot_alist]
       .general_info.activity_type_display = cv106.display,
       reply->slist[tot_slist].assay_list[tot_alist].general_info.delta_check_ind = ba
       .delta_checking_ind, reply->slist[tot_slist].assay_list[tot_alist].general_info.
       inter_data_check_ind = ba.interpretive_ind, reply->slist[tot_slist].assay_list[tot_alist].
       general_info.res_proc_type_code_value = dta.bb_result_processing_cd,
       reply->slist[tot_slist].assay_list[tot_alist].general_info.res_proc_type_display = cv1636
       .display, reply->slist[tot_slist].assay_list[tot_alist].general_info.concept.concept_cki = dta
       .concept_cki, reply->slist[tot_slist].assay_list[tot_alist].general_info.sci_notation_ind =
       dta.sci_notation_ind,
       reply->slist[tot_slist].assay_list[tot_alist].general_info.rad_section_type_code_value = dta
       .rad_section_type_cd, reply->slist[tot_slist].assay_list[tot_alist].general_info.
       rad_section_type_display = cv14286.display, reply->slist[tot_slist].assay_list[tot_alist].
       source = 1,
       reply->slist[tot_slist].assay_list[tot_alist].general_info.single_select_ind = dta
       .single_select_ind, reply->slist[tot_slist].assay_list[tot_alist].general_info.io_flag = dta
       .io_flag, reply->slist[tot_slist].assay_list[tot_alist].general_info.event.code_value = dta
       .event_cd,
       reply->slist[tot_slist].assay_list[tot_alist].general_info.event.display =
       uar_get_code_display(dta.event_cd), reply->slist[tot_slist].assay_list[tot_alist].general_info
       .event.event_cd_cki = cv.cki, reply->slist[tot_slist].assay_list[tot_alist].default_type_flag
        = dta.default_type_flag
      ENDIF
     WITH nocounter
    ;end select
    SELECT INTO "NL:"
     FROM assay_processing_r apr,
      discrete_task_assay dta,
      profile_task_r ptr,
      order_catalog oc,
      br_assay ba,
      code_value cv106,
      code_value cv289,
      code_value cv1636,
      code_value cv14286,
      code_value cv
     PLAN (apr
      WHERE (apr.service_resource_cd=request->search_list[x].code_value)
       AND apr.active_ind=1)
      JOIN (dta
      WHERE parser(name_parse)
       AND dta.active_ind=1
       AND dta.task_assay_cd=apr.task_assay_cd)
      JOIN (ptr
      WHERE ptr.active_ind=1
       AND ptr.task_assay_cd=apr.task_assay_cd)
      JOIN (oc
      WHERE oc.active_ind=1
       AND oc.catalog_cd=ptr.catalog_cd
       AND oc.resource_route_lvl=2)
      JOIN (cv106
      WHERE cv106.code_set=106
       AND cv106.active_ind=1
       AND cv106.code_value=dta.activity_type_cd)
      JOIN (cv289
      WHERE cv289.code_set=outerjoin(289)
       AND cv289.active_ind=outerjoin(1)
       AND cv289.code_value=outerjoin(dta.default_result_type_cd))
      JOIN (cv1636
      WHERE cv1636.code_set=outerjoin(1636)
       AND cv1636.active_ind=outerjoin(1)
       AND cv1636.code_value=outerjoin(dta.bb_result_processing_cd))
      JOIN (cv14286
      WHERE cv14286.code_set=outerjoin(14286)
       AND cv14286.active_ind=outerjoin(1)
       AND cv14286.code_value=outerjoin(dta.rad_section_type_cd))
      JOIN (cv
      WHERE cv.code_value=dta.event_cd)
      JOIN (ba
      WHERE ba.task_assay_cd=outerjoin(dta.task_assay_cd))
     HEAD apr.service_resource_cd
      reply->slist[tot_slist].code_value = apr.service_resource_cd, reply->slist[tot_slist].
      active_ind = apr.active_ind
      IF (alist_count=0)
       stat = alterlist(reply->slist[tot_slist].assay_list,5)
      ENDIF
     DETAIL
      found = 0
      FOR (i = 1 TO tot_alist)
        IF ((reply->slist[tot_slist].assay_list[i].code_value=dta.task_assay_cd))
         found = 1, i = (tot_alist+ 1)
        ENDIF
      ENDFOR
      IF (found=0)
       alist_count = (alist_count+ 1), tot_alist = (tot_alist+ 1)
       IF (alist_count > 5)
        stat = alterlist(reply->slist[tot_slist].assay_list,(tot_alist+ 5)), slist_count = 1
       ENDIF
       reply->slist[tot_slist].assay_list[tot_alist].code_value = dta.task_assay_cd, reply->slist[
       tot_slist].assay_list[tot_alist].display = dta.mnemonic, reply->slist[tot_slist].assay_list[
       tot_alist].description = dta.description,
       reply->slist[tot_slist].assay_list[tot_alist].active_ind = dta.active_ind, reply->slist[
       tot_slist].assay_list[tot_alist].general_info.result_type_code_value = dta
       .default_result_type_cd, reply->slist[tot_slist].assay_list[tot_alist].general_info.
       result_type_display = cv289.display,
       reply->slist[tot_slist].assay_list[tot_alist].general_info.result_type_mean = cv289
       .cdf_meaning, reply->slist[tot_slist].assay_list[tot_alist].general_info.
       activity_type_code_value = dta.activity_type_cd, reply->slist[tot_slist].assay_list[tot_alist]
       .general_info.activity_type_display = cv106.display,
       reply->slist[tot_slist].assay_list[tot_alist].general_info.delta_check_ind = ba
       .delta_checking_ind, reply->slist[tot_slist].assay_list[tot_alist].general_info.
       inter_data_check_ind = ba.interpretive_ind, reply->slist[tot_slist].assay_list[tot_alist].
       general_info.res_proc_type_code_value = dta.bb_result_processing_cd,
       reply->slist[tot_slist].assay_list[tot_alist].general_info.concept.concept_cki = dta
       .concept_cki, reply->slist[tot_slist].assay_list[tot_alist].general_info.sci_notation_ind =
       dta.sci_notation_ind, reply->slist[tot_slist].assay_list[tot_alist].general_info.
       res_proc_type_display = cv1636.display,
       reply->slist[tot_slist].assay_list[tot_alist].general_info.rad_section_type_code_value = dta
       .rad_section_type_cd, reply->slist[tot_slist].assay_list[tot_alist].general_info.
       rad_section_type_display = cv14286.display, reply->slist[tot_slist].assay_list[tot_alist].
       source = 1,
       reply->slist[tot_slist].assay_list[tot_alist].general_info.single_select_ind = dta
       .single_select_ind, reply->slist[tot_slist].assay_list[tot_alist].general_info.io_flag = dta
       .io_flag, reply->slist[tot_slist].assay_list[tot_alist].general_info.event.code_value = dta
       .event_cd,
       reply->slist[tot_slist].assay_list[tot_alist].general_info.event.display =
       uar_get_code_display(dta.event_cd), reply->slist[tot_slist].assay_list[tot_alist].general_info
       .event.event_cd_cki = cv.cki, reply->slist[tot_slist].assay_list[tot_alist].default_type_flag
        = dta.default_type_flag
      ENDIF
     WITH nocounter
    ;end select
    SET stat = alterlist(reply->slist[tot_slist].assay_list,tot_alist)
   ELSEIF ((request->search_by=2))
    SET stat = alterlist(reply->slist[tot_slist].assay_list,5)
    SET alist_count = 0
    SET tot_alist = 0
    IF ((request->search_list[x].code_value=0))
     SET name_parse = concat(name_parse,
      " and (dta.active_ind = 1 or request->include_inactive_child_ind = 1)")
    ELSE
     SET name_parse = concat(name_parse,
      " and dta.activity_type_cd = request->search_list[x]->code_value and ",
      "(dta.active_ind = 1 or request->include_inactive_child_ind = 1)")
    ENDIF
    SELECT INTO "NL:"
     FROM discrete_task_assay dta,
      br_assay ba,
      code_value cv106,
      code_value cv289,
      code_value cv1636,
      code_value cv14286,
      code_value cv
     PLAN (dta
      WHERE parser(name_parse))
      JOIN (cv106
      WHERE cv106.code_set=106
       AND cv106.active_ind=1
       AND cv106.code_value=dta.activity_type_cd)
      JOIN (cv289
      WHERE cv289.code_set=outerjoin(289)
       AND cv289.active_ind=outerjoin(1)
       AND cv289.code_value=outerjoin(dta.default_result_type_cd))
      JOIN (cv1636
      WHERE cv1636.code_set=outerjoin(1636)
       AND cv1636.active_ind=outerjoin(1)
       AND cv1636.code_value=outerjoin(dta.bb_result_processing_cd))
      JOIN (cv14286
      WHERE cv14286.code_set=outerjoin(14286)
       AND cv14286.active_ind=outerjoin(1)
       AND cv14286.code_value=outerjoin(dta.rad_section_type_cd))
      JOIN (cv
      WHERE cv.code_value=dta.event_cd)
      JOIN (ba
      WHERE ba.task_assay_cd=outerjoin(dta.task_assay_cd))
     ORDER BY dta.task_assay_cd
     HEAD dta.task_assay_cd
      reply->slist[tot_slist].code_value = dta.task_assay_cd, reply->slist[tot_slist].active_ind =
      dta.active_ind, alist_count = (alist_count+ 1),
      tot_alist = (tot_alist+ 1)
      IF (alist_count > 5)
       stat = alterlist(reply->slist[tot_slist].assay_list,(tot_alist+ 5)), slist_count = 1
      ENDIF
      reply->slist[tot_slist].assay_list[tot_alist].code_value = dta.task_assay_cd, reply->slist[
      tot_slist].assay_list[tot_alist].display = dta.mnemonic, reply->slist[tot_slist].assay_list[
      tot_alist].description = dta.description,
      reply->slist[tot_slist].assay_list[tot_alist].active_ind = dta.active_ind, reply->slist[
      tot_slist].assay_list[tot_alist].general_info.result_type_code_value = dta
      .default_result_type_cd, reply->slist[tot_slist].assay_list[tot_alist].source = 1
     DETAIL
      reply->slist[tot_slist].assay_list[tot_alist].general_info.result_type_display = cv289.display,
      reply->slist[tot_slist].assay_list[tot_alist].general_info.result_type_mean = cv289.cdf_meaning,
      reply->slist[tot_slist].assay_list[tot_alist].general_info.activity_type_code_value = dta
      .activity_type_cd,
      reply->slist[tot_slist].assay_list[tot_alist].general_info.activity_type_display = cv106
      .display, reply->slist[tot_slist].assay_list[tot_alist].general_info.delta_check_ind = ba
      .delta_checking_ind, reply->slist[tot_slist].assay_list[tot_alist].general_info.
      inter_data_check_ind = ba.interpretive_ind,
      reply->slist[tot_slist].assay_list[tot_alist].general_info.res_proc_type_code_value = dta
      .bb_result_processing_cd, reply->slist[tot_slist].assay_list[tot_alist].general_info.concept.
      concept_cki = dta.concept_cki, reply->slist[tot_slist].assay_list[tot_alist].general_info.
      sci_notation_ind = dta.sci_notation_ind,
      reply->slist[tot_slist].assay_list[tot_alist].general_info.res_proc_type_display = cv1636
      .display, reply->slist[tot_slist].assay_list[tot_alist].general_info.
      rad_section_type_code_value = dta.rad_section_type_cd, reply->slist[tot_slist].assay_list[
      tot_alist].general_info.rad_section_type_display = cv14286.display,
      reply->slist[tot_slist].assay_list[tot_alist].general_info.single_select_ind = dta
      .single_select_ind, reply->slist[tot_slist].assay_list[tot_alist].general_info.io_flag = dta
      .io_flag, reply->slist[tot_slist].assay_list[tot_alist].general_info.event.code_value = dta
      .event_cd,
      reply->slist[tot_slist].assay_list[tot_alist].general_info.event.display = uar_get_code_display
      (dta.event_cd), reply->slist[tot_slist].assay_list[tot_alist].general_info.event.event_cd_cki
       = cv.cki, reply->slist[tot_slist].assay_list[tot_alist].default_type_flag = dta
      .default_type_flag
     WITH nocounter
    ;end select
    SET total_assays = (total_assays+ tot_alist)
    IF ((request->max_reply > 0)
     AND (total_assays > request->max_reply))
     SET stat = alterlist(reply->slist,0)
     SET reply->too_many_results_ind = 1
     SET tot_slist = 0
     GO TO enditnow
    ENDIF
    SET bb_activity_type_cd = 0.0
    SELECT INTO "NL:"
     FROM code_value cv
     WHERE cv.code_set=106
      AND cv.active_ind=1
      AND cv.cdf_meaning="BB"
     DETAIL
      bb_activity_type_cd = cv.code_value
     WITH nocounter
    ;end select
    SET start_total = tot_alist
    IF ((request->search_list[x].code_value > 0))
     SET name_parse_auto = concat(name_parse_auto,
      " and dta.activity_type_cd = request->search_list[x]->code_value ")
    ENDIF
    SELECT INTO "NL:"
     FROM br_auto_dta dta
     PLAN (dta
      WHERE parser(name_parse_auto)
       AND dta.br_client_id=auto_client_id)
     DETAIL
      found = 0
      FOR (i = 1 TO start_total)
        IF ((((reply->slist[tot_slist].assay_list[i].display=dta.mnemonic)) OR (cnvtupper(reply->
         slist[tot_slist].assay_list[i].display)=cnvtupper(dta.mnemonic)
         AND dta.activity_type_cd != bb_activity_type_cd)) )
         found = 1, i = start_total
        ENDIF
      ENDFOR
      IF (found=0)
       reply->slist[tot_slist].code_value = dta.task_assay_cd, reply->slist[tot_slist].active_ind = 1,
       alist_count = (alist_count+ 1),
       tot_alist = (tot_alist+ 1)
       IF (alist_count > 5)
        stat = alterlist(reply->slist[tot_slist].assay_list,(tot_alist+ 5)), slist_count = 1
       ENDIF
       reply->slist[tot_slist].assay_list[tot_alist].code_value = dta.task_assay_cd, reply->slist[
       tot_slist].assay_list[tot_alist].display = dta.mnemonic, reply->slist[tot_slist].assay_list[
       tot_alist].description = dta.description,
       reply->slist[tot_slist].assay_list[tot_alist].active_ind = 1, reply->slist[tot_slist].
       assay_list[tot_alist].general_info.result_type_code_value = dta.result_type_cd, reply->slist[
       tot_slist].assay_list[tot_alist].general_info.activity_type_code_value = dta.activity_type_cd,
       reply->slist[tot_slist].assay_list[tot_alist].general_info.res_proc_type_code_value = dta
       .bb_result_processing_cd, reply->slist[tot_slist].assay_list[tot_alist].source = 2
      ENDIF
     WITH skipbedrock = 1, nocounter
    ;end select
    IF (tot_alist > 0)
     SELECT INTO "NL:"
      FROM (dummyt d  WITH seq = tot_alist),
       code_value cv106,
       code_value cv289
      PLAN (d
       WHERE (reply->slist[tot_slist].assay_list[d.seq].code_value > 0)
        AND (reply->slist[tot_slist].assay_list[d.seq].general_info.result_type_display IN (" *",
       null)))
       JOIN (cv106
       WHERE cv106.code_set=106
        AND cv106.active_ind=1
        AND (cv106.code_value=reply->slist[tot_slist].assay_list[d.seq].general_info.
       activity_type_code_value))
       JOIN (cv289
       WHERE cv289.code_set=outerjoin(289)
        AND cv289.active_ind=outerjoin(1)
        AND cv289.code_value=outerjoin(reply->slist[tot_slist].assay_list[d.seq].general_info.
        result_type_code_value))
      DETAIL
       reply->slist[tot_slist].assay_list[d.seq].general_info.result_type_display = cv289.display,
       reply->slist[tot_slist].assay_list[d.seq].general_info.result_type_mean = cv289.cdf_meaning,
       reply->slist[tot_slist].assay_list[d.seq].general_info.activity_type_display = cv106.display
      WITH nocounter
     ;end select
     SELECT INTO "NL:"
      FROM (dummyt d  WITH seq = tot_alist),
       code_value cv
      PLAN (d
       WHERE (reply->slist[tot_slist].assay_list[d.seq].general_info.res_proc_type_code_value > 0))
       JOIN (cv
       WHERE (cv.code_value=reply->slist[tot_slist].assay_list[d.seq].general_info.
       res_proc_type_code_value))
      DETAIL
       reply->slist[tot_slist].assay_list[d.seq].general_info.res_proc_type_display = cv.display
      WITH nocounter
     ;end select
    ENDIF
    SET stat = alterlist(reply->slist[tot_slist].assay_list,tot_alist)
   ELSEIF ((request->search_by=3))
    SET reply->slist[tot_slist].code_value = request->search_list[x].code_value
    SET tot_alist = 1
    SET stat = alterlist(reply->slist[tot_slist].assay_list,tot_alist)
    SELECT INTO "NL:"
     FROM discrete_task_assay dta,
      br_assay ba,
      code_value cv106,
      code_value cv289,
      code_value cv1636,
      code_value cv14286,
      code_value cv
     PLAN (dta
      WHERE (dta.task_assay_cd=request->search_list[x].code_value)
       AND ((dta.active_ind=1) OR ((request->include_inactive_child_ind=1))) )
      JOIN (cv106
      WHERE cv106.code_set=outerjoin(106)
       AND cv106.active_ind=outerjoin(1)
       AND cv106.code_value=outerjoin(dta.activity_type_cd))
      JOIN (cv289
      WHERE cv289.code_set=outerjoin(289)
       AND cv289.active_ind=outerjoin(1)
       AND cv289.code_value=outerjoin(dta.default_result_type_cd))
      JOIN (cv1636
      WHERE cv1636.code_set=outerjoin(1636)
       AND cv1636.active_ind=outerjoin(1)
       AND cv1636.code_value=outerjoin(dta.bb_result_processing_cd))
      JOIN (cv14286
      WHERE cv14286.code_set=outerjoin(14286)
       AND cv14286.active_ind=outerjoin(1)
       AND cv14286.code_value=outerjoin(dta.rad_section_type_cd))
      JOIN (cv
      WHERE cv.code_value=dta.event_cd)
      JOIN (ba
      WHERE ba.task_assay_cd=outerjoin(dta.task_assay_cd))
     DETAIL
      reply->slist[tot_slist].active_ind = dta.active_ind, reply->slist[tot_slist].assay_list[
      tot_alist].code_value = dta.task_assay_cd, reply->slist[tot_slist].assay_list[tot_alist].
      display = dta.mnemonic,
      reply->slist[tot_slist].assay_list[tot_alist].description = dta.description, reply->slist[
      tot_slist].assay_list[tot_alist].active_ind = dta.active_ind, reply->slist[tot_slist].
      assay_list[tot_alist].general_info.result_type_code_value = dta.default_result_type_cd,
      reply->slist[tot_slist].assay_list[tot_alist].general_info.result_type_display = cv289.display,
      reply->slist[tot_slist].assay_list[tot_alist].general_info.result_type_mean = cv289.cdf_meaning,
      reply->slist[tot_slist].assay_list[tot_alist].general_info.activity_type_code_value = dta
      .activity_type_cd,
      reply->slist[tot_slist].assay_list[tot_alist].general_info.activity_type_display = cv106
      .display, reply->slist[tot_slist].assay_list[tot_alist].general_info.delta_check_ind = ba
      .delta_checking_ind, reply->slist[tot_slist].assay_list[tot_alist].general_info.
      inter_data_check_ind = ba.interpretive_ind,
      reply->slist[tot_slist].assay_list[tot_alist].general_info.res_proc_type_code_value = dta
      .bb_result_processing_cd, reply->slist[tot_slist].assay_list[tot_alist].general_info.concept.
      concept_cki = dta.concept_cki, reply->slist[tot_slist].assay_list[tot_alist].general_info.
      sci_notation_ind = dta.sci_notation_ind,
      reply->slist[tot_slist].assay_list[tot_alist].general_info.res_proc_type_display = cv1636
      .display, reply->slist[tot_slist].assay_list[tot_alist].general_info.
      rad_section_type_code_value = dta.rad_section_type_cd, reply->slist[tot_slist].assay_list[
      tot_alist].general_info.rad_section_type_display = cv14286.display,
      reply->slist[tot_slist].assay_list[tot_alist].source = 1, reply->slist[tot_slist].assay_list[
      tot_alist].general_info.single_select_ind = dta.single_select_ind, reply->slist[tot_slist].
      assay_list[tot_alist].general_info.io_flag = dta.io_flag,
      reply->slist[tot_slist].assay_list[tot_alist].general_info.event.code_value = dta.event_cd,
      reply->slist[tot_slist].assay_list[tot_alist].general_info.event.display = uar_get_code_display
      (dta.event_cd), reply->slist[tot_slist].assay_list[tot_alist].general_info.event.event_cd_cki
       = cv.cki,
      reply->slist[tot_slist].assay_list[tot_alist].default_type_flag = dta.default_type_flag
     WITH nocounter
    ;end select
    IF (curqual=0)
     SELECT INTO "NL:"
      FROM br_auto_dta dta
      PLAN (dta
       WHERE (dta.task_assay_cd=request->search_list[x].code_value)
        AND dta.br_client_id=auto_client_id)
      DETAIL
       reply->slist[tot_slist].active_ind = 1, reply->slist[tot_slist].assay_list[tot_alist].
       code_value = dta.task_assay_cd, reply->slist[tot_slist].assay_list[tot_alist].display = dta
       .mnemonic,
       reply->slist[tot_slist].assay_list[tot_alist].description = dta.description, reply->slist[
       tot_slist].assay_list[tot_alist].active_ind = 1, reply->slist[tot_slist].assay_list[tot_alist]
       .general_info.result_type_code_value = dta.result_type_cd,
       reply->slist[tot_slist].assay_list[tot_alist].general_info.activity_type_code_value = dta
       .activity_type_cd, reply->slist[tot_slist].assay_list[tot_alist].general_info.
       res_proc_type_code_value = dta.bb_result_processing_cd, reply->slist[tot_slist].assay_list[
       tot_alist].source = 2
      WITH skipbedrock = 1, nocounter
     ;end select
     IF (curqual=0)
      SET slist_count = (slist_count - 1)
      SET tot_slist = (tot_slist - 1)
     ELSE
      SELECT INTO "NL:"
       FROM code_value cv106
       PLAN (cv106
        WHERE cv106.code_set=106
         AND cv106.active_ind=1
         AND (cv106.code_value=reply->slist[tot_slist].assay_list[tot_alist].general_info.
        activity_type_code_value))
       DETAIL
        reply->slist[tot_slist].assay_list[1].general_info.activity_type_display = cv106.display
       WITH nocounter
      ;end select
      SELECT INTO "NL:"
       FROM code_value cv289
       PLAN (cv289
        WHERE cv289.code_set=289
         AND cv289.active_ind=1
         AND (cv289.code_value=reply->slist[tot_slist].assay_list[tot_alist].general_info.
        result_type_code_value))
       DETAIL
        reply->slist[tot_slist].assay_list[tot_alist].general_info.result_type_display = cv289
        .display, reply->slist[tot_slist].assay_list[tot_alist].general_info.result_type_mean = cv289
        .cdf_meaning
       WITH nocounter
      ;end select
      IF ((reply->slist[tot_slist].assay_list[tot_alist].general_info.res_proc_type_code_value > 0))
       SELECT INTO "NL:"
        FROM code_value cv
        PLAN (cv
         WHERE (cv.code_value=reply->slist[tot_slist].assay_list[tot_alist].general_info.
         res_proc_type_code_value))
        DETAIL
         reply->slist[tot_slist].assay_list[tot_alist].general_info.res_proc_type_display = cv
         .display
        WITH nocounter
       ;end select
      ENDIF
     ENDIF
    ENDIF
    SET stat = alterlist(reply->slist[tot_slist].assay_list,tot_alist)
   ENDIF
   IF ((request->load.reference_ranges_ind=1))
    FOR (i = 1 TO tot_alist)
      SET stat = alterlist(reply->slist[tot_slist].assay_list[i].rr_list,5)
      SET rlist_count = 0
      SET tot_rlist = 0
      SELECT INTO "NL:"
       FROM reference_range_factor rrf,
        code_value cv54,
        code_value cv57,
        code_value cv2052,
        code_value cv221,
        code_value cv226,
        code_value cv236,
        code_value cv340_from,
        code_value cv340_to
       PLAN (rrf
        WHERE (rrf.task_assay_cd=reply->slist[tot_slist].assay_list[i].code_value)
         AND ((rrf.active_ind=1) OR (rrf.active_ind=0
         AND (request->include_inactive_child_ind=1))) )
        JOIN (cv54
        WHERE cv54.code_set=outerjoin(54)
         AND cv54.active_ind=outerjoin(1)
         AND cv54.code_value=outerjoin(rrf.units_cd))
        JOIN (cv57
        WHERE cv57.code_set=outerjoin(57)
         AND cv57.active_ind=outerjoin(1)
         AND cv57.code_value=outerjoin(rrf.sex_cd))
        JOIN (cv2052
        WHERE cv2052.code_set=outerjoin(2052)
         AND cv2052.active_ind=outerjoin(1)
         AND cv2052.code_value=outerjoin(rrf.specimen_type_cd))
        JOIN (cv221
        WHERE cv221.code_set=outerjoin(221)
         AND cv221.code_value=outerjoin(rrf.service_resource_cd))
        JOIN (cv340_from
        WHERE cv340_from.code_set=outerjoin(340)
         AND cv340_from.active_ind=outerjoin(1)
         AND cv340_from.code_value=outerjoin(rrf.age_from_units_cd))
        JOIN (cv340_to
        WHERE cv340_to.code_set=outerjoin(340)
         AND cv340_to.active_ind=outerjoin(1)
         AND cv340_to.code_value=outerjoin(rrf.age_to_units_cd))
        JOIN (cv226
        WHERE cv226.code_set=outerjoin(226)
         AND cv226.active_ind=outerjoin(1)
         AND cv226.code_value=outerjoin(rrf.species_cd))
        JOIN (cv236
        WHERE cv236.code_set=outerjoin(236)
         AND cv236.active_ind=outerjoin(1)
         AND cv236.code_value=outerjoin(rrf.delta_check_type_cd))
       ORDER BY rrf.precedence_sequence
       DETAIL
        rlist_count = (rlist_count+ 1), tot_rlist = (tot_rlist+ 1)
        IF (rlist_count > 5)
         stat = alterlist(reply->slist[tot_slist].assay_list[i].rr_list,(tot_rlist+ 5)), rlist_count
          = 1
        ENDIF
        reply->slist[tot_slist].assay_list[i].rr_list[tot_rlist].active_ind = rrf.active_ind, reply->
        slist[tot_slist].assay_list[i].rr_list[tot_rlist].def_value = rrf.default_result, reply->
        slist[tot_slist].assay_list[i].rr_list[tot_rlist].rrf_id = rrf.reference_range_factor_id,
        reply->slist[tot_slist].assay_list[i].rr_list[tot_rlist].sequence = rrf.precedence_sequence,
        reply->slist[tot_slist].assay_list[i].rr_list[tot_rlist].uom_code_value = rrf.units_cd, reply
        ->slist[tot_slist].assay_list[i].rr_list[tot_rlist].uom_display = cv54.display,
        reply->slist[tot_slist].assay_list[i].rr_list[tot_rlist].unknown_age_ind = rrf
        .unknown_age_ind, reply->slist[tot_slist].assay_list[i].rr_list[tot_rlist].from_age = rrf
        .age_from_minutes, reply->slist[tot_slist].assay_list[i].rr_list[tot_rlist].
        from_age_unit_code_value = rrf.age_from_units_cd,
        reply->slist[tot_slist].assay_list[i].rr_list[tot_rlist].from_age_unit_display = cv340_from
        .display, reply->slist[tot_slist].assay_list[i].rr_list[tot_rlist].from_age_unit_mean =
        cv340_from.cdf_meaning, reply->slist[tot_slist].assay_list[i].rr_list[tot_rlist].to_age = rrf
        .age_to_minutes,
        reply->slist[tot_slist].assay_list[i].rr_list[tot_rlist].to_age_unit_code_value = rrf
        .age_to_units_cd, reply->slist[tot_slist].assay_list[i].rr_list[tot_rlist].
        to_age_unit_display = cv340_to.display, reply->slist[tot_slist].assay_list[i].rr_list[
        tot_rlist].to_age_unit_mean = cv340_to.cdf_meaning,
        reply->slist[tot_slist].assay_list[i].rr_list[tot_rlist].sex_code_value = rrf.sex_cd, reply->
        slist[tot_slist].assay_list[i].rr_list[tot_rlist].sex_display = cv57.display, reply->slist[
        tot_slist].assay_list[i].rr_list[tot_rlist].sex_mean = cv57.cdf_meaning,
        reply->slist[tot_slist].assay_list[i].rr_list[tot_rlist].specimen_type_code_value = rrf
        .specimen_type_cd, reply->slist[tot_slist].assay_list[i].rr_list[tot_rlist].
        specimen_type_display = cv2052.display, reply->slist[tot_slist].assay_list[i].rr_list[
        tot_rlist].service_resource_code_value = rrf.service_resource_cd,
        reply->slist[tot_slist].assay_list[i].rr_list[tot_rlist].service_resource_display = cv221
        .display, reply->slist[tot_slist].assay_list[i].rr_list[tot_rlist].service_resource_mean =
        cv221.cdf_meaning, reply->slist[tot_slist].assay_list[i].rr_list[tot_rlist].species.
        code_value = rrf.species_cd,
        reply->slist[tot_slist].assay_list[i].rr_list[tot_rlist].species.display = cv226.display,
        reply->slist[tot_slist].assay_list[i].rr_list[tot_rlist].species.meaning = cv226.cdf_meaning
        IF (rrf.delta_check_type_cd > 0)
         reply->slist[tot_slist].assay_list[i].rr_list[tot_rlist].delta_check_type.code_value = rrf
         .delta_check_type_cd, reply->slist[tot_slist].assay_list[i].rr_list[tot_rlist].
         delta_check_type.display = cv236.display, reply->slist[tot_slist].assay_list[i].rr_list[
         tot_rlist].delta_check_type.description = cv236.description,
         reply->slist[tot_slist].assay_list[i].rr_list[tot_rlist].delta_check_type.mean = cv236
         .cdf_meaning
        ENDIF
        reply->slist[tot_slist].assay_list[i].rr_list[tot_rlist].delta_minutes = rrf.delta_minutes,
        reply->slist[tot_slist].assay_list[i].rr_list[tot_rlist].delta_value = rrf.delta_value, reply
        ->slist[tot_slist].assay_list[i].rr_list[tot_rlist].delta_chk_flag = rrf.delta_chk_flag,
        reply->slist[tot_slist].assay_list[i].rr_list[tot_rlist].ref_low = rrf.normal_low, reply->
        slist[tot_slist].assay_list[i].rr_list[tot_rlist].ref_high = rrf.normal_high, reply->slist[
        tot_slist].assay_list[i].rr_list[tot_rlist].ref_ind = rrf.normal_ind,
        reply->slist[tot_slist].assay_list[i].rr_list[tot_rlist].crit_low = rrf.critical_low, reply->
        slist[tot_slist].assay_list[i].rr_list[tot_rlist].crit_high = rrf.critical_high, reply->
        slist[tot_slist].assay_list[i].rr_list[tot_rlist].crit_ind = rrf.critical_ind,
        reply->slist[tot_slist].assay_list[i].rr_list[tot_rlist].review_low = rrf.review_low, reply->
        slist[tot_slist].assay_list[i].rr_list[tot_rlist].review_high = rrf.review_high, reply->
        slist[tot_slist].assay_list[i].rr_list[tot_rlist].review_ind = rrf.review_ind,
        reply->slist[tot_slist].assay_list[i].rr_list[tot_rlist].linear_low = rrf.linear_low, reply->
        slist[tot_slist].assay_list[i].rr_list[tot_rlist].linear_high = rrf.linear_high, reply->
        slist[tot_slist].assay_list[i].rr_list[tot_rlist].linear_ind = rrf.linear_ind,
        reply->slist[tot_slist].assay_list[i].rr_list[tot_rlist].dilute_ind = rrf.dilute_ind, reply->
        slist[tot_slist].assay_list[i].rr_list[tot_rlist].feasible_low = rrf.feasible_low, reply->
        slist[tot_slist].assay_list[i].rr_list[tot_rlist].feasible_high = rrf.feasible_high,
        reply->slist[tot_slist].assay_list[i].rr_list[tot_rlist].feasible_ind = rrf.feasible_ind
       WITH nocounter
      ;end select
      SET stat = alterlist(reply->slist[tot_slist].assay_list[i].rr_list,tot_rlist)
      FOR (z = 1 TO tot_rlist)
        SET adlist_count = 0
        SET tot_adlist = 0
        SELECT INTO "NL:"
         FROM advanced_delta ad,
          code_value cv236
         PLAN (ad
          WHERE (ad.reference_range_factor_id=reply->slist[tot_slist].assay_list[i].rr_list[z].rrf_id
          )
           AND ad.active_ind=1)
          JOIN (cv236
          WHERE cv236.code_set=outerjoin(236)
           AND cv236.active_ind=outerjoin(1)
           AND cv236.code_value=outerjoin(ad.delta_check_type_cd))
         ORDER BY ad.advanced_delta_id
         HEAD REPORT
          stat = alterlist(reply->slist[tot_slist].assay_list[i].rr_list[z].adv_deltas,5)
         DETAIL
          adlist_count = (adlist_count+ 1), tot_adlist = (tot_adlist+ 1)
          IF (adlist_count > 5)
           stat = alterlist(reply->slist[tot_slist].assay_list[i].rr_list[z].adv_deltas,(tot_adlist+
            5)), adlist_count = 1
          ENDIF
          reply->slist[tot_slist].assay_list[i].rr_list[z].adv_deltas[tot_adlist].delta_ind = ad
          .delta_ind, reply->slist[tot_slist].assay_list[i].rr_list[z].adv_deltas[tot_adlist].
          delta_low = ad.delta_low, reply->slist[tot_slist].assay_list[i].rr_list[z].adv_deltas[
          tot_adlist].delta_high = ad.delta_high,
          reply->slist[tot_slist].assay_list[i].rr_list[z].adv_deltas[tot_adlist].delta_minutes = ad
          .delta_minutes, reply->slist[tot_slist].assay_list[i].rr_list[z].adv_deltas[tot_adlist].
          delta_value = ad.delta_value
          IF (ad.delta_check_type_cd > 0)
           reply->slist[tot_slist].assay_list[i].rr_list[z].adv_deltas[tot_adlist].delta_check_type.
           code_value = ad.delta_check_type_cd, reply->slist[tot_slist].assay_list[i].rr_list[z].
           adv_deltas[tot_adlist].delta_check_type.display = cv236.display, reply->slist[tot_slist].
           assay_list[i].rr_list[z].adv_deltas[tot_adlist].delta_check_type.description = cv236
           .description,
           reply->slist[tot_slist].assay_list[i].rr_list[z].adv_deltas[tot_adlist].delta_check_type.
           mean = cv236.cdf_meaning
          ENDIF
         FOOT REPORT
          stat = alterlist(reply->slist[tot_slist].assay_list[i].rr_list[z].adv_deltas,tot_adlist)
         WITH nocounter
        ;end select
        SET arlist_count = 0
        SET tot_arlist = 0
        SET stat = alterlist(reply->slist[tot_slist].assay_list[i].rr_list[z].alpha_list,5)
        SELECT INTO "NL:"
         FROM alpha_responses ar,
          nomenclature n,
          code_value cv
         PLAN (ar
          WHERE (ar.reference_range_factor_id=reply->slist[tot_slist].assay_list[i].rr_list[z].rrf_id
          )
           AND ((ar.active_ind=1) OR (ar.active_ind=0
           AND (request->include_inactive_child_ind=1))) )
          JOIN (n
          WHERE n.nomenclature_id=ar.nomenclature_id
           AND n.active_ind=1)
          JOIN (cv
          WHERE cv.code_set=outerjoin(1902)
           AND cv.active_ind=outerjoin(1)
           AND cv.code_value=outerjoin(ar.result_process_cd))
         ORDER BY ar.sequence
         DETAIL
          arlist_count = (arlist_count+ 1), tot_arlist = (tot_arlist+ 1)
          IF (arlist_count > 5)
           stat = alterlist(reply->slist[tot_slist].assay_list[i].rr_list[z].alpha_list,(tot_arlist+
            5)), arlist_count = 1
          ENDIF
          reply->slist[tot_slist].assay_list[i].rr_list[z].alpha_list[tot_arlist].active_ind = ar
          .active_ind, reply->slist[tot_slist].assay_list[i].rr_list[z].alpha_list[tot_arlist].
          nomenclature_id = ar.nomenclature_id, reply->slist[tot_slist].assay_list[i].rr_list[z].
          alpha_list[tot_arlist].sequence = ar.sequence,
          reply->slist[tot_slist].assay_list[i].rr_list[z].alpha_list[tot_arlist].source_string = n
          .source_string, reply->slist[tot_slist].assay_list[i].rr_list[z].alpha_list[tot_arlist].
          short_string = n.short_string, reply->slist[tot_slist].assay_list[i].rr_list[z].alpha_list[
          tot_arlist].mnemonic = n.mnemonic,
          reply->slist[tot_slist].assay_list[i].rr_list[z].alpha_list[tot_arlist].default_ind = ar
          .default_ind, reply->slist[tot_slist].assay_list[i].rr_list[z].alpha_list[tot_arlist].
          use_units_ind = ar.use_units_ind, reply->slist[tot_slist].assay_list[i].rr_list[z].
          alpha_list[tot_arlist].reference_ind = ar.reference_ind,
          reply->slist[tot_slist].assay_list[i].rr_list[z].alpha_list[tot_arlist].
          result_process_code_value = ar.result_process_cd, reply->slist[tot_slist].assay_list[i].
          rr_list[z].alpha_list[tot_arlist].result_process_display = cv.display, reply->slist[
          tot_slist].assay_list[i].rr_list[z].alpha_list[tot_arlist].result_process_description = cv
          .description,
          reply->slist[tot_slist].assay_list[i].rr_list[z].alpha_list[tot_arlist].result_value = ar
          .result_value, reply->slist[tot_slist].assay_list[i].rr_list[z].alpha_list[tot_arlist].
          truth_state_cd = ar.truth_state_cd, reply->slist[tot_slist].assay_list[i].rr_list[z].
          alpha_list[tot_arlist].truth_state_display = uar_get_code_display(ar.truth_state_cd),
          reply->slist[tot_slist].assay_list[i].rr_list[z].alpha_list[tot_arlist].truth_state_mean =
          uar_get_code_meaning(ar.truth_state_cd), reply->slist[tot_slist].assay_list[i].rr_list[z].
          alpha_list[tot_arlist].grid_display = ar.multi_alpha_sort_order
         WITH nocounter
        ;end select
        SET stat = alterlist(reply->slist[tot_slist].assay_list[i].rr_list[z].alpha_list,tot_arlist)
      ENDFOR
      SET fndtbl = checkdic("REF_RANGE_NOTIFY_TRIG","T",0)
      IF (fndtbl=2)
       CALL echo("REF_RANGE_NOTIFY_TRIG table found")
      ELSE
       CALL echo("REF_RANGE_NOTIFY_TRIG table not found")
      ENDIF
      DECLARE rulelist_count = i4 WITH protect
      DECLARE tot_rulelist = i4 WITH protect
      IF (fndtbl=2)
       FOR (z = 1 TO tot_rlist)
         SET rulelist_count = 0
         SET tot_rulelist = 0
         SET stat = alterlist(reply->slist[tot_slist].assay_list[i].rr_list[z].rule_list,5)
         SELECT INTO "NL:"
          FROM ref_range_notify_trig rrnt
          PLAN (rrnt
           WHERE (rrnt.reference_range_factor_id=reply->slist[tot_slist].assay_list[i].rr_list[z].
           rrf_id))
          ORDER BY rrnt.trigger_seq_nbr
          DETAIL
           rulelist_count = (rulelist_count+ 1), tot_rulelist = (tot_rulelist+ 1)
           IF (rulelist_count > 5)
            stat = alterlist(reply->slist[tot_slist].assay_list[i].rr_list[z].rule_list,(tot_rulelist
             + 5)), rulelist_count = 1
           ENDIF
           reply->slist[tot_slist].assay_list[i].rr_list[z].rule_list[tot_rulelist].
           ref_range_notify_trig_id = rrnt.ref_range_notify_trig_id, reply->slist[tot_slist].
           assay_list[i].rr_list[z].rule_list[tot_rulelist].trigger_name = rrnt.trigger_name, reply->
           slist[tot_slist].assay_list[i].rr_list[z].rule_list[tot_rulelist].trigger_seq_nbr = rrnt
           .trigger_seq_nbr
          WITH nocounter
         ;end select
         SET stat = alterlist(reply->slist[tot_slist].assay_list[i].rr_list[z].rule_list,tot_rulelist
          )
       ENDFOR
      ENDIF
    ENDFOR
   ENDIF
   DECLARE active_code_value = f8 WITH protect
   DECLARE elist_count = i4 WITH protect
   DECLARE tot_elist = i4 WITH protect
   IF ((request->load.equivalent_info_ind=1))
    SET active_code_value = 0
    SELECT INTO "NL:"
     FROM code_value cv
     WHERE cv.code_set=48
      AND cv.active_ind=1
      AND cv.cdf_meaning="ACTIVE"
     DETAIL
      active_code_value = cv.code_value
     WITH nocounter
    ;end select
    FOR (i = 1 TO tot_alist)
      SET stat = alterlist(reply->slist[tot_slist].assay_list[i].equivalent_assay,5)
      SET elist_count = 0
      SET tot_elist = 0
      SELECT INTO "NL:"
       FROM related_assay ra,
        related_assay ra2,
        discrete_task_assay dta
       PLAN (ra
        WHERE (ra.task_assay_cd=reply->slist[tot_slist].assay_list[i].code_value)
         AND ((ra.active_status_cd=active_code_value) OR (ra.active_status_cd=0
         AND (request->include_inactive_child_ind=1))) )
        JOIN (ra2
        WHERE ra2.related_entity_id=ra.related_entity_id
         AND (ra2.task_assay_cd != reply->slist[tot_slist].assay_list[i].code_value)
         AND ((ra.active_status_cd=active_code_value) OR (ra.active_status_cd=0
         AND (request->include_inactive_child_ind=1))) )
        JOIN (dta
        WHERE dta.active_ind=1
         AND dta.task_assay_cd=ra2.task_assay_cd)
       DETAIL
        elist_count = (elist_count+ 1), tot_elist = (tot_elist+ 1)
        IF (elist_count > 5)
         stat = alterlist(reply->slist[tot_slist].assay_list[i].equivalent_assay,(tot_elist+ 5)),
         elist_count = 1
        ENDIF
        IF (ra2.active_status_cd=active_code_value)
         reply->slist[tot_slist].assay_list[i].equivalent_assay[tot_elist].active_ind = 1
        ELSE
         reply->slist[tot_slist].assay_list[i].equivalent_assay[tot_elist].active_ind = 0
        ENDIF
        reply->slist[tot_slist].assay_list[i].equivalent_assay[tot_elist].code_value = ra2
        .task_assay_cd, reply->slist[tot_slist].assay_list[i].equivalent_assay[tot_elist].display =
        dta.mnemonic
       WITH nocounter
      ;end select
      SET stat = alterlist(reply->slist[tot_slist].assay_list[i].equivalent_assay,tot_elist)
    ENDFOR
   ENDIF
   DECLARE dlist_count = i4
   DECLARE tot_dlist = i4
   IF ((request->load.data_map_ind=1))
    FOR (i = 1 TO tot_alist)
      SET stat = alterlist(reply->slist[tot_slist].assay_list[i].data_map,5)
      SET dlist_count = 0
      SET tot_dlist = 0
      SELECT INTO "NL:"
       FROM data_map dm,
        code_value cv221
       PLAN (dm
        WHERE (dm.task_assay_cd=reply->slist[tot_slist].assay_list[i].code_value)
         AND ((dm.active_ind=1) OR (dm.active_ind=1
         AND (request->include_inactive_child_ind=1))) )
        JOIN (cv221
        WHERE cv221.code_set=outerjoin(221)
         AND cv221.code_value=outerjoin(dm.service_resource_cd))
       DETAIL
        dlist_count = (dlist_count+ 1), tot_dlist = (tot_dlist+ 1)
        IF (dlist_count > 5)
         stat = alterlist(reply->slist[tot_slist].assay_list[i].data_map,(tot_dlist+ 5)), dlist_count
          = 1
        ENDIF
        reply->slist[tot_slist].assay_list[i].data_map[tot_dlist].active_ind = dm.active_ind, reply->
        slist[tot_slist].assay_list[i].data_map[tot_dlist].service_resource_code_value = dm
        .service_resource_cd, reply->slist[tot_slist].assay_list[i].data_map[tot_dlist].
        service_resource_display = cv221.display,
        reply->slist[tot_slist].assay_list[i].data_map[tot_dlist].min_digits = dm.min_digits, reply->
        slist[tot_slist].assay_list[i].data_map[tot_dlist].max_digits = dm.max_digits, reply->slist[
        tot_slist].assay_list[i].data_map[tot_dlist].dec_place = dm.min_decimal_places,
        reply->slist[tot_slist].assay_list[i].data_map[tot_dlist].data_map_type_flag = dm
        .data_map_type_flag
       WITH nocounter
      ;end select
      SET stat = alterlist(reply->slist[tot_slist].assay_list[i].data_map,tot_dlist)
    ENDFOR
   ENDIF
   IF ((request->load.equation_ind=1))
    DECLARE assay_disp = vc
    DECLARE comp_name = vc
    DECLARE equation_disp = vc
    DECLARE ecompcnt = i4 WITH protect, noconstant(0)
    FOR (i = 1 TO tot_alist)
      SET stat = alterlist(reply->slist[tot_slist].assay_list[i].equation,5)
      SET elist_count = 0
      SET tot_elist = 0
      SELECT INTO "nl:"
       FROM equation e,
        equation_component ec
       PLAN (e
        WHERE (e.task_assay_cd=reply->slist[tot_slist].assay_list[i].code_value)
         AND e.active_ind=1)
        JOIN (ec
        WHERE ec.equation_id=e.equation_id)
       ORDER BY e.equation_id, ec.sequence
       HEAD e.equation_id
        ecompcnt = 0, elist_count = (elist_count+ 1), tot_elist = (tot_elist+ 1)
        IF (elist_count > 5)
         stat = alterlist(reply->slist[tot_slist].assay_list[i].equation,(tot_elist+ 5)), elist_count
          = 1
        ENDIF
        reply->slist[tot_slist].assay_list[i].equation[tot_elist].id = e.equation_id, reply->slist[
        tot_slist].assay_list[i].equation[tot_elist].equation_description = e.equation_description,
        reply->slist[tot_slist].assay_list[i].equation[tot_elist].age_from = e.age_from_minutes,
        reply->slist[tot_slist].assay_list[i].equation[tot_elist].age_from_units.code_value = e
        .age_from_units_cd, reply->slist[tot_slist].assay_list[i].equation[tot_elist].age_from_units.
        display = uar_get_code_display(e.age_from_units_cd), reply->slist[tot_slist].assay_list[i].
        equation[tot_elist].age_from_units.mean = uar_get_code_meaning(e.age_from_units_cd),
        reply->slist[tot_slist].assay_list[i].equation[tot_elist].age_to = e.age_to_minutes, reply->
        slist[tot_slist].assay_list[i].equation[tot_elist].age_to_units.code_value = e
        .age_to_units_cd, reply->slist[tot_slist].assay_list[i].equation[tot_elist].age_to_units.
        display = uar_get_code_display(e.age_to_units_cd),
        reply->slist[tot_slist].assay_list[i].equation[tot_elist].age_to_units.mean =
        uar_get_code_meaning(e.age_to_units_cd), reply->slist[tot_slist].assay_list[i].equation[
        tot_elist].sex.code_value = e.sex_cd, reply->slist[tot_slist].assay_list[i].equation[
        tot_elist].sex.display = uar_get_code_display(e.sex_cd),
        reply->slist[tot_slist].assay_list[i].equation[tot_elist].sex.mean = uar_get_code_meaning(e
         .sex_cd), reply->slist[tot_slist].assay_list[i].equation[tot_elist].unknown_age_ind = e
        .unknown_age_ind, reply->slist[tot_slist].assay_list[i].equation[tot_elist].default_ind = e
        .default_ind,
        equation_disp = e.equation_description
       HEAD ec.sequence
        assay_disp = trim(uar_get_code_display(ec.included_assay_cd)), comp_name = trim(ec.name),
        equation_disp = replace(equation_disp,comp_name,assay_disp,2),
        ecompcnt = (ecompcnt+ 1), stat = alterlist(reply->slist[tot_slist].assay_list[i].equation[
         tot_elist].components,ecompcnt), reply->slist[tot_slist].assay_list[i].equation[tot_elist].
        components[ecompcnt].component_name = ec.name,
        reply->slist[tot_slist].assay_list[i].equation[tot_elist].components[ecompcnt].included_assay
        .code_value = ec.included_assay_cd, reply->slist[tot_slist].assay_list[i].equation[tot_elist]
        .components[ecompcnt].included_assay.display = uar_get_code_display(ec.included_assay_cd),
        reply->slist[tot_slist].assay_list[i].equation[tot_elist].components[ecompcnt].included_assay
        .mean = uar_get_code_meaning(ec.included_assay_cd),
        reply->slist[tot_slist].assay_list[i].equation[tot_elist].components[ecompcnt].constant_value
         = ec.constant_value, reply->slist[tot_slist].assay_list[i].equation[tot_elist].components[
        ecompcnt].required_flag = ec.result_req_flag, reply->slist[tot_slist].assay_list[i].equation[
        tot_elist].components[ecompcnt].look_time_direction_flag = ec.look_time_direction_flag,
        reply->slist[tot_slist].assay_list[i].equation[tot_elist].components[ecompcnt].
        time_window_back_minutes = ec.time_window_back_minutes, reply->slist[tot_slist].assay_list[i]
        .equation[tot_elist].components[ecompcnt].time_window_minutes = ec.time_window_minutes, reply
        ->slist[tot_slist].assay_list[i].equation[tot_elist].components[ecompcnt].value_unit.
        code_value = ec.units_cd,
        reply->slist[tot_slist].assay_list[i].equation[tot_elist].components[ecompcnt].value_unit.
        display = uar_get_code_display(ec.units_cd), reply->slist[tot_slist].assay_list[i].equation[
        tot_elist].components[ecompcnt].value_unit.mean = uar_get_code_meaning(ec.units_cd), reply->
        slist[tot_slist].assay_list[i].equation[tot_elist].components[ecompcnt].optional_value = ec
        .default_value
       FOOT  e.equation_id
        reply->slist[tot_slist].assay_list[i].equation[tot_elist].description = equation_disp
       WITH nocounter
      ;end select
      SET stat = alterlist(reply->slist[tot_slist].assay_list[i].equation,tot_elist)
    ENDFOR
   ENDIF
 ENDFOR
 SET stat = alterlist(reply->slist,tot_slist)
 SET scnt = size(reply->slist,5)
 FOR (x = 1 TO scnt)
  SET acnt = size(reply->slist[x].assay_list,5)
  IF (acnt > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(acnt)),
     code_value_event_r r,
     code_value c,
     v500_event_set_explode v
    PLAN (d
     WHERE (reply->slist[x].assay_list[d.seq].event.code_value=0))
     JOIN (r
     WHERE (r.parent_cd=reply->slist[x].assay_list[d.seq].code_value))
     JOIN (c
     WHERE c.code_value=r.event_cd)
     JOIN (v
     WHERE v.event_cd=outerjoin(c.code_value))
    ORDER BY d.seq
    HEAD d.seq
     reply->slist[x].assay_list[d.seq].event.code_value = c.code_value, reply->slist[x].assay_list[d
     .seq].event.display = c.display
     IF (v.event_cd > 0)
      reply->slist[x].assay_list[d.seq].event.es_hier_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(acnt)),
     v500_event_set_explode v
    PLAN (d
     WHERE (reply->slist[x].assay_list[d.seq].general_info.event.code_value > 0))
     JOIN (v
     WHERE (v.event_cd=reply->slist[x].assay_list[d.seq].general_info.event.code_value))
    ORDER BY d.seq
    HEAD d.seq
     reply->slist[x].assay_list[d.seq].event.es_hier_ind = 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(acnt)),
     nomenclature n
    PLAN (d
     WHERE size(trim(reply->slist[x].assay_list[d.seq].general_info.concept.concept_cki)) > 0)
     JOIN (n
     WHERE n.primary_cterm_ind=1
      AND n.active_ind=1
      AND (n.concept_cki=reply->slist[x].assay_list[d.seq].general_info.concept.concept_cki))
    DETAIL
     reply->slist[x].assay_list[d.seq].general_info.concept.concept_name = n.source_string, reply->
     slist[x].assay_list[d.seq].general_info.concept.vocab_cd = n.source_vocabulary_cd, reply->slist[
     x].assay_list[d.seq].general_info.concept.vocab_axis_cd = n.vocab_axis_cd,
     reply->slist[x].assay_list[d.seq].general_info.concept.source_identifier = n.source_identifier
    WITH nocounter
   ;end select
   IF (validate(request->load.dynamic_group_ind))
    IF ((request->load.dynamic_group_ind=1))
     FREE SET rep_groups
     RECORD rep_groups(
       1 assays[*]
         2 ta_code = f8
     )
     DECLARE task_cnt = i4 WITH protect
     DECLARE task_tot_cnt = i4 WITH protect
     DECLARE dcnt = i4 WITH protect
     DECLARE dtcnt = i4 WITH protect
     SET task_cnt = 0
     SELECT INTO "nl:"
      FROM doc_set_ref d1,
       doc_set_section_ref_r d2,
       doc_set_section_ref d3,
       doc_set_element_ref d4
      PLAN (d1
       WHERE d1.doc_set_description IN ("", " ", null)
        AND d1.active_ind=1
        AND d1.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND d1.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
        AND d1.doc_set_ref_id=d1.prev_doc_set_ref_id)
       JOIN (d2
       WHERE d2.doc_set_ref_id=d1.doc_set_ref_id
        AND d2.active_ind=1
        AND d2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND d2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
        AND d2.doc_set_section_ref_r_id=d2.prev_doc_set_section_ref_r_id)
       JOIN (d3
       WHERE d3.doc_set_section_ref_id=d2.doc_set_section_ref_id
        AND d3.active_ind=1
        AND d3.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND d3.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
        AND d3.doc_set_section_ref_id=d3.prev_doc_set_section_ref_id)
       JOIN (d4
       WHERE d4.doc_set_section_ref_id=d3.doc_set_section_ref_id
        AND d4.active_ind=1
        AND d4.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND d4.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
        AND d4.doc_set_element_id=d4.prev_doc_set_element_id
        AND d4.task_assay_cd > 0)
      ORDER BY d4.task_assay_cd
      HEAD REPORT
       task_cnt = 0, task_tot_cnt = 0, stat = alterlist(rep_groups->assays,100)
      HEAD d4.task_assay_cd
       task_cnt = (task_cnt+ 1), task_tot_cnt = (task_tot_cnt+ 1)
       IF (task_tot_cnt > 100)
        stat = alterlist(rep_groups->assays,(task_cnt+ 100)), task_tot_cnt = 1
       ENDIF
       rep_groups->assays[task_cnt].ta_code = d4.task_assay_cd
      FOOT REPORT
       stat = alterlist(rep_groups->assays,task_cnt)
      WITH nocounter
     ;end select
     FOR (a = 1 TO acnt)
       SET num = 0
       SET tindex = 0
       SET tindex = locatevalsort(num,1,task_cnt,reply->slist[x].assay_list[a].code_value,rep_groups
        ->assays[num].ta_code)
       IF (tindex > 0)
        SET reply->slist[x].assay_list[a].dgroup_label_ind = 1
       ENDIF
     ENDFOR
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(acnt)),
       discrete_task_assay dta,
       dynamic_label_template dgt,
       doc_set_ref dsr
      PLAN (d)
       JOIN (dta
       WHERE (dta.task_assay_cd=reply->slist[x].assay_list[d.seq].code_value))
       JOIN (dgt
       WHERE dgt.label_template_id=dta.label_template_id)
       JOIN (dsr
       WHERE dsr.doc_set_ref_id=dgt.doc_set_ref_id
        AND dsr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
        AND dsr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
        AND dsr.active_ind=1)
      ORDER BY d.seq, dsr.doc_set_ref_id
      HEAD d.seq
       dcnt = 0, dtcnt = 0, stat = alterlist(reply->slist[x].assay_list[d.seq].dynamic_groups,10)
      HEAD dsr.doc_set_ref_id
       dcnt = (dcnt+ 1), dtcnt = (dtcnt+ 1)
       IF (dcnt > 10)
        stat = alterlist(reply->slist[x].assay_list[d.seq].dynamic_groups,(dtcnt+ 10)), dcnt = 1
       ENDIF
       reply->slist[x].assay_list[d.seq].dynamic_groups[dtcnt].doc_set_ref_id = dsr.doc_set_ref_id,
       reply->slist[x].assay_list[d.seq].dynamic_groups[dtcnt].description = dsr.doc_set_name
      FOOT  d.seq
       stat = alterlist(reply->slist[x].assay_list[d.seq].dynamic_groups,dtcnt)
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF (validate(request->load.lookback_minutes_ind))
    IF ((request->load.lookback_minutes_ind=1))
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(acnt)),
       dta_offset_min dom,
       code_value cv
      PLAN (d)
       JOIN (dom
       WHERE (dom.task_assay_cd=reply->slist[x].assay_list[d.seq].code_value)
        AND dom.active_ind=1)
       JOIN (cv
       WHERE cv.code_value=dom.offset_min_type_cd
        AND cv.active_ind=1)
      ORDER BY d.seq
      HEAD d.seq
       dcnt = 0
      DETAIL
       dcnt = (dcnt+ 1), stat = alterlist(reply->slist[x].assay_list[d.seq].lookback_minutes,dcnt),
       reply->slist[x].assay_list[d.seq].lookback_minutes[dcnt].type_code_value = dom
       .offset_min_type_cd,
       reply->slist[x].assay_list[d.seq].lookback_minutes[dcnt].type_display = cv.display, reply->
       slist[x].assay_list[d.seq].lookback_minutes[dcnt].type_mean = cv.cdf_meaning, reply->slist[x].
       assay_list[d.seq].lookback_minutes[dcnt].minutes_nbr = dom.offset_min_nbr
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF (validate(request->load.interpretations_ind))
    IF ((request->load.interpretations_ind=1))
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(acnt)),
       dcp_interp di
      PLAN (d)
       JOIN (di
       WHERE (di.task_assay_cd=reply->slist[x].assay_list[d.seq].code_value))
      ORDER BY d.seq
      HEAD d.seq
       reply->slist[x].assay_list[d.seq].interpretations_ind = 1
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(acnt)),
     code_value_extension cve
    PLAN (d)
     JOIN (cve
     WHERE (cve.code_value=reply->slist[x].assay_list[d.seq].code_value)
      AND cve.field_name="dta_witness_required_ind")
    DETAIL
     IF (cve.field_value="1")
      reply->slist[x].assay_list[d.seq].witness_required_ind = 1
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ENDFOR
#enditnow
 IF (tot_slist > 0)
  SET reply->status_data.status = "S"
 ELSE
  IF ((((request->search_by=1)) OR ((request->search_by=2))) )
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
 CALL echorecord(reply)
 CALL echo(name_parse)
END GO
