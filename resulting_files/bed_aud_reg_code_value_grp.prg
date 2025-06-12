CREATE PROGRAM bed_aud_reg_code_value_grp
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
 RECORD int_rec(
   1 qual[*]
     2 code_set = i2
 )
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 high_volume_flag = i2
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
  )
 ENDIF
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM pm_flx_prompt pf
   PLAN (pf
    WHERE pf.active_ind=1
     AND pf.codeset > 0
     AND pf.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND pf.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 250000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 175000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = alterlist(reply->collist,10)
 SET reply->collist[1].header_text = "Parent Code Set"
 SET reply->collist[1].data_type = 3
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Parent Code Set Name"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Parent Code Value"
 SET reply->collist[3].data_type = 2
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Parent Code Value Display"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Child Code Set"
 SET reply->collist[5].data_type = 3
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Child Code Set Name"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Child Code Value"
 SET reply->collist[7].data_type = 2
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Child Code Value Display"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Last Updated By"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Last Update Date and Time"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SELECT DISTINCT INTO "nl:"
  pf.codeset
  FROM pm_flx_prompt pf
  PLAN (pf
   WHERE pf.active_ind=1
    AND pf.codeset > 0
    AND pf.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pf.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  HEAD REPORT
   cnt = 0, stat = alterlist(int_rec->qual,25)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,25)=0)
    stat = alterlist(int_rec->qual,(25+ cnt))
   ENDIF
   int_rec->qual[cnt].code_set = pf.codeset
  FOOT REPORT
   stat = alterlist(int_rec->qual,cnt)
  WITH nocounter, noheading
 ;end select
 IF (size(int_rec,5)=0)
  GO TO exit_script
 ENDIF
 CALL echo("Got Here")
 SELECT INTO "nl:"
  parent_code_set = cv1.code_set, parent_cs_name = cvs1.display, parent_value = cvg.parent_code_value,
  parent_display = cv1.display, child_code_set = cv2.code_set, child_cs_name = cvs2.display,
  child_value = cvg.child_code_value, child_display = cv2.display
  FROM (dummyt d  WITH seq = value(size(int_rec->qual,5))),
   code_value_group cvg,
   code_value cv1,
   code_value cv2,
   code_value_set cvs1,
   code_value_set cvs2,
   prsnl p
  PLAN (d)
   JOIN (cv1
   WHERE (cv1.code_set=int_rec->qual[d.seq].code_set)
    AND cv1.active_ind=1
    AND cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cv1.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (cvg
   WHERE cvg.parent_code_value=cv1.code_value)
   JOIN (cv2
   WHERE cvg.child_code_value=cv2.code_value
    AND cv2.active_ind=1
    AND cv2.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cv2.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (cvs1
   WHERE cvs1.code_set=cv1.code_set)
   JOIN (cvs2
   WHERE cvs2.code_set=cv2.code_set)
   JOIN (p
   WHERE p.person_id=outerjoin(cvg.updt_id)
    AND p.active_ind=outerjoin(1))
  ORDER BY parent_code_set, child_code_set, parent_value
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->rowlist,25)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,25)=0)
    stat = alterlist(reply->rowlist,(25+ cnt))
   ENDIF
   stat = alterlist(reply->rowlist[cnt].celllist,10), reply->rowlist[cnt].celllist[1].nbr_value = cv1
   .code_set, reply->rowlist[cnt].celllist[2].string_value = cvs1.display,
   reply->rowlist[cnt].celllist[3].double_value = cvg.parent_code_value, reply->rowlist[cnt].
   celllist[4].string_value = cv1.display, reply->rowlist[cnt].celllist[5].nbr_value = cv2.code_set,
   reply->rowlist[cnt].celllist[6].string_value = cvs2.display, reply->rowlist[cnt].celllist[7].
   double_value = cvg.child_code_value, reply->rowlist[cnt].celllist[8].string_value = cv2.display,
   reply->rowlist[cnt].celllist[9].string_value = p.name_full_formatted, reply->rowlist[cnt].
   celllist[10].string_value = format(cvg.updt_dt_tm,";;Q")
  FOOT REPORT
   stat = alterlist(reply->rowlist,cnt)
  WITH nocounter, noheading
 ;end select
 SET reply->status_data.status = "S"
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("erm_code_value_group.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
#exit_script
END GO
