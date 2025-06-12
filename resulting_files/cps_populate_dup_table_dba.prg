CREATE PROGRAM cps_populate_dup_table:dba
 FREE SET dup_list
 RECORD dup_list(
   1 qual_knt = i4
   1 qual[*]
     2 primary_id = f8
     2 delete_id = f8
     2 now_dt_tm = vc
     2 mnemonic = vc
     2 short_string = vc
 )
 SET true = 1
 SET false = 0
 SET dvar = 0
 RECORD err_log(
   1 msg_qual = i4
   1 msg[*]
     2 err_msg = vc
 )
 SET msg_knt = 0
 SET err_log->msg_qual = msg_knt
 SET err_level = 0
 SET errmsg = fillstring(132," ")
 SET errcode = 0
 SET log_file = "CPS_POP_NOMEN_DUP_HOLD.LOG"
 FREE DEFINE rtl2
 DEFINE rtl2 "NOMEN_DUPLICATE.IDS"
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("CPS_POP_NOMEN_DUP_HOLD begin : ",format(cnvtdatetime(
    curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 SELECT INTO "nl:"
  the_line = r.line
  FROM rtl2t r
  HEAD REPORT
   knt = 0, stat = alterlist(dup_list->qual,10)
  DETAIL
   line1 = fillstring(500," "), line2 = fillstring(500," "), line3 = fillstring(500," "),
   line4 = fillstring(500," ")
   IF (the_line > " ")
    knt = (knt+ 1)
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(dup_list->qual,(knt+ 9))
    ENDIF
    line1 = the_line, parse1 = findstring("<:>",line1,1), dup_list->qual[knt].primary_id = cnvtreal(
     substring(1,(parse1 - 1),the_line)),
    line2 = trim(substring((parse1+ 3),500,line1)), parse2 = findstring("<:>",line2,1), dup_list->
    qual[knt].delete_id = cnvtreal(substring(1,(parse2 - 1),line2)),
    line3 = trim(substring((parse2+ 3),500,line2)), parse3 = findstring("<:>",line3,1), dup_list->
    qual[knt].mnemonic = trim(substring(1,(parse3 - 1),line3)),
    line4 = trim(substring((parse3+ 3),500,line3)), parse4 = findstring("<:>",line4,1), dup_list->
    qual[knt].short_string = trim(substring(1,(parse4 - 1),line4)),
    dup_list->qual[knt].now_dt_tm = trim(substring((parse4+ 3),25,line4))
   ENDIF
  FOOT REPORT
   dup_list->qual_knt = knt, stat = alterlist(dup_list->qual,knt)
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,1)
 IF (errcode > 1)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = errmsg
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat("   ERROR> Failed to find ",
   "CCLUSERDIR:NOMEN_DUPLICATES.IDS")
  SET err_level = 2
  GO TO exit_script
 ENDIF
 INSERT  FROM nomen_dup_hold n,
   (dummyt d  WITH seq = value(dup_list->qual_knt))
  SET d.seq = 1, n.primary_nomen_id = dup_list->qual[d.seq].primary_id, n.delete_nomen_id = dup_list
   ->qual[d.seq].delete_id,
   n.updt_dt_tm = cnvtdatetime(dup_list->qual[d.seq].now_dt_tm), n.mnemonic = trim(substring(1,25,
     dup_list->qual[d.seq].mnemonic)), n.short_string = trim(substring(1,60,dup_list->qual[d.seq].
     short_string))
  PLAN (d
   WHERE d.seq > 0)
   JOIN (n
   WHERE 0=0)
  WITH nocounter
 ;end insert
 SET errcode = error(errmsg,1)
 IF (errcode > 1)
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = errmsg
  SET msg_knt = (msg_knt+ 1)
  SET stat = alterlist(err_log->msg,msg_knt)
  SET err_log->msg[msg_knt].err_msg = concat(
   "   ERROR> Failed to insert into Nomen_Dup_Hold correctly")
  SET err_level = 2
  GO TO exit_script
 ENDIF
#exit_script
 IF (err_level > 0)
  SET the_status = "FAILURE"
  ROLLBACK
 ELSE
  SET the_status = "SUCCESS"
  COMMIT
 ENDIF
 SET msg_knt = (msg_knt+ 1)
 SET stat = alterlist(err_log->msg,msg_knt)
 SET err_log->msg[msg_knt].err_msg = concat("CPS_POP_NOMEN_DUP_HOLD   END :",trim(the_status),"  ",
  format(cnvtdatetime(curdate,curtime3),"dd-mmm-yyyy hh:mm:ss;;d"))
 CALL error_logging(dvar)
 GO TO end_program
 SUBROUTINE error_logging(lvar)
  SET err_log->msg_qual = msg_knt
  SELECT INTO value(log_file)
   out_string = substring(1,132,err_log->msg[d.seq].err_msg)
   FROM (dummyt d  WITH seq = value(err_log->msg_qual))
   PLAN (d
    WHERE d.seq > 0)
   DETAIL
    row + 1, col 0, out_string
   WITH nocounter, append, format = variable,
    noformfeed, maxrow = value((msg_knt+ 1)), maxcol = 150
  ;end select
 END ;Subroutine
#end_program
END GO
