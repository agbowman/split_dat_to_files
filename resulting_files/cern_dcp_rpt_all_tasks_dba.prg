CREATE PROGRAM cern_dcp_rpt_all_tasks:dba
 RECORD temp(
   1 cnt = i2
   1 qual[*]
     2 date = vc
     2 description = vc
     2 desc_cnt = i2
     2 desc_qual[*]
       3 desc_line = vc
     2 details = vc
     2 det_cnt = i2
     2 det_qual[*]
       3 det_line = vc
     2 status = vc
 )
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 DECLARE code_set = f8
 DECLARE code_value = f8
 DECLARE cdf_meaning = vc
 DECLARE age = vc
 DECLARE dob = vc
 DECLARE sex = vc
 DECLARE mrn = vc
 DECLARE fnbr = vc
 DECLARE date = vc
 DECLARE attenddoc = vc
 DECLARE name = vc
 DECLARE unit = vc
 DECLARE room = vc
 DECLARE bed = vc
 DECLARE location = vc
 DECLARE person_id = f8
 DECLARE encntr_id = f8
 DECLARE ops_ind = c1
 DECLARE beg_ind = i2
 DECLARE end_ind = i2
 DECLARE x2 = vc
 DECLARE x3 = vc
 DECLARE abc = vc
 DECLARE xyz = vc
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET age = fillstring(15," ")
 SET dob = fillstring(15," ")
 SET sex = fillstring(40," ")
 SET mrn = fillstring(20," ")
 SET fnbr = fillstring(20," ")
 SET date = fillstring(30," ")
 SET attenddoc = fillstring(30," ")
 SET name = fillstring(30," ")
 SET unit = fillstring(20," ")
 SET room = fillstring(20," ")
 SET bed = fillstring(20," ")
 SET location = fillstring(50," ")
 SET person_id = 0
 SET encntr_id = 0
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
 DECLARE printed_date = vc WITH constant(datetimezoneformat(cnvtdatetime(curdate,curtime3),
   curtimezoneapp,"MM/DD/YY HH:mm ZZZ"))
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
 SELECT INTO "nl:"
  FROM encounter e,
   person p,
   (dummyt d1  WITH seq = 1),
   encntr_alias ea2,
   (dummyt d2  WITH seq = 1),
   encntr_alias ea,
   (dummyt d3  WITH seq = 1),
   encntr_prsnl_reltn epr,
   prsnl pl
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
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=finnbr_cd
    AND ea.active_ind=1)
   JOIN (d3)
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND epr.encntr_prsnl_r_cd=attend_doc_cd
    AND epr.active_ind=1
    AND ((epr.expiration_ind != 1) OR (epr.expiration_ind = null)) )
   JOIN (pl
   WHERE pl.person_id=epr.prsnl_person_id)
  HEAD REPORT
   age = trim(cnvtage(cnvtdate(p.birth_dt_tm),curdate),3), dob = format(p.birth_dt_tm,"@SHORTDATE"),
   name = substring(1,30,p.name_full_formatted),
   sex = substring(1,40,uar_get_code_display(p.sex_cd)), mrn = substring(1,20,cnvtalias(ea2.alias,ea2
     .alias_pool_cd)), fnbr = substring(1,20,cnvtalias(ea.alias,ea.alias_pool_cd)),
   attenddoc = substring(1,30,pl.name_full_formatted), unit = substring(1,20,uar_get_code_display(e
     .loc_nurse_unit_cd)), room = substring(1,10,uar_get_code_display(e.loc_room_cd)),
   bed = substring(1,10,uar_get_code_display(e.loc_bed_cd)), location = concat(trim(unit),"/",trim(
     room),"/",trim(bed)), date = format(e.reg_dt_tm,"@SHORTDATE"),
   person_id = e.person_id, encntr_id = e.encntr_id
  WITH nocounter, outerjoin = d1, dontcare = ea2,
   outerjoin = d2, dontcare = ea, outerjoin = d3,
   dontcare = epr
 ;end select
 SELECT INTO "nl:"
  FROM task_activity ta,
   order_task ot,
   orders o
  PLAN (ta
   WHERE ta.person_id=person_id
    AND ta.encntr_id=encntr_id
    AND ta.task_dt_tm >= cnvtdatetime(beg_dt_tm)
    AND ta.task_dt_tm <= cnvtdatetime(end_dt_tm))
   JOIN (ot
   WHERE ot.reference_task_id=ta.reference_task_id)
   JOIN (o
   WHERE o.order_id=ta.order_id)
  ORDER BY ta.task_dt_tm
  HEAD REPORT
   temp->cnt = 0
  DETAIL
   temp->cnt = (temp->cnt+ 1), stat = alterlist(temp->qual,temp->cnt), temp->qual[temp->cnt].date =
   datetimezoneformat(ta.task_dt_tm,ta.task_tz,"@SHORTDATETIME"),
   temp->qual[temp->cnt].status = uar_get_code_display(ta.task_status_cd), temp->qual[temp->cnt].
   description = ot.task_description, temp->qual[temp->cnt].details = o.clinical_display_line
  WITH nocounter
 ;end select
 FOR (x = 1 TO temp->cnt)
   SET pt->line_cnt = 0
   SET max_length = 55
   EXECUTE dcp_parse_text value(temp->qual[x].details), value(max_length)
   SET stat = alterlist(temp->qual[x].det_qual,pt->line_cnt)
   SET temp->qual[x].det_cnt = pt->line_cnt
   FOR (w = 1 TO pt->line_cnt)
     SET temp->qual[x].det_qual[w].det_line = pt->lns[w].line
   ENDFOR
   SET pt->line_cnt = 0
   SET max_length = 30
   EXECUTE dcp_parse_text value(temp->qual[x].description), value(max_length)
   SET stat = alterlist(temp->qual[x].desc_qual,pt->line_cnt)
   SET temp->qual[x].desc_cnt = pt->line_cnt
   FOR (w = 1 TO pt->line_cnt)
     SET temp->qual[x].desc_qual[w].desc_line = pt->lns[w].line
   ENDFOR
 ENDFOR
 SELECT INTO request->output_device
  d1.seq
  FROM (dummyt d1  WITH seq = 1)
  PLAN (d1)
  HEAD REPORT
   xcol = 0, ycol = 0, scol = 0,
   zcol = 0, line_cnt = 0
  HEAD PAGE
   "{cpi/8}{f/12}", row + 1, "{pos/235/50}{b}ALL TASKS",
   row + 1, "{cpi/12}{f/8}", row + 1,
   "{pos/30/70}{b}Name: {endb}", name, row + 1,
   "{pos/30/82}{b}MRN: {endb}", mrn, row + 1,
   "{pos/30/94}{b}Location: {endb}", location, row + 1,
   "{pos/30/130}{b}{u}Task Date/Time", row + 1, "{pos/120/130}{b}{u}Task Description",
   row + 1, "{pos/250/130}{b}{u}Details", row + 1,
   "{pos/500/130}{b}{u}Task Status", row + 1, "{cpi/14}",
   row + 1, ycol = 145
  DETAIL
   FOR (x = 1 TO temp->cnt)
     line_cnt = temp->qual[x].det_cnt, add_line_ind = 0
     IF ((temp->qual[x].desc_cnt > line_cnt))
      line_cnt = temp->qual[x].desc_cnt, add_line_ind = 1
     ENDIF
     IF ((((line_cnt * 10)+ ycol) > 710))
      BREAK
     ENDIF
     xcol = 30,
     CALL print(calcpos(xcol,ycol)), temp->qual[x].date,
     row + 1, xcol = 500,
     CALL print(calcpos(xcol,ycol)),
     temp->qual[x].status, row + 1, xcol = 120,
     scol = ycol
     FOR (z = 1 TO temp->qual[x].desc_cnt)
       CALL print(calcpos(xcol,ycol)), temp->qual[x].desc_qual[z].desc_line, row + 1,
       ycol = (ycol+ 10), zcol = ycol
     ENDFOR
     ycol = scol, xcol = 250
     FOR (z = 1 TO temp->qual[x].det_cnt)
       CALL print(calcpos(xcol,ycol)), temp->qual[x].det_qual[z].det_line, row + 1,
       ycol = (ycol+ 10)
     ENDFOR
     IF (add_line_ind=1)
      ycol = zcol, ycol = (ycol+ 5)
     ELSE
      ycol = (ycol+ 5)
     ENDIF
   ENDFOR
  FOOT PAGE
   "{pos/200/750}Page: ", curpage"##", row + 1,
   "{pos/275/750}Print Date/Time: ", printed_date, row + 1
  WITH nocounter, maxrow = 800, maxcol = 800,
   dio = postscript
 ;end select
#exit_script
END GO
