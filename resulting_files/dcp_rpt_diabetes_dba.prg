CREATE PROGRAM dcp_rpt_diabetes:dba
 SET lab_cd = 111304
 SET gluc_cd = 110468
 SET finger_cd = 139241
 SET ins_cd = 243584
 SET oral_cd = 243583
 SET diet_cd = 243585
 SET iv_cd = 243586
 SET ster_cd = 243587
 SET com_cd = 274836
 SET meter_cd = 243588
 RECORD temp(
   1 cnt = i2
   1 res[*]
     2 date = dq8
     2 doc = vc
     2 rind = vc
     2 lab = vc
     2 lab_note_ind = i2
     2 lab_event_id = f8
     2 lab_text = vc
     2 gluc = vc
     2 gluc_note_ind = i2
     2 gluc_event_id = f8
     2 gluc_text = vc
     2 finger = vc
     2 finger_note_ind = i2
     2 finger_event_id = f8
     2 finger_text = vc
     2 diet = vc
     2 diet_note_ind = i2
     2 diet_event_id = f8
     2 diet_text = vc
     2 iv = vc
     2 iv_note_ind = i2
     2 iv_event_id = f8
     2 iv_text = vc
     2 ster = vc
     2 ster_note_ind = i2
     2 ster_event_id = f8
     2 ster_text = vc
     2 meter = vc
     2 meter_note_ind = i2
     2 meter_event_id = f8
     2 meter_text = vc
     2 ins = vc
     2 ins_sze = i2
     2 ins_ln_cnt = i2
     2 ins_list[*]
       3 ins_line = vc
     2 ins_note_ind = i2
     2 ins_event_id = f8
     2 ins_text = vc
     2 oral = vc
     2 oral_sze = i2
     2 oral_ln_cnt = i2
     2 oral_list[*]
       3 oral_line = vc
     2 oral_note_ind = i2
     2 oral_event_id = f8
     2 oral_text = vc
     2 com = vc
     2 com_sze = i2
     2 com_ln_cnt = i2
     2 com_list[*]
       3 com_line = vc
     2 com_note_ind = i2
     2 com_event_id = f8
     2 com_text = vc
 )
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 SET xxx = fillstring(20," ")
 SET xcol = 0
 SET ycol = 0
 SET xcol2 = 0
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
 SET finnbr = fillstring(50," ")
 SET admitdoc = fillstring(50," ")
 SET unit = fillstring(20," ")
 SET room = fillstring(20," ")
 SET bed = fillstring(20," ")
 SET yyy = fillstring(60," ")
 SET g = 0
 SET h = 0
 SET i = 0
 SET person_id = 0.0
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
   SELECT INTO "nl:"
    e.reg_dt_tm
    FROM encounter e
    PLAN (e
     WHERE (e.encntr_id=request->visit[1].encntr_id))
    DETAIL
     beg_dt_tm = cnvtdatetime(e.reg_dt_tm), end_dt_tm = cnvtdatetime(curdate,0)
    WITH nocounter
   ;end select
  ELSE
   SET beg_dt_tm = cnvtdatetime(curdate,0)
   SET end_dt_tm = cnvtdatetime(curdate,curtime)
  ENDIF
 ENDIF
 SET code_set = 120
 SET cdf_meaning = "OCFCOMP"
 EXECUTE cpm_get_cd_for_cdf
 SET ocfcomp_cd = code_value
 SET code_set = 52
 SET cdf_meaning = "CRITICAL"
 EXECUTE cpm_get_cd_for_cdf
 SET critical_cd = code_value
 SET code_set = 319
 SET cdf_meaning = "FIN NBR"
 EXECUTE cpm_get_cd_for_cdf
 SET finnbr_cd = code_value
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
 SET code_set = 333
 SET cdf_meaning = "ATTENDDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET attend_doc_cd = code_value
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
   encntr_alias ea,
   (dummyt d1  WITH seq = 1),
   (dummyt d3  WITH seq = 1),
   (dummyt d2  WITH seq = 1)
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
   reg_dt_tm = cnvtdatetime(e.reg_dt_tm), person_id = p.person_id
  WITH nocounter, outerjoin = d1, dontcare = pa,
   dontcare = epr, outerjoin = d2, outerjoin = d3,
   dontcare = ea
 ;end select
 SELECT INTO "nl:"
  c.event_cd, c.event_end_dt_tm, c.performed_prsnl_id,
  d.seq, pl.person_id
  FROM clinical_event c,
   (dummyt d  WITH seq = 1),
   prsnl pl
  PLAN (c
   WHERE c.person_id=person_id
    AND c.view_level=1
    AND c.publish_flag=1
    AND c.event_cd IN (lab_cd, gluc_cd, finger_cd, ins_cd, oral_cd,
   diet_cd, iv_cd, ster_cd, com_cd, meter_cd)
    AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
    AND c.event_end_dt_tm >= cnvtdatetime(beg_dt_tm)
    AND c.event_end_dt_tm <= cnvtdatetime(end_dt_tm))
   JOIN (d)
   JOIN (pl
   WHERE c.performed_prsnl_id=pl.person_id)
  ORDER BY cnvtdatetime(c.event_end_dt_tm)
  HEAD REPORT
   temp->cnt = 0, holdd1 = 0.0, holdd2 = 0.0,
   holdd3 = 0.0
  HEAD c.event_end_dt_tm
   holdd1 = cnvtdatetime(c.event_end_dt_tm), holdd3 = abs((holdd1 - holdd2))
   IF (((holdd3/ 10000000) > 60))
    temp->cnt = (temp->cnt+ 1)
   ENDIF
   holdd2 = holdd1
  DETAIL
   stat = alterlist(temp->res,temp->cnt), temp->res[temp->cnt].date = c.event_end_dt_tm
   IF (c.event_cd=lab_cd)
    temp->res[temp->cnt].lab = c.event_tag, temp->res[temp->cnt].lab_note_ind = btest(c
     .subtable_bit_map,1), temp->res[temp->cnt].lab_event_id = c.event_id
    IF (c.normalcy_cd=critical_cd)
     temp->res[temp->cnt].lab = concat("C ",trim(temp->res[temp->cnt].lab))
    ELSEIF (c.normalcy_cd IN (low_cd, extremelow_cd, paniclow_cd))
     temp->res[temp->cnt].lab = concat("L ",trim(temp->res[temp->cnt].lab))
    ELSEIF (c.normalcy_cd IN (extremehigh_cd, panichigh_cd, high_cd))
     temp->res[temp->cnt].lab = concat("H ",trim(temp->res[temp->cnt].lab))
    ENDIF
   ELSEIF (c.event_cd=gluc_cd)
    temp->res[temp->cnt].gluc = c.event_tag, temp->res[temp->cnt].gluc_note_ind = btest(c
     .subtable_bit_map,1), temp->res[temp->cnt].gluc_event_id = c.event_id
    IF (c.normalcy_cd=critical_cd)
     temp->res[temp->cnt].gluc = concat("C ",trim(temp->res[temp->cnt].gluc))
    ELSEIF (c.normalcy_cd IN (low_cd, extremelow_cd, paniclow_cd))
     temp->res[temp->cnt].gluc = concat("L ",trim(temp->res[temp->cnt].gluc))
    ELSEIF (c.normalcy_cd IN (extremehigh_cd, panichigh_cd, high_cd))
     temp->res[temp->cnt].gluc = concat("H ",trim(temp->res[temp->cnt].gluc))
    ENDIF
   ELSEIF (c.event_cd=finger_cd)
    temp->res[temp->cnt].finger = c.event_tag, temp->res[temp->cnt].finger_note_ind = btest(c
     .subtable_bit_map,1), temp->res[temp->cnt].finger_event_id = c.event_id
    IF (c.normalcy_cd=critical_cd)
     temp->res[temp->cnt].finger = concat("C ",trim(temp->res[temp->cnt].finger))
    ELSEIF (c.normalcy_cd IN (low_cd, extremelow_cd, paniclow_cd))
     temp->res[temp->cnt].finger = concat("L ",trim(temp->res[temp->cnt].finger))
    ELSEIF (c.normalcy_cd IN (extremehigh_cd, panichigh_cd, high_cd))
     temp->res[temp->cnt].finger = concat("H ",trim(temp->res[temp->cnt].finger))
    ENDIF
   ELSEIF (c.event_cd=ins_cd)
    temp->res[temp->cnt].ins = c.event_tag, temp->res[temp->cnt].ins_note_ind = btest(c
     .subtable_bit_map,1), temp->res[temp->cnt].ins_event_id = c.event_id
   ELSEIF (c.event_cd=oral_cd)
    temp->res[temp->cnt].oral = c.event_tag, temp->res[temp->cnt].oral_note_ind = btest(c
     .subtable_bit_map,1), temp->res[temp->cnt].oral_event_id = c.event_id
   ELSEIF (c.event_cd=diet_cd)
    temp->res[temp->cnt].diet = c.event_tag, temp->res[temp->cnt].diet_note_ind = btest(c
     .subtable_bit_map,1), temp->res[temp->cnt].diet_event_id = c.event_id
   ELSEIF (c.event_cd=iv_cd)
    temp->res[temp->cnt].iv = c.event_tag, temp->res[temp->cnt].iv_note_ind = btest(c
     .subtable_bit_map,1), temp->res[temp->cnt].iv_event_id = c.event_id
   ELSEIF (c.event_cd=ster_cd)
    temp->res[temp->cnt].ster = c.event_tag, temp->res[temp->cnt].ster_note_ind = btest(c
     .subtable_bit_map,1), temp->res[temp->cnt].ster_event_id = c.event_id
   ELSEIF (c.event_cd=com_cd)
    temp->res[temp->cnt].com = c.event_tag, temp->res[temp->cnt].com_note_ind = btest(c
     .subtable_bit_map,1), temp->res[temp->cnt].com_event_id = c.event_id
   ELSEIF (c.event_cd=meter_cd)
    temp->res[temp->cnt].meter = c.event_tag, temp->res[temp->cnt].meter_note_ind = btest(c
     .subtable_bit_map,1), temp->res[temp->cnt].meter_event_id = c.event_id
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 FOR (y = 1 TO temp->cnt)
   CALL echo(build("date--",temp->res[y].date))
   CALL echo(build("ster--",temp->res[y].ster))
   CALL echo(build("meter--",temp->res[y].meter))
   CALL echo(build("com--",temp->res[y].com))
   CALL echo(build("lab--",temp->res[y].lab))
   CALL echo(build("iv--",temp->res[y].iv))
   CALL echo(build("diet--",temp->res[y].diet))
   CALL echo(build("oral--",temp->res[y].oral))
   CALL echo(build("ins--",temp->res[y].ins))
   CALL echo(build("finger--",temp->res[y].finger))
   CALL echo(build("gluc--",temp->res[y].gluc))
 ENDFOR
 FOR (y = 1 TO temp->cnt)
   IF ((temp->res[y].lab_note_ind=1))
    SET event_id = temp->res[y].lab_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->res[y].lab_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->res[y].gluc_note_ind=1))
    SET event_id = temp->res[y].gluc_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->res[y].gluc_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->res[y].finger_note_ind=1))
    SET event_id = temp->res[y].finger_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->res[y].finger_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->res[y].ins_note_ind=1))
    SET event_id = temp->res[y].ins_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->res[y].ins_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->res[y].oral_note_ind=1))
    SET event_id = temp->res[y].oral_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->res[y].oral_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->res[y].diet_note_ind=1))
    SET event_id = temp->res[y].diet_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->res[y].diet_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->res[y].iv_note_ind=1))
    SET event_id = temp->res[y].iv_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->res[y].iv_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->res[y].ster_note_ind=1))
    SET event_id = temp->res[y].ster_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->res[y].ster_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->res[y].com_note_ind=1))
    SET event_id = temp->res[y].com_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->res[y].com_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->res[y].meter_note_ind=1))
    SET event_id = temp->res[y].meter_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->res[y].meter_text = concat(trim(blob_out,3))
   ENDIF
 ENDFOR
 FOR (m = 1 TO temp->cnt)
  SET temp->res[m].com_sze = textlen(temp->res[m].com)
  IF ((temp->res[m].com_sze > 12))
   SET pt->line_cnt = 0
   SET max_length = 24
   EXECUTE dcp_parse_text value(temp->res[m].com), value(max_length)
   SET stat = alterlist(temp->res[m].com_list,pt->line_cnt)
   SET temp->res[m].com_ln_cnt = pt->line_cnt
   FOR (x = 1 TO pt->line_cnt)
     SET temp->res[m].com_list[x].com_line = pt->lns[x].line
   ENDFOR
   IF ((pt->line_cnt > i))
    SET i = pt->line_cnt
   ENDIF
  ENDIF
 ENDFOR
 FOR (m = 1 TO temp->cnt)
  SET temp->res[m].ins_sze = textlen(temp->res[m].ins)
  IF ((temp->res[m].ins_sze > 12))
   SET pt->line_cnt = 0
   SET max_length = 24
   EXECUTE dcp_parse_text value(temp->res[m].ins), value(max_length)
   SET stat = alterlist(temp->res[m].ins_list,pt->line_cnt)
   SET temp->res[m].ins_ln_cnt = pt->line_cnt
   FOR (x = 1 TO pt->line_cnt)
     SET temp->res[m].ins_list[x].ins_line = pt->lns[x].line
   ENDFOR
   IF ((pt->line_cnt > g))
    SET g = pt->line_cnt
   ENDIF
  ENDIF
 ENDFOR
 FOR (m = 1 TO temp->cnt)
  SET temp->res[m].oral_sze = textlen(temp->res[m].oral)
  IF ((temp->res[m].oral_sze > 12))
   SET pt->line_cnt = 0
   SET max_length = 24
   EXECUTE dcp_parse_text value(temp->res[m].oral), value(max_length)
   SET stat = alterlist(temp->res[m].oral_list,pt->line_cnt)
   SET temp->res[m].oral_ln_cnt = pt->line_cnt
   FOR (x = 1 TO pt->line_cnt)
     SET temp->res[m].oral_list[x].oral_line = pt->lns[x].line
   ENDFOR
   IF ((pt->line_cnt > h))
    SET h = pt->line_cnt
   ENDIF
  ENDIF
 ENDFOR
 SELECT INTO request->output_device
  d.seq
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD PAGE
   "{ps/792 0 translate 90 rotate/}", row + 1, "{pos/60/45}{f/12}{cpi/13}Patient Name:  ",
   name, row + 1, "{pos/60/57}Date of Birth:  ",
   dob, row + 1, "{pos/60/69}Admitting Physician:  ",
   admitdoc, row + 1, "{pos/320/45}Med Rec Num:  ",
   mrn, row + 1, "{pos/320/57}Age:  ",
   age, row + 1, yyy = concat(trim(unit)," ; ",trim(room)," ; ",trim(bed)),
   "{pos/320/69}Location:  ", yyy, row + 1,
   "{pos/320/81}Financial Num: ", finnbr, row + 1,
   "{pos/275/105}{f/13}Diabetes Flowsheet", row + 1, "{pos/255/117}For  ",
   f = cnvtdatetime(end_dt_tm), u = cnvtdatetime(beg_dt_tm), u"mm/dd/yy hh:mm;;d",
   " - ", f"mm/dd/yy hh:mm;;d", row + 1,
   "{pos/255/119}", q, row + 1,
   "{cpi/16}", row + 1, "{pos/45/155}{u}Procedure",
   row + 1, "{pos/45/170}{f/12}Lab Glucose", row + 1,
   "{pos/45/185}Fingerstick Glucose", row + 1, "{pos/45/200}{u}{f/13}Diabetes Medications",
   row + 1, "{pos/45/215}{f/12}Insulin", row + 1,
   xcol = 45, ycol = 215
   IF (g > 0)
    ycol = (ycol+ (g * 15))
   ELSE
    ycol = (ycol+ 15)
   ENDIF
   CALL print(calcpos(xcol,ycol)), "Oral Agents", row + 1
   IF (h > 0)
    ycol = (ycol+ (h * 15))
   ELSE
    ycol = (ycol+ 15)
   ENDIF
   CALL print(calcpos(xcol,ycol)), "{u}{f/13}Other Parameters", row + 1,
   ycol = (ycol+ 15),
   CALL print(calcpos(xcol,ycol)), "{f/12}Diet",
   row + 1, ycol = (ycol+ 15),
   CALL print(calcpos(xcol,ycol)),
   "IV's with Dextrose", row + 1, ycol = (ycol+ 15),
   CALL print(calcpos(xcol,ycol)), "Steroids", row + 1,
   ycol = (ycol+ 15),
   CALL print(calcpos(xcol,ycol)), "Comments",
   row + 1
   IF (i > 0)
    ycol = (ycol+ (i * 15))
   ELSE
    ycol = (ycol+ 15)
   ENDIF
   CALL print(calcpos(xcol,ycol)), "Meter Number", row + 1,
   xcol = 200, xcol2 = 193
  DETAIL
   FOR (y = 1 TO temp->cnt)
     ycol = 155,
     CALL print(calcpos(xcol,ycol)), "{f/13}{u}",
     temp->res[y].date"mm/dd/yy hh:mm;;d", row + 1, ycol = (ycol+ 15)
     IF ((temp->res[y].lab > " "))
      IF (substring(1,1,temp->res[y].lab) IN ("H", "L", "C"))
       CALL print(calcpos(xcol2,ycol)), "{f/12}", temp->res[y].lab
      ELSE
       CALL print(calcpos(xcol,ycol)), "{f/12}", temp->res[y].lab
      ENDIF
      ycol = (ycol+ 15)
     ELSE
      IF (substring(1,1,temp->res[y].gluc) IN ("H", "L", "C"))
       CALL print(calcpos(xcol2,ycol)), "{f/12}", temp->res[y].gluc
      ELSE
       CALL print(calcpos(xcol,ycol)), "{f/12}", temp->res[y].gluc
      ENDIF
      ycol = (ycol+ 15)
     ENDIF
     IF (substring(1,1,temp->res[y].finger) IN ("H", "L", "C"))
      CALL print(calcpos(xcol2,ycol)), temp->res[y].finger
     ELSE
      CALL print(calcpos(xcol,ycol)), temp->res[y].finger
     ENDIF
     ycol = (ycol+ 30)
     IF ((temp->res[y].ins_sze <= 12))
      CALL print(calcpos(xcol,ycol)), temp->res[y].ins
      IF (g > 0)
       ycol = (ycol+ (g * 15))
      ELSE
       ycol = (ycol+ 15)
      ENDIF
     ELSE
      FOR (x = 1 TO temp->res[y].ins_ln_cnt)
        CALL print(calcpos(xcol,ycol)), temp->res[y].ins_list[x].ins_line, row + 1,
        ycol = (ycol+ 15)
      ENDFOR
     ENDIF
     IF ((temp->res[y].oral_sze <= 12))
      CALL print(calcpos(xcol,ycol)), temp->res[y].oral
      IF (h > 0)
       ycol = (ycol+ (h * 15))
      ELSE
       ycol = (ycol+ 15)
      ENDIF
     ELSE
      FOR (x = 1 TO temp->res[y].oral_ln_cnt)
        CALL print(calcpos(xcol,ycol)), temp->res[y].oral_list[x].oral_line, row + 1,
        ycol = (ycol+ 15)
      ENDFOR
     ENDIF
     ycol = (ycol+ 15),
     CALL print(calcpos(xcol,ycol)), temp->res[y].diet,
     row + 1, ycol = (ycol+ 15),
     CALL print(calcpos(xcol,ycol)),
     temp->res[y].iv, row + 1, ycol = (ycol+ 15),
     CALL print(calcpos(xcol,ycol)), temp->res[y].ster, row + 1,
     ycol = (ycol+ 15)
     IF ((temp->res[y].com_sze <= 12))
      CALL print(calcpos(xcol,ycol)), temp->res[y].com
      IF (i > 0)
       ycol = (ycol+ (i * 15))
      ELSE
       ycol = (ycol+ 15)
      ENDIF
     ELSE
      FOR (x = 1 TO temp->res[y].com_ln_cnt)
        CALL print(calcpos(xcol,ycol)), temp->res[y].com_list[x].com_line, row + 1,
        ycol = (ycol+ 15)
      ENDFOR
     ENDIF
     CALL print(calcpos(xcol,ycol)), temp->res[y].meter, row + 1,
     xcol = (xcol+ 130), xcol2 = (xcol2+ 130)
     IF ((y < temp->cnt))
      IF (xcol > 600)
       BREAK
      ENDIF
     ENDIF
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
