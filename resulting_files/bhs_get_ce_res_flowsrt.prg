CREATE PROGRAM bhs_get_ce_res_flowsrt
 RECORD results_pt_info(
   1 person_id = f8
   1 encntr_id = f8
 ) WITH persist
 IF (cnvtreal(parameter(1,0)) > 0.00)
  SET results_pt_info->person_id = cnvtreal( $1)
 ENDIF
 IF (cnvtreal(parameter(2,0)) > 0.00)
  SET results_pt_info->encntr_id = cnvtreal( $2)
 ENDIF
 IF (((results_pt_info->person_id+ results_pt_info->encntr_id) <= 0.00))
  CALL echo("no valid person_id or encntr_id given. exiting script")
  GO TO exit_script
 ENDIF
 FREE RECORD result_info
 RECORD result_info(
   1 beg_search_dt = c20
   1 end_search_dt = c20
   1 max_es_cnt = i4
   1 max_r_cnt = i4
   1 max_d_cnt = i4
   1 es_cnt = i4
   1 event_sets[*]
     2 event_set_disp_key = vc
     2 event_set_cd = f8
     2 event_set_disp = vc
   1 d_cnt = i4
   1 dates[*]
     2 date_time = c16
     2 max_res_date = i4
     2 r_cnt = i4
     2 results[*]
       3 event_set_slot = i4
       3 display = vc
       3 value = vc
       3 coll_seq = i4
 ) WITH persist
 DECLARE tmp_str = vc
 IF (reflect(parameter(3,0)) > " ")
  SET tmp_str = trim(build(parameter(3,0)),3)
  IF (uar_get_code_by("displaykey",93,tmp_str) > 0.00)
   SET stat = alterlist(result_info->event_sets,1)
   SET result_info->es_cnt = 1
   IF ((result_info->max_es_cnt < result_info->es_cnt))
    SET result_info->max_es_cnt = result_info->es_cnt
   ENDIF
   SET result_info->event_sets[1].event_set_disp_key = tmp_str
   SET result_info->event_sets[1].event_set_cd = uar_get_code_by("DISPLAYKEY",93,tmp_str)
   SET result_info->event_sets[1].event_set_disp = cnvtcap(cnvtlower(uar_get_code_display(result_info
      ->event_sets[1].event_set_cd)))
  ENDIF
 ELSE
  CALL echo("Multiple slots in parameter 3")
  DECLARE tmp_slot = i4 WITH noconstant(1)
  WHILE (reflect(parameter(3,tmp_slot)) > " ")
    SET tmp_str = trim(build(parameter(3,tmp_slot)),3)
    IF (uar_get_code_by("DISPLAYKEY",93,tmp_str) > 0.00)
     SET result_info->es_cnt = (result_info->es_cnt+ 1)
     IF ((result_info->max_es_cnt < result_info->es_cnt))
      SET result_info->max_es_cnt = result_info->es_cnt
     ENDIF
     SET stat = alterlist(result_info->event_sets,result_info->es_cnt)
     SET result_info->event_sets[result_info->es_cnt].event_set_disp_key = tmp_str
     SET result_info->event_sets[result_info->es_cnt].event_set_cd = uar_get_code_by("DISPLAYKEY",93,
      tmp_str)
    ENDIF
    SET tmp_slot = (tmp_slot+ 1)
  ENDWHILE
  FREE SET tmp_slot
 ENDIF
 FREE SET tmp_str
 IF ((result_info->es_cnt <= 0))
  CALL echo("No event sets passed in. Exiting Script")
  GO TO exit_script
 ENDIF
 IF (reflect(parameter(4,0)) > " ")
  IF (cnvtint(parameter(4,0))=0)
   CALL echo("Using 0 days back as begin search range")
   SET result_info->beg_search_dt = format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d")
  ELSE
   SET result_info->beg_search_dt = format(cnvtdatetime((curdate - abs(cnvtint(parameter(4,0)))),
     curtime3),"DD-MMM-YYYY HH:MM:SS;;D")
  ENDIF
 ELSE
  CALL echo("Using 0 days back as begin search range")
  SET result_info->beg_search_dt = format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d")
 ENDIF
 IF (reflect(parameter(4,0)) > " ")
  IF (cnvtint(parameter(5,0))=0)
   CALL echo("Using 0 days forward as end search range")
   SET result_info->end_search_dt = format(cnvtdatetime(curdate,235959),"DD-MMM-YYYY HH:MM:SS;;D")
  ELSE
   SET result_info->end_search_dt = format(cnvtdatetime((curdate+ abs(cnvtint(parameter(5,0)))),
     235959),"DD-MMM-YYYY HH:MM:SS;;D")
  ENDIF
 ELSE
  CALL echo("using 0 days forward as end search range")
  SET result_info->end_search_dt = format(cnvtdatetime(curdate,235959),"DD-MMM-YYYY HH:MM:SS;;D")
 ENDIF
 SELECT INTO "nl:"
  sort_dt_tm = format(ce.event_end_dt_tm,"yyyymmddhhmm;;d")
  FROM (dummyt d  WITH seq = value(result_info->es_cnt)),
   v500_event_set_explode vese,
   clinical_event ce,
   v500_event_set_canon vec
  PLAN (d)
   JOIN (ce
   WHERE (ce.encntr_id=results_pt_info->encntr_id)
    AND ce.event_end_dt_tm BETWEEN cnvtdatetime(result_info->beg_search_dt) AND cnvtdatetime(
    result_info->end_search_dt)
    AND ce.view_level=1
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (vese
   WHERE vese.event_cd=ce.event_cd
    AND vese.event_set_level=0)
   JOIN (vec
   WHERE vese.event_set_cd=vec.event_set_cd
    AND (vec.parent_event_set_cd=result_info->event_sets[d.seq].event_set_cd))
  ORDER BY vec.event_set_collating_seq, sort_dt_tm DESC
  HEAD REPORT
   d_cnt = 0, r_cnt = 0, d_cnt = (result_info->d_cnt+ 1),
   stat = alterlist(result_info->dates,d_cnt), result_info->d_cnt = d_cnt
  HEAD vec.event_set_collating_seq
   result_info->dates[d_cnt].date_time = format(ce.event_end_dt_tm,"mm/dd/yyyy hh:mm;;d"), r_cnt = (
   result_info->dates[d_cnt].r_cnt+ 1), stat = alterlist(result_info->dates[d_cnt].results,r_cnt),
   result_info->dates[d_cnt].r_cnt = r_cnt
   IF ((result_info->max_r_cnt < result_info->dates[d_cnt].r_cnt))
    result_info->max_r_cnt = result_info->dates[d_cnt].r_cnt
   ENDIF
   IF ((result_info->dates[d_cnt].max_res_date < result_info->dates[d_cnt].r_cnt))
    result_info->dates[d_cnt].max_res_date = result_info->dates[d_cnt].r_cnt
   ENDIF
   result_info->dates[d_cnt].results[r_cnt].event_set_slot = d.seq, result_info->dates[d_cnt].
   results[r_cnt].display = ce.event_title_text, result_info->dates[d_cnt].results[r_cnt].coll_seq =
   vec.event_set_collating_seq
   IF (ce.result_units_cd > 0.00)
    result_info->dates[d_cnt].results[r_cnt].value = build2(trim(ce.result_val,3)," ",
     uar_get_code_display(ce.result_units_cd))
   ELSE
    result_info->dates[d_cnt].results[r_cnt].value = trim(ce.result_val,3)
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(result_info)
#exit_script
END GO
