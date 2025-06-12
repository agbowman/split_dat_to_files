CREATE PROGRAM ct_chg_lib_qn:dba
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
   1 status = c1
   1 reason_for_failure = vc
 )
 SET reply->status = "F"
 DECLARE long_text_id = f8 WITH protect, noconstant(0.0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 SELECT INTO "nl:"
  eql.elig_quest_library_id
  FROM elig_quest_library eql
  WHERE (eql.elig_quest_library_id=request->elig_quest_library_id)
  DETAIL
   long_text_id = eql.long_text_id
  WITH nocounter, forupdate(eql)
 ;end select
 IF (curqual=0)
  SET failed = true
  SET reply->status = "F"
  SET reply->reason_for_failure = "Library Question does not exist."
  GO TO exit_script
 ENDIF
 UPDATE  FROM elig_quest_library eql
  SET eql.eql_cat_cd = request->eql_cat_cd, eql.eql_label = request->eql_label, eql.answer_format_id
    = request->answer_format_id,
   eql.value_required_flag = request->value_required_flag, eql.date_required_flag = request->
   date_required_flag, eql.updt_cnt = (eql.updt_cnt+ 1),
   eql.updt_dt_tm = cnvtdatetime(sysdate), eql.updt_id = reqinfo->updt_id, eql.updt_task = reqinfo->
   updt_task,
   eql.updt_applctx = reqinfo->updt_applctx
  WHERE (eql.elig_quest_library_id=request->elig_quest_library_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed = true
  SET reply->reason_for_failure = "Unable to update Elig_Quest_Library table"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  ltr.long_text_id
  FROM long_text_reference ltr
  WHERE ltr.long_text_id=long_text_id
  WITH nocounter, forupdate(eql)
 ;end select
 IF (curqual=0)
  SET failed = true
  SET reply->status = "F"
  SET reply->reason_for_failure = "Long_Text Question does not exist."
  GO TO exit_script
 ENDIF
 UPDATE  FROM long_text_reference ltr
  SET ltr.long_text = request->eql_question, ltr.updt_dt_tm = cnvtdatetime(sysdate), ltr.updt_id =
   reqinfo->updt_id,
   ltr.updt_applctx = reqinfo->updt_applctx, ltr.updt_task = reqinfo->updt_task, ltr.updt_cnt = (ltr
   .updt_cnt+ 1)
  WHERE ltr.long_text_id=long_text_id
  WITH nocounter
 ;end update
 IF (curqual=0)
  SET failed = true
  SET reply->reason_for_failure = "Unable to update Long_Text_Reference table"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed=true)
  SET reqinfo->commit_ind = 0
  SET reply->status = "F"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status = "S"
 ENDIF
 SET last_mod = "001"
 SET mod_date = "April 02, 2004"
END GO
