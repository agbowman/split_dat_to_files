CREATE PROGRAM ams_fill_print_purge:dba
 PAINT
 DECLARE numrows = i4 WITH constant(20), protect
 DECLARE numcols = i4 WITH constant(75), protect
 DECLARE soffrow = i4 WITH constant(6), protect
 DECLARE soffcol = i4 WITH constant(3), protect
 DECLARE quesrow = i4 WITH constant(22), protect
 DECLARE maxrows = i4 WITH protect
 DECLARE cnt = i4 WITH protect
 DECLARE arow = i4 WITH protect
 DECLARE rowstr = c75 WITH protect
 DECLARE pick = i4 WITH protect
 DECLARE ccl_ver = i4 WITH protect, noconstant(cnvtint(build(currev,currevminor,currevminor2)))
 DECLARE status = c1 WITH protect, noconstant("F")
 DECLARE debug_ind = i2 WITH protect
 DECLARE statusstr = vc WITH protect
 DECLARE last_mod = vc WITH protect
 DECLARE i = i4 WITH protect
 RECORD log(
   1 qual_cnt = i4
   1 qual[*]
     2 smsgtype = c12
     2 dmsg_dt_tm = dq8
     2 smsg = vc
 ) WITH protect
 DECLARE validatelogin(null) = null WITH protect
 DECLARE clearscreen(null) = null WITH protect
 DECLARE drawmenu(title=vc,detailline=vc,warningline=vc) = null WITH protect
 DECLARE emailfile(vcrecep=vc,vcfrom=vc,vcsubj=vc,vcbody=vc,vcfile=vc) = i2 WITH protect
 DECLARE getclient(null) = vc WITH protect
 DECLARE gethnaemail(null) = vc WITH protect
 DECLARE addlogmsg(msgtype=vc,msg=vc) = null WITH protect
 DECLARE createlogfile(filename=vc) = null WITH protect
 DECLARE drawscrollbox(begrow=i4,begcol=i4,endrow=i4,endcol=i4) = null WITH protect
 DECLARE downarrow(newrow=c75) = null WITH protect
 DECLARE uparrow(newrow=c75) = null WITH protect
 SUBROUTINE validatelogin(null)
   EXECUTE cclseclogin
   SET message = nowindow
   IF ((xxcclseclogin->loggedin != 1))
    SET status = "F"
    SET statusstr = "You must be logged in securely. Please run the program again."
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE clearscreen(null)
   DECLARE i = i4 WITH protect
   SET i = soffrow
   WHILE (i <= numrows)
    CALL clear(i,soffcol,numcols)
    SET i = (i+ 1)
   ENDWHILE
   CALL clear((numrows+ 2),soffcol,numcols)
 END ;Subroutine
 SUBROUTINE drawmenu(title,detailline,warningline)
   CALL clear(1,1)
   CALL box((soffrow - 5),(soffcol - 1),(numrows+ 3),(numcols+ 3))
   CALL video(r)
   CALL text((soffrow - 4),soffcol,title)
   CALL text((soffrow - 3),soffcol,detailline)
   CALL video(b)
   CALL text((soffrow - 2),soffcol,warningline)
   CALL video(n)
   CALL line((soffrow - 1),(soffcol - 1),(numcols+ 2),xhor)
   CALL line((soffrow+ 15),(soffcol - 1),(numcols+ 2),xhor)
   CALL text((soffrow+ 16),soffcol,"Choose an option:")
 END ;Subroutine
 SUBROUTINE emailfile(vcrecep,vcfrom,vcsubj,vcbody,vcfile)
   DECLARE retval = i2
   RECORD email_request(
     1 recepstr = vc
     1 fromstr = vc
     1 subjectstr = vc
     1 bodystr = vc
     1 filenamestr = vc
   ) WITH protect
   RECORD email_reply(
     1 status = c1
     1 errorstr = vc
   ) WITH protect
   SET email_request->recepstr = vcrecep
   SET email_request->fromstr = vcfrom
   SET email_request->subjectstr = vcsubj
   SET email_request->bodystr = vcbody
   SET email_request->filenamestr = vcfile
   EXECUTE ams_run_email_file  WITH replace("REQUEST",email_request), replace("REPLY",email_reply)
   IF ((email_reply->status="S"))
    SET retval = 1
   ELSE
    SET retval = 0
   ENDIF
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE getclient(null)
   DECLARE retval = vc WITH protect, noconstant("")
   SET retval = logical("CLIENT_MNEMONIC")
   IF (retval="")
    SELECT INTO "nl:"
     d.info_char
     FROM dm_info d
     WHERE d.info_domain="DATA MANAGEMENT"
      AND d.info_name="CLIENT MNEMONIC"
     DETAIL
      retval = trim(d.info_char)
     WITH nocounter
    ;end select
   ENDIF
   IF (retval="")
    SET retval = "unknown"
   ENDIF
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE gethnaemail(null)
   DECLARE retval = vc WITH protect
   SELECT INTO "nl:"
    p.email
    FROM prsnl p
    WHERE (p.person_id=reqinfo->updt_id)
    DETAIL
     retval = trim(p.email)
    WITH nocounter
   ;end select
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE addlogmsg(msgtype,msg)
   SET log->qual_cnt = (log->qual_cnt+ 1)
   IF (mod(log->qual_cnt,50)=1)
    SET stat = alterlist(log->qual,(log->qual_cnt+ 49))
   ENDIF
   SET log->qual[log->qual_cnt].smsgtype = msgtype
   SET log->qual[log->qual_cnt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_cnt].smsg = msg
 END ;Subroutine
 SUBROUTINE createlogfile(filename)
   DECLARE logcnt = i4 WITH protect
   IF (ccl_ver >= 871)
    SET modify = filestream
   ENDIF
   SET stat = alterlist(log->qual,log->qual_cnt)
   FREE SET output_log
   SET logical output_log value(nullterm(concat("CCLUSERDIR:",trim(cnvtlower(filename)))))
   SELECT INTO output_log
    FROM (dummyt d  WITH seq = 1)
    HEAD REPORT
     outline = fillstring(254," ")
    DETAIL
     FOR (logcnt = 1 TO log->qual_cnt)
       outline = trim(substring(1,254,concat(format(log->qual[logcnt].smsgtype,"############")," :: ",
          format(log->qual[logcnt].dmsg_dt_tm,"dd-mmm-yyyy hh:mm:ss;;q")," :: ",trim(log->qual[logcnt
           ].smsg)))), col 0, outline
       IF ((logcnt != log->qual_cnt))
        row + 1
       ENDIF
     ENDFOR
    WITH nocounter, formfeed = none, format = stream,
     append, maxcol = 255, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE drawscrollbox(begrow,begcol,endrow,endcol)
  CALL box(begrow,begcol,endrow,endcol)
  CALL scrollinit((begrow+ 1),(begcol+ 1),(endrow - 1),(endcol - 1))
 END ;Subroutine
 SUBROUTINE downarrow(newrow)
   IF (arow=maxrows)
    CALL scrolldown(maxrows,maxrows,newrow)
   ELSE
    SET arow = (arow+ 1)
    CALL scrolldown((arow - 1),arow,newrow)
   ENDIF
 END ;Subroutine
 SUBROUTINE uparrow(newrow)
   IF (arow=1)
    CALL scrollup(arow,arow,rowstr)
   ELSE
    SET arow = (arow - 1)
    CALL scrollup((arow+ 1),arow,rowstr)
   ENDIF
 END ;Subroutine
 IF (validate(debug,0))
  IF (debug=1)
   SET debug_ind = 1
  ELSE
   SET debug_ind = 0
   SET trace = callecho
   SET trace = notest
   SET trace = nordbdebug
   SET trace = nordbbind
   SET trace = noechoinput
   SET trace = noechoinput2
   SET trace = noechorecord
   SET trace = noshowuar
   SET trace = noechosub
   SET trace = nowarning
   SET trace = nowarning2
   SET message = noinformation
   SET trace = nocost
  ENDIF
 ELSE
  SET debug_ind = 0
  SET trace = callecho
  SET trace = notest
  SET trace = nordbdebug
  SET trace = nordbbind
  SET trace = noechoinput
  SET trace = noechoinput2
  SET trace = noechorecord
  SET trace = noshowuar
  SET trace = noechosub
  SET trace = nowarning
  SET trace = nowarning2
  SET message = noinformation
  SET trace = nocost
 ENDIF
 SET last_mod = "005"
 DECLARE title_line = c75 WITH protect, constant(
  "                      AMS Fill_Print_Hx Purge Utility                       ")
 DECLARE detail_line = c75 WITH protect, constant(
  "            Purges fill_print_hx and fill_print_ord_hx in batches           ")
 DECLARE script_name = c22 WITH protect, constant("AMS_FILL_PRINT_PURGE")
 DECLARE template_nbr = i4 WITH protect, constant(110)
 DECLARE fill_list_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4040,"FILL"))
 DECLARE order_label_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4040,"ORD"))
 DECLARE mar_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4040,"MAR"))
 DECLARE pmp_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4040,"PMP"))
 DECLARE sor_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4040,"ASO"))
 DECLARE claim_trans_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4040,"CLM"))
 DECLARE control_sub_batch_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4040,"CSB"))
 DECLARE detail_rx_log_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4040,"DPL"))
 DECLARE disp_sum_rpt_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4040,"DSR"))
 DECLARE future_refill_rpt_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4040,"FRR"))
 DECLARE retail_fin_rpt_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4040,"FIN"))
 DECLARE partial_refill_rpt_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4040,"PRR"))
 DECLARE patient_trans_rpt_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4040,"PTR"))
 DECLARE pcl_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4040,"PCL"))
 DECLARE udr_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4040,"UDR"))
 DECLARE batchsz = i4 WITH protect
 DECLARE nbriterations = i4 WITH protect
 DECLARE i = i4 WITH protect
 DECLARE idx = i4 WITH protect
 DECLARE filllistdays = i4 WITH protect
 DECLARE ambulatorydays = i4 WITH protect
 DECLARE mardays = i4 WITH protect
 DECLARE orderlabeldays = i4 WITH protect
 DECLARE pmpdays = i4 WITH protect
 DECLARE sordays = i4 WITH protect
 DECLARE udrdays = i4 WITH protect
 DECLARE finished = i2 WITH protect
 DECLARE cclerror = vc WITH protect
 DECLARE maxdays = i4 WITH protect, noconstant(3)
 RECORD rows(
   1 list[*]
     2 run_id = f8
 ) WITH protect
 CALL validatelogin(null)
