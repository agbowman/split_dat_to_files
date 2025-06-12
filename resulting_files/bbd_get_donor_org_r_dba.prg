CREATE PROGRAM bbd_get_donor_org_r:dba
 RECORD reply(
   1 qual[*]
     2 organization_id = f8
     2 organization_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET donor_org_cd = 0
 SET count = 0
 SET cdf_meaning = fillstring(12," ")
 SET cdf_meaning = "DONOR"
 SET code_value = 0.0
 SET code_set = 338
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,code_value)
 IF (code_value=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].operationname = "retrieve"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get__meaning_by_codeset"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "unable to retrieve code value for 338 and DONOR"
  GO TO exitscript
 ENDIF
 SET donor_org_cd = code_value
 SELECT INTO "nl:"
  p.organization_id, o.org_name
  FROM person_org_reltn p,
   organization o
  PLAN (p
   WHERE (p.person_id=request->person_id)
    AND p.person_org_reltn_cd=donor_org_cd
    AND p.active_ind=1)
   JOIN (o
   WHERE o.organization_id=p.organization_id
    AND o.active_ind=1)
  DETAIL
   count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].organization_id = o
   .organization_id,
   reply->qual[count].organization_name = o.org_name
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exitscript
END GO
