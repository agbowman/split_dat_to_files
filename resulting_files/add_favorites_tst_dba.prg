CREATE PROGRAM add_favorites_tst:dba
 FREE SET request
 RECORD request(
   1 favorite_list[*]
     2 personnel_id = f8
     2 personnel_group_id = f8
     2 favorite_type_cd = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
 )
 FREE SET reply
 RECORD reply(
   1 favorite_list[*]
     2 favorite_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET stat = alterlist(request->favorite_list,1)
 SET request->favorite_list[1].personnel_id = 4463324.000000
 SET request->favorite_list[1].favorite_type_cd = 1442797040.000000
 SET request->favorite_list[1].parent_entity_name = "PRSNL"
 SET request->favorite_list[1].parent_entity_id = 4463325.000000
 EXECUTE add_favorites
 CALL echorecord(reply)
END GO
