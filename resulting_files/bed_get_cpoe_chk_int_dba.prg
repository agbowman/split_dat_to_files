CREATE PROGRAM bed_get_cpoe_chk_int:dba
 FREE SET reply
 RECORD reply(
   1 intermittent_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET field_found = 0
 RANGE OF o IS order_catalog_synonym
 SET field_found = validate(o.intermittent_ind)
 FREE RANGE o
 IF (field_found=1)
  SET reply->intermittent_ind = 1
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
