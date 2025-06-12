CREATE PROGRAM bhs_athn_read_privs_by_key
 RECORD orequest(
   1 patient_user_criteria
     2 user_id = f8
     2 patient_user_relationship_cd = f8
   1 privilege_criteria
     2 privileges[*]
       3 privilege_cd = f8
     2 locations[*]
       3 location_id = f8
 )
 RECORD out_rec(
   1 status = vc
   1 patient_user_information
     2 user_id = vc
     2 patient_user_relationship_cd = vc
     2 patient_user_relationship_disp = vc
     2 role_id = vc
     2 role_disp = vc
   1 privileges[*]
     2 privilege_disp = vc
     2 privilege_meaning = vc
     2 privilege_cd = vc
     2 priviledge_value_disp = vc
     2 priviledge_value_meaning = vc
     2 priviledge_value_cd = vc
     2 exceptions[*]
       3 entity_name = vc
       3 entity_value_disp = vc
       3 entity_value_cd = vc
       3 exception_type_disp = vc
       3 exception_type_meaning = vc
       3 exception_type_cd = vc
 )
 SET orequest->patient_user_criteria.user_id =  $2
 SET orequest->patient_user_criteria.patient_user_relationship_cd =  $3
 DECLARE t_line = vc
 DECLARE t_line2 = vc
 DECLARE t_code = f8
 DECLARE done = i2
 SET cnt = 0
 SET t_line =  $4
 WHILE (done=0)
   IF (findstring(",",t_line)=0)
    SET cnt += 1
    IF (isnumeric(t_line)=0)
     SET stat = alterlist(orequest->privilege_criteria.privileges,cnt)
     SET orequest->privilege_criteria.privileges[cnt].privilege_cd = uar_get_code_by("MEANING",6016,
      t_line)
    ELSE
     SET stat = alterlist(orequest->privilege_criteria.privileges,cnt)
     SET orequest->privilege_criteria.privileges[cnt].privilege_cd = cnvtreal(t_line)
    ENDIF
    SET done = 1
   ELSE
    SET cnt += 1
    SET t_line2 = substring(1,(findstring(",",t_line) - 1),t_line)
    IF (isnumeric(t_line2)=0)
     SET stat = alterlist(orequest->privilege_criteria.privileges,cnt)
     SET orequest->privilege_criteria.privileges[cnt].privilege_cd = uar_get_code_by("MEANING",6016,
      t_line2)
    ELSE
     SET stat = alterlist(orequest->privilege_criteria.privileges,cnt)
     SET orequest->privilege_criteria.privileges[cnt].privilege_cd = cnvtreal(t_line2)
    ENDIF
    SET t_line = substring((findstring(",",t_line)+ 1),textlen(t_line),t_line)
   ENDIF
 ENDWHILE
 SET stat = tdbexecute(5000,6022,680500,"REC",orequest,
  "REC",oreply,4)
 IF ((oreply->transaction_status.success_ind=1))
  SET out_rec->status = "Success"
 ELSE
  SET out_rec->status = "Failed"
 ENDIF
 SET out_rec->patient_user_information.user_id = cnvtstring(oreply->patient_user_information.user_id)
 SET out_rec->patient_user_information.patient_user_relationship_cd = cnvtstring(oreply->
  patient_user_information.patient_user_relationship_cd)
 SET out_rec->patient_user_information.patient_user_relationship_disp = uar_get_code_display(oreply->
  patient_user_information.patient_user_relationship_cd)
 SET out_rec->patient_user_information.role_id = cnvtstring(oreply->patient_user_information.role_id)
 SET out_rec->patient_user_information.role_disp = uar_get_code_display(oreply->
  patient_user_information.role_id)
 SET stat = alterlist(out_rec->privileges,size(oreply->privileges,5))
 FOR (i = 1 TO size(oreply->privileges,5))
   SET out_rec->privileges[i].privilege_cd = cnvtstring(oreply->privileges[i].privilege_cd)
   SET out_rec->privileges[i].privilege_disp = uar_get_code_display(oreply->privileges[i].
    privilege_cd)
   SET out_rec->privileges[i].privilege_meaning = uar_get_code_meaning(oreply->privileges[i].
    privilege_cd)
   IF ((oreply->privileges[i].default.granted_ind=0)
    AND size(oreply->privileges[i].default.exceptions,5)=0)
    SET out_rec->privileges[i].priviledge_value_cd = "2629"
    SET t_code = 2629
   ELSEIF ((oreply->privileges[i].default.granted_ind=0)
    AND size(oreply->privileges[i].default.exceptions,5) > 0)
    SET out_rec->privileges[i].priviledge_value_cd = "2630"
    SET t_code = 2630
   ELSEIF ((oreply->privileges[i].default.granted_ind=1)
    AND size(oreply->privileges[i].default.exceptions,5)=0)
    SET out_rec->privileges[i].priviledge_value_cd = "2631"
    SET t_code = 2631
   ELSEIF ((oreply->privileges[i].default.granted_ind=1)
    AND size(oreply->privileges[i].default.exceptions,5) > 0)
    SET out_rec->privileges[i].priviledge_value_cd = "2632"
    SET t_code = 2632
   ENDIF
   SET out_rec->privileges[i].priviledge_value_disp = uar_get_code_display(t_code)
   SET out_rec->privileges[i].priviledge_value_meaning = uar_get_code_meaning(t_code)
   SET stat = alterlist(out_rec->privileges[i].exceptions,size(oreply->privileges[i].default.
     exceptions,5))
   FOR (j = 1 TO size(oreply->privileges[i].default.exceptions,5))
     SET out_rec->privileges[i].exceptions[j].entity_name = oreply->privileges[i].default.exceptions[
     j].entity_name
     SET out_rec->privileges[i].exceptions[j].entity_value_cd = cnvtstring(oreply->privileges[i].
      default.exceptions[j].id)
     SET out_rec->privileges[i].exceptions[j].entity_value_disp = uar_get_code_display(oreply->
      privileges[i].default.exceptions[j].id)
     SET out_rec->privileges[i].exceptions[j].exception_type_cd = cnvtstring(oreply->privileges[i].
      default.exceptions[j].type_cd)
     SET out_rec->privileges[i].exceptions[j].exception_type_disp = uar_get_code_display(oreply->
      privileges[i].default.exceptions[j].type_cd)
     SET out_rec->privileges[i].exceptions[j].exception_type_meaning = uar_get_code_meaning(oreply->
      privileges[i].default.exceptions[j].type_cd)
   ENDFOR
 ENDFOR
 SET _memory_reply_string = cnvtrectojson(out_rec)
END GO
