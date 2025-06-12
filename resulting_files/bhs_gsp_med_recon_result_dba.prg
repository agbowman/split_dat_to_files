CREATE PROGRAM bhs_gsp_med_recon_result:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 output_device = vc
    1 script_name = vc
    1 person_cnt = i4
    1 person[*]
      2 person_id = f8
    1 visit_cnt = i4
    1 visit[1]
      2 encntr_id = f8
    1 prsnl_cnt = i4
    1 prsnl[*]
      2 prsnl_id = f8
    1 nv_cnt = i4
    1 nv[*]
      2 pvc_name = vc
      2 pvc_value = vc
    1 batch_selection = vc
  )
  SET request->visit[1].encntr_id = 408392854
  SET request->output_device = "MINE"
  SET request->visit_cnt = 1
 ENDIF
 DECLARE cnt = i4
 FREE RECORD mmr
 RECORD mmr(
   1 res_cnt = i4
   1 enc[*]
     2 time_stmp = vc
     2 form = vc
     2 mrr_res = vc
     2 per_chart = vc
 )
 RECORD reply(
   1 spread_type = i2
   1 report_title = vc
   1 grid_lines_ind = i2
   1 col_cnt = i2
   1 col[*]
     2 header = vc
     2 width = i2
     2 type = i2
     2 wrap_ind = i2
   1 row_cnt = i2
   1 row[*]
     2 keyl[*]
       3 key_type = i2
       3 key_id = f8
     2 col[*]
       3 data_string = vc
       3 data_double = f8
       3 data_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET form1 = uar_get_code_by("DISPLAYKEY",72,"MEDRECONCILIATION")
 SET form2 = uar_get_code_by("DISPLAYKEY",72,"HOMEMEDICATIONREVIEW")
 SET form3 = uar_get_code_by("DISPLAYKEY",72,"MEDRECONCILIATIONADMIT")
 SET form4 = uar_get_code_by("DISPLAYKEY",72,"MEDRECONCILIATIONTRANSFER")
 SET form5 = uar_get_code_by("DISPLAYKEY",72,"MEDRECONCILIATIONDISCHARGE")
 SELECT INTO "nl:"
  c_event_disp = uar_get_code_display(c.event_cd), c.result_val, p.name_full_formatted,
  time_stamp = format(c.updt_dt_tm,"mm/dd/yyyy hh:mm;;d")
  FROM clinical_event c,
   prsnl p
  PLAN (c
   WHERE (request->visit[1].encntr_id=c.encntr_id)
    AND c.event_cd IN (form1, form2, form3, form4, form5))
   JOIN (p
   WHERE c.updt_id=p.person_id)
  ORDER BY c.updt_dt_tm
  HEAD REPORT
   cnt = 0, stat = alterlist(mmr->enc,10)
  HEAD c.event_id
   cnt = (cnt+ 1), mmr->res_cnt = cnt
   IF (mod(cnt,10)=1)
    stat = alterlist(mmr->enc,(cnt+ 10))
   ENDIF
  DETAIL
   mmr->enc[cnt].time_stmp = trim(time_stamp), mmr->enc[cnt].form = trim(c_event_disp), mmr->enc[cnt]
   .mrr_res = trim(c.result_val),
   mmr->enc[cnt].per_chart = trim(p.name_full_formatted)
  FOOT REPORT
   stat = alterlist(mmr->enc,cnt), mmr->res_cnt = cnt
 ;end select
 SET col_cnt = 4
 SET reply->col_cnt = col_cnt
 SET stat = alterlist(reply->col,col_cnt)
 SET reply->col[1].header = "Powerform"
 SET reply->col[1].width = 130
 SET reply->col[1].wrap_ind = 1
 SET reply->col[2].header = "Result"
 SET reply->col[2].width = 100
 SET reply->col[2].wrap_ind = 1
 SET reply->col[3].header = "Charted By"
 SET reply->col[3].width = 160
 SET reply->col[3].wrap_ind = 1
 SET reply->col[4].header = "Date/Time"
 SET reply->col[4].width = 130
 SET reply->col[4].wrap_ind = 1
 SET reply->report_title = "Medication Reconciliation History"
 SET reply->grid_lines_ind = 3
 FOR (i = 1 TO size(mmr->enc,5))
   SET reply->row_cnt = i
   SET stat = alterlist(reply->row,i)
   SET stat = alterlist(reply->row[i].col,4)
   SET reply->row[i].col[1].data_string = mmr->enc[i].form
   SET reply->row[i].col[2].data_string = mmr->enc[i].mrr_res
   SET reply->row[i].col[3].data_string = mmr->enc[i].per_chart
   SET reply->row[i].col[4].data_string = mmr->enc[i].time_stmp
 ENDFOR
 CALL echorecord(mmr,"jpf_mmr")
 CALL echorecord(reply,"jpf_reply")
 SET reply->status_data.status = "S"
END GO
