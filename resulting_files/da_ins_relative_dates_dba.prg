CREATE PROGRAM da_ins_relative_dates:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting script da_ins_relative_dates..."
 DECLARE errmsg = vc WITH protect, noconstant(" ")
 DECLARE loop = i4 WITH protect, noconstant(0)
 DECLARE code_cnt = i4 WITH protect, noconstant(0)
 DECLARE num_rows = i4 WITH protect, noconstant(0)
 FREE RECORD da_action
 RECORD da_action(
   1 row[*]
     2 app_action = i1
     2 seq_id = f8
 )
 FREE RECORD m_dm2_seq_stat
 RECORD m_dm2_seq_stat(
   1 n_status = i4
   1 s_error_msg = vc
 ) WITH protect
 SET date_cnt = size(requestin->list_0,5)
 SET stat = alterlist(da_action->row,date_cnt)
 SELECT INTO "nl:"
  dcnt = count(*)
  FROM da_relative_date d
  WHERE d.relative_date_cd > 0.0
  FOOT REPORT
   num_rows = dcnt
  WITH nocounter
 ;end select
 IF (num_rows > 0)
  CALL echo("deleting all rows from da_relative_date...")
  DELETE  FROM da_relative_date d
   WHERE d.relative_date_cd > 0.0
   WITH nocounter
  ;end delete
  COMMIT
 ENDIF
 SET _seq_path = "DA_ACTION->ROW"
 EXECUTE dm2_dar_get_bulk_seq _seq_path, date_cnt, "SEQ_ID",
 1, "DA_SEQ"
 IF ((m_dm2_seq_stat->n_status != 1))
  SET readme_data->message = concat("Error in DM2_DAR_GET_BULK_SEQ: ",m_dm2_seq_stat->s_error_msg)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv,
   (dummyt d  WITH seq = value(date_cnt))
  PLAN (d)
   JOIN (cv
   WHERE cv.code_set=14729
    AND (cv.cdf_meaning=requestin->list_0[d.seq].relative_date_cd)
    AND cv.active_ind=1)
  HEAD REPORT
   code_cnt = 0
  DETAIL
   code_cnt += 1, requestin->list_0[d.seq].relative_date_cd = cnvtstring(cv.code_value)
  WITH nocounter, outerjoin = d
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->message = concat("Failed on select from code_value: ",errmsg)
  GO TO exit_script
 ENDIF
 FREE RECORD copy_requestin
 RECORD copy_requestin(
   1 list_0[*]
     2 relative_date_cd = f8
     2 from_date_str = vc
     2 to_date_str = vc
     2 active_ind = i4
 )
 SET stat = alterlist(copy_requestin->list_0,size(requestin->list_0,5))
 FOR (loop = 1 TO size(requestin->list_0,5))
   SET copy_requestin->list_0[loop].relative_date_cd = cnvtreal(requestin->list_0[loop].
    relative_date_cd)
   SET copy_requestin->list_0[loop].from_date_str = requestin->list_0[loop].from_date_str
   SET copy_requestin->list_0[loop].to_date_str = requestin->list_0[loop].to_date_str
   SET copy_requestin->list_0[loop].active_ind = cnvtint(requestin->list_0[loop].active_ind)
 ENDFOR
 IF (error(errmsg,0) > 0)
  SET readme_data->message = concat("Failed to copy requestin: ",errmsg)
  GO TO exit_script
 ENDIF
 INSERT  FROM da_relative_date drd,
   (dummyt d  WITH seq = value(date_cnt))
  SET drd.da_relative_date_id = da_action->row[d.seq].seq_id, drd.relative_date_cd = copy_requestin->
   list_0[d.seq].relative_date_cd, drd.from_date_txt = copy_requestin->list_0[d.seq].from_date_str,
   drd.to_date_txt = copy_requestin->list_0[d.seq].to_date_str, drd.active_ind = copy_requestin->
   list_0[d.seq].active_ind
  PLAN (d)
   JOIN (drd)
  WITH nocounter, outerjoin = d
 ;end insert
 IF (error(errmsg,0) > 0)
  SET readme_data->message = concat("Failed to insert data: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (curqual=date_cnt)
  SET readme_data->status = "S"
  SET readme_data->message = "Success: All rows inserted to DA_RELATIVE_DATE table."
 ENDIF
#exit_script
 IF ((readme_data->status="S"))
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
 FREE RECORD da_action
 FREE RECORD m_dm2_seq_stat
 FREE RECORD copy_requestin
END GO
