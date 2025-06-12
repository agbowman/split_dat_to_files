CREATE PROGRAM cv_da_updt_device_location:dba
 IF (validate(reply) != 1)
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE nrowidx = i4 WITH noconstant(0), protect
 DECLARE performing_location_code_value = f8 WITH protect
 SET nrowidx = 1
 SET performing_location_code_value = uar_get_code_by("DISPLAY",220,request->objarray[nrowidx].
  performing_location)
 UPDATE  FROM cv_device_location_r cd
  SET cd.default_ind =
   IF ((validate(request->objarray[nrowidx].default_ind,- (1)) != - (1))) validate(request->objarray[
     nrowidx].default_ind,- (1))
   ELSE cd.default_ind
   ENDIF
   , cd.performing_location_cd =
   IF ((validate(performing_location_code_value,- (0.00001)) != - (0.00001))) validate(
     performing_location_code_value,- (0.00001))
   ELSE cd.performing_location_cd
   ENDIF
   , cd.updt_id = reqinfo->updt_id,
   cd.updt_dt_tm = cnvtdatetime(sysdate), cd.updt_task = reqinfo->updt_task, cd.updt_applctx =
   reqinfo->updt_applctx,
   cd.updt_cnt = (cd.updt_cnt+ 1), cd.user_id =
   IF ((validate(request->objarray[nrowidx].user_id,- (0.00001)) != - (0.00001))) validate(request->
     objarray[nrowidx].user_id,- (0.00001))
   ELSE cd.user_id
   ENDIF
   , cd.active_dev_user_ind = 0
  WHERE (cd.cv_device_location_r_id=request->objarray[nrowidx].cv_device_location_r_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
