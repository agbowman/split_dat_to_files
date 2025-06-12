CREATE PROGRAM bed_aud_incmplt_gl_assay:dba
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
 RECORD request_serv_res(
   1 slist[*]
     2 code_value = f8
   1 activity_type_code_value = f8
 )
 RECORD reply_serv_res(
   1 rlist[*]
     2 code_value = f8
     2 display = vc
     2 description = vc
     2 mean = vc
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD request_sr_detail(
   1 service_resources[*]
     2 code_value = f8
   1 load
     2 sequence_ind = i2
     2 result_type_ind = i2
     2 alpha_ind = i2
     2 numeric_ind = i2
 )
 RECORD reply_sr_detail(
   1 service_resources[*]
     2 code_value = f8
     2 assay_need_seq_ind = i2
     2 assay_need_result_type_ind = i2
     2 assay_need_alpha_ind = i2
     2 assay_need_numeric_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 qual[*]
     2 org_id = f8
     2 org_disp = vc
     2 code_value = f8
     2 display = vc
     2 assay_need_seq_ind = i2
     2 assay_need_result_type_ind = i2
     2 assay_need_alpha_ind = i2
     2 assay_need_numeric_ind = i2
 )
 SET need_result_type_cnt = 0
 SET need_alpha_cnt = 0
 SET need_numeric_cnt = 0
 SET glb_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=106
    AND cv.cdf_meaning="GLB"
    AND cv.active_ind=1)
  DETAIL
   glb_cd = cv.code_value
  WITH nocounter
 ;end select
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM service_resource s,
    code_value cv
   PLAN (s
    WHERE s.active_ind=1
     AND s.activity_type_cd=glb_cd)
    JOIN (cv
    WHERE cv.code_value=s.service_resource_cd
     AND cv.active_ind=1
     AND cv.code_set=221
     AND cv.cdf_meaning IN ("BENCH", "INSTRUMENT"))
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 1000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 3000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = alterlist(reply->collist,6)
 SET reply->collist[1].header_text = "Organization"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Instrument/Bench/Multiplexor"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Assays Missing Sequencing"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Assays Missing Result Type"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Assays Missing Numeric Ranges"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Assays Missing Alpha Responses"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET request_serv_res->activity_type_code_value = glb_cd
 SET trace = recpersist
 EXECUTE bed_get_service_resource  WITH replace("REQUEST",request_serv_res), replace("REPLY",
  reply_serv_res)
 SET rcnt = size(reply_serv_res->rlist,5)
 CALL echo(build("rcnt:",rcnt))
 IF (rcnt=0)
  GO TO skip_detail
 ENDIF
 SET stat = alterlist(request_sr_detail->service_resources,rcnt)
 FOR (ridx = 1 TO rcnt)
   SET request_sr_detail->service_resources[ridx].code_value = reply_serv_res->rlist[ridx].code_value
 ENDFOR
 SET request_sr_detail->load.sequence_ind = 1
 SET request_sr_detail->load.result_type_ind = 1
 SET request_sr_detail->load.alpha_ind = 1
 SET request_sr_detail->load.numeric_ind = 1
 SET trace = recpersist
 EXECUTE bed_get_sr_detail  WITH replace("REQUEST",request_sr_detail), replace("REPLY",
  reply_sr_detail)
 SET r2cnt = size(reply_sr_detail->service_resources,5)
 CALL echo(build("r2cnt:",r2cnt))
 IF (r2cnt=0)
  SET rcnt = 0
  GO TO skip_detail
 ENDIF
 SET qcnt = 0
 SELECT INTO "nl:"
  sr_disp = cnvtupper(reply_serv_res->rlist[d.seq].display)
  FROM (dummyt d  WITH seq = r2cnt),
   service_resource sr,
   organization o
  PLAN (d
   WHERE (((reply_sr_detail->service_resources[d.seq].assay_need_seq_ind=1)) OR ((((reply_sr_detail->
   service_resources[d.seq].assay_need_result_type_ind=1)) OR ((((reply_sr_detail->service_resources[
   d.seq].assay_need_alpha_ind=1)) OR ((reply_sr_detail->service_resources[d.seq].
   assay_need_numeric_ind=1))) )) )) )
   JOIN (sr
   WHERE (sr.service_resource_cd=reply_sr_detail->service_resources[d.seq].code_value))
   JOIN (o
   WHERE o.organization_id=outerjoin(sr.organization_id))
  ORDER BY o.org_name_key, sr_disp
  DETAIL
   qcnt = (qcnt+ 1), stat = alterlist(temp->qual,qcnt), temp->qual[qcnt].org_id = sr.organization_id,
   temp->qual[qcnt].org_disp = o.org_name, temp->qual[qcnt].code_value = reply_sr_detail->
   service_resources[d.seq].code_value, temp->qual[qcnt].display = reply_serv_res->rlist[d.seq].
   display,
   temp->qual[qcnt].assay_need_seq_ind = reply_sr_detail->service_resources[d.seq].assay_need_seq_ind,
   temp->qual[qcnt].assay_need_result_type_ind = reply_sr_detail->service_resources[d.seq].
   assay_need_result_type_ind, temp->qual[qcnt].assay_need_numeric_ind = reply_sr_detail->
   service_resources[d.seq].assay_need_numeric_ind,
   temp->qual[qcnt].assay_need_alpha_ind = reply_sr_detail->service_resources[d.seq].
   assay_need_alpha_ind
  WITH nocounter
 ;end select
 CALL echo(build("qcnt:",qcnt))
 IF (qcnt=0)
  GO TO skip_detail
 ENDIF
 SET row_nbr = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = qcnt)
  PLAN (d)
  DETAIL
   row_nbr = (row_nbr+ 1), stat = alterlist(reply->rowlist,row_nbr), stat = alterlist(reply->rowlist[
    row_nbr].celllist,6),
   reply->rowlist[row_nbr].celllist[1].string_value = temp->qual[d.seq].org_disp, reply->rowlist[
   row_nbr].celllist[2].string_value = temp->qual[d.seq].display
   IF ((temp->qual[d.seq].assay_need_seq_ind=1))
    reply->rowlist[row_nbr].celllist[3].string_value = "X"
   ELSE
    reply->rowlist[row_nbr].celllist[3].string_value = " "
   ENDIF
   IF ((temp->qual[d.seq].assay_need_result_type_ind=1))
    reply->rowlist[row_nbr].celllist[4].string_value = "X", need_result_type_cnt = (
    need_result_type_cnt+ 1)
   ELSE
    reply->rowlist[row_nbr].celllist[4].string_value = " "
   ENDIF
   IF ((temp->qual[d.seq].assay_need_numeric_ind=1))
    reply->rowlist[row_nbr].celllist[5].string_value = "X", need_numeric_cnt = (need_numeric_cnt+ 1)
   ELSE
    reply->rowlist[row_nbr].celllist[5].string_value = " "
   ENDIF
   IF ((temp->qual[d.seq].assay_need_alpha_ind=1))
    reply->rowlist[row_nbr].celllist[6].string_value = "X", need_alpha_cnt = (need_alpha_cnt+ 1)
   ELSE
    reply->rowlist[row_nbr].celllist[6].string_value = " "
   ENDIF
  WITH nocounter
 ;end select
