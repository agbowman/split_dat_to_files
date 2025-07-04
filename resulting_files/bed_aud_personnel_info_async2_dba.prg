CREATE PROGRAM bed_aud_personnel_info_async2:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 position_code[*]
      2 position_code_value = f8
    1 physician = i2
    1 username = i2
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i8
      2 total_items = i8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 DECLARE rowidentifier = vc WITH protect, noconstant("")
 IF ( NOT (validate(temprequest,0)))
  RECORD temprequest(
    1 reportname = vc
    1 completedind = i2
    1 rowidentifier = vc
  )
 ENDIF
 IF ( NOT (validate(tempreply,0)))
  RECORD tempreply(
    1 nodename = vc
    1 rowidentifier = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET temprequest->reportname = request->output_filename
 SET temprequest->completedind = 0
 SET temprequest->rowidentifier = ""
 EXECUTE bed_ens_rpt_node_info  WITH replace("REQUEST",temprequest), replace("REPLY",tempreply)
 CALL echorecord(temprequest)
 CALL echorecord(tempreply)
 SET rowidentifier = tempreply->rowidentifier
 EXECUTE bed_aud_personnel_info
 CALL echorecord(reply)
 SET temprequest->reportname = request->output_filename
 SET temprequest->completedind = 1
 SET temprequest->rowidentifier = rowidentifier
 EXECUTE bed_ens_rpt_node_info  WITH replace("REQUEST",temprequest), replace("REPLY",tempreply)
END GO
