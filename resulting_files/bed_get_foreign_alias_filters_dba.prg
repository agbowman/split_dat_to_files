CREATE PROGRAM bed_get_foreign_alias_filters:dba
 FREE SET reply
 RECORD reply(
   1 facilities[*]
     2 display = vc
     2 catalog_types[*]
       3 display = vc
       3 activity_types[*]
         4 display = vc
         4 interface_names[*]
           5 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET fcnt = 0
 SELECT INTO "NL:"
  FROM br_foreign_alias b
  PLAN (b
   WHERE (b.alias_type=request->alias_type))
  ORDER BY b.facility, b.catalog_type, b.activity_type,
   b.interface_name
  HEAD b.facility
   fcnt = (fcnt+ 1), stat = alterlist(reply->facilities,fcnt), reply->facilities[fcnt].display = b
   .facility,
   ccnt = 0
  HEAD b.catalog_type
   ccnt = (ccnt+ 1), stat = alterlist(reply->facilities[fcnt].catalog_types,ccnt), reply->facilities[
   fcnt].catalog_types[ccnt].display = b.catalog_type,
   acnt = 0
  HEAD b.activity_type
   acnt = (acnt+ 1), stat = alterlist(reply->facilities[fcnt].catalog_types[ccnt].activity_types,acnt
    ), reply->facilities[fcnt].catalog_types[ccnt].activity_types[acnt].display = b.activity_type,
   icnt = 0
  HEAD b.interface_name
   icnt = (icnt+ 1), stat = alterlist(reply->facilities[fcnt].catalog_types[ccnt].activity_types[acnt
    ].interface_names,icnt), reply->facilities[fcnt].catalog_types[ccnt].activity_types[acnt].
   interface_names[icnt].display = b.interface_name
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
