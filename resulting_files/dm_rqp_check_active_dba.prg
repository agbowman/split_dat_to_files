CREATE PROGRAM dm_rqp_check_active:dba
 DECLARE rqp_emsg = vc
 DECLARE rqp_ecode = f8
 DECLARE unique_cnt = i4
 DECLARE infile_name = vc
 DECLARE check_pos = i4
 DECLARE check_char = vc
 DECLARE line_data = vc
 DECLARE first_one = c1
 DECLARE found_field = vc
 DECLARE field_number = i4
 SET rqp_emsg = fillstring(132," ")
 SET rqp_ecode = 0
 SET unique_cnt = 0
 SET readme_data->status = "S"
 SET readme_data->message = "All records in the CSV file are updated in the request_processing table"
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
 SET infile_name =  $1
 SET logical csv_name value(infile_name)
 IF (findfile(infile_name)=0)
  SET readme_data->message = ".csv file not found"
  SET readme_data->status = "F"
  GO TO exit_script
 ENDIF
 FREE DEFINE rtl2
 DEFINE rtl2 "csv_name"
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
 SET all_in_the_csv = "Y"
 SELECT INTO "nl:"
  rqp.request_number
  FROM (dummyt d  WITH seq = value(unique_cnt)),
   request_processing rqp
  PLAN (d)
   JOIN (rqp
   WHERE (mmp_rqp->data[d.seq].request_number=rqp.request_number)
    AND (mmp_rqp->data[d.seq].target_request_number=rqp.target_request_number)
    AND (mmp_rqp->data[d.seq].format_script=rqp.format_script)
    AND (mmp_rqp->data[d.seq].service=rqp.service)
    AND (mmp_rqp->data[d.seq].destination_step_id=rqp.destination_step_id))
  DETAIL
   IF ((rqp.active_ind != mmp_rqp->data[d.seq].active_ind))
    readme_data->status = "F", readme_data->message = build(
     "This record is in the CSV file, but not updated on"," the request_processing table.",
     " Request #: ",mmp_rqp->data[d.seq].request_number,", Target RQ#: ",
     mmp_rqp->data[d.seq].target_request_number,", Format Script: ",mmp_rqp->data[d.seq].
     format_script,", Service: ",mmp_rqp->data[d.seq].service,
     ", Dest St id: ",mmp_rqp->data[d.seq].destination_step_id,", Forward ovr ind: ",mmp_rqp->data[d
     .seq].forward_override_ind,", Reproc Reply ind: ",
     mmp_rqp->data[d.seq].reprocess_reply_ind,", Active ind: ",mmp_rqp->data[d.seq].active_ind)
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 EXECUTE dm_readme_status
END GO
