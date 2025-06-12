CREATE PROGRAM cv_get_dataset_alias_by_pool:dba
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
  SET sn_log_level = evaluate(log_level,lvl_error,"E",lvl_warning,"W",
   lvl_audit,"A",lvl_info,"I",lvl_debug,
   "D","U")
  IF (log_reply=log_to_reply)
   SET num_event = size(reply->status_data.subeventstatus,5)
   IF (num_event=1)
    IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
     SET num_event = (num_event+ 1)
    ENDIF
   ELSE
    SET num_event = (num_event+ 1)
   ENDIF
   SET stat = alter(reply->status_data.subeventstatus,num_event)
   SET reply->status_data.subeventstatus[num_event].operationname = log_event
   SET reply->status_data.subeventstatus[num_event].operationstatus = sn_log_level
   SET reply->status_data.subeventstatus[num_event].targetobjectname = curprog
   SET reply->status_data.subeventstatus[num_event].targetobjectvalue = log_mesg
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
      2 alias = vc
      2 source_id = f8
      2 display = vc
      2 alias_type_nbr = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET prsnlgrp_delimstr = "___"
 SET count1 = 0
 SET aliascount = 0
 SET aliascount1 = 0
 SET aliascount2 = 0
 SET aliascount3 = 0
 SET atleastonesuccess = "F"
 IF (band(request->datasets_nbr,1)=1)
  IF ( NOT (validate(req_org_alias_by_pool,0)))
   RECORD req_org_alias_by_pool(
     1 alias_pool_cd = f8
     1 organization_id = f8
     1 qual[*]
       2 organization_alias_id = f8
       2 org_alias_type_cd = f8
       2 org_alias_type_disp = c40
       2 beg_effective_dt_tm = dq8
       2 end_effective_dt_tm = dq8
       2 alias = vc
       2 alias_pool_cd = f8
       2 alias_pool_disp = c40
       2 organization_id = f8
       2 display = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
  ENDIF
  SET req_org_alias_by_pool->alias_pool_cd = request->alias_pool_cd
  SET req_org_alias_by_pool->organization_id = request->source_id
  EXECUTE cv_get_org_alias_by_pool
  IF ((reply->status_data.status="S"))
   SET atleastonesuccess = "S"
   SET stat = alterlist(reply->qual,size(req_org_alias_by_pool->qual,5))
   FOR (count1 = 1 TO size(req_org_alias_by_pool->qual,5))
     SET reply->qual[count1].alias = req_org_alias_by_pool->qual[count1].alias
     SET reply->qual[count1].source_id = req_org_alias_by_pool->qual[count1].organization_id
     SET reply->qual[count1].alias_type_nbr = 0
     SET reply->qual[count1].display = req_org_alias_by_pool->qual[count1].display
   ENDFOR
   SET aliascount = (count1 - 1)
   SET aliascount1 = (count1 - 1)
  ENDIF
  IF ((reply->status_data.status="Z"))
   CALL sn_log_message(lvl_info,log_to_reply,"ORG_ALIAS","No records in Org Alias Pool")
  ELSEIF ((reply->status_data.status="F"))
   CALL sn_log_message(lvl_error,log_to_reply,"ORG_ALIAS","Error in Org Alias Pool")
  ENDIF
 ENDIF
 IF (band(request->datasets_nbr,2)=2)
  IF ( NOT (validate(req_prsnlalias_by_pool,0)))
   RECORD req_prsnlalias_by_pool(
     1 alias_pool_cd = f8
     1 prsnl_alias[*]
       2 prsnl_alias_id = f8
       2 person_id = f8
       2 updt_cnt = i4
       2 updt_dt_tm = dq8
       2 updt_id = f8
       2 updt_task = i4
       2 updt_applctx = i4
       2 active_ind = i2
       2 active_status_cd = f8
       2 active_status_dt_tm = dq8
       2 active_status_prsnl_id = f8
       2 alias_pool_cd = f8
       2 prsnl_alias_type_cd = f8
       2 alias = vc
       2 prsnl_alias_sub_type_cd = f8
       2 check_digit = i4
       2 check_digit_method_cd = f8
       2 beg_effective_dt_tm = dq8
       2 end_effective_dt_tm = dq8
       2 data_status_cd = f8
       2 data_status_dt_tm = dq8
       2 data_status_prsnl_id = f8
       2 contributor_system_cd = f8
       2 display = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
  ENDIF
  SET req_prsnlalias_by_pool->alias_pool_cd = request->alias_pool_cd
  EXECUTE cv_get_prsnlalias_by_pool
  IF ((reply->status_data.status="S"))
   SET atleastonesuccess = "S"
   SET stat = alterlist(reply->qual,(aliascount+ size(req_prsnlalias_by_pool->prsnl_alias,5)))
   FOR (count1 = 1 TO size(req_prsnlalias_by_pool->prsnl_alias,5))
     SET aliascount = (aliascount+ 1)
     SET reply->qual[aliascount].alias = req_prsnlalias_by_pool->prsnl_alias[count1].alias
     SET reply->qual[aliascount].source_id = req_prsnlalias_by_pool->prsnl_alias[count1].person_id
     SET reply->qual[aliascount].alias_type_nbr = 2
     SET reply->qual[aliascount].display = req_prsnlalias_by_pool->prsnl_alias[count1].display
   ENDFOR
   SET aliascount2 = (aliascount - aliascount1)
  ENDIF
  IF ((reply->status_data.status="Z"))
   CALL sn_log_message(lvl_info,log_to_reply,"PRSNL_ALIAS","No records in Prsnl Alias Pool")
   IF (atleastonesuccess="S")
    SET reply->status_data.status = "S"
   ENDIF
  ELSEIF ((reply->status_data.status="F"))
   CALL sn_log_message(lvl_error,log_to_reply,"PRSNL_ALIAS","Error in Prsnl Alias Pool")
   IF (atleastonesuccess="S")
    SET reply->status_data.status = "S"
   ENDIF
  ENDIF
 ENDIF
 IF (band(request->datasets_nbr,4)=4)
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
  EXECUTE cv_get_prsnl_grp_by_class
  IF ((reply->status_data.status="S"))
   SET atleastonesuccess = "S"
   SET stat = alterlist(reply->qual,(aliascount+ size(req_prsnl_grp_by_class->qual,5)))
   FOR (count1 = 1 TO size(req_prsnl_grp_by_class->qual,5))
     SET aliascount = (aliascount+ 1)
     SET delimpos = findstring(prsnlgrp_delimstr,req_prsnl_grp_by_class->qual[count1].
      prsnl_group_desc)
     SET aliaspos = (delimpos+ textlen(prsnlgrp_delimstr))
     SET aliaslen = ((textlen(req_prsnl_grp_by_class->qual[count1].prsnl_group_desc) - aliaspos) - 1)
     SET reply->qual[aliascount].alias = substring(aliaspos,aliaslen,req_prsnl_grp_by_class->qual[
      count1].prsnl_group_desc)
     SET reply->qual[aliascount].source_id = req_prsnl_grp_by_class->qual[count1].prsnl_group_id
     SET reply->qual[aliascount].alias_type_nbr = 1
     SET reply->qual[aliascount].display = substring(1,(delimpos - 1),req_prsnl_grp_by_class->qual[
      count1].prsnl_group_desc)
   ENDFOR
   SET aliascount3 = ((aliascount - aliascount1) - aliascount2)
  ENDIF
  IF ((reply->status_data.status="Z"))
   CALL sn_log_message(lvl_info,log_to_reply,"PRSNL_GRP_ALIAS","No records in Prsnl Grp Alias Pool")
   IF (atleastonesuccess="S")
    SET reply->status_data.status = "S"
   ENDIF
  ELSEIF ((reply->status_data.status="F"))
   CALL sn_log_message(lvl_error,log_to_reply,"PRSNL_GRP_ALIAS","Error in Prsnl Grp Alias Pool")
   IF (atleastonesuccess="S")
    SET reply->status_data.status = "S"
   ENDIF
  ENDIF
 ENDIF
 IF ( NOT ((reply->status_data.status="F")))
  IF (aliascount=0)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 CALL echo(build("Count of Org Alias = ",aliascount1))
 CALL echo(build("Count of Prsnl Alias = ",aliascount2))
 CALL echo(build("Count of Prsnl_grp Alias = ",aliascount3))
END GO
