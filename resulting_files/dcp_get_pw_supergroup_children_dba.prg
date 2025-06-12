CREATE PROGRAM dcp_get_pw_supergroup_children:dba
 RECORD reply(
   1 qual_cnt = i4
   1 qual[*]
     2 order_id = f8
     2 encntr_id = f8
     2 catalog_cd = f8
     2 order_status_cd = f8
     2 order_mnemonic = vc
     2 synonym_id = f8
     2 clinical_display_line = vc
     2 oe_format_id = f8
     2 last_updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET failed = "F"
 SET child_cnt = 0
 SELECT INTO "nl:"
  o.cs_order_id
  FROM orders o
  WHERE (o.cs_order_id=request->parent_order_id)
  DETAIL
   child_cnt = (child_cnt+ 1)
   IF (child_cnt > size(reply->qual,5))
    stat = alterlist(reply->qual,(child_cnt+ 10))
   ENDIF
   reply->qual[child_cnt].order_id = o.order_id, reply->qual[child_cnt].encntr_id = o.encntr_id,
   reply->qual[child_cnt].catalog_cd = o.catalog_cd,
   reply->qual[child_cnt].order_status_cd = o.order_status_cd, reply->qual[child_cnt].order_mnemonic
    = o.order_mnemonic, reply->qual[child_cnt].synonym_id = o.synonym_id,
   reply->qual[child_cnt].clinical_display_line = o.clinical_display_line, reply->qual[child_cnt].
   oe_format_id = o.oe_format_id, reply->qual[child_cnt].last_updt_cnt = o.updt_cnt
  WITH nocounter
 ;end select
 SET reply->qual_cnt = child_cnt
 SET stat = alterlist(reply->qual,child_cnt)
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
