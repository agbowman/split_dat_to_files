CREATE PROGRAM ct_mp_get_pt_prscrn_list_page:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "JSON Request:" = ""
  WITH outdev, jsonrequest
 DECLARE g_debug_ind = i2 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 IF (validate(debug_on,0))
  IF (debug_on=1)
   SET g_debug_ind = 1
  ENDIF
 ENDIF
 FREE RECORD request
 SET stat = cnvtjsontorec( $JSONREQUEST)
 RECORD reply(
   1 prescreenlist[*]
     2 pt_prot_prescreen_id = f8
     2 prot_master_id = f8
     2 person_id = f8
     2 last_name = vc
     2 first_name = vc
     2 full_name = vc
     2 birth_dt_tm = dq8
     2 sex_cd = f8
     2 race_cd = f8
     2 prot_alias = vc
     2 screening_dt_tm = dq8
     2 screener_person_id = f8
     2 screener_full_name = vc
     2 screening_status_cd = f8
     2 screening_status_disp = vc
     2 screening_status_desc = vc
     2 screening_status_mean = c12
     2 referral_dt_tm = dq8
     2 referral_person_id = f8
     2 referral_full_name = vc
     2 comment_text = vc
     2 reason_text = vc
     2 filename = vc
     2 displayable_docs_ind = i2
     2 cur_pt_elig_tracking_id = f8
     2 open_amendment_id = f8
     2 added_via_flag = i2
     2 mrns[*]
       3 mrn = vc
       3 orgid = f8
       3 orgname = vc
       3 alias_pool_cd = f8
       3 alias_pool_disp = vc
       3 alias_pool_desc = vc
       3 alias_pool_mean = c12
   1 latest_prescreen_dt_tm = dq8
   1 latest_prescreen_person_id = f8
   1 latest_prescreen_full_name = vc
   1 pending_jobs = i2
   1 total_patients_cnt = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD person(
   1 person_list[*]
     2 person_id = f8
     2 type = i2
     2 index = i2
     2 name_full_formatted = vc
 )
 IF ( NOT (validate(pref_request,0)))
  RECORD pref_request(
    1 pref_entry = vc
  )
 ENDIF
 IF ( NOT (validate(pref_reply,0)))
  RECORD pref_reply(
    1 pref_value = i4
    1 pref_values[*]
      2 values = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD qualifiers(
   1 persons[*]
     2 person_id = f8
 )
 RECORD protocolids(
   1 protocols[*]
     2 protocolid = f8
 )
 DECLARE cur_list_cnt = i2 WITH protect, noconstant(0)
 DECLARE num = i2 WITH protect, noconstant(0)
 DECLARE nstart = i2 WITH protect, noconstant(1)
 DECLARE batch_size = i2 WITH protect, noconstant(20)
 DECLARE loop_cnt = i2 WITH protect, noconstant(0)
 DECLARE new_list_cnt = i2 WITH protect, noconstant(0)
 DECLARE i = i2 WITH protect, noconstant(0)
 DECLARE status_list_cnt = i2 WITH protect, noconstant(0)
 DECLARE protocoldoccd = f8 WITH protect, noconstant(0.0)
 DECLARE opencd = f8 WITH protect, noconstant(0.0)
 DECLARE conceptcd = f8 WITH protect, noconstant(0.0)
 DECLARE enrollingcd = f8 WITH protect, noconstant(0.0)
 DECLARE eligiblecd = f8 WITH protect, noconstant(0.0)
 DECLARE elignoverifcd = f8 WITH protect, noconstant(0.0)
 DECLARE syscancelcd = f8 WITH protect, noconstant(0.0)
 DECLARE where_status = vc WITH protect
 DECLARE temp = vc WITH protect
 DECLARE mrn_cd = f8 WITH protect, noconstant(0.0)
 DECLARE new = i2 WITH protect, noconstant(0)
 DECLARE cnt = i2 WITH protect, noconstant(0)
 DECLARE cntm = i2 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE person_cnt = i4 WITH protect, noconstant(0)
 DECLARE institution_cd = f8 WITH protect, noconstant(0.0)
 DECLARE userorgstr = vc WITH protect
 DECLARE faccnt = i2 WITH protect, noconstant(0)
 DECLARE facstr = vc WITH protect
 DECLARE bfacfound = i2 WITH protect, noconstant(0)
 DECLARE registry_cd = f8 WITH protect, noconstant(0.0)
 DECLARE cfg_yes_cd = f8 WITH protect, noconstant(0.0)
 DECLARE cfg_where = vc WITH protect
 DECLARE pendingjob = f8 WITH protect, constant(uar_get_code_by("MEANING",17917,"PENDING"))
 DECLARE cur_person_list_cnt = i4 WITH protect, noconstant(0)
 DECLARE new_person_list_cnt = i4 WITH protect, noconstant(0)
 DECLARE start_rownum = i4 WITH protect, noconstant(0)
 DECLARE end_rownum = i4 WITH protect, noconstant(0)
 DECLARE ndefaultinterest = i2 WITH protect, noconstant(0)
 DECLARE interest_where_string = vc WITH protect, noconstant("")
 DECLARE qualifier_cnt = i4 WITH protect, noconstant(0)
 DECLARE prot_master_id = f8 WITH protect, noconstant(0)
 DECLARE print_all = i2 WITH protect, noconstant(0)
 DECLARE it = i4 WITH protect, noconstant(0)
 DECLARE prescreen_type = i2 WITH protect, noconstant(0)
 DECLARE log_domain_exists_ind_pm = i2 WITH protect, noconstant(0)
 DECLARE log_domain_where_str_pm = vc WITH protect, noconstant("1=1")
 DECLARE log_domain_where_str_cfg = vc WITH protect, noconstant("1=1")
 DECLARE indx = i4 WITH protect, noconstant(0)
 SET log_domain_exists_ind_pm = checkdic("PROT_MASTER.LOGICAL_DOMAIN_ID","A",0)
 IF (log_domain_exists_ind_pm=2)
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
  SET log_domain_where_str_pm = "pm.logical_domain_id = domain_reply->logical_domain_id"
  SET log_domain_where_str_cfg = "cfg.logical_domain_id = outerjoin(domain_reply->logical_domain_id)"
 ENDIF
 RECORD user_org_reply(
   1 organizations[*]
     2 organization_id = f8
     2 confid_cd = f8
     2 confid_level = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE userorgsize = i2 WITH protect, noconstant(0)
 DECLARE orgidx = i2 WITH protect, noconstant(0)
 DECLARE orgstr = vc WITH protect
 SUBROUTINE (builduserorglist(tablestr=vc) =vc)
   EXECUTE ct_get_user_orgs  WITH replace("REPLY","USER_ORG_REPLY")
   SET userorgsize = size(user_org_reply->organizations,5)
   IF (userorgsize > 0)
    SET orgstr = build("expand(orgIdx, 1, userOrgSize, ",tablestr,
     ", user_org_reply->organizations[orgIdx]->organization_id)")
   ELSE
    SET orgstr = "1=1"
   ENDIF
   RETURN(orgstr)
 END ;Subroutine
 SET reply->status_data.status = "F"
 SET cur_list_cnt = size(request->protocols,5)
 SET loop_cnt = ceil((cnvtreal(cur_list_cnt)/ batch_size))
 SET new_list_cnt = (batch_size * loop_cnt)
 SET stat = alterlist(request->protocols,new_list_cnt)
 SET stat = uar_get_meaning_by_codeset(4,"MRN",1,mrn_cd)
 SET stat = uar_get_meaning_by_codeset(17901,"SYSCANCEL",1,syscancelcd)
 SET stat = uar_get_meaning_by_codeset(17304,"PROTOCOL",1,protocoldoccd)
 SET stat = uar_get_meaning_by_codeset(17274,"ACTIVATED",1,opencd)
 SET stat = uar_get_meaning_by_codeset(17274,"CONCEPT",1,conceptcd)
 SET stat = uar_get_meaning_by_codeset(17900,"ENROLLING",1,enrollingcd)
 SET stat = uar_get_meaning_by_codeset(17285,"ELIGIBLE",1,eligiblecd)
 SET stat = uar_get_meaning_by_codeset(17285,"ELIGNOVER",1,elignoverifcd)
 SET bstat = uar_get_meaning_by_codeset(17296,"INSTITUTION",1,institution_cd)
 SET stat = uar_get_meaning_by_codeset(17906,"REGISTRY",1,registry_cd)
 SET stat = uar_get_meaning_by_codeset(17907,"YES",1,cfg_yes_cd)
 SET stat = alterlist(protocolids->protocols,cur_list_cnt)
 FOR (i = 1 TO cur_list_cnt)
   SET protocolids->protocols[i].protocolid = request->protocols[i].protocolid
 ENDFOR
 SET i = 0
 SET prescreen_type = request->prescreen_type
 SET status_list_cnt = size(request->statuslist,5)
 CALL echo(status_list_cnt)
 IF (status_list_cnt > 0)
  FOR (i = 1 TO status_list_cnt)
   IF (i=1)
    SET where_status = build("ps.screening_status_cd in (",request->statuslist[i].status_cd)
   ELSE
    SET temp = concat(trim(where_status),",",build(request->statuslist[i].status_cd))
    SET where_status = trim(temp)
   ENDIF
   CALL echo(request->statuslist[i].status_cd)
  ENDFOR
  SET where_status = concat(where_status,")")
 ELSE
  SET where_status = "1=1"
 ENDIF
 CALL echo(where_status)
 IF ((request->view_mode=1))
  SET cfg_where = "cfg.config_value_cd != outerjoin(cfg_yes_cd)"
 ELSEIF ((request->view_mode=2))
  SET cfg_where = "cfg.config_value_cd = outerjoin(cfg_yes_cd)"
 ELSE
  SET cfg_where = "1=1"
 ENDIF
 CALL echo(cfg_where)
 IF (prescreen_type=0)
  SET interest_where_string = "1=1"
  SET reply->pending_jobs = 0
  SELECT INTO "NL:"
   cpi.ct_prescreen_job_id
   FROM ct_prescreen_job cpj,
    ct_prot_prescreen_job_info cpi,
    (dummyt d  WITH seq = value(loop_cnt))
   PLAN (d
    WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
    JOIN (cpi
    WHERE expand(num,nstart,cur_list_cnt,cpi.prot_master_id,protocolids->protocols[num].protocolid)
     AND cpi.completed_flag=0)
    JOIN (cpj
    WHERE cpj.ct_prescreen_job_id=cpi.ct_prescreen_job_id
     AND cpj.job_status_cd=pendingjob)
   DETAIL
    reply->pending_jobs = 1
   WITH nocounter, expand = 2
  ;end select
 ENDIF
 SET pref_request->pref_entry = "default_interest"
 EXECUTE ct_get_pref  WITH replace("REQUEST_STRUCT","PREF_REQUEST"), replace("REPLY","PREF_REPLY")
 CALL echo(build("pref",pref_reply->pref_value))
 IF ((pref_reply->pref_value=1))
  SET ndefaultinterest = 1
  SET interest_where_string = "cps.not_interested_ind = 0"
 ELSE
  SET ndefaultinterest = 0
  SET interest_where_string = "cps.not_interested_ind = 1"
 ENDIF
 SET cnt = 0
 SELECT INTO "nl:"
  FROM ct_pt_settings cps,
   person p
  PLAN (cps
   WHERE cps.active_ind=1
    AND parser(interest_where_string))
   JOIN (p
   WHERE p.person_id=cps.person_id
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND p.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND (p.logical_domain_id=domain_reply->logical_domain_id))
  ORDER BY cps.person_id
  DETAIL
   qualifier_cnt += 1
   IF (mod(qualifier_cnt,10)=1)
    stat = alterlist(qualifiers->persons,(qualifier_cnt+ 9))
   ENDIF
   qualifiers->persons[qualifier_cnt].person_id = cps.person_id
  WITH nocounter
 ;end select
 SET stat = alterlist(qualifiers->persons,qualifier_cnt)
 IF (ndefaultinterest=1)
  SET interest_where_string =
  "expand(it, 1 , qualifier_cnt, ps.person_id, qualifiers->persons[it].person_id)"
 ELSE
  SET interest_where_string =
  "not expand(it, 1, qualifier_cnt, ps.person_id, qualifiers->persons[it].person_id)"
 ENDIF
 SET cnt = 0
 IF ((request->org_security_ind=1))
  RECORD calling_fac_reply(
    1 skip = i2
    1 org_security_ind = i2
    1 org_security_fnd = i2
    1 facility_list[*]
      2 facility_display = vc
      2 facility_cd = f8
  )
  SET calling_fac_reply->skip = 1
  SET calling_fac_reply->org_security_ind = request->org_security_ind
  SET calling_fac_reply->org_security_fnd = 1
  EXECUTE ct_get_facility_list  WITH replace("FACILITYLIST","CALLING_FAC_REPLY")
  SET faccnt = size(calling_fac_reply->facility_list,5)
  CALL echorecord(calling_fac_reply)
  IF (faccnt > 0)
   SET facstr =
   "expand(indx, 1, facCnt, e.loc_facility_cd, calling_fac_reply->facility_list[indx].facility_cd)"
   CALL echo(facstr)
   SET bfacfound = 1
  ELSE
   SET bfacfound = 0
  ENDIF
 ENDIF
 IF ((request->page_size=0))
  SET print_all = 1
 ELSE
  SET start_rownum = ((request->page_size * (request->page_num - 1))+ 1)
  SET end_rownum = ((start_rownum+ request->page_size) - 1)
 ENDIF
 SET prot_master_id = request->protocols[1].protocolid
 CALL echo(start_rownum)
 CALL echo(end_rownum)
 SET cnt = 0
 SET stat = alterlist(reply->prescreenlist,cnt)
 CALL echo(build("bFacFound",bfacfound))
 IF (bfacfound=1)
  IF (cur_list_cnt > 0)
   FOR (i = (cur_list_cnt+ 1) TO new_list_cnt)
     SET request->protocols[i].protocolid = request->protocols[cur_list_cnt].protocolid
   ENDFOR
   SELECT
    temptable.*
    FROM (
     (
     (SELECT DISTINCT INTO "nl:"
      pt_prot_prescreen_id = ps.pt_prot_prescreen_id, prot_master_id = ps.prot_master_id, person_id
       = p.person_id,
      last_name = p.name_last, first_name = p.name_first, full_name = p.name_full_formatted,
      birth_dt_tm = p.birth_dt_tm, sex_cd = p.sex_cd, race_cd = p.race_cd,
      prot_alias = pm.primary_mnemonic, screening_dt_tm = ps.screened_dt_tm, screener_person_id = ps
      .screener_person_id,
      screening_status_cd = ps.screening_status_cd, referral_dt_tm = ps.referred_dt_tm,
      referral_person_id = ps.referred_person_id,
      comment_text = ps.comment_text, reason_text = ps.reason_text, added_via_flag = ps
      .added_via_flag,
      open_amendment_id = pra.prot_amendment_id
      FROM prot_master pm,
       person p,
       pt_prot_prescreen ps,
       prot_amendment pra,
       encounter e
      WHERE expand(num,nstart,cur_list_cnt,pm.prot_master_id,protocolids->protocols[num].protocolid)
       AND pm.end_effective_dt_tm > cnvtdatetime(sysdate)
       AND ps.prot_master_id=pm.prot_master_id
       AND ps.screening_status_cd != syscancelcd
       AND parser(where_status)
       AND p.person_id=ps.person_id
       AND p.active_ind=1
       AND e.person_id=p.person_id
       AND parser(facstr)
       AND (pra.prot_master_id= Outerjoin(pm.prot_master_id))
       AND (pra.amendment_status_cd= Outerjoin(opencd))
      WITH rdbunion, sqltype("f8","f8","f8","vc","vc",
        "vc","dq8","f8","f8","vc",
        "dq8","f8","f8","dq8","f8",
        "vc","vc","i2","f8"), expand = 2))
     temptable)
    ORDER BY cnvtupper(temptable.last_name), cnvtupper(temptable.first_name)
    HEAD temptable.pt_prot_prescreen_id
     person_cnt += 1
     IF (((person_cnt >= start_rownum
      AND person_cnt <= end_rownum) OR (print_all=1)) )
      cnt += 1
      IF (mod(cnt,50)=1)
       stat = alterlist(reply->prescreenlist,(cnt+ 50))
      ENDIF
      reply->prescreenlist[cnt].pt_prot_prescreen_id = temptable.pt_prot_prescreen_id, reply->
      prescreenlist[cnt].prot_master_id = temptable.prot_master_id, reply->prescreenlist[cnt].
      person_id = temptable.person_id,
      reply->prescreenlist[cnt].last_name = temptable.last_name, reply->prescreenlist[cnt].first_name
       = temptable.first_name, reply->prescreenlist[cnt].full_name = temptable.full_name,
      reply->prescreenlist[cnt].birth_dt_tm = temptable.birth_dt_tm, reply->prescreenlist[cnt].sex_cd
       = temptable.sex_cd, reply->prescreenlist[cnt].race_cd = temptable.race_cd,
      reply->prescreenlist[cnt].prot_alias = temptable.prot_alias, reply->prescreenlist[cnt].
      screening_dt_tm = temptable.screening_dt_tm, reply->prescreenlist[cnt].screener_person_id =
      temptable.screener_person_id,
      reply->prescreenlist[cnt].screening_status_cd = temptable.screening_status_cd, reply->
      prescreenlist[cnt].screening_status_disp = uar_get_code_display(temptable.screening_status_cd),
      reply->prescreenlist[cnt].screening_status_mean = uar_get_code_meaning(temptable
       .screening_status_cd),
      reply->prescreenlist[cnt].referral_dt_tm = temptable.referral_dt_tm, reply->prescreenlist[cnt].
      referral_person_id = temptable.referral_person_id, reply->prescreenlist[cnt].comment_text =
      temptable.comment_text,
      reply->prescreenlist[cnt].reason_text = temptable.reason_text, reply->prescreenlist[cnt].
      open_amendment_id = temptable.open_amendment_id, reply->prescreenlist[cnt].added_via_flag =
      temptable.added_via_flag
     ENDIF
    WITH nocounter, expand = 2
   ;end select
   SET stat = alterlist(request->protocols,cur_list_cnt)
   SET reply->total_patients_cnt = person_cnt
   IF (curqual=0
    AND cnt=0)
    CALL report_failure("SELECT","Z","CT_GET_PT_PRESCREEN_LIST",
     "Did not find any prescreened patients for protocol list.")
    GO TO exit_script
   ENDIF
  ENDIF
 ELSE
  IF (cur_list_cnt > 0)
   FOR (i = (cur_list_cnt+ 1) TO new_list_cnt)
     SET request->protocols[i].protocolid = request->protocols[cur_list_cnt].protocolid
   ENDFOR
   SELECT
    temptable.*
    FROM (
     (
     (SELECT DISTINCT INTO "NL:"
      pt_prot_prescreen_id = ps.pt_prot_prescreen_id, prot_master_id = ps.prot_master_id, person_id
       = p.person_id,
      last_name = p.name_last, first_name = p.name_first, full_name = p.name_full_formatted,
      birth_dt_tm = p.birth_dt_tm, sex_cd = p.sex_cd, race_cd = p.race_cd,
      prot_alias = pm.primary_mnemonic, screening_dt_tm = ps.screened_dt_tm, screener_person_id = ps
      .screener_person_id,
      screening_status_cd = ps.screening_status_cd, referral_dt_tm = ps.referred_dt_tm,
      referral_person_id = ps.referred_person_id,
      comment_text = ps.comment_text, reason_text = ps.reason_text, added_via_flag = ps
      .added_via_flag,
      open_amendment_id = pra.prot_amendment_id
      FROM prot_master pm,
       pt_prot_prescreen ps,
       prot_amendment pra,
       person p
      WHERE expand(num,nstart,cur_list_cnt,pm.prot_master_id,protocolids->protocols[num].protocolid)
       AND ps.prot_master_id=pm.prot_master_id
       AND ps.screening_status_cd != syscancelcd
       AND parser(where_status)
       AND p.person_id=ps.person_id
       AND p.active_ind=1
       AND (pra.prot_master_id= Outerjoin(pm.prot_master_id))
       AND (pra.amendment_status_cd= Outerjoin(opencd))
       AND pm.end_effective_dt_tm > cnvtdatetime(sysdate)
      WITH rdbunion, sqltype("f8","f8","f8","vc","vc",
        "vc","dq8","f8","f8","vc",
        "dq8","f8","f8","dq8","f8",
        "vc","vc","i2","f8"), expand = 2))
     temptable)
    ORDER BY cnvtupper(temptable.last_name), cnvtupper(temptable.first_name)
    HEAD temptable.pt_prot_prescreen_id
     person_cnt += 1
     IF (((person_cnt >= start_rownum
      AND person_cnt <= end_rownum) OR (print_all=1)) )
      cnt += 1
      IF (mod(cnt,50)=1)
       stat = alterlist(reply->prescreenlist,(cnt+ 50))
      ENDIF
      reply->prescreenlist[cnt].pt_prot_prescreen_id = temptable.pt_prot_prescreen_id, reply->
      prescreenlist[cnt].prot_master_id = temptable.prot_master_id, reply->prescreenlist[cnt].
      person_id = temptable.person_id,
      reply->prescreenlist[cnt].last_name = temptable.last_name, reply->prescreenlist[cnt].first_name
       = temptable.first_name, reply->prescreenlist[cnt].full_name = temptable.full_name,
      reply->prescreenlist[cnt].birth_dt_tm = temptable.birth_dt_tm, reply->prescreenlist[cnt].sex_cd
       = temptable.sex_cd, reply->prescreenlist[cnt].race_cd = temptable.race_cd,
      reply->prescreenlist[cnt].prot_alias = temptable.prot_alias, reply->prescreenlist[cnt].
      screening_dt_tm = temptable.screening_dt_tm, reply->prescreenlist[cnt].screener_person_id =
      temptable.screener_person_id,
      reply->prescreenlist[cnt].screening_status_cd = temptable.screening_status_cd, reply->
      prescreenlist[cnt].screening_status_disp = uar_get_code_display(temptable.screening_status_cd),
      reply->prescreenlist[cnt].screening_status_mean = uar_get_code_meaning(temptable
       .screening_status_cd),
      reply->prescreenlist[cnt].referral_dt_tm = temptable.referral_dt_tm, reply->prescreenlist[cnt].
      referral_person_id = temptable.referral_person_id, reply->prescreenlist[cnt].comment_text =
      temptable.comment_text,
      reply->prescreenlist[cnt].reason_text = temptable.reason_text, reply->prescreenlist[cnt].
      open_amendment_id = temptable.open_amendment_id, reply->prescreenlist[cnt].added_via_flag =
      temptable.added_via_flag
     ENDIF
    WITH nocounter
   ;end select
   SET stat = alterlist(request->protocols,cur_list_cnt)
   SET reply->total_patients_cnt = person_cnt
   IF (curqual=0
    AND cnt=0)
    CALL report_failure("SELECT","Z","CT_GET_PT_PRESCREEN_LIST",
     "Did not find any prescreened patients for protocol list.")
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 SET stat = alterlist(reply->prescreenlist,cnt)
 CALL echo(build("cnt: ",cnt))
 IF (cnt > 0)
  SET person_cnt = 0
  FOR (i = 1 TO cnt)
   IF ((reply->prescreenlist[i].screener_person_id > 0))
    SET person_cnt += 1
    SET stat = alterlist(person->person_list,person_cnt)
    SET person->person_list[person_cnt].person_id = reply->prescreenlist[i].screener_person_id
    SET person->person_list[person_cnt].index = i
    SET person->person_list[person_cnt].type = 1
   ENDIF
   IF ((reply->prescreenlist[i].referral_person_id > 0))
    SET person_cnt += 1
    SET stat = alterlist(person->person_list,person_cnt)
    SET person->person_list[person_cnt].person_id = reply->prescreenlist[i].referral_person_id
    SET person->person_list[person_cnt].index = i
    SET person->person_list[person_cnt].type = 2
   ENDIF
  ENDFOR
  IF ((reply->latest_prescreen_person_id > 0))
   SET person_cnt += 1
   SET stat = alterlist(person->person_list,person_cnt)
   SET person->person_list[person_cnt].person_id = reply->latest_prescreen_person_id
   SET person->person_list[person_cnt].index = - (1)
   SET person->person_list[person_cnt].type = 3
  ENDIF
  SET cur_list_cnt = size(person->person_list,5)
  SET loop_cnt = ceil((cnvtreal(cur_list_cnt)/ batch_size))
  SET new_list_cnt = (batch_size * loop_cnt)
  SET stat = alterlist(person->person_list,new_list_cnt)
  FOR (i = (cur_list_cnt+ 1) TO new_list_cnt)
    SET person->person_list[i].person_id = person->person_list[cur_list_cnt].person_id
  ENDFOR
  SELECT INTO "NL:"
   p.name_first, p.name_last, p.name_full_formatted,
   p.person_id
   FROM person p,
    (dummyt d  WITH seq = value(loop_cnt))
   PLAN (d
    WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
    JOIN (p
    WHERE expand(num,nstart,((nstart+ batch_size) - 1),p.person_id,person->person_list[num].person_id
     )
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
   DETAIL
    index = locateval(num,1,cur_list_cnt,p.person_id,person->person_list[num].person_id)
    WHILE (index > 0
     AND index <= cur_list_cnt)
     person->person_list[index].name_full_formatted = p.name_full_formatted,index = locateval(num,(
      index+ 1),cur_list_cnt,p.person_id,person->person_list[num].person_id)
    ENDWHILE
   WITH nocounter
  ;end select
  SET stat = alterlist(person->person_list,cur_list_cnt)
  FOR (i = 1 TO person_cnt)
    IF ((person->person_list[i].type=1))
     SET index = person->person_list[i].index
     SET reply->prescreenlist[index].screener_full_name = person->person_list[i].name_full_formatted
    ELSEIF ((person->person_list[i].type=2))
     SET index = person->person_list[i].index
     SET reply->prescreenlist[index].referral_full_name = person->person_list[i].name_full_formatted
    ELSEIF ((person->person_list[i].type=3))
     SET reply->latest_prescreen_full_name = person->person_list[i].name_full_formatted
    ENDIF
  ENDFOR
  SELECT INTO "NL:"
   pt.pt_elig_tracking_id
   FROM pt_elig_tracking pt,
    prot_amendment pa,
    prot_questionnaire pq,
    (dummyt d  WITH seq = value(cnt))
   PLAN (d)
    JOIN (pa
    WHERE (pa.prot_master_id=reply->prescreenlist[d.seq].prot_master_id))
    JOIN (pq
    WHERE pq.prot_amendment_id=pa.prot_amendment_id
     AND pq.questionnaire_type_cd=enrollingcd)
    JOIN (pt
    WHERE (pt.person_id=reply->prescreenlist[d.seq].person_id)
     AND pt.prot_questionnaire_id=pq.prot_questionnaire_id
     AND pt.elig_status_cd IN (elignoverifcd, eligiblecd))
   DETAIL
    reply->prescreenlist[d.seq].cur_pt_elig_tracking_id = pt.pt_elig_tracking_id
   WITH nocounter
  ;end select
 ENDIF
 IF (cnt > 0)
  SET cur_person_list_cnt = size(reply->prescreenlist,5)
  SET loop_cnt = ceil((cnvtreal(cur_person_list_cnt)/ batch_size))
  SET new_person_list_cnt = (batch_size * loop_cnt)
  SET stat = alterlist(reply->prescreenlist,new_person_list_cnt)
  FOR (i = (cur_person_list_cnt+ 1) TO new_person_list_cnt)
    SET reply->prescreenlist[i].person_id = reply->prescreenlist[cur_person_list_cnt].person_id
  ENDFOR
  SET num = 1
  SET nstart = 1
  SELECT INTO "NL:"
   pa.alias, pa.alias_pool_cd
   FROM person_alias pa,
    (dummyt d  WITH seq = value(loop_cnt))
   PLAN (d
    WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
    JOIN (pa
    WHERE expand(num,nstart,((nstart+ batch_size) - 1),pa.person_id,reply->prescreenlist[num].
     person_id)
     AND pa.person_alias_type_cd=mrn_cd
     AND pa.active_ind=1
     AND pa.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND pa.end_effective_dt_tm >= cnvtdatetime(sysdate))
   HEAD pa.person_id
    cntm = 0, index = 0
   DETAIL
    index = locateval(num,1,cur_person_list_cnt,pa.person_id,reply->prescreenlist[num].person_id)
    IF (index > 0)
     cntm += 1
    ENDIF
    WHILE (index > 0
     AND index <= cur_person_list_cnt)
      stat = alterlist(reply->prescreenlist[index].mrns,cntm), reply->prescreenlist[index].mrns[cntm]
      .mrn = trim(cnvtalias(pa.alias,pa.alias_pool_cd)), reply->prescreenlist[index].mrns[cntm].
      alias_pool_cd = pa.alias_pool_cd,
      reply->prescreenlist[index].mrns[cntm].alias_pool_disp = uar_get_code_display(pa.alias_pool_cd),
      index = locateval(num,(index+ 1),cur_person_list_cnt,pa.person_id,reply->prescreenlist[num].
       person_id)
    ENDWHILE
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->prescreenlist,cur_person_list_cnt)
 ENDIF
 GO TO exit_script
 SUBROUTINE (report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) =null)
   IF (opstatus="F")
    SET failed = "T"
   ENDIF
   SET reply->status_data.subeventstatus[1].operationname = trim(opname)
   SET reply->status_data.subeventstatus[1].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[1].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (g_debug_ind=1)
  CALL echorecord(reply)
 ELSE
  IF (validate(_memory_reply_string)=1)
   SET _memory_reply_string = cnvtrectojson(reply)
   CALL echorecord(reply)
  ENDIF
 ENDIF
 FREE RECORD reply
 SET last_mod = "018"
 SET mod_date = "August 09, 2022"
 FREE RECORD person
END GO
