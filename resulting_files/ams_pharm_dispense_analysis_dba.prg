CREATE PROGRAM ams_pharm_dispense_analysis:dba
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
 DECLARE auditstatusmsg = vc WITH protect
 DECLARE emailstatus = vc WITH protect
 DECLARE status = vc WITH protect
 DECLARE cnt = i4 WITH protect
 DECLARE datacount = i4 WITH protect
 DECLARE isfacilityset = i2 WITH protect
 DECLARE checkallfac = i2 WITH protect
 DECLARE checkspecfac = f8 WITH protect
 DECLARE isitemset = i2 WITH protect
 DECLARE checkallitem = i2 WITH protect
 DECLARE checkspecitem = f8 WITH protec
 DECLARE iscatset = i2 WITH protect
 DECLARE checkallcat = i2 WITH protect
 DECLARE checkspeccat = f8 WITH protect
 DECLARE isdisplocset = i2 WITH protect
 DECLARE checkalldisploc = i2 WITH protect
 DECLARE checkspecdisploc = f8 WITH protect
 DECLARE displocdisp = vc WITH protect
 DECLARE sdate = dq8 WITH protect
 DECLARE edate = dq8 WITH protect
 DECLARE errormsg = vc WITH protect
 DECLARE facname = vc WITH protect
 DECLARE filename = vc WITH protect
 DECLARE emailind = i2 WITH protect
 DECLARE question1 = vc WITH protect
 DECLARE question2 = vc WITH protect
 DECLARE questioncat = vc WITH protect
 DECLARE question3 = vc WITH protect
 DECLARE question4 = vc WITH protect
 DECLARE question5 = vc WITH protect
 DECLARE question6 = vc WITH protect
 DECLARE questionvalidate = vc WITH protect
 DECLARE auditresultmsg = vc WITH protect
 DECLARE cdcatpharm = f8 WITH constant(uar_get_code_by("MEANING",6000,"PHARMACY")), protect
 DECLARE cdactpharm = f8 WITH constant(uar_get_code_by("MEANING",106,"PHARMACY")), protect
 DECLARE cdpharminpat = f8 WITH constant(uar_get_code_by("MEANING",4500,"INPATIENT")), protect
 DECLARE cdmedidentdesc = f8 WITH constant(uar_get_code_by("MEANING",11000,"DESC")), protect
 DECLARE cddispeventdevreturn = f8 WITH constant(uar_get_code_by("MEANING",4032,"DEVICERETURN")),
 protect
 DECLARE cddispeventdevdisp = f8 WITH constant(uar_get_code_by("MEANING",4032,"DEVICEDISPEN")),
 protect
 DECLARE cdaliasfin = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR")), protect
 DECLARE amsemail = vc WITH protect
 DECLARE subjstr = vc WITH protect
 DECLARE recpstr = vc WITH protect
 DECLARE bodystr = vc WITH protect
 FREE RECORD pharm_dispeses
 RECORD pharm_dispenses(
   1 list[*]
     2 fin_nbr = vc
     2 patient = vc
     2 dispense_hx_id = f8
     2 prod_disp_hx_id = f8
     2 encounter_id = f8
     2 order_id = f8
     2 catalog_cd = f8
     2 item_id = f8
     2 product_desc = vc
     2 order_desc = vc
     2 other_charge = vc
     2 facility_cd = f8
     2 disp_loc_cd = f8
     2 dispense_cat = f8
     2 dc_charge_type = i2
     2 disp_event_type_cd = f8
     2 disp_dt_tm = dq8
     2 price_sched = vc
     2 cost = f8
     2 price = f8
     2 event_total_price = f8
     2 qpd = f8
     2 charged = i2
     2 chrg_diff_order = i2
     2 chrg_same_order = i2
     2 disp_diff_order = i2
     2 disp_same_order = i2
     2 chrg_same_catalog = i2
     2 pt_loc_cd = f8
 )
 CALL validatelogin(null)
