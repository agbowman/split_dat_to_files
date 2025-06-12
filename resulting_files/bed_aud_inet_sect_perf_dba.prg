CREATE PROGRAM bed_aud_inet_sect_perf:dba
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
  )
 ENDIF
 RECORD temp(
   1 vlist[*]
     2 view_name = vc
     2 prim_event_cnt = f8
 )
 SUBROUTINE get_code_value(xcodeset,xcdf)
   SET to_return = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=xcodeset
      AND c.cdf_meaning=xcdf
      AND c.active_ind=1)
    DETAIL
     to_return = c.code_value
    WITH nocounter
   ;end select
   RETURN(to_return)
 END ;Subroutine
 SET stat = alterlist(reply->collist,2)
 SET reply->collist[1].header_text = "Section Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Greater than 40 primitive event sets (assays)"
 SET reply->collist[2].data_type = 2
 SET reply->collist[2].hide_ind = 0
 SET totcnt = 0
 SET tcnt = 0
 SELECT INTO "nl:"
  vcnt = count(*)
  FROM working_view_section wvs
  DETAIL
   totcnt = vcnt
  WITH nocounter
 ;end select
 IF ((request->skip_volume_check_ind=0))
  IF (totcnt > 10000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (totcnt > 5000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  vname = wvs.display_name
  FROM working_view_section wvs,
   working_view_item wvi
  PLAN (wvs
   WHERE wvs.display_name > " ")
   JOIN (wvi
   WHERE wvi.working_view_section_id=wvs.working_view_section_id)
  ORDER BY wvs.display_name, wvi.primitive_event_set_name
  HEAD REPORT
   tcnt = 0
  HEAD wvs.display_name
   pecnt = 0
  HEAD wvi.primitive_event_set_name
   pecnt = (pecnt+ 1)
  FOOT  wvs.display_name
   IF (pecnt > 40)
    tcnt = (tcnt+ 1), stat = alterlist(temp->vlist,tcnt), temp->vlist[tcnt].view_name = wvs
    .display_name,
    temp->vlist[tcnt].prim_event_cnt = pecnt
   ENDIF
  WITH nocounter
 ;end select
 IF (tcnt > 0)
  SET rcnt = 0
  SELECT INTO "nl:"
   vname = cnvtupper(temp->vlist[d.seq].view_name)
   FROM (dummyt d  WITH seq = tcnt)
   ORDER BY vname
   HEAD vname
    rcnt = (rcnt+ 1), stat = alterlist(reply->rowlist,rcnt), stat = alterlist(reply->rowlist[rcnt].
     celllist,2),
    reply->rowlist[rcnt].celllist[1].string_value = temp->vlist[d.seq].view_name, reply->rowlist[rcnt
    ].celllist[2].double_value = temp->vlist[d.seq].prim_event_cnt
   WITH nocounter
  ;end select
 ENDIF
 IF (tcnt > 0)
  SET reply->run_status_flag = 3
 ELSE
  SET reply->run_status_flag = 1
 ENDIF
 SET stat = alterlist(reply->statlist,1)
 SET reply->statlist[1].statistic_meaning = "INETSECTSTOOMANYPRIMS"
 SET reply->statlist[1].total_items = totcnt
 SET reply->statlist[1].qualifying_items = tcnt
 IF (tcnt > 0)
  SET reply->statlist[1].status_flag = 3
 ELSE
  SET reply->statlist[1].status_flag = 1
 ENDIF
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("inet_sect_perf_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 SET reply->status_data.status = "S"
END GO
