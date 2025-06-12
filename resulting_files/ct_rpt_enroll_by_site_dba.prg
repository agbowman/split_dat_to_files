CREATE PROGRAM ct_rpt_enroll_by_site:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Protocol" = 0,
  "Enrolling Institution" = 0,
  "Principal Investigator" = 0,
  "Initiating Service" = 0,
  "Group By" = 0,
  "Order groups by" = 2,
  "Output Type" = 0,
  "Delimiter" = ","
  WITH outdev, protocol, org,
  person, init_svc, groupby,
  orderby, out_type, delimiter
 RECORD qual_list(
   1 all_protocols_ind = i2
   1 protocol_cnt = i4
   1 protocols[*]
     2 prot_master_id = f8
   1 all_organizations_ind = i2
   1 organization_cnt = i4
   1 organizations[*]
     2 organization_id = f8
   1 all_persons_ind = i2
   1 person_cnt = i4
   1 persons[*]
     2 person_id = f8
   1 all_init_services_ind = i2
   1 init_service_cnt = i4
   1 init_services[*]
     2 init_service_cd = f8
 )
 RECORD results(
   1 messages[*]
     2 text = vc
   1 pis[*]
     2 prot_master_id = f8
     2 pi_id = f8
     2 prot_role_id = f8
     2 pi_name_full = c100
   1 enrollments[*]
     2 person_id = f8
     2 prot_master_id = f8
     2 primary_mnemonic = c255
     2 initiating_service_cd = f8
     2 therapeutic_ind = i2
     2 enroll_org_id = f8
     2 enroll_org_name = c100
     2 enroll_org_coord_inst_ind = i2
     2 on_study_ind = i2
     2 off_tx_ind = i2
     2 off_study_ind = i2
 )
 RECORD countlist(
   1 prot_pis[*]
     2 pi_id = f8
     2 pi_name_full = c100
   1 pis[*]
     2 pi_id = f8
   1 init_services[*]
     2 initiating_service_cd = f8
   1 protocols[*]
     2 prot_master_id = f8
   1 enroll_orgs[*]
     2 enroll_org_id = f8
 )
 RECORD label(
   1 rpt_title = vc
   1 rpt_order_by_title = vc
   1 rep_exec_time = vc
   1 enroll_inst_header = vc
   1 prot_mnemonic_header = vc
   1 pri_investigator_header = vc
   1 init_serv_header = vc
   1 cur_on_study_header = vc
   1 cur_off_treat_header = vc
   1 cur_off_study_header = vc
   1 total_enrolled_header = vc
   1 total_sites = vc
   1 total_init = vc
   1 total_pi = vc
   1 total_prot = vc
   1 end_of_rpt = vc
   1 no_prot_found = vc
   1 unable_to_exec = vc
   1 unhandled_grp = vc
   1 comma = vc
   1 at_least_one_prot = vc
   1 at_least_one_org = vc
   1 at_least_one_pi = vc
   1 at_least_one_init = vc
   1 represents = vc
   1 on_the_prot = vc
   1 semi = vc
   1 rpt_page = vc
 )
 RECORD reportlist(
   1 order_by_1 = vc
   1 order_by_2 = vc
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
 DECLARE m_s_order_by_init = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ORDER_BY_INIT",
   "Ordered by Initiating Service"))
 DECLARE m_s_order_by_prot = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ORDER_BY_PROT",
   "Ordered by Protocol"))
 DECLARE m_s_order_by_site = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ORDER_BY_SITE",
   "Ordered by Site"))
 SET label->rpt_title = uar_i18ngetmessage(i18nhandle,"ENROLL_BY_SITE","Enrollment by Site")
 SET label->rep_exec_time = uar_i18ngetmessage(i18nhandle,"REP_EXEC_TIME","Report execution time:")
 SET label->enroll_inst_header = uar_i18ngetmessage(i18nhandle,"ENROLL_INST","Enrolling Institution")
 SET label->prot_mnemonic_header = uar_i18ngetmessage(i18nhandle,"PROT_MNEMONIC","Protocol Mnemonic")
 SET label->pri_investigator_header = uar_i18ngetmessage(i18nhandle,"PRI_INVESTIGATOR",
  "Principal Investigator")
 SET label->init_serv_header = uar_i18ngetmessage(i18nhandle,"INIT_SERV","Initiating Service")
 SET label->cur_on_study_header = uar_i18ngetmessage(i18nhandle,"CUR_ON_STUDY","Currently On Study")
 SET label->cur_off_treat_header = uar_i18ngetmessage(i18nhandle,"CUR_OFF_TREAT",
  "Currently Off Treatment")
 SET label->cur_off_study_header = uar_i18ngetmessage(i18nhandle,"CUR_OFF_STUDY",
  "Currently Off Study")
 SET label->total_enrolled_header = uar_i18ngetmessage(i18nhandle,"TOTAL_ENROLLED","Total Enrolled")
 SET label->total_sites = uar_i18ngetmessage(i18nhandle,"TOTAL_SITES","Total Sites:")
 SET label->total_init = uar_i18ngetmessage(i18nhandle,"TOTAL_INIT","Total Initiating Services:")
 SET label->total_pi = uar_i18ngetmessage(i18nhandle,"TOTAL_PI","Total Principal Investigator:")
 SET label->total_prot = uar_i18ngetmessage(i18nhandle,"TOTAL_PROT","Total Protocols:")
 SET label->end_of_rpt = uar_i18ngetmessage(i18nhandle,"END_OF_RPT","*** End of Report ***")
 SET label->no_prot_found = uar_i18ngetmessage(i18nhandle,"NO_PROT_FOUND",
  "There were no protocols found for the selected information.")
 SET label->unable_to_exec = uar_i18ngetmessage(i18nhandle,"UNABLE_TO_EXEC",
  "Unable to execute report, the following issues were encountered:")
 SET label->unhandled_grp = uar_i18ngetmessage(i18nhandle,"UNHANDLED_GRP",
  "Unhandled group by value selected.")
 SET label->comma = uar_i18ngetmessage(i18nhandle,"COMMA",",")
 SET label->at_least_one_prot = uar_i18ngetmessage(i18nhandle,"AT_LEAST_ONE_PROT",
  "At least one protocol must be selected.")
 SET label->at_least_one_org = uar_i18ngetmessage(i18nhandle,"AT_LEAST_ONE_ORG",
  "At least one organization must be selected.")
 SET label->at_least_one_pi = uar_i18ngetmessage(i18nhandle,"AT_LEAST_ONE_PI",
  "At least one principal investigator must be selected.")
 SET label->at_least_one_init = uar_i18ngetmessage(i18nhandle,"AT_LEAST_ONE_INIT",
  "At least one initiating service must be selected.")
 SET label->represents = uar_i18ngetmessage(i18nhandle,"REPRESENTS","* Represents")
 SET label->on_the_prot = uar_i18ngetmessage(i18nhandle,"ON_THE_PROT","on the protocol")
 SET label->semi = uar_i18ngetmessage(i18nhandle,"SEMI",";")
 SET label->rpt_page = uar_i18ngetmessage(i18nhandle,"PAGE","Page:")
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE tempstr = vc WITH protect, noconstant("")
 DECLARE tmp_prot = vc WITH protect, noconstant("")
 DECLARE tmp_org = vc WITH protect, noconstant("")
 DECLARE tmp_pi = vc WITH protect, noconstant("")
 DECLARE tmp_init_svc = vc WITH protect, noconstant("")
 DECLARE tmp_site = vc WITH protect, noconstant("")
 DECLARE orderby = vc WITH protect, noconstant("")
 DECLARE orderby2 = vc WITH protect, noconstant("")
 DECLARE newstr = vc WITH protect, noconstant("")
 DECLARE delimiter = vc WITH protect, noconstant(",")
 DECLARE num = i2 WITH protect, noconstant(0)
 DECLARE new_line_ind = i2 WITH protect, noconstant(0)
 DECLARE offset = i4 WITH protect, noconstant(0)
 DECLARE parmidx = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE pi_cd = f8 WITH protect, noconstant(0.0)
 DECLARE coord_inst_cd = f8 WITH protect, noconstant(0.0)
 DECLARE therapeutic_cd = f8 WITH protect, noconstant(0.0)
 DECLARE prot_cnt = i4 WITH protect, noconstant(0)
 DECLARE pi_cnt = i4 WITH protect, noconstant(0)
 DECLARE enroll_cnt = i4 WITH protect, noconstant(0)
 DECLARE init_svc_cnt = i4 WITH protect, noconstant(0)
 DECLARE msg_cnt = i4 WITH protect, noconstant(0)
 DECLARE site_cnt = i4 WITH protect, noconstant(0)
 DECLARE rec_pos = i4 WITH protect, noconstant(0)
 DECLARE on_study_cnt = i4 WITH protect, noconstant(0)
 DECLARE off_study_cnt = i4 WITH protect, noconstant(0)
 DECLARE off_tx_cnt = i4 WITH protect, noconstant(0)
 DECLARE total_cnt = i4 WITH protect, noconstant(0)
 DECLARE on_study_total = i4 WITH protect, noconstant(0)
 DECLARE off_study_total = i4 WITH protect, noconstant(0)
 DECLARE off_tx_total = i4 WITH protect, noconstant(0)
 DECLARE enroll_total = i4 WITH protect, noconstant(0)
 DECLARE nstart = i2 WITH protect, noconstant(0)
 DECLARE batch_size = i2 WITH protect, noconstant(0)
 DECLARE loop_cnt = i2 WITH protect, noconstant(0)
 DECLARE cur_list_size = i2 WITH protect, noconstant(0)
 DECLARE new_list_size = i2 WITH protect, noconstant(0)
 SET stat = uar_get_meaning_by_codeset(17441,"COORDINST",1,coord_inst_cd)
 SET stat = uar_get_meaning_by_codeset(17441,"PRIMARY",1,pi_cd)
 SET stat = uar_get_meaning_by_codeset(17275,"THERAPEUTIC",1,therapeutic_cd)
 SET label->rep_exec_time = concat(label->rep_exec_time," ",format(cnvtdatetime(sysdate),
   "@SHORTDATETIME"))
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
  IF (cnvtreal(parameter(parmidx,1))=0.0)
   SET cnt = 0
   SET qual_list->all_protocols_ind = 1
  ELSE
   SET stat = alterlist(qual_list->protocols,1)
   SET qual_list->protocols[1].prot_master_id = cnvtreal(parameter(parmidx,1))
   SET qual_list->protocol_cnt = 1
  ENDIF
 ELSE
  CALL addmessage(label->at_least_one_prot)
 ENDIF
 SET qual_list->all_organizations_ind = 0
 SET parmidx = 3
 IF (reflect(parameter(parmidx,0))="C1")
  SET qual_list->all_organizations_ind = 1
 ELSEIF (substring(1,1,reflect(parameter(parmidx,0)))="L")
  SET cnt = 1
  WHILE (reflect(parameter(parmidx,cnt)) > " ")
    IF (mod(cnt,10)=1)
     SET stat = alterlist(qual_list->organizations,(cnt+ 9))
    ENDIF
    SET qual_list->organizations[cnt].organization_id = cnvtreal(parameter(parmidx,cnt))
    SET cnt += 1
  ENDWHILE
  SET cnt -= 1
  SET qual_list->organization_cnt = cnt
  SET stat = alterlist(qual_list->organizations,cnt)
 ELSEIF (reflect(parameter(parmidx,0))="F8")
  IF (cnvtreal(parameter(parmidx,1))=0.0)
   SET qual_list->all_organizations_ind = 1
  ELSE
   SET stat = alterlist(qual_list->organizations,1)
   SET qual_list->organizations[1].organization_id = cnvtreal(parameter(parmidx,1))
   SET qual_list->organization_cnt = 1
  ENDIF
 ELSE
  CALL addmessage(label->at_least_one_org)
 ENDIF
 SET qual_list->all_persons_ind = 0
 SET parmidx = 4
 IF (reflect(parameter(parmidx,0))="C1")
  SET qual_list->all_persons_ind = 1
 ELSEIF (substring(1,1,reflect(parameter(parmidx,0)))="L")
  SET cnt = 1
  WHILE (reflect(parameter(parmidx,cnt)) > " ")
    IF (mod(cnt,10)=1)
     SET stat = alterlist(qual_list->persons,(cnt+ 9))
    ENDIF
    SET qual_list->persons[cnt].person_id = cnvtreal(parameter(parmidx,cnt))
    SET cnt += 1
  ENDWHILE
  SET cnt -= 1
  SET qual_list->person_cnt = cnt
  SET stat = alterlist(qual_list->persons,cnt)
 ELSEIF (reflect(parameter(parmidx,0))="F8")
  IF (cnvtreal(parameter(parmidx,1))=0.0)
   SET qual_list->all_persons_ind = 1
  ELSE
   SET stat = alterlist(qual_list->persons,1)
   SET qual_list->persons[1].person_id = cnvtreal(parameter(parmidx,1))
   SET qual_list->person_cnt = 1
  ENDIF
 ELSE
  CALL addmessage(label->at_least_one_pi)
 ENDIF
 SET qual_list->all_init_services_ind = 0
 SET parmidx = 5
 IF (reflect(parameter(parmidx,0))="C1")
  SET qual_list->all_init_services_ind = 1
 ELSEIF (substring(1,1,reflect(parameter(parmidx,0)))="L")
  SET cnt = 1
  WHILE (reflect(parameter(parmidx,cnt)) > " ")
    IF (mod(cnt,10)=1)
     SET stat = alterlist(qual_list->init_services,(cnt+ 9))
    ENDIF
    SET qual_list->init_services[cnt].init_service_cd = cnvtreal(parameter(parmidx,cnt))
    SET cnt += 1
  ENDWHILE
  SET cnt -= 1
  SET qual_list->init_service_cnt = cnt
  SET stat = alterlist(qual_list->init_services,cnt)
 ELSEIF (reflect(parameter(parmidx,0))="F8")
  IF (cnvtreal(parameter(parmidx,1))=0.0)
   SET qual_list->all_init_services_ind = 1
  ELSE
   SET stat = alterlist(qual_list->init_services,1)
   SET qual_list->init_services[1].init_service_cd = cnvtreal(parameter(parmidx,1))
   SET qual_list->init_service_cnt = 1
  ENDIF
 ELSE
  CALL addmessage(label->at_least_one_init)
 ENDIF
 SET delimiter =  $DELIMITER
 IF (( $ORDERBY=1))
  IF (( $GROUPBY=0))
   SET orderby = "CNVTLOWER(uar_get_code_display(results->enrollments[d.seq].initiating_service_cd))"
   SET orderby2 = "CNVTLOWER(results->enrollments[d.seq].primary_mnemonic)"
  ELSEIF (( $GROUPBY=1))
   SET orderby = "CNVTLOWER(results->enrollments[d.seq].primary_mnemonic)"
   SET orderby2 = "CNVTLOWER(results->enrollments[d.seq].enroll_org_name)"
  ELSEIF (( $GROUPBY=2))
   SET orderby = "CNVTLOWER(uar_get_code_display(results->enrollments[d.seq].initiating_service_cd))"
   SET orderby2 = "CNVTLOWER(results->enrollments[d.seq].enroll_org_name)"
  ELSEIF (( $GROUPBY=3))
   SET orderby = "CNVTLOWER(uar_get_code_display(results->enrollments[d.seq].initiating_service_cd))"
   SET orderby2 = "CNVTLOWER(results->enrollments[d.seq].enroll_org_name)"
  ENDIF
  SET label->rpt_order_by_title = m_s_order_by_init
 ELSEIF (( $ORDERBY=2))
  IF (( $GROUPBY=0))
   SET orderby = "CNVTLOWER(results->enrollments[d.seq].primary_mnemonic)"
   SET orderby2 = "1=1"
  ELSEIF (( $GROUPBY=1))
   SET orderby = "CNVTLOWER(results->enrollments[d.seq].primary_mnemonic)"
   SET orderby2 = "CNVTLOWER(results->enrollments[d.seq].enroll_org_name)"
  ELSEIF (( $GROUPBY=2))
   SET orderby = "CNVTLOWER(results->enrollments[d.seq].primary_mnemonic)"
   SET orderby2 = "CNVTLOWER(results->enrollments[d.seq].enroll_org_name)"
  ELSEIF (( $GROUPBY=3))
   SET orderby = "CNVTLOWER(results->enrollments[d.seq].enroll_org_name)"
   SET orderby2 = "1=1"
  ENDIF
  SET label->rpt_order_by_title = m_s_order_by_prot
 ELSE
  IF (( $GROUPBY=0))
   SET orderby = "CNVTLOWER(results->enrollments[d.seq].enroll_org_name)"
   SET orderby2 = "CNVTLOWER(results->enrollments[d.seq].primary_mnemonic)"
  ELSEIF (((( $GROUPBY=1)) OR (((( $GROUPBY=2)) OR (( $GROUPBY=3))) )) )
   SET orderby = "CNVTLOWER(results->enrollments[d.seq].enroll_org_name)"
   SET orderby2 = "CNVTLOWER(results->enrollments[d.seq].primary_mnemonic)"
  ENDIF
  SET label->rpt_order_by_title = m_s_order_by_site
 ENDIF
 SET reportlist->order_by_1 = orderby
 SET reportlist->order_by_2 = orderby2
 IF (size(results->messages,5)=0)
  SET cnt = 0
  SET enroll_cnt = 0
  SET pi_cnt = 0
  SELECT INTO "nl:"
   p.person_id, org.org_name, prot = pm.primary_mnemonic,
   init_service = uar_get_code_display(pm.initiating_service_cd), pi = pi.name_full_formatted, ppr
   .on_study_dt_tm,
   ppr.tx_completion_dt_tm, ppr.off_study_dt_tm
   FROM pt_prot_reg ppr,
    organization org,
    person p,
    prot_master pm,
    prot_amendment pa,
    prot_role pr,
    person pi
   PLAN (ppr
    WHERE (((qual_list->all_protocols_ind=1)) OR (expand(num,1,qual_list->protocol_cnt,ppr
     .prot_master_id,qual_list->protocols[num].prot_master_id)))
     AND (((qual_list->all_organizations_ind=1)) OR (expand(num,1,qual_list->organization_cnt,ppr
     .enrolling_organization_id,qual_list->organizations[num].organization_id)))
     AND ppr.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00"))
    JOIN (org
    WHERE org.organization_id=ppr.enrolling_organization_id
     AND (org.logical_domain_id=domain_reply->logical_domain_id))
    JOIN (p
    WHERE p.person_id=ppr.person_id)
    JOIN (pm
    WHERE pm.prot_master_id=ppr.prot_master_id
     AND pm.prot_master_id > 0.0
     AND pm.end_effective_dt_tm > cnvtdatetime(sysdate)
     AND (((qual_list->all_init_services_ind=1)) OR (expand(num,1,qual_list->init_service_cnt,pm
     .initiating_service_cd,qual_list->init_services[num].init_service_cd))) )
    JOIN (pa
    WHERE pa.prot_master_id=pm.prot_master_id
     AND pa.amendment_status_cd=pm.prot_status_cd)
    JOIN (pr
    WHERE pr.prot_amendment_id=pa.prot_amendment_id
     AND ((pr.prot_role_cd=pi_cd) OR (pr.prot_role_cd=coord_inst_cd))
     AND pr.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00"))
    JOIN (pi
    WHERE (pi.person_id= Outerjoin(pr.person_id))
     AND (((qual_list->all_persons_ind=1)) OR (expand(num,1,qual_list->person_cnt,pi.person_id,
     qual_list->persons[num].person_id))) )
   ORDER BY ppr.prot_master_id, ppr.pt_prot_reg_id
   HEAD ppr.prot_master_id
    enroll_cnt += 1
    IF (mod(enroll_cnt,10)=1)
     stat = alterlist(results->enrollments,(enroll_cnt+ 9))
    ENDIF
    results->enrollments[enroll_cnt].person_id = ppr.pt_prot_reg_id, results->enrollments[enroll_cnt]
    .prot_master_id = pm.prot_master_id, results->enrollments[enroll_cnt].primary_mnemonic = pm
    .primary_mnemonic,
    results->enrollments[enroll_cnt].initiating_service_cd = pm.initiating_service_cd, results->
    enrollments[enroll_cnt].enroll_org_id = ppr.enrolling_organization_id, results->enrollments[
    enroll_cnt].enroll_org_name = org.org_name
    IF (pm.prot_type_cd=therapeutic_cd)
     results->enrollments[enroll_cnt].therapeutic_ind = 1
    ELSE
     results->enrollments[enroll_cnt].therapeutic_ind = 0
    ENDIF
    IF (ppr.off_study_dt_tm <= cnvtdatetime(sysdate))
     results->enrollments[enroll_cnt].off_study_ind = 1
    ENDIF
    IF (ppr.tx_completion_dt_tm <= cnvtdatetime(sysdate))
     results->enrollments[enroll_cnt].off_tx_ind = 1
    ENDIF
   HEAD ppr.pt_prot_reg_id
    enroll_cnt += 1
    IF (mod(enroll_cnt,10)=1)
     stat = alterlist(results->enrollments,(enroll_cnt+ 9))
    ENDIF
    results->enrollments[enroll_cnt].person_id = ppr.pt_prot_reg_id, results->enrollments[enroll_cnt]
    .prot_master_id = pm.prot_master_id, results->enrollments[enroll_cnt].primary_mnemonic = pm
    .primary_mnemonic,
    results->enrollments[enroll_cnt].initiating_service_cd = pm.initiating_service_cd, results->
    enrollments[enroll_cnt].enroll_org_id = ppr.enrolling_organization_id, results->enrollments[
    enroll_cnt].enroll_org_name = org.org_name
    IF (pm.prot_type_cd=therapeutic_cd)
     results->enrollments[enroll_cnt].therapeutic_ind = 1
    ELSE
     results->enrollments[enroll_cnt].therapeutic_ind = 0
    ENDIF
    IF (ppr.off_study_dt_tm <= cnvtdatetime(sysdate))
     results->enrollments[enroll_cnt].off_study_ind = 1
    ENDIF
    IF (ppr.tx_completion_dt_tm <= cnvtdatetime(sysdate))
     results->enrollments[enroll_cnt].off_tx_ind = 1
    ENDIF
   DETAIL
    IF (ppr.enrolling_organization_id=pr.organization_id
     AND pr.prot_role_cd=coord_inst_cd)
     results->enrollments[enroll_cnt].enroll_org_coord_inst_ind = 1
    ENDIF
    IF (pr.prot_role_cd=pi_cd)
     IF (locateval(idx,1,size(results->pis,5),pr.prot_role_id,results->pis[idx].prot_role_id)=0)
      pi_cnt += 1
      IF (mod(pi_cnt,10)=1)
       stat = alterlist(results->pis,(pi_cnt+ 9))
      ENDIF
      results->pis[pi_cnt].pi_id = pi.person_id, results->pis[pi_cnt].pi_name_full = pi
      .name_full_formatted, results->pis[pi_cnt].prot_master_id = pm.prot_master_id,
      results->pis[pi_cnt].prot_role_id = pr.prot_role_id
     ENDIF
    ENDIF
   WITH nocounter, expand = 2
  ;end select
  SET stat = alterlist(results->enrollments,enroll_cnt)
  SET stat = alterlist(results->pis,pi_cnt)
 ENDIF
 SUBROUTINE addmessage(smsg)
   SET msg_cnt = (size(results->messages,5)+ 1)
   SET stat = alterlist(results->messages,msg_cnt)
   SET results->messages[msg_cnt].text = smsg
 END ;Subroutine
 SET last_mod = "005"
 SET mod_date = "March 02, 2023"
END GO
