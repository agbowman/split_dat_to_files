CREATE PROGRAM bb_upd_printer_facility_reltn:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE script_name = c29 WITH constant("bb_upd_printer_facility_reltn")
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE add_ind = i2 WITH constant(1)
 DECLARE change_ind = i2 WITH constant(2)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 FOR (i_idx = 1 TO size(request->facilityprinterreltnlist,5))
   SELECT INTO "nl:"
    FROM bb_facility_printer_r fpr
    WHERE (fpr.bb_facility_printer_r_id=request->facilityprinterreltnlist[i_idx].
    bb_facility_printer_r_id)
    WITH nocounter, forupdate(fpr)
   ;end select
   IF (curqual > 0
    AND (request->facilityprinterreltnlist[i_idx].add_change_ind=add_ind))
    SET request->facilityprinterreltnlist[i_idx].add_change_ind = change_ind
   ENDIF
   IF ((request->facilityprinterreltnlist[i_idx].add_change_ind=change_ind)
    AND (request->facilityprinterreltnlist[i_idx].active_ind=1))
    UPDATE  FROM bb_facility_printer_r fpr
     SET fpr.active_ind = request->facilityprinterreltnlist[i_idx].active_ind, fpr.bb_printer_id =
      request->facilityprinterreltnlist[i_idx].bb_printer_id, fpr.bb_organization_id = request->
      facilityprinterreltnlist[i_idx].bb_organization_id,
      fpr.updt_cnt = (fpr.updt_cnt+ 1), fpr.updt_applctx = reqinfo->updt_applctx, fpr.updt_dt_tm =
      cnvtdatetime(sysdate),
      fpr.updt_id = reqinfo->updt_id, fpr.updt_task = reqinfo->updt_task
     WHERE (fpr.bb_facility_printer_r_id=request->facilityprinterreltnlist[i_idx].
     bb_facility_printer_r_id)
     WITH nocounter
    ;end update
    SET error_check = error(errmsg,0)
    IF (error_check != 0)
     CALL errorhandler("F","Upd bb_facility_printer_r",errmsg)
    ENDIF
   ELSEIF ((request->facilityprinterreltnlist[i_idx].add_change_ind=change_ind)
    AND (request->facilityprinterreltnlist[i_idx].active_ind=0))
    DELETE  FROM bb_facility_printer_r fpr
     WHERE (fpr.bb_facility_printer_r_id=request->facilityprinterreltnlist[i_idx].
     bb_facility_printer_r_id)
     WITH nocounter
    ;end delete
    SET error_check = error(errmsg,0)
    IF (error_check != 0)
     CALL errorhandler("F","Del bb_facility_printer_r",errmsg)
    ENDIF
   ELSEIF ((request->facilityprinterreltnlist[i_idx].add_change_ind=add_ind))
    INSERT  FROM bb_facility_printer_r fpr
     SET fpr.active_ind = request->facilityprinterreltnlist[i_idx].active_ind, fpr.active_status_cd
       = reqdata->active_status_cd, fpr.active_status_dt_tm = cnvtdatetime(sysdate),
      fpr.active_status_prsnl_id = reqinfo->updt_id, fpr.bb_printer_id = request->
      facilityprinterreltnlist[i_idx].bb_printer_id, fpr.bb_organization_id = request->
      facilityprinterreltnlist[i_idx].bb_organization_id,
      fpr.bb_facility_printer_r_id = request->facilityprinterreltnlist[i_idx].
      bb_facility_printer_r_id
     WITH nocounter
    ;end insert
    SET error_check = error(errmsg,0)
    IF (error_check != 0)
     CALL errorhandler("F","Ins bb_facility_printer_r",errmsg)
    ENDIF
   ENDIF
 ENDFOR
 GO TO set_status
 SUBROUTINE (errorhandler(operationstatus=c1,targetobjectname=vc,targetobjectvalue=vc) =null)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(reply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (reply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt += 1
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[error_cnt].operationname = script_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
   SET reqinfo->commit_ind = 0
   GO TO exit_script
 END ;Subroutine
#set_status
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
END GO
