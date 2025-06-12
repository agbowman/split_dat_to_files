CREATE PROGRAM cust_config_audit_all:dba
 PROMPT
  "Contrib_system_cd (default=0.0):" = 0.0
  WITH systemcd
 SET modify = filestream
 SET scriptver = "scriptver=025"
 CALL echo(build(scriptver,char(0)))
 IF ((reqinfo->updt_id=0))
  CALL echo(build(
    "#######################################################################################",char(0)
    ))
  CALL echo(
   "ERROR: You must be logged into a CCL session to run this script (Use 'cclseclogin go') first")
  CALL echo(build(
    "########################################################################################",char(0
     )))
  GO TO exit_script
 ENDIF
 IF (0 < curgroup)
  CALL echo(build("######################################################################",char(0)))
  CALL echo(build(" ",char(0)))
  CALL echo(build("You need GROUP(00) access. Your current Acess is GROUP(",curgroup,")",char(0)))
  CALL echo(build(" ",char(0)))
  CALL echo(build("######################################################################",char(0)))
  GO TO exit_script
 ENDIF
 CALL echo(build("***** Begin cust_config_audit_all *****",char(0)))
 DECLARE configauditesi(null) = null WITH protect
 DECLARE configauditeso(null) = null WITH protect
 DECLARE triggerreport(null) = null WITH protect
 DECLARE getoenscriptexp(null) = null WITH protect
 DECLARE getoenprocexp(null) = null WITH protect
 DECLARE getselectionscripts(null) = null WITH protect
 DECLARE getcsirules(null) = null WITH protect
 DECLARE getinboundaliases(null) = null WITH protect
 DECLARE getoutboundaliases(null) = null WITH protect
 DECLARE holdrules(null) = null WITH protect
 DECLARE domaininfo(null) = null WITH protect
 DECLARE cer_temp = vc WITH protect, constant(logical("cer_temp"))
 DECLARE dsuspendedcd = f8 WITH constant(uar_get_code_by("MEANING",48,"SUSPENDED")), protect
 DECLARE fileheader = vc WITH constant(build(cer_temp,"/")), protect
 DECLARE subext = vc WITH constant(build("oenexp_")), protect
 DECLARE lfsystemcd = f8 WITH noconstant(cnvtreal( $SYSTEMCD)), protect
 CALL domaininfo(1)
 CALL configauditall(lfsystemcd)
 CALL triggerreport(1)
 CALL getoenscriptexp(1)
 CALL getoenprocexp(1)
 CALL getselectionscripts(1)
 CALL getcsirules(1)
 CALL getinboundaliases(1)
 CALL getoutboundaliases(1)
 CALL holdrules(1)
 IF (validate(CTP_FSI::fsi_files) != 1)
  CALL delfile("",build(cer_temp,"/",trim(cnvtlower(logical("ENVIRONMENT")),3),"_fsi_turnover.zip"))
  CALL zipfiles(build(cer_temp,"/",trim(cnvtlower(logical("ENVIRONMENT")),3),"_fsi_turnover"),build(
    cer_temp,"/","*",trim(subext,3),"*"))
  CALL delfile("",build(fileheader,"*.",trim(subext,3),"*"))
 ENDIF
 GO TO exit_script
 SUBROUTINE domaininfo(x)
   DECLARE endext2 = vc WITH noconstant("_domain"), protect
   CALL addctp_notes(build("Domain:",trim(cnvtlower(logical("ENVIRONMENT")),3)))
   CALL addctp_notes(build("UTC:",curutc))
   CALL addctp_notes(build("Node:",curnode))
   CALL addctp_notes(build("Node TZ:",curtimezone))
   CALL addctp_notes(build("ccl version:",currev,".",currevminor,".",
     currevminor2))
   CALL addctp_notes(build("turnover script version:",scriptver))
   CALL addctp_notes(build("turnover script run dt_Tm:",format(cnvtdatetime(sysdate),
      "DD-MMM-YYYY HH:MM;;D")))
 END ;Subroutine
 SUBROUTINE (configauditall(lfsystemcd=f8) =null WITH protect)
   DECLARE endext = vc WITH noconstant("config"), protect
   RECORD csdmflag(
     1 qual[*]
       2 column_name = vc
       2 flag_value = f8
       2 description = vc
   ) WITH protect
   RECORD recsystemcd(
     1 sys_qual_cnt = i4
     1 sys_qual[*]
       2 systemcd = f8
       2 systemdirectioncd = f8
       2 systemdisp = vc
   ) WITH protect
   SELECT INTO "nl"
    FROM dm_flags dm
    WHERE dm.table_name="CONTRIBUTOR_SYSTEM"
    ORDER BY dm.table_name, dm.column_name, dm.flag_value
    HEAD REPORT
     dmflagcnt = 0
    DETAIL
     dmflagcnt += 1
     IF (mod(dmflagcnt,10)=1)
      stat = alterlist(csdmflag->qual,(dmflagcnt+ 9))
     ENDIF
     csdmflag->qual[dmflagcnt].column_name = dm.column_name, csdmflag->qual[dmflagcnt].flag_value =
     dm.flag_value, csdmflag->qual[dmflagcnt].description = dm.description
    FOOT REPORT
     stat = alterlist(csdmflag->qual,dmflagcnt)
    WITH nocounter
   ;end select
   SELECT
    IF (lfsystemcd > 0)
     PLAN (cs
      WHERE cs.contributor_system_cd=lfsystemcd)
      JOIN (cv
      WHERE cv.code_set=89
       AND cv.code_value=cs.contributor_system_cd)
    ELSE
     PLAN (cs
      WHERE cs.active_ind=1
       AND ((cs.contributor_system_cd != 0.0) OR (cs.active_ind=0
       AND cs.active_status_cd=dsuspendedcd)) )
      JOIN (cv
      WHERE cv.code_set=89
       AND cv.code_value=cs.contributor_system_cd)
    ENDIF
    INTO "nl:"
    lvcdisplay = trim(cv.display,3)
    FROM contributor_system cs,
     code_value cv
    HEAD REPORT
     sys_cnt = 0
    DETAIL
     sys_cnt += 1
     IF (mod(sys_cnt,10)=1)
      stat = alterlist(recsystemcd->sys_qual,(sys_cnt+ 9))
     ENDIF
     recsystemcd->sys_qual[sys_cnt].systemcd = cs.contributor_system_cd, recsystemcd->sys_qual[
     sys_cnt].systemdirectioncd = cs.sys_direction_cd, lvcdisplay = replace(lvcdisplay,"/","",0),
     recsystemcd->sys_qual[sys_cnt].systemdisp = cnvtlower(build(trim(fileheader,3),trim(cnvtlower(
         trim(lvcdisplay,3)),4),".",trim(subext,3),trim(endext,3))),
     CALL echo(build("mytest=",recsystemcd->sys_qual[sys_cnt].systemdisp,char(0)))
    FOOT REPORT
     recsystemcd->sys_qual_cnt = sys_cnt, stat = alterlist(recsystemcd->sys_qual,sys_cnt)
    WITH nocounter
   ;end select
   CALL configauditesi(1)
   CALL configauditeso(1)
   CALL echo(build("recsystemcd->sys_qual_cnt =",recsystemcd->sys_qual_cnt,char(0)))
 END ;Subroutine
 SUBROUTINE configauditesi(x)
  DECLARE endext2 = vc WITH noconstant("_esi"), protect
  FOR (ccidx = 1 TO recsystemcd->sys_qual_cnt)
    CALL echo(build("system_name =",recsystemcd->sys_qual[ccidx].systemdisp,endext2,char(0)))
    CALL echo(build("system_cv =",recsystemcd->sys_qual[ccidx].systemcd,char(0)))
    SELECT INTO value(build(trim(recsystemcd->sys_qual[ccidx].systemdisp,3),endext2))
     m.contributor_system_cd, m.prsnl_person_id, m.organization_id,
     m.loc_facility_cd, m.contr_sys_type_cd, m.contributor_source_cd,
     m.act_contributor_system_cd, m.esi_org_alias_cd, m.auto_combine_ind,
     m.doc_event_class_cd, m.result_alias_ind, m.event_class_source_flag,
     m.updt_dt_tm, m.updt_id, m.sys_direction_cd,
     m.alt_contrib_src_cd, m.opf_match_threshold"###", m.opf_report_threshold"###",
     m.micro_multi_interp_ind, m.micro_list_replace_flag, m.time_zone_flag,
     m.time_zone"################################", m.message_format_cd, m.grouper_hold_time,
     m.max_grouper_orders, m.grouper_multi_ords_ind, m.active_ind,
     m.active_status_cd, m.updt_dt_tm, m.updt_id,
     o.org_name"#######################################", p.name_full_formatted
     "#######################################", c1_display = uar_get_code_display(m
      .contributor_system_cd),
     c1_code_set = uar_get_code_set(m.contributor_system_cd), c2_display = uar_get_code_display(m
      .loc_facility_cd), c2_code_set = uar_get_code_set(m.loc_facility_cd),
     c3_display = uar_get_code_display(m.contr_sys_type_cd), c3_code_set = uar_get_code_set(m
      .contr_sys_type_cd), c4_display = uar_get_code_display(m.contributor_source_cd),
     c4_code_set = uar_get_code_set(m.contributor_source_cd), c5_display = uar_get_code_display(m
      .act_contributor_system_cd), c5_code_set = uar_get_code_set(m.act_contributor_system_cd),
     c6_display = uar_get_code_display(m.esi_org_alias_cd), c6_code_set = uar_get_code_set(m
      .esi_org_alias_cd), c7_display = uar_get_code_display(m.doc_event_class_cd),
     c7_code_set = uar_get_code_set(m.doc_event_class_cd), c8_display = uar_get_code_display(m
      .sys_direction_cd), c8_code_set = uar_get_code_set(m.sys_direction_cd),
     c9_display = uar_get_code_display(m.alt_contrib_src_cd), c9_code_set = uar_get_code_set(m
      .alt_contrib_src_cd), c10_display = uar_get_code_display(m.active_status_cd),
     c10_code_set = uar_get_code_set(m.active_status_cd), c11_display = uar_get_code_display(m
      .message_format_cd), c11_code_set = uar_get_code_set(m.message_format_cd)
     FROM contributor_system m,
      organization o,
      prsnl p
     PLAN (m
      WHERE (m.contributor_system_cd=recsystemcd->sys_qual[ccidx].systemcd))
      JOIN (o
      WHERE o.organization_id=m.organization_id)
      JOIN (p
      WHERE p.person_id=m.prsnl_person_id)
     ORDER BY m.contributor_system_cd
     HEAD REPORT
      blank = fillstring(25,"_"), blank_line = fillstring(125,"="), dash = fillstring(125,"-")
     HEAD PAGE
      col 15, "CONTRIBUTOR SYSTEM REPORT ESI", row + 1,
      col 35, "Display/Description", col 80,
      "Value", col 105, "Code Set",
      row + 1
     HEAD m.contributor_system_cd
      null
     DETAIL
      col 1, blank_line, row + 1,
      col 1, "Contributor System Code:", col 35,
      c1_display, col 75, m.contributor_system_cd
      IF (cnvtreal(c1_code_set) > 0)
       col 100, c1_code_set
      ENDIF
      row + 1, col 1, "Organization Id:",
      col 35, o.org_name, col 75,
      m.organization_id, row + 1, col 1,
      "Personnel Name:", col 35, p.name_full_formatted,
      col 75, m.prsnl_person_id, row + 1,
      col 1, "Facility Code:", col 35,
      c2_display, col 75, m.loc_facility_cd
      IF (cnvtreal(c2_code_set) > 0)
       col 100, c2_code_set
      ENDIF
      row + 1, col 1, "Contributor System Type:",
      col 35, c3_display, col 75,
      m.contr_sys_type_cd
      IF (cnvtreal(c3_code_set) > 0)
       col 100, c3_code_set
      ENDIF
      row + 1, col 1, "Contributor Source Code:",
      col 35, c4_display, col 75,
      m.contributor_source_cd
      IF (cnvtreal(c4_code_set) > 0)
       col 100, c4_code_set
      ENDIF
      row + 1, col 1, "Actual Contributor Sys Code:",
      col 35, c5_display, col 75,
      m.act_contributor_system_cd
      IF (cnvtreal(c5_code_set) > 0)
       col 100, c5_code_set
      ENDIF
      row + 1, col 1, "Encntr Organization Alias Cd",
      col 35, c6_display, col 75,
      m.esi_org_alias_cd
      IF (cnvtreal(c6_code_set) > 0)
       col 100, c6_code_set
      ENDIF
      row + 1, col 1, "Auto Combine Allowed Ind",
      col 75, m.auto_combine_ind, row + 1,
      col 1, "ESI Special Source Flag"
      FOR (idx = 1 TO size(csdmflag->qual,5))
        IF ("ESI_SPECIAL_SOURCE_FLAG"=trim(csdmflag->qual[idx].column_name,3)
         AND (m.esi_special_source_flag=csdmflag->qual[idx].flag_value))
         flag_desc = substring(1,40,trim(csdmflag->qual[idx].description,3)), col 35, flag_desc
        ENDIF
      ENDFOR
      col 75, m.esi_special_source_flag, row + 1,
      col 1, "Result Alias Ind"
      IF (m.result_alias_ind=0)
       col 35, "Alias to event_cd"
      ELSE
       col 35, "Alias to orc_cd"
      ENDIF
      col 75, m.result_alias_ind, row + 1,
      col 1, "Event Class Source Flag"
      FOR (idx = 1 TO size(csdmflag->qual,5))
        IF ("EVENT_CLASS_SOURCE_FLAG"=trim(csdmflag->qual[idx].column_name,3)
         AND (m.event_class_source_flag=csdmflag->qual[idx].flag_value))
         flag_desc = substring(1,40,trim(csdmflag->qual[idx].description,3)), col 35, flag_desc
        ENDIF
      ENDFOR
      col 75, m.event_class_source_flag, row + 1,
      col 1, "Doc Event Class Cd", col 35,
      c7_display, col 75, m.doc_event_class_cd
      IF (cnvtreal(c7_code_set) > 0)
       col 100, c7_code_set
      ENDIF
      row + 1, col 1, "Sys Direction Cd",
      col 35, c8_display, col 75,
      m.sys_direction_cd
      IF (cnvtreal(c8_code_set) > 0)
       col 100, c8_code_set
      ENDIF
      row + 1, col 1, "Alt Contrib Src Cd",
      col 35, c9_display, col 75,
      m.alt_contrib_src_cd
      IF (cnvtreal(c9_code_set) > 0)
       col 100, c9_code_set
      ENDIF
      row + 1, col 1, "OPF Match Threshold",
      col 75, m.opf_match_threshold, row + 1,
      col 1, "OPF Report Threshold", col 75,
      m.opf_report_threshold, row + 1, col 1,
      "Micro Multi Interp Ind"
      IF (m.micro_multi_interp_ind=1)
       col 35, "Process multiple interps"
      ELSE
       col 35, "Process single interps"
      ENDIF
      col 75, m.micro_multi_interp_ind, row + 1,
      col 1, "Micro List Replace Flag"
      FOR (idx = 1 TO size(csdmflag->qual,5))
        IF ("MICRO_LIST_REPLACE_FLAG"=trim(csdmflag->qual[idx].column_name,3)
         AND (m.micro_list_replace_flag=csdmflag->qual[idx].flag_value))
         flag_desc = substring(1,40,trim(csdmflag->qual[idx].description,3)), col 35, flag_desc
        ENDIF
      ENDFOR
      col 75, m.micro_list_replace_flag, row + 1,
      col 1, "Time Zone Flag"
      FOR (idx = 1 TO size(csdmflag->qual,5))
        IF ("TIME_ZONE_FLAG"=trim(csdmflag->qual[idx].column_name,3)
         AND (m.time_zone_flag=csdmflag->qual[idx].flag_value))
         flag_desc = substring(1,40,trim(csdmflag->qual[idx].description,3)), col 35, flag_desc
        ENDIF
      ENDFOR
      col 75, m.time_zone_flag, row + 1,
      col 1, "Time Zone", col 35,
      m.time_zone, row + 1, col 1,
      "Message Format Cd", col 35, c11_display,
      col 75, m.message_format_cd
      IF (cnvtreal(c11_code_set) > 0)
       col 100, c11_code_set
      ENDIF
      row + 1, col 1, "Grouper Hold Time",
      col 75, m.grouper_hold_time, row + 1,
      col 1, "Max Grouper Orders", col 75,
      m.max_grouper_orders, row + 1, col 1,
      "Grouper Multiple Orders Ind", col 75, m.grouper_multi_ords_ind
      IF (m.active_ind=0)
       row + 1, col 1, "Active Indicator",
       col 81, m.active_ind, row + 1,
       col 1, "Active Status Code", col 35,
       c10_display, col 75, m.active_status_cd
       IF (cnvtreal(c10_code_set) > 0)
        col 100, c10_code_set
       ENDIF
      ENDIF
      row + 1, col 1, "Update Date/Time",
      col 81, m.updt_dt_tm, row + 1,
      col 1, "Update Id", col 75,
      m.updt_id, row + 1, col 1,
      dash
     FOOT  m.contributor_system_cd
      col 1, blank_line, row + 2
     WITH nocounter
    ;end select
    SELECT INTO value(build(trim(recsystemcd->sys_qual[ccidx].systemdisp,3),endext2))
     m.contributor_system_cd, m.match_field_cd, m.match_function_cd,
     m.match_validation_cd, m.alias_entity_name, m.alias_entity_alias_type_cd,
     m.prim_alias_ind, m.alias_pool_cd, m.billing_ind,
     c1_display = uar_get_code_display(m.contributor_system_cd), c1_code_set = uar_get_code_set(m
      .contributor_system_cd), c2_display = uar_get_code_display(m.match_function_cd),
     c2_code_set = uar_get_code_set(m.match_function_cd), c3_display = uar_get_code_display(m
      .match_field_cd), c3_code_set = uar_get_code_set(m.match_field_cd),
     c4_display = uar_get_code_display(m.alias_entity_alias_type_cd), c4_code_set = uar_get_code_set(
      m.alias_entity_alias_type_cd), c5_display = uar_get_code_display(m.match_validation_cd),
     c5_code_set = uar_get_code_set(m.match_validation_cd), c6_display = uar_get_code_display(m
      .alias_pool_cd), c7_display = uar_get_code_display(m.order_control_cd),
     c7_code_set = uar_get_code_set(m.order_control_cd)
     FROM match_tag_parms m
     PLAN (m
      WHERE (m.contributor_system_cd=recsystemcd->sys_qual[ccidx].systemcd)
       AND m.active_ind=1)
     ORDER BY m.contributor_system_cd, m.match_function_cd, m.match_field_cd,
      c6_display
     HEAD REPORT
      blank = fillstring(25,"_"), blank_line = fillstring(125,"="), dash = fillstring(125,"-")
     HEAD PAGE
      col 15, "MATCH TAG PARAMETERS", row + 1,
      col 35, "Display", col 80,
      "Value", col 105, "Code Set",
      row + 1
     HEAD m.contributor_system_cd
      col 1, blank_line, row + 1,
      col 1, "Contributor System Code:", col 35,
      c1_display, col 75, m.contributor_system_cd,
      col 100, c1_code_set, row + 1
     HEAD m.match_function_cd
      col 3, dash, row + 1,
      col 3, "Match Function Code:", col 35,
      c2_display, col 75, m.match_function_cd,
      col 100, c2_code_set, row + 1,
      col 3, dash, row + 1
     DETAIL
      col 5, "Match Field:", col 35,
      c3_display, col 75, m.match_field_cd,
      col 100, c3_code_set, row + 1,
      col 5, "Match Validation Code:", col 35,
      c5_display, col 75, m.match_validation_cd,
      col 100, c5_code_set, row + 1,
      col 5, "Alias Entity:", col 75,
      m.alias_entity_name, row + 1, col 5,
      "Alias Entity Type:", col 35, c4_display,
      col 75, m.alias_entity_alias_type_cd
      IF (cnvtreal(c4_code_set) > 0)
       col 100, c4_code_set
      ENDIF
      row + 1, col 5, "Alias Pool Code:",
      col 35, c6_display, col 75,
      m.alias_pool_cd, row + 1, col 5,
      "Primary Ind:", col 75, m.prim_alias_ind
      IF (m.alias_entity_name="ORDER")
       row + 1, col 5, "Order Control Code:",
       col 35, c7_display, col 75,
       m.order_control_cd
       IF (cnvtreal(c7_code_set) > 0)
        col 100, c7_code_set
       ENDIF
       row + 1, col 5, "Billing Ind:",
       col 75, m.billing_ind
      ENDIF
      row + 1, col 5, dash,
      row + 1
     FOOT  m.match_function_cd
      col 1
     FOOT  m.contributor_system_cd
      col 1
     WITH nocounter, noformfeed, append,
      maxrow = 1
    ;end select
    SELECT INTO value(build(trim(recsystemcd->sys_qual[ccidx].systemdisp,3),endext2))
     m.contributor_system_cd, m.esi_task_cd, m.person_ensure_type_cd,
     m.encntr_ensure_type_cd, m.event_ensure_type_cd, m.order_ensure_type_cd,
     c1_display = uar_get_code_display(m.contributor_system_cd), c1_code_set = uar_get_code_set(m
      .contributor_system_cd), c2_display = uar_get_code_display(m.esi_task_cd),
     c2_code_set = uar_get_code_set(m.esi_task_cd), c3_display = uar_get_code_display(m
      .person_ensure_type_cd), c3_code_set = uar_get_code_set(m.person_ensure_type_cd),
     c4_display = uar_get_code_display(m.encntr_ensure_type_cd), c4_code_set = uar_get_code_set(m
      .encntr_ensure_type_cd), c5_display = uar_get_code_display(m.event_ensure_type_cd),
     c5_code_set = uar_get_code_set(m.event_ensure_type_cd), c6_display = uar_get_code_display(m
      .order_ensure_type_cd), c6_code_set = uar_get_code_set(m.order_ensure_type_cd),
     c7_display = uar_get_code_display(m.person_alias_ensure_type_cd), c7_code_set = uar_get_code_set
     (m.person_alias_ensure_type_cd), c8_display = uar_get_code_display(m.encntr_alias_ensure_type_cd
      ),
     c8_code_set = uar_get_code_set(m.encntr_alias_ensure_type_cd), c9_display = uar_get_code_display
     (m.coding_segment_ens_type_cd), c9_code_set = uar_get_code_set(m.coding_segment_ens_type_cd),
     c10_display = uar_get_code_display(m.allergy_segment_ens_type_cd), c10_code_set =
     uar_get_code_set(m.allergy_segment_ens_type_cd), c11_display = uar_get_code_display(m
      .problem_segment_ens_type_cd),
     c11_code_set = uar_get_code_set(m.problem_segment_ens_type_cd)
     FROM esi_ensure_parms m
     PLAN (m
      WHERE (m.contributor_system_cd=recsystemcd->sys_qual[ccidx].systemcd))
     ORDER BY m.contributor_system_cd
     HEAD REPORT
      blank = fillstring(25,"_"), blank_line = fillstring(125,"="), dash = fillstring(125,"-")
     HEAD PAGE
      col 15, "ESI ENSURE PARAMETERS", row + 1,
      col 35, "Display", col 80,
      "Value", col 105, "Code Set",
      row + 1
     HEAD m.contributor_system_cd
      null
     DETAIL
      col 1, blank_line, row + 1,
      col 1, "Contributor System Code:", col 35,
      c1_display, col 75, m.contributor_system_cd,
      col 100, c1_code_set, row + 1,
      col 1, "ESI Task Code:", col 35,
      c2_display, col 75, m.esi_task_cd,
      col 100, c2_code_set, row + 1,
      col 1, "Person Ensure Type Code:", col 35,
      c3_display, col 75, m.person_ensure_type_cd,
      col 100, c3_code_set, row + 1,
      col 1, "Encounter Ensure Type Code:", col 35,
      c4_display, col 75, m.encntr_ensure_type_cd,
      col 100, c4_code_set, row + 1,
      col 1, "Event Ensure Type Code:", col 35,
      c5_display, col 75, m.event_ensure_type_cd,
      col 100, c5_code_set, row + 1,
      col 1, "Order Ensure Type Code:", col 35,
      c6_display, col 75, m.order_ensure_type_cd
      IF (cnvtreal(c6_code_set) > 0)
       col 100, c6_code_set
      ENDIF
      row + 1, col 1, "Person Alias  Ensure Type Code:",
      col 35, c7_display, col 75,
      m.person_alias_ensure_type_cd
      IF (cnvtreal(c7_code_set) > 0)
       col 100, c7_code_set
      ENDIF
      row + 1, col 1, "Encounter Alias Ensure Type Code:",
      col 35, c8_display, col 75,
      m.encntr_alias_ensure_type_cd
      IF (cnvtreal(c8_code_set) > 0)
       col 100, c8_code_set
      ENDIF
      row + 1, col 1, "Coding Segment Ensure Type Code:",
      col 35, c9_display, col 75,
      m.coding_segment_ens_type_cd
      IF (cnvtreal(c9_code_set) > 0)
       col 100, c9_code_set
      ENDIF
      row + 1, col 1, "Allergy Segment Ensure Type Code:",
      col 35, c10_display, col 75,
      m.allergy_segment_ens_type_cd
      IF (cnvtreal(c10_code_set) > 0)
       col 100, c10_code_set
      ENDIF
      row + 1, col 1, "Problem Segment Ensure Type Code:",
      col 35, c11_display, col 75,
      m.problem_segment_ens_type_cd
      IF (cnvtreal(c11_code_set) > 0)
       col 100, c11_code_set
      ENDIF
      row + 1, col 1, dash
     FOOT  m.contributor_system_cd
      col 1, blank_line, row + 2
     WITH nocounter, noformfeed, append,
      maxrow = 1
    ;end select
    SELECT INTO value(build(trim(recsystemcd->sys_qual[ccidx].systemdisp,3),endext2))
     m.contributor_system_cd, m.esi_alias_field_cd, m.esi_alias_type,
     m.esi_assign_fac, m.alias_entity_name, m.alias_entity_alias_type_cd,
     m.alias_pool_cd, m.skip_string, m.trunc_size,
     m.alias_filter_cd, m.esi_assign_auth, m.prsnl_proc_opt_cd,
     m.prsnl_ft_string, m.esi_source, m.alias_ensure_parms_flag,
     c1_display = uar_get_code_display(m.contributor_system_cd), c1_code_set = uar_get_code_set(m
      .contributor_system_cd), c2_display = uar_get_code_display(m.esi_alias_field_cd),
     c2_code_set = uar_get_code_set(m.esi_alias_field_cd), c3_display = uar_get_code_display(m
      .alias_entity_alias_type_cd), c3_code_set = uar_get_code_set(m.alias_entity_alias_type_cd),
     c4_display = uar_get_code_display(m.alias_pool_cd), c4_code_set = uar_get_code_set(m
      .alias_pool_cd), c5_display = uar_get_code_display(m.alias_filter_cd),
     c5_code_set = uar_get_code_set(m.alias_filter_cd), c6_display = uar_get_code_display(m
      .prsnl_proc_opt_cd), c6_code_set = uar_get_code_set(m.prsnl_proc_opt_cd)
     FROM esi_alias_trans m
     PLAN (m
      WHERE (m.contributor_system_cd=recsystemcd->sys_qual[ccidx].systemcd))
     ORDER BY m.contributor_system_cd, m.alias_entity_name, m.esi_alias_field_cd,
      c4_display
     HEAD REPORT
      blank = fillstring(25,"_"), blank_line = fillstring(125,"="), dash = fillstring(125,"-")
     HEAD PAGE
      col 15, "ESI ALIAS TRANSLATION", row + 1,
      col 35, "Display/Description", col 80,
      "Value", col 105, "Code Set",
      row + 1
     HEAD m.contributor_system_cd
      null
     DETAIL
      col 1, blank_line, row + 1,
      col 1, "Contributor System Code:", col 35,
      c1_display, col 75, m.contributor_system_cd,
      col 100, c1_code_set, row + 1,
      col 1, "ESI Alias Field Code:", col 35,
      c2_display, col 75, m.esi_alias_field_cd,
      col 100, c2_code_set
      IF (m.alias_entity_name="PERSONNEL")
       row + 1, col 1, "ESI Assign Authority:",
       col 35, m.esi_assign_auth, row + 1,
       col 1, "ESI Alias Type:", col 35,
       m.esi_alias_type, row + 1, col 1,
       "ESI Assign Facility:", col 35, m.esi_assign_fac,
       row + 1, col 1, "Personnel Source:",
       col 35, m.esi_source, row + 1,
       col 1, "Alias Entity Alias Type Code:", col 35,
       c3_display, col 75, m.alias_entity_alias_type_cd
       IF (cnvtreal(c3_code_set) > 0)
        col 100, c3_code_set
       ENDIF
       row + 1, col 1, "Alias Pool Code:",
       col 35, c4_display, col 75,
       m.alias_pool_cd
       IF (cnvtreal(c4_code_set) > 0)
        col 100, c4_code_set
       ENDIF
       row + 1, col 1, "Personnel Processing Options:",
       col 35, c6_display, col 75,
       m.prsnl_proc_opt_cd, col 100, c6_code_set,
       row + 1, col 1, "Free Text Personnel String:",
       col 35, m.prsnl_ft_string, row + 1,
       col 1, "Alias Size:", col 35,
       m.trunc_size, row + 1, col 1,
       "Alias Filter Code:", col 35, c5_display,
       col 75, m.alias_filter_cd, col 100,
       c5_code_set, row + 1, col 1,
       dash
      ELSE
       row + 1, col 1, "ESI Assign Authority:",
       col 35, m.esi_assign_auth, row + 1,
       col 1, "ESI Alias Type:", col 35,
       m.esi_alias_type, row + 1, col 1,
       "ESI Assign Facility:", col 35, m.esi_assign_fac,
       row + 1, col 1, "Alias Entity Name:",
       col 35, m.alias_entity_name, row + 1,
       col 1, "Alias Entity Alias Type Code:", col 35,
       c3_display, col 75, m.alias_entity_alias_type_cd
       IF (cnvtreal(c3_code_set) > 0)
        col 100, c3_code_set
       ENDIF
       row + 1, col 1, "Alias Pool Code:",
       col 35, c4_display, col 75,
       m.alias_pool_cd
       IF (cnvtreal(c4_code_set) > 0)
        col 100, c4_code_set
       ENDIF
       row + 1, col 1, "Skip String:",
       col 30, m.skip_string, row + 1,
       col 1, "Alias Size:", col 35,
       m.trunc_size, row + 1, col 1,
       "Alias Filter Code:", col 35, c5_display,
       col 75, m.alias_filter_cd, col 100,
       c5_code_set, row + 1, col 1,
       "Alias Ensure Parms Flag:"
       IF (m.alias_ensure_parms_flag=1)
        col 35, "eligible for override ensure"
       ELSE
        col 35, "Not eligible for override ensure"
       ENDIF
       row + 1, col 1, dash
      ENDIF
     FOOT  m.contributor_system_cd
      col 1, blank_line, row + 2
     WITH nocounter, noformfeed, append,
      maxrow = 1
    ;end select
    CALL specialconfigoptions(recsystemcd->sys_qual[ccidx].systemcd)
    CALL addctp_file(build(recsystemcd->sys_qual[ccidx].systemdisp,endext2),"CONFIG AUDIT ESI")
  ENDFOR
 END ;Subroutine
 SUBROUTINE configauditeso(x)
   DECLARE endext2 = vc WITH noconstant("_eso"), protect
   DECLARE lfsysdirectionbidirect = f8 WITH noconstant(uar_get_code_by("MEANING",14869,"BIDIRECT")),
   protect
   DECLARE lfsysdirectionfromhnam = f8 WITH noconstant(uar_get_code_by("MEANING",14869,"FROM_HNA")),
   protect
   FOR (ccidx = 1 TO recsystemcd->sys_qual_cnt)
     IF ((recsystemcd->sys_qual[ccidx].systemdirectioncd IN (lfsysdirectionbidirect,
     lfsysdirectionfromhnam)))
      CALL echo(build("system_name =",recsystemcd->sys_qual[ccidx].systemdisp,endext2,char(0)))
      CALL echo(build("system_name =",recsystemcd->sys_qual[ccidx].systemcd,char(0)))
      SELECT INTO value(build(trim(recsystemcd->sys_qual[ccidx].systemdisp,3),endext2))
       m.contributor_system_cd, m.prsnl_person_id, m.organization_id,
       m.loc_facility_cd, m.contr_sys_type_cd, m.contributor_source_cd,
       m.act_contributor_system_cd, m.esi_org_alias_cd, m.auto_combine_ind,
       m.doc_event_class_cd, m.result_alias_ind, m.event_class_source_flag,
       m.updt_dt_tm, m.updt_id, m.sys_direction_cd,
       m.alt_contrib_src_cd, m.opf_match_threshold"###", m.opf_report_threshold"###",
       m.micro_multi_interp_ind, m.micro_list_replace_flag, m.time_zone_flag,
       m.time_zone"################################", m.message_format_cd, m.grouper_hold_time,
       m.max_grouper_orders, m.grouper_multi_ords_ind, m.active_ind,
       m.active_status_cd, m.updt_dt_tm, m.updt_id,
       o.org_name"#######################################", p.name_full_formatted
       "#######################################", c1_display = uar_get_code_display(m
        .contributor_system_cd),
       c1_code_set = uar_get_code_set(m.contributor_system_cd), c2_display = uar_get_code_display(m
        .loc_facility_cd), c2_code_set = uar_get_code_set(m.loc_facility_cd),
       c3_display = uar_get_code_display(m.contr_sys_type_cd), c3_code_set = uar_get_code_set(m
        .contr_sys_type_cd), c4_display = uar_get_code_display(m.contributor_source_cd),
       c4_code_set = uar_get_code_set(m.contributor_source_cd), c5_display = uar_get_code_display(m
        .act_contributor_system_cd), c5_code_set = uar_get_code_set(m.act_contributor_system_cd),
       c6_display = uar_get_code_display(m.esi_org_alias_cd), c6_code_set = uar_get_code_set(m
        .esi_org_alias_cd), c7_display = uar_get_code_display(m.doc_event_class_cd),
       c7_code_set = uar_get_code_set(m.doc_event_class_cd), c8_display = uar_get_code_display(m
        .sys_direction_cd), c8_code_set = uar_get_code_set(m.sys_direction_cd),
       c9_display = uar_get_code_display(m.alt_contrib_src_cd), c9_code_set = uar_get_code_set(m
        .alt_contrib_src_cd), c10_display = uar_get_code_display(m.active_status_cd),
       c10_code_set = uar_get_code_set(m.active_status_cd), c11_display = uar_get_code_display(m
        .message_format_cd), c11_code_set = uar_get_code_set(m.message_format_cd),
       eso_field_display = uar_get_code_display(ofp.field_processing_cd), eso_proc_display =
       uar_get_code_display(ofp.process_type_cd), eso_proc_mean = uar_get_code_meaning(ofp
        .process_type_cd)
       FROM contributor_system m,
        organization o,
        prsnl p,
        outbound_field_processing ofp
       PLAN (m
        WHERE (m.contributor_system_cd=recsystemcd->sys_qual[ccidx].systemcd))
        JOIN (ofp
        WHERE ofp.contributor_system_cd=m.contributor_system_cd)
        JOIN (o
        WHERE o.organization_id=m.organization_id)
        JOIN (p
        WHERE p.person_id=m.prsnl_person_id)
       ORDER BY m.contributor_system_cd, eso_proc_display
       HEAD REPORT
        blank = fillstring(25,"_"), blank_line = fillstring(125,"="), dash = fillstring(125,"-")
       HEAD PAGE
        col 15, "CONTRIBUTOR SYSTEM REPORT ESO", row + 1,
        col 35, "Display/Description", col 80,
        "Value", col 105, "Code Set",
        row + 1
       HEAD m.contributor_system_cd
        col 1, blank_line, row + 1,
        col 1, "Contributor System Code:", col 35,
        c1_display, col 75, m.contributor_system_cd
        IF (cnvtreal(c1_code_set) > 0)
         col 100, c1_code_set
        ENDIF
        row + 1, col 1, "Organization Id:",
        col 35, o.org_name, col 75,
        m.organization_id, row + 1, col 1,
        "Personnel Name:", col 35, p.name_full_formatted,
        col 75, m.prsnl_person_id, row + 1,
        col 1, "Contributor Source Code:", col 35,
        c4_display, col 75, m.contributor_source_cd
        IF (cnvtreal(c4_code_set) > 0)
         col 100, c4_code_set
        ENDIF
        row + 1, col 1, "Sys Direction Cd:",
        col 35, c8_display, col 75,
        m.sys_direction_cd
        IF (cnvtreal(c8_code_set) > 0)
         col 100, c8_code_set
        ENDIF
        row + 1, col 1, "Alt Contrib Src cd:"
        IF (size(trim(c9_display),3))
         col 35, c9_display
        ELSE
         col 35, "Default - No Alt Contributor Source Selected"
        ENDIF
        col 75, m.alt_contrib_src_cd
        IF (cnvtreal(c9_code_set) > 0)
         col 100, c9_code_set
        ENDIF
        row + 1, col 1, "Update Date/Time",
        col 81, m.updt_dt_tm, row + 1,
        col 1, "Update Id", col 75,
        m.updt_id, row + 2, col 1,
        "ESO Special Source Flag:"
        FOR (idx = 1 TO size(csdmflag->qual,5))
          IF ("ESO_SPECIAL_SOURCE_FLAG"=trim(csdmflag->qual[idx].column_name,3)
           AND (m.eso_special_source_flag=csdmflag->qual[idx].flag_value))
           flag_desc = substring(1,40,trim(csdmflag->qual[idx].description,3)), col 35, flag_desc
          ENDIF
        ENDFOR
        IF (m.eso_special_source_flag=4
         AND 0=size(trim(flag_desc,3)))
         flag_desc = "Send Nomenclature identifer", col 35, flag_desc
        ENDIF
        IF (m.eso_special_source_flag=5
         AND size(trim(flag_desc,3)))
         flag_desc = "Send Nomenclature identifer and local identifier", col 35, flag_desc
        ENDIF
        col 75, m.eso_special_source_flag, row + 1
       HEAD eso_proc_display
        IF ("DTTM_PROC"=trim(eso_proc_mean,3))
         col 1, eso_proc_display, col 35,
         eso_field_display, row + 1, col 1,
         "ESO Time Zone:", mystring = substring(1,45,ofp.null_string), col 35,
         mystring, row + 1
        ENDIF
        IF ("CVO_PROCESS"=trim(eso_proc_mean,3))
         col 1, "Outbound Alias Processing:", col 35,
         eso_field_display, row + 1
        ENDIF
        IF ("DB_NULL"=trim(eso_proc_mean,3))
         col 1, eso_proc_display, mystring = substring(1,45,ofp.null_string),
         col 35, mystring, row + 1
        ENDIF
       FOOT  m.contributor_system_cd
        col 1, blank_line, row + 2
       WITH nocounter
      ;end select
      CALL outboundfieldprocessing(recsystemcd->sys_qual[ccidx].systemcd)
      CALL addctp_file(build(recsystemcd->sys_qual[ccidx].systemdisp,endext2),"CONFIG AUDIT ESO")
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE outboundfieldprocessing(lfsystemcd)
   RECORD request(
     1 contributor_system_cd = f8
   ) WITH protect
   RECORD reply(
     1 qual[*]
       2 process_type_cd = f8
       2 process_type = vc
       2 process_type_cs = i4
       2 process_type_cdf = vc
       2 field_processing_cd = f8
       2 field_processing = vc
       2 field_processing_cs = i4
       2 field_processing_cdf = vc
       2 active_ind = i2
       2 seq_num = i4
       2 null_string = vc
       2 category = vc
       2 section = vc
       2 sub_section = vc
       2 question = vc
       2 default_value = vc
       2 write_to = vc
       2 required = vc
       2 code_set = i4
       2 alwaysactive = i2
       2 related = vc
       2 history_ind = i2
       2 sortstring = c50
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   RECORD rptdata(
     1 qual[*]
       2 process_type_cd = f8
       2 process_type = vc
       2 process_type_cs = i4
       2 process_type_cdf = vc
       2 field_processing_cd = f8
       2 field_processing = vc
       2 field_processing_cs = i4
       2 field_processing_cdf = vc
       2 active_ind = i2
       2 seq_num = i4
       2 null_string = vc
       2 category = vc
       2 section = vc
       2 sub_section = vc
       2 question = vc
       2 default_value = vc
       2 write_to = vc
       2 required = vc
       2 code_set = i4
       2 alwaysactive = i2
       2 related = vc
       2 history_ind = i2
       2 sortstring = vc
       2 sortseq = i4
   ) WITH protect
   SET request->contributor_system_cd = lfsystemcd
   EXECUTE sim_eso_get_out_field_proc
   DECLARE idxi = i4 WITH noconstant(size(reply->qual,5)), protect
   SELECT INTO "nl"
    FROM (dummyt d  WITH seq = value(idxi))
    DETAIL
     reply->qual[d.seq].sortstring = concat(trim(substring(1,25,reply->qual[d.seq].category),3),char(
       32),trim(substring(1,25,reply->qual[d.seq].section),3))
    WITH nocounter
   ;end select
   SET stat = alterlist(rptdata->qual,0)
   DECLARE iidx2 = i4 WITH noconstant(0.0), protect
   SELECT INTO "nl"
    category = trim(substring(1,25,reply->qual[d.seq].category),3), subcat = trim(substring(1,25,
      reply->qual[d.seq].section),3)
    FROM (dummyt d  WITH seq = value(idxi))
    WHERE (reply->qual[d.seq].category != "MAIN")
     AND 0 != size(trim(reply->qual[d.seq].category,3))
    ORDER BY category, subcat
    HEAD REPORT
     iidx2 = 0
    HEAD category
     null
    HEAD subcat
     sortseq = 0
    DETAIL
     iidx2 += 1
     IF (mod(iidx2,20)=1)
      stat = alterlist(rptdata->qual,(iidx2+ 19))
     ENDIF
     rptdata->qual[iidx2].active_ind = reply->qual[d.seq].active_ind, rptdata->qual[iidx2].question
      = reply->qual[d.seq].question, rptdata->qual[iidx2].field_processing = reply->qual[d.seq].
     field_processing,
     rptdata->qual[iidx2].null_string = reply->qual[d.seq].null_string, rptdata->qual[iidx2].
     sortstring = trim(concat(trim(category,3),char(32),trim(subcat,3)),3), rptdata->qual[iidx2].
     write_to = reply->qual[d.seq].write_to,
     sortseq += 1
     IF (trim(reply->qual[d.seq].process_type_cdf,3) IN ("SEND_APP", "SEND_FAC", "RECV_APP",
     "RECV_FAC"))
      CASE (trim(reply->qual[d.seq].process_type_cdf,3))
       OF "SEND_APP":
        sortseq = 1
       OF "SEND_FAC":
        sortseq = 2
       OF "RECV_APP":
        sortseq = 3
       OF "RECV_FAC":
        sortseq = 4
      ENDCASE
     ENDIF
     IF (trim(reply->qual[d.seq].process_type_cdf,3) IN ("ENABLE_NOMEN", "AL1_SRCVOCAB",
     "PRB_SRCVOCAB", "RCT_SRCVOCAB", "DG1_SRCVOCAB"))
      CASE (trim(reply->qual[d.seq].process_type_cdf,3))
       OF "ENABLE_NOMEN":
        sortseq = 1
       OF "AL1_SRCVOCAB":
        sortseq = 2
       OF "PRB_SRCVOCAB":
        sortseq = 3
       OF "RCT_SRCVOCAB":
        sortseq = 4
       OF "DG1_SRCVOCAB":
        sortseq = 5
      ENDCASE
     ENDIF
     IF (trim(reply->qual[d.seq].process_type_cdf,3) IN ("ENABLE_ITEM", "RX_IDEN_TYPE", "NOTIMINGRND",
     "PRN_FLEX", "QT_IVL_FLEX",
     "SOFTSTOPSUP", "SNDMULTM_ID"))
      CASE (trim(reply->qual[d.seq].process_type_cdf,3))
       OF "ENABLE_ITEM":
        sortseq = 1
       OF "RX_IDEN_TYPE":
        sortseq = 2
       OF "NOTIMINGRND":
        sortseq = 3
       OF "PRN_FLEX":
        sortseq = 4
       OF "QT_IVL_FLEX":
        sortseq = 5
       OF "SOFTSTOPSUP":
        sortseq = 6
       OF "SNDMULTM_ID":
        sortseq = 7
      ENDCASE
     ENDIF
     rptdata->qual[iidx2].sortseq = sortseq
    FOOT REPORT
     stat = alterlist(rptdata->qual,iidx2)
    WITH nocounter
   ;end select
   DECLARE lv1line1 = c130 WITH noconstant(fillstring(130,"-")), protect
   DECLARE lv1line2 = c130 WITH noconstant(fillstring(130,"=")), protect
   DECLARE lv2line1 = c124 WITH noconstant(fillstring(124,"-")), protect
   DECLARE lv2line2 = c124 WITH noconstant(fillstring(124,"=")), protect
   DECLARE lv3line1 = c121 WITH noconstant(fillstring(121,"-")), protect
   DECLARE lv3line2 = c121 WITH noconstant(fillstring(121,"=")), protect
   DECLARE sortstring = c50
   SELECT INTO value(build(trim(recsystemcd->sys_qual[ccidx].systemdisp,3),endext2))
    sortstring = substring(1,50,rptdata->qual[d.seq].sortstring), qstr = substring(1,80,rptdata->
     qual[d.seq].question), seqnum = rptdata->qual[d.seq].sortseq
    FROM (dummyt d  WITH seq = value(size(rptdata->qual,5)))
    ORDER BY sortstring, seqnum
    HEAD REPORT
     dummayval = 1, row + 1, col 1,
     "Outbound Field Processing"
    HEAD sortstring
     row + 2, col 1, sortstring,
     row + 1, col 4, "Outbound Field Process",
     col 86, "Active", col 93,
     "Value", row + 1, col 1,
     lv1line1, row + 1
    DETAIL
     col 1, seqnum"##"
     IF (80 < size(trim(rptdata->qual[d.seq].question,3)))
      question = concat(trim(substring(1,77,rptdata->qual[d.seq].question),3),"...")
     ELSE
      question = substring(1,80,rptdata->qual[d.seq].question)
     ENDIF
     col 4, question
     IF (rptdata->qual[d.seq].active_ind)
      col 86, "ON"
     ELSE
      col 86, "OFF"
     ENDIF
     IF (trim(rptdata->qual[d.seq].write_to,3) IN ("FIELD_PROCESSING_CD"))
      col 93, rptdata->qual[d.seq].field_processing, row + 1
     ELSEIF (trim(rptdata->qual[d.seq].write_to,3) IN ("NUMERICNULLSTRING", "NULLSTRING"))
      col 93, rptdata->qual[d.seq].null_string, row + 1
     ELSEIF (trim(rptdata->qual[d.seq].write_to,3) IN ("MSH4"))
      IF (size(trim(rptdata->qual[d.seq].field_processing,3)))
       col 93, rptdata->qual[d.seq].field_processing
      ELSE
       col 93, rptdata->qual[d.seq].null_string
      ENDIF
      row + 1
     ELSEIF (trim(rptdata->qual[d.seq].write_to,3) IN ("QT_IVL_FLEX"))
      pieceidx = 1
      WHILE (pieceidx > 0)
        piecenum = piece(trim(rptdata->qual[d.seq].null_string,3),":",pieceidx,"NOTFOUND",4)
        CASE (piecenum)
         OF "4":
          col 94,"Orderable(4)",row + 1
         OF "6":
          col 94,"Therapuetic Class(6)",row + 1
         OF "8":
          col 94,"Nursing Group(8)",row + 1
         OF "10":
          col 94,"Nursing Unit(10)",row + 1
         OF "12":
          col 94,"Physician(12)",row + 1
         OF "14":
          col 94,"Activity Type(14)",row + 1
         OF "16":
          col 94,"Adhoc Frequency(16)",row + 1
         OF "NOTFOUND":
          pieceidx = - (1)
         ELSE
          col 94,piecenum,row + 1,
          row + 1
        ENDCASE
        pieceidx += 1
      ENDWHILE
     ELSE
      row + 1, null
     ENDIF
    WITH nocounter, maxrow = 1, maxcol = 300,
     noformfeed, append
   ;end select
 END ;Subroutine
 SUBROUTINE getselectionscripts(x)
   DECLARE endext = vc WITH noconstant("select"), protect
   DECLARE line1 = c125 WITH constant(fillstring(125,"-")), protect
   DECLARE line2 = c125 WITH constant(fillstring(125,"=")), protect
   DECLARE line3 = c125 WITH constant(fillstring(125,"#")), protect
   DECLARE command = vc WITH noconstant(""), protect
   DECLARE command2 = vc WITH noconstant(""), protect
   DECLARE cmd_status = i4 WITH noconstant(0), protect
   DECLARE lvcmyselect = vc
   DECLARE targetfilename = vc WITH noconstant(""), protect
   RECORD recselect(
     1 qual_cnt = i4
     1 qual[*]
       2 object_name = vc
       2 source_name = vc
       2 file_name = vc
       2 status = vc
   )
   SELECT INTO "nl"
    FROM dprotect d
    PLAN (d
     WHERE d.object_name IN ("ESO_GET_CE_SELECTION", "ESO_GET_PM_SELECTION",
     "ESO_GET_ORDER_SELECTION", "SCH_GET_ESO_SELECTION")
      AND d.group=0)
    ORDER BY d.object_name
    HEAD REPORT
     selcnt = 0
    DETAIL
     selcnt += 1
     IF (mod(selcnt,50)=1)
      stat = alterlist(recselect->qual,(selcnt+ 49))
     ENDIF
     recselect->qual[selcnt].object_name = cnvtlower(trim(d.object_name,3)), recselect->qual[selcnt].
     source_name = trim(d.source_name,3)
    FOOT REPORT
     recselect->qual_cnt = selcnt, stat = alterlist(recselect->qual,selcnt)
    WITH nocounter
   ;end select
   CALL echo(build(" ",char(0)))
   CALL echo(build(" ",char(0)))
   CALL echo(build(line2,char(0)))
   DECLARE translate_fileheader = vc WITH constant("trans_"), protect
   IF (cursys2 IN ("LNX", "AIX"))
    SET command = concat("cd $CCLUSERDIR")
    SET command2 = concat("pwd")
   ENDIF
   CALL echo(build("change dir->",command,char(0)))
   CALL dcl(command,size(trim(command)),cmd_status)
   IF (cmd_status != 1)
    SET lvcmessage = build("ERROR: cannot change dir:",cnvtstring(cmd_status),char(0))
    CALL echo(build(line3,char(0)))
    CALL echo(build("#",lvcmessage,char(0)))
    CALL echo(build(line3,char(0)))
    GO TO exit_script
   ELSE
    CALL echo(concat("AUDIT: change dir successful, status =:",cnvtstring(cmd_status),char(0)))
   ENDIF
   CALL echo(build(" ",char(0)))
   FOR (selidx = 1 TO recselect->qual_cnt)
     CALL echo(build(line2,char(0)))
     CALL echo(build("Working on -> ",recselect->qual[selidx].object_name,char(0)))
     IF (0=size(trim(recselect->qual[selidx].source_name,3)))
      CALL echo(build("Translateing::",recselect->qual[selidx].object_name,char(0)))
      SET lvcmyselect = cnvtlower(build(concat("translate into",' "',trim(fileheader,3),
         translate_fileheader,recselect->qual[selidx].object_name,
         '" ',recselect->qual[selidx].object_name," ","go")))
      CALL echo(build("ccl command->",lvcmyselect,char(0)))
      CALL parser(lvcmyselect)
      CALL copyfile("",build(fileheader,translate_fileheader,trim(recselect->qual[selidx].object_name,
         3),".ccl"),build(fileheader,trim(recselect->qual[selidx].object_name,3),".ccl",".",trim(
         subext,3),
        trim(endext,3)))
      CALL delfile("",build(fileheader,translate_fileheader,trim(recselect->qual[selidx].object_name,
         3),".ccl"))
      SET recselect->qual[selidx].status = concat("translated"," ",recselect->qual[selidx].
       object_name)
      SET recselect->qual[selidx].file_name = cnvtlower(build(fileheader,trim(recselect->qual[selidx]
         .object_name,3),".ccl",".",trim(subext,3),
        trim(endext,3)))
     ELSE
      IF (cursys2 IN ("LNX", "AIX"))
       IF (findstring(":",recselect->qual[selidx].source_name,1,0))
        SET recselect->qual[selidx].source_name = replace(recselect->qual[selidx].source_name,":","/",
         0)
        SET lvctranslogical = trim(logical(piece(recselect->qual[selidx].source_name,"/",1,"")),3)
        IF (trim(lvctranslogical,3))
         SET recselect->qual[selidx].source_name = replace(recselect->qual[selidx].source_name,piece(
           recselect->qual[selidx].source_name,"/",1,""),lvctranslogical,0)
        ENDIF
       ENDIF
       SET pos = findstring("/",recselect->qual[selidx].source_name,1,1)
       IF (pos)
        SET targetfilename = cnvtlower(build(fileheader,substring((pos+ 1),(size(trim(recselect->
             qual[selidx].source_name,3)) - pos),recselect->qual[selidx].source_name)))
       ELSE
        SET targetfilename = cnvtlower(build(fileheader,recselect->qual[selidx].source_name))
       ENDIF
       CALL echo(build("file_loc=",recselect->qual[selidx].source_name,char(0)))
       CALL echo(build("targetfilename=",targetfilename,".",trim(subext,3),trim(endext,3),
         char(0)))
       IF (copyfile("",recselect->qual[selidx].source_name,build(targetfilename,".",trim(subext,3),
         trim(endext,3))))
        SET recselect->qual[selidx].status = concat("copied"," ",recselect->qual[selidx].object_name)
        SET recselect->qual[selidx].file_name = cnvtlower(build(targetfilename,".",trim(subext,3),
          trim(endext,3)))
       ELSE
        CALL echo(build("TRANSLATEing::",recselect->qual[selidx].object_name,char(0)))
        SET lvcmyselect = cnvtlower(build(concat("translate into",' "',trim(fileheader,3),
           translate_fileheader,recselect->qual[selidx].object_name,
           '" ',recselect->qual[selidx].object_name," ","go")))
        CALL echo(build("ccl command->",lvcmyselect,char(0)))
        CALL parser(lvcmyselect)
        CALL copyfile("",build(fileheader,translate_fileheader,trim(recselect->qual[selidx].
           object_name,3),".ccl"),build(fileheader,trim(recselect->qual[selidx].object_name,3),".ccl",
          ".",trim(subext,3),
          trim(endext,3)))
        CALL delfile("",build(fileheader,translate_fileheader,trim(recselect->qual[selidx].
           object_name,3),".ccl"))
        SET recselect->qual[selidx].status = concat("translated"," ",recselect->qual[selidx].
         object_name)
        SET recselect->qual[selidx].file_name = cnvtlower(build(fileheader,trim(recselect->qual[
           selidx].object_name,3),".ccl",".",trim(subext,3),
          trim(endext,3)))
       ENDIF
      ELSE
       CALL echo(build("This OS is not supported.... yet",char(0)))
      ENDIF
     ENDIF
     CALL echo(build(line1,char(0)))
     CALL echo(build(" ",char(0)))
     CALL addctp_file(recselect->qual[selidx].file_name,"SELECTION SCRIPTS")
   ENDFOR
   CALL echo(build(line2,char(0)))
   FOR (selidx = 1 TO recselect->qual_cnt)
     CALL echo(build(recselect->qual[selidx].status,char(0)))
   ENDFOR
 END ;Subroutine
 SUBROUTINE getinboundaliases(x)
   DECLARE endext = vc WITH noconstant("alias"), protect
   DECLARE tmp_string = vc WITH noconstant(" "), protect
   DECLARE aliasfilename_in = vc WITH noconstant(cnvtlower(build(fileheader,"inbound",".",trim(subext,
       3),trim(endext,3)))), protect
   SELECT INTO value(trim(aliasfilename_in,3))
    FROM code_value_alias cva,
     code_value cv
    PLAN (cva)
     JOIN (cv
     WHERE cv.code_value=cva.code_value)
    ORDER BY cva.contributor_source_cd, cv.code_set
    HEAD REPORT
     tmp_string = " ", myheader = concat(
      "CODE_SET|CODE_VALUE|DISPLAY|DESCRIPTION|DEFINITION|CDF_MEANING|ACTIVE_IND|",
      "CONTRIBUTOR_SOURCE_DISP|ALIAS|ALIAS_TYPE_MEANING"), col 0,
     myheader, row + 1
    DETAIL
     tmp_string = build(cv.code_set,"|",cv.code_value,"|",trim(cv.display,3),
      "|",trim(cv.description,3),"|",trim(cv.definition,3),"|",
      cv.cdf_meaning,"|",cv.active_ind,"|",uar_get_code_display(cva.contributor_source_cd),
      "|",cva.alias,cva.alias_type_meaning), col 0, tmp_string,
     row + 1
    WITH nocounter, maxrow = 1, noformfeed,
     maxcol = 500, format = stream
   ;end select
   CALL addctp_file(aliasfilename_in,"INBOUND ALIASES")
 END ;Subroutine
 SUBROUTINE getoutboundaliases(x)
   DECLARE endext = vc WITH noconstant("alias"), protect
   DECLARE tmp_string = vc WITH noconstant(" "), protect
   DECLARE aliasfilename_out = vc WITH noconstant(cnvtlower(build(fileheader,"outbound",".",trim(
       subext,3),trim(endext,3)))), protect
   SELECT INTO value(trim(aliasfilename_out,3))
    FROM code_value_outbound cvo,
     code_value cv
    PLAN (cvo)
     JOIN (cv
     WHERE cv.code_value=cvo.code_value)
    ORDER BY cvo.contributor_source_cd, cv.code_set
    HEAD REPORT
     tmp_string = " ", myheader = concat(
      "CODE_SET|CODE_VALUE|DISPLAY|DESCRIPTION|DEFINITION|CDF_MEANING|ACTIVE_IND|",
      "CONTRIBUTOR_SOURCE_DISP|ALIAS|ALIAS_TYPE_MEANING"), col 0,
     myheader, row + 1
    DETAIL
     tmp_string = build(cv.code_set,"|",cv.code_value,"|",trim(cv.display,3),
      "|",trim(cv.description,3),"|",trim(cv.definition,3),"|",
      cv.cdf_meaning,"|",cv.active_ind,"|",uar_get_code_display(cvo.contributor_source_cd),
      "|",cvo.alias,cvo.alias_type_meaning), col 0, tmp_string,
     row + 1
    WITH nocounter, maxrow = 1, noformfeed,
     maxcol = 500, format = stream
   ;end select
   CALL addctp_file(aliasfilename_out,"OUTBOUND ALIASES")
 END ;Subroutine
 SUBROUTINE getcsirules(x)
   DECLARE endext = vc WITH noconstant("rules"), protect
   DECLARE csirulesfilename = vc WITH noconstant(cnvtlower(build(fileheader,"codesetinterface",".",
      trim(subext,3),trim(endext,3)))), protect
   SELECT INTO value(trim(csirulesfilename,3))
    csi.active_ind, contributor_system = uar_get_code_display(csi.contributor_system_cd),
    contrib_sys_cd = csi.contributor_system_cd,
    csi.code_set, code_set_display = cvs.display, process_cd_display = uar_get_code_display(csi
     .process_cd),
    csi.process_cd, default_alias =
    IF (size(trim(csi.default_alias,3),1) > 47) concat(substring(1,47,csi.default_alias),"...")
    ELSE substring(1,50,csi.default_alias)
    ENDIF
    , csi.updt_cnt
    FROM code_set_interface csi,
     code_value_set cvs
    PLAN (csi
     WHERE csi.contributor_system_cd > 0)
     JOIN (cvs
     WHERE cvs.code_set=csi.code_set)
    ORDER BY csi.contributor_system_cd, csi.code_set
    HEAD REPORT
     blank = fillstring(15,""), blank_line = fillstring(125,"="), dash = fillstring(125,"-")
    HEAD PAGE
     col 45, "CODE SET INTERFACE RULES", row + 2
    HEAD contributor_system
     col 1, contributor_system, row + 1,
     col 1, "Active", col 15,
     "Code Set", col 25, "Code Set Display",
     col 50, "Process Code Display", col 80,
     "Default Alias", row + 1, col 1,
     blank_line, row + 1
    DETAIL
     IF (csi.active_ind > 0)
      col 1, "Active"
     ELSE
      col 1, "Inactive"
     ENDIF
     col 10, csi.code_set, col 25,
     code_set_display, col 50, process_cd_display,
     col 80, default_alias, row + 1
    FOOT  contributor_system
     row + 1
    FOOT REPORT
     col 1, blank_line, row + 1,
     col 40, "END CODE SET INTERFACE RULES REPORT", row + 1,
     col 1, blank_line, row + 1
    WITH nocounter, maxrow = 1, noformfeed,
     maxcol = 160
   ;end select
   CALL addctp_file(csirulesfilename,"CSI RULES")
 END ;Subroutine
 SUBROUTINE getoenscriptexp(x)
   DECLARE endext = vc WITH noconstant("script"), protect
   DECLARE lvcrev = vc WITH noconstant(""), protect
   DECLARE lvcname = vc WITH noconstant(""), protect
   DECLARE lvcdesc = vc WITH noconstant(""), protect
   DECLARE lvctype = vc WITH noconstant(""), protect
   DECLARE lvcexe = vc WITH noconstant(""), protect
   DECLARE lvcreadonly = vc WITH noconstant(""), protect
   DECLARE lvcscriptfilename = vc WITH noconstant(""), protect
   RECORD s_oenscript_request(
     1 qual_cnt = i4
     1 qual[*]
       2 scriptname = vc
       2 sc_refcnt = i4
       2 sc_desc = vc
       2 sc_type = c20
       2 not_executable = i4
       2 read_only = i4
       2 sc_body = vc
   ) WITH protect
   SELECT INTO "nl"
    FROM oen_script os
    HEAD REPORT
     lisidx = 0
    DETAIL
     lisidx += 1
     IF (mod(lisidx,50)=1)
      stat = alterlist(s_oenscript_request->qual,(lisidx+ 49))
     ENDIF
     s_oenscript_request->qual[lisidx].scriptname = trim(os.script_name,3), s_oenscript_request->
     qual[lisidx].sc_refcnt = os.script_refcnt, s_oenscript_request->qual[lisidx].sc_desc = os
     .script_desc,
     s_oenscript_request->qual[lisidx].sc_type = os.script_type, s_oenscript_request->qual[lisidx].
     not_executable = os.not_executable, s_oenscript_request->qual[lisidx].read_only = os.read_only,
     s_oenscript_request->qual[lisidx].sc_body = os.script_body
    FOOT REPORT
     s_oenscript_request->qual_cnt = lisidx
    WITH nocounter
   ;end select
   FOR (lissidx = 1 TO s_oenscript_request->qual_cnt)
     SET lvcrev = build('"REV"',",",'"6"')
     SET lvcname = build('"sc_name"',',"',trim(s_oenscript_request->qual[lissidx].scriptname,3),'"')
     SET lvcdesc = build('"sc_desc"',',"',trim(s_oenscript_request->qual[lissidx].sc_desc,3),'"')
     SET lvctype = build('"sc_type"',',"',trim(s_oenscript_request->qual[lissidx].sc_type,3),'"')
     SET lvcexe = build('"not_executeable"',',"',s_oenscript_request->qual[lissidx].not_executable,
      '"')
     SET lvcreadonly = build('"read_only"',',"',s_oenscript_request->qual[lissidx].read_only,'"')
     SET lvcscriptfilename = cnvtlower(build(trim(fileheader,3),trim(s_oenscript_request->qual[
        lissidx].scriptname,3),".",trim(subext,3),trim(endext,3)))
     SELECT INTO value(trim(lvcscriptfilename,3))
      build(lvcrev,char(10),lvcname,char(10),lvcdesc,
       char(10),lvctype,char(10),lvcexe,char(10),
       lvcreadonly,char(10),'"sc_body","',s_oenscript_request->qual[lissidx].sc_body,'"')
      WITH format = stream, noheading
     ;end select
     CALL addctp_file(lvcscriptfilename,"OEN SCRIPTS")
   ENDFOR
 END ;Subroutine
 SUBROUTINE getoenprocexp(x)
   DECLARE endext = vc WITH noconstant("procinfo"), protect
   DECLARE lvcprocfile = vc WITH noconstant(""), protect
   DECLARE temp_line = vc WITH noconstant(""), protect
   RECORD s_oenproc_request(
     1 qual_cnt = i4
     1 qual[*]
       2 file_name = vc
       2 interfaceid = i4
       2 proc_name = vc
       2 proc_desc = vc
       2 service = vc
       2 trait_cnt = i4
       2 trait[*]
         3 name = vc
         3 data = vc
   ) WITH protect
   SELECT INTO "nl"
    FROM oen_procinfo op,
     oen_personality ops
    PLAN (op)
     JOIN (ops
     WHERE op.interfaceid=ops.interfaceid)
    ORDER BY op.interfaceid, ops.name
    HEAD REPORT
     lisidx = 0
    HEAD op.interfaceid
     lisidx += 1
     IF (mod(lisidx,10)=1)
      stat = alterlist(s_oenproc_request->qual,(lisidx+ 9))
     ENDIF
     s_oenproc_request->qual[lisidx].file_name = replace(cnvtlower(trim(op.proc_name,3)),
      "0123456789abcdefghijklmnopqrstuvwxyz_ ","0123456789abcdefghijklmnopqrstuvwxyz_ ",3),
     s_oenproc_request->qual[lisidx].file_name = replace(trim(s_oenproc_request->qual[lisidx].
       file_name,3)," ","_",0), s_oenproc_request->qual[lisidx].interfaceid = op.interfaceid,
     s_oenproc_request->qual[lisidx].proc_name = op.proc_name, s_oenproc_request->qual[lisidx].
     proc_desc = op.proc_desc, s_oenproc_request->qual[lisidx].service = op.service,
     lisidx2 = 0
    DETAIL
     lisidx2 += 1
     IF (mod(lisidx2,10)=1)
      stat = alterlist(s_oenproc_request->qual[lisidx].trait,(lisidx2+ 9))
     ENDIF
     s_oenproc_request->qual[lisidx].trait[lisidx2].name = trim(ops.name,3), s_oenproc_request->qual[
     lisidx].trait[lisidx2].data = trim(ops.value)
    FOOT  op.interfaceid
     s_oenproc_request->qual[lisidx].trait_cnt = lisidx2, stat = alterlist(s_oenproc_request->qual[
      lisidx].trait,lisidx2)
    FOOT REPORT
     s_oenproc_request->qual_cnt = lisidx, stat = alterlist(s_oenproc_request->qual,lisidx)
    WITH nocounter
   ;end select
   FOR (lissidx = 1 TO s_oenproc_request->qual_cnt)
     SET lvcprocfile = cnvtlower(build(trim(fileheader,3),trim(s_oenproc_request->qual[lissidx].
        file_name,3),".",trim(subext,3),trim(endext,3)))
     SELECT INTO value(trim(lvcprocfile,3))
      FROM (dummyt d  WITH seq = 1)
      HEAD REPORT
       temp_line = " "
      DETAIL
       temp_line = build('"proc_name","',trim(s_oenproc_request->qual[lissidx].proc_name,3),'"',char(
         10),'"proc_desc","',
        trim(s_oenproc_request->qual[lissidx].proc_desc,3),'"',char(10),'"service","',trim(
         s_oenproc_request->qual[lissidx].service,3),
        '"'),
       CALL print(temp_line), row + 1
       FOR (lissidx2 = 1 TO s_oenproc_request->qual[lissidx].trait_cnt)
         temp_line = build('"',trim(s_oenproc_request->qual[lissidx].trait[lissidx2].name,3),'","',
          trim(s_oenproc_request->qual[lissidx].trait[lissidx2].data),'"'),
         CALL print(temp_line), row + 1
       ENDFOR
      WITH format = lfstream, noheading, noformfeed,
       maxcol = 200, maxrow = 1
     ;end select
     CALL addctp_file(lvcprocfile,"OEN PROCINFO")
   ENDFOR
 END ;Subroutine
 SUBROUTINE triggerreport(x)
   DECLARE sparse = vc WITH noconstant("0 = 0"), protect
   DECLARE sdminforeply = vc WITH noconstant(""), protect
   DECLARE endext = vc WITH noconstant("trigger"), protect
   FREE RECORD interface_class
   RECORD interface_class(
     1 cs401935_cnt = i4
     1 cs401935[*]
       2 code_value = f8
       2 cdfmeaning = vc
       2 cvextval = vc
       2 description = vc
       2 rtseq = i2
       2 arghelp = vc
       2 routine_id = f8
   )
   SELECT INTO "nl:"
    FROM code_value cv,
     code_value_extension cve
    PLAN (cv
     WHERE cv.code_set=4001935
      AND cv.active_ind=1)
     JOIN (cve
     WHERE cve.code_value=cv.code_value
      AND cve.field_name="ARGUMENT")
    HEAD REPORT
     licssize = 0
    DETAIL
     IF (size(trim(cve.field_value,3)))
      licssize += 1
      IF (mod(licssize,10)=1)
       stat = alterlist(interface_class->cs401935,(licssize+ 9))
      ENDIF
      interface_class->cs401935[licssize].code_value = cv.code_value, interface_class->cs401935[
      licssize].cdfmeaning = cv.cdf_meaning, interface_class->cs401935[licssize].cvextval = trim(cve
       .field_value,3),
      interface_class->cs401935[licssize].description = cv.description
     ENDIF
    FOOT REPORT
     interface_class->cs401935_cnt = licssize, stat = alterlist(interface_class->cs401935,licssize)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM dm_info dm
    PLAN (dm
     WHERE dm.info_domain="ESO_TRIGGER"
      AND dm.info_name="ORM")
    DETAIL
     sdminforeply = dm.info_char
    WITH nocounter
   ;end select
   DECLARE line1 = vc WITH constant(fillstring(130,"=")), protect
   DECLARE line2 = vc WITH constant(fillstring(130,"-")), protect
   DECLARE line5 = vc WITH constant(fillstring(106,"=")), protect
   DECLARE line6 = vc WITH constant(fillstring(106,"-")), protect
   DECLARE liworkingarg = vc WITH noconstant(""), protect
   DECLARE myconcat = vc WITH noconstant(""), protect
   DECLARE hl7_in1segment = i2 WITH noconstant(0), protect
   DECLARE trigger_report = vc WITH noconstant(cnvtlower(build(fileheader,"eso_trig_rpt",".",trim(
       subext,3),trim(endext,3)))), protect
   SELECT INTO value(trim(trigger_report,3))
    lvcclass = cnvtlower(cv2.display), lvcsubclass = cnvtlower(cv1.display), cv2.display,
    classtype = trim(cv1.display,3), et.active_ind, et_desc = substring(1,60,trim(et.description,3)),
    er_desc = substring(1,60,trim(er.description,3)), etrr_routine_args = substring(1,100,trim(etrr
      .routine_args,3)), er.active_ind,
    er.description, etrr.active_ind, lvcermyarghold = trim(er.args_help,3)
    FROM eso_trigger et,
     eso_routine er,
     eso_trig_routine_r etrr,
     code_value cv1,
     code_value_extension cve,
     code_value cv2
    PLAN (et
     WHERE et.trigger_id > 0)
     JOIN (etrr
     WHERE etrr.trigger_id=et.trigger_id)
     JOIN (er
     WHERE er.routine_id=etrr.routine_id)
     JOIN (cv1
     WHERE et.interface_type_cd=cv1.code_value)
     JOIN (cve
     WHERE cv1.code_value=cve.code_value
      AND cve.field_name="INTERFACE_CLASS")
     JOIN (cv2
     WHERE cv2.code_set=25752
      AND cv2.active_ind=1
      AND cve.field_value=cv2.cdf_meaning)
    ORDER BY lvcclass, lvcsubclass, et.trigger_id,
     etrr.sequence_nbr
    HEAD REPORT
     col 1, "ESO Tigger Report", row + 1
    HEAD lvcclass
     dummyval = 1
    HEAD lvcsubclass
     row + 1, myconcat = concat(trim(cv2.display,3),"->",trim(cv1.display,3)), col 1,
     myconcat
    HEAD et.trigger_id
     row + 1, col 1, "Trigger",
     col 66, "Class", col 82,
     "Type", col 97, "SubType",
     row + 1, col 1, line1,
     row + 1
     IF (et.active_ind=1)
      col 1, "ON"
     ELSE
      col 1, "OFF"
     ENDIF
     col 5, et_desc, col 66,
     et.class, col 82, et.type,
     col 97, et.subtype, row + 1,
     col 1, line2, row + 1
    HEAD etrr.routine_id
     IF (trim(er.description,3)="HL7 IN1/IN2/IN3/ZNI/ZN2/ZN3 Segments")
      IF (findstring("IN1",etrr.routine_args) > 0
       AND etrr.active_ind=1)
       col 5, "ON"
      ELSE
       col 5, "OFF"
      ENDIF
      col 9, "HL7 IN1 Segment", row + 1
      IF (findstring("IN2",etrr.routine_args) > 0
       AND etrr.active_ind=1)
       col 5, "ON"
      ELSE
       col 5, "OFF"
      ENDIF
      col 9, "HL7 IN2 Segment", row + 1
      IF (findstring("IN3",etrr.routine_args) > 0
       AND etrr.active_ind=1)
       col 5, "ON"
      ELSE
       col 5, "OFF"
      ENDIF
      col 9, "HL7 IN3 Segment", row + 1
      IF (findstring("ZNI",etrr.routine_args) > 0
       AND etrr.active_ind=1)
       col 5, "ON"
      ELSE
       col 5, "OFF"
      ENDIF
      col 9, "HL7 ZNI Segment", row + 1
      IF (findstring("ZN2",etrr.routine_args) > 0
       AND etrr.active_ind=1)
       col 5, "ON"
      ELSE
       col 5, "OFF"
      ENDIF
      col 9, "HL7 ZN2 Segment", row + 1
      IF (findstring("ZN3",etrr.routine_args) > 0
       AND etrr.active_ind=1)
       col 5, "ON"
      ELSE
       col 5, "OFF"
      ENDIF
      col 9, "HL7 ZN2 Segment", hl7_in1segment = 1
     ELSE
      hl7_in1segment = 0
      IF (et.active_ind=1
       AND etrr.active_ind=1)
       col 5, "ON"
      ELSE
       col 5, "OFF"
      ENDIF
      col 9, er_desc
     ENDIF
     IF (size(trim(er.args_help,3))
      AND 0=hl7_in1segment)
      myworkingargshelp = replace(er.args_help,",",";",0), row + 1, idx2 = 0,
      liworkingarg = "MYVALUE"
      WHILE ("NOT FOUND" != trim(liworkingarg,3))
        idx2 += 1, liworkingarg = piece(trim(myworkingargshelp,3),";",idx2,"NOT FOUND",4)
        IF ("NOT FOUND" != trim(liworkingarg,3))
         IF (idx2=1)
          col 25, "Argument", col 70,
          "Description", row + 1, col 25,
          line5, row + 1
         ENDIF
         linum = 1, lifnd_idx = 0
         WHILE ((linum <= interface_class->cs401935_cnt))
          IF (findstring(trim(interface_class->cs401935[linum].cvextval,3),trim(liworkingarg,3),1,0))
           lifnd_idx = linum, linum = interface_class->cs401935_cnt
          ENDIF
          ,linum += 1
         ENDWHILE
         IF (lifnd_idx)
          IF (et.active_ind=1
           AND etrr.active_ind=1
           AND findstring(liworkingarg,etrr.routine_args,1,0))
           col 25, "ON"
          ELSE
           col 25, "OFF"
          ENDIF
         ENDIF
         col 29, interface_class->cs401935[lifnd_idx].cvextval, col 70,
         interface_class->cs401935[lifnd_idx].description, row + 1
        ENDIF
      ENDWHILE
      IF (0 < idx2)
       col 25, line6, row + 1
      ENDIF
     ELSEIF (trim(er.routine,3) IN ("CE_EVENT_CHART_REQUEST", "CE_EVENT_REPORT_REQUEST_XR"))
      idx2 = 0
      IF (0 < size(trim(etrr.routine_args,3)))
       row + 1, col 25, "Argument",
       row + 1, col 25, line5,
       row + 1, idx2 = 1, col 29,
       etrr_routine_args, row + 1
      ENDIF
      liworkingarg = "MYVALUE"
      WHILE ("NOT FOUND" != trim(liworkingarg,3))
        idx2 += 1, liworkingarg = piece(trim(er.args_help,3),";",idx2,"NOT FOUND",4)
        IF ("NOT FOUND" != trim(liworkingarg,3))
         col 29, liworkingarg, row + 1
        ENDIF
      ENDWHILE
      IF (0 < idx2)
       col 25, line6, row + 1
      ENDIF
      row + 1
     ENDIF
     row + 1
    DETAIL
     dummyva1 = 1
    FOOT REPORT
     row + 1, row + 1
    WITH nocounter, noformfeed, maxrow = 1
   ;end select
   CALL addctp_file(trigger_report,"ESO TRIGGERS")
 END ;Subroutine
 SUBROUTINE specialconfigoptions(lfsystemcd)
   DECLARE line1 = vc WITH constant(fillstring(130,"=")), protect
   DECLARE line2 = vc WITH constant(fillstring(130,"-")), protect
   DECLARE line3 = vc WITH constant(fillstring(80,"=")), protect
   DECLARE line4 = vc WITH constant(fillstring(80,"-")), protect
   DECLARE blank_line = vc WITH constant(fillstring(125,"=")), protect
   DECLARE myval = c100 WITH noconstant(" "), protect
   DECLARE idxi = i4 WITH noconstant(0), protect
   RECORD reply(
     1 qual[*]
       2 codevalue_disp = vc
       2 codevalue_cd = f8
       2 codevalue_cdf = vc
       2 codevalue_cs = i4
       2 configuration_options = vc
       2 type = vc
       2 category = vc
       2 section = vc
       2 sub_section = vc
       2 field = vc
       2 def_meaning = vc
       2 contributor_source_cd = f8
       2 contributor_source_disp = vc
       2 alias_type_list = vc
       2 alias_type_display = vc
       2 aliasqual[*]
         3 alias = vc
         3 alias_type_meaning = vc
         3 contributor_source_cd = f8
         3 contributor_source_disp = vc
         3 updt_cnt = i4
       2 use_option_table = vc
       2 server_version = vc
       2 sort_sequence = i4
     1 contributorsystems[*]
       2 contributor_system_disp = vc
     1 con_sys_config = i2
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   RECORD spec_cfg_request(
     1 contributor_system_cd = f8
   ) WITH protect
   SET spec_cfg_request->contributor_system_cd = lfsystemcd
   EXECUTE sim_esi_get_spec_codes  WITH replace("REQUEST",spec_cfg_request)
   SELECT INTO value(build(trim(recsystemcd->sys_qual[ccidx].systemdisp,3),endext2))
    FROM contributor_system cs
    WHERE cs.contributor_system_cd=lfsystemcd
    HEAD REPORT
     col 1, "Special Configuration", row + 2,
     col 1, "Special Contributor System Properties", row + 1,
     col 1, "Configuration Options", col 80,
     "Response", row + 1, col 1,
     line1
    DETAIL
     row + 1, col 1, "For Clinical Event Processing, are you mapping events to the event code or ..."
     IF (cs.result_alias_ind=0)
      col 80, "Event Code"
     ELSE
      col 80, "Order Catalog/DTA"
     ENDIF
     row + 1, col 1, "Do you want to post Input and Output results to the I&O tables?"
     IF (cs.io_result_ind=0)
      col 80, "No"
     ELSE
      col 80, "Yes"
     ENDIF
     row + 1, col 1, "What category of documents is being received on this feed?"
     FOR (idx = 1 TO size(csdmflag->qual,5))
       IF ("EVENT_CLASS_SOURCE_FLAG"=trim(csdmflag->qual[idx].column_name,3)
        AND (cs.event_class_source_flag=csdmflag->qual[idx].flag_value))
        flag_desc = substring(1,50,trim(csdmflag->qual[idx].description,3)), col 80, flag_desc
       ENDIF
     ENDFOR
     row + 1, col 1, "On Discrete Microbiology results, how should the interface process updated ..."
     FOR (idx = 1 TO size(csdmflag->qual,5))
       IF ("MICRO_LIST_REPLACE_FLAG"=trim(csdmflag->qual[idx].column_name,3)
        AND (cs.micro_list_replace_flag=csdmflag->qual[idx].flag_value))
        flag_desc = substring(1,50,trim(csdmflag->qual[idx].description,3)), col 80, flag_desc
       ENDIF
     ENDFOR
     row + 1, col 1, "Can Discrete Microbiology susceptibility tests have multiple interpretive r..."
     IF (cs.micro_multi_interp_ind=0)
      col 80, "No"
     ELSE
      col 80, "Yes"
     ENDIF
     row + 1, col 1, "When using Order Grouping, will orders be grouped based on a last test indi..."
     IF (cs.grouper_multi_ords_ind=0)
      col 80, "No"
     ELSE
      col 80, "Yes"
     ENDIF
     row + 1, col 1, "What is the maximum number of seconds to hold laboratory orders before grou...",
     col 80, cs.grouper_hold_time, row + 1,
     col 1, "What is the maximum number of laboratory orders to hold before grouping?", col 80,
     cs.max_grouper_orders, row + 1
    WITH nocounter, noformfeed, append,
     maxrow = 1
   ;end select
   SET idxi = size(reply->qual,5)
   SELECT INTO value(build(trim(recsystemcd->sys_qual[ccidx].systemdisp,3),endext2))
    cat = reply->qual[d.seq].category, sec = reply->qual[d.seq].section, subsec = reply->qual[d.seq].
    sub_section
    FROM (dummyt d  WITH seq = value(idxi))
    ORDER BY reply->qual[d.seq].category, reply->qual[d.seq].section, reply->qual[d.seq].sub_section,
     reply->qual[d.seq].sort_sequence
    HEAD REPORT
     dummayval = 1, col 1, "Special Configuration"
    HEAD cat
     dummayval = 1
    HEAD sec
     dummyval = 1
    HEAD subsec
     row + 1, row + 1, myval = build2(trim(reply->qual[d.seq].category,3)," ",trim(reply->qual[d.seq]
       .section,3)," ",trim(reply->qual[d.seq].sub_section,3)),
     col 1, myval, row + 1,
     col 1, "Configuration Options", col + 71,
     "Code Set", col + 6, "Code Value",
     col + 1, "CDF", row + 1,
     col 1, line1, idxlinenum = 0
    DETAIL
     row + 1, idxlinenum += 1, myidx = format(idxlinenum,"##;rp0"),
     col 1, myidx
     IF (86 < size(trim(reply->qual[d.seq].configuration_options,3)))
      question = concat(trim(substring(1,83,reply->qual[d.seq].configuration_options),3),"...")
     ELSE
      question = substring(1,85,reply->qual[d.seq].configuration_options)
     ENDIF
     col 4, question, col 90,
     reply->qual[d.seq].codevalue_cs, col + 2, reply->qual[d.seq].codevalue_cd,
     col + 1, reply->qual[d.seq].codevalue_cdf
     IF (size(reply->qual[d.seq].aliasqual,5))
      row + 1, col 50, "Response",
      col 118, "Type Meaning", row + 1,
      col 50, line3
      FOR (liiidx = 1 TO size(reply->qual[d.seq].aliasqual,5))
        row + 1, responseans = substring(1,28,reply->qual[d.seq].aliasqual[liiidx].alias), col 50,
        reply->qual[d.seq].aliasqual[liiidx].alias, col 118, reply->qual[d.seq].aliasqual[liiidx].
        alias_type_meaning
      ENDFOR
      row + 1, col 50, line4
     ENDIF
    FOOT REPORT
     row + 1, row + 1, col 1,
     blank_line
    WITH nocounter, noformfeed, append,
     maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE holdrules(x)
   FREE RECORD holdrules
   RECORD holdrules(
     1 hqual[*]
       2 hrrank = i4
       2 hrruleid = i4
       2 hractiveind = i2
       2 hrdescription = vc
       2 hrinterfacetypecd = f8
       2 hrinterfacetypedisp = vc
       2 hrclass = vc
       2 hrtype = vc
       2 hrsubtype = vc
       2 hrruleactioncd = f8
       2 hrruleactiondisp = vc
       2 hrencountertypecd = f8
       2 hrencountertypedisp = vc
       2 hrorganizationid = f8
       2 hrorganizationname = vc
       2 hractivitytypecd = f8
       2 hractivitytypedisp = vc
       2 hrorderactioncd = f8
       2 hrorderactiondisp = vc
       2 hrcatalogcd = f8
       2 hrcatalogdisp = vc
       2 hreventcd = f8
       2 hreventdisp = vc
       2 hreventclasscd = f8
       2 hreventclassdisp = vc
       2 hrcontribcd = f8
       2 hrcontribdisp = vc
       2 hractioncd = f8
       2 hractiondisp = vc
       2 hrmsgvercd = f8
       2 hrmsgverdisp = vc
       2 hrpersonfirsteventid = i4
       2 hrpersonfirsteventdisp = vc
       2 hrencntrfirsteventid = i4
       2 hrencntrfirsteventdisp = cv
       2 rcseq = i4
       2 rcactiveind = i2
       2 rcopactivityflagid = i4
       2 rcopactivityflagdisp = vc
       2 rcassignauthcd = f8
       2 rcassignauthdisp = vc
       2 rcaliaspoolcd = f8
       2 rcaliaspooldisp = vc
   ) WITH protect
   DECLARE lihidx = i4 WITH noconstant(0), protect
   DECLARE endext = vc WITH noconstant("hold"), protect
   SELECT INTO "nl:"
    hr.class, hr.type, hr.subtype,
    act_contrib_sys_cd = uar_get_code_display(hr.action_contrib_sys_cd), rule_act_disp =
    uar_get_code_display(hr.rule_action_cd), intfc_type_disp = uar_get_code_display(hr
     .interface_type_cd),
    act_type_disp = uar_get_code_display(hr.activity_type_cd), enc_type_disp = uar_get_code_display(
     hr.encntr_type_cd), evnt_class_disp = uar_get_code_display(hr.event_class_cd),
    ord_act_disp = uar_get_code_display(hr.order_action_cd), mess_vers_disp = uar_get_code_display(hr
     .message_version_cd), cat_disp = uar_get_code_display(hr.catalog_cd),
    evnt_disp = uar_get_code_display(hr.event_cd), org_id = hr.organization_id, org_disp = org
    .org_name,
    hrc.seq_num, hrc.parent_entity_name, assign_auth_sys_disp = uar_get_code_display(hrc
     .assign_authority_sys_cd),
    alias_pool_disp = uar_get_code_display(hrc.alias_pool_cd), hrc.op_activity_flag, hr.*,
    hrc.*
    FROM hold_rule hr,
     hold_rule_condition hrc,
     organization org
    PLAN (hr)
     JOIN (hrc
     WHERE (0!= Outerjoin(hr.hold_rule_id))
      AND (hrc.hold_rule_id= Outerjoin(hr.hold_rule_id)) )
     JOIN (org
     WHERE hr.organization_id=org.organization_id)
    ORDER BY hr.hold_rule_id, hr.description, hrc.seq_num
    DETAIL
     lihidx += 1, stat = alterlist(holdrules->hqual,lihidx), getrank = 0
     IF (hr.catalog_cd > 0)
      getrank += 1
     ENDIF
     IF (hr.event_cd > 0)
      getrank += 1
     ENDIF
     IF (hr.action_contrib_sys_cd > 0)
      getrank += 1
     ENDIF
     IF (hr.activity_type_cd > 0)
      getrank += 1
     ENDIF
     IF (hr.encntr_type_cd > 0)
      getrank += 1
     ENDIF
     IF (hr.event_class_cd > 0)
      getrank += 1
     ENDIF
     IF (hr.order_action_cd > 0)
      getrank += 1
     ENDIF
     IF (hr.organization_id > 0)
      getrank += 1
     ENDIF
     IF (hr.person_first_event_flag IN (0, 1))
      getrank += 1
     ENDIF
     IF (hr.encntr_first_event_flag IN (0, 1))
      getrank += 1
     ENDIF
     holdrules->hqual[lihidx].hrrank = getrank, holdrules->hqual[lihidx].hrruleid = hr.hold_rule_id,
     holdrules->hqual[lihidx].hractiveind = hr.active_ind,
     holdrules->hqual[lihidx].hrdescription = substring(1,30,trim(hr.description,3)), holdrules->
     hqual[lihidx].hrinterfacetypecd = hr.interface_type_cd, holdrules->hqual[lihidx].
     hrinterfacetypedisp = intfc_type_disp,
     holdrules->hqual[lihidx].hrclass = substring(1,15,trim(hr.class,3)), holdrules->hqual[lihidx].
     hrtype = substring(1,15,trim(hr.type,3)), holdrules->hqual[lihidx].hrsubtype = substring(1,15,
      trim(hr.subtype,3)),
     holdrules->hqual[lihidx].hrruleactioncd = hr.rule_action_cd, holdrules->hqual[lihidx].
     hrruleactiondisp = rule_act_disp, holdrules->hqual[lihidx].hrencountertypecd = hr.encntr_type_cd,
     holdrules->hqual[lihidx].hrencountertypedisp = enc_type_disp, holdrules->hqual[lihidx].
     hrorganizationid = org.organization_id, holdrules->hqual[lihidx].hrorganizationname = org
     .org_name,
     holdrules->hqual[lihidx].hractivitytypecd = hr.activity_type_cd, holdrules->hqual[lihidx].
     hractivitytypedisp = act_type_disp, holdrules->hqual[lihidx].hrorderactioncd = hr
     .order_action_cd,
     holdrules->hqual[lihidx].hrorderactiondisp = ord_act_disp, holdrules->hqual[lihidx].hrcatalogcd
      = hr.catalog_cd, holdrules->hqual[lihidx].hrcatalogdisp = cat_disp,
     holdrules->hqual[lihidx].hreventcd = hr.event_cd, holdrules->hqual[lihidx].hreventdisp =
     evnt_disp, holdrules->hqual[lihidx].hreventclasscd = hr.event_class_cd,
     holdrules->hqual[lihidx].hreventclassdisp = evnt_class_disp, holdrules->hqual[lihidx].
     hrcontribcd = hr.action_contrib_sys_cd, holdrules->hqual[lihidx].hrcontribdisp =
     act_contrib_sys_cd,
     holdrules->hqual[lihidx].hractioncd = hr.rule_action_cd, holdrules->hqual[lihidx].hractiondisp
      = rule_act_disp, holdrules->hqual[lihidx].hrmsgvercd = hr.message_version_cd,
     holdrules->hqual[lihidx].hrmsgverdisp = mess_vers_disp, holdrules->hqual[lihidx].
     hrpersonfirsteventid = hr.person_first_event_flag
     CASE (hr.person_first_event_flag)
      OF 0:
       holdrules->hqual[lihidx].hrpersonfirsteventdisp = "False"
      OF 1:
       holdrules->hqual[lihidx].hrpersonfirsteventdisp = "True"
      OF 2:
       holdrules->hqual[lihidx].hrpersonfirsteventdisp = "True or False"
     ENDCASE
     holdrules->hqual[lihidx].hrencntrfirsteventid = hr.encntr_first_event_flag
     IF (0=hr.encntr_first_event_flag)
      holdrules->hqual[lihidx].hrencntrfirsteventdisp = "False"
     ENDIF
     IF (1=hr.encntr_first_event_flag)
      holdrules->hqual[lihidx].hrencntrfirsteventdisp = "True"
     ENDIF
     IF (2=hr.encntr_first_event_flag)
      holdrules->hqual[lihidx].hrencntrfirsteventdisp = "True or False"
     ENDIF
     holdrules->hqual[lihidx].rcseq = hrc.seq_num, holdrules->hqual[lihidx].rcactiveind = hrc
     .active_ind, holdrules->hqual[lihidx].rcopactivityflagid = hrc.op_activity_flag
     CASE (hrc.op_activity_flag)
      OF 1:
       holdrules->hqual[lihidx].rcopactivityflagdisp = "Person Alias"
      OF 2:
       holdrules->hqual[lihidx].rcopactivityflagdisp = "Encntr Alias"
      OF 3:
       holdrules->hqual[lihidx].rcopactivityflagdisp = "Order Alias"
      OF 4:
       holdrules->hqual[lihidx].rcopactivityflagdisp = "Scheduling Event Alias"
      OF 5:
       holdrules->hqual[lihidx].rcopactivityflagdisp = "LR Alias"
     ENDCASE
     holdrules->hqual[lihidx].rcassignauthcd = hrc.assign_authority_sys_cd, holdrules->hqual[lihidx].
     rcassignauthdisp = assign_auth_sys_disp, holdrules->hqual[lihidx].rcaliaspoolcd = hrc
     .alias_pool_cd,
     holdrules->hqual[lihidx].rcaliaspooldisp = alias_pool_disp
    WITH nocounter
   ;end select
   DECLARE lv1line1 = c130 WITH noconstant(fillstring(130,"-")), protect
   DECLARE lv1line2 = c130 WITH noconstant(fillstring(130,"=")), protect
   DECLARE lv2line1 = c124 WITH noconstant(fillstring(124,"-")), protect
   DECLARE lv2line2 = c124 WITH noconstant(fillstring(124,"=")), protect
   DECLARE lv3line1 = c121 WITH noconstant(fillstring(121,"-")), protect
   DECLARE lv3line2 = c121 WITH noconstant(fillstring(121,"=")), protect
   DECLARE hold_report = vc WITH noconstant(cnvtlower(build(fileheader,"hold_configs",".",trim(subext,
       3),trim(endext,3)))), protect
   SELECT INTO value(trim(hold_report,3))
    lvcrank = holdrules->hqual[d.seq].hrrank, liruleid = holdrules->hqual[d.seq].hrruleid, liseq =
    holdrules->hqual[d.seq].rcseq
    FROM (dummyt d  WITH seq = value(lihidx))
    ORDER BY holdrules->hqual[d.seq].hrrank, holdrules->hqual[d.seq].hrruleid DESC, holdrules->hqual[
     d.seq].rcseq
    HEAD REPORT
     col 1, "INTERFACE HOLD CONFIGURATIONS", row + 2
    HEAD lvcrank
     linerank = format(holdrules->hqual[d.seq].hrrank,"##;rp0")
    HEAD liruleid
     col 1, "Rank", col 07,
     "Active", col 15, "RuleID",
     col 23, "Description", row + 1,
     col 01, lv1line2, row + 1
     IF (0=lihidx)
      col 7, "**** NO HOLD RULES CONFIGURED ****", row + 1
     ELSE
      col 1, linerank
      IF (holdrules->hqual[d.seq].hractiveind)
       col 07, "ON"
      ELSE
       col 07, "OFF"
      ENDIF
      lvcruleid = cnvtstring(holdrules->hqual[d.seq].hrruleid), col 15, lvcruleid,
      col 23, holdrules->hqual[d.seq].hrdescription, row + 1,
      col 01, lv1line1, row + 1,
      col 7, "Related Information", col 32,
      "Description", row + 1, col 7,
      lv2line2, row + 1
      IF (size(trim(holdrules->hqual[d.seq].hrinterfacetypedisp,3)))
       col 7, "Interface Type:", col 32,
       holdrules->hqual[d.seq].hrinterfacetypedisp, row + 1
      ENDIF
      IF (size(trim(holdrules->hqual[d.seq].hrclass,3)))
       col 7, "Class:", col 32,
       holdrules->hqual[d.seq].hrclass, row + 1
      ENDIF
      IF (size(trim(holdrules->hqual[d.seq].hrtype,3)))
       col 7, "Type:", col 32,
       holdrules->hqual[d.seq].hrtype, row + 1
      ENDIF
      IF (size(trim(holdrules->hqual[d.seq].hrsubtype,3)))
       col 7, "SubType:", col 32,
       holdrules->hqual[d.seq].hrsubtype, row + 1
      ENDIF
      IF (size(trim(holdrules->hqual[d.seq].hrruleactiondisp,3)))
       col 7, "Rule Action:", col 32,
       holdrules->hqual[d.seq].hrruleactiondisp, row + 1
      ENDIF
      IF (size(trim(holdrules->hqual[d.seq].hrencountertypedisp,3)))
       col 7, "Encounter Type:", col 32,
       holdrules->hqual[d.seq].hrencountertypedisp, row + 1
      ENDIF
      IF (size(trim(holdrules->hqual[d.seq].hrorganizationname,3)))
       col 7, "Organization:", lvcorgname = substring(1,98,trim(holdrules->hqual[d.seq].
         hrorganizationname,3)),
       col 32, lvcorgname, row + 1
      ENDIF
      IF (size(trim(holdrules->hqual[d.seq].hractivitytypedisp,3)))
       col 7, "Activity Type:", col 32,
       holdrules->hqual[d.seq].hractivitytypedisp, row + 1
      ENDIF
      IF (size(trim(holdrules->hqual[d.seq].hrorderactiondisp,3)))
       col 7, "Order Action:", col 32,
       holdrules->hqual[d.seq].hrorderactiondisp, row + 1
      ENDIF
      IF (size(trim(holdrules->hqual[d.seq].hrcatalogdisp,3)))
       col 7, "Catalog:", col 32,
       holdrules->hqual[d.seq].hrcatalogdisp, row + 1
      ENDIF
      IF (size(trim(holdrules->hqual[d.seq].hreventdisp,3)))
       col 7, "Event:", col 32,
       holdrules->hqual[d.seq].hreventdisp, row + 1
      ENDIF
      IF (size(trim(holdrules->hqual[d.seq].hreventclassdisp,3)))
       col 7, "Event Class:", col 32,
       holdrules->hqual[d.seq].hreventclassdisp, row + 1
      ENDIF
      IF (size(trim(holdrules->hqual[d.seq].hrcontribdisp,3)))
       col 7, "Action Contrib Sys:", col 32,
       holdrules->hqual[d.seq].hrcontribdisp, row + 1
      ENDIF
      IF (size(trim(holdrules->hqual[d.seq].hrmsgverdisp,3)))
       col 7, "Message Version:", col 32,
       holdrules->hqual[d.seq].hrmsgverdisp, row + 1
      ENDIF
      IF (size(trim(holdrules->hqual[d.seq].hrpersonfirsteventdisp,3)))
       col 7, "Person First Event:", col 32,
       holdrules->hqual[d.seq].hrpersonfirsteventdisp, row + 1
      ENDIF
      IF (size(trim(holdrules->hqual[d.seq].hrencntrfirsteventdisp,3)))
       col 7, "Encntr First Event:", col 32,
       holdrules->hqual[d.seq].hrencntrfirsteventdisp, row + 1
      ENDIF
     ENDIF
     col 7, lv2line1, row + 1
     IF (holdrules->hqual[d.seq].rcseq)
      col 10, "HOLD RULE CONDITION", row + 1,
      col 10, "Active", col 18,
      "SEQNum", col 25, "OP Activity Flag",
      col 49, "Assigning Auth", col 90,
      "Alias Pool", row + 1, col 10,
      lv3line2, row + 1
     ENDIF
    HEAD liseq
     IF (holdrules->hqual[d.seq].rcseq)
      IF (holdrules->hqual[d.seq].rcactiveind)
       col 10, "ON"
      ELSE
       col 10, "OFF"
      ENDIF
      col 13, holdrules->hqual[d.seq].rcseq, col 25,
      holdrules->hqual[d.seq].rcopactivityflagdisp, col 49, holdrules->hqual[d.seq].rcassignauthdisp,
      col 90, holdrules->hqual[d.seq].rcaliaspooldisp, row + 1
     ENDIF
    DETAIL
     dummayval = 1
    FOOT  liseq
     dummayval = 1
    FOOT  liruleid
     IF (holdrules->hqual[d.seq].rcseq)
      col 10, lv3line1, row + 2
     ENDIF
    FOOT  lvcrank
     row + 1
    WITH nocounter, noformfeed, maxrow = 1
   ;end select
   CALL addctp_file(hold_report,"HOLD RULE CONFIGURATIONS")
 END ;Subroutine
 SUBROUTINE copyfile(dir_loc,lfile_name,lbackup_loc)
   DECLARE cmd_status = i4 WITH noconstant(0), protect
   DECLARE command = vc WITH noconstant(""), protect
   DECLARE command2 = vc WITH noconstant(""), protect
   DECLARE rtn_val = i2 WITH noconstant(1), protect
   IF (cursys2 IN ("LNX", "AIX"))
    SET command = concat("cp ",trim(dir_loc,3),trim(lfile_name,3)," ",trim(lbackup_loc,3))
    SET command2 = concat("ls ",trim(dir_loc,3),trim(lfile_name,3))
   ENDIF
   CALL echo(build("ls command->",command2,char(0)))
   CALL dcl(command2,size(trim(command2)),cmd_status)
   IF (cmd_status != 1)
    SET lvcmessage = build("Audit: no files to copy:",cnvtstring(cmd_status),char(0))
    CALL echo(build("#----------------------------------------",char(0)))
    CALL echo(build("#",lvcmessage,char(0)))
    CALL echo(build("#----------------------------------------",char(0)))
    SET rtn_val = 0
   ELSE
    CALL echo(build("copy command->",command,char(0)))
    CALL dcl(command,size(trim(command)),cmd_status)
    IF (cmd_status != 1)
     SET lvcmessage = build("ERROR: copy not sucessful status:",cnvtstring(cmd_status),char(0))
     CALL echo(build("#----------------------------------------",char(0)))
     CALL echo(build("#",lvcmessage,char(0)))
     CALL echo(build("#----------------------------------------",char(0)))
     SET rtn_val = 0
    ELSE
     CALL echo(build("#----------------------------------------",char(0)))
     CALL echo(concat("AUDIT: copy sucessfull status:",cnvtstring(cmd_status),char(0)))
     CALL echo(build("#----------------------------------------",char(0)))
    ENDIF
   ENDIF
   RETURN(rtn_val)
 END ;Subroutine
 SUBROUTINE (delfile(dir_loc=vc,lfilename=vc) =null WITH protect)
   DECLARE command = vc WITH noconstant(""), protect
   DECLARE cmd_status = i4 WITH noconstant(0), protect
   DECLARE rtn_val = i2 WITH noconstant(1), protect
   IF (cursys2 IN ("LNX", "AIX"))
    SET command = concat("rm ",trim(dir_loc,3),trim(lfilename,3))
   ENDIF
   CALL echo(build("del command->",command,char(0)))
   CALL dcl(command,size(trim(command)),cmd_status)
   CALL echo(build("#----------------------------------------",char(0)))
   IF (cmd_status != 1)
    CALL echo(concat("WARNING: unable to delete file:",trim(lfilename,3),char(0)))
    SET rtn_val = 0
   ELSE
    CALL echo(concat("AUDIT: File Sucessfully Deleted:",trim(lfilename,3),char(0)))
    SET rtn_val = 1
   ENDIF
   CALL echo(build("#----------------------------------------",char(0)))
   RETURN(rtn_val)
 END ;Subroutine
 SUBROUTINE (zipfiles(zipfilename=vc,filestozip=vc) =null WITH protect)
   DECLARE command = vc WITH noconstant(""), protect
   DECLARE cmd_status = i4 WITH noconstant(0), protect
   DECLARE rtn_val = i2 WITH noconstant(1), protect
   IF (cursys2 IN ("LNX", "AIX"))
    SET command = concat("zip -u ",trim(zipfilename,3)," ",trim(filestozip,3))
   ENDIF
   CALL echo(build("zip command->",command,char(0)))
   CALL dcl(command,size(trim(command)),cmd_status)
   CALL echo(build("#----------------------------------------",char(0)))
   IF (cmd_status != 1)
    CALL echo(concat("WARNING: unable to zip files:",trim(filestozip,3),char(0)))
    SET rtn_val = 0
   ELSE
    IF (cursys2 IN ("LNX", "AIX"))
     SET command = concat("ls ",trim(zipfilename,3),"*.*")
    ENDIF
    CALL dcl(command,size(trim(command)),cmd_status)
    IF (cmd_status != 1)
     CALL echo(concat("WARNING: unable to zip files:",trim(filestozip,3),char(0)))
    ELSE
     CALL echo(concat("AUDIT: Files Sucessfully ziped:",trim(zipfilename,3),".zip",char(0)))
     SET rtn_val = 1
    ENDIF
   ENDIF
   CALL echo(build("#----------------------------------------",char(0)))
   RETURN(rtn_val)
 END ;Subroutine
 SUBROUTINE (addctp_file(file_name=vc,file_type=vc) =null WITH protect)
   IF (validate(CTP_FSI::fsi_files)=1)
    SET ctp_fsi::fsi_files->file_cnt += 1
    SET stat = alterlist(ctp_fsi::fsi_files->file_list,ctp_fsi::fsi_files->file_cnt)
    SET ctp_fsi::fsi_files->file_list[ctp_fsi::fsi_files->file_cnt].file_name = file_name
    SET ctp_fsi::fsi_files->file_list[ctp_fsi::fsi_files->file_cnt].file_type = file_type
   ENDIF
 END ;Subroutine
 SUBROUTINE addctp_notes(textline)
   IF (validate(CTP_FSI::fsi_files)=1)
    SET stat = alterlist(ctp_fsi::fsi_files->notes,(size(ctp_fsi::fsi_files->notes,5)+ 1))
    SET ctp_fsi::fsi_files->notes[size(ctp_fsi::fsi_files->notes,5)].note_text = textline
   ENDIF
 END ;Subroutine
#exit_script
 CALL echo(build(scriptver,char(0)))
 CALL echo(build("***** End cust_config_audit_all *****",char(0)))
END GO
