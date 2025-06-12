CREATE PROGRAM ctp_bed_mu_filter_copy_imp:dba
 DECLARE err_msg = vc WITH protect, noconstant(" ")
 DECLARE err_code = i4 WITH protect, noconstant(0)
 SET err_code = error(err_msg,1)
 RECORD build(
   1 filter_qual[*]
     2 err_ind = i2
     2 from_topic = vc
     2 from_topic_id = f8
     2 from_report = vc
     2 from_report_id = f8
     2 from_filter = vc
     2 from_filter_id = f8
     2 from_filter_cat_mean = vc
     2 from_value[*]
       3 parent_entity_name = vc
       3 parent_entity_id = f8
       3 value_dt_tm = dq8
       3 freetext_desc = vc
       3 qualifier_flag = i2
       3 value_seq = i4
       3 value_type_flag = i2
       3 group_seq = i4
       3 mpage_param_mean = vc
       3 mpage_param_value = vc
       3 parent_entity_name2 = vc
       3 parent_entity_id2 = f8
       3 map_data_type_cd = f8
       3 map_data_type_meaning = vc
       3 map_data_type_display = vc
     2 to_topic = vc
     2 to_topic_id = f8
     2 to_report = vc
     2 to_report_id = f8
     2 to_filter = vc
     2 to_filter_id = f8
     2 to_filter_cat_mean = vc
 ) WITH protect
 RECORD uniq_fltr_bld(
   1 filter_qual[*]
     2 err_ind = i2
     2 to_topic_id = f8
     2 to_report_id = f8
     2 to_filter_id = f8
     2 to_filter_cat_mean = vc
     2 add_value[*]
       3 parent_entity_name = vc
       3 parent_entity_id = f8
       3 freetext_desc = vc
       3 qualifier_flag = i2
       3 value_seq = i4
       3 value_type_flag = i2
       3 group_seq = i4
       3 mpage_param_mean = vc
       3 mpage_param_value = vc
       3 parent_entity_name2 = vc
       3 parent_entity_id2 = f8
       3 map_data_type_cd = f8
     2 excl_value[*]
       3 parent_entity_id = f8
       3 parent_entity_id2 = f8
 ) WITH protect
 RECORD IMPORT::log(
   1 layout_error = i2
   1 cnt = i4
   1 list[*]
     2 full_msg = vc
     2 msg_cnt = i4
     2 msg[*]
       3 txt = vc
     2 skip_ind = i2
     2 commit_success_ind = i2
 ) WITH protect
 DECLARE IMPORT::errormsg(index=i4,message=vc) = null WITH protect
 DECLARE IMPORT::rep_errormsg(index=i4,message=vc,success_ind=i1,success_msg_ind=i1,skip_ind=i1) =
 null WITH protect
 DECLARE IMPORT::cclerrorcheck(index=i4,rep_ind=i1) = i2 WITH protect
 DECLARE IMPORT::get_ref_data(null) = null WITH protect
 DECLARE IMPORT::get_bdr_filters(index=i4,to_from_flag=i2) = null WITH privateprotect
 DECLARE IMPORT::copy_bdr_filter(index=i4) = null WITH privateprotect
 DECLARE requestin_size = i4 WITH protect, constant(size(requestin->list_0,5))
 DECLARE csv_row = i4 WITH protect, noconstant(0)
 DECLARE IMPORT::err_msg = vc WITH protect, noconstant(" ")
 DECLARE IMPORT::cnt = i4 WITH protect, noconstant(0)
 DECLARE IMPORT::i = i4 WITH protect, noconstant(0)
 DECLARE IMPORT::pos = i4 WITH protect, noconstant(0)
 DECLARE IMPORT::debug_on = i2 WITH protect, noconstant(0)
 DECLARE msg = vc
 DECLARE rm_loc_cpoe = vc WITH protect, constant("LOCATIONS FOR CPOE")
 DECLARE rm_loc_cpoe_meds = vc WITH protect, constant("LAB/RAD UNITS FOR CPOE MEDS")
 DECLARE rm_loc_cpoe_lab = vc WITH protect, constant("LAB/RAD UNITS FOR CPOE LABS")
 DECLARE rm_loc_cpoe_rad = vc WITH protect, constant("LAB/RAD UNITS FOR CPOE RAD")
 DECLARE mu3_exloc_cpoe_meds = vc WITH protect, constant(
  "EXCLUDED AMBULATORY UNITS - CPOE MEDS (EP MEASURES ONLY)")
 DECLARE mu3_exloc_cpoe_lab = vc WITH protect, constant(
  "EXCLUDED AMBULATORY UNITS - CPOE LAB (EP MEASURES ONLY)")
 DECLARE mu3_exloc_cpoe_rad = vc WITH protect, constant(
  "EXCLUDED AMBULATORY UNITS - CPOE RAD (EP MEASURES ONLY)")
 DECLARE look_ndx = i4 WITH protect, noconstant(0)
 DECLARE topic_pos = i4 WITH protect, noconstant(0)
 DECLARE report_pos = i4 WITH protect, noconstant(0)
 DECLARE filter_pos = i4 WITH protect, noconstant(0)
 DECLARE filter_cnt = i4 WITH protect, noconstant(0)
 IF (validate(ctp_bed_mu_filter_copy_import_debug))
  SET IMPORT::debug_on = true
  SET dm_dbi_parent_commit_ind = true
 ENDIF
 SET stat = alterlist(import::log->list,requestin_size)
 SET stat = alterlist(build->filter_qual,requestin_size)
 IF (validate(requestin->list_0[1].eol))
  FOR (csv_row = 1 TO requestin_size)
    IF (trim(requestin->list_0[csv_row].eol,3) != "EOL")
     CALL IMPORT::errormsg(csv_row,"Missing end of line marker")
     SET import::log->layout_error = true
    ENDIF
  ENDFOR
 ELSE
  CALL IMPORT::errormsg(1,"Missing end of line column")
  SET import::log->layout_error = true
 ENDIF
 IF ((import::log->layout_error=true))
  GO TO log_file
 ENDIF
 SET err_code = error(err_msg,0)
 IF (err_code != 0)
  CALL cclexception(err_code,"E",err_msg)
  GO TO exit_script
 ENDIF
 CALL IMPORT::get_ref_data(null)
 SET err_code = error(err_msg,0)
 IF (err_code != 0)
  CALL cclexception(err_code,"E",err_msg)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(requestin_size))
  PLAN (d)
  DETAIL
   IF (textlen(trim(requestin->list_0[d.seq].topicfrom,3))=0)
    build->filter_qual[d.seq].err_ind = 1,
    CALL IMPORT::errormsg(d.seq,build("ERROR Topic From is blank"))
   ENDIF
   IF (textlen(trim(requestin->list_0[d.seq].reportfrom,3))=0)
    build->filter_qual[d.seq].err_ind = 1,
    CALL IMPORT::errormsg(d.seq,build("ERROR Report From is blank"))
   ENDIF
   IF (textlen(trim(requestin->list_0[d.seq].filterfrom,3))=0)
    build->filter_qual[d.seq].err_ind = 1,
    CALL IMPORT::errormsg(d.seq,build("ERROR Filter From is blank"))
   ENDIF
   IF (textlen(trim(requestin->list_0[d.seq].topicto,3))=0)
    build->filter_qual[d.seq].err_ind = 1,
    CALL IMPORT::errormsg(d.seq,build("ERROR Topic To is blank"))
   ENDIF
   IF (textlen(trim(requestin->list_0[d.seq].reportto,3))=0)
    build->filter_qual[d.seq].err_ind = 1,
    CALL IMPORT::errormsg(d.seq,build("ERROR Report To is blank"))
   ENDIF
   IF (textlen(trim(requestin->list_0[d.seq].filterto,3))=0)
    build->filter_qual[d.seq].err_ind = 1,
    CALL IMPORT::errormsg(d.seq,build("ERROR Filter To is blank"))
   ENDIF
   topic_pos = locateval(look_ndx,1,size(import_ref_data->cat_qual,5),cnvtupper(trim(requestin->
      list_0[d.seq].topicfrom,3)),cnvtupper(import_ref_data->cat_qual[look_ndx].cat_name))
   IF (topic_pos > 0)
    build->filter_qual[d.seq].from_topic_id = import_ref_data->cat_qual[topic_pos].br_cat_id, build->
    filter_qual[d.seq].from_topic = trim(import_ref_data->cat_qual[topic_pos].cat_name,3), report_pos
     = locateval(look_ndx,1,size(import_ref_data->cat_qual[topic_pos].report_qual,5),cnvtupper(trim(
       requestin->list_0[d.seq].reportfrom,3)),cnvtupper(import_ref_data->cat_qual[topic_pos].
      report_qual[look_ndx].report_name))
    IF (report_pos > 0)
     build->filter_qual[d.seq].from_report_id = import_ref_data->cat_qual[topic_pos].report_qual[
     report_pos].br_report_id, build->filter_qual[d.seq].from_report = trim(import_ref_data->
      cat_qual[topic_pos].report_qual[report_pos].report_name,3), filter_pos = locateval(look_ndx,1,
      size(import_ref_data->cat_qual[topic_pos].report_qual[report_pos].filter,5),cnvtupper(trim(
        requestin->list_0[d.seq].filterfrom,3)),cnvtupper(import_ref_data->cat_qual[topic_pos].
       report_qual[report_pos].filter[look_ndx].filter_disp))
     IF (filter_pos > 0)
      build->filter_qual[d.seq].from_filter_id = import_ref_data->cat_qual[topic_pos].report_qual[
      report_pos].filter[filter_pos].br_filter_id, build->filter_qual[d.seq].from_filter = trim(
       import_ref_data->cat_qual[topic_pos].report_qual[report_pos].filter[filter_pos].filter_disp,3),
      build->filter_qual[d.seq].from_filter_cat_mean = import_ref_data->cat_qual[topic_pos].
      report_qual[report_pos].filter[filter_pos].filter_cat_mean
      IF ((import_ref_data->cat_qual[topic_pos].report_qual[report_pos].filter[filter_pos].
      filter_defined=0))
       build->filter_qual[d.seq].err_ind = 1,
       CALL IMPORT::errormsg(d.seq,build("ERROR Filter From has no values defined"))
      ENDIF
     ELSE
      build->filter_qual[d.seq].err_ind = 1,
      CALL IMPORT::errormsg(d.seq,build("ERROR Filter From is not valid for this Topic/Report"))
     ENDIF
    ELSE
     build->filter_qual[d.seq].err_ind = 1,
     CALL IMPORT::errormsg(d.seq,build("ERROR Report From is not a valid Report for this Topic"))
    ENDIF
   ELSE
    build->filter_qual[d.seq].err_ind = 1,
    CALL IMPORT::errormsg(d.seq,build("ERROR Topic From is not a valid Topic"))
   ENDIF
   topic_pos = locateval(look_ndx,1,size(import_ref_data->cat_qual,5),cnvtupper(trim(requestin->
      list_0[d.seq].topicto,3)),cnvtupper(import_ref_data->cat_qual[look_ndx].cat_name))
   IF (topic_pos > 0)
    build->filter_qual[d.seq].to_topic_id = import_ref_data->cat_qual[topic_pos].br_cat_id, build->
    filter_qual[d.seq].to_topic = trim(import_ref_data->cat_qual[topic_pos].cat_name,3), report_pos
     = locateval(look_ndx,1,size(import_ref_data->cat_qual[topic_pos].report_qual,5),cnvtupper(trim(
       requestin->list_0[d.seq].reportto,3)),cnvtupper(import_ref_data->cat_qual[topic_pos].
      report_qual[look_ndx].report_name))
    IF (report_pos > 0)
     build->filter_qual[d.seq].to_report_id = import_ref_data->cat_qual[topic_pos].report_qual[
     report_pos].br_report_id, build->filter_qual[d.seq].to_report = trim(import_ref_data->cat_qual[
      topic_pos].report_qual[report_pos].report_name,3), filter_pos = locateval(look_ndx,1,size(
       import_ref_data->cat_qual[topic_pos].report_qual[report_pos].filter,5),cnvtupper(trim(
        requestin->list_0[d.seq].filterto,3)),cnvtupper(import_ref_data->cat_qual[topic_pos].
       report_qual[report_pos].filter[look_ndx].filter_disp))
     IF (filter_pos > 0)
      build->filter_qual[d.seq].to_filter_id = import_ref_data->cat_qual[topic_pos].report_qual[
      report_pos].filter[filter_pos].br_filter_id, build->filter_qual[d.seq].to_filter = trim(
       import_ref_data->cat_qual[topic_pos].report_qual[report_pos].filter[filter_pos].filter_disp,3),
      build->filter_qual[d.seq].to_filter_cat_mean = import_ref_data->cat_qual[topic_pos].
      report_qual[report_pos].filter[filter_pos].filter_cat_mean
     ELSE
      build->filter_qual[d.seq].err_ind = 1,
      CALL IMPORT::errormsg(d.seq,build("ERROR Filter To is not valid for this Topic/Report"))
     ENDIF
    ELSE
     build->filter_qual[d.seq].err_ind = 1,
     CALL IMPORT::errormsg(d.seq,build("ERROR Report To is not a valid Report for this Topic"))
    ENDIF
   ELSE
    build->filter_qual[d.seq].err_ind = 1,
    CALL IMPORT::errormsg(d.seq,build("ERROR Topic To is not a valid Topic"))
   ENDIF
   IF ((build->filter_qual[d.seq].to_filter_id > 0)
    AND (build->filter_qual[d.seq].from_filter_id > 0))
    IF (cnvtupper(build->filter_qual[d.seq].to_filter) IN (mu3_exloc_cpoe_meds, mu3_exloc_cpoe_lab,
    mu3_exloc_cpoe_rad)
     AND cnvtupper(build->filter_qual[d.seq].from_filter) IN (rm_loc_cpoe_meds, rm_loc_cpoe_lab,
    rm_loc_cpoe_rad))
     dummy_temp = ""
    ELSE
     IF ((build->filter_qual[d.seq].to_filter_cat_mean != build->filter_qual[d.seq].
     from_filter_cat_mean))
      build->filter_qual[d.seq].err_ind = 1,
      CALL IMPORT::errormsg(d.seq,build(
       "ERROR Filter Category Mean does not match for Filter From and Filter To"))
     ENDIF
    ENDIF
    IF ((build->filter_qual[d.seq].from_topic_id=build->filter_qual[d.seq].to_topic_id)
     AND (build->filter_qual[d.seq].from_report_id=build->filter_qual[d.seq].to_report_id)
     AND (build->filter_qual[d.seq].from_filter_id=build->filter_qual[d.seq].to_filter_id))
     build->filter_qual[d.seq].err_ind = 1,
     CALL IMPORT::errormsg(d.seq,build("ERROR Filter can not be copied to itself"))
    ENDIF
   ENDIF
   filter_pos = locateval(look_ndx,1,size(build->filter_qual,5),build->filter_qual[d.seq].
    from_topic_id,build->filter_qual[look_ndx].from_topic_id,
    build->filter_qual[d.seq].from_report_id,build->filter_qual[look_ndx].from_report_id,build->
    filter_qual[d.seq].from_filter_id,build->filter_qual[look_ndx].from_filter_id,build->filter_qual[
    d.seq].to_topic_id,
    build->filter_qual[look_ndx].to_topic_id,build->filter_qual[d.seq].to_report_id,build->
    filter_qual[look_ndx].to_report_id,build->filter_qual[d.seq].to_filter_id,build->filter_qual[
    look_ndx].to_filter_id)
   IF (filter_pos > 0
    AND filter_pos != d.seq)
    build->filter_qual[d.seq].err_ind = 1,
    CALL IMPORT::errormsg(d.seq,build("ERROR Duplicate From/To Filter to Copy"))
   ENDIF
  WITH nocounter
 ;end select
 SET filter_cnt = 0
 FOR (fltr_cnt = 1 TO size(build->filter_qual,5))
   SET excl_cnt = 0
   SET add_cnt = 0
   IF ((build->filter_qual[fltr_cnt].err_ind != 1))
    CALL IMPORT::get_bdr_filters(fltr_cnt,1)
    SET filter_pos = locateval(look_ndx,1,size(uniq_fltr_bld->filter_qual,5),build->filter_qual[
     fltr_cnt].to_topic_id,uniq_fltr_bld->filter_qual[look_ndx].to_topic_id,
     build->filter_qual[fltr_cnt].to_filter_id,uniq_fltr_bld->filter_qual[look_ndx].to_filter_id)
    IF (filter_pos=0)
     SET filter_cnt = (filter_cnt+ 1)
     IF (mod(filter_cnt,10)=1)
      SET stat = alterlist(uniq_fltr_bld->filter_qual,(filter_cnt+ 9))
     ENDIF
     SET uniq_fltr_bld->filter_qual[filter_cnt].to_topic_id = build->filter_qual[fltr_cnt].
     to_topic_id
     SET uniq_fltr_bld->filter_qual[filter_cnt].to_filter_id = build->filter_qual[fltr_cnt].
     to_filter_id
     SET uniq_fltr_bld->filter_qual[filter_cnt].to_filter_cat_mean = build->filter_qual[fltr_cnt].
     to_filter_cat_mean
     IF (cnvtupper(build->filter_qual[fltr_cnt].to_filter) IN (mu3_exloc_cpoe_meds,
     mu3_exloc_cpoe_lab, mu3_exloc_cpoe_rad)
      AND cnvtupper(build->filter_qual[fltr_cnt].from_filter) IN (rm_loc_cpoe, rm_loc_cpoe_meds,
     rm_loc_cpoe_lab, rm_loc_cpoe_rad))
      SET stat = alterlist(uniq_fltr_bld->filter_qual[filter_cnt].excl_value,size(build->filter_qual[
        fltr_cnt].from_value,5))
     ELSE
      SET stat = alterlist(uniq_fltr_bld->filter_qual[filter_cnt].add_value,size(build->filter_qual[
        fltr_cnt].from_value,5))
     ENDIF
     FOR (fltr_i = 1 TO size(build->filter_qual[fltr_cnt].from_value,5))
       IF (cnvtupper(build->filter_qual[fltr_cnt].from_filter) IN (rm_loc_cpoe, rm_loc_cpoe_meds,
       rm_loc_cpoe_lab, rm_loc_cpoe_rad))
        SET uniq_fltr_bld->filter_qual[filter_cnt].excl_value[fltr_i].parent_entity_id = build->
        filter_qual[fltr_cnt].from_value[fltr_i].parent_entity_id
        SET uniq_fltr_bld->filter_qual[filter_cnt].excl_value[fltr_i].parent_entity_id2 = build->
        filter_qual[fltr_cnt].from_value[fltr_i].parent_entity_id2
       ELSE
        SET stat = alterlist(uniq_fltr_bld->filter_qual[filter_cnt].add_value,size(build->
          filter_qual[fltr_cnt].from_value,5))
        SET uniq_fltr_bld->filter_qual[filter_cnt].add_value[fltr_i].freetext_desc = build->
        filter_qual[fltr_cnt].from_value[fltr_i].freetext_desc
        SET uniq_fltr_bld->filter_qual[filter_cnt].add_value[fltr_i].group_seq = build->filter_qual[
        fltr_cnt].from_value[fltr_i].group_seq
        SET uniq_fltr_bld->filter_qual[filter_cnt].add_value[fltr_i].map_data_type_cd = build->
        filter_qual[fltr_cnt].from_value[fltr_i].map_data_type_cd
        SET uniq_fltr_bld->filter_qual[filter_cnt].add_value[fltr_i].mpage_param_mean = build->
        filter_qual[fltr_cnt].from_value[fltr_i].mpage_param_mean
        SET uniq_fltr_bld->filter_qual[filter_cnt].add_value[fltr_i].mpage_param_value = build->
        filter_qual[fltr_cnt].from_value[fltr_i].mpage_param_value
        SET uniq_fltr_bld->filter_qual[filter_cnt].add_value[fltr_i].parent_entity_id = build->
        filter_qual[fltr_cnt].from_value[fltr_i].parent_entity_id
        SET uniq_fltr_bld->filter_qual[filter_cnt].add_value[fltr_i].parent_entity_id2 = build->
        filter_qual[fltr_cnt].from_value[fltr_i].parent_entity_id2
        SET uniq_fltr_bld->filter_qual[filter_cnt].add_value[fltr_i].parent_entity_name = build->
        filter_qual[fltr_cnt].from_value[fltr_i].parent_entity_name
        SET uniq_fltr_bld->filter_qual[filter_cnt].add_value[fltr_i].parent_entity_name2 = build->
        filter_qual[fltr_cnt].from_value[fltr_i].parent_entity_name2
        SET uniq_fltr_bld->filter_qual[filter_cnt].add_value[fltr_i].qualifier_flag = build->
        filter_qual[fltr_cnt].from_value[fltr_i].qualifier_flag
        SET uniq_fltr_bld->filter_qual[filter_cnt].add_value[fltr_i].value_seq = build->filter_qual[
        fltr_cnt].from_value[fltr_i].value_seq
        SET uniq_fltr_bld->filter_qual[filter_cnt].add_value[fltr_i].value_type_flag = build->
        filter_qual[fltr_cnt].from_value[fltr_i].value_type_flag
       ENDIF
     ENDFOR
    ELSE
     SET excl_cnt = size(uniq_fltr_bld->filter_qual[filter_pos].excl_value,5)
     SET add_cnt = size(uniq_fltr_bld->filter_qual[filter_pos].add_value,5)
     FOR (fltr_i = 1 TO size(build->filter_qual[fltr_cnt].from_value,5))
       IF (cnvtupper(build->filter_qual[fltr_cnt].to_filter) IN (mu3_exloc_cpoe_meds,
       mu3_exloc_cpoe_lab, mu3_exloc_cpoe_rad)
        AND cnvtupper(build->filter_qual[fltr_cnt].from_filter) IN (rm_loc_cpoe, rm_loc_cpoe_meds,
       rm_loc_cpoe_lab, rm_loc_cpoe_rad))
        SET excl_pos = locateval(look_ndx,1,size(uniq_fltr_bld->filter_qual[filter_pos].excl_value,5),
         build->filter_qual[fltr_cnt].from_value[fltr_i].parent_entity_id,uniq_fltr_bld->filter_qual[
         filter_pos].excl_value[look_ndx].parent_entity_id,
         build->filter_qual[fltr_cnt].from_value[fltr_i].parent_entity_id2,uniq_fltr_bld->
         filter_qual[filter_pos].excl_value[look_ndx].parent_entity_id2)
        IF (excl_pos=0)
         SET excl_cnt = (excl_cnt+ 1)
         SET stat = alterlist(uniq_fltr_bld->filter_qual[filter_pos].excl_value,excl_cnt)
         SET uniq_fltr_bld->filter_qual[filter_pos].excl_value[excl_cnt].parent_entity_id = build->
         filter_qual[fltr_cnt].from_value[fltr_i].parent_entity_id
         SET uniq_fltr_bld->filter_qual[filter_pos].excl_value[excl_cnt].parent_entity_id2 = build->
         filter_qual[fltr_cnt].from_value[fltr_i].parent_entity_id2
        ENDIF
       ELSE
        SET add_pos = locateval(look_ndx,1,size(uniq_fltr_bld->filter_qual[filter_pos].add_value,5),
         build->filter_qual[fltr_cnt].from_value[fltr_i].parent_entity_id,uniq_fltr_bld->filter_qual[
         filter_pos].add_value[look_ndx].parent_entity_id,
         build->filter_qual[fltr_cnt].from_value[fltr_i].parent_entity_id2,uniq_fltr_bld->
         filter_qual[filter_pos].add_value[look_ndx].parent_entity_id2)
        IF (add_pos=0)
         SET add_cnt = (add_cnt+ 1)
         SET stat = alterlist(uniq_fltr_bld->filter_qual[filter_pos].add_value,add_cnt)
         SET uniq_fltr_bld->filter_qual[filter_pos].add_value[add_cnt].freetext_desc = build->
         filter_qual[fltr_cnt].from_value[fltr_i].freetext_desc
         SET uniq_fltr_bld->filter_qual[filter_pos].add_value[add_cnt].group_seq = build->
         filter_qual[fltr_cnt].from_value[fltr_i].group_seq
         SET uniq_fltr_bld->filter_qual[filter_pos].add_value[add_cnt].map_data_type_cd = build->
         filter_qual[fltr_cnt].from_value[fltr_i].map_data_type_cd
         SET uniq_fltr_bld->filter_qual[filter_pos].add_value[add_cnt].mpage_param_mean = build->
         filter_qual[fltr_cnt].from_value[fltr_i].mpage_param_mean
         SET uniq_fltr_bld->filter_qual[filter_pos].add_value[add_cnt].mpage_param_value = build->
         filter_qual[fltr_cnt].from_value[fltr_i].mpage_param_value
         SET uniq_fltr_bld->filter_qual[filter_pos].add_value[add_cnt].parent_entity_id = build->
         filter_qual[fltr_cnt].from_value[fltr_i].parent_entity_id
         SET uniq_fltr_bld->filter_qual[filter_pos].add_value[add_cnt].parent_entity_id2 = build->
         filter_qual[fltr_cnt].from_value[fltr_i].parent_entity_id2
         SET uniq_fltr_bld->filter_qual[filter_pos].add_value[add_cnt].parent_entity_name = build->
         filter_qual[fltr_cnt].from_value[fltr_i].parent_entity_name
         SET uniq_fltr_bld->filter_qual[filter_pos].add_value[add_cnt].parent_entity_name2 = build->
         filter_qual[fltr_cnt].from_value[fltr_i].parent_entity_name2
         SET uniq_fltr_bld->filter_qual[filter_pos].add_value[add_cnt].qualifier_flag = build->
         filter_qual[fltr_cnt].from_value[fltr_i].qualifier_flag
         SET uniq_fltr_bld->filter_qual[filter_pos].add_value[add_cnt].value_seq = build->
         filter_qual[fltr_cnt].from_value[fltr_i].value_seq
         SET uniq_fltr_bld->filter_qual[filter_pos].add_value[add_cnt].value_type_flag = build->
         filter_qual[fltr_cnt].from_value[fltr_i].value_type_flag
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
 ENDFOR
 SET stat = alterlist(uniq_fltr_bld->filter_qual,filter_cnt)
 IF (IMPORT::debug_on)
  CALL echorecord(build)
  CALL echorecord(uniq_fltr_bld)
 ENDIF
 CALL echo(">>>Beginning upload...")
 FOR (upld_cnt = 1 TO size(uniq_fltr_bld->filter_qual,5))
  SET msg = " "
  IF ((uniq_fltr_bld->filter_qual[upld_cnt].err_ind != 1))
   IF (size(uniq_fltr_bld->filter_qual[upld_cnt].add_value,5) > 0)
    CALL IMPORT::copy_bdr_filters(upld_cnt)
    IF ((uniq_fltr_bld->filter_qual[upld_cnt].err_ind=1))
     CALL IMPORT::rep_errormsg(upld_cnt,msg,false,false,false)
    ENDIF
   ELSE
    SET uniq_fltr_bld->filter_qual[upld_cnt].err_ind = 1
    CALL IMPORT::rep_errormsg(upld_cnt,"No Values defined for this Filter",false,false,true)
   ENDIF
   IF ((uniq_fltr_bld->filter_qual[upld_cnt].err_ind != 1))
    CALL IMPORT::rep_errormsg(upld_cnt," ",true,false,false)
    IF (IMPORT::debug_on)
     CALL echo(build("!!!Debug On(Commit):",upld_cnt))
    ELSE
     COMMIT
     CALL echo(build("+++Commit Performed:",upld_cnt))
    ENDIF
   ELSE
    IF (IMPORT::debug_on)
     CALL echo(build("!!!Debug On(Rollback):",upld_cnt))
    ELSE
     ROLLBACK
     CALL echo(build("---Rollback Performed:",upld_cnt))
    ENDIF
   ENDIF
  ENDIF
 ENDFOR
 IF (IMPORT::debug_on)
  CALL echorecord(IMPORT::log)
 ENDIF
