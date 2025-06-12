CREATE PROGRAM ec_get_genview_timings
 PROMPT
  "Enter Output Directory:" = "",
  "Enter encntr_id       :" = "",
  "Enter position_cd     :" = ""
  WITH outdev, encntrid, positioncd
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
   1 distinct_genview_cnt = i2
   1 distinct_genviews[*]
     2 program_name = vc
     2 level = vc
     2 start_tm = f8
     2 stop_tm = f8
     2 duration = f8
   1 tab_cnt = i4
   1 tabs[*]
     2 name = vc
     2 duration = f8
     2 genview_cnt = i4
     2 genviews[*]
       3 program_name = vc
       3 level = vc
       3 duration = f8
     2 position_cnt = i4
     2 positions[*]
       3 position_cd = f8
       3 position = vc
       3 user_cnt = i4
       3 physician_cnt = i4
 )
 SET rpt->output_device =  $OUTDEV
 SET rpt->position_cd = cnvtreal( $POSITIONCD)
 SET rpt->encntr_id = cnvtreal( $ENCNTRID)
 IF ((rpt->encntr_id=0.0))
  EXECUTE ec_encntr_list "MINE", 5, 30,
  2 WITH nocounter
  GO TO exit_script
 ENDIF
 IF ((rpt->position_cd=0.0))
  SELECT
   p.position_cd, position = uar_get_code_display(p.position_cd), physician_cnt = count(p.person_id)
   FROM prsnl p
   PLAN (p
    WHERE p.physician_ind=1
     AND p.active_ind=1
     AND p.position_cd != 0)
   GROUP BY p.position_cd
   ORDER BY physician_cnt DESC
   WITH nocounter
  ;end select
  CALL echo("Showing positions and exiting.")
  GO TO exit_script
 ELSEIF ((rpt->position_cd=- (1.0)))
  SET rpt->position_cd = 0.0
 ELSE
  SELECT INTO "nl"
   FROM code_value cv
   WHERE cv.code_set=88
    AND cv.active_ind=1
    AND (cv.code_value=rpt->position_cd)
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL echo("Unable to find the provided position")
   GO TO exit_script
  ENDIF
 ENDIF
 DECLARE tempint = i2 WITH noconstant(0), protect
 DECLARE tabcnt = i2 WITH noconstant(0), protect
 DECLARE genviewcnt = i2 WITH noconstant(0), protect
 DECLARE distinctgenviewcnt = i4 WITH noconstant(0), protect
 DECLARE recpos = i4 WITH noconstant(0), protect
 SELECT INTO "nl"
  FROM detail_prefs dp,
   name_value_prefs nvp,
   view_prefs vp,
   name_value_prefs nvp2
  PLAN (dp
   WHERE dp.application_number IN (600005, 4250111)
    AND dp.position_cd IN (0, rpt->position_cd)
    AND dp.prsnl_id=0.0
    AND dp.active_ind=1)
   JOIN (nvp
   WHERE nvp.parent_entity_id=dp.detail_prefs_id
    AND nvp.parent_entity_name="DETAIL_PREFS"
    AND ((nvp.pvc_name=trim("GENVIEWINFO")) OR (nvp.pvc_name=trim("GENSPREADINFO")))
    AND nvp.active_ind=1)
   JOIN (vp
   WHERE vp.application_number=dp.application_number
    AND vp.position_cd=dp.position_cd
    AND vp.prsnl_id=dp.prsnl_id
    AND vp.view_name=dp.view_name
    AND vp.view_seq=dp.view_seq
    AND vp.active_ind=1)
   JOIN (nvp2
   WHERE nvp2.parent_entity_name="VIEW_PREFS"
    AND nvp2.parent_entity_id=vp.view_prefs_id
    AND nvp2.pvc_name=trim("VIEW_CAPTION")
    AND nvp2.active_ind=1)
  ORDER BY nvp2.pvc_value, dp.position_cd DESC, nvp.pvc_value
  HEAD nvp2.pvc_value
   tabcnt = (rpt->tab_cnt+ 1), rpt->tab_cnt = tabcnt, stat = alterlist(rpt->tabs,tabcnt),
   rpt->tabs[tabcnt].name = nvp2.pvc_value, position_cnt = 0
  HEAD dp.position_cd
   position_cnt = (position_cnt+ 1)
  DETAIL
   IF (position_cnt=1)
    tempint = findstring(";",nvp.pvc_value), sprogname = cnvtupper(substring(1,(tempint - 1),nvp
      .pvc_value))
    IF (checkprg(sprogname) > 0)
     genviewcnt = (rpt->tabs[tabcnt].genview_cnt+ 1), rpt->tabs[tabcnt].genview_cnt = genviewcnt,
     stat = alterlist(rpt->tabs[tabcnt].genviews,genviewcnt),
     rpt->tabs[tabcnt].genviews[genviewcnt].program_name = cnvtlower(substring(1,(tempint - 1),nvp
       .pvc_value)), rpt->tabs[tabcnt].genviews[genviewcnt].level = cnvtlower(substring((tempint+ 1),
       size(nvp.pvc_value),nvp.pvc_value)), tempint = 0,
     recpos = locateval(tempint,1,rpt->distinct_genview_cnt,rpt->tabs[tabcnt].genviews[genviewcnt].
      program_name,rpt->distinct_genviews[tempint].program_name)
     IF (recpos=0)
      distinctgenviewcnt = (rpt->distinct_genview_cnt+ 1), rpt->distinct_genview_cnt =
      distinctgenviewcnt, stat = alterlist(rpt->distinct_genviews,distinctgenviewcnt),
      rpt->distinct_genviews[distinctgenviewcnt].program_name = rpt->tabs[tabcnt].genviews[genviewcnt
      ].program_name
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 DECLARE positioncnt = i4 WITH noconstant(0), protect
 IF ((rpt->tab_cnt > 0))
  SELECT INTO "nl"
   FROM (dummyt d  WITH seq = rpt->tab_cnt),
    name_value_prefs nvp,
    view_prefs vp,
    code_value cv
   PLAN (d)
    JOIN (nvp
    WHERE (nvp.pvc_value=rpt->tabs[d.seq].name)
     AND nvp.parent_entity_name="VIEW_PREFS"
     AND nvp.pvc_name=trim("VIEW_CAPTION"))
    JOIN (vp
    WHERE vp.view_prefs_id=nvp.parent_entity_id
     AND vp.application_number=600005
     AND vp.prsnl_id=0)
    JOIN (cv
    WHERE cv.code_value=vp.position_cd
     AND cv.active_ind=1)
   ORDER BY nvp.pvc_value, vp.position_cd
   DETAIL
    positioncnt = (rpt->tabs[d.seq].position_cnt+ 1), rpt->tabs[d.seq].position_cnt = positioncnt,
    stat = alterlist(rpt->tabs[d.seq].positions,positioncnt),
    rpt->tabs[d.seq].positions[positioncnt].position_cd = vp.position_cd, rpt->tabs[d.seq].positions[
    positioncnt].position = uar_get_code_display(vp.position_cd)
   WITH nocounter
  ;end select
 ENDIF
 IF ((rpt->tab_cnt > 0))
  SELECT INTO "nl"
   d1.seq, d2.seq, p.position_cd,
   user_cnt = count(p.person_id)
   FROM (dummyt d1  WITH seq = rpt->tab_cnt),
    dummyt d2,
    prsnl p
   PLAN (d1
    WHERE maxrec(d2,rpt->tabs[d1.seq].position_cnt))
    JOIN (d2)
    JOIN (p
    WHERE (p.position_cd=rpt->tabs[d1.seq].positions[d2.seq].position_cd)
     AND p.active_ind=1)
   GROUP BY d1.seq, d2.seq, p.position_cd
   ORDER BY user_cnt DESC
   DETAIL
    rpt->tabs[d1.seq].positions[d2.seq].user_cnt = user_cnt
   WITH nocounter
  ;end select
 ENDIF
 IF ((rpt->tab_cnt > 0))
  SELECT INTO "nl"
   d1.seq, d2.seq, p.position_cd,
   physician_cnt = count(p.person_id)
   FROM (dummyt d1  WITH seq = rpt->tab_cnt),
    dummyt d2,
    prsnl p
   PLAN (d1
    WHERE maxrec(d2,rpt->tabs[d1.seq].position_cnt))
    JOIN (d2)
    JOIN (p
    WHERE (p.position_cd=rpt->tabs[d1.seq].positions[d2.seq].position_cd)
     AND p.physician_ind=1
     AND p.active_ind=1)
   GROUP BY d1.seq, d2.seq, p.position_cd
   ORDER BY physician_cnt DESC
   DETAIL
    rpt->tabs[d1.seq].positions[d2.seq].physician_cnt = physician_cnt
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl"
  FROM encounter e
  PLAN (e
   WHERE (e.encntr_id=rpt->encntr_id))
  DETAIL
   rpt->person_id = e.person_id
  WITH nocounter
 ;end select
 DECLARE i = i2 WITH noconstant(0), private
 FOR (i = 1 TO rpt->distinct_genview_cnt)
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
   IF ((rpt->distinct_genviews[i].level="person"))
    SET request->person_cnt = 1
    SET stat = alterlist(request->person,1)
    SET request->person[1].person_id = rpt->person_id
   ELSE
    SET request->visit_cnt = 1
    SET stat = alterlist(request->visit,1)
    SET request->visit[1].encntr_id = rpt->encntr_id
   ENDIF
   SET rpt->distinct_genviews[i].start_tm = curtime3
   CALL parser(build2("execute ",rpt->distinct_genviews[i].program_name," go"))
   SET rpt->distinct_genviews[i].stop_tm = curtime3
   SET rpt->distinct_genviews[i].duration = ((rpt->distinct_genviews[i].stop_tm - rpt->
   distinct_genviews[i].start_tm)/ 100)
 ENDFOR
 DECLARE outfile = vc WITH noconstant(""), protect
 IF (cnvtupper( $OUTDEV)="MINE")
  SET outfile = "MINE"
 ELSE
  SET outfile = concat( $OUTDEV,"ec_genview_timings.csv")
 ENDIF
 IF ((rpt->distinct_genview_cnt > 0))
  SELECT INTO value(outfile)
   encntr_id = rpt->encntr_id, program_name = substring(1,100,rpt->distinct_genviews[d1.seq].
    program_name), elapsed = rpt->distinct_genviews[d1.seq].duration
   FROM (dummyt d1  WITH seq = rpt->distinct_genview_cnt)
   PLAN (d1)
   ORDER BY cnvtreal(rpt->distinct_genviews[d1.seq].duration) DESC
   WITH pcformat('"',",",1), format = stream, append,
    noheading
  ;end select
 ENDIF
 IF ((rpt->tab_cnt > 0))
  SELECT INTO "nl:"
   tab_name = rpt->tabs[d1.seq].name, position_cd = rpt->tabs[d1.seq].positions[d2.seq].position_cd
   FROM (dummyt d1  WITH seq = rpt->tab_cnt),
    dummyt d2
   PLAN (d1
    WHERE maxrec(d2,rpt->tabs[d1.seq].position_cnt))
    JOIN (d2)
   ORDER BY tab_name, position_cd
   HEAD REPORT
    cnt = 0
   HEAD tab_name
    ipos = locateval(idx,1,tabposreply->qualcnt,rpt->tabs[d1.seq].name,tabposreply->qual[idx].
     tab_name)
    IF (ipos=0)
     cnt = (tabposreply->qualcnt+ 1), tabposreply->qualcnt = cnt, stat = alterlist(tabposreply->qual,
      cnt),
     tabposreply->qual[cnt].tab_name = rpt->tabs[d1.seq].name, poscnt = 0
    ELSE
     cnt = ipos
    ENDIF
   DETAIL
    ipos2 = locateval(idx,1,tabposreply->qual[cnt].poscnt,position_cd,tabposreply->qual[cnt].
     positions[idx].position_cd)
    IF (ipos2=0)
     poscnt = (tabposreply->qual[cnt].poscnt+ 1), tabposreply->qual[cnt].poscnt = poscnt, stat =
     alterlist(tabposreply->qual[cnt].positions,poscnt),
     tabposreply->qual[cnt].positions[poscnt].position_cd = rpt->tabs[d1.seq].positions[d2.seq].
     position_cd, tabposreply->qual[cnt].positions[poscnt].position = rpt->tabs[d1.seq].positions[d2
     .seq].position, tabposreply->qual[cnt].positions[poscnt].physiciancnt = rpt->tabs[d1.seq].
     positions[d2.seq].physician_cnt,
     tabposreply->qual[cnt].positions[poscnt].usercnt = rpt->tabs[d1.seq].positions[d2.seq].user_cnt
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((rpt->tab_cnt > 0))
  SELECT INTO "nl:"
   tab_name = rpt->tabs[d1.seq].name, program_name = rpt->tabs[d1.seq].genviews[d2.seq].program_name
   FROM (dummyt d1  WITH seq = rpt->tab_cnt),
    dummyt d2
   PLAN (d1
    WHERE maxrec(d2,rpt->tabs[d1.seq].genview_cnt))
    JOIN (d2)
   ORDER BY tab_name, program_name
   HEAD REPORT
    cnt = 0
   DETAIL
    ipos = locateval(idx,1,tabposreply->qualcnt,rpt->tabs[d1.seq].name,tabposreply->qual[idx].
     tab_name)
    IF (ipos > 0)
     ipos2 = locateval(idx,1,tabposreply->qual[ipos].scriptcnt,rpt->tabs[d1.seq].genviews[d2.seq].
      program_name,tabposreply->qual[ipos].scripts[idx].script_name)
     IF (ipos2=0)
      cnt = (tabposreply->qual[ipos].scriptcnt+ 1), tabposreply->qual[ipos].scriptcnt = cnt, stat =
      alterlist(tabposreply->qual[ipos].scripts,cnt),
      tabposreply->qual[ipos].scripts[cnt].script_name = rpt->tabs[d1.seq].genviews[d2.seq].
      program_name
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#exit_script
END GO
