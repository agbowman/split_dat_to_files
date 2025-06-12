CREATE PROGRAM ct_stratum_susp_g_func:dba
 SET false = 0
 SET true = 1
 SET stratum_susp_g_func_status = "F"
 SET stratum_susp_g_func_cnts = 0
 SET stratum_susp_g_func_new = 0
 SET stratum_susp_g_func_s = 0
 SET cval = 0.0
 SET cmean = fillstring(12," ")
 CALL echo("find the suspensions of this stratum")
 SELECT INTO "nl:"
  susp.*
  FROM prot_stratum_susp susp
  PLAN (susp
   WHERE (susp.stratum_id=reply->ss[stratum_susp_g_func_ssindex].stratum_id)
    AND susp.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  ORDER BY susp.begin_effective_dt_tm
  DETAIL
   stratum_susp_g_func_cnts = (stratum_susp_g_func_cnts+ 1)
   IF (mod(stratum_susp_g_func_cnts,10)=1)
    stratum_susp_g_func_new = (stratum_susp_g_func_cnts+ 10), stat = alterlist(reply->susps,
     stratum_susp_g_func_new)
   ENDIF
   reply->ss[stratum_susp_g_func_ssindex].susps[stratum_susp_g_func_cnts].susp_id = susp.susp_id,
   reply->ss[stratum_susp_g_func_ssindex].susps[stratum_susp_g_func_cnts].prot_stratum_susp_id = susp
   .prot_stratum_susp_id, reply->ss[stratum_susp_g_func_ssindex].susps[stratum_susp_g_func_cnts].
   stratum_id = susp.stratum_id,
   reply->ss[stratum_susp_g_func_ssindex].susps[stratum_susp_g_func_cnts].reason_cd = susp.reason_cd,
   reply->ss[stratum_susp_g_func_ssindex].susps[stratum_susp_g_func_cnts].comment_txt = susp
   .comment_txt, reply->ss[stratum_susp_g_func_ssindex].susps[stratum_susp_g_func_cnts].
   susp_effective_dt_tm = susp.susp_effective_dt_tm,
   reply->ss[stratum_susp_g_func_ssindex].susps[stratum_susp_g_func_cnts].susp_end_dt_tm = susp
   .susp_end_dt_tm, reply->ss[stratum_susp_g_func_ssindex].susps[stratum_susp_g_func_cnts].updt_cnt
    = susp.updt_cnt
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->ss[stratum_susp_g_func_ssindex].susps,stratum_susp_g_func_cnts)
 SET stratum_susp_g_func_status = "S"
 IF (func_doecho=false)
  GO TO noecho
 ENDIF
 IF (stratum_susp_g_func_cnts > 0)
  CALL echo(" -----------------------------------------------------------")
 ENDIF
 FOR (stratum_susp_g_func_s = 1 TO stratum_susp_g_func_cnts)
   CALL echo(build(" Reply->Ss[",stratum_susp_g_func_ssindex,"]->Susps[",stratum_susp_g_func_s,
     "]->susp_id =",
     reply->ss[stratum_susp_g_func_ssindex].susps[stratum_susp_g_func_s].susp_id))
   CALL echo(build(" Reply->Ss[",stratum_susp_g_func_ssindex,"]->Susps[",stratum_susp_g_func_s,
     "]->prot_stratum_susp_id =",
     reply->ss[stratum_susp_g_func_ssindex].susps[stratum_susp_g_func_s].prot_stratum_susp_id))
   CALL echo(build(" Reply->Ss[",stratum_susp_g_func_ssindex,"]->Susps[",stratum_susp_g_func_s,
     "]->stratum_id =",
     reply->ss[stratum_susp_g_func_ssindex].susps[stratum_susp_g_func_s].stratum_id))
   CALL echo(build(" Reply->Ss[",stratum_susp_g_func_ssindex,"]->Susps[",stratum_susp_g_func_s,
     "]->reason_cd =",
     reply->ss[stratum_susp_g_func_ssindex].susps[stratum_susp_g_func_s].reason_cd))
   CALL echo(build(" Reply->Ss[",stratum_susp_g_func_ssindex,"]->Susps[",stratum_susp_g_func_s,
     "]->comment_txt =",
     reply->ss[stratum_susp_g_func_ssindex].susps[stratum_susp_g_func_s].comment_txt))
   CALL echo(build(" Reply->Ss[",stratum_susp_g_func_ssindex,"]->Susps[",stratum_susp_g_func_s,
     "]->susp_effective_dt_tm =",
     reply->ss[stratum_susp_g_func_ssindex].susps[stratum_susp_g_func_s].susp_effective_dt_tm))
   CALL echo(build(" Reply->Ss[",stratum_susp_g_func_ssindex,"]->Susps[",stratum_susp_g_func_s,
     "]->susp_end_dt_tm =",
     reply->ss[stratum_susp_g_func_ssindex].susps[stratum_susp_g_func_s].susp_end_dt_tm))
   CALL echo(build(" Reply->Ss[",stratum_susp_g_func_ssindex,"]->Susps[",stratum_susp_g_func_s,
     "]->updt_cnt =",
     reply->ss[stratum_susp_g_func_ssindex].susps[stratum_susp_g_func_s].updt_cnt))
   CALL echo(" -----------------------------------------------------------")
 ENDFOR
#noecho
 SET debug_code_stemp = fillstring(999," ")
 SET debug_code_ecode = 1
 SET debug_code_cntd = size(reply->debug,5)
 WHILE (debug_code_ecode != 0)
  SET debug_code_ecode = error(debug_code_stemp,0)
  IF (debug_code_ecode != 0)
   SET debug_code_cntd = (debug_code_cntd+ 1)
   SET stat = alterlist(reply->debug,debug_code_cntd)
   SET reply->debug[debug_code_cntd].str = debug_code_stemp
  ENDIF
 ENDWHILE
END GO
