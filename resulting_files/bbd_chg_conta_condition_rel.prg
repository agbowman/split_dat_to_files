CREATE PROGRAM bbd_chg_conta_condition_rel
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
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c30
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c30
       3 targetobjectvalue = vc
       3 sourceobjectqual = i4
 )
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 SELECT INTO "nl:"
  c.container_condition_id
  FROM container_condition_r c
  WHERE (c.container_condition_id=request->container_condition_id)
  WITH nocounter, separator = " ", format,
   forupdate(c)
 ;end select
 IF (curqual > 0)
  UPDATE  FROM container_condition_r ccr
   SET ccr.cntnr_temperature_value = request->container_temperature, ccr.cntnr_temperature_degree_cd
     = request->container_temperature_degree_cd, ccr.updt_cnt = (ccr.updt_cnt+ 1)
   WHERE (ccr.container_condition_id=request->container_condition_id)
   WITH nocounter
  ;end update
  SET error_check = error(errmsg,0)
  IF (error_check != 0)
   SET reply->status_data.status = "F"
   CALL subevent_add("Update Container Condition Temperature Info","F",
    "bbd_chg_conta_condition_rel.prg",errmsg)
   SET reqinfo->commit_ind = 0
   GO TO exit_script
  ENDIF
 ELSE
  SET reply->status_data.status = "Z"
  CALL subevent_add("Container Condition Relationship Not Found","Z",
   "bbd_chg_conta_condition_rel.prg",errmsg)
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
END GO
