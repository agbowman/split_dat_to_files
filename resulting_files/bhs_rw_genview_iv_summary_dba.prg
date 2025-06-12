CREATE PROGRAM bhs_rw_genview_iv_summary:dba
 DECLARE output_var = vc WITH protect, noconstant("")
 IF (validate(request->visit[1].encntr_id,0.00) <= 0.00
  AND cnvtreal(parameter(2,0)) <= 0.00)
  CALL echo("No encntr_id given. Exiting Script")
  GO TO exit_script
 ELSEIF (cnvtreal(parameter(2,0)) > 0.00)
  RECORD request(
    1 output_device = vc
    1 script_name = vc
    1 person_cnt = i4
    1 person[*]
      2 person_id = f8
    1 visit_cnt = i4
    1 visit[*]
      2 encntr_id = f8
    1 prsnl_cnt = i4
    1 prsnl[*]
      2 prsnl_id = f8
    1 nv_cnt = i4
    1 nv[*]
      2 pvc_name = vc
      2 pvc_value = vc
    1 batch_selection = vc
  ) WITH protect
  SET output_var = trim(build( $1),3)
  SET request->visit_cnt = 1
  CALL alterlist(request->visit,1)
  SET request->visit[1].encntr_id = cnvtreal( $2)
 ELSE
  SET output_var = " "
 ENDIF
 IF (validate(reply->status_data.status,"A")="A"
  AND validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 text = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  ) WITH protect
 ENDIF
 SET reply->status_data.status = "F"
 FREE RECORD work
 RECORD work(
   1 sites[4]
     2 cs72_ivsite_cd = f8
     2 cs72_insertion_cd = f8
     2 cs72_catheter_type_cd = f8
     2 cs72_iv_gauge_cd = f8
     2 cs72_discontinued_cd = f8
     2 ivsite = vc
     2 ivsite_dt_tm = dq8
     2 insertion_dt_tm = dq8
     2 insert_chart_dt_tm = dq8
     2 catheter_type = vc
     2 catheter_chart_dt_tm = dq8
     2 iv_gauge = vc
     2 iv_gauge_dt_tm = dq8
     2 discontinued = vc
     2 discontinued_dt_tm = dq8
 ) WITH protect
 DECLARE cs8_inerror_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"INERROR"))
 SET work->sites[1].cs72_ivsite_cd = uar_get_code_by("DISPLAYKEY",72,"IVSITEI")
 SET work->sites[1].cs72_insertion_cd = uar_get_code_by("DISPLAYKEY",72,"DATETIMEOFINSERTIONACCESSI")
 SET work->sites[1].cs72_catheter_type_cd = uar_get_code_by("DISPLAYKEY",72,"CATHETERTYPEI")
 SET work->sites[1].cs72_iv_gauge_cd = uar_get_code_by("DISPLAYKEY",72,"IVGAUGEI")
 SET work->sites[1].cs72_discontinued_cd = uar_get_code_by("DISPLAYKEY",72,"DISCONTINUEREASONI")
 SET work->sites[2].cs72_ivsite_cd = uar_get_code_by("DISPLAYKEY",72,"IVSITEII")
 SET work->sites[2].cs72_insertion_cd = uar_get_code_by("DISPLAYKEY",72,"DATETIMEOFINSERTIONACCESSII"
  )
 SET work->sites[2].cs72_catheter_type_cd = uar_get_code_by("DISPLAYKEY",72,"CATHETERTYPEII")
 SET work->sites[2].cs72_iv_gauge_cd = uar_get_code_by("DISPLAYKEY",72,"IVGAUGEII")
 SET work->sites[2].cs72_discontinued_cd = uar_get_code_by("DISPLAYKEY",72,"DISCONTINUEREASONII")
 SET work->sites[3].cs72_ivsite_cd = uar_get_code_by("DISPLAYKEY",72,"IVSITEIII")
 SET work->sites[3].cs72_insertion_cd = uar_get_code_by("DISPLAYKEY",72,
  "DATETIMEOFINSERTIONACCESSIII")
 SET work->sites[3].cs72_catheter_type_cd = uar_get_code_by("DISPLAYKEY",72,"CATHETERTYPEIII")
 SET work->sites[3].cs72_iv_gauge_cd = uar_get_code_by("DISPLAYKEY",72,"IVGAUGEIII")
 SET work->sites[3].cs72_discontinued_cd = uar_get_code_by("DISPLAYKEY",72,"DISCONTINUEREASONIII")
 SET work->sites[4].cs72_ivsite_cd = uar_get_code_by("DISPLAYKEY",72,"IVSITEIV")
 SET work->sites[4].cs72_insertion_cd = uar_get_code_by("DISPLAYKEY",72,"DATETIMEOFINSERTIONACCESSIV"
  )
 SET work->sites[4].cs72_catheter_type_cd = uar_get_code_by("DISPLAYKEY",72,"CATHETERTYPEIV")
 SET work->sites[4].cs72_iv_gauge_cd = uar_get_code_by("DISPLAYKEY",72,"IVGAUGEIV")
 SET work->sites[4].cs72_discontinued_cd = uar_get_code_by("DISPLAYKEY",72,"DISCONTINUEREASONIV")
 SELECT INTO "NL:"
  ce.event_cd
  FROM clinical_event ce,
   ce_date_result cdr
  PLAN (ce
   WHERE (ce.encntr_id=request->visit[1].encntr_id)
    AND ce.view_level=1
    AND ce.publish_flag=1
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ce.result_status_cd != cs8_inerror_cd
    AND ce.event_cd IN (work->sites[1].cs72_ivsite_cd, work->sites[1].cs72_insertion_cd, work->sites[
   1].cs72_catheter_type_cd, work->sites[1].cs72_iv_gauge_cd, work->sites[1].cs72_discontinued_cd,
   work->sites[2].cs72_ivsite_cd, work->sites[2].cs72_insertion_cd, work->sites[2].
   cs72_catheter_type_cd, work->sites[2].cs72_iv_gauge_cd, work->sites[2].cs72_discontinued_cd,
   work->sites[3].cs72_ivsite_cd, work->sites[3].cs72_insertion_cd, work->sites[3].
   cs72_catheter_type_cd, work->sites[3].cs72_iv_gauge_cd, work->sites[3].cs72_discontinued_cd,
   work->sites[4].cs72_ivsite_cd, work->sites[4].cs72_insertion_cd, work->sites[4].
   cs72_catheter_type_cd, work->sites[4].cs72_iv_gauge_cd, work->sites[4].cs72_discontinued_cd))
   JOIN (cdr
   WHERE outerjoin(ce.event_id)=cdr.event_id
    AND ce.valid_until_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
  ORDER BY ce.event_cd, ce.event_end_dt_tm DESC, 0
  HEAD ce.event_cd
   CASE (ce.event_cd)
    OF work->sites[1].cs72_ivsite_cd:
     IF (trim(work->sites[1].ivsite,3) <= " ")
      work->sites[1].ivsite = trim(ce.result_val,3), work->sites[1].ivsite_dt_tm = ce.event_end_dt_tm
     ENDIF
    OF work->sites[1].cs72_insertion_cd:
     IF ((work->sites[1].insertion_dt_tm <= 0.00))
      work->sites[1].insertion_dt_tm = cdr.result_dt_tm, work->sites[1].insert_chart_dt_tm = ce
      .event_end_dt_tm
     ENDIF
    OF work->sites[1].cs72_catheter_type_cd:
     IF (trim(work->sites[1].catheter_type,3) <= " ")
      work->sites[1].catheter_type = trim(ce.result_val,3), work->sites[1].catheter_chart_dt_tm = ce
      .event_end_dt_tm
     ENDIF
    OF work->sites[1].cs72_iv_gauge_cd:
     IF (trim(work->sites[1].iv_gauge,3) <= " ")
      work->sites[1].iv_gauge = trim(ce.result_val,3), work->sites[1].iv_gauge_dt_tm = ce
      .event_end_dt_tm
     ENDIF
    OF work->sites[1].cs72_discontinued_cd:
     IF (trim(work->sites[1].discontinued,3) <= " ")
      work->sites[1].discontinued = trim(ce.result_val,3), work->sites[1].discontinued_dt_tm = ce
      .event_end_dt_tm
     ENDIF
    OF work->sites[2].cs72_ivsite_cd:
     IF (trim(work->sites[2].ivsite,3) <= " ")
      work->sites[2].ivsite = trim(ce.result_val,3), work->sites[2].ivsite_dt_tm = ce.event_end_dt_tm
     ENDIF
    OF work->sites[2].cs72_insertion_cd:
     IF ((work->sites[2].insertion_dt_tm <= 0.00))
      work->sites[2].insertion_dt_tm = cdr.result_dt_tm, work->sites[2].insert_chart_dt_tm = ce
      .event_end_dt_tm
     ENDIF
    OF work->sites[2].cs72_catheter_type_cd:
     IF (trim(work->sites[2].catheter_type,3) <= " ")
      work->sites[2].catheter_type = trim(ce.result_val,3), work->sites[2].catheter_chart_dt_tm = ce
      .event_end_dt_tm
     ENDIF
    OF work->sites[2].cs72_iv_gauge_cd:
     IF (trim(work->sites[2].iv_gauge,3) <= " ")
      work->sites[2].iv_gauge = trim(ce.result_val,3), work->sites[2].iv_gauge_dt_tm = ce
      .event_end_dt_tm
     ENDIF
    OF work->sites[2].cs72_discontinued_cd:
     IF (trim(work->sites[2].discontinued,3) <= " ")
      work->sites[2].discontinued = trim(ce.result_val,3), work->sites[2].discontinued_dt_tm = ce
      .event_end_dt_tm
     ENDIF
    OF work->sites[3].cs72_ivsite_cd:
     IF (trim(work->sites[3].ivsite,3) <= " ")
      work->sites[3].ivsite = trim(ce.result_val,3), work->sites[3].ivsite_dt_tm = ce.event_end_dt_tm
     ENDIF
    OF work->sites[3].cs72_insertion_cd:
     IF ((work->sites[3].insertion_dt_tm <= 0.00))
      work->sites[3].insertion_dt_tm = cdr.result_dt_tm, work->sites[3].insert_chart_dt_tm = ce
      .event_end_dt_tm
     ENDIF
    OF work->sites[3].cs72_catheter_type_cd:
     IF (trim(work->sites[3].catheter_type,3) <= " ")
      work->sites[3].catheter_type = trim(ce.result_val,3), work->sites[3].catheter_chart_dt_tm = ce
      .event_end_dt_tm
     ENDIF
    OF work->sites[3].cs72_iv_gauge_cd:
     IF (trim(work->sites[3].iv_gauge,3) <= " ")
      work->sites[3].iv_gauge = trim(ce.result_val,3), work->sites[3].iv_gauge_dt_tm = ce
      .event_end_dt_tm
     ENDIF
    OF work->sites[3].cs72_discontinued_cd:
     IF (trim(work->sites[3].discontinued,3) <= " ")
      work->sites[3].discontinued = trim(ce.result_val,3), work->sites[3].discontinued_dt_tm = ce
      .event_end_dt_tm
     ENDIF
    OF work->sites[4].cs72_ivsite_cd:
     IF (trim(work->sites[4].ivsite,3) <= " ")
      work->sites[4].ivsite = trim(ce.result_val,3), work->sites[4].ivsite_dt_tm = ce.event_end_dt_tm
     ENDIF
    OF work->sites[4].cs72_insertion_cd:
     IF ((work->sites[4].insertion_dt_tm <= 0.00))
      work->sites[4].insertion_dt_tm = cdr.result_dt_tm, work->sites[4].insert_chart_dt_tm = ce
      .event_end_dt_tm
     ENDIF
    OF work->sites[4].cs72_catheter_type_cd:
     IF (trim(work->sites[4].catheter_type,3) <= " ")
      work->sites[4].catheter_type = trim(ce.result_val,3), work->sites[4].catheter_chart_dt_tm = ce
      .event_end_dt_tm
     ENDIF
    OF work->sites[4].cs72_iv_gauge_cd:
     IF (trim(work->sites[4].iv_gauge,3) <= " ")
      work->sites[4].iv_gauge = trim(ce.result_val,3), work->sites[4].iv_gauge_dt_tm = ce
      .event_end_dt_tm
     ENDIF
    OF work->sites[4].cs72_discontinued_cd:
     IF (trim(work->sites[4].discontinued,3) <= " ")
      work->sites[4].discontinued = trim(ce.result_val,3), work->sites[4].discontinued_dt_tm = ce
      .event_end_dt_tm
     ENDIF
   ENDCASE
  WITH nocounter
 ;end select
 SET beg_rtf = "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Tahoma;}} \f0\fs18"
 SET end_rtf = "}"
 SET beg_bold = "\b"
 SET end_bold = "\b0"
 SET beg_uline = "\ul"
 SET end_uline = "\ulnone"
 SET beg_ital = "\i"
 SET end_ital = "\i0"
 SET new_line = concat(char(10),char(13))
 SET end_line = "\par"
 CALL echorecord(work,output_var)
 SET reply->text = build2(beg_rtf,"    ",beg_bold,beg_uline," IV Insertion Summary",
  end_bold,end_uline,end_line,new_line)
 FOR (s = 1 TO 4)
   IF ((((work->sites[s].insertion_dt_tm > work->sites[s].discontinued_dt_tm)) OR ((work->sites[s].
   ivsite_dt_tm <= 0.00))) )
    SET work->sites[s].discontinued = " "
    SET work->sites[s].discontinued_dt_tm = 0.00
   ENDIF
   SET reply->text = build2(reply->text,end_line,new_line,beg_bold," ",
    trim(uar_get_code_display(work->sites[s].cs72_ivsite_cd),3),":",end_bold,"  ",trim(work->sites[s]
     .ivsite,3))
   SET reply->text = build2(reply->text,end_line,new_line,beg_bold," ",
    trim(uar_get_code_display(work->sites[s].cs72_insertion_cd),3),":",end_bold,"  ",format(work->
     sites[s].insertion_dt_tm,"@SHORTDATETIME"))
   SET reply->text = build2(reply->text,end_line,new_line,beg_bold," ",
    trim(uar_get_code_display(work->sites[s].cs72_catheter_type_cd),3),":",end_bold,"  ",trim(work->
     sites[s].catheter_type,3))
   SET reply->text = build2(reply->text,end_line,new_line,beg_bold," ",
    trim(uar_get_code_display(work->sites[s].cs72_iv_gauge_cd),3),":",end_bold,"  ",trim(work->sites[
     s].iv_gauge,3))
   SET reply->text = build2(reply->text,end_line,new_line,beg_bold," ",
    trim(uar_get_code_display(work->sites[s].cs72_discontinued_cd),3),":",end_bold,"  ",format(work->
     sites[s].discontinued_dt_tm,"@SHORTDATETIME"),
    " ",trim(work->sites[s].discontinued,3))
   IF (s < 4)
    SET reply->text = build2(reply->text,end_line,new_line,
     "__________________________________________________________",end_line,
     new_line)
   ENDIF
 ENDFOR
 SET reply->text = build2(reply->text,end_rtf)
 SET reply->status_data.status = "S"
 IF (trim(output_var,3) > " "
  AND size(reply->text) > 0)
  SELECT INTO value(output_var)
   FROM dummyt d
   HEAD REPORT
    cur_spot = 1, next_spot = findstring(end_line,reply->text,1,0), loop_cnt = 0
   DETAIL
    WHILE (cur_spot < size(reply->text)
     AND next_spot > 0
     AND loop_cnt < 50)
      next_spot = (next_spot+ 6), row + 1, col 0,
      CALL print(substring(cur_spot,((next_spot - cur_spot) - 1),reply->text)), cur_spot = next_spot,
      next_spot = findstring(end_line,reply->text,cur_spot,0),
      loop_cnt = (loop_cnt+ 1)
    ENDWHILE
    row + 1, col 0,
    CALL print(substring(cur_spot,((size(reply->text) - cur_spot)+ 1),reply->text))
   WITH append, nocounter, maxcol = 32000
  ;end select
 ENDIF
#exit_script
 FREE RECORD work
END GO
