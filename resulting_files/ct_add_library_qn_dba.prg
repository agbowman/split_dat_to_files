CREATE PROGRAM ct_add_library_qn:dba
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
 IF ( NOT (validate(domain_reply)))
  RECORD domain_reply(
    1 logical_domain_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 EXECUTE ct_get_logical_domain_id  WITH replace("REPLY",domain_reply)
 RECORD reply(
   1 elig_quest_library_id = f8
   1 status_data
     2 status = c1
     2 reason_for_failure = vc
 )
 SET reply->status_data.status = "F"
 DECLARE domain_id = f8 WITH protect, noconstant(0.0)
 DECLARE add_count = i2 WITH protect, noconstant(0)
 DECLARE eql_id = f8 WITH protect, noconstant(0.0)
 DECLARE count1 = i2 WITH protect, noconstant(0)
 DECLARE failed = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 SELECT INTO "nl:"
  nextseqnum = seq(protocol_def_seq,nextval)
  FROM dual
  DETAIL
   eql_id = nextseqnum
  WITH format, nocounter
 ;end select
 INSERT  FROM long_text_reference ltr
  SET ltr.long_text_id = seq(long_data_seq,nextval), ltr.long_text = request->eql_question, ltr
   .parent_entity_name = "ELIG_QUEST_LIBRARY",
   ltr.parent_entity_id = eql_id, ltr.updt_dt_tm = cnvtdatetime(sysdate), ltr.updt_id = reqinfo->
   updt_id,
   ltr.updt_applctx = reqinfo->updt_applctx, ltr.updt_task = reqinfo->updt_task, ltr.updt_cnt = 0,
   ltr.active_ind = 1, ltr.active_status_cd = reqdata->active_status_cd, ltr.active_status_dt_tm =
   cnvtdatetime(sysdate),
   ltr.active_status_prsnl_id = reqinfo->updt_id
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = true
  SET reply->status_data.reason_for_failure = "Unable to insert into long_text_reference table."
  GO TO exit_script
 ENDIF
 INSERT  FROM elig_quest_library eql
  SET eql.long_text_id = seq(long_data_seq,currval), eql.elig_quest_library_id = eql_id, eql
   .eql_cat_cd = request->eql_cat_cd,
   eql.eql_label = request->eql_label, eql.answer_format_id = request->answer_format_id, eql
   .value_required_flag = request->val_reqd_flag,
   eql.date_required_flag = request->dt_reqd_flag, eql.updt_dt_tm = cnvtdatetime(sysdate), eql
   .updt_id = reqinfo->updt_id,
   eql.updt_task = reqinfo->updt_task, eql.updt_applctx = reqinfo->updt_applctx, eql.updt_cnt = 0,
   eql.logical_domain_id = domain_reply->logical_domain_id
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = true
  SET reply->status_data.reason_for_failure = "Unable to insert"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed=true)
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
  SET reply->elig_quest_library_id = eql_id
 ENDIF
 SET last_mod = "003"
 SET mod_date = "Nov 22, 2019"
END GO
