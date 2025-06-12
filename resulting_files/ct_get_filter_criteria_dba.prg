CREATE PROGRAM ct_get_filter_criteria:dba
 RECORD reply(
   1 code_qual[*]
     2 codeset = f8
     2 value = f8
     2 display = vc
     2 meaning = vc
   1 sponsor[*]
     2 value = f8
     2 display = vc
   1 collinsti[*]
     2 value = f8
     2 display = vc
   1 peerrevw[*]
     2 value = f8
     2 display = vc
   1 mrn_cd = f8
   1 ssn_cd = f8
   1 collaborator = f8
   1 institution = f8
   1 eligible_alias_pools[*]
     2 alias_pool_cd = f8
     2 alias_pool_disp = c50
     2 alias_pool_desc = c50
     2 alias_pool_mean = c12
     2 format_mask = c100
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 debug[*]
     2 str = vc
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
 DECLARE cnt = i2 WITH protect, noconstant(0)
 DECLARE cval = f8 WITH protect, noconstant(0.0)
 DECLARE cmean = c12 WITH protect, noconstant(fillstring(12," "))
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE protaliastype_cd = f8 WITH protect, noconstant(0.0)
 DECLARE institutional_cd = f8 WITH protect, noconstant(0.0)
 DECLARE userorgsize = i2 WITH protect, noconstant(0)
 DECLARE orgidx = i4 WITH protect, noconstant(0)
 DECLARE userorgstr = vc WITH protect
 SET reply->status_data.status = "F"
 SET reply->collaborator = 0.0
 SET reply->institution = 0.0
 SET reply->mrn_cd = 0.0
 SET reply->ssn_cd = 0.0
 SET bstat = uar_get_meaning_by_codeset(4,"MRN",1,reply->mrn_cd)
 SET bstat = uar_get_meaning_by_codeset(4,"SSN",1,reply->ssn_cd)
 SET bstat = uar_get_meaning_by_codeset(17296,"INSTITUTION",1,reply->institution)
 SELECT DISTINCT INTO "nl:"
  c.code_value, c.code_set, c.display
  FROM code_value c
  WHERE c.code_set IN (17270, 17273, 17294, 17272, 17430,
  17276, 17274, 17275, 12801, 17279,
  18769)
  ORDER BY c.display
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt += 1
   IF (cnt > size(reply->code_qual,5))
    stat = alterlist(reply->code_qual,(cnt+ 5))
   ENDIF
   reply->code_qual[cnt].codeset = c.code_set, reply->code_qual[cnt].value = c.code_value, reply->
   code_qual[cnt].display = c.display,
   reply->code_qual[cnt].meaning = c.cdf_meaning,
   CALL echo(build("c.display =",c.display))
  FOOT REPORT
   stat = alterlist(reply->code_qual,cnt)
  WITH nocounter
 ;end select
 IF ((request->orgsecurity=1))
  SET userorgsize = size(request->userorgs,5)
  IF (userorgsize > 0)
   SET userorgstr =
   "expand(orgIdx, 1, userOrgSize, pr_r.organization_id, request->userOrgs[orgIdx]->organization_id)"
  ELSE
   SET userorgstr = "1=1"
  ENDIF
 ELSE
  SET userorgstr = "1=1"
 ENDIF
 CALL echo(build("userOrgStr: ",userorgstr))
 SET cnt = 0
 IF ((request->orgsecurity=1))
  SELECT DISTINCT INTO "nl:"
   pr.organization_id, o.org_name
   FROM peer_reviewer pr,
    organization o,
    prot_amendment pa,
    prot_role pr_r
   PLAN (pr_r
    WHERE pr_r.organization_id > 0.0
     AND (pr_r.prot_role_type_cd=reply->institution)
     AND pr_r.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND parser(userorgstr))
    JOIN (pa
    WHERE pa.prot_amendment_id=pr_r.prot_amendment_id)
    JOIN (pr
    WHERE pr.prot_master_id=pa.prot_master_id
     AND pr.organization_id > 0.0)
    JOIN (o
    WHERE o.organization_id=pr.organization_id
     AND (o.logical_domain_id=domain_reply->logical_domain_id))
   HEAD REPORT
    cnt = 0
   DETAIL
    CALL echo("here"), cnt += 1
    IF (cnt > size(reply->peerrevw,5))
     stat = alterlist(reply->peerrevw,(cnt+ 5))
    ENDIF
    reply->peerrevw[cnt].value = pr.organization_id, reply->peerrevw[cnt].display = o.org_name
   FOOT REPORT
    stat = alterlist(reply->peerrevw,cnt)
   WITH nocounter, expand = 2
  ;end select
  CALL echo(build("peer review count:",cnt))
 ELSE
  SELECT DISTINCT INTO "nl:"
   pr.organization_id, o.org_name
   FROM peer_reviewer pr,
    organization o
   PLAN (pr
    WHERE pr.organization_id > 0.0)
    JOIN (o
    WHERE o.organization_id=pr.organization_id
     AND (o.logical_domain_id=domain_reply->logical_domain_id))
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt += 1
    IF (cnt > size(reply->peerrevw,5))
     stat = alterlist(reply->peerrevw,(cnt+ 5))
    ENDIF
    reply->peerrevw[cnt].value = pr.organization_id, reply->peerrevw[cnt].display = o.org_name
   FOOT REPORT
    stat = alterlist(reply->peerrevw,cnt)
   WITH nocounter
  ;end select
 ENDIF
 SET cnt = 0
 IF ((request->orgsecurity=1))
  SELECT DISTINCT INTO "nl:"
   o.organization_id, o.org_name
   FROM prot_grant_sponsor pgs,
    organization o,
    prot_amendment pa,
    prot_role pr_r
   PLAN (pr_r
    WHERE pr_r.organization_id > 0.0
     AND (pr_r.prot_role_type_cd=reply->institution)
     AND pr_r.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND parser(userorgstr))
    JOIN (pa
    WHERE pa.prot_amendment_id=pr_r.prot_amendment_id)
    JOIN (pgs
    WHERE pgs.prot_amendment_id=pa.prot_amendment_id
     AND pgs.organization_id > 0.0)
    JOIN (o
    WHERE o.organization_id=pgs.organization_id
     AND (o.logical_domain_id=domain_reply->logical_domain_id))
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt += 1
    IF (cnt > size(reply->sponsor,5))
     stat = alterlist(reply->sponsor,(cnt+ 5))
    ENDIF
    reply->sponsor[cnt].value = o.organization_id, reply->sponsor[cnt].display = o.org_name
   FOOT REPORT
    stat = alterlist(reply->sponsor,cnt)
   WITH nocounter, expand = 2
  ;end select
  CALL echo(build("sponsor count:",cnt))
 ELSE
  SELECT DISTINCT INTO "nl:"
   o.organization_id, o.org_name
   FROM prot_grant_sponsor pgs,
    organization o
   PLAN (pgs
    WHERE pgs.organization_id > 0.0)
    JOIN (o
    WHERE o.organization_id=pgs.organization_id
     AND (o.logical_domain_id=domain_reply->logical_domain_id))
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt += 1
    IF (cnt > size(reply->sponsor,5))
     stat = alterlist(reply->sponsor,(cnt+ 5))
    ENDIF
    reply->sponsor[cnt].value = o.organization_id, reply->sponsor[cnt].display = o.org_name
   FOOT REPORT
    stat = alterlist(reply->sponsor,cnt)
   WITH nocounter
  ;end select
 ENDIF
 SET bstat = uar_get_meaning_by_codeset(17441,"COLLABORATOR",1,reply->collaborator)
 CALL echo("Pre collaborator select")
 SELECT DISTINCT INTO "nl:"
  o.organization_id, o.org_name
  FROM organization o,
   prot_role pr_r
  PLAN (pr_r
   WHERE pr_r.organization_id > 0.0
    AND (pr_r.prot_role_cd=reply->collaborator)
    AND (pr_r.prot_role_type_cd=reply->institution)
    AND parser(userorgstr))
   JOIN (o
   WHERE o.organization_id=pr_r.organization_id
    AND (o.logical_domain_id=domain_reply->logical_domain_id))
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt += 1
   IF (cnt > size(reply->collinsti,5))
    stat = alterlist(reply->collinsti,(cnt+ 5))
   ENDIF
   reply->collinsti[cnt].value = o.organization_id, reply->collinsti[cnt].display = o.org_name
  FOOT REPORT
   stat = alterlist(reply->collinsti,cnt)
  WITH nocounter, expand = 2
 ;end select
 CALL echo("Post collaborator select")
 SET stat = uar_get_meaning_by_codeset(17296,"INSTITUTION",1,institutional_cd)
 SET stat = uar_get_meaning_by_codeset(12801,"PROT_MASTER",1,protaliastype_cd)
 SELECT DISTINCT INTO "nl:"
  p.alias_pool_cd
  FROM alias_pool p,
   prot_role r,
   org_alias_pool_reltn oar
  PLAN (r
   WHERE r.prot_role_type_cd=institutional_cd
    AND r.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (oar
   WHERE oar.organization_id=r.organization_id
    AND oar.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND oar.alias_entity_alias_type_cd=protaliastype_cd)
   JOIN (p
   WHERE oar.alias_pool_cd=p.alias_pool_cd
    AND p.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND (p.logical_domain_id=domain_reply->logical_domain_id))
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->eligible_alias_pools,(cnt+ 9))
   ENDIF
   reply->eligible_alias_pools[cnt].alias_pool_cd = p.alias_pool_cd, reply->eligible_alias_pools[cnt]
   .format_mask = p.format_mask
  FOOT REPORT
   stat = alterlist(reply->eligible_alias_pools,cnt)
  WITH nocounter
 ;end select
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echo(build("reply->status_data->status =",reply->status_data.status))
 GO TO noecho
 CALL echo(build("INSTITUTION :",reply->institution))
 CALL echo(build("COLLABORATOR :",reply->collaborator))
 CALL echo("******************************************************************************")
 CALL echo("Colaborating Institutes")
 FOR (j = 1 TO size(reply->collinsti,5))
   CALL echo(build("    reply->COLLINSTI[",j,"]->display",reply->collinsti[j].display))
 ENDFOR
 CALL echo("******************************************************************************")
#noecho
 SET debug_code_stemp = fillstring(999," ")
 SET debug_code_ecode = 1
 SET debug_code_cntd = size(reply->debug,5)
 WHILE (debug_code_ecode != 0)
  SET debug_code_ecode = error(debug_code_stemp,0)
  IF (debug_code_ecode != 0)
   SET debug_code_cntd += 1
   SET stat = alterlist(reply->debug,debug_code_cntd)
   SET reply->debug[debug_code_cntd].str = debug_code_stemp
  ENDIF
 ENDWHILE
 SET last_mod = "006"
 SET mod_date = "May 25, 2022"
END GO
