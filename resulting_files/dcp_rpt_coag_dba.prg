CREATE PROGRAM dcp_rpt_coag:dba
 SET ptt_cd = 111093
 SET act_cd = 111100
 SET pro_cd = 111089
 SET inr_cd = 111201
 SET plt_cd = 111125
 SET hgb_cd = 111108
 SET hct_cd = 111110
 SET coum_cd = 227353
 SET hepu_cd = 227427
 SET hepb_cd = 227426
 SET other_cd = 227513
 RECORD temp(
   1 cnt = i2
   1 res[*]
     2 date = dq8
     2 doc = vc
     2 rind = vc
     2 ptt = vc
     2 ptt_note_ind = i2
     2 ptt_event_id = f8
     2 ptt_text = vc
     2 act = vc
     2 act_note_ind = i2
     2 act_event_id = f8
     2 act_text = vc
     2 pro = vc
     2 pro_note_ind = i2
     2 pro_event_id = f8
     2 pro_text = vc
     2 inr = vc
     2 inr_note_ind = i2
     2 inr_event_id = f8
     2 inr_text = vc
     2 plt = vc
     2 plt_note_ind = i2
     2 plt_event_id = f8
     2 plt_text = vc
     2 hgb = vc
     2 hgb_note_ind = i2
     2 hgb_event_id = f8
     2 hgb_text = vc
     2 hct = vc
     2 hct_note_ind = i2
     2 hct_event_id = f8
     2 hct_text = vc
     2 coum = vc
     2 coum_sze = i2
     2 coum_ln_cnt = i2
     2 coum_list[*]
       3 coum_line = vc
     2 coum_note_ind = i2
     2 coum_event_id = f8
     2 coum_text = vc
     2 hepu = vc
     2 hepu_sze = i2
     2 hepu_ln_cnt = i2
     2 hepu_list[*]
       3 hepu_line = vc
     2 hepu_note_ind = i2
     2 hepu_event_id = f8
     2 hepu_text = vc
     2 hepb = vc
     2 hepb_sze = i2
     2 hepb_ln_cnt = i2
     2 hepb_list[*]
       3 hepb_line = vc
     2 hepb_note_ind = i2
     2 hepb_event_id = f8
     2 hepb_text = vc
     2 other = vc
     2 other_sze = i2
     2 other_ln_cnt = i2
     2 other_list[*]
       3 other_line = vc
     2 other_note_ind = i2
     2 other_event_id = f8
     2 other_text = vc
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
 SET code_set = 319
 SET cdf_meaning = "FIN NBR"
 EXECUTE cpm_get_cd_for_cdf
 SET finnbr_cd = code_value
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
    AND c.event_cd IN (ptt_cd, act_cd, pro_cd, inr_cd, plt_cd,
   hgb_cd, hct_cd, coum_cd, hepb_cd, hepu_cd,
   other_cd)
    AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
    AND c.event_end_dt_tm >= cnvtdatetime(beg_dt_tm)
    AND c.event_end_dt_tm <= cnvtdatetime(end_dt_tm))
   JOIN (d)
   JOIN (pl
   WHERE c.performed_prsnl_id=pl.person_id)
  ORDER BY cnvtdatetime(c.event_end_dt_tm)
  HEAD REPORT
   temp->cnt = 0
  HEAD c.event_end_dt_tm
   temp->cnt = (temp->cnt+ 1)
  DETAIL
   stat = alterlist(temp->res,temp->cnt), temp->res[temp->cnt].date = c.event_end_dt_tm
   IF (c.event_cd=ptt_cd)
    temp->res[temp->cnt].ptt = c.event_tag, temp->res[temp->cnt].ptt_note_ind = btest(c
     .subtable_bit_map,1), temp->res[temp->cnt].ptt_event_id = c.event_id
    IF (c.normalcy_cd=critical_cd)
     temp->res[temp->cnt].ptt = concat("C ",trim(temp->res[temp->cnt].ptt))
    ELSEIF (c.normalcy_cd IN (low_cd, extremelow_cd, paniclow_cd))
     temp->res[temp->cnt].ptt = concat("L ",trim(temp->res[temp->cnt].ptt))
    ELSEIF (c.normalcy_cd IN (extremehigh_cd, panichigh_cd, high_cd))
     temp->res[temp->cnt].ptt = concat("H ",trim(temp->res[temp->cnt].ptt))
    ENDIF
   ELSEIF (c.event_cd=act_cd)
    temp->res[temp->cnt].act = c.event_tag, temp->res[temp->cnt].act_note_ind = btest(c
     .subtable_bit_map,1), temp->res[temp->cnt].act_event_id = c.event_id
    IF (c.normalcy_cd=critical_cd)
     temp->res[temp->cnt].act = concat("C ",trim(temp->res[temp->cnt].act))
    ELSEIF (c.normalcy_cd IN (low_cd, extremelow_cd, paniclow_cd))
     temp->res[temp->cnt].act = concat("L ",trim(temp->res[temp->cnt].act))
    ELSEIF (c.normalcy_cd IN (extremehigh_cd, panichigh_cd, high_cd))
     temp->res[temp->cnt].act = concat("H ",trim(temp->res[temp->cnt].act))
    ENDIF
   ELSEIF (c.event_cd=pro_cd)
    temp->res[temp->cnt].pro = c.event_tag, temp->res[temp->cnt].pro_note_ind = btest(c
     .subtable_bit_map,1), temp->res[temp->cnt].pro_event_id = c.event_id
    IF (c.normalcy_cd=critical_cd)
     temp->res[temp->cnt].pro = concat("C ",trim(temp->res[temp->cnt].pro))
    ELSEIF (c.normalcy_cd IN (low_cd, extremelow_cd, paniclow_cd))
     temp->res[temp->cnt].pro = concat("L ",trim(temp->res[temp->cnt].pro))
    ELSEIF (c.normalcy_cd IN (extremehigh_cd, panichigh_cd, high_cd))
     temp->res[temp->cnt].pro = concat("H ",trim(temp->res[temp->cnt].pro))
    ENDIF
   ELSEIF (c.event_cd=inr_cd)
    temp->res[temp->cnt].inr = c.event_tag, temp->res[temp->cnt].inr_note_ind = btest(c
     .subtable_bit_map,1), temp->res[temp->cnt].inr_event_id = c.event_id
    IF (c.normalcy_cd=critical_cd)
     temp->res[temp->cnt].inr = concat("C ",trim(temp->res[temp->cnt].inr))
    ELSEIF (c.normalcy_cd IN (low_cd, extremelow_cd, paniclow_cd))
     temp->res[temp->cnt].inr = concat("L ",trim(temp->res[temp->cnt].inr))
    ELSEIF (c.normalcy_cd IN (extremehigh_cd, panichigh_cd, high_cd))
     temp->res[temp->cnt].inr = concat("H ",trim(temp->res[temp->cnt].inr))
    ENDIF
   ELSEIF (c.event_cd=plt_cd)
    temp->res[temp->cnt].plt = c.event_tag, temp->res[temp->cnt].plt_note_ind = btest(c
     .subtable_bit_map,1), temp->res[temp->cnt].plt_event_id = c.event_id
    IF (c.normalcy_cd=critical_cd)
     temp->res[temp->cnt].plt = concat("C ",trim(temp->res[temp->cnt].plt))
    ELSEIF (c.normalcy_cd IN (low_cd, extremelow_cd, paniclow_cd))
     temp->res[temp->cnt].plt = concat("L ",trim(temp->res[temp->cnt].plt))
    ELSEIF (c.normalcy_cd IN (extremehigh_cd, panichigh_cd, high_cd))
     temp->res[temp->cnt].plt = concat("H ",trim(temp->res[temp->cnt].plt))
    ENDIF
   ELSEIF (c.event_cd=hgb_cd)
    temp->res[temp->cnt].hgb = c.event_tag, temp->res[temp->cnt].hgb_note_ind = btest(c
     .subtable_bit_map,1), temp->res[temp->cnt].hgb_event_id = c.event_id
    IF (c.normalcy_cd=critical_cd)
     temp->res[temp->cnt].hgb = concat("C ",trim(temp->res[temp->cnt].hgb))
    ELSEIF (c.normalcy_cd IN (low_cd, extremelow_cd, paniclow_cd))
     temp->res[temp->cnt].hgb = concat("L ",trim(temp->res[temp->cnt].hgb))
    ELSEIF (c.normalcy_cd IN (extremehigh_cd, panichigh_cd, high_cd))
     temp->res[temp->cnt].hgb = concat("H ",trim(temp->res[temp->cnt].hgb))
    ENDIF
   ELSEIF (c.event_cd=hct_cd)
    temp->res[temp->cnt].hct = c.event_tag, temp->res[temp->cnt].hct_note_ind = btest(c
     .subtable_bit_map,1), temp->res[temp->cnt].hct_event_id = c.event_id
    IF (c.normalcy_cd=critical_cd)
     temp->res[temp->cnt].hct = concat("C ",trim(temp->res[temp->cnt].hct))
    ELSEIF (c.normalcy_cd IN (low_cd, extremelow_cd, paniclow_cd))
     temp->res[temp->cnt].hct = concat("L ",trim(temp->res[temp->cnt].hct))
    ELSEIF (c.normalcy_cd IN (extremehigh_cd, panichigh_cd, high_cd))
     temp->res[temp->cnt].hct = concat("H ",trim(temp->res[temp->cnt].hct))
    ENDIF
   ELSEIF (c.event_cd=coum_cd)
    temp->res[temp->cnt].coum = c.event_tag, temp->res[temp->cnt].coum_note_ind = btest(c
     .subtable_bit_map,1), temp->res[temp->cnt].coum_event_id = c.event_id
   ELSEIF (c.event_cd=hepu_cd)
    temp->res[temp->cnt].hepu = c.event_tag, temp->res[temp->cnt].hepu_note_ind = btest(c
     .subtable_bit_map,1), temp->res[temp->cnt].hepu_event_id = c.event_id
   ELSEIF (c.event_cd=hepb_cd)
    temp->res[temp->cnt].hepb = c.event_tag, temp->res[temp->cnt].hepb_note_ind = btest(c
     .subtable_bit_map,1), temp->res[temp->cnt].hepb_event_id = c.event_id
   ELSEIF (c.event_cd=other_cd)
    temp->res[temp->cnt].other = c.event_tag, temp->res[temp->cnt].other_note_ind = btest(c
     .subtable_bit_map,1), temp->res[temp->cnt].other_event_id = c.event_id
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
 FOR (y = 1 TO temp->cnt)
   IF ((temp->res[y].ptt_note_ind=1))
    SET event_id = temp->res[y].ptt_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->res[y].ptt_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->res[y].act_note_ind=1))
    SET event_id = temp->res[y].act_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->res[y].act_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->res[y].pro_note_ind=1))
    SET event_id = temp->res[y].pro_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->res[y].pro_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->res[y].inr_note_ind=1))
    SET event_id = temp->res[y].inr_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->res[y].inr_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->res[y].plt_note_ind=1))
    SET event_id = temp->res[y].plt_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->res[y].plt_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->res[y].hgb_note_ind=1))
    SET event_id = temp->res[y].hgb_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->res[y].hgb_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->res[y].hct_note_ind=1))
    SET event_id = temp->res[y].hct_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->res[y].hct_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->res[y].coum_note_ind=1))
    SET event_id = temp->res[y].coum_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->res[y].coum_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->res[y].hepu_note_ind=1))
    SET event_id = temp->res[y].hepu_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->res[y].hepu_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->res[y].hepb_note_ind=1))
    SET event_id = temp->res[y].hepb_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->res[y].hepb_text = concat(trim(blob_out,3))
   ENDIF
   IF ((temp->res[y].other_note_ind=1))
    SET event_id = temp->res[y].other_event_id
    EXECUTE FROM get_note_begin TO get_note_end
    SET temp->res[y].other_text = concat(trim(blob_out,3))
   ENDIF
 ENDFOR
 FOR (m = 1 TO temp->cnt)
  SET temp->res[m].coum_sze = textlen(temp->res[m].coum)
  IF ((temp->res[m].coum_sze > 12))
   SET pt->line_cnt = 0
   SET max_length = 12
   EXECUTE dcp_parse_text value(temp->res[m].coum), value(max_length)
   SET stat = alterlist(temp->res[m].coum_list,pt->line_cnt)
   SET temp->res[m].coum_ln_cnt = pt->line_cnt
   FOR (x = 1 TO pt->line_cnt)
     SET temp->res[m].coum_list[x].coum_line = pt->lns[x].line
   ENDFOR
   IF ((pt->line_cnt > i))
    SET i = pt->line_cnt
   ENDIF
  ENDIF
 ENDFOR
 FOR (m = 1 TO temp->cnt)
  SET temp->res[m].hepu_sze = textlen(temp->res[m].hepu)
  IF ((temp->res[m].hepu_sze > 12))
   SET pt->line_cnt = 0
   SET max_length = 12
   EXECUTE dcp_parse_text value(temp->res[m].hepu), value(max_length)
   SET stat = alterlist(temp->res[m].hepu_list,pt->line_cnt)
   SET temp->res[m].hepu_ln_cnt = pt->line_cnt
   FOR (x = 1 TO pt->line_cnt)
     SET temp->res[m].hepu_list[x].hepu_line = pt->lns[x].line
   ENDFOR
   IF ((pt->line_cnt > g))
    SET g = pt->line_cnt
   ENDIF
  ENDIF
 ENDFOR
 FOR (m = 1 TO temp->cnt)
  SET temp->res[m].hepb_sze = textlen(temp->res[m].hepb)
  IF ((temp->res[m].hepb_sze > 12))
   SET pt->line_cnt = 0
   SET max_length = 12
   EXECUTE dcp_parse_text value(temp->res[m].hepb), value(max_length)
   SET stat = alterlist(temp->res[m].hepb_list,pt->line_cnt)
   SET temp->res[m].hepb_ln_cnt = pt->line_cnt
   FOR (x = 1 TO pt->line_cnt)
     SET temp->res[m].hepb_list[x].hepb_line = pt->lns[x].line
   ENDFOR
   IF ((pt->line_cnt > h))
    SET h = pt->line_cnt
   ENDIF
  ENDIF
 ENDFOR
 FOR (m = 1 TO temp->cnt)
  SET temp->res[m].other_sze = textlen(temp->res[m].other)
  IF ((temp->res[m].other_sze > 12))
   SET pt->line_cnt = 0
   SET max_length = 12
   EXECUTE dcp_parse_text value(temp->res[m].other), value(max_length)
   SET stat = alterlist(temp->res[m].other_list,pt->line_cnt)
   SET temp->res[m].other_ln_cnt = pt->line_cnt
   FOR (x = 1 TO pt->line_cnt)
     SET temp->res[m].other_list[x].other_line = pt->lns[x].line
   ENDFOR
  ENDIF
 ENDFOR
 SELECT INTO request->output_device
  d.seq
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD PAGE
   "{ps/792 0 translate 90 rotate/}", row + 1, "{cpi/13}",
   row + 1, "{pos/60/45}{f/12}Patient Name:  ", name,
   row + 1, "{pos/60/57}Date of Birth:  ", dob,
   row + 1, "{pos/60/69}Admitting Physician:  ", admitdoc,
   row + 1, "{pos/320/45}Med Rec Num:  ", mrn,
   row + 1, "{pos/320/57}Age:  ", age,
   row + 1, yyy = concat(trim(unit)," ; ",trim(room)," ; ",trim(bed)), "{pos/320/69}Location:  ",
   yyy, row + 1, "{pos/320/81}Financial Num: ",
   finnbr, row + 1, "{pos/262/105}{f/13}Anticoagulant Flowsheet",
   row + 1, "{pos/255/117}For  ", f = cnvtdatetime(end_dt_tm),
   u = cnvtdatetime(beg_dt_tm), u"mm/dd/yy hh:mm;;d", " - ",
   f"mm/dd/yy hh:mm;;d", row + 1, "{pos/255/119}",
   q, row + 1, "{cpi/16}",
   row + 1, "{pos/45/170}{u}PTT", row + 1,
   "{pos/45/185}{u}ACT", row + 1, "{pos/45/200}{u}Protime",
   row + 1, "{pos/45/215}{u}INR", row + 1,
   "{pos/45/230}{u}PLT", row + 1, "{pos/45/245}{u}Hgb",
   row + 1, "{pos/45/260}{u}Hct", row + 1,
   "{pos/45/275}{u}Coumadin Dosage", row + 1, xcol = 45,
   ycol = 275
   IF (i > 0)
    ycol = (ycol+ (i * 15))
   ELSE
    ycol = (ycol+ 15)
   ENDIF
   CALL print(calcpos(xcol,ycol)), "{u}Heparin Units/Hr", row + 1
   IF (g > 0)
    ycol = (ycol+ (g * 15))
   ELSE
    ycol = (ycol+ 15)
   ENDIF
   CALL print(calcpos(xcol,ycol)), "{u}Heparin Bolus", row + 1
   IF (h > 0)
    ycol = (ycol+ (h * 15))
   ELSE
    ycol = (ycol+ 15)
   ENDIF
   CALL print(calcpos(xcol,ycol)), "{u}Other", row + 1,
   xcol = 200, xcol2 = 193
  DETAIL
   FOR (y = 1 TO temp->cnt)
     ycol = 155,
     CALL print(calcpos(xcol,ycol)), "{f/13}{u}",
     temp->res[y].date"hh:mm;;m", row + 1, ycol = (ycol+ 15)
     IF (substring(1,1,temp->res[y].ptt) IN ("H", "L", "C"))
      CALL print(calcpos(xcol2,ycol)), "{f/12}", temp->res[y].ptt
     ELSE
      CALL print(calcpos(xcol,ycol)), "{f/12}", temp->res[y].ptt
     ENDIF
     ycol = (ycol+ 15)
     IF (substring(1,1,temp->res[y].act) IN ("H", "L", "C"))
      CALL print(calcpos(xcol2,ycol)), temp->res[y].act
     ELSE
      CALL print(calcpos(xcol,ycol)), temp->res[y].act
     ENDIF
     ycol = (ycol+ 15)
     IF (substring(1,1,temp->res[y].pro) IN ("H", "L", "C"))
      CALL print(calcpos(xcol2,ycol)), temp->res[y].pro
     ELSE
      CALL print(calcpos(xcol,ycol)), temp->res[y].pro
     ENDIF
     ycol = (ycol+ 15)
     IF (substring(1,1,temp->res[y].inr) IN ("H", "L", "C"))
      CALL print(calcpos(xcol2,ycol)), temp->res[y].inr
     ELSE
      CALL print(calcpos(xcol,ycol)), temp->res[y].inr
     ENDIF
     ycol = (ycol+ 15)
     IF (substring(1,1,temp->res[y].plt) IN ("H", "L", "C"))
      CALL print(calcpos(xcol2,ycol)), temp->res[y].plt
     ELSE
      CALL print(calcpos(xcol,ycol)), temp->res[y].plt
     ENDIF
     ycol = (ycol+ 15)
     IF (substring(1,1,temp->res[y].hgb) IN ("H", "L", "C"))
      CALL print(calcpos(xcol2,ycol)), temp->res[y].hgb
     ELSE
      CALL print(calcpos(xcol,ycol)), temp->res[y].hgb
     ENDIF
     ycol = (ycol+ 15)
     IF (substring(1,1,temp->res[y].hct) IN ("H", "L", "C"))
      CALL print(calcpos(xcol2,ycol)), temp->res[y].hct
     ELSE
      CALL print(calcpos(xcol,ycol)), temp->res[y].hct
     ENDIF
     ycol = (ycol+ 15)
     IF ((temp->res[y].coum_sze <= 12))
      CALL print(calcpos(xcol,ycol)), temp->res[y].coum
      IF (i > 0)
       ycol = (ycol+ (i * 15))
      ELSE
       ycol = (ycol+ 15)
      ENDIF
     ELSE
      FOR (x = 1 TO temp->res[y].coum_ln_cnt)
        CALL print(calcpos(xcol,ycol)), temp->res[y].coum_list[x].coum_line, row + 1,
        ycol = (ycol+ 15)
      ENDFOR
     ENDIF
     IF ((temp->res[y].hepu_sze <= 12))
      CALL print(calcpos(xcol,ycol)), temp->res[y].hepu
      IF (g > 0)
       ycol = (ycol+ (g * 15))
      ELSE
       ycol = (ycol+ 15)
      ENDIF
     ELSE
      FOR (x = 1 TO temp->res[y].hepu_ln_cnt)
        CALL print(calcpos(xcol,ycol)), temp->res[y].hepu_list[x].hepu_line, row + 1,
        ycol = (ycol+ 15)
      ENDFOR
     ENDIF
     IF ((temp->res[y].hepb_sze <= 12))
      CALL print(calcpos(xcol,ycol)), temp->res[y].hepb
      IF (h > 0)
       ycol = (ycol+ (h * 15))
      ELSE
       ycol = (ycol+ 15)
      ENDIF
     ELSE
      FOR (x = 1 TO temp->res[y].hepb_ln_cnt)
        CALL print(calcpos(xcol,ycol)), temp->res[y].hepb_list[x].hepb_line, row + 1,
        ycol = (ycol+ 15)
      ENDFOR
     ENDIF
     IF ((temp->res[y].other_sze <= 12))
      CALL print(calcpos(xcol,ycol)), temp->res[y].other
     ELSE
      FOR (x = 1 TO temp->res[y].other_ln_cnt)
        CALL print(calcpos(xcol,ycol)), temp->res[y].other_list[x].other_line, row + 1,
        ycol = (ycol+ 15)
      ENDFOR
     ENDIF
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
