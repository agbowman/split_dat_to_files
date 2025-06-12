CREATE PROGRAM bed_get_ens_tasks_pubmedrec:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD dprequest(
   1 dplist[*]
     2 action_flag = c1
     2 application_number = i4
     2 position_cd = f8
     2 prsnl_id = f8
     2 person_id = f8
     2 view_name = c12
     2 view_seq = i4
     2 comp_name = c12
     2 comp_seq = i4
 )
 FREE SET dpreply
 RECORD dpreply(
   1 dplist[*]
     2 detail_prefs_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD nvprequest(
   1 nvplist[*]
     2 action_flag = c1
     2 parent_entity_name = c32
     2 parent_entity_id = f8
     2 pvc_name = c32
     2 pvc_value = c256
 )
 FREE SET nvpreply
 RECORD nvpreply(
   1 nvplist[*]
     2 name_value_prefs_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET stat = alterlist(dprequest->dplist,1)
 SET dprequest->dplist[1].application_number = request->application_number
 SET dprequest->dplist[1].position_cd = request->position_cd
 SET dprequest->dplist[1].prsnl_id = request->prsnl_id
 SET dprequest->dplist[1].person_id = 0.0
 SET dprequest->dplist[1].view_name = "AUTHORIZE"
 SET dprequest->dplist[1].view_seq = 0
 SET dprequest->dplist[1].comp_name = "AUTHORIZE"
 SET dprequest->dplist[1].comp_seq = 0
 SET stat = alterlist(nvprequest->nvplist,1)
 SET stat = alterlist(nvpreply->nvplist,1)
 SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
 SET nvprequest->nvplist[1].pvc_name = "COMMAND_32888"
 SET dprequest->dplist[1].action_flag = "0"
 SET trace = recpersist
 EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
 SET menu_auth_value = "  "
 SET nvp_exists = 0
 IF ((dpreply->dplist[1].detail_prefs_id > 0))
  SELECT INTO "NL:"
   FROM name_value_prefs nvp
   WHERE nvp.parent_entity_name="DETAIL_PREFS"
    AND (nvp.parent_entity_id=dpreply->dplist[1].detail_prefs_id)
    AND nvp.pvc_name="COMMAND_32888"
    AND nvp.active_ind=1
   DETAIL
    nvp_exists = 1, menu_auth_value = nvp.pvc_value
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->action="0"))
  SET reply->status_data.status = "F"
  IF ((((dpreply->dplist[1].detail_prefs_id=0)) OR (nvp_exists=0)) )
   SET dprequest->dplist[1].position_cd = 0.0
   SET trace = recpersist
   EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
   IF ((dpreply->dplist[1].detail_prefs_id > 0))
    SELECT INTO "NL:"
     FROM name_value_prefs nvp
     WHERE nvp.parent_entity_name="DETAIL_PREFS"
      AND (nvp.parent_entity_id=dpreply->dplist[1].detail_prefs_id)
      AND nvp.pvc_name="COMMAND_32888"
      AND nvp.active_ind=1
     DETAIL
      menu_auth_value = nvp.pvc_value
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
  IF (menu_auth_value="1")
   SET reply->status_data.status = "S"
  ENDIF
 ELSEIF ((request->action="2"))
  IF ((dpreply->dplist[1].detail_prefs_id=0))
   SET dprequest->dplist[1].action_flag = "1"
   SET trace = recpersist
   EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
  ENDIF
  SET stat = alterlist(nvprequest->nvplist,1)
  SET stat = alterlist(nvpreply->nvplist,1)
  SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
  SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
  SET nvprequest->nvplist[1].pvc_name = "COMMAND_32888"
  IF (nvp_exists > 0)
   IF (menu_auth_value != "1")
    SET nvprequest->nvplist[1].pvc_value = "1"
    SET nvprequest->nvplist[1].action_flag = "2"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
  ELSE
   SET nvprequest->nvplist[1].pvc_value = "1"
   SET nvprequest->nvplist[1].action_flag = "1"
   SET trace = recpersist
   EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",nvpreply
    )
  ENDIF
 ELSEIF ((request->action="3"))
  IF ((dpreply->dplist[1].detail_prefs_id=0))
   SET dprequest->dplist[1].action_flag = "1"
   SET trace = recpersist
   EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
  ENDIF
  SET stat = alterlist(nvprequest->nvplist,1)
  SET stat = alterlist(nvpreply->nvplist,1)
  SET nvprequest->nvplist[1].parent_entity_name = "DETAIL_PREFS"
  SET nvprequest->nvplist[1].parent_entity_id = dpreply->dplist[1].detail_prefs_id
  SET nvprequest->nvplist[1].pvc_name = "COMMAND_32888"
  IF (nvp_exists > 0)
   IF (menu_auth_value != "-2")
    SET nvprequest->nvplist[1].pvc_value = "-2"
    SET nvprequest->nvplist[1].action_flag = "2"
    SET trace = recpersist
    EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",
     nvpreply)
   ENDIF
  ELSE
   SET nvprequest->nvplist[1].pvc_value = "-2"
   SET nvprequest->nvplist[1].action_flag = "1"
   SET trace = recpersist
   EXECUTE bed_get_ens_name_value_prefs  WITH replace("REQUEST",nvprequest), replace("REPLY",nvpreply
    )
  ENDIF
 ENDIF
#exitscript
END GO
