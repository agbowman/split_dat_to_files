CREATE PROGRAM bb_ref_get_organizations:dba
 RECORD reply(
   1 qual[*]
     2 organization_id = f8
     2 org_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET serrormsg = fillstring(255," ")
 SET serror_check = error(serrormsg,1)
 DECLARE d278cd = f8
 DECLARE nreplycnt = i4
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->qual,10)
 SET d278cd = 0.0
 SET stat = uar_get_meaning_by_codeset(278,request->cdf_meaning,1,d278cd)
 IF (d278cd=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Code lookup codeset 278 failed"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  t.organization_id, orgs.organization_id
  FROM org_type_reltn t,
   organization orgs
  PLAN (t
   WHERE t.organization_id > 0
    AND t.org_type_cd=d278cd
    AND t.active_ind=1)
   JOIN (orgs
   WHERE t.organization_id=orgs.organization_id
    AND orgs.active_ind=1)
  DETAIL
   nreplycnt = (nreplycnt+ 1)
   IF (mod(nreplycnt,10)=1
    AND nreplycnt != 1)
    stat = alterlist(reply->qual,(nreplycnt+ 10))
   ENDIF
   reply->qual[nreplycnt].org_name = orgs.org_name, reply->qual[nreplycnt].organization_id = orgs
   .organization_id
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,nreplycnt)
 SET serror_check = error(serrormsg,0)
 IF (serror_check=0)
  IF (nreplycnt > 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
 ENDIF
#exit_script
END GO
