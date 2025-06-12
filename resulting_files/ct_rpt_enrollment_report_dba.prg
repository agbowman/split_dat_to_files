CREATE PROGRAM ct_rpt_enrollment_report:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Protocols" = "",
  "Accrual numbers" = 2,
  "Order By" = 0,
  "Output type" = 0,
  "Delimiter" = ","
  WITH outdev, protocols, accrual,
  orderby, out_type, delimiter
 RECORD protlist(
   1 protocols[*]
     2 protocol_id = f8
     2 prot_mnemonic = vc
   1 accrual_numbers = i2
   1 order_by = i2
 )
 RECORD results(
   1 protocols[*]
     2 prot_master_id = f8
     2 prot_mnemonic = vc
     2 collab_site_ind = i2
     2 parent_prot_master_id = f8
     2 activation_date = dq8
     2 prot_status_cd = f8
     2 prot_status_disp = c40
     2 prot_status_desc = c60
     2 prot_status_mean = c12
     2 trialwide_cur_accrual = i2
     2 trialwide_targeted = i2
     2 trialwide_percent = c10
     2 trialwide_prj_accrual = i2
     2 site_cur_accrual = i2
     2 site_targeted = i2
     2 site_percent = c10
     2 site_prj_accrual = i2
     2 primary_sponsor = c100
 )
 RECORD accrual_request(
   1 collab_site_ind = i2
   1 parent_prot_master_id = f8
   1 active_parent_amend_id = f8
   1 prot_amendment_id = f8
   1 prot_master_id = f8
   1 requiredaccrualcd = f8
   1 person_id = f8
   1 participation_type_cd = f8
   1 application_nbr = i4
   1 pref_domain = vc
   1 pref_section = vc
   1 pref_name = vc
 )
 RECORD accrual_reply(
   1 grouptargetaccrual = i2
   1 grouptargetaccrued = i2
   1 targetaccrual = i2
   1 totalaccrued = i2
   1 excludedpersonind = i2
   1 bfound = i2
   1 active_parent_amend_id = f8
   1 active_parent_amend_dt_tm = dq8
   1 group_target_accrual = i2
   1 participation_type_cd = f8
   1 prot_accrual = i2
   1 group_accrual = i2
   1 track_tw_accrual = i2
   1 collab_ind = i2
   1 is_parent = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD report_labels(
   1 m_s_trial_wide_title = vc
   1 m_s_site_title = vc
   1 m_s_trial_and_site_title = vc
   1 m_s_rpt_exec_time = vc
   1 m_s_prot_mnemonic_header = vc
   1 m_s_act_date_header = vc
   1 m_s_status_header = vc
   1 m_s_trial_cur_accrual_header = vc
   1 m_s_percent_trial_header = vc
   1 m_s_site_cur_accrual_header = vc
   1 m_s_projected_accrual_header = vc
   1 m_s_trial_target_accrual_header = vc
   1 m_s_site_target_accrual_header = vc
   1 m_s_percent_site_header = vc
   1 m_s_percent_header = vc
   1 m_s_sponsor_header = vc
   1 m_s_total_prots_selected = vc
   1 m_s_total_pts_accrued = vc
   1 m_s_total_site_pts_accrued = vc
   1 m_s_end_of_rpt = vc
   1 m_s_order_by_date = vc
   1 m_s_order_by_status = vc
   1 m_s_order_by_sponsor = vc
   1 m_s_order_by_prot = vc
   1 m_s_no_prot_found = vc
   1 m_s_page = vc
   1 execution_timestamp = vc
   1 sorting_field = vc
   1 sorted_by = vc
   1 report_title = vc
   1 accrual_type = i2
   1 output_type = i2
   1 delimiter_output = vc
   1 total_prot = vc
   1 total_patients = vc
   1 total_site_pt_accrued = vc
 )
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 IF ( NOT (validate(domain_reply)))
  RECORD domain_reply(
    1 logical_domain_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 EXECUTE ct_get_logical_domain_id  WITH replace("REPLY",domain_reply)
 DECLARE i18nhandle = i4 WITH public, noconstant(0)
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET report_labels->m_s_trial_wide_title = uar_i18ngetmessage(i18nhandle,"TRIAL_ACCRUAL",
  "Trial Wide Accrual Totals per Protocol")
 SET report_labels->m_s_site_title = uar_i18ngetmessage(i18nhandle,"SITE_ACCRUAL",
  "Site Accrual Totals per Protocol")
 SET report_labels->m_s_trial_and_site_title = uar_i18ngetmessage(i18nhandle,"TRIAL_SITE_ACCRUAL",
  "Accrual Totals per Protocol")
 SET report_labels->m_s_rpt_exec_time = uar_i18ngetmessage(i18nhandle,"RPT_EXEC_TIME",
  "Report execution time:")
 SET report_labels->m_s_prot_mnemonic_header = uar_i18ngetmessage(i18nhandle,"PROT_MNEMONIC",
  "Protocol Mnemonic")
 SET report_labels->m_s_act_date_header = uar_i18ngetmessage(i18nhandle,"ACT_DATE","Activation Date")
 SET report_labels->m_s_status_header = uar_i18ngetmessage(i18nhandle,"STATUS_HEADER","Status")
 SET report_labels->m_s_trial_cur_accrual_header = uar_i18ngetmessage(i18nhandle,"TRIAL_CUR_ACCRUAL",
  "Trial Wide Current Accrual")
 SET report_labels->m_s_percent_trial_header = uar_i18ngetmessage(i18nhandle,"PERCENT_TRIAL",
  "% of Trial Wide Total")
 SET report_labels->m_s_site_cur_accrual_header = uar_i18ngetmessage(i18nhandle,"SITE_CUR_ACCRUAL",
  "Current Site Accrual")
 SET report_labels->m_s_projected_accrual_header = uar_i18ngetmessage(i18nhandle,"PROJECTED_ACCRUAL",
  "Projected Accrual Amount")
 SET report_labels->m_s_trial_target_accrual_header = uar_i18ngetmessage(i18nhandle,
  "TRIAL_TARGET_ACCRUAL","Trial Wide Target Accrual")
 SET report_labels->m_s_site_target_accrual_header = uar_i18ngetmessage(i18nhandle,
  "SITE_TARGET_ACCRUAL","Site Target Accrual")
 SET report_labels->m_s_percent_site_header = uar_i18ngetmessage(i18nhandle,"PERCENT_SITE",
  "% of Site Target")
 SET report_labels->m_s_percent_header = uar_i18ngetmessage(i18nhandle,"PERCENT","% of Total")
 SET report_labels->m_s_sponsor_header = uar_i18ngetmessage(i18nhandle,"SPONSOR","Sponsor")
 SET report_labels->m_s_total_prots_selected = uar_i18ngetmessage(i18nhandle,"TOTAL_PROTS_SEL",
  "Total Protocols Selected:")
 SET report_labels->m_s_total_pts_accrued = uar_i18ngetmessage(i18nhandle,"TOTAL_PTS_ACCRUED",
  "Total Patients Accrued:")
 SET report_labels->m_s_total_site_pts_accrued = uar_i18ngetmessage(i18nhandle,
  "TOTAL_SITE_PTS_ACCRUED","Total Site Patients Accrued:")
 SET report_labels->m_s_end_of_rpt = uar_i18ngetmessage(i18nhandle,"END_OF_RPT",
  "*** End of Report ***")
 SET report_labels->m_s_order_by_date = uar_i18ngetmessage(i18nhandle,"ORDER_BY_DATE",
  "Ordered by activation date")
 SET report_labels->m_s_order_by_status = uar_i18ngetmessage(i18nhandle,"ORDER_BY_STATUS",
  "Ordered by status")
 SET report_labels->m_s_order_by_sponsor = uar_i18ngetmessage(i18nhandle,"ORDER_BY_SPONSOR",
  "Ordered by sponsor")
 SET report_labels->m_s_order_by_prot = uar_i18ngetmessage(i18nhandle,"ORDER_BY_PROT",
  "Ordered by protocol")
 SET report_labels->m_s_no_prot_found = uar_i18ngetmessage(i18nhandle,"NO_PROT_FOUND",
  "There were no protocols found that met the selected search criteria.")
 SET report_labels->m_s_page = uar_i18ngetmessage(i18nhandle,"PAGE","Page:")
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE tempstr = vc WITH protect, noconstant("")
 DECLARE tmp_prot = vc WITH protect, noconstant("")
 DECLARE tmp_status = vc WITH protect, noconstant("")
 DECLARE tmp_sponsor = vc WITH protect, noconstant("")
 DECLARE tmp_prj_acc = vc WITH protect, noconstant("")
 DECLARE tmp_site_prj_acc = vc WITH protect, noconstant("")
 DECLARE tmp_tw_targ = vc WITH protect, noconstant("")
 DECLARE tmp_tw_cur_acc = vc WITH protect, noconstant("")
 DECLARE tmp_tw_percent = vc WITH protect, noconstant("")
 DECLARE tmp_site_targ = vc WITH protect, noconstant("")
 DECLARE tmp_site_cur_acc = vc WITH protect, noconstant("")
 DECLARE tmp_site_percent = vc WITH protect, noconstant("")
 DECLARE temp_row = i4 WITH protect, noconstant(0)
 DECLARE orderby = vc WITH protect, noconstant("")
 DECLARE exec_timestamp = vc WITH protect, noconstant("")
 DECLARE tmp_act_date = vc WITH protect, noconstant("")
 DECLARE prot_cnt = i2 WITH protect, noconstant(0)
 DECLARE idx = i2 WITH protect, noconstant(0)
 DECLARE prot_id = f8 WITH protect, noconstant(0.0)
 DECLARE active_amd_id = f8 WITH protect, noconstant(0.0)
 DECLARE active_amd_dt_tm = dq8 WITH protect, noconstant(0.0)
 DECLARE tmp_duration = vc WITH protect, noconstant("")
 DECLARE all_prots_ind = i2 WITH protect, noconstant(0)
 DECLARE tw_cur_accrual_sum = i4 WITH protect, noconstant(0)
 DECLARE site_cur_accrual_sum = i4 WITH protect, noconstant(0)
 DECLARE num = i2 WITH protect, noconstant(0)
 DECLARE offset = i2 WITH protect, noconstant(0)
 DECLARE org_prim_cd = f8 WITH protect, noconstant(0.0)
 DECLARE tempval = f8 WITH protect, noconstant(0.0)
 DECLARE proj_duration = i4 WITH protect, noconstant(0)
 DECLARE days_from_act = i4 WITH protect, noconstant(0)
 DECLARE duration_cd = f8 WITH protect, noconstant(0.0)
 DECLARE duration_value = f8 WITH protect, noconstant(0.0)
 DECLARE trialwide_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17906,"TRIALWIDE"))
 DECLARE def_org_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17906,"DEFAULTORG"))
 DECLARE trialwide_value_cd = f8 WITH protect, noconstant(0.00)
 DECLARE def_org_value_cd = f8 WITH protect, noconstant(0.00)
 DECLARE accrual_required_indc_cd = f8 WITH protect, noconstant(0.00)
 DECLARE m_s_blank_percent = vc WITH protect, constant("     --")
 SET stat = uar_get_meaning_by_codeset(17271,"PRIMARY",1,org_prim_cd)
 SET report_labels->execution_timestamp = concat(report_labels->m_s_rpt_exec_time," ",format(
   cnvtdatetime(sysdate),"@SHORTDATETIME"))
 SET report_labels->accrual_type =  $ACCRUAL
 SET report_labels->output_type =  $OUT_TYPE
 SET report_labels->delimiter_output =  $DELIMITER
 IF (reflect(parameter(2,0))="C1")
  SET all_prots_ind = 1
 ELSEIF (substring(1,1,reflect(parameter(2,0)))="L")
  SET cnt = 1
  WHILE (reflect(parameter(2,cnt)) > " ")
    IF (mod(cnt,10)=1)
     SET stat = alterlist(protlist->protocols,(cnt+ 9))
    ENDIF
    SET protlist->protocols[cnt].protocol_id = cnvtreal(parameter(2,cnt))
    SET cnt += 1
  ENDWHILE
  SET cnt -= 1
  SET stat = alterlist(protlist->protocols,cnt)
 ELSEIF (reflect(parameter(2,0))="F8")
  IF (cnvtreal(parameter(2,0))=0.0)
   SET all_prots_ind = 1
  ENDIF
  SET stat = alterlist(protlist->protocols,1)
  SET protlist->protocols[1].protocol_id = cnvtreal(parameter(2,1))
 ENDIF
 IF (all_prots_ind=1)
  SET cnt = 0
  SELECT DISTINCT
   pm.primary_mnemonic, pm.prot_master_id
   FROM prot_amendment pa,
    prot_master pm
   PLAN (pa
    WHERE pa.amendment_dt_tm <= cnvtdatetime(sysdate))
    JOIN (pm
    WHERE pm.prot_master_id=pa.prot_master_id
     AND (pm.logical_domain_id=domain_reply->logical_domain_id)
     AND pm.prot_master_id > 0.0)
   DETAIL
    cnt += 1
    IF (mod(cnt,10)=1)
     stat = alterlist(protlist->protocols,(cnt+ 9))
    ENDIF
    protlist->protocols[cnt].protocol_id = pm.prot_master_id
   WITH nocounter
  ;end select
  SET stat = alterlist(protlist->protocols,cnt)
 ENDIF
 SET prot_cnt = size(protlist->protocols,5)
 SET stat = alterlist(results->protocols,prot_cnt)
 FOR (idx = 1 TO prot_cnt)
   SET prot_id = protlist->protocols[idx].protocol_id
   SET results->protocols[idx].prot_master_id = prot_id
   SET results->protocols[idx].activation_date = cnvtdatetime("31-DEC-2100 00:00:00.00")
   SET active_amd_dt_tm = 0
   SET trialwide_value_cd = 0.00
   SET def_org_value_cd = 0.00
   SET active_amd_id = 0.00
   SELECT INTO "nl:"
    pm.primary_mnemonic, pm.prot_master_id, pa.parent_amendment_id
    FROM prot_master pm,
     prot_amendment pa,
     ct_prot_type_config cfg
    PLAN (pm
     WHERE pm.prot_master_id=prot_id)
     JOIN (pa
     WHERE pa.prot_master_id=pm.prot_master_id
      AND pa.amendment_dt_tm <= cnvtdatetime(sysdate))
     JOIN (cfg
     WHERE cfg.protocol_type_cd=pa.participation_type_cd
      AND (cfg.logical_domain_id=domain_reply->logical_domain_id)
      AND cfg.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND ((cfg.item_cd=trialwide_cd) OR (cfg.item_cd=def_org_cd)) )
    HEAD pm.prot_master_id
     results->protocols[idx].prot_mnemonic = pm.primary_mnemonic, results->protocols[idx].
     prot_status_cd = pm.prot_status_cd, results->protocols[idx].prot_status_disp =
     uar_get_code_display(pm.prot_status_cd)
    DETAIL
     IF ((pa.amendment_dt_tm < results->protocols[idx].activation_date))
      results->protocols[idx].activation_date = pa.amendment_dt_tm
     ENDIF
     IF (pa.amendment_dt_tm > active_amd_dt_tm)
      active_amd_dt_tm = pa.amendment_dt_tm, active_amd_id = pa.prot_amendment_id, results->
      protocols[idx].trialwide_targeted = pa.groupwide_targeted_accrual,
      results->protocols[idx].site_targeted = pa.targeted_accrual, accrual_required_indc_cd = pa
      .accrual_required_indc_cd, duration_cd = pa.anticipated_prot_dur_uom_cd,
      duration_value = pa.anticipated_prot_dur_value
     ENDIF
     IF (pm.collab_site_org_id > 0)
      results->protocols[idx].collab_site_ind = 1, results->protocols[idx].parent_prot_master_id = pm
      .parent_prot_master_id
     ENDIF
     IF (cfg.item_cd=trialwide_cd)
      trialwide_value_cd = cfg.config_value_cd
     ENDIF
     IF (cfg.item_cd=def_org_cd)
      def_org_value_cd = cfg.config_value_cd
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    pa.parent_amendment_id
    FROM prot_grant_sponsor pgs,
     organization org
    PLAN (pgs
     WHERE pgs.prot_amendment_id=active_amd_id)
     JOIN (org
     WHERE org.organization_id=pgs.organization_id
      AND pgs.primary_secondary_cd=org_prim_cd)
    DETAIL
     results->protocols[idx].primary_sponsor = org.org_name
    WITH nocounter
   ;end select
   SET proj_duration = 0
   SET days_from_act = 0
   SET accrual_request->prot_master_id = results->protocols[idx].prot_master_id
   SET accrual_request->prot_amendment_id = active_amd_id
   SET accrual_request->parent_prot_master_id = results->protocols[idx].parent_prot_master_id
   SET accrual_request->collab_site_ind = results->protocols[idx].collab_site_ind
   SET accrual_request->active_parent_amend_id = 0.0
   SET accrual_request->requiredaccrualcd = 0.0
   SET accrual_request->person_id = 0.0
   SET accrual_request->participation_type_cd = 0.0
   SET stat = initrec(accrual_reply)
   EXECUTE ct_get_prot_accrual_numbers  WITH replace("REPLY","ACCRUAL_REPLY"), replace("REQUEST",
    "ACCRUAL_REQUEST")
   IF (uar_get_code_meaning(accrual_required_indc_cd)="NO")
    SET results->protocols[idx].site_cur_accrual = accrual_reply->prot_accrual
    SET results->protocols[idx].site_percent = m_s_blank_percent
    SET results->protocols[idx].site_prj_accrual = - (1)
    SET results->protocols[idx].site_targeted = - (1)
    SET results->protocols[idx].trialwide_cur_accrual = - (1)
    SET results->protocols[idx].trialwide_percent = m_s_blank_percent
    SET results->protocols[idx].trialwide_prj_accrual = - (1)
    SET results->protocols[idx].trialwide_targeted = - (1)
   ELSE
    SET results->protocols[idx].site_cur_accrual = accrual_reply->prot_accrual
    SET results->protocols[idx].trialwide_cur_accrual = accrual_reply->group_accrual
    IF (uar_get_code_meaning(def_org_value_cd)="NO")
     SET results->protocols[idx].trialwide_targeted = - (1)
    ELSE
     SET results->protocols[idx].trialwide_targeted = accrual_reply->group_target_accrual
    ENDIF
    SET tempstr = uar_get_code_meaning(duration_cd)
    IF (tempstr="MONTH")
     SET tmp_duration = concat(cnvtstring(duration_value),",M")
     SET proj_duration = datetimecmp(cnvtlookahead(tmp_duration,active_amd_dt_tm),active_amd_dt_tm)
    ELSEIF (tempstr="YEAR")
     SET tmp_duration = concat(cnvtstring(duration_value),",Y")
     SET proj_duration = datetimecmp(cnvtlookahead(tmp_duration,active_amd_dt_tm),active_amd_dt_tm)
    ELSEIF (tempstr="DAY")
     SET proj_duration = duration_value
    ELSE
     SET results->protocols[idx].trialwide_prj_accrual = - (1)
     SET results->protocols[idx].site_prj_accrual = - (1)
    ENDIF
    IF ((results->protocols[idx].trialwide_targeted <= 0))
     SET results->protocols[idx].trialwide_percent = m_s_blank_percent
     SET results->protocols[idx].trialwide_prj_accrual = - (1)
     SET results->protocols[idx].site_prj_accrual = - (1)
    ELSE
     SET tempval = 0.0
     SET tempacc = 0.0
     SET temptarg = 0.0
     SET tempacc = results->protocols[idx].trialwide_cur_accrual
     SET temptarg = results->protocols[idx].trialwide_targeted
     SET tempval = ((tempacc/ temptarg) * 100.0)
     SET tempstr = format(tempval,"####.#")
     SET results->protocols[idx].trialwide_percent = concat(tempstr,"%")
     IF ((results->protocols[idx].collab_site_ind=1))
      SET days_from_act = datetimediff(cnvtdatetime(sysdate),accrual_reply->active_parent_amend_dt_tm,
       1)
     ELSE
      SET days_from_act = datetimediff(cnvtdatetime(sysdate),active_amd_dt_tm,1)
     ENDIF
     IF ((accrual_reply->group_accrual > 0))
      SET tempval = accrual_reply->group_target_accrual
      SET tempacc = proj_duration
      SET temptarg = days_from_act
      SET results->protocols[idx].trialwide_prj_accrual = ((tempval/ tempacc) * temptarg)
      IF ((results->protocols[idx].trialwide_prj_accrual > accrual_reply->group_target_accrual))
       SET results->protocols[idx].trialwide_prj_accrual = accrual_reply->group_target_accrual
      ENDIF
      SET tempval = results->protocols[idx].site_targeted
      SET tempacc = proj_duration
      SET temptarg = days_from_act
      SET results->protocols[idx].site_prj_accrual = ((tempval/ tempacc) * temptarg)
      IF ((results->protocols[idx].site_prj_accrual > results->protocols[idx].site_targeted))
       SET results->protocols[idx].site_prj_accrual = results->protocols[idx].site_targeted
      ENDIF
     ENDIF
    ENDIF
    IF ((results->protocols[idx].site_targeted <= 0))
     SET results->protocols[idx].site_percent = m_s_blank_percent
    ELSE
     SET tempval = 0.0
     SET tempacc = 0.0
     SET temptarg = 0.0
     SET tempacc = results->protocols[idx].site_cur_accrual
     SET temptarg = results->protocols[idx].site_targeted
     SET tempval = ((tempacc/ temptarg) * 100.0)
     SET tempstr = format(tempval,"####.#")
     SET results->protocols[idx].site_percent = concat(tempstr,"%")
    ENDIF
    IF (uar_get_code_meaning(trialwide_value_cd)="YES"
     AND (accrual_reply->bfound=1))
     SET results->protocols[idx].trialwide_cur_accrual = accrual_reply->group_accrual
    ELSE
     SET results->protocols[idx].trialwide_cur_accrual = - (1)
    ENDIF
   ENDIF
 ENDFOR
 IF (( $ACCRUAL=0))
  SET report_labels->report_title = report_labels->m_s_trial_wide_title
 ELSEIF (( $ACCRUAL=1))
  SET report_labels->report_title = report_labels->m_s_site_title
 ELSE
  SET report_labels->report_title = report_labels->m_s_trial_and_site_title
 ENDIF
 IF (( $ORDERBY=1))
  SET report_labels->sorting_field = "results->protocols[d.seq].activation_date"
  SET report_labels->sorted_by = report_labels->m_s_order_by_date
 ELSEIF (( $ORDERBY=2))
  SET report_labels->sorting_field = "CNVTLOWER(results->protocols[d.seq].prot_status_disp)"
  SET report_labels->sorted_by = report_labels->m_s_order_by_status
 ELSEIF (( $ORDERBY=3))
  SET report_labels->sorting_field = "CNVTLOWER(results->protocols[d.seq].primary_sponsor)"
  SET report_labels->sorted_by = report_labels->m_s_order_by_sponsor
 ELSE
  SET report_labels->sorting_field = "CNVTLOWER(results->protocols[d.seq].prot_mnemonic)"
  SET report_labels->sorted_by = report_labels->m_s_order_by_prot
 ENDIF
 SET cnt = 0
 SET last_mod = "007"
 SET mod_date = "Nov 25, 2019"
END GO