#main_menu
 CALL clear(1,1)
 CALL box((soffrow - 5),(soffcol - 1),(numrows+ 3),(numcols+ 3))
 CALL video(r)
 CALL text((soffrow - 4),soffcol,
  "                      AMS Pharmacy Dispense Analysis                       ")
 CALL text((soffrow - 3),soffcol,
  "     Audit will provide list of all dispense events over a given time      ")
 CALL video(n)
 CALL line((soffrow - 1),(soffcol - 1),(numcols+ 2),xhor)
 CALL line((soffrow+ 15),(soffcol - 1),(numcols+ 2),xhor)
 WHILE (isfacilityset=0)
   CALL text(soffrow,soffcol,"Fill in facility display (or ALL) (Shift+F5 to select facility).")
   SET question1 = "Facility display:"
   CALL text((soffrow+ 1),soffcol,question1)
   SET help = promptmsg("Facility display starts with:")
   SET help = pos(3,1,15,80)
   SET help =
   SELECT DISTINCT INTO "nl:"
    facility = cv.display
    FROM code_value cv
    WHERE cv.code_set=220
     AND cv.active_ind=1
     AND cv.cdf_meaning="FACILITY"
     AND cnvtupper(cv.display) >= cnvtupper(curaccept)
    ORDER BY cv.display_key
    WITH nocounter
   ;end select
   CALL accept((soffrow+ 1),(soffcol+ (textlen(question1)+ 1)),"P(40);CP"
    WHERE textlen(trim(curaccept)) > 0)
   SET facilitydisp = trim(cnvtupper(curaccept))
   SET help = off
   IF (cnvtupper(curaccept)="ALL")
    SET checkallfac = 1
    SET facilitydisp = "All Facilities"
    SET checkspecfac = 0
    SET isfacilityset = 1
   ELSEIF (cnvtupper(curaccept)="QUIT")
    GO TO exit_script
   ELSE
    SELECT INTO "nl:"
     facility = cv.display
     FROM code_value cv
     WHERE cv.code_set=220
      AND cv.cdf_meaning="FACILITY"
      AND cv.active_ind=1
      AND cnvtupper(cv.display)=cnvtupper(trim(facilitydisp))
      AND cv.code_value != 0
     DETAIL
      checkspecfac = cv.code_value, facilitydisp = cv.display
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL clear((soffrow+ 1),soffcol,numcols)
     CALL clear((soffrow+ 2),soffcol,numcols)
     CALL text((soffrow+ 2),soffcol,concat(trim(facilitydisp)," is not a valid facility display."))
    ELSE
     CALL clear((soffrow+ 2),soffcol,numcols)
     SET checkallfac = 0
     SET isfacilityset = 1
    ENDIF
   ENDIF
 ENDWHILE
 WHILE (isitemset=0)
   CALL clear((soffrow+ 2),soffcol,numcols)
   SET question2 = "Enter ITEM_ID     (0 for ALL):"
   CALL text((soffrow+ 2),soffcol,question2)
   CALL accept((soffrow+ 2),(soffcol+ (textlen(question2)+ 1)),"9(15);C",0)
   IF (cnvtint(curaccept)=0)
    SET checkallitem = 1
    SET checkspecitem = 0
    SET isitemset = 1
   ELSE
    SELECT DISTINCT INTO "nl:"
     FROM medication_definition md
     WHERE md.item_id=cnvtint(curaccept)
     DETAIL
      checkspecitem = cnvtint(md.item_id)
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL clear((soffrow+ 2),soffcol,numcols)
     CALL clear((soffrow+ 3),soffcol,numcols)
     CALL text((soffrow+ 3),soffcol,concat(trim(cnvtstring(curaccept))," is not a valid item_id."))
    ELSE
     CALL clear((soffrow+ 3),soffcol,numcols)
     SET checkallitem = 0
     SET isitemset = 1
     SET checkallcat = 1
     SET checkspeccat = 0
     SET iscatset = 1
    ENDIF
   ENDIF
 ENDWHILE
 WHILE (iscatset=0)
   CALL clear((soffrow+ 3),soffcol,numcols)
   SET questioncat = "Enter CATALOG_CD  (0 for ALL):"
   CALL text((soffrow+ 3),soffcol,questioncat)
   CALL accept((soffrow+ 3),(soffcol+ (textlen(questioncat)+ 1)),"9(15);C",0)
   IF (cnvtint(curaccept)=0)
    SET checkallcat = 1
    SET checkspeccat = 0
    SET iscatset = 1
   ELSE
    SELECT DISTINCT INTO "nl:"
     FROM order_catalog oc
     WHERE oc.catalog_cd=cnvtint(curaccept)
     DETAIL
      checkspeccat = cnvtint(oc.catalog_cd)
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL clear((soffrow+ 3),soffcol,numcols)
     CALL clear((soffrow+ 4),soffcol,numcols)
     CALL text((soffrow+ 4),soffcol,concat(trim(cnvtstring(curaccept))," is not a valid catalog_cd.")
      )
    ELSE
     CALL clear((soffrow+ 4),soffcol,numcols)
     SET checkallcat = 0
     SET iscatset = 1
    ENDIF
   ENDIF
 ENDWHILE
 WHILE (isdisplocset=0)
   CALL clear((soffrow+ 4),soffcol,numcols)
   SET question3 = "Enter DISP_LOC_CD (0 for ALL):"
   CALL text((soffrow+ 4),soffcol,question3)
   CALL accept((soffrow+ 4),(soffcol+ (textlen(question3)+ 1)),"9(15);C",0)
   IF (cnvtint(curaccept)=0)
    SET checkalldisploc = 1
    SET checkspecdisploc = 0
    SET isdisplocset = 1
   ELSE
    SELECT DISTINCT INTO "nl:"
     FROM code_value cv
     WHERE cv.code_set=220
      AND cv.active_ind=1
      AND cv.code_value=cnvtint(curaccept)
     DETAIL
      displocdisp = cv.display, checkspecdisploc = cv.code_value
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL clear((soffrow+ 4),soffcol,numcols)
     CALL clear((soffrow+ 5),soffcol,numcols)
     CALL text((soffrow+ 5),soffcol,concat(trim(cnvtstring(curaccept))," is not a valid disp_loc_cd."
       ))
    ELSE
     CALL clear((soffrow+ 5),soffcol,numcols)
     SET checkalldisploc = 0
     SET isdisplocset = 1
    ENDIF
   ENDIF
 ENDWHILE
 CALL clear((soffrow+ 5),soffcol,numcols)
 SET question4 = "Enter FROM date time (MM/DD/YYYY):"
 CALL text((soffrow+ 5),soffcol,question4)
 CALL text((soffrow+ 5),(soffcol+ (textlen(question4)+ 12)),"00:00")
 CALL accept((soffrow+ 5),(soffcol+ (textlen(question4)+ 1)),"NNDNNDNNNN;C",format((curdate - 30),
   "MM/DD/YYYY;;D")
  WHERE format(cnvtdate(cnvtalphanum(curaccept)),"MM/DD/YYYY;;D")=curaccept)
 SET sdate = cnvtdatetime(cnvtdate(cnvtalphanum(curaccept)),0000)
 SET question5 = "Enter TO date time   (MM/DD/YYYY):"
 CALL text((soffrow+ 6),soffcol,question5)
 CALL text((soffrow+ 6),(soffcol+ (textlen(question5)+ 12)),"23:59")
 CALL accept((soffrow+ 6),(soffcol+ (textlen(question5)+ 1)),"NNDNNDNNNN;C",format((curdate - 1),
   "MM/DD/YYYY;;D")
  WHERE format(cnvtdate(cnvtalphanum(curaccept)),"MM/DD/YYYY;;D")=curaccept
   AND sdate < cnvtdatetime(cnvtdate(cnvtalphanum(curaccept)),235959))
 SET edate = cnvtdatetime(cnvtdate(cnvtalphanum(curaccept)),235959)
 SET question6 = "Email the file? (If yes, PHI will be removed) (Y/N):"
 CALL text((soffrow+ 7),soffcol,question6)
 CALL accept((soffrow+ 7),(soffcol+ (textlen(question6)+ 1)),"A;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="Y")
  CALL clear((soffrow+ 7),soffcol,numcols)
  SET question6 = "Enter email address:"
  CALL text((soffrow+ 7),soffcol,question6)
  CALL accept((soffrow+ 7),(soffcol+ (textlen(question6)+ 1)),"P(54);C",gethnaemail(null)
   WHERE trim(curaccept)="*@*.*")
  SET amsemail = curaccept
  SET emailind = 1
 ELSE
  SET emailind = 0
 ENDIF
 SET questionvalidate = "Are these settings correct? (Y/N):"
 CALL text((soffrow+ 16),soffcol,questionvalidate)
 CALL accept((soffrow+ 16),(soffcol+ (textlen(questionvalidate)+ 1)),"A;CU",""
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="N")
  SET isfacilityset = 0
  SET isitemset = 0
  SET iscatset = 0
  SET isdisplocset = 0
  SET auditresultmsg = ""
  SET emailstatus = ""
  SET filename = ""
  SET amsemail = ""
  GO TO main_menu
 ELSE
  CALL clear((soffrow+ 16),soffcol,numcols)
 ENDIF
 SET auditresultmsg = "Getting data...This can take a while..."
 CALL text((soffrow+ 8),soffcol,auditresultmsg)
 SELECT INTO "nl:"
  fin = ea.alias, pt = p.name_full_formatted, dh.dispense_hx_id,
  o.encntr_id, o.order_id, o.catalog_cd,
  dh.order_id, mi.item_id, product_desc = mi.value,
  o.dept_misc_line, facility = uar_get_code_display(e.loc_facility_cd), e.loc_facility_cd,
  dh.disp_loc_cd, disp_cat = uar_get_code_display(dc.dispense_category_cd), dc_chrg_type =
  IF (dc.charge_pt_sch_ind=0) "Manual"
  ELSEIF (dc.charge_pt_sch_ind=1) "COD"
  ELSE "COA"
  ENDIF
  ,
  event_type = uar_get_code_display(dh.disp_event_type_cd), cost = pdh.cost, price = pdh.price,
  qpd = op.dose_quantity, charge =
  IF (dh.charge_ind=1) "YES"
  ELSE "NO"
  ENDIF
  , pt_loc = uar_get_code_display(elh.loc_nurse_unit_cd)
  FROM orders o,
   dispense_hx dh,
   prod_dispense_hx pdh,
   price_sched ps,
   order_product op,
   med_identifier mi,
   person p,
   encntr_loc_hist elh,
   order_detail od,
   dispense_category dc,
   encounter e,
   encntr_alias ea
  PLAN (o
   WHERE o.orig_order_dt_tm BETWEEN cnvtdatetime(sdate) AND cnvtdatetime(edate)
    AND o.template_order_id=0
    AND o.catalog_type_cd=cdcatpharm
    AND o.orig_ord_as_flag IN (0, 4)
    AND o.activity_type_cd=cdactpharm
    AND o.template_order_flag IN (0, 1, 7)
    AND ((o.catalog_cd=checkspeccat) OR (checkallcat=1)) )
   JOIN (dh
   WHERE dh.order_id=o.order_id
    AND dh.order_id > 0
    AND dh.pharm_type_cd=cdpharminpat
    AND ((dh.disp_loc_cd=checkspecdisploc) OR (checkalldisploc=1)) )
   JOIN (pdh
   WHERE pdh.dispense_hx_id=dh.dispense_hx_id
    AND ((pdh.item_id=checkspecitem) OR (checkallitem=1)) )
   JOIN (ps
   WHERE ps.price_sched_id=pdh.price_sched_id)
   JOIN (op
   WHERE op.order_id=dh.order_id
    AND op.action_sequence=dh.action_sequence
    AND op.ingred_sequence=pdh.ingred_sequence
    AND op.item_id=pdh.item_id)
   JOIN (mi
   WHERE mi.item_id=pdh.item_id
    AND mi.med_product_id=0
    AND mi.med_identifier_type_cd=cdmedidentdesc
    AND mi.primary_ind=1
    AND mi.pharmacy_type_cd=cdpharminpat)
   JOIN (p
   WHERE p.person_id=o.person_id)
   JOIN (elh
   WHERE elh.encntr_id=o.encntr_id
    AND elh.beg_effective_dt_tm < dh.dispense_dt_tm
    AND elh.end_effective_dt_tm > dh.dispense_dt_tm
    AND elh.active_ind=1)
   JOIN (od
   WHERE od.order_id=o.order_id
    AND od.oe_field_meaning="DISPENSECATEGORY"
    AND od.action_sequence IN (
   (SELECT
    max(od2.action_sequence)
    FROM order_detail od2
    WHERE od2.order_id=od.order_id
     AND od2.oe_field_meaning=od.oe_field_meaning
     AND od2.updt_dt_tm <= dh.updt_dt_tm)))
   JOIN (dc
   WHERE dc.dispense_category_cd=od.oe_field_value)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND ((e.loc_facility_cd=checkspecfac) OR (checkallfac=1)) )
   JOIN (ea
   WHERE ea.encntr_id=o.encntr_id
    AND ea.encntr_alias_type_cd=cdaliasfin
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ea.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3))
  HEAD REPORT
   cnt = 0, datacount = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt > size(pharm_dispenses->list,5))
    stat = alterlist(pharm_dispenses->list,(cnt+ 5))
   ENDIF
   pharm_dispenses->list[cnt].fin_nbr = ea.alias, pharm_dispenses->list[cnt].patient = p
   .name_full_formatted, pharm_dispenses->list[cnt].encounter_id = e.encntr_id,
   pharm_dispenses->list[cnt].order_id = o.order_id, pharm_dispenses->list[cnt].catalog_cd = o
   .catalog_cd, pharm_dispenses->list[cnt].dispense_hx_id = dh.dispense_hx_id,
   pharm_dispenses->list[cnt].prod_disp_hx_id = pdh.prod_dispense_hx_id, pharm_dispenses->list[cnt].
   item_id = mi.item_id, pharm_dispenses->list[cnt].product_desc = mi.value,
   pharm_dispenses->list[cnt].order_desc = o.dept_misc_line, pharm_dispenses->list[cnt].facility_cd
    = e.loc_facility_cd, pharm_dispenses->list[cnt].disp_loc_cd = dh.disp_loc_cd,
   pharm_dispenses->list[cnt].dispense_cat = dc.dispense_category_cd, pharm_dispenses->list[cnt].
   dc_charge_type = dc.charge_pt_sch_ind, pharm_dispenses->list[cnt].disp_dt_tm = dh.dispense_dt_tm,
   pharm_dispenses->list[cnt].disp_event_type_cd = dh.disp_event_type_cd, pharm_dispenses->list[cnt].
   price_sched = ps.price_sched_desc, pharm_dispenses->list[cnt].cost = pdh.cost,
   pharm_dispenses->list[cnt].price = pdh.price, pharm_dispenses->list[cnt].event_total_price = dh
   .event_total_price, pharm_dispenses->list[cnt].qpd = op.dose_quantity,
   pharm_dispenses->list[cnt].charged = dh.charge_ind, pharm_dispenses->list[cnt].pt_loc_cd = elh
   .loc_nurse_unit_cd, pharm_dispenses->list[cnt].chrg_diff_order = 0,
   pharm_dispenses->list[cnt].chrg_same_order = 0, pharm_dispenses->list[cnt].disp_diff_order = 0,
   pharm_dispenses->list[cnt].disp_same_order = 0,
   pharm_dispenses->list[cnt].chrg_same_catalog = 0, datacount = (datacount+ 1)
  FOOT REPORT
   stat = alterlist(pharm_dispenses->list,cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET status = "F"
  SET auditstatusmsg = "NO RESULTS for entered search criteria."
  GO TO exit_question
 ELSE
  SET status = "S"
  CALL clear((soffrow+ 8),soffcol,numcols)
  SET auditresultmsg = concat(trim(cnvtstring(datacount))," results were found...")
  CALL text((soffrow+ 8),soffcol,auditresultmsg)
 ENDIF
 CALL text((soffrow+ 9),soffcol,"Checking encounters for same item charges...")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(pharm_dispenses->list,5))),
   orders o,
   dispense_hx dh,
   prod_dispense_hx pdh
  PLAN (d)
   JOIN (o
   WHERE (o.encntr_id=pharm_dispenses->list[d.seq].encounter_id)
    AND (o.order_id != pharm_dispenses->list[d.seq].order_id)
    AND o.template_order_id=0
    AND o.catalog_type_cd=cdcatpharm)
   JOIN (dh
   WHERE dh.order_id=o.order_id
    AND dh.pharm_type_cd=cdpharminpat
    AND dh.order_id > 0)
   JOIN (pdh
   WHERE pdh.dispense_hx_id=dh.dispense_hx_id
    AND (pdh.item_id=pharm_dispenses->list[d.seq].item_id)
    AND pdh.charge_ind=1)
  DETAIL
   IF (curqual=0)
    pharm_dispenses->list[d.seq].chrg_diff_order = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(pharm_dispenses->list,5))),
   orders o,
   dispense_hx dh,
   prod_dispense_hx pdh
  PLAN (d)
   JOIN (o
   WHERE (o.encntr_id=pharm_dispenses->list[d.seq].encounter_id)
    AND (o.order_id=pharm_dispenses->list[d.seq].order_id)
    AND o.template_order_id=0
    AND o.catalog_type_cd=cdcatpharm)
   JOIN (dh
   WHERE dh.order_id=o.order_id
    AND dh.pharm_type_cd=cdpharminpat
    AND dh.order_id > 0
    AND (dh.dispense_hx_id != pharm_dispenses->list[d.seq].dispense_hx_id))
   JOIN (pdh
   WHERE pdh.dispense_hx_id=dh.dispense_hx_id
    AND (pdh.item_id=pharm_dispenses->list[d.seq].item_id)
    AND pdh.charge_ind=1)
  DETAIL
   IF (curqual=0)
    pharm_dispenses->list[d.seq].chrg_same_order = 1
   ENDIF
  WITH nocounter
 ;end select
 CALL text((soffrow+ 10),soffcol,"Checking encounters for same item device returns...")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(pharm_dispenses->list,5))),
   orders o,
   dispense_hx dh,
   prod_dispense_hx pdh
  PLAN (d)
   JOIN (o
   WHERE (o.encntr_id=pharm_dispenses->list[d.seq].encounter_id)
    AND (o.order_id != pharm_dispenses->list[d.seq].order_id)
    AND o.template_order_id=0
    AND o.catalog_type_cd=cdcatpharm)
   JOIN (dh
   WHERE dh.order_id=o.order_id
    AND dh.pharm_type_cd=cdpharminpat
    AND dh.disp_event_type_cd=cddispeventdevreturn
    AND dh.order_id > 0)
   JOIN (pdh
   WHERE pdh.dispense_hx_id=dh.dispense_hx_id
    AND (pdh.item_id=pharm_dispenses->list[d.seq].item_id))
  DETAIL
   IF (curqual=0)
    pharm_dispenses->list[d.seq].disp_diff_order = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(pharm_dispenses->list,5))),
   orders o,
   dispense_hx dh,
   prod_dispense_hx pdh
  PLAN (d)
   JOIN (o
   WHERE (o.encntr_id=pharm_dispenses->list[d.seq].encounter_id)
    AND (o.order_id=pharm_dispenses->list[d.seq].order_id)
    AND o.template_order_id=0
    AND o.catalog_type_cd=cdcatpharm)
   JOIN (dh
   WHERE dh.order_id=o.order_id
    AND dh.pharm_type_cd=cdpharminpat
    AND dh.disp_event_type_cd=cddispeventdevreturn
    AND dh.order_id > 0
    AND (dh.dispense_hx_id != pharm_dispenses->list[d.seq].dispense_hx_id))
   JOIN (pdh
   WHERE pdh.dispense_hx_id=dh.dispense_hx_id
    AND (pdh.item_id=pharm_dispenses->list[d.seq].item_id))
  DETAIL
   IF (curqual=0)
    pharm_dispenses->list[d.seq].disp_same_order = 1
   ENDIF
  WITH nocounter
 ;end select
 CALL text((soffrow+ 11),soffcol,"Checking encounters for same catalog charges...")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(pharm_dispenses->list,5))),
   orders o,
   dispense_hx dh,
   prod_dispense_hx pdh
  PLAN (d)
   JOIN (o
   WHERE (o.encntr_id=pharm_dispenses->list[d.seq].encounter_id)
    AND (o.order_id=pharm_dispenses->list[d.seq].order_id)
    AND o.template_order_id=0
    AND o.catalog_type_cd=cdcatpharm)
   JOIN (dh
   WHERE dh.order_id=o.order_id
    AND dh.pharm_type_cd=cdpharminpat
    AND dh.order_id > 0
    AND (dh.dispense_hx_id != pharm_dispenses->list[d.seq].dispense_hx_id))
   JOIN (pdh
   WHERE pdh.dispense_hx_id=dh.dispense_hx_id
    AND pdh.item_id IN (
   (SELECT
    ocir2.item_id
    FROM order_catalog_item_r ocir,
     order_catalog_item_r ocir2
    WHERE (ocir.item_id=pharm_dispenses->list[d.seq].item_id)
     AND ocir2.catalog_cd=ocir.catalog_cd
     AND (ocir2.item_id != pharm_dispenses->list[d.seq].item_id)))
    AND pdh.charge_ind=1)
  DETAIL
   IF (curqual=0)
    pharm_dispenses->list[d.seq].chrg_same_catalog = 1
   ENDIF
  WITH nocounter
 ;end select
 SET filename = cnvtlower(concat(trim(curdomain),"_ams_pharm_dispense_analysis",".csv"))
 IF (emailind=1)
  SET emailstatus = "Creating CSV and emailing file..."
  CALL text((soffrow+ 12),soffcol,emailstatus)
  SELECT INTO value(filename)
   encounter_id = pharm_dispenses->list[d1.seq].encounter_id, order_id = pharm_dispenses->list[d1.seq
   ].order_id, dispense_hx_id = pharm_dispenses->list[d1.seq].dispense_hx_id,
   prod_disp_hx_id = pharm_dispenses->list[d1.seq].prod_disp_hx_id, catalog_cd = pharm_dispenses->
   list[d1.seq].catalog_cd, item_id = pharm_dispenses->list[d1.seq].item_id,
   prod_description = substring(1,200,pharm_dispenses->list[d1.seq].product_desc), order_description
    = substring(1,225,pharm_dispenses->list[d1.seq].order_desc), facility = substring(1,40,
    uar_get_code_display(pharm_dispenses->list[d1.seq].facility_cd)),
   disp_loc = substring(1,40,uar_get_code_display(pharm_dispenses->list[d1.seq].disp_loc_cd)),
   disp_cat = substring(1,40,uar_get_code_display(pharm_dispenses->list[d1.seq].dispense_cat)),
   charge_type =
   IF ((pharm_dispenses->list[d1.seq].dc_charge_type=0)) "MAN"
   ELSEIF ((pharm_dispenses->list[d1.seq].dc_charge_type=1)) "COD"
   ELSEIF ((pharm_dispenses->list[d1.seq].dc_charge_type=2)) "COA"
   ELSE "ERR"
   ENDIF
   ,
   dispense_type = substring(1,40,uar_get_code_display(pharm_dispenses->list[d1.seq].
     disp_event_type_cd)), disp_dt_tm = format(pharm_dispenses->list[d1.seq].disp_dt_tm,";;q"),
   price_sched = substring(1,200,pharm_dispenses->list[d1.seq].price_sched),
   cost = pharm_dispenses->list[d1.seq].cost, price = pharm_dispenses->list[d1.seq].price,
   event_total_price = pharm_dispenses->list[d1.seq].event_total_price,
   qpd = pharm_dispenses->list[d1.seq].qpd, charged =
   IF ((pharm_dispenses->list[d1.seq].charged=0)) "No"
   ELSEIF ((pharm_dispenses->list[d1.seq].charged=1)) "Yes"
   ELSE "Error"
   ENDIF
   , chrg_same_ord =
   IF ((pharm_dispenses->list[d1.seq].chrg_same_order=0)) "No"
   ELSEIF ((pharm_dispenses->list[d1.seq].chrg_same_order=1)) "Yes"
   ELSE "Error"
   ENDIF
   ,
   chrg_dif_ord =
   IF ((pharm_dispenses->list[d1.seq].chrg_diff_order=0)) "No"
   ELSEIF ((pharm_dispenses->list[d1.seq].chrg_diff_order=1)) "Yes"
   ELSE "Error"
   ENDIF
   , ret_same_ord =
   IF ((pharm_dispenses->list[d1.seq].disp_same_order=0)) "No"
   ELSEIF ((pharm_dispenses->list[d1.seq].disp_same_order=1)) "Yes"
   ELSE "Error"
   ENDIF
   , ret_dif_ord =
   IF ((pharm_dispenses->list[d1.seq].disp_diff_order=0)) "No"
   ELSEIF ((pharm_dispenses->list[d1.seq].disp_diff_order=1)) "Yes"
   ELSE "Error"
   ENDIF
   ,
   chrg_same_catalog =
   IF ((pharm_dispenses->list[d1.seq].chrg_same_catalog=0)) "No"
   ELSEIF ((pharm_dispenses->list[d1.seq].chrg_same_catalog=1)) "Yes"
   ELSE "Error"
   ENDIF
   , nurse_unit = substring(1,40,uar_get_code_display(pharm_dispenses->list[d1.seq].pt_loc_cd))
   FROM (dummyt d1  WITH seq = value(size(pharm_dispenses->list,5)))
   WITH format = stream, pcformat('"',",",1), format(date,";;q"),
    format
  ;end select
  IF (curqual > 0)
   SET status = "S"
  ELSE
   SET status = "F"
   SET auditstatusmsg = "File NOT successfully created."
   GO TO exit_question
  ENDIF
  SET recpstr = amsemail
  SET subjstr = concat(trim(curdomain),": Pharmacy Dispense Analysis ",format(cnvtdatetime(curdate,
     curtime3),"@SHORTDATETIME"))
  SET bodystr = "Pharmacy dispense analysis attached."
  SET stat = emailfile(recpstr,amsemail,subjstr,bodystr,filename)
  IF (stat=1)
   SET status = "S"
   GO TO exit_question
  ELSE
   SET status = "F"
   SET auditstatusmsg = "Email NOT successfully sent."
   GO TO exit_question
  ENDIF
 ELSEIF (emailind=0)
  SET emailstatus = "Creating CSV and saving file..."
  CALL text((soffrow+ 12),soffcol,emailstatus)
  SELECT INTO value(filename)
   fin = substring(1,200,pharm_dispenses->list[d1.seq].fin_nbr), patient_name = substring(1,100,
    pharm_dispenses->list[d1.seq].patient), encounter_id = pharm_dispenses->list[d1.seq].encounter_id,
   order_id = pharm_dispenses->list[d1.seq].order_id, dispense_hx_id = pharm_dispenses->list[d1.seq].
   dispense_hx_id, prod_disp_hx_id = pharm_dispenses->list[d1.seq].prod_disp_hx_id,
   catalog_cd = pharm_dispenses->list[d1.seq].catalog_cd, item_id = pharm_dispenses->list[d1.seq].
   item_id, prod_description = substring(1,200,pharm_dispenses->list[d1.seq].product_desc),
   order_description = substring(1,225,pharm_dispenses->list[d1.seq].order_desc), facility =
   substring(1,40,uar_get_code_display(pharm_dispenses->list[d1.seq].facility_cd)), disp_loc =
   substring(1,40,uar_get_code_display(pharm_dispenses->list[d1.seq].disp_loc_cd)),
   disp_cat = substring(1,40,uar_get_code_display(pharm_dispenses->list[d1.seq].dispense_cat)),
   charge_type =
   IF ((pharm_dispenses->list[d1.seq].dc_charge_type=0)) "MAN"
   ELSEIF ((pharm_dispenses->list[d1.seq].dc_charge_type=1)) "COD"
   ELSEIF ((pharm_dispenses->list[d1.seq].dc_charge_type=2)) "COA"
   ELSE "ERR"
   ENDIF
   , dispense_type = substring(1,40,uar_get_code_display(pharm_dispenses->list[d1.seq].
     disp_event_type_cd)),
   disp_dt_tm = format(pharm_dispenses->list[d1.seq].disp_dt_tm,";;q"), price_sched = substring(1,200,
    pharm_dispenses->list[d1.seq].price_sched), cost = pharm_dispenses->list[d1.seq].cost,
   price = pharm_dispenses->list[d1.seq].price, event_total_price = pharm_dispenses->list[d1.seq].
   event_total_price, qpd = pharm_dispenses->list[d1.seq].qpd,
   charged =
   IF ((pharm_dispenses->list[d1.seq].charged=0)) "No"
   ELSEIF ((pharm_dispenses->list[d1.seq].charged=1)) "Yes"
   ELSE "Error"
   ENDIF
   , chrg_same_ord =
   IF ((pharm_dispenses->list[d1.seq].chrg_same_order=0)) "No"
   ELSEIF ((pharm_dispenses->list[d1.seq].chrg_same_order=1)) "Yes"
   ELSE "Error"
   ENDIF
   , chrg_dif_ord =
   IF ((pharm_dispenses->list[d1.seq].chrg_diff_order=0)) "No"
   ELSEIF ((pharm_dispenses->list[d1.seq].chrg_diff_order=1)) "Yes"
   ELSE "Error"
   ENDIF
   ,
   ret_same_ord =
   IF ((pharm_dispenses->list[d1.seq].disp_same_order=0)) "No"
   ELSEIF ((pharm_dispenses->list[d1.seq].disp_same_order=1)) "Yes"
   ELSE "Error"
   ENDIF
   , ret_dif_ord =
   IF ((pharm_dispenses->list[d1.seq].disp_diff_order=0)) "No"
   ELSEIF ((pharm_dispenses->list[d1.seq].disp_diff_order=1)) "Yes"
   ELSE "Error"
   ENDIF
   , chrg_same_catalog =
   IF ((pharm_dispenses->list[d1.seq].chrg_same_catalog=0)) "No"
   ELSEIF ((pharm_dispenses->list[d1.seq].chrg_same_catalog=1)) "Yes"
   ELSE "Error"
   ENDIF
   ,
   nurse_unit = substring(1,40,uar_get_code_display(pharm_dispenses->list[d1.seq].pt_loc_cd))
   FROM (dummyt d1  WITH seq = value(size(pharm_dispenses->list,5)))
   WITH format = stream, pcformat('"',",",1), format(date,";;q"),
    format
  ;end select
  IF (curqual > 0)
   SET status = "S"
  ELSE
   SET status = "F"
   SET auditstatusmsg = "File NOT successfully created."
   GO TO exit_question
  ENDIF
 ELSE
  CALL text((soffrow+ 14),soffcol,"Email indicator incorrect...")
  GO TO exit_question
 ENDIF
#exit_question
 IF (status="S")
  CALL text((soffrow+ 12),soffcol,concat(emailstatus," Success."))
  CALL text((soffrow+ 13),soffcol,"FILE LOCATION: $CCLUSERDIR")
  CALL text((soffrow+ 14),soffcol,concat("FILE: ",filename))
 ELSE
  CALL text((soffrow+ 12),soffcol,auditstatusmsg)
  IF (filename != "")
   CALL text((soffrow+ 14),soffcol,concat("FILE: ",filename))
  ELSE
   CALL text((soffrow+ 14),soffcol,"FILE: No file created.")
  ENDIF
 ENDIF
 SET questionexit = "Run another audit? Y/N:"
 CALL text((soffrow+ 16),soffcol,questionexit)
 CALL accept((soffrow+ 16),(soffcol+ 24),"A;CU","N"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="N")
  GO TO exit_script
 ELSE
  SET isfacilityset = 0
  SET isitemset = 0
  SET iscatset = 0
  SET isdisplocset = 0
  SET auditresultmsg = ""
  SET emailstatus = ""
  SET filename = ""
  SET amsemail = ""
  GO TO main_menu
 ENDIF
#exit_script
 CALL clear(1,1)
 SET last_mod = "001"
END GO
