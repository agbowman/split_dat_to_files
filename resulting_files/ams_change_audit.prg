CREATE PROGRAM ams_change_audit
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Email (ops only)" = "",
  "Lookback Type" = "lookback",
  "Enter number of days to look back" = "14",
  "Start Date" = "CURDATE",
  "End Date" = "CURDATE",
  "Audit Type" = "summary",
  "Detail Audit Type" = "area",
  "Detail Audit Area" = "",
  "Detail Audit User (Username)" = ""
  WITH outdev, email, range_type,
  lookback, sdate, edate,
  aud_type, detail_aud_type, detail_aud_area,
  detail_aud_user
 RECORD audit_data(
   1 summary_list[*]
     2 audit_type = c25
     2 name = c20
     2 position = c20
     2 username = c15
     2 count = i4
   1 detail_list[*]
     2 audit_type = c25
     2 detail_info1 = c40
     2 detail_info2 = c40
     2 name = c20
     2 position = c20
     2 updt_dt = dq8
     2 updt_id = f8
     2 updt_task = i4
 )
 RECORD audit_type(
   1 qual[21]
     2 audit_type = vc
 )
 SET audit_type->qual[1].audit_type = "ORDERCATALOG"
 SET audit_type->qual[2].audit_type = "ORDERCATALOGSYNONYM"
 SET audit_type->qual[3].audit_type = "DTA"
 SET audit_type->qual[4].audit_type = "EVENTSET1"
 SET audit_type->qual[5].audit_type = "EVENTSET2"
 SET audit_type->qual[6].audit_type = "PFREF"
 SET audit_type->qual[7].audit_type = "PFDEF"
 SET audit_type->qual[8].audit_type = "PFSECTION"
 SET audit_type->qual[9].audit_type = "PREFMAINT"
 SET audit_type->qual[10].audit_type = "INET"
 SET audit_type->qual[11].audit_type = "CODEVALUE"
 SET audit_type->qual[12].audit_type = "EXMENU"
 SET audit_type->qual[13].audit_type = "PPLANS"
 SET audit_type->qual[14].audit_type = "OPSTASK"
 SET audit_type->qual[15].audit_type = "OPSSCHEDULE"
 SET audit_type->qual[16].audit_type = "PFTRULE"
 SET audit_type->qual[17].audit_type = "PFTRULEACTION"
 SET audit_type->qual[18].audit_type = "PFTRULEGROUP"
 SET audit_type->qual[19].audit_type = "PFTRULEQUAL"
 SET audit_type->qual[20].audit_type = "APPPREFS"
 SET audit_type->qual[21].audit_type = "VIEWPREFS"
 DECLARE detcnt = i4 WITH protect
 SET detcnt = 0
 DECLARE sumcnt = i4 WITH protect
 SET sumcnt = 0
 DECLARE lookback = f8 WITH protect
 SET lookback = cnvtint( $LOOKBACK)
 DECLARE detail_iterate = i4 WITH protect
 IF (( $AUD_TYPE="detail"))
  IF (( $DETAIL_AUD_TYPE="area"))
   SET detail_iterate = 1
  ELSEIF (( $DETAIL_AUD_TYPE="user"))
   SET detail_iterate = size(audit_type->qual,5)
  ENDIF
 ENDIF
 DECLARE start_date = dq8 WITH protect
 IF (( $RANGE_TYPE="lookback"))
  SET start_date = cnvtdatetime((curdate - lookback),0)
 ELSEIF (( $RANGE_TYPE="daterange"))
  SET start_date = cnvtdatetime( $SDATE)
 ENDIF
 DECLARE end_date = dq8 WITH protect
 IF (( $RANGE_TYPE="lookback"))
  SET end_date = cnvtdatetime(curdate,curtime3)
 ELSEIF (( $RANGE_TYPE="daterange"))
  SET end_date = cnvtdatetime(concat(trim( $EDATE,3)," 23:59:59"))
 ENDIF
 DECLARE detail_audit_area = vc WITH protect
 IF (( $AUD_TYPE="detail"))
  IF (( $DETAIL_AUD_TYPE="area"))
   IF (( $DETAIL_AUD_AREA="Order Catalog"))
    SET detail_audit_area = "ORDERCATALOG"
   ELSEIF (( $DETAIL_AUD_AREA="Order Catalog Synonym"))
    SET detail_audit_area = "ORDERCATALOGSYNONYM"
   ELSEIF (( $DETAIL_AUD_AREA="Discrete Task Assay"))
    SET detail_audit_area = "DTA"
   ELSEIF (( $DETAIL_AUD_AREA="Event Set"))
    SET detail_audit_area = "EVENTSET1"
   ELSEIF (( $DETAIL_AUD_AREA="Event Set/Code Set Relationship"))
    SET detail_audit_area = "EVENTSET2"
   ELSEIF (( $DETAIL_AUD_AREA="PowerForm Definition"))
    SET detail_audit_area = "PFREF"
   ELSEIF (( $DETAIL_AUD_AREA="PowerForm Sections"))
    SET detail_audit_area = "PFDEF"
   ELSEIF (( $DETAIL_AUD_AREA="PowerForm Section Definition"))
    SET detail_audit_area = "PFSECTION"
   ELSEIF (( $DETAIL_AUD_AREA="Detailed Preferences"))
    SET detail_audit_area = "PREFMAINT"
   ELSEIF (( $DETAIL_AUD_AREA="INet Working View"))
    SET detail_audit_area = "INET"
   ELSEIF (( $DETAIL_AUD_AREA="Code Values"))
    SET detail_audit_area = "CODEVALUE"
   ELSEIF (( $DETAIL_AUD_AREA="Explorer Menu"))
    SET detail_audit_area = "EXMENU"
   ELSEIF (( $DETAIL_AUD_AREA="PowerPlans"))
    SET detail_audit_area = "PPLANS"
   ELSEIF (( $DETAIL_AUD_AREA="Operation Job Settings"))
    SET detail_audit_area = "OPSTASK"
   ELSEIF (( $DETAIL_AUD_AREA="Operation Job Steps"))
    SET detail_audit_area = "OPSSCHEDULE"
   ELSEIF (( $DETAIL_AUD_AREA="Claim Rules Top-Level"))
    SET detail_audit_area = "PFTRULE"
   ELSEIF (( $DETAIL_AUD_AREA="Claim Rules Action"))
    SET detail_audit_area = "PFTRULEACTION"
   ELSEIF (( $DETAIL_AUD_AREA="Claim Rules Qualification Grouping"))
    SET detail_audit_area = "PFTRULEGROUP"
   ELSEIF (( $DETAIL_AUD_AREA="Claim Rules Qualification Detail"))
    SET detail_audit_area = "PFTRULEQUAL"
   ELSEIF (( $DETAIL_AUD_AREA="Application-Level Preferences"))
    SET detail_audit_area = "APPPREFS"
   ELSEIF (( $DETAIL_AUD_AREA="View-Level Preferences"))
    SET detail_audit_area = "VIEWPREFS"
   ENDIF
  ENDIF
 ENDIF
 DECLARE detail_audit_user = f8 WITH protect
 SET detail_audit_user = 0
 DECLARE detail_audit_user_name = c30 WITH protect
 SET detail_audit_user_name = "USER NOT FOUND"
 DECLARE blank_name = c20 WITH protect
 SET blank_name = "BLANK (UPDT_ID=0)"
 DECLARE blank_pos = c20 WITH protect
 SET blank_pos = "BLANK (UPDT_ID=0)"
 DECLARE ops_scheduler = i4 WITH public, constant(4600)
 DECLARE ops_monitor = i4 WITH public, constant(4700)
 DECLARE ops_server = i4 WITH public, constant(4800)
 DECLARE is_ops_job = i2 WITH protect, noconstant(0)
 IF (validate(reqinfo->updt_app,- (1)) IN (ops_scheduler, ops_monitor, ops_server))
  SET is_ops_job = true
 ENDIF
 DECLARE output_dest = vc WITH protect
 IF (is_ops_job=true)
  SET output_dest = concat(trim(logical("CCLUSERDIR"),3),"/","ams_change_audit",".rtf")
 ELSE
  SET output_dest =  $OUTDEV
 ENDIF
 DECLARE emailfrom = c31 WITH protect, constant("ams_change_audit@cerner.com")
 DECLARE emailsubject = vc WITH protect, constant(concat("AMS Change Audit from ",format(start_date,
    "DD-MMM-YYYY;;D")," to ",format(end_date,"DD-MMM-YYYY;;D")))
 DECLARE emailbody = vc WITH protect, noconstant(concat(
   "See attached for a summary report showing changes made from ",format(start_date,"DD-MMM-YYYY;;D"),
   " to ",format(end_date,"DD-MMM-YYYY;;D")))
 DECLARE amsuser(prsnl_id=f8) = i2
 DECLARE updtdminfo(prog_name=vc) = null
 DECLARE sprogramname = vc WITH protect, constant("AMS_CHANGE_AUDIT")
 DECLARE run_ind = i2 WITH protect, noconstant(false)
 IF (is_ops_job=false)
  SET run_ind = amsuser(reqinfo->updt_id)
  IF (run_ind=false)
   SELECT INTO  $OUTDEV
    FROM dummyt d
    HEAD REPORT
     row 3, col 20, "THIS PROGRAM IS INTENDED FOR USE BY AMS ASSOCIATES ONLY"
    WITH nocounter
   ;end select
   GO TO exit_script
  ENDIF
 ENDIF
 CALL updtdminfo(sprogramname)
 IF (( $AUD_TYPE="summary"))
  SELECT INTO "nl:"
   name = substring(1,20,p.name_full_formatted), position = substring(1,20,uar_get_code_display(p
     .position_cd)), username = substring(1,15,p.username),
   countx = count(oc.updt_id)
   FROM order_catalog oc,
    prsnl p
   WHERE oc.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND oc.updt_id=p.person_id
   GROUP BY p.name_full_formatted, p.username, p.position_cd
   ORDER BY countx DESC, name
   DETAIL
    sumcnt = (sumcnt+ 1), stat = alterlist(audit_data->summary_list,sumcnt), audit_data->
    summary_list[sumcnt].audit_type = "ORDERCATALOG",
    audit_data->summary_list[sumcnt].name = name, audit_data->summary_list[sumcnt].position =
    position, audit_data->summary_list[sumcnt].username = username,
    audit_data->summary_list[sumcnt].count = countx
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   name = substring(1,20,p.name_full_formatted), position = substring(1,20,uar_get_code_display(p
     .position_cd)), username = substring(1,15,p.username),
   countx = count(ocs.updt_id)
   FROM order_catalog_synonym ocs,
    prsnl p
   WHERE ocs.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND ocs.updt_id=p.person_id
   GROUP BY p.name_full_formatted, p.username, p.position_cd
   ORDER BY countx DESC, name
   DETAIL
    sumcnt = (sumcnt+ 1), stat = alterlist(audit_data->summary_list,sumcnt), audit_data->
    summary_list[sumcnt].audit_type = "ORDERCATALOGSYNONYM",
    audit_data->summary_list[sumcnt].name = name, audit_data->summary_list[sumcnt].position =
    position, audit_data->summary_list[sumcnt].username = username,
    audit_data->summary_list[sumcnt].count = countx
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   name = substring(1,20,p.name_full_formatted), position = substring(1,20,uar_get_code_display(p
     .position_cd)), username = substring(1,15,p.username),
   countx = count(dta.updt_id)
   FROM discrete_task_assay dta,
    prsnl p
   WHERE dta.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND dta.updt_id=p.person_id
   GROUP BY p.name_full_formatted, p.username, p.position_cd
   ORDER BY countx DESC, name
   DETAIL
    sumcnt = (sumcnt+ 1), stat = alterlist(audit_data->summary_list,sumcnt), audit_data->
    summary_list[sumcnt].audit_type = "DTA",
    audit_data->summary_list[sumcnt].name = name, audit_data->summary_list[sumcnt].position =
    position, audit_data->summary_list[sumcnt].username = username,
    audit_data->summary_list[sumcnt].count = countx
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   name = substring(1,20,p.name_full_formatted), position = substring(1,20,uar_get_code_display(p
     .position_cd)), username = substring(1,15,p.username),
   countx = count(esc.updt_id)
   FROM v500_event_set_code esc,
    prsnl p
   WHERE esc.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND esc.updt_id=p.person_id
   GROUP BY p.name_full_formatted, p.username, p.position_cd
   ORDER BY countx DESC, name
   DETAIL
    sumcnt = (sumcnt+ 1), stat = alterlist(audit_data->summary_list,sumcnt), audit_data->
    summary_list[sumcnt].audit_type = "EVENTSET1",
    audit_data->summary_list[sumcnt].name = name, audit_data->summary_list[sumcnt].position =
    position, audit_data->summary_list[sumcnt].username = username,
    audit_data->summary_list[sumcnt].count = countx
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   name = substring(1,20,p.name_full_formatted), position = substring(1,20,uar_get_code_display(p
     .position_cd)), username = substring(1,15,p.username),
   countx = count(ese.updt_id)
   FROM v500_event_set_explode ese,
    prsnl p
   WHERE ese.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND ese.updt_id=p.person_id
   GROUP BY p.name_full_formatted, p.username, p.position_cd
   ORDER BY countx DESC, name
   DETAIL
    sumcnt = (sumcnt+ 1), stat = alterlist(audit_data->summary_list,sumcnt), audit_data->
    summary_list[sumcnt].audit_type = "EVENTSET2",
    audit_data->summary_list[sumcnt].name = name, audit_data->summary_list[sumcnt].position =
    position, audit_data->summary_list[sumcnt].username = username,
    audit_data->summary_list[sumcnt].count = countx
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   name = substring(1,20,p.name_full_formatted), position = substring(1,20,uar_get_code_display(p
     .position_cd)), username = substring(1,15,p.username),
   countx = count(dfr.updt_id)
   FROM dcp_forms_ref dfr,
    prsnl p
   WHERE dfr.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND dfr.updt_id=p.person_id
   GROUP BY p.name_full_formatted, p.username, p.position_cd
   ORDER BY countx DESC, name
   DETAIL
    sumcnt = (sumcnt+ 1), stat = alterlist(audit_data->summary_list,sumcnt), audit_data->
    summary_list[sumcnt].audit_type = "PFREF",
    audit_data->summary_list[sumcnt].name = name, audit_data->summary_list[sumcnt].position =
    position, audit_data->summary_list[sumcnt].username = username,
    audit_data->summary_list[sumcnt].count = countx
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   name = substring(1,20,p.name_full_formatted), position = substring(1,20,uar_get_code_display(p
     .position_cd)), username = substring(1,15,p.username),
   countx = count(dfd.updt_id)
   FROM dcp_forms_def dfd,
    prsnl p
   WHERE dfd.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND dfd.updt_id=p.person_id
   GROUP BY p.name_full_formatted, p.username, p.position_cd
   ORDER BY countx DESC, name
   DETAIL
    sumcnt = (sumcnt+ 1), stat = alterlist(audit_data->summary_list,sumcnt), audit_data->
    summary_list[sumcnt].audit_type = "PFDEF",
    audit_data->summary_list[sumcnt].name = name, audit_data->summary_list[sumcnt].position =
    position, audit_data->summary_list[sumcnt].username = username,
    audit_data->summary_list[sumcnt].count = countx
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   name = substring(1,20,p.name_full_formatted), position = substring(1,20,uar_get_code_display(p
     .position_cd)), username = substring(1,15,p.username),
   countx = count(s.updt_id)
   FROM dcp_section_ref s,
    prsnl p
   WHERE s.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND s.updt_id=p.person_id
   GROUP BY p.name_full_formatted, p.username, p.position_cd
   ORDER BY countx DESC, name
   DETAIL
    sumcnt = (sumcnt+ 1), stat = alterlist(audit_data->summary_list,sumcnt), audit_data->
    summary_list[sumcnt].audit_type = "PFSECTION",
    audit_data->summary_list[sumcnt].name = name, audit_data->summary_list[sumcnt].position =
    position, audit_data->summary_list[sumcnt].username = username,
    audit_data->summary_list[sumcnt].count = countx
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   name = substring(1,20,p.name_full_formatted), position = substring(1,20,uar_get_code_display(p
     .position_cd)), username = substring(1,15,p.username),
   countx = count(nvp.updt_id)
   FROM name_value_prefs nvp,
    prsnl p,
    detail_prefs dp
   WHERE nvp.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND nvp.updt_id=p.person_id
    AND nvp.parent_entity_name="DETAIL_PREFS"
    AND nvp.parent_entity_id=dp.detail_prefs_id
    AND dp.prsnl_id=0
   GROUP BY p.name_full_formatted, p.username, p.position_cd
   ORDER BY countx DESC, name
   DETAIL
    sumcnt = (sumcnt+ 1), stat = alterlist(audit_data->summary_list,sumcnt), audit_data->
    summary_list[sumcnt].audit_type = "PREFMAINT",
    audit_data->summary_list[sumcnt].name = name, audit_data->summary_list[sumcnt].position =
    position, audit_data->summary_list[sumcnt].username = username,
    audit_data->summary_list[sumcnt].count = countx
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   name = substring(1,20,p.name_full_formatted), position = substring(1,20,uar_get_code_display(p
     .position_cd)), username = substring(1,15,p.username),
   countx = count(wvs.updt_id)
   FROM working_view_section wvs,
    prsnl p
   WHERE wvs.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND wvs.updt_id=p.person_id
   GROUP BY p.name_full_formatted, p.username, p.position_cd
   ORDER BY countx DESC, name
   DETAIL
    sumcnt = (sumcnt+ 1), stat = alterlist(audit_data->summary_list,sumcnt), audit_data->
    summary_list[sumcnt].audit_type = "INET",
    audit_data->summary_list[sumcnt].name = name, audit_data->summary_list[sumcnt].position =
    position, audit_data->summary_list[sumcnt].username = username,
    audit_data->summary_list[sumcnt].count = countx
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   name = substring(1,20,p.name_full_formatted), position = substring(1,20,uar_get_code_display(p
     .position_cd)), username = substring(1,15,p.username),
   countx = count(cv.updt_id)
   FROM code_value cv,
    prsnl p
   WHERE cv.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND cv.updt_id=p.person_id
   GROUP BY p.name_full_formatted, p.username, p.position_cd
   ORDER BY countx DESC, name
   DETAIL
    sumcnt = (sumcnt+ 1), stat = alterlist(audit_data->summary_list,sumcnt), audit_data->
    summary_list[sumcnt].audit_type = "CODEVALUE",
    audit_data->summary_list[sumcnt].name = name, audit_data->summary_list[sumcnt].position =
    position, audit_data->summary_list[sumcnt].username = username,
    audit_data->summary_list[sumcnt].count = countx
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   name = substring(1,20,p.name_full_formatted), position = substring(1,20,uar_get_code_display(p
     .position_cd)), username = substring(1,15,p.username),
   countx = count(em.updt_id)
   FROM explorer_menu em,
    prsnl p
   WHERE em.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND (em.updt_cnt=
   (SELECT
    max(em1.updt_cnt)
    FROM explorer_menu em1
    WHERE em1.menu_id=em.menu_id))
    AND em.updt_id=p.person_id
   GROUP BY p.name_full_formatted, p.username, p.position_cd
   ORDER BY countx DESC, name
   DETAIL
    sumcnt = (sumcnt+ 1), stat = alterlist(audit_data->summary_list,sumcnt), audit_data->
    summary_list[sumcnt].audit_type = "EXMENU",
    audit_data->summary_list[sumcnt].name = name, audit_data->summary_list[sumcnt].position =
    position, audit_data->summary_list[sumcnt].username = username,
    audit_data->summary_list[sumcnt].count = countx
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   name = substring(1,20,p.name_full_formatted), position = substring(1,20,uar_get_code_display(p
     .position_cd)), username = substring(1,15,p.username),
   countx = count(pc.updt_id)
   FROM pathway_catalog pc,
    prsnl p
   WHERE pc.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND pc.updt_id=p.person_id
   GROUP BY p.name_full_formatted, p.username, p.position_cd
   ORDER BY countx DESC, name
   DETAIL
    sumcnt = (sumcnt+ 1), stat = alterlist(audit_data->summary_list,sumcnt), audit_data->
    summary_list[sumcnt].audit_type = "PPLANS",
    audit_data->summary_list[sumcnt].name = name, audit_data->summary_list[sumcnt].position =
    position, audit_data->summary_list[sumcnt].username = username,
    audit_data->summary_list[sumcnt].count = countx
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   name = substring(1,20,p.name_full_formatted), position = substring(1,20,uar_get_code_display(p
     .position_cd)), username = substring(1,15,p.username),
   countx = count(ot.updt_id)
   FROM ops_task ot,
    prsnl p
   WHERE ot.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND ot.updt_id=p.person_id
   GROUP BY p.name_full_formatted, p.username, p.position_cd
   ORDER BY countx DESC, name
   DETAIL
    sumcnt = (sumcnt+ 1), stat = alterlist(audit_data->summary_list,sumcnt), audit_data->
    summary_list[sumcnt].audit_type = "OPSTASK",
    audit_data->summary_list[sumcnt].name = name, audit_data->summary_list[sumcnt].position =
    position, audit_data->summary_list[sumcnt].username = username,
    audit_data->summary_list[sumcnt].count = countx
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   name = substring(1,20,p.name_full_formatted), position = substring(1,20,uar_get_code_display(p
     .position_cd)), username = substring(1,15,p.username),
   countx = count(osp.updt_id)
   FROM ops_schedule_param osp,
    prsnl p
   WHERE osp.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND osp.updt_id=p.person_id
   GROUP BY p.name_full_formatted, p.username, p.position_cd
   ORDER BY countx DESC, name
   DETAIL
    sumcnt = (sumcnt+ 1), stat = alterlist(audit_data->summary_list,sumcnt), audit_data->
    summary_list[sumcnt].audit_type = "OPSSCHEDULE",
    audit_data->summary_list[sumcnt].name = name, audit_data->summary_list[sumcnt].position =
    position, audit_data->summary_list[sumcnt].username = username,
    audit_data->summary_list[sumcnt].count = countx
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   name = substring(1,20,p.name_full_formatted), position = substring(1,20,uar_get_code_display(p
     .position_cd)), username = substring(1,15,p.username),
   countx = count(pr.updt_id)
   FROM pft_rule pr,
    prsnl p
   WHERE pr.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND pr.updt_id=p.person_id
   GROUP BY p.name_full_formatted, p.username, p.position_cd
   ORDER BY countx DESC, name
   DETAIL
    sumcnt = (sumcnt+ 1), stat = alterlist(audit_data->summary_list,sumcnt), audit_data->
    summary_list[sumcnt].audit_type = "PFTRULE",
    audit_data->summary_list[sumcnt].name = name, audit_data->summary_list[sumcnt].position =
    position, audit_data->summary_list[sumcnt].username = username,
    audit_data->summary_list[sumcnt].count = countx
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   name = substring(1,20,p.name_full_formatted), position = substring(1,20,uar_get_code_display(p
     .position_cd)), username = substring(1,15,p.username),
   countx = count(pra.updt_id)
   FROM pft_rule_action pra,
    prsnl p
   WHERE pra.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND pra.updt_id=p.person_id
   GROUP BY p.name_full_formatted, p.username, p.position_cd
   ORDER BY countx DESC, name
   DETAIL
    sumcnt = (sumcnt+ 1), stat = alterlist(audit_data->summary_list,sumcnt), audit_data->
    summary_list[sumcnt].audit_type = "PFTRULEACTION",
    audit_data->summary_list[sumcnt].name = name, audit_data->summary_list[sumcnt].position =
    position, audit_data->summary_list[sumcnt].username = username,
    audit_data->summary_list[sumcnt].count = countx
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   name = substring(1,20,p.name_full_formatted), position = substring(1,20,uar_get_code_display(p
     .position_cd)), username = substring(1,15,p.username),
   countx = count(prg.updt_id)
   FROM pft_rule_group prg,
    prsnl p
   WHERE prg.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND prg.updt_id=p.person_id
   GROUP BY p.name_full_formatted, p.username, p.position_cd
   ORDER BY countx DESC, name
   DETAIL
    sumcnt = (sumcnt+ 1), stat = alterlist(audit_data->summary_list,sumcnt), audit_data->
    summary_list[sumcnt].audit_type = "PFTRULEGROUP",
    audit_data->summary_list[sumcnt].name = name, audit_data->summary_list[sumcnt].position =
    position, audit_data->summary_list[sumcnt].username = username,
    audit_data->summary_list[sumcnt].count = countx
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   name = substring(1,20,p.name_full_formatted), position = substring(1,20,uar_get_code_display(p
     .position_cd)), username = substring(1,15,p.username),
   countx = count(prq.updt_id)
   FROM pft_rule_qualification prq,
    prsnl p
   WHERE prq.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND prq.updt_id=p.person_id
   GROUP BY p.name_full_formatted, p.username, p.position_cd
   ORDER BY countx DESC, name
   DETAIL
    sumcnt = (sumcnt+ 1), stat = alterlist(audit_data->summary_list,sumcnt), audit_data->
    summary_list[sumcnt].audit_type = "PFTRULEQUAL",
    audit_data->summary_list[sumcnt].name = name, audit_data->summary_list[sumcnt].position =
    position, audit_data->summary_list[sumcnt].username = username,
    audit_data->summary_list[sumcnt].count = countx
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   name = substring(1,20,p.name_full_formatted), position = substring(1,20,uar_get_code_display(p
     .position_cd)), username = substring(1,15,p.username),
   countx = count(nvp.updt_id)
   FROM name_value_prefs nvp,
    prsnl p,
    app_prefs ap
   WHERE nvp.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND nvp.updt_id=p.person_id
    AND nvp.parent_entity_name="APP_PREFS"
    AND nvp.parent_entity_id=ap.app_prefs_id
    AND ap.prsnl_id=0
   GROUP BY p.name_full_formatted, p.username, p.position_cd
   ORDER BY countx DESC, name
   DETAIL
    sumcnt = (sumcnt+ 1), stat = alterlist(audit_data->summary_list,sumcnt), audit_data->
    summary_list[sumcnt].audit_type = "APPPREFS",
    audit_data->summary_list[sumcnt].name = name, audit_data->summary_list[sumcnt].position =
    position, audit_data->summary_list[sumcnt].username = username,
    audit_data->summary_list[sumcnt].count = countx
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   name = substring(1,20,p.name_full_formatted), position = substring(1,20,uar_get_code_display(p
     .position_cd)), username = substring(1,15,p.username),
   countx = count(nvp.updt_id)
   FROM name_value_prefs nvp,
    prsnl p,
    view_prefs vp
   WHERE nvp.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND nvp.updt_id=p.person_id
    AND nvp.parent_entity_name="VIEW_PREFS"
    AND nvp.parent_entity_id=vp.view_prefs_id
    AND vp.prsnl_id=0
   GROUP BY p.name_full_formatted, p.username, p.position_cd
   ORDER BY countx DESC, name
   DETAIL
    sumcnt = (sumcnt+ 1), stat = alterlist(audit_data->summary_list,sumcnt), audit_data->
    summary_list[sumcnt].audit_type = "VIEWPREFS",
    audit_data->summary_list[sumcnt].name = name, audit_data->summary_list[sumcnt].position =
    position, audit_data->summary_list[sumcnt].username = username,
    audit_data->summary_list[sumcnt].count = countx
   WITH nocounter, separator = " ", format
  ;end select
 ELSEIF (( $AUD_TYPE="detail"))
  IF (( $DETAIL_AUD_TYPE="user"))
   SELECT INTO "nl:"
    name = substring(1,30,p.name_full_formatted), id = p.person_id
    FROM prsnl p
    WHERE cnvtupper(p.username)=cnvtupper(trim( $DETAIL_AUD_USER,3))
     AND p.active_ind=1
    DETAIL
     detail_audit_user = id, detail_audit_user_name = name
    WITH nocounter, separator = " ", format
   ;end select
  ENDIF
  SELECT INTO "nl:"
   description = substring(1,40,oc.description), name = substring(1,20,p.name_full_formatted),
   position = substring(1,20,uar_get_code_display(p.position_cd)),
   date = oc.updt_dt_tm"@SHORTDATETIME", id = oc.updt_id, task = oc.updt_task
   FROM order_catalog oc,
    prsnl p
   WHERE oc.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND oc.updt_id=p.person_id
   ORDER BY name, date
   DETAIL
    detcnt = (detcnt+ 1), stat = alterlist(audit_data->detail_list,detcnt), audit_data->detail_list[
    detcnt].audit_type = "ORDERCATALOG",
    audit_data->detail_list[detcnt].detail_info1 = description, audit_data->detail_list[detcnt].
    detail_info2 = " ", audit_data->detail_list[detcnt].name = name,
    audit_data->detail_list[detcnt].position = position, audit_data->detail_list[detcnt].updt_dt =
    date, audit_data->detail_list[detcnt].updt_id = id,
    audit_data->detail_list[detcnt].updt_task = task
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   mnemonic = substring(1,40,ocs.mnemonic), name = substring(1,20,p.name_full_formatted), position =
   substring(1,20,uar_get_code_display(p.position_cd)),
   date = ocs.updt_dt_tm"@SHORTDATETIME", id = ocs.updt_id, task = ocs.updt_task
   FROM order_catalog_synonym ocs,
    prsnl p
   WHERE ocs.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND ocs.updt_id=p.person_id
   ORDER BY name, date
   DETAIL
    detcnt = (detcnt+ 1), stat = alterlist(audit_data->detail_list,detcnt), audit_data->detail_list[
    detcnt].audit_type = "ORDERCATALOGSYNONYM",
    audit_data->detail_list[detcnt].detail_info1 = mnemonic, audit_data->detail_list[detcnt].
    detail_info2 = " ", audit_data->detail_list[detcnt].name = name,
    audit_data->detail_list[detcnt].position = position, audit_data->detail_list[detcnt].updt_dt =
    date, audit_data->detail_list[detcnt].updt_id = id,
    audit_data->detail_list[detcnt].updt_task = task
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   mnemonic = substring(1,40,dta.mnemonic), name = substring(1,20,p.name_full_formatted), position =
   substring(1,20,uar_get_code_display(p.position_cd)),
   date = dta.updt_dt_tm"@SHORTDATETIME", id = dta.updt_id, task = dta.updt_task
   FROM discrete_task_assay dta,
    prsnl p
   WHERE dta.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND dta.updt_id=p.person_id
   ORDER BY name, date
   DETAIL
    detcnt = (detcnt+ 1), stat = alterlist(audit_data->detail_list,detcnt), audit_data->detail_list[
    detcnt].audit_type = "DTA",
    audit_data->detail_list[detcnt].detail_info1 = mnemonic, audit_data->detail_list[detcnt].
    detail_info2 = " ", audit_data->detail_list[detcnt].name = name,
    audit_data->detail_list[detcnt].position = position, audit_data->detail_list[detcnt].updt_dt =
    date, audit_data->detail_list[detcnt].updt_id = id,
    audit_data->detail_list[detcnt].updt_task = task
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   description = substring(1,40,esc.event_set_cd_descr), name = substring(1,20,p.name_full_formatted),
   position = substring(1,20,uar_get_code_display(p.position_cd)),
   date = esc.updt_dt_tm"@SHORTDATETIME", id = esc.updt_id, task = esc.updt_task
   FROM v500_event_set_code esc,
    prsnl p
   WHERE esc.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND esc.updt_id=p.person_id
   ORDER BY name, date
   DETAIL
    detcnt = (detcnt+ 1), stat = alterlist(audit_data->detail_list,detcnt), audit_data->detail_list[
    detcnt].audit_type = "EVENTSET1",
    audit_data->detail_list[detcnt].detail_info1 = description, audit_data->detail_list[detcnt].
    detail_info2 = " ", audit_data->detail_list[detcnt].name = name,
    audit_data->detail_list[detcnt].position = position, audit_data->detail_list[detcnt].updt_dt =
    date, audit_data->detail_list[detcnt].updt_id = id,
    audit_data->detail_list[detcnt].updt_task = task
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   description = substring(1,40,uar_get_code_display(ese.event_set_cd)), name = substring(1,20,p
    .name_full_formatted), position = substring(1,20,uar_get_code_display(p.position_cd)),
   date = ese.updt_dt_tm"@SHORTDATETIME", id = ese.updt_id, task = ese.updt_task
   FROM v500_event_set_explode ese,
    prsnl p
   WHERE ese.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND ese.updt_id=p.person_id
   ORDER BY name, date
   DETAIL
    detcnt = (detcnt+ 1), stat = alterlist(audit_data->detail_list,detcnt), audit_data->detail_list[
    detcnt].audit_type = "EVENTSET2",
    audit_data->detail_list[detcnt].detail_info1 = description, audit_data->detail_list[detcnt].
    detail_info2 = " ", audit_data->detail_list[detcnt].name = name,
    audit_data->detail_list[detcnt].position = position, audit_data->detail_list[detcnt].updt_dt =
    date, audit_data->detail_list[detcnt].updt_id = id,
    audit_data->detail_list[detcnt].updt_task = task
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   description = substring(1,40,dfr.description), name = substring(1,20,p.name_full_formatted),
   position = substring(1,20,uar_get_code_display(p.position_cd)),
   date = dfr.updt_dt_tm"@SHORTDATETIME", id = dfr.updt_id, task = dfr.updt_task
   FROM dcp_forms_ref dfr,
    prsnl p
   WHERE dfr.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND dfr.updt_id=p.person_id
   ORDER BY name, date
   DETAIL
    detcnt = (detcnt+ 1), stat = alterlist(audit_data->detail_list,detcnt), audit_data->detail_list[
    detcnt].audit_type = "PFREF",
    audit_data->detail_list[detcnt].detail_info1 = description, audit_data->detail_list[detcnt].
    detail_info2 = " ", audit_data->detail_list[detcnt].name = name,
    audit_data->detail_list[detcnt].position = position, audit_data->detail_list[detcnt].updt_dt =
    date, audit_data->detail_list[detcnt].updt_id = id,
    audit_data->detail_list[detcnt].updt_task = task
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   form_section = concat(trim(substring(1,20,dfr.description),3),"/",trim(substring(1,19,dsr
      .description),3)), name = substring(1,20,p.name_full_formatted), position = substring(1,20,
    uar_get_code_display(p.position_cd)),
   date = dfd.updt_dt_tm"@SHORTDATETIME", id = dfd.updt_id, task = dfd.updt_task
   FROM dcp_forms_def dfd,
    prsnl p,
    dcp_forms_ref dfr,
    dcp_section_ref dsr
   WHERE dfd.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND dfd.dcp_forms_ref_id=dfr.dcp_forms_ref_id
    AND dfd.dcp_section_ref_id=dsr.dcp_section_ref_id
    AND dfd.updt_id=p.person_id
    AND (dfr.updt_cnt=
   (SELECT
    max(dfr1.updt_cnt)
    FROM dcp_forms_ref dfr1
    WHERE dfr1.dcp_forms_ref_id=dfr.dcp_forms_ref_id))
    AND (dsr.updt_cnt=
   (SELECT
    max(dsr1.updt_cnt)
    FROM dcp_section_ref dsr1
    WHERE dsr1.dcp_section_ref_id=dsr.dcp_section_ref_id))
   ORDER BY name, date
   DETAIL
    detcnt = (detcnt+ 1), stat = alterlist(audit_data->detail_list,detcnt), audit_data->detail_list[
    detcnt].audit_type = "PFDEF",
    audit_data->detail_list[detcnt].detail_info1 = form_section, audit_data->detail_list[detcnt].
    detail_info2 = " ", audit_data->detail_list[detcnt].name = name,
    audit_data->detail_list[detcnt].position = position, audit_data->detail_list[detcnt].updt_dt =
    date, audit_data->detail_list[detcnt].updt_id = id,
    audit_data->detail_list[detcnt].updt_task = task
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   section = substring(1,40,s.definition), name = substring(1,20,p.name_full_formatted), position =
   substring(1,20,uar_get_code_display(p.position_cd)),
   date = s.updt_dt_tm"@SHORTDATETIME", id = s.updt_id, task = s.updt_task
   FROM dcp_section_ref s,
    prsnl p
   WHERE s.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND s.updt_id=p.person_id
   ORDER BY name, date
   DETAIL
    detcnt = (detcnt+ 1), stat = alterlist(audit_data->detail_list,detcnt), audit_data->detail_list[
    detcnt].audit_type = "PFSECTION",
    audit_data->detail_list[detcnt].detail_info1 = section, audit_data->detail_list[detcnt].
    detail_info2 = " ", audit_data->detail_list[detcnt].name = name,
    audit_data->detail_list[detcnt].position = position, audit_data->detail_list[detcnt].updt_dt =
    date, audit_data->detail_list[detcnt].updt_id = id,
    audit_data->detail_list[detcnt].updt_task = task
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   pref = substring(1,40,nvp.pvc_name), name = substring(1,20,p.name_full_formatted), position =
   substring(1,20,uar_get_code_display(p.position_cd)),
   date = nvp.updt_dt_tm"@SHORTDATETIME", id = nvp.updt_id, task = nvp.updt_task
   FROM name_value_prefs nvp,
    prsnl p,
    detail_prefs dp
   WHERE nvp.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND nvp.parent_entity_name="DETAIL_PREFS"
    AND nvp.parent_entity_id=dp.detail_prefs_id
    AND dp.prsnl_id=0
    AND nvp.updt_id=p.person_id
   ORDER BY name, date
   DETAIL
    detcnt = (detcnt+ 1), stat = alterlist(audit_data->detail_list,detcnt), audit_data->detail_list[
    detcnt].audit_type = "PREFMAINT",
    audit_data->detail_list[detcnt].detail_info1 = pref, audit_data->detail_list[detcnt].detail_info2
     = " ", audit_data->detail_list[detcnt].name = name,
    audit_data->detail_list[detcnt].position = position, audit_data->detail_list[detcnt].updt_dt =
    date, audit_data->detail_list[detcnt].updt_id = id,
    audit_data->detail_list[detcnt].updt_task = task
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   section = substring(1,40,wvs.display_name), name = substring(1,20,p.name_full_formatted), position
    = substring(1,20,uar_get_code_display(p.position_cd)),
   date = wvs.updt_dt_tm"@SHORTDATETIME", id = wvs.updt_id, task = wvs.updt_task
   FROM working_view_section wvs,
    prsnl p
   WHERE wvs.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND wvs.updt_id=p.person_id
   ORDER BY name, date
   DETAIL
    detcnt = (detcnt+ 1), stat = alterlist(audit_data->detail_list,detcnt), audit_data->detail_list[
    detcnt].audit_type = "INET",
    audit_data->detail_list[detcnt].detail_info1 = section, audit_data->detail_list[detcnt].
    detail_info2 = " ", audit_data->detail_list[detcnt].name = name,
    audit_data->detail_list[detcnt].position = position, audit_data->detail_list[detcnt].updt_dt =
    date, audit_data->detail_list[detcnt].updt_id = id,
    audit_data->detail_list[detcnt].updt_task = task
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   code_value_set = concat(trim(substring(1,19,cvs.display),3),"/",trim(substring(1,20,cv.display),3)
    ), name = substring(1,20,p.name_full_formatted), position = substring(1,20,uar_get_code_display(p
     .position_cd)),
   date = cv.updt_dt_tm"@SHORTDATETIME", id = cv.updt_id, task = cv.updt_task
   FROM code_value cv,
    code_value_set cvs,
    prsnl p
   WHERE cv.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND cv.updt_id=p.person_id
    AND cv.code_set=cvs.code_set
   ORDER BY name, date
   DETAIL
    detcnt = (detcnt+ 1), stat = alterlist(audit_data->detail_list,detcnt), audit_data->detail_list[
    detcnt].audit_type = "CODEVALUE",
    audit_data->detail_list[detcnt].detail_info1 = code_value_set, audit_data->detail_list[detcnt].
    detail_info2 = " ", audit_data->detail_list[detcnt].name = name,
    audit_data->detail_list[detcnt].position = position, audit_data->detail_list[detcnt].updt_dt =
    date, audit_data->detail_list[detcnt].updt_id = id,
    audit_data->detail_list[detcnt].updt_task = task
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   menu_item = em.item_desc, name = substring(1,20,p.name_full_formatted), position = substring(1,20,
    uar_get_code_display(p.position_cd)),
   date = em.updt_dt_tm"@SHORTDATETIME", id = em.updt_id, task = em.updt_task
   FROM explorer_menu em,
    prsnl p
   WHERE em.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND (em.updt_cnt=
   (SELECT
    max(em1.updt_cnt)
    FROM explorer_menu em1
    WHERE em1.menu_id=em.menu_id))
    AND em.updt_id=p.person_id
   ORDER BY name, date
   DETAIL
    detcnt = (detcnt+ 1), stat = alterlist(audit_data->detail_list,detcnt), audit_data->detail_list[
    detcnt].audit_type = "EXMENU",
    audit_data->detail_list[detcnt].detail_info1 = menu_item, audit_data->detail_list[detcnt].
    detail_info2 = " ", audit_data->detail_list[detcnt].name = name,
    audit_data->detail_list[detcnt].position = position, audit_data->detail_list[detcnt].updt_dt =
    date, audit_data->detail_list[detcnt].updt_id = id,
    audit_data->detail_list[detcnt].updt_task = task
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   pref = substring(1,40,nvp.pvc_name), name = substring(1,20,p.name_full_formatted), position =
   substring(1,20,uar_get_code_display(p.position_cd)),
   date = nvp.updt_dt_tm"@SHORTDATETIME", id = nvp.updt_id, task = nvp.updt_task
   FROM name_value_prefs nvp,
    prsnl p,
    view_prefs vp
   WHERE nvp.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND nvp.parent_entity_name="VIEW_PREFS"
    AND nvp.parent_entity_id=vp.view_prefs_id
    AND vp.prsnl_id=0
    AND nvp.updt_id=p.person_id
   ORDER BY name, date
   DETAIL
    detcnt = (detcnt+ 1), stat = alterlist(audit_data->detail_list,detcnt), audit_data->detail_list[
    detcnt].audit_type = "VIEWPREFS",
    audit_data->detail_list[detcnt].detail_info1 = pref, audit_data->detail_list[detcnt].detail_info2
     = " ", audit_data->detail_list[detcnt].name = name,
    audit_data->detail_list[detcnt].position = position, audit_data->detail_list[detcnt].updt_dt =
    date, audit_data->detail_list[detcnt].updt_id = id,
    audit_data->detail_list[detcnt].updt_task = task
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   description = substring(1,40,pc.description), name = substring(1,20,p.name_full_formatted),
   position = substring(1,20,uar_get_code_display(p.position_cd)),
   date = pc.updt_dt_tm"@SHORTDATETIME", id = pc.updt_id, task = pc.updt_task
   FROM pathway_catalog pc,
    prsnl p
   WHERE pc.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND pc.updt_id=p.person_id
   ORDER BY name, date
   DETAIL
    detcnt = (detcnt+ 1), stat = alterlist(audit_data->detail_list,detcnt), audit_data->detail_list[
    detcnt].audit_type = "PPLANS",
    audit_data->detail_list[detcnt].detail_info1 = description, audit_data->detail_list[detcnt].
    detail_info2 = " ", audit_data->detail_list[detcnt].name = name,
    audit_data->detail_list[detcnt].position = position, audit_data->detail_list[detcnt].updt_dt =
    date, audit_data->detail_list[detcnt].updt_id = id,
    audit_data->detail_list[detcnt].updt_task = task
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   ops_job =
   IF (ot.job_grp_name=" ") substring(1,40,oj.name)
   ELSE substring(1,40,ot.job_grp_name)
   ENDIF
   , name = substring(1,20,p.name_full_formatted), position = substring(1,20,uar_get_code_display(p
     .position_cd)),
   date = ot.updt_dt_tm"@SHORTDATETIME", id = ot.updt_id, task = ot.updt_task
   FROM ops_task ot,
    ops_job oj,
    prsnl p
   WHERE ot.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND ot.updt_id=p.person_id
    AND ot.ops_job_id=oj.ops_job_id
   ORDER BY name, date
   DETAIL
    detcnt = (detcnt+ 1), stat = alterlist(audit_data->detail_list,detcnt), audit_data->detail_list[
    detcnt].audit_type = "OPSTASK",
    audit_data->detail_list[detcnt].detail_info1 = ops_job, audit_data->detail_list[detcnt].
    detail_info2 = " ", audit_data->detail_list[detcnt].name = name,
    audit_data->detail_list[detcnt].position = position, audit_data->detail_list[detcnt].updt_dt =
    date, audit_data->detail_list[detcnt].updt_id = id,
    audit_data->detail_list[detcnt].updt_task = task
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   ops_job_step = concat(trim(substring(1,25,
      IF (ot.job_grp_name=" ") oj.name
      ELSE ot.job_grp_name
      ENDIF
      ),3),"/",trim(substring(1,14,ojs.step_name),3)), name = substring(1,20,p.name_full_formatted),
   position = substring(1,20,uar_get_code_display(p.position_cd)),
   date = ot.updt_dt_tm"@SHORTDATETIME", id = ot.updt_id, task = ot.updt_task
   FROM ops_task ot,
    ops_job oj,
    ops_schedule_param osp,
    ops_job_step ojs,
    prsnl p
   WHERE osp.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND osp.updt_id=p.person_id
    AND osp.ops_task_id=ot.ops_task_id
    AND ot.ops_job_id=oj.ops_job_id
    AND osp.ops_job_step_id=ojs.ops_job_step_id
   ORDER BY name, date
   DETAIL
    detcnt = (detcnt+ 1), stat = alterlist(audit_data->detail_list,detcnt), audit_data->detail_list[
    detcnt].audit_type = "OPSSCHEDULE",
    audit_data->detail_list[detcnt].detail_info1 = ops_job_step, audit_data->detail_list[detcnt].
    detail_info2 = " ", audit_data->detail_list[detcnt].name = name,
    audit_data->detail_list[detcnt].position = position, audit_data->detail_list[detcnt].updt_dt =
    date, audit_data->detail_list[detcnt].updt_id = id,
    audit_data->detail_list[detcnt].updt_task = task
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   description = substring(1,40,pr.rule_name), name = substring(1,20,p.name_full_formatted), position
    = substring(1,20,uar_get_code_display(p.position_cd)),
   date = pr.updt_dt_tm"@SHORTDATETIME", id = pr.updt_id, task = pr.updt_task
   FROM pft_rule pr,
    prsnl p
   WHERE pr.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND pr.updt_id=p.person_id
   ORDER BY name, date
   DETAIL
    detcnt = (detcnt+ 1), stat = alterlist(audit_data->detail_list,detcnt), audit_data->detail_list[
    detcnt].audit_type = "PFTRULE",
    audit_data->detail_list[detcnt].detail_info1 = description, audit_data->detail_list[detcnt].
    detail_info2 = " ", audit_data->detail_list[detcnt].name = name,
    audit_data->detail_list[detcnt].position = position, audit_data->detail_list[detcnt].updt_dt =
    date, audit_data->detail_list[detcnt].updt_id = id,
    audit_data->detail_list[detcnt].updt_task = task
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   rule_action = concat(trim(substring(1,20,pr.rule_name),3),"/",trim(substring(1,19,pra.action_name)
     )), name = substring(1,20,p.name_full_formatted), position = substring(1,20,uar_get_code_display
    (p.position_cd)),
   date = pra.updt_dt_tm"@SHORTDATETIME", id = pra.updt_id, task = pra.updt_task
   FROM pft_rule_action pra,
    prsnl p,
    pft_rule pr
   WHERE pra.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND pra.updt_id=p.person_id
    AND pra.rule_id=pr.rule_id
   ORDER BY name, date
   DETAIL
    detcnt = (detcnt+ 1), stat = alterlist(audit_data->detail_list,detcnt), audit_data->detail_list[
    detcnt].audit_type = "PFTRULEACTION",
    audit_data->detail_list[detcnt].detail_info1 = rule_action, audit_data->detail_list[detcnt].
    detail_info2 = " ", audit_data->detail_list[detcnt].name = name,
    audit_data->detail_list[detcnt].position = position, audit_data->detail_list[detcnt].updt_dt =
    date, audit_data->detail_list[detcnt].updt_id = id,
    audit_data->detail_list[detcnt].updt_task = task
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   description = concat(trim(substring(1,20,pr.rule_desc),3),"/",trim(substring(1,19,prg.group_desc),
     3)), name = substring(1,20,p.name_full_formatted), position = substring(1,20,
    uar_get_code_display(p.position_cd)),
   date = prg.updt_dt_tm"@SHORTDATETIME", id = prg.updt_id, task = prg.updt_task
   FROM pft_rule_group prg,
    pft_rule pr,
    prsnl p
   WHERE prg.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND prg.updt_id=p.person_id
    AND prg.rule_id=pr.rule_id
   ORDER BY name, date
   DETAIL
    detcnt = (detcnt+ 1), stat = alterlist(audit_data->detail_list,detcnt), audit_data->detail_list[
    detcnt].audit_type = "PFTRULEGROUP",
    audit_data->detail_list[detcnt].detail_info1 = description, audit_data->detail_list[detcnt].
    detail_info2 = " ", audit_data->detail_list[detcnt].name = name,
    audit_data->detail_list[detcnt].position = position, audit_data->detail_list[detcnt].updt_dt =
    date, audit_data->detail_list[detcnt].updt_id = id,
    audit_data->detail_list[detcnt].updt_task = task
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   description = concat(trim(substring(1,20,prg.group_desc),3),"/",trim(substring(1,19,prq.value_disp
      ),3)), name = substring(1,20,p.name_full_formatted), position = substring(1,20,
    uar_get_code_display(p.position_cd)),
   date = prq.updt_dt_tm"@SHORTDATETIME", id = prq.updt_id, task = prq.updt_task
   FROM pft_rule_group prg,
    pft_rule_qualification prq,
    prsnl p
   WHERE prq.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND prq.updt_id=p.person_id
    AND prq.group_id=prg.group_id
   ORDER BY name, date
   DETAIL
    detcnt = (detcnt+ 1), stat = alterlist(audit_data->detail_list,detcnt), audit_data->detail_list[
    detcnt].audit_type = "PFTRULEQUAL",
    audit_data->detail_list[detcnt].detail_info1 = description, audit_data->detail_list[detcnt].
    detail_info2 = " ", audit_data->detail_list[detcnt].name = name,
    audit_data->detail_list[detcnt].position = position, audit_data->detail_list[detcnt].updt_dt =
    date, audit_data->detail_list[detcnt].updt_id = id,
    audit_data->detail_list[detcnt].updt_task = task
   WITH nocounter, separator = " ", format
  ;end select
  SELECT INTO "nl:"
   pref = substring(1,40,nvp.pvc_name), name = substring(1,20,p.name_full_formatted), position =
   substring(1,20,uar_get_code_display(p.position_cd)),
   date = nvp.updt_dt_tm"@SHORTDATETIME", id = nvp.updt_id, task = nvp.updt_task
   FROM name_value_prefs nvp,
    prsnl p,
    app_prefs ap
   WHERE nvp.updt_dt_tm BETWEEN cnvtdatetime(start_date) AND cnvtdatetime(end_date)
    AND nvp.parent_entity_name="APP_PREFS"
    AND nvp.parent_entity_id=ap.app_prefs_id
    AND ap.prsnl_id=0
    AND nvp.updt_id=p.person_id
   ORDER BY name, date
   DETAIL
    detcnt = (detcnt+ 1), stat = alterlist(audit_data->detail_list,detcnt), audit_data->detail_list[
    detcnt].audit_type = "APPPREFS",
    audit_data->detail_list[detcnt].detail_info1 = pref, audit_data->detail_list[detcnt].detail_info2
     = " ", audit_data->detail_list[detcnt].name = name,
    audit_data->detail_list[detcnt].position = position, audit_data->detail_list[detcnt].updt_dt =
    date, audit_data->detail_list[detcnt].updt_id = id,
    audit_data->detail_list[detcnt].updt_task = task
   WITH nocounter, separator = " ", format
  ;end select
 ENDIF
 SELECT INTO value(output_dest)
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD REPORT
   IF (( $AUD_TYPE="summary"))
    "Summary Change Audit Report from ", start_date"DD-MMM-YYYY;;D", col + 1,
    "to ", end_date"DD-MMM-YYYY;;D"
   ELSEIF (( $AUD_TYPE="detail"))
    "Detail Change Audit Report from ", start_date"DD-MMM-YYYY;;D", col + 1,
    "to ", end_date"DD-MMM-YYYY;;D"
    IF (( $DETAIL_AUD_TYPE="user"))
     row + 1, "Detail for user:", col + 1,
     detail_audit_user_name
    ELSEIF (( $DETAIL_AUD_TYPE="area"))
     row + 1, "Detail for area:", col + 1,
      $DETAIL_AUD_AREA
    ENDIF
   ENDIF
  DETAIL
   IF (( $AUD_TYPE="summary"))
    FOR (x = 1 TO size(audit_type->qual,5))
      row + 2
      IF ((audit_type->qual[x].audit_type="ORDERCATALOG"))
       "****Order Catalog Audit Summary****", row + 1,
       "This audit displays who made changes to the Order Catalog over the time period specified"
      ELSEIF ((audit_type->qual[x].audit_type="ORDERCATALOGSYNONYM"))
       "****Order Catalog Synonym Audit Summary****", row + 1,
       "This audit displays who made changes to Order Catalog Synonyms over the time period specified"
      ELSEIF ((audit_type->qual[x].audit_type="DTA"))
       "****Discrete Task Assay Audit Summary****", row + 1,
       "This audit displays who made changes made to DTAs over the time period specified"
      ELSEIF ((audit_type->qual[x].audit_type="EVENTSET1"))
       "****Event Set Audit Summary****", row + 1,
       "This audit displays who made changes to Event Sets over the time period specified"
      ELSEIF ((audit_type->qual[x].audit_type="EVENTSET2"))
       "****Event Set/Code Relationship Audit Summary****", row + 1,
       "This audit displays who made changes to Event Set/Code relationships over the time period specified"
      ELSEIF ((audit_type->qual[x].audit_type="PFREF"))
       "****PowerForm Definition Audit Summary****", row + 1,
       "This audit displays who made changes to PowerForm definitions over the time period specified"
      ELSEIF ((audit_type->qual[x].audit_type="PFDEF"))
       "****PowerForm Sections Audit Summary****", row + 1,
       "This audit displays who changed the sections included on PowerForms over the time period specified"
      ELSEIF ((audit_type->qual[x].audit_type="PFSECTION"))
       "****PowerForms Section Definition Audit Summary****", row + 1,
       "This audit displays who made changes to PowerForm section definitions over the time period specified"
      ELSEIF ((audit_type->qual[x].audit_type="PREFMAINT"))
       "****Detailed Preferences Audit Summary****", row + 1,
       "This audit displays who made changes to Detailed Preferences over the time period specified"
      ELSEIF ((audit_type->qual[x].audit_type="INET"))
       "****INet Working View Audit Summary****", row + 1,
       "This audit displays who made changes to INet Working View over the time period specified"
      ELSEIF ((audit_type->qual[x].audit_type="CODEVALUE"))
       "****Code Values Audit Summary****", row + 1,
       "This audit displays who made changes to Code Values over the time period specified"
      ELSEIF ((audit_type->qual[x].audit_type="EXMENU"))
       "****Explorer Menu Audit Summary****", row + 1,
       "This audit displays who made changes to Explorer Menu items over the time period specified"
      ELSEIF ((audit_type->qual[x].audit_type="PPLANS"))
       "****PowerPlans Audit Summary****", row + 1,
       "This audit displays who made changes to PowerPlans over the time period specified"
      ELSEIF ((audit_type->qual[x].audit_type="OPSTASK"))
       "****Operation Jobs Settings Audit Summary****", row + 1,
       "This audit displays who made changes to Ops Jobs Settings over the time period specified"
      ELSEIF ((audit_type->qual[x].audit_type="OPSSCHEDULE"))
       "****Operation Jobs Steps Audit Summary****", row + 1,
       "This audit displays who made changes to Ops Jobs Steps Details over the time period specified"
      ELSEIF ((audit_type->qual[x].audit_type="PFTRULE"))
       "****Claim Rules Top-Level Information Audit Summary****", row + 1,
       "This audit displays who made changes to Claim Rule top-level information ",
       row + 1, "(i.e. type, name, description, etc.) over the time period specified"
      ELSEIF ((audit_type->qual[x].audit_type="PFTRULEACTION"))
       "****Claim Rules Action Information Audit Summary****", row + 1,
       "This audit displays who made changes to Claim Rule action information over the time period specified"
      ELSEIF ((audit_type->qual[x].audit_type="PFTRULEGROUP"))
       "****Claim Rules Qualification Grouping Information Audit Summary****", row + 1,
       "This audit displays who made changes to Claim Rule Qualification Grouping information over the time period specified"
      ELSEIF ((audit_type->qual[x].audit_type="PFTRULEQUAL"))
       "****Claim Rules Qualification Detail Information Audit Summary****", row + 1,
       "This audit displays who made changes to Claim Rule Qualification detail information over the time period specified"
      ELSEIF ((audit_type->qual[x].audit_type="APPPREFS"))
       "****Application-Level Preferences Audit Summary****", row + 1,
       "This audit displays who made changes to Application-Level Preferences over the time period specified"
      ELSEIF ((audit_type->qual[x].audit_type="VIEWPREFS"))
       "****View-Level Preferences Audit Summary****", row + 1,
       "This audit displays who made changes to View-Level Preferences over the time period specified"
      ENDIF
      sumheadcnt = 0
      FOR (y = 1 TO size(audit_data->summary_list,5))
        IF ((audit_data->summary_list[y].audit_type=audit_type->qual[x].audit_type))
         sumheadcnt = (sumheadcnt+ 1)
        ENDIF
      ENDFOR
      IF (sumheadcnt > 0)
       row + 2, "Name", col + 19,
       "Position", col + 15, "Username",
       col + 10, "Count"
      ELSE
       row + 2, col + 5, "No data returned for this audit"
      ENDIF
      FOR (y = 1 TO size(audit_data->summary_list,5))
        IF ((audit_data->summary_list[y].audit_type=audit_type->qual[x].audit_type))
         row + 1
         IF ((audit_data->summary_list[y].name=" "))
          blank_name
         ELSE
          audit_data->summary_list[y].name
         ENDIF
         col + 3
         IF ((audit_data->summary_list[y].position=" "))
          blank_pos
         ELSE
          audit_data->summary_list[y].position
         ENDIF
         col + 3, audit_data->summary_list[y].username, col + 3,
         audit_data->summary_list[y].count";L"
        ENDIF
      ENDFOR
    ENDFOR
   ELSEIF (( $AUD_TYPE="detail"))
    row + 2
    FOR (x = 1 TO detail_iterate)
      IF (((( $DETAIL_AUD_TYPE="area")
       AND detail_audit_area="ORDERCATALOG") OR (( $DETAIL_AUD_TYPE="user")
       AND x=1)) )
       "****Order Catalog Audit Detail****", row + 1,
       "This audit displays who made changes to the Order Catalog over the time period specified",
       detheadcnt = 0
       IF (( $DETAIL_AUD_TYPE="area"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type="ORDERCATALOG")
           AND (audit_data->detail_list[z].updt_id=detail_audit_user))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ENDIF
       IF (detheadcnt > 0)
        row + 2, "Name", col + 18,
        "Position", col + 14, "Description",
        col + 31, "Update Dt/Tm", col + 8,
        "Update Task"
        IF (( $DETAIL_AUD_TYPE="user"))
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type="ORDERCATALOG")
            AND (audit_data->detail_list[z].updt_id=detail_audit_user))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ELSE
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ENDIF
       ELSE
        row + 2, col + 5, "No data returned for this audit"
       ENDIF
      ELSEIF (((( $DETAIL_AUD_TYPE="area")
       AND detail_audit_area="ORDERCATALOGSYNONYM") OR (( $DETAIL_AUD_TYPE="user")
       AND x=2)) )
       IF (( $DETAIL_AUD_TYPE="area"))
        "****Order Catalog Synonym Audit Detail****"
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        row + 2, "****Order Catalog Synonym Audit Detail****"
       ENDIF
       row + 1,
       "This audit displays who made changes to Order Catalog Synonyms over the time period specified",
       detheadcnt = 0
       IF (( $DETAIL_AUD_TYPE="area"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type="ORDERCATALOGSYNONYM")
           AND (audit_data->detail_list[z].updt_id=detail_audit_user))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ENDIF
       IF (detheadcnt > 0)
        row + 2, "Name", col + 18,
        "Position", col + 14, "Mnemonic",
        col + 34, "Update Dt/Tm", col + 8,
        "Update Task"
        IF (( $DETAIL_AUD_TYPE="user"))
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type="ORDERCATALOGSYNONYM")
            AND (audit_data->detail_list[z].updt_id=detail_audit_user))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ELSE
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ENDIF
       ELSE
        row + 2, col + 5, "No data returned for this audit"
       ENDIF
      ELSEIF (((( $DETAIL_AUD_TYPE="area")
       AND detail_audit_area="DTA") OR (( $DETAIL_AUD_TYPE="user")
       AND x=3)) )
       IF (( $DETAIL_AUD_TYPE="area"))
        "****Discrete Task Assay Audit Detail****"
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        row + 2, "****Discrete Task Assay Audit Detail****"
       ENDIF
       row + 1, "This audit displays who made changes made to DTAs over the time period specified",
       detheadcnt = 0
       IF (( $DETAIL_AUD_TYPE="area"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type="DTA")
           AND (audit_data->detail_list[z].updt_id=detail_audit_user))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ENDIF
       IF (detheadcnt > 0)
        row + 2, "Name", col + 18,
        "Position", col + 14, "Mnemonic",
        col + 34, "Update Dt/Tm", col + 8,
        "Update Task"
        IF (( $DETAIL_AUD_TYPE="user"))
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type="DTA")
            AND (audit_data->detail_list[z].updt_id=detail_audit_user))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ELSE
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ENDIF
       ELSE
        row + 2, col + 5, "No data returned for this audit"
       ENDIF
      ELSEIF (((( $DETAIL_AUD_TYPE="area")
       AND detail_audit_area="EVENTSET1") OR (( $DETAIL_AUD_TYPE="user")
       AND x=4)) )
       IF (( $DETAIL_AUD_TYPE="area"))
        "****Event Set Audit Detail****"
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        row + 2, "****Event Set Audit Detail****"
       ENDIF
       row + 1, "This audit displays who made changes to Event Sets over the time period specified",
       detheadcnt = 0
       IF (( $DETAIL_AUD_TYPE="area"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type="EVENTSET1")
           AND (audit_data->detail_list[z].updt_id=detail_audit_user))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ENDIF
       IF (detheadcnt > 0)
        row + 2, "Name", col + 18,
        "Position", col + 14, "Description",
        col + 31, "Update Dt/Tm", col + 8,
        "Update Task"
        IF (( $DETAIL_AUD_TYPE="user"))
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type="EVENTSET1")
            AND (audit_data->detail_list[z].updt_id=detail_audit_user))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ELSE
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ENDIF
       ELSE
        row + 2, col + 5, "No data returned for this audit"
       ENDIF
      ELSEIF (((( $DETAIL_AUD_TYPE="area")
       AND detail_audit_area="EVENTSET2") OR (( $DETAIL_AUD_TYPE="user")
       AND x=5)) )
       IF (( $DETAIL_AUD_TYPE="area"))
        "****Event Set/Code Set Relationship Audit Detail****"
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        row + 2, "****Event Set/Code Set Relationship Audit Detail****"
       ENDIF
       row + 1,
       "This audit displays who made changes to Event Set/Code relationships over the time period specified",
       detheadcnt = 0
       IF (( $DETAIL_AUD_TYPE="area"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type="EVENTSET2")
           AND (audit_data->detail_list[z].updt_id=detail_audit_user))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ENDIF
       IF (detheadcnt > 0)
        row + 2, "Name", col + 18,
        "Position", col + 14, "Description",
        col + 31, "Update Dt/Tm", col + 8,
        "Update Task"
        IF (( $DETAIL_AUD_TYPE="user"))
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type="EVENTSET2")
            AND (audit_data->detail_list[z].updt_id=detail_audit_user))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ELSE
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ENDIF
       ELSE
        row + 2, col + 5, "No data returned for this audit"
       ENDIF
      ELSEIF (((( $DETAIL_AUD_TYPE="area")
       AND detail_audit_area="PFREF") OR (( $DETAIL_AUD_TYPE="user")
       AND x=6)) )
       IF (( $DETAIL_AUD_TYPE="area"))
        "****PowerForm Definition Audit Detail****"
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        row + 2, "****PowerForm Definition Audit Detail****"
       ENDIF
       row + 1,
       "This audit displays who made changes to PowerForm definitions over the time period specified",
       detheadcnt = 0
       IF (( $DETAIL_AUD_TYPE="area"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type="PFREF")
           AND (audit_data->detail_list[z].updt_id=detail_audit_user))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ENDIF
       IF (detheadcnt > 0)
        row + 2, "Name", col + 18,
        "Position", col + 14, "Description",
        col + 31, "Update Dt/Tm", col + 8,
        "Update Task"
        IF (( $DETAIL_AUD_TYPE="user"))
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type="PFREF")
            AND (audit_data->detail_list[z].updt_id=detail_audit_user))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ELSE
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ENDIF
       ELSE
        row + 2, col + 5, "No data returned for this audit"
       ENDIF
      ELSEIF (((( $DETAIL_AUD_TYPE="area")
       AND detail_audit_area="PFDEF") OR (( $DETAIL_AUD_TYPE="user")
       AND x=7)) )
       IF (( $DETAIL_AUD_TYPE="area"))
        "****PowerForm Sections Audit Detail****"
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        row + 2, "****PowerForm Sections Audit Detail****"
       ENDIF
       row + 1,
       "This audit displays who changed the sections included on PowerForms over the time period specified",
       detheadcnt = 0
       IF (( $DETAIL_AUD_TYPE="area"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type="PFDEF")
           AND (audit_data->detail_list[z].updt_id=detail_audit_user))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ENDIF
       IF (detheadcnt > 0)
        row + 2, "Name", col + 18,
        "Position", col + 14, "Form/Section",
        col + 30, "Update Dt/Tm", col + 8,
        "Update Task"
        IF (( $DETAIL_AUD_TYPE="user"))
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type="PFDEF")
            AND (audit_data->detail_list[z].updt_id=detail_audit_user))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ELSE
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ENDIF
       ELSE
        row + 2, col + 5, "No data returned for this audit"
       ENDIF
      ELSEIF (((( $DETAIL_AUD_TYPE="area")
       AND detail_audit_area="PFSECTION") OR (( $DETAIL_AUD_TYPE="user")
       AND x=8)) )
       IF (( $DETAIL_AUD_TYPE="area"))
        "****PowerForms Section Definition Audit Detail****"
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        row + 2, "****PowerForms Section Definition Audit Detail****"
       ENDIF
       row + 1,
       "This audit displays who made changes to PowerForm section definitions over the time period specified",
       detheadcnt = 0
       IF (( $DETAIL_AUD_TYPE="area"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type="PFSECTION")
           AND (audit_data->detail_list[z].updt_id=detail_audit_user))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ENDIF
       IF (detheadcnt > 0)
        row + 2, "Name", col + 18,
        "Position", col + 14, "Section",
        col + 35, "Update Dt/Tm", col + 8,
        "Update Task"
        IF (( $DETAIL_AUD_TYPE="user"))
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type="PFSECTION")
            AND (audit_data->detail_list[z].updt_id=detail_audit_user))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ELSE
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ENDIF
       ELSE
        row + 2, col + 5, "No data returned for this audit"
       ENDIF
      ELSEIF (((( $DETAIL_AUD_TYPE="area")
       AND detail_audit_area="PREFMAINT") OR (( $DETAIL_AUD_TYPE="user")
       AND x=9)) )
       IF (( $DETAIL_AUD_TYPE="area"))
        "****Detailed Preferences Audit Detail****"
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        row + 2, "****Detailed Preferences Audit Detail****"
       ENDIF
       row + 1,
       "This audit displays who made changes to Detailed Preferences over the time period specified",
       detheadcnt = 0
       IF (( $DETAIL_AUD_TYPE="area"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type="PREFMAINT")
           AND (audit_data->detail_list[z].updt_id=detail_audit_user))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ENDIF
       IF (detheadcnt > 0)
        row + 2, "Name", col + 18,
        "Position", col + 14, "Preference",
        col + 32, "Update Dt/Tm", col + 8,
        "Update Task"
        IF (( $DETAIL_AUD_TYPE="user"))
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type="PREFMAINT")
            AND (audit_data->detail_list[z].updt_id=detail_audit_user))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ELSE
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ENDIF
       ELSE
        row + 2, col + 5, "No data returned for this audit"
       ENDIF
      ELSEIF (((( $DETAIL_AUD_TYPE="area")
       AND detail_audit_area="INET") OR (( $DETAIL_AUD_TYPE="user")
       AND x=10)) )
       IF (( $DETAIL_AUD_TYPE="area"))
        "****INet Working View Audit Detail****"
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        row + 2, "****INet Working View Audit Detail****"
       ENDIF
       row + 1,
       "This audit displays who made changes to INet Working View over the time period specified",
       detheadcnt = 0
       IF (( $DETAIL_AUD_TYPE="area"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type="INET")
           AND (audit_data->detail_list[z].updt_id=detail_audit_user))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ENDIF
       IF (detheadcnt > 0)
        row + 2, "Name", col + 18,
        "Position", col + 14, "Section",
        col + 35, "Update Dt/Tm", col + 8,
        "Update Task"
        IF (( $DETAIL_AUD_TYPE="user"))
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type="INET")
            AND (audit_data->detail_list[z].updt_id=detail_audit_user))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ELSE
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ENDIF
       ELSE
        row + 2, col + 5, "No data returned for this audit"
       ENDIF
      ELSEIF (((( $DETAIL_AUD_TYPE="area")
       AND detail_audit_area="CODEVALUE") OR (( $DETAIL_AUD_TYPE="user")
       AND x=11)) )
       IF (( $DETAIL_AUD_TYPE="area"))
        "****Code Values Audit Detail****"
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        row + 2, "****Code Values Audit Detail****"
       ENDIF
       row + 1, "This audit displays who made changes to Code Values over the time period specified",
       detheadcnt = 0
       IF (( $DETAIL_AUD_TYPE="area"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type="CODEVALUE")
           AND (audit_data->detail_list[z].updt_id=detail_audit_user))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ENDIF
       IF (detheadcnt > 0)
        row + 2, "Name", col + 18,
        "Position", col + 14, "Code Set/Value",
        col + 28, "Update Dt/Tm", col + 8,
        "Update Task"
        IF (( $DETAIL_AUD_TYPE="user"))
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type="CODEVALUE")
            AND (audit_data->detail_list[z].updt_id=detail_audit_user))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ELSE
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ENDIF
       ELSE
        row + 2, col + 5, "No data returned for this audit"
       ENDIF
      ELSEIF (((( $DETAIL_AUD_TYPE="area")
       AND detail_audit_area="EXMENU") OR (( $DETAIL_AUD_TYPE="user")
       AND x=12)) )
       IF (( $DETAIL_AUD_TYPE="area"))
        "****Explorer Menu Audit Detail****"
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        row + 2, "****Explorer Menu Audit Detail****"
       ENDIF
       row + 1,
       "This audit displays who made changes to Explorer Menu items over the time period specified",
       detheadcnt = 0
       IF (( $DETAIL_AUD_TYPE="area"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type="EXMENU")
           AND (audit_data->detail_list[z].updt_id=detail_audit_user))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ENDIF
       IF (detheadcnt > 0)
        row + 2, "Name", col + 18,
        "Position", col + 14, "Menu Item",
        col + 33, "Update Dt/Tm", col + 8,
        "Update Task"
        IF (( $DETAIL_AUD_TYPE="user"))
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type="EXMENU")
            AND (audit_data->detail_list[z].updt_id=detail_audit_user))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ELSE
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ENDIF
       ELSE
        row + 2, col + 5, "No data returned for this audit"
       ENDIF
      ELSEIF (((( $DETAIL_AUD_TYPE="area")
       AND detail_audit_area="VIEWPREFS") OR (( $DETAIL_AUD_TYPE="user")
       AND x=13)) )
       IF (( $DETAIL_AUD_TYPE="area"))
        "****View-Level Preferences Audit Detail****"
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        row + 2, "****View-Level Preferences Audit Detail****"
       ENDIF
       row + 1,
       "This audit displays who made changes to View-Level Preferences over the time period specified",
       detheadcnt = 0
       IF (( $DETAIL_AUD_TYPE="area"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type="VIEWPREFS")
           AND (audit_data->detail_list[z].updt_id=detail_audit_user))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ENDIF
       IF (detheadcnt > 0)
        row + 2, "Name", col + 18,
        "Position", col + 14, "Preference",
        col + 32, "Update Dt/Tm", col + 8,
        "Update Task"
        IF (( $DETAIL_AUD_TYPE="user"))
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type="VIEWPREFS")
            AND (audit_data->detail_list[z].updt_id=detail_audit_user))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ELSE
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ENDIF
       ELSE
        row + 2, col + 5, "No data returned for this audit"
       ENDIF
      ELSEIF (((( $DETAIL_AUD_TYPE="area")
       AND detail_audit_area="PPLANS") OR (( $DETAIL_AUD_TYPE="user")
       AND x=14)) )
       IF (( $DETAIL_AUD_TYPE="area"))
        "****PowerPlans Audit Detail****"
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        row + 2, "****PowerPlans Audit Detail****"
       ENDIF
       row + 1, "This audit displays who made changes to PowerPlans over the time period specified",
       detheadcnt = 0
       IF (( $DETAIL_AUD_TYPE="area"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type="PPLANS")
           AND (audit_data->detail_list[z].updt_id=detail_audit_user))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ENDIF
       IF (detheadcnt > 0)
        row + 2, "Name", col + 18,
        "Position", col + 14, "Description",
        col + 31, "Update Dt/Tm", col + 8,
        "Update Task"
        IF (( $DETAIL_AUD_TYPE="user"))
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type="PPLANS")
            AND (audit_data->detail_list[z].updt_id=detail_audit_user))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ELSE
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ENDIF
       ELSE
        row + 2, col + 5, "No data returned for this audit"
       ENDIF
      ELSEIF (((( $DETAIL_AUD_TYPE="area")
       AND detail_audit_area="OPSTASK") OR (( $DETAIL_AUD_TYPE="user")
       AND x=15)) )
       IF (( $DETAIL_AUD_TYPE="area"))
        "****Operation Jobs Settings Audit Detail****"
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        row + 2, "****Operation Jobs Settings Audit Detail****"
       ENDIF
       row + 1,
       "This audit displays who made changes to Ops Jobs Settings over the time period specified",
       detheadcnt = 0
       IF (( $DETAIL_AUD_TYPE="area"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type="OPSTASK")
           AND (audit_data->detail_list[z].updt_id=detail_audit_user))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ENDIF
       IF (detheadcnt > 0)
        row + 2, "Name", col + 18,
        "Position", col + 14, "Ops Job",
        col + 35, "Update Dt/Tm", col + 8,
        "Update Task"
        IF (( $DETAIL_AUD_TYPE="user"))
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type="OPSTASK")
            AND (audit_data->detail_list[z].updt_id=detail_audit_user))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ELSE
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ENDIF
       ELSE
        row + 2, col + 5, "No data returned for this audit"
       ENDIF
      ELSEIF (((( $DETAIL_AUD_TYPE="area")
       AND detail_audit_area="OPSSCHEDULE") OR (( $DETAIL_AUD_TYPE="user")
       AND x=16)) )
       IF (( $DETAIL_AUD_TYPE="area"))
        "****Operation Jobs Steps Audit Detail****"
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        row + 2, "****Operation Jobs Steps Audit Detail****"
       ENDIF
       row + 1,
       "This audit displays who made changes to Ops Jobs Steps Details over the time period specified",
       detheadcnt = 0
       IF (( $DETAIL_AUD_TYPE="area"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type="OPSSCHEDULE")
           AND (audit_data->detail_list[z].updt_id=detail_audit_user))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ENDIF
       IF (detheadcnt > 0)
        row + 2, "Name", col + 18,
        "Position", col + 14, "Ops Job/Step",
        col + 30, "Update Dt/Tm", col + 8,
        "Update Task"
        IF (( $DETAIL_AUD_TYPE="user"))
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type="OPSSCHEDULE")
            AND (audit_data->detail_list[z].updt_id=detail_audit_user))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ELSE
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ENDIF
       ELSE
        row + 2, col + 5, "No data returned for this audit"
       ENDIF
      ELSEIF (((( $DETAIL_AUD_TYPE="area")
       AND detail_audit_area="PFTRULE") OR (( $DETAIL_AUD_TYPE="user")
       AND x=17)) )
       IF (( $DETAIL_AUD_TYPE="area"))
        "****Claim Rules Top-Level Information Audit Detail****"
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        row + 2, "****Claim Rules Top-Level Information Audit Detail****"
       ENDIF
       row + 1, "This audit displays who made changes to Claim Rule top-level information ", row + 1,
       "(i.e. type, name, description, etc.) over the time period specified", detheadcnt = 0
       IF (( $DETAIL_AUD_TYPE="area"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type="PFTRULE")
           AND (audit_data->detail_list[z].updt_id=detail_audit_user))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ENDIF
       IF (detheadcnt > 0)
        row + 2, "Name", col + 18,
        "Position", col + 14, "Rule Name",
        col + 33, "Update Dt/Tm", col + 8,
        "Update Task"
        IF (( $DETAIL_AUD_TYPE="user"))
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type="PFTRULE")
            AND (audit_data->detail_list[z].updt_id=detail_audit_user))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ELSE
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ENDIF
       ELSE
        row + 2, col + 5, "No data returned for this audit"
       ENDIF
      ELSEIF (((( $DETAIL_AUD_TYPE="area")
       AND detail_audit_area="PFTRULEACTION") OR (( $DETAIL_AUD_TYPE="user")
       AND x=18)) )
       IF (( $DETAIL_AUD_TYPE="area"))
        "****Claim Rules Action Information Audit Detail****"
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        row + 2, "****Claim Rules Action Information Audit Detail****"
       ENDIF
       row + 1,
       "This audit displays who made changes to Claim Rule action information over the time period specified",
       detheadcnt = 0
       IF (( $DETAIL_AUD_TYPE="area"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type="PFTRULEACTION")
           AND (audit_data->detail_list[z].updt_id=detail_audit_user))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ENDIF
       IF (detheadcnt > 0)
        row + 2, "Name", col + 18,
        "Position", col + 14, "Rule/Action",
        col + 31, "Update Dt/Tm", col + 8,
        "Update Task"
        IF (( $DETAIL_AUD_TYPE="user"))
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type="PFTRULEACTION")
            AND (audit_data->detail_list[z].updt_id=detail_audit_user))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ELSE
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ENDIF
       ELSE
        row + 2, col + 5, "No data returned for this audit"
       ENDIF
      ELSEIF (((( $DETAIL_AUD_TYPE="area")
       AND detail_audit_area="PFTRULEGROUP") OR (( $DETAIL_AUD_TYPE="user")
       AND x=19)) )
       IF (( $DETAIL_AUD_TYPE="area"))
        "****Claim Rules Qualification Grouping Information Audit Detail****"
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        row + 2, "****Claim Rules Qualification Grouping Information Audit Detail****"
       ENDIF
       row + 1,
       "This audit displays who made changes to Claim Rule Qualification Grouping information over the time period specified",
       detheadcnt = 0
       IF (( $DETAIL_AUD_TYPE="area"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type="PFTRULEGROUP")
           AND (audit_data->detail_list[z].updt_id=detail_audit_user))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ENDIF
       IF (detheadcnt > 0)
        row + 2, "Name", col + 18,
        "Position", col + 14, "Rule/Group Name",
        col + 27, "Update Dt/Tm", col + 8,
        "Update Task"
        IF (( $DETAIL_AUD_TYPE="user"))
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type="PFTRULEGROUP")
            AND (audit_data->detail_list[z].updt_id=detail_audit_user))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ELSE
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ENDIF
       ELSE
        row + 2, col + 5, "No data returned for this audit"
       ENDIF
      ELSEIF (((( $DETAIL_AUD_TYPE="area")
       AND detail_audit_area="PFTRULEQUAL") OR (( $DETAIL_AUD_TYPE="user")
       AND x=20)) )
       IF (( $DETAIL_AUD_TYPE="area"))
        "****Claim Rules Qualification Detail Information Audit Detail****"
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        row + 2, "****Claim Rules Qualification Detail Information Audit Detail****"
       ENDIF
       row + 1,
       "This audit displays who made changes to Claim Rule Qualification detail information over the time period specified",
       detheadcnt = 0
       IF (( $DETAIL_AUD_TYPE="area"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type="PFTRULEQUAL")
           AND (audit_data->detail_list[z].updt_id=detail_audit_user))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ENDIF
       IF (detheadcnt > 0)
        row + 2, "Name", col + 18,
        "Position", col + 14, "Group/Qualification Name",
        col + 18, "Update Dt/Tm", col + 8,
        "Update Task"
        IF (( $DETAIL_AUD_TYPE="user"))
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type="PFTRULEQUAL")
            AND (audit_data->detail_list[z].updt_id=detail_audit_user))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ELSE
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ENDIF
       ELSE
        row + 2, col + 5, "No data returned for this audit"
       ENDIF
      ELSEIF (((( $DETAIL_AUD_TYPE="area")
       AND detail_audit_area="APPPREFS") OR (( $DETAIL_AUD_TYPE="user")
       AND x=21)) )
       IF (( $DETAIL_AUD_TYPE="area"))
        "****Application-Level Preferences Audit Detail****"
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        row + 2, "****Application-Level Preferences Audit Detail****"
       ENDIF
       row + 1,
       "This audit displays who made changes to Application-Level Preferences over the time period specified",
       detheadcnt = 0
       IF (( $DETAIL_AUD_TYPE="area"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ELSEIF (( $DETAIL_AUD_TYPE="user"))
        FOR (z = 1 TO size(audit_data->detail_list,5))
          IF ((audit_data->detail_list[z].audit_type="APPPREFS")
           AND (audit_data->detail_list[z].updt_id=detail_audit_user))
           detheadcnt = (detheadcnt+ 1)
          ENDIF
        ENDFOR
       ENDIF
       IF (detheadcnt > 0)
        row + 2, "Name", col + 18,
        "Position", col + 14, "Preference",
        col + 32, "Update Dt/Tm", col + 8,
        "Update Task"
        IF (( $DETAIL_AUD_TYPE="user"))
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type="APPPREFS")
            AND (audit_data->detail_list[z].updt_id=detail_audit_user))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ELSE
         FOR (z = 1 TO size(audit_data->detail_list,5))
           IF ((audit_data->detail_list[z].audit_type=detail_audit_area))
            row + 1, audit_data->detail_list[z].name, col + 2,
            audit_data->detail_list[z].position, col + 2, audit_data->detail_list[z].detail_info1";L",
            col + 2, audit_data->detail_list[z].updt_dt"@SHORTDATETIME", col + 3,
            audit_data->detail_list[z].updt_task";L"
           ENDIF
         ENDFOR
        ENDIF
       ELSE
        row + 2, col + 5, "No data returned for this audit"
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
  FOOT REPORT
   row + 2, "End of report"
  WITH maxcol = 136, maxrow = 60
 ;end select
 IF (is_ops_job=true)
  CALL pause(5)
  IF (size(trim( $EMAIL)) > 0)
   CALL emailfile(trim( $EMAIL),emailfrom,emailsubject,emailbody,"ccluserdir:ams_change_audit.rtf")
  ENDIF
 ENDIF
 SUBROUTINE emailfile(vcrecep,vcfrom,vcsubj,vcbody,vcfile)
   DECLARE retval = i2
   RECORD email_request(
     1 recepstr = vc
     1 fromstr = vc
     1 subjectstr = vc
     1 bodystr = vc
     1 filenamestr = vc
   ) WITH protect
   RECORD email_reply(
     1 status = c1
     1 errorstr = vc
   ) WITH protect
   SET email_request->recepstr = vcrecep
   SET email_request->fromstr = vcfrom
   SET email_request->subjectstr = vcsubj
   SET email_request->bodystr = vcbody
   SET email_request->filenamestr = vcfile
   EXECUTE ams_run_email_file  WITH replace("REQUEST",email_request), replace("REPLY",email_reply)
   IF ((email_reply->status="S"))
    SET retval = 1
    SET stat = remove(vcfile)
   ELSE
    SET retval = 0
   ENDIF
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE amsuser(a_prsnl_id)
   DECLARE user_ind = i2 WITH protect, noconstant(false)
   DECLARE prsnl_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",213,"PRSNL"))
   SELECT INTO "nl:"
    p.person_id
    FROM person_name p
    PLAN (p
     WHERE p.person_id=a_prsnl_id
      AND p.name_type_cd=prsnl_cd
      AND p.name_title="Cerner AMS"
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    DETAIL
     IF (p.person_id > 0)
      user_ind = true
     ENDIF
    WITH nocounter
   ;end select
   RETURN(user_ind)
 END ;Subroutine
 SUBROUTINE updtdminfo(a_prog_name)
   DECLARE found = i2 WITH protect, noconstant(false)
   DECLARE info_nbr = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM dm_info d
    PLAN (d
     WHERE d.info_domain="AMS_TOOLKIT"
      AND d.info_name=a_prog_name)
    DETAIL
     found = true, info_nbr = (d.info_number+ 1)
    WITH nocounter
   ;end select
   IF (found=false)
    INSERT  FROM dm_info d
     SET d.info_domain = "AMS_TOOLKIT", d.info_name = a_prog_name, d.info_date = cnvtdatetime(curdate,
       curtime3),
      d.info_number = 1, d.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
   ELSE
    UPDATE  FROM dm_info d
     SET d.info_number = info_nbr
     WHERE d.info_domain="AMS_TOOLKIT"
      AND d.info_name=a_prog_name
     WITH nocounter
    ;end update
   ENDIF
 END ;Subroutine
#exit_script
 SET script_ver = "001  04/15/2015  PS016848 Initial Release"
END GO
