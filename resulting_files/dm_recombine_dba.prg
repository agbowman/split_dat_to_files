CREATE PROGRAM dm_recombine:dba
 IF ( NOT (validate(cmb_tree)))
  FREE RECORD cmb_tree
  RECORD cmb_tree(
    1 valid_ind = i2
    1 final_enc_id = f8
    1 final_id = f8
    1 cmb[*]
      2 parent = vc
      2 cmb_id = f8
      2 from_id = f8
      2 to_id = f8
      2 encntr_id = f8
      2 updt_dt_tm = dq8
      2 updt_id = f8
      2 application_flag = i2
    1 cnt = i2
    1 err_tbl = vc
    1 err_msg = vc
  )
 ENDIF
 SET dm_debug_cmb = 0
 IF (validate(dm_debug,0) > 0)
  SET dm_debug_cmb = 1
 ENDIF
 DECLARE dm_recmb_id = f8
 SET dm_recmb_id = 0.0
 DECLARE dm_recmb_from_id = f8
 SET dm_recmb_from_id = 0.0
 DECLARE dm_recmb_to_id = f8
 SET dm_recmb_to_id = 0.0
 DECLARE dm_recmb_encntr_id = f8
 SET dm_recmb_encntr_id = 0.0
 DECLARE dm_recmb_cnt = i2
 SET dm_recmb_cnt = 0
 DECLARE dr_prev_encntr = f8
 SET dr_prev_encntr = 0.0
 DECLARE dr_ecode = i4
 SET dr_ecode = 0
 SET dr_call_script = "DM_RECOMBINE"
 FREE RECORD dr_work
 RECORD dr_work(
   1 dm_recmb_tbl = vc
   1 dm_recmb_pk = vc
   1 dm_recmb_from = vc
   1 dm_recmb_to = vc
   1 dr_err_tbl = vc
   1 dr_err_msg = vc
   1 dm_recmb_parent = vc
   1 dr_prev_parent = vc
 )
 SET dr_work->dm_recmb_parent = cnvtupper( $1)
 SET dm_recmb_id =  $2
 SELECT INTO "nl:"
  p.person_id
  FROM prsnl p
  WHERE p.username=curuser
  DETAIL
   reqinfo->updt_id = p.person_id
  WITH nocounter
 ;end select
 IF (validate(reqdata,"Z") != "Z")
  SET reqdata->data_status_cd = 66666
  SET reqdata->contributor_system_cd = 66666
 ELSE
  SET dr_work->dr_err_tbl = " "
  SET dr_work->dr_err_msg =
  "Record reqdata does not exist.  Please log out CCL and log back in to restart dm_recombine."
 ENDIF
 IF (validate(reqinfo,"Z") != "Z")
  SET reqinfo->updt_applctx = 66666
  SET reqinfo->updt_task = 100102
 ELSE
  SET dr_work->dr_err_tbl = " "
  SET dr_work->dr_err_msg =
  "Record reqinfo does not exist.  Please log out CCL and log back in to restart dm_recombine."
 ENDIF
 SET error_cnt = 0
 SET reply_cnt = 0
 FREE SET reply
 RECORD reply(
   1 xxx_combine_id[*]
     2 combine_id = f8
     2 parent_table = c50
     2 from_xxx_id = f8
     2 to_xxx_id = f8
     2 encntr_id = f8
   1 error[*]
     2 create_dt_tm = dq8
     2 parent_table = c50
     2 from_id = f8
     2 to_id = f8
     2 encntr_id = f8
     2 error_table = c32
     2 error_type = vc
     2 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 FREE RECORD dr_rpt
 RECORD dr_rpt(
   1 line[*]
     2 txt = vc
   1 cnt = i2
 )
 SET dr_log_file = build("dm_recmb_",cnvtint(dm_recmb_id),".txt")
 CALL echo(build("log_file =",dr_log_file))
 SELECT INTO value(dr_log_file)
  d.*
  FROM (dummyt d  WITH seq = 1)
  DETAIL
   row + 1, col 0, "RECOMBINE LOG FILE FOR COMBINE ID ",
   col + 0, dm_recmb_id, row + 2
  WITH nocounter
 ;end select
 CASE (dr_work->dm_recmb_parent)
  OF "PERSON":
   SET dr_work->dm_recmb_tbl = "PERSON_COMBINE"
   SET dr_work->dm_recmb_pk = "PERSON_COMBINE_ID"
   SET dr_work->dm_recmb_from = "FROM_PERSON_ID"
   SET dr_work->dm_recmb_to = "TO_PERSON_ID"
  OF "ENCOUNTER":
   SET dr_work->dm_recmb_tbl = "ENCNTR_COMBINE"
   SET dr_work->dm_recmb_pk = "ENCNTR_COMBINE_ID"
   SET dr_work->dm_recmb_from = "FROM_ENCNTR_ID"
   SET dr_work->dm_recmb_to = "TO_ENCNTR_ID"
  OF "LOCATION":
  OF "HEALTH_PLAN":
  OF "ORGANIZATION":
   SET dr_work->dm_recmb_tbl = "COMBINE"
   SET dr_work->dm_recmb_pk = "COMBINE_ID"
   SET dr_work->dm_recmb_from = "FROM_ID"
   SET dr_work->dm_recmb_to = "TO_ID"
  ELSE
   SET dr_work->dr_err_tbl = dr_work->dm_recmb_parent
   SET dr_work->dr_err_msg = concat("The parent table ",dr_work->dm_recmb_parent,
    " is invalid for combine.")
   GO TO dm_recmb_error
 ENDCASE
 IF (dm_debug_cmb=1)
  CALL echo(build("dr_work->dm_recmb_tbl =",dr_work->dm_recmb_tbl))
  CALL echo(build("dr_work->dm_recmb_pk =",dr_work->dm_recmb_pk))
  CALL echo(build("dr_work->dm_recmb_from =",dr_work->dm_recmb_from))
  CALL echo(build("dr_work->dm_recmb_to =",dr_work->dm_recmb_to))
  CALL echo(build("dr_work->dm_recmb_parent =",dr_work->dm_recmb_parent))
 ENDIF
 IF (dm_debug_cmb=1)
  CALL echo(build("Find from_id and to_id for combine_id ",dm_recmb_id))
 ENDIF
 IF ((dr_work->dm_recmb_parent="PERSON"))
  SELECT INTO "nl:"
   FROM person_combine p
   WHERE p.person_combine_id=dm_recmb_id
    AND p.active_ind=1
   DETAIL
    dm_recmb_from_id = p.from_person_id, dm_recmb_to_id = p.to_person_id, dm_recmb_encntr_id = p
    .encntr_id
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM (value(dr_work->dm_recmb_tbl) c)
   WHERE parser(build("c.",dr_work->dm_recmb_pk,"=dm_recmb_id"))
    AND c.active_ind=1
   DETAIL
    dm_recmb_from_id = parser(build("c.",dr_work->dm_recmb_from)), dm_recmb_to_id = parser(build("c.",
      dr_work->dm_recmb_to)), dm_recmb_encntr_id = 0.0
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual=0)
  SET dr_work->dr_err_tbl = dr_work->dm_recmb_tbl
  SET dr_work->dr_err_msg = build("Combine_id ",dm_recmb_id," is invalid or inactive.")
  GO TO dm_recmb_error
 ENDIF
 IF (dm_debug_cmb=1)
  CALL echo(build("dm_recmb_from_id =",dm_recmb_from_id))
  CALL echo(build("dm_recmb_to_id =",dm_recmb_to_id))
  CALL echo(build("dm_recmb_encntr_id =",dm_recmb_encntr_id))
  CALL echo(build("dm_recmb_id =",dm_recmb_id))
  CALL echo("Executing dm_combine_tree...")
 ENDIF
 EXECUTE dm_combine_tree dr_work->dm_recmb_parent, dm_recmb_from_id, dm_recmb_encntr_id,
 dm_recmb_id
 IF (size(cmb_tree->err_msg,1) > 0)
  GO TO end_program
 ENDIF
 FOR (dr_i = 1 TO cmb_tree->cnt)
   IF (dr_i=1)
    SET dr_prev_encntr = cmb_tree->cmb[1].encntr_id
    SET dr_work->dr_prev_parent = cmb_tree->cmb[1].parent
   ELSE
    IF ((((dr_prev_encntr != cmb_tree->cmb[dr_i].encntr_id)) OR ((dr_work->dr_prev_parent != cmb_tree
    ->cmb[dr_i].parent))) )
     SET dr_work->dr_err_tbl = " "
     SET dr_work->dr_err_msg =
     "Encounter Combine or Person Combine is involved in Encounter Move.  Can not perform Recombine."
     SET dr_i = cmb_tree->cnt
     GO TO dm_recmb_error
    ENDIF
    SET dr_prev_encntr = cmb_tree->cmb[dr_i].encntr_id
    SET dr_work->dr_prev_parent = cmb_tree->cmb[dr_i].parent
   ENDIF
 ENDFOR
 IF (dm_debug_cmb=1)
  CALL echo("Calling dm_call_combine...")
 ENDIF
 SET dr_idx = 0
 FOR (dr_idx = 1 TO cmb_tree->cnt)
   FREE SET request
   RECORD request(
     1 parent_table = c50
     1 cmb_mode = c20
     1 error_message = c132
     1 transaction_type = c8
     1 xxx_combine[*]
       2 xxx_combine_id = f8
       2 from_xxx_id = f8
       2 from_mrn = c200
       2 from_alias_pool_cd = f8
       2 from_alias_type_cd = f8
       2 to_xxx_id = f8
       2 to_mrn = c200
       2 to_alias_pool_cd = f8
       2 to_alias_type_cd = f8
       2 encntr_id = f8
       2 application_flag = i2
       2 combine_weight = f8
     1 xxx_combine_det[*]
       2 xxx_combine_det_id = f8
       2 xxx_combine_id = f8
       2 entity_name = c32
       2 entity_id = f8
       2 entity_pk[*]
         3 col_name = c30
         3 data_type = c30
         3 data_char = c100
         3 data_number = f8
         3 data_date = dq8
       2 combine_action_cd = f8
       2 attribute_name = c32
       2 prev_active_ind = i2
       2 prev_active_status_cd = f8
       2 prev_end_eff_dt_tm = dq8
       2 combine_desc_cd = f8
       2 to_record_ind = i2
   )
   SET stat = alterlist(request->xxx_combine,1)
   SET request->parent_table = cmb_tree->cmb[dr_idx].parent
   SET request->cmb_mode = "RE-CMB"
   SET request->transaction_type = curuser
   SET request->xxx_combine[1].xxx_combine_id = cmb_tree->cmb[dr_idx].cmb_id
   SET request->xxx_combine[1].from_xxx_id = cmb_tree->cmb[dr_idx].from_id
   SET request->xxx_combine[1].encntr_id = cmb_tree->cmb[dr_idx].encntr_id
   SET request->xxx_combine[1].to_xxx_id = cmb_tree->cmb[dr_idx].to_id
   SET request->xxx_combine[1].application_flag = 1
   IF (dm_debug_cmb=1)
    CALL echo("Below is the request record pass in dm_call_combine...")
    CALL echorecord(request)
   ENDIF
   EXECUTE dm_call_combine
   IF (reply_cnt > 0)
    SELECT INTO value(dr_log_file)
     d.*
     FROM (dummyt d  WITH seq = value(reply_cnt))
     HEAD REPORT
      beg_cnt = 0
     DETAIL
      beg_cnt = dr_rpt->cnt, dr_rpt->cnt += 1, stat = alterlist(dr_rpt->line,dr_rpt->cnt),
      dr_rpt->line[dr_rpt->cnt].txt = concat("Combine_id    =  ",build(format(reply->xxx_combine_id[d
         .seq].combine_id,"##########;l"))), dr_rpt->cnt += 1, stat = alterlist(dr_rpt->line,dr_rpt->
       cnt),
      dr_rpt->line[dr_rpt->cnt].txt = concat("Parent table  =  ",reply->xxx_combine_id[d.seq].
       parent_table), dr_rpt->cnt += 1, stat = alterlist(dr_rpt->line,dr_rpt->cnt),
      dr_rpt->line[dr_rpt->cnt].txt = concat("From id       =  ",build(format(reply->xxx_combine_id[d
         .seq].from_xxx_id,"##########;l"))), dr_rpt->cnt += 1, stat = alterlist(dr_rpt->line,dr_rpt
       ->cnt),
      dr_rpt->line[dr_rpt->cnt].txt = concat("To id         =  ",build(format(reply->xxx_combine_id[d
         .seq].to_xxx_id,"##########;l"))), dr_rpt->cnt += 1, stat = alterlist(dr_rpt->line,dr_rpt->
       cnt),
      dr_rpt->line[dr_rpt->cnt].txt = concat("Encntr id     =  ",build(format(reply->xxx_combine_id[d
         .seq].encntr_id,"##########;l"))), dr_rpt->cnt += 1, stat = alterlist(dr_rpt->line,dr_rpt->
       cnt),
      dr_rpt->line[dr_rpt->cnt].txt = concat("Status        =  ",reply->status_data.status)
      FOR (dr_m = (beg_cnt+ 1) TO dr_rpt->cnt)
        col 0, dr_rpt->line[dr_m].txt, row + 1
      ENDFOR
      row + 1, col 0,
      "*************************************************************************************",
      row + 1
     WITH nocounter, append
    ;end select
   ENDIF
   IF (error_cnt > 0)
    GO TO dr_report
   ENDIF
 ENDFOR
 GO TO dr_report
