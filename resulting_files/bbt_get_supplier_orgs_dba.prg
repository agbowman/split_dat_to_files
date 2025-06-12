CREATE PROGRAM bbt_get_supplier_orgs:dba
 RECORD reply(
   1 qual[10]
     2 organization_id = f8
     2 org_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET cdf_meaning = fillstring(12," ")
 IF ((request->cdf_meaning > " "))
  SET cdf_meaning = request->cdf_meaning
 ELSE
  SET cdf_meaning = "BBSUPPL"
 ENDIF
 SET code_value = 0.0
 SET stat = uar_get_meaning_by_codeset(278,cdf_meaning,1,code_value)
 IF (stat=1)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get_meaning_by_codeset"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = cdf_meaning
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  *
  FROM dummyt d1,
   org_type_reltn t,
   dummyt d2,
   organization orgs
  PLAN (d1
   WHERE d1.seq=1)
   JOIN (t
   WHERE t.org_type_cd=code_value
    AND t.active_ind=1)
   JOIN (d2
   WHERE d2.seq=1)
   JOIN (orgs
   WHERE t.organization_id=orgs.organization_id
    AND orgs.active_ind=1)
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alter(reply->qual,(count1+ 10))
   ENDIF
   reply->qual[count1].org_name = orgs.org_name, reply->qual[count1].organization_id = orgs
   .organization_id
  WITH nocounter
 ;end select
 SET stat = alter(reply->qual,count1)
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "ORGANIZATION"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
