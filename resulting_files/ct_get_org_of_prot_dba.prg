CREATE PROGRAM ct_get_org_of_prot:dba
 RECORD reply(
   1 orgs[*]
     2 datebeg = dq8
     2 dateend = dq8
     2 amendmentid = f8
     2 orgid = f8
     2 orgname = vc
     2 active = i2
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
 DECLARE c = i2 WITH protect, noconstant(0)
 DECLARE x = i2 WITH protect, noconstant(0)
 DECLARE false = i2 WITH protect, constant(0)
 DECLARE true = i2 WITH protect, constant(- (1))
 DECLARE active = i2 WITH protect, noconstant(- (1))
 DECLARE institution = f8 WITH protect, noconstant(0.00)
 DECLARE userorgstr = vc WITH protect
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE highestamdnbr = i2 WITH protect, noconstant(0)
 DECLARE highestamdid = f8 WITH protect, noconstant(0.0)
 DECLARE pmid = f8 WITH protect, noconstant(0.0)
 SET bstat = uar_get_meaning_by_codeset(17296,"INSTITUTION",1,institution)
 SET highestamdnbr = 0.0
 SET highestamdid = 0.0
 SET pmid = request->protocolid
 EXECUTE ct_get_highest_a_nbr
 IF ((request->orgsecurity=1))
  SET userorgstr = builduserorglist("p.organization_id")
 ELSE
  SET userorgstr = "1=1"
 ENDIF
 CALL echo(build("userOrgStr: ",userorgstr))
 IF ((request->getinactivealso=false))
  SELECT INTO "nl:"
   p.*, o.organization_id, o.org_name
   FROM prot_role p,
    organization o
   PLAN (p
    WHERE p.prot_amendment_id=highestamdid
     AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND p.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND p.prot_role_type_cd=institution
     AND parser(userorgstr))
    JOIN (o
    WHERE o.organization_id=p.organization_id
     AND o.active_ind=1
     AND o.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND o.end_effective_dt_tm >= cnvtdatetime(sysdate))
   DETAIL
    active = true
    IF (p.beg_effective_dt_tm > cnvtdatetime(sysdate))
     active = false
    ELSE
     IF (p.end_effective_dt_tm < cnvtdatetime(sysdate))
      active = false
     ENDIF
    ENDIF
    IF (active=true)
     c += 1
     IF (mod(c,10)=1)
      stat = alterlist(reply->orgs,(c+ 10))
     ENDIF
     reply->orgs[c].datebeg = p.beg_effective_dt_tm, reply->orgs[c].dateend = p.end_effective_dt_tm,
     reply->orgs[c].amendmentid = p.prot_amendment_id,
     reply->orgs[c].orgid = o.organization_id, reply->orgs[c].orgname = o.org_name, reply->orgs[c].
     active = active
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   p.*, o.organization_id, o.org_name
   FROM prot_role p,
    organization o,
    prot_amendment pr_am
   PLAN (pr_am
    WHERE (pr_am.prot_master_id=request->protocolid))
    JOIN (p
    WHERE p.prot_amendment_id=pr_am.prot_amendment_id
     AND p.prot_role_type_cd=institution
     AND parser(userorgstr))
    JOIN (o
    WHERE o.organization_id=p.organization_id
     AND o.active_ind=1
     AND o.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND o.end_effective_dt_tm >= cnvtdatetime(sysdate))
   DETAIL
    active = true
    IF (p.beg_effective_dt_tm > cnvtdatetime(sysdate))
     active = false
    ELSE
     IF (p.end_effective_dt_tm < cnvtdatetime(sysdate))
      active = false
     ELSE
      IF (p.prot_amendment_id != highestamdid)
       active = false
      ENDIF
     ENDIF
    ENDIF
    c += 1
    IF (mod(c,10)=1)
     stat = alterlist(reply->orgs,(c+ 10))
    ENDIF
    reply->orgs[c].datebeg = p.beg_effective_dt_tm, reply->orgs[c].dateend = p.end_effective_dt_tm,
    reply->orgs[c].amendmentid = p.prot_amendment_id,
    reply->orgs[c].orgid = o.organization_id, reply->orgs[c].orgname = o.org_name, reply->orgs[c].
    active = active
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->orgs,c)
 SET reply->status_data.status = "S"
 GO TO skipecho
 CALL echo("Reply->status_data->status =",0)
 CALL echo(reply->status_data.status,1)
 CALL echo("--------------------------------------------------------------")
 FOR (x = 1 TO c)
   CALL echo("Value of x = ",0)
   CALL echo(x,1)
   CALL echo("Reply->Orgs[x]->OrgID = ",0)
   CALL echo(reply->orgs[x].orgid,1)
   CALL echo("Reply->Orgs[x]->OrgName = ",0)
   CALL echo(reply->orgs[x].orgname,1)
   CALL echo("Reply->Orgs[x]->Active = ",0)
   CALL echo(reply->orgs[x].active,1)
   CALL echo("--------------------------------------------------------------")
 ENDFOR
#skipecho
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
 SET last_mod = "005"
 SET mod_date = "June 10, 2008"
END GO
