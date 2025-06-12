CREATE PROGRAM daf_icd9_get_master_server:dba
 RECORD reply(
   1 master_node_name = vc
   1 message = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE errcode = i4 WITH public, noconstant(0)
 DECLARE errmsg = vc WITH public
 SELECT INTO "nl:"
  FROM dm_text_find_server dtfs
  WHERE dtfs.server_node_type="Master"
  DETAIL
   reply->master_node_name = dtfs.server_node_name
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,1)
 IF (errcode != 0)
  SET reply->status_data.status = "F"
  SET reply->master_node_name = " "
  SET reply->message = concat("Unable to read from DM_TEXT_FIND_SERVER:",errmsg)
  GO TO exit_script
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "S"
  SET reply->master_node_name = " "
  SET reply->message = "No Master Node could be found."
  GO TO exit_script
 ENDIF
 IF (size(reply->master_node_name,1)=0)
  SET reply->status_data.status = "S"
  SET reply->master_node_name = " "
  SET reply->message = "Cannot Use an Empty Master Node Name."
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
 SET reply->message = "Master Server Node found as expected."
#exit_script
END GO
