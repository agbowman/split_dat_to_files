CREATE PROGRAM ct_get_protocol_access:dba
 PROMPT
  "Mode" = 0
  WITH mode
 IF ( NOT (validate(protlist)))
  RECORD protlist(
    1 skip = i2
    1 org_security_ind = i2
    1 org_security_fnd = i2
    1 protocol_list[*]
      2 prot_master_id = f8
      2 primary_mnemonic = vc
  )
 ENDIF
 RECORD fullprotocollist(
   1 protocol_list[*]
     2 prot_master_id = f8
     2 primary_mnemonic = vc
 )
 RECORD tempprotlist(
   1 skip = i2
   1 org_security_ind = i2
   1 org_security_fnd = i2
   1 protocol_list[*]
     2 prot_master_id = f8
     2 primary_mnemonic = vc
 )
 RECORD ct_get_pref_request(
   1 pref_entry = vc
 )
 RECORD ct_get_pref_reply(
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
 RECORD history_request(
   1 status_list[*]
     2 prot_status_cd = f8
   1 protocol_list[*]
     2 prot_master_id = f8
 )
 RECORD history_reply(
   1 protocol_list[*]
     2 prot_master_id = f8
 )
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
 FREE RECORD sac_def_pos_req
 RECORD sac_def_pos_req(
   1 personnel_id = f8
 )
 FREE RECORD sac_def_pos_list_req
 RECORD sac_def_pos_list_req(
   1 personnels[*]
     2 personnel_id = f8
 )
 FREE RECORD sac_def_pos_rep
 RECORD sac_def_pos_rep(
   1 position_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD sac_def_pos_list_rep
 RECORD sac_def_pos_list_rep(
   1 personnels[*]
     2 personnel_id = f8
     2 personnel_found = i2
     2 position_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD sac_cur_pos_rep
 RECORD sac_cur_pos_rep(
   1 position_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE getdefaultposition(null) = i2
 DECLARE getmultipledefaultpositions(null) = i2
 DECLARE getcurrentposition(null) = i2
 EXECUTE sacrtl
 SUBROUTINE getdefaultposition(null)
   DECLARE stat = i2 WITH protect
   SET stat = initrec(sac_def_pos_rep)
   SET sac_def_pos_rep->status_data.subeventstatus[1].operationname = "GetDefaultPosition"
   SET sac_def_pos_rep->status_data.subeventstatus[1].targetobjectname = "POSITION_CD"
   SELECT INTO "nl:"
    p.position_cd
    FROM prsnl p
    WHERE (p.person_id=sac_def_pos_req->personnel_id)
    DETAIL
     sac_def_pos_rep->position_cd = p.position_cd
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET sac_def_pos_rep->status_data.status = "Z"
    SET sac_def_pos_rep->status_data.subeventstatus[1].operationstatus = "Z"
    SET sac_def_pos_rep->status_data.subeventstatus[1].targetobjectvalue = build2("Personnel ID of ",
     cnvtstring(sac_def_pos_req->personnel_id,17)," does not exist.")
    RETURN(0)
   ENDIF
   IF ((sac_def_pos_rep->position_cd < 0))
    SET sac_def_pos_rep->status_data.status = "F"
    SET sac_def_pos_rep->status_data.subeventstatus[1].operationstatus = "F"
    SET sac_def_pos_rep->status_data.subeventstatus[1].targetobjectvalue = build2(
     "Invalid POSITION_CD of ",cnvtstring(sac_def_pos_rep->position_cd,17),". Value is less than 0.")
    RETURN(0)
   ENDIF
   SET sac_def_pos_rep->status_data.status = "S"
   SET sac_def_pos_rep->status_data.subeventstatus[1].operationstatus = "S"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getmultipledefaultpositions(null)
   DECLARE stat = i2 WITH protect
   SET stat = initrec(sac_def_pos_list_rep)
   SET sac_def_pos_list_rep->status_data.subeventstatus[1].operationname =
   "GetMultipleDefaultPositions"
   SET sac_def_pos_list_rep->status_data.subeventstatus[1].targetobjectname = "POSITION_CD"
   DECLARE prsnl_list_size = i4 WITH protect
   SET prsnl_list_size = size(sac_def_pos_list_req->personnels,5)
   IF (prsnl_list_size=0)
    SET sac_def_pos_list_rep->status_data.status = "F"
    SET sac_def_pos_list_rep->status_data.subeventstatus[1].operationstatus = "F"
    SET sac_def_pos_list_rep->status_data.subeventstatus[1].targetobjectvalue = build2(
     "No personnel IDs set in request list of size ",cnvtstring(prsnl_list_size))
    RETURN(0)
   ENDIF
   SET stat = alterlist(sac_def_pos_list_rep->personnels,prsnl_list_size)
   FOR (x = 1 TO prsnl_list_size)
     SET sac_def_pos_list_rep->personnels[x].personnel_id = sac_def_pos_list_req->personnels[x].
     personnel_id
     SET sac_def_pos_list_rep->personnels[x].personnel_found = 0
     SET sac_def_pos_list_rep->personnels[x].position_cd = - (1)
   ENDFOR
   DECLARE prsnl_idx = i4 WITH protect
   DECLARE expand_idx = i4 WITH protect
   DECLARE actual_idx = i4 WITH protect
   SELECT INTO "nl:"
    p.position_cd
    FROM prsnl p
    WHERE expand(prsnl_idx,1,prsnl_list_size,p.person_id,sac_def_pos_list_req->personnels[prsnl_idx].
     personnel_id)
    DETAIL
     actual_idx = locateval(expand_idx,1,prsnl_list_size,p.person_id,sac_def_pos_list_rep->
      personnels[expand_idx].personnel_id), sac_def_pos_list_rep->personnels[actual_idx].
     personnel_found = 1, sac_def_pos_list_rep->personnels[actual_idx].position_cd = p.position_cd
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET sac_def_pos_list_rep->status_data.status = "Z"
    SET sac_def_pos_list_rep->status_data.subeventstatus[1].operationstatus = "Z"
    SET sac_def_pos_list_rep->status_data.subeventstatus[1].targetobjectvalue = build2(
     "No personnels found in request list of size ",cnvtstring(prsnl_list_size))
    RETURN(0)
   ENDIF
   SET sac_def_pos_list_rep->status_data.status = "S"
   SET sac_def_pos_list_rep->status_data.subeventstatus[1].operationstatus = "S"
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getcurrentposition(null)
   DECLARE stat = i2 WITH protect
   SET stat = initrec(sac_cur_pos_rep)
   SET sac_cur_pos_rep->status_data.subeventstatus[1].operationname = "GetCurrentPosition"
   SET sac_cur_pos_rep->status_data.subeventstatus[1].targetobjectname = "POSITION_CD"
   SET sac_cur_pos_rep->status_data.status = "F"
   SET sac_cur_pos_rep->status_data.subeventstatus[1].operationstatus = "F"
   DECLARE hpositionhandle = i4 WITH protect, noconstant(0)
   DECLARE clearhandle = i4 WITH protect, noconstant(0)
   SET hpositionhandle = uar_sacgetcurrentpositions()
   IF (hpositionhandle=0)
    CALL echo("Get Position failed: Unable to get the position handle.")
    SET sac_cur_pos_rep->status_data.subeventstatus[1].targetobjectvalue =
    "Get Current Position Failed: Unable to get the position handle."
    SET clearhandle = uar_sacclosehandle(hpositionhandle)
    RETURN(0)
   ENDIF
   DECLARE positioncnt = i4 WITH protect, noconstant(0)
   SET positioncnt = uar_srvgetitemcount(hpositionhandle,nullterm("Positions"))
   IF (positioncnt != 1)
    CALL echo("Get Position failed: Position count was not exactly 1.")
    SET sac_cur_pos_rep->status_data.subeventstatus[1].targetobjectvalue = build2(
     "Get Current Position Failed: ",cnvtstring(positioncnt,1)," positions returned.")
    SET clearhandle = uar_sacclosehandle(hpositionhandle)
    RETURN(0)
   ENDIF
   DECLARE hpositionlisthandle = i4 WITH protect, noconstant(0)
   SET hpositionlisthandle = uar_srvgetitem(hpositionhandle,nullterm("Positions"),0)
   IF (hpositionlisthandle=0)
    CALL echo("Get Position item failed: Unable to retrieve current position.")
    SET sac_cur_pos_rep->status_data.subeventstatus[1].targetobjectvalue =
    "Get Current Position Failed: Unable to retrieve current position."
    SET clearhandle = uar_sacclosehandle(hpositionlisthandle)
    SET clearhandle = uar_sacclosehandle(hpositionhandle)
    RETURN(0)
   ENDIF
   SET sac_cur_pos_rep->position_cd = uar_srvgetdouble(hpositionlisthandle,nullterm("PositionCode"))
   SET sac_cur_pos_rep->status_data.status = "S"
   SET sac_cur_pos_rep->status_data.subeventstatus[1].operationstatus = "S"
   SET clearhandle = uar_sacclosehandle(hpositionlisthandle)
   SET clearhandle = uar_sacclosehandle(hpositionhandle)
   RETURN(1)
 END ;Subroutine
 IF ((protlist->skip=0))
  EXECUTE ccl_prompt_api_dataset "dataset"
 ENDIF
 DECLARE prescreen_cd = f8 WITH protect, noconstant(0.0)
 DECLARE activated_cd = f8 WITH protect, noconstant(0.0)
 DECLARE institution_cd = f8 WITH protect, noconstant(0.0)
 DECLARE prot_cnt = i2 WITH protect, noconstant(0)
 DECLARE total_prot_cnt = i2 WITH protect, noconstant(0)
 DECLARE num = i2 WITH protect, noconstant(0)
 DECLARE index = i2 WITH protect, noconstant(0)
 DECLARE modetype = i2 WITH protect, noconstant(0)
 DECLARE protocol = vc WITH protect
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE userorgstr = vc WITH protect
 DECLARE idx = i2 WITH protect, noconstant(0)
 DECLARE nstart = i2 WITH protect, noconstant(0)
 DECLARE batch_size = i2 WITH protect, noconstant(0)
 DECLARE loop_cnt = i2 WITH protect, noconstant(0)
 DECLARE cur_list_size = i2 WITH protect, noconstant(0)
 DECLARE new_list_size = i2 WITH protect, noconstant(0)
 DECLARE activestr = vc WITH protect
 DECLARE concept_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17274,"CONCEPT"))
 DECLARE discontinued_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17274,"DISCONTINUED"))
 DECLARE curprotcnt = i2 WITH protect, noconstant(0)
 DECLARE qualifiedprotcnt = i2 WITH protect, noconstant(0)
 DECLARE pos = i2 WITH protect, noconstant(0)
 SET modetype = cnvtint( $MODE)
 SET stat = uar_get_meaning_by_codeset(17311,"PRESCREEN",1,prescreen_cd)
 SET stat = uar_get_meaning_by_codeset(17274,"ACTIVATED",1,activated_cd)
 SET stat = uar_get_meaning_by_codeset(17296,"INSTITUTION",1,institution_cd)
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
 IF ((protlist->org_security_fnd=0))
  RECORD org_sec_reply(
    1 orgsecurityflag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  EXECUTE ct_get_org_security  WITH replace("REPLY","ORG_SEC_REPLY")
  CALL echo(build("org_sec_reply->OrgSecurityFlag: ",org_sec_reply->orgsecurityflag))
  SET protlist->org_security_ind = org_sec_reply->orgsecurityflag
 ENDIF
 IF ((protlist->org_security_ind=1))
  SET userorgstr = builduserorglist("pr.organization_id")
  SELECT DISTINCT INTO "nl:"
   pm.prot_master_id
   FROM prot_master pm,
    prot_amendment pa,
    prot_role pr
   PLAN (pm
    WHERE pm.primary_mnemonic > ""
     AND pm.end_effective_dt_tm > cnvtdatetime(sysdate)
     AND (pm.logical_domain_id=domain_reply->logical_domain_id))
    JOIN (pa
    WHERE pa.prot_master_id=pm.prot_master_id
     AND pa.amendment_status_cd=pm.prot_status_cd)
    JOIN (pr
    WHERE pr.prot_amendment_id=pa.prot_amendment_id
     AND pr.prot_role_type_cd=institution_cd
     AND parser(userorgstr)
     AND pr.end_effective_dt_tm >= cnvtdatetime(sysdate))
   HEAD REPORT
    total_prot_cnt = 0
   DETAIL
    total_prot_cnt += 1
    IF (mod(total_prot_cnt,10)=1)
     stat = alterlist(fullprotocollist->protocol_list,(total_prot_cnt+ 9))
    ENDIF
    fullprotocollist->protocol_list[total_prot_cnt].prot_master_id = pm.prot_master_id
   FOOT REPORT
    stat = alterlist(fullprotocollist->protocol_list,total_prot_cnt)
   WITH nocounter
  ;end select
 ELSE
  CALL echo("protList->org_security_ind = 0")
  SELECT DISTINCT INTO "nl:"
   pm.prot_master_id
   FROM prot_master pm,
    prot_amendment pa
   PLAN (pm
    WHERE pm.primary_mnemonic > ""
     AND pm.end_effective_dt_tm > cnvtdatetime(sysdate)
     AND (pm.logical_domain_id=domain_reply->logical_domain_id))
    JOIN (pa
    WHERE pa.prot_master_id=pm.prot_master_id
     AND pa.amendment_status_cd=pm.prot_status_cd)
   HEAD REPORT
    total_prot_cnt = 0
   DETAIL
    total_prot_cnt += 1
    IF (mod(total_prot_cnt,10)=1)
     stat = alterlist(fullprotocollist->protocol_list,(total_prot_cnt+ 9))
    ENDIF
    fullprotocollist->protocol_list[total_prot_cnt].prot_master_id = pm.prot_master_id
   FOOT REPORT
    stat = alterlist(fullprotocollist->protocol_list,total_prot_cnt)
   WITH nocounter
  ;end select
 ENDIF
 CALL echorecord(fullprotocollist)
 SET cur_list_size = size(fullprotocollist->protocol_list,5)
 SET batch_size = 50
 SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
 SET new_list_size = (loop_cnt * batch_size)
 SET stat = alterlist(fullprotocollist->protocol_list,new_list_size)
 SET nstart = 1
 FOR (idx = (cur_list_size+ 1) TO new_list_size)
   SET fullprotocollist->protocol_list[idx].prot_master_id = fullprotocollist->protocol_list[
   cur_list_size].prot_master_id
 ENDFOR
 SET ct_get_pref_request->pref_entry = "screener_pref"
 EXECUTE ct_get_pref  WITH replace("REQUEST_STRUCT","CT_GET_PREF_REQUEST"), replace("REPLY",
  "CT_GET_PREF_REPLY")
 IF ((ct_get_pref_reply->pref_value=2))
  SET modetype = 2
 ENDIF
 IF (modetype=0)
  SET activestr = "1=1"
 ELSEIF (modetype=2)
  SET activestr = "pm.prot_status_cd = concept_cd AND pm.screener_ind = 1 AND pm.network_flag < 2"
 ELSE
  SET activestr = "pm.prot_status_cd = activated_cd"
 ENDIF
 SELECT DISTINCT INTO "nl:"
  pm.primary_mnemonic
  FROM entity_access ea,
   prot_amendment pa,
   prot_master pm,
   (dummyt d1  WITH seq = value(loop_cnt))
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (pm
   WHERE expand(num,nstart,(nstart+ (batch_size - 1)),pm.prot_master_id,fullprotocollist->
    protocol_list[num].prot_master_id)
    AND parser(activestr)
    AND pm.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (pa
   WHERE pa.prot_master_id=pm.prot_master_id
    AND pa.amendment_status_cd=pm.prot_status_cd)
   JOIN (ea
   WHERE ea.prot_amendment_id=pa.prot_amendment_id
    AND (ea.person_id=reqinfo->updt_id)
    AND ea.functionality_cd=prescreen_cd
    AND ea.access_mask="RCUDE"
    AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
  DETAIL
   prot_cnt += 1
   IF (mod(prot_cnt,10)=1)
    stat = alterlist(protlist->protocol_list,(prot_cnt+ 9))
   ENDIF
   protlist->protocol_list[prot_cnt].prot_master_id = pm.prot_master_id, protlist->protocol_list[
   prot_cnt].primary_mnemonic = pm.primary_mnemonic
  WITH nocounter
 ;end select
 SET stat = alterlist(protlist->protocol_list,prot_cnt)
 SET stat = getcurrentposition(null)
 IF (stat)
  CALL echo(build("User's current position is ",sac_cur_pos_rep->position_cd))
 ELSE
  CALL echo(build("Default position lookup failed with status ",sac_cur_pos_rep->status_data.status))
 ENDIF
 SELECT DISTINCT INTO "nl:"
  pm.primary_mnemonic
  FROM prot_master pm,
   prot_amendment pa,
   prot_role pr,
   prot_role_access ra,
   (dummyt d1  WITH seq = value(loop_cnt))
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
   JOIN (pm
   WHERE expand(num,nstart,(nstart+ (batch_size - 1)),pm.prot_master_id,fullprotocollist->
    protocol_list[num].prot_master_id)
    AND parser(activestr)
    AND pm.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (pa
   WHERE pa.prot_master_id=pm.prot_master_id
    AND pa.amendment_status_cd=pm.prot_status_cd)
   JOIN (pr
   WHERE pr.prot_amendment_id=pa.prot_amendment_id
    AND (((pr.person_id=reqinfo->updt_id)) OR ((pr.position_cd=sac_cur_pos_rep->position_cd)))
    AND pr.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (ra
   WHERE ra.prot_role_cd=pr.prot_role_cd
    AND ra.functionality_cd=prescreen_cd
    AND ra.access_mask="RCUDE"
    AND ra.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND (ra.logical_domain_id=domain_reply->logical_domain_id))
  HEAD REPORT
   index = 0, num = 0
  DETAIL
   index = locateval(num,1,prot_cnt,pm.prot_master_id,protlist->protocol_list[num].prot_master_id)
   IF (index=0)
    prot_cnt += 1, stat = alterlist(protlist->protocol_list,prot_cnt), protlist->protocol_list[
    prot_cnt].prot_master_id = pm.prot_master_id,
    protlist->protocol_list[prot_cnt].primary_mnemonic = pm.primary_mnemonic
   ENDIF
  FOOT REPORT
   stat = alterlist(protlist->protocol_list,prot_cnt)
  WITH nocounter
 ;end select
 SET stat = alterlist(fullprotocollist->protocol_list,cur_list_size)
 CALL echorecord(protlist)
 IF (modetype=2)
  SET stat = alterlist(tempprotlist->protocol_list,prot_cnt)
  SET stat = alterlist(history_request->protocol_list,prot_cnt)
  SET tempprotlist->org_security_fnd = protlist->org_security_fnd
  SET tempprotlist->org_security_ind = protlist->org_security_ind
  SET tempprotlist->skip = protlist->skip
  SET stat = alterlist(history_request->status_list,2)
  SET stat = alterlist(history_request->protocol_list,prot_cnt)
  SET history_request->status_list[1].prot_status_cd = concept_cd
  SET history_request->status_list[2].prot_status_cd = discontinued_cd
  FOR (idx = 1 TO prot_cnt)
    SET history_request->protocol_list[idx].prot_master_id = protlist->protocol_list[idx].
    prot_master_id
    SET tempprotlist->protocol_list[idx].primary_mnemonic = protlist->protocol_list[idx].
    primary_mnemonic
    SET tempprotlist->protocol_list[idx].prot_master_id = protlist->protocol_list[idx].prot_master_id
  ENDFOR
  EXECUTE ct_get_prot_by_status_history  WITH replace("REQUEST","HISTORY_REQUEST"), replace("REPLY",
   "HISTORY_REPLY")
  SET qualifiedprotcnt = size(history_reply->protocol_list,5)
  SET stat = initrec(protlist)
  SET stat = alterlist(protlist->protocol_list,qualifiedprotcnt)
  SET protlist->org_security_fnd = tempprotlist->org_security_fnd
  SET protlist->org_security_ind = tempprotlist->org_security_ind
  SET protlist->skip = tempprotlist->skip
  FOR (idx = 1 TO qualifiedprotcnt)
    SET pos = locateval(num,1,prot_cnt,history_reply->protocol_list[idx].prot_master_id,tempprotlist
     ->protocol_list[num].prot_master_id)
    SET protlist->protocol_list[idx].primary_mnemonic = tempprotlist->protocol_list[pos].
    primary_mnemonic
    SET protlist->protocol_list[idx].prot_master_id = tempprotlist->protocol_list[pos].prot_master_id
  ENDFOR
  SET prot_cnt = qualifiedprotcnt
 ENDIF
 IF ((protlist->skip=0))
  IF (prot_cnt > 0)
   SELECT INTO "NL:"
    protocol = pm.primary_mnemonic
    FROM prot_master pm,
     (dummyt d  WITH seq = value(prot_cnt))
    PLAN (d)
     JOIN (pm
     WHERE (pm.prot_master_id=protlist->protocol_list[d.seq].prot_master_id))
    ORDER BY protocol
    HEAD REPORT
     stat = makedataset(1)
    DETAIL
     stat = writerecord(0)
    FOOT REPORT
     stat = closedataset(0), stat = setstatus("S")
    WITH nocounter, reporthelp, check
   ;end select
  ENDIF
 ENDIF
 SET last_mod = "006"
 SET mod_date = "Aug 26, 2020"
END GO
