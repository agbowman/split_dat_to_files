CREATE PROGRAM dcp_rpt_vitals:dba
 SET temp_cd = 22609
 SET pulse_cd = 22418
 SET resp_cd = 22585
 SET sbp_cd = 22608
 SET dbp_cd = 22369
 SET ox_cd = 227503
 RECORD temp(
   1 cnt = i2
   1 v[*]
     2 date = dq8
     2 doc = vc
     2 t = vc
     2 t_note_ind = i2
     2 t_event_id = f8
     2 t_text = vc
     2 p = vc
     2 p_note_ind = i2
     2 p_event_id = f8
     2 p_text = vc
     2 r = vc
     2 r_note_ind = i2
     2 r_event_id = f8
     2 r_text = vc
     2 s = vc
     2 s_note_ind = i2
     2 s_event_id = f8
     2 s_text = vc
     2 d = vc
     2 d_note_ind = i2
     2 d_event_id = f8
     2 d_text = vc
     2 o = vc
     2 o_note_ind = i2
     2 o_event_id = f8
     2 o_text = vc
 )
 SET xxx = fillstring(20," ")
 SET xcol = 0
 SET ycol = 0
 SET a = fillstring(20," ")
 SET code_value = 0.0
 SET code_set = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET q = fillstring(27,"_")
 SET k = fillstring(34,"_")
 SET name = fillstring(50," ")
 SET age = fillstring(50," ")
 SET dob = fillstring(50," ")
 SET mrn = fillstring(50," ")
 SET admitdoc = fillstring(50," ")
 SET unit = fillstring(20," ")
 SET room = fillstring(20," ")
 SET bed = fillstring(20," ")
 SET finnbr = fillstring(20," ")
 SET yyy = fillstring(60," ")
 SET event_id = 0.0
 SET ops_ind = "N"
 IF ((request->batch_selection > " "))
  SET ops_ind = "Y"
 ENDIF
 SET beg_ind = 0
 SET end_ind = 0
 SET beg_dt_tm = cnvtdatetime(curdate,curtime)
 SET end_dt_tm = cnvtdatetime(curdate,curtime)
 SET x2 = "  "
 SET x3 = "   "
 SET abc = fillstring(25," ")
 SET xyz = "  -   -       :  :  "
 CALL echo(build("xyz:",xyz))
 FOR (x = 1 TO request->nv_cnt)
   IF ((request->nv[x].pvc_name="BEG_DT_TM"))
    SET beg_ind = 1
    SET abc = trim(request->nv[x].pvc_value)
    SET stat = movestring(abc,7,xyz,1,2)
    SET x2 = substring(5,2,abc)
    IF (x2="01")
     SET x3 = "JAN"
    ELSEIF (x2="02")
     SET x3 = "FEB"
    ELSEIF (x2="03")
     SET x3 = "MAR"
    ELSEIF (x2="04")
     SET x3 = "APR"
    ELSEIF (x2="05")
     SET x3 = "MAY"
    ELSEIF (x2="06")
     SET x3 = "JUN"
    ELSEIF (x2="07")
     SET x3 = "JUL"
    ELSEIF (x2="08")
     SET x3 = "AUG"
    ELSEIF (x2="09")
     SET x3 = "SEP"
    ELSEIF (x2="10")
     SET x3 = "OCT"
    ELSEIF (x2="11")
     SET x3 = "NOV"
    ELSEIF (x2="12")
     SET x3 = "DEC"
    ENDIF
    SET stat = movestring(x3,1,xyz,4,3)
    SET stat = movestring(abc,1,xyz,8,4)
    SET stat = movestring(abc,9,xyz,13,2)
    SET stat = movestring(abc,11,xyz,16,2)
    SET stat = movestring(abc,13,xyz,19,2)
    SET beg_dt_tm = cnvtdatetime(xyz)
   ELSEIF ((request->nv[x].pvc_name="END_DT_TM"))
    SET end_ind = 1
    SET abc = trim(request->nv[x].pvc_value)
    SET stat = movestring(abc,7,xyz,1,2)
    SET x2 = substring(5,2,abc)
    IF (x2="01")
     SET x3 = "JAN"
    ELSEIF (x2="02")
     SET x3 = "FEB"
    ELSEIF (x2="03")
     SET x3 = "MAR"
    ELSEIF (x2="04")
     SET x3 = "APR"
    ELSEIF (x2="05")
     SET x3 = "MAY"
    ELSEIF (x2="06")
     SET x3 = "JUN"
    ELSEIF (x2="07")
     SET x3 = "JUL"
    ELSEIF (x2="08")
     SET x3 = "AUG"
    ELSEIF (x2="09")
     SET x3 = "SEP"
    ELSEIF (x2="10")
     SET x3 = "OCT"
    ELSEIF (x2="11")
     SET x3 = "NOV"
    ELSEIF (x2="12")
     SET x3 = "DEC"
    ENDIF
    SET stat = movestring(x3,1,xyz,4,3)
    SET stat = movestring(abc,1,xyz,8,4)
    SET stat = movestring(abc,9,xyz,13,2)
    SET stat = movestring(abc,11,xyz,16,2)
    SET stat = movestring(abc,13,xyz,19,2)
    SET end_dt_tm = cnvtdatetime(xyz)
   ENDIF
 ENDFOR
 IF (((end_ind=0) OR (beg_ind=0)) )
  IF (ops_ind="Y")
   SET beg_dt_tm = cnvtdatetime((curdate - 1),0)
   SET end_dt_tm = cnvtdatetime((curdate - 1),2359)
  ELSE
   SET beg_dt_tm = cnvtdatetime(curdate,0)
   SET end_dt_tm = cnvtdatetime(curdate,curtime)
  ENDIF
 ENDIF
 SET code_set = 52
 SET cdf_meaning = "CRITICAL"
 EXECUTE cpm_get_cd_for_cdf
 SET critical_cd = code_value
 SET code_set = 52
 SET cdf_meaning = "HIGH"
 EXECUTE cpm_get_cd_for_cdf
 SET high_cd = code_value
 SET code_set = 52
 SET cdf_meaning = "LOW"
 EXECUTE cpm_get_cd_for_cdf
 SET low_cd = code_value
 SET code_set = 52
 SET cdf_meaning = "PANICLOW"
 EXECUTE cpm_get_cd_for_cdf
 SET paniclow_cd = code_value
 SET code_set = 52
 SET cdf_meaning = "PANICHIGH"
 EXECUTE cpm_get_cd_for_cdf
 SET panichigh_cd = code_value
 SET code_set = 52
 SET cdf_meaning = "EXTREMELOW"
 EXECUTE cpm_get_cd_for_cdf
 SET extremelow_cd = code_value
 SET code_set = 52
 SET cdf_meaning = "EXTREMEHIGH"
 EXECUTE cpm_get_cd_for_cdf
 SET extremehigh_cd = code_value
 SET code_set = 4
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_cd = code_value
 SET code_set = 319
 SET cdf_meaning = "FIN NBR"
 EXECUTE cpm_get_cd_for_cdf
 SET finnbr_cd = code_value
 SET code_set = 333
 SET cdf_meaning = "ATTENDDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET attend_doc_cd = code_value
 SET code_set = 120
 SET cdf_meaning = "OCFCOMP"
 EXECUTE cpm_get_cd_for_cdf
 SET ocfcomp_cd = code_value
 SELECT INTO "nl:"
  c.event_cd, c.event_end_dt_tm, c.performed_prsnl_id,
  cv.code_value, pl.person_id
  FROM clinical_event c,
   code_value cv,
   prsnl pl
  PLAN (c
   WHERE (c.encntr_id=request->visit[1].encntr_id)
    AND c.view_level=1
    AND c.publish_flag=1
    AND c.event_cd IN (temp_cd, resp_cd, pulse_cd, sbp_cd, dbp_cd,
   ox_cd)
    AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
    AND c.event_end_dt_tm >= cnvtdatetime(beg_dt_tm)
    AND c.event_end_dt_tm <= cnvtdatetime(end_dt_tm))
   JOIN (pl
   WHERE c.performed_prsnl_id=pl.person_id)
   JOIN (cv
   WHERE cv.code_value=pl.position_cd)
  ORDER BY c.event_end_dt_tm DESC, c.parent_event_id
  HEAD REPORT
   temp->cnt = 0, holdd1 = 0.0, holdd2 = 0.0,
   holdd3 = 0.0
  HEAD c.parent_event_id
   temp->cnt = (temp->cnt+ 1)
  DETAIL
   stat = alterlist(temp->v,temp->cnt), temp->v[temp->cnt].date = c.event_end_dt_tm, temp->v[temp->
   cnt].doc = concat(trim(pl.name_full_formatted)," ",trim(cv.definition))
   IF (c.event_cd=temp_cd)
    temp->v[temp->cnt].t = c.event_tag, temp->v[temp->cnt].t_note_ind = btest(c.subtable_bit_map,1),
    temp->v[temp->cnt].t_event_id = c.event_id
    IF (c.normalcy_cd=critical_cd)
     temp->v[temp->cnt].t = concat("C ",trim(temp->v[temp->cnt].t))
    ELSEIF (c.normalcy_cd IN (low_cd, extremelow_cd, paniclow_cd))
     temp->v[temp->cnt].t = concat("L ",trim(temp->v[temp->cnt].t))
    ELSEIF (c.normalcy_cd IN (extremehigh_cd, panichigh_cd, high_cd))
     temp->v[temp->cnt].t = concat("H ",trim(temp->v[temp->cnt].t))
    ENDIF
   ELSEIF (c.event_cd=pulse_cd)
    temp->v[temp->cnt].p = c.event_tag, temp->v[temp->cnt].p_note_ind = btest(c.subtable_bit_map,1),
    temp->v[temp->cnt].p_event_id = c.event_id
    IF (c.normalcy_cd=critical_cd)
     temp->v[temp->cnt].p = concat("C ",trim(temp->v[temp->cnt].p))
    ELSEIF (c.normalcy_cd IN (extremelow_cd, low_cd, paniclow_cd))
     temp->v[temp->cnt].p = concat("L ",trim(temp->v[temp->cnt].p))
    ELSEIF (c.normalcy_cd IN (panichigh_cd, high_cd, extremehigh_cd))
     temp->v[temp->cnt].p = concat("H ",trim(temp->v[temp->cnt].p))
    ENDIF
   ELSEIF (c.event_cd=resp_cd)
    temp->v[temp->cnt].r = c.event_tag, temp->v[temp->cnt].r_note_ind = btest(c.subtable_bit_map,1),
    temp->v[temp->cnt].r_event_id = c.event_id
    IF (c.normalcy_cd=critical_cd)
     temp->v[temp->cnt].r = concat("C ",trim(temp->v[temp->cnt].r))
    ELSEIF (c.normalcy_cd IN (extremelow_cd, low_cd, paniclow_cd))
     temp->v[temp->cnt].r = concat("L ",trim(temp->v[temp->cnt].r))
    ELSEIF (c.normalcy_cd IN (panichigh_cd, high_cd, extremehigh_cd))
     temp->v[temp->cnt].r = concat("H ",trim(temp->v[temp->cnt].r))
    ENDIF
   ELSEIF (c.event_cd=sbp_cd)
    temp->v[temp->cnt].s = c.event_tag, temp->v[temp->cnt].s_note_ind = btest(c.subtable_bit_map,1),
    temp->v[temp->cnt].s_event_id = c.event_id
    IF (c.normalcy_cd=critical_cd)
     temp->v[temp->cnt].s = concat("C ",trim(temp->v[temp->cnt].s))
    ELSEIF (c.normalcy_cd IN (extremelow_cd, low_cd, paniclow_cd))
     temp->v[temp->cnt].s = concat("L ",trim(temp->v[temp->cnt].s))
    ELSEIF (c.normalcy_cd IN (panichigh_cd, high_cd, extremehigh_cd))
     temp->v[temp->cnt].s = concat("H ",trim(temp->v[temp->cnt].s))
    ENDIF
   ELSEIF (c.event_cd=dbp_cd)
    temp->v[temp->cnt].d = c.event_tag, temp->v[temp->cnt].d_note_ind = btest(c.subtable_bit_map,1),
    temp->v[temp->cnt].d_event_id = c.event_id
    IF (c.normalcy_cd=critical_cd)
     temp->v[temp->cnt].d = concat("C ",trim(temp->v[temp->cnt].d))
    ELSEIF (c.normalcy_cd IN (paniclow_cd, low_cd, extremelow_cd))
     temp->v[temp->cnt].d = concat("L ",trim(temp->v[temp->cnt].d))
    ELSEIF (c.normalcy_cd IN (extremehigh_cd, high_cd, panichigh_cd))
     temp->v[temp->cnt].d = concat("H ",trim(temp->v[temp->cnt].d))
    ENDIF
   ELSEIF (c.event_cd=ox_cd)
    temp->v[temp->cnt].o = c.event_tag, temp->v[temp->cnt].o_note_ind = btest(c.subtable_bit_map,1),
    temp->v[temp->cnt].o_event_id = c.event_id
    IF (c.normalcy_cd=critical_cd)
     temp->v[temp->cnt].o = concat("C ",trim(temp->v[temp->cnt].o))
    ELSEIF (c.normalcy_cd IN (extremelow_cd, low_cd, paniclow_cd))
     temp->v[temp->cnt].o = concat("L ",trim(temp->v[temp->cnt].o))
    ELSEIF (c.normalcy_cd IN (panichigh_cd, high_cd, extremehigh_cd))
     temp->v[temp->cnt].o = concat("H ",trim(temp->v[temp->cnt].o))
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 FOR (y = 1 TO temp->cnt)
   IF ((temp->v[y].t_note_ind=1))
    SET event_id = temp->v[y].t_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->v[y].t_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->v[y].p_note_ind=1))
    SET event_id = temp->v[y].p_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->v[y].p_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->v[y].r_note_ind=1))
    SET event_id = temp->v[y].r_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->v[y].r_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->v[y].s_note_ind=1))
    SET event_id = temp->v[y].s_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->v[y].s_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->v[y].d_note_ind=1))
    SET event_id = temp->v[y].d_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->v[y].d_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->v[y].o_note_ind=1))
    SET event_id = temp->v[y].o_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->v[y].o_text = concat(trim(blob_out,3))
   ENDIF
 ENDFOR
 FOR (y = 1 TO temp->cnt)
  CALL echo(build("ind",temp->v[y].o_note_ind))
  CALL echo(build("text",temp->v[y].o_text))
 ENDFOR
 SELECT INTO "nl:"
  e.encntr_id, e.reg_dt_tm, p.name_full_formatted,
  p.birth_dt_tm, pa.alias, pl.name_full_formatted,
  e.loc_nurse_unit_cd, e.loc_room_cd, e.loc_bed_cd,
  epr.seq
  FROM person p,
   encounter e,
   person_alias pa,
   encntr_prsnl_reltn epr,
   prsnl pl,
   (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1),
   encntr_alias ea
  PLAN (e
   WHERE (e.encntr_id=request->visit[1].encntr_id))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (d1)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=mrn_alias_cd
    AND pa.active_ind=1)
   JOIN (d2)
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.encntr_prsnl_r_cd=attend_doc_cd
    AND epr.active_ind=1
    AND ((epr.expiration_ind != 1) OR (epr.expiration_ind = null)) )
   JOIN (d3)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=finnbr_cd)
   JOIN (pl
   WHERE pl.person_id=epr.prsnl_person_id)
  HEAD REPORT
   name = substring(1,30,p.name_full_formatted), age = cnvtage(cnvtdate(p.birth_dt_tm),curdate), dob
    = format(p.birth_dt_tm,"mm/dd/yy;;d"),
   mrn = substring(1,20,pa.alias), finnbr = substring(1,20,ea.alias), admitdoc = substring(1,30,pl
    .name_full_formatted),
   unit = substring(1,20,uar_get_code_display(e.loc_nurse_unit_cd)), room = substring(1,10,
    uar_get_code_display(e.loc_room_cd)), bed = substring(1,10,uar_get_code_display(e.loc_bed_cd))
  DETAIL
   reg_dt_tm = cnvtdatetime(e.reg_dt_tm)
  WITH nocounter, outerjoin = d1, dontcare = pa,
   dontcare = epr, outerjoin = d2, outerjoin = d3,
   dontcare = ea
 ;end select
 SELECT INTO request->output_device
  d.seq
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD REPORT
   "{pos/60/55}{f/12}Patient Name:  ", name, row + 1,
   "{pos/60/67}Date of Birth:  ", dob, row + 1,
   "{pos/60/79}Admitting Physician:  ", admitdoc, row + 1,
   "{pos/320/55}Med Rec Num:  ", mrn, row + 1,
   "{pos/320/67}Age:  ", age, row + 1,
   yyy = concat(trim(unit)," ; ",trim(room)," ; ",trim(bed)), "{pos/320/79}Location:  ", yyy,
   row + 1, "{pos/320/91}Financial Num: ", finnbr,
   row + 1, "{pos/230/125}{f/13}Vital Signs Summary", row + 1,
   "{pos/215/137}For  ", f = cnvtdatetime(end_dt_tm), u = cnvtdatetime(beg_dt_tm),
   u"mm/dd/yy hh:mm;;d", " - ", f"mm/dd/yy hh:mm;;d",
   row + 1, "{pos/215/139}", q,
   row + 1, "{pos/150/180}{u}Temp    C", row + 1,
   "{pos/180/176}o", row + 1, "{pos/210/180}{u}HR",
   row + 1, "{pos/260/180}{u}RR", row + 1,
   "{pos/300/180}{u}BP", row + 1, "{pos/360/180}{u}Pulse Ox",
   row + 1, "{pos/420/180}{u}Performed By", row + 1
  DETAIL
   ycol = 192
   FOR (y = 1 TO temp->cnt)
     xcol = 60,
     CALL print(calcpos(xcol,ycol)), "{f/12}",
     temp->v[y].date"mm/dd/yy hh:mm;;d"
     IF (substring(1,1,temp->v[y].t) IN ("H", "L", "C"))
      xcol = 141
     ELSE
      xcol = 150
     ENDIF
     CALL print(calcpos(xcol,ycol)), temp->v[y].t
     IF (substring(1,1,temp->v[y].p) IN ("H", "L", "C"))
      xcol = 201
     ELSE
      xcol = 210
     ENDIF
     CALL print(calcpos(xcol,ycol)), temp->v[y].p
     IF (substring(1,1,temp->v[y].r) IN ("H", "L", "C"))
      xcol = 251
     ELSE
      xcol = 260
     ENDIF
     CALL print(calcpos(xcol,ycol)), temp->v[y].r
     IF (((substring(1,8,temp->v[y].d)="In Error") OR (substring(1,8,temp->v[y].s)="In Error")) )
      xcol = 300,
      CALL print(calcpos(xcol,ycol)), "In Error"
     ELSE
      IF ((((temp->v[y].s > " ")) OR ((temp->v[y].d > " "))) )
       xxx = concat(trim(temp->v[y].s)," / ",trim(temp->v[y].d))
       IF (substring(1,1,xxx) IN ("H", "L", "C"))
        xcol = 291
       ELSE
        xcol = 300
       ENDIF
       CALL print(calcpos(xcol,ycol)), xxx
      ENDIF
     ENDIF
     IF (substring(1,1,temp->v[y].o) IN ("H", "L", "C"))
      xcol = 351
     ELSE
      xcol = 360
     ENDIF
     CALL print(calcpos(xcol,ycol)), temp->v[y].o, xcol = 420,
     CALL print(calcpos(xcol,ycol)), temp->v[y].doc, row + 1,
     ycol = (ycol+ 12)
     IF ((temp->v[y].t_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Temperature comment: ",
      temp->v[y].t_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->v[y].p_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Heart Rate comment: ",
      temp->v[y].p_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->v[y].r_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Respitory Rate comment: ",
      temp->v[y].r_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->v[y].s_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Systolic Blood Pressure comment: ",
      temp->v[y].s_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->v[y].d_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Diastolic Blood Pressure comment: ",
      temp->v[y].d_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     IF ((temp->v[y].o_note_ind=1))
      xcol = 60,
      CALL print(calcpos(xcol,ycol)), "Pulse Ox comment: ",
      temp->v[y].o_text, row + 1, ycol = (ycol+ 12)
     ENDIF
     ycol = (ycol+ 12), row + 1
   ENDFOR
  FOOT PAGE
   ycol = 750, xcol = 250,
   CALL print(calcpos(xcol,ycol)),
   "{f/8}{cpi/16}Page", curpage, row + 1,
   xcol = 310,
   CALL print(calcpos(xcol,ycol)), curdate,
   curtime, row + 1
  WITH nocounter, dio = postscript, maxcol = 800,
   maxrow = 800
 ;end select
 GO TO exit_program
#get_note_begin
 SET blob_out = fillstring(32000," ")
 SELECT INTO "nl:"
  cen.seq, lb.long_blob
  FROM ce_event_note cen,
   long_blob lb
  PLAN (cen
   WHERE cen.event_id=event_id)
   JOIN (lb
   WHERE lb.parent_entity_id=cen.ce_event_note_id
    AND lb.parent_entity_name="CE_EVENT_NOTE")
  DETAIL
   IF (cen.compression_cd=ocfcomp_cd)
    blob_out = fillstring(32000," "), blob_out2 = fillstring(32000," "), blob_out3 = fillstring(32000,
     " "),
    blob_ret_len = 0,
    CALL uar_ocf_uncompress(lb.long_blob,textlen(lb.long_blob),blob_out,32000,blob_ret_len)
   ELSE
    blob_out = fillstring(32000," "), y1 = size(trim(lb.long_blob)), blob_out = substring(1,(y1 - 8),
     lb.long_blob)
   ENDIF
   CALL uar_rtf(blob_out,textlen(blob_out),blob_out2,32000,32000,0), blob_out = blob_out2
  WITH nocounter
 ;end select
#get_note_end
#exit_program
END GO
