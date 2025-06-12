CREATE PROGRAM bhs_rw_iv_end_by_pl
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Facility" = 0,
  "Patient Location" = 0,
  "Enter Begin Date" = "SYSDATE",
  "Enter End Date" = "SYSDATE"
  WITH outdev, org, loc_cd,
  beg_dt_tm, end_dt_tm
 IF (datetimediff(cnvtdatetime( $END_DT_TM),cnvtdatetime( $BEG_DT_TM)) > 7)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   DETAIL
    row 20, col 5, "Date range cannot be greater than 7. Please reduce your date/range"
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM location l
  WHERE l.location_cd=cnvtreal( $LOC_CD)
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   DETAIL
    row 20, col 5, "Invalid location(s) selected"
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 RECORD rw_work(
   1 pass_cnt = i4
   1 e_cnt = i4
   1 encntrs[*]
     2 encntr_id = f8
     2 pass_ind = i2
 )
 SELECT DISTINCT INTO "NL:"
  ce.encntr_id
  FROM clinical_event ce
  PLAN (ce
   WHERE ce.clinsig_updt_dt_tm BETWEEN cnvtdatetime( $BEG_DT_TM) AND cnvtdatetime( $END_DT_TM)
    AND ((ce.event_end_dt_tm+ 0) BETWEEN cnvtdatetime( $BEG_DT_TM) AND cnvtdatetime( $END_DT_TM))
    AND ((ce.event_class_cd=value(uar_get_code_by("MEANING",53,"MED"))) OR (ce.event_cd=value(
    uar_get_code_by("DISPLAYKEY",72,"IVPBENDORTRANSFERDATETIME"))))
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND ce.view_level=1
    AND  EXISTS (
   (SELECT
    e.encntr_id
    FROM encounter e
    WHERE ce.encntr_id=e.encntr_id
     AND e.active_ind=1))
    AND  EXISTS (
   (SELECT
    p.person_id
    FROM person p
    WHERE ce.person_id=p.person_id
     AND p.active_ind=1)))
  ORDER BY ce.encntr_id
  HEAD ce.encntr_id
   rw_work->e_cnt = (rw_work->e_cnt+ 1), stat = alterlist(rw_work->encntrs,rw_work->e_cnt), rw_work->
   encntrs[rw_work->e_cnt].encntr_id = ce.encntr_id
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  rw_work->encntrs[d.seq].encntr_id
  FROM (dummyt d  WITH seq = value(rw_work->e_cnt)),
   encntr_loc_hist elh
  PLAN (d)
   JOIN (elh
   WHERE (rw_work->encntrs[d.seq].encntr_id=elh.encntr_id)
    AND elh.beg_effective_dt_tm <= cnvtdatetime( $END_DT_TM)
    AND elh.end_effective_dt_tm >= cnvtdatetime( $BEG_DT_TM)
    AND ((elh.loc_nurse_unit_cd+ 0)=cnvtreal( $LOC_CD)))
  HEAD d.seq
   rw_work->encntrs[d.seq].pass_ind = 1, rw_work->pass_cnt = (rw_work->pass_cnt+ 1)
  FOOT REPORT
   CALL echo(build2("Pass Count = ",rw_work->pass_cnt))
  WITH nocounter, nullreport
 ;end select
 IF ((rw_work->pass_cnt <= 0))
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   DETAIL
    row 20, col 5, "No encounters for selected date range/location."
   WITH nocounter
  ;end select
  GO TO exit_script
 ELSEIF ((rw_work->pass_cnt > 500))
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   DETAIL
    row 20, col 5,
    "Too many encounters qualified. Please reduce your date/range or number of locations"
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 FREE RECORD rw_request
 RECORD rw_request(
   1 output_device = vc
   1 script_name = vc
   1 person_cnt = i4
   1 person[*]
     2 person_id = f8
   1 visit_cnt = i4
   1 visit[*]
     2 encntr_id = f8
     2 sort_order = i4
   1 prsnl_cnt = i4
   1 prsnl[*]
     2 prsnl_id = f8
   1 nv_cnt = i4
   1 nv[*]
     2 pvc_name = vc
     2 pvc_value = vc
   1 batch_selection = vc
 )
 SET rw_request->output_device =  $OUTDEV
 SET rw_request->prsnl_cnt = 1
 SET stat = alterlist(rw_request->prsnl,1)
 SET rw_request->prsnl[1].prsnl_id = reqinfo->updt_id
 FOR (v = 1 TO rw_work->e_cnt)
   IF ((rw_work->encntrs[v].pass_ind=1))
    SET rw_request->visit_cnt = (rw_request->visit_cnt+ 1)
    SET stat = alterlist(rw_request->visit,rw_request->visit_cnt)
    SET rw_request->visit[rw_request->visit_cnt].encntr_id = rw_work->encntrs[v].encntr_id
   ENDIF
 ENDFOR
 SET rw_request->nv_cnt = 2
 SET stat = alterlist(rw_request->nv,2)
 SET rw_request->nv[1].pvc_name = "BEG_DT_TM"
 SET rw_request->nv[1].pvc_value =  $BEG_DT_TM
 SET rw_request->nv[2].pvc_name = "END_DT_TM"
 SET rw_request->nv[2].pvc_value =  $END_DT_TM
 EXECUTE bhs_rw_iv_end_report  WITH replace(request,rw_request)
#exit_script
 DECLARE errmsg = c130
 DECLARE errcode = i4 WITH noconstant(error(errmsg,1))
 IF (errcode != 0)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   DETAIL
    row 5, col 0, "1 ERRORS:",
    row + 1
    WHILE (errcode != 0)
      row + 1, col 0, errmsg,
      errcode = error(errmsg,0)
    ENDWHILE
   WITH nocounter, append
  ;end select
 ENDIF
END GO
