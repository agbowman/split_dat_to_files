CREATE PROGRAM dcp_get_query_templates
 SET modify = predeclare
 RECORD reply(
   1 qual[*]
     2 query_type_cd = f8
     2 template_id = f8
     2 template_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE count = i4 WITH noconstant(0)
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE querytypedisplay = vc WITH noconstant
 SELECT INTO "nl:"
  FROM dcp_pl_query_template qt
  WHERE qt.template_id > 0
  ORDER BY qt.template_name
  DETAIL
   count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].query_type_cd = qt
   .query_type_cd,
   reply->qual[count].template_id = qt.template_id, reply->qual[count].template_name = qt
   .template_name
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
