CREATE PROGRAM bsc_remove_adv_filter:dba
 SET modify = predeclare
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 DELETE  FROM comp_filter_group_item cfgi
  WHERE cfgi.comp_filter_group_id IN (
  (SELECT
   cfg.comp_filter_group_id
   FROM comp_filter_group cfg
   WHERE (cfg.filter_name=request->filter_name)
    AND (cfg.person_id=request->person_id)
    AND (cfg.component_cd=request->component_cd)))
  WITH nocounter
 ;end delete
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = concat(
   "Delete error on comp_filter_group_item - ",errmsg)
  GO TO exit_script
 ELSEIF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus.operationname = "No records deleted"
 ELSE
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus.operationname = "Success"
 ENDIF
 DELETE  FROM comp_filter_group cfg
  WHERE (cfg.filter_name=request->filter_name)
   AND (cfg.person_id=request->person_id)
   AND (cfg.component_cd=request->component_cd)
 ;end delete
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  ROLLBACK
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = concat("Delete error on comp_filter_group - ",
   errmsg)
 ELSEIF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus.operationname = "No records deleted"
 ELSE
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus.operationname = "Success"
  SET reqinfo->commit_ind = 1
 ENDIF
#exit_script
 SET last_mod = "001"
 SET mod_date = "08/08/2007"
 SET modify = nopredeclare
END GO
