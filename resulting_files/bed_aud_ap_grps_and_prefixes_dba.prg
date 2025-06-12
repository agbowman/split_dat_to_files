CREATE PROGRAM bed_aud_ap_grps_and_prefixes:dba
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
     2 group_disp = vc
     2 group_desc = vc
     2 auto_reset_acc_bucket = i2
     2 allow_for_manual_reset = i2
     2 prefix_disp = vc
     2 prefix_desc = vc
     2 case_type = vc
     2 order_disp = vc
     2 process_task_def = vc
     2 initiate_tasks = i2
     2 id_scheme = vc
     2 service_resource = vc
     2 last_updated_by = vc
 )
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM prefix_group pg,
    ap_prefix ap
   PLAN (pg
    WHERE pg.active_ind=1)
    JOIN (ap
    WHERE ap.group_id=outerjoin(pg.group_id)
     AND ap.active_ind=outerjoin(1))
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
  FROM prefix_group pg,
   ap_prefix ap,
   code_value cv1,
   code_value cv2,
   code_value cv3,
   code_value cv4,
   code_value cv5,
   code_value cv6,
   code_value cv7,
   ap_prefix_tag_group_r ar1,
   ap_prefix_tag_group_r ar2,
   ap_prefix_tag_group_r ar3,
   ap_tag at1,
   ap_tag at2,
   ap_tag at3,
   person p
  PLAN (pg
   WHERE pg.active_ind=1)
   JOIN (ap
   WHERE ap.group_id=outerjoin(pg.group_id)
    AND ap.active_ind=outerjoin(1))
   JOIN (cv1
   WHERE cv1.code_value=outerjoin(ap.site_cd)
    AND cv1.active_ind=outerjoin(1))
   JOIN (cv2
   WHERE cv2.code_value=outerjoin(ap.accession_format_cd)
    AND cv2.active_ind=outerjoin(1))
   JOIN (cv3
   WHERE cv3.code_value=outerjoin(ap.case_type_cd)
    AND cv3.active_ind=outerjoin(1))
   JOIN (cv4
   WHERE cv4.code_value=outerjoin(ap.order_catalog_cd)
    AND cv4.active_ind=outerjoin(1))
   JOIN (cv5
   WHERE cv5.code_value=outerjoin(ap.default_proc_catalog_cd)
    AND cv5.active_ind=outerjoin(1))
   JOIN (cv6
   WHERE cv6.code_value=outerjoin(pg.site_cd)
    AND cv6.active_ind=outerjoin(1))
   JOIN (cv7
   WHERE cv7.code_value=outerjoin(ap.service_resource_cd)
    AND cv7.active_ind=outerjoin(1))
   JOIN (ar1
   WHERE ar1.prefix_id=outerjoin(ap.prefix_id)
    AND ar1.tag_type_flag=outerjoin(1))
   JOIN (ar2
   WHERE ar2.prefix_id=outerjoin(ap.prefix_id)
    AND ar2.tag_type_flag=outerjoin(2))
   JOIN (ar3
   WHERE ar3.prefix_id=outerjoin(ap.prefix_id)
    AND ar3.tag_type_flag=outerjoin(3))
   JOIN (at1
   WHERE at1.tag_group_id=outerjoin(ar1.tag_group_id)
    AND at1.tag_sequence=outerjoin(1)
    AND at1.active_ind=outerjoin(1))
   JOIN (at2
   WHERE at2.tag_group_id=outerjoin(ar2.tag_group_id)
    AND at2.tag_sequence=outerjoin(1)
    AND at2.active_ind=outerjoin(1))
   JOIN (at3
   WHERE at3.tag_group_id=outerjoin(ar3.tag_group_id)
    AND at3.tag_sequence=outerjoin(1)
    AND at3.active_ind=outerjoin(1))
   JOIN (p
   WHERE p.person_id=outerjoin(ap.updt_id)
    AND p.active_ind=outerjoin(1))
  ORDER BY pg.group_name
  DETAIL
   tcnt = (tcnt+ 1), temp->tcnt = tcnt, stat = alterlist(temp->tqual,tcnt),
   temp->tqual[tcnt].group_disp = concat(trim(cv6.display),trim(pg.group_name)), temp->tqual[tcnt].
   group_desc = pg.group_desc, temp->tqual[tcnt].auto_reset_acc_bucket = pg.reset_yearly_ind,
   temp->tqual[tcnt].allow_for_manual_reset = pg.manual_assign_ind, temp->tqual[tcnt].prefix_disp =
   concat(trim(cv1.display),trim(cv2.display)), temp->tqual[tcnt].prefix_desc = ap.prefix_desc,
   temp->tqual[tcnt].case_type = cv3.display, temp->tqual[tcnt].order_disp = cv4.display, temp->
   tqual[tcnt].process_task_def = cv5.display,
   temp->tqual[tcnt].initiate_tasks = ap.initiate_protocol_ind, temp->tqual[tcnt].id_scheme = concat(
    trim(at1.tag_disp),trim(ar2.tag_separator),trim(at2.tag_disp),trim(ar3.tag_separator),trim(at3
     .tag_disp)), temp->tqual[tcnt].service_resource = cv7.display,
   temp->tqual[tcnt].last_updated_by = p.name_full_formatted
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,13)
 SET reply->collist[1].header_text = "Group Display"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Group Description"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Automatically Reset Accession Number Bucket Annually"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Allow for Manual Reset of the Accession Number Bucket"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Prefix"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Prefix Description"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Case Type"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Specimen Request Procedure"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Processing Task Default"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Initiate Tasks"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "ID Scheme"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Service Resource"
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = "Last Updated By"
 SET reply->collist[13].data_type = 1
 SET reply->collist[13].hide_ind = 0
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,13)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].group_disp
   SET reply->rowlist[row_nbr].celllist[2].string_value = temp->tqual[x].group_desc
   IF ((temp->tqual[x].auto_reset_acc_bucket=1))
    SET reply->rowlist[row_nbr].celllist[3].string_value = "X"
   ENDIF
   IF ((temp->tqual[x].allow_for_manual_reset=1))
    SET reply->rowlist[row_nbr].celllist[4].string_value = "X"
   ENDIF
   SET reply->rowlist[row_nbr].celllist[5].string_value = temp->tqual[x].prefix_disp
   SET reply->rowlist[row_nbr].celllist[6].string_value = temp->tqual[x].prefix_desc
   SET reply->rowlist[row_nbr].celllist[7].string_value = temp->tqual[x].case_type
   SET reply->rowlist[row_nbr].celllist[8].string_value = temp->tqual[x].order_disp
   SET reply->rowlist[row_nbr].celllist[9].string_value = temp->tqual[x].process_task_def
   IF ((temp->tqual[x].initiate_tasks=1))
    SET reply->rowlist[row_nbr].celllist[10].string_value = "X"
   ENDIF
   SET reply->rowlist[row_nbr].celllist[11].string_value = temp->tqual[x].id_scheme
   SET reply->rowlist[row_nbr].celllist[12].string_value = temp->tqual[x].service_resource
   SET reply->rowlist[row_nbr].celllist[13].string_value = temp->tqual[x].last_updated_by
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("ap_groups_and_prefixes.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
