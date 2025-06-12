CREATE PROGRAM act_ens_allergy:dba
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
 SET data_error = 14
 SET general_error = 15
 SET reactivate_error = 16
 SET eff_error = 17
 SET ccl_error = 18
 SET recalc_error = 19
 SET input_error = 20
 SET exe_error = 21
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 RECORD reply(
   1 allergy_cnt = i4
   1 allergy[*]
     2 allergy_instance_id = f8
     2 allergy_id = f8
     2 reaction_cnt = i4
     2 reaction[*]
       3 reaction_id = f8
     2 allergy_comment_cnt = i4
     2 allergy_comment[*]
       3 allergy_comment_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD comment
 RECORD comment(
   1 qual_knt = i4
   1 qual[*]
     2 allergy_comment_id = f8
     2 allergy_id = f8
     2 allergy_instance_id = f8
     2 allergy_comment = vc
     2 comment_dt_tm = dq8
     2 comment_tz = i4
     2 comment_prsnl_id = f8
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 beg_effective_tz = i4
     2 end_effective_dt_tm = dq8
     2 contributor_system_cd = f8
     2 data_status_cd = f8
     2 data_status_dt_tm = dq8
     2 data_status_prsnl_id = f8
 )
 SET stat = alterlist(reply->allergy,request->allergy_cnt)
 SET reply->status_data.status = "F"
 SET code_value = 0.0
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET iadd = 1
 SET upd = 2
 SET none = 0
 SET multi_add = 3
 SET reviewed = 4
 SET allergy_action = none
 SET reaction_action = none
 SET comment_action = none
 SET current_active_ind = 0
 SET current_reaction_act_ind = 0
 SET new_id = 0.0
 SET existing_comment_nbr = 0
 SET comment_exist = false
 SET load_existing_comments_exec = false
 SET allergy_pure_dup = true
 SET allergy_dup = true
 SET allergy_reviewed = false
 SET now_dt_tm = cnvtdatetime(curdate,curtime3)
 SET reaction_status_dt_tm = cnvtdatetime(now_dt_tm)
 SET canceled_cd = 0.0
 SET canceled_dt_tm = cnvtdatetime(curdate,curtime3)
 SET reaction_active_ind = 1
 SET code_value = 0.0
 SET code_set = 12025
 SET cdf_meaning = "CANCELED"
 EXECUTE cpm_get_cd_for_cdf
 SET canceled_cd = code_value
 IF (code_value < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("cdf_meaning ",trim(cdf_meaning)," not found in code_set ",trim(cnvtstring(
     code_set)))
  GO TO exit_script
 ENDIF
 SET code_value = 0.0
 SET code_set = 12025
 SET cdf_meaning = "ACTIVE"
 EXECUTE cpm_get_cd_for_cdf
 SET reaction_status_cd = code_value
 IF (code_value < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("cdf_meaning ",trim(cdf_meaning)," not found in code_set ",trim(cnvtstring(
     code_set)))
  GO TO exit_script
 ENDIF
 IF ((reqdata->data_status_cd < 1))
  SET code_set = 8
  SET cdf_meaning = "AUTH"
  EXECUTE cpm_get_cd_for_cdf
  SET auth_cd = code_value
  IF (code_value < 1)
   SET failed = select_error
   SET table_name = "CODE_VALUE"
   SET serrmsg = concat("cdf_meaning ",trim(cdf_meaning)," not found in code_set ",trim(cnvtstring(
      code_set)))
   GO TO exit_script
  ENDIF
 ELSE
  SET auth_cd = reqdata->data_status_cd
 ENDIF
 SET code_value = 0.0
 SET code_set = 8
 SET cdf_meaning = "UNAUTH"
 EXECUTE cpm_get_cd_for_cdf
 SET unauth_cd = code_value
 IF (code_value < 1)
  SET failed = select_error
  SET table_name = "CODE_VALUE"
  SET serrmsg = concat("cdf_meaning ",trim(cdf_meaning)," not found in code_set ",trim(cnvtstring(
     code_set)))
  GO TO exit_script
 ENDIF
 IF ((reqdata->active_status_cd < 1))
  SET code_value = 0.0
  SET code_set = 48
  SET cdf_meaning = "ACTIVE"
  SET active_cd = code_value
  IF (code_value < 1)
   SET failed = select_error
   SET table_name = "CODE_VALUE"
   SET serrmsg = concat("cdf_meaning ",trim(cdf_meaning)," not found in code_set ",trim(cnvtstring(
      code_set)))
   GO TO exit_script
  ENDIF
 ELSE
  SET active_cd = reqdata->active_status_cd
 ENDIF
 IF ((reqdata->inactive_status_cd < 1))
  SET code_value = 0.0
  SET code_set = 48
  SET cdf_meaning = "INACTIVE"
  SET inactive_cd = code_value
  IF (code_value < 1)
   SET failed = select_error
   SET table_name = "CODE_VALUE"
   SET serrmsg = concat("cdf_meaning ",trim(cdf_meaning)," not found in code_set ",trim(cnvtstring(
      code_set)))
   GO TO exit_script
  ENDIF
 ELSE
  SET inactive_cd = reqdata->inactive_status_cd
 ENDIF
 FOR (i = 1 TO request->allergy_cnt)
   SET comment->qual_knt = 0
   SET load_existing_comments_exec = false
   SET allergy_action = none
   SET reaction_action = none
   SET comment_action = none
   SET allergy_dup = true
   SET allergy_pure_dup = true
   SET allergy_reviewed = false
   IF ((request->allergy[i].reaction_status_cd < 1))
    SET request->allergy[i].reaction_status_cd = reaction_status_cd
   ENDIF
   IF ((request->allergy[i].allergy_id > 0))
    SELECT INTO "nl:"
     FROM allergy a
     PLAN (a
      WHERE (a.allergy_id=request->allergy[i].allergy_id)
       AND ((a.end_effective_dt_tm+ 0) > cnvtdatetime(curdate,curtime3)))
     ORDER BY a.beg_effective_dt_tm
     DETAIL
      request->allergy[i].allergy_instance_id = a.allergy_instance_id
      CASE (request->allergy[i].person_idf)
       OF 0:
        request->allergy[i].person_id = a.person_id
       OF 1:
        request->allergy[i].person_id = request->allergy[i].person_id
       OF 2:
        request->allergy[i].person_id = null
      ENDCASE
      CASE (request->allergy[i].encntr_idf)
       OF 0:
        request->allergy[i].encntr_id = a.encntr_id
       OF 1:
        request->allergy[i].encntr_id = request->allergy[i].encntr_id
       OF 2:
        request->allergy[i].encntr_id = null
      ENDCASE
      CASE (request->allergy[i].substance_nom_idf)
       OF 0:
        request->allergy[i].substance_nom_id = a.substance_nom_id
       OF 1:
        request->allergy[i].substance_nom_id = request->allergy[i].substance_nom_id
       OF 2:
        request->allergy[i].substance_nom_id = null
      ENDCASE
      CASE (request->allergy[i].substance_ftdescf)
       OF 0:
        request->allergy[i].substance_ftdesc = a.substance_ftdesc
       OF 1:
        request->allergy[i].substance_ftdesc = request->allergy[i].substance_ftdesc
       OF 2:
        request->allergy[i].substance_ftdesc = ""
      ENDCASE
      CASE (request->allergy[i].substance_type_cdf)
       OF 0:
        request->allergy[i].substance_type_cd = a.substance_type_cd
       OF 1:
        request->allergy[i].substance_type_cd = request->allergy[i].substance_type_cd
       OF 2:
        request->allergy[i].substance_type_cd = null
      ENDCASE
      CASE (request->allergy[i].reaction_class_cdf)
       OF 0:
        request->allergy[i].reaction_class_cd = a.reaction_class_cd
       OF 1:
        request->allergy[i].reaction_class_cd = request->allergy[i].reaction_class_cd
       OF 2:
        request->allergy[i].reaction_class_cd = null
      ENDCASE
      CASE (request->allergy[i].severity_cdf)
       OF 0:
        request->allergy[i].severity_cd = a.severity_cd
       OF 1:
        request->allergy[i].severity_cd = request->allergy[i].severity_cd
       OF 2:
        request->allergy[i].severity_cd = null
      ENDCASE
      CASE (request->allergy[i].source_of_info_cdf)
       OF 0:
        request->allergy[i].source_of_info_cd = a.source_of_info_cd
       OF 1:
        request->allergy[i].source_of_info_cd = request->allergy[i].source_of_info_cd
       OF 2:
        request->allergy[i].source_of_info_cd = null
      ENDCASE
      CASE (request->allergy[i].source_of_info_ftf)
       OF 0:
        request->allergy[i].source_of_info_ft = a.source_of_info_ft
       OF 1:
        request->allergy[i].source_of_info_ft = request->allergy[i].source_of_info_ft
       OF 2:
        request->allergy[i].source_of_info_ft = ""
      ENDCASE
      CASE (request->allergy[i].onset_dt_tmf)
       OF 0:
        request->allergy[i].onset_dt_tm = a.onset_dt_tm
       OF 1:
        request->allergy[i].onset_dt_tm = request->allergy[i].onset_dt_tm
       OF 2:
        request->allergy[i].onset_dt_tm = null
      ENDCASE
      CASE (request->allergy[i].onset_tzf)
       OF 0:
        request->allergy[i].onset_tz = a.onset_tz
       OF 1:
        request->allergy[i].onset_tz = request->allergy[i].onset_tz
       OF 2:
        request->allergy[i].onset_tz = null
      ENDCASE
      CASE (request->allergy[i].onset_precision_cdf)
       OF 0:
        request->allergy[i].onset_precision_cd = a.onset_precision_cd
       OF 1:
        request->allergy[i].onset_precision_cd = request->allergy[i].onset_precision_cd
       OF 2:
        request->allergy[i].onset_precision_cd = null
      ENDCASE
      CASE (request->allergy[i].onset_precision_flagf)
       OF 0:
        request->allergy[i].onset_precision_flag = a.onset_precision_flag
       OF 1:
        request->allergy[i].onset_precision_flag = request->allergy[i].onset_precision_flag
       OF 2:
        request->allergy[i].onset_precision_flag = null
      ENDCASE
      CASE (request->allergy[i].reaction_status_cdf)
       OF 0:
        request->allergy[i].reaction_status_cd = a.reaction_status_cd
       OF 1:
        request->allergy[i].reaction_status_cd = request->allergy[i].reaction_status_cd
       OF 2:
        request->allergy[i].reaction_status_cd = null
      ENDCASE
      CASE (request->allergy[i].cancel_reason_cdf)
       OF 0:
        request->allergy[i].cancel_reason_cd = a.cancel_reason_cd
       OF 1:
        request->allergy[i].cancel_reason_cd = request->allergy[i].cancel_reason_cd
       OF 2:
        request->allergy[i].cancel_reason_cd = null
      ENDCASE
      CASE (request->allergy[i].cancel_dt_tmf)
       OF 0:
        request->allergy[i].cancel_dt_tm = a.cancel_dt_tm
       OF 1:
        request->allergy[i].cancel_dt_tm = request->allergy[i].cancel_dt_tm
       OF 2:
        request->allergy[i].cancel_dt_tm = null
      ENDCASE
      CASE (request->allergy[i].cancel_prsnl_idf)
       OF 0:
        request->allergy[i].cancel_prsnl_id = a.cancel_prsnl_id
       OF 1:
        request->allergy[i].cancel_prsnl_id = request->allergy[i].cancel_prsnl_id
       OF 2:
        request->allergy[i].cancel_prsnl_id = null
      ENDCASE
      CASE (request->allergy[i].created_prsnl_idf)
       OF 0:
        request->allergy[i].created_prsnl_id = a.created_prsnl_id
       OF 1:
        request->allergy[i].created_prsnl_id = request->allergy[i].created_prsnl_id
       OF 2:
        request->allergy[i].created_prsnl_id = null
      ENDCASE
      CASE (request->allergy[i].reviewed_dt_tmf)
       OF 0:
        request->allergy[i].reviewed_dt_tm = a.reviewed_dt_tm
       OF 1:
        request->allergy[i].reviewed_dt_tm = request->allergy[i].reviewed_dt_tm
       OF 2:
        request->allergy[i].reviewed_dt_tm = null
      ENDCASE
      CASE (request->allergy[i].reviewed_tzf)
       OF 0:
        request->allergy[i].reviewed_tz = a.reviewed_tz
       OF 1:
        request->allergy[i].reviewed_tz = request->allergy[i].reviewed_tz
       OF 2:
        request->allergy[i].reviewed_tz = null
      ENDCASE
      CASE (request->allergy[i].reviewed_prsnl_idf)
       OF 0:
        request->allergy[i].reviewed_prsnl_id = a.reviewed_prsnl_id
       OF 1:
        request->allergy[i].reviewed_prsnl_id = request->allergy[i].reviewed_prsnl_id
       OF 2:
        request->allergy[i].reviewed_prsnl_id = null
      ENDCASE
      CASE (request->allergy[i].active_indf)
       OF 0:
        request->allergy[i].active_ind = a.active_ind
       OF 1:
        request->allergy[i].active_ind = request->allergy[i].active_ind
       OF 2:
        request->allergy[i].active_ind = null
      ENDCASE
      CASE (request->allergy[i].beg_effective_dt_tmf)
       OF 0:
        request->allergy[i].beg_effective_dt_tm = a.beg_effective_dt_tm
       OF 1:
        request->allergy[i].beg_effective_dt_tm = request->allergy[i].beg_effective_dt_tm
       OF 2:
        request->allergy[i].beg_effective_dt_tm = null
      ENDCASE
      CASE (request->allergy[i].beg_effective_tzf)
       OF 0:
        request->allergy[i].beg_effective_tz = a.beg_effective_tz
       OF 1:
        request->allergy[i].beg_effective_tz = request->allergy[i].beg_effective_tz
       OF 2:
        request->allergy[i].beg_effective_tz = null
      ENDCASE
      CASE (request->allergy[i].contributor_system_cdf)
       OF 0:
        request->allergy[i].contributor_system_cd = a.contributor_system_cd
       OF 1:
        request->allergy[i].contributor_system_cd = request->allergy[i].contributor_system_cd
       OF 2:
        request->allergy[i].contributor_system_cd = null
      ENDCASE
      CASE (request->allergy[i].data_status_cdf)
       OF 0:
        request->allergy[i].data_status_cd = a.data_status_cd
       OF 1:
        request->allergy[i].data_status_cd = request->allergy[i].data_status_cd
       OF 2:
        request->allergy[i].data_status_cd = null
      ENDCASE
      CASE (request->allergy[i].data_status_dt_tmf)
       OF 0:
        request->allergy[i].data_status_dt_tm = a.data_status_dt_tm
       OF 1:
        request->allergy[i].data_status_dt_tm = request->allergy[i].data_status_dt_tm
       OF 2:
        request->allergy[i].data_status_dt_tm = null
      ENDCASE
      CASE (request->allergy[i].data_status_prsnl_idf)
       OF 0:
        request->allergy[i].data_status_prsnl_id = a.data_status_prsnl_id
       OF 1:
        request->allergy[i].data_status_prsnl_id = request->allergy[i].data_status_prsnl_id
       OF 2:
        request->allergy[i].data_status_prsnl_id = null
      ENDCASE
      CASE (request->allergy[i].verified_status_flagf)
       OF 0:
        request->allergy[i].verified_status_flag = a.verified_status_flag
       OF 1:
        request->allergy[i].verified_status_flag = request->allergy[i].verified_status_flag
       OF 2:
        request->allergy[i].verified_status_flag = null
      ENDCASE
      CASE (request->allergy[i].rec_src_vocab_cdf)
       OF 0:
        request->allergy[i].rec_src_vocab_cd = a.rec_src_vocab_cd
       OF 1:
        request->allergy[i].rec_src_vocab_cd = request->allergy[i].rec_src_vocab_cd
       OF 2:
        request->allergy[i].rec_src_vocab_cd = null
      ENDCASE
      CASE (request->allergy[i].rec_src_identifierf)
       OF 0:
        request->allergy[i].rec_src_identifier = a.rec_src_identifer
       OF 1:
        request->allergy[i].rec_src_identifier = request->allergy[i].rec_src_identifier
       OF 2:
        request->allergy[i].rec_src_identifier = ""
      ENDCASE
      CASE (request->allergy[i].rec_src_stringf)
       OF 0:
        request->allergy[i].rec_src_string = a.rec_src_string
       OF 1:
        request->allergy[i].rec_src_string = request->allergy[i].rec_src_string
       OF 2:
        request->allergy[i].rec_src_string = ""
      ENDCASE
      CASE (request->allergy[i].orig_prsnl_idf)
       OF 0:
        request->allergy[i].orig_prsnl_id = a.orig_prsnl_id
       OF 1:
        request->allergy[i].orig_prsnl_id = request->allergy[i].orig_prsnl_id
       OF 2:
        request->allergy[i].orig_prsnl_id = null
      ENDCASE
      CASE (request->allergy[i].created_dt_tmf)
       OF 0:
        request->allergy[i].created_dt_tm = a.created_dt_tm
       OF 1:
        request->allergy[i].created_dt_tm = request->allergy[i].created_dt_tm
       OF 2:
        request->allergy[i].created_dt_tm = null
      ENDCASE
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET failed = input_error
     GO TO exit_script
    ENDIF
   ENDIF
   IF ((request->allergy[i].allergy_instance_id > 0))
    SET allergy_dup = true
    CALL is_allergy_pure_dup(i)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "ALLERGY"
     GO TO exit_script
    ENDIF
   ELSE
    CALL is_allergy_dup(i)
    IF (ierrcode > 0)
     SET failed = select_error
     SET table_name = "ALLERGY"
     GO TO exit_script
    ENDIF
    IF (allergy_dup=true)
     CALL is_allergy_pure_dup(i)
     IF (ierrcode > 0)
      SET failed = select_error
      SET table_name = "ALLERGY"
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
   IF (allergy_dup=false)
    CALL echo("***")
    CALL echo("***   Inserting a NEW allergy")
    CALL echo("***")
    SET allergy_action = iadd
    CALL get_next_allergy_seq(i)
    IF (ierrcode > 0)
     SET failed = gen_nbr_error
     SET table_name = "HEALTH_STATUS_SEQ"
     GO TO exit_script
    ENDIF
    SET request->allergy[i].allergy_instance_id = new_id
    SET request->allergy[i].allergy_id = new_id
    SET reaction_status_dt_tm = cnvtdatetime(now_dt_tm)
    IF ((request->allergy[i].reaction_status_cd=canceled_cd))
     IF ((((request->allergy[i].cancel_dt_tm < 1)) OR ((request->allergy[i].cancel_dt_tm=null))) )
      SET request->allergy[i].cancel_dt_tm = cnvtdatetime(curdate,curtime3)
     ENDIF
    ENDIF
    CALL insert_allergy(i)
    IF (ierrcode > 0)
     SET failed = insert_error
     SET table_name = "ALLERGY"
     GO TO exit_script
    ENDIF
   ELSEIF (allergy_dup=true
    AND allergy_pure_dup=false)
    CALL echo("***")
    CALL echo("***   Updating an EXISTING allergy")
    CALL echo("***")
    SET allergy_action = upd
    CALL deactivate_allergy(i)
    IF (ierrcode > 0)
     SET failed = update_error
     SET table_name = "ALLERGY"
     GO TO exit_script
    ENDIF
    CALL get_next_allergy_seq(i)
    IF (ierrcode > 0)
     SET failed = gen_nbr_error
     SET table_name = "HEALTH_STATUS_SEQ"
     GO TO exit_script
    ENDIF
    SET request->allergy[i].allergy_instance_id = new_id
    CALL insert_allergy(i)
    IF (ierrcode > 0)
     SET failed = insert_error
     SET table_name = "ALLERGY"
     GO TO exit_script
    ENDIF
   ELSEIF (allergy_reviewed=true)
    CALL echo("***")
    CALL echo("***   Updating with REVIEW only")
    CALL echo("***")
    SET allergy_action = reviewed
    CALL stamp_reviewed(i)
    IF (ierrcode > 0)
     SET failed = update_error
     SET table_name = "ALLERGY"
     GO TO exit_script
    ENDIF
   ELSEIF (current_active_ind=0
    AND (request->allergy[i].active_ind=1))
    CALL echo("***")
    CALL echo("***   Insert allergy as active")
    CALL echo("***")
    SET allergy_action = upd
    CALL get_next_allergy_seq(i)
    IF (ierrcode > 0)
     SET failed = gen_nbr_error
     SET table_name = "HEALTH_STATUS_SEQ"
     GO TO exit_script
    ENDIF
    SET request->allergy[i].allergy_instance_id = new_id
    CALL insert_allergy(i)
    IF (ierrcode > 0)
     SET failed = insert_error
     SET table_name = "ALLERGY"
     GO TO exit_script
    ENDIF
   ELSEIF (current_active_ind=1
    AND (request->allergy[i].active_ind=0))
    CALL echo("***")
    CALL echo("***   Deactivate an existing allergy")
    CALL echo("***")
    SET allergy_action = upd
    CALL deactivate_allergy(i)
    IF (ierrcode > 0)
     SET failed = update_error
     SET table_name = "ALLERGY"
     GO TO exit_script
    ENDIF
   ENDIF
   SET reply->allergy_cnt = i
   SET reply->allergy[i].allergy_instance_id = request->allergy[i].allergy_instance_id
   SET reply->allergy[i].allergy_id = request->allergy[i].allergy_id
   SET reply->allergy[i].reaction_cnt = request->allergy[i].reaction_cnt
   SET stat = alterlist(reply->allergy[i].reaction,reply->allergy[i].reaction_cnt)
   SET reply->allergy[i].allergy_comment_cnt = request->allergy[i].allergy_comment_cnt
   SET stat = alterlist(reply->allergy[i].allergy_comment,reply->allergy[i].allergy_comment_cnt)
   SET reaction_pure_dup = true
   SET reaction_dup = true
   SET reaction_action = none
   IF ((request->allergy[i].reaction_cnt > 0))
    CALL echo("***")
    CALL echo(build("***   reaction_cnt :",request->allergy[i].reaction_cnt))
    CALL echo("***")
    IF (allergy_action=iadd)
     CALL echo("***")
     CALL echo("***   Inserting reactions for a NEW allergy")
     CALL echo("***")
     SET reaction_action = multi_add
     CALL insert_new_reaction(i)
     IF (ierrcode > 0)
      SET failed = insert_error
      SET table_name = "REACTION"
      GO TO exit_script
     ENDIF
     SET ierrcode = 0
     SELECT INTO "nl:"
      r.reaction_id
      FROM reaction r
      PLAN (r
       WHERE (r.allergy_id=request->allergy[i].allergy_id))
      ORDER BY r.reaction_id
      HEAD REPORT
       knt = 0
      DETAIL
       knt = (knt+ 1), reply->allergy[i].reaction[knt].reaction_id = r.reaction_id, request->allergy[
       i].reaction[knt].reaction_id = r.reaction_id
      FOOT REPORT
       reply->allergy[i].reaction_cnt = knt
      WITH nocounter
     ;end select
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = select_error
      SET table_name = "REACTION"
      GO TO exit_script
     ENDIF
    ELSE
     CALL echo("***")
     CALL echo("***   do reactions for existing allergy")
     CALL echo("***")
     FOR (j = 1 TO request->allergy[i].reaction_cnt)
       CALL echo("***")
       CALL echo(build("***   reaction_cnt :",j))
       CALL echo("***")
       IF ((request->allergy[i].reaction[j].reaction_id > 0))
        SET reaction_dup = true
        CALL echo("***")
        CALL echo(build("***   reaction_id > 0 :",request->allergy[i].reaction[j].reaction_id))
        CALL echo("***   call IS_REACTION_PURE_DUP(i,j)")
        CALL echo("***")
        CALL is_reaction_pure_dup(i,j)
        IF (ierrcode > 0)
         SET failed = select_error
         SET table_name = "REACTION"
         GO TO exit_script
        ENDIF
       ELSE
        CALL echo("***")
        CALL echo("***   possible new reaction call IS_REACTION_DUP(i,j)")
        CALL echo("***")
        CALL is_reaction_dup(i,j)
        IF (ierrcode > 0)
         SET failed = select_error
         SET table_name = "REACTION"
         GO TO exit_script
        ENDIF
        IF (reaction_dup=true)
         CALL echo("***")
         CALL echo("***   reaction_dup = TRUE call IS_REACTION_PURE_DUP(i,j)")
         CALL echo("***")
         CALL is_reaction_pure_dup(i,j)
         IF (ierrcode > 0)
          SET failed = select_error
          SET table_name = "REACTION"
          GO TO exit_script
         ENDIF
        ENDIF
       ENDIF
       IF (reaction_dup=false)
        CALL echo("***")
        CALL echo("***   Inserting a NEW reaction")
        CALL echo("***")
        SET reaction_action = iadd
        CALL get_next_allergy_seq(i)
        IF (ierrcode > 0)
         SET failed = gen_nbr_error
         SET table_name = "HEALTH_STATUS_SEQ"
         GO TO exit_script
        ENDIF
        SET request->allergy[i].reaction[j].reaction_id = new_id
        CALL insert_reaction(i,j)
        IF (ierrcode > 0)
         SET failed = insert_error
         SET table_name = "REACTION"
         GO TO exit_script
        ENDIF
       ELSEIF (reaction_dup=true
        AND reaction_pure_dup=false)
        CALL echo("***")
        CALL echo("***   Updating an EXISTING reaction")
        CALL echo("***")
        SET reaction_action = upd
        IF (current_reaction_act_ind=0
         AND (request->allergy[i].reaction[j].active_ind=1))
         CALL get_next_allergy_seq(i)
         IF (ierrcode > 0)
          SET failed = gen_nbr_error
          SET table_name = "HEALTH_STATUS_SEQ"
          GO TO exit_script
         ENDIF
         CALL echo("***")
         CALL echo("***   Ending the effective reaction row")
         CALL echo("***")
         CALL end_effective_reaction(i,j)
         IF (ierrcode > 0)
          SET failed = update_error
          SET table_name = "REACTION"
          GO TO exit_script
         ENDIF
         CALL echo("***")
         CALL echo("***   Inserting an active row for the reaction")
         CALL echo("***")
         SET reaction_action = upd
         SET request->allergy[i].reaction[j].reaction_id = new_id
         CALL insert_reaction(i,j)
         IF (ierrcode > 0)
          SET failed = insert_error
          SET table_name = "REACTION"
          GO TO exit_script
         ENDIF
        ELSEIF (current_reaction_act_ind=1
         AND (request->allergy[i].reaction[j].active_ind=0))
         CALL echo("***")
         CALL echo("***   Updating an existing row to inactive")
         CALL echo("***")
         SET reaction_action = upd
         CALL deactivate_reaction(i,j)
         IF (ierrcode > 0)
          SET failed = update_error
          SET table_name = "REACTION"
          GO TO exit_script
         ENDIF
        ENDIF
       ENDIF
       SET reply->allergy[i].reaction_cnt = j
       SET reply->allergy[i].reaction[j].reaction_id = request->allergy[i].reaction[j].reaction_id
     ENDFOR
    ENDIF
   ENDIF
   SET comment_pure_dup = true
   SET comment_dup = true
   SET comment_action = none
   IF ((request->allergy[i].allergy_comment_cnt > 0))
    IF (allergy_action=iadd)
     CALL echo("***")
     CALL echo("***   Inserting comments for a NEW allergy")
     CALL echo("***")
     SET comment_action = multi_add
     CALL insert_new_comment(i)
     IF (ierrcode > 0)
      SET failed = insert_error
      SET table_name = "ALLERGY_COMMENT"
      GO TO exit_script
     ENDIF
     SET ierrcode = 0
     SELECT INTO "nl:"
      ac.allergy_comment_id
      FROM allergy_comment ac
      PLAN (ac
       WHERE (ac.allergy_id=request->allergy[i].allergy_id))
      ORDER BY ac.allergy_comment_id
      HEAD REPORT
       knt = 0
      DETAIL
       knt = (knt+ 1), reply->allergy[i].allergy_comment[knt].allergy_comment_id = ac
       .allergy_comment_id, request->allergy[i].allergy_comment[knt].allergy_comment_id = ac
       .allergy_comment_id
      FOOT REPORT
       reply->allergy[i].allergy_comment_cnt = knt
      WITH nocounter
     ;end select
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET failed = select_error
      SET table_name = "ALLERGY_COMMENT"
      GO TO exit_script
     ENDIF
    ELSE
     CALL load_existing_comments(i)
     IF (ierrcode > 0)
      SET failed = select_error
      SET table_name = "ALLERGY_COMMENT"
      GO TO exit_script
     ENDIF
     IF (existing_comment_nbr < 1)
      SET comment_action = multi_add
      CALL insert_new_comment(i)
      IF (ierrcode > 0)
       SET failed = insert_error
       SET table_name = "ALLERGY_COMMENT"
       GO TO exit_script
      ENDIF
      SET ierrcode = 0
      SELECT INTO "nl:"
       ac.allergy_comment_id
       FROM allergy_comment ac
       PLAN (ac
        WHERE (ac.allergy_id=request->allergy[i].allergy_id))
       ORDER BY ac.allergy_comment_id
       HEAD REPORT
        knt = 0
       DETAIL
        knt = (knt+ 1), reply->allergy[i].allergy_comment[knt].allergy_comment_id = ac
        .allergy_comment_id, request->allergy[i].allergy_comment[knt].allergy_comment_id = ac
        .allergy_comment_id
       FOOT REPORT
        reply->allergy[i].allergy_comment_cnt = knt
       WITH nocounter
      ;end select
      SET ierrcode = error(serrmsg,1)
      IF (ierrcode > 0)
       SET failed = select_error
       SET table_name = "ALLERGY_COMMENT"
       GO TO exit_script
      ENDIF
     ELSE
      FOR (k = 1 TO request->allergy[i].allergy_comment_cnt)
        CALL does_comment_exist(i,k)
        IF (comment_exist=false)
         SET comment_action = iadd
         CALL get_next_allergy_seq(i)
         IF (ierrcode > 0)
          SET failed = gen_nbr_error
          SET table_name = "HEALTH_STATUS_SEQ"
          GO TO exit_script
         ENDIF
         SET request->allergy[i].allergy_comment[k].allergy_comment_id = new_id
         CALL insert_comment(i,k)
         IF (ierrcode > 0)
          SET failed = insert_error
          SET table_name = "ALLERGY_COMMENT"
          GO TO exit_script
         ENDIF
        ENDIF
        SET reply->allergy[i].allergy_comment_cnt = k
        SET reply->allergy[i].allergy_comment[k].allergy_comment_id = request->allergy[i].
        allergy_comment[k].allergy_comment_id
      ENDFOR
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 SUBROUTINE is_allergy_pure_dup(aidx)
   SET allergy_pure_dup = true
   SET allergy_reviewed = false
   SET current_active_ind = 0
   SET ierrcode = 0
   SELECT INTO "nl:"
    FROM allergy a
    PLAN (a
     WHERE (a.allergy_instance_id=request->allergy[aidx].allergy_instance_id))
    DETAIL
     current_active_ind = a.active_ind, request->allergy[aidx].substance_nom_id = a.substance_nom_id,
     request->allergy[aidx].substance_ftdesc = a.substance_ftdesc
     IF ((request->allergy[aidx].encntr_id < 1))
      request->allergy[aidx].encntr_id = a.encntr_id
     ENDIF
     IF ( NOT ((request->allergy[aidx].cancel_dt_tm > 0)))
      request->allergy[aidx].cancel_dt_tm = a.cancel_dt_tm
     ENDIF
     IF (a.reaction_status_cd=canceled_cd
      AND (request->allergy[aidx].reaction_status_cd != canceled_cd))
      request->allergy[aidx].cancel_dt_tm = null
     ENDIF
     IF ((a.reaction_status_cd != request->allergy[aidx].reaction_status_cd))
      reaction_status_dt_tm = cnvtdatetime(now_dt_tm)
     ELSEIF (a.reaction_status_dt_tm=null)
      reaction_status_dt_tm = null
     ELSE
      reaction_status_dt_tm = cnvtdatetime(a.reaction_status_dt_tm)
     ENDIF
     IF ((a.substance_type_cd != request->allergy[aidx].substance_type_cd))
      allergy_pure_dup = false,
      CALL echo("***"),
      CALL echo("***   SUBSTANCE_TYPE_CD"),
      CALL echo("***")
     ELSEIF ((a.reaction_class_cd != request->allergy[aidx].reaction_class_cd))
      allergy_pure_dup = false,
      CALL echo("***"),
      CALL echo("***   REACTION_CLASS_CD"),
      CALL echo("***")
     ELSEIF ((a.severity_cd != request->allergy[aidx].severity_cd))
      allergy_pure_dup = false,
      CALL echo("***"),
      CALL echo("***   SEVERITY_CD"),
      CALL echo("***")
     ELSEIF ((a.source_of_info_cd != request->allergy[aidx].source_of_info_cd))
      allergy_pure_dup = false,
      CALL echo("***"),
      CALL echo("***   SOURCE_OF_INFO_CD"),
      CALL echo("***")
     ELSEIF (((a.source_of_info_ft=null
      AND (request->allergy[aidx].source_of_info_ft > " ")) OR (a.source_of_info_ft != null
      AND (request->allergy[aidx].source_of_info_ft > " ")
      AND (request->allergy[aidx].source_of_info_ft != a.source_of_info_ft))) )
      allergy_pure_dup = false,
      CALL echo("***"),
      CALL echo("***   SOURCE_OF_INFO_FT"),
      CALL echo("***")
     ELSEIF ((a.reaction_status_cd != request->allergy[aidx].reaction_status_cd))
      IF ((request->allergy[aidx].reaction_status_cd=canceled_cd))
       IF ( NOT ((request->allergy[aidx].cancel_dt_tm > 0)))
        request->allergy[aidx].cancel_dt_tm = canceled_dt_tm
       ENDIF
      ENDIF
      allergy_pure_dup = false,
      CALL echo("***"),
      CALL echo("***   REACTION_STATUS_CD"),
      CALL echo("***")
     ELSEIF ((a.cancel_reason_cd != request->allergy[aidx].cancel_reason_cd))
      allergy_pure_dup = false,
      CALL echo("***"),
      CALL echo("***   CANCEL_REASON_CD"),
      CALL echo("***")
     ENDIF
     IF ((request->allergy[aidx].onset_dt_tm > 0))
      IF (((a.onset_dt_tm=null
       AND (request->allergy[aidx].onset_dt_tm > 0)) OR (a.onset_dt_tm != null
       AND (request->allergy[aidx].onset_dt_tm != a.onset_dt_tm))) )
       allergy_pure_dup = false,
       CALL echo("***"),
       CALL echo("***   ONSET_DT_TM"),
       CALL echo("***")
      ENDIF
     ELSE
      request->allergy[aidx].onset_dt_tm = a.onset_dt_tm, request->allergy[aidx].onset_tz = a
      .onset_tz
     ENDIF
     IF ((request->allergy[aidx].onset_precision_cd > 0))
      IF ((a.onset_precision_cd != request->allergy[aidx].onset_precision_cd))
       allergy_pure_dup = false,
       CALL echo("***"),
       CALL echo("***   ONSET_PRECISION_CD"),
       CALL echo("***")
      ENDIF
     ELSE
      request->allergy[aidx].onset_precision_cd = a.onset_precision_cd
     ENDIF
     IF ((request->allergy[aidx].onset_precision_flag > 0))
      IF ((a.onset_precision_flag != request->allergy[aidx].onset_precision_flag))
       allergy_pure_dup = false,
       CALL echo("***"),
       CALL echo("***   ONSET_PRECISION_FLAG"),
       CALL echo("***")
      ENDIF
     ELSE
      request->allergy[aidx].onset_precision_flag = a.onset_precision_flag
     ENDIF
     IF ((request->allergy[aidx].created_prsnl_id > 0))
      IF ((a.created_prsnl_id != request->allergy[aidx].created_prsnl_id))
       allergy_pure_dup = false,
       CALL echo("***"),
       CALL echo("***   CREATED_PRSNL_ID"),
       CALL echo("***")
      ENDIF
     ELSE
      request->allergy[aidx].created_prsnl_id = a.created_prsnl_id
     ENDIF
     IF ((request->allergy[aidx].reviewed_dt_tm > 0))
      IF ((request->allergy[aidx].reviewed_dt_tm=cnvtdatetime("1-jan-1800 00:00:00")))
       request->allergy[aidx].reviewed_dt_tm = null
       IF (a.reviewed_dt_tm != null)
        allergy_reviewed = true
       ENDIF
      ELSEIF (((a.reviewed_dt_tm=null
       AND (request->allergy[aidx].reviewed_dt_tm > 0)) OR (a.reviewed_dt_tm != null
       AND (request->allergy[aidx].reviewed_dt_tm != a.reviewed_dt_tm))) )
       allergy_reviewed = true,
       CALL echo("***"),
       CALL echo("***   REVIEWED_DT_TM"),
       CALL echo("***")
      ENDIF
     ELSE
      request->allergy[aidx].reviewed_dt_tm = a.reviewed_dt_tm, request->allergy[aidx].reviewed_tz =
      a.reviewed_tz
     ENDIF
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
 END ;Subroutine
 SUBROUTINE is_allergy_dup(aidx)
   SET allergy_dup = true
   SET ierrcode = 0
   SELECT
    IF ((request->allergy[aidx].substance_nom_id > 0))
     PLAN (a
      WHERE (a.person_id=request->allergy[aidx].person_id)
       AND (a.substance_nom_id=request->allergy[aidx].substance_nom_id))
    ELSE
     PLAN (a
      WHERE (a.person_id=request->allergy[aidx].person_id)
       AND (a.substance_ftdesc=request->allergy[aidx].substance_ftdesc))
    ENDIF
    INTO "nl:"
    a.allergy_instance_id, a.updt_dt_tm
    FROM allergy a
    ORDER BY a.updt_dt_tm DESC, a.allergy_instance_id DESC
    HEAD REPORT
     found_it = false
    HEAD a.allergy_instance_id
     IF (found_it=false)
      request->allergy[aidx].allergy_instance_id = a.allergy_instance_id, request->allergy[aidx].
      allergy_id = a.allergy_id, found_it = true,
      CALL echo(build("***   allergy_instance_id :",a.allergy_instance_id)),
      CALL echo(build("***            allergy_id :",a.allergy_id))
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual < 1)
    SET allergy_dup = false
   ENDIF
   SET ierrcode = error(serrmsg,1)
 END ;Subroutine
 SUBROUTINE is_reaction_pure_dup(aidx,ridx)
   SET reaction_pure_dup = true
   SET current_reaction_act_ind = 0
   SET ierrcode = 0
   CALL echo("***")
   CALL echo(build("***   reaction_nom_id :",request->allergy[aidx].reaction[ridx].reaction_nom_id))
   CALL echo(build("***   reaction_id :",request->allergy[aidx].reaction[ridx].reaction_id))
   CALL echo(build("***   reaction_ftdesc :",request->allergy[aidx].reaction[ridx].reaction_ftdesc))
   CALL echo("***")
   SELECT
    IF ((request->allergy[aidx].reaction[ridx].reaction_nom_id > 0))
     PLAN (r
      WHERE (r.reaction_id=request->allergy[aidx].reaction[ridx].reaction_id)
       AND (r.reaction_nom_id=request->allergy[aidx].reaction[ridx].reaction_nom_id))
    ELSE
     PLAN (r
      WHERE (r.reaction_id=request->allergy[aidx].reaction[ridx].reaction_id)
       AND (r.reaction_ftdesc=request->allergy[aidx].reaction[ridx].reaction_ftdesc))
    ENDIF
    INTO "nl:"
    FROM reaction r
    DETAIL
     current_reaction_act_ind = r.active_ind,
     CALL echo("***"),
     CALL echo(build("***   r.active_ind :",r.active_ind)),
     CALL echo(build("***   request->allergy[aidx].reaction[ridx].active_ind :",request->allergy[aidx
      ].reaction[ridx].active_ind))
     IF ((r.active_ind != request->allergy[aidx].reaction[ridx].active_ind))
      reaction_pure_dup = false,
      CALL echo("***   reaction_pure_dup = FALSE")
     ENDIF
     CALL echo("***")
    WITH nocounter
   ;end select
   IF (curqual < 1)
    SET reaction_pure_dup = false
   ENDIF
   SET ierrcode = error(serrmsg,1)
 END ;Subroutine
 SUBROUTINE is_reaction_dup(aidx,ridx)
   SET reaction_dup = true
   SET ierrcode = 0
   CALL echo("***")
   CALL echo(build("***   reaction_nom_id :",request->allergy[aidx].reaction[ridx].reaction_nom_id))
   CALL echo(build("***   allergy_id :",request->allergy[aidx].allergy_id))
   CALL echo(build("***   reaction_ftdesc :",request->allergy[aidx].reaction[ridx].reaction_ftdesc))
   CALL echo("***")
   SELECT
    IF ((request->allergy[aidx].reaction[ridx].reaction_nom_id > 0))
     PLAN (r
      WHERE (r.allergy_id=request->allergy[aidx].allergy_id)
       AND (r.reaction_nom_id=request->allergy[aidx].reaction[ridx].reaction_nom_id))
    ELSE
     PLAN (r
      WHERE (r.allergy_id=request->allergy[aidx].allergy_id)
       AND (r.reaction_ftdesc=request->allergy[aidx].reaction[ridx].reaction_ftdesc))
    ENDIF
    INTO "nl:"
    r.reaction_id, r.updt_dt_tm
    FROM reaction r
    ORDER BY r.updt_dt_tm DESC, r.reaction_id DESC
    HEAD REPORT
     found_it = false
    HEAD r.reaction_id
     IF (found_it=false)
      request->allergy[aidx].reaction[ridx].reaction_id = r.reaction_id, found_it = true,
      CALL echo("***"),
      CALL echo(build("***   found_it = TRUE request->allergy[aidx].reaction[ridx].reaction_id :",
       request->allergy[aidx].reaction[ridx].reaction_id)),
      CALL echo("***")
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual < 1)
    SET reaction_dup = false
   ENDIF
   SET ierrcode = error(serrmsg,1)
 END ;Subroutine
 SUBROUTINE does_comment_exist(aidx,cidx)
   CALL echo("***")
   CALL echo("***   DOES_COMMENT_EXIST")
   CALL echo("***")
   SET comment_exist = false
   FOR (p = 1 TO existing_comment_nbr)
     IF ((request->allergy[aidx].allergy_comment[cidx].allergy_comment=comment->qual[p].
     allergy_comment))
      SET comment_exist = true
      SET request->allergy[aidx].allergy_comment[cidx].allergy_comment_id = comment->qual[p].
      allergy_comment_id
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE load_existing_comments(aidx)
   CALL echo("***")
   CALL echo("***   LOAD_EXISTING_COMMENTS")
   CALL echo("***")
   SET existing_comment_nbr = 0
   SET load_existing_comments_exec = true
   SET ierrcode = 0
   SELECT INTO "nl:"
    ac.allergy_comment_id, ac.updt_dt_tm
    FROM allergy_comment ac
    PLAN (ac
     WHERE (ac.allergy_id=request->allergy[aidx].allergy_id))
    ORDER BY ac.updt_dt_tm DESC, ac.allergy_comment_id DESC
    HEAD REPORT
     knt = 0, stat = alterlist(comment->qual,10)
    DETAIL
     knt = (knt+ 1)
     IF (mod(knt,10)=1
      AND knt != 1)
      stat = alterlist(comment->qual,(knt+ 9))
     ENDIF
     comment->qual[knt].allergy_comment_id = ac.allergy_comment_id, comment->qual[knt].
     allergy_comment = ac.allergy_comment, comment->qual[knt].allergy_comment_id = ac
     .allergy_comment_id,
     comment->qual[knt].comment_dt_tm = ac.comment_dt_tm, comment->qual[knt].comment_tz = ac
     .comment_tz, comment->qual[knt].comment_prsnl_id = ac.comment_prsnl_id,
     comment->qual[knt].active_ind = ac.active_ind, comment->qual[knt].active_status_cd = ac
     .active_status_cd, comment->qual[knt].active_status_dt_tm = ac.active_status_dt_tm,
     comment->qual[knt].active_status_prsnl_id = ac.active_status_prsnl_id, comment->qual[knt].
     beg_effective_dt_tm = ac.beg_effective_dt_tm, comment->qual[knt].beg_effective_tz = ac
     .beg_effective_tz,
     comment->qual[knt].end_effective_dt_tm = ac.end_effective_dt_tm, comment->qual[knt].
     contributor_system_cd = ac.contributor_system_cd, comment->qual[knt].data_status_cd = ac
     .data_status_cd,
     comment->qual[knt].data_status_dt_tm = ac.data_status_dt_tm, comment->qual[knt].
     data_status_prsnl_id = ac.data_status_prsnl_id
    FOOT REPORT
     comment->qual_knt = knt, stat = alterlist(comment->qual,knt), existing_comment_nbr = knt
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
 END ;Subroutine
 SUBROUTINE get_next_allergy_seq(tvar)
   SET new_id = 0.0
   SET ierrcode = 0
   SELECT INTO "nl:"
    num = seq(health_status_seq,nextval)
    FROM dual
    DETAIL
     new_id = cnvtreal(num)
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
 END ;Subroutine
 SUBROUTINE insert_allergy(aidx)
   SET ierrcode = 0
   INSERT  FROM allergy a
    SET a.allergy_instance_id = request->allergy[aidx].allergy_instance_id, a.allergy_id = request->
     allergy[aidx].allergy_id, a.person_id = request->allergy[aidx].person_id,
     a.encntr_id = request->allergy[aidx].encntr_id, a.substance_nom_id = request->allergy[aidx].
     substance_nom_id, a.substance_ftdesc = request->allergy[aidx].substance_ftdesc,
     a.substance_type_cd = request->allergy[aidx].substance_type_cd, a.reaction_status_cd = request->
     allergy[aidx].reaction_status_cd, a.reaction_status_dt_tm =
     IF (reaction_status_dt_tm=null) null
     ELSE cnvtdatetime(reaction_status_dt_tm)
     ENDIF
     ,
     a.orig_prsnl_id =
     IF ((request->allergy[aidx].orig_prsnl_id > 0)) request->allergy[aidx].orig_prsnl_id
     ELSE reqinfo->updt_id
     ENDIF
     , a.reaction_class_cd = request->allergy[aidx].reaction_class_cd, a.severity_cd = request->
     allergy[aidx].severity_cd,
     a.source_of_info_cd = request->allergy[aidx].source_of_info_cd, a.source_of_info_ft = request->
     allergy[aidx].source_of_info_ft, a.onset_dt_tm =
     IF ((request->allergy[aidx].onset_dt_tm > 0)) cnvtdatetime(request->allergy[aidx].onset_dt_tm)
     ELSE null
     ENDIF
     ,
     a.onset_tz =
     IF ((request->allergy[aidx].onset_tz > 0)) request->allergy[aidx].onset_tz
     ELSE curtimezoneapp
     ENDIF
     , a.onset_precision_cd = request->allergy[aidx].onset_precision_cd, a.onset_precision_flag =
     request->allergy[aidx].onset_precision_flag,
     a.created_dt_tm =
     IF ((request->allergy[aidx].created_dt_tm > 0)) cnvtdatetime(request->allergy[aidx].
       created_dt_tm)
     ELSE cnvtdatetime(curdate,curtime3)
     ENDIF
     , a.created_prsnl_id =
     IF ((request->allergy[aidx].created_prsnl_id > 0)) request->allergy[aidx].created_prsnl_id
     ELSE reqinfo->updt_id
     ENDIF
     , a.cancel_reason_cd = request->allergy[aidx].cancel_reason_cd,
     a.cancel_dt_tm = cnvtdatetime(request->allergy[aidx].cancel_dt_tm), a.cancel_prsnl_id = request
     ->allergy[aidx].cancel_prsnl_id, a.contributor_system_cd = request->allergy[aidx].
     contributor_system_cd,
     a.reviewed_dt_tm =
     IF ((request->allergy[aidx].reviewed_dt_tm=cnvtdatetime("1-jan-1800 00:00:00"))) null
     ELSEIF ((request->allergy[aidx].reviewed_dt_tm > 0)) cnvtdatetime(request->allergy[aidx].
       reviewed_dt_tm)
     ELSE null
     ENDIF
     , a.reviewed_tz =
     IF ((request->allergy[aidx].reviewed_tz > 0)) request->allergy[aidx].reviewed_tz
     ELSE curtimezoneapp
     ENDIF
     , a.reviewed_prsnl_id = request->allergy[aidx].reviewed_prsnl_id,
     a.verified_status_flag = request->allergy[aidx].verified_status_flag, a.rec_src_vocab_cd =
     request->allergy[aidx].rec_src_vocab_cd, a.rec_src_identifer = request->allergy[aidx].
     rec_src_identifier,
     a.rec_src_string = request->allergy[aidx].rec_src_string, a.data_status_cd =
     IF ((request->allergy[aidx].data_status_cd < 1)) unauth_cd
     ELSE request->allergy[aidx].data_status_cd
     ENDIF
     , a.data_status_dt_tm = cnvtdatetime(curdate,curtime3),
     a.data_status_prsnl_id = reqinfo->updt_id, a.beg_effective_dt_tm =
     IF ((request->allergy[aidx].beg_effective_dt_tm < 1)) cnvtdatetime(curdate,curtime3)
     ELSE cnvtdatetime(request->allergy[aidx].beg_effective_dt_tm)
     ENDIF
     , a.beg_effective_tz =
     IF ((request->allergy[aidx].beg_effective_tz > 0)) request->allergy[aidx].beg_effective_tz
     ELSE curtimezoneapp
     ENDIF
     ,
     a.end_effective_dt_tm =
     IF ((request->allergy[aidx].end_effective_dt_tm < 1)) cnvtdatetime("31-dec-2100 23:59:59")
     ELSE cnvtdatetime(request->allergy[aidx].end_effective_dt_tm)
     ENDIF
     , a.active_ind = request->allergy[aidx].active_ind, a.active_status_cd =
     IF ((request->allergy[aidx].active_status_cd < 1)) active_cd
     ELSE request->allergy[aidx].active_status_cd
     ENDIF
     ,
     a.active_status_prsnl_id = reqinfo->updt_id, a.active_status_dt_tm = cnvtdatetime(curdate,
      curtime3), a.updt_cnt = 0,
     a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id = reqinfo->updt_id, a.updt_task =
     reqinfo->updt_task,
     a.updt_applctx = reqinfo->updt_applctx
    PLAN (a
     WHERE 0=0)
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
 END ;Subroutine
 SUBROUTINE deactivate_allergy(aidx)
   SET ierrcode = 0
   UPDATE  FROM allergy a
    SET a.updt_cnt = (a.updt_cnt+ 1), a.active_ind = false, a.active_status_cd = inactive_cd,
     a.active_status_prsnl_id = reqinfo->updt_id, a.active_status_dt_tm = cnvtdatetime(curdate,
      curtime3), a.end_effective_dt_tm = cnvtdatetime(curdate,curtime3),
     a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id = reqinfo->updt_id, a.updt_applctx =
     reqinfo->updt_applctx,
     a.updt_task = reqinfo->updt_task
    PLAN (a
     WHERE (a.allergy_instance_id=request->allergy[aidx].allergy_instance_id))
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
 END ;Subroutine
 SUBROUTINE stamp_reviewed(aidx)
   SET ierrcode = 0
   UPDATE  FROM allergy a
    SET a.reviewed_dt_tm = cnvtdatetime(request->allergy[aidx].reviewed_dt_tm), a.reviewed_tz =
     IF ((request->allergy[aidx].reviewed_tz > 0)) request->allergy[aidx].reviewed_tz
     ELSE curtimezoneapp
     ENDIF
     , a.reviewed_prsnl_id =
     IF ((request->allergy[aidx].reviewed_dt_tm=null)) 0.0
     ELSEIF ((request->allergy[aidx].reviewed_prsnl_id < 1)) reqinfo->updt_id
     ELSE request->allergy[aidx].reviewed_prsnl_id
     ENDIF
    PLAN (a
     WHERE (a.allergy_instance_id=request->allergy[aidx].allergy_instance_id))
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
 END ;Subroutine
 SUBROUTINE insert_new_reaction(aidx)
   SET ierrcode = 0
   INSERT  FROM reaction r,
     (dummyt d  WITH seq = value(request->allergy[aidx].reaction_cnt))
    SET r.reaction_id = cnvtreal(seq(health_status_seq,nextval)), r.allergy_instance_id = request->
     allergy[aidx].allergy_instance_id, r.allergy_id = request->allergy[aidx].allergy_id,
     r.reaction_nom_id = request->allergy[aidx].reaction[d.seq].reaction_nom_id, r.reaction_ftdesc =
     request->allergy[aidx].reaction[d.seq].reaction_ftdesc, r.contributor_system_cd = request->
     allergy[aidx].reaction[d.seq].contributor_system_cd,
     r.data_status_cd =
     IF ((request->allergy[aidx].reaction[d.seq].data_status_cd < 1)) unauth_cd
     ELSE request->allergy[aidx].reaction[d.seq].data_status_cd
     ENDIF
     , r.data_status_dt_tm = cnvtdatetime(curdate,curtime3), r.data_status_prsnl_id = reqinfo->
     updt_id,
     r.beg_effective_dt_tm =
     IF ((request->allergy[aidx].reaction[d.seq].beg_effective_dt_tm < 1)) cnvtdatetime(curdate,
       curtime3)
     ELSE cnvtdatetime(request->allergy[aidx].reaction[d.seq].beg_effective_dt_tm)
     ENDIF
     , r.end_effective_dt_tm =
     IF ((request->allergy[aidx].reaction[d.seq].end_effective_dt_tm < 1)) cnvtdatetime(
       "31-dec-2100 23:59:59")
     ELSE cnvtdatetime(request->allergy[aidx].reaction[d.seq].end_effective_dt_tm)
     ENDIF
     , r.active_ind = request->allergy[aidx].reaction[d.seq].active_ind,
     r.active_status_cd =
     IF ((request->allergy[aidx].reaction[d.seq].active_status_cd < 1)) active_cd
     ELSE request->allergy[aidx].reaction[d.seq].active_status_cd
     ENDIF
     , r.active_status_prsnl_id = reqinfo->updt_id, r.active_status_dt_tm = cnvtdatetime(curdate,
      curtime3),
     r.updt_cnt = 0, r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r.updt_id = reqinfo->updt_id,
     r.updt_applctx = reqinfo->updt_applctx, r.updt_task = reqinfo->updt_task
    PLAN (d
     WHERE d.seq > 0)
     JOIN (r
     WHERE 0=0)
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
 END ;Subroutine
 SUBROUTINE insert_reaction(aidx,ridx)
   SET ierrcode = 0
   INSERT  FROM reaction r
    SET r.reaction_id = request->allergy[aidx].reaction[ridx].reaction_id, r.allergy_instance_id =
     request->allergy[aidx].allergy_instance_id, r.allergy_id = request->allergy[aidx].allergy_id,
     r.reaction_nom_id = request->allergy[aidx].reaction[ridx].reaction_nom_id, r.reaction_ftdesc =
     request->allergy[aidx].reaction[ridx].reaction_ftdesc, r.contributor_system_cd = request->
     allergy[aidx].reaction[ridx].contributor_system_cd,
     r.data_status_cd =
     IF ((request->allergy[aidx].reaction[ridx].data_status_cd < 1)) unauth_cd
     ELSE request->allergy[aidx].reaction[ridx].data_status_cd
     ENDIF
     , r.data_status_dt_tm = cnvtdatetime(curdate,curtime3), r.data_status_prsnl_id = reqinfo->
     updt_id,
     r.beg_effective_dt_tm =
     IF ((request->allergy[aidx].reaction[ridx].beg_effective_dt_tm < 1)) cnvtdatetime(curdate,
       curtime3)
     ELSE cnvtdatetime(request->allergy[aidx].reaction[ridx].beg_effective_dt_tm)
     ENDIF
     , r.end_effective_dt_tm =
     IF ((request->allergy[aidx].reaction[ridx].end_effective_dt_tm < 1)) cnvtdatetime(
       "31-dec-2100 23:59:59")
     ELSE cnvtdatetime(request->allergy[aidx].reaction[ridx].end_effective_dt_tm)
     ENDIF
     , r.active_ind = request->allergy[aidx].reaction[ridx].active_ind,
     r.active_status_cd =
     IF ((request->allergy[aidx].reaction[ridx].active_status_cd < 1)) active_cd
     ELSE request->allergy[aidx].reaction[ridx].active_status_cd
     ENDIF
     , r.active_status_prsnl_id = reqinfo->updt_id, r.active_status_dt_tm = cnvtdatetime(curdate,
      curtime3),
     r.updt_cnt = 0, r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r.updt_id = reqinfo->updt_id,
     r.updt_applctx = reqinfo->updt_applctx, r.updt_task = reqinfo->updt_task
    PLAN (r
     WHERE 0=0)
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
 END ;Subroutine
 SUBROUTINE deactivate_reaction(aidx,ridx)
   SET ierrcode = 0
   UPDATE  FROM reaction r
    SET r.active_ind = false, r.active_status_cd = inactive_cd, r.active_status_prsnl_id = r
     .active_status_prsnl_id,
     r.active_status_dt_tm = cnvtdatetime(curdate,curtime3), r.updt_cnt = (r.updt_cnt+ 1), r
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     r.updt_id = reqinfo->updt_id, r.updt_applctx = reqinfo->updt_applctx, r.updt_task = reqinfo->
     updt_task
    PLAN (r
     WHERE (r.reaction_id=request->allergy[aidx].reaction[ridx].reaction_id))
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
 END ;Subroutine
 SUBROUTINE end_effective_reaction(aidx,ridx)
   SET ierrcode = 0
   UPDATE  FROM reaction r
    SET r.active_status_prsnl_id = request->allergy[aidx].reaction[ridx].active_status_prsnl_id, r
     .active_status_dt_tm =
     IF ((request->allergy[aidx].reaction[ridx].active_status_dt_tm > 0)) request->allergy[aidx].
      reaction[ridx].active_status_dt_tm
     ELSE cnvtdatetime(curdate,curtime3)
     ENDIF
     , r.end_effective_dt_tm =
     IF ((request->allergy[aidx].reaction[ridx].end_effective_dt_tm > 0)) request->allergy[aidx].
      reaction[ridx].end_effective_dt_tm
     ELSE cnvtdatetime(curdate,curtime3)
     ENDIF
     ,
     r.updt_cnt = (r.updt_cnt+ 1), r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r.updt_id = reqinfo
     ->updt_id,
     r.updt_applctx = reqinfo->updt_applctx, r.updt_task = reqinfo->updt_task
    PLAN (r
     WHERE (r.reaction_id=request->allergy[aidx].reaction[ridx].reaction_id))
    WITH nocounter
   ;end update
   SET ierrcode = error(serrmsg,1)
 END ;Subroutine
 SUBROUTINE insert_new_comment(aidx)
   SET ierrcode = 0
   INSERT  FROM allergy_comment ac,
     (dummyt d  WITH seq = value(request->allergy[aidx].allergy_comment_cnt))
    SET ac.allergy_comment_id = cnvtreal(seq(health_status_seq,nextval)), ac.allergy_instance_id =
     request->allergy[aidx].allergy_instance_id, ac.allergy_id = request->allergy[aidx].allergy_id,
     ac.comment_dt_tm = cnvtdatetime(request->allergy[aidx].allergy_comment[d.seq].comment_dt_tm), ac
     .comment_tz =
     IF ((request->allergy[aidx].allergy_comment[d.seq].comment_tz > 0)) request->allergy[aidx].
      allergy_comment[d.seq].comment_tz
     ELSE curtimezoneapp
     ENDIF
     , ac.comment_prsnl_id = request->allergy[aidx].allergy_comment[d.seq].comment_prsnl_id,
     ac.allergy_comment = request->allergy[aidx].allergy_comment[d.seq].allergy_comment, ac
     .contributor_system_cd = request->allergy[aidx].allergy_comment[d.seq].contributor_system_cd, ac
     .data_status_cd =
     IF ((request->allergy[aidx].allergy_comment[d.seq].data_status_cd < 1)) unauth_cd
     ELSE request->allergy[aidx].allergy_comment[d.seq].data_status_cd
     ENDIF
     ,
     ac.data_status_dt_tm = cnvtdatetime(curdate,curtime3), ac.data_status_prsnl_id = reqinfo->
     updt_id, ac.beg_effective_dt_tm =
     IF ((request->allergy[aidx].allergy_comment[d.seq].beg_effective_dt_tm < 1)) cnvtdatetime(
       curdate,curtime3)
     ELSE cnvtdatetime(request->allergy[aidx].allergy_comment[d.seq].beg_effective_dt_tm)
     ENDIF
     ,
     ac.beg_effective_tz =
     IF ((request->allergy[aidx].allergy_comment[d.seq].beg_effective_tz > 0)) request->allergy[aidx]
      .allergy_comment[d.seq].beg_effective_tz
     ELSE curtimezoneapp
     ENDIF
     , ac.end_effective_dt_tm =
     IF ((request->allergy[aidx].allergy_comment[d.seq].end_effective_dt_tm < 1)) cnvtdatetime(
       "31-dec-2100 23:59:59")
     ELSE cnvtdatetime(request->allergy[aidx].allergy_comment[d.seq].end_effective_dt_tm)
     ENDIF
     , ac.active_ind = true,
     ac.active_status_cd =
     IF ((request->allergy[aidx].allergy_comment[d.seq].active_status_cd < 1)) active_cd
     ELSE request->allergy[aidx].allergy_comment[d.seq].active_status_cd
     ENDIF
     , ac.active_status_prsnl_id = reqinfo->updt_id, ac.active_status_dt_tm = cnvtdatetime(curdate,
      curtime3),
     ac.updt_cnt = 0, ac.updt_dt_tm = cnvtdatetime(curdate,curtime3), ac.updt_id = reqinfo->updt_id,
     ac.updt_applctx = reqinfo->updt_applctx, ac.updt_task = reqinfo->updt_task
    PLAN (d
     WHERE d.seq > 0)
     JOIN (ac
     WHERE 0=0)
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
 END ;Subroutine
 SUBROUTINE insert_comment(aidx,cidx)
   SET ierrcode = 0
   INSERT  FROM allergy_comment ac
    SET ac.allergy_comment_id = request->allergy[aidx].allergy_comment[cidx].allergy_comment_id, ac
     .allergy_instance_id = request->allergy[aidx].allergy_instance_id, ac.allergy_id = request->
     allergy[aidx].allergy_id,
     ac.comment_dt_tm = cnvtdatetime(request->allergy[aidx].allergy_comment[cidx].comment_dt_tm), ac
     .comment_tz =
     IF ((request->allergy[aidx].allergy_comment[cidx].comment_tz > 0)) request->allergy[aidx].
      allergy_comment[cidx].comment_tz
     ELSE curtimezoneapp
     ENDIF
     , ac.comment_prsnl_id = request->allergy[aidx].allergy_comment[cidx].comment_prsnl_id,
     ac.allergy_comment = request->allergy[aidx].allergy_comment[cidx].allergy_comment, ac
     .contributor_system_cd = request->allergy[aidx].allergy_comment[cidx].contributor_system_cd, ac
     .data_status_cd =
     IF ((request->allergy[aidx].allergy_comment[cidx].data_status_cd < 1)) unauth_cd
     ELSE request->allergy[aidx].allergy_comment[cidx].data_status_cd
     ENDIF
     ,
     ac.data_status_dt_tm = cnvtdatetime(curdate,curtime3), ac.data_status_prsnl_id = reqinfo->
     updt_id, ac.beg_effective_dt_tm =
     IF ((request->allergy[aidx].allergy_comment[cidx].beg_effective_dt_tm < 1)) cnvtdatetime(curdate,
       curtime3)
     ELSE cnvtdatetime(request->allergy[aidx].allergy_comment[cidx].beg_effective_dt_tm)
     ENDIF
     ,
     ac.beg_effective_tz =
     IF ((request->allergy[aidx].allergy_comment[cidx].beg_effective_tz > 0)) request->allergy[aidx].
      allergy_comment[cidx].beg_effective_tz
     ELSE curtimezoneapp
     ENDIF
     , ac.end_effective_dt_tm =
     IF ((request->allergy[aidx].allergy_comment[cidx].end_effective_dt_tm < 1)) cnvtdatetime(
       "31-dec-2100 23:59:59")
     ELSE cnvtdatetime(request->allergy[aidx].allergy_comment[cidx].end_effective_dt_tm)
     ENDIF
     , ac.active_ind = true,
     ac.active_status_cd =
     IF ((request->allergy[aidx].allergy_comment[cidx].active_status_cd < 1)) active_cd
     ELSE request->allergy[aidx].allergy_comment[cidx].active_status_cd
     ENDIF
     , ac.active_status_prsnl_id = reqinfo->updt_id, ac.active_status_dt_tm = cnvtdatetime(curdate,
      curtime3),
     ac.updt_cnt = 0, ac.updt_dt_tm = cnvtdatetime(curdate,curtime3), ac.updt_id = reqinfo->updt_id,
     ac.updt_applctx = reqinfo->updt_applctx, ac.updt_task = reqinfo->updt_task
    PLAN (ac
     WHERE 0=0)
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
 END ;Subroutine
#exit_script
 IF (failed != false)
  SET reqinfo->commit_ind = false
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  ELSEIF (failed=gen_nbr_error)
   SET reply->status_data.subeventstatus[1].operationname = "GEN_SEQ_NBR"
  ELSEIF (failed=update_error)
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATE"
  ELSEIF (failed=lock_error)
   SET reply->status_data.subeventstatus[1].operationname = "LOCK"
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDIF
 ELSE
  SET reqinfo->commit_ind = true
  SET reply->status_data.status = "S"
 ENDIF
END GO
