CREATE PROGRAM cdi_del_forms:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE count = i4 WITH noconstant(value(size(request->forms,5))), public
 DECLARE num = i4 WITH noconstant(1)
 DECLARE rule_cnt = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 IF (count > 0)
  UPDATE  FROM cdi_form f
   SET f.active_ind = 0, f.updt_cnt = (f.updt_cnt+ 1), f.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    f.updt_task = reqinfo->updt_task, f.updt_id = reqinfo->updt_id, f.updt_applctx = reqinfo->
    updt_applctx
   WHERE expand(num,1,count,f.cdi_form_id,request->forms[num].cdi_form_id)
  ;end update
  IF (curqual != count)
   SET ecode = 0
   SET emsg = fillstring(200," ")
   SET ecode = error(emsg,1)
   SET reply->status_data.subeventstatus[1].operationname = "DELETE"
   SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_FORM"
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
