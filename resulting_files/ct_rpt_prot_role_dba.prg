CREATE PROGRAM ct_rpt_prot_role:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Protocols" = 0,
  "Roles" = 0,
  "Person" = 0,
  "Organization" = 0,
  "Role Type" = value(*),
  "Amendment Detail" = 0,
  "Order groups by" = 1,
  "Group By" = 0,
  "Position" = 0,
  "Output type" = 0,
  "Delimiter" = ","
  WITH outdev, protocols, roles,
  person, organization, roletype,
  amd_detail, orderby, groupby,
  position, out_type, delimiter
 RECORD qual_list(
   1 all_protocols_ind = i2
   1 protocol_cnt = i4
   1 protocols[*]
     2 prot_master_id = f8
   1 all_organizations_ind = i2
   1 organization_cnt = i4
   1 organizations[*]
     2 organization_id = f8
   1 all_roles_ind = i2
   1 rcnt = i4
   1 roles[*]
     2 role_cd = f8
   1 all_persons_ind = i2
   1 person_cnt = i4
   1 persons[*]
     2 person_id = f8
   1 all_roletypes_ind = i2
   1 roletype_cnt = i4
   1 roletypes[*]
     2 roletype_cd = f8
   1 all_positions_ind = i2
   1 position_cnt = i4
   1 positions[*]
     2 position_cd = f8
   1 amd_detail_ind = i2
 )
 RECORD results(
   1 messages[*]
     2 text = vc
   1 prot_cnt = i4
   1 protocols[*]
     2 prot_master_id = f8
     2 primary_mnemonic = c30
     2 prot_amendment_id = f8
     2 amd_activation_date = dq8
     2 amendment_nbr = i4
     2 revision_nbr_txt = vc
     2 revision_ind = i2
     2 revision_seq = i4
     2 amd_status_cd = f8
     2 amd_status_disp = c40
     2 role_cd = f8
     2 role_disp = c40
     2 role_type_cd = f8
     2 role_type_disp = c40
     2 primary_contact_ind = i2
     2 org_name = c100
     2 person_full_name = c100
     2 position_cd = f8
     2 position_disp = c40
     2 role_activated_date = dq8
     2 role_inactivated_date = dq8
 )
 RECORD label(
   1 rpt_title = vc
   1 rpt_order_by_title = vc
   1 rep_exec_time = vc
   1 prot_mnemonic_header = vc
   1 role_header = vc
   1 person_header = vc
   1 position_header = vc
   1 status_header = vc
   1 organization_header = vc
   1 prot_contact_header = vc
   1 total_prot = vc
   1 total_roles = vc
   1 total_roles_for = vc
   1 total_roles_for_colon = vc
   1 end_of_rpt = vc
   1 no_prot_found = vc
   1 unable_to_exec = vc
   1 amendment = vc
   1 init_prot = vc
   1 revision = vc
   1 at_least_one_prot = vc
   1 at_least_one_role = vc
   1 at_least_one_prsn = vc
   1 at_least_one_org = vc
   1 at_least_one_role_type = vc
   1 at_least_one_position = vc
   1 seperator = vc
   1 mark = vc
   1 date_added = vc
   1 date_removed = vc
   1 rpt_page = vc
 )
 RECORD reportlist(
   1 order_by = vc
   1 order_by_prot_mnemonic = vc
   1 order_by_amd_nbr = vc
   1 order_by_rev_seq = vc
   1 order_by_role_disp = vc
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
 DECLARE m_s_order_by_person = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ORDER_BY_PERSON",
   "Ordered by person"))
 DECLARE m_s_order_by_role = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ORDER_BY_ROLE",
   "Ordered by role"))
 DECLARE m_s_order_by_prot = vc WITH constant(uar_i18ngetmessage(i18nhandle,"ORDER_BY_PROT",
   "Ordered by protocol"))
 SET label->rpt_title = uar_i18ngetmessage(i18nhandle,"PROT_BY_ROLE","Protocols by Role Report")
 SET label->rep_exec_time = uar_i18ngetmessage(i18nhandle,"REP_EXEC_TIME","Report execution time:")
 SET label->prot_mnemonic_header = uar_i18ngetmessage(i18nhandle,"PROT_MNEMONIC","Protocol Mnemonic")
 SET label->role_header = uar_i18ngetmessage(i18nhandle,"ROLE","Role")
 SET label->person_header = uar_i18ngetmessage(i18nhandle,"PERSON","Person")
 SET label->position_header = uar_i18ngetmessage(i18nhandle,"POSITION","Position")
 SET label->status_header = uar_i18ngetmessage(i18nhandle,"STATUS","Status")
 SET label->organization_header = uar_i18ngetmessage(i18nhandle,"ORGANIZATION","Organization")
 SET label->prot_contact_header = uar_i18ngetmessage(i18nhandle,"PRIMARY_CONTACT","Protocol Contact")
 SET label->total_prot = uar_i18ngetmessage(i18nhandle,"TOTAL_PROT","Total Protocols:")
 SET label->total_roles = uar_i18ngetmessage(i18nhandle,"TOTAL_ROLES","Total Roles:")
 SET label->total_roles_for = uar_i18ngetmessage(i18nhandle,"TOTAL_ROLES_FOR","Total Roles for")
 SET label->total_roles_for_colon = uar_i18ngetmessage(i18nhandle,"TOTAL_ROLES_FOR_COLON",":")
 SET label->end_of_rpt = uar_i18ngetmessage(i18nhandle,"END_OF_RPT","*** End of Report ***")
 SET label->no_prot_found = uar_i18ngetmessage(i18nhandle,"NO_PROT_FOUND",
  "There were no protocols found with the selected role information.")
 SET label->unable_to_exec = uar_i18ngetmessage(i18nhandle,"UNABLE_TO_EXEC",
  "Unable to execute report, the following issues were encountered:")
 SET label->amendment = uar_i18ngetmessage(i18nhandle,"AMENDMENT","Amendment")
 SET label->init_prot = uar_i18ngetmessage(i18nhandle,"INIT_PROT","Initial Protocol")
 SET label->revision = uar_i18ngetmessage(i18nhandle,"REVISION","Revision")
 SET label->at_least_one_prot = uar_i18ngetmessage(i18nhandle,"AT_LEAST_ONE_PROT",
  "At least one protocol must be selected.")
 SET label->at_least_one_role = uar_i18ngetmessage(i18nhandle,"AT_LEAST_ONE_ROLE",
  "At least one role must be selected.")
 SET label->at_least_one_prsn = uar_i18ngetmessage(i18nhandle,"AT_LEAST_ONE_PRSN",
  "At least one person must be selected.")
 SET label->at_least_one_org = uar_i18ngetmessage(i18nhandle,"AT_LEAST_ONE_ORG",
  "At least one organization must be selected.")
 SET label->at_least_one_role_type = uar_i18ngetmessage(i18nhandle,"AT_LEAST_ONE_ROLE_TYPE",
  "At least one role type must be selected.")
 SET label->at_least_one_position = uar_i18ngetmessage(i18nhandle,"AT_LEAST_ONE_POSITION",
  "At least one position must be selected.")
 SET label->seperator = uar_i18ngetmessage(i18nhandle,"SEPERATOR","-")
 SET label->mark = uar_i18ngetmessage(i18nhandle,"MARK","X")
 SET label->date_added = uar_i18ngetmessage(i18nhandle,"DATE_ADDED","Date Activated")
 SET label->date_removed = uar_i18ngetmessage(i18nhandle,"DATE_REMOVED","Date Inactivated")
 SET label->rpt_page = uar_i18ngetmessage(i18nhandle,"RPT_PAGE","Page:")
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE tempstr = vc WITH protect, noconstant("")
 DECLARE tmp_prot = vc WITH protect, noconstant("")
 DECLARE tmp_status = vc WITH protect, noconstant("")
 DECLARE tmp_amd_desc = vc WITH protect, noconstant("")
 DECLARE tmp_role = vc WITH protect, noconstant("")
 DECLARE orderby_role = vc WITH protect, noconstant("")
 DECLARE orderby_prot = vc WITH protect, noconstant("")
 DECLARE num = i2 WITH protect, noconstant(0)
 DECLARE offset = i4 WITH protect, noconstant(0)
 DECLARE parmidx = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE prot_id = f8 WITH protect, noconstant(0.0)
 DECLARE amd_id = f8 WITH protect, noconstant(0.0)
 DECLARE role_cd = f8 WITH protect, noconstant(0.0)
 DECLARE orderby = vc WITH protect, noconstant("")
 DECLARE person_name = vc WITH protect, noconstant("")
 DECLARE prot_cnt = i4 WITH protect, noconstant(0)
 DECLARE acnt = i4 WITH protect, noconstant(0)
 DECLARE rcnt = i4 WITH protect, noconstant(0)
 DECLARE msg_cnt = i4 WITH protect, noconstant(0)
 DECLARE skip_amd = i2 WITH protect, noconstant(0)
 DECLARE nstart = i2 WITH protect, noconstant(0)
 DECLARE batch_size = i2 WITH protect, noconstant(0)
 DECLARE loop_cnt = i2 WITH protect, noconstant(0)
 DECLARE cur_list_size = i2 WITH protect, noconstant(0)
 DECLARE new_list_size = i2 WITH protect, noconstant(0)
 DECLARE exec_timestamp = vc WITH protect, noconstant("")
 DECLARE tmp_amd = vc WITH protect, noconstant("")
 DECLARE tmp_amd_status = vc WITH protect, noconstant("")
 DECLARE tmp_name = vc WITH protect, noconstant("")
 DECLARE tmp_position = vc WITH protect, noconstant("")
 DECLARE tmp_org = vc WITH protect, noconstant("")
 DECLARE tmp_inactivated_date = vc WITH protect, noconstant("")
 DECLARE tmp_cont = vc WITH protect, noconstant("")
 DECLARE person_count = f8 WITH protect, noconstant(0)
 DECLARE person_map(mode=vc,mapkey=vc,mapval=vc) = i4 WITH map = "HASH"
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
  SET stat = alterlist(qual_list->protocols,1)
  SET qual_list->protocols[1].prot_master_id = cnvtreal(parameter(parmidx,1))
  SET qual_list->protocol_cnt = 1
 ELSE
  CALL addmessage(label->at_least_one_prot)
 ENDIF
 SET qual_list->all_roles_ind = 0
 SET parmidx = 3
 IF (reflect(parameter(parmidx,0))="C1")
  SET qual_list->all_roles_ind = 1
 ELSEIF (substring(1,1,reflect(parameter(parmidx,0)))="L")
  SET cnt = 1
  WHILE (reflect(parameter(parmidx,cnt)) > " ")
    IF (mod(cnt,10)=1)
     SET stat = alterlist(qual_list->roles,(cnt+ 9))
    ENDIF
    SET qual_list->roles[cnt].role_cd = cnvtreal(parameter(parmidx,cnt))
    SET cnt += 1
  ENDWHILE
  SET cnt -= 1
  SET qual_list->rcnt = cnt
  SET stat = alterlist(qual_list->roles,cnt)
 ELSEIF (reflect(parameter(parmidx,0))="F8")
  IF (cnvtreal(parameter(parmidx,1)) <= 0)
   SET qual_list->all_roles_ind = 1
  ELSE
   SET stat = alterlist(qual_list->roles,1)
   SET qual_list->roles[1].role_cd = cnvtreal(parameter(parmidx,1))
   SET qual_list->rcnt = 1
  ENDIF
 ELSE
  CALL addmessage(label->at_least_one_role)
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
  SET stat = alterlist(qual_list->persons,1)
  SET qual_list->persons[1].person_id = cnvtreal(parameter(parmidx,1))
  SET qual_list->person_cnt = 1
 ELSE
  CALL addmessage(label->at_least_one_prsn)
 ENDIF
 SET qual_list->all_organizations_ind = 0
 SET parmidx = 5
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
  SET stat = alterlist(qual_list->organizations,1)
  SET qual_list->organizations[1].organization_id = cnvtreal(parameter(parmidx,1))
  SET qual_list->organization_cnt = 1
 ELSE
  CALL addmessage(label->at_least_one_org)
 ENDIF
 SET qual_list->all_roletypes_ind = 0
 SET parmidx = 6
 IF (reflect(parameter(parmidx,0))="C1")
  SET qual_list->all_roletypes_ind = 1
 ELSEIF (substring(1,1,reflect(parameter(parmidx,0)))="L")
  SET cnt = 1
  WHILE (reflect(parameter(parmidx,cnt)) > " ")
    IF (mod(cnt,10)=1)
     SET stat = alterlist(qual_list->roletypes,(cnt+ 9))
    ENDIF
    SET qual_list->roletypes[cnt].roletype_cd = cnvtreal(parameter(parmidx,cnt))
    SET cnt += 1
  ENDWHILE
  SET cnt -= 1
  SET qual_list->roletype_cnt = cnt
  SET stat = alterlist(qual_list->roletypes,cnt)
 ELSEIF (reflect(parameter(parmidx,0))="F8")
  IF (cnvtreal(parameter(parmidx,1)) <= 0)
   SET qual_list->all_roletypes_ind = 1
  ELSE
   SET stat = alterlist(qual_list->roletypes,1)
   SET qual_list->roletypes[1].roletype_cd = cnvtreal(parameter(parmidx,1))
   SET qual_list->roletype_cnt = 1
  ENDIF
 ELSE
  CALL addmessage(label->at_least_one_role_type)
 ENDIF
 SET qual_list->all_positions_ind = 0
 SET parmidx = 10
 IF (((reflect(parameter(parmidx,0))="C1") OR (reflect(parameter(parmidx,0))="I4")) )
  SET qual_list->all_positions_ind = 1
 ELSEIF (substring(1,1,reflect(parameter(parmidx,0)))="L")
  SET cnt = 1
  WHILE (reflect(parameter(parmidx,cnt)) > " ")
    IF (mod(cnt,10)=1)
     SET stat = alterlist(qual_list->positions,(cnt+ 9))
    ENDIF
    SET qual_list->positions[cnt].position_cd = cnvtreal(parameter(parmidx,cnt))
    SET cnt += 1
  ENDWHILE
  SET cnt -= 1
  SET qual_list->position_cnt = cnt
  SET stat = alterlist(qual_list->positions,cnt)
 ELSEIF (reflect(parameter(parmidx,0))="F8")
  SET stat = alterlist(qual_list->positions,1)
  SET qual_list->positions[1].position_cd = cnvtreal(parameter(parmidx,1))
  SET qual_list->position_cnt = 1
 ELSE
  CALL addmessage(m_s_at_least_one_position)
 ENDIF
 SET qual_list->amd_detail_ind =  $AMD_DETAIL
 IF (( $ORDERBY=1))
  SET orderby = "CNVTLOWER(results->protocols[d.seq].person_full_name)"
  SET label->rpt_order_by_title = m_s_order_by_person
 ELSEIF (( $ORDERBY=2))
  IF (( $GROUPBY=0))
   SET orderby = "CNVTLOWER(results->protocols[d.seq].role_disp)"
  ELSE
   SET orderby = "1=1"
  ENDIF
  SET label->rpt_order_by_title = m_s_order_by_role
 ELSE
  SET orderby = "1=1"
  SET label->rpt_order_by_title = m_s_order_by_prot
 ENDIF
 SET reportlist->order_by = orderby
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
  SELECT
   pm.primary_mnemonic, pa.amendment_nbr, pa.revision_seq,
   pa.revision_nbr_txt, pr.primary_contact_ind, p.name_full_formatted,
   prorg.org_name, pr.beg_effective_dt_tm, pr.end_effective_dt_tm
   FROM prot_role pr,
    prot_master pm,
    prot_amendment pa,
    prsnl p,
    organization prorg,
    (dummyt d1  WITH seq = value(loop_cnt))
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (pm
    WHERE (((qual_list->all_protocols_ind=1)
     AND (pm.logical_domain_id=domain_reply->logical_domain_id)) OR (expand(num,nstart,(nstart+ (
     batch_size - 1)),pm.prot_master_id,qual_list->protocols[num].prot_master_id)))
     AND pm.prot_master_id > 0
     AND pm.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (pa
    WHERE pa.prot_master_id=pm.prot_master_id
     AND ((pa.amendment_status_cd=pm.prot_status_cd) OR ((qual_list->amd_detail_ind=1))) )
    JOIN (pr
    WHERE pr.prot_amendment_id=pa.prot_amendment_id
     AND (((qual_list->all_roles_ind=1)) OR (expand(num,1,qual_list->rcnt,pr.prot_role_cd,qual_list->
     roles[num].role_cd)))
     AND (((qual_list->all_roletypes_ind=1)) OR (expand(num,1,qual_list->roletype_cnt,pr
     .prot_role_type_cd,qual_list->roletypes[num].roletype_cd)))
     AND (((qual_list->all_positions_ind=1)) OR (expand(num,1,qual_list->position_cnt,pr.position_cd,
     qual_list->positions[num].position_cd))) )
    JOIN (p
    WHERE (p.person_id= Outerjoin(pr.person_id))
     AND (((qual_list->all_persons_ind=1)
     AND (p.logical_domain_id=domain_reply->logical_domain_id)) OR (expand(num,1,qual_list->
     person_cnt,p.person_id,qual_list->persons[num].person_id))) )
    JOIN (prorg
    WHERE (prorg.organization_id= Outerjoin(pr.organization_id))
     AND (((qual_list->all_organizations_ind=1)
     AND (prorg.logical_domain_id=domain_reply->logical_domain_id)) OR (expand(num,1,qual_list->
     organization_cnt,prorg.organization_id,qual_list->organizations[num].organization_id))) )
   ORDER BY cnvtlower(pm.primary_mnemonic), pa.amendment_nbr DESC, pa.revision_seq DESC,
    p.name_full_formatted, uar_get_code_display(pr.prot_role_cd), pr.end_effective_dt_tm
   HEAD REPORT
    prot_cnt = 0
   HEAD pm.prot_master_id
    prot_cnt += 1, acnt = 0
   HEAD pa.prot_amendment_id
    acnt += 1
    IF (( $AMD_DETAIL=0)
     AND acnt > 1)
     skip_amd = 1
    ELSE
     skip_amd = 0
    ENDIF
   DETAIL
    IF (skip_amd=0)
     cnt += 1
     IF (mod(cnt,10)=1)
      stat = alterlist(results->protocols,(cnt+ 9))
     ENDIF
     results->protocols[cnt].prot_master_id = pm.prot_master_id, results->protocols[cnt].
     primary_mnemonic = pm.primary_mnemonic, results->protocols[cnt].prot_amendment_id = pa
     .prot_amendment_id,
     results->protocols[cnt].amd_activation_date = pa.amendment_dt_tm, results->protocols[cnt].
     amendment_nbr = pa.amendment_nbr, results->protocols[cnt].amd_status_disp = uar_get_code_display
     (pa.amendment_status_cd),
     results->protocols[cnt].revision_nbr_txt = pa.revision_nbr_txt, results->protocols[cnt].
     revision_ind = pa.revision_ind, results->protocols[cnt].revision_seq = pa.revision_seq,
     rcnt += 1, results->protocols[cnt].role_cd = pr.prot_role_cd, results->protocols[cnt].role_disp
      = uar_get_code_display(pr.prot_role_cd),
     results->protocols[cnt].person_full_name = p.name_full_formatted, results->protocols[cnt].
     primary_contact_ind = pr.primary_contact_ind, results->protocols[cnt].role_type_disp =
     uar_get_code_display(pr.prot_role_type_cd),
     results->protocols[cnt].org_name = prorg.org_name, results->protocols[cnt].position_cd = pr
     .position_cd, results->protocols[cnt].position_disp = uar_get_code_display(pr.position_cd),
     results->protocols[cnt].role_activated_date = pr.beg_effective_dt_tm, results->protocols[cnt].
     role_inactivated_date = pr.end_effective_dt_tm
    ENDIF
   WITH nocounter
  ;end select
  SET stat = alterlist(results->protocols,cnt)
  SET results->prot_cnt = prot_cnt
 ENDIF
 SET reportlist->order_by_role_disp = "cnvtlower(results->protocols[d.seq].role_disp)"
 SET reportlist->order_by_prot_mnemonic = "cnvtlower(results->protocols[d.seq].primary_mnemonic)"
 SET reportlist->order_by_amd_nbr = " results->protocols[d.seq].amendment_nbr"
 SET reportlist->order_by_rev_seq = " results->protocols[d.seq].revision_seq"
 SUBROUTINE addmessage(smsg)
   SET msg_cnt = (size(results->messages,5)+ 1)
   SET stat = alterlist(results->messages,msg_cnt)
   SET results->messages[msg_cnt].text = smsg
 END ;Subroutine
 SET last_mod = "007"
 SET mod_date = "Nov 25, 2019"
END GO
