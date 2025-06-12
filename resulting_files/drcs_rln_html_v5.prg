CREATE PROGRAM drcs_rln_html_v5
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "errormsg1" = "",
  "errormsg2" = "",
  "errormsg3" = "",
  "errormsg4" = "",
  "errormsg5" = ""
  WITH outdev, errormsg1, errormsg2,
  errormsg3, errormsg4, errormsg5
 DECLARE filename = vc WITH protect, constant(build("ccluserdir:",cnvtlower(curprog),"_logging_",
   format(curdate,"MMDDYYYY;;D"),".dat"))
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE cd_cnt = i4
 RECORD log(
   1 data1 = vc
   1 data2 = vc
   1 perform_loc_disp = vc
   1 order_alias_disp = vc
   1 loc_alias_disp = vc
   1 reqstartdttm_after_12mos = i2
   1 reqstartdttm_after_6mos = i2
   1 73_ref_only_src = f8
 )
 DECLARE encounterid = f8 WITH protect, noconstant(0)
 DECLARE personid = f8 WITH protect, noconstant(0)
 DECLARE 73_ref_only_src = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",73,"AMBULATORYRLN")
  )
 DECLARE 6000_lab_catalog_code = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3081"))
 DECLARE 6003_order_action_type = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3094")
  )
 DECLARE 6003_modify_action_type = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!3093"
   ))
 DECLARE 6003_activate_action_type = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!13773"))
 DECLARE 220_loc_nurse_unit = f8 WITH protect, noconstant(0)
 DECLARE alias_do_not_send = vc WITH protect, constant("DONOTSEND")
 DECLARE alias_skip = vc WITH protect, constant("SKIPMSG")
 DECLARE alias_type = vc WITH protect, constant("AMBULATORY")
 DECLARE order_alias_disp = vc WITH protect, noconstant("")
 DECLARE loc_alias_disp = vc WITH protect, noconstant("")
 DECLARE 16449_performingloc = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16449,
   "PERFORMINGLOCATIONAMBULATORY"))
 DECLARE 222_srvarea = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2856"))
 DECLARE 222_ambulatory = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!9458"))
 DECLARE correct_lab = vc WITH protect, noconstant("")
 DECLARE amb_loc_type = vc WITH protect, noconstant("")
 DECLARE correct_alias = vc WITH protect, noconstant("")
 DECLARE ref_lab_only = vc WITH protect, noconstant("")
 DECLARE correct_clinic = vc WITH protect, noconstant("")
 DECLARE oefieldvalue = f8 WITH protect, noconstant(0)
 DECLARE ord_id = f8 WITH protect, noconstant(0)
 DECLARE 220_loc_nurse_unit_disp = vc WITH protect, noconstant("")
 DECLARE 2052_specimen_type = vc WITH protect, noconstant("")
 DECLARE 2054_collection_priority = vc WITH protect, noconstant("")
 DECLARE reqstartdttm_disp = vc WITH protect, noconstant("")
 DECLARE nurse_collect = vc WITH protect, noconstant("")
 DECLARE spec_inx = vc WITH protect, noconstant("")
 DECLARE label_cmt = vc WITH protect, noconstant("")
 DECLARE diagnosis = vc WITH protect, noconstant("")
 DECLARE is_future_ord = vc WITH protect, noconstant("")
 DECLARE is_override = vc WITH protect, noconstant("")
 DECLARE perform_loc_disp = vc WITH protect, noconstant("")
 DECLARE perform_loc = vc WITH protect, noconstant("")
 DECLARE 4003_freq = vc WITH protect, noconstant("")
 DECLARE order_loc = vc WITH protect, noconstant("")
 DECLARE collby = vc WITH protect, noconstant("")
 DECLARE order_synonym = vc WITH protect, noconstant("")
 DECLARE reqstartdttm_after_12mos = i2 WITH protect, noconstant(0)
 DECLARE reqstartdttm_after_6mos = i2 WITH protect, noconstant(0)
 DECLARE reqstartdttm = dq8 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE order_idx = i4 WITH protect, noconstant(0)
 DECLARE detail_idx = i4 WITH protect, noconstant(0)
 DECLARE alert_cnt = i2 WITH protect, noconstant(0)
 DECLARE html_errmsg = vc WITH protect, noconstant("")
 DECLARE header = vc WITH protect, noconstant("")
 DECLARE display = vc WITH protect, noconstant("")
 RECORD quest_labcorp_cds(
   1 qual[*]
     2 labcorp_cont_cd = f8
     2 labcorp_loc_cd = f8
     2 quest_cont_cd = f8
     2 quest_loc_cd = f8
     2 contributor_cds = f8
     2 location_cds = f8
 )
 RECORD orderdisplayline(
   1 qual[*]
     2 orderid = f8
     2 display_line = vc
 )
 RECORD rln(
   1 qual[*]
     2 missinglocalias = i2
     2 missingordalias = i2
     2 reqstartdttm_after_12mos = i2
     2 reqstartdttm_after_6mos = i2
     2 reflabonly = i2
     2 synonym_mnem = vc
     2 order_id = f8
     2 synonym_code = f8
     2 perf_loc = vc
     2 display_line = vc
     2 spindex = i4
     2 spec_type = vc
     2 coll_prior = vc
     2 reqstartdttm = dq8
     2 reqstartdttm_disp = vc
     2 label_cmt = vc
     2 spec_inx = vc
     2 nurs_coll = vc
     2 diagnosis = vc
     2 freq = vc
     2 order_loc = vc
     2 future_ord = vc
 )
 SELECT INTO "nl:"
  loc_disp = uar_get_code_display(cvo.code_value)
  FROM code_value_outbound cvo,
   code_value_outbound cvo2
  PLAN (cvo
   WHERE cvo.contributor_source_cd=73_ref_only_src
    AND cvo.code_set=220
    AND isnumeric(cvo.alias) > 0)
   JOIN (cvo2
   WHERE cvo2.contributor_source_cd=73_ref_only_src
    AND cvo2.code_set=73
    AND cvo2.code_value=cnvtreal(cvo.alias))
  HEAD REPORT
   cd_cnt = 0
  HEAD cvo.code_value
   cd_cnt += 1
   IF (mod(cd_cnt,10)=1)
    stat = alterlist(quest_labcorp_cds->qual,(cd_cnt+ 9))
   ENDIF
   IF (trim(cvo2.alias)="LABCORP")
    log_message = build2(log_message,"; cvo2.alias = ",cvo2.alias), quest_labcorp_cds->qual[cd_cnt].
    labcorp_cont_cd = cvo2.code_value, quest_labcorp_cds->qual[cd_cnt].labcorp_loc_cd = cvo
    .code_value
   ELSEIF (trim(cvo2.alias)="QUEST")
    log_message = build2(log_message,"; cvo2.alias = ",cvo2.alias), quest_labcorp_cds->qual[cd_cnt].
    quest_cont_cd = cvo2.code_value, quest_labcorp_cds->qual[cd_cnt].quest_loc_cd = cvo.code_value
   ENDIF
   IF (size(cvo2.alias) > 0)
    log_message = build2(log_message,"; cvo2.alias = ",cvo2.alias), quest_labcorp_cds->qual[cd_cnt].
    contributor_cds = cvo2.code_value, quest_labcorp_cds->qual[cd_cnt].location_cds = cvo.code_value
   ENDIF
  FOOT REPORT
   null
  WITH nocounter
 ;end select
 SET retval = - (1)
 IF (eksrequest != 3072006)
  SET retval = - (1)
  SET log_message = build2(curprog," is not compatible with request ",cnvtint(eksrequest))
  GO TO exit_script
 ENDIF
 IF (link_template < 1)
  SET retval = - (1)
  SET log_message = "Missing required OPT_LINK parameter"
  GO TO exit_script
 ENDIF
 IF (link_personid < 1)
  SET retval = - (1)
  SET log_message = "Missing person_id check linked logic template"
  GO TO exit_script
 ELSE
  SET personid = link_personid
 ENDIF
 IF (link_encntrid < 1)
  SET retval = - (1)
  SET log_message = "Missing encounter_id check linked logic template"
  GO TO exit_script
 ELSE
  SET encounterid = link_encntrid
 ENDIF
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE expand(order_idx,1,size(request->orderlist,5),o.order_id,request->orderlist[order_idx].
    orderid)
    AND o.catalog_type_cd=6000_lab_catalog_code)
  HEAD REPORT
   idx = 0
  DETAIL
   idx += 1
   IF (mod(idx,10)=1)
    stat = alterlist(orderdisplayline->qual,(idx+ 9))
   ENDIF
   orderdisplayline->qual[idx].orderid = o.order_id, orderdisplayline->qual[idx].display_line = o
   .order_detail_display_line
  FOOT REPORT
   stat = alterlist(orderdisplayline->qual,idx)
  WITH nocounter, expand = 1, format
 ;end select
 SET order_idx = 0
 SET detail_idx = 0
 SET alert_cnt = 0
 IF (size(request->orderlist,5) >= 1)
  SET stat = alterlist(rln->qual,size(request->orderlist,5))
  FOR (order_idx = 1 TO size(request->orderlist,5))
    SET 2052_specimen_type = ""
    SET 2054_collection_priority = ""
    SET reqstartdttm = 0
    SET reqstartdttm_disp = ""
    SET nurse_collect = ""
    SET spec_inx = ""
    SET label_cmt = ""
    SET diagnosis = ""
    SET is_future_ord = "No"
    SET perform_loc_disp = ""
    SET quest = ""
    SET labcorp = ""
    SET order_alias_disp = ""
    SET ref_lab_only = " "
    SET correct_clinic = " "
    SET correct_lab = " "
    SET amb_loc_type = ""
    SET order_synonym = ""
    SET 4003_freq = ""
    SET order_loc = ""
    SET collby = ""
    SET pos = 0
    SET pos2 = 0
    SET reqstartdttm_after_12mos = 0
    SET reqstartdttm_after_6mos = 0
    SET loc_alias_disp = "0"
    IF ((request->orderlist[order_idx].catalogtypecd IN (6000_lab_catalog_code))
     AND (request->orderlist[order_idx].actiontypecd IN (6003_order_action_type,
    6003_activate_action_type, 6003_modify_action_type)))
     SET loc_alias_disp = "0"
     FOR (detail_idx = 1 TO size(request->orderlist[order_idx].detaillist,5))
       IF ((request->orderlist[order_idx].detaillist[detail_idx].oefieldmeaning="SPECIMEN TYPE"))
        SET 2052_specimen_type = request->orderlist[order_idx].detaillist[detail_idx].
        oefielddisplayvalue
       ELSEIF ((request->orderlist[order_idx].detaillist[detail_idx].oefieldmeaning=
       "2054_COLLECTION_PRIORITY"))
        SET 2054_collection_priority = build2(request->orderlist[order_idx].detaillist[detail_idx].
         oefielddisplayvalue," Collect")
       ELSEIF ((request->orderlist[order_idx].detaillist[detail_idx].oefieldmeaning="REQSTARTDTTM"))
        SET reqstartdttm = request->orderlist[order_idx].detaillist[detail_idx].oefielddttmvalue
        SET reqstartdttm_disp = request->orderlist[order_idx].detaillist[detail_idx].
        oefielddisplayvalue
       ELSEIF ((request->orderlist[order_idx].detaillist[detail_idx].oefieldmeaning="4003_FREQ"))
        SET 4003_freq = request->orderlist[order_idx].detaillist[detail_idx].oefielddisplayvalue
       ELSEIF ((request->orderlist[order_idx].detaillist[detail_idx].oefieldmeaning=
       "HOLDUNTILCOLLECTED")
        AND (request->orderlist[order_idx].detaillist[detail_idx].oefieldvalue=1.0))
        SET nurse_collect = "Hold Until Collected"
       ELSEIF ((request->orderlist[order_idx].detaillist[detail_idx].oefieldmeaning="SPECINX"))
        SET spec_inx = request->orderlist[order_idx].detaillist[detail_idx].oefielddisplayvalue
       ELSEIF ((request->orderlist[order_idx].detaillist[detail_idx].oefieldmeaning="ICD9"))
        SET diagnosis = request->orderlist[order_idx].detaillist[detail_idx].oefielddisplayvalue
       ELSEIF ((request->orderlist[order_idx].detaillist[detail_idx].oefieldmeaning="ORDERLOC"))
        SET order_loc = request->orderlist[order_idx].detaillist[detail_idx].oefielddisplayvalue
       ELSEIF ((request->orderlist[order_idx].detaillist[detail_idx].oefieldmeaning="COLLBY"))
        SET collby = build2("coll. by ",request->orderlist[order_idx].detaillist[detail_idx].
         oefielddisplayvalue)
       ELSEIF (trim(request->orderlist[order_idx].detaillist[detail_idx].oefieldmeaning)=
       "FUTUREORDER")
        IF (trim(request->orderlist[order_idx].detaillist[detail_idx].oefielddisplayvalue)="No")
         SET is_future_ord = "No"
        ELSEIF (trim(request->orderlist[order_idx].detaillist[detail_idx].oefielddisplayvalue)="Yes")
         SET is_future_ord = "Yes"
        ENDIF
       ELSEIF (trim(request->orderlist[order_idx].detaillist[detail_idx].oefieldmeaning)=
       "OVERRIDESHARE")
        IF (cnvtreal(request->orderlist[order_idx].detaillist[detail_idx].oefieldvalue)=0)
         SET is_override = ""
        ELSEIF (trim(request->orderlist[order_idx].detaillist[detail_idx].oefielddisplayvalue)="No")
         SET is_override = "No"
        ELSEIF (trim(request->orderlist[order_idx].detaillist[detail_idx].oefielddisplayvalue)="Yes")
         SET is_override = "Yes"
        ENDIF
       ELSEIF ((request->orderlist[order_idx].detaillist[detail_idx].oefieldmeaning="PERFORMLOC"))
        SET perform_loc = uar_get_code_display(request->orderlist[order_idx].detaillist[detail_idx].
         oefieldvalue)
        IF (cnvtreal(request->orderlist[order_idx].detaillist[detail_idx].oefieldvalue)=0)
         SET perform_loc_disp = ""
         SET log_message = build2(log_message,"; Performing Location alias not found")
        ELSEIF (locateval(num,1,size(quest_labcorp_cds->qual,5),cnvtreal(request->orderlist[order_idx
          ].detaillist[detail_idx].oefieldvalue),quest_labcorp_cds->qual[num].quest_loc_cd) > 0)
         SET perform_loc_disp = "Quest"
         SET log_message = build2(log_message,"; Performing Location aliased to Quest")
        ELSEIF (locateval(num,1,size(quest_labcorp_cds->qual,5),cnvtreal(request->orderlist[order_idx
          ].detaillist[detail_idx].oefieldvalue),quest_labcorp_cds->qual[num].labcorp_loc_cd) > 0)
         SET perform_loc_disp = "LabCorp"
         SET log_message = build2(log_message,"; Performing Location aliased to LabCorp")
        ELSEIF (locateval(num,1,size(quest_labcorp_cds->qual,5),cnvtreal(request->orderlist[order_idx
          ].detaillist[detail_idx].oefieldvalue),quest_labcorp_cds->qual[num].location_cds) > 0)
         SET perform_loc_disp = "ReferenceLab"
         SET log_message = build2(log_message,"; Performing Location aliased to Other Reference Lab")
        ELSE
         SET perform_loc_disp = "OTHER"
         SET log_message = build2(log_message,"; Performing Location is 'Other'")
        ENDIF
        SET log_message = build2(log_message,"; perform loc cd = ",request->orderlist[order_idx].
         detaillist[detail_idx].oefieldvalue)
        IF ((request->orderlist[order_idx].detaillist[detail_idx].oefieldvalue > 0)
         AND perform_loc_disp != "OTHER")
         SET correct_clinic = "no"
         SELECT INTO "nl:"
          FROM encounter e,
           (left JOIN code_value_outbound cvo ON (cvo.code_value=request->orderlist[order_idx].
           detaillist[detail_idx].oefieldvalue)
            AND cvo.code_set=220
            AND cvo.contributor_source_cd=73_ref_only_src
            AND isnumeric(cvo.alias) > 0),
           (left JOIN code_value_outbound cvo2 ON cvo2.contributor_source_cd=cnvtreal(cvo.alias)
            AND cvo2.code_set=220
            AND cvo2.code_value=e.loc_nurse_unit_cd)
          PLAN (e
           WHERE (e.encntr_id=request->encntr_id))
           JOIN (cvo)
           JOIN (cvo2)
          HEAD REPORT
           220_loc_nurse_unit_disp = uar_get_code_display(e.loc_nurse_unit_cd)
           IF (cvo2.code_value > 0)
            correct_clinic = "yes", log_message = build2(log_message,"; location alias found")
           ENDIF
          WITH nocounter
         ;end select
        ENDIF
        IF (perform_loc_disp="LabCorp")
         SET correct_alias = "no"
         SELECT INTO "nl:"
          FROM order_catalog_synonym ocs,
           code_value_outbound cvo
          PLAN (ocs
           WHERE (ocs.synonym_id=request->orderlist[order_idx].synonym_code)
            AND ocs.catalog_type_cd=6000_lab_catalog_code)
           JOIN (cvo
           WHERE cvo.code_value=ocs.catalog_cd
            AND expand(num,1,size(quest_labcorp_cds->qual,5),cvo.contributor_source_cd,
            quest_labcorp_cds->qual[num].labcorp_cont_cd))
          DETAIL
           correct_alias = "yes"
          WITH nocounter
         ;end select
        ELSEIF (perform_loc_disp="Quest")
         SET correct_alias = "no"
         SELECT INTO "nl:"
          FROM order_catalog_synonym ocs,
           code_value_outbound cvo
          PLAN (ocs
           WHERE (ocs.synonym_id=request->orderlist[order_idx].synonym_code)
            AND ocs.catalog_type_cd=6000_lab_catalog_code)
           JOIN (cvo
           WHERE cvo.code_value=ocs.catalog_cd
            AND expand(num,1,size(quest_labcorp_cds->qual,5),cvo.contributor_source_cd,
            quest_labcorp_cds->qual[num].quest_cont_cd))
          DETAIL
           correct_alias = "yes"
          WITH nocounter
         ;end select
        ELSEIF (perform_loc_disp="ReferenceLab")
         SET correct_alias = "no"
         SELECT INTO "nl:"
          FROM order_catalog_synonym ocs,
           code_value_outbound cvo
          PLAN (ocs
           WHERE (ocs.synonym_id=request->orderlist[order_idx].synonym_code)
            AND ocs.catalog_type_cd=6000_lab_catalog_code)
           JOIN (cvo
           WHERE cvo.code_value=ocs.catalog_cd
            AND expand(num,1,size(quest_labcorp_cds->qual,5),cvo.contributor_source_cd,
            quest_labcorp_cds->qual[num].contributor_cds))
          DETAIL
           correct_alias = "yes"
          WITH nocounter
         ;end select
        ENDIF
        SELECT
         *
         FROM code_value cv
         WHERE (cv.code_value=request->orderlist[order_idx].detaillist[detail_idx].oefieldvalue)
         DETAIL
          amb_loc_type = cv.cdf_meaning, log_message = build2(log_message,"; Amb loc type ",
           amb_loc_type)
         WITH nocounter
        ;end select
        IF (perform_loc_disp != ""
         AND amb_loc_type="AMBULATORY")
         SET correct_lab = "no"
         SET ord_id = request->orderlist[order_idx].orderid
         SET oefieldvalue = request->orderlist[order_idx].detaillist[detail_idx].oefieldvalue
         SELECT INTO "nl:"
          FROM orc_resource_list r,
           loc_resource_r lr,
           location_group lg
          PLAN (r
           WHERE (r.catalog_cd=request->orderlist[order_idx].catalog_code)
            AND r.active_ind=1)
           JOIN (lr
           WHERE lr.service_resource_cd=r.service_resource_cd)
           JOIN (lg
           WHERE lg.parent_loc_cd=lr.location_cd
            AND lg.active_ind=1
            AND (lg.child_loc_cd=request->orderlist[order_idx].detaillist[detail_idx].oefieldvalue)
            AND lg.location_group_type_cd=222_srvarea)
          DETAIL
           correct_lab = "yes", log_message = build2(log_message,
            "; correct ambulatory area lab found")
          WITH nocounter, format, maxrec = 1
         ;end select
        ELSEIF (perform_loc_disp != ""
         AND amb_loc_type="SRVAREA")
         SET correct_lab = "no"
         SET ord_id = request->orderlist[order_idx].orderid
         SET oefieldvalue = request->orderlist[order_idx].detaillist[detail_idx].oefieldvalue
         SELECT INTO "nl:"
          FROM orc_resource_list r,
           loc_resource_r lr,
           location_group lg
          PLAN (r
           WHERE (r.catalog_cd=request->orderlist[order_idx].catalog_code)
            AND r.active_ind=1)
           JOIN (lr
           WHERE lr.service_resource_cd=r.service_resource_cd)
           JOIN (lg
           WHERE lg.parent_loc_cd=lr.location_cd
            AND (lg.parent_loc_cd=request->orderlist[order_idx].detaillist[detail_idx].oefieldvalue)
            AND lg.active_ind=1
            AND lg.location_group_type_cd=222_srvarea)
          DETAIL
           correct_lab = "yes", log_message = build2(log_message,"; correct service area lab found")
          WITH nocounter, format, maxrec = 1
         ;end select
        ENDIF
       ENDIF
     ENDFOR
     IF (((perform_loc_disp=""
      AND is_future_ord="Yes"
      AND (request->orderlist[order_idx].actiontypecd != 6003_order_action_type)) OR (
     perform_loc_disp=""
      AND is_future_ord="No")) )
      SET ref_lab_only = "no"
      SELECT INTO "nl:"
       FROM order_catalog_synonym ocs,
        code_value_outbound cvo
       PLAN (ocs
        WHERE (ocs.synonym_id=request->orderlist[order_idx].synonym_code)
         AND ocs.catalog_type_cd=6000_lab_catalog_code)
        JOIN (cvo
        WHERE cvo.code_value=ocs.catalog_cd
         AND cvo.contributor_source_cd=73_ref_only_src)
       DETAIL
        ref_lab_only = "yes"
       WITH nocounter, format
      ;end select
     ENDIF
     SELECT INTO "nl:"
      FROM order_catalog_synonym ocs
      WHERE (ocs.synonym_id=request->orderlist[order_idx].synonym_code)
      DETAIL
       order_synonym = ocs.mnemonic
      WITH nocounter, format
     ;end select
     IF (((perform_loc_disp="Quest") OR (((perform_loc_disp="LabCorp") OR (perform_loc_disp=
     "ReferenceLab")) ))
      AND is_future_ord="No"
      AND reqstartdttm > cnvtlookahead("12, m"))
      SET reqstartdttm_after_12mos = 1.0
     ENDIF
     SET log->loc_alias_disp = loc_alias_disp
     SET log->reqstartdttm_after_12mos = reqstartdttm_after_12mos
     SET log->reqstartdttm_after_6mos = reqstartdttm_after_6mos
     SET log->order_alias_disp = order_alias_disp
     SET log->perform_loc_disp = perform_loc_disp
     SET log->73_ref_only_src = 73_ref_only_src
     SET log_message = build2(log_message,"REF_LAB_ONLY1 = ",ref_lab_only,"PERFORM_LOC: ",
      perform_loc_disp,
      " CORRECT_LAB = ",correct_lab," CORRECT_ALIAS= ",correct_alias," IS_OVERRIDE",
      is_override," CORRECT_CLINIC = ",correct_clinic," reqstartdttm_after_12mos = ",
      reqstartdttm_after_12mos,
      " ord_id = ",ord_id," action = ",uar_get_code_display(request->orderlist[order_idx].
       actiontypecd)," oefieldvalue = ",
      oefieldvalue)
     IF (((ref_lab_only="yes") OR (((correct_lab="no") OR (((correct_clinic="no") OR (((correct_alias
     ="no") OR (reqstartdttm_after_12mos=1.0)) )) )) )) )
      SET alert_cnt += 1
      IF (((perform_loc_disp="LabCorp") OR (((perform_loc_disp="Quest") OR (perform_loc_disp=
      "Referencelab")) )) )
       IF (((correct_lab="no") OR (correct_alias="no")) )
        SET rln->qual[alert_cnt].missingordalias = 1.0
       ENDIF
      ELSEIF (perform_loc_disp="OTHER")
       IF (correct_lab="no")
        SET rln->qual[alert_cnt].missingordalias = 1.0
       ENDIF
      ELSE
       SET rln->qual[alert_cnt].missingordalias = 0.0
      ENDIF
      IF (correct_clinic="no")
       SET rln->qual[alert_cnt].missinglocalias = 1.0
      ELSE
       SET rln->qual[alert_cnt].missinglocalias = 0.0
      ENDIF
      IF (ref_lab_only="yes")
       SET rln->qual[alert_cnt].reflabonly = 1.0
      ELSE
       SET rln->qual[alert_cnt].reflabonly = 0.0
      ENDIF
      IF (reqstartdttm_after_12mos=1.0)
       SET rln->qual[alert_cnt].reqstartdttm_after_12mos = 1.0
      ELSE
       SET rln->qual[alert_cnt].reqstartdttm_after_12mos = 0.0
      ENDIF
      SET rln->qual[alert_cnt].spindex = order_idx
      SET rln->qual[alert_cnt].order_id = request->orderlist[order_idx].orderid
      SET rln->qual[alert_cnt].synonym_code = request->orderlist[order_idx].synonym_code
      SET rln->qual[alert_cnt].spec_type = 2052_specimen_type
      SET rln->qual[alert_cnt].coll_prior = 2054_collection_priority
      SET rln->qual[alert_cnt].reqstartdttm = reqstartdttm
      SET rln->qual[alert_cnt].reqstartdttm_disp = reqstartdttm_disp
      SET rln->qual[alert_cnt].spec_inx = spec_inx
      SET rln->qual[alert_cnt].nurs_coll = nurse_collect
      SET rln->qual[alert_cnt].diagnosis = diagnosis
      SET rln->qual[alert_cnt].freq = 4003_freq
      SET rln->qual[alert_cnt].order_loc = order_loc
      SET rln->qual[alert_cnt].future_ord = is_future_ord
      SET rln->qual[alert_cnt].perf_loc = perform_loc
      SET rln->qual[alert_cnt].synonym_mnem = order_synonym
      SET pos = locateval(idx,1,size(orderdisplayline->qual,5),request->orderlist[order_idx].orderid,
       orderdisplayline->qual[idx].orderid)
      IF (size(orderdisplayline->qual[pos].display_line,5) > 1)
       SET rln->qual[alert_cnt].display_line = orderdisplayline->qual[pos].display_line
      ELSE
       IF (2052_specimen_type != "")
        SET rln->qual[alert_cnt].display_line = build2(2052_specimen_type)
       ENDIF
       IF (2054_collection_priority != "")
        SET rln->qual[alert_cnt].display_line = build2(rln->qual[alert_cnt].display_line,", ",
         2054_collection_priority)
       ENDIF
       IF (reqstartdttm != 0)
        SET rln->qual[alert_cnt].display_line = build2(rln->qual[alert_cnt].display_line,", ",
         reqstartdttm_disp)
       ENDIF
       IF (collby != "")
        SET rln->qual[alert_cnt].display_line = build2(rln->qual[alert_cnt].display_line,", ",collby)
       ENDIF
       IF (4003_freq != "")
        SET rln->qual[alert_cnt].display_line = build2(rln->qual[alert_cnt].display_line,", ",
         4003_freq)
       ENDIF
       IF (perform_loc_disp != "")
        SET rln->qual[alert_cnt].display_line = build2(rln->qual[alert_cnt].display_line,", ",
         perform_loc_disp)
       ENDIF
       IF (nurse_collect != "")
        SET rln->qual[alert_cnt].display_line = build2(rln->qual[alert_cnt].display_line,", ",
         nurse_collect)
       ENDIF
       IF (spec_inx != "")
        SET rln->qual[alert_cnt].display_line = build2(rln->qual[alert_cnt].display_line,", ",
         spec_inx)
       ENDIF
       IF (diagnosis != "")
        SET rln->qual[alert_cnt].display_line = build2(rln->qual[alert_cnt].display_line,", ",
         diagnosis)
       ENDIF
       IF (order_loc != "")
        SET rln->qual[alert_cnt].display_line = build2(rln->qual[alert_cnt].display_line,", ",
         order_loc)
       ENDIF
      ENDIF
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 SET stat = alterlist(rln->qual,alert_cnt)
 IF (alert_cnt > 0)
  SET header = build2(
   '<table border="1" style="width:100%"><tr><th><font face="Arial";>Order</font></th><th>',
   '<font face="Arial";>Details</font></th><th><font face="Arial";>Error Message</font></th></tr>')
  SET eksdata->tqual[3].qual[curindex].person_id = request->person_id
  SET eksdata->tqual[3].qual[curindex].encntr_id = request->encntr_id
  FOR (idx = 1 TO alert_cnt)
    SET html_errmsg = ""
    IF ((rln->qual[idx].missinglocalias=1.0))
     IF (html_errmsg="")
      SET html_errmsg = build2( $ERRORMSG1,trim(rln->qual[idx].perf_loc)," (",220_loc_nurse_unit_disp,
       ")")
     ELSE
      SET html_errmsg = build2(html_errmsg, $ERRORMSG1,trim(rln->qual[idx].perf_loc)," (",
       220_loc_nurse_unit_disp,
       ")")
     ENDIF
    ENDIF
    IF ((rln->qual[idx].missingordalias=1.0))
     IF (html_errmsg="")
      SET html_errmsg = build2( $ERRORMSG2,trim(rln->qual[idx].perf_loc)," (",trim(rln->qual[idx].
        synonym_mnem),")")
     ELSE
      SET html_errmsg = build2(html_errmsg,"<br>", $ERRORMSG2,trim(rln->qual[idx].perf_loc)," (",
       rln->qual[idx].synonym_mnem,")")
     ENDIF
    ENDIF
    IF ((rln->qual[idx].reflabonly=1.0))
     IF (html_errmsg="")
      SET html_errmsg = build2( $ERRORMSG3," (",trim(rln->qual[idx].synonym_mnem),")")
     ELSE
      SET html_errmsg = build2(html_errmsg,"<br>", $ERRORMSG3," (",rln->qual[idx].synonym_mnem,
       ")")
     ENDIF
    ENDIF
    IF ((rln->qual[idx].reqstartdttm_after_12mos=1.0))
     IF (html_errmsg="")
      SET html_errmsg = build2( $ERRORMSG4," (",trim(rln->qual[idx].reqstartdttm_disp),")")
     ELSE
      SET html_errmsg = build2(html_errmsg,"<br>", $ERRORMSG4," (",trim(rln->qual[idx].
        reqstartdttm_disp),
       ")")
     ENDIF
    ENDIF
    IF ((rln->qual[idx].reqstartdttm_after_6mos=1.0))
     IF (html_errmsg="")
      SET html_errmsg = build2( $ERRORMSG5," (",trim(rln->qual[idx].reqstartdttm_disp),")")
     ELSE
      SET html_errmsg = build2(html_errmsg,"<br>", $ERRORMSG5," (",trim(rln->qual[idx].
        reqstartdttm_disp),
       ")")
     ENDIF
    ENDIF
    SET display = build2('<tr><td><font face="Arial";>',trim(rln->qual[idx].synonym_mnem),
     '</font></td><td><font face="Arial";>',trim(rln->qual[idx].display_line),
     '</font></td><td><font face="Arial";>',
     html_errmsg,"</font></td></tr>",display)
  ENDFOR
  SET eksdata->tqual[3].qual[curindex].cnt = 1
  SET stat = alterlist(eksdata->tqual[3].qual[curindex].data,2)
  SET eksdata->tqual[3].qual[curindex].data[1].misc = "<SPINDEX>"
  SET eksdata->tqual[3].qual[curindex].data[2].misc = build2(trim(cnvtstring(rln->qual[1].spindex)),
   "|",header,display,"</table>")
  SET retval = 100
 ELSE
  SET retval = 0
 ENDIF
#exit_script
 IF (validate(ekmlog_ind,- (1)) > 0)
  CALL echo(concat("filename: ",filename))
  CALL echorecord(log,filename)
  CALL echorecord(eksdata,filename,1)
  CALL echorecord(request,filename,1)
  CALL echorecord(reply,filename,1)
  CALL echorecord(rln,filename,1)
  CALL echorecord(orderdisplayline,filename,1)
 ENDIF
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET log_message = build2("Error: ",errmsg)
  SET retval = - (1)
 ENDIF
 CALL echo(log_message)
 SET last_mod = build2(
  "007 08/22/18 NC028211 CCPS-14477 and 14553 Added back in the order validation based on outbound alias ",
  "presense and made sure it worked with overrideshare ",
  "added additional log messages viewable from EKSMonitor")
END GO
