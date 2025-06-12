CREATE PROGRAM cdi_del_ac_fields
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE count = i4 WITH noconstant(value(size(request->field,5))), public
 DECLARE num = i4 WITH noconstant(1)
 SET reply->status_data.status = "F"
 IF (count > 0)
  DELETE  FROM cdi_ac_field acf
   WHERE expand(num,1,count,acf.cdi_ac_field_id,request->field[num].cdi_ac_field_id)
   WITH nocounter
  ;end delete
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 IF ((reply->status_data.status != "S"))
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
