CREATE PROGRAM cdi_del_user_filters:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE count = i4 WITH noconstant(value(size(request->filters,5))), public
 DECLARE num = i4 WITH noconstant(1)
 SET reply->status_data.status = "F"
 IF (count > 0)
  DELETE  FROM cdi_user_filter f
   WHERE expand(num,1,count,f.cdi_user_filter_id,request->filters[num].cdi_user_filter_id)
    AND f.cdi_user_filter_id != 0
   WITH nocounter
  ;end delete
  IF (curqual != count)
   SET ecode = 0
   SET emsg = fillstring(132," ")
   SET ecode = error(emsg,1)
   SET reply->status_data.subeventstatus[1].operationname = "DELETE"
   SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_user_filter"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = emsg
   GO TO exit_script
  ENDIF
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
