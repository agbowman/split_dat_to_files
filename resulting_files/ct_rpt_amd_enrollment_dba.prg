CREATE PROGRAM ct_rpt_amd_enrollment:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Protocols" = 0,
  "Order By" = 0,
  "Output type" = 0,
  "Delimiter" = ","
  WITH outdev, protocols, orderby,
  out_type, delimiter
 RECORD protlist(
   1 protocols[*]
     2 protocol_id = f8
   1 accrual_numbers = i2
   1 order_by = i2
 )
 RECORD results(
   1 messages[*]
     2 text = vc
   1 protocols[*]
     2 prot_master_id = f8
     2 primary_mnemonic = vc
     2 cur_amd_id = f8
     2 parent_prot_master_id = f8
     2 init_activation_date = dq8
     2 cur_accrual = i4
     2 amendments[*]
       3 prot_amendment_id = f8
       3 amenmdent_status_cd = f8
       3 amendment_nbr = i4
       3 revision_ind = i2
       3 revision_nbr_txt = vc
       3 amd_accural = i4
 )
 RECORD report_labels(
   1 m_s_rpt_title = vc
   1 m_s_rep_exec_time = vc
   1 m_s_prot_mnemonic_header = vc
   1 m_s_init_act_date_header = vc
   1 m_s_cur_accrual_header = vc
   1 m_s_amd_accrual_header = vc
   1 m_s_amd_rev_header = vc
   1 m_s_amd_status_header = vc
   1 m_s_total_prots = vc
   1 m_s_end_of_rpt = vc
   1 m_s_init_prot = vc
   1 m_s_amendment = vc
   1 m_s_revision = vc
   1 m_s_unable_to_exec = vc
   1 m_s_no_prot_found = vc
   1 m_s_one_prot = vc
   1 m_s_order_by_date = vc
   1 m_s_order_by_prot = vc
   1 m_s_seperator = vc
   1 m_s_page = vc
   1 sorting_field = vc
   1 output_type = i2
   1 delimiter_output = vc
   1 execution_timestamp = vc
   1 sorted_by = vc
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
 FREE RECORD request
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
 DECLARE i18nhandle = i4 WITH public, noconstant(0)
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET report_labels->m_s_rpt_title = uar_i18ngetmessage(i18nhandle,"AMD_LVL_ENROLL_RPT",
  "Amendment Level Enrollment Report")
 SET report_labels->m_s_rep_exec_time = uar_i18ngetmessage(i18nhandle,"REP_EXEC_TIME",
  "Report execution time:")
 SET report_labels->m_s_prot_mnemonic_header = uar_i18ngetmessage(i18nhandle,"PROT_MNEMONIC",
  "Protocol Mnemonic")
 SET report_labels->m_s_init_act_date_header = uar_i18ngetmessage(i18nhandle,"INIT_ACT_DATE",
  "Initial Activation Date")
 SET report_labels->m_s_cur_accrual_header = uar_i18ngetmessage(i18nhandle,"CUR_ACCRUAL",
  "Current Accrual")
 SET report_labels->m_s_amd_accrual_header = uar_i18ngetmessage(i18nhandle,"AMD_ACCRUAL",
  "Amendment Accrual")
 SET report_labels->m_s_amd_rev_header = uar_i18ngetmessage(i18nhandle,"AMD_REV","Amendment/Revision"
  )
 SET report_labels->m_s_amd_status_header = uar_i18ngetmessage(i18nhandle,"AMD_STATUS",
  "Amendment Status")
 SET report_labels->m_s_total_prots = uar_i18ngetmessage(i18nhandle,"TOTAL_PROTS","Total Protocols:")
 SET report_labels->m_s_end_of_rpt = uar_i18ngetmessage(i18nhandle,"END_OF_RPT",
  "*** End of Report ***")
 SET report_labels->m_s_init_prot = uar_i18ngetmessage(i18nhandle,"INIT_PROT","Initial Protocol")
 SET report_labels->m_s_amendment = uar_i18ngetmessage(i18nhandle,"AMENDMENT","Amendment")
 SET report_labels->m_s_revision = uar_i18ngetmessage(i18nhandle,"REVISION","Revision")
 SET report_labels->m_s_unable_to_exec = uar_i18ngetmessage(i18nhandle,"UNABLE_TO_EXEC",
  "Unable to execute report, the following issues were encountered:")
 SET report_labels->m_s_no_prot_found = uar_i18ngetmessage(i18nhandle,"NO_PROT_FOUND",
  "There were no protocols found that met the selected search criteria.")
 SET report_labels->m_s_one_prot = uar_i18ngetmessage(i18nhandle,"ONE_PROT",
  "At least one protocol must be selected.")
 SET report_labels->m_s_order_by_date = uar_i18ngetmessage(i18nhandle,"ORDER_BY_DATE",
  "Ordered by activation date")
 SET report_labels->m_s_order_by_prot = uar_i18ngetmessage(i18nhandle,"ORDER_BY_PROT",
  "Ordered by protocol")
 SET report_labels->m_s_seperator = uar_i18ngetmessage(i18nhandle,"SEPERATOR","-")
 SET report_labels->m_s_page = uar_i18ngetmessage(i18nhandle,"PAGE","Page:")
 SET report_labels->delimiter_output =  $DELIMITER
 SET report_labels->output_type =  $OUT_TYPE
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE tempstr = vc WITH protect, noconstant("")
 DECLARE tmp_prot = vc WITH protect, noconstant("")
 DECLARE tmp_act_date = vc WITH protect, noconstant("")
 DECLARE tmp_amd_acc = vc WITH protect, noconstant("")
 DECLARE tmp_cur_acc = vc WITH protect, noconstant("")
 DECLARE tmp_amd = vc WITH protect, noconstant("")
 DECLARE tmp_status = vc WITH protect, noconstant("")
 DECLARE temp_row = i4 WITH protect, noconstant(0)
 DECLARE orderby = vc WITH protect, noconstant("")
 DECLARE exec_timestamp = vc WITH protect, noconstant("")
 DECLARE prot_cnt = i2 WITH protect, noconstant(0)
 DECLARE amd_cnt = i2 WITH protect, noconstant(0)
 DECLARE cnt = i2 WITH protect, noconstant(0)
 DECLARE idx = i2 WITH protect, noconstant(0)
 DECLARE aidx = i2 WITH protect, noconstant(0)
 DECLARE prot_id = f8 WITH protect, noconstant(0.0)
 DECLARE num = i2 WITH protect, noconstant(0)
 DECLARE offset = i2 WITH protect, noconstant(0)
 DECLARE enrolling_cd = f8 WITH protect, noconstant(0.0)
 DECLARE nstart = i2 WITH protect, noconstant(0)
 DECLARE batch_size = i2 WITH protect, noconstant(0)
 DECLARE loop_cnt = i2 WITH protect, noconstant(0)
 DECLARE cur_list_size = i2 WITH protect, noconstant(0)
 DECLARE new_list_size = i2 WITH protect, noconstant(0)
 DECLARE getprotenrolls(prot_id=f8) = null
 SET stat = uar_get_meaning_by_codeset(17900,"ENROLLING",1,enrolling_cd)
 SET report_labels->execution_timestamp = concat(report_labels->m_s_rep_exec_time," ",format(
   cnvtdatetime(sysdate),"@SHORTDATETIME"))
 IF (substring(1,1,reflect(parameter(2,0)))="L")
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
  SET stat = alterlist(protlist->protocols,1)
  SET protlist->protocols[1].protocol_id = cnvtreal(parameter(2,1))
 ELSE
  CALL addmessage(report_labels->m_s_one_prot)
 ENDIF
 IF (size(results->messages,5)=0)
  SET cnt = 0
  SET cur_list_size = size(protlist->protocols,5)
  SET batch_size = 10
  SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
  SET new_list_size = (loop_cnt * batch_size)
  SET stat = alterlist(protlist->protocols,new_list_size)
  SET nstart = 1
  FOR (idx = (cur_list_size+ 1) TO new_list_size)
    SET protlist->protocols[idx].protocol_id = protlist->protocols[cur_list_size].protocol_id
  ENDFOR
  SELECT INTO "nl:"
   pm.primary_mnemonic, pm.prot_master_id, pa.parent_amendment_id
   FROM (dummyt d1  WITH seq = value(loop_cnt)),
    prot_master pm,
    prot_amendment pa
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (pm
    WHERE expand(num,nstart,(nstart+ (batch_size - 1)),pm.prot_master_id,protlist->protocols[num].
     protocol_id)
     AND pm.prot_master_id > 0
     AND pm.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (pa
    WHERE pa.prot_master_id=pm.prot_master_id
     AND pa.amendment_dt_tm <= cnvtdatetime(sysdate))
   ORDER BY pm.prot_master_id, pa.amendment_nbr, pa.revision_seq
   HEAD pm.prot_master_id
    amd_cnt = 0, cnt += 1
    IF (mod(cnt,10)=1)
     stat = alterlist(results->protocols,(cnt+ 9))
    ENDIF
    results->protocols[cnt].prot_master_id = pm.prot_master_id, results->protocols[cnt].
    primary_mnemonic = pm.primary_mnemonic
    IF (pm.collab_site_org_id > 0)
     results->protocols[cnt].parent_prot_master_id = pm.parent_prot_master_id
    ENDIF
    results->protocols[cnt].init_activation_date = cnvtdatetime("31-DEC-2100 00:00:00.00")
   DETAIL
    amd_cnt += 1
    IF (mod(amd_cnt,10)=1)
     stat = alterlist(results->protocols[cnt].amendments,(amd_cnt+ 9))
    ENDIF
    IF ((pa.amendment_dt_tm < results->protocols[cnt].init_activation_date))
     results->protocols[cnt].init_activation_date = pa.amendment_dt_tm
    ENDIF
    IF (pa.amendment_status_cd=pm.prot_status_cd)
     results->protocols[cnt].cur_amd_id = pa.prot_amendment_id
    ENDIF
    results->protocols[cnt].amendments[amd_cnt].prot_amendment_id = pa.prot_amendment_id, results->
    protocols[cnt].amendments[amd_cnt].amenmdent_status_cd = pa.amendment_status_cd, results->
    protocols[cnt].amendments[amd_cnt].amendment_nbr = pa.amendment_nbr,
    results->protocols[cnt].amendments[amd_cnt].revision_ind = pa.revision_ind, results->protocols[
    cnt].amendments[amd_cnt].revision_nbr_txt = pa.revision_nbr_txt
   FOOT  pm.prot_master_id
    stat = alterlist(results->protocols[cnt].amendments,amd_cnt)
   WITH nocounter
  ;end select
  SET stat = alterlist(results->protocols,cnt)
  SET prot_cnt = size(results->protocols,5)
  FOR (cnt = 1 TO prot_cnt)
    SET amd_cnt = size(results->protocols[cnt].amendments,5)
    CALL getprotenrollments(cnt)
    FOR (aidx = 1 TO amd_cnt)
     SELECT DISTINCT
      p.pt_elig_tracking_id
      FROM pt_consent pco,
       pt_elig_consent_reltn pec,
       pt_elig_tracking p,
       prot_questionnaire pq,
       prot_amendment pa
      PLAN (pa
       WHERE (pa.prot_amendment_id=results->protocols[cnt].amendments[aidx].prot_amendment_id))
       JOIN (pq
       WHERE pq.prot_amendment_id=pa.prot_amendment_id
        AND pq.questionnaire_type_cd=enrolling_cd)
       JOIN (p
       WHERE p.prot_questionnaire_id=pq.prot_questionnaire_id)
       JOIN (pec
       WHERE pec.pt_elig_tracking_id=p.pt_elig_tracking_id
        AND pec.active_ind=1)
       JOIN (pco
       WHERE pco.consent_id=pec.consent_id
        AND pco.not_returned_reason_cd=0
        AND pco.end_effective_dt_tm > cnvtdatetime(sysdate)
        AND pco.consent_signed_dt_tm > cnvtdatetime(sysdate))
      DETAIL
       IF (p.pt_elig_tracking_id > 0.0)
        results->protocols[cnt].amendments[aidx].amd_accural += 1
       ENDIF
      WITH nocounter
     ;end select
     SELECT DISTINCT INTO "nl:"
      pc.consent_id
      FROM pt_consent pc,
       pt_elig_consent_reltn pecr
      PLAN (pc
       WHERE (pc.prot_amendment_id=results->protocols[cnt].amendments[aidx].prot_amendment_id)
        AND pc.not_returned_reason_cd=0
        AND pc.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00")
        AND pc.consent_signed_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00"))
       JOIN (pecr
       WHERE (pecr.consent_id= Outerjoin(pc.consent_id)) )
      HEAD pc.pt_consent_id
       IF (pecr.pt_elig_consent_reltn_id=0)
        results->protocols[cnt].amendments[aidx].amd_accural += 1
       ENDIF
      WITH nocounter
     ;end select
    ENDFOR
    IF ((results->protocols[cnt].cur_amd_id > 0))
     SET stat = initrec(accrual_request)
     SET accrual_request->prot_master_id = results->protocols[cnt].prot_master_id
     SET accrual_request->prot_amendment_id = results->protocols[cnt].cur_amd_id
     SET accrual_request->parent_prot_master_id = results->protocols[cnt].parent_prot_master_id
     SET stat = initrec(accrual_reply)
     EXECUTE ct_get_prot_accrual_numbers  WITH replace("REPLY","ACCRUAL_REPLY"), replace("REQUEST",
      "ACCRUAL_REQUEST")
     IF ((accrual_reply->collab_ind=0)
      AND (accrual_reply->is_parent=0))
      SET results->protocols[cnt].cur_accrual = accrual_reply->group_accrual
     ELSE
      SET results->protocols[cnt].cur_accrual = accrual_reply->prot_accrual
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 IF (( $ORDERBY=1))
  SET report_labels->sorting_field = "results->protocols[d.seq].init_activation_date"
  SET report_labels->sorted_by = report_labels->m_s_order_by_date
 ELSE
  SET report_labels->sorting_field = "CNVTLOWER(results->protocols[d.seq].primary_mnemonic)"
  SET report_labels->sorted_by = report_labels->m_s_order_by_prot
 ENDIF
 SUBROUTINE (getprotenrollments(prot_idx=i4) =null)
   RECORD request(
     1 patientid = f8
     1 protocolid = f8
     1 ptqualifier = i2
     1 protocols[*]
       2 protocolid = f8
     1 orgsecurity = i2
   )
   FREE RECORD pt_reply
   RECORD pt_reply(
     1 curdate = dq8
     1 tara = i4
     1 groupwidetara = i4
     1 prot_status_cd = f8
     1 prot_status_disp = vc
     1 prot_status_desc = vc
     1 prot_status_mean = c12
     1 as[*]
       2 amendstatus_cd = f8
       2 amendstatus_disp = vc
       2 amendstatus_desc = vc
       2 amendstatus_mean = c12
       2 datebegactive = dq8
       2 dateendactive = dq8
       2 datebegsusp = dq8
       2 nbr = i4
       2 id = f8
       2 revisionnbrtxt = c30
       2 revisionind = i2
     1 activeamendid = f8
     1 activeamendnbr = f8
     1 activedttm = dq8
     1 activerevisionind = i2
     1 activerevisionnbrtxt = c30
     1 highestamendid = f8
     1 highestamendnbr = f8
     1 registry_only_ind = i2
     1 enrolls[*]
       2 prot_master_id = f8
       2 prot_status_cd = f8
       2 prot_status_disp = vc
       2 prot_status_desc = vc
       2 prot_status_mean = c12
       2 prot_type_cd = f8
       2 prot_type_disp = vc
       2 prot_type_desc = vc
       2 prot_type_mean = c12
       2 cur_dateamendassignstart = dq8
       2 cur_dateamendassignend = dq8
       2 cur_protamendid = f8
       2 cur_amendmentnbr = i4
       2 cur_revisionnbrtxt = c30
       2 cur_revisionind = i2
       2 first_dateamendassignstart = dq8
       2 first_dateamendassignend = dq8
       2 first_protamendid = f8
       2 elig_protamendid = f8
       2 ptprotregid = f8
       2 regid = f8
       2 eligid = f8
       2 protalias = vc
       2 nomenclatureid = f8
       2 removalorgid = f8
       2 removalorgname = vc
       2 removalperid = f8
       2 removalpername = vc
       2 protaccessionnbr = vc
       2 dateonstudy = dq8
       2 dateoffstudy = dq8
       2 dateontherapy = dq8
       2 dateofftherapy = dq8
       2 datefirstpdfail = dq8
       2 firstdisrelevent_cd = f8
       2 firstdisrelevent_disp = vc
       2 firstdisrelevent_desc = vc
       2 firstdisrelevent_mean = c12
       2 enrollingorgid = f8
       2 enrollingorgname = vc
       2 protarmid = f8
       2 diagtype_cd = f8
       2 diagtype_disp = vc
       2 diagtype_desc = vc
       2 diagtype_mean = c12
       2 bestresp_cd = f8
       2 bestresp_disp = vc
       2 bestresp_desc = vc
       2 bestresp_mean = c12
       2 datefirstpd = dq8
       2 datefirstcr = dq8
       2 regupdtcnt = i4
       2 personid = f8
       2 lastname = vc
       2 firstname = vc
       2 namefullformatted = vc
       2 stratumlabel = vc
       2 stratumid = f8
       2 follow_up_status_cd = f8
       2 follow_up_status_disp = vc
       2 txremovalorgid = f8
       2 txremovalorgname = vc
       2 txremovalperid = f8
       2 txremovalpername = vc
       2 txremovalreason_cd = f8
       2 txremovalreason_disp = vc
       2 txremovalreason_desc = vc
       2 txremovalreason_mean = c12
       2 txremovalreason = c255
       2 removalreason_cd = f8
       2 removalreason_disp = vc
       2 removalreason_desc = vc
       2 removalreason_mean = c12
       2 removalreason = c255
       2 episode_id = f8
       2 cohort_label = c30
       2 cohort_id = f8
       2 txorgid = f8
       2 txorgname = vc
       2 txperid = f8
       2 txpername = vc
       2 txcomment = vc
       2 statusenum = i4
       2 mrns[*]
         3 mrn = vc
         3 orgid = f8
         3 orgname = vc
         3 alias_pool_cd = f8
         3 alias_pool_disp = vc
         3 alias_pool_desc = vc
         3 alias_pool_mean = c12
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
     1 debug[*]
       2 str = vc
   )
   DECLARE pt_cnt = i4 WITH protect
   DECLARE idx = i4 WITH protect
   DECLARE pamd_idx = i4 WITH protect
   SET stat = initrec(pt_reply)
   SET request->protocolid = results->protocols[prot_idx].prot_master_id
   SET request->ptqualifier = 0
   SET request->orgsecurity = 0
   SET request->patientid = 0.0
   EXECUTE ct_get_pt_enrollments  WITH replace("REPLY","PT_REPLY")
   IF ((pt_reply->status_data.status="S"))
    SET pt_cnt = size(pt_reply->enrolls,5)
    FOR (idx = 1 TO pt_cnt)
      SET pamd_idx = locateval(num,1,pt_cnt,pt_reply->enrolls[idx].cur_protamendid,results->
       protocols[prot_idx].amendments[num].prot_amendment_id)
      CALL echo(build("pamd_idx = ",pamd_idx))
      IF (pamd_idx > 0)
       SET results->protocols[cnt].amendments[pamd_idx].amd_accural = (results->protocols[prot_idx].
       amendments[pamd_idx].amd_accural+ 1)
      ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE addmessage(smsg)
   SET msg_cnt = (size(results->messages,5)+ 1)
   SET stat = alterlist(results->messages,msg_cnt)
   SET results->messages[msg_cnt].text = smsg
 END ;Subroutine
 SET last_mod = "007"
 SET mod_date = "March 02, 2023"
END GO
