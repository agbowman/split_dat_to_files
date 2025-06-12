CREATE PROGRAM cern_dcp_rpt_vitals:dba
 DECLARE temp_cd = f8
 DECLARE pulse_cd = f8
 DECLARE resp_cd = f8
 DECLARE sbp_cd = f8
 DECLARE dbp_cd = f8
 DECLARE xxx = vc
 DECLARE xcol = i4
 DECLARE ycol = i4
 DECLARE code_value = f8
 DECLARE code_set = f8
 DECLARE cdf_meaning = vc
 DECLARE name = vc
 DECLARE age = vc
 DECLARE dob = vc
 DECLARE mrn = vc
 DECLARE admitdoc = vc
 DECLARE unit = vc
 DECLARE room = vc
 DECLARE bed = vc
 DECLARE finnbr = vc
 DECLARE yyy = vc
 DECLARE person_id = f8
 DECLARE ops_ind = c1
 DECLARE beg_ind = i2
 DECLARE end_ind = i2
 DECLARE beg_dt_tm = dq8
 DECLARE end_dt_tm = dq8
 DECLARE x2 = vc
 DECLARE x3 = vc
 DECLARE abc = vc
 DECLARE xyz = vc
 DECLARE offset = i2 WITH protect, noconstant(0)
 DECLARE daylight = i2 WITH protect, noconstant(0)
 SET temp_cd = 0
 SET pulse_cd = 0
 SET resp_cd = 0
 SET sbp_cd = 0
 SET dbp_cd = 0
 RECORD temp(
   1 cnt = i2
   1 v[*]
     2 date = vc
     2 doc = vc
     2 t = vc
     2 p = vc
     2 r = vc
     2 s = vc
     2 d = vc
 )
 SET xxx = fillstring(20," ")
 SET xcol = 0
 SET ycol = 0
 SET code_value = 0.0
 SET code_set = 0.0
 SET cdf_meaning = fillstring(12," ")
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
 SET person_id = 0
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
   SET end_dt_tm = cnvtdatetime((curdate - 1),235959)
  ELSE
   SET beg_dt_tm = cnvtdatetime(curdate,0)
   SET end_dt_tm = cnvtdatetime(curdate,curtime)
  ENDIF
 ENDIF
 SET code_set = 319
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
 SET code_set = 8
 SET cdf_meaning = "INERROR"
 EXECUTE cpm_get_cd_for_cdf
 SET error_cd = code_value
 SELECT INTO "nl:"
  FROM person p,
   encounter e,
   encntr_alias ea2,
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
   JOIN (ea2
   WHERE ea2.encntr_id=e.encntr_id
    AND ea2.encntr_alias_type_cd=mrn_alias_cd
    AND ea2.active_ind=1)
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
    = datetimezoneformat(p.birth_dt_tm,p.birth_tz,"@SHORTDATE"),
   mrn = substring(1,20,cnvtalias(ea2.alias,ea2.alias_pool_cd)), finnbr = substring(1,20,ea.alias),
   admitdoc = substring(1,30,pl.name_full_formatted),
   unit = substring(1,20,uar_get_code_display(e.loc_nurse_unit_cd)), room = substring(1,10,
    uar_get_code_display(e.loc_room_cd)), bed = substring(1,10,uar_get_code_display(e.loc_bed_cd)),
   reg_dt_tm = cnvtdatetime(e.reg_dt_tm), person_id = e.person_id
  WITH nocounter, outerjoin = d1, dontcare = ea2,
   dontcare = epr, outerjoin = d2, outerjoin = d3,
   dontcare = ea
 ;end select
 SELECT INTO "nl:"
  FROM clinical_event c,
   prsnl pl
  PLAN (c
   WHERE c.person_id=person_id
    AND (c.encntr_id=request->visit[1].encntr_id)
    AND c.event_cd IN (temp_cd, resp_cd, pulse_cd, sbp_cd, dbp_cd)
    AND c.view_level=1
    AND c.publish_flag=1
    AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
    AND c.event_end_dt_tm >= cnvtdatetime(beg_dt_tm)
    AND c.event_end_dt_tm <= cnvtdatetime(end_dt_tm)
    AND c.result_status_cd != error_cd)
   JOIN (pl
   WHERE c.performed_prsnl_id=pl.person_id)
  ORDER BY c.event_end_dt_tm DESC, c.parent_event_id
  HEAD REPORT
   temp->cnt = 0
  HEAD c.parent_event_id
   temp->cnt = (temp->cnt+ 1)
  DETAIL
   stat = alterlist(temp->v,temp->cnt), temp->v[temp->cnt].date = concat(format(datetimezone(c
      .event_end_dt_tm,c.event_end_tz),"@SHORTDATETIME")," ",datetimezonebyindex(c.event_end_tz,
     offset,daylight,7,c.event_end_dt_tm)), temp->v[temp->cnt].doc = pl.name_full_formatted
   IF (c.event_cd=temp_cd)
    temp->v[temp->cnt].t = c.event_tag
   ELSEIF (c.event_cd=pulse_cd)
    temp->v[temp->cnt].p = c.event_tag
   ELSEIF (c.event_cd=resp_cd)
    temp->v[temp->cnt].r = c.event_tag
   ELSEIF (c.event_cd=sbp_cd)
    temp->v[temp->cnt].s = c.event_tag
   ELSEIF (c.event_cd=dbp_cd)
    temp->v[temp->cnt].d = c.event_tag
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO request->output_device
  d.seq
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD PAGE
   "{pos/60/40}{f/8}{cpi/13}Patient Name:  ", name, row + 1,
   "{pos/60/50}Date of Birth:  ", dob, row + 1,
   "{pos/60/60}Admitting Physician:  ", admitdoc, row + 1,
   "{pos/370/40}Med Rec Num:  ", mrn, row + 1,
   "{pos/370/50}Age:  ", age, row + 1,
   yyy = concat(trim(unit),"/",trim(room),"/",trim(bed)), "{pos/370/60}Location:  ", yyy,
   row + 1, "{pos/230/85}{f/9}{cpi/11}Vital Signs Summary", row + 1,
   f = cnvtdatetime(end_dt_tm), u = cnvtdatetime(beg_dt_tm), "{pos/205/97}",
   u"@SHORTDATETIME", " - ", f"@SHORTDATETIME",
   row + 1, "{f/8}{cpi/13}", row + 1,
   "{pos/158/130}{b}{u}Temp", row + 1, "{pos/218/130}{b}{u}HR",
   row + 1, "{pos/273/130}{b}{u}RR", row + 1,
   "{pos/323/130}{b}{u}BP", row + 1, "{pos/408/130}{b}{u}Performed By",
   row + 1
  DETAIL
   ycol = 144
   FOR (y = 1 TO temp->cnt)
     xcol = 60,
     CALL print(calcpos(xcol,ycol)), temp->v[y].date,
     row + 1, xcol = 158,
     CALL print(calcpos(xcol,ycol)),
     temp->v[y].t, row + 1, xcol = 218,
     CALL print(calcpos(xcol,ycol)), temp->v[y].p, row + 1,
     xcol = 273,
     CALL print(calcpos(xcol,ycol)), temp->v[y].r,
     row + 1
     IF ((((temp->v[y].s > " ")) OR ((temp->v[y].d > " "))) )
      xxx = concat(trim(temp->v[y].s)," / ",trim(temp->v[y].d)), xcol = 323,
      CALL print(calcpos(xcol,ycol)),
      xxx, row + 1
     ENDIF
     xcol = 408,
     CALL print(calcpos(xcol,ycol)), temp->v[y].doc,
     row + 1, ycol = (ycol+ 15)
     IF (ycol > 680)
      BREAK
     ENDIF
   ENDFOR
  FOOT PAGE
   ycol = 750, xcol = 250,
   CALL print(calcpos(xcol,ycol)),
   "Page ", curpage"##", row + 1,
   xcol = 310,
   CALL print(calcpos(xcol,ycol)), curdate,
   " ", curtime, row + 1
  WITH nocounter, dio = postscript, maxcol = 300,
   maxrow = 300
 ;end select
#exit_program
END GO
