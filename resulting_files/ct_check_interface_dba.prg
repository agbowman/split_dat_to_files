CREATE PROGRAM ct_check_interface:dba
 RECORD reply(
   1 active_ind = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 IF ((request->interface_class=""))
  GO TO exit_script
 ENDIF
 IF ((request->interface_class=""))
  GO TO qualify_class
 ENDIF
 IF ((request->interface_subtype=""))
  GO TO qualify_class_type
 ELSE
  GO TO qualify_all
 ENDIF
#qualify_class
 CALL echo("Qualify on class")
 SELECT INTO "nl:"
  FROM eso_trigger t
  WHERE (t.class=request->interface_class)
  DETAIL
   cnt = (cnt+ 1)
  WITH nocounter
 ;end select
 SET reply->active_ind = cnt
 SET reply->status_data.status = "S"
 GO TO exit_script
#qualify_class_type
 CALL echo("Qualify on class and type")
 SELECT INTO "nl:"
  FROM eso_trigger t
  WHERE (t.class=request->interface_class)
   AND (t.type=request->interface_type)
  DETAIL
   cnt = (cnt+ 1)
  WITH nocounter
 ;end select
 SET reply->active_ind = cnt
 SET reply->status_data.status = "S"
 GO TO exit_script
#qualify_all
 CALL echo("Qualify on class, type, and subtype")
 SELECT INTO "nl:"
  FROM eso_trigger t
  WHERE (t.class=request->interface_class)
   AND (t.type=request->interface_type)
   AND (t.subtype=request->interface_subtype)
  DETAIL
   cnt = (cnt+ 1)
  WITH nocounter
 ;end select
 SET reply->active_ind = cnt
 SET reply->status_data.status = "S"
 GO TO exit_script
#exit_script
 CALL echo(build("status = ",reply->status_data.status))
 CALL echo(build("active_ind = ",reply->active_ind))
END GO
