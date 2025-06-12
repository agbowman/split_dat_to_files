CREATE PROGRAM aps_del_signline_task_assoc:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET reqinfo->commit_ind = 0
 DELETE  FROM sign_line_dta_r sldr
  WHERE (sldr.format_id=request->format_id)
  WITH nocounter
 ;end delete
 DELETE  FROM sign_line_ep_r sler
  WHERE (sler.format_id=request->format_id)
  WITH nocounter
 ;end delete
 DELETE  FROM sign_line_layout_field_r slfr
  WHERE (slfr.format_id=request->format_id)
  WITH nocounter
 ;end delete
 SET reqinfo->commit_ind = 1
 SET reply->status_data.status = "S"
#exit_script
END GO
