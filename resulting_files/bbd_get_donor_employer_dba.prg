CREATE PROGRAM bbd_get_donor_employer:dba
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
 SET count = 0
 SET employer_type_cd = 0.0
 SET cv_cnt = 1
 SET stat = uar_get_meaning_by_codeset(338,"EMPLOYER",cv_cnt,employer_type_cd)
 SELECT INTO "nl:"
  po.*, o.*
  FROM person_org_reltn po,
   organization o
  PLAN (po
   WHERE (po.person_id=request->person_id)
    AND po.person_org_reltn_cd=employer_type_cd
    AND cnvtdatetime(curdate,curtime3) >= po.beg_effective_dt_tm
    AND cnvtdatetime(curdate,curtime3) <= po.end_effective_dt_tm
    AND po.active_ind=1)
   JOIN (o
   WHERE o.organization_id=po.organization_id
    AND cnvtdatetime(curdate,curtime3) >= o.beg_effective_dt_tm
    AND cnvtdatetime(curdate,curtime3) <= o.end_effective_dt_tm
    AND o.active_ind=1)
  DETAIL
   count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].organization_id = o
   .organization_id,
   reply->qual[count].organization_name = o.org_name
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#end_script
END GO
