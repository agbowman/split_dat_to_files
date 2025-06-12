CREATE PROGRAM cp_get_chart_category:dba
 RECORD reply(
   1 qual[*]
     2 chart_category_id = f8
     2 category_name = c50
     2 category_seq = i4
     2 sensitive_ind = i2
     2 expandable_doc_ind = i2
     2 parent_category_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE x = i2 WITH public, noconstant(0)
 SELECT INTO "nl:"
  c.category_seq
  FROM chart_category c
  WHERE c.active_ind=1
  ORDER BY c.category_seq
  DETAIL
   x = (x+ 1)
   IF (x > size(reply->qual,5))
    stat = alterlist(reply->qual,(x+ 9))
   ENDIF
   reply->qual[x].chart_category_id = c.chart_category_id, reply->qual[x].category_name = c
   .category_name, reply->qual[x].category_seq = c.category_seq,
   reply->qual[x].sensitive_ind = c.sensitive_ind, reply->qual[x].expandable_doc_ind = c
   .expandable_doc_ind, reply->qual[x].parent_category_id = c.parent_category_id
  FOOT REPORT
   stat = alterlist(reply->qual,x)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Chart_Category"
  SET reqinfo->commit_ind = false
 ENDIF
END GO
