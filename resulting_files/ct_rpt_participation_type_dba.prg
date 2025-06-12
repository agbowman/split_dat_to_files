CREATE PROGRAM ct_rpt_participation_type:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Participation Type" = 0,
  "Protocol Status" = 0,
  "Detail Level" = 1,
  "Order By" = 0,
  "Output type" = 0,
  "Delimiter" = ","
  WITH outdev, particpation_type, prot_status,
  detaillevel, orderby, out_type,
  delimiter
 RECORD qual_list(
   1 all_participation_types_ind = i2
   1 participation_type_cnt = i4
   1 participation_types[*]
     2 participation_type_cd = f8
   1 all_statuses_ind = i2
   1 status_cnt = i4
   1 statuses[*]
     2 status_cd = f8
 )
 RECORD countlist(
   1 participation_types[*]
     2 participation_type_cd = f8
     2 participation_type_cnt = i4
 )
 RECORD results(
   1 messages[*]
     2 text = vc
   1 protocols[*]
     2 prot_master_id = f8
     2 primary_mnemonic = c30
     2 parent_prot_master_id = f8
     2 collab_site_ind = i2
     2 init_activation_date = dq8
     2 cur_amd_id = f8
     2 cur_amd_act_date = dq8
     2 cur_amd_nbr = i4
     2 cur_revision_nbr_txt = vc
     2 cur_revision_ind = i2
     2 prot_status_cd = f8
     2 prot_status_disp = c40
     2 primary_sponsor = c100
     2 participation_type_cd = f8
     2 participation_type_disp = c40
     2 cur_accrual = i4
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
 RECORD reportlist(
   1 orderby = vc
 )
 RECORD label(
   1 rpt_title = vc
   1 rpt_title_order_by = vc
   1 rep_exec_time = vc
   1 part_type_header = vc
   1 prot_mnemonic_header = vc
   1 init_act_header = vc
   1 status_header = vc
   1 cur_amd_header = vc
   1 amd_act_date_header = vc
   1 cur_acc_header = vc
   1 sponsor_header = vc
   1 total_prot = vc
   1 total_prot_for = vc
   1 total_prot_unassign = vc
   1 total_prot_for_colon = vc
   1 end_of_rpt = vc
   1 no_prot_found = vc
   1 unable_to_exec = vc
   1 amendment = vc
   1 init_prot = vc
   1 revision = vc
   1 at_least_one_part = vc
   1 at_least_one_prot = vc
   1 report_page = vc
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
 DECLARE m_s_order_by_act_date = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ORDER_BY_ACT_DATE",
   "Ordered by initial activation date"))
 DECLARE m_s_order_by_prot = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ORDER_BY_PROT",
   "Ordered by protocol"))
 DECLARE m_s_order_by_sponsor = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ORDER_BY_SPONSOR",
   "Ordered by sponsor"))
 DECLARE m_s_order_by_status = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ORDER_BY_STATUS",
   "Ordered by status"))
 DECLARE m_s_order_by_participation = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "ORDER_BY_PARTICIPATION","Ordered by participation type"))
 SET label->rpt_title = uar_i18ngetmessage(i18nhandle,"PROT_BY_PART_TYPE",
  "Protocols by Participation Type")
 SET label->rep_exec_time = uar_i18ngetmessage(i18nhandle,"REP_EXEC_TIME","Report execution time:")
 SET label->part_type_header = uar_i18ngetmessage(i18nhandle,"PART_TYPE","Participation Type")
 SET label->prot_mnemonic_header = uar_i18ngetmessage(i18nhandle,"PROT_MNEMONIC","Protocol Mnemonic")
 SET label->init_act_header = uar_i18ngetmessage(i18nhandle,"INIT_ACT_DATE","Initial Activation Date"
  )
 SET label->status_header = uar_i18ngetmessage(i18nhandle,"STATUS","Status")
 SET label->cur_amd_header = uar_i18ngetmessage(i18nhandle,"CUR_AMD","Current Amendment")
 SET label->amd_act_date_header = uar_i18ngetmessage(i18nhandle,"AMD_ACT_DATE",
  "Amendment Activation Date")
 SET label->cur_acc_header = uar_i18ngetmessage(i18nhandle,"CUR_ACCRUAL","Current Accrual")
 SET label->sponsor_header = uar_i18ngetmessage(i18nhandle,"SPONSOR","Sponsor")
 SET label->total_prot = uar_i18ngetmessage(i18nhandle,"TOTAL_PROT","Total Protocols:")
 SET label->total_prot_for = uar_i18ngetmessage(i18nhandle,"TOTAL_PROT_FOR","Total Protocols for")
 SET label->total_prot_unassign = uar_i18ngetmessage(i18nhandle,"TOTAL_PROT_UNASSIGN",
  "Total Protocols for Unassigned:")
 SET label->total_prot_for_colon = uar_i18ngetmessage(i18nhandle,"TOTAL_PROT_FOR_COLON",":")
 SET label->end_of_rpt = uar_i18ngetmessage(i18nhandle,"END_OF_RPT","*** End of Report ***")
 SET label->no_prot_found = uar_i18ngetmessage(i18nhandle,"NO_PROT_FOUND",
  "There were no protocols found with the selected information.")
 SET label->unable_to_exec = uar_i18ngetmessage(i18nhandle,"UNABLE_TO_EXEC",
  "Unable to execute report, the following issues were encountered:")
 SET label->amendment = uar_i18ngetmessage(i18nhandle,"AMENDMENT","Amendment")
 SET label->init_prot = uar_i18ngetmessage(i18nhandle,"INIT_PROT","Initial Protocol")
 SET label->revision = uar_i18ngetmessage(i18nhandle,"REVISION","Revision")
 SET label->at_least_one_part = uar_i18ngetmessage(i18nhandle,"AT_LEAST_ONE_PART",
  "At least one participation type must be selected.")
 SET label->at_least_one_prot = uar_i18ngetmessage(i18nhandle,"AT_LEAST_ONE_PROT",
  "At least one protocol status must be selected.")
 SET label->report_page = uar_i18ngetmessage(i18nhandle,"RPT_PAGE","Page:")
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE msg_cnt = i4 WITH protect, noconstant(0)
 DECLARE tempstr = vc WITH protect, noconstant("")
 DECLARE tmp_part_type = vc WITH protect, noconstant("")
 DECLARE tmp_prot = vc WITH protect, noconstant("")
 DECLARE tmp_init_act_date = vc WITH protect, noconstant("")
 DECLARE tmp_status = vc WITH protect, noconstant("")
 DECLARE tmp_amd_desc = vc WITH protect, noconstant("")
 DECLARE tmp_amd_date = vc WITH protect, noconstant("")
 DECLARE tmp_cur_acc = vc WITH protect, noconstant("")
 DECLARE tmp_sponsor = vc WITH protect, noconstant("")
 DECLARE offset = i4 WITH protect, noconstant(0)
 DECLARE num = i2 WITH protect, noconstant(0)
 DECLARE parmidx = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE prot_id = f8 WITH protect, noconstant(0.0)
 DECLARE par_pos = i4 WITH protect, noconstant(0)
 DECLARE prot_cnt = i4 WITH protect, noconstant(0)
 DECLARE participation_type_cnt = i4 WITH protect, noconstant(0)
 DECLARE org_prim_cd = f8 WITH protect, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(17271,"PRIMARY",1,org_prim_cd)
 SET label->rep_exec_time = concat(label->rep_exec_time," ",format(cnvtdatetime(sysdate),
   "@SHORTDATETIME"))
 SET qual_list->all_participation_types_ind = 0
 SET parmidx = 2
 IF (reflect(parameter(parmidx,0))="C1")
  SET qual_list->all_participation_types_ind = 1
 ELSEIF (substring(1,1,reflect(parameter(parmidx,0)))="L")
  SET cnt = 1
  WHILE (reflect(parameter(parmidx,cnt)) > " ")
    IF (mod(cnt,10)=1)
     SET stat = alterlist(qual_list->participation_types,(cnt+ 9))
    ENDIF
    SET qual_list->participation_types[cnt].participation_type_cd = cnvtreal(parameter(parmidx,cnt))
    SET cnt += 1
  ENDWHILE
  SET cnt -= 1
  SET qual_list->participation_type_cnt = cnt
  SET stat = alterlist(qual_list->participation_types,cnt)
 ELSEIF (reflect(parameter(parmidx,0))="F8")
  SET stat = alterlist(qual_list->participation_types,1)
  SET qual_list->participation_types[1].participation_type_cd = cnvtreal(parameter(parmidx,1))
  SET qual_list->participation_type_cnt = 1
 ELSE
  CALL addmessage(label->at_least_one_part)
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
  CALL addmessage(label->at_least_one_prot)
 ENDIF
 IF (( $ORDERBY=1))
  SET orderby = "results->protocols[d.seq].init_activation_date"
  SET label->rpt_title_order_by = m_s_order_by_act_date
 ELSEIF (( $ORDERBY=2))
  SET orderby = "CNVTLOWER(substring(1, 25, TRIM(results->protocols[d.seq].prot_status_disp)))"
  SET label->rpt_title_order_by = m_s_order_by_status
 ELSEIF (( $ORDERBY=3))
  SET orderby = "CNVTLOWER(substring(1, 25, TRIM(results->protocols[d.seq].primary_sponsor)))"
  SET label->rpt_title_order_by = m_s_order_by_sponsor
 ELSEIF (( $ORDERBY=4))
  SET orderby =
  "CNVTLOWER(substring(1, 20, TRIM(results->protocols[d.seq].participation_type_disp)))"
  SET label->rpt_title_order_by = m_s_order_by_participation
 ELSE
  SET orderby = "CNVTLOWER(substring(1, 20, results->protocols[d.seq].primary_mnemonic))"
  SET label->rpt_title_order_by = m_s_order_by_prot
 ENDIF
 SET reportlist->orderby = orderby
 IF (size(results->messages,5)=0)
  SET cnt = 0
  SELECT INTO "nl:"
   pm.prot_master_id
   FROM prot_master pm,
    prot_amendment pa,
    prot_grant_sponsor pgs,
    organization org
   PLAN (pa
    WHERE pa.prot_master_id > 0.0
     AND (((qual_list->all_participation_types_ind=1)) OR (expand(num,1,qual_list->
     participation_type_cnt,pa.participation_type_cd,qual_list->participation_types[num].
     participation_type_cd))) )
    JOIN (pm
    WHERE pm.prot_master_id=pa.prot_master_id
     AND (((qual_list->all_statuses_ind=1)) OR (expand(num,1,qual_list->status_cnt,pm.prot_status_cd,
     qual_list->statuses[num].status_cd)))
     AND pm.end_effective_dt_tm > cnvtdatetime(sysdate)
     AND (pm.logical_domain_id=domain_reply->logical_domain_id))
    JOIN (pgs
    WHERE (pgs.prot_amendment_id= Outerjoin(pa.prot_amendment_id)) )
    JOIN (org
    WHERE (org.organization_id= Outerjoin(pgs.organization_id))
     AND (pgs.primary_secondary_cd= Outerjoin(org_prim_cd)) )
   ORDER BY cnvtlower(pm.primary_mnemonic), pa.amendment_dt_tm, pa.amendment_nbr DESC,
    pa.revision_seq DESC
   HEAD pm.prot_master_id
    cnt += 1
    IF (mod(cnt,10)=1)
     stat = alterlist(results->protocols,(cnt+ 9))
    ENDIF
    results->protocols[cnt].prot_master_id = pm.prot_master_id, results->protocols[cnt].
    primary_mnemonic = pm.primary_mnemonic, results->protocols[cnt].prot_status_cd = pm
    .prot_status_cd,
    results->protocols[cnt].prot_status_disp = uar_get_code_display(pm.prot_status_cd), results->
    protocols[cnt].init_activation_date = cnvtdatetime("31-DEC-2100 00:00:00"), results->protocols[
    cnt].cur_amd_act_date = 0
   DETAIL
    IF ((results->protocols[cnt].init_activation_date > pa.amendment_dt_tm)
     AND pa.amendment_dt_tm > 0)
     results->protocols[cnt].init_activation_date = pa.amendment_dt_tm
    ENDIF
    IF ((((pa.amendment_dt_tm > results->protocols[cnt].cur_amd_act_date)
     AND pa.amendment_dt_tm < cnvtdatetime("31-DEC-2100 00:00:00")) OR ((results->protocols[cnt].
    cur_amd_id=0))) )
     results->protocols[cnt].cur_amd_act_date = pa.amendment_dt_tm, results->protocols[cnt].
     cur_amd_nbr = pa.amendment_nbr, results->protocols[cnt].cur_revision_nbr_txt = pa
     .revision_nbr_txt,
     results->protocols[cnt].cur_revision_ind = pa.revision_ind, results->protocols[cnt].
     primary_sponsor = org.org_name, results->protocols[cnt].participation_type_cd = pa
     .participation_type_cd,
     results->protocols[cnt].participation_type_disp = uar_get_code_display(pa.participation_type_cd),
     results->protocols[cnt].cur_amd_id = pa.prot_amendment_id
    ENDIF
    IF (pm.collab_site_org_id > 0)
     results->protocols[cnt].collab_site_ind = 1, results->protocols[cnt].parent_prot_master_id = pm
     .parent_prot_master_id
    ENDIF
   WITH nocounter
  ;end select
  SET stat = alterlist(results->protocols,cnt)
  FOR (idx = 1 TO cnt)
    IF ((results->protocols[idx].cur_amd_act_date > 0)
     AND (results->protocols[idx].cur_amd_act_date < cnvtdatetime("31-DEC-2100 00:00:00")))
     SET stat = initrec(accrual_request)
     SET accrual_request->prot_master_id = results->protocols[idx].prot_master_id
     SET accrual_request->prot_amendment_id = results->protocols[idx].cur_amd_id
     SET accrual_request->parent_prot_master_id = results->protocols[idx].parent_prot_master_id
     SET stat = initrec(accrual_reply)
     EXECUTE ct_get_prot_accrual_numbers  WITH replace("REPLY","ACCRUAL_REPLY"), replace("REQUEST",
      "ACCRUAL_REQUEST")
     IF ((accrual_reply->bfound=true))
      SET results->protocols[idx].cur_accrual = accrual_reply->group_accrual
     ELSE
      SET results->protocols[idx].cur_accrual = accrual_reply->prot_accrual
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 SUBROUTINE addmessage(smsg)
   SET msg_cnt = (size(results->messages,5)+ 1)
   SET stat = alterlist(results->messages,msg_cnt)
   SET results->messages[msg_cnt].text = smsg
 END ;Subroutine
 SET last_mod = "005"
 SET mod_date = "APR 04, 2016"
 SET last_mod = "006"
 SET mod_date = "Nov 26, 2019"
END GO
