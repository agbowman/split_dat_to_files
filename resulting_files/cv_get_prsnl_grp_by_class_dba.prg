CREATE PROGRAM cv_get_prsnl_grp_by_class:dba
 SET cfc_prsnlgrpalias_by_pool = "F"
 SET lvl_error = 0
 SET lvl_warning = 1
 SET lvl_audit = 2
 SET lvl_info = 3
 SET lvl_debug = 4
 SET log_to_reply = 1
 SET log_to_screen = 0
 SET log_msg = fillstring(100," ")
 DECLARE sn_log_message(log_level,log_reply,log_event,log_mesg) = null WITH protected
 SUBROUTINE sn_log_message(log_level,log_reply,log_event,log_mesg)
   DECLARE sn_log_num = i4 WITH protected, noconstant(0)
   SET sn_log_level = evaluate(log_level,lvl_error,"E",lvl_warning,"W",
    lvl_audit,"A",lvl_info,"I",lvl_debug,
    "D","U")
   IF (log_reply=log_to_reply)
    SET sn_log_num = size(reply->status_data.subeventstatus,5)
    IF (sn_log_num=1)
     IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
      SET sn_log_num += 1
     ENDIF
    ELSE
     SET sn_log_num += 1
    ENDIF
    SET stat = alter(reply->status_data.subeventstatus,sn_log_num)
    SET reply->status_data.subeventstatus[sn_log_num].operationname = log_event
    SET reply->status_data.subeventstatus[sn_log_num].operationstatus = sn_log_level
    SET reply->status_data.subeventstatus[sn_log_num].targetobjectname = curprog
    SET reply->status_data.subeventstatus[sn_log_num].targetobjectvalue = log_mesg
   ELSE
    CALL echo("-----------------")
    CALL echo(build("Event           :",log_event))
    CALL echo(build("Status          :",sn_log_level))
    CALL echo(build("Current Program :",curprog))
    CALL echo(build("Message         :",log_mesg))
   ENDIF
 END ;Subroutine
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 qual[*]
      2 prsnl_group_id = f8
      2 prsnl_group_type_cd = f8
      2 prsnl_group_type_disp = vc
      2 service_resource_cd = f8
      2 service_resource_disp = c40
      2 prsnl_group_desc = vc
      2 prsnl_group_name = vc
      2 prsnl_group_class_cd = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  IF ( NOT (validate(req_prsnl_grp_by_class,0)))
   RECORD req_prsnl_grp_by_class(
     1 prsnl_group_class_cd = f8
     1 qual[*]
       2 prsnl_group_id = f8
       2 prsnl_group_type_cd = f8
       2 prsnl_group_type_disp = vc
       2 service_resource_cd = f8
       2 service_resource_disp = c40
       2 prsnl_group_desc = vc
       2 prsnl_group_name = vc
       2 prsnl_group_class_cd = f8
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
  ENDIF
  SET req_prsnl_grp_by_class->prsnl_group_class_cd = request->prsnl_group_class_cd
  SET cfc_prsnlgrpalias_by_pool = "T"
 ENDIF
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT INTO "nl:"
  p.prsnl_group_id
  FROM prsnl_group p
  WHERE (p.prsnl_group_class_cd=req_prsnl_grp_by_class->prsnl_group_class_cd)
   AND p.active_ind=1
   AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
   AND p.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   count1 += 1, stat = alterlist(req_prsnl_grp_by_class->qual,count1), req_prsnl_grp_by_class->qual[
   count1].prsnl_group_id = p.prsnl_group_id,
   req_prsnl_grp_by_class->qual[count1].prsnl_group_type_cd = p.prsnl_group_type_cd,
   req_prsnl_grp_by_class->qual[count1].service_resource_cd = p.service_resource_cd,
   req_prsnl_grp_by_class->qual[count1].prsnl_group_desc = p.prsnl_group_desc,
   req_prsnl_grp_by_class->qual[count1].prsnl_group_name = p.prsnl_group_name, req_prsnl_grp_by_class
   ->qual[count1].prsnl_group_class_cd = p.prsnl_group_class_cd
  WITH nocounter
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "Z"
  CALL sn_log_message(lvl_info,log_to_reply,"PRSNL_GRP_ALIAS","No records in Prsnl Grp Alias Pool")
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (cfc_prsnlgrpalias_by_pool="T")
  SET stat = alterlist(reply->qual,size(req_prsnl_grp_by_class->qual,5))
  FOR (count1 = 1 TO size(req_prsnl_grp_by_class->qual,5))
    SET reply->qual[count1].prsnl_group_id = req_prsnl_grp_by_class->qual[count1].prsnl_group_id
    SET reply->qual[count1].prsnl_group_type_cd = req_prsnl_grp_by_class->qual[count1].
    prsnl_group_type_cd
    SET reply->qual[count1].service_resource_cd = req_prsnl_grp_by_class->qual[count1].
    service_resource_cd
    SET reply->qual[count1].prsnl_group_desc = req_prsnl_grp_by_class->qual[count1].prsnl_group_desc
    SET reply->qual[count1].prsnl_group_class_cd = req_prsnl_grp_by_class->qual[count1].
    prsnl_group_class_cd
  ENDFOR
 ENDIF
END GO
