CREATE PROGRAM bbd_get_group_by_mean:dba
 RECORD reply(
   1 group_id = f8
   1 group_cd = f8
   1 group_cd_disp = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET modify = predeclare
 DECLARE script_name = c21 WITH constant("bbd_get_group_by_mean")
 DECLARE error_msg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(error(error_msg,1))
 DECLARE uar_error = vc WITH protect, noconstant("")
 DECLARE prsnl_group_type_cs = i4 WITH constant(357)
 DECLARE prsnlgrouptypecd = f8 WITH protect, noconstant(0.0)
 SET prsnlgrouptypecd = uar_get_code_by("MEANING",prsnl_group_type_cs,nullterm(request->cdf_meaning))
 IF (prsnlgrouptypecd <= 0.0)
  SET uar_error = concat("Failed to retrieve personnel group type code with meaning of ",trim(request
    ->cdf_meaning),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SELECT INTO "nl:"
  pg.*
  FROM prsnl_group pg
  WHERE pg.prsnl_group_type_cd=prsnlgrouptypecd
   AND pg.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND pg.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   AND pg.active_ind=1
  DETAIL
   reply->group_id = pg.prsnl_group_id, reply->group_cd = pg.prsnl_group_type_cd
  WITH nocounter
 ;end select
 GO TO set_status
 DECLARE errorhandler(operationstatus=c1,targetobjectname=c25,targetobjectvalue=vc) = null
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
   GO TO exit_script
 END ;Subroutine
#set_status
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
END GO
