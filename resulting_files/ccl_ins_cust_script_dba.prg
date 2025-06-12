CREATE PROGRAM ccl_ins_cust_script:dba
 DECLARE err_msg = vc WITH noconstant("")
 DECLARE error_code = i4 WITH noconstant(0)
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  cso.ccl_cust_script_objects_id
  FROM ccl_cust_script_objects cso
  WHERE cnvtupper(cso.object_name)=cnvtupper(request->object_name)
   AND (cso.group_number=request->group_number)
   AND cso.active_ind=1
 ;end select
 IF (curqual=0)
  INSERT  FROM ccl_cust_script_objects co
   SET co.object_name = cnvtupper(request->object_name), co.group_number = request->group_number, co
    .ccl_cust_script_objects_id = seq(ccl_seq,nextval),
    co.updt_dt_tm = cnvtdatetime(curdate,curtime3), co.updt_id = reqinfo->updt_id, co.active_ind = 1
  ;end insert
  SET error_code = error(err_msg,0)
  IF (error_code != 0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "ccl_get_cust_scripts"
   SET reply->status_data.subeventstatus[1].targetobjectname = "Error Message"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = err_msg
  ELSE
   SET reply->status_data.status = "S"
   SET reqinfo->commit_ind = 1
  ENDIF
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
