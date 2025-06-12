CREATE PROGRAM ct_mp_get_prescreen_patient:dba
 RECORD reply(
   1 prescreenlist[*]
     2 pt_prot_prescreen_id = f8
     2 prot_master_id = f8
     2 person_id = f8
     2 added_via_flag = i2
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
   1 manually_added_column_exists = i2
   1 total_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
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
 DECLARE cur_list_cnt = i2 WITH protect, noconstant(0)
 DECLARE num = i2 WITH protect, noconstant(0)
 DECLARE num1 = i2 WITH protect, noconstant(0)
 DECLARE nstart = i2 WITH protect, noconstant(1)
 DECLARE nstart1 = i2 WITH protect, noconstant(1)
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
 DECLARE person_cnt = i2 WITH protect, noconstant(0)
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
 DECLARE manually_added_column_exists = i2 WITH protect, noconstant(0)
 DECLARE t_count = i4 WITH protect, noconstant(0)
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
   EXECUTE ct_mp_get_user_orgs  WITH replace("REPLY","USER_ORG_REPLY")
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
 SET manually_added_column_exists = checkdic("PT_PROT_PRESCREEN.ADDED_VIA_FLAG","A",0)
 SET reply->manually_added_column_exists = manually_added_column_exists
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
 IF ((request->org_security_ind=1)
  AND (request->person_id=0))
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
   FOR (indx = 1 TO faccnt)
     IF (indx=1)
      SET facstr = build(calling_fac_reply->facility_list[indx].facility_cd)
     ELSE
      SET facstr = build(facstr,", ",calling_fac_reply->facility_list[indx].facility_cd)
     ENDIF
   ENDFOR
   SET facstr = concat("e.loc_facility_cd in (",facstr,")")
   SET bfacfound = 1
  ELSE
   SET bfacfound = 0
  ENDIF
 ELSEIF ((request->org_security_ind=1)
  AND (request->person_id > 0))
  SET userorgstr = builduserorglist("pr.organization_id")
  SET bfacfound = 1
 ENDIF
 SET reply->pending_jobs = 0
 SELECT INTO "NL:"
  cpi.ct_prescreen_job_id
  FROM ct_prescreen_job cpj,
   ct_prot_prescreen_job_info cpi,
   (dummyt d  WITH seq = value(loop_cnt))
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
   JOIN (cpi
   WHERE expand(num,nstart,((nstart+ batch_size) - 1),cpi.prot_master_id,request->protocols[num].
    protocolid)
    AND cpi.completed_flag=0)
   JOIN (cpj
   WHERE cpj.ct_prescreen_job_id=cpi.ct_prescreen_job_id
    AND cpj.job_status_cd=pendingjob)
  DETAIL
   reply->pending_jobs = 1
  WITH nocounter
 ;end select
 SET cnt = 0
 SET row_num = 0
 SET t_count = 0
 SET stat = alterlist(reply->prescreenlist,cnt)
 DECLARE statuscount = i4 WITH protect, noconstant(size(request->psstatuslist,5))
 CALL echo(build("bFacFound",bfacfound))
 IF (bfacfound=1)
  IF (cur_list_cnt > 0)
   FOR (i = (cur_list_cnt+ 1) TO new_list_cnt)
     SET request->protocols[i].protocolid = request->protocols[cur_list_cnt].protocolid
   ENDFOR
   SELECT
    temp_count = count(*)
    FROM prot_master pm,
     person p,
     pt_prot_prescreen ps,
     prot_amendment pra,
     encounter e
    WHERE expand(num,nstart,((nstart+ batch_size) - 1),pm.prot_master_id,request->protocols[num].
     protocolid)
     AND expand(num1,nstart1,statuscount,ps.screening_status_cd,request->psstatuslist[num1].
     pre_status_cd)
     AND ps.prot_master_id=pm.prot_master_id
     AND ps.screening_status_cd != syscancelcd
     AND p.person_id=ps.person_id
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND p.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND e.person_id=p.person_id
     AND (pra.prot_master_id= Outerjoin(pm.prot_master_id))
     AND pm.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND (pra.amendment_status_cd= Outerjoin(opencd))
    ORDER BY ps.pt_prot_prescreen_id, e.person_id
    HEAD REPORT
     t_count = temp_count
    WITH format, nocounter
   ;end select
   SET reply->total_cnt = t_count
   IF (manually_added_column_exists=2)
    SELECT INTO "NL:"
     pst.*
     FROM (
      (
      (SELECT
       ps.pt_prot_prescreen_id, ps.prot_master_id, p.person_id,
       p.name_last, p.name_first, p.name_full_formatted,
       p.birth_dt_tm, p.sex_cd, p.race_cd,
       pm.primary_mnemonic, ps.screened_dt_tm, ps.screener_person_id,
       ps.screening_status_cd, ps.referred_dt_tm, ps.referred_person_id,
       ps.comment_text, ps.reason_text, pra.prot_amendment_id,
       ps.added_via_flag, row_num = row_number() OVER(
       ORDER BY ps.pt_prot_prescreen_id, e.person_id)
       FROM prot_master pm,
        person p,
        pt_prot_prescreen ps,
        prot_amendment pra,
        encounter e
       WHERE expand(num,nstart,((nstart+ batch_size) - 1),pm.prot_master_id,request->protocols[num].
        protocolid)
        AND expand(num1,nstart1,statuscount,ps.screening_status_cd,request->psstatuslist[num1].
        pre_status_cd)
        AND ps.prot_master_id=pm.prot_master_id
        AND ps.screening_status_cd != syscancelcd
        AND p.person_id=ps.person_id
        AND p.active_ind=1
        AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND p.end_effective_dt_tm >= cnvtdatetime(sysdate)
        AND e.person_id=p.person_id
        AND (pra.prot_master_id= Outerjoin(pm.prot_master_id))
        AND pm.end_effective_dt_tm >= cnvtdatetime(sysdate)
        AND (pra.amendment_status_cd= Outerjoin(opencd))
       ORDER BY ps.pt_prot_prescreen_id, e.person_id
       WITH sqltype("f8","f8","f8","vc","vc",
         "vc","dq8","f8","f8","vc",
         "dq8","f8","f8","dq8","f8",
         "vc","vc","f8","i2","i4")))
      pst)
     WHERE pst.row_num BETWEEN request->row_start_num AND request->row_end_num
     HEAD pst.pt_prot_prescreen_id
      CALL echo(pst.name_full_formatted), cnt += 1
      IF (mod(cnt,50)=1)
       new = (cnt+ 50), stat = alterlist(reply->prescreenlist,new)
      ENDIF
      reply->prescreenlist[cnt].pt_prot_prescreen_id = pst.pt_prot_prescreen_id, reply->
      prescreenlist[cnt].prot_master_id = pst.prot_master_id, reply->prescreenlist[cnt].person_id =
      pst.person_id,
      reply->prescreenlist[cnt].last_name = pst.name_last, reply->prescreenlist[cnt].first_name = pst
      .name_first, reply->prescreenlist[cnt].full_name = pst.name_full_formatted,
      reply->prescreenlist[cnt].birth_dt_tm = pst.birth_dt_tm, reply->prescreenlist[cnt].sex_cd = pst
      .sex_cd, reply->prescreenlist[cnt].race_cd = pst.race_cd,
      reply->prescreenlist[cnt].prot_alias = pst.primary_mnemonic, reply->prescreenlist[cnt].
      screening_dt_tm = pst.screened_dt_tm, reply->prescreenlist[cnt].screener_person_id = pst
      .screener_person_id,
      reply->prescreenlist[cnt].screening_status_cd = pst.screening_status_cd, reply->prescreenlist[
      cnt].referral_dt_tm = pst.referred_dt_tm, reply->prescreenlist[cnt].referral_person_id = pst
      .referred_person_id,
      reply->prescreenlist[cnt].comment_text = pst.comment_text, reply->prescreenlist[cnt].
      reason_text = pst.reason_text, reply->prescreenlist[cnt].open_amendment_id = pst
      .prot_amendment_id
      IF (manually_added_column_exists=2)
       reply->prescreenlist[cnt].added_via_flag = pst.added_via_flag
      ELSE
       reply->prescreenlist[cnt].added_via_flag = - (1)
      ENDIF
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "NL:"
     pst.*
     FROM (
      (
      (SELECT
       ps.pt_prot_prescreen_id, ps.prot_master_id, p.person_id,
       p.name_last, p.name_first, p.name_full_formatted,
       p.birth_dt_tm, p.sex_cd, p.race_cd,
       pm.primary_mnemonic, ps.screened_dt_tm, ps.screener_person_id,
       ps.screening_status_cd, ps.referred_dt_tm, ps.referred_person_id,
       ps.comment_text, ps.reason_text, pra.prot_amendment_id,
       row_num = row_number() OVER(
       ORDER BY ps.pt_prot_prescreen_id, e.person_id)
       FROM prot_master pm,
        person p,
        pt_prot_prescreen ps,
        prot_amendment pra,
        encounter e
       WHERE expand(num,nstart,((nstart+ batch_size) - 1),pm.prot_master_id,request->protocols[num].
        protocolid)
        AND expand(num1,nstart1,statuscount,ps.screening_status_cd,request->psstatuslist[num1].
        pre_status_cd)
        AND ps.prot_master_id=pm.prot_master_id
        AND ps.screening_status_cd != syscancelcd
        AND p.person_id=ps.person_id
        AND p.active_ind=1
        AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND p.end_effective_dt_tm >= cnvtdatetime(sysdate)
        AND e.person_id=p.person_id
        AND (pra.prot_master_id= Outerjoin(pm.prot_master_id))
        AND pm.end_effective_dt_tm >= cnvtdatetime(sysdate)
        AND (pra.amendment_status_cd= Outerjoin(opencd))
       ORDER BY ps.pt_prot_prescreen_id, e.person_id
       WITH sqltype("f8","f8","f8","vc","vc",
         "vc","dq8","f8","f8","vc",
         "dq8","f8","f8","dq8","f8",
         "vc","vc","f8","i4")))
      pst)
     WHERE pst.row_num BETWEEN request->row_start_num AND request->row_end_num
     HEAD pst.pt_prot_prescreen_id
      CALL echo(pst.name_full_formatted), cnt += 1
      IF (mod(cnt,50)=1)
       new = (cnt+ 50), stat = alterlist(reply->prescreenlist,new)
      ENDIF
      reply->prescreenlist[cnt].pt_prot_prescreen_id = pst.pt_prot_prescreen_id, reply->
      prescreenlist[cnt].prot_master_id = pst.prot_master_id, reply->prescreenlist[cnt].person_id =
      pst.person_id,
      reply->prescreenlist[cnt].last_name = pst.name_last, reply->prescreenlist[cnt].first_name = pst
      .name_first, reply->prescreenlist[cnt].full_name = pst.name_full_formatted,
      reply->prescreenlist[cnt].birth_dt_tm = pst.birth_dt_tm, reply->prescreenlist[cnt].sex_cd = pst
      .sex_cd, reply->prescreenlist[cnt].race_cd = pst.race_cd,
      reply->prescreenlist[cnt].prot_alias = pst.primary_mnemonic, reply->prescreenlist[cnt].
      screening_dt_tm = pst.screened_dt_tm, reply->prescreenlist[cnt].screener_person_id = pst
      .screener_person_id,
      reply->prescreenlist[cnt].screening_status_cd = pst.screening_status_cd, reply->prescreenlist[
      cnt].referral_dt_tm = pst.referred_dt_tm, reply->prescreenlist[cnt].referral_person_id = pst
      .referred_person_id,
      reply->prescreenlist[cnt].comment_text = pst.comment_text, reply->prescreenlist[cnt].
      reason_text = pst.reason_text, reply->prescreenlist[cnt].open_amendment_id = pst
      .prot_amendment_id,
      reply->prescreenlist[cnt].added_via_flag = - (1)
     WITH nocounter
    ;end select
   ENDIF
   SET stat = alterlist(request->protocols,cur_list_cnt)
   IF (curqual=0
    AND cnt=0)
    CALL report_failure("SELECT","Z","ct_mp_get_prescreen_patient",
     "Did not find any prescreened patients for protocol list.")
    GO TO exit_script
   ENDIF
  ELSE
   IF ((request->person_id=0))
    SET where_person = "1=1"
   ELSE
    SET where_person = build("pst.person_id = ",request->person_id)
   ENDIF
   SET status_list_cnt = size(request->statuslist,5)
   SELECT
    temp_count = count(*)
    FROM prot_master pm,
     person p,
     pt_prot_prescreen ps,
     prot_amendment pra,
     ct_document cd,
     ct_document_version cdv,
     prot_role pr,
     ct_prot_type_config cfg
    WHERE ps.prot_master_id > 0
     AND ps.screening_status_cd != syscancelcd
     AND expand(num1,nstart1,statuscount,ps.screening_status_cd,request->psstatuslist[num1].
     pre_status_cd)
     AND pm.prot_master_id=ps.prot_master_id
     AND pm.network_flag < 2
     AND p.person_id=ps.person_id
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND p.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND (pra.prot_master_id= Outerjoin(pm.prot_master_id))
     AND (pra.amendment_status_cd= Outerjoin(opencd))
     AND pm.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND (cfg.protocol_type_cd= Outerjoin(pra.participation_type_cd))
     AND (cfg.item_cd= Outerjoin(registry_cd))
     AND (cfg.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
     AND pr.prot_amendment_id=pra.prot_amendment_id
     AND pr.prot_role_type_cd=institution_cd
     AND pr.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND (cd.prot_amendment_id= Outerjoin(pra.prot_amendment_id))
     AND (cd.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
     AND (cdv.ct_document_id= Outerjoin(cd.ct_document_id))
     AND (cdv.end_effective_dt_tm>= Outerjoin(cnvtdatetime("31-dec-2100 00:00:00.00")))
     AND (cdv.display_ind= Outerjoin(1))
    ORDER BY ps.pt_prot_prescreen_id, pm.primary_mnemonic, ps.screened_dt_tm
    HEAD REPORT
     t_count = temp_count
    WITH format, nocounter
   ;end select
   SET reply->total_cnt = t_count
   IF (manually_added_column_exists=2)
    SELECT INTO "NL:"
     pst.*
     FROM (
      (
      (SELECT
       ps.pt_prot_prescreen_id, ps.prot_master_id, p.person_id,
       p.name_last, p.name_first, p.name_full_formatted,
       p.birth_dt_tm, p.sex_cd, p.race_cd,
       pm.primary_mnemonic, ps.screened_dt_tm, ps.screener_person_id,
       ps.screening_status_cd, ps.referred_dt_tm, ps.referred_person_id,
       ps.comment_text, ps.reason_text, pra.prot_amendment_id,
       ps.added_via_flag, row_num = row_number() OVER(
       ORDER BY ps.pt_prot_prescreen_id, pm.primary_mnemonic, ps.screened_dt_tm)
       FROM prot_master pm,
        person p,
        pt_prot_prescreen ps,
        prot_amendment pra,
        ct_document cd,
        ct_document_version cdv,
        prot_role pr,
        ct_prot_type_config cfg
       WHERE ps.prot_master_id > 0
        AND ps.screening_status_cd != syscancelcd
        AND expand(num1,nstart1,statuscount,ps.screening_status_cd,request->psstatuslist[num1].
        pre_status_cd)
        AND pm.prot_master_id=ps.prot_master_id
        AND pm.network_flag < 2
        AND p.person_id=ps.person_id
        AND p.active_ind=1
        AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND p.end_effective_dt_tm >= cnvtdatetime(sysdate)
        AND (pra.prot_master_id= Outerjoin(pm.prot_master_id))
        AND (pra.amendment_status_cd= Outerjoin(opencd))
        AND pm.end_effective_dt_tm >= cnvtdatetime(sysdate)
        AND (cfg.protocol_type_cd= Outerjoin(pra.participation_type_cd))
        AND (cfg.item_cd= Outerjoin(registry_cd))
        AND (cfg.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
        AND pr.prot_amendment_id=pra.prot_amendment_id
        AND pr.prot_role_type_cd=institution_cd
        AND pr.end_effective_dt_tm >= cnvtdatetime(sysdate)
        AND (cd.prot_amendment_id= Outerjoin(pra.prot_amendment_id))
        AND (cd.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
        AND (cdv.ct_document_id= Outerjoin(cd.ct_document_id))
        AND (cdv.end_effective_dt_tm>= Outerjoin(cnvtdatetime("31-dec-2100 00:00:00.00")))
        AND (cdv.display_ind= Outerjoin(1))
       ORDER BY ps.pt_prot_prescreen_id, pm.primary_mnemonic, ps.screened_dt_tm
       WITH sqltype("f8","f8","f8","vc","vc",
         "vc","dq8","f8","f8","vc",
         "dq8","f8","f8","dq8","f8",
         "vc","vc","f8","i2","i4")))
      pst)
     WHERE pst.row_num BETWEEN request->row_start_num AND request->row_end_num
     HEAD pst.pt_prot_prescreen_id
      cnt += 1
      IF (mod(cnt,50)=1)
       new = (cnt+ 50), stat = alterlist(reply->prescreenlist,new)
      ENDIF
      reply->prescreenlist[cnt].pt_prot_prescreen_id = pst.pt_prot_prescreen_id, reply->
      prescreenlist[cnt].prot_master_id = pst.prot_master_id, reply->prescreenlist[cnt].person_id =
      pst.person_id,
      reply->prescreenlist[cnt].last_name = pst.name_last, reply->prescreenlist[cnt].first_name = pst
      .name_first, reply->prescreenlist[cnt].full_name = pst.name_full_formatted,
      reply->prescreenlist[cnt].birth_dt_tm = pst.birth_dt_tm, reply->prescreenlist[cnt].sex_cd = pst
      .sex_cd, reply->prescreenlist[cnt].race_cd = pst.race_cd,
      reply->prescreenlist[cnt].prot_alias = pst.primary_mnemonic, reply->prescreenlist[cnt].
      screening_dt_tm = pst.screened_dt_tm, reply->prescreenlist[cnt].screener_person_id = pst
      .screener_person_id,
      reply->prescreenlist[cnt].screening_status_cd = pst.screening_status_cd, reply->prescreenlist[
      cnt].referral_dt_tm = pst.referred_dt_tm, reply->prescreenlist[cnt].referral_person_id = pst
      .referred_person_id,
      reply->prescreenlist[cnt].comment_text = pst.comment_text, reply->prescreenlist[cnt].
      reason_text = pst.reason_text, reply->latest_prescreen_dt_tm = pst.screened_dt_tm,
      reply->latest_prescreen_person_id = pst.screener_person_id, reply->prescreenlist[cnt].
      open_amendment_id = pst.prot_amendment_id
      IF (manually_added_column_exists=2)
       reply->prescreenlist[cnt].added_via_flag = pst.added_via_flag
      ELSE
       reply->prescreenlist[cnt].added_via_flag = - (1)
      ENDIF
     DETAIL
      IF (cdv.display_ind=1)
       reply->prescreenlist[cnt].displayable_docs_ind = 1
      ENDIF
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "NL:"
     pst.*
     FROM (
      (
      (SELECT
       ps.pt_prot_prescreen_id, ps.prot_master_id, p.person_id,
       p.name_last, p.name_first, p.name_full_formatted,
       p.birth_dt_tm, p.sex_cd, p.race_cd,
       pm.primary_mnemonic, ps.screened_dt_tm, ps.screener_person_id,
       ps.screening_status_cd, ps.referred_dt_tm, ps.referred_person_id,
       ps.comment_text, ps.reason_text, pra.prot_amendment_id,
       row_num = row_number() OVER(
       ORDER BY ps.pt_prot_prescreen_id, pm.primary_mnemonic, ps.screened_dt_tm)
       FROM prot_master pm,
        person p,
        pt_prot_prescreen ps,
        prot_amendment pra,
        ct_document cd,
        ct_document_version cdv,
        prot_role pr,
        ct_prot_type_config cfg
       WHERE ps.prot_master_id > 0
        AND ps.screening_status_cd != syscancelcd
        AND expand(num1,nstart1,statuscount,ps.screening_status_cd,request->psstatuslist[num1].
        pre_status_cd)
        AND pm.prot_master_id=ps.prot_master_id
        AND pm.network_flag < 2
        AND p.person_id=ps.person_id
        AND p.active_ind=1
        AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND p.end_effective_dt_tm >= cnvtdatetime(sysdate)
        AND (pra.prot_master_id= Outerjoin(pm.prot_master_id))
        AND (pra.amendment_status_cd= Outerjoin(opencd))
        AND pm.end_effective_dt_tm >= cnvtdatetime(sysdate)
        AND (cfg.protocol_type_cd= Outerjoin(pra.participation_type_cd))
        AND (cfg.item_cd= Outerjoin(registry_cd))
        AND (cfg.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
        AND pr.prot_amendment_id=pra.prot_amendment_id
        AND pr.prot_role_type_cd=institution_cd
        AND pr.end_effective_dt_tm >= cnvtdatetime(sysdate)
        AND (cd.prot_amendment_id= Outerjoin(pra.prot_amendment_id))
        AND (cd.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
        AND (cdv.ct_document_id= Outerjoin(cd.ct_document_id))
        AND (cdv.end_effective_dt_tm>= Outerjoin(cnvtdatetime("31-dec-2100 00:00:00.00")))
        AND (cdv.display_ind= Outerjoin(1))
       ORDER BY ps.pt_prot_prescreen_id, pm.primary_mnemonic, ps.screened_dt_tm
       WITH sqltype("f8","f8","f8","vc","vc",
         "vc","dq8","f8","f8","vc",
         "dq8","f8","f8","dq8","f8",
         "vc","vc","f8","i4")))
      pst)
     WHERE pst.row_num BETWEEN request->row_start_num AND request->row_end_num
     HEAD pst.pt_prot_prescreen_id
      cnt += 1
      IF (mod(cnt,50)=1)
       new = (cnt+ 50), stat = alterlist(reply->prescreenlist,new)
      ENDIF
      reply->prescreenlist[cnt].pt_prot_prescreen_id = pst.pt_prot_prescreen_id, reply->
      prescreenlist[cnt].prot_master_id = pst.prot_master_id, reply->prescreenlist[cnt].person_id =
      pst.person_id,
      reply->prescreenlist[cnt].last_name = pst.name_last, reply->prescreenlist[cnt].first_name = pst
      .name_first, reply->prescreenlist[cnt].full_name = pst.name_full_formatted,
      reply->prescreenlist[cnt].birth_dt_tm = pst.birth_dt_tm, reply->prescreenlist[cnt].sex_cd = pst
      .sex_cd, reply->prescreenlist[cnt].race_cd = pst.race_cd,
      reply->prescreenlist[cnt].prot_alias = pst.primary_mnemonic, reply->prescreenlist[cnt].
      screening_dt_tm = pst.screened_dt_tm, reply->prescreenlist[cnt].screener_person_id = pst
      .screener_person_id,
      reply->prescreenlist[cnt].screening_status_cd = pst.screening_status_cd, reply->prescreenlist[
      cnt].referral_dt_tm = pst.referred_dt_tm, reply->prescreenlist[cnt].referral_person_id = pst
      .referred_person_id,
      reply->prescreenlist[cnt].comment_text = pst.comment_text, reply->prescreenlist[cnt].
      reason_text = pst.reason_text, reply->latest_prescreen_dt_tm = pst.screened_dt_tm,
      reply->latest_prescreen_person_id = pst.screener_person_id, reply->prescreenlist[cnt].
      open_amendment_id = pst.prot_amendment_id, reply->prescreenlist[cnt].added_via_flag = - (1)
     DETAIL
      IF (cdv.display_ind=1)
       reply->prescreenlist[cnt].displayable_docs_ind = 1
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF (curqual=0
    AND cnt=0)
    CALL report_failure("SELECT","Z","ct_mp_get_prescreen_patient",
     "Did not find any prescreened protocols for patient.")
    GO TO exit_script
   ENDIF
  ENDIF
 ELSE
  IF (cur_list_cnt > 0)
   FOR (i = (cur_list_cnt+ 1) TO new_list_cnt)
     SET request->protocols[i].protocolid = request->protocols[cur_list_cnt].protocolid
   ENDFOR
   SELECT
    temp_count = count(*)
    FROM prot_master pm,
     person p,
     pt_prot_prescreen ps,
     prot_amendment pra
    WHERE expand(num,nstart,((nstart+ batch_size) - 1),pm.prot_master_id,request->protocols[num].
     protocolid)
     AND expand(num1,nstart1,statuscount,ps.screening_status_cd,request->psstatuslist[num1].
     pre_status_cd)
     AND ps.prot_master_id=pm.prot_master_id
     AND ps.screening_status_cd != syscancelcd
     AND p.person_id=ps.person_id
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND p.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND (pra.prot_master_id= Outerjoin(pm.prot_master_id))
     AND (pra.amendment_status_cd= Outerjoin(opencd))
     AND pm.end_effective_dt_tm >= cnvtdatetime(sysdate)
    ORDER BY ps.pt_prot_prescreen_id, p.person_id
    HEAD REPORT
     t_count = temp_count
    WITH format, nocounter
   ;end select
   SET reply->total_cnt = t_count
   IF (manually_added_column_exists=2)
    SELECT INTO "NL:"
     pst.*
     FROM (
      (
      (SELECT
       ps.pt_prot_prescreen_id, ps.prot_master_id, p.person_id,
       p.name_last, p.name_first, p.name_full_formatted,
       p.birth_dt_tm, p.sex_cd, p.race_cd,
       pm.primary_mnemonic, ps.screened_dt_tm, ps.screener_person_id,
       ps.screening_status_cd, ps.referred_dt_tm, ps.referred_person_id,
       ps.comment_text, ps.reason_text, pra.prot_amendment_id,
       ps.added_via_flag, row_num = row_number() OVER(
       ORDER BY ps.pt_prot_prescreen_id, p.person_id)
       FROM prot_master pm,
        person p,
        pt_prot_prescreen ps,
        prot_amendment pra
       WHERE expand(num,nstart,((nstart+ batch_size) - 1),pm.prot_master_id,request->protocols[num].
        protocolid)
        AND expand(num1,nstart1,statuscount,ps.screening_status_cd,request->psstatuslist[num1].
        pre_status_cd)
        AND ps.prot_master_id=pm.prot_master_id
        AND ps.screening_status_cd != syscancelcd
        AND p.person_id=ps.person_id
        AND p.active_ind=1
        AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND p.end_effective_dt_tm >= cnvtdatetime(sysdate)
        AND (pra.prot_master_id= Outerjoin(pm.prot_master_id))
        AND (pra.amendment_status_cd= Outerjoin(opencd))
        AND pm.end_effective_dt_tm >= cnvtdatetime(sysdate)
       ORDER BY ps.pt_prot_prescreen_id, p.person_id
       WITH sqltype("f8","f8","f8","vc","vc",
         "vc","dq8","f8","f8","vc",
         "dq8","f8","f8","dq8","f8",
         "vc","vc","f8","i2","i4")))
      pst)
     WHERE pst.row_num BETWEEN request->row_start_num AND request->row_end_num
     HEAD pst.pt_prot_prescreen_id
      CALL echo(pst.name_full_formatted), cnt += 1
      IF (mod(cnt,50)=1)
       new = (cnt+ 50), stat = alterlist(reply->prescreenlist,new)
      ENDIF
      reply->prescreenlist[cnt].pt_prot_prescreen_id = pst.pt_prot_prescreen_id, reply->
      prescreenlist[cnt].prot_master_id = pst.prot_master_id, reply->prescreenlist[cnt].person_id =
      pst.person_id,
      reply->prescreenlist[cnt].last_name = pst.name_last, reply->prescreenlist[cnt].first_name = pst
      .name_first, reply->prescreenlist[cnt].full_name = pst.name_full_formatted,
      reply->prescreenlist[cnt].birth_dt_tm = pst.birth_dt_tm, reply->prescreenlist[cnt].sex_cd = pst
      .sex_cd, reply->prescreenlist[cnt].race_cd = pst.race_cd,
      reply->prescreenlist[cnt].prot_alias = pst.primary_mnemonic, reply->prescreenlist[cnt].
      screening_dt_tm = pst.screened_dt_tm, reply->prescreenlist[cnt].screener_person_id = pst
      .screener_person_id,
      reply->prescreenlist[cnt].screening_status_cd = pst.screening_status_cd, reply->prescreenlist[
      cnt].referral_dt_tm = pst.referred_dt_tm, reply->prescreenlist[cnt].referral_person_id = pst
      .referred_person_id,
      reply->prescreenlist[cnt].comment_text = pst.comment_text, reply->prescreenlist[cnt].
      reason_text = pst.reason_text, reply->prescreenlist[cnt].open_amendment_id = pst
      .prot_amendment_id
      IF (manually_added_column_exists=2)
       reply->prescreenlist[cnt].added_via_flag = pst.added_via_flag
      ELSE
       reply->prescreenlist[cnt].added_via_flag = - (1)
      ENDIF
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "NL:"
     pst.*
     FROM (
      (
      (SELECT
       ps.pt_prot_prescreen_id, ps.prot_master_id, p.person_id,
       p.name_last, p.name_first, p.name_full_formatted,
       p.birth_dt_tm, p.sex_cd, p.race_cd,
       pm.primary_mnemonic, ps.screened_dt_tm, ps.screener_person_id,
       ps.screening_status_cd, ps.referred_dt_tm, ps.referred_person_id,
       ps.comment_text, ps.reason_text, pra.prot_amendment_id,
       row_num = row_number() OVER(
       ORDER BY ps.pt_prot_prescreen_id, p.person_id)
       FROM prot_master pm,
        person p,
        pt_prot_prescreen ps,
        prot_amendment pra
       WHERE expand(num,nstart,((nstart+ batch_size) - 1),pm.prot_master_id,request->protocols[num].
        protocolid)
        AND expand(num1,nstart1,statuscount,ps.screening_status_cd,request->psstatuslist[num1].
        pre_status_cd)
        AND ps.prot_master_id=pm.prot_master_id
        AND ps.screening_status_cd != syscancelcd
        AND p.person_id=ps.person_id
        AND p.active_ind=1
        AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND p.end_effective_dt_tm >= cnvtdatetime(sysdate)
        AND (pra.prot_master_id= Outerjoin(pm.prot_master_id))
        AND (pra.amendment_status_cd= Outerjoin(opencd))
        AND pm.end_effective_dt_tm >= cnvtdatetime(sysdate)
       ORDER BY ps.pt_prot_prescreen_id, p.person_id
       WITH sqltype("f8","f8","f8","vc","vc",
         "vc","dq8","f8","f8","vc",
         "dq8","f8","f8","dq8","f8",
         "vc","vc","f8","i4")))
      pst)
     WHERE pst.row_num BETWEEN request->row_start_num AND request->row_end_num
     HEAD pst.pt_prot_prescreen_id
      CALL echo(pst.name_full_formatted), cnt += 1
      IF (mod(cnt,50)=1)
       new = (cnt+ 50), stat = alterlist(reply->prescreenlist,new)
      ENDIF
      reply->prescreenlist[cnt].pt_prot_prescreen_id = pst.pt_prot_prescreen_id, reply->
      prescreenlist[cnt].prot_master_id = pst.prot_master_id, reply->prescreenlist[cnt].person_id =
      pst.person_id,
      reply->prescreenlist[cnt].last_name = pst.name_last, reply->prescreenlist[cnt].first_name = pst
      .name_first, reply->prescreenlist[cnt].full_name = pst.name_full_formatted,
      reply->prescreenlist[cnt].birth_dt_tm = pst.birth_dt_tm, reply->prescreenlist[cnt].sex_cd = pst
      .sex_cd, reply->prescreenlist[cnt].race_cd = pst.race_cd,
      reply->prescreenlist[cnt].prot_alias = pst.primary_mnemonic, reply->prescreenlist[cnt].
      screening_dt_tm = pst.screened_dt_tm, reply->prescreenlist[cnt].screener_person_id = pst
      .screener_person_id,
      reply->prescreenlist[cnt].screening_status_cd = pst.screening_status_cd, reply->prescreenlist[
      cnt].referral_dt_tm = pst.referred_dt_tm, reply->prescreenlist[cnt].referral_person_id = pst
      .referred_person_id,
      reply->prescreenlist[cnt].comment_text = pst.comment_text, reply->prescreenlist[cnt].
      reason_text = pst.reason_text, reply->prescreenlist[cnt].open_amendment_id = pst
      .prot_amendment_id,
      reply->prescreenlist[cnt].added_via_flag = - (1)
     WITH nocounter
    ;end select
   ENDIF
   SET stat = alterlist(request->protocols,cur_list_cnt)
   IF (curqual=0
    AND cnt=0)
    CALL report_failure("SELECT","Z","ct_mp_get_prescreen_patient",
     "Did not find any prescreened patients for protocol list.")
    GO TO exit_script
   ENDIF
  ELSE
   IF ((request->person_id=0))
    SET where_person = "1=1"
   ELSE
    SET where_person = build("pst.person_id = ",request->person_id)
   ENDIF
   SET status_list_cnt = size(request->statuslist,5)
   SELECT
    temp_count = count(*)
    FROM prot_master pm,
     person p,
     pt_prot_prescreen ps,
     prot_amendment pra,
     ct_document cd,
     ct_document_version cdv,
     ct_prot_type_config cfg
    WHERE ps.prot_master_id > 0
     AND ps.screening_status_cd != syscancelcd
     AND expand(num1,nstart1,statuscount,ps.screening_status_cd,request->psstatuslist[num1].
     pre_status_cd)
     AND pm.prot_master_id=ps.prot_master_id
     AND pm.network_flag < 2
     AND pm.display_ind=1
     AND p.person_id=ps.person_id
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND p.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND (pra.prot_master_id= Outerjoin(pm.prot_master_id))
     AND (pra.amendment_status_cd= Outerjoin(pm.prot_status_cd))
     AND pm.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND (cfg.protocol_type_cd= Outerjoin(pra.participation_type_cd))
     AND (cfg.item_cd= Outerjoin(registry_cd))
     AND (cfg.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
     AND (cd.prot_amendment_id= Outerjoin(pra.prot_amendment_id))
     AND (cd.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
     AND (cdv.ct_document_id= Outerjoin(cd.ct_document_id))
     AND (cdv.end_effective_dt_tm>= Outerjoin(cnvtdatetime("31-dec-2100 00:00:00.00")))
     AND (cdv.display_ind= Outerjoin(1))
    ORDER BY ps.pt_prot_prescreen_id, pm.primary_mnemonic, ps.screened_dt_tm
    HEAD REPORT
     t_count = temp_count
    WITH format, nocounter
   ;end select
   SET reply->total_cnt = t_count
   IF (manually_added_column_exists=2)
    SELECT INTO "NL:"
     pst.*
     FROM (
      (
      (SELECT
       ps.pt_prot_prescreen_id, ps.prot_master_id, p.person_id,
       p.name_last, p.name_first, p.name_full_formatted,
       p.birth_dt_tm, p.sex_cd, p.race_cd,
       pm.primary_mnemonic, ps.screened_dt_tm, ps.screener_person_id,
       ps.screening_status_cd, ps.referred_dt_tm, ps.referred_person_id,
       ps.comment_text, ps.reason_text, pra.prot_amendment_id,
       ps.added_via_flag, pra.amendment_status_cd, row_num = row_number() OVER(
       ORDER BY ps.pt_prot_prescreen_id, pm.primary_mnemonic, ps.screened_dt_tm)
       FROM prot_master pm,
        person p,
        pt_prot_prescreen ps,
        prot_amendment pra,
        ct_document cd,
        ct_document_version cdv,
        ct_prot_type_config cfg
       WHERE ps.prot_master_id > 0
        AND ps.screening_status_cd != syscancelcd
        AND expand(num1,nstart1,statuscount,ps.screening_status_cd,request->psstatuslist[num1].
        pre_status_cd)
        AND pm.prot_master_id=ps.prot_master_id
        AND pm.network_flag < 2
        AND pm.display_ind=1
        AND p.person_id=ps.person_id
        AND p.active_ind=1
        AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND p.end_effective_dt_tm >= cnvtdatetime(sysdate)
        AND (pra.prot_master_id= Outerjoin(pm.prot_master_id))
        AND (pra.amendment_status_cd= Outerjoin(pm.prot_status_cd))
        AND pm.end_effective_dt_tm >= cnvtdatetime(sysdate)
        AND (cfg.protocol_type_cd= Outerjoin(pra.participation_type_cd))
        AND (cfg.item_cd= Outerjoin(registry_cd))
        AND (cfg.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
        AND (cd.prot_amendment_id= Outerjoin(pra.prot_amendment_id))
        AND (cd.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
        AND (cdv.ct_document_id= Outerjoin(cd.ct_document_id))
        AND (cdv.end_effective_dt_tm>= Outerjoin(cnvtdatetime("31-dec-2100 00:00:00.00")))
        AND (cdv.display_ind= Outerjoin(1))
       ORDER BY ps.pt_prot_prescreen_id, pm.primary_mnemonic, ps.screened_dt_tm
       WITH sqltype("f8","f8","f8","vc","vc",
         "vc","dq8","f8","f8","vc",
         "dq8","f8","f8","dq8","f8",
         "vc","vc","f8","i2","f8",
         "i4")))
      pst)
     WHERE pst.row_num BETWEEN request->row_start_num AND request->row_end_num
     HEAD pst.pt_prot_prescreen_id
      cnt += 1
      IF (mod(cnt,50)=1)
       new = (cnt+ 50), stat = alterlist(reply->prescreenlist,new)
      ENDIF
      reply->prescreenlist[cnt].pt_prot_prescreen_id = pst.pt_prot_prescreen_id, reply->
      prescreenlist[cnt].prot_master_id = pst.prot_master_id, reply->prescreenlist[cnt].person_id =
      pst.person_id,
      reply->prescreenlist[cnt].last_name = pst.name_last, reply->prescreenlist[cnt].first_name = pst
      .name_first, reply->prescreenlist[cnt].full_name = pst.name_full_formatted,
      reply->prescreenlist[cnt].birth_dt_tm = pst.birth_dt_tm, reply->prescreenlist[cnt].sex_cd = pst
      .sex_cd, reply->prescreenlist[cnt].race_cd = pst.race_cd,
      reply->prescreenlist[cnt].prot_alias = pst.primary_mnemonic, reply->prescreenlist[cnt].
      screening_dt_tm = pst.screened_dt_tm, reply->prescreenlist[cnt].screener_person_id = pst
      .screener_person_id,
      reply->prescreenlist[cnt].screening_status_cd = pst.screening_status_cd, reply->prescreenlist[
      cnt].referral_dt_tm = pst.referred_dt_tm, reply->prescreenlist[cnt].referral_person_id = pst
      .referred_person_id,
      reply->prescreenlist[cnt].comment_text = pst.comment_text, reply->prescreenlist[cnt].
      reason_text = pst.reason_text
      IF (manually_added_column_exists=2)
       reply->prescreenlist[cnt].added_via_flag = pst.added_via_flag
      ELSE
       reply->prescreenlist[cnt].added_via_flag = - (1)
      ENDIF
      reply->latest_prescreen_dt_tm = pst.screened_dt_tm, reply->latest_prescreen_person_id = pst
      .screener_person_id
      IF (((pst.amendment_status_cd=opencd) OR (pst.amendment_status_cd=conceptcd)) )
       reply->prescreenlist[cnt].open_amendment_id = pst.prot_amendment_id
      ENDIF
     DETAIL
      IF (cdv.display_ind=1)
       reply->prescreenlist[cnt].displayable_docs_ind = 1
      ENDIF
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "NL:"
     pst.*
     FROM (
      (
      (SELECT
       ps.pt_prot_prescreen_id, ps.prot_master_id, p.person_id,
       p.name_last, p.name_first, p.name_full_formatted,
       p.birth_dt_tm, p.sex_cd, p.race_cd,
       pm.primary_mnemonic, ps.screened_dt_tm, ps.screener_person_id,
       ps.screening_status_cd, ps.referred_dt_tm, ps.referred_person_id,
       ps.comment_text, ps.reason_text, pra.prot_amendment_id,
       pra.amendment_status_cd, row_num = row_number() OVER(
       ORDER BY ps.pt_prot_prescreen_id, pm.primary_mnemonic, ps.screened_dt_tm)
       FROM prot_master pm,
        person p,
        pt_prot_prescreen ps,
        prot_amendment pra,
        ct_document cd,
        ct_document_version cdv,
        ct_prot_type_config cfg
       WHERE ps.prot_master_id > 0
        AND ps.screening_status_cd != syscancelcd
        AND expand(num1,nstart1,statuscount,ps.screening_status_cd,request->psstatuslist[num1].
        pre_status_cd)
        AND pm.prot_master_id=ps.prot_master_id
        AND pm.network_flag < 2
        AND pm.display_ind=1
        AND p.person_id=ps.person_id
        AND p.active_ind=1
        AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND p.end_effective_dt_tm >= cnvtdatetime(sysdate)
        AND (pra.prot_master_id= Outerjoin(pm.prot_master_id))
        AND (pra.amendment_status_cd= Outerjoin(pm.prot_status_cd))
        AND pm.end_effective_dt_tm >= cnvtdatetime(sysdate)
        AND (cfg.protocol_type_cd= Outerjoin(pra.participation_type_cd))
        AND (cfg.item_cd= Outerjoin(registry_cd))
        AND (cfg.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
        AND (cd.prot_amendment_id= Outerjoin(pra.prot_amendment_id))
        AND (cd.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
        AND (cdv.ct_document_id= Outerjoin(cd.ct_document_id))
        AND (cdv.end_effective_dt_tm>= Outerjoin(cnvtdatetime("31-dec-2100 00:00:00.00")))
        AND (cdv.display_ind= Outerjoin(1))
       ORDER BY ps.pt_prot_prescreen_id, pm.primary_mnemonic, ps.screened_dt_tm
       WITH sqltype("f8","f8","f8","vc","vc",
         "vc","dq8","f8","f8","vc",
         "dq8","f8","f8","dq8","f8",
         "vc","vc","f8","f8","i4")))
      pst)
     WHERE pst.row_num BETWEEN request->row_start_num AND request->row_end_num
     HEAD pst.pt_prot_prescreen_id
      cnt += 1
      IF (mod(cnt,50)=1)
       new = (cnt+ 50), stat = alterlist(reply->prescreenlist,new)
      ENDIF
      reply->prescreenlist[cnt].pt_prot_prescreen_id = pst.pt_prot_prescreen_id, reply->
      prescreenlist[cnt].prot_master_id = pst.prot_master_id, reply->prescreenlist[cnt].person_id =
      pst.person_id,
      reply->prescreenlist[cnt].last_name = pst.name_last, reply->prescreenlist[cnt].first_name = pst
      .name_first, reply->prescreenlist[cnt].full_name = pst.name_full_formatted,
      reply->prescreenlist[cnt].birth_dt_tm = pst.birth_dt_tm, reply->prescreenlist[cnt].sex_cd = pst
      .sex_cd, reply->prescreenlist[cnt].race_cd = pst.race_cd,
      reply->prescreenlist[cnt].prot_alias = pst.primary_mnemonic, reply->prescreenlist[cnt].
      screening_dt_tm = pst.screened_dt_tm, reply->prescreenlist[cnt].screener_person_id = pst
      .screener_person_id,
      reply->prescreenlist[cnt].screening_status_cd = pst.screening_status_cd, reply->prescreenlist[
      cnt].referral_dt_tm = pst.referred_dt_tm, reply->prescreenlist[cnt].referral_person_id = pst
      .referred_person_id,
      reply->prescreenlist[cnt].comment_text = pst.comment_text, reply->prescreenlist[cnt].
      reason_text = pst.reason_text, reply->prescreenlist[cnt].added_via_flag = - (1),
      reply->latest_prescreen_dt_tm = pst.screened_dt_tm, reply->latest_prescreen_person_id = pst
      .screener_person_id
      IF (((pst.amendment_status_cd=opencd) OR (pst.amendment_status_cd=conceptcd)) )
       reply->prescreenlist[cnt].open_amendment_id = pst.prot_amendment_id
      ENDIF
     DETAIL
      IF (cdv.display_ind=1)
       reply->prescreenlist[cnt].displayable_docs_ind = 1
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF (curqual=0
    AND cnt=0)
    CALL report_failure("SELECT","Z","ct_mp_get_prescreen_patient",
     "Did not find any prescreened protocols for patient.")
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
      .mrn = pa.alias, reply->prescreenlist[index].mrns[cntm].alias_pool_cd = pa.alias_pool_cd,
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
 SET last_mod = "014"
 SET mod_date = "January 19, 2018"
 FREE RECORD person
END GO
