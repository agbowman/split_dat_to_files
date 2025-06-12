CREATE PROGRAM delete_favorites_tst:dba
 FREE SET request
 RECORD request(
   1 personnel_id = f8
   1 personnel_group_id = f8
   1 favorite_type_cd = f8
   1 favorite_list[*]
     2 favorite_id = f8
 )
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET request->personnel_id = 2896569.0
 SET request->favorite_type_cd = 1442797040.0
 EXECUTE delete_favorites
 CALL echorecord(reply)
END GO
