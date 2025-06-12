CREATE PROGRAM bed_get_edarea_info:dba
 FREE SET reply
 RECORD reply(
   1 alist[*]
     2 area_id = vc
     2 edarea_desc = vc
     2 edarea_abbrev = vc
     2 edarea_type = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SELECT INTO "nl:"
  FROM br_name_value bnv
  PLAN (bnv
   WHERE bnv.br_nv_key1 IN ("EDAREA", "EDCOAREA", "EDWAITAREA", "EDPAAREA"))
  ORDER BY bnv.br_name_value_id
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->alist,cnt), reply->alist[cnt].area_id = build(bnv
    .br_name_value_id),
   reply->alist[cnt].edarea_desc = bnv.br_value, reply->alist[cnt].edarea_abbrev = bnv.br_name, reply
   ->alist[cnt].edarea_type = bnv.br_nv_key1
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
