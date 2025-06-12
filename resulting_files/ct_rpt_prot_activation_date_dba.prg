CREATE PROGRAM ct_rpt_prot_activation_date:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Activation Date Qualification" = 0,
  "Start Date" = curdate,
  "End Date" = curdate,
  "Order By" = 1,
  "Sort Order" = 0,
  "Output type" = 0,
  "Delimiter" = ","
  WITH outdev, datequal, startdate,
  enddate, orderby, sortorder,
  out_type, delimiter
 RECORD protlist(
   1 protocol_cnt = i2
   1 protocols[*]
     2 prot_master_id = f8
 )
 RECORD reportlist(
   1 date_qual = i2
   1 start_date = dq8
   1 end_date = dq8
   1 sort_by = vc
 )
 RECORD results(
   1 protocols[*]
     2 prot_master_id = f8
     2 primary_mnemonic = c30
     2 init_activation_date = dq8
     2 amd_activation_date = dq8
     2 cur_amd_id = f8
     2 cur_amd_nbr = i4
     2 cur_revision_nbr_txt = vc
     2 cur_revision_ind = i2
     2 prot_status_cd = f8
     2 prot_status_disp = c40
     2 prot_status_desc = c60
     2 prot_status_mean = c12
     2 primary_sponsor = c100
     2 amendments[*]
       3 prot_amendment_id = f8
       3 amd_activation_date = dq8
       3 amendment_nbr = i4
       3 revision_nbr_txt = vc
       3 revision_ind = i2
       3 revision_seq = i4
       3 amd_status_cd = f8
       3 amd_status_disp = c40
       3 amd_status_desc = c60
       3 amd_status_mean = c12
       3 primary_sponsor = c100
 )
 RECORD label(
   1 report_title = vc
   1 report_date_title = vc
   1 report_sort_title = vc
   1 init_act_header = vc
   1 prot_mnemonic_header = vc
   1 cur_prot_status_header = vc
   1 amendment = vc
   1 amd_act_date_header = vc
   1 amd_status_header = vc
   1 amd_sponsor_header = vc
   1 total_prots = vc
   1 total_new_prots = vc
   1 total_amds = vc
   1 total_revs = vc
   1 end_of_rpt = vc
   1 revision = vc
   1 end_before_start = vc
   1 no_prot = vc
   1 rep_exec_time = vc
   1 init_prot = vc
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
 DECLARE m_s_before_date = vc WITH constant(uar_i18ngetmessage(i18nhandle,"BETWEEN_DATE","Before:"))
 DECLARE m_s_after_date = vc WITH constant(uar_i18ngetmessage(i18nhandle,"AFTER_DATE","After:"))
 DECLARE m_s_between_date = vc WITH constant(uar_i18ngetmessage(i18nhandle,"BETWEEN_DATE","Between:")
  )
 DECLARE m_s_sorted_by_prot = vc WITH constant(uar_i18ngetmessage(i18nhandle,"SORTED_BY_PROT",
   "Sorted by protocol"))
 DECLARE m_s_sorted_by_init_date = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "SORTED_BY_INIT_DATE","Sorted by initial activation date"))
 DECLARE m_s_sorted_by_status = vc WITH constant(uar_i18ngetmessage(i18nhandle,"SORTED_BY_STATUS",
   "Sorted by protocol status"))
 DECLARE m_s_rep_exec_time = vc WITH constant(uar_i18ngetmessage(i18nhandle,"REP_EXEC_TIME",
   "Report execution time:"))
 SET label->report_title = uar_i18ngetmessage(i18nhandle,"PROT_ACT_DATE_RPT",
  "Protocol Activation Date Report")
 SET label->init_act_header = uar_i18ngetmessage(i18nhandle,"INIT_ACT_DATE","Initial Activation Date"
  )
 SET label->prot_mnemonic_header = uar_i18ngetmessage(i18nhandle,"PROT_MNEMONIC","Protocol Mnemonic")
 SET label->cur_prot_status_header = uar_i18ngetmessage(i18nhandle,"CUR_PROT_STATUS",
  "Current Protocol Status")
 SET label->amendment = uar_i18ngetmessage(i18nhandle,"AMENDMENT","Amendment")
 SET label->amd_act_date_header = uar_i18ngetmessage(i18nhandle,"AMD_ACT_DATE",
  "Amendment Activation Date")
 SET label->amd_status_header = uar_i18ngetmessage(i18nhandle,"AMD_STATUS","Amendment Status")
 SET label->amd_sponsor_header = uar_i18ngetmessage(i18nhandle,"AMD_SPONSOR","Amendment Sponsor")
 SET label->total_prots = uar_i18ngetmessage(i18nhandle,"TOTAL_PROTS","Total Protocols:")
 SET label->total_new_prots = uar_i18ngetmessage(i18nhandle,"TOTAL_NEW_PROTS","Total New Protocols:")
 SET label->total_amds = uar_i18ngetmessage(i18nhandle,"TOTAL_AMDS","Total Amendments:")
 SET label->total_revs = uar_i18ngetmessage(i18nhandle,"TOTAL_REVS","Total Revisions:")
 SET label->end_of_rpt = uar_i18ngetmessage(i18nhandle,"END_OF_RPT","*** End of Report ***")
 SET label->revision = uar_i18ngetmessage(i18nhandle,"REVISION","Revision")
 SET label->init_prot = uar_i18ngetmessage(i18nhandle,"INIT_PROT","Initial Protocol")
 SET label->no_prot = uar_i18ngetmessage(i18nhandle,"NO_PROT",
  "There were no protocols that met the criteria for the Protocol Activation Date Report.")
 SET label->rpt_page = uar_i18ngetmessage(i18nhandle,"RPT_PAGE","Page :")
 DECLARE sdebug = vc WITH protect, noconstant(" ")
 DECLARE error_msg = vc WITH protect, noconstant(" ")
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE tempstr = vc WITH protect, noconstant("")
 DECLARE offset = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE amd_cnt = i4 WITH protect, noconstant(0)
 DECLARE rev_cnt = i4 WITH protect, noconstant(0)
 DECLARE new_cnt = i4 WITH protect, noconstant(0)
 DECLARE prot_mnemonic = vc WITH protect, noconstant("")
 DECLARE prot_id = f8 WITH protect, noconstant(0.0)
 DECLARE tmp_init_act_date = vc WITH protect, noconstant("")
 DECLARE tmp_prot = vc WITH protect, noconstant("")
 DECLARE tmp_amd_desc = vc WITH protect, noconstant("")
 DECLARE tmp_act_date = vc WITH protect, noconstant("")
 DECLARE tmp_sponsor = vc WITH protect, noconstant("")
 DECLARE tmp_status = vc WITH protect, noconstant("")
 DECLARE tmp_prot_status = vc WITH protect, noconstant("")
 DECLARE temp_row = i4 WITH protect, noconstant(0)
 DECLARE orderby = vc WITH protect, noconstant("")
 DECLARE prot_cnt = i2 WITH protect, noconstant(0)
 DECLARE num = i2 WITH protect, noconstant(0)
 DECLARE date_qual = vc WITH protect, noconstant("")
 DECLARE sponsor_type_cd = f8 WITH protect, noconstant(0.0)
 SET label->rep_exec_time = concat(m_s_rep_exec_time," ",format(cnvtdatetime(sysdate),
   "@SHORTDATETIME"))
 SET date_qual = "1=1"
 IF (( $DATEQUAL=0))
  SET reportlist->start_date = cnvtdatetime(cnvtdate( $STARTDATE),2359)
  SET tempstr = trim(format(cnvtdatetime(reportlist->start_date),"@LONGDATE;t(3);q"),3)
  SET label->report_date_title = concat(m_s_before_date," ",tempstr)
  SET date_qual = "pa.amendment_dt_tm < cnvtdatetime(reportlist->start_date)"
 ELSEIF (( $DATEQUAL=1))
  SET reportlist->start_date = cnvtdatetime(cnvtdate( $STARTDATE),0)
  SET tempstr = trim(format(cnvtdatetime(reportlist->start_date),"@LONGDATE;t(3);q"),3)
  SET date_qual = "pa.amendment_dt_tm > cnvtdatetime(reportlist->start_date)"
  SET label->report_date_title = concat(m_s_after_date," ",tempstr)
 ELSE
  SET reportlist->start_date = cnvtdatetime(cnvtdate( $STARTDATE),0)
  SET reportlist->end_date = cnvtdatetime(cnvtdate( $ENDDATE),2359)
  IF (cnvtdatetime(reportlist->start_date) > cnvtdatetime(reportlist->end_date))
   SET label->end_before_start = uar_i18ngetmessage(i18nhandle,"END_BEFORE_START",
    "The end date cannot be before the start date.")
   GO TO exit_script
  ELSE
   SET tempstr = concat(trim(format(cnvtdatetime(reportlist->start_date),"@LONGDATE;t(3);q"),3)," - ",
    trim(format(cnvtdatetime(reportlist->end_date),"@LONGDATE;t(3);q"),3))
   SET date_qual = concat("pa.amendment_dt_tm > cnvtdatetime(reportlist->start_date)"," AND ",
    "pa.amendment_dt_tm < cnvtdatetime(reportlist->end_date)")
   SET label->report_date_title = concat(m_s_between_date," ",tempstr)
  ENDIF
 ENDIF
 SET reportlist->date_qual =  $DATEQUAL
 SET stat = uar_get_meaning_by_codeset(17271,"PRIMARY",1,sponsor_type_cd)
 IF (size(error_msg,1)=0)
  SELECT INTO "nl:"
   pa.prot_master_id
   FROM prot_amendment pa
   PLAN (pa
    WHERE parser(date_qual)
     AND pa.amendment_dt_tm <= cnvtdatetime(sysdate)
     AND pa.prot_amendment_id > 0.0)
   ORDER BY pa.prot_master_id
   HEAD REPORT
    cnt = 0
   HEAD pa.prot_master_id
    cnt += 1
    IF (mod(cnt,10)=1)
     stat = alterlist(protlist->protocols,(cnt+ 9))
    ENDIF
    protlist->protocols[cnt].prot_master_id = pa.prot_master_id
   FOOT REPORT
    stat = alterlist(protlist->protocols,cnt), protlist->protocol_cnt = cnt
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   pm.prot_master_id
   FROM prot_master pm,
    prot_amendment pa,
    prot_grant_sponsor pgs,
    organization org
   PLAN (pa
    WHERE expand(num,1,protlist->protocol_cnt,pa.prot_master_id,protlist->protocols[num].
     prot_master_id))
    JOIN (pm
    WHERE pm.prot_master_id=pa.prot_master_id
     AND pm.end_effective_dt_tm > cnvtdatetime(sysdate)
     AND (pm.logical_domain_id=domain_reply->logical_domain_id))
    JOIN (pgs
    WHERE (pgs.prot_amendment_id= Outerjoin(pa.prot_amendment_id))
     AND (pgs.primary_secondary_cd= Outerjoin(sponsor_type_cd)) )
    JOIN (org
    WHERE (org.organization_id= Outerjoin(pgs.organization_id)) )
   ORDER BY pm.prot_master_id, pa.amendment_nbr, pa.revision_seq
   HEAD REPORT
    cnt = 0
   HEAD pm.prot_master_id
    cnt += 1, amd_cnt = 0
    IF (mod(cnt,10)=1)
     stat = alterlist(results->protocols,(cnt+ 9))
    ENDIF
    results->protocols[cnt].prot_master_id = pm.prot_master_id, results->protocols[cnt].
    primary_mnemonic = pm.primary_mnemonic, results->protocols[cnt].prot_status_cd = pm
    .prot_status_cd,
    results->protocols[cnt].prot_status_disp = uar_get_code_display(pm.prot_status_cd), results->
    protocols[cnt].init_activation_date = cnvtdatetime("31-DEC-2100 00:00:00"), results->protocols[
    cnt].amd_activation_date = 0
   DETAIL
    IF ((results->protocols[cnt].init_activation_date > pa.amendment_dt_tm)
     AND pa.amendment_dt_tm > 0)
     results->protocols[cnt].init_activation_date = pa.amendment_dt_tm
    ENDIF
    IF (((( $DATEQUAL=0)
     AND pa.amendment_dt_tm < cnvtdatetime(reportlist->start_date)) OR (((( $DATEQUAL=1)
     AND pa.amendment_dt_tm > cnvtdatetime(reportlist->start_date)) OR (( $DATEQUAL=2)
     AND pa.amendment_dt_tm > cnvtdatetime(reportlist->start_date)
     AND pa.amendment_dt_tm < cnvtdatetime(reportlist->end_date))) ))
     AND pa.amendment_dt_tm <= cnvtdatetime(sysdate))
     amd_cnt += 1
     IF (mod(amd_cnt,10)=1)
      stat = alterlist(results->protocols[cnt].amendments,(amd_cnt+ 9))
     ENDIF
     results->protocols[cnt].amendments[amd_cnt].prot_amendment_id = pa.prot_amendment_id, results->
     protocols[cnt].amendments[amd_cnt].amd_activation_date = pa.amendment_dt_tm, results->protocols[
     cnt].amendments[amd_cnt].amendment_nbr = pa.amendment_nbr,
     results->protocols[cnt].amendments[amd_cnt].revision_nbr_txt = pa.revision_nbr_txt, results->
     protocols[cnt].amendments[amd_cnt].revision_ind = pa.revision_ind, results->protocols[cnt].
     amendments[amd_cnt].amd_status_cd = pa.amendment_status_cd,
     results->protocols[cnt].amendments[amd_cnt].amd_status_disp = uar_get_code_display(pa
      .amendment_status_cd), results->protocols[cnt].amendments[amd_cnt].primary_sponsor = org
     .org_name
    ENDIF
   FOOT  pm.prot_master_id
    CALL echo("FOOT pm.prot_master_id"), stat = alterlist(results->protocols[cnt].amendments,amd_cnt)
   FOOT REPORT
    stat = alterlist(results->protocols,cnt)
   WITH nocounter
  ;end select
  IF (( $ORDERBY=0))
   SET orderby = "results->protocols[d.seq].init_activation_date"
   SET label->report_sort_title = m_s_sorted_by_init_date
  ELSEIF (( $ORDERBY=2))
   SET orderby = "CNVTLOWER(results->protocols[d.seq].prot_status_disp)"
   SET label->report_sort_title = m_s_sorted_by_status
  ELSE
   SET orderby = "CNVTLOWER(results->protocols[d.seq].primary_mnemonic)"
   SET label->report_sort_title = m_s_sorted_by_prot
  ENDIF
  SET reportlist->sort_by = orderby
 ENDIF
#exit_script
 SET last_mod = "004"
 SET mod_date = "MAR 13, 2017"
 SET last_mod = "005"
 SET mod_date = "Nov 25, 2019"
END GO
