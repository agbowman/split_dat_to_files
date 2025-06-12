CREATE PROGRAM cp_structured_doc_build_data:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "CP Component Id" = 0,
  "CP Component Detail Doc Version" = - (1)
  WITH outdev, cp_component_id, comp_version
 DECLARE staticcontentlocation = vc WITH protect, noconstant("")
 FREE RECORD record_data
 RECORD record_data(
   1 concept_cki = vc
   1 section_ref[*]
     2 dd_sref_section_id = f8
     2 template_rltns[*]
       3 dd_sref_templ_instance_ident = vc
       3 dd_sref_chf_cmplnt_crit_id = f8
       3 parent_entity_id = f8
       3 parent_entity_name = vc
     2 groupbys[*]
       3 label = vc
       3 display_seq = i4
       3 displayflag = i2
       3 subgroupbys[*]
         4 label = vc
         4 display_seq = i4
         4 displayflag = i2
         4 items[*]
           5 value = vc
           5 priority = i2
           5 ocid = vc
           5 display_seq = i4
           5 displayflag = i2
           5 code[*]
             6 code_system = vc
             6 value = vc
           5 attributes[*]
             6 name = vc
             6 attrib_type = vc
             6 attribid = vc
             6 ocid = vc
             6 priority = i2
             6 display_seq = i4
             6 displayflag = i2
             6 code[*]
               7 code_system = vc
               7 value = vc
             6 attribute_menu_items[*]
               7 value = vc
               7 caption = vc
               7 user_input = i2
               7 data_type = vc
               7 ocid = vc
               7 normalfinding = vc
               7 display_seq = i4
               7 min_value = f8
               7 max_value = f8
               7 priority = i2
               7 ui_type = vc
               7 ui_value = vc
               7 label_id = vc
               7 child_label_id = vc
               7 code[*]
                 8 code_system = vc
                 8 value = vc
         4 code[*]
           5 code_system = vc
           5 value = vc
       3 items[*]
         4 value = vc
         4 priority = i2
         4 ocid = vc
         4 display_seq = i4
         4 displayflag = i2
         4 code[*]
           5 code_system = vc
           5 value = vc
         4 attributes[*]
           5 name = vc
           5 attrib_type = vc
           5 attribid = vc
           5 ocid = vc
           5 priority = i2
           5 display_seq = i4
           5 displayflag = i2
           5 code[*]
             6 code_system = vc
             6 value = vc
           5 attribute_menu_items[*]
             6 value = vc
             6 caption = vc
             6 user_input = i2
             6 data_type = vc
             6 ocid = vc
             6 normalfinding = vc
             6 display_seq = i4
             6 min_value = f8
             6 max_value = f8
             6 priority = i2
             6 ui_type = vc
             6 ui_value = vc
             6 label_id = vc
             6 child_label_id = vc
     2 template_xmls[*]
       3 template_xml = vc
     2 subsections[*]
       3 dd_sref_section_id = f8
       3 template_rltns[*]
         4 dd_sref_templ_instance_ident = vc
         4 dd_sref_chf_cmplnt_crit_id = f8
         4 parent_entity_id = f8
         4 parent_entity_name = vc
       3 groupbys[*]
         4 label = vc
         4 display_seq = i4
         4 displayflag = i2
         4 subgroupbys[*]
           5 label = vc
           5 display_seq = i4
           5 displayflag = i2
           5 items[*]
             6 value = vc
             6 priority = i2
             6 ocid = vc
             6 display_seq = i4
             6 displayflag = i2
             6 attributes[*]
               7 name = vc
               7 attrib_type = vc
               7 attribid = vc
               7 ocid = vc
               7 priority = i2
               7 display_seq = i4
               7 displayflag = i2
               7 attribute_menu_items[*]
                 8 value = vc
                 8 caption = vc
                 8 user_input = i2
                 8 data_type = vc
                 8 ocid = vc
                 8 normalfinding = vc
                 8 display_seq = i4
                 8 min_value = f8
                 8 max_value = f8
                 8 priority = i2
                 8 ui_type = vc
                 8 ui_value = vc
                 8 label_id = vc
                 8 child_label_id = vc
         4 items[*]
           5 value = vc
           5 priority = i2
           5 ocid = vc
           5 display_seq = i4
           5 displayflag = i2
           5 attributes[*]
             6 name = vc
             6 attrib_type = vc
             6 attribid = vc
             6 ocid = vc
             6 priority = i2
             6 display_seq = i4
             6 displayflag = i2
             6 attribute_menu_items[*]
               7 value = vc
               7 caption = vc
               7 user_input = i2
               7 data_type = vc
               7 ocid = vc
               7 normalfinding = vc
               7 display_seq = i4
               7 min_value = f8
               7 max_value = f8
               7 priority = i2
               7 ui_type = vc
               7 ui_value = vc
               7 label_id = vc
               7 child_label_id = vc
       3 template_xmls[*]
         4 template_xmls = vc
       3 section_label = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 document_events
     2 json = vc
   1 term_decorations
     2 json = vc
   1 document_layout
     2 json = vc
   1 behaviors
     2 json = vc
 ) WITH protect
 FREE RECORD behaviors
 RECORD behaviors(
   1 cnt = i4
   1 qual[*]
     2 description = vc
     2 cp_node_behavior_id = f8
     2 cp_node_id = f8
     2 cp_pathway_id = f8
     2 reaction_entity_id = f8
     2 reaction_entity_name = vc
     2 response_ident = vc
     2 reaction_type_mean = vc
     2 instance_ident = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD code_values
 RECORD code_values(
   1 code_cnt = i4
   1 codes[*]
     2 value = f8
     2 display = vc
     2 meaning = vc
 )
 FREE RECORD recommendation_folders
 RECORD recommendation_folders(
   1 regimen_cnt = i4
   1 powerplan_cnt = i4
   1 allorders_cnt = i4
   1 treatment_cnt = i4
   1 orderfolders_cnt = i4
   1 regimen[*]
     2 display = vc
     2 id = f8
     2 mean = vc
   1 powerplan[*]
     2 display = vc
     2 id = f8
     2 mean = vc
   1 allorders[*]
     2 display = vc
     2 id = f8
     2 mean = vc
     2 detail_id = f8
     2 detail_display = vc
     2 cat_type_mean = vc
     2 ord_type_flag = i4
     2 usage_flag = i4
   1 treatmentnodes[*]
     2 display = vc
     2 id = f8
     2 mean = vc
   1 orderfolders[*]
     2 display = vc
     2 id = f8
     2 mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ( NOT (validate(json_data_record)))
  RECORD json_data_record(
    1 jscriterion = vc
    1 jsstructuredata = vc
    1 jsrecommendationdata = vc
    1 jsnodeid = f8
    1 jsnodename = vc
    1 jscomponentid = f8
    1 jspathwayname = vc
    1 jspathwayid = f8
    1 jsclinicalinstanceident = vc
    1 jseventslongtextid = f8
    1 jsdecorationslongtextid = f8
    1 jslayoutlongtextid = f8
    1 jscompdetailreltncds = vc
    1 jsrecommendationcategories = vc
    1 jstreatmentlineforpathway = vc
    1 jscodesetvalues = vc
    1 jssourceflag = i2
    1 jslatestdocver = i4
    1 jslatestclninst = vc
    1 jslatestclninstdisplay = vc
    1 jscurrentdocver = i4
    1 jscompvrsnnmbrs = vc
    1 jslatestcompver = i4
    1 jscurrentcompver = i4
    1 jspathwaytypemean = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF ( NOT (validate(recommendation_category)))
  RECORD recommendation_category(
    1 categories_cnt = i4
    1 categories[*]
      2 suggestmean = vc
      2 display = vc
      2 mean = vc
      2 type = vc
      2 detailmean = vc
  )
 ENDIF
 IF ( NOT (validate(treatment_line_templates)))
  RECORD treatment_line_templates(
    1 template_cnt = i4
    1 templates[*]
      2 display = vc
      2 clin_id = vc
      2 version = i4
      2 update_date_time = dq8
  )
 ENDIF
 IF ( NOT (validate(code_set_values)))
  RECORD code_set_values(
    1 code_set_cnt = i4
    1 code_sets[*]
      2 code_set = i4
      2 code_value_cnt = i4
      2 code_values[*]
        3 meaning = vc
        3 display = vc
        3 code_value = f8
        3 description = vc
        3 cki = vc
        3 concept_cki = vc
        3 defination = vc
        3 display_key = vc
  )
 ENDIF
 FREE RECORD comp_vrsn_nmbrs_rec
 RECORD comp_vrsn_nmbrs_rec(
   1 comp_vrsn_nmbrs[*]
     2 version_nbr = i4
 )
 DECLARE current_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), protect
 DECLARE current_time_zone = i4 WITH constant(datetimezonebyname(curtimezone)), protect
 DECLARE ending_date_time = dq8 WITH constant(cnvtdatetime("31-DEC-2100")), protect
 DECLARE bind_cnt = i4 WITH constant(50), protect
 DECLARE lower_bound_date = vc WITH constant("01-JAN-1800 00:00:00.00"), protect
 DECLARE upper_bound_date = vc WITH constant("31-DEC-2100 23:59:59.99"), protect
 DECLARE codelistcnt = i4 WITH noconstant(0), protect
 DECLARE prsnllistcnt = i4 WITH noconstant(0), protect
 DECLARE phonelistcnt = i4 WITH noconstant(0), protect
 DECLARE code_idx = i4 WITH noconstant(0), protect
 DECLARE prsnl_idx = i4 WITH noconstant(0), protect
 DECLARE phone_idx = i4 WITH noconstant(0), protect
 DECLARE prsnl_cnt = i4 WITH noconstant(0), protect
 DECLARE mpc_ap_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_doc_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_mdoc_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_rad_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_txt_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_num_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_immun_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_med_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_date_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_done_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_mbo_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_procedure_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_grp_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_hlatyping_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE eventclasscdpopulated = i2 WITH protect, noconstant(0)
 DECLARE getorgsecurityflag(null) = i2 WITH protect
 DECLARE cclimpersonation(null) = null WITH protect
 SUBROUTINE (addcodetolist(code_value=f8(val),record_data=vc(ref)) =null WITH protect)
   IF (code_value != 0)
    IF (((codelistcnt=0) OR (locateval(code_idx,1,codelistcnt,code_value,record_data->codes[code_idx]
     .code) <= 0)) )
     SET codelistcnt += 1
     SET stat = alterlist(record_data->codes,codelistcnt)
     SET record_data->codes[codelistcnt].code = code_value
     SET record_data->codes[codelistcnt].sequence = uar_get_collation_seq(code_value)
     SET record_data->codes[codelistcnt].meaning = uar_get_code_meaning(code_value)
     SET record_data->codes[codelistcnt].display = uar_get_code_display(code_value)
     SET record_data->codes[codelistcnt].description = uar_get_code_description(code_value)
     SET record_data->codes[codelistcnt].code_set = uar_get_code_set(code_value)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (outputcodelist(record_data=vc(ref)) =null WITH protect)
   CALL log_message("In OutputCodeList() @deprecated",log_level_debug)
 END ;Subroutine
 SUBROUTINE (addpersonneltolist(prsnl_id=f8(val),record_data=vc(ref)) =null WITH protect)
   CALL addpersonneltolistwithdate(prsnl_id,record_data,current_date_time)
 END ;Subroutine
 SUBROUTINE (addpersonneltolistwithdate(prsnl_id=f8(val),record_data=vc(ref),active_date=f8(val)) =
  null WITH protect)
   DECLARE personnel_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",213,"PRSNL"))
   IF (((active_date=null) OR (active_date=0.0)) )
    SET active_date = current_date_time
   ENDIF
   IF (prsnl_id != 0)
    IF (((prsnllistcnt=0) OR (locateval(prsnl_idx,1,prsnllistcnt,prsnl_id,record_data->prsnl[
     prsnl_idx].id,
     active_date,record_data->prsnl[prsnl_idx].active_date) <= 0)) )
     SET prsnllistcnt += 1
     IF (prsnllistcnt > size(record_data->prsnl,5))
      SET stat = alterlist(record_data->prsnl,(prsnllistcnt+ 9))
     ENDIF
     SET record_data->prsnl[prsnllistcnt].id = prsnl_id
     IF (validate(record_data->prsnl[prsnllistcnt].active_date) != 0)
      SET record_data->prsnl[prsnllistcnt].active_date = active_date
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (outputpersonnellist(report_data=vc(ref)) =null WITH protect)
   CALL log_message("In OutputPersonnelList()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE prsnl_name_type_cd = f8 WITH constant(uar_get_code_by("MEANING",213,"PRSNL")), protect
   DECLARE active_date_ind = i2 WITH protect, noconstant(0)
   DECLARE filteredcnt = i4 WITH protect, noconstant(0)
   DECLARE prsnl_seq = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   IF (prsnllistcnt > 0)
    SELECT INTO "nl:"
     FROM prsnl p,
      (left JOIN person_name pn ON pn.person_id=p.person_id
       AND pn.name_type_cd=prsnl_name_type_cd
       AND pn.active_ind=1)
     PLAN (p
      WHERE expand(idx,1,size(report_data->prsnl,5),p.person_id,report_data->prsnl[idx].id))
      JOIN (pn)
     ORDER BY p.person_id, pn.end_effective_dt_tm DESC
     HEAD REPORT
      prsnl_seq = 0, active_date_ind = validate(report_data->prsnl[1].active_date,0)
     HEAD p.person_id
      IF (active_date_ind=0)
       prsnl_seq = locateval(idx,1,prsnllistcnt,p.person_id,report_data->prsnl[idx].id)
       IF (pn.person_id > 0)
        report_data->prsnl[prsnl_seq].provider_name.name_full = trim(pn.name_full,3), report_data->
        prsnl[prsnl_seq].provider_name.name_first = trim(pn.name_first,3), report_data->prsnl[
        prsnl_seq].provider_name.name_middle = trim(pn.name_middle,3),
        report_data->prsnl[prsnl_seq].provider_name.name_last = trim(pn.name_last,3), report_data->
        prsnl[prsnl_seq].provider_name.username = trim(p.username,3), report_data->prsnl[prsnl_seq].
        provider_name.initials = trim(pn.name_initials,3),
        report_data->prsnl[prsnl_seq].provider_name.title = trim(pn.name_initials,3)
       ELSE
        report_data->prsnl[prsnl_seq].provider_name.name_full = trim(p.name_full_formatted,3),
        report_data->prsnl[prsnl_seq].provider_name.name_first = trim(p.name_first,3), report_data->
        prsnl[prsnl_seq].provider_name.name_last = trim(p.name_last,3),
        report_data->prsnl[prsnl_seq].provider_name.username = trim(p.username,3)
       ENDIF
      ENDIF
     DETAIL
      IF (active_date_ind != 0)
       prsnl_seq = locateval(idx,1,prsnllistcnt,p.person_id,report_data->prsnl[idx].id)
       WHILE (prsnl_seq > 0)
        IF ((report_data->prsnl[prsnl_seq].active_date BETWEEN pn.beg_effective_dt_tm AND pn
        .end_effective_dt_tm))
         IF (pn.person_id > 0)
          report_data->prsnl[prsnl_seq].person_name_id = pn.person_name_id, report_data->prsnl[
          prsnl_seq].beg_effective_dt_tm = pn.beg_effective_dt_tm, report_data->prsnl[prsnl_seq].
          end_effective_dt_tm = pn.end_effective_dt_tm,
          report_data->prsnl[prsnl_seq].provider_name.name_full = trim(pn.name_full,3), report_data->
          prsnl[prsnl_seq].provider_name.name_first = trim(pn.name_first,3), report_data->prsnl[
          prsnl_seq].provider_name.name_middle = trim(pn.name_middle,3),
          report_data->prsnl[prsnl_seq].provider_name.name_last = trim(pn.name_last,3), report_data->
          prsnl[prsnl_seq].provider_name.username = trim(p.username,3), report_data->prsnl[prsnl_seq]
          .provider_name.initials = trim(pn.name_initials,3),
          report_data->prsnl[prsnl_seq].provider_name.title = trim(pn.name_initials,3)
         ELSE
          report_data->prsnl[prsnl_seq].provider_name.name_full = trim(p.name_full_formatted,3),
          report_data->prsnl[prsnl_seq].provider_name.name_first = trim(p.name_first,3), report_data
          ->prsnl[prsnl_seq].provider_name.name_last = trim(pn.name_last,3),
          report_data->prsnl[prsnl_seq].provider_name.username = trim(p.username,3)
         ENDIF
         IF ((report_data->prsnl[prsnl_seq].active_date=current_date_time))
          report_data->prsnl[prsnl_seq].active_date = 0
         ENDIF
        ENDIF
        ,prsnl_seq = locateval(idx,(prsnl_seq+ 1),prsnllistcnt,p.person_id,report_data->prsnl[idx].id
         )
       ENDWHILE
      ENDIF
     FOOT REPORT
      stat = alterlist(report_data->prsnl,prsnllistcnt)
     WITH nocounter
    ;end select
    CALL error_and_zero_check_rec(curqual,"PRSNL","OutputPersonnelList",1,0,
     report_data)
    IF (active_date_ind != 0)
     SELECT INTO "nl:"
      end_effective_dt_tm = report_data->prsnl[d.seq].end_effective_dt_tm, person_name_id =
      report_data->prsnl[d.seq].person_name_id, prsnl_id = report_data->prsnl[d.seq].id
      FROM (dummyt d  WITH seq = size(report_data->prsnl,5))
      ORDER BY end_effective_dt_tm DESC, person_name_id, prsnl_id
      HEAD REPORT
       filteredcnt = 0, idx = size(report_data->prsnl,5), stat = alterlist(report_data->prsnl,(idx *
        2))
      HEAD end_effective_dt_tm
       donothing = 0
      HEAD prsnl_id
       idx += 1, filteredcnt += 1, report_data->prsnl[idx].id = report_data->prsnl[d.seq].id,
       report_data->prsnl[idx].person_name_id = report_data->prsnl[d.seq].person_name_id
       IF ((report_data->prsnl[d.seq].person_name_id > 0.0))
        report_data->prsnl[idx].beg_effective_dt_tm = report_data->prsnl[d.seq].beg_effective_dt_tm,
        report_data->prsnl[idx].end_effective_dt_tm = report_data->prsnl[d.seq].end_effective_dt_tm
       ELSE
        report_data->prsnl[idx].beg_effective_dt_tm = cnvtdatetime("01-JAN-1900"), report_data->
        prsnl[idx].end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
       ENDIF
       report_data->prsnl[idx].provider_name.name_full = report_data->prsnl[d.seq].provider_name.
       name_full, report_data->prsnl[idx].provider_name.name_first = report_data->prsnl[d.seq].
       provider_name.name_first, report_data->prsnl[idx].provider_name.name_middle = report_data->
       prsnl[d.seq].provider_name.name_middle,
       report_data->prsnl[idx].provider_name.name_last = report_data->prsnl[d.seq].provider_name.
       name_last, report_data->prsnl[idx].provider_name.username = report_data->prsnl[d.seq].
       provider_name.username, report_data->prsnl[idx].provider_name.initials = report_data->prsnl[d
       .seq].provider_name.initials,
       report_data->prsnl[idx].provider_name.title = report_data->prsnl[d.seq].provider_name.title
      FOOT REPORT
       stat = alterlist(report_data->prsnl,idx), stat = alterlist(report_data->prsnl,filteredcnt,0)
      WITH nocounter
     ;end select
     CALL error_and_zero_check_rec(curqual,"PRSNL","FilterPersonnelList",1,0,
      report_data)
    ENDIF
   ENDIF
   CALL log_message(build("Exit OutputPersonnelList(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (addphonestolist(prsnl_id=f8(val),record_data=vc(ref)) =null WITH protect)
   IF (prsnl_id != 0)
    IF (((phonelistcnt=0) OR (locateval(phone_idx,1,phonelistcnt,prsnl_id,record_data->phone_list[
     prsnl_idx].person_id) <= 0)) )
     SET phonelistcnt += 1
     IF (phonelistcnt > size(record_data->phone_list,5))
      SET stat = alterlist(record_data->phone_list,(phonelistcnt+ 9))
     ENDIF
     SET record_data->phone_list[phonelistcnt].person_id = prsnl_id
     SET prsnl_cnt += 1
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (outputphonelist(report_data=vc(ref),phone_types=vc(ref)) =null WITH protect)
   CALL log_message("In OutputPhoneList()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE personcnt = i4 WITH protect, constant(size(report_data->phone_list,5))
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE idx2 = i4 WITH protect, noconstant(0)
   DECLARE idx3 = i4 WITH protect, noconstant(0)
   DECLARE phonecnt = i4 WITH protect, noconstant(0)
   DECLARE prsnlidx = i4 WITH protect, noconstant(0)
   IF (phonelistcnt > 0)
    SELECT
     IF (size(phone_types->phone_codes,5)=0)
      phone_sorter = ph.phone_id
      FROM phone ph
      WHERE expand(idx,1,personcnt,ph.parent_entity_id,report_data->phone_list[idx].person_id)
       AND ph.parent_entity_name="PERSON"
       AND ph.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND ph.end_effective_dt_tm >= cnvtdatetime(sysdate)
       AND ph.active_ind=1
       AND ph.phone_type_seq=1
      ORDER BY ph.parent_entity_id, phone_sorter
     ELSE
      phone_sorter = locateval(idx2,1,size(phone_types->phone_codes,5),ph.phone_type_cd,phone_types->
       phone_codes[idx2].phone_cd)
      FROM phone ph
      WHERE expand(idx,1,personcnt,ph.parent_entity_id,report_data->phone_list[idx].person_id)
       AND ph.parent_entity_name="PERSON"
       AND ph.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND ph.end_effective_dt_tm >= cnvtdatetime(sysdate)
       AND ph.active_ind=1
       AND expand(idx2,1,size(phone_types->phone_codes,5),ph.phone_type_cd,phone_types->phone_codes[
       idx2].phone_cd)
       AND ph.phone_type_seq=1
      ORDER BY ph.parent_entity_id, phone_sorter
     ENDIF
     INTO "nl:"
     HEAD ph.parent_entity_id
      phonecnt = 0, prsnlidx = locateval(idx3,1,personcnt,ph.parent_entity_id,report_data->
       phone_list[idx3].person_id)
     HEAD phone_sorter
      phonecnt += 1
      IF (size(report_data->phone_list[prsnlidx].phones,5) < phonecnt)
       stat = alterlist(report_data->phone_list[prsnlidx].phones,(phonecnt+ 5))
      ENDIF
      report_data->phone_list[prsnlidx].phones[phonecnt].phone_id = ph.phone_id, report_data->
      phone_list[prsnlidx].phones[phonecnt].phone_type_cd = ph.phone_type_cd, report_data->
      phone_list[prsnlidx].phones[phonecnt].phone_type = uar_get_code_display(ph.phone_type_cd),
      report_data->phone_list[prsnlidx].phones[phonecnt].phone_num = formatphonenumber(ph.phone_num,
       ph.phone_format_cd,ph.extension)
     FOOT  ph.parent_entity_id
      stat = alterlist(report_data->phone_list[prsnlidx].phones,phonecnt)
     WITH nocounter, expand = value(evaluate(floor(((personcnt - 1)/ 30)),0,0,1))
    ;end select
    SET stat = alterlist(report_data->phone_list,prsnl_cnt)
    CALL error_and_zero_check_rec(curqual,"PHONE","OutputPhoneList",1,0,
     report_data)
   ENDIF
   CALL log_message(build("Exit OutputPhoneList(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (putstringtofile(svalue=vc(val)) =null WITH protect)
   CALL log_message("In PutStringToFile()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   IF (validate(_memory_reply_string)=1)
    SET _memory_reply_string = svalue
   ELSE
    FREE RECORD putrequest
    RECORD putrequest(
      1 source_dir = vc
      1 source_filename = vc
      1 nbrlines = i4
      1 line[*]
        2 linedata = vc
      1 overflowpage[*]
        2 ofr_qual[*]
          3 ofr_line = vc
      1 isblob = c1
      1 document_size = i4
      1 document = gvc
    )
    SET putrequest->source_dir =  $OUTDEV
    SET putrequest->isblob = "1"
    SET putrequest->document = svalue
    SET putrequest->document_size = size(putrequest->document)
    EXECUTE eks_put_source  WITH replace("REQUEST",putrequest), replace("REPLY",putreply)
   ENDIF
   CALL log_message(build("Exit PutStringToFile(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (putunboundedstringtofile(trec=vc(ref)) =null WITH protect)
   CALL log_message("In PutUnboundedStringToFile()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE curstringlength = i4 WITH noconstant(textlen(trec->val))
   DECLARE newmaxvarlen = i4 WITH noconstant(0)
   DECLARE origcurmaxvarlen = i4 WITH noconstant(0)
   IF (curstringlength > curmaxvarlen)
    SET origcurmaxvarlen = curmaxvarlen
    SET newmaxvarlen = (curstringlength+ 10000)
    SET modify maxvarlen newmaxvarlen
   ENDIF
   CALL putstringtofile(trec->val)
   IF (newmaxvarlen > 0)
    SET modify maxvarlen origcurmaxvarlen
   ENDIF
   CALL log_message(build("Exit PutUnboundedStringToFile(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (putjsonrecordtofile(record_data=vc(ref)) =null WITH protect)
   CALL log_message("In PutJSONRecordToFile()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   RECORD _tempjson(
     1 val = gvc
   )
   SET _tempjson->val = cnvtrectojson(record_data)
   CALL putunboundedstringtofile(_tempjson)
   CALL log_message(build("Exit PutJSONRecordToFile(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (getparametervalues(index=i4(val),value_rec=vc(ref)) =null WITH protect)
   DECLARE par = vc WITH noconstant(""), protect
   DECLARE lnum = i4 WITH noconstant(0), protect
   DECLARE num = i4 WITH noconstant(1), protect
   DECLARE cnt = i4 WITH noconstant(0), protect
   DECLARE cnt2 = i4 WITH noconstant(0), protect
   DECLARE param_value = f8 WITH noconstant(0.0), protect
   DECLARE param_value_str = vc WITH noconstant(""), protect
   SET par = reflect(parameter(index,0))
   IF (validate(debug_ind,0)=1)
    CALL echo(par)
   ENDIF
   IF (((par="F8") OR (par="I4")) )
    SET param_value = parameter(index,0)
    IF (param_value > 0)
     SET value_rec->cnt += 1
     SET stat = alterlist(value_rec->qual,value_rec->cnt)
     SET value_rec->qual[value_rec->cnt].value = param_value
    ENDIF
   ELSEIF (substring(1,1,par)="C")
    SET param_value_str = parameter(index,0)
    IF (trim(param_value_str,3) != "")
     SET value_rec->cnt += 1
     SET stat = alterlist(value_rec->qual,value_rec->cnt)
     SET value_rec->qual[value_rec->cnt].value = trim(param_value_str,3)
    ENDIF
   ELSEIF (substring(1,1,par)="L")
    SET lnum = 1
    WHILE (lnum > 0)
     SET par = reflect(parameter(index,lnum))
     IF (par != " ")
      IF (((par="F8") OR (par="I4")) )
       SET param_value = parameter(index,lnum)
       IF (param_value > 0)
        SET value_rec->cnt += 1
        SET stat = alterlist(value_rec->qual,value_rec->cnt)
        SET value_rec->qual[value_rec->cnt].value = param_value
       ENDIF
       SET lnum += 1
      ELSEIF (substring(1,1,par)="C")
       SET param_value_str = parameter(index,lnum)
       IF (trim(param_value_str,3) != "")
        SET value_rec->cnt += 1
        SET stat = alterlist(value_rec->qual,value_rec->cnt)
        SET value_rec->qual[value_rec->cnt].value = trim(param_value_str,3)
       ENDIF
       SET lnum += 1
      ENDIF
     ELSE
      SET lnum = 0
     ENDIF
    ENDWHILE
   ENDIF
   IF (validate(debug_ind,0)=1)
    CALL echorecord(value_rec)
   ENDIF
 END ;Subroutine
 SUBROUTINE (getlookbackdatebytype(units=i4(val),flag=i4(val)) =dq8 WITH protect)
   DECLARE looback_date = dq8 WITH noconstant(cnvtdatetime("01-JAN-1800 00:00:00"))
   IF (units != 0)
    CASE (flag)
     OF 1:
      SET looback_date = cnvtlookbehind(build(units,",H"),cnvtdatetime(sysdate))
     OF 2:
      SET looback_date = cnvtlookbehind(build(units,",D"),cnvtdatetime(sysdate))
     OF 3:
      SET looback_date = cnvtlookbehind(build(units,",W"),cnvtdatetime(sysdate))
     OF 4:
      SET looback_date = cnvtlookbehind(build(units,",M"),cnvtdatetime(sysdate))
     OF 5:
      SET looback_date = cnvtlookbehind(build(units,",Y"),cnvtdatetime(sysdate))
    ENDCASE
   ENDIF
   RETURN(looback_date)
 END ;Subroutine
 SUBROUTINE (getcodevaluesfromcodeset(evt_set_rec=vc(ref),evt_cd_rec=vc(ref)) =null WITH protect)
  DECLARE csidx = i4 WITH noconstant(0)
  SELECT DISTINCT INTO "nl:"
   FROM v500_event_set_explode vese
   WHERE expand(csidx,1,evt_set_rec->cnt,vese.event_set_cd,evt_set_rec->qual[csidx].value)
   DETAIL
    evt_cd_rec->cnt += 1, stat = alterlist(evt_cd_rec->qual,evt_cd_rec->cnt), evt_cd_rec->qual[
    evt_cd_rec->cnt].value = vese.event_cd
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE (geteventsetnamesfromeventsetcds(evt_set_rec=vc(ref),evt_set_name_rec=vc(ref)) =null
  WITH protect)
   DECLARE index = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM v500_event_set_code v
    WHERE expand(index,1,evt_set_rec->cnt,v.event_set_cd,evt_set_rec->qual[index].value)
    HEAD REPORT
     cnt = 0, evt_set_name_rec->cnt = evt_set_rec->cnt, stat = alterlist(evt_set_name_rec->qual,
      evt_set_rec->cnt)
    DETAIL
     pos = locateval(index,1,evt_set_rec->cnt,v.event_set_cd,evt_set_rec->qual[index].value)
     WHILE (pos > 0)
       cnt += 1, evt_set_name_rec->qual[pos].value = v.event_set_name, pos = locateval(index,(pos+ 1),
        evt_set_rec->cnt,v.event_set_cd,evt_set_rec->qual[index].value)
     ENDWHILE
    FOOT REPORT
     pos = locateval(index,1,evt_set_name_rec->cnt,"",evt_set_name_rec->qual[index].value)
     WHILE (pos > 0)
       evt_set_name_rec->cnt -= 1, stat = alterlist(evt_set_name_rec->qual,evt_set_name_rec->cnt,(pos
         - 1)), pos = locateval(index,pos,evt_set_name_rec->cnt,"",evt_set_name_rec->qual[index].
        value)
     ENDWHILE
     evt_set_name_rec->cnt = cnt, stat = alterlist(evt_set_name_rec->qual,evt_set_name_rec->cnt)
    WITH nocounter, expand = value(evaluate(floor(((evt_set_rec->cnt - 1)/ 30)),0,0,1))
   ;end select
 END ;Subroutine
 SUBROUTINE (returnviewertype(eventclasscd=f8(val),eventid=f8(val)) =vc WITH protect)
   CALL log_message("In returnViewerType()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   IF (eventclasscdpopulated=0)
    SET mpc_ap_type_cd = uar_get_code_by("MEANING",53,"AP")
    SET mpc_doc_type_cd = uar_get_code_by("MEANING",53,"DOC")
    SET mpc_mdoc_type_cd = uar_get_code_by("MEANING",53,"MDOC")
    SET mpc_rad_type_cd = uar_get_code_by("MEANING",53,"RAD")
    SET mpc_txt_type_cd = uar_get_code_by("MEANING",53,"TXT")
    SET mpc_num_type_cd = uar_get_code_by("MEANING",53,"NUM")
    SET mpc_immun_type_cd = uar_get_code_by("MEANING",53,"IMMUN")
    SET mpc_med_type_cd = uar_get_code_by("MEANING",53,"MED")
    SET mpc_date_type_cd = uar_get_code_by("MEANING",53,"DATE")
    SET mpc_done_type_cd = uar_get_code_by("MEANING",53,"DONE")
    SET mpc_mbo_type_cd = uar_get_code_by("MEANING",53,"MBO")
    SET mpc_procedure_type_cd = uar_get_code_by("MEANING",53,"PROCEDURE")
    SET mpc_grp_type_cd = uar_get_code_by("MEANING",53,"GRP")
    SET mpc_hlatyping_type_cd = uar_get_code_by("MEANING",53,"HLATYPING")
    SET eventclasscdpopulated = 1
   ENDIF
   DECLARE sviewerflag = vc WITH protect, noconstant("")
   CASE (eventclasscd)
    OF mpc_ap_type_cd:
     SET sviewerflag = "AP"
    OF mpc_doc_type_cd:
    OF mpc_mdoc_type_cd:
    OF mpc_rad_type_cd:
     SET sviewerflag = "DOC"
    OF mpc_txt_type_cd:
    OF mpc_num_type_cd:
    OF mpc_immun_type_cd:
    OF mpc_med_type_cd:
    OF mpc_date_type_cd:
    OF mpc_done_type_cd:
     SET sviewerflag = "EVENT"
    OF mpc_mbo_type_cd:
     SET sviewerflag = "MICRO"
    OF mpc_procedure_type_cd:
     SET sviewerflag = "PROC"
    OF mpc_grp_type_cd:
     SET sviewerflag = "GRP"
    OF mpc_hlatyping_type_cd:
     SET sviewerflag = "HLA"
    ELSE
     SET sviewerflag = "STANDARD"
   ENDCASE
   IF (eventclasscd=mpc_mdoc_type_cd)
    SELECT INTO "nl:"
     c2.*
     FROM clinical_event c1,
      clinical_event c2
     PLAN (c1
      WHERE c1.event_id=eventid)
      JOIN (c2
      WHERE c1.parent_event_id=c2.event_id
       AND c2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
     HEAD c2.event_id
      IF (c2.event_class_cd=mpc_ap_type_cd)
       sviewerflag = "AP"
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   CALL log_message(build("Exit returnViewerType(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
   RETURN(sviewerflag)
 END ;Subroutine
 SUBROUTINE (cnvtisodttmtodq8(isodttmstr=vc) =dq8 WITH protect)
   DECLARE converteddq8 = dq8 WITH protect, noconstant(0)
   SET converteddq8 = cnvtdatetimeutc2(substring(1,10,isodttmstr),"YYYY-MM-DD",substring(12,8,
     isodttmstr),"HH:MM:SS",4,
    curtimezonedef)
   RETURN(converteddq8)
 END ;Subroutine
 SUBROUTINE (cnvtdq8toisodttm(dq8dttm=f8) =vc WITH protect)
   DECLARE convertedisodttm = vc WITH protect, noconstant("")
   IF (dq8dttm > 0.0)
    SET convertedisodttm = build(replace(datetimezoneformat(cnvtdatetime(dq8dttm),datetimezonebyname(
        "UTC"),"yyyy-MM-dd HH:mm:ss",curtimezonedef)," ","T",1),"Z")
   ELSE
    SET convertedisodttm = nullterm(convertedisodttm)
   ENDIF
   RETURN(convertedisodttm)
 END ;Subroutine
 SUBROUTINE getorgsecurityflag(null)
   DECLARE org_security_flag = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="SECURITY"
     AND di.info_name="SEC_ORG_RELTN"
    HEAD REPORT
     org_security_flag = 0
    DETAIL
     org_security_flag = cnvtint(di.info_number)
    WITH nocounter
   ;end select
   RETURN(org_security_flag)
 END ;Subroutine
 SUBROUTINE (getcomporgsecurityflag(dminfo_name=vc(val)) =i2 WITH protect)
   DECLARE org_security_flag = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="SECURITY"
     AND di.info_name=dminfo_name
    HEAD REPORT
     org_security_flag = 0
    DETAIL
     org_security_flag = cnvtint(di.info_number)
    WITH nocounter
   ;end select
   RETURN(org_security_flag)
 END ;Subroutine
 SUBROUTINE (populateauthorizedorganizations(personid=f8(val),value_rec=vc(ref)) =null WITH protect)
   DECLARE organization_cnt = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM prsnl_org_reltn por
    WHERE por.person_id=personid
     AND por.active_ind=1
     AND por.beg_effective_dt_tm BETWEEN cnvtdatetime(lower_bound_date) AND cnvtdatetime(sysdate)
     AND por.end_effective_dt_tm BETWEEN cnvtdatetime(sysdate) AND cnvtdatetime(upper_bound_date)
    ORDER BY por.organization_id
    HEAD REPORT
     organization_cnt = 0
    DETAIL
     organization_cnt += 1
     IF (mod(organization_cnt,20)=1)
      stat = alterlist(value_rec->organizations,(organization_cnt+ 19))
     ENDIF
     value_rec->organizations[organization_cnt].organizationid = por.organization_id
    FOOT REPORT
     value_rec->cnt = organization_cnt, stat = alterlist(value_rec->organizations,organization_cnt)
    WITH nocounter
   ;end select
   IF (validate(debug_ind,0)=1)
    CALL echorecord(value_rec)
   ENDIF
 END ;Subroutine
 SUBROUTINE (getuserlogicaldomain(id=f8) =f8 WITH protect)
   DECLARE returnid = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM prsnl p
    WHERE p.person_id=id
    DETAIL
     returnid = p.logical_domain_id
    WITH nocounter
   ;end select
   RETURN(returnid)
 END ;Subroutine
 SUBROUTINE (getpersonneloverride(ppr_cd=f8(val)) =i2 WITH protect)
   DECLARE override_ind = i2 WITH protect, noconstant(0)
   IF (ppr_cd <= 0.0)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM code_value_extension cve
    WHERE cve.code_value=ppr_cd
     AND cve.code_set=331
     AND ((cve.field_value="1") OR (cve.field_value="2"))
     AND cve.field_name="Override"
    DETAIL
     override_ind = 1
    WITH nocounter
   ;end select
   RETURN(override_ind)
 END ;Subroutine
 SUBROUTINE cclimpersonation(null)
   CALL log_message("In cclImpersonation()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   EXECUTE secrtl
   DECLARE uar_secsetcontext(hctx=i4) = i2 WITH image_axp = "secrtl", image_aix =
   "libsec.a(libsec.o)", uar = "SecSetContext",
   persist
   DECLARE seccntxt = i4 WITH public
   DECLARE namelen = i4 WITH public
   DECLARE domainnamelen = i4 WITH public
   SET namelen = (uar_secgetclientusernamelen()+ 1)
   SET domainnamelen = (uar_secgetclientdomainnamelen()+ 2)
   SET stat = memalloc(name,1,build("C",namelen))
   SET stat = memalloc(domainname,1,build("C",domainnamelen))
   SET stat = uar_secgetclientusername(name,namelen)
   SET stat = uar_secgetclientdomainname(domainname,domainnamelen)
   SET setcntxt = uar_secimpersonate(nullterm(name),nullterm(domainname))
   CALL log_message(build("Exit cclImpersonation(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (geteventsetdisplaysfromeventsetcds(evt_set_rec=vc(ref),evt_set_disp_rec=vc(ref)) =null
  WITH protect)
   DECLARE index = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM v500_event_set_code v
    WHERE expand(index,1,evt_set_rec->cnt,v.event_set_cd,evt_set_rec->qual[index].value)
    HEAD REPORT
     cnt = 0, evt_set_disp_rec->cnt = evt_set_rec->cnt, stat = alterlist(evt_set_disp_rec->qual,
      evt_set_rec->cnt)
    DETAIL
     pos = locateval(index,1,evt_set_rec->cnt,v.event_set_cd,evt_set_rec->qual[index].value)
     WHILE (pos > 0)
       cnt += 1, evt_set_disp_rec->qual[pos].value = v.event_set_cd_disp, pos = locateval(index,(pos
        + 1),evt_set_rec->cnt,v.event_set_cd,evt_set_rec->qual[index].value)
     ENDWHILE
    FOOT REPORT
     pos = locateval(index,1,evt_set_disp_rec->cnt,"",evt_set_disp_rec->qual[index].value)
     WHILE (pos > 0)
       evt_set_disp_rec->cnt -= 1, stat = alterlist(evt_set_disp_rec->qual,evt_set_disp_rec->cnt,(pos
         - 1)), pos = locateval(index,pos,evt_set_disp_rec->cnt,"",evt_set_disp_rec->qual[index].
        value)
     ENDWHILE
     evt_set_disp_rec->cnt = cnt, stat = alterlist(evt_set_disp_rec->qual,evt_set_disp_rec->cnt)
    WITH nocounter, expand = value(evaluate(floor(((evt_set_rec->cnt - 1)/ 30)),0,0,1))
   ;end select
 END ;Subroutine
 SUBROUTINE (decodestringparameter(description=vc(val)) =vc WITH protect)
   DECLARE decodeddescription = vc WITH private
   SET decodeddescription = replace(description,"%3B",";",0)
   SET decodeddescription = replace(decodeddescription,"%25","%",0)
   RETURN(decodeddescription)
 END ;Subroutine
 SUBROUTINE (urlencode(json=vc(val)) =vc WITH protect)
   DECLARE encodedjson = vc WITH private
   SET encodedjson = replace(json,char(91),"%5B",0)
   SET encodedjson = replace(encodedjson,char(123),"%7B",0)
   SET encodedjson = replace(encodedjson,char(58),"%3A",0)
   SET encodedjson = replace(encodedjson,char(125),"%7D",0)
   SET encodedjson = replace(encodedjson,char(93),"%5D",0)
   SET encodedjson = replace(encodedjson,char(44),"%2C",0)
   SET encodedjson = replace(encodedjson,char(34),"%22",0)
   RETURN(encodedjson)
 END ;Subroutine
 SUBROUTINE (istaskgranted(task_number=i4(val)) =i2 WITH protect)
   CALL log_message("In IsTaskGranted",log_level_debug)
   DECLARE fntime = f8 WITH private, noconstant(curtime3)
   DECLARE task_granted = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM task_access ta,
     application_group ag
    PLAN (ta
     WHERE ta.task_number=task_number
      AND ta.app_group_cd > 0.0)
     JOIN (ag
     WHERE (ag.position_cd=reqinfo->position_cd)
      AND ag.app_group_cd=ta.app_group_cd
      AND ag.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ag.end_effective_dt_tm > cnvtdatetime(sysdate))
    DETAIL
     task_granted = 1
    WITH nocounter, maxqual(ta,1)
   ;end select
   CALL log_message(build("Exit IsTaskGranted - ",build2(cnvtint((curtime3 - fntime))),"0 ms"),
    log_level_debug)
   RETURN(task_granted)
 END ;Subroutine
 DECLARE log_program_name = vc WITH protect, noconstant("")
 DECLARE log_override_ind = i2 WITH protect, noconstant(0)
 SET log_program_name = curprog
 SET log_override_ind = 0
 DECLARE log_level_error = i2 WITH protect, noconstant(0)
 DECLARE log_level_warning = i2 WITH protect, noconstant(1)
 DECLARE log_level_audit = i2 WITH protect, noconstant(2)
 DECLARE log_level_info = i2 WITH protect, noconstant(3)
 DECLARE log_level_debug = i2 WITH protect, noconstant(4)
 DECLARE hsys = i4 WITH protect, noconstant(0)
 DECLARE sysstat = i4 WITH protect, noconstant(0)
 DECLARE serrmsg = c132 WITH protect, noconstant(" ")
 DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
 DECLARE crsl_msg_default = i4 WITH protect, noconstant(0)
 DECLARE crsl_msg_level = i4 WITH protect, noconstant(0)
 EXECUTE msgrtl
 SET crsl_msg_default = uar_msgdefhandle()
 SET crsl_msg_level = uar_msggetlevel(crsl_msg_default)
 DECLARE lcrslsubeventcnt = i4 WITH protect, noconstant(0)
 DECLARE icrslloggingstat = i2 WITH protect, noconstant(0)
 DECLARE lcrslsubeventsize = i4 WITH protect, noconstant(0)
 DECLARE icrslloglvloverrideind = i2 WITH protect, noconstant(0)
 DECLARE scrsllogtext = vc WITH protect, noconstant("")
 DECLARE scrsllogevent = vc WITH protect, noconstant("")
 DECLARE icrslholdloglevel = i2 WITH protect, noconstant(0)
 DECLARE icrslerroroccured = i2 WITH protect, noconstant(0)
 DECLARE lcrsluarmsgwritestat = i4 WITH protect, noconstant(0)
 DECLARE crsl_info_domain = vc WITH protect, constant("DISCERNABU SCRIPT LOGGING")
 DECLARE crsl_logging_on = c1 WITH protect, constant("L")
 IF (((logical("MP_LOGGING_ALL") > " ") OR (logical(concat("MP_LOGGING_",log_program_name)) > " ")) )
  SET log_override_ind = 1
 ENDIF
 SUBROUTINE (log_message(logmsg=vc,loglvl=i4) =null)
   SET icrslloglvloverrideind = 0
   SET scrsllogtext = ""
   SET scrsllogevent = ""
   SET scrsllogtext = concat("{{Script::",value(log_program_name),"}} ",logmsg)
   IF (log_override_ind=0)
    SET icrslholdloglevel = loglvl
   ELSE
    IF (crsl_msg_level < loglvl)
     SET icrslholdloglevel = crsl_msg_level
     SET icrslloglvloverrideind = 1
    ELSE
     SET icrslholdloglevel = loglvl
    ENDIF
   ENDIF
   IF (icrslloglvloverrideind=1)
    SET scrsllogevent = "Script_Override"
   ELSE
    CASE (icrslholdloglevel)
     OF log_level_error:
      SET scrsllogevent = "Script_Error"
     OF log_level_warning:
      SET scrsllogevent = "Script_Warning"
     OF log_level_audit:
      SET scrsllogevent = "Script_Audit"
     OF log_level_info:
      SET scrsllogevent = "Script_Info"
     OF log_level_debug:
      SET scrsllogevent = "Script_Debug"
    ENDCASE
   ENDIF
   SET lcrsluarmsgwritestat = uar_msgwrite(crsl_msg_default,0,nullterm(scrsllogevent),
    icrslholdloglevel,nullterm(scrsllogtext))
   CALL echo(logmsg)
 END ;Subroutine
 SUBROUTINE (error_message(logstatusblockind=i2) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     IF (validate(reply))
      SET reply->status_data.status = "F"
     ENDIF
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      IF (validate(reply))
       CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
      ENDIF
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check_rec(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=
  i2,recorddata=vc(ref)) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     CALL populate_subeventstatus_rec(opname,"F",serrmsg,logmsg,recorddata)
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   IF (icrslerroroccured=1
    AND errorforceexit=1)
    SET recorddata->status_data.status = "F"
    GO TO exit_script
   ENDIF
   IF (qualnum=0
    AND zeroforceexit=1)
    SET recorddata->status_data.status = "Z"
    CALL populate_subeventstatus_rec(opname,"Z","No records qualified",logmsg,recorddata)
    GO TO exit_script
   ENDIF
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2
  ) =i2)
   RETURN(error_and_zero_check_rec(qualnum,opname,logmsg,errorforceexit,zeroforceexit,
    reply))
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_rec(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),recorddata=vc(ref)) =i2)
   IF (validate(recorddata->status_data.status,"-1") != "-1")
    SET lcrslsubeventcnt = size(recorddata->status_data.subeventstatus,5)
    SET lcrslsubeventsize = size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      operationname))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      operationstatus))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectname))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectvalue))
    IF (lcrslsubeventsize > 0)
     SET lcrslsubeventcnt += 1
     SET icrslloggingstat = alter(recorddata->status_data.subeventstatus,lcrslsubeventcnt)
    ENDIF
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].targetobjectvalue =
    targetobjectvalue
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   CALL populate_subeventstatus_rec(operationname,operationstatus,targetobjectname,targetobjectvalue,
    reply)
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) =i2)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 SUBROUTINE (check_log_level(arg_log_level=i4) =i2)
   IF (((crsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 DECLARE filterdoccomponentdetails(null) = null WITH protect
 SUBROUTINE (checkforexistingactivepathway(pathwayname=vc,pathwaytypecd=f8,logicaldomainid=f8) =f8
  WITH protect)
   CALL log_message("Begin CheckForExistingPathway()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE active_pathway_status = f8 WITH constant(uar_get_code_by("MEANING",4003198,"ACTIVE")),
   protect
   DECLARE existingpathwayid = f8 WITH noconstant(- (1)), protect
   SELECT INTO "NL:"
    FROM cp_pathway cp
    WHERE cp.logical_domain_id=logicaldomainid
     AND cnvtupper(cp.pathway_name)=cnvtupper(pathwayname)
     AND cp.pathway_status_cd=active_pathway_status
     AND cp.pathway_type_cd=pathwaytypecd
    DETAIL
     existingpathwayid = cp.cp_pathway_id
    WITH nocounter
   ;end select
   IF (validate(debug_ind,0))
    CALL echo(build("ExistingPathwayId: ",existingpathwayid))
   ENDIF
   CALL log_message(build("Exit CheckForExistingPathway(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
   RETURN(existingpathwayid)
 END ;Subroutine
 SUBROUTINE (decodexmlspecialcharacters(identifier=vc) =vc WITH protect)
   CALL log_message("In decodeXmlSpecialCharacters()",log_level_debug)
   SET identifier = replace(identifier,"&gt;",">",0)
   SET identifier = replace(identifier,"&lt;","<",0)
   SET identifier = replace(identifier,"&#34;",'"',0)
   SET identifier = replace(identifier,"&#39;","'",0)
   RETURN(identifier)
   CALL log_message("Exit decodeXmlSpecialCharacters()",log_level_debug)
 END ;Subroutine
 SUBROUTINE (encodeinternationalcharacters(stringtoencode=vc) =vc WITH protect)
   CALL log_message("In encodeInternationalCharacters()",log_level_debug)
   DECLARE encodedstring = vc WITH protect, noconstant(stringtoencode)
   SET encodedstring = replace(encodedstring,"","~#192;",0)
   SET encodedstring = replace(encodedstring,"","~#193;",0)
   SET encodedstring = replace(encodedstring,"","~#194;",0)
   SET encodedstring = replace(encodedstring,"","~#195;",0)
   SET encodedstring = replace(encodedstring,"","~#196;",0)
   SET encodedstring = replace(encodedstring,"","~#197;",0)
   SET encodedstring = replace(encodedstring,"","~#198;",0)
   SET encodedstring = replace(encodedstring,"","~#199;",0)
   SET encodedstring = replace(encodedstring,"","~#200;",0)
   SET encodedstring = replace(encodedstring,"","~#201;",0)
   SET encodedstring = replace(encodedstring,"","~#202;",0)
   SET encodedstring = replace(encodedstring,"","~#203;",0)
   SET encodedstring = replace(encodedstring,"","~#204;",0)
   SET encodedstring = replace(encodedstring,"","~#205;",0)
   SET encodedstring = replace(encodedstring,"","~#206;",0)
   SET encodedstring = replace(encodedstring,"","~#207;",0)
   SET encodedstring = replace(encodedstring,"","~#208;",0)
   SET encodedstring = replace(encodedstring,"","~#209;",0)
   SET encodedstring = replace(encodedstring,"","~#210;",0)
   SET encodedstring = replace(encodedstring,"","~#211;",0)
   SET encodedstring = replace(encodedstring,"","~#212;",0)
   SET encodedstring = replace(encodedstring,"","~#213;",0)
   SET encodedstring = replace(encodedstring,"","~#214;",0)
   SET encodedstring = replace(encodedstring,"","~#216;",0)
   SET encodedstring = replace(encodedstring,"","~#217;",0)
   SET encodedstring = replace(encodedstring,"","~#218;",0)
   SET encodedstring = replace(encodedstring,"","~#219;",0)
   SET encodedstring = replace(encodedstring,"","~#220;",0)
   SET encodedstring = replace(encodedstring,"","~#221;",0)
   SET encodedstring = replace(encodedstring,"","~#222;",0)
   SET encodedstring = replace(encodedstring,"","~#223;",0)
   SET encodedstring = replace(encodedstring,"","~#224;",0)
   SET encodedstring = replace(encodedstring,"","~#225;",0)
   SET encodedstring = replace(encodedstring,"","~#226;",0)
   SET encodedstring = replace(encodedstring,"","~#227;",0)
   SET encodedstring = replace(encodedstring,"","~#228;",0)
   SET encodedstring = replace(encodedstring,"","~#229;",0)
   SET encodedstring = replace(encodedstring,"","~#230;",0)
   SET encodedstring = replace(encodedstring,"","~#231;",0)
   SET encodedstring = replace(encodedstring,"","~#232;",0)
   SET encodedstring = replace(encodedstring,"","~#233;",0)
   SET encodedstring = replace(encodedstring,"","~#234;",0)
   SET encodedstring = replace(encodedstring,"","~#235;",0)
   SET encodedstring = replace(encodedstring,"","~#236;",0)
   SET encodedstring = replace(encodedstring,"","~#237;",0)
   SET encodedstring = replace(encodedstring,"","~#238;",0)
   SET encodedstring = replace(encodedstring,"","~#239;",0)
   SET encodedstring = replace(encodedstring,"","~#240;",0)
   SET encodedstring = replace(encodedstring,"","~#241;",0)
   SET encodedstring = replace(encodedstring,"","~#242;",0)
   SET encodedstring = replace(encodedstring,"","~#243;",0)
   SET encodedstring = replace(encodedstring,"","~#244;",0)
   SET encodedstring = replace(encodedstring,"","~#245;",0)
   SET encodedstring = replace(encodedstring,"","~#246;",0)
   SET encodedstring = replace(encodedstring,"","~#248;",0)
   SET encodedstring = replace(encodedstring,"","~#249;",0)
   SET encodedstring = replace(encodedstring,"","~#250;",0)
   SET encodedstring = replace(encodedstring,"","~#251;",0)
   SET encodedstring = replace(encodedstring,"","~#252;",0)
   SET encodedstring = replace(encodedstring,"","~#253;",0)
   SET encodedstring = replace(encodedstring,"","~#254;",0)
   SET encodedstring = replace(encodedstring,"","~#255;",0)
   SET encodedstring = replace(encodedstring,"","~#338;",0)
   SET encodedstring = replace(encodedstring,"","~#339;",0)
   SET encodedstring = replace(encodedstring,"","~#352;",0)
   SET encodedstring = replace(encodedstring,"","~#353;",0)
   SET encodedstring = replace(encodedstring,"","~#376;",0)
   SET encodedstring = replace(encodedstring,"","~#402;",0)
   SET encodedstring = replace(encodedstring,"","~#142;",0)
   SET encodedstring = replace(encodedstring,"","~#158;",0)
   SET encodedstring = replace(encodedstring,"","~#161;",0)
   SET encodedstring = replace(encodedstring,"","~#162;",0)
   SET encodedstring = replace(encodedstring,"","~#164;",0)
   SET encodedstring = replace(encodedstring,"","~#165;",0)
   SET encodedstring = replace(encodedstring,"","~#166;",0)
   SET encodedstring = replace(encodedstring,"","~#167;",0)
   SET encodedstring = replace(encodedstring,"","~#168;",0)
   SET encodedstring = replace(encodedstring,"","~#169;",0)
   SET encodedstring = replace(encodedstring,"","~#170;",0)
   SET encodedstring = replace(encodedstring,"","~#171;",0)
   SET encodedstring = replace(encodedstring,"","~#172;",0)
   SET encodedstring = replace(encodedstring,"","~#174;",0)
   SET encodedstring = replace(encodedstring,"","~#175;",0)
   SET encodedstring = replace(encodedstring,"","~#176;",0)
   SET encodedstring = replace(encodedstring,"","~#177;",0)
   SET encodedstring = replace(encodedstring,"","~#179;",0)
   SET encodedstring = replace(encodedstring,"","~#178;",0)
   SET encodedstring = replace(encodedstring,"","~#180;",0)
   SET encodedstring = replace(encodedstring,"","~#181;",0)
   SET encodedstring = replace(encodedstring,"","~#182;",0)
   SET encodedstring = replace(encodedstring,"","~#183;",0)
   SET encodedstring = replace(encodedstring,"","~#184;",0)
   SET encodedstring = replace(encodedstring,"","~#185;",0)
   SET encodedstring = replace(encodedstring,"","~#186;",0)
   SET encodedstring = replace(encodedstring,"","~#187;",0)
   SET encodedstring = replace(encodedstring,"","~#188;",0)
   SET encodedstring = replace(encodedstring,"","~#189;",0)
   SET encodedstring = replace(encodedstring,"","~#190;",0)
   SET encodedstring = replace(encodedstring,"","~#191;",0)
   SET encodedstring = replace(encodedstring,"","~#247;",0)
   SET encodedstring = replace(encodedstring,"","~#215;",0)
   SET encodedstring = replace(encodedstring,"","~#136;",0)
   SET encodedstring = replace(encodedstring,"","~#152;",0)
   SET encodedstring = replace(encodedstring,"","~#150;",0)
   SET encodedstring = replace(encodedstring,"","~#151;",0)
   SET encodedstring = replace(encodedstring,"","~#145;",0)
   SET encodedstring = replace(encodedstring,"","~#146;",0)
   SET encodedstring = replace(encodedstring,"","~#130;",0)
   SET encodedstring = replace(encodedstring,"","~#147;",0)
   SET encodedstring = replace(encodedstring,"","~#148;",0)
   SET encodedstring = replace(encodedstring,"","~#132;",0)
   SET encodedstring = replace(encodedstring,"","~#134;",0)
   SET encodedstring = replace(encodedstring,"","~#135;",0)
   SET encodedstring = replace(encodedstring,"","~#149;",0)
   SET encodedstring = replace(encodedstring,"","~#133;",0)
   SET encodedstring = replace(encodedstring,"","~#137;",0)
   SET encodedstring = replace(encodedstring,"","~#139;",0)
   SET encodedstring = replace(encodedstring,"","~#155;",0)
   SET encodedstring = replace(encodedstring,"","~#128;",0)
   SET encodedstring = replace(encodedstring,"","~#153;",0)
   SET encodedstring = replace(encodedstring,"","~#163;",0)
   RETURN(encodedstring)
   CALL log_message("Exit encodeInternationalCharacters()",log_level_debug)
 END ;Subroutine
 SUBROUTINE (decodeinternationalcharacters(stringtodecode=vc) =vc WITH protect)
   CALL log_message("In decodeInternationalCharacters()",log_level_debug)
   DECLARE decodedstring = vc WITH protect, noconstant(stringtodecode)
   SET decodedstring = replace(decodedstring,"~#192;","",0)
   SET decodedstring = replace(decodedstring,"~#193;","",0)
   SET decodedstring = replace(decodedstring,"~#194;","",0)
   SET decodedstring = replace(decodedstring,"~#195;","",0)
   SET decodedstring = replace(decodedstring,"~#196;","",0)
   SET decodedstring = replace(decodedstring,"~#197;","",0)
   SET decodedstring = replace(decodedstring,"~#198;","",0)
   SET decodedstring = replace(decodedstring,"~#199;","",0)
   SET decodedstring = replace(decodedstring,"~#200;","",0)
   SET decodedstring = replace(decodedstring,"~#201;","",0)
   SET decodedstring = replace(decodedstring,"~#202;","",0)
   SET decodedstring = replace(decodedstring,"~#203;","",0)
   SET decodedstring = replace(decodedstring,"~#204;","",0)
   SET decodedstring = replace(decodedstring,"~#205;","",0)
   SET decodedstring = replace(decodedstring,"~#206;","",0)
   SET decodedstring = replace(decodedstring,"~#207;","",0)
   SET decodedstring = replace(decodedstring,"~#208;","",0)
   SET decodedstring = replace(decodedstring,"~#209;","",0)
   SET decodedstring = replace(decodedstring,"~#210;","",0)
   SET decodedstring = replace(decodedstring,"~#211;","",0)
   SET decodedstring = replace(decodedstring,"~#212;","",0)
   SET decodedstring = replace(decodedstring,"~#213;","",0)
   SET decodedstring = replace(decodedstring,"~#214;","",0)
   SET decodedstring = replace(decodedstring,"~#216;","",0)
   SET decodedstring = replace(decodedstring,"~#217;","",0)
   SET decodedstring = replace(decodedstring,"~#218;","",0)
   SET decodedstring = replace(decodedstring,"~#219;","",0)
   SET decodedstring = replace(decodedstring,"~#220;","",0)
   SET decodedstring = replace(decodedstring,"~#221;","",0)
   SET decodedstring = replace(decodedstring,"~#222;","",0)
   SET decodedstring = replace(decodedstring,"~#223;","",0)
   SET decodedstring = replace(decodedstring,"~#224;","",0)
   SET decodedstring = replace(decodedstring,"~#225;","",0)
   SET decodedstring = replace(decodedstring,"~#226;","",0)
   SET decodedstring = replace(decodedstring,"~#227;","",0)
   SET decodedstring = replace(decodedstring,"~#228;","",0)
   SET decodedstring = replace(decodedstring,"~#229;","",0)
   SET decodedstring = replace(decodedstring,"~#230;","",0)
   SET decodedstring = replace(decodedstring,"~#231;","",0)
   SET decodedstring = replace(decodedstring,"~#232;","",0)
   SET decodedstring = replace(decodedstring,"~#233;","",0)
   SET decodedstring = replace(decodedstring,"~#234;","",0)
   SET decodedstring = replace(decodedstring,"~#235;","",0)
   SET decodedstring = replace(decodedstring,"~#236;","",0)
   SET decodedstring = replace(decodedstring,"~#237;","",0)
   SET decodedstring = replace(decodedstring,"~#238;","",0)
   SET decodedstring = replace(decodedstring,"~#239;","",0)
   SET decodedstring = replace(decodedstring,"~#240;","",0)
   SET decodedstring = replace(decodedstring,"~#241;","",0)
   SET decodedstring = replace(decodedstring,"~#242;","",0)
   SET decodedstring = replace(decodedstring,"~#243;","",0)
   SET decodedstring = replace(decodedstring,"~#244;","",0)
   SET decodedstring = replace(decodedstring,"~#245;","",0)
   SET decodedstring = replace(decodedstring,"~#246;","",0)
   SET decodedstring = replace(decodedstring,"~#248;","",0)
   SET decodedstring = replace(decodedstring,"~#249;","",0)
   SET decodedstring = replace(decodedstring,"~#250;","",0)
   SET decodedstring = replace(decodedstring,"~#251;","",0)
   SET decodedstring = replace(decodedstring,"~#252;","",0)
   SET decodedstring = replace(decodedstring,"~#253;","",0)
   SET decodedstring = replace(decodedstring,"~#254;","",0)
   SET decodedstring = replace(decodedstring,"~#255;","",0)
   SET decodedstring = replace(decodedstring,"~#338;","",0)
   SET decodedstring = replace(decodedstring,"~#339;","",0)
   SET decodedstring = replace(decodedstring,"~#352;","",0)
   SET decodedstring = replace(decodedstring,"~#353;","",0)
   SET decodedstring = replace(decodedstring,"~#376;","",0)
   SET decodedstring = replace(decodedstring,"~#402;","",0)
   SET decodedstring = replace(decodedstring,"~#142;","",0)
   SET decodedstring = replace(decodedstring,"~#158;","",0)
   SET decodedstring = replace(decodedstring,"~#161;","",0)
   SET decodedstring = replace(decodedstring,"~#162;","",0)
   SET decodedstring = replace(decodedstring,"~#164;","",0)
   SET decodedstring = replace(decodedstring,"~#165;","",0)
   SET decodedstring = replace(decodedstring,"~#166;","",0)
   SET decodedstring = replace(decodedstring,"~#167;","",0)
   SET decodedstring = replace(decodedstring,"~#168;","",0)
   SET decodedstring = replace(decodedstring,"~#169;","",0)
   SET decodedstring = replace(decodedstring,"~#170;","",0)
   SET decodedstring = replace(decodedstring,"~#171;","",0)
   SET decodedstring = replace(decodedstring,"~#172;","",0)
   SET decodedstring = replace(decodedstring,"~#174;","",0)
   SET decodedstring = replace(decodedstring,"~#175;","",0)
   SET decodedstring = replace(decodedstring,"~#176;","",0)
   SET decodedstring = replace(decodedstring,"~#177;","",0)
   SET decodedstring = replace(decodedstring,"~#178;","",0)
   SET decodedstring = replace(decodedstring,"~#179;","",0)
   SET decodedstring = replace(decodedstring,"~#180;","",0)
   SET decodedstring = replace(decodedstring,"~#181;","",0)
   SET decodedstring = replace(decodedstring,"~#182;","",0)
   SET decodedstring = replace(decodedstring,"~#183;","",0)
   SET decodedstring = replace(decodedstring,"~#184;","",0)
   SET decodedstring = replace(decodedstring,"~#185;","",0)
   SET decodedstring = replace(decodedstring,"~#186;","",0)
   SET decodedstring = replace(decodedstring,"~#187;","",0)
   SET decodedstring = replace(decodedstring,"~#188;","",0)
   SET decodedstring = replace(decodedstring,"~#189;","",0)
   SET decodedstring = replace(decodedstring,"~#190;","",0)
   SET decodedstring = replace(decodedstring,"~#191;","",0)
   SET decodedstring = replace(decodedstring,"~#247;","",0)
   SET decodedstring = replace(decodedstring,"~#215;","",0)
   SET decodedstring = replace(decodedstring,"~#136;","",0)
   SET decodedstring = replace(decodedstring,"~#152;","",0)
   SET decodedstring = replace(decodedstring,"~#150;","",0)
   SET decodedstring = replace(decodedstring,"~#151;","",0)
   SET decodedstring = replace(decodedstring,"~#145;","",0)
   SET decodedstring = replace(decodedstring,"~#146;","",0)
   SET decodedstring = replace(decodedstring,"~#130;","",0)
   SET decodedstring = replace(decodedstring,"~#147;","",0)
   SET decodedstring = replace(decodedstring,"~#148;","",0)
   SET decodedstring = replace(decodedstring,"~#132;","",0)
   SET decodedstring = replace(decodedstring,"~#134;","",0)
   SET decodedstring = replace(decodedstring,"~#135;","",0)
   SET decodedstring = replace(decodedstring,"~#149;","",0)
   SET decodedstring = replace(decodedstring,"~#133;","",0)
   SET decodedstring = replace(decodedstring,"~#137;","",0)
   SET decodedstring = replace(decodedstring,"~#139;","",0)
   SET decodedstring = replace(decodedstring,"~#155;","",0)
   SET decodedstring = replace(decodedstring,"~#128;","",0)
   SET decodedstring = replace(decodedstring,"~#153;","",0)
   SET decodedstring = replace(decodedstring,"~#163;","",0)
   RETURN(decodedstring)
   CALL log_message("Exit decodeInternationalCharacters()",log_level_debug)
 END ;Subroutine
 SUBROUTINE (checkforexistingconcept(conceptdisplay=vc) =f8 WITH protect)
   CALL log_message("Begin CheckForExistingConcept()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE conceptcodeset = i4 WITH constant(4003132), protect
   DECLARE conceptid = f8 WITH noconstant(- (1)), protect
   DECLARE displaykey = vc WITH noconstant(""), protect
   SET displaykey = trim(cnvtupper(cnvtalphanum(substring(1,40,conceptdisplay))))
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=conceptcodeset
     AND cv.display_key=displaykey
     AND cv.active_ind=1
    DETAIL
     conceptid = cv.code_value
    WITH nocounter
   ;end select
   IF (validate(debug_ind,0))
    CALL echo(build("ExistingConceptId: ",conceptid))
   ENDIF
   CALL log_message(build("Exit CheckForExistingConcept(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
   RETURN(conceptid)
 END ;Subroutine
 SUBROUTINE filterdoccomponentdetails(null)
   CALL log_message("In filterDocComponentDetails()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE node_cntr = i4 WITH noconstant(0), protect
   DECLARE node_size = i4 WITH noconstant(0), protect
   DECLARE act_node_size = i4 WITH noconstant(0), protect
   DECLARE act_node_indx = i4 WITH noconstant(0), protect
   DECLARE doc_comp_indx = i4 WITH noconstant(0), protect
   DECLARE doc_comp_det_indx = i4 WITH noconstant(0), protect
   DECLARE search_cntr = i4 WITH noconstant(0), protect
   DECLARE cur_comp_det_version_nbr = i4 WITH noconstant(0), protect
   DECLARE latest_doc_content_det_indx = i4 WITH noconstant(0), protect
   DECLARE latest_doc_events_det_indx = i4 WITH noconstant(0), protect
   DECLARE latest_doc_decor_det_indx = i4 WITH noconstant(0), protect
   DECLARE comp_det_doc_content_mean = vc WITH constant("DOCCONTENT"), protect
   DECLARE comp_det_doc_events_mean = vc WITH constant("DOCEVENTS"), protect
   DECLARE comp_det_term_dec_mean = vc WITH constant("DOCTERMDEC"), protect
   SET node_size = size(reply->node_list,5)
   SET act_node_size = size(reply->pathway_instance.pathway_actions.node_list,5)
   FOR (node_cntr = 1 TO node_size)
     SET doc_comp_indx = locateval(search_cntr,1,size(reply->node_list[node_cntr].component_list,5),
      "GUIDEDTRMNT",reply->node_list[node_cntr].component_list[search_cntr].comp_type_cd_meaning)
     IF (doc_comp_indx=0)
      SET doc_comp_indx = locateval(search_cntr,1,size(reply->node_list[node_cntr].component_list,5),
       "PATHWAY_DOC",reply->node_list[node_cntr].component_list[search_cntr].comp_type_cd_meaning)
     ENDIF
     IF (doc_comp_indx > 0)
      SET latest_doc_content_det_indx = locateval(search_cntr,1,size(reply->node_list[node_cntr].
        component_list[doc_comp_indx].comp_detail_list,5),1,reply->node_list[node_cntr].
       component_list[doc_comp_indx].comp_detail_list[search_cntr].default_ind,
       comp_det_doc_content_mean,reply->node_list[node_cntr].component_list[doc_comp_indx].
       comp_detail_list[search_cntr].detail_reltn_cd_mean)
      IF (latest_doc_content_det_indx > 0)
       SET reply->node_list[node_cntr].current_assoc_doc_instance_ident = reply->node_list[node_cntr]
       .component_list[doc_comp_indx].comp_detail_list[latest_doc_content_det_indx].entity_ident
       SET reply->node_list[node_cntr].current_assoc_doc_version_text = reply->node_list[node_cntr].
       component_list[doc_comp_indx].comp_detail_list[latest_doc_content_det_indx].version_text
       SET reply->node_list[node_cntr].current_assoc_doc_version_flag = reply->node_list[node_cntr].
       component_list[doc_comp_indx].comp_detail_list[latest_doc_content_det_indx].version_flag
       SET latest_doc_events_det_indx = locateval(search_cntr,1,size(reply->node_list[node_cntr].
         component_list[doc_comp_indx].comp_detail_list,5),1,reply->node_list[node_cntr].
        component_list[doc_comp_indx].comp_detail_list[search_cntr].default_ind,
        comp_det_doc_events_mean,reply->node_list[node_cntr].component_list[doc_comp_indx].
        comp_detail_list[search_cntr].detail_reltn_cd_mean)
       IF (latest_doc_events_det_indx > 0)
        SET reply->node_list[node_cntr].current_assoc_doc_events_id = reply->node_list[node_cntr].
        component_list[doc_comp_indx].comp_detail_list[latest_doc_events_det_indx].entity_id
       ENDIF
       SET latest_doc_decor_det_indx = locateval(search_cntr,1,size(reply->node_list[node_cntr].
         component_list[doc_comp_indx].comp_detail_list,5),1,reply->node_list[node_cntr].
        component_list[doc_comp_indx].comp_detail_list[search_cntr].default_ind,
        comp_det_term_dec_mean,reply->node_list[node_cntr].component_list[doc_comp_indx].
        comp_detail_list[search_cntr].detail_reltn_cd_mean)
       IF (latest_doc_decor_det_indx > 0)
        SET reply->node_list[node_cntr].current_assoc_doc_decor_id = reply->node_list[node_cntr].
        component_list[doc_comp_indx].comp_detail_list[latest_doc_decor_det_indx].entity_id
       ENDIF
       SET cur_comp_det_version_nbr = - (1)
       SET act_node_indx = locateval(search_cntr,1,act_node_size,reply->node_list[node_cntr].
        cp_node_id,reply->pathway_instance.pathway_actions.node_list[search_cntr].node_id)
       IF (act_node_indx > 0)
        IF (textlen(trim(reply->pathway_instance.pathway_actions.node_list[act_node_indx].
          last_saved_doc_instance_ident)) > 0)
         SET reply->node_list[node_cntr].last_saved_doc_instance_ident = reply->pathway_instance.
         pathway_actions.node_list[act_node_indx].last_saved_doc_instance_ident
         SET doc_comp_det_indx = locateval(search_cntr,1,size(reply->node_list[node_cntr].
           component_list[doc_comp_indx].comp_detail_list,5),reply->pathway_instance.pathway_actions.
          node_list[act_node_indx].last_saved_doc_instance_ident,reply->node_list[node_cntr].
          component_list[doc_comp_indx].comp_detail_list[search_cntr].entity_ident)
         IF (doc_comp_det_indx > 0)
          SET cur_comp_det_version_nbr = reply->node_list[node_cntr].component_list[doc_comp_indx].
          comp_detail_list[doc_comp_det_indx].version_nbr
         ENDIF
        ENDIF
       ENDIF
       IF ((cur_comp_det_version_nbr > - (1)))
        CALL filtercomponentdetails(node_cntr,doc_comp_indx,build2("version_nbr = ",
          cur_comp_det_version_nbr))
       ELSE
        CALL filtercomponentdetails(node_cntr,doc_comp_indx,"default_ind = 1")
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   CALL log_message(build("Exit filterDocComponentDetails(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (filtercomponentdetails(nodeindx=i4,compindx=i4,comparefield=vc) =null WITH protect)
   CALL log_message("In filterComponentDetails()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE det_cntr = i4 WITH noconstant(1), protect
   DECLARE det_size = i4 WITH noconstant(0), protect
   DECLARE to_keep = i4 WITH noconstant(0), protect
   DECLARE compare_eval = vc WITH noconstant(""), protect
   SET det_size = size(reply->node_list[nodeindx].component_list[compindx].comp_detail_list,5)
   WHILE (det_cntr <= det_size)
     SET compare_eval = build("reply->node_list[",nodeindx,"]->component_list[",compindx,
      "]->comp_detail_list[",
      det_cntr,"].",comparefield)
     IF (validate(debug_ind,0)=1)
      CALL echo(build(" det_cntr -- > ",det_cntr))
      CALL echo(build(" det_size -- > ",det_size))
      CALL echo(build(" compare_eval -- > ",compare_eval))
      CALL echo(build(" parser(compare_eval) -- > ",parser(compare_eval)))
     ENDIF
     IF ((reply->node_list[nodeindx].component_list[compindx].comp_detail_list[det_cntr].
     detail_reltn_cd_mean="ORDEROPTS"))
      SET to_keep += 1
      SET det_cntr += 1
     ELSEIF ( NOT (parser(compare_eval)))
      SET stat = alterlist(reply->node_list[nodeindx].component_list[compindx].comp_detail_list,(
       det_size - 1),to_keep)
      SET det_size = size(reply->node_list[nodeindx].component_list[compindx].comp_detail_list,5)
     ELSE
      SET to_keep += 1
      SET det_cntr += 1
     ENDIF
   ENDWHILE
   CALL log_message(build("Exit filterComponentDetails(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 DECLARE loadcomponentdetails(null) = null WITH protect
 DECLARE generatejsonrecord(null) = null WITH protect
 DECLARE getrecommendationcategories(null) = null WITH protect
 DECLARE gettreatmentlineforpathway(null) = null WITH protect
 DECLARE retrievecompversionnumbers(null) = null WITH protect
 DECLARE iintentioncodeset = i4 WITH protect, constant(4003278)
 DECLARE iconceptgroupcodeset = i4 WITH protect, constant(4003133)
 DECLARE idetailattributetypecodeset = i4 WITH protect, constant(4003333)
 DECLARE ipathwaytypecodeset = i4 WITH protect, constant(4003197)
 DECLARE itreatmentlinetypecodeset = i4 WITH protect, constant(4003313)
 DECLARE icompdetailreltncodeset = i4 WITH protect, constant(4003134)
 DECLARE igendercodeset = i4 WITH protect, constant(57)
 DECLARE doccontenttypecd = f8 WITH constant(uar_get_code_by("MEANING",4003134,"DOCCONTENT")),
 protect
 DECLARE cp_pathway_name = vc WITH protect, noconstant("")
 DECLARE cp_node_name = vc WITH protect, noconstant("")
 DECLARE cp_component_id = f8 WITH protect, constant( $CP_COMPONENT_ID)
 DECLARE cp_pathway_type_mean = vc WITH protect, noconstant("")
 DECLARE cp_node_id = f8 WITH protect, constant(getnodeid(cp_component_id))
 DECLARE cp_pathway_id = f8 WITH protect, constant(getpathwayid(cp_node_id))
 DECLARE curr_comp_version_nbr = i4 WITH protect, noconstant(0)
 DECLARE documentation_clin_ident = vc WITH protect, noconstant("")
 DECLARE documentation_events_id = f8 WITH protect, noconstant(0)
 DECLARE documentation_decor_id = f8 WITH protect, noconstant(0)
 DECLARE documentation_layout_id = f8 WITH protect, noconstant(0)
 DECLARE documentation_source_flag = i2 WITH protect, noconstant(0)
 DECLARE compversion = i4 WITH protect, constant( $COMP_VERSION)
 DECLARE strdocversionnbr = i4 WITH protect, noconstant(0)
 SUBROUTINE main(null)
   CALL log_message("In main()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH private, constant(curtime3)
   SET json_data_record->status_data.status = "S"
   CALL loadcomponentdetails(cp_component_id)
   CALL retrievecompversionnumbers(cp_component_id)
   CALL getcompdetailreltncodes(null)
   EXECUTE cp_load_structure_doc:dba "NOFORMS", nullterm(documentation_clin_ident), value(
    documentation_events_id),
   value(documentation_decor_id), 1, compversion,
   cp_component_id WITH replace("STRUCTURE_REPLY","RECORD_DATA")
   CALL gettreatmentlineforpathway(null)
   SET record_data->document_layout.json = getlayoutjson(documentation_layout_id)
   SET record_data->behaviors.json = getbehaviorsjson(cp_pathway_id,cp_node_id)
   IF (validate(debug_ind,0)=1)
    CALL echorecord(record_data)
   ENDIF
   CALL getorderoptionsbycategory(cp_component_id)
   CALL getrecommendationcategories(null)
   RECORD code_set_rec(
     1 cnt = i4
     1 qual[*]
       2 value = i4
   )
   SET stat = alterlist(code_set_rec->qual,1)
   SET code_set_rec->cnt = 1
   SET code_set_rec->qual[1].value = igendercodeset
   CALL getcodesetvalues(code_set_rec)
   CALL generatejsonrecord(null)
   CALL log_message(build("Exit main(), Elapsed time in seconds:",((curtime3 - begin_date_time)/ 100)
     ),log_level_debug)
 END ;Subroutine
 SUBROUTINE (getcodesetvalues(code_set_rec=vc(ref)) =null WITH protect)
   CALL log_message("In GetCodeSetValues()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH private, constant(curtime3)
   DECLARE cindx = i4 WITH protect, noconstant(0)
   DECLARE cvcnt = i4 WITH protect, noconstant(0)
   DECLARE cssize = i4 WITH protect, noconstant(size(code_set_values->code_sets,5))
   DECLARE cvsize = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE expand(cindx,1,code_set_rec->cnt,cv.code_set,code_set_rec->qual[cindx].value)
     AND cv.active_ind=1
    ORDER BY cv.code_set, cv.code_value
    HEAD cv.code_set
     cssize += 1, stat = alterlist(code_set_values->code_sets,cssize), code_set_values->code_set_cnt
      = cssize,
     code_set_values->code_sets[cssize].code_set = cv.code_set, cvsize = size(code_set_values->
      code_sets[cssize].code_values,5)
    HEAD cv.code_value
     cvsize += 1
     IF (((cvsize=1) OR (mod(cvsize,10)=1)) )
      stat = alterlist(code_set_values->code_sets[cssize].code_values,(cvsize+ 9))
     ENDIF
     code_set_values->code_sets[cssize].code_values[cvsize].code_value = cv.code_value,
     code_set_values->code_sets[cssize].code_values[cvsize].display = cv.display, code_set_values->
     code_sets[cssize].code_values[cvsize].meaning = cv.cdf_meaning,
     code_set_values->code_sets[cssize].code_values[cvsize].code_value = cv.code_value,
     code_set_values->code_sets[cssize].code_values[cvsize].description = cv.description,
     code_set_values->code_sets[cssize].code_values[cvsize].cki = cv.cki,
     code_set_values->code_sets[cssize].code_values[cvsize].concept_cki = cv.concept_cki,
     code_set_values->code_sets[cssize].code_values[cvsize].display_key = cv.display_key,
     code_set_values->code_sets[cssize].code_values[cvsize].defination = cv.definition
    FOOT  cv.code_set
     stat = alterlist(code_set_values->code_sets[cssize].code_values,cvsize), code_set_values->
     code_sets[cssize].code_value_cnt = cvsize
    WITH nocounter
   ;end select
   CALL log_message(build("Exit GetCodeSetValues(), Elapsed time in seconds:",((curtime3 -
     begin_date_time)/ 100)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getcompdetailreltncodes(null)
   CALL log_message("In getCompDetailReltnCodes()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH private, constant(curtime3)
   DECLARE cnt = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=icompdetailreltncodeset
      AND cv.active_ind=1
      AND cv.code_value > 0)
    HEAD cv.code_value
     cnt += 1, stat = alterlist(code_values->codes,cnt), code_values->codes[cnt].display = cv.display,
     code_values->codes[cnt].meaning = cv.cdf_meaning, code_values->codes[cnt].value = cv.code_value
    FOOT REPORT
     code_values->code_cnt = cnt, stat = alterlist(code_values->codes,cnt)
    WITH nocounter
   ;end select
   CALL log_message(build("Exit getCompDetailReltnCodes(), Elapsed time in seconds:",((curtime3 -
     begin_date_time)/ 100)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (getnodeid(cp_component_id=f8) =f8 WITH protect)
   CALL log_message("In GetNodeId()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH private, constant(curtime3)
   DECLARE node_id = f8 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM cp_component cc,
     cp_node cn
    PLAN (cc
     WHERE cc.cp_component_id=cp_component_id)
     JOIN (cn
     WHERE cn.cp_node_id=cc.cp_node_id)
    DETAIL
     cp_node_name = cn.node_display, node_id = cc.cp_node_id
    WITH nocounter
   ;end select
   IF (node_id <= 0)
    SET json_data_record->status_data.status = "F"
    SET json_data_record->status_data.subeventstatus[1].operationname = "GetNodeId"
    SET json_data_record->status_data.subeventstatus[1].operationstatus = "F"
    SET json_data_record->status_data.subeventstatus[1].targetobjectname = "NodeID"
    SET json_data_record->status_data.subeventstatus[1].targetobjectvalue = "0"
    GO TO exit_script
   ENDIF
   CALL log_message(build("Exit GetNodeId(), Elapsed time in seconds:",((curtime3 - begin_date_time)
     / 100)),log_level_debug)
   RETURN(node_id)
 END ;Subroutine
 SUBROUTINE (getorderoptionsbycategory(cp_component_id=f8) =f8 WITH protect)
   CALL log_message("In GetOrderOptionsByCategory()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH private, constant(curtime3)
   EXECUTE cp_get_pathway_comp_reco "NOFORMS", cp_component_id
   IF (validate(debug_ind,0)=1)
    CALL echorecord(recommendation_folders)
   ENDIF
   CALL log_message(build("Exit GetOrderOptionsByCategory(), Elapsed time in seconds:",((curtime3 -
     begin_date_time)/ 100)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (getpathwayid(cp_node_id=f8) =f8 WITH protect)
   CALL log_message("In GetPathwayId()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH private, constant(curtime3)
   DECLARE pathway_id = f8 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM cp_node cn,
     cp_pathway cp
    PLAN (cn
     WHERE cn.cp_node_id=cp_node_id)
     JOIN (cp
     WHERE cp.cp_pathway_id=cn.cp_pathway_id)
    DETAIL
     cp_pathway_name = cp.pathway_name, pathway_id = cn.cp_pathway_id, cp_pathway_type_mean =
     uar_get_code_meaning(cp.pathway_type_cd)
    WITH nocounter
   ;end select
   IF (cp_node_id <= 0)
    SET json_data_record->status_data.status = "F"
    SET json_data_record->status_data.subeventstatus[1].operationname = "GetPathwayId"
    SET json_data_record->status_data.subeventstatus[1].operationstatus = "F"
    SET json_data_record->status_data.subeventstatus[1].targetobjectname = "PathwayID"
    SET json_data_record->status_data.subeventstatus[1].targetobjectvalue = "0"
    GO TO exit_script
   ENDIF
   CALL log_message(build("Exit GetPathwayId(), Elapsed time in seconds:",((curtime3 -
     begin_date_time)/ 100)),log_level_debug)
   RETURN(pathway_id)
 END ;Subroutine
 SUBROUTINE (getlayoutjson(documentation_layout_id=f8) =vc WITH protect)
   CALL log_message("In GetLayoutJSON()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH private, constant(curtime3)
   DECLARE layout_json = vc WITH protect, noconstant("")
   DECLARE outbuf = vc WITH protect, noconstant("")
   DECLARE retlen = i4 WITH protect, noconstant(0)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE bloblen = i4 WITH protect, noconstant(0)
   DECLARE substring_str = vc WITH protect, noconstant("")
   DECLARE html_output = vc WITH protect, noconstant("")
   IF (documentation_layout_id > 0)
    SELECT INTO "nl:"
     FROM long_text_reference lt
     PLAN (lt
      WHERE lt.long_text_id=documentation_layout_id)
     HEAD REPORT
      outbuf = " ", retlen = 0
     HEAD lt.long_text_id
      offset = 0, bloblen = blobgetlen(lt.long_text),
      CALL echo(build(" bloblen -- > ",bloblen))
     DETAIL
      retlen = 1, stat = memrealloc(outbuf,1,build("C",bloblen)), retlen = blobget(outbuf,offset,lt
       .long_text)
      IF (offset=0)
       offset = 1
      ENDIF
      cnt = 0
      WHILE (offset < bloblen)
        substring_str = notrim(substring(offset,200,outbuf)), cnt += 1, layout_json = notrim(concat(
          layout_json,substring_str)),
        offset += 200
      ENDWHILE
     WITH rdbarrayfetch = 1, maxcol = 250, maxrec = 10
    ;end select
   ENDIF
   CALL log_message(build("Exit GetLayoutJSON(), Elapsed time in seconds:",((curtime3 -
     begin_date_time)/ 100)),log_level_debug)
   RETURN(layout_json)
 END ;Subroutine
 SUBROUTINE (getbehaviorsjson(cp_pathway_id=f8,cp_node_id=f8) =vc WITH protect)
   CALL log_message("In GetBehaviorsJSON()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH private, constant(curtime3)
   DECLARE behavior_json = vc WITH protect, noconstant("")
   DECLARE instance_ident = vc WITH protect, noconstant("")
   IF (cp_node_id > 0)
    IF (curr_comp_version_nbr > 0)
     SET instance_ident = decodeinternationalcharacters(documentation_clin_ident)
    ENDIF
    EXECUTE cp_get_node_bhvr:dba "NOFORMS", cp_pathway_id, value(cp_node_id),
    value(instance_ident) WITH replace("RECORD_DATA","BEHAVIORS")
    IF ((behaviors->cnt > 0))
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = behaviors->cnt),
       order_catalog_synonym ocs
      PLAN (d1
       WHERE (behaviors->qual[d1.seq].reaction_entity_name="ORDER_CATALOG_SYNONYM"))
       JOIN (ocs
       WHERE (ocs.synonym_id=behaviors->qual[d1.seq].reaction_entity_id))
      ORDER BY d1.seq
      HEAD d1.seq
       behaviors->qual[d1.seq].description = ocs.mnemonic
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = behaviors->cnt),
       order_sentence os,
       ord_cat_sent_r osr,
       order_catalog_synonym ocs
      PLAN (d1
       WHERE (behaviors->qual[d1.seq].reaction_entity_name="ORDER_SENTENCE"))
       JOIN (os
       WHERE (os.order_sentence_id=behaviors->qual[d1.seq].reaction_entity_id))
       JOIN (osr
       WHERE osr.order_sentence_id=os.order_sentence_id)
       JOIN (ocs
       WHERE ocs.synonym_id=osr.synonym_id)
      ORDER BY d1.seq
      HEAD d1.seq
       behaviors->qual[d1.seq].description = build2(ocs.mnemonic,"( ",os.order_sentence_display_line,
        " )")
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = behaviors->cnt),
       order_sentence os,
       order_catalog_synonym ocs
      PLAN (d1
       WHERE (behaviors->qual[d1.seq].reaction_entity_name="ORDER_SENTENCE")
        AND (behaviors->qual[d1.seq].description=""))
       JOIN (os
       WHERE (os.order_sentence_id=behaviors->qual[d1.seq].reaction_entity_id)
        AND os.parent_entity_name="ORDER_CATALOG_SYNONYM")
       JOIN (ocs
       WHERE ocs.synonym_id=os.parent_entity_id)
      ORDER BY d1.seq
      HEAD d1.seq
       behaviors->qual[d1.seq].description = build2(ocs.mnemonic,"( ",os.order_sentence_display_line,
        " )")
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = behaviors->cnt),
       cp_node c
      PLAN (d1
       WHERE (behaviors->qual[d1.seq].reaction_entity_name="CP_NODE"))
       JOIN (c
       WHERE (c.cp_node_id=behaviors->qual[d1.seq].reaction_entity_id))
      ORDER BY d1.seq
      HEAD d1.seq
       behaviors->qual[d1.seq].description = c.node_display
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = behaviors->cnt),
       regimen_catalog rc
      PLAN (d1
       WHERE (behaviors->qual[d1.seq].reaction_entity_name="REGIMEN_CATALOG"))
       JOIN (rc
       WHERE (rc.regimen_catalog_id=behaviors->qual[d1.seq].reaction_entity_id))
      ORDER BY d1.seq
      HEAD d1.seq
       behaviors->qual[d1.seq].description = rc.regimen_name
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = behaviors->cnt),
       pathway_catalog pc
      PLAN (d1
       WHERE (behaviors->qual[d1.seq].reaction_entity_name="PATHWAY_CATALOG"))
       JOIN (pc
       WHERE (pc.pathway_catalog_id=behaviors->qual[d1.seq].reaction_entity_id))
      ORDER BY d1.seq
      HEAD d1.seq
       behaviors->qual[d1.seq].description = pc.description
      WITH nocounter
     ;end select
     SELECT INTO "nl:"
      FROM (dummyt d1  WITH seq = behaviors->cnt),
       alt_sel_cat c
      PLAN (d1
       WHERE (behaviors->qual[d1.seq].reaction_entity_name="ALT_SEL_CAT"))
       JOIN (c
       WHERE (c.alt_sel_category_id=behaviors->qual[d1.seq].reaction_entity_id))
      ORDER BY d1.seq
      HEAD d1.seq
       behaviors->qual[d1.seq].description = c.long_description
      WITH nocounter
     ;end select
     DECLARE pos = i4 WITH noconstant(0), protect
     DECLARE idx = i4 WITH noconstant(0), protect
     SELECT INTO "nl:"
      FROM long_text_reference ltr
      PLAN (ltr
       WHERE expand(idx,1,size(behaviors->qual,5),"LONG_TEXT_REFERENCE",behaviors->qual[idx].
        reaction_entity_name,
        ltr.long_text_id,behaviors->qual[idx].reaction_entity_id))
      HEAD ltr.long_text_id
       pos = locateval(idx,1,size(behaviors->qual,5),"LONG_TEXT_REFERENCE",behaviors->qual[idx].
        reaction_entity_name,
        ltr.long_text_id,behaviors->qual[idx].reaction_entity_id)
       IF (pos > 0)
        behaviors->qual[pos].description = ltr.long_text
       ENDIF
      WITH nocounter, expand = 1
     ;end select
     SET behavior_json = cnvtrectojson(behaviors)
    ENDIF
   ENDIF
   CALL log_message(build("Exit GetBehaviorsJSON(), Elapsed time in seconds:",((curtime3 -
     begin_date_time)/ 100)),log_level_debug)
   RETURN(behavior_json)
 END ;Subroutine
 SUBROUTINE retrievecompversionnumbers(null)
   CALL log_message("In the retrieveCompVersionNumbers subroutine",log_level_debug)
   DECLARE begin_date_time = dq8 WITH private, constant(curtime3)
   DECLARE ccnt = i4 WITH noconstant(0), protect
   DECLARE curinstident = vc WITH protect, noconstant("")
   SELECT DISTINCT INTO "nl:"
    FROM cp_component_detail ccd,
     cp_component_detail ccd1
    PLAN (ccd
     WHERE ccd.cp_component_id=cp_component_id
      AND ccd.default_ind=1
      AND ccd.component_detail_reltn_cd=doccontenttypecd)
     JOIN (ccd1
     WHERE ccd1.cp_component_id=ccd.cp_component_id
      AND ccd1.version_nbr <= ccd.version_nbr
      AND ccd1.component_detail_reltn_cd=doccontenttypecd)
    ORDER BY ccd1.version_nbr
    HEAD ccd1.version_nbr
     ccnt += 1, stat = alterlist(comp_vrsn_nmbrs_rec->comp_vrsn_nmbrs,ccnt), comp_vrsn_nmbrs_rec->
     comp_vrsn_nmbrs[ccnt].version_nbr = ccd1.version_nbr,
     json_data_record->jscurrentcompver = ccd.version_nbr
    WITH nocounter
   ;end select
   SELECT DISTINCT INTO "nl:"
    FROM cp_component_detail ccd
    WHERE ccd.cp_component_id=cp_component_id
     AND ccd.component_detail_reltn_cd=doccontenttypecd
    ORDER BY ccd.version_nbr DESC
    HEAD REPORT
     json_data_record->jslatestcompver = ccd.version_nbr, curinstident = ccd.component_ident
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM dd_sref_template dst1,
     dd_sref_template dst2
    PLAN (dst1
     WHERE dst1.dd_sref_tmpl_instance_ident=curinstident)
     JOIN (dst2
     WHERE dst2.cln_ident=dst1.cln_ident
      AND dst2.active_ind=1)
    HEAD REPORT
     json_data_record->jslatestdocver = dst2.version_nbr, json_data_record->jslatestclninst = dst2
     .dd_sref_tmpl_instance_ident, json_data_record->jslatestclninstdisplay = dst2.display,
     json_data_record->jscurrentdocver = dst1.version_nbr
    WITH nocounter
   ;end select
   CALL log_message(build("Exit retrieveCompVersionNumbers(), Elapsed time in seconds:",((curtime3 -
     begin_date_time)/ 100)),log_level_debug)
 END ;Subroutine
 SUBROUTINE loadcomponentdetails(componentid)
   CALL log_message("In LoadComponentDetails()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH private, constant(curtime3)
   DECLARE versionclause = vc WITH noconstant(""), protect
   IF (compversion > 0)
    SET versionclause = "ccd.cp_component_id = componentId and ccd.version_nbr = compVersion"
   ELSE
    SET versionclause =
    "ccd.cp_component_id = componentId and (ccd.default_ind = 1 or (ccd.default_ind = 0 and ccd.version_nbr = 0))"
   ENDIF
   SELECT INTO "nl:"
    FROM cp_component_detail ccd
    PLAN (ccd
     WHERE parser(versionclause))
    ORDER BY ccd.cp_component_detail_id
    HEAD ccd.cp_component_detail_id
     CASE (uar_get_code_meaning(ccd.component_detail_reltn_cd))
      OF "DOCCONTENT":
       documentation_clin_ident = ccd.component_ident,documentation_source_flag = ccd.source_flag,
       curr_comp_version_nbr = ccd.version_nbr
      OF "DOCEVENTS":
       documentation_events_id = ccd.component_entity_id
      OF "DOCTERMDEC":
       documentation_decor_id = ccd.component_entity_id
      OF "DOCLAYOUT":
       documentation_layout_id = ccd.component_entity_id
     ENDCASE
    WITH nocounter
   ;end select
   CALL log_message(build("Exit LoadComponentDetails(), Elapsed time in seconds:",((curtime3 -
     begin_date_time)/ 100)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getrecommendationcategories(null)
   CALL log_message("In getRecommendationCategories()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH private, constant(curtime3)
   DECLARE categories_json = vc WITH protect, noconstant("")
   SET stat = alterlist(recommendation_category->categories,7)
   SET recommendation_category->categories_cnt = 7
   SET recommendation_category->categories[1].display = "Regimens"
   SET recommendation_category->categories[1].suggestmean = "SUGGEST_REGIMEN"
   SET recommendation_category->categories[1].mean = "REGIMEN_CATALOG"
   SET recommendation_category->categories[1].type = "REGIMEN"
   SET recommendation_category->categories[2].display = "Powerplans"
   SET recommendation_category->categories[2].suggestmean = "SUGGEST_POWER_PLAN"
   SET recommendation_category->categories[2].mean = "PATHWAY_CATALOG"
   SET recommendation_category->categories[2].type = "POWERPLAN"
   SET recommendation_category->categories[3].display = "Orders"
   SET recommendation_category->categories[3].suggestmean = "SUGGEST_ORDER"
   SET recommendation_category->categories[3].mean = "ORDER_CATALOG_SYNONYM"
   SET recommendation_category->categories[3].detailmean = "ORDER_SENTENCE"
   SET recommendation_category->categories[3].type = "ALLORDERS"
   SET recommendation_category->categories[4].display = "Treatment Lines"
   SET recommendation_category->categories[4].suggestmean = "SUGGEST_TREATMENT"
   SET recommendation_category->categories[4].mean = "CP_NODE"
   SET recommendation_category->categories[4].type = "TREATMENTNODES"
   SET recommendation_category->categories[5].display = "Order Folders"
   SET recommendation_category->categories[5].suggestmean = "SUGGEST_FOLDER"
   SET recommendation_category->categories[5].mean = "ALT_SEL_CAT"
   SET recommendation_category->categories[5].type = "ORDERFOLDERS"
   SET recommendation_category->categories[6].display = "Free-text"
   SET recommendation_category->categories[6].suggestmean = "SUGGEST_FREE_TEXT"
   SET recommendation_category->categories[6].mean = "LONG_TEXT_REFERENCE"
   SET recommendation_category->categories[6].type = "FREETEXT"
   SET recommendation_category->categories[7].display = "Section"
   SET recommendation_category->categories[7].suggestmean = "SUGGEST_SECTION"
   SET recommendation_category->categories[7].mean = "SECTION"
   SET recommendation_category->categories[7].type = "SECTIONS"
   SET categories_json = cnvtrectojson(recommendation_category)
   CALL log_message(build("Exit getRecommendationCategories(), Elapsed time in seconds:",((curtime3
      - begin_date_time)/ 100)),log_level_debug)
   RETURN(categories_json)
 END ;Subroutine
 SUBROUTINE gettreatmentlineforpathway(null)
   CALL log_message("In GetTreatmentLineForPathway()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH private, constant(curtime3)
   DECLARE pathway_nm_upper = vc WITH protect, noconstant(concat(cnvtupper(cp_pathway_name)," - ","*"
     ))
   DECLARE import_key = vc WITH protect, noconstant(concat("CERN_CPM","*"))
   DECLARE tcnt = i4 WITH protect, noconstant(size(treatment_line_templates->templates,5))
   DECLARE curtemplatename = vc WITH protect, noconstant("")
   DECLARE pnamesize = i4 WITH protect, noconstant(0)
   DECLARE tlindx = i2 WITH protect, noconstant(0)
   DECLARE tlsize = i4 WITH protect, noconstant(0)
   DECLARE tloc = i4 WITH protect, noconstant(0)
   DECLARE clnidposition = i4 WITH protect, noconstant(0)
   DECLARE clnidlength = i4 WITH protect, noconstant(0)
   DECLARE clniduppertemplatesubstringpattern = vc WITH protect, noconstant("")
   DECLARE templatedisplayupper = vc WITH protect, noconstant("")
   DECLARE guidlength = i4 WITH protect, constant(36)
   IF (cp_pathway_name > " ")
    SET pnamesize = size(pathway_nm_upper,1)
    SELECT INTO "nl:"
     textlen_dd_cln_ident = textlen(dd.cln_ident)
     FROM dd_sref_template dd
     PLAN (dd
      WHERE operator(dd.display_key,"ESCAPELIKE",patstring(pathway_nm_upper))
       AND operator(dd.cln_ident,"REGEXPLIKE",import_key))
     ORDER BY dd.version_nbr DESC, dd.updt_dt_tm DESC
     HEAD dd.dd_sref_template_id
      tloc = 0, tlsize = size(treatment_line_templates->templates,5), tloc = locateval(tlindx,1,
       tlsize,dd.cln_ident,treatment_line_templates->templates[tlindx].clin_id),
      clnidposition = findstring("CLNID!",dd.cln_ident,1,1), clnidposition = ((clnidposition+
      guidlength)+ textlen("CLNID!")), clnidlength = textlen_dd_cln_ident,
      clniduppertemplatesubstringpattern = cnvtupper(trim(substring(clnidposition,clnidlength,dd
         .cln_ident))), templatedisplayupper = cnvtupper(trim(dd.display,8))
      IF (textlen(clniduppertemplatesubstringpattern) > 0)
       clniduppertemplatesubstringpattern = concat("*",clniduppertemplatesubstringpattern)
      ENDIF
      CASE (templatedisplayupper)
       OF patstring(clniduppertemplatesubstringpattern,0):
        IF (tloc > 0
         AND (treatment_line_templates->templates[tloc].version < dd.version_nbr))
         treatment_line_templates->templates[tloc].clin_id = dd.cln_ident, treatment_line_templates->
         templates[tloc].display = dd.display, treatment_line_templates->templates[tloc].version = dd
         .version_nbr,
         treatment_line_templates->templates[tloc].update_date_time = cnvtdatetimeutc(dd.updt_dt_tm,1
          )
        ELSEIF (tloc=0)
         tcnt += 1, stat = alterlist(treatment_line_templates->templates,tcnt),
         treatment_line_templates->template_cnt = tcnt,
         treatment_line_templates->templates[tcnt].clin_id = dd.cln_ident, treatment_line_templates->
         templates[tcnt].display = dd.display, treatment_line_templates->templates[tcnt].version = dd
         .version_nbr,
         treatment_line_templates->templates[tcnt].update_date_time = cnvtdatetimeutc(dd.updt_dt_tm,1
          )
        ENDIF
      ENDCASE
     WITH nocounter
    ;end select
   ELSE
    IF (validate(debug_ind,0)=1)
     CALL echo(build("Failed to get correct pathway name GetTreatmentLineForPathway"))
    ENDIF
   ENDIF
   IF (validate(debug_ind,0)=1)
    CALL echo("Treatment Line Templates found under a pathway")
    CALL echorecord(treatment_line_templates)
   ENDIF
   CALL log_message(build("Exit GetTreatmentLineForPathway(), Elapsed time in seconds:",((curtime3 -
     begin_date_time)/ 100)),log_level_debug)
 END ;Subroutine
 SUBROUTINE generatejsonrecord(null)
   CALL log_message("In GenerateJsonRecord()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH private, constant(curtime3)
   SET json_data_record->jsclinicalinstanceident = decodeinternationalcharacters(
    documentation_clin_ident)
   SET json_data_record->jscomponentid = cp_component_id
   SET json_data_record->jsdecorationslongtextid = documentation_decor_id
   SET json_data_record->jseventslongtextid = documentation_events_id
   SET json_data_record->jslayoutlongtextid = documentation_layout_id
   SET json_data_record->jssourceflag = documentation_source_flag
   SET json_data_record->jsnodeid = cp_node_id
   SET json_data_record->jscompdetailreltncds = cnvtrectojson(code_values)
   SET json_data_record->jsstructuredata = cnvtrectojson(record_data)
   SET json_data_record->jsrecommendationdata = cnvtrectojson(recommendation_folders)
   SET json_data_record->jstreatmentlineforpathway = decodeinternationalcharacters(cnvtrectojson(
     treatment_line_templates))
   SET json_data_record->jscodesetvalues = cnvtrectojson(code_set_values)
   SET json_data_record->jspathwayid = cp_pathway_id
   SET json_data_record->jspathwayname = cp_pathway_name
   SET json_data_record->jsnodename = cp_node_name
   SET json_data_record->jscompvrsnnmbrs = cnvtrectojson(comp_vrsn_nmbrs_rec)
   SET json_data_record->jspathwaytypemean = cp_pathway_type_mean
   IF (validate(debug_ind,0)=1)
    CALL echo(build("cp_pathway_name --> ",cp_pathway_name))
    CALL echo(build("cp_node_name --> ",cp_node_name))
    CALL echo(build("cp_pathway_type_mean --> ",cp_pathway_type_mean))
    CALL echorecord(recommendation_category)
   ENDIF
   SET json_data_record->jsrecommendationcategories = cnvtrectojson(recommendation_category)
   IF (validate(debug_ind,0)=1)
    CALL echorecord(json_data_record)
   ENDIF
   CALL log_message(build("Exit GenerateJsonRecord(), Elapsed time in seconds:",((curtime3 -
     begin_date_time)/ 100)),log_level_debug)
 END ;Subroutine
 CALL main(null)
#exit_script
 IF (validate(debug_ind,0)=1)
  CALL echorecord(record_data)
  CALL echorecord(json_data_record)
 ENDIF
 CALL putjsonrecordtofile(json_data_record)
 FREE RECORD record_data
END GO
