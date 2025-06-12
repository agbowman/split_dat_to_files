CREATE PROGRAM dm_rqp_check:dba
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
 SET rqp_emsg = fillstring(132," ")
 SET rqp_ecode = 0
 SET unique_cnt = 0
 SET rqp_error_cnt = 0
 FREE RECORD mmp_rqp
 RECORD mmp_rqp(
   1 data[*]
     2 request_number = i4
     2 sequence = i4
     2 target_request_number = i4
     2 format_script = vc
     2 service = vc
     2 forward_override_ind = i2
     2 destination_step_id = f8
     2 active_ind = i2
     2 reprocess_reply_ind = i2
 )
 SET rdm_infile_name = concat("cer_install:", $1)
 CALL parser(concat('set logical rdm_csv_name"',rdm_infile_name,'"'))
 CALL parser("go")
 FREE DEFINE rtl2
 DEFINE rtl2 "rdm_csv_name"
 SELECT INTO "nl:"
  t.line
  FROM rtl2t t
  WHERE t.line > " "
  HEAD REPORT
   unique_stat = alterlist(mmp_rqp->data,50), unique_cnt = 0, line_data = fillstring(2000," "),
   first_one = "Y"
  DETAIL
   IF (first_one="N")
    unique_cnt = (unique_cnt+ 1)
    IF (mod(unique_cnt,50)=1
     AND unique_cnt != 1)
     unique_stat = alterlist(mmp_rqp->data,(unique_cnt+ 49))
    ENDIF
    line_data = t.line, field_number = 1, check_pos = 0
    WHILE (field_number <= 9)
      check_char = " ", check_pos = 0
      WHILE (check_pos <= 2000
       AND check_char != ",")
       check_pos = (check_pos+ 1),check_char = substring(check_pos,1,line_data)
      ENDWHILE
      found_field = substring(1,(check_pos - 1),line_data)
      CASE (field_number)
       OF 1:
        mmp_rqp->data[unique_cnt].request_number = cnvtint(found_field)
       OF 2:
        mmp_rqp->data[unique_cnt].sequence = cnvtint(found_field)
       OF 3:
        mmp_rqp->data[unique_cnt].target_request_number = cnvtint(found_field)
       OF 4:
        mmp_rqp->data[unique_cnt].format_script = found_field
       OF 5:
        mmp_rqp->data[unique_cnt].service = found_field
       OF 6:
        mmp_rqp->data[unique_cnt].forward_override_ind = cnvtint(found_field)
       OF 7:
        mmp_rqp->data[unique_cnt].destination_step_id = cnvtreal(found_field)
       OF 8:
        mmp_rqp->data[unique_cnt].active_ind = cnvtint(found_field)
       OF 9:
        mmp_rqp->data[unique_cnt].reprocess_reply_ind = cnvtint(found_field)
      ENDCASE
      line_data = substring((check_pos+ 1),2000,line_data), field_number = (field_number+ 1)
    ENDWHILE
   ENDIF
   first_one = "N"
  WITH nocounter, maxcol = 2100
 ;end select
 SET stat = alterlist(mmp_rqp->data,unique_cnt)
 SET all_in_the_csv = "Y"
 SELECT INTO "nl:"
  rqp.request_number
  FROM (dummyt d  WITH seq = value(unique_cnt)),
   request_processing rqp
  PLAN (d)
   JOIN (rqp
   WHERE (mmp_rqp->data[d.seq].request_number=rqp.request_number)
    AND (mmp_rqp->data[d.seq].target_request_number=rqp.target_request_number)
    AND ((cnvtupper(mmp_rqp->data[d.seq].format_script)=cnvtupper(rqp.format_script)) OR ((mmp_rqp->
   data[d.seq].format_script=" ")
    AND ((rqp.format_script=null) OR (rqp.format_script <= " ")) ))
    AND ((cnvtupper(mmp_rqp->data[d.seq].service)=cnvtupper(rqp.service)) OR ((mmp_rqp->data[d.seq].
   service=" ")
    AND ((rqp.service=null) OR (rqp.service <= " ")) ))
    AND (mmp_rqp->data[d.seq].destination_step_id=rqp.destination_step_id)
    AND (mmp_rqp->data[d.seq].forward_override_ind=rqp.forward_override_ind)
    AND (mmp_rqp->data[d.seq].reprocess_reply_ind=rqp.reprocess_reply_ind))
  DETAIL
   rqp_error_cnt = (rqp_error_cnt+ 1), all_in_the_csv = "N"
   IF (rqp_error_cnt=1)
    rqp_emsg = build("ERROR Inserting request numbers: ",mmp_rqp->data[d.seq].request_number)
   ELSE
    rqp_emsg = build(rqp_emsg,",",mmp_rqp->data[d.seq].request_number)
   ENDIF
  WITH outerjoin = d, dontexist
 ;end select
 IF (curqual > 0)
  SET readme_data->status = "F"
  SET readme_data->message = rqp_emsg
 ELSEIF (all_in_the_csv="Y")
  SET readme_data->status = "S"
  SET readme_data->message = "All records in the CSV file are in the request_processing table"
 ENDIF
END GO
