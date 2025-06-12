CREATE PROGRAM cps_ens_network:dba
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
    1 network_qual = i2
    1 network[*]
      2 network_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET table_name = "NETWORK"
 SET stat = alterlist(reply->network,request->network_qual)
 IF ((request->network_qual > 0))
  FOR (inx0 = 1 TO request->network_qual)
    CASE (request->network[inx0].action_type)
     OF "ADD":
      SET action_begin = inx0
      SET action_end = inx0
      EXECUTE cps_add_hp_network
      IF (failed != false)
       GO TO check_error
      ENDIF
     OF "UPT":
      SET action_begin = inx0
      SET action_end = inx0
      EXECUTE cps_upt_network
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
  SET reply->network_qual = request->network_qual
  SET reqinfo->commit_ind = true
 ELSE
  SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
 ENDIF
#end_program
END GO
