CREATE PROGRAM cclhelp:dba
 PAINT
 SET scroll_cnt = 0
 SET scroll_len = 60
 SET scroll_title = concat("CCL HELP Version",format((((currev * 10000)+ (currevminor * 100))+
   currevminor2),"(######);p0"))
 SET scroll_info[20] = fillstring(60," ")
 SET menu_main = 1
#l_cclhelp_begin
 SET accept = video(b)
 SET cclhelp_menu = menu_main
 SET cnt = 0
 SET cnt += 1
 SET topic_exit = cnt
 SET scroll_info[cnt] = format(cnt,"##) EXIT;rp0")
 SET cnt += 1
 SET topic_news = cnt
 SET scroll_info[cnt] = format(cnt,"##) NEWS;rp0")
 SET cnt += 1
 SET topic_questions = cnt
 SET scroll_info[cnt] = format(cnt,"##) QUESTIONS;rp0")
 SET cnt += 1
 SET topic_trace = cnt
 SET scroll_info[cnt] = format(cnt,"##) TRACE;rp0")
 SET cnt += 1
 SET topic_variables = cnt
 SET scroll_info[cnt] = format(cnt,"##) VARIABLES;rp0")
 SET cnt += 1
 SET topic_directives = cnt
 SET scroll_info[cnt] = format(cnt,"##) DIRECTIVES;rp0")
 SET cnt += 1
 SET topic_dio = cnt
 SET scroll_info[cnt] = format(cnt,"##) DIO;rp0")
 SET cnt += 1
 SET topic_oracle = cnt
 SET scroll_info[cnt] = format(cnt,"##) ORACLE;rp0")
 SET cnt += 1
 SET topic_sqlserver = cnt
 SET scroll_info[cnt] = format(cnt,"##) SQLSERVER;rp0")
 SET cnt += 1
 SET topic_rdbms = cnt
 SET scroll_info[cnt] = format(cnt,"##) RDBMS;rp0")
 SET cnt += 1
 SET topic_limits = cnt
 SET scroll_info[cnt] = format(cnt,"##) LIMITS;rp0")
 SET cnt += 1
 SET topic_debugger = cnt
 SET scroll_info[cnt] = format(cnt,"##) DEBUGGER;rp0")
 SET cnt += 1
 SET topic_metasymbols = cnt
 SET scroll_info[cnt] = format(cnt,"##) METASYMBOLS;rp0")
 SET cnt += 1
 SET topic_functions = cnt
 SET scroll_info[cnt] = format(cnt,"##) FUNCTIONS;rp0")
 SET cnt += 1
 SET topic_commands = cnt
 SET scroll_info[cnt] = format(cnt,"##) COMMANDS;rp0")
 SET cnt += 1
 SET topic_cclrtl = cnt
 SET scroll_info[cnt] = format(cnt,"##) CCLRTL;rp0")
 SET cnt += 1
 SET topic_doc = cnt
 SET scroll_info[cnt] = format(cnt,"##) DOC;rp0")
 SET scroll_cnt = cnt
 SET srowoff = 02
 SET scoloff = 10
 SET numsrow = scroll_cnt
 SET numscol = scroll_len
 SET maxcnt = scroll_cnt
 SET scroll_cnt = 1
 CALL text(24,1,"Select ")
 CALL box(srowoff,scoloff,((srowoff+ numsrow)+ 1),((scoloff+ numscol)+ 1))
 CALL text(srowoff,(scoloff+ 5),scroll_title)
 CALL scrollinit((srowoff+ 1),(scoloff+ 1),(srowoff+ numsrow),(scoloff+ numscol))
 WHILE (scroll_cnt <= numsrow)
  CALL scrolltext(scroll_cnt,scroll_info[scroll_cnt])
  SET scroll_cnt += 1
 ENDWHILE
 SET scroll_cnt = 1
 SET arow = 1
#l_cclhelp_pick
 SET scroll_pick = 0
 WHILE (scroll_pick=0)
  CALL accept(24,10,"999;S",0)
  CASE (curscroll)
   OF 0:
    IF (curaccept=0)
     SET scroll_pick = scroll_cnt
     GO TO l_cclhelp_run
    ELSEIF (cnvtint(curaccept) BETWEEN 1 AND maxcnt)
     SET scroll_pick = cnvtint(curaccept)
     GO TO l_cclhelp_run
    ENDIF
   OF 1:
    IF (scroll_cnt < maxcnt)
     SET scroll_cnt += 1
     IF (arow=numsrow)
      CALL scrolldown(arow,arow,scroll_info[scroll_cnt])
     ELSE
      SET arow += 1
      CALL scrolldown((arow - 1),arow,scroll_info[scroll_cnt])
     ENDIF
    ENDIF
   OF 2:
    IF (scroll_cnt > 1)
     SET scroll_cnt -= 1
     IF (arow=1)
      CALL scrollup(arow,arow,scroll_info[scroll_cnt])
     ELSE
      SET arow -= 1
      CALL scrollup((arow+ 1),arow,scroll_info[scroll_cnt])
     ENDIF
    ENDIF
  ENDCASE
 ENDWHILE
 GO TO l_cclhelp_pick
#l_cclhelp_run
 SET scroll_cnt = maxcnt
 CASE (scroll_pick)
  OF topic_exit:
   GO TO l_cclhelp_done
  OF topic_trace:
   EXECUTE cclhelp_topic "TRACE"
  OF topic_variables:
   EXECUTE cclhelp_topic "VARIABLES"
  OF topic_oracle:
   EXECUTE cclhelp_topic "ORACLE"
  OF topic_sqlserver:
   EXECUTE cclhelp_topic "SQLSERVER"
  OF topic_rdbms:
   EXECUTE cclhelp_topic "RDBMS"
  OF topic_commands:
   EXECUTE cclhelp_topic "COMMANDS"
  OF topic_directives:
   EXECUTE cclhelp_topic "DIRECTIVES"
  OF topic_metasymbols:
   EXECUTE cclhelp_topic "METASYMBOLS"
  OF topic_functions:
   EXECUTE cclhelp_topic "FUNCTIONS"
  OF topic_debugger:
   EXECUTE cclhelp_topic "DEBUGGER"
  OF topic_cclrtl:
   EXECUTE cclhelp_topic "CCLRTL"
  OF topic_dio:
   EXECUTE cclhelp_topic "DIO"
  OF topic_limits:
   EXECUTE cclhelp_topic "LIMITS"
  OF topic_questions:
   EXECUTE cclhelp_topic "QUESTIONS"
  OF topic_news:
   EXECUTE cclnews
  OF topic_doc:
   EXECUTE rtlview "mine", "ccldir:cclhelp.dat"
 ENDCASE
 SET scroll_pick = 0
 GO TO l_cclhelp_begin
#l_cclhelp_done
 CALL clear(1,1)
END GO
