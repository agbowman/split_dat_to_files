CREATE PROGRAM bed_aud_cn_emar_prn_response
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
 DECLARE med_task_list = vc
 SET med_task_list = " "
 SELECT INTO "NL:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=6026
   AND cv.cdf_meaning="MED"
  DETAIL
   IF (med_task_list=" ")
    med_task_list = build(" ot.task_type_cd in (",cv.code_value)
   ELSE
    med_task_list = build(med_task_list,",",cv.code_value)
   ENDIF
  WITH nocounter, noheading
 ;end select
 SET med_task_list = concat(med_task_list,")")
 CALL echo(med_task_list)
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM order_task ot,
    order_task_response otr
   PLAN (ot
    WHERE parser(med_task_list)
     AND ot.active_ind=1)
    JOIN (otr
    WHERE otr.reference_task_id=ot.reference_task_id)
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 1500)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 1000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = alterlist(reply->collist,4)
 SET reply->collist[1].header_text = "Task Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "PRN Response Task"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Route That Will Cause the PRN Task to Generate"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "# of Minutes to generate follow up PRN response task"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SELECT INTO "nl:"
  ot.task_description, cv.display, otr.response_minutes
  FROM order_task ot,
   order_task_response otr,
   order_task ot2,
   code_value cv
  PLAN (ot
   WHERE parser(med_task_list)
    AND ot.active_ind=1)
   JOIN (otr
   WHERE otr.reference_task_id=ot.reference_task_id)
   JOIN (cv
   WHERE cv.code_value=otr.route_cd)
   JOIN (ot2
   WHERE otr.response_task_id=ot2.reference_task_id)
  ORDER BY ot.task_description, otr.route_cd
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->rowlist,50)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,50)=0)
    stat = alterlist(reply->rowlist,(50+ cnt))
   ENDIF
   stat = alterlist(reply->rowlist[cnt].celllist,4), reply->rowlist[cnt].celllist[1].string_value =
   ot.task_description, reply->rowlist[cnt].celllist[2].string_value = ot2.task_description,
   reply->rowlist[cnt].celllist[3].string_value = cv.display, reply->rowlist[cnt].celllist[4].
   string_value = cnvtstring(otr.response_minutes)
  FOOT REPORT
   stat = alterlist(reply->rowlist,cnt)
  WITH nocounter, noheading
 ;end select
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("carenet_emar_prn_response.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
