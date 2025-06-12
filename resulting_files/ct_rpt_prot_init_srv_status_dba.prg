CREATE PROGRAM ct_rpt_prot_init_srv_status:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Initiating Service/Department" = value(0.000000),
  "Protocol Status" = value(0.000000),
  "Order By" = 1,
  "Level of detail" = 0,
  "Output type" = 0,
  "Delimiter" = ","
  WITH outdev, initiatingservices, status,
  orderby, detaillevel, out_type,
  delimiter
 RECORD reportlist(
   1 all_init_services = i2
   1 init_service_cnt = i2
   1 init_services[*]
     2 init_service_cd = f8
   1 all_statuses = i2
   1 status_cnt = i2
   1 statuses[*]
     2 status_cd = f8
   1 order_by = vc
 )
 RECORD statuslist(
   1 statuses[*]
     2 prot_status_cd = f8
 )
 RECORD init_servicelist(
   1 init_services[*]
     2 init_service_cd = f8
 )
 RECORD results(
   1 protocols[*]
     2 prot_master_id = f8
     2 parent_prot_master_id = f8
     2 collab_site_ind = i2
     2 prot_mnemonic = vc
     2 init_service_cd = f8
     2 init_service_disp = c40
     2 init_service_desc = c60
     2 init_service_mean = c12
     2 init_activation_date = dq8
     2 amd_description = c40
     2 amd_nbr = i4
     2 active_amd_id = f8
     2 revision_nbr_txt = c60
     2 revision_ind = i2
     2 amd_activation_date = dq8
     2 prot_status_cd = f8
     2 prot_status_disp = c40
     2 prot_status_desc = c60
     2 prot_status_mean = c12
     2 cur_accrual = i4
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
 RECORD label(
   1 rpt_title = vc
   1 rpt_sorted_title = vc
   1 rpt_serv_stat_title = vc
   1 rep_exec_time = vc
   1 prot_mnemonic_header = vc
   1 init_act_header = vc
   1 init_serv_header = vc
   1 status_header = vc
   1 cur_amd_header = vc
   1 amd_act_date_header = vc
   1 cur_acc_header = vc
   1 sponsor_header = vc
   1 total_prot = vc
   1 total_init_serv = vc
   1 total_statuses = vc
   1 end_of_rpt = vc
   1 criteria_not_met = vc
   1 amendment = vc
   1 init_prot = vc
   1 revision = vc
   1 rpt_page = vc
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
 DECLARE m_s_sorted_by_act_date = vc WITH constant(uar_i18ngetmessage(i18nhandle,"SORTED_BY_ACT_DATE",
   "Sorted by activation date"))
 DECLARE m_s_sorted_by_prot = vc WITH constant(uar_i18ngetmessage(i18nhandle,"SORTED_BY_PROT",
   "Sorted by protocol"))
 DECLARE m_s_sorted_by_sponsor = vc WITH constant(uar_i18ngetmessage(i18nhandle,"SORTED_BY_SPONSOR",
   "Sorted by sponsor"))
 DECLARE m_s_sorted_by_status = vc WITH constant(uar_i18ngetmessage(i18nhandle,"SORTED_BY_STATUS",
   "Sorted by status"))
 DECLARE m_s_sorted_by_init_serv = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "SORTED_BY_INIT_SERV","Sorted by initiating service"))
 DECLARE m_s_all_serv_stat = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ALL_SERV_STAT",
   "All initiating services and all statuses"))
 DECLARE m_s_all_serv = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ALL_SERV",
   "All Initiating services"))
 DECLARE m_s_all_stat = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ALL_STAT","All Statuses"))
 SET label->rpt_title = uar_i18ngetmessage(i18nhandle,"PROT_INIT_SER_STAT_RPT",
  "Protocol Initiating Service and Status Report")
 SET label->rep_exec_time = uar_i18ngetmessage(i18nhandle,"REP_EXEC_TIME","Report execution time:")
 SET label->prot_mnemonic_header = uar_i18ngetmessage(i18nhandle,"PROT_MNEMONIC","Protocol Mnemonic")
 SET label->init_act_header = uar_i18ngetmessage(i18nhandle,"INIT_ACT_DATE","Initial Activation Date"
  )
 SET label->init_serv_header = uar_i18ngetmessage(i18nhandle,"INIT_SERV","Initiating Service")
 SET label->status_header = uar_i18ngetmessage(i18nhandle,"STATUS","Status")
 SET label->cur_amd_header = uar_i18ngetmessage(i18nhandle,"CUR_AMD","Current Amendment")
 SET label->amd_act_date_header = uar_i18ngetmessage(i18nhandle,"AMD_ACT_DATE",
  "Amendment Activation Date")
 SET label->cur_acc_header = uar_i18ngetmessage(i18nhandle,"CUR_ACCRUAL","Current Accrual")
 SET label->sponsor_header = uar_i18ngetmessage(i18nhandle,"SPONSOR","Sponsor")
 SET label->total_prot = uar_i18ngetmessage(i18nhandle,"TOTAL_PROT","Total Protocols Selected:")
 SET label->total_init_serv = uar_i18ngetmessage(i18nhandle,"TOTAL_INIT_SERV",
  "Total Initiating Services:")
 SET label->total_statuses = uar_i18ngetmessage(i18nhandle,"TOTAL_STATUSES","Total Statuses:")
 SET label->end_of_rpt = uar_i18ngetmessage(i18nhandle,"END_OF_RPT","*** End of Report ***")
 SET label->criteria_not_met = uar_i18ngetmessage(i18nhandle,"CRITERIA_NOT_MET",
  "There were no protocols found that met the selected search criteria.")
 SET label->amendment = uar_i18ngetmessage(i18nhandle,"AMENDMENT","Amendment")
 SET label->init_prot = uar_i18ngetmessage(i18nhandle,"INIT_PROT","Initial Protocol")
 SET label->revision = uar_i18ngetmessage(i18nhandle,"REVISION","Revision")
 SET label->rpt_page = uar_i18ngetmessage(i18nhandle,"RPT_PAGE","Page:")
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE cnt = i4 WITH public, noconstant(0)
 DECLARE tempstr = vc WITH protect, noconstant("")
 DECLARE offset = i4 WITH protect, noconstant(0)
 DECLARE col_offset = i4 WITH protect, noconstant(0)
 DECLARE prot_mnemonic = vc WITH protect, noconstant("")
 DECLARE tmp_prot = vc WITH protect, noconstant("")
 DECLARE tmp_status = vc WITH protect, noconstant("")
 DECLARE tmp_sponsor = vc WITH protect, noconstant("")
 DECLARE tmp_amd_desc = vc WITH protect, noconstant("")
 DECLARE tmp_status = vc WITH protect, noconstant("")
 DECLARE tmp_init_srv = vc WITH protect, noconstant("")
 DECLARE tmp_act_date = vc WITH protect, noconstant("")
 DECLARE tmp_init_act_date = vc WITH protect, noconstant("")
 DECLARE tmp_cur_acc = vc WITH protect, noconstant("")
 DECLARE temp_row = i4 WITH protect, noconstant(0)
 DECLARE orderby = vc WITH protect, noconstant("")
 DECLARE exec_timestamp = vc WITH protect, noconstant("")
 DECLARE init_service_cnt = i4 WITH protect, noconstant(0)
 DECLARE status_cnt = i4 WITH protect, noconstant(0)
 DECLARE status_pos = i4 WITH protect, noconstant(0)
 DECLARE idx = i2 WITH protect, noconstant(0)
 DECLARE prot_id = f8 WITH protect, noconstant(0.0)
 DECLARE init_service_cd = f8 WITH protect, noconstant(0.0)
 DECLARE status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE num = i2 WITH protect, noconstant(0)
 DECLARE org_prim_cd = f8 WITH protect, noconstant(0.0)
 SET reportlist->all_init_services = 0
 SET reportlist->all_statuses = 0
 SET label->rep_exec_time = concat(label->rep_exec_time," ",format(cnvtdatetime(sysdate),
   "@SHORTDATETIME"))
 IF (reflect(parameter(2,0))="C1")
  SET stat = alterlist(reportlist->init_services,0)
  SET reportlist->all_init_services = 1
 ELSEIF (substring(1,1,reflect(parameter(2,0)))="L")
  SET cnt = 1
  WHILE (reflect(parameter(2,cnt)) > " ")
    IF (mod(cnt,10)=1)
     SET stat = alterlist(reportlist->init_services,(cnt+ 9))
    ENDIF
    SET reportlist->init_services[cnt].init_service_cd = cnvtreal(parameter(2,cnt))
    SET cnt += 1
  ENDWHILE
  SET reportlist->init_service_cnt = (cnt - 1)
  SET stat = alterlist(reportlist->init_services,reportlist->init_service_cnt)
 ELSEIF (reflect(parameter(2,0))="F8")
  SET reportlist->init_service_cnt = 1
  SET stat = alterlist(reportlist->init_services,1)
  SET reportlist->init_services[1].init_service_cd = cnvtreal(parameter(2,1))
 ENDIF
 SET reportlist->all_statuses = 0
 IF (reflect(parameter(3,0))="C1")
  SET stat = alterlist(reportlist->statuses,0)
  SET reportlist->all_statuses = 1
 ELSEIF (substring(1,1,reflect(parameter(3,0)))="L")
  SET cnt = 1
  WHILE (reflect(parameter(3,cnt)) > " ")
    IF (mod(cnt,10)=1)
     SET stat = alterlist(reportlist->statuses,(cnt+ 9))
    ENDIF
    SET reportlist->statuses[cnt].status_cd = cnvtreal(parameter(3,cnt))
    SET cnt += 1
  ENDWHILE
  SET reportlist->status_cnt = (cnt - 1)
  SET stat = alterlist(reportlist->statuses,reportlist->status_cnt)
 ELSEIF (reflect(parameter(3,0))="F8")
  SET reportlist->status_cnt = 1
  SET stat = alterlist(reportlist->statuses,reportlist->status_cnt)
  SET reportlist->statuses[1].status_cd = cnvtreal(parameter(3,1))
 ENDIF
 SET stat = uar_get_meaning_by_codeset(17271,"PRIMARY",1,org_prim_cd)
 SET cnt = 0
 SELECT INTO "nl:"
  pm.prot_master_id
  FROM prot_master pm,
   prot_amendment pa,
   prot_grant_sponsor pgs,
   organization org
  PLAN (pm
   WHERE pm.prot_master_id > 0.0
    AND (((reportlist->all_init_services=1)) OR (expand(num,1,reportlist->init_service_cnt,pm
    .initiating_service_cd,reportlist->init_services[num].init_service_cd)))
    AND (((reportlist->all_statuses=1)) OR (expand(num,1,reportlist->status_cnt,pm.prot_status_cd,
    reportlist->statuses[num].status_cd)))
    AND pm.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND (pm.logical_domain_id=domain_reply->logical_domain_id))
   JOIN (pa
   WHERE pa.prot_master_id=pm.prot_master_id)
   JOIN (pgs
   WHERE (pgs.prot_amendment_id= Outerjoin(pa.prot_amendment_id)) )
   JOIN (org
   WHERE (org.organization_id= Outerjoin(pgs.organization_id))
    AND (pgs.primary_secondary_cd= Outerjoin(org_prim_cd)) )
  ORDER BY pm.prot_master_id, pa.amendment_dt_tm DESC, pa.amendment_nbr DESC,
   pa.revision_seq DESC
  HEAD pm.prot_master_id
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(results->protocols,(cnt+ 9))
   ENDIF
   results->protocols[cnt].prot_master_id = pm.prot_master_id, results->protocols[cnt].prot_mnemonic
    = pm.primary_mnemonic, results->protocols[cnt].init_service_cd = pm.initiating_service_cd,
   results->protocols[cnt].prot_status_cd = pm.prot_status_cd, results->protocols[cnt].
   prot_status_disp = uar_get_code_display(pm.prot_status_cd), results->protocols[cnt].
   init_service_disp = uar_get_code_display(pm.initiating_service_cd),
   results->protocols[cnt].init_activation_date = cnvtdatetime("31-DEC-2100 00:00:00"), results->
   protocols[cnt].amd_activation_date = 0
  DETAIL
   IF ((results->protocols[cnt].init_activation_date > pa.amendment_dt_tm)
    AND pa.amendment_dt_tm > 0)
    results->protocols[cnt].init_activation_date = pa.amendment_dt_tm
   ENDIF
   IF ((pa.amendment_dt_tm > results->protocols[cnt].amd_activation_date)
    AND pa.amendment_dt_tm < cnvtdatetime("31-DEC-2100 00:00:00"))
    results->protocols[cnt].amd_activation_date = pa.amendment_dt_tm, results->protocols[cnt].amd_nbr
     = pa.amendment_nbr, results->protocols[cnt].revision_nbr_txt = pa.revision_nbr_txt,
    results->protocols[cnt].revision_ind = pa.revision_ind, results->protocols[cnt].primary_sponsor
     = org.org_name, results->protocols[cnt].active_amd_id = pa.prot_amendment_id
   ENDIF
   IF (pm.collab_site_org_id > 0)
    results->protocols[cnt].collab_site_ind = 1, results->protocols[cnt].parent_prot_master_id = pm
    .parent_prot_master_id
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(results->protocols,cnt)
 FOR (idx = 1 TO cnt)
   IF ((results->protocols[idx].amd_activation_date > 0)
    AND (results->protocols[idx].amd_activation_date < cnvtdatetime("31-DEC-2100 00:00:00")))
    SET stat = initrec(accrual_request)
    SET accrual_request->prot_master_id = results->protocols[idx].prot_master_id
    SET accrual_request->prot_amendment_id = results->protocols[idx].active_amd_id
    SET accrual_request->parent_prot_master_id = results->protocols[idx].parent_prot_master_id
    SET stat = initrec(accrual_reply)
    EXECUTE ct_get_prot_accrual_numbers  WITH replace("REPLY","ACCRUAL_REPLY"), replace("REQUEST",
     "ACCRUAL_REQUEST")
    SET results->protocols[idx].cur_accrual = accrual_reply->prot_accrual
   ENDIF
 ENDFOR
 IF ((reportlist->all_init_services=1)
  AND (reportlist->all_statuses=1))
  SET label->rpt_serv_stat_title = m_s_all_serv_stat
 ELSEIF ((reportlist->all_init_services=1))
  SET label->rpt_serv_stat_title = m_s_all_serv
 ELSEIF ((reportlist->all_statuses=1))
  SET label->rpt_serv_stat_title = m_s_all_stat
 ELSE
  SET label->rpt_serv_stat_title = ""
 ENDIF
 IF (( $ORDERBY=0))
  SET orderby = "results->protocols[d.seq].init_activation_date"
  SET label->rpt_sorted_title = m_s_sorted_by_act_date
 ELSEIF (( $ORDERBY=2))
  SET orderby = "CNVTLOWER(results->protocols[d.seq].prot_mnemonic)"
  SET label->rpt_sorted_title = m_s_sorted_by_prot
 ELSEIF (( $ORDERBY=3))
  SET orderby = "CNVTLOWER(results->protocols[d.seq].primary_sponsor)"
  SET label->rpt_sorted_title = m_s_sorted_by_sponsor
 ELSEIF (( $ORDERBY=4))
  SET orderby = "CNVTLOWER(results->protocols[d.seq].prot_status_disp)"
  SET label->rpt_sorted_title = m_s_sorted_by_status
 ELSE
  SET orderby = "CNVTLOWER(results->protocols[d.seq].init_service_disp)"
  SET label->rpt_sorted_title = m_s_sorted_by_init_serv
 ENDIF
 SET reportlist->order_by = orderby
 SET last_mod = "005"
 SET mod_date = "APR 04, 2016"
 SET last_mod = "006"
 SET mod_date = "Nov 26, 2019"
END GO
