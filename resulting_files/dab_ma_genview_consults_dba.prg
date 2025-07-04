CREATE PROGRAM dab_ma_genview_consults:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 output_device = vc
    1 script_name = vc
    1 person_cnt = i4
    1 person[*]
      2 person_id = f8
    1 visit_cnt = i4
    1 visit[1]
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
  SET request->visit[1].encntr_id = 1135322
  SET request->visit_cnt = 1
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
 FREE RECORD dlrec
 RECORD dlrec(
   1 encntr_total = i4
   1 seq[*]
     2 orders_total = i4
     2 orders[*]
       3 order_mnemonic = vc
       3 order_detail_display_line = vc
       3 clinical_display_line = vc
 )
 SET rhead = "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Arial;}}"
 SET rh2r = "\plain \f0 \fs18 \cb2 \pard\sl0 "
 SET rh2b = "\plain \f0 \fs18 \b \cb2 \pard\sl0 "
 SET rh2bu = "\plain \f0 \fs18 \b \ul \cb2 \pard\sl0 "
 SET rh2u = "\plain \f0 \fs18 \u \cb2 \pard\sl0 "
 SET rh2i = "\plain \f0 \fs18 \i \cb2 \pard\sl0 "
 SET reol = "\par "
 SET rtab = "\tab "
 SET wr = " \plain \f0 \fs18 "
 SET wb = " \plain \f0 \fs18 \b \cb2 "
 SET wu = " \plain \f0 \fs18 \ul \cb "
 SET wi = " \plain \f0 \fs18 \i \cb2 "
 SET wbi = " \plain \f0 \fs18 \b \i \cb2 "
 SET wiu = " \plain \f0 \fs18 \i \ul \cb2 "
 SET wbiu = " \plain \f0 \fs18 \b \ul \i \cb2 "
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
 DECLARE o_incomplete_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"INCOMPLETE"))
 DECLARE o_inprocess_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"INPROCESS"))
 DECLARE o_ordered_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE o_pending_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"PENDING"))
 DECLARE o_suspended_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"SUSPENDED"))
 DECLARE o_pending_rev_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"PENDING REV"))
 DECLARE o_completed_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
 DECLARE inerror_cd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE order_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE physther_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"PHYS THER"))
 DECLARE occther_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"OCC THER"))
 DECLARE speechther_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"SPEECH THER"))
 DECLARE audiology_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"AUDIOLOGY"))
 DECLARE antepartum_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"ANTEPARTUM"))
 DECLARE neurodiag_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"NEURODIAG"))
 DECLARE pulmlab_cd = f8 WITH public, constant(uar_get_code_by("MEANING",6000,"PULM LAB"))
 DECLARE noninvasivecardiologytxprocedures_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",
   106,"NONINVASIVECARDIOLOGYTXPROCEDURES"))
 DECLARE mdtornconsults_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "MDTORNCONSULTS"))
 CALL echo(mdtornconsults_cd)
 DECLARE consults_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,"CONSULTS"))
 CALL echo(mdtornconsults_cd)
 DECLARE hyperbaricoxygentx_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "HYPERBARICOXYGENTX"))
 DECLARE mdtorntxprocedures_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "MDTORNTXPROCEDURES"))
 DECLARE dialysistxprocedures_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",106,
   "DIALYSISTXPROCEDURES"))
 SET stat = alterlist(dlrec->seq,request->visit_cnt)
 SELECT INTO "nl:"
  sort_order =
  IF (o.catalog_type_cd=physther_cd) 1
  ELSEIF (o.catalog_type_cd=occther_cd) 2
  ELSEIF (o.catalog_type_cd=speechther_cd) 3
  ELSEIF (o.catalog_type_cd=audiology_cd) 4
  ELSEIF (o.catalog_type_cd=antepartum_cd) 5
  ELSEIF (o.activity_type_cd=consults_cd) 6
  ELSEIF (o.activity_type_cd=mdtornconsults_cd) 7
  ELSEIF (o.catalog_type_cd=neurodiag_cd) 8
  ELSEIF (o.catalog_type_cd=pulmlab_cd) 9
  ELSEIF (o.activity_type_cd=hyperbaricoxygentx_cd) 10
  ELSEIF (o.activity_type_cd=noninvasivecardiologytxprocedures_cd) 11
  ELSEIF (o.activity_type_cd=mdtorntxprocedures_cd) 12
  ELSEIF (o.activity_type_cd=dialysistxprocedures_cd) 13
  ELSE 99
  ENDIF
  FROM orders o
  PLAN (o
   WHERE (o.encntr_id=request->visit[1].encntr_id)
    AND ((o.order_status_cd+ 0) IN (o_incomplete_cd, o_inprocess_cd, o_ordered_cd, o_pending_cd,
   o_pending_rev_cd))
    AND o.template_order_flag IN (0, 1)
    AND o.orderable_type_flag=0
    AND ((o.catalog_type_cd IN (physther_cd, occther_cd, speechther_cd, audiology_cd, antepartum_cd,
   neurodiag_cd, pulmlab_cd)) OR (o.activity_type_cd IN (noninvasivecardiologytxprocedures_cd,
   hyperbaricoxygentx_cd, mdtornconsults_cd, consults_cd, mdtorntxprocedures_cd,
   dialysistxprocedures_cd))) )
  ORDER BY o.encntr_id, sort_order, cnvtdatetime(o.orig_order_dt_tm),
   o.order_id
  HEAD o.encntr_id
   cnt = 0, stat = alterlist(dlrec->seq[1].orders,10)
  DETAIL
   cnt = (cnt+ 1),
   CALL echo(build(request->visit[1].encntr_id,cnt))
   IF (mod(cnt,10)=1)
    stat = alterlist(dlrec->seq[1].orders,(cnt+ 10))
   ENDIF
   dlrec->seq[1].orders[cnt].order_mnemonic = o.order_mnemonic, dlrec->seq[1].orders[cnt].
   clinical_display_line = o.clinical_display_line
  FOOT  o.encntr_id
   stat = alterlist(dlrec->seq[1].orders,cnt), dlrec->seq[1].orders_total = cnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dummyt
  HEAD REPORT
   print_flag = 0, gline_cnt = 0,
   MACRO (gpage_heading)
    temp = concat(rhead,rh2bu," Procedures/Consults ",wr,reol), addtoreply
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
   IF ((dlrec->encntr_total=0))
    dlrec->encntr_total = 1
   ENDIF
   temp = " "
   FOR (i = 1 TO dlrec->encntr_total)
     FOR (a = 1 TO dlrec->seq[i].orders_total)
      temp = concat(wb,dlrec->seq[i].orders[a].order_mnemonic,": ",wr," ",
       dlrec->seq[i].orders[a].clinical_display_line," ",reol),addtoreply
     ENDFOR
     temp = reol, addtoreply
   ENDFOR
  WITH noforms
 ;end select
 SET reply->status_data.status = "S"
 SET reply->text = concat(reply->text,rtfeof)
 CALL echo(reply->text)
 FREE RECORD dlrec
 FREE RECORD request
END GO
