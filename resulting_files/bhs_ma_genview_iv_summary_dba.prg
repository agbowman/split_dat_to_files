CREATE PROGRAM bhs_ma_genview_iv_summary:dba
 IF ( NOT (validate(summary,0)))
  RECORD summary(
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
  SET summary->visit_cnt = 1
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 text = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 RECORD dlrec(
   1 encntr_total = i4
   1 category[4]
     2 ivsite = vc
     2 insertion_dt_tm = dq8
     2 catheter_type = vc
     2 discontinued = vc
     2 discontinued_dt_tm = dq8
     2 ivsite_dt_tm = dq8
     2 ivsite_display = vc
     2 insertion_display = vc
     2 catheter_type_display = vc
     2 discontinued_display = vc
 )
 SET rhead = "{\RTF1\ANSI \DEFF0{\FONTTBL{\F0\FSWISS ARIAL;}}"
 SET rh2r = "\PLAIN \F0 \FS18 \CB2 \PARD\SL0 "
 SET rh2b = "\PLAIN \F0 \FS18 \B \CB2 \PARD\SL0 "
 SET rh2bu = "\PLAIN \F0 \FS18 \B \UL \CB2 \PARD\SL0 "
 SET rh2u = "\PLAIN \F0 \FS18 \U \CB2 \PARD\SL0 "
 SET rh2i = "\PLAIN \F0 \FS18 \I \CB2 \PARD\SL0 "
 SET reol = "\PAR "
 SET rtab = "\TAB "
 SET wr = " \PLAIN \F0 \FS18 "
 SET wb = " \PLAIN \F0 \FS18 \B \CB2 "
 SET wu = " \PLAIN \F0 \FS18 \UL \CB "
 SET wi = " \PLAIN \F0 \FS18 \I \CB2 "
 SET wbi = " \PLAIN \F0 \FS18 \B \I \CB2 "
 SET wiu = " \PLAIN \F0 \FS18 \I \UL \CB2 "
 SET wbiu = " \PLAIN \F0 \FS18 \B \UL \I \CB2 "
 SET rtfeof = "}"
 DECLARE last_title = vc WITH public, noconstant(" ")
 DECLARE title_string = vc WITH public, noconstant(" ")
 DECLARE tempstring = vc WITH public, noconstant(" ")
 DECLARE temp = vc WITH public, noconstant(" ")
 DECLARE print_string = vc WITH public, noconstant(" ")
 DECLARE line1 = vc WITH public, constant(fillstring(100,"_"))
 DECLARE filler = vc WITH public, constant(fillstring(100," "))
 DECLARE line2 = vc WITH public, noconstant(" ")
 DECLARE cnt = i4 WITH public, noconstant(0)
 DECLARE inerror_var = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",8,"INERROR"))
 DECLARE ivsitei_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"IVSITEI"))
 DECLARE datetimeofinsertioni_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "DATETIMEOFINSERTIONI"))
 DECLARE cathetertypei_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"CATHETERTYPEI")
  )
 DECLARE discontinuereasoni_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "DISCONTINUEREASONI"))
 SET dlrec->category[1].ivsite_display = uar_get_code_display(ivsitei_cd)
 SET dlrec->category[1].insertion_display = uar_get_code_display(datetimeofinsertioni_cd)
 SET dlrec->category[1].catheter_type_display = uar_get_code_display(cathetertypei_cd)
 SET dlrec->category[1].discontinued_display = uar_get_code_display(discontinuereasoni_cd)
 DECLARE ivsiteii_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"IVSITEII"))
 DECLARE datetimeofinsertionii_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "DATETIMEOFINSERTIONII"))
 DECLARE cathetertypeii_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "CATHETERTYPEII"))
 DECLARE discontinuereasonii_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "DISCONTINUEREASONII"))
 SET dlrec->category[2].ivsite_display = uar_get_code_display(ivsiteii_cd)
 SET dlrec->category[2].insertion_display = uar_get_code_display(datetimeofinsertionii_cd)
 SET dlrec->category[2].catheter_type_display = uar_get_code_display(cathetertypeii_cd)
 SET dlrec->category[2].discontinued_display = uar_get_code_display(discontinuereasonii_cd)
 DECLARE ivsiteiii_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"IVSITEIII"))
 DECLARE datetimeofinsertioniii_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "DATETIMEOFINSERTIONIII"))
 DECLARE cathetertypeiii_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "CATHETERTYPEIII"))
 DECLARE discontinuereasoniii_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "DISCONTINUEREASONIII"))
 SET dlrec->category[3].ivsite_display = uar_get_code_display(ivsiteiii_cd)
 SET dlrec->category[3].insertion_display = uar_get_code_display(datetimeofinsertioniii_cd)
 SET dlrec->category[3].catheter_type_display = uar_get_code_display(cathetertypeiii_cd)
 SET dlrec->category[3].discontinued_display = uar_get_code_display(discontinuereasoniii_cd)
 DECLARE ivsiteiv_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,"IVSITEIV"))
 DECLARE datetimeofinsertioniv_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "DATETIMEOFINSERTIONIV"))
 DECLARE cathetertypeiv_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "CATHETERTYPEIV"))
 DECLARE discontinuereasoniv_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",72,
   "DISCONTINUEREASONIV"))
 SET dlrec->category[4].ivsite_display = uar_get_code_display(ivsiteiv_cd)
 SET dlrec->category[4].insertion_display = uar_get_code_display(datetimeofinsertioniv_cd)
 SET dlrec->category[4].catheter_type_display = uar_get_code_display(cathetertypeiv_cd)
 SET dlrec->category[4].discontinued_display = uar_get_code_display(discontinuereasoniv_cd)
 SELECT DISTINCT INTO "NL:"
  FROM clinical_event c,
   ce_date_result cdr
  PLAN (c
   WHERE (request->visit[1].encntr_id=c.encntr_id)
    AND c.event_cd IN (ivsitei_cd, datetimeofinsertioni_cd, cathetertypei_cd, discontinuereasoni_cd,
   ivsiteii_cd,
   datetimeofinsertionii_cd, cathetertypeii_cd, discontinuereasonii_cd, ivsiteiii_cd,
   datetimeofinsertioniii_cd,
   cathetertypeiii_cd, discontinuereasoniii_cd, ivsiteiv_cd, datetimeofinsertioniv_cd,
   cathetertypeiv_cd,
   discontinuereasoniv_cd)
    AND c.view_level=1
    AND c.publish_flag=1
    AND c.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
    AND c.result_status_cd != inerror_var
    AND c.event_tag > " ")
   JOIN (cdr
   WHERE outerjoin(c.event_id)=cdr.event_id
    AND c.valid_until_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
  ORDER BY c.event_cd, cnvtdatetime(c.event_end_dt_tm)
  DETAIL
   IF (c.event_cd=ivsitei_cd)
    dlrec->category[1].ivsite = trim(c.result_val,3), dlrec->category[1].ivsite_dt_tm = c
    .event_end_dt_tm
   ELSEIF (c.event_cd=datetimeofinsertioni_cd)
    dlrec->category[1].insertion_dt_tm = cdr.result_dt_tm
   ELSEIF (c.event_cd=cathetertypei_cd)
    dlrec->category[1].catheter_type = trim(c.result_val,3)
   ELSEIF (c.event_cd=discontinuereasoni_cd)
    dlrec->category[1].discontinued = trim(c.result_val,3), dlrec->category[1].discontinued_dt_tm = c
    .event_end_dt_tm
   ELSEIF (c.event_cd=ivsiteii_cd)
    dlrec->category[2].ivsite = trim(c.result_val,3), dlrec->category[2].ivsite_dt_tm = c
    .event_end_dt_tm
   ELSEIF (c.event_cd=datetimeofinsertionii_cd)
    dlrec->category[2].insertion_dt_tm = cdr.result_dt_tm
   ELSEIF (c.event_cd=cathetertypeii_cd)
    dlrec->category[2].catheter_type = trim(c.result_val,3)
   ELSEIF (c.event_cd=discontinuereasonii_cd)
    dlrec->category[2].discontinued = trim(c.result_val,3), dlrec->category[2].discontinued_dt_tm = c
    .event_end_dt_tm
   ELSEIF (c.event_cd=ivsiteiii_cd)
    dlrec->category[3].ivsite = trim(c.result_val,3), dlrec->category[3].ivsite_dt_tm = c
    .event_end_dt_tm
   ELSEIF (c.event_cd=datetimeofinsertioniii_cd)
    dlrec->category[3].insertion_dt_tm = cdr.result_dt_tm
   ELSEIF (c.event_cd=cathetertypeiii_cd)
    dlrec->category[3].catheter_type = trim(c.result_val,3)
   ELSEIF (c.event_cd=discontinuereasoniii_cd)
    dlrec->category[3].discontinued = trim(c.result_val,3), dlrec->category[3].discontinued_dt_tm = c
    .event_end_dt_tm
   ELSEIF (c.event_cd=ivsiteiv_cd)
    dlrec->category[4].ivsite = trim(c.result_val,3), dlrec->category[4].ivsite_dt_tm = c
    .event_end_dt_tm
   ELSEIF (c.event_cd=datetimeofinsertioniv_cd)
    dlrec->category[4].insertion_dt_tm = cdr.result_dt_tm
   ELSEIF (c.event_cd=cathetertypeiv_cd)
    dlrec->category[4].catheter_type = trim(c.result_val,3)
   ELSEIF (c.event_cd=discontinuereasoniv_cd)
    dlrec->category[4].discontinued = trim(c.result_val,3), dlrec->category[4].discontinued_dt_tm = c
    .event_end_dt_tm
   ENDIF
  FOOT REPORT
   FOR (cat = 1 TO 4)
     IF ((dlrec->category[cat].ivsite > " ")
      AND (dlrec->category[cat].discontinued > " "))
      IF ((dlrec->category[cat].insertion_dt_tm > dlrec->category[cat].discontinued_dt_tm))
       dlrec->category[cat].discontinued = " ", dlrec->category[cat].discontinued_dt_tm = 0
      ENDIF
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM dummyt d1
  HEAD REPORT
   print_flag = 0, gline_cnt = 0,
   MACRO (gpage_heading)
    temp = concat(rhead,rh2bu,"    IV INSERTION SUMMARY ",wr,reol), addtoreply
   ENDMACRO
   ,
   MACRO (parse_string)
    limit = 0, maxlen = 80
    WHILE (tempstring > " "
     AND limit < 1000)
      ii = 0, limit = (limit+ 1), pos = 0
      WHILE (pos=0)
       ii = (ii+ 1),
       IF (substring((maxlen - ii),1,tempstring) IN (" ", ",", "."))
        pos = (maxlen - ii)
       ELSEIF (ii=maxlen)
        pos = maxlen
       ENDIF
      ENDWHILE
      printstring = substring(1,pos,tempstring), temp = concat("     ",print_string,reol), addtoreply,
      tempstring = substring((pos+ 1),9999,tempstring)
    ENDWHILE
   ENDMACRO
   ,
   MACRO (gtitle_print)
    reply->text = concat(reply->text,wu,title_string," ",wr,
     " ",reol)
   ENDMACRO
   ,
   MACRO (addtoreply)
    reply->text = concat(reply->text,temp), gline_cnt = (gline_cnt+ 1)
    IF (gline_cnt > 60)
     gline_cnt = 0
    ENDIF
   ENDMACRO
   ,
   gpage_heading
  DETAIL
   temp = ""
   FOR (cat = 1 TO 4)
     temp = concat(wb,dlrec->category[cat].ivsite_display,": ",wr," ",
      dlrec->category[cat].ivsite," ",reol), addtoreply, temp = concat(wb,dlrec->category[cat].
      insertion_display,": ",wr," ",
      format(dlrec->category[cat].insertion_dt_tm,"@SHORTDATETIME")," ",reol),
     addtoreply, temp = concat(wb,dlrec->category[cat].catheter_type_display,": ",wr," ",
      dlrec->category[cat].catheter_type," ",reol), addtoreply,
     temp = concat(wb,dlrec->category[cat].discontinued_display,": ",wr," ",
      format(dlrec->category[cat].discontinued_dt_tm,"@SHORTDATETIME")," ",dlrec->category[cat].
      discontinued," ",reol), addtoreply, temp = reol,
     addtoreply
   ENDFOR
  WITH noforms
 ;end select
 SET reply->status_data.status = "S"
 SET reply->text = concat(reply->text,rtfeof)
 FREE RECORD dlrec
 FREE RECORD summary
END GO
