CREATE PROGRAM bbd_upd_recruit_list_donors:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value))
  = null WITH protect
 SUBROUTINE subevent_add(op_name,op_status,obj_name,obj_value)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
 SET modify = predeclare
 DECLARE errorhandler(operationstatus=c1,targetobjectname=c25,targetobjectvalue=vc) = null
 DECLARE script_name = c25 WITH protect, constant("BBD_UPD_RECRUIT_LIST_DO..")
 DECLARE lindex = i4 WITH protect, noconstant(0)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 SET reply->status_data.status = "F"
 CALL echorecord(request)
 FOR (lindex = 1 TO size(request->donorlist,5))
   SELECT INTO "nl:"
    dr.recruiting_donor_reltn_id
    FROM bbd_recruiting_donor_reltn dr
    WHERE (dr.list_id=request->list_id)
     AND (dr.person_id=request->donorlist[lindex].person_id)
     AND dr.active_ind=1
    WITH forupdate(dr), nocounter
   ;end select
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Failed to lock rows.",errmsg)
   ENDIF
   IF (curqual=0)
    CALL errorhandler("F","BBD_UPD_RECRUIT_LIST_DO..",
     "Person does not exist on table - BBD_RECRUITING_DONOR_RELTN.")
   ELSE
    UPDATE  FROM bbd_recruiting_donor_reltn dr
     SET dr.active_ind = 0, dr.updt_dt_tm = cnvtdatetime(curdate,curtime3), dr.updt_id = reqinfo->
      updt_id,
      dr.updt_applctx = reqinfo->updt_applctx, dr.updt_task = reqinfo->updt_task, dr.updt_cnt = (dr
      .updt_cnt+ 1)
     WHERE (dr.list_id=request->list_id)
      AND (dr.person_id=request->donorlist[lindex].person_id)
     WITH nocounter
    ;end update
    SET error_check = error(errmsg,0)
    IF (error_check != 0)
     CALL errorhandler("F","Failed to update rows.",errmsg)
    ENDIF
   ENDIF
 ENDFOR
 GO TO set_status
 SUBROUTINE errorhandler(operationstatus,targetobjectname,targetobjectvalue)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(reply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (reply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt = (error_cnt+ 1)
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