#skip_detail
 IF (((need_result_type_cnt > 0) OR (((need_alpha_cnt > 0) OR (need_numeric_cnt > 0)) )) )
  SET reply->run_status_flag = 3
 ELSE
  SET reply->run_status_flag = 1
 ENDIF
 SET stat = alterlist(reply->statlist,3)
 SET reply->statlist[1].statistic_meaning = "GLASSAYNEEDRESTYPE"
 SET reply->statlist[1].total_items = rcnt
 SET reply->statlist[1].qualifying_items = need_result_type_cnt
 IF (need_result_type_cnt > 0)
  SET reply->statlist[1].status_flag = 3
 ELSE
  SET reply->statlist[1].status_flag = 1
 ENDIF
 SET reply->statlist[2].statistic_meaning = "GLASSAYNEEDALPHA"
 SET reply->statlist[2].total_items = rcnt
 SET reply->statlist[2].qualifying_items = need_alpha_cnt
 IF (need_alpha_cnt > 0)
  SET reply->statlist[2].status_flag = 3
 ELSE
  SET reply->statlist[2].status_flag = 1
 ENDIF
 SET reply->statlist[3].statistic_meaning = "GLASSAYNEEDNUM"
 SET reply->statlist[3].total_items = rcnt
 SET reply->statlist[3].qualifying_items = need_numeric_cnt
 IF (need_numeric_cnt > 0)
  SET reply->statlist[3].status_flag = 3
 ELSE
  SET reply->statlist[3].status_flag = 1
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("incmplt_gl_assay_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
