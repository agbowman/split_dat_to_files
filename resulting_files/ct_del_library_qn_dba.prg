CREATE PROGRAM ct_del_library_qn:dba
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
 RECORD reply(
   1 status_data
     2 status = c1
     2 reason_for_failure = vc
 )
 SET reply->status_data.status = "F"
 SET failed = false
 DECLARE long_text_id = f8 WITH protect, noconstant(0.0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 SELECT INTO "nl:"
  eql.elig_quest_library_id
  FROM elig_quest_library eql
  WHERE (eql.elig_quest_library_id=request->elig_quest_library_id)
  DETAIL
   long_text_id = eql.long_text_id
  WITH nocounter
 ;end select
 DELETE  FROM elig_quest_library eql
  WHERE (eql.elig_quest_library_id=request->elig_quest_library_id)
 ;end delete
 IF (curqual=0)
  SET failed = true
  SET reply->status_data.reason_for_failure = "Cannot delete question"
 ENDIF
 DELETE  FROM long_text_reference ltr
  WHERE ltr.long_text_id=long_text_id
 ;end delete
 IF (curqual=0)
  SET failed = true
  SET reply->status_data.reason_for_failure = "Cannot delete question text."
 ENDIF
#exit_script
 IF (failed=true)
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "001"
 SET mod_date = "April 02, 2004"
END GO
