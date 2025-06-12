CREATE PROGRAM dd_rem_default_print_methods:dba
 DECLARE err_code = f8 WITH protect, noconstant(0.0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE indx = i4 WITH protect, noconstant(0)
 DECLARE deletepref = i2 WITH protect, noconstant(0)
 DECLARE pref_to_del = vc WITH constant("print methods")
 DECLARE pref_val_to_del = vc WITH constant("1;1;0;0;0")
 DECLARE status = vc WITH noconstant("")
 DECLARE message = vc WITH noconstant("")
 SET status = "F"
 SET message = concat("Error - Failed to delete preference:",error_msg)
 FREE RECORD requestin
 FREE RECORD replyout
 RECORD requestin(
   1 config_names[*]
     2 config_name = vc
 )
 SET stat = alterlist(requestin->config_names,1)
 SET requestin->config_names[1].config_name = pref_to_del
 SET stat = tdbexecute(3202004,3202004,969597,"REC",requestin,
  "REC",replyout)
 IF (stat != 0)
  SET status = "F"
  SET message = concat("Error - tdbexecute for request 969597 returned stat = 1:",error_msg)
  GO TO exit_script
 ENDIF
 SET err_code = error(error_msg,1)
 IF (err_code > 0)
  SET status = "F"
  SET message = concat("Error - Failed to delete preference:",error_msg)
  GO TO exit_script
 ENDIF
 FOR (indx = 1 TO size(replyout->config_values,5))
   IF ((replyout->config_values[indx].facility_cd=0.0)
    AND (replyout->config_values[indx].nurse_unit_cd=0.0)
    AND (replyout->config_values[indx].note_type_id=0.0)
    AND (replyout->config_values[indx].position_cd=0.0)
    AND (replyout->config_values[indx].soc_type_cd=0.0))
    IF (size(replyout->config_values[indx].values,5)=1)
     IF (trim(replyout->config_values[indx].values[1].config_value)=pref_val_to_del)
      SET deletepref = 1
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 FREE RECORD requestin
 IF (deletepref=1)
  RECORD requestin(
    1 user_id = f8
    1 config_values[*]
      2 facility_cd = f8
      2 nurse_unit_cd = f8
      2 note_type_id = f8
      2 position_cd = f8
      2 soc_type_cd = f8
      2 name = vc
      2 values[*]
        3 config_value = vc
      2 del_ind = i2
  )
  SET stat = alterlist(requestin->config_values,1)
  SET requestin->user_id = 0.0
  SET requestin->config_values[1].facility_cd = 0.0
  SET requestin->config_values[1].nurse_unit_cd = 0.0
  SET requestin->config_values[1].note_type_id = 0.0
  SET requestin->config_values[1].position_cd = 0.0
  SET requestin->config_values[1].soc_type_cd = 0.0
  SET requestin->config_values[1].name = pref_to_del
  SET requestin->config_values[1].del_ind = 1
  SET stat = tdbexecute(3202004,3202004,969598,"REC",requestin,
   "REC",replyout)
  IF (stat != 0)
   SET status = "F"
   SET message = concat("Error - tdbexecute for request 969598 returned stat = 1:",error_msg)
   GO TO exit_script
  ENDIF
  SET err_code = error(error_msg,1)
  IF (err_code > 0)
   SET status = "F"
   SET message = concat("Error - Failed to delete preference:",error_msg)
   GO TO exit_script
  ELSE
   SET status = "S"
   SET message = "Success: Preference is deleted."
  ENDIF
 ELSE
  SET status = "S"
  SET message = "Success: No invalid default preferences found."
 ENDIF
#exit_script
 CALL echo(build2("status: ",status))
 CALL echo(build2("message: ",message))
END GO
