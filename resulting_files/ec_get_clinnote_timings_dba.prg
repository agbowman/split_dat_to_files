CREATE PROGRAM ec_get_clinnote_timings:dba
 PROMPT
  "Enter Output Directory:" = "MINE",
  "Enter encntr_id       :" = ""
  WITH outdev, encntrid
 DECLARE sprogname = vc WITH noconstant(""), protect
 DECLARE ipos = i4 WITH noconstant(0), protect
 DECLARE ipos2 = i4 WITH noconstant(0), protect
 DECLARE idx = i4 WITH noconstant(0), protect
 IF ( NOT (validate(tabposreply,0)))
  RECORD tabposreply(
    1 qualcnt = i4
    1 qual[*]
      2 tab_name = vc
      2 poscnt = i4
      2 positions[*]
        3 position_cd = f8
        3 position = vc
        3 physiciancnt = i4
        3 usercnt = i4
      2 scriptcnt = i4
      2 scripts[*]
        3 script_name = vc
  )
 ENDIF
 RECORD rpt(
   1 output_device = vc
   1 position_cd = f8
   1 encntr_id = f8
   1 person_id = f8
   1 distinct_clinnotetemp_cnt = i2
   1 distinct_clinnotetemps[*]
     2 program_name = vc
     2 clinnote_name = vc
     2 level = vc
     2 start_tm = f8
     2 stop_tm = f8
     2 duration = f8
 )
 SET rpt->output_device =  $OUTDEV
 SET rpt->encntr_id = cnvtreal( $ENCNTRID)
 SELECT INTO "nl"
  FROM encounter e
  PLAN (e
   WHERE (e.encntr_id=rpt->encntr_id))
  DETAIL
   rpt->person_id = e.person_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("Unable to find encntr_id")
  GO TO exit_script
 ENDIF
 SELECT DISTINCT INTO "nl:"
  cv.definition
  FROM clinical_event ce,
   note_type nt,
   note_type_template_reltn tr,
   clinical_note_template cnt,
   code_value cv
  PLAN (ce
   WHERE ce.updt_dt_tm > cnvtdatetime((curdate - 5),000000)
    AND ce.view_level=1)
   JOIN (nt
   WHERE nt.event_cd=ce.event_cd
    AND nt.data_status_ind=1)
   JOIN (tr
   WHERE (tr.note_type_id=(nt.note_type_id+ 0)))
   JOIN (cnt
   WHERE (cnt.template_id=(tr.template_id+ 0))
    AND cnt.smart_template_cd > 0.0)
   JOIN (cv
   WHERE cv.code_value=cnt.smart_template_cd)
  HEAD REPORT
   cnt = 0
  DETAIL
   sprogname = cnvtupper(cv.definition)
   IF (checkprg(sprogname) > 0)
    cnt = (rpt->distinct_clinnotetemp_cnt+ 1), rpt->distinct_clinnotetemp_cnt = cnt, stat = alterlist
    (rpt->distinct_clinnotetemps,cnt),
    rpt->distinct_clinnotetemps[cnt].program_name = cv.definition, rpt->distinct_clinnotetemps[cnt].
    clinnote_name = cnt.template_name
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(rpt)
 DECLARE i = i2 WITH noconstant(0), private
 FOR (i = 1 TO rpt->distinct_clinnotetemp_cnt)
   FREE RECORD request
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
   )
   FREE RECORD reply
   RECORD reply(
     1 text = vc
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
   SET request->person_cnt = 1
   SET stat = alterlist(request->person,1)
   SET request->person[1].person_id = rpt->person_id
   SET request->visit_cnt = 1
   SET stat = alterlist(request->visit,1)
   SET request->visit[1].encntr_id = rpt->encntr_id
   SET rpt->distinct_clinnotetemps[i].start_tm = curtime3
   CALL parser(build2("execute ",rpt->distinct_clinnotetemps[i].program_name," go"))
   SET rpt->distinct_clinnotetemps[i].stop_tm = curtime3
   SET rpt->distinct_clinnotetemps[i].duration = ((rpt->distinct_clinnotetemps[i].stop_tm - rpt->
   distinct_clinnotetemps[i].start_tm)/ 100)
 ENDFOR
 DECLARE outfile = vc WITH noconstant(""), protect
 IF (cnvtupper( $OUTDEV)="MINE")
  SET outfile = "MINE"
 ELSE
  SET outfile = concat( $OUTDEV,"ec_clinnote_timings.csv")
 ENDIF
 IF ((rpt->distinct_clinnotetemp_cnt > 0))
  SELECT INTO value(outfile)
   encntr_id = rpt->encntr_id, program_name = substring(1,100,rpt->distinct_clinnotetemps[d1.seq].
    program_name), elapsed = rpt->distinct_clinnotetemps[d1.seq].duration
   FROM (dummyt d1  WITH seq = rpt->distinct_clinnotetemp_cnt)
   PLAN (d1)
   ORDER BY cnvtreal(rpt->distinct_clinnotetemps[d1.seq].duration) DESC
   WITH nocounter, pcformat('"',",",1), format = stream,
    noheading
  ;end select
 ENDIF
 IF ((rpt->distinct_clinnotetemp_cnt > 0))
  SELECT INTO "nl:"
   tab_name = rpt->distinct_clinnotetemps[d1.seq].clinnote_name
   FROM (dummyt d1  WITH seq = rpt->distinct_clinnotetemp_cnt)
   PLAN (d1)
   ORDER BY tab_name
   HEAD REPORT
    cnt = 0
   HEAD tab_name
    ipos = locateval(idx,1,tabposreply->qualcnt,rpt->distinct_clinnotetemps[d1.seq].clinnote_name,
     tabposreply->qual[idx].tab_name)
    IF (ipos=0)
     cnt = (tabposreply->qualcnt+ 1), tabposreply->qualcnt = cnt, stat = alterlist(tabposreply->qual,
      cnt),
     tabposreply->qual[cnt].tab_name = rpt->distinct_clinnotetemps[d1.seq].clinnote_name, poscnt = 0
    ELSE
     cnt = ipos
    ENDIF
   DETAIL
    ipos2 = locateval(idx,1,tabposreply->qual[cnt].poscnt,0.0,tabposreply->qual[cnt].positions[idx].
     position_cd)
    IF (ipos2=0)
     poscnt = (tabposreply->qual[cnt].poscnt+ 1), tabposreply->qual[cnt].poscnt = poscnt, stat =
     alterlist(tabposreply->qual[cnt].positions,poscnt),
     tabposreply->qual[cnt].positions[poscnt].position_cd = 0.0, tabposreply->qual[cnt].positions[
     poscnt].position = "", tabposreply->qual[cnt].positions[poscnt].physiciancnt = 0,
     tabposreply->qual[cnt].positions[poscnt].usercnt = - (1)
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((rpt->distinct_clinnotetemp_cnt > 0))
  SELECT INTO "nl:"
   tab_name = rpt->distinct_clinnotetemps[d1.seq].clinnote_name, program_name = rpt->
   distinct_clinnotetemps[d1.seq].program_name
   FROM (dummyt d1  WITH seq = rpt->distinct_clinnotetemp_cnt)
   PLAN (d1)
   ORDER BY tab_name, program_name
   HEAD REPORT
    cnt = 0
   DETAIL
    ipos = locateval(idx,1,tabposreply->qualcnt,rpt->distinct_clinnotetemps[d1.seq].clinnote_name,
     tabposreply->qual[idx].tab_name)
    IF (ipos > 0)
     ipos2 = locateval(idx,1,tabposreply->qual[ipos].scriptcnt,rpt->distinct_clinnotetemps[d1.seq].
      program_name,tabposreply->qual[ipos].scripts[idx].script_name)
     IF (ipos2=0)
      cnt = (tabposreply->qual[ipos].scriptcnt+ 1), tabposreply->qual[ipos].scriptcnt = cnt, stat =
      alterlist(tabposreply->qual[ipos].scripts,cnt),
      tabposreply->qual[ipos].scripts[cnt].script_name = rpt->distinct_clinnotetemps[d1.seq].
      program_name
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#exit_script
END GO
