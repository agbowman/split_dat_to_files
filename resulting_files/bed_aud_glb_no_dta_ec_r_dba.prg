CREATE PROGRAM bed_aud_glb_no_dta_ec_r:dba
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
 RECORD temp(
   1 dlist[*]
     2 task_assay_cd = f8
     2 dtaname = vc
     2 dtadesc = vc
 )
 DECLARE glb_disp = vc
 SET glb_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=106
    AND c.cdf_meaning="GLB"
    AND c.active_ind=1)
  DETAIL
   glb_cd = c.code_value, glb_disp = c.display
  WITH nocounter
 ;end select
 SET dcnt = 0
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM discrete_task_assay dta
   PLAN (dta
    WHERE dta.activity_type_cd=glb_cd
     AND dta.active_ind=1)
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 25000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 15000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM discrete_task_assay dta,
   code_value_event_r cver
  PLAN (dta
   WHERE dta.active_ind=1
    AND dta.activity_type_cd=glb_cd)
   JOIN (cver
   WHERE cver.parent_cd=outerjoin(dta.task_assay_cd))
  ORDER BY dta.mnemonic_key_cap
  HEAD REPORT
   dcnt = 0
  DETAIL
   IF (cver.event_cd=0)
    dcnt = (dcnt+ 1), stat = alterlist(temp->dlist,dcnt), temp->dlist[dcnt].task_assay_cd = dta
    .task_assay_cd,
    temp->dlist[dcnt].dtaname = dta.mnemonic, temp->dlist[dcnt].dtadesc = dta.description
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,3)
 SET reply->collist[1].header_text = "Assay Display"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Assay Description"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 1
 SET reply->collist[3].header_text = "task_assay_cd"
 SET reply->collist[3].data_type = 2
 SET reply->collist[3].hide_ind = 1
 IF (dcnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = dcnt)
  HEAD REPORT
   row_nbr = 0
  DETAIL
   row_nbr = (row_nbr+ 1), stat = alterlist(reply->rowlist,row_nbr), stat = alterlist(reply->rowlist[
    row_nbr].celllist,3),
   reply->rowlist[row_nbr].celllist[1].string_value = temp->dlist[d.seq].dtaname, reply->rowlist[
   row_nbr].celllist[2].string_value = temp->dlist[d.seq].dtadesc, reply->rowlist[row_nbr].celllist[3
   ].double_value = temp->dlist[d.seq].task_assay_cd
  WITH nocounter
 ;end select
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("gl_assay_no_event_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