#log_file
 CALL echo(">>>BEGIN LOG FILE")
 FOR (csv_row = 1 TO requestin_size)
  SET run::import->rows_processed = (run::import->rows_processed+ 1)
  IF ((import::log->list[csv_row].msg_cnt > 0))
   SET run::import->rows_with_errors = (run::import->rows_with_errors+ 1)
   FOR (index = 1 TO import::log->list[csv_row].msg_cnt)
     IF (index=1)
      SET import::log->list[csv_row].full_msg = import::log->list[csv_row].msg[index].txt
     ELSE
      SET import::log->list[csv_row].full_msg = build(import::log->list[csv_row].full_msg,"|",
       import::log->list[csv_row].msg[index].txt)
     ENDIF
   ENDFOR
  ELSEIF ((import::log->layout_error=true))
   SET import::log->list[csv_row].full_msg = " "
  ELSEIF ((import::log->list[csv_row].skip_ind=true))
   IF (textlen(trim(import::log->list[csv_row].full_msg))=0)
    SET import::log->list[csv_row].full_msg = "Skipped"
   ELSE
    SET import::log->list[csv_row].full_msg = build("Skipped|",import::log->list[csv_row].full_msg)
   ENDIF
  ELSEIF ((import::log->list[csv_row].commit_success_ind=true))
   IF (size(trim(import::log->list[csv_row].full_msg))=0)
    SET import::log->list[csv_row].full_msg = "Success"
   ELSE
    SET import::log->list[csv_row].full_msg = build("Success|",import::log->list[csv_row].full_msg)
   ENDIF
  ELSE
   SET import::log->list[csv_row].full_msg = "Skipped due to unexpected error"
  ENDIF
 ENDFOR
 SELECT
  IF (findfile(build(run::import->logical,run::import->log_file)))
   WITH format, format = stream, pcformat('"',",",1),
    noheading, append
  ELSE
   WITH format, format = stream, pcformat('"',",",1),
    heading
  ENDIF
  INTO value(build(run::import->logical,run::import->log_file))
  topic_from = substring(1,250,trim(requestin->list_0[d.seq].topicfrom)), report_from = substring(1,
   250,trim(requestin->list_0[d.seq].reportfrom)), filter_from = substring(1,250,trim(requestin->
    list_0[d.seq].filterfrom)),
  topic_to = substring(1,250,trim(requestin->list_0[d.seq].topicto)), report_to = substring(1,250,
   trim(requestin->list_0[d.seq].reportto)), filter_to = substring(1,250,trim(requestin->list_0[d.seq
    ].filterto)),
  build_status = substring(1,500,import::log->list[d.seq].full_msg)
  FROM (dummyt d  WITH seq = value(requestin_size))
  PLAN (d)
  WITH nocounter
 ;end select
 SUBROUTINE IMPORT::errormsg(index,message)
   DECLARE msg_cnt = i4 WITH protect, noconstant(import::log->list[index].msg_cnt)
   SET msg_cnt = (msg_cnt+ 1)
   SET stat = alterlist(import::log->list[index].msg,msg_cnt)
   SET import::log->list[index].msg[msg_cnt].txt = check(message)
   SET import::log->list[index].msg_cnt = msg_cnt
 END ;Subroutine
 SUBROUTINE IMPORT::rep_errormsg(index,message,success_ind,success_msg_ind,skip_ind)
   DECLARE IMPORT::index = i4 WITH protect, constant(index)
   DECLARE fltr_err_pos = i4 WITH protect, noconstant(0)
   SET fltr_err_pos = locateval(look_ndx,1,size(build->filter_qual,5),uniq_fltr_bld->filter_qual[
    IMPORT::index].to_topic_id,build->filter_qual[look_ndx].to_topic_id,
    uniq_fltr_bld->filter_qual[IMPORT::index].to_filter_id,build->filter_qual[look_ndx].to_filter_id)
   WHILE (fltr_err_pos > 0)
    IF ((import::log->list[fltr_err_pos].msg_cnt=0))
     IF (success_ind=true)
      SET import::log->list[fltr_err_pos].commit_success_ind = true
     ELSEIF (success_msg_ind=true)
      SET import::log->list[fltr_err_pos].full_msg = build(import::log->list[fltr_err_pos].full_msg,
       message,"| ")
     ELSEIF (skip_ind=true)
      SET import::log->list[fltr_err_pos].skip_ind = 1
      IF (textlen(trim(message,3)) > 0)
       SET import::log->list[fltr_err_pos].full_msg = build(import::log->list[fltr_err_pos].full_msg,
        message,"| ")
      ENDIF
     ELSE
      CALL IMPORT::errormsg(fltr_err_pos,message)
     ENDIF
    ENDIF
    SET fltr_err_pos = locateval(look_ndx,(fltr_err_pos+ 1),size(build->filter_qual,5),uniq_fltr_bld
     ->filter_qual[IMPORT::index].to_topic_id,build->filter_qual[look_ndx].to_topic_id,
     uniq_fltr_bld->filter_qual[IMPORT::index].to_filter_id,build->filter_qual[look_ndx].to_filter_id
     )
   ENDWHILE
 END ;Subroutine
 SUBROUTINE IMPORT::cclerrorcheck(index,rep_ind)
   DECLARE err_msg = vc WITH protect, noconstant(" ")
   DECLARE cnt = i4 WITH protect, noconstant(0)
   SET stat = error(err_msg,0)
   IF (stat > 0)
    SET cnt = (cnt+ 1)
    IF (rep_ind=true)
     CALL IMPORT::rep_errormsg(index,err_msg,false,false,false)
    ELSE
     CALL IMPORT::errormsg(index,err_msg)
    ENDIF
    WHILE (stat != 0
     AND cnt <= 10)
      SET stat = error(err_msg,0)
      IF (stat != 0)
       IF (rep_ind=true)
        CALL IMPORT::rep_errormsg(index,err_msg,false,false,false)
       ELSE
        CALL IMPORT::errormsg(index,err_msg)
       ENDIF
      ENDIF
      SET cnt = (cnt+ 1)
    ENDWHILE
   ENDIF
   IF (cnt=0)
    RETURN(false)
   ELSE
    RETURN(true)
   ENDIF
 END ;Subroutine
 SUBROUTINE IMPORT::get_ref_data(null)
   DECLARE temp_fnd = vc WITH protect
   RECORD import_ref_data(
     1 cat_qual[*]
       2 br_cat_id = f8
       2 cat_name = vc
       2 cat_mean = vc
       2 report_qual[*]
         3 br_report_id = f8
         3 report_name = vc
         3 report_mean = vc
         3 report_seq = i4
         3 filter[*]
           4 br_filter_id = f8
           4 filter_mean = vc
           4 filter_disp = vc
           4 filter_seq = i4
           4 filter_cat_mean = vc
           4 filter_defined = i2
           4 filter_category_type_mean = vc
           4 codeset = i4
   ) WITH persistscript
   RECORD dm_cat_req(
     1 category_type_flag = i2
   ) WITH protect
   RECORD dm_cat_reply(
     1 category[*]
       2 br_datamart_category_id = f8
       2 category_name = vc
       2 category_mean = vc
       2 text[*]
         3 text_type_mean = vc
         3 text = vc
         3 text_seq = i4
       2 reports[*]
         3 br_datamart_report_id = f8
         3 report_name = vc
         3 report_mean = vc
         3 report_seq = i4
         3 text[*]
           4 text_type_mean = vc
           4 text = vc
           4 text_seq = i4
         3 baseline_value = vc
         3 target_value = vc
         3 mpage_pos_flag = i2
         3 mpage_pos_seq = i4
         3 selected_ind = i2
         3 cond_report_mean = vc
         3 mpage_default_ind = i2
         3 layout_flags[*]
           4 layout_flag = i2
       2 cat_baseline_value = vc
       2 cat_target_value = vc
       2 flex_flag = i2
       2 rel_score_ind = i2
       2 base_target_ind = i2
       2 layout_flag = i2
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   SET trace = nocallecho
   EXECUTE bed_get_datamart_cat_reports  WITH replace("REQUEST",dm_cat_req), replace("REPLY",
    dm_cat_reply)
   SET trace = callecho
   SET stat = error(msg,0)
   IF (stat != 0)
    SET import::log->layout_error = true
    CALL IMPORT::errormsg(1,"ERROR: CCL error during bed_get_datamart_cat_reports script call")
    GO TO log_file
   ELSEIF ((dm_cat_reply->status_data.status="F"))
    SET import::log->layout_error = true
    CALL IMPORT::errormsg(1,
     "ERROR: Failed during bed_get_datamart_cat_reports script call to get Topic/Reports")
    GO TO log_file
   ELSE
    SELECT INTO "nl:"
     cat_name = cnvtupper(trim(substring(1,150,dm_cat_reply->category[d.seq].category_name),3)),
     cat_id = dm_cat_reply->category[d.seq].br_datamart_category_id, rpt_seq = dm_cat_reply->
     category[d.seq].reports[d2.seq].report_seq,
     rpt_name = cnvtupper(trim(substring(1,150,dm_cat_reply->category[d.seq].reports[d2.seq].
        report_name),3)), rpt_id = dm_cat_reply->category[d.seq].reports[d2.seq].
     br_datamart_report_id
     FROM (dummyt d  WITH seq = value(size(dm_cat_reply->category,5))),
      (dummyt d2  WITH seq = 1),
      br_datamart_report_filter_r r,
      br_datamart_filter f,
      br_datamart_value bdv,
      br_datamart_filter_category bdfc
     PLAN (d
      WHERE maxrec(d2,size(dm_cat_reply->category[d.seq].reports,5)))
      JOIN (d2)
      JOIN (r
      WHERE (r.br_datamart_report_id=dm_cat_reply->category[d.seq].reports[d2.seq].
      br_datamart_report_id))
      JOIN (f
      WHERE f.br_datamart_filter_id=r.br_datamart_filter_id)
      JOIN (bdv
      WHERE bdv.br_datamart_category_id=outerjoin(f.br_datamart_category_id)
       AND bdv.br_datamart_filter_id=outerjoin(f.br_datamart_filter_id)
       AND bdv.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime)))
      JOIN (bdfc
      WHERE bdfc.filter_category_mean=f.filter_category_mean)
     ORDER BY cat_name, cat_id, rpt_seq,
      rpt_name, rpt_id, f.filter_seq,
      f.br_datamart_filter_id
     HEAD REPORT
      cat_cnt = 0
     HEAD cat_id
      cat_cnt = (cat_cnt+ 1)
      IF (mod(cat_cnt,100)=1)
       stat = alterlist(import_ref_data->cat_qual,(cat_cnt+ 99))
      ENDIF
      import_ref_data->cat_qual[cat_cnt].br_cat_id = dm_cat_reply->category[d.seq].
      br_datamart_category_id, import_ref_data->cat_qual[cat_cnt].cat_mean = dm_cat_reply->category[d
      .seq].category_mean, import_ref_data->cat_qual[cat_cnt].cat_name = dm_cat_reply->category[d.seq
      ].category_name,
      rpt_cnt = 0
     HEAD rpt_id
      rpt_cnt = (rpt_cnt+ 1)
      IF (mod(rpt_cnt,100)=1)
       stat = alterlist(import_ref_data->cat_qual[cat_cnt].report_qual,(rpt_cnt+ 99))
      ENDIF
      import_ref_data->cat_qual[cat_cnt].report_qual[rpt_cnt].br_report_id = dm_cat_reply->category[d
      .seq].reports[d2.seq].br_datamart_report_id, import_ref_data->cat_qual[cat_cnt].report_qual[
      rpt_cnt].report_name = dm_cat_reply->category[d.seq].reports[d2.seq].report_name,
      import_ref_data->cat_qual[cat_cnt].report_qual[rpt_cnt].report_mean = dm_cat_reply->category[d
      .seq].reports[d2.seq].report_mean,
      import_ref_data->cat_qual[cat_cnt].report_qual[rpt_cnt].report_seq = dm_cat_reply->category[d
      .seq].reports[d2.seq].report_seq, fltr_cnt = 0
     HEAD f.br_datamart_filter_id
      value_cnt = 0, fltr_cnt = (fltr_cnt+ 1)
      IF (mod(fltr_cnt,100)=1)
       stat = alterlist(import_ref_data->cat_qual[cat_cnt].report_qual[rpt_cnt].filter,(fltr_cnt+ 99)
        )
      ENDIF
      import_ref_data->cat_qual[cat_cnt].report_qual[rpt_cnt].filter[fltr_cnt].br_filter_id = f
      .br_datamart_filter_id, import_ref_data->cat_qual[cat_cnt].report_qual[rpt_cnt].filter[fltr_cnt
      ].filter_disp = f.filter_display, import_ref_data->cat_qual[cat_cnt].report_qual[rpt_cnt].
      filter[fltr_cnt].filter_mean = f.filter_mean,
      import_ref_data->cat_qual[cat_cnt].report_qual[rpt_cnt].filter[fltr_cnt].filter_seq = f
      .filter_seq, import_ref_data->cat_qual[cat_cnt].report_qual[rpt_cnt].filter[fltr_cnt].
      filter_cat_mean = f.filter_category_mean, import_ref_data->cat_qual[cat_cnt].report_qual[
      rpt_cnt].filter[fltr_cnt].filter_category_type_mean = bdfc.filter_category_type_mean,
      import_ref_data->cat_qual[cat_cnt].report_qual[rpt_cnt].filter[fltr_cnt].codeset = bdfc.codeset
     DETAIL
      IF (bdv.br_datamart_value_id > 0)
       value_cnt = (value_cnt+ 1)
      ENDIF
     FOOT  f.br_datamart_filter_id
      IF (value_cnt > 0)
       import_ref_data->cat_qual[cat_cnt].report_qual[rpt_cnt].filter[fltr_cnt].filter_defined = 1
      ENDIF
     FOOT  rpt_id
      stat = alterlist(import_ref_data->cat_qual[cat_cnt].report_qual[rpt_cnt].filter,fltr_cnt)
     FOOT  cat_id
      stat = alterlist(import_ref_data->cat_qual[cat_cnt].report_qual,rpt_cnt)
     FOOT REPORT
      stat = alterlist(import_ref_data->cat_qual,cat_cnt)
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE IMPORT::get_bdr_filters(index,to_from_flag)
   DECLARE IMPORT::index = i4 WITH protect, constant(index)
   DECLARE IMPORT::to_from_flag = i2 WITH protect, constant(to_from_flag)
   RECORD bdr_get_request(
     1 br_datamart_category_id = f8
     1 filter[1]
       2 br_datamart_filter_id = f8
     1 flex_id = f8
   ) WITH protect
   RECORD bdr_get_reply(
     1 filter[*]
       2 br_datamart_filter_id = f8
       2 value[*]
         3 parent_entity_name = vc
         3 parent_entity_id = f8
         3 value_dt_tm = dq8
         3 freetext_desc = vc
         3 qualifier_flag = i2
         3 value_seq = i4
         3 value_type_flag = i2
         3 group_seq = i4
         3 mpage_param_mean = vc
         3 mpage_param_value = vc
         3 parent_entity_name2 = vc
         3 parent_entity_id2 = f8
         3 map_data_type_cd = f8
         3 map_data_type_meaning = vc
         3 map_data_type_display = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   IF ((IMPORT::to_from_flag=1))
    SET bdr_get_request->br_datamart_category_id = build->filter_qual[IMPORT::index].from_topic_id
    SET bdr_get_request->filter[1].br_datamart_filter_id = build->filter_qual[IMPORT::index].
    from_filter_id
   ELSE
    CALL IMPORT::errormsg(IMPORT::index,build(
      "ERROR Invalid to_from_flag in the import::get_bdr_filters subroutine"))
    SET build->filter_qual[IMPORT::index].err_ind = 1
   ENDIF
   SET bdr_get_request->flex_id = 0.0
   SET trace = nocallecho
   EXECUTE bed_get_datamart_values  WITH replace("REQUEST",bdr_get_request), replace("REPLY",
    bdr_get_reply)
   SET trace = callecho
   IF (IMPORT::cclerrorcheck(IMPORT::index,false))
    SET msg = concat("ERROR CCL script bed_get_datamart_values Failed to get filter values")
    SET build->filter_qual[IMPORT::index].err_ind = 1
   ELSEIF ((bdr_get_reply->status_data[1].status != "S"))
    SET msg = concat("ERROR Failed to get filter values")
    SET build->filter_qual[IMPORT::index].err_ind = 1
   ELSE
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(bdr_get_reply->filter,5)))
     PLAN (d)
     DETAIL
      stat = alterlist(build->filter_qual[IMPORT::index].from_value,size(bdr_get_reply->filter[d.seq]
        .value,5))
      FOR (val_cnt = 1 TO size(bdr_get_reply->filter[d.seq].value,5))
        build->filter_qual[IMPORT::index].from_value[val_cnt].freetext_desc = bdr_get_reply->filter[d
        .seq].value[val_cnt].freetext_desc, build->filter_qual[IMPORT::index].from_value[val_cnt].
        group_seq = bdr_get_reply->filter[d.seq].value[val_cnt].group_seq, build->filter_qual[
        IMPORT::index].from_value[val_cnt].map_data_type_cd = bdr_get_reply->filter[d.seq].value[
        val_cnt].map_data_type_cd,
        build->filter_qual[IMPORT::index].from_value[val_cnt].map_data_type_display = bdr_get_reply->
        filter[d.seq].value[val_cnt].map_data_type_display, build->filter_qual[IMPORT::index].
        from_value[val_cnt].map_data_type_meaning = bdr_get_reply->filter[d.seq].value[val_cnt].
        map_data_type_meaning, build->filter_qual[IMPORT::index].from_value[val_cnt].mpage_param_mean
         = bdr_get_reply->filter[d.seq].value[val_cnt].mpage_param_mean,
        build->filter_qual[IMPORT::index].from_value[val_cnt].mpage_param_value = bdr_get_reply->
        filter[d.seq].value[val_cnt].mpage_param_value, build->filter_qual[IMPORT::index].from_value[
        val_cnt].parent_entity_id = bdr_get_reply->filter[d.seq].value[val_cnt].parent_entity_id,
        build->filter_qual[IMPORT::index].from_value[val_cnt].parent_entity_id2 = bdr_get_reply->
        filter[d.seq].value[val_cnt].parent_entity_id2,
        build->filter_qual[IMPORT::index].from_value[val_cnt].parent_entity_name = bdr_get_reply->
        filter[d.seq].value[val_cnt].parent_entity_name, build->filter_qual[IMPORT::index].
        from_value[val_cnt].parent_entity_name2 = bdr_get_reply->filter[d.seq].value[val_cnt].
        parent_entity_name2, build->filter_qual[IMPORT::index].from_value[val_cnt].qualifier_flag =
        bdr_get_reply->filter[d.seq].value[val_cnt].qualifier_flag,
        build->filter_qual[IMPORT::index].from_value[val_cnt].value_dt_tm = bdr_get_reply->filter[d
        .seq].value[val_cnt].value_dt_tm, build->filter_qual[IMPORT::index].from_value[val_cnt].
        value_seq = bdr_get_reply->filter[d.seq].value[val_cnt].value_seq, build->filter_qual[
        IMPORT::index].from_value[val_cnt].value_type_flag = bdr_get_reply->filter[d.seq].value[
        val_cnt].value_type_flag
      ENDFOR
     WITH nocounter
    ;end select
   ENDIF
   IF (IMPORT::cclerrorcheck(IMPORT::index,false))
    SET msg = concat("ERROR CCL script Failed to get filter values")
    SET build->filter_qual[IMPORT::index].err_ind = 1
   ENDIF
   SET trace = callecho
 END ;Subroutine
 SUBROUTINE IMPORT::copy_bdr_filters(index)
   DECLARE IMPORT::index = i4 WITH protect, constant(index)
   DECLARE add_val_cnt = i4 WITH protect
   RECORD bed_ens_req(
     1 br_datamart_category_id = f8
     1 br_datamart_report_id = f8
     1 baseline_value = vc
     1 target_value = vc
     1 filter[1]
       2 br_datamart_filter_id = f8
       2 filter_mean = vc
       2 value[*]
         3 parent_entity_id = f8
         3 value_dt_tm = dq8
         3 freetext_desc = vc
         3 qualifier_flag = i2
         3 value_seq = i4
         3 value_type_flag = i2
         3 group_seq = i4
         3 mpage_param_mean = vc
         3 mpage_param_value = vc
         3 parent_entity_id2 = f8
         3 map_data_type_cd = f8
         3 parent_entity_name = vc
         3 parent_entity_name2 = vc
       2 flex_id = f8
       2 flex_types[*]
         3 parent_entity_id = f8
         3 parent_entity_name = vc
         3 parent_entity_type_flag = i2
       2 groups[*]
         3 parent_parent_entity_id = f8
         3 parent_parent_entity_name = vc
         3 parent_parent_entity_type_flag = i2
         3 child_parent_entity_id = f8
         3 child_parent_entity_name = vc
         3 child_parent_entity_type_flag = i2
   ) WITH protect
   RECORD bed_ens_reply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   SET bed_ens_req->br_datamart_category_id = uniq_fltr_bld->filter_qual[IMPORT::index].to_topic_id
   SET bed_ens_req->filter[1].br_datamart_filter_id = uniq_fltr_bld->filter_qual[IMPORT::index].
   to_filter_id
   SET bed_ens_req->filter[1].filter_mean = uniq_fltr_bld->filter_qual[IMPORT::index].
   to_filter_cat_mean
   SET add_val_cnt = 0
   FOR (val_cnt = 1 TO size(uniq_fltr_bld->filter_qual[IMPORT::index].add_value,5))
    SET val_pos = locateval(look_ndx,1,size(uniq_fltr_bld->filter_qual[IMPORT::index].excl_value,5),
     uniq_fltr_bld->filter_qual[IMPORT::index].add_value[val_cnt].parent_entity_id,uniq_fltr_bld->
     filter_qual[IMPORT::index].excl_value[look_ndx].parent_entity_id,
     uniq_fltr_bld->filter_qual[IMPORT::index].add_value[val_cnt].parent_entity_id2,uniq_fltr_bld->
     filter_qual[IMPORT::index].excl_value[look_ndx].parent_entity_id2)
    IF (val_pos=0)
     SET add_val_cnt = (add_val_cnt+ 1)
     SET stat = alterlist(bed_ens_req->filter[1].value,add_val_cnt)
     SET bed_ens_req->filter[1].value[add_val_cnt].freetext_desc = uniq_fltr_bld->filter_qual[
     IMPORT::index].add_value[val_cnt].freetext_desc
     SET bed_ens_req->filter[1].value[add_val_cnt].group_seq = uniq_fltr_bld->filter_qual[IMPORT::
     index].add_value[val_cnt].group_seq
     SET bed_ens_req->filter[1].value[add_val_cnt].map_data_type_cd = uniq_fltr_bld->filter_qual[
     IMPORT::index].add_value[val_cnt].map_data_type_cd
     SET bed_ens_req->filter[1].value[add_val_cnt].mpage_param_mean = uniq_fltr_bld->filter_qual[
     IMPORT::index].add_value[val_cnt].mpage_param_mean
     SET bed_ens_req->filter[1].value[add_val_cnt].mpage_param_value = uniq_fltr_bld->filter_qual[
     IMPORT::index].add_value[val_cnt].mpage_param_value
     SET bed_ens_req->filter[1].value[add_val_cnt].parent_entity_id = uniq_fltr_bld->filter_qual[
     IMPORT::index].add_value[val_cnt].parent_entity_id
     SET bed_ens_req->filter[1].value[add_val_cnt].parent_entity_id2 = uniq_fltr_bld->filter_qual[
     IMPORT::index].add_value[val_cnt].parent_entity_id2
     SET bed_ens_req->filter[1].value[add_val_cnt].parent_entity_name = uniq_fltr_bld->filter_qual[
     IMPORT::index].add_value[val_cnt].parent_entity_name
     SET bed_ens_req->filter[1].value[add_val_cnt].parent_entity_name2 = uniq_fltr_bld->filter_qual[
     IMPORT::index].add_value[val_cnt].parent_entity_name2
     SET bed_ens_req->filter[1].value[add_val_cnt].qualifier_flag = uniq_fltr_bld->filter_qual[
     IMPORT::index].add_value[val_cnt].qualifier_flag
     SET bed_ens_req->filter[1].value[add_val_cnt].value_seq = uniq_fltr_bld->filter_qual[IMPORT::
     index].add_value[val_cnt].value_seq
     SET bed_ens_req->filter[1].value[add_val_cnt].value_type_flag = uniq_fltr_bld->filter_qual[
     IMPORT::index].add_value[val_cnt].value_type_flag
    ENDIF
   ENDFOR
   EXECUTE bed_ens_datamart_values  WITH replace("REQUEST",bed_ens_req), replace("REPLY",
    bed_ens_reply)
   IF (IMPORT::cclerrorcheck(IMPORT::index,true))
    SET msg = concat("ERROR CCL script bed_ens_datamart_values Failed to copy over the filter values"
     )
    SET uniq_fltr_bld->filter_qual[IMPORT::index].err_ind = 1
   ELSEIF ((bed_ens_reply->status_data[1].status != "S"))
    SET msg = concat("ERROR Failed to copy over the filter values")
    SET uniq_fltr_bld->filter_qual[IMPORT::index].err_ind = 1
   ENDIF
   IF (IMPORT::cclerrorcheck(IMPORT::index,true))
    SET msg = concat("ERROR CCL script Failed to copy over the filter values")
    SET uniq_fltr_bld->filter_qual[IMPORT::index].err_ind = 1
   ENDIF
 END ;Subroutine
 SET last_mod = "000 12/01/16 rv5893 Initial Release"
#exit_script
END GO
