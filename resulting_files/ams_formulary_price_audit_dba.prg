CREATE PROGRAM ams_formulary_price_audit:dba
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
 DECLARE checkallfac = i2 WITH protect
 DECLARE checkspecfac = f8 WITH protect
 DECLARE facilitydisp = vc WITH protect
 DECLARE facilitycd = f8 WITH protect
 DECLARE isfacilityset = i2 WITH protect
 DECLARE itemqpd = i2 WITH protect
 DECLARE cnt = i4 WITH protect
 DECLARE itemfac = f8 WITH protect
 DECLARE loopcnt = i4 WITH protect
 DECLARE question1 = vc WITH protect
 DECLARE question2 = vc WITH protect
 DECLARE question3 = vc WITH protect
 DECLARE questionvalidate = vc WITH protect
 DECLARE questionexit = vc WITH protect
 DECLARE cd_cat_pharm = f8 WITH constant(uar_get_code_by("MEANING",6000,"PHARMACY")), protect
 DECLARE cd_pharm_inpt = f8 WITH constant(uar_get_code_by("MEANING",4500,"INPATIENT")), protect
 DECLARE cd_desc = f8 WITH constant(uar_get_code_by("MEANING",11000,"DESC")), protect
 DECLARE cd_ndc = f8 WITH constant(uar_get_code_by("MEANING",11000,"NDC")), protect
 DECLARE cd_cdm = f8 WITH constant(uar_get_code_by("MEANING",11000,"CDM")), protect
 DECLARE cd_syspkgtyp = f8 WITH constant(uar_get_code_by("MEANING",4062,"SYSPKGTYP")), protect
 DECLARE cd_system = f8 WITH constant(uar_get_code_by("MEANING",4062,"SYSTEM")), protect
 DECLARE cd_orderable = f8 WITH constant(uar_get_code_by("MEANING",4063,"ORDERABLE")), protect
 DECLARE cd_active = f8 WITH constant(uar_get_code_by("MEANING",48,"ACTIVE")), protect
 DECLARE amsemail = vc WITH protect
 DECLARE subjstr = vc WITH protect
 DECLARE recpstr = vc WITH protect
 DECLARE bodystr = vc WITH protect
 DECLARE filename = vc WITH protect
 DECLARE auditstatusmsg = vc WITH protect
 DECLARE statusmsg = vc WITH protect
 RECORD request(
   1 pricing_ind = i2
   1 price_schedule_id = f8
   1 total_price = f8
   1 care_locn_cd = f8
   1 inv_loc_cd = f8
   1 facility_cd = f8
   1 encounter_type_cd = f8
   1 bill_list[*]
     2 item_id = f8
     2 dose_quantity = f8
     2 price = f8
     2 manf_id = f8
     2 tnf_cost = f8
   1 no_cost_ind = i2
 )
 RECORD item_info(
   1 list[*]
     2 facility = vc
     2 item_id = f8
     2 description = vc
     2 med_flag = i2
     2 int_flag = i2
     2 cont_flag = i2
     2 price = f8
     2 price_sched = vc
     2 cost_basis_cd = f8
     2 price_sched_id = f8
     2 cost = f8
     2 dispense_category = vc
     2 ndc = vc
     2 sequence = i4
     2 manf_item_id = f8
     2 cdm = vc
 )
 RECORD price_reply(
   1 total_price = f8
   1 bill_list[*]
     2 cost = f8
     2 tax_amt = f8
     2 price_sched_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 CALL validatelogin(null)
#main_menu
 SET auditstatusmsg = " "
 CALL clear(1,1)
 CALL box((soffrow - 5),(soffcol - 1),(numrows+ 3),(numcols+ 3))
 CALL video(r)
 CALL text((soffrow - 4),soffcol,
  "                        AMS Formulary Price Audit                          ")
 CALL text((soffrow - 3),soffcol,
  "       Audit will provide list of products and their price and cost        ")
 CALL video(n)
 CALL line((soffrow - 1),(soffcol - 1),(numcols+ 2),xhor)
 CALL line((soffrow+ 15),(soffcol - 1),(numcols+ 2),xhor)
 SET isfacilityset = 0
 WHILE (isfacilityset=0)
   CALL text(soffrow,soffcol,"Fill in facility display (or ALL) (Shift+F5 to select facility).")
   SET question1 = "Facility display:"
   CALL text((soffrow+ 1),soffcol,question1)
   SET help = promptmsg("Facility display starts with:")
   SET help = pos(3,1,15,80)
   SET help =
   SELECT DISTINCT INTO "nl:"
    facility = cv.display
    FROM code_value cv,
     med_flex_object_idx mfoi
    PLAN (cv
     WHERE cv.code_set=220
      AND cv.active_ind=1
      AND cv.cdf_meaning="FACILITY"
      AND cnvtupper(cv.display) >= cnvtupper(curaccept))
     JOIN (mfoi
     WHERE mfoi.parent_entity_id=cv.code_value
      AND mfoi.parent_entity_name="CODE_VALUE")
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
      AND cnvtupper(cv.display)=cnvtupper(facilitydisp)
      AND cv.code_value != 0
     DETAIL
      checkspecfac = cv.code_value, facilitydisp = cv.display
     WITH nocounter
    ;end select
    IF (curqual=0)
     CALL clear((soffrow+ 1),soffcol,numcols)
     CALL clear((soffrow+ 2),soffcol,numcols)
     CALL text((soffrow+ 2),soffcol,concat(facilitydisp," is not a valid facility display."))
    ELSE
     CALL clear((soffrow+ 2),soffcol,numcols)
     SET checkallfac = 0
     SET isfacilityset = 1
    ENDIF
   ENDIF
 ENDWHILE
 SET question2 = "Enter the QPD as a whole number (1-9999):"
 CALL text((soffrow+ 2),soffcol,question2)
 CALL accept((soffrow+ 2),(soffcol+ (textlen(question2)+ 1)),"9(4);",1
  WHERE curaccept > 0.0)
 SET itemqpd = cnvtint(curaccept)
 CALL clear((soffrow+ 3),soffcol,numcols)
 SET amsemail = ""
 SET question3 = "Enter your email address:"
 CALL text((soffrow+ 3),soffcol,question3)
 CALL accept((soffrow+ 3),(soffcol+ (textlen(question3)+ 1)),"P(48-textlen(question3));C",gethnaemail
  (null)
  WHERE trim(curaccept)="*@*.*")
 SET amsemail = curaccept
 CALL clear((soffrow+ 16),soffcol,numcols)
 CALL text((soffrow+ 4),soffcol,concat("Getting Items..."))
 SELECT INTO "NL:"
  facility = uar_get_code_display(mfoi.parent_entity_id), generic = oc.primary_mnemonic, mdf.item_id,
  seq = mfoix.sequence, ndc = mi1.value, desc = mi2.value,
  upper_desc = cnvtupper(mi2.value), cdm = mi3.value, mod.price_sched_id,
  ps.price_sched_desc, ps.cost_basis_cd, uar_get_code_display(mod.dispense_category_cd),
  mdi.med_filter_ind, mdi.continuous_filter_ind, mdi.intermittent_filter_ind
  FROM medication_definition md,
   med_def_flex mdf,
   order_catalog_item_r ocir,
   order_catalog oc,
   med_def_flex mdfx,
   med_flex_object_idx mfoi,
   med_flex_object_idx mfoix,
   med_flex_object_idx mfoi2,
   med_flex_object_idx mfoi3,
   med_identifier mi1,
   med_identifier mi2,
   med_identifier mi3,
   med_oe_defaults mod,
   price_sched ps,
   med_dispense mdi
  PLAN (md
   WHERE md.med_type_flag=0)
   JOIN (mdf
   WHERE mdf.item_id=md.item_id
    AND mdf.active_ind=1
    AND mdf.pharmacy_type_cd=cd_pharm_inpt
    AND mdf.flex_type_cd=cd_syspkgtyp)
   JOIN (ocir
   WHERE ocir.item_id=mdf.item_id)
   JOIN (oc
   WHERE oc.catalog_cd=ocir.catalog_cd)
   JOIN (mfoi
   WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
    AND mfoi.flex_object_type_cd=cd_orderable
    AND mfoi.parent_entity_name="CODE_VALUE"
    AND ((mfoi.parent_entity_id=checkspecfac) OR (((checkallfac=1) OR (mfoi.parent_entity_id=0)) )) )
   JOIN (mdfx
   WHERE mdfx.item_id=mdf.item_id
    AND mdfx.flex_type_cd=cd_system)
   JOIN (mfoix
   WHERE mfoix.med_def_flex_id=mdfx.med_def_flex_id
    AND mfoix.parent_entity_name="MED_PRODUCT")
   JOIN (mi1
   WHERE mi1.item_id=mdf.item_id
    AND mi1.med_def_flex_id=mdfx.med_def_flex_id
    AND mi1.med_product_id=mfoix.parent_entity_id
    AND mi1.med_identifier_type_cd=cd_ndc
    AND mi1.active_ind=1
    AND mi1.primary_ind=1)
   JOIN (mi2
   WHERE mi2.item_id=mdf.item_id
    AND mi2.med_def_flex_id=mdfx.med_def_flex_id
    AND mi2.med_product_id=0
    AND mi2.med_identifier_type_cd=cd_desc
    AND mi2.active_ind=1
    AND mi2.primary_ind=1)
   JOIN (mi3
   WHERE mi3.item_id=mdf.item_id
    AND mi3.med_def_flex_id=mdfx.med_def_flex_id
    AND mi3.med_product_id=0
    AND mi3.med_identifier_type_cd=cd_cdm
    AND mi3.active_ind=1
    AND mi3.primary_ind=1)
   JOIN (mfoi2
   WHERE mfoi2.med_def_flex_id=mdfx.med_def_flex_id
    AND mfoi2.parent_entity_name="MED_OE_DEFAULTS")
   JOIN (mod
   WHERE mod.med_oe_defaults_id=mfoi2.parent_entity_id)
   JOIN (ps
   WHERE ps.price_sched_id=mod.price_sched_id)
   JOIN (mfoi3
   WHERE mfoi3.med_def_flex_id=mdf.med_def_flex_id
    AND mfoi3.parent_entity_name="MED_DISPENSE")
   JOIN (mdi
   WHERE mdi.med_dispense_id=mfoi3.parent_entity_id)
  ORDER BY upper_desc, mi2.item_id, seq,
   ndc, facility
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt > size(item_info->list,5))
    stat = alterlist(item_info->list,(cnt+ 999))
   ENDIF
   item_info->list[cnt].facility = facility, item_info->list[cnt].item_id = mdf.item_id, item_info->
   list[cnt].description = desc,
   item_info->list[cnt].med_flag = mdi.med_filter_ind, item_info->list[cnt].price_sched = ps
   .price_sched_desc, item_info->list[cnt].price_sched_id = ps.price_sched_id,
   item_info->list[cnt].cost_basis_cd = ps.cost_basis_cd, item_info->list[cnt].cont_flag = mdi
   .continuous_filter_ind, item_info->list[cnt].dispense_category = uar_get_code_display(mod
    .dispense_category_cd),
   item_info->list[cnt].ndc = ndc, item_info->list[cnt].cdm = cdm, item_info->list[cnt].sequence =
   seq,
   item_info->list[cnt].int_flag = mdi.intermittent_filter_ind, item_info->list[cnt].manf_item_id =
   mi1.med_product_id
  FOOT REPORT
   stat = alterlist(item_info->list,cnt)
  WITH nocounter
 ;end select
 IF (cnt=0)
  CALL clear((soffrow+ 4),soffcol,numcols)
  CALL text((soffrow+ 4),soffcol,concat("Total items in audit: ",cnvtstring(cnt)))
  SET auditstatusmsg = "No results found.  No CSV created or email sent."
  GO TO exit_question
 ELSE
  CALL clear((soffrow+ 4),soffcol,numcols)
  CALL text((soffrow+ 4),soffcol,concat("Total items in audit: ",cnvtstring(cnt)))
 ENDIF
 SET questionvalidate = "Continue with audit? (Y/N):"
 CALL text((soffrow+ 16),soffcol,questionvalidate)
 CALL accept((soffrow+ 16),(soffcol+ (textlen(questionvalidate)+ 1)),"A;CU","N"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="N")
  GO TO main_menu
 ELSE
  CALL clear((soffrow+ 16),soffcol,numcols)
 ENDIF
 FOR (loopcnt = 1 TO size(item_info->list,5))
   SET stat = initrec(request)
   SET request->pricing_ind = 1
   SET request->price_schedule_id = item_info->list[loopcnt].price_sched_id
   SET stat = alterlist(request->bill_list,1)
   SET request->bill_list[1].item_id = item_info->list[loopcnt].item_id
   SET request->bill_list[1].dose_quantity = itemqpd
   SET request->bill_list[1].manf_id = item_info->list[loopcnt].manf_item_id
   SET stat = initrec(price_reply)
   SET message = window
   EXECUTE rx_get_cost_wrapper  WITH replace("REPLY",price_reply)
   CALL text((soffrow+ 6),soffcol,concat("Calculating Price - ",trim(cnvtstring(loopcnt))," of ",trim
     (cnvtstring(cnt))," completed."))
   SET item_info->list[loopcnt].price = price_reply->total_price
   SET item_info->list[loopcnt].cost = price_reply->bill_list[1].cost
 ENDFOR
 SET filename = cnvtlower(concat(trim(replace(facilitydisp," ","_")),"_ams_formulary_price_audit.csv"
   ))
 SELECT INTO value(filename)
  facility = evaluate(item_info->list[d1.seq].facility,"",substring(1,200,"All Facilities"),substring
   (1,40,item_info->list[d1.seq].facility)), description = substring(1,200,item_info->list[d1.seq].
   description), ndc = substring(1,200,item_info->list[d1.seq].ndc),
  cdm = substring(1,200,item_info->list[d1.seq].cdm), sequence = item_info->list[d1.seq].sequence,
  cost = item_info->list[d1.seq].cost,
  price = item_info->list[d1.seq].price, price_sched = substring(1,200,item_info->list[d1.seq].
   price_sched), cost_type = substring(1,200,uar_get_code_display(item_info->list[cnt].cost_basis_cd)
   ),
  med_flag = item_info->list[d1.seq].med_flag, cont_flag = item_info->list[d1.seq].cont_flag,
  int_flag = item_info->list[d1.seq].int_flag,
  disp_category = substring(1,200,item_info->list[d1.seq].dispense_category), item_id = item_info->
  list[d1.seq].item_id
  FROM (dummyt d1  WITH seq = value(size(item_info->list,5)))
  WITH format = stream, pcformat('"',",",1), format(date,";;q"),
   format
 ;end select
 SET recpstr = amsemail
 SET subjstr = concat(trim(curdomain),": Pharmacy Price Cost Analysis - ",trim(facilitydisp))
 SET bodystr = concat(facilitydisp," - price cost analysis attached.")
 SET stat = emailfile(recpstr,amsemail,subjstr,bodystr,filename)
 CALL text((soffrow+ 13),soffcol,concat("FILE LOCATION: $CCLUSERDIR"))
 CALL text((soffrow+ 14),soffcol,concat("FILE: ",filename))
 IF (stat=1)
  SET status = "S"
  SET auditstatusmsg = concat(auditstatusmsg,"Email successfully sent.")
 ELSE
  SET status = "F"
  SET auditstatusmsg = concat(auditstatusmsg,"Email NOT successfully sent.")
 ENDIF
#exit_question
 CALL text((soffrow+ 7),soffcol,concat(auditstatusmsg))
 CALL clear((soffrow+ 16),soffcol,numcols)
 SET questionexit = "Run another audit? Y/N:"
 CALL text((soffrow+ 16),soffcol,questionexit)
 CALL accept((soffrow+ 16),(soffcol+ (textlen(questionexit)+ 1)),"A;CU","N"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="N")
  GO TO exit_script
 ELSE
  GO TO main_menu
 ENDIF
#exit_script
 CALL clear(1,1)
 SET message = nowindow
 SET last_mod = "000"
END GO
