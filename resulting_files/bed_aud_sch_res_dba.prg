CREATE PROGRAM bed_aud_sch_res:dba
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
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM sch_resource r
   WHERE r.active_ind=1
    AND r.res_type_flag IN (1, 2, 3)
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 5000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 3000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = alterlist(reply->collist,5)
 SET reply->collist[1].header_text = "Resource Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Resource Booking Limit"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Resource Type"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Associated Personnel Name"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Associated Radiology or Surgery Room Display"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET count = 0
 SELECT INTO "NL:"
  FROM sch_resource r,
   prsnl p,
   code_value c
  PLAN (r
   WHERE r.active_ind=1
    AND r.res_type_flag IN (1, 2, 3))
   JOIN (p
   WHERE p.person_id=outerjoin(r.person_id)
    AND p.active_ind=outerjoin(1))
   JOIN (c
   WHERE c.code_value=outerjoin(r.service_resource_cd)
    AND c.active_ind=outerjoin(1))
  ORDER BY r.mnemonic
  DETAIL
   count = (count+ 1), stat = alterlist(reply->rowlist,count), stat = alterlist(reply->rowlist[count]
    .celllist,5),
   reply->rowlist[count].celllist[1].string_value = r.mnemonic, reply->rowlist[count].celllist[2].
   string_value = cnvtstring(r.quota)
   IF (r.res_type_flag=1)
    reply->rowlist[count].celllist[3].string_value = "General"
   ELSEIF (r.res_type_flag=2)
    reply->rowlist[count].celllist[3].string_value = "Personnel"
   ELSE
    reply->rowlist[count].celllist[3].string_value = "Service Resource"
   ENDIF
   reply->rowlist[count].celllist[4].string_value = p.name_full_formatted, reply->rowlist[count].
   celllist[5].string_value = c.display
  WITH nocounter
 ;end select
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("scheduling_resources.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
