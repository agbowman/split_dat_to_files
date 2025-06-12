CREATE PROGRAM bed_aud_org_group:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist[*]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist[*]
        3 dbl_value = f8
        3 string_value = vc
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
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET auth_code = 0.0
 SET auth_code = uar_get_code_by("MEANING",8,"AUTH")
 SET col_cnt = 4
 SET stat = alterlist(reply->collist,col_cnt)
 SET reply->collist[1].header_text = "Organization Group"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Organization Group Type"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 1
 SET reply->collist[3].header_text = "Organization Name"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Organization ID"
 SET reply->collist[4].data_type = 2
 SET reply->collist[4].hide_ind = 1
 SET high_volume_cnt = 0
 SET row_tot_cnt = 0
 DECLARE org_type_lst = vc
 SELECT INTO "nl:"
  FROM organization o,
   org_set_org_r osor,
   org_set os,
   org_set_type_r ostr,
   code_value cv
  PLAN (o
   WHERE o.data_status_cd=auth_code
    AND o.active_ind=1)
   JOIN (osor
   WHERE osor.organization_id=o.organization_id
    AND osor.active_ind=1)
   JOIN (os
   WHERE os.org_set_id=osor.org_set_id
    AND os.active_ind=1)
   JOIN (ostr
   WHERE ostr.org_set_id=os.org_set_id
    AND ostr.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=ostr.org_set_type_cd
    AND cv.active_ind=1)
  ORDER BY cnvtupper(os.name), os.org_set_id, cnvtupper(o.org_name),
   o.organization_id, cnvtupper(cv.display)
  HEAD REPORT
   row_tot_cnt = 0
  HEAD os.org_set_id
   org_type_lst = ""
  HEAD o.organization_id
   row_tot_cnt = (size(reply->rowlist,5)+ 1), stat = alterlist(reply->rowlist,row_tot_cnt), stat =
   alterlist(reply->rowlist[row_tot_cnt].celllist,col_cnt),
   reply->rowlist[row_tot_cnt].celllist[1].string_value = os.name, reply->rowlist[row_tot_cnt].
   celllist[3].string_value = o.org_name, reply->rowlist[row_tot_cnt].celllist[4].double_value = o
   .organization_id,
   tcnt = 0, org_type_lst = ""
  DETAIL
   tcnt = (tcnt+ 1)
   IF (tcnt=1)
    org_type_lst = cv.display
   ELSE
    org_type_lst = concat(org_type_lst,", ",cv.display)
   ENDIF
  FOOT  o.organization_id
   reply->rowlist[row_tot_cnt].celllist[2].string_value = org_type_lst
  WITH nocounter
 ;end select
 IF ((request->skip_volume_check_ind=0))
  CALL echo(row_tot_cnt)
  IF (row_tot_cnt > 5000)
   SET reply->high_volume_flag = 2
   SET stat = alterlist(reply->rowlist,0)
   GO TO exit_script
  ELSEIF (row_tot_cnt > 3000)
   SET reply->high_volume_flag = 1
   SET stat = alterlist(reply->rowlist,0)
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("br_org_group.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
