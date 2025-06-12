CREATE PROGRAM bed_aud_ap_synoptic_rpt_assn:dba
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
 FREE RECORD temp
 RECORD temp(
   1 tcnt = i2
   1 tqual[*]
     2 worksheet = vc
     2 specimen = vc
     2 report_name = vc
     2 report_section = vc
     2 prefix = vc
     2 def_work_spec_assn = i2
 )
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM ap_synoptic_spec_prefix_r as,
    ap_synoptic_rpt_section_r ar
   PLAN (as)
    JOIN (ar
    WHERE a2.cki_identifier=a1.cki_identifier
     AND a2.cki_source=a1.cki_source)
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
 SET tcnt = 0
 SELECT INTO "NL:"
  FROM ap_synoptic_spec_prefix_r a1,
   ap_synoptic_rpt_section_r a2,
   ap_prefix ap,
   code_value cv1,
   code_value cv2,
   code_value cv3
  PLAN (a1)
   JOIN (a2
   WHERE a2.cki_identifier=a1.cki_identifier
    AND a2.cki_source=a1.cki_source)
   JOIN (ap
   WHERE ap.prefix_id=outerjoin(a1.prefix_id)
    AND ap.active_ind=outerjoin(1))
   JOIN (cv1
   WHERE cv1.code_value=outerjoin(a1.specimen_cd)
    AND cv1.active_ind=outerjoin(1))
   JOIN (cv2
   WHERE cv2.code_value=outerjoin(a2.catalog_cd)
    AND cv2.active_ind=outerjoin(1))
   JOIN (cv3
   WHERE cv3.code_value=outerjoin(a2.task_assay_cd)
    AND cv3.active_ind=outerjoin(1))
  ORDER BY a1.cki_identifier
  DETAIL
   tcnt = (tcnt+ 1), temp->tcnt = tcnt, stat = alterlist(temp->tqual,tcnt),
   temp->tqual[tcnt].worksheet = a1.cki_identifier, temp->tqual[tcnt].specimen = cv1.display, temp->
   tqual[tcnt].report_name = cv2.display,
   temp->tqual[tcnt].report_section = cv3.display, temp->tqual[tcnt].prefix = ap.prefix_name, temp->
   tqual[tcnt].def_work_spec_assn = a1.suggested_flag
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,6)
 SET reply->collist[1].header_text = "Synoptic Worksheet"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Specimen"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Report"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Report Section"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Prefix"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Default Worksheet Specimen Association"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,6)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].worksheet
   SET reply->rowlist[row_nbr].celllist[2].string_value = temp->tqual[x].specimen
   SET reply->rowlist[row_nbr].celllist[3].string_value = temp->tqual[x].report_name
   SET reply->rowlist[row_nbr].celllist[4].string_value = temp->tqual[x].report_section
   SET reply->rowlist[row_nbr].celllist[5].string_value = temp->tqual[x].prefix
   IF ((temp->tqual[x].def_work_spec_assn=1))
    SET reply->rowlist[row_nbr].celllist[6].string_value = "X"
   ELSE
    SET reply->rowlist[row_nbr].celllist[6].string_value = " "
   ENDIF
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("ap_synoptic_reporting_worksheet_associations.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