#main_menu
 CALL drawmenu(title_line,detail_line,"")
 CALL clear(quesrow,soffcol,numcols)
 CALL text(soffrow,soffcol,"Number of rows to delete from fill_print_hx in one batch:")
 CALL accept(soffrow,(soffcol+ 57),"99999;"
  WHERE curaccept > 0)
 SET batchsz = curaccept
 CALL text((soffrow+ 1),soffcol,"Number of batches:")
 CALL accept((soffrow+ 1),(soffcol+ 18),"99999;"
  WHERE curaccept > 0)
 SET nbriterations = curaccept
 CALL clearscreen(null)
 CALL text(soffrow,soffcol,"Beginning to delete rows on fill_print_hx and fill_print_ord_hx")
 SELECT INTO "nl:"
  dmt.token_str, dmt.value
  FROM dm_purge_job dj,
   dm_purge_job_token dmt
  PLAN (dj
   WHERE dj.template_nbr=template_nbr)
   JOIN (dmt
   WHERE dmt.job_id=dj.job_id)
  DETAIL
   CASE (dmt.token_str)
    OF "AMB_DAYS":
     ambulatorydays = cnvtint(dmt.value)
    OF "ASO_DAYS":
     sordays = cnvtint(dmt.value)
    OF "FILL_DAYS":
     filllistdays = cnvtint(dmt.value)
    OF "MAR_DAYS":
     mardays = cnvtint(dmt.value)
    OF "ORD_DAYS":
     orderlabeldays = cnvtint(dmt.value)
    OF "PMP_DAYS":
     pmpdays = cnvtint(dmt.value)
    OF "UDR_DAYS":
     udrdays = cnvtint(dmt.value)
   ENDCASE
   IF (maxdays < cnvtint(dmt.value))
    maxdays = cnvtint(dmt.value)
   ENDIF
  WITH nocounter
 ;end select
 IF (filllistdays < 3
  AND filllistdays > 0)
  SET filllistdays = 3
 ENDIF
 IF (mardays < 3
  AND mardays > 0)
  SET mardays = 3
 ENDIF
 CALL text((soffrow+ 1),soffcol,"Rows will be purged based on these settings:")
 IF (((ambulatorydays=0) OR (((sordays=0) OR (((filllistdays=0) OR (((mardays=0) OR (((orderlabeldays
 =0) OR (((pmpdays=0) OR (udrdays=0)) )) )) )) )) )) )
  CALL text((soffrow+ 1),soffcol,"Current purge settings (run types with 0 days will not be purged):"
   )
 ENDIF
 CALL text((soffrow+ 2),soffcol,build2("Fill list days: ",trim(cnvtstring(filllistdays))))
 CALL text((soffrow+ 3),soffcol,build2("Ambulatory report days: ",trim(cnvtstring(ambulatorydays))))
 CALL text((soffrow+ 4),soffcol,build2("MAR report days: ",trim(cnvtstring(mardays))))
 CALL text((soffrow+ 5),soffcol,build2("Order entry label days: ",trim(cnvtstring(orderlabeldays))))
 CALL text((soffrow+ 6),soffcol,build2("PMP days: ",trim(cnvtstring(pmpdays))))
 CALL text((soffrow+ 7),soffcol,build2("Stop order report days: ",trim(cnvtstring(sordays))))
 CALL text((soffrow+ 8),soffcol,build2("User defined report days: ",trim(cnvtstring(udrdays))))
 CALL text((soffrow+ 9),soffcol,build2("All other run types: ",trim(cnvtstring(maxdays))))
 FOR (loopcnt = 1 TO nbriterations)
   CALL clear((soffrow+ 10),soffcol,numcols)
   CALL clear((soffrow+ 11),soffcol,numcols)
   CALL clear((soffrow+ 12),soffcol,numcols)
   CALL clear((soffrow+ 13),soffcol,numcols)
   CALL clear((soffrow+ 14),soffcol,numcols)
   CALL text((soffrow+ 11),soffcol,build2("Starting iteration ",trim(cnvtstring(loopcnt))," of ",trim
     (cnvtstring(nbriterations))))
   SET stat = initrec(rows)
   SELECT INTO "nl:"
    fx.run_id
    FROM fill_print_hx fx
    WHERE fx.run_id != 0
     AND ((fx.run_type_cd=fill_list_cd
     AND fx.updt_dt_tm < cnvtdatetime((curdate - filllistdays),curtime3)
     AND filllistdays > 0) OR (((fx.run_type_cd=sor_cd
     AND fx.updt_dt_tm < cnvtdatetime((curdate - sordays),curtime3)
     AND sordays > 0) OR (((fx.run_type_cd IN (claim_trans_cd, control_sub_batch_cd, detail_rx_log_cd,
    disp_sum_rpt_cd, future_refill_rpt_cd,
    retail_fin_rpt_cd, partial_refill_rpt_cd, patient_trans_rpt_cd)
     AND fx.updt_dt_tm < cnvtdatetime((curdate - ambulatorydays),curtime3)
     AND ambulatorydays > 0) OR (((fx.run_type_cd=mar_cd
     AND fx.updt_dt_tm < cnvtdatetime((curdate - mardays),curtime3)
     AND mardays > 0) OR (((fx.run_type_cd IN (order_label_cd, pcl_cd)
     AND fx.updt_dt_tm < cnvtdatetime((curdate - orderlabeldays),curtime3)
     AND orderlabeldays > 0) OR (((fx.run_type_cd=pmp_cd
     AND fx.updt_dt_tm < cnvtdatetime((curdate - pmpdays),curtime3)
     AND pmpdays > 0) OR (((fx.run_type_cd IN (udr_cd, 0.0)
     AND fx.updt_dt_tm < cnvtdatetime((curdate - udrdays),curtime3)
     AND udrdays > 0) OR (fx.updt_dt_tm < cnvtdatetime((curdate - maxdays),curtime3)
     AND maxdays > 0)) )) )) )) )) )) ))
    HEAD REPORT
     i = 0
    DETAIL
     i = (i+ 1)
     IF (mod(i,10000)=1)
      stat = alterlist(rows->list,(i+ 9999))
     ENDIF
     rows->list[i].run_id = fx.run_id
    FOOT REPORT
     IF (mod(i,10000) != 0)
      stat = alterlist(rows->list,i)
     ENDIF
    WITH nocounter, maxqual(fx,value(batchsz)), forupdate(fx)
   ;end select
   IF (debug_ind=1)
    CALL echorecord(rows)
   ENDIF
   IF (i < batchsz)
    SET finished = 1
   ENDIF
   IF (i=0)
    SET status = "S"
    GO TO exit_script
   ENDIF
   CALL text((soffrow+ 12),soffcol,"Deleting rows from fill_print_hx")
   DELETE  FROM fill_print_hx fx
    WHERE expand(idx,1,size(rows->list,5),fx.run_id,rows->list[idx].run_id)
     AND fx.run_id != 0
    WITH nocounter, expand = 1
   ;end delete
   IF (curqual=size(rows->list,5))
    SET status = "S"
    CALL clear((soffrow+ 12),soffcol,numcols)
    CALL text((soffrow+ 12),soffcol,"Rows deleted from fill_print_hx: ",trim(cnvtstring(curqual)))
   ELSE
    ROLLBACK
    SET status = "F"
    SET statusstr = "ERROR DELETING INTO FILL_PRINT_HX. ROLLING BACK CHANGES AND EXITING SCRIPT."
    CALL text((soffrow+ 12),soffcol,statusstr)
    CALL text((soffrow+ 13),soffcol,build2("curqual = ",curqual))
    CALL text((soffrow+ 14),build2("size rows->list = ",size(rows->list,5)))
    CALL text(quesrow,soffcol,"Continue?:")
    CALL accept(quesrow,(soffcol+ 10),"A;CU","Y"
     WHERE curaccept IN ("Y"))
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    fpoh.run_id
    FROM fill_print_ord_hx fpoh
    WHERE expand(idx,1,size(rows->list,5),fpoh.run_id,rows->list[idx].run_id)
    HEAD REPORT
     i = 0
    DETAIL
     i = (i+ 1)
    WITH nocounter, forupdate(fpoh), expand = 1
   ;end select
   CALL text((soffrow+ 13),soffcol,"Deleting child rows from fill_print_ord_hx")
   DELETE  FROM fill_print_ord_hx fpoh
    WHERE expand(idx,1,size(rows->list,5),fpoh.run_id,rows->list[idx].run_id)
     AND fpoh.run_id != 0
    WITH nocounter, expand = 1
   ;end delete
   IF (error(cclerror,0)=0)
    SET status = "S"
    CALL clear((soffrow+ 13),soffcol,numcols)
    CALL text((soffrow+ 13),soffcol,build2("Rows deleted from fill_print_ord_hx: ",trim(cnvtstring(i)
       )))
   ELSE
    ROLLBACK
    SET status = "F"
    SET statusstr = "ERROR UPDATING FILL_PRINT_ORD_HX. ROLLING BACK CHANGES AND EXITING SCRIPT."
    CALL text((soffrow+ 11),soffcol,statusstr)
    CALL text((soffrow+ 12),soffcol,build2("curqual = ",curqual))
    CALL text((soffrow+ 13),soffcol,build2("i = ",i))
    CALL text(quesrow,soffcol,"Continue?:")
    CALL accept(quesrow,(soffcol+ 10),"A;CU","Y"
     WHERE curaccept IN ("Y"))
    GO TO exit_script
   ENDIF
   COMMIT
   IF (finished=1)
    GO TO exit_script
   ENDIF
 ENDFOR
#exit_script
 IF (status="F")
  CALL echo(statusstr)
 ELSE
  IF (finished=1)
   CALL text((soffrow+ 14),soffcol,"All rows on fill_print_hx that can be purged have been removed.")
   CALL text(quesrow,soffcol,"Continue?:")
   CALL accept(quesrow,(soffcol+ 10),"A;CU","Y"
    WHERE curaccept IN ("Y"))
  ELSE
   CALL text((soffrow+ 14),soffcol,
    "There are additional rows on fill_print_hx that qualify for purging.")
   CALL text(quesrow,soffcol,"Do you want to run script again to remove more rows?:")
   CALL accept(quesrow,(soffcol+ 53),"A;CU","Y"
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="Y")
    GO TO main_menu
   ENDIF
  ENDIF
 ENDIF
 CALL clear(1,1)
 SET message = nowindow
 SET last_mod = "002"
END GO
