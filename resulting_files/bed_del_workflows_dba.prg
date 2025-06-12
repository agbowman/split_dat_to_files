CREATE PROGRAM bed_del_workflows:dba
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
 RECORD wkflw(
   1 wkflw_list[*]
     2 wkflw_id = f8
     2 wkflw_val = c256
 )
 DECLARE pparse = vc
 SET stat = alterlist(dprequest->dplist,1)
 SET dprequest->dplist[1].application_number = request->application_number
 SET dprequest->dplist[1].position_cd = request->position_cd
 SET dprequest->dplist[1].prsnl_id = 0.0
 SET dprequest->dplist[1].person_id = 0.0
 SET dprequest->dplist[1].view_name = "PCOFFICE"
 SET dprequest->dplist[1].view_seq = 0
 SET dprequest->dplist[1].comp_name = "PCOFFICE"
 SET dprequest->dplist[1].comp_seq = 0
 SET dprequest->dplist[1].action_flag = "0"
 SET trace = recpersist
 EXECUTE bed_get_ens_detail_prefs  WITH replace("REQUEST",dprequest), replace("REPLY",dpreply)
 IF ((dpreply->dplist[1].detail_prefs_id > 0))
  SET wkflw_value = concat(trim(request->pvc_value),",,1")
  SET wkflw_cd = 0.0
  SELECT INTO "NL:"
   FROM name_value_prefs nvp
   WHERE nvp.parent_entity_name="DETAIL_PREFS"
    AND (nvp.parent_entity_id=dpreply->dplist[1].detail_prefs_id)
    AND nvp.pvc_value=wkflw_value
   DETAIL
    wkflw_cd = nvp.name_value_prefs_id
   WITH nocounter
  ;end select
  IF (wkflw_cd > 0)
   DELETE  FROM name_value_prefs nvp
    WHERE nvp.name_value_prefs_id=wkflw_cd
    WITH nocounter
   ;end delete
  ENDIF
  SET wkflw_value = concat("'*",trim(request->pvc_value),"*'")
  SET pparse = concat("nvp.pvc_value = ",wkflw_value)
  SET tot_wkflw = 0
  SELECT INTO "nl:"
   nvp.name_value_prefs_id, nvp.pvc_value
   FROM name_value_prefs nvp
   WHERE parser(pparse)
    AND nvp.parent_entity_name="DETAIL_PREFS"
    AND (nvp.parent_entity_id=dpreply->dplist[1].detail_prefs_id)
   DETAIL
    tot_wkflw = (tot_wkflw+ 1), stat = alterlist(wkflw->wkflw_list,tot_wkflw), wkflw->wkflw_list[
    tot_wkflw].wkflw_id = nvp.name_value_prefs_id,
    wkflw->wkflw_list[tot_wkflw].wkflw_val = nvp.pvc_value
   WITH nocounter
  ;end select
  IF (tot_wkflw > 0)
   FOR (wcnt = 1 TO tot_wkflw)
     SET field1 = fillstring(256," ")
     SET field2 = fillstring(256," ")
     SET comma1 = 0
     SET comma2 = 0
     SET comma1 = findstring(",",wkflw->wkflw_list[wcnt].wkflw_val,1)
     SET comma2 = findstring(",",wkflw->wkflw_list[wcnt].wkflw_val,(comma1+ 1))
     IF (comma1 > 0
      AND comma2 > 0)
      SET field1 = substring(1,(comma1 - 1),wkflw->wkflw_list[wcnt].wkflw_val)
      SET len = ((comma2 - 1) - comma1)
      SET field2 = substring((comma1+ 1),len,wkflw->wkflw_list[wcnt].wkflw_val)
      IF (trim(field1)=trim(request->pvc_value))
       SET wkflw->wkflw_list[wcnt].wkflw_val = concat(trim(field2),",,1")
      ELSE
       SET wkflw->wkflw_list[wcnt].wkflw_val = concat(trim(field1),",,1")
      ENDIF
      UPDATE  FROM name_value_prefs nvp
       SET nvp.pvc_value = wkflw->wkflw_list[wcnt].wkflw_val, nvp.updt_cnt = (nvp.updt_cnt+ 1), nvp
        .updt_id = reqinfo->updt_id,
        nvp.updt_dt_tm = cnvtdatetime(curdate,curtime), nvp.updt_task = reqinfo->updt_task, nvp
        .updt_applctx = reqinfo->updt_applctx
       WHERE (nvp.name_value_prefs_id=wkflw->wkflw_list[wcnt].wkflw_id)
       WITH nocounter
      ;end update
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
END GO
