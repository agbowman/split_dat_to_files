CREATE PROGRAM bhs_rpt_ed_trop_genview:dba
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
  SET request->visit[1].encntr_id = 47274815.00
  SET request->output_device = "MINE"
  SET request->visit_cnt = 1
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data[1]
      2 status = c4
    1 text = gvc
  )
 ENDIF
 FREE RECORD dta
 RECORD dta(
   1 qual[*]
     2 dtatitle = vc
     2 dtainfo[*]
       3 time_stmp = c30
       3 dtaval = vc
 )
 SET rhead = "{\rtf1\ansi \deff0{\fonttbl{\f0\fmodern\fprq1\fcharset0 r_ansi;}}"
 SET rhead = concat(rhead,"{\colortbl;\red0\green0\blue0;\red0\green0\blue255;")
 SET rhead = concat(rhead,"\red0\green255\blue255;\red0\green255\blue0;\red255\green0\blue255;")
 SET rhead = concat(rhead,"\red255\green0\blue0;\red255\green255\blue0;\red255\green255\blue255;")
 SET rhead = concat(rhead,"\red0\green0\blue128;\red0\green128\blue128;\red0\green128\blue0;")
 SET rhead = concat(rhead,"\red128\green0\blue128;\red128\green0\blue0;\red128\green128\blue0;")
 SET rhead = concat(rhead,"\red128\green128\blue128;\red192\green192\blue192;}")
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
 SET pmh = uar_get_code_by("DISPLAYKEY",72,"PMH")
 SET troponintquant = uar_get_code_by("DISPLAYKEY",72,"TROPONINTQUANT")
 CALL echo("test")
 DECLARE cnt = i4
 DECLARE cnt2 = i4
 DECLARE i = i4
 SELECT INTO "NL:"
  c.result_val, time_stamp = format(c.event_end_dt_tm,"mm/dd/yyyy hh:mm;;d")
  FROM clinical_event c
  WHERE (request->visit[1].encntr_id=c.encntr_id)
   AND c.event_cd IN (pmh, troponintquant)
   AND (c.event_end_dt_tm > (sysdate - 1))
   AND c.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
  ORDER BY c.event_cd, c.updt_dt_tm DESC
  HEAD REPORT
   cnt = 0
  HEAD c.event_cd
   cnt2 = 0, cnt = (cnt+ 1), stat = alterlist(dta->qual,cnt),
   dta->qual[cnt].dtatitle = uar_get_code_display(c.event_cd)
  DETAIL
   cnt2 = (cnt2+ 1), stat = alterlist(dta->qual[cnt].dtainfo,cnt2), dta->qual[cnt].dtainfo[cnt2].
   time_stmp = trim(time_stamp,3),
   dta->qual[cnt].dtainfo[cnt2].dtaval = trim(c.result_val,3)
  FOOT REPORT
   stat = alterlist(dta->qual,cnt)
  WITH nocounter
 ;end select
 CALL echorecord(dta)
 SET reply->text = patstring(" ",32000)
 SET reply->text = rhead
 FOR (i = 1 TO size(dta->qual,5))
  SET reply->text = concat(reply->text,rh2bu,dta->qual[i].dtatitle,reol)
  FOR (x = 1 TO size(dta->qual[i].dtainfo,5))
    SET reply->text = concat(reply->text,rh2r,dta->qual[i].dtainfo[x].time_stmp,rtab,trim(check(dta->
       qual[i].dtainfo[x].dtaval),3),
     rtab,reol,reol)
  ENDFOR
 ENDFOR
 SET reply->text = concat(reply->text,rtfeof)
 CALL echo(reply->text)
END GO
