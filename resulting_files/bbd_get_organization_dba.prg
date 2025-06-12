CREATE PROGRAM bbd_get_organization:dba
 RECORD reply(
   1 qual[*]
     2 org_name = c100
     2 org_id = f8
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
 SET stat = alterlist(reply->qual,20)
 SET donorgroup_cd = 0.0
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_cnt = 0
 SET code_set = 278
 SET cdf_meaning = "DONORGROUP"
 SET code_cnt = 1
 SET status = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,donorgroup_cd)
 IF ((request->opt_ind=1))
  SELECT INTO "nl:"
   o.org_name
   FROM organization o,
    org_type_reltn ot
   PLAN (ot
    WHERE ot.org_type_cd=donorgroup_cd
     AND ot.active_ind=1)
    JOIN (o
    WHERE o.organization_id=ot.organization_id
     AND (((request->search_ind=1)
     AND o.org_name_key=patstring(request->search_string)) OR ((request->search_ind=0)
     AND o.active_ind=1)) )
   ORDER BY o.org_name
   DETAIL
    count = (count+ 1)
    IF (mod(count,20)=1
     AND count != 1)
     stat = alterlist(reply->qual,(count+ 19))
    ENDIF
    reply->qual[count].org_name = o.org_name, reply->qual[count].org_id = o.organization_id
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->qual,count)
  IF (curqual != 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ELSE
  IF ((request->opt_ind=0))
   SELECT INTO "nl:"
    o.org_name
    FROM organization o
    WHERE (((request->search_ind=1)
     AND o.org_name_key=patstring(request->search_string)) OR ((request->search_ind=0)
     AND o.active_ind=1))
    ORDER BY o.org_name
    DETAIL
     count = (count+ 1)
     IF (mod(count,20)=1
      AND count != 1)
      stat = alterlist(reply->qual,(count+ 19))
     ENDIF
     reply->qual[count].org_name = o.org_name, reply->qual[count].org_id = o.organization_id
    WITH nocounter
   ;end select
   SET stat = alterlist(reply->qual,count)
   IF (curqual != 0)
    SET reply->status_data.status = "S"
   ELSE
    SET reply->status_data.status = "Z"
   ENDIF
  ENDIF
 ENDIF
#exitscript
END GO
