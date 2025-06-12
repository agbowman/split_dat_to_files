CREATE PROGRAM cps_ens_person:dba
 SET false = 0
 SET true = 1
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET replace_error = 6
 SET delete_error = 7
 SET undelete_error = 8
 SET remove_error = 9
 SET attribute_error = 10
 SET lock_error = 11
 SET none_found = 12
 SET select_error = 13
 SET failed = false
 SET table_name = fillstring(50," ")
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 person_qual = i4
    1 person[*] = i4
      2 person_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[2]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET table_name = "PERSON"
 IF ((request->person_qual > 0))
  SET stat = alterlist(reply->person,request->person_qual)
  FOR (inx0 = 1 TO request->person_qual)
    SET hold_name = concat(trim(request->person[inx0].name_last_key),trim(request->person[inx0].
      name_first_key))
    SET request->person[inx0].name_phonetic = soundex(cnvtupper(hold_name))
    CASE (request->person[inx0].action_type)
     OF "ADD":
      IF ((((request->esi_ensure_type=" ")) OR ((((request->esi_ensure_type=null)) OR ((((request->
      esi_ensure_type="ADD")) OR ((((request->esi_ensure_type="UPT")) OR ((request->esi_ensure_type=
      "RPL"))) )) )) )) )
       SET action_begin = inx0
       SET action_end = inx0
       EXECUTE pm_add_person
      ENDIF
      IF (failed != false)
       GO TO check_error
      ENDIF
      SET request->person[inx0].autopsy_cd = 0
     OF "UPT":
      IF ((((request->esi_ensure_type=" ")) OR ((((request->esi_ensure_type="UPT")) OR ((request->
      esi_ensure_type=null))) )) )
       SET action_begin = inx0
       SET action_end = inx0
       EXECUTE pm_upt_person
      ENDIF
      IF (failed != false)
       GO TO check_error
      ENDIF
     ELSE
      SET failed = true
      GO TO check_error
    ENDCASE
  ENDFOR
 ENDIF
#check_error
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  CASE (failed)
   OF gen_nbr_error:
    SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR"
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   OF replace_error:
    SET reply->status_data.subeventstatus[1].operationname = "REPLACE"
   OF delete_error:
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
   OF undelete_error:
    SET reply->status_data.subeventstatus[1].operationname = "UNDELETE"
   OF remove_error:
    SET reply->status_data.subeventstatus[1].operationname = "REMOVE"
   OF attribute_error:
    SET reply->status_data.subeventstatus[1].operationname = "ATTRIBUTE"
   OF lock_error:
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
 ENDIF
#end_program
END GO
