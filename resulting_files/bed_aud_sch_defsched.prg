CREATE PROGRAM bed_aud_sch_defsched
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
 FREE SET temp
 RECORD temp(
   1 temp_num = i4
   1 list[*]
     2 template_name = vc
     2 def_sched_id = f8
     2 res_num = i4
     2 resources[*]
       3 applied = vc
       3 resource_cd = f8
       3 resource_name = vc
       3 start_date = dq8
       3 end_date = dq8
       3 days_of_application = vc
       3 weeks_of_month = vc
     2 day_begin = i4
     2 day_end = i4
     2 apply_range = i4
     2 slot_num = i4
     2 slots[*]
       3 start_time = i4
       3 end_time = i4
       3 slot_type = vc
       3 release_to = vc
       3 release_time = vc
 )
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM sch_def_sched s
   PLAN (s
    WHERE s.active_ind=1)
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
  ELSEIF (high_volume_cnt=0)
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "NL:"
  FROM sch_def_sched s
  PLAN (s
   WHERE s.active_ind=1)
  ORDER BY s.mnemonic
  DETAIL
   temp->temp_num = (temp->temp_num+ 1), stat = alterlist(temp->list,temp->temp_num), temp->list[temp
   ->temp_num].template_name = s.mnemonic,
   temp->list[temp->temp_num].def_sched_id = s.def_sched_id, temp->list[temp->temp_num].day_begin = s
   .beg_tm, temp->list[temp->temp_num].day_end = s.end_tm,
   temp->list[temp->temp_num].apply_range = s.apply_range
  WITH nocounter
 ;end select
 IF ((temp->temp_num > 0))
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = temp->temp_num),
    sch_freq f,
    sch_def_apply da,
    sch_resource r
   PLAN (d)
    JOIN (da
    WHERE (da.def_sched_id=temp->list[d.seq].def_sched_id)
     AND da.active_ind=1
     AND ((da.def_state_meaning="ACTIVE") OR (((da.def_state_meaning="MODIFIED") OR (da
    .def_state_meaning="COMPLETE"
     AND ((da.end_dt_tm > cnvtdatetime(curdate,curtime3)) OR (da.end_dt_tm=cnvtdatetime(curdate,
     curtime3))) )) )) )
    JOIN (r
    WHERE r.resource_cd=da.resource_cd)
    JOIN (f
    WHERE f.frequency_id=da.frequency_id)
   DETAIL
    temp->list[d.seq].res_num = (temp->list[d.seq].res_num+ 1), stat = alterlist(temp->list[d.seq].
     resources,temp->list[d.seq].res_num), temp->list[d.seq].resources[temp->list[d.seq].res_num].
    resource_name = r.mnemonic,
    temp->list[d.seq].resources[temp->list[d.seq].res_num].resource_cd = r.resource_cd, temp->list[d
    .seq].resources[temp->list[d.seq].res_num].applied = "Yes", temp->list[d.seq].resources[temp->
    list[d.seq].res_num].start_date = cnvtdatetime(da.beg_dt_tm),
    temp->list[d.seq].resources[temp->list[d.seq].res_num].end_date = cnvtdatetime(da.end_dt_tm)
    FOR (i = 1 TO 5)
      IF (substring(i,1,f.week_string)="X")
       temp->list[d.seq].resources[temp->list[d.seq].res_num].weeks_of_month = build(temp->list[d.seq
        ].resources[temp->list[d.seq].res_num].weeks_of_month,i)
      ENDIF
    ENDFOR
    FOR (i = 1 TO 7)
      IF (substring(i,1,f.days_of_week)="X")
       CASE (i)
        OF 1:
         temp->list[d.seq].resources[temp->list[d.seq].res_num].days_of_application = "U"
        OF 2:
         temp->list[d.seq].resources[temp->list[d.seq].res_num].days_of_application = build(temp->
          list[d.seq].resources[temp->list[d.seq].res_num].days_of_application,"M")
        OF 3:
         temp->list[d.seq].resources[temp->list[d.seq].res_num].days_of_application = build(temp->
          list[d.seq].resources[temp->list[d.seq].res_num].days_of_application,"T")
        OF 4:
         temp->list[d.seq].resources[temp->list[d.seq].res_num].days_of_application = build(temp->
          list[d.seq].resources[temp->list[d.seq].res_num].days_of_application,"W")
        OF 5:
         temp->list[d.seq].resources[temp->list[d.seq].res_num].days_of_application = build(temp->
          list[d.seq].resources[temp->list[d.seq].res_num].days_of_application,"H")
        OF 6:
         temp->list[d.seq].resources[temp->list[d.seq].res_num].days_of_application = build(temp->
          list[d.seq].resources[temp->list[d.seq].res_num].days_of_application,"F")
        OF 7:
         temp->list[d.seq].resources[temp->list[d.seq].res_num].days_of_application = build(temp->
          list[d.seq].resources[temp->list[d.seq].res_num].days_of_application,"S")
       ENDCASE
      ENDIF
    ENDFOR
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = temp->temp_num),
    sch_def_res sdr,
    sch_resource r
   PLAN (d)
    JOIN (sdr
    WHERE (sdr.def_sched_id=temp->list[d.seq].def_sched_id)
     AND sdr.active_ind=1)
    JOIN (r
    WHERE r.resource_cd=sdr.resource_cd
     AND r.active_ind=1)
   DETAIL
    resource_found = 0
    FOR (x = 1 TO temp->list[d.seq].res_num)
      IF ((temp->list[d.seq].resources[x].resource_cd=sdr.resource_cd))
       resource_found = 1
      ENDIF
    ENDFOR
    IF (resource_found=0)
     temp->list[d.seq].res_num = (temp->list[d.seq].res_num+ 1), stat = alterlist(temp->list[d.seq].
      resources,temp->list[d.seq].res_num), temp->list[d.seq].resources[temp->list[d.seq].res_num].
     resource_name = r.mnemonic,
     temp->list[d.seq].resources[temp->list[d.seq].res_num].resource_cd = r.resource_cd, temp->list[d
     .seq].resources[temp->list[d.seq].res_num].applied = "No"
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = temp->temp_num),
    sch_def_slot sds,
    code_value cv1,
    code_value cv2
   PLAN (d)
    JOIN (sds
    WHERE (sds.def_sched_id=temp->list[d.seq].def_sched_id))
    JOIN (cv1
    WHERE cv1.code_value=outerjoin(sds.vis_beg_units_cd)
     AND cv1.active_ind=outerjoin(1))
    JOIN (cv2
    WHERE cv2.code_value=outerjoin(sds.vis_end_units_cd)
     AND cv2.active_ind=outerjoin(1))
   ORDER BY sds.beg_offset
   DETAIL
    temp->list[d.seq].slot_num = (temp->list[d.seq].slot_num+ 1), stat = alterlist(temp->list[d.seq].
     slots,temp->list[d.seq].slot_num)
    IF (((sds.vis_beg_units > 0) OR (sds.vis_end_units > 0))
     AND sds.seq_nbr > 0)
     temp->list[d.seq].slots[temp->list[d.seq].slot_num].release_to = sds.slot_mnemonic
     IF (sds.vis_beg_units > 0)
      temp->list[d.seq].slots[temp->list[d.seq].slot_num].release_time = build2(trim(cnvtstring(sds
         .vis_beg_units))," ",trim(cv1.display))
     ELSE
      temp->list[d.seq].slots[temp->list[d.seq].slot_num].release_time = build2(trim(cnvtstring(sds
         .vis_end_units))," ",trim(cv2.display))
     ENDIF
    ELSE
     temp->list[d.seq].slots[temp->list[d.seq].slot_num].slot_type = sds.slot_mnemonic
    ENDIF
    temp->list[d.seq].slots[temp->list[d.seq].slot_num].start_time = make_hours((sds.beg_offset+
     get_minutes(temp->list[d.seq].day_begin))), temp->list[d.seq].slots[temp->list[d.seq].slot_num].
    end_time = make_hours((sds.end_offset+ get_minutes(temp->list[d.seq].day_begin)))
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->collist,15)
 SET reply->collist[1].header_text = "Template Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Days of Application"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Weeks of Month"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Default Resources"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Template Applied"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Template Start Date"
 SET reply->collist[6].data_type = 4
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Template End Date"
 SET reply->collist[7].data_type = 4
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Apply Range"
 SET reply->collist[8].data_type = 3
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Day Begin"
 SET reply->collist[9].data_type = 3
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Day End"
 SET reply->collist[10].data_type = 3
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Slot Start Time"
 SET reply->collist[11].data_type = 3
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Slot End Time"
 SET reply->collist[12].data_type = 3
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = "Slot Type"
 SET reply->collist[13].data_type = 1
 SET reply->collist[13].hide_ind = 0
 SET reply->collist[14].header_text = "Slot Release To"
 SET reply->collist[14].data_type = 1
 SET reply->collist[14].hide_ind = 0
 SET reply->collist[15].header_text = "Slot Release Time"
 SET reply->collist[15].data_type = 1
 SET reply->collist[15].hide_ind = 0
 SET outputrows = 0
 FOR (i = 1 TO temp->temp_num)
   SET tempstart = (outputrows+ 1)
   FOR (j = 1 TO temp->list[i].slot_num)
     SET outputrows = (outputrows+ 1)
     SET stat = alterlist(reply->rowlist,outputrows)
     SET stat = alterlist(reply->rowlist[outputrows].celllist,15)
     SET reply->rowlist[outputrows].celllist[1].string_value = temp->list[i].template_name
     SET reply->rowlist[outputrows].celllist[11].nbr_value = temp->list[i].slots[j].start_time
     SET reply->rowlist[outputrows].celllist[12].nbr_value = temp->list[i].slots[j].end_time
     SET reply->rowlist[outputrows].celllist[13].string_value = temp->list[i].slots[j].slot_type
     SET reply->rowlist[outputrows].celllist[14].string_value = temp->list[i].slots[j].release_to
     SET reply->rowlist[outputrows].celllist[15].string_value = temp->list[i].slots[j].release_time
   ENDFOR
   IF (outputrows >= tempstart)
    SET reply->rowlist[tempstart].celllist[8].nbr_value = temp->list[i].apply_range
    SET reply->rowlist[tempstart].celllist[9].nbr_value = temp->list[i].day_begin
    SET reply->rowlist[tempstart].celllist[10].nbr_value = temp->list[i].day_end
   ENDIF
   FOR (j = 1 TO temp->list[i].res_num)
     IF (tempstart > outputrows)
      SET outputrows = (outputrows+ 1)
      SET tempstart = outputrows
      SET stat = alterlist(reply->rowlist,outputrows)
      SET stat = alterlist(reply->rowlist[outputrows].celllist,15)
      SET reply->rowlist[tempstart].celllist[1].string_value = temp->list[i].template_name
     ENDIF
     SET reply->rowlist[tempstart].celllist[4].string_value = temp->list[i].resources[j].
     resource_name
     SET reply->rowlist[tempstart].celllist[5].string_value = temp->list[i].resources[j].applied
     IF ((temp->list[i].resources[j].applied="Yes"))
      SET reply->rowlist[tempstart].celllist[2].string_value = temp->list[i].resources[j].
      days_of_application
      SET reply->rowlist[tempstart].celllist[3].string_value = temp->list[i].resources[j].
      weeks_of_month
      SET reply->rowlist[tempstart].celllist[6].date_value = temp->list[i].resources[j].start_date
      SET reply->rowlist[tempstart].celllist[7].date_value = temp->list[i].resources[j].end_date
     ENDIF
     SET tempstart = (tempstart+ 1)
   ENDFOR
 ENDFOR
 SET reply->status_data.status = "S"
 CALL echorecord(temp)
 SUBROUTINE get_minutes(xtime)
   SET hours = floor((xtime/ 100))
   SET minutes = mod(xtime,100)
   RETURN(((hours * 60)+ minutes))
 END ;Subroutine
 SUBROUTINE make_hours(xtime)
   SET minutes = xtime
   SET hours = 0
   WHILE (minutes >= 60)
    SET minutes = (minutes - 60)
    SET hours = (hours+ 1)
   ENDWHILE
   RETURN(((hours * 100)+ minutes))
 END ;Subroutine
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("def_sched_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
