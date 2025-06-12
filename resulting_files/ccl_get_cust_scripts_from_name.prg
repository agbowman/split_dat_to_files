CREATE PROGRAM ccl_get_cust_scripts_from_name
 RECORD reply(
   1 enabled_objects[*]
     2 ccl_cust_script_objects_id = f8
     2 object_name = vc
     2 group_number = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE objname = vc
 SET objname = request->object_name
 SELECT
  *
  FROM ccl_cust_script_objects ccso
  WHERE ccso.active_ind=1
   AND ccso.object_name=patstring(objname)
  HEAD REPORT
   stat = alterlist(reply->enabled_objects,100), count = 0
  DETAIL
   count += 1
   IF (mod(count,100)=1
    AND count > 100)
    stat = alterlist(reply->enabled_objects,(count+ 99))
   ENDIF
   reply->enabled_objects[count].ccl_cust_script_objects_id = ccso.ccl_cust_script_objects_id, reply
   ->enabled_objects[count].object_name = ccso.object_name, reply->enabled_objects[count].
   group_number = ccso.group_number
  FOOT REPORT
   stat = alterlist(reply->enabled_objects,count)
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
