CREATE PROGRAM bed_get_foreign_alias_data:dba
 FREE SET reply
 RECORD reply(
   1 foreign_alias[*]
     2 br_foreign_alias_id = f8
     2 short_name = vc
     2 long_name = vc
     2 inbound_alias = vc
     2 outbound_alias = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE br_parse = vc
 SET br_parse = "b.alias_type = request->alias_type"
 IF ((request->facility > " "))
  SET br_parse = concat(br_parse," and b.facility = request->facility")
 ENDIF
 IF ((request->catalog_type > " "))
  SET br_parse = concat(br_parse," and b.catalog_type = request->catalog_type")
 ENDIF
 IF ((request->activity_type > " "))
  SET br_parse = concat(br_parse," and b.activity_type = request->activity_type")
 ENDIF
 IF ((request->interface_name > " "))
  SET br_parse = concat(br_parse," and b.interface_name = request->interface_name")
 ENDIF
 SET fcnt = 0
 SET alterlist_fcnt = 0
 SET stat = alterlist(reply->foreign_alias,50)
 SELECT INTO "NL:"
  FROM br_foreign_alias b
  PLAN (b
   WHERE parser(br_parse))
  ORDER BY b.short_name
  DETAIL
   fcnt = (fcnt+ 1), alterlist_fcnt = (alterlist_fcnt+ 1)
   IF (alterlist_fcnt > 50)
    stat = alterlist(reply->foreign_alias,(fcnt+ 50)), alterlist_fcnt = 1
   ENDIF
   reply->foreign_alias[fcnt].br_foreign_alias_id = b.br_foreign_alias_id, reply->foreign_alias[fcnt]
   .short_name = b.short_name, reply->foreign_alias[fcnt].long_name = b.long_name,
   reply->foreign_alias[fcnt].inbound_alias = b.inbound_alias, reply->foreign_alias[fcnt].
   outbound_alias = b.outbound_alias
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->foreign_alias,fcnt)
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
