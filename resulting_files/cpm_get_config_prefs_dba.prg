CREATE PROGRAM cpm_get_config_prefs:dba
 RECORD reply(
   1 config_name_cnt = i4
   1 cn_list[*]
     2 config_status = c1
     2 config_name = vc
     2 config_value = vc
     2 flexed_by = vc
     2 parent_entity_name = vc
     2 parent_entity_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 cn_cnt = i4
   1 cn_list[*]
     2 config_name = vc
     2 config_value = vc
     2 flexed_by = vc
     2 parent_entity_name = vc
     2 parent_entity_id = f8
 )
 DECLARE cn_cnt = i4 WITH noconstant(size(request->cn_list,5))
 DECLARE count1 = i4 WITH noconstant(0)
 DECLARE start = i4 WITH noconstant(1)
 DECLARE stop = i4 WITH noconstant(size(request->cn_list,5))
 DECLARE num = i4
 DECLARE bnd_cnt = i4
 DECLARE x = i4 WITH noconstant(0)
 DECLARE y = i4 WITH noconstant(0)
 DECLARE check = i4 WITH noconstant(0)
 SET reply->status_data.status = "S"
 SET reply->config_name_cnt = cn_cnt
 SET stat = alterlist(reply->cn_list,cn_cnt)
 SET request->organization_id = 0
 IF ((request->organization_id=0))
  SELECT INTO "NL:"
   cp.config_name
   FROM config_prefs cp
   WHERE expand(num,start,stop,cp.config_name,request->cn_list[num].config_name)
    AND cp.flexed_by="INSTALLATION"
   ORDER BY cp.config_name
   DETAIL
    count1 = (count1+ 1)
    IF (count1 > size(temp->cn_list,5))
     stat = alterlist(temp->cn_list,(count1+ 10))
    ENDIF
    temp->cn_list[count1].config_name = cp.config_name, temp->cn_list[count1].config_value = cp
    .config_value, temp->cn_list[count1].flexed_by = cp.flexed_by,
    temp->cn_list[count1].parent_entity_name = cp.parent_entity_name, temp->cn_list[count1].
    parent_entity_id = cp.parent_entity_id
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "NL:"
   cp.config_name
   FROM config_prefs cp
   WHERE expand(num,start,stop,cp.config_name,request->cn_list[num].config_name)
   ORDER BY cp.config_name
   DETAIL
    count1 = (count1+ 1)
    IF (count1 > size(temp->cn_list,5))
     stat = alterlist(temp->cn_list,(count1+ 10))
    ENDIF
    temp->cn_list[count1].config_name = cp.config_name, temp->cn_list[count1].config_value = cp
    .config_value, temp->cn_list[count1].flexed_by = cp.flexed_by,
    temp->cn_list[count1].parent_entity_name = cp.parent_entity_name, temp->cn_list[count1].
    parent_entity_id = cp.parent_entity_id
   WITH nocounter
  ;end select
 ENDIF
 IF (count1=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 IF ((request->organization_id > 0))
  GO TO org_flexing
 ENDIF
 FOR (x = 1 TO cn_cnt)
   SET check = 0
   SET reply->cn_list[x].config_name = request->cn_list[x].config_name
   FOR (y = 1 TO count1)
     IF ((temp->cn_list[y].config_name=request->cn_list[x].config_name))
      SET reply->cn_list[x].config_value = temp->cn_list[y].config_value
      SET reply->cn_list[x].flexed_by = temp->cn_list[y].flexed_by
      SET reply->cn_list[x].parent_entity_name = temp->cn_list[y].parent_entity_name
      SET reply->cn_list[x].parent_entity_id = temp->cn_list[y].parent_entity_id
      SET reply->cn_list[x].config_status = "S"
      SET check = 1
     ENDIF
   ENDFOR
   IF (check=0)
    SET reply->cn_list[x].config_status = "Z"
   ENDIF
 ENDFOR
 GO TO exit_script
#org_flexing
#exit_script
 FOR (x = 1 TO cn_cnt)
   CALL echo(build("status:",reply->cn_list[x].config_status))
   CALL echo(build("flexed by:",reply->cn_list[x].flexed_by))
   CALL echo(build("parent name:",reply->cn_list[x].parent_entity_name))
   CALL echo(build("parent id:",reply->cn_list[x].parent_entity_id))
   CALL echo(build("name:",reply->cn_list[x].config_name))
   CALL echo(build("value:",reply->cn_list[x].config_value))
 ENDFOR
END GO
