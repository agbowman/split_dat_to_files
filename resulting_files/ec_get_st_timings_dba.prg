CREATE PROGRAM ec_get_st_timings:dba
 PROMPT
  "Enter Output Device  :" = "MINE",
  "Enter encntr_id      :" = ""
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
   1 encntr_id = f8
   1 form_cnt = i2
   1 forms[*]
     2 name = vc
     2 use_cnt = i4
     2 dcp_form_instance_id = f8
     2 section_cnt = i2
     2 sections[*]
       3 name = vc
       3 template_cnt = i2
       3 templates[*]
         4 name = vc
         4 program_name = vc
         4 template_cd = f8
         4 level = vc
         4 duration = f8
   1 distinct_template_cnt = i2
   1 distinct_templates[*]
     2 program_name = vc
     2 start_tm = f8
     2 stop_tm = f8
     2 duration = f8
     2 level = vc
 )
 SET rpt->output_device =  $OUTDEV
 SET rpt->encntr_id = cnvtreal( $ENCNTRID)
 IF ((rpt->encntr_id=0.0))
  SET trace = nocost
  SET message = noinformation
  EXECUTE ec_encntr_list "MINE", 5, 30,
  2 WITH nocounter
  GO TO exit_script
 ENDIF
 DECLARE tempint = i2 WITH noconstant(0), protect
 DECLARE distincttemplatecnt = i2 WITH noconstant(0), protect
 DECLARE formcnt = i2 WITH noconstant(0), protect
 SELECT DISTINCT INTO "nl"
  dfr.dcp_form_instance_id, use_cnt = count(dfa.dcp_forms_activity_id)
  FROM dcp_forms_activity dfa,
   dcp_forms_ref dfr
  PLAN (dfa
   WHERE dfa.updt_dt_tm > cnvtdatetime((curdate - 1),curtime3))
   JOIN (dfr
   WHERE dfr.dcp_forms_ref_id=dfa.dcp_forms_ref_id
    AND dfr.active_ind=1)
  GROUP BY dfr.dcp_form_instance_id
  DETAIL
   formcnt = (rpt->form_cnt+ 1), rpt->form_cnt = formcnt, stat = alterlist(rpt->forms,formcnt),
   rpt->forms[formcnt].dcp_form_instance_id = dfr.dcp_form_instance_id, rpt->forms[formcnt].use_cnt
    = use_cnt
  WITH nocounter
 ;end select
 IF ((rpt->form_cnt > 0))
  SELECT INTO "nl"
   FROM (dummyt d  WITH seq = rpt->form_cnt),
    dcp_forms_ref dfr,
    dcp_forms_def dfd,
    dcp_section_ref dsr,
    dcp_input_ref dir,
    name_value_prefs nvp,
    code_value cv
   PLAN (d)
    JOIN (dfr
    WHERE (dfr.dcp_form_instance_id=rpt->forms[d.seq].dcp_form_instance_id)
     AND dfr.active_ind=1)
    JOIN (dfd
    WHERE dfd.dcp_form_instance_id=dfr.dcp_form_instance_id
     AND dfd.active_ind=1)
    JOIN (dsr
    WHERE dsr.dcp_section_ref_id=dfd.dcp_section_ref_id
     AND dsr.active_ind=1)
    JOIN (dir
    WHERE dir.dcp_section_ref_id=dsr.dcp_section_ref_id
     AND dir.input_type=13
     AND dir.active_ind=1)
    JOIN (nvp
    WHERE nvp.parent_entity_name="DCP_INPUT_REF"
     AND nvp.parent_entity_id=dir.dcp_input_ref_id
     AND nvp.pvc_name="template_cd"
     AND nvp.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=nvp.merge_id
     AND cv.code_set=16529)
   ORDER BY dfr.dcp_form_instance_id, dsr.dcp_section_ref_id, nvp.merge_id
   HEAD dfr.dcp_form_instance_id
    rpt->forms[d.seq].name = dfr.description
   HEAD dsr.dcp_section_ref_id
    sectioncnt = (rpt->forms[d.seq].section_cnt+ 1), rpt->forms[d.seq].section_cnt = sectioncnt, stat
     = alterlist(rpt->forms[d.seq].sections,sectioncnt),
    rpt->forms[d.seq].sections[sectioncnt].name = dsr.description
   HEAD nvp.merge_id
    sprogname = cnvtupper(cv.definition)
    IF (checkprg(sprogname) > 0)
     templatecnt = (rpt->forms[d.seq].sections[sectioncnt].template_cnt+ 1), rpt->forms[d.seq].
     sections[sectioncnt].template_cnt = templatecnt, stat = alterlist(rpt->forms[d.seq].sections[
      sectioncnt].templates,templatecnt),
     rpt->forms[d.seq].sections[sectioncnt].templates[templatecnt].template_cd = nvp.merge_id, rpt->
     forms[d.seq].sections[sectioncnt].templates[templatecnt].name = cv.display, rpt->forms[d.seq].
     sections[sectioncnt].templates[templatecnt].program_name = cnvtlower(cv.definition),
     rpt->forms[d.seq].sections[sectioncnt].templates[templatecnt].level = cnvtlower(cv.description),
     tempint = 0, recpos = locateval(tempint,1,rpt->distinct_template_cnt,rpt->forms[d.seq].sections[
      sectioncnt].templates[templatecnt].program_name,rpt->distinct_templates[tempint].program_name)
     IF (recpos=0)
      distincttemplatecnt = (rpt->distinct_template_cnt+ 1), rpt->distinct_template_cnt =
      distincttemplatecnt, stat = alterlist(rpt->distinct_templates,distincttemplatecnt),
      rpt->distinct_templates[distincttemplatecnt].program_name = rpt->forms[d.seq].sections[
      sectioncnt].templates[templatecnt].program_name
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 FOR (i = 1 TO rpt->distinct_template_cnt)
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
   IF ((rpt->distinct_templates[i].level="person"))
    SET request->person_cnt = 1
    SET stat = alterlist(request->person,1)
    SET request->person[1].person_id = rpt->person_id
   ELSE
    SET request->visit_cnt = 1
    SET stat = alterlist(request->visit,1)
    SET request->visit[1].encntr_id = rpt->encntr_id
   ENDIF
   SET rpt->distinct_templates[i].start_tm = curtime3
   CALL parser(build2("execute ",rpt->distinct_templates[i].program_name," go"))
   SET rpt->distinct_templates[i].stop_tm = curtime3
   SET rpt->distinct_templates[i].duration = ((rpt->distinct_templates[i].stop_tm - rpt->
   distinct_templates[i].start_tm)/ 100)
 ENDFOR
 FOR (i = 1 TO rpt->form_cnt)
   FOR (j = 1 TO rpt->forms[i].section_cnt)
     FOR (k = 1 TO rpt->forms[i].sections[j].template_cnt)
       SET tempint = 0
       SET recpos = locateval(tempint,1,rpt->distinct_template_cnt,rpt->forms[i].sections[j].
        templates[k].program_name,rpt->distinct_templates[tempint].program_name)
       IF (recpos=0)
        CALL echo("Error indexing the templates.")
        GO TO exit_script
       ENDIF
       SET rpt->forms[i].sections[j].templates[k].duration = rpt->distinct_templates[recpos].duration
     ENDFOR
   ENDFOR
 ENDFOR
 DECLARE outfile = vc WITH noconstant(""), protect
 IF (cnvtupper( $OUTDEV)="MINE")
  SET outfile = "MINE"
 ELSE
  SET outfile = concat( $OUTDEV,"ec_get_st_timings.csv")
 ENDIF
 IF ((rpt->distinct_template_cnt > 0))
  SELECT INTO value(outfile)
   encntr_id = rpt->encntr_id, program_name = substring(1,100,rpt->distinct_templates[d1.seq].
    program_name), elapsed = rpt->distinct_templates[d1.seq].duration
   FROM (dummyt d1  WITH seq = rpt->distinct_template_cnt)
   PLAN (d1)
   ORDER BY cnvtreal(rpt->distinct_templates[d1.seq].duration) DESC
   WITH pcformat('"',",",1), format = stream, append,
    noheading
  ;end select
 ENDIF
 IF ((rpt->distinct_template_cnt > 0))
  SELECT INTO "nl:"
   tab_name = rpt->distinct_templates[d1.seq].program_name
   FROM (dummyt d1  WITH seq = rpt->distinct_template_cnt)
   PLAN (d1)
   ORDER BY tab_name
   HEAD REPORT
    cnt = 0
   HEAD tab_name
    ipos = locateval(idx,1,tabposreply->qualcnt,rpt->distinct_templates[d1.seq].program_name,
     tabposreply->qual[idx].tab_name)
    IF (ipos=0)
     cnt = (tabposreply->qualcnt+ 1), tabposreply->qualcnt = cnt, stat = alterlist(tabposreply->qual,
      cnt),
     tabposreply->qual[cnt].tab_name = rpt->distinct_templates[d1.seq].program_name, poscnt = 0
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
     tabposreply->qual[cnt].positions[poscnt].usercnt = - (2)
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((rpt->distinct_template_cnt > 0))
  SELECT INTO "nl:"
   tab_name = rpt->distinct_templates[d1.seq].program_name, program_name = rpt->distinct_templates[d1
   .seq].program_name
   FROM (dummyt d1  WITH seq = rpt->distinct_template_cnt)
   PLAN (d1)
   ORDER BY tab_name, program_name
   HEAD REPORT
    cnt = 0
   DETAIL
    ipos = locateval(idx,1,tabposreply->qualcnt,rpt->distinct_templates[d1.seq].program_name,
     tabposreply->qual[idx].tab_name)
    IF (ipos > 0)
     ipos2 = locateval(idx,1,tabposreply->qual[ipos].scriptcnt,rpt->distinct_templates[d1.seq].
      program_name,tabposreply->qual[ipos].scripts[idx].script_name)
     IF (ipos2=0)
      cnt = (tabposreply->qual[ipos].scriptcnt+ 1), tabposreply->qual[ipos].scriptcnt = cnt, stat =
      alterlist(tabposreply->qual[ipos].scripts,cnt),
      tabposreply->qual[ipos].scripts[cnt].script_name = rpt->distinct_templates[d1.seq].program_name
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#exit_script
END GO
