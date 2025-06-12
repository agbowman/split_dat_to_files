CREATE PROGRAM ct_rpt_milestone_comp:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Protocols" = 0,
  "Protocol Status" = 0,
  "Milestone Activity" = 0.000000,
  "Committee" = 0,
  "Organization" = 0,
  "Role" = 0.000000,
  "Start Date (Optional)" = curdate,
  "End Date (Optional)" = curdate,
  "Output type" = 0,
  "Delimiter" = ","
  WITH outdev, protocols, protstatus,
  activity, committee, org,
  role, startdate, enddate,
  out_type, delimiter
 RECORD qual_list(
   1 last_activity_ind = i2
   1 entity_type_flag = i2
   1 all_protocols_ind = i2
   1 protocol_cnt = i4
   1 protocols[*]
     2 prot_master_id = f8
   1 all_statuses_ind = i2
   1 status_cnt = i4
   1 statuses[*]
     2 status_cd = f8
   1 activity_cd = f8
   1 responsible_party = vc
   1 committee_id = f8
   1 organization_id = f8
   1 role_cd = f8
   1 start_date = dq8
   1 end_date = dq8
 )
 RECORD results(
   1 messages[*]
     2 text = vc
   1 protocols[*]
     2 prot_master_id = f8
     2 primary_mnemonic = c30
     2 init_activation_date = dq8
     2 amendments[*]
       3 prot_amendment_id = f8
       3 amendment_nbr = i4
       3 revision_nbr_txt = vc
       3 revision_ind = i2
       3 revision_seq = i2
       3 amd_status_cd = f8
       3 activity_cd = f8
       3 sequence_nbr = i4
       3 entity_type_flag = i2
       3 responsible_party = c100
       3 completed_dt_tm = dq8
 )
 RECORD report_labels(
   1 m_s_end_before_start = vc
   1 m_s_start_date_must = vc
   1 m_s_end_date_must = vc
   1 m_s_at_least_one_c_o_r = vc
   1 m_s_only_one = vc
   1 m_s_at_least_one_status = vc
   1 m_s_at_least_one_prot = vc
   1 m_s_activity = vc
   1 m_s_prot_by_last_comp = vc
   1 m_s_prot_by_activity = vc
   1 m_s_between = vc
   1 m_s_rep_exec_time = vc
   1 m_s_prot_mnemonic_header = vc
   1 m_s_amendment = vc
   1 m_s_amd_status_header = vc
   1 m_s_activity_header = vc
   1 m_s_completed_date_header = vc
   1 m_s_total_prots = vc
   1 m_s_end_of_rpt = vc
   1 m_s_revision = vc
   1 m_s_init_prot = vc
   1 m_s_unable_to_exec = vc
   1 m_s_no_prots = vc
   1 m_s_seperator = vc
   1 m_s_page = vc
   1 execution_timestamp = vc
   1 report_title = vc
   1 activity_title = vc
   1 date_title = vc
   1 delimiter_output = vc
   1 output_type = i4
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
 SET report_labels->m_s_end_before_start = uar_i18ngetmessage(i18nhandle,"END_BEFORE_START",
  "The end date cannot be before the start date.")
 SET report_labels->m_s_start_date_must = uar_i18ngetmessage(i18nhandle,"START_DATE_MUST",
  "A start date must be entered if an end date is specified.")
 SET report_labels->m_s_end_date_must = uar_i18ngetmessage(i18nhandle,"START_DATE_MUST",
  "An end date must be entered if a start date is specified.")
 SET report_labels->m_s_at_least_one_c_o_r = uar_i18ngetmessage(i18nhandle,"AT_LEAST_ONE_C_O_R",
  "At least one committee, organization or role must be selected.")
 SET report_labels->m_s_only_one = uar_i18ngetmessage(i18nhandle,"ONLY_ONE",
  "Only one committee, organization or role can be selected at a time.")
 SET report_labels->m_s_at_least_one_status = uar_i18ngetmessage(i18nhandle,"AT_LEAST_ONE_STATUS",
  "At least one status must be selected.")
 SET report_labels->m_s_at_least_one_prot = uar_i18ngetmessage(i18nhandle,"AT_LEAST_ONE_PROT",
  "At least one protocol must be selected.")
 SET report_labels->m_s_activity = uar_i18ngetmessage(i18nhandle,"ACTIVITY","Activity:")
 SET report_labels->m_s_prot_by_last_comp = uar_i18ngetmessage(i18nhandle,"PROT_BY_LAST_COMP",
  "Protocols by Last Completed Activity Report")
 SET report_labels->m_s_prot_by_activity = uar_i18ngetmessage(i18nhandle,"PROT_BY_ACTIVITY",
  "Protocols by Specific Activity Report")
 SET report_labels->m_s_between = uar_i18ngetmessage(i18nhandle,"BETWEEN","Between:")
 SET report_labels->m_s_rep_exec_time = uar_i18ngetmessage(i18nhandle,"REP_EXEC_TIME",
  "Report execution time:")
 SET report_labels->m_s_prot_mnemonic_header = uar_i18ngetmessage(i18nhandle,"PROT_MNEMONIC",
  "Protocol Mnemonic")
 SET report_labels->m_s_amendment = uar_i18ngetmessage(i18nhandle,"AMENDMENT","Amendment")
 SET report_labels->m_s_amd_status_header = uar_i18ngetmessage(i18nhandle,"AMD_STATUS",
  "Amendment Status")
 SET report_labels->m_s_activity_header = uar_i18ngetmessage(i18nhandle,"ACTIVITY","Activity")
 SET report_labels->m_s_completed_date_header = uar_i18ngetmessage(i18nhandle,"COMPLETED_DATE",
  "Completed Date")
 SET report_labels->m_s_total_prots = uar_i18ngetmessage(i18nhandle,"TOTAL_PROTS","Total Protocols:")
 SET report_labels->m_s_end_of_rpt = uar_i18ngetmessage(i18nhandle,"END_OF_RPT",
  "*** End of Report ***")
 SET report_labels->m_s_revision = uar_i18ngetmessage(i18nhandle,"REVISION","Revision")
 SET report_labels->m_s_init_prot = uar_i18ngetmessage(i18nhandle,"INIT_PROT","Initial Protocol")
 SET report_labels->m_s_unable_to_exec = uar_i18ngetmessage(i18nhandle,"UNABLE_TO_EXEC",
  "Unable to execute report, the following issues were encountered:")
 SET report_labels->m_s_no_prots = uar_i18ngetmessage(i18nhandle,"NO_PROTS",
  "There were no protocols with the selected milestone activity information.")
 SET report_labels->m_s_seperator = uar_i18ngetmessage(i18nhandle,"SEPERATOR","-")
 SET report_labels->m_s_page = uar_i18ngetmessage(i18nhandle,"PAGE","Page:")
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE title1 = vc WITH protect, noconstant("")
 DECLARE title2 = vc WITH protect, noconstant("")
 DECLARE title3 = vc WITH protect, noconstant("")
 DECLARE title4 = vc WITH protect, noconstant("")
 DECLARE tempstr = vc WITH protect, noconstant("")
 DECLARE tmp_prot = vc WITH protect, noconstant("")
 DECLARE tmp_status = vc WITH protect, noconstant("")
 DECLARE tmp_activity = vc WITH protect, noconstant("")
 DECLARE tmp_act_date = vc WITH protect, noconstant("")
 DECLARE tmp_amd_desc = vc WITH protect, noconstant("")
 DECLARE p_amendment_status_disp = vc WITH protect, noconstant("")
 DECLARE p_prot_role_disp = vc WITH protect, noconstant("")
 DECLARE p_activity_disp = vc WITH protect, noconstant("")
 DECLARE prim_mnemonic = vc WITH protect, noconstant("")
 DECLARE amd_nbr = i4 WITH protect, noconstant(0)
 DECLARE rev_seq = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE num = i2 WITH protect, noconstant(0)
 DECLARE numstat = i2 WITH protect, noconstant(0)
 DECLARE offset = i4 WITH protect, noconstant(0)
 DECLARE amd_id = f8 WITH protect, noconstant(0.0)
 DECLARE prot_id = f8 WITH protect, noconstant(0.0)
 DECLARE parmidx = i4 WITH protect, noconstant(0)
 DECLARE added_flag = i2 WITH protect, noconstant(0)
 DECLARE add_record = i2 WITH protect, noconstant(0)
 DECLARE tmp_record = i2 WITH protect, noconstant(0)
 DECLARE last_performed_dt_tm = dq8 WITH protect
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE prot_cnt = i4 WITH protect, noconstant(0)
 DECLARE amd_cnt = i4 WITH protect, noconstant(0)
 DECLARE activated_cd = f8 WITH protect, noconstant(0.0)
 DECLARE superseded_cd = f8 WITH protect, noconstant(0.0)
 DECLARE exec_timestamp = vc WITH protect, noconstant("")
 DECLARE nstart = i2 WITH protect, noconstant(0)
 DECLARE batch_size = i2 WITH protect, noconstant(0)
 DECLARE loop_cnt = i2 WITH protect, noconstant(0)
 DECLARE cur_list_size = i2 WITH protect, noconstant(0)
 DECLARE new_list_size = i2 WITH protect, noconstant(0)
 DECLARE rpt_title_i18n = vc WITH protect, noconstant("")
 DECLARE activity_i18n = vc WITH protect, noconstant("")
 DECLARE between_date_i18n = vc WITH protect, noconstant("")
 DECLARE exec_timestamp_i18n = vc WITH protect, noconstant("")
 SET report_labels->execution_timestamp = concat(report_labels->m_s_rep_exec_time," ",format(
   cnvtdatetime(sysdate),"@SHORTDATETIME"))
 SET report_labels->output_type =  $OUT_TYPE
 SET report_labels->delimiter_output =  $DELIMITER
 SET qual_list->all_protocols_ind = 0
 SET parmidx = 2
 IF (reflect(parameter(parmidx,0))="C1")
  SET cnt = 0
  SET qual_list->all_protocols_ind = 1
 ELSEIF (substring(1,1,reflect(parameter(parmidx,0)))="L")
  SET cnt = 1
  WHILE (reflect(parameter(parmidx,cnt)) > " ")
    IF (mod(cnt,10)=1)
     SET stat = alterlist(qual_list->protocols,(cnt+ 9))
    ENDIF
    SET qual_list->protocols[cnt].prot_master_id = cnvtreal(parameter(parmidx,cnt))
    SET cnt += 1
  ENDWHILE
  SET cnt -= 1
  SET qual_list->protocol_cnt = cnt
  SET stat = alterlist(qual_list->protocols,cnt)
 ELSEIF (reflect(parameter(parmidx,0))="F8")
  SET stat = alterlist(qual_list->protocols,1)
  SET qual_list->protocols[1].prot_master_id = cnvtreal(parameter(parmidx,1))
  SET qual_list->protocol_cnt = 1
 ELSE
  CALL addmessage(report_labels->m_s_at_least_one_prot)
 ENDIF
 SET qual_list->all_statuses_ind = 0
 SET parmidx = 3
 IF (reflect(parameter(parmidx,0))="C1")
  SET qual_list->all_statuses_ind = 1
 ELSEIF (substring(1,1,reflect(parameter(parmidx,0)))="L")
  SET cnt = 1
  WHILE (reflect(parameter(parmidx,cnt)) > " ")
    IF (mod(cnt,10)=1)
     SET stat = alterlist(qual_list->statuses,(cnt+ 9))
    ENDIF
    SET qual_list->statuses[cnt].status_cd = cnvtreal(parameter(parmidx,cnt))
    SET cnt += 1
  ENDWHILE
  SET cnt -= 1
  SET qual_list->status_cnt = cnt
  SET stat = alterlist(qual_list->statuses,cnt)
 ELSEIF (reflect(parameter(parmidx,0))="F8")
  SET stat = alterlist(qual_list->statuses,1)
  SET qual_list->statuses[1].status_cd = cnvtreal(parameter(parmidx,1))
  SET qual_list->status_cnt = 1
 ELSE
  CALL addmessage(report_labels->m_s_at_least_one_status)
 ENDIF
 SET qual_list->activity_cd = cnvtreal( $ACTIVITY)
 SET cnt = 0
 SET qual_list->committee_id = cnvtreal( $COMMITTEE)
 IF ((qual_list->committee_id > 0.0))
  SELECT INTO "nl:"
   FROM committee com
   WHERE (com.committee_id=qual_list->committee_id)
   DETAIL
    qual_list->responsible_party = com.committee_name
   WITH nocounter
  ;end select
  SET cnt += 1
  SET qual_list->entity_type_flag = 2
 ENDIF
 SET qual_list->organization_id = cnvtreal( $ORG)
 IF ((qual_list->organization_id > 0.0))
  SELECT INTO "nl:"
   FROM organization org
   WHERE (org.organization_id=qual_list->organization_id)
   DETAIL
    qual_list->responsible_party = org.org_name
   WITH nocounter
  ;end select
  SET qual_list->entity_type_flag = 1
  SET cnt += 1
 ENDIF
 SET qual_list->role_cd = cnvtreal( $ROLE)
 IF ((qual_list->role_cd > 0.0))
  SET qual_list->responsible_party = uar_get_code_display(qual_list->role_cd)
  SET qual_list->entity_type_flag = 0
  SET cnt += 1
 ENDIF
 IF (cnt > 1)
  CALL addmessage(report_labels->m_s_only_one)
 ENDIF
 IF (cnt=0
  AND (qual_list->activity_cd > 0))
  CALL addmessage(report_labels->m_s_at_least_one_c_o_r)
 ELSEIF (cnt=0
  AND (qual_list->activity_cd=0))
  SET qual_list->last_activity_ind = 1
 ENDIF
 SET qual_list->start_date = cnvtdatetime(cnvtdate( $STARTDATE),0)
 SET qual_list->end_date = cnvtdatetime(cnvtdate( $ENDDATE),2359)
 IF ((qual_list->start_date=0)
  AND (qual_list->end_date=0))
  SET report_labels->date_title = ""
 ELSEIF ((qual_list->start_date=0)
  AND (qual_list->end_date > 0))
  CALL addmessage(report_labels->m_s_start_date_must)
 ELSEIF ((qual_list->start_date > 0)
  AND (qual_list->end_date=0))
  CALL addmessage(report_labels->m_s_end_date_must)
 ELSE
  IF ((qual_list->start_date > qual_list->end_date))
   CALL addmessage(report_labels->m_s_end_before_start)
  ELSE
   SET report_labels->date_title = concat(report_labels->m_s_between," ",trim(format(cnvtdatetime(
       qual_list->start_date),"@LONGDATE;t(3);q"),3)," - ",trim(format(cnvtdatetime(qual_list->
       end_date),"@LONGDATE;t(3);q"),3))
  ENDIF
 ENDIF
 IF ((qual_list->last_activity_ind=1))
  SET report_labels->report_title = report_labels->m_s_prot_by_last_comp
  SET report_labels->activity_title = " "
 ELSE
  SET report_labels->report_title = report_labels->m_s_prot_by_activity
  IF ((qual_list->activity_cd > 0)
   AND (qual_list->responsible_party != ""))
   SET report_labels->activity_title = concat(report_labels->m_s_activity," ",trim(
     uar_get_code_display(qual_list->activity_cd))," ",trim(qual_list->responsible_party))
  ENDIF
 ENDIF
 IF (size(results->messages,5)=0)
  SET cnt = 0
  SET cur_list_size = size(qual_list->protocols,5)
  SET batch_size = 10
  SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
  SET new_list_size = (loop_cnt * batch_size)
  SET stat = alterlist(qual_list->protocols,new_list_size)
  SET nstart = 1
  FOR (idx = (cur_list_size+ 1) TO new_list_size)
    SET qual_list->protocols[idx].prot_master_id = qual_list->protocols[cur_list_size].prot_master_id
  ENDFOR
  SELECT INTO "nl:"
   pm.primary_mnemonic, pm.prot_master_id, pa.amendment_nbr,
   pa.revision_seq, pa.revision_nbr_txt, cm.ct_milestones_id,
   cm.activity_cd, cm.performed_dt_tm, cm.prot_role_cd
   FROM (dummyt d1  WITH seq = value(loop_cnt)),
    prot_master pm,
    prot_amendment pa,
    ct_milestones cm,
    organization resp_org,
    committee com
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (pm
    WHERE (((qual_list->all_protocols_ind=1)) OR (expand(num,nstart,(nstart+ (batch_size - 1)),pm
     .prot_master_id,qual_list->protocols[num].prot_master_id)))
     AND (((qual_list->all_statuses_ind=1)) OR (expand(numstat,1,qual_list->status_cnt,pm
     .prot_status_cd,qual_list->statuses[numstat].status_cd)))
     AND pm.prot_master_id > 0
     AND pm.end_effective_dt_tm > cnvtdatetime(sysdate)
     AND (pm.logical_domain_id=domain_reply->logical_domain_id))
    JOIN (pa
    WHERE pa.prot_master_id=pm.prot_master_id)
    JOIN (cm
    WHERE cm.prot_amendment_id=pa.prot_amendment_id
     AND (((cm.activity_cd=qual_list->activity_cd)) OR ((qual_list->activity_cd=0)))
     AND (((cm.entity_type_flag=qual_list->entity_type_flag)) OR ((qual_list->last_activity_ind=1)))
     AND ((cm.performed_dt_tm >= cnvtdatetime(qual_list->start_date)
     AND cm.performed_dt_tm <= cnvtdatetime(qual_list->end_date)) OR ((((qual_list->start_date=0))
     OR ((qual_list->end_date=0))) )) )
    JOIN (com
    WHERE (com.committee_id= Outerjoin(cm.committee_id)) )
    JOIN (resp_org
    WHERE (resp_org.organization_id= Outerjoin(cm.organization_id)) )
   ORDER BY cnvtlower(pm.primary_mnemonic), cm.performed_dt_tm DESC, pa.amendment_nbr,
    pa.revision_seq
   HEAD REPORT
    cnt = 0
   HEAD pm.prot_master_id
    amd_cnt = 0, cnt += 1
    IF (mod(cnt,10)=1)
     stat = alterlist(results->protocols,(cnt+ 9))
    ENDIF
    results->protocols[cnt].prot_master_id = pm.prot_master_id, results->protocols[cnt].
    primary_mnemonic = pm.primary_mnemonic, last_performed_dt_tm = 0
   DETAIL
    add_record = 0
    IF ((qual_list->last_activity_ind=1))
     CALL echo("TEST")
     IF (cm.performed_dt_tm >= last_performed_dt_tm
      AND cm.performed_dt_tm <= cnvtdatetime(curdate,curtime))
      last_performed_dt_tm = cm.performed_dt_tm, add_record = 1
     ENDIF
    ELSE
     IF ((qual_list->committee_id > 0))
      IF ((cm.committee_id=qual_list->committee_id))
       add_record = 1
      ENDIF
     ELSEIF ((qual_list->organization_id > 0))
      IF ((cm.organization_id=qual_list->organization_id))
       add_record = 1
      ENDIF
     ELSEIF ((qual_list->role_cd > 0))
      IF ((cm.prot_role_cd=qual_list->role_cd))
       add_record = 1
      ENDIF
     ELSE
      add_record = 0
     ENDIF
    ENDIF
    IF (add_record=1)
     amd_cnt += 1
     IF (mod(amd_cnt,10)=1)
      stat = alterlist(results->protocols[cnt].amendments,(amd_cnt+ 9))
     ENDIF
     results->protocols[cnt].amendments[amd_cnt].prot_amendment_id = pa.prot_amendment_id, results->
     protocols[cnt].amendments[amd_cnt].amendment_nbr = pa.amendment_nbr, results->protocols[cnt].
     amendments[amd_cnt].revision_ind = pa.revision_ind,
     results->protocols[cnt].amendments[amd_cnt].revision_seq = pa.revision_seq, results->protocols[
     cnt].amendments[amd_cnt].revision_nbr_txt = pa.revision_nbr_txt, results->protocols[cnt].
     amendments[amd_cnt].amd_status_cd = pa.amendment_status_cd,
     results->protocols[cnt].amendments[amd_cnt].activity_cd = cm.activity_cd, results->protocols[cnt
     ].amendments[amd_cnt].completed_dt_tm = cm.performed_dt_tm, results->protocols[cnt].amendments[
     amd_cnt].entity_type_flag = cm.entity_type_flag
     IF (cm.entity_type_flag=0)
      results->protocols[cnt].amendments[amd_cnt].responsible_party = uar_get_code_display(cm
       .prot_role_cd)
     ELSEIF (cm.entity_type_flag=1)
      results->protocols[cnt].amendments[amd_cnt].responsible_party = resp_org.org_name
     ELSEIF (cm.entity_type_flag=2)
      results->protocols[cnt].amendments[amd_cnt].responsible_party = com.committee_name
     ENDIF
     added_flag = 1
    ENDIF
   FOOT  pm.prot_master_id
    IF (added_flag=0)
     stat = alterlist(results->protocols[cnt].amendments,0), cnt -= 1
    ELSE
     stat = alterlist(results->protocols[cnt].amendments,amd_cnt)
    ENDIF
   FOOT REPORT
    stat = alterlist(results->protocols,cnt)
   WITH nocounter
  ;end select
 ENDIF
 SUBROUTINE addmessage(smsg)
   SET msg_cnt = (size(results->messages,5)+ 1)
   SET stat = alterlist(results->messages,msg_cnt)
   SET results->messages[msg_cnt].text = smsg
 END ;Subroutine
 SET last_mod = "004"
 SET mod_date = "Mar 10, 2017"
END GO
