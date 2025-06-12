CREATE PROGRAM bb_get_schedule_in_use:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 in_use_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
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
 DECLARE serror = c132 WITH protect, noconstant(" ")
 SET modify = predeclare
 SET reply->status_data.status = "F"
 SET reply->in_use_ind = 0
 SELECT
  *
  FROM bb_qc_group b
  WHERE (b.schedule_cd=request->schedule_cd)
   AND b.active_ind=1
  DETAIL
   reply->in_use_ind = 1
  WITH nocounter
 ;end select
 IF (error(serror,0) > 0)
  CALL subevent_add("EXECUTE","F","bb_get_schedule_in_use",serror)
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
END GO
