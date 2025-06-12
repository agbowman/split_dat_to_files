CREATE PROGRAM ams_pharm_toolkit:dba
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
 DECLARE releaseversion = vc WITH protect
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE d.info_domain="AMS ToolKit"
   AND d.info_name="Version"
  DETAIL
   releaseversion = trim(d.info_char)
  WITH nocounter
 ;end select
 CALL validatelogin(null)
 CALL text(3,3," This program is for use by qualified Cerner AMS personnel       ")
 CALL text(4,3," only. It is not compatible with all levels of code and may cause")
 CALL text(5,3," detrimental impact to the system when used incorrectly. By      ")
 CALL text(6,3," continuing you acknowledge that you are eligible to use this    ")
 CALL text(7,3," program.                                                        ")
 CALL text(15,3,"Continue? (Y/N) ")
 CALL accept(15,20,"C;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 CASE (curaccept)
  OF "Y":
   GO TO main_menu
  OF "N":
   GO TO exit_script
 ENDCASE
#main_menu
 CALL clear(1,1)
 CALL box((soffrow - 5),(soffcol - 1),(numrows+ 3),(numcols+ 3))
 CALL video(r)
 CALL text((soffrow - 4),soffcol,
  "                      Application Management Services                      ")
 CALL text((soffrow - 3),soffcol,
  "                              Pharmacy Toolkit                             ")
 CALL video(n)
 CALL line((soffrow - 1),(soffcol - 1),(numcols+ 2),xhor)
 CALL text(soffrow,(soffcol+ 13),"Audits")
 CALL line((soffrow+ 1),(soffcol+ 1),30)
 CALL text((soffrow+ 2),(soffcol+ 1),"01 Multum Load Test")
 CALL text((soffrow+ 3),(soffcol+ 1),"03 Fill Batch Schedule Audit")
 CALL text((soffrow+ 4),(soffcol+ 1),"05 Pharmacy Health Check Audit")
 CALL text((soffrow+ 5),(soffcol+ 1),"07 Product Assignment Audit")
 CALL text((soffrow+ 6),(soffcol+ 1),"09 Formulary Price Audit")
 CALL text((soffrow+ 7),(soffcol+ 1),"11 NDC Matching Audit")
 CALL text((soffrow+ 8),(soffcol+ 1),"13 Pharmacy Dispense Audit")
 CALL text(soffrow,(numcols - 18),"Utilities")
 CALL line((soffrow+ 1),(numcols - 28),30)
 CALL text((soffrow+ 2),(numcols - 28),"02 Tallman Synonyms & Products")
 CALL text((soffrow+ 3),(numcols - 28),"04 Copy Order Catalog Settings")
 CALL text((soffrow+ 4),(numcols - 28),"06 Copy Task Settings")
 CALL text((soffrow+ 5),(numcols - 28),"08 Clean Up IV Order Catalog")
 CALL text((soffrow+ 6),(numcols - 28),"10 Update Synonyms for Multum")
 CALL text((soffrow+ 7),(numcols - 28),"12 Purge Fill_Print_Hx")
 CALL text((soffrow+ 8),(numcols - 28),"14 Pharmacy Bill Item Setup")
 CALL text((soffrow+ 9),(numcols - 28),"16 Import Therapeutic Subs")
 CALL text((soffrow+ 10),(numcols - 28),"18 Import Code Value Aliases")
 CALL text((soffrow+ 14),(numcols - 28),"98 Email file")
 CALL text((soffrow+ 14),(soffcol+ 1),"99 Exit")
 CALL line((soffrow+ 15),(soffcol - 1),(numcols+ 2),xhor)
 CALL text(quesrow,soffcol,"Choose an option:")
 CALL text(quesrow,(soffcol+ 58),build2("Release: ",releaseversion))
 CALL accept((soffrow+ 16),(soffcol+ 18),"99;",99
  WHERE curaccept IN (1, 2, 3, 4, 5,
  6, 7, 8, 9, 10,
  11, 12, 13, 14, 16,
  18, 98, 99))
 CASE (curaccept)
  OF 1:
   EXECUTE ams_mltm_test
  OF 2:
   EXECUTE ams_tallman_utility
  OF 3:
   EXECUTE ams_fill_batch_check_utility
  OF 4:
   EXECUTE ams_ord_cat_utility
  OF 5:
   EXECUTE ams_pharm_health_check_utility
  OF 6:
   EXECUTE ams_task_utility
  OF 7:
   EXECUTE ams_prod_assign_audit
  OF 8:
   EXECUTE ams_cleanup_iv_ord_cat
  OF 9:
   EXECUTE ams_formulary_price_audit
  OF 10:
   EXECUTE ams_mltm_updt_synonyms
  OF 11:
   EXECUTE ams_ndc_matching_audit
  OF 12:
   EXECUTE ams_fill_print_purge
  OF 13:
   EXECUTE ams_pharm_dispense_analysis
  OF 14:
   EXECUTE ams_pharm_bill_item_setup_util
  OF 16:
   EXECUTE ams_thera_sub_utility
  OF 18:
   EXECUTE ams_cv_alias_upload
  OF 98:
   EXECUTE ams_email_file
  OF 99:
   GO TO exit_script
 ENDCASE
#exit_script
 CALL clear(1,1)
 SET message = nowindow
 IF (status="F")
  CALL echo(statusstr)
 ENDIF
 SET last_mod = "012"
END GO
