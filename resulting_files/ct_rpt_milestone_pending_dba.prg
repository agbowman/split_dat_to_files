CREATE PROGRAM ct_rpt_milestone_pending:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Protocols" = 0,
  "Completed Activity" = 0,
  "Pending Activities" = 0,
  "Committees" = 0,
  "Organizations" = 0,
  "Roles" = 0,
  "Output type" = 0,
  "Delimiter" = ","
  WITH outdev, protocols, comp_act,
  pending_act, committees, orgs,
  roles, out_type, delimiter
 RECORD qual_list(
   1 all_protocols_ind = i2
   1 protocol_cnt = i4
   1 protocols[*]
     2 prot_master_id = f8
   1 comp_activity_cd = f8
   1 pending_activity_cd = f8
   1 all_committees_ind = i2
   1 committee_cnt = i4
   1 committees[*]
     2 committee_id = f8
   1 all_organizations_ind = i2
   1 organization_cnt = i4
   1 organizations[*]
     2 organization_id = f8
   1 all_roles_ind = i2
   1 role_cnt = i4
   1 roles[*]
     2 role_cd = f8
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
       3 amd_status_cd = f8
       3 activities[*]
         4 activity_cd = f8
         4 sequence_nbr = i4
         4 entity_type_flag = i2
         4 responsible_party = c100
         4 completed_dt_tm = dq8
 )
 RECORD label(
   1 prot_mnemonic_header = vc
   1 amendment = vc
   1 amd_status_header = vc
   1 activity_header = vc
   1 completed_date_header = vc
   1 total_prots = vc
   1 end_of_rpt = vc
   1 revision = vc
   1 init_prot = vc
   1 not_specified = vc
   1 rpt_title = vc
   1 completed_activity = vc
   1 pending_activity = vc
   1 rep_exec_time = vc
   1 at_least_one_prot = vc
   1 at_least_one_c_o_r = vc
   1 unable_to_exec = vc
   1 no_prots = vc
   1 seperator = vc
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
 SET label->prot_mnemonic_header = uar_i18ngetmessage(i18nhandle,"PROT_MNEMONIC","Protocol Mnemonic")
 SET label->amendment = uar_i18ngetmessage(i18nhandle,"AMENDMENT","Amendment")
 SET label->amd_status_header = uar_i18ngetmessage(i18nhandle,"AMD_STATUS","Amendment Status")
 SET label->activity_header = uar_i18ngetmessage(i18nhandle,"ACTIVITY","Activity")
 SET label->completed_date_header = uar_i18ngetmessage(i18nhandle,"COMPLETED_DATE","Completed Date")
 SET label->total_prots = uar_i18ngetmessage(i18nhandle,"TOTAL_PROTS","Total Protocols:")
 SET label->end_of_rpt = uar_i18ngetmessage(i18nhandle,"END_OF_RPT","*** End of Report ***")
 SET label->revision = uar_i18ngetmessage(i18nhandle,"REVISION","Revision")
 SET label->init_prot = uar_i18ngetmessage(i18nhandle,"INIT_PROT","Initial Protocol")
 SET label->not_specified = uar_i18ngetmessage(i18nhandle,"NOT_SPECIFIED","Not specified")
 SET label->rpt_title = uar_i18ngetmessage(i18nhandle,"PENDING_MILESTONE_ACT_RPT",
  "Pending Milestone Activity Report")
 SET label->completed_activity = uar_i18ngetmessage(i18nhandle,"COMPLETED_ACT","Completed Activity:")
 SET label->pending_activity = uar_i18ngetmessage(i18nhandle,"PENDING_ACT","Pending Activity:")
 SET label->rep_exec_time = uar_i18ngetmessage(i18nhandle,"REP_EXEC_TIME","Report execution time:")
 SET label->at_least_one_prot = uar_i18ngetmessage(i18nhandle,"AT_LEAST_ONE_PROT",
  "At least one protocol must be selected.")
 SET label->at_least_one_c_o_r = uar_i18ngetmessage(i18nhandle,"AT_LEAST_ONE_C_O_R",
  "At least one committee, organization or role must be selected.")
 SET label->unable_to_exec = uar_i18ngetmessage(i18nhandle,"UNABLE_TO_EXEC",
  "Unable to execute report, the following issues were encountered:")
 SET label->no_prots = uar_i18ngetmessage(i18nhandle,"NO_PROTS",
  "There were no protocols found with pending activities for the selected criteria.")
 SET label->seperator = uar_i18ngetmessage(i18nhandle,"SEPERATOR","-")
 SET label->rpt_page = uar_i18ngetmessage(i18nhandle,"RPT_PAGE","Page:")
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE tempstr = vc WITH protect, noconstant("")
 DECLARE tmp_prot = vc WITH protect, noconstant("")
 DECLARE tmp_status = vc WITH protect, noconstant("")
 DECLARE tmp_activity = vc WITH protect, noconstant("")
 DECLARE tmp_act_date = vc WITH protect, noconstant("")
 DECLARE tmp_amd_desc = vc WITH protect, noconstant("")
 DECLARE prot_mnemonic = vc WITH protect, noconstant("")
 DECLARE offset = i4 WITH protect, noconstant(0)
 DECLARE num = i2 WITH protect, noconstant(0)
 DECLARE parmidx = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE prot_id = f8 WITH protect, noconstant(0.0)
 DECLARE added_flag = i2 WITH protect, noconstant(0)
 DECLARE add_record = i2 WITH protect, noconstant(0)
 DECLARE amd_added_flag = i2 WITH protect, noconstant(0)
 DECLARE incomp_record = i2 WITH protect, noconstant(0)
 DECLARE prot_cnt = i4 WITH protect, noconstant(0)
 DECLARE amd_cnt = i4 WITH protect, noconstant(0)
 DECLARE act_cnt = i4 WITH protect, noconstant(0)
 DECLARE nstart = i2 WITH protect, noconstant(0)
 DECLARE batch_size = i2 WITH protect, noconstant(0)
 DECLARE loop_cnt = i2 WITH protect, noconstant(0)
 DECLARE cur_list_size = i2 WITH protect, noconstant(0)
 DECLARE new_list_size = i2 WITH protect, noconstant(0)
 DECLARE superseded_cd = f8 WITH protect, noconstant(0.0)
 DECLARE activated_cd = f8 WITH protect, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(17274,"SUPERCEDED",1,superseded_cd)
 SET stat = uar_get_meaning_by_codeset(17274,"ACTIVATED",1,activated_cd)
 SET label->rep_exec_time = concat(label->rep_exec_time," ",format(cnvtdatetime(sysdate),
   "@SHORTDATETIME"))
 SET qual_list->all_protocols_ind = 0
 SET parmidx = 2
 IF (reflect(parameter(parmidx,0))="C1")
  SET cnt = 0
  SET qual_list->all_protocols_ind = 1
  SET qual_list->protocol_cnt = 0
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
 SET parmidx = 3
 SET qual_list->comp_activity_cd = cnvtreal(parameter(parmidx,1))
 IF ((qual_list->comp_activity_cd > 0.0))
  SET label->completed_activity = concat(label->completed_activity," ",uar_get_code_display(qual_list
    ->comp_activity_cd))
 ELSE
  SET label->completed_activity = concat(label->completed_activity," ",label->not_specified)
 ENDIF
 SET parmidx = 4
 SET qual_list->pending_activity_cd = cnvtreal(parameter(parmidx,1))
 IF ((qual_list->pending_activity_cd > 0.0))
  SET label->pending_activity = concat(label->pending_activity," ",uar_get_code_display(qual_list->
    pending_activity_cd))
 ELSE
  SET label->pending_activity = concat(label->pending_activity," ",label->not_specified)
 ENDIF
 SET qual_list->all_committees_ind = 0
 SET parmidx = 5
 IF (reflect(parameter(parmidx,0))="C1")
  SET cnt = 0
  SET qual_list->all_committees_ind = 1
 ELSEIF (substring(1,1,reflect(parameter(parmidx,0)))="L")
  SET cnt = 1
  WHILE (reflect(parameter(parmidx,cnt)) > " ")
    IF (mod(cnt,10)=1)
     SET stat = alterlist(qual_list->committees,(cnt+ 9))
    ENDIF
    SET qual_list->committees[cnt].committee_id = cnvtreal(parameter(parmidx,cnt))
    SET cnt += 1
  ENDWHILE
  SET cnt -= 1
  SET qual_list->committee_cnt = cnt
  SET stat = alterlist(qual_list->committees,cnt)
 ELSEIF (reflect(parameter(parmidx,0))="F8")
  SET stat = alterlist(qual_list->committees,1)
  SET qual_list->committees[1].committee_id = cnvtreal(parameter(parmidx,1))
  SET qual_list->committee_cnt = 1
 ENDIF
 SET qual_list->all_organizations_ind = 0
 SET parmidx = 6
 IF (reflect(parameter(parmidx,0))="C1")
  SET cnt = 0
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
 ENDIF
 SET qual_list->all_roles_ind = 0
 SET parmidx = 7
 IF (reflect(parameter(parmidx,0))="C1")
  SET cnt = 0
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
  SET qual_list->role_cnt = cnt
  SET stat = alterlist(qual_list->roles,cnt)
 ELSEIF (reflect(parameter(parmidx,0))="F8")
  SET stat = alterlist(qual_list->roles,1)
  SET qual_list->roles[1].role_cd = cnvtreal(parameter(parmidx,1))
  SET qual_list->role_cnt = 1
 ENDIF
 IF ((qual_list->all_committees_ind=0)
  AND (qual_list->committee_cnt=0)
  AND (qual_list->all_organizations_ind=0)
  AND (qual_list->organization_cnt=0)
  AND (qual_list->all_roles_ind=0)
  AND (qual_list->role_cnt=0))
  CALL addmessage(label->at_least_one_c_o_r)
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
   pm.primary_mnemonic, pm.prot_status_cd, pa.amendment_nbr,
   pa.revision_seq, pa.revision_nbr_txt, cm.ct_milestones_id,
   cm.activity_cd, cm.performed_dt_tm, cm.prot_role_cd
   FROM prot_master pm,
    prot_amendment pa,
    ct_milestones cm,
    organization resp_org,
    committee com,
    (dummyt d1  WITH seq = value(loop_cnt))
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (pm
    WHERE (((qual_list->all_protocols_ind=1)
     AND (pm.logical_domain_id=domain_reply->logical_domain_id)) OR (expand(num,nstart,(nstart+ (
     batch_size - 1)),pm.prot_master_id,qual_list->protocols[num].prot_master_id)))
     AND pm.prot_master_id != 0
     AND pm.end_effective_dt_tm > cnvtdatetime(sysdate))
    JOIN (pa
    WHERE pa.prot_master_id=pm.prot_master_id)
    JOIN (cm
    WHERE cm.prot_amendment_id=pa.prot_amendment_id
     AND (((cm.activity_cd=qual_list->comp_activity_cd)
     AND cm.performed_dt_tm <= cnvtdatetime(curdate,curtime)) OR ((((cm.activity_cd=qual_list->
    pending_activity_cd)) OR ((qual_list->pending_activity_cd=0)))
     AND cm.performed_dt_tm > cnvtdatetime(curdate,curtime))) )
    JOIN (com
    WHERE (com.committee_id= Outerjoin(cm.committee_id)) )
    JOIN (resp_org
    WHERE (resp_org.organization_id= Outerjoin(cm.organization_id)) )
   ORDER BY cnvtlower(pm.primary_mnemonic), pa.amendment_nbr, pa.revision_seq,
    cm.performed_dt_tm
   HEAD pm.prot_master_id
    amd_added_flag = 0, prot_cnt += 1, amd_cnt = 0,
    cnt += 1
    IF (mod(cnt,10)=1)
     stat = alterlist(results->protocols,(cnt+ 9))
    ENDIF
    results->protocols[cnt].prot_master_id = pm.prot_master_id, results->protocols[cnt].
    primary_mnemonic = pm.primary_mnemonic
   HEAD pa.prot_amendment_id
    added_flag = 0, act_cnt = 0, amd_cnt += 1,
    incomp_record = 0
    IF (mod(amd_cnt,10)=1)
     stat = alterlist(results->protocols[cnt].amendments,(amd_cnt+ 9))
    ENDIF
    results->protocols[cnt].amendments[amd_cnt].prot_amendment_id = pa.prot_amendment_id, results->
    protocols[cnt].amendments[amd_cnt].amendment_nbr = pa.amendment_nbr, results->protocols[cnt].
    amendments[amd_cnt].revision_ind = pa.revision_ind,
    results->protocols[cnt].amendments[amd_cnt].revision_nbr_txt = pa.revision_nbr_txt, results->
    protocols[cnt].amendments[amd_cnt].amd_status_cd = pa.amendment_status_cd
   DETAIL
    add_record = 0
    IF (cm.committee_id > 0
     AND (((qual_list->all_committees_ind=1)) OR (locateval(idx,1,qual_list->committee_cnt,cm
     .committee_id,qual_list->committees[idx].committee_id) > 0)) )
     add_record = 1
    ENDIF
    IF (cm.organization_id > 0
     AND (((qual_list->all_organizations_ind=1)) OR (locateval(idx,1,qual_list->organization_cnt,cm
     .organization_id,qual_list->organizations[idx].organization_id) > 0)) )
     add_record = 1
    ENDIF
    IF (cm.prot_role_cd > 0
     AND (((qual_list->all_roles_ind=1)) OR (locateval(idx,1,qual_list->role_cnt,cm.prot_role_cd,
     qual_list->roles[idx].role_cd) > 0)) )
     add_record = 1
    ENDIF
    IF ((qual_list->comp_activity_cd > 0)
     AND (qual_list->pending_activity_cd > 0)
     AND cm.performed_dt_tm > cnvtdatetime(curdate,curtime))
     incomp_record = 1, add_record = 0
    ENDIF
    IF (add_record=1)
     act_cnt += 1
     IF (mod(act_cnt,10)=1)
      stat = alterlist(results->protocols[cnt].amendments[amd_cnt].activities,(act_cnt+ 9))
     ENDIF
     results->protocols[cnt].amendments[amd_cnt].activities[act_cnt].activity_cd = cm.activity_cd,
     results->protocols[cnt].amendments[amd_cnt].activities[act_cnt].completed_dt_tm = cm
     .performed_dt_tm, results->protocols[cnt].amendments[amd_cnt].activities[act_cnt].
     entity_type_flag = cm.entity_type_flag
     IF (cm.entity_type_flag=0)
      results->protocols[cnt].amendments[amd_cnt].activities[act_cnt].responsible_party =
      uar_get_code_display(cm.prot_role_cd)
     ELSEIF (cm.entity_type_flag=1)
      results->protocols[cnt].amendments[amd_cnt].activities[act_cnt].responsible_party = resp_org
      .org_name
     ELSEIF (cm.entity_type_flag=2)
      results->protocols[cnt].amendments[amd_cnt].activities[act_cnt].responsible_party = com
      .committee_name
     ENDIF
     added_flag = 1
    ENDIF
   FOOT  pa.prot_amendment_id
    IF (((added_flag=0) OR ((qual_list->comp_activity_cd > 0)
     AND (qual_list->pending_activity_cd > 0)
     AND incomp_record=0)) )
     stat = alterlist(results->protocols[cnt].amendments[amd_cnt].activities,0)
    ELSE
     stat = alterlist(results->protocols[cnt].amendments[amd_cnt].activities,act_cnt), amd_added_flag
      = 1
    ENDIF
    IF (amd_added_flag=0)
     amd_cnt -= 1
    ENDIF
   FOOT  pm.prot_master_id
    CALL echo("TEST")
    IF (amd_added_flag=0)
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
 SET mod_date = "Nov 25, 2019"
END GO