#dm_recmb_error
 SET dr_ecode = error(dr_work->dr_err_msg,1)
 IF (dr_ecode != 0)
  SET dr_work->dr_err_tbl = " "
 ENDIF
 SET error_cnt += 1
 SET stat = alterlist(reply->error,error_cnt)
 SET reply->status_data.status = "F"
 SET reply->error[error_cnt].create_dt_tm = cnvtdatetime(sysdate)
 SET reply->error[error_cnt].parent_table = dr_work->dm_recmb_parent
 SET reply->error[error_cnt].from_id = dm_recmb_from_id
 SET reply->error[error_cnt].to_id = dm_recmb_to_id
 SET reply->error[error_cnt].encntr_id = dm_recmb_encntr_id
 SET reply->error[error_cnt].error_table = dr_work->dr_err_tbl
 SET reply->error[error_cnt].error_type = "DATA_ERROR"
 SET reply->error[error_cnt].error_msg = dr_work->dr_err_msg
#dr_report
 IF (error_cnt > 0)
  SELECT INTO value(dr_log_file)
   d.*
   FROM (dummyt d  WITH seq = value(error_cnt))
   HEAD REPORT
    beg_cnt = 0
   DETAIL
    beg_cnt = dr_rpt->cnt, dr_rpt->cnt += 1, stat = alterlist(dr_rpt->line,dr_rpt->cnt),
    dr_rpt->line[dr_rpt->cnt].txt = concat("Error from_id =  ",build(format(reply->error[d.seq].
       from_id,"##########;l"))), dr_rpt->cnt += 1, stat = alterlist(dr_rpt->line,dr_rpt->cnt),
    dr_rpt->line[dr_rpt->cnt].txt = concat("Error to_id   =  ",build(format(reply->error[d.seq].to_id,
       "##########;l"))), dr_rpt->cnt += 1, stat = alterlist(dr_rpt->line,dr_rpt->cnt),
    dr_rpt->line[dr_rpt->cnt].txt = concat("Error msg     =  ",reply->error[d.seq].error_msg), dr_rpt
    ->cnt += 1, stat = alterlist(dr_rpt->line,dr_rpt->cnt),
    dr_rpt->line[dr_rpt->cnt].txt = concat("Error table   =  ",reply->error[d.seq].error_table),
    dr_rpt->cnt += 1, stat = alterlist(dr_rpt->line,dr_rpt->cnt),
    dr_rpt->line[dr_rpt->cnt].txt = concat("Error type    =  ",reply->error[d.seq].error_type),
    dr_rpt->cnt += 1, stat = alterlist(dr_rpt->line,dr_rpt->cnt),
    dr_rpt->line[dr_rpt->cnt].txt = concat("Status        =  ",reply->status_data.status)
    FOR (dr_m = (beg_cnt+ 1) TO dr_rpt->cnt)
      col 0, dr_rpt->line[dr_m].txt, row + 1
    ENDFOR
    row + 1, col 0,
    "*************************************************************************************",
    row + 1
   WITH nocounter, append
  ;end select
 ENDIF
 FREE DEFINE rtl
 FREE SET file_loc
 SET logical file_loc value(dr_log_file)
 DEFINE rtl "file_loc"
 SELECT
  r.line
  FROM rtlt r
  WITH nocounter
 ;end select
#end_program
 IF (dm_debug_cmb=1)
  IF (error_cnt=0)
   CALL echo("*****************************************************")
   CALL echo("THIS IS JUST TESTING !!! DON'T FORGET TO ROLLBACK !!!")
   CALL echo("*****************************************************")
  ENDIF
 ENDIF
END GO
