CREATE PROGRAM ct_rpt_prot_activation_summary:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Activation Date Qualification" = 0,
  "Start Date" = curdate,
  "End Date" = "CURDATE",
  "Order By" = 0,
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
   1 sort_order = i2
   1 sorting_field = vc
   1 output_type = i2
   1 delimiter_output = vc
 )
 RECORD results(
   1 protocols[*]
     2 prot_master_id = f8
     2 primary_mnemonic = c30
     2 init_activation_date = dq8
     2 new_protocol_ind = i2
     2 new_amd_cnt = i4
     2 new_rev_cnt = i4
     2 totals_per_protocol = i4
 )
 RECORD report_labels(
   1 m_s_rpt_title = vc
   1 m_s_before_date = vc
   1 m_s_after_date = vc
   1 m_s_between_date = vc
   1 m_s_sorted_by_init_date = vc
   1 m_s_sorted_by_amd_cnt = vc
   1 m_s_sorted_by_rev_cnt = vc
   1 m_s_sorted_by_totals = vc
   1 m_s_sorted_by_prot = vc
   1 m_s_rep_exec_time = vc
   1 m_s_init_act_header = vc
   1 m_s_prot_mnemonic_header = vc
   1 m_s_new_prot_header = vc
   1 m_s_new_amds_header = vc
   1 m_s_new_revs_header = vc
   1 m_s_totals_per_prot_header = vc
   1 m_s_totals = vc
   1 m_s_end_of_rpt = vc
   1 m_s_criteria_not_met = vc
   1 m_s_yes = vc
   1 m_s_no = vc
   1 m_s_sorted_by = vc
   1 m_s_date_title = vc
   1 m_s_page = vc
   1 date_format = vc
   1 execution_timestamp = vc
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
 SET report_labels->m_s_rpt_title = uar_i18ngetmessage(i18nhandle,"PROT_ACT_SUM_RPT",
  "Protocol Activation Summary Report")
 SET report_labels->m_s_before_date = uar_i18ngetmessage(i18nhandle,"BEFORE_DATE","Before:")
 SET report_labels->m_s_after_date = uar_i18ngetmessage(i18nhandle,"AFTER_DATE","After:")
 SET report_labels->m_s_between_date = uar_i18ngetmessage(i18nhandle,"BETWEEN_DATE","Between:")
 SET report_labels->m_s_sorted_by_init_date = uar_i18ngetmessage(i18nhandle,"SORTED_BY_INIT_DATE",
  "Sorted by initial activation date")
 SET report_labels->m_s_sorted_by_amd_cnt = uar_i18ngetmessage(i18nhandle,"SORTED_BY_AMD_CNT",
  "Sorted by new amendment count")
 SET report_labels->m_s_sorted_by_rev_cnt = uar_i18ngetmessage(i18nhandle,"SORTED_BY_REV_CNT",
  "Sorted by new revision count")
 SET report_labels->m_s_sorted_by_totals = uar_i18ngetmessage(i18nhandle,"SORTED_BY_TOTALS",
  "Sorted by totals per protocol")
 SET report_labels->m_s_sorted_by_prot = uar_i18ngetmessage(i18nhandle,"SORTED_BY_PROT",
  "Sorted by protocol")
 SET report_labels->m_s_rep_exec_time = uar_i18ngetmessage(i18nhandle,"REP_EXEC_TIME",
  "Report execution time:")
 SET report_labels->m_s_init_act_header = uar_i18ngetmessage(i18nhandle,"INIT_ACT_DATE",
  "Initial Activation Date")
 SET report_labels->m_s_prot_mnemonic_header = uar_i18ngetmessage(i18nhandle,"PROT_MNEMONIC",
  "Protocol Mnemonic")
 SET report_labels->m_s_new_prot_header = uar_i18ngetmessage(i18nhandle,"NEW_PROT","New Protocol")
 SET report_labels->m_s_new_amds_header = uar_i18ngetmessage(i18nhandle,"NEW_AMDS","New Amendments")
 SET report_labels->m_s_new_revs_header = uar_i18ngetmessage(i18nhandle,"NEW_REVS","New Revisions")
 SET report_labels->m_s_totals_per_prot_header = uar_i18ngetmessage(i18nhandle,"TOTALS_PER_PROT",
  "Totals Per Protocol")
 SET report_labels->m_s_totals = uar_i18ngetmessage(i18nhandle,"TOTALS","Totals")
 SET report_labels->m_s_end_of_rpt = uar_i18ngetmessage(i18nhandle,"END_OF_RPT",
  "*** End of Report ***")
 SET report_labels->m_s_criteria_not_met = uar_i18ngetmessage(i18nhandle,"CRITERIA_NOT_MET",
  "There were no protocols that met the criteria for the Protocol Activation Summary Report.")
 SET report_labels->m_s_yes = uar_i18ngetmessage(i18nhandle,"YES","Yes")
 SET report_labels->m_s_no = uar_i18ngetmessage(i18nhandle,"NO","No")
 SET report_labels->m_s_page = uar_i18ngetmessage(i18nhandle,"PAGE","Page:")
 SET reportlist->sort_order =  $SORTORDER
 SET reportlist->output_type =  $OUT_TYPE
 SET reportlist->delimiter_output =  $DELIMITER
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE tempstr = vc WITH protect, noconstant("")
 DECLARE offset = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE prot_mnemonic = vc WITH protect, noconstant("")
 DECLARE prot_id = f8 WITH protect, noconstant(0.0)
 DECLARE tmp_init_act_date = vc WITH protect, noconstant("")
 DECLARE tmp_prot = vc WITH protect, noconstant("")
 DECLARE tmp_new_prot = vc WITH protect, noconstant("")
 DECLARE tmp_new_amds = vc WITH protect, noconstant("")
 DECLARE tmp_new_revs = vc WITH protect, noconstant("")
 DECLARE tmp_totals = vc WITH protect, noconstant("")
 DECLARE temp_row = i4 WITH protect, noconstant(0)
 DECLARE orderdirection = vc WITH protect, noconstant("")
 DECLARE exec_timestamp = vc WITH protect, noconstant("")
 DECLARE new_prot_total = i4 WITH protect, noconstant(0)
 DECLARE new_amd_total = i4 WITH protect, noconstant(0)
 DECLARE new_rev_total = i4 WITH protect, noconstant(0)
 DECLARE prot_cnt = i2 WITH protect, noconstant(0)
 DECLARE num = i2 WITH protect, noconstant(0)
 DECLARE date_qual = vc WITH protect, noconstant("")
 DECLARE count = i4 WITH protect, noconstant(0)
 SET report_labels->execution_timestamp = concat(report_labels->m_s_rep_exec_time," ",format(
   cnvtdatetime(sysdate),"@SHORTDATETIME"))
 IF (( $DATEQUAL=0))
  SET reportlist->start_date = cnvtdatetime(cnvtdate( $STARTDATE),2359)
  SET tempstr = trim(format(cnvtdatetime(reportlist->start_date),"@LONGDATE;t(3);q"),3)
  SET report_labels->m_s_date_title = report_labels->m_s_before_date
  SET report_labels->m_s_date_title = concat(report_labels->m_s_date_title,": ",tempstr)
  SET date_qual = "pa.amendment_dt_tm < cnvtdatetime(reportlist->start_date)"
 ELSEIF (( $DATEQUAL=1))
  SET reportlist->start_date = cnvtdatetime(cnvtdate( $STARTDATE),0)
  SET tempstr = trim(format(cnvtdatetime(reportlist->start_date),"@LONGDATE;t(3);q"),3)
  SET report_labels->m_s_date_title = report_labels->m_s_after_date
  SET report_labels->m_s_date_title = concat(report_labels->m_s_date_title,": ",tempstr)
  SET date_qual = "pa.amendment_dt_tm > cnvtdatetime(reportlist->start_date)"
 ELSE
  SET reportlist->start_date = cnvtdatetime(cnvtdate( $STARTDATE),0)
  SET reportlist->end_date = cnvtdatetime(cnvtdate( $ENDDATE),2359)
  SET tempstr = concat(trim(format(cnvtdatetime(reportlist->start_date),"@LONGDATE;t(3);q"),3)," - ",
   trim(format(cnvtdatetime(reportlist->end_date),"@LONGDATE;t(3);q"),3))
  SET date_qual = concat("pa.amendment_dt_tm > cnvtdatetime(reportlist->start_date)"," AND ",
   "pa.amendment_dt_tm < cnvtdatetime(reportlist->end_date)")
  SET report_labels->m_s_date_title = report_labels->m_s_between_date
  SET report_labels->m_s_date_title = concat(report_labels->m_s_date_title,": ",tempstr)
 ENDIF
 SELECT INTO "nl:"
  pm.prot_master_id
  FROM prot_master pm,
   prot_amendment pa
  PLAN (pm
   WHERE pm.prot_master_id > 0.0
    AND pm.end_effective_dt_tm > cnvtdatetime(sysdate)
    AND (pm.logical_domain_id=domain_reply->logical_domain_id))
   JOIN (pa
   WHERE pa.prot_master_id=pm.prot_master_id
    AND parser(date_qual)
    AND pa.amendment_dt_tm <= cnvtdatetime(sysdate))
  ORDER BY pm.prot_master_id
  HEAD REPORT
   cnt = 0
  HEAD pm.prot_master_id
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(protlist->protocols,(cnt+ 9))
   ENDIF
   protlist->protocols[cnt].prot_master_id = pm.prot_master_id
  FOOT REPORT
   stat = alterlist(protlist->protocols,cnt), protlist->protocol_cnt = cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  pm.prot_master_id
  FROM prot_master pm,
   prot_amendment pa
  PLAN (pm
   WHERE expand(num,1,protlist->protocol_cnt,pm.prot_master_id,protlist->protocols[num].
    prot_master_id))
   JOIN (pa
   WHERE pa.prot_master_id=pm.prot_master_id)
  HEAD REPORT
   cnt = 0
  HEAD pm.prot_master_id
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(results->protocols,(cnt+ 9))
   ENDIF
   results->protocols[cnt].prot_master_id = pm.prot_master_id, results->protocols[cnt].
   primary_mnemonic = pm.primary_mnemonic, results->protocols[cnt].init_activation_date =
   cnvtdatetime("31-DEC-2100 00:00:00")
  DETAIL
   IF (pa.amendment_dt_tm > 0
    AND pa.amendment_dt_tm < cnvtdatetime("31-DEC-2100 00:00:00"))
    IF ((results->protocols[cnt].init_activation_date > pa.amendment_dt_tm)
     AND pa.amendment_dt_tm > 0)
     results->protocols[cnt].init_activation_date = pa.amendment_dt_tm
    ENDIF
    IF (( $DATEQUAL=0))
     IF (pa.amendment_dt_tm < cnvtdatetime(reportlist->start_date))
      IF (pa.revision_ind=0)
       results->protocols[cnt].new_amd_cnt += 1
      ELSE
       results->protocols[cnt].new_rev_cnt += 1
      ENDIF
     ENDIF
    ELSEIF (( $DATEQUAL=1))
     IF (pa.amendment_dt_tm > cnvtdatetime(reportlist->start_date))
      IF (pa.revision_ind=0)
       results->protocols[cnt].new_amd_cnt += 1
      ELSE
       results->protocols[cnt].new_rev_cnt += 1
      ENDIF
     ENDIF
    ELSEIF (( $DATEQUAL=2))
     IF (pa.amendment_dt_tm > cnvtdatetime(reportlist->start_date)
      AND pa.amendment_dt_tm < cnvtdatetime(reportlist->end_date))
      IF (pa.revision_ind=0)
       results->protocols[cnt].new_amd_cnt += 1
      ELSE
       results->protocols[cnt].new_rev_cnt += 1
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  FOOT  pm.prot_master_id
   IF (( $DATEQUAL=0))
    IF ((results->protocols[cnt].init_activation_date < cnvtdatetime(reportlist->start_date)))
     results->protocols[cnt].new_protocol_ind = 1
    ENDIF
   ELSEIF (( $DATEQUAL=1))
    IF ((results->protocols[cnt].init_activation_date > cnvtdatetime(reportlist->start_date)))
     results->protocols[cnt].new_protocol_ind = 1
    ENDIF
   ELSEIF (( $DATEQUAL=2))
    IF ((results->protocols[cnt].init_activation_date > cnvtdatetime(reportlist->start_date))
     AND (results->protocols[cnt].init_activation_date < cnvtdatetime(reportlist->end_date)))
     results->protocols[cnt].new_protocol_ind = 1
    ENDIF
   ENDIF
   results->protocols[cnt].totals_per_protocol = (results->protocols[cnt].new_amd_cnt+ results->
   protocols[cnt].new_rev_cnt)
  FOOT REPORT
   stat = alterlist(results->protocols,cnt)
  WITH nocounter
 ;end select
 IF (( $ORDERBY=1))
  SET reportlist->sorting_field = "results->protocols[d.seq].init_activation_date"
  SET report_labels->m_s_sorted_by = report_labels->m_s_sorted_by_init_date
 ELSEIF (( $ORDERBY=2))
  SET reportlist->sorting_field = " results->protocols[d.seq].new_amd_cnt"
  SET report_labels->m_s_sorted_by = report_labels->m_s_sorted_by_amd_cnt
 ELSEIF (( $ORDERBY=3))
  SET reportlist->sorting_field = "results->protocols[d.seq].new_rev_cnt"
  SET report_labels->m_s_sorted_by = report_labels->m_s_sorted_by_rev_cnt
 ELSEIF (( $ORDERBY=4))
  SET reportlist->sorting_field = " results->protocols[d.seq].totals_per_protocol "
  SET report_labels->m_s_sorted_by = report_labels->m_s_sorted_by_totals
 ELSE
  SET reportlist->sorting_field = " CNVTLOWER(results->protocols[d.seq].primary_mnemonic) "
  SET report_labels->m_s_sorted_by = report_labels->m_s_sorted_by_prot
 ENDIF
 SET last_mod = "005"
 SET mod_date = "Nov 25, 2019"
END GO
