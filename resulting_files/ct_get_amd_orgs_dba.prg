CREATE PROGRAM ct_get_amd_orgs:dba
 RECORD reply(
   1 qual[*]
     2 org_id = f8
     2 org_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE count = i2 WITH protect, noconstant(0)
 DECLARE instd_cd = f8 WITH protect, noconstant(0.0)
 DECLARE userorgstr = vc WITH protect
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 SET stat = uar_get_meaning_by_codeset(17296,"INSTITUTION",1,instd_cd)
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
 IF ((request->validating_ind=0))
  EXECUTE ct_get_org_security  WITH replace("REPLY","ORG_SEC_REPLY")
  CALL echo(build("org_sec_reply->OrgSecurityFlag: ",org_sec_reply->orgsecurityflag))
 ENDIF
 IF ((request->validating_ind=0))
  IF ((org_sec_reply->orgsecurityflag=1))
   SET userorgstr = builduserorglist("pr.organization_id")
  ELSE
   SET userorgstr = "1=1"
  ENDIF
 ELSE
  SET userorgstr = "1=1"
 ENDIF
 CALL echo(build("userOrgStr: ",userorgstr))
 SELECT DISTINCT INTO "nl:"
  pr.organization_id
  FROM prot_role pr,
   organization o
  PLAN (pr
   WHERE (pr.prot_amendment_id=request->prot_amendment_id)
    AND pr.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND pr.prot_role_type_cd=instd_cd
    AND parser(userorgstr))
   JOIN (o
   WHERE pr.organization_id=o.organization_id)
  ORDER BY o.org_name
  DETAIL
   count += 1, stat = alterlist(reply->qual,count), reply->qual[count].org_id = pr.organization_id,
   reply->qual[count].org_name = o.org_name
  WITH dontcare = o, nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 CALL echo(build("status:",reply->status_data.status))
 SET last_mod = "003"
 SET mod_date = "June 10, 2008"
END GO
