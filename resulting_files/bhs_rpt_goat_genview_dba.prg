CREATE PROGRAM bhs_rpt_goat_genview:dba
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
  SET request->visit[1].encntr_id = 33799532
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
 DECLARE cnt = i4
 FREE RECORD goat
 RECORD goat(
   1 res_cnt = i4
   1 enc[*]
     2 time_stmp = c30
     2 goat_res = c20
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
 SET dta1 = uar_get_code_by("DISPLAYKEY",72,"TOTALGOATSCORE")
 SELECT INTO "NL:"
  c.result_val, time_stamp = format(c.event_end_dt_tm,"mm/dd/yyyy hh:mm;;d")
  FROM clinical_event c
  WHERE (request->visit[1].encntr_id=c.encntr_id)
   AND c.event_cd=dta1
  ORDER BY c.updt_dt_tm DESC, 0
  HEAD REPORT
   cnt = 0, stat = alterlist(goat->enc,10)
  HEAD c.event_id
   cnt = (cnt+ 1), goat->res_cnt = cnt
   IF (mod(cnt,10)=1)
    stat = alterlist(goat->enc,(cnt+ 10))
   ENDIF
  DETAIL
   goat->enc[cnt].time_stmp = trim(time_stamp), goat->enc[cnt].goat_res = trim(c.result_val)
  FOOT REPORT
   stat = alterlist(goat->enc,cnt), goat->res_cnt = cnt
 ;end select
 DECLARE i = i4
 SET reply->text = concat(rhead,rh2bu,"Total GOAT Score",rtab,rtab,
  "Date/Time",rtab,rtab,reol)
 FOR (i = 1 TO size(goat->enc,5))
   SET reply->text = concat(reply->text,rh2r,rtab,goat->enc[i].goat_res,rtab,
    goat->enc[i].time_stmp,reol)
 ENDFOR
 SET reply->text = concat(reply->text,rtfeof)
 CALL echorecord(goat)
END GO
