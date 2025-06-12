CREATE PROGRAM ct_rpt_prescreen_results:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Order report by:" = 0,
  "Prescreen Job:" = 0
  WITH outdev, orderby, jobid
 IF ( NOT (validate(reply)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD report_info(
   1 job_id = f8
   1 report_type_flag = i2
   1 screener_name = vc
   1 screened_dt_tm = dq8
   1 prot_list[*]
     2 prot_master_id = f8
     2 primary_mnemonic = vc
     2 init_service_cd = f8
     2 person_list[*]
       3 person_id = f8
       3 last_name = vc
       3 first_name = vc
       3 mrn_list[*]
         4 mrn = vc
         4 alias_pool_disp = vc
     2 qualified_num = i4
   1 pt_list[*]
     2 person_id = f8
     2 last_name = vc
     2 first_name = vc
     2 mrn_list[*]
       3 mrn = vc
       3 alias_pool_disp = vc
     2 prot_cnt = i2
     2 prot_list[*]
       3 prot_master_id = f8
       3 primary_mnemonic = vc
       3 init_service_cd = f8
       3 qualified_num = i4
 )
 RECORD report_labels(
   1 rpt_test_screen = vc
   1 rpt_screen = vc
   1 rpt_prot_view = vc
   1 rpt_pt_view = vc
   1 rpt_protocol = vc
   1 rpt_init_service = vc
   1 rpt_last_name = vc
   1 rpt_first_name = vc
   1 rpt_mrn = vc
   1 rpt_pot_prots = vc
   1 rpt_pot_pts = vc
 )
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE prot_cnt = i4 WITH protect, noconstant(0)
 DECLARE pt_cnt = i4 WITH protect, noconstant(0)
 DECLARE mrn_cnt = i4 WITH protect, noconstant(0)
 DECLARE rpt_title = vc WITH protect, noconstant("")
 DECLARE rpt_order_by = vc WITH protect, noconstant("")
 DECLARE mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE datestr = vc WITH protect
 DECLARE prot_count = i2 WITH protect, noconstant(0)
 DECLARE outline = vc WITH protect
 DECLARE pat_cnt = i4 WITH protect, noconstant(0)
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE j = i4 WITH protect, noconstant(0)
 DECLARE bfoundpt = i2 WITH protect, noconstant(0)
 DECLARE m = i4 WITH protect, noconstant(0)
 DECLARE mrn_size = i4 WITH protect, noconstant(0)
 DECLARE k = i4 WITH protect, noconstant(0)
 DECLARE pt_prot_cnt = i4 WITH protect, noconstant(0)
 DECLARE pat_idx = i4 WITH protect, noconstant(0)
 DECLARE bfoundptprot = i2 WITH protect, noconstant(0)
 DECLARE n = i4 WITH protect, noconstant(0)
 DECLARE prot_idx = i2 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
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
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET report_labels->rpt_test_screen = uar_i18ngetmessage(i18nhandle,"TEST_PRESCREEN",
  "Test Pre-Screening")
 SET report_labels->rpt_screen = uar_i18ngetmessage(i18nhandle,"PRESCREEN","Pre-Screening")
 SET report_labels->rpt_prot_view = uar_i18ngetmessage(i18nhandle,"PROT_VIEW","Protocol View")
 SET report_labels->rpt_pt_view = uar_i18ngetmessage(i18nhandle,"PT_VIEW","Patient View")
 SET report_labels->rpt_protocol = uar_i18ngetmessage(i18nhandle,"PROTOCOL","Protocol Mnemonic")
 SET report_labels->rpt_init_service = uar_i18ngetmessage(i18nhandle,"INIT_SRV","Initiating Service")
 SET report_labels->rpt_last_name = uar_i18ngetmessage(i18nhandle,"LAST_NAME","Last Name")
 SET report_labels->rpt_first_name = uar_i18ngetmessage(i18nhandle,"FIRST_NAME","First Name")
 SET report_labels->rpt_mrn = uar_i18ngetmessage(i18nhandle,"MRN","MRN")
 SET report_labels->rpt_pot_prots = uar_i18ngetmessage(i18nhandle,"POTENTIAL_PRESCREEN_RPT",
  "Potential Protocols: ")
 SET report_labels->rpt_pot_pts = uar_i18ngetmessage(i18nhandle,"POT_PTS_PRESCREEN_RPT",
  "Potential Patients:")
 IF (( $ORDERBY=0))
  SET rpt_order_by = report_labels->rpt_prot_view
 ELSE
  SET rpt_order_by = report_labels->rpt_pt_view
 ENDIF
 SET report_info->job_id = cnvtreal( $JOBID)
 CALL echo(build("report_info->job_id: ",report_info->job_id))
 SELECT INTO "NL:"
  cpi.prot_master_id
  FROM ct_prescreen_job cpj,
   prsnl p,
   ct_prot_prescreen_job_info cpi,
   prot_master pm
  PLAN (cpj
   WHERE (cpj.ct_prescreen_job_id=report_info->job_id))
   JOIN (p
   WHERE p.person_id=cpj.prsnl_id)
   JOIN (cpi
   WHERE cpi.ct_prescreen_job_id=cpj.ct_prescreen_job_id)
   JOIN (pm
   WHERE pm.prot_master_id=cpi.prot_master_id
    AND pm.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY cpi.prot_master_id
  HEAD REPORT
   report_info->screened_dt_tm = cpj.job_end_dt_tm, report_info->screener_name = p
   .name_full_formatted, report_info->report_type_flag = cpj.job_type_flag,
   prot_cnt = 0
  HEAD cpi.prot_master_id
   prot_cnt = (prot_cnt+ 1)
   IF (mod(prot_cnt,10)=1)
    stat = alterlist(report_info->prot_list,(prot_cnt+ 9))
   ENDIF
   report_info->prot_list[prot_cnt].prot_master_id = cpi.prot_master_id, report_info->prot_list[
   prot_cnt].init_service_cd = pm.initiating_service_cd, report_info->prot_list[prot_cnt].
   primary_mnemonic = pm.primary_mnemonic,
   report_info->prot_list[prot_cnt].qualified_num = cpi.pt_qualified_nbr
  FOOT REPORT
   stat = alterlist(report_info->prot_list,prot_cnt)
  WITH nocounter
 ;end select
 IF ((((report_info->report_type_flag=0)) OR ((report_info->report_type_flag=1))) )
  SET rpt_title = report_labels->rpt_test_screen
 ELSE
  SET rpt_title = report_labels->rpt_screen
 ENDIF
 SET datestr = trim(format(cnvtdatetime(report_info->screened_dt_tm),"@LONGDATETIME;t(3);q"),7)
 IF ((report_info->report_type_flag=1))
  SELECT INTO "NL:"
   cpi.ct_prescreen_job_id
   FROM pt_prot_prescreen_test pt,
    person p,
    person_alias pa,
    (dummyt d  WITH seq = value(prot_cnt))
   PLAN (d)
    JOIN (pt
    WHERE (pt.ct_prescreen_job_id=report_info->job_id)
     AND (pt.prot_master_id=report_info->prot_list[d.seq].prot_master_id))
    JOIN (p
    WHERE p.person_id=pt.person_id)
    JOIN (pa
    WHERE pa.person_id=outerjoin(p.person_id)
     AND pa.person_alias_type_cd=outerjoin(mrn_cd)
     AND pa.active_ind=outerjoin(1)
     AND pa.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
     AND pa.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
   ORDER BY pt.prot_master_id, pt.person_id, pa.person_alias_id
   HEAD pt.prot_master_id
    pt_cnt = 0
   HEAD p.person_id
    pt_cnt = (pt_cnt+ 1)
    IF (mod(pt_cnt,10)=1)
     stat = alterlist(report_info->prot_list[d.seq].person_list,(pt_cnt+ 9))
    ENDIF
    report_info->prot_list[d.seq].person_list[pt_cnt].person_id = p.person_id, report_info->
    prot_list[d.seq].person_list[pt_cnt].last_name = p.name_last, report_info->prot_list[d.seq].
    person_list[pt_cnt].first_name = p.name_first,
    mrn_cnt = 0
   HEAD pa.person_alias_id
    IF (pa.person_alias_id > 0.0)
     mrn_cnt = (mrn_cnt+ 1)
     IF (mod(mrn_cnt,10)=1)
      stat = alterlist(report_info->prot_list[d.seq].person_list[pt_cnt].mrn_list,(mrn_cnt+ 9))
     ENDIF
     report_info->prot_list[d.seq].person_list[pt_cnt].mrn_list[mrn_cnt].mrn = trim(cnvtalias(pa
       .alias,pa.alias_pool_cd)), report_info->prot_list[d.seq].person_list[pt_cnt].mrn_list[mrn_cnt]
     .alias_pool_disp = uar_get_code_display(pa.alias_pool_cd)
    ENDIF
   FOOT  p.person_id
    stat = alterlist(report_info->prot_list[d.seq].person_list[pt_cnt].mrn_list,mrn_cnt)
   FOOT  pt.prot_master_id
    stat = alterlist(report_info->prot_list[d.seq].person_list,pt_cnt)
   WITH nocounter
  ;end select
 ELSEIF ((report_info->report_type_flag=2))
  SELECT INTO "NL:"
   cpi.ct_prescreen_job_id
   FROM pt_prot_prescreen pt,
    person p,
    person_alias pa,
    (dummyt d  WITH seq = value(prot_cnt))
   PLAN (d)
    JOIN (pt
    WHERE (pt.ct_prescreen_job_id=report_info->job_id)
     AND (pt.prot_master_id=report_info->prot_list[d.seq].prot_master_id))
    JOIN (p
    WHERE p.person_id=pt.person_id)
    JOIN (pa
    WHERE pa.person_id=outerjoin(p.person_id)
     AND pa.person_alias_type_cd=outerjoin(mrn_cd)
     AND pa.active_ind=outerjoin(1)
     AND pa.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
     AND pa.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
   ORDER BY pt.prot_master_id, pt.person_id, pa.person_alias_id
   HEAD pt.prot_master_id
    pt_cnt = 0
   HEAD p.person_id
    pt_cnt = (pt_cnt+ 1)
    IF (mod(pt_cnt,10)=1)
     stat = alterlist(report_info->prot_list[d.seq].person_list,(pt_cnt+ 9))
    ENDIF
    report_info->prot_list[d.seq].person_list[pt_cnt].person_id = p.person_id, report_info->
    prot_list[d.seq].person_list[pt_cnt].last_name = p.name_last, report_info->prot_list[d.seq].
    person_list[pt_cnt].first_name = p.name_first,
    mrn_cnt = 0
   HEAD pa.person_alias_id
    IF (pa.person_alias_id > 0.0)
     mrn_cnt = (mrn_cnt+ 1)
     IF (mod(mrn_cnt,10)=1)
      stat = alterlist(report_info->prot_list[d.seq].person_list[pt_cnt].mrn_list,(mrn_cnt+ 9))
     ENDIF
     report_info->prot_list[d.seq].person_list[pt_cnt].mrn_list[mrn_cnt].mrn = trim(cnvtalias(pa
       .alias,pa.alias_pool_cd)), report_info->prot_list[d.seq].person_list[pt_cnt].mrn_list[mrn_cnt]
     .alias_pool_disp = uar_get_code_display(pa.alias_pool_cd)
    ENDIF
   FOOT  p.person_id
    stat = alterlist(report_info->prot_list[d.seq].person_list[pt_cnt].mrn_list,mrn_cnt)
   FOOT  pt.prot_master_id
    stat = alterlist(report_info->prot_list[d.seq].person_list,pt_cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (( $ORDERBY=1)
  AND (report_info->report_type_flag > 0))
  SET pat_cnt = 0
  FOR (i = 1 TO size(report_info->prot_list,5))
    FOR (j = 1 TO size(report_info->prot_list[i].person_list,5))
      SET bfoundpt = false
      SET pat_idx = locateval(m,1,pat_cnt,report_info->prot_list[i].person_list[j].person_id,
       report_info->pt_list[m].person_id)
      IF (pat_idx > 0)
       SET bfoundpt = true
       SET pat_idx = m
      ENDIF
      IF (bfoundpt=false)
       SET pat_cnt = (pat_cnt+ 1)
       SET stat = alterlist(report_info->pt_list,pat_cnt)
       SET report_info->pt_list[pat_cnt].person_id = report_info->prot_list[i].person_list[j].
       person_id
       SET report_info->pt_list[pat_cnt].last_name = report_info->prot_list[i].person_list[j].
       last_name
       SET report_info->pt_list[pat_cnt].first_name = report_info->prot_list[i].person_list[j].
       first_name
       SET mrn_size = size(report_info->prot_list[i].person_list[j].mrn_list,5)
       FOR (k = 1 TO mrn_size)
         SET stat = alterlist(report_info->pt_list[pat_cnt].mrn_list,mrn_size)
         SET report_info->pt_list[pat_cnt].mrn_list[k].mrn = report_info->prot_list[i].person_list[j]
         .mrn_list[k].mrn
         SET report_info->pt_list[pat_cnt].mrn_list[k].alias_pool_disp = report_info->prot_list[i].
         person_list[j].mrn_list[k].alias_pool_disp
       ENDFOR
       SET stat = alterlist(report_info->pt_list[pat_cnt].prot_list,1)
       SET report_info->pt_list[pat_cnt].prot_list[1].prot_master_id = report_info->prot_list[i].
       prot_master_id
       SET report_info->pt_list[pat_cnt].prot_list[1].primary_mnemonic = report_info->prot_list[i].
       primary_mnemonic
       SET report_info->pt_list[pat_cnt].prot_list[1].init_service_cd = report_info->prot_list[i].
       init_service_cd
       SET report_info->pt_list[pat_cnt].prot_list[1].qualified_num = report_info->prot_list[i].
       qualified_num
       SET report_info->pt_list[pat_cnt].prot_cnt = 1
      ELSE
       SET pt_prot_cnt = size(report_info->pt_list[pat_idx].prot_list,5)
       SET bfoundptprot = false
       SET prot_idx = locateval(n,1,pt_prot_cnt,report_info->pt_list[pat_idx].prot_list[n].
        prot_master_id,report_info->prot_list[n].prot_master_id)
       IF (prot_idx > 0)
        SET bfoundptprot = true
       ENDIF
       IF (bfoundptprot=false)
        SET pt_prot_cnt = (pt_prot_cnt+ 1)
        SET stat = alterlist(report_info->pt_list[pat_idx].prot_list,pt_prot_cnt)
        SET report_info->pt_list[pat_idx].prot_list[pt_prot_cnt].prot_master_id = report_info->
        prot_list[i].prot_master_id
        SET report_info->pt_list[pat_idx].prot_list[pt_prot_cnt].primary_mnemonic = report_info->
        prot_list[i].primary_mnemonic
        SET report_info->pt_list[pat_idx].prot_list[pt_prot_cnt].init_service_cd = report_info->
        prot_list[i].init_service_cd
        SET report_info->pt_list[pat_idx].prot_list[pt_prot_cnt].qualified_num = report_info->
        prot_list[i].qualified_num
        SET report_info->pt_list[pat_idx].prot_cnt = pt_prot_cnt
       ENDIF
      ENDIF
    ENDFOR
  ENDFOR
  CALL echorecord(report_info)
 ENDIF
 SET last_mod = "003"
 SET mod_date = "Feb 22, 2018"
#exit_script
END GO
