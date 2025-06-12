CREATE PROGRAM bed_aud_sch_slottypes
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
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
 SET stat = alterlist(reply->collist,7)
 SET reply->collist[1].header_text = "Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Type"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Start Time Interval"
 SET reply->collist[3].data_type = 3
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Duration"
 SET reply->collist[4].data_type = 3
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Display Scheme"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Priority"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Flex Rule"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET use_pri = 0
 SELECT INTO "NL:"
  FROM sch_slot_type s
  DETAIL
   IF (validate(s.priority_cd)=1)
    use_pri = 1
   ENDIF
  WITH nocounter, maxrec = 1
 ;end select
 SET rows = 0
 IF (use_pri=1)
  SELECT INTO "NL:"
   FROM sch_slot_type s,
    sch_disp_scheme d,
    code_value c,
    sch_flex_string f
   PLAN (s
    WHERE s.active_ind=1)
    JOIN (d
    WHERE outerjoin(s.disp_scheme_id)=d.disp_scheme_id)
    JOIN (c
    WHERE c.code_value=outerjoin(s.priority_cd))
    JOIN (f
    WHERE f.sch_flex_id=outerjoin(s.sch_flex_id))
   ORDER BY s.mnemonic
   DETAIL
    rows = (rows+ 1), stat = alterlist(reply->rowlist,rows), stat = alterlist(reply->rowlist[rows].
     celllist,7),
    reply->rowlist[rows].celllist[1].string_value = s.mnemonic
    IF (s.contiguous_ind=0)
     reply->rowlist[rows].celllist[2].string_value = "Discrete"
    ELSE
     reply->rowlist[rows].celllist[2].string_value = "Contiguous"
    ENDIF
    IF (s.interval >= 0)
     reply->rowlist[rows].celllist[3].nbr_value = s.interval
    ENDIF
    reply->rowlist[rows].celllist[4].nbr_value = s.def_duration, reply->rowlist[rows].celllist[5].
    string_value = d.mnemonic
    IF (s.priority_cd > 0)
     reply->rowlist[rows].celllist[6].string_value = c.display
    ENDIF
    IF (s.sch_flex_id > 0)
     reply->rowlist[rows].celllist[7].string_value = f.mnemonic
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "NL:"
   FROM sch_slot_type s,
    sch_disp_scheme d,
    sch_flex_string
   PLAN (s
    WHERE s.active_ind=1)
    JOIN (d
    WHERE outerjoin(s.disp_scheme_id)=d.disp_scheme_id)
    JOIN (f
    WHERE f.sch_flex_id=outerjoin(s.sch_flex_id))
   ORDER BY s.mnemonic
   DETAIL
    rows = (rows+ 1), stat = alterlist(reply->rowlist,rows), stat = alterlist(reply->rowlist[rows].
     celllist,7),
    reply->rowlist[rows].celllist[1].string_value = s.mnemonic
    IF (s.contiguous_ind=0)
     reply->rowlist[rows].celllist[2].string_value = "Discrete"
    ELSE
     reply->rowlist[rows].celllist[2].string_value = "Contiguous"
    ENDIF
    IF (s.interval >= 0)
     reply->rowlist[rows].celllist[3].nbr_value = s.interval
    ENDIF
    reply->rowlist[rows].celllist[4].nbr_value = s.def_duration, reply->rowlist[rows].celllist[5].
    string_value = d.mnemonic
    IF (s.sch_flex_id > 0)
     reply->rowlist[rows].celllist[7].string_value = f.mnemonic
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
END GO
