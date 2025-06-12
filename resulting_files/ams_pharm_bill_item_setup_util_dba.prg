CREATE PROGRAM ams_pharm_bill_item_setup_util:dba
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
 DECLARE displaymappings(null) = null WITH protect
 DECLARE loadmappings(null) = null WITH protect
 DECLARE promptuserfornewmapping(null) = null WITH protect
 DECLARE addmapping(facilitycd=f8,billcodeschcd=f8,identtypecd=f8) = i2 WITH protect
 DECLARE removemapping(bnv_id=f8) = null WITH protect
 DECLARE displayemailcontacts(null) = null WITH protect
 DECLARE loademails(null) = null WITH protect
 DECLARE promptuserfornewemail(null) = null WITH protect
 DECLARE addemail(facilitycd=f8,email=vc) = i2 WITH protect
 DECLARE runinitialsetup(null) = null WITH protect
 DECLARE displayidentifiercounts(null) = null WITH protect
 DECLARE loadexistingbillitems(facilitycd=f8) = null WITH protect
 DECLARE syncidentifiers(null) = null WITH protect
 DECLARE getcdmprefsetting(null) = i2 WITH protect
 DECLARE setinitialsetupdatetime(facilitycd=f8) = i2 WITH protect
 DECLARE getinitialsetupdatetime(facilitycd=f8) = i2 WITH protect
 DECLARE removeemail(bnv_id=f8) = null WITH protect
 DECLARE title_line = c75 WITH protect, constant(
  "                    AMS Pharmacy Bill Item Setup Utility                    ")
 DECLARE detail_line = c75 WITH protect, constant(
  "   Performs prerequiste steps to create bill code schedules for products    ")
 DECLARE script_name = vc WITH protect, constant("AMS_PHARM_BILL_ITEM_SETUP")
 DECLARE info_domain = vc WITH protect, constant("AMS_TOOLKIT")
 DECLARE inpatient_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4500,"INPATIENT"))
 DECLARE active_status_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE system_pkg_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4062,"SYSPKGTYP"))
 DECLARE system_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4062,"SYSTEM"))
 DECLARE orderable_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4063,"ORDERABLE"))
 DECLARE manf_item = i2 WITH protect, constant(0)
 DECLARE cdm_pref = i2 WITH protect, constant(getcdmprefsetting(null))
 DECLARE ndc_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"NDC"))
 DECLARE pharm_act_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",106,"PHARMACY"))
 DECLARE ext_parent_manf_item_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",13016,
   "MANF ITEM"))
 DECLARE errormsg = vc WITH protect
 RECORD mappings(
   1 mapping_cnt = i4
   1 list[*]
     2 facility_cd = f8
     2 facility_disp = vc
     2 bill_code_sched_cd = f8
     2 bill_code_sched_disp = vc
     2 med_identifier_type_cd = f8
     2 med_identifier_disp = vc
     2 br_name_value_id = f8
 ) WITH protect
 RECORD emails(
   1 emails_cnt = i4
   1 list[*]
     2 facility_cd = f8
     2 facility_disp = vc
     2 email_address = vc
     2 br_name_value_id = f8
 ) WITH protect
 RECORD identifiers(
   1 list[*]
     2 item_id = f8
     2 old_value = vc
     2 new_value = vc
     2 med_identifier_id = f8
     2 med_def_flex_id = f8
     2 bill_code_sched_cd = f8
     2 med_identifier_type_cd = f8
     2 med_type_flag = i2
     2 facility_cd = f8
     2 insert_ind = i2
     2 update_ind = i2
 ) WITH protect
 CALL validatelogin(null)
 SET status = "S"
#main_menu
 CALL drawmenu(title_line,detail_line,"")
 CALL text((soffrow+ 4),(soffcol+ 22),"1 Copy Settings from Products to CSPricingTool")
 CALL text((soffrow+ 5),(soffcol+ 22),"2 View/Modify Identifier to BC Schedule Mapping")
 CALL text((soffrow+ 6),(soffcol+ 22),"3 View/Modify Email Contacts for a Facility")
 CALL text((soffrow+ 7),(soffcol+ 22),"4 View Existing Pharmacy Identifiers")
 CALL text((soffrow+ 8),(soffcol+ 22),"5 Run Initial Setup for a Facility")
 CALL text((soffrow+ 9),(soffcol+ 22),"6 Exit")
 CALL accept(quesrow,(soffcol+ 17),"9;",6
  WHERE curaccept IN (1, 2, 3, 4, 5,
  6))
 CASE (curaccept)
  OF 1:
   CALL clear(1,1)
   SET message = nowindow
   EXECUTE ams_pharm_bill_item_setup
  OF 2:
   CALL displaymappings(null)
   GO TO main_menu
  OF 3:
   CALL displayemailcontacts(null)
   GO TO main_menu
  OF 4:
   CALL displayidentifiercounts(null)
  OF 5:
   CALL runinitialsetup(null)
   GO TO main_menu
  OF 6:
   GO TO exit_script
 ENDCASE
 SUBROUTINE displaymappings(null)
   DECLARE billcodedisp = c26 WITH protect
   DECLARE facilitydisp = c22 WITH protect
   DECLARE identdisp = c23 WITH protect
   CALL clearscreen(null)
   CALL loadmappings(null)
   SET maxrows = 12
   CALL drawscrollbox((soffrow+ 1),(soffcol+ 1),numrows,(numcols+ 1))
   SET cnt = 0
   WHILE (cnt < maxrows
    AND (cnt < mappings->mapping_cnt))
     SET cnt = (cnt+ 1)
     SET facilitydisp = mappings->list[cnt].facility_disp
     SET billcodedisp = mappings->list[cnt].bill_code_sched_disp
     SET identdisp = mappings->list[cnt].med_identifier_disp
     SET rowstr = build2(facilitydisp," ",billcodedisp," ",identdisp)
     CALL scrolltext(cnt,rowstr)
   ENDWHILE
   SET cnt = 1
   SET arow = 1
   SET pick = 0
   CALL text((soffrow+ 1),(soffcol+ 2),"Facility")
   CALL text((soffrow+ 1),(soffcol+ 25),"Bill Code Schedule")
   CALL text((soffrow+ 1),(soffcol+ 52),"Identifier")
   WHILE (pick=0)
     CALL text(quesrow,soffcol,"(M)ain Menu or (A)dd or (R)emove Item:")
     CALL accept(quesrow,(soffcol+ 38),"A;CUS","M"
      WHERE curaccept IN ("M", "A", "R"))
     CASE (curscroll)
      OF 0:
       IF (curaccept="M")
        GO TO main_menu
       ELSEIF (curaccept="A")
        CALL promptuserfornewmapping(null)
        GO TO main_menu
       ELSE
        CALL removemapping(mappings->list[cnt].br_name_value_id)
       ENDIF
       SET pick = 1
      OF 1:
       IF ((cnt < mappings->mapping_cnt))
        SET cnt = (cnt+ 1)
        SET facilitydisp = mappings->list[cnt].facility_disp
        SET billcodedisp = mappings->list[cnt].bill_code_sched_disp
        SET identdisp = mappings->list[cnt].med_identifier_disp
        SET rowstr = build2(facilitydisp," ",billcodedisp," ",identdisp)
        CALL downarrow(rowstr)
       ENDIF
      OF 2:
       IF (cnt > 1)
        SET cnt = (cnt - 1)
        SET facilitydisp = mappings->list[cnt].facility_disp
        SET billcodedisp = mappings->list[cnt].bill_code_sched_disp
        SET identdisp = mappings->list[cnt].med_identifier_disp
        SET rowstr = build2(facilitydisp," ",billcodedisp," ",identdisp)
        CALL uparrow(rowstr)
       ENDIF
     ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE loadmappings(null)
   DECLARE cnt = i4 WITH protect
   DECLARE pos = i4 WITH protect
   DECLARE facstr = vc WITH protect
   DECLARE notfnd = vc WITH protect, constant("<not_found>")
   SET stat = initrec(mappings)
   SELECT INTO "nl:"
    fac_disp = uar_get_code_display(cnvtreal(piece(bnv.br_nv_key1,"|",2,notfnd,3))), bnv.br_nv_key1,
    bnv.br_name,
    bnv.br_value
    FROM br_name_value bnv
    PLAN (bnv
     WHERE bnv.br_nv_key1=patstring(concat(script_name,"|*"))
      AND bnv.br_nv_key1 != concat(script_name,"|EMAIL")
      AND bnv.br_nv_key1 != concat(script_name,"|SETUPDTTM"))
    ORDER BY fac_disp, bnv.br_nv_key1
    HEAD REPORT
     cnt = 0
    HEAD bnv.br_nv_key1
     hcpcsfound = 0, qcffound = 0
    DETAIL
     cnt = (cnt+ 1)
     IF (mod(cnt,5)=1)
      stat = alterlist(mappings->list,(cnt+ 4))
     ENDIF
     facstr = piece(bnv.br_nv_key1,"|",2,notfnd,3)
     IF (facstr != notfnd)
      mappings->list[cnt].facility_cd = cnvtreal(facstr)
     ENDIF
     mappings->list[cnt].facility_disp = evaluate(facstr,"0","All",uar_get_code_display(mappings->
       list[cnt].facility_cd)), mappings->list[cnt].bill_code_sched_cd = cnvtreal(bnv.br_value)
     IF (cnvtreal(bnv.br_value) > 0)
      mappings->list[cnt].bill_code_sched_disp = uar_get_code_display(cnvtreal(bnv.br_value))
     ELSE
      mappings->list[cnt].bill_code_sched_disp = "QCF"
     ENDIF
     mappings->list[cnt].med_identifier_type_cd = cnvtreal(bnv.br_name), mappings->list[cnt].
     med_identifier_disp = uar_get_code_display(cnvtreal(bnv.br_name)), mappings->list[cnt].
     br_name_value_id = bnv.br_name_value_id
    FOOT REPORT
     mappings->mapping_cnt = cnt
     IF (mod(cnt,5) != 0)
      stat = alterlist(mappings->list,cnt)
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE promptuserfornewmapping(null)
   DECLARE facilitycd = f8 WITH protect
   DECLARE facilitydisp = vc WITH protect
   DECLARE identtypecd = f8 WITH protect
   DECLARE identdisp = vc WITH protect
   DECLARE billcodeschedcd = f8 WITH protect
   DECLARE billcodedisp = vc WITH protect
   DECLARE prevexistsind = i2 WITH protect
   SET facilitycd = - (1)
   SET identtypecd = 0
   CALL clearscreen(null)
   CALL text(soffrow,soffcol,
    "Create new identifier to bill code schedule mapping. (Shift + F5 to select)")
   WHILE ((facilitycd=- (1)))
     CALL text((soffrow+ 1),soffcol,"Facility display:")
     SET help = promptmsg("Facility display starts with:")
     SET help = pos(3,1,15,80)
     SET help =
     SELECT INTO "nl:"
      facility = cv.display
      FROM code_value cv
      PLAN (cv
       WHERE cv.code_set=220
        AND cv.active_ind=1
        AND cv.cdf_meaning="FACILITY"
        AND cnvtupper(cv.display) >= cnvtupper(curaccept))
      ORDER BY cv.display_key
     ;end select
     CALL accept((soffrow+ 1),(soffcol+ 29),"P(40);CP")
     SET facilitydisp = trim(cnvtupper(curaccept))
     SET help = off
     IF (cnvtupper(curaccept)="QUIT")
      GO TO main_menu
     ELSEIF (cnvtupper(curaccept)="ALL")
      SET facilitycd = 0
     ELSE
      SELECT INTO "nl:"
       cv.code_value
       FROM code_value cv
       WHERE cv.code_set=220
        AND cv.active_ind=1
        AND cv.cdf_meaning="FACILITY"
        AND trim(cnvtupper(cv.display))=cnvtupper(facilitydisp)
       DETAIL
        facilitycd = cv.code_value
       WITH nocounter
      ;end select
      IF (curqual != 1)
       CALL text((soffrow+ 2),soffcol,"No facility found! Enter a valid facility display value.")
      ELSE
       CALL clear((soffrow+ 2),soffcol,numcols)
      ENDIF
     ENDIF
   ENDWHILE
   WHILE (identtypecd=0)
     CALL text((soffrow+ 2),soffcol,"Pharmacy identifier:")
     SET help = promptmsg("Identifier starts with:")
     SET help = pos(3,1,15,80)
     SET help =
     SELECT INTO "nl:"
      identifier = cv.display
      FROM code_value cv
      PLAN (cv
       WHERE cv.code_set=11000
        AND cv.active_ind=1
        AND cv.cdf_meaning IN ("HCPCS", "RX *")
        AND cnvtupper(cv.display) >= cnvtupper(curaccept))
      ORDER BY cv.display_key
     ;end select
     CALL accept((soffrow+ 2),(soffcol+ 29),"P(40);CP")
     SET identdisp = trim(cnvtupper(curaccept))
     SET help = off
     IF (cnvtupper(curaccept)="QUIT")
      GO TO main_menu
     ENDIF
     SELECT INTO "nl:"
      cv.code_value
      FROM code_value cv
      WHERE cv.code_set=11000
       AND cv.active_ind=1
       AND cv.cdf_meaning IN ("HCPCS", "RX *")
       AND trim(cnvtupper(cv.display))=cnvtupper(identdisp)
      DETAIL
       identtypecd = cv.code_value
      WITH nocounter
     ;end select
     IF (curqual != 1)
      CALL text((soffrow+ 3),soffcol,"No identifier found! Enter a valid identifier value.")
     ELSE
      CALL clear((soffrow+ 3),soffcol,numcols)
     ENDIF
   ENDWHILE
   WHILE (billcodeschedcd=0)
     CALL text((soffrow+ 3),soffcol,"Bill code schedule (or QCF):")
     SET help = promptmsg("Bill code schedule starts with:")
     SET help = pos(3,1,15,80)
     SET help =
     SELECT INTO "nl:"
      bill_code_schedule = cv.display
      FROM code_value cv
      PLAN (cv
       WHERE cv.code_set=14002
        AND cv.active_ind=1
        AND cv.cdf_meaning IN ("HCPCS", "REVENUE")
        AND cnvtupper(cv.display) >= cnvtupper(curaccept))
      ORDER BY cv.display_key
     ;end select
     CALL accept((soffrow+ 3),(soffcol+ 29),"P(40);CP")
     SET billcodedisp = trim(cnvtupper(curaccept))
     SET help = off
     IF (cnvtupper(curaccept)="QUIT")
      GO TO main_menu
     ENDIF
     IF (cnvtupper(curaccept) != "QCF")
      SELECT INTO "nl:"
       cv.code_value
       FROM code_value cv
       WHERE cv.code_set=14002
        AND cv.active_ind=1
        AND cv.cdf_meaning IN ("HCPCS", "REVENUE")
        AND trim(cnvtupper(cv.display))=cnvtupper(billcodedisp)
       DETAIL
        billcodeschedcd = cv.code_value
       WITH nocounter
      ;end select
      IF (curqual != 1)
       CALL text((soffrow+ 4),soffcol,"No identifier found! Enter a valid identifier value.")
      ELSE
       CALL clear((soffrow+ 4),soffcol,numcols)
      ENDIF
     ELSE
      SET billcodeschedcd = - (1)
     ENDIF
   ENDWHILE
   SELECT INTO "nl:"
    bnv.br_nv_key1
    FROM br_name_value bnv
    PLAN (bnv
     WHERE bnv.br_nv_key1=concat(script_name,"|",trim(cnvtstring(facilitycd)))
      AND ((bnv.br_name=trim(cnvtstring(identtypecd))) OR (bnv.br_value=trim(cnvtstring(
       billcodeschedcd)))) )
    HEAD REPORT
     prevexistsind = 0
    DETAIL
     prevexistsind = 1
    WITH nocounter
   ;end select
   IF (prevexistsind=1)
    CALL text((soffrow+ 13),soffcol,"A mapping with this bill code schedule or identifier already")
    CALL text((soffrow+ 14),soffcol,"exists for this facility. Mapping has not been saved.")
   ELSE
    SET stat = addmapping(facilitycd,billcodeschedcd,identtypecd)
    IF (stat=0)
     CALL text((soffrow+ 14),soffcol,"Error writing mapping to br_name_value")
    ELSE
     CALL text((soffrow+ 14),soffcol,"Successfully saved identifier to bill code schedule mapping")
    ENDIF
   ENDIF
   CALL text(quesrow,soffcol,"Continue?:")
   CALL accept(quesrow,(soffcol+ 10),"A;CUS","Y"
    WHERE curaccept IN ("Y"))
 END ;Subroutine
 SUBROUTINE addmapping(facilitycd,billcodeschcd,identtypecd)
   DECLARE retval = i2 WITH protect, noconstant(0)
   SET trace = recpersist
   RECORD br_request(
     1 br_name = vc
     1 br_value = vc
     1 br_nv_key1 = vc
   )
   RECORD br_reply(
     1 br_name_value_id = f8
     1 status_data
       2 status = c1
       2 subeventstatus[*]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET br_request->br_name = trim(cnvtstring(identtypecd))
   SET br_request->br_value = trim(cnvtstring(billcodeschcd))
   SET br_request->br_nv_key1 = trim(build(script_name,"|",cnvtstring(facilitycd)))
   EXECUTE bed_add_name_value  WITH replace("REQUEST",br_request), replace("REPLY",br_reply)
   IF ((br_reply->status_data.status="F"))
    SET retval = 0
   ELSE
    COMMIT
    SET retval = 1
   ENDIF
   SET trace = norecpersist
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE removemapping(bnv_id)
   DELETE  FROM br_name_value bnv
    WHERE bnv.br_name_value_id=bnv_id
     AND bnv.br_name_value_id != 0.0
    WITH nocounter
   ;end delete
   CALL clear(quesrow,soffcol,numcols)
   IF (curqual=1
    AND error(errormsg,0)=0)
    CALL text(quesrow,soffcol,"Commit?:")
    CALL accept(quesrow,(soffcol+ 8),"A;CU"
     WHERE curaccept IN ("Y", "N"))
    IF (curaccept="Y")
     COMMIT
    ELSE
     ROLLBACK
    ENDIF
   ELSE
    CALL text((soffrow+ 14),soffcol,"ERROR DELETING FROM BR_NAME_VALUE.ROLLING BACK CHANGE.")
    ROLLBACK
    CALL text(quesrow,soffcol,"Continue?:")
    CALL accept(quesrow,(soffcol+ 10),"A;CU","Y"
     WHERE curaccept IN ("Y"))
   ENDIF
 END ;Subroutine
 SUBROUTINE displayemailcontacts(null)
   DECLARE facilitydisp = c30 WITH protect
   DECLARE email = c44 WITH protect
   CALL clearscreen(null)
   CALL loademails(null)
   SET maxrows = 12
   CALL drawscrollbox((soffrow+ 1),(soffcol+ 1),numrows,(numcols+ 1))
   SET cnt = 0
   WHILE (cnt < maxrows
    AND (cnt < emails->emails_cnt))
     SET cnt = (cnt+ 1)
     SET facilitydisp = emails->list[cnt].facility_disp
     SET email = emails->list[cnt].email_address
     SET rowstr = build2(facilitydisp," ",email)
     CALL scrolltext(cnt,rowstr)
   ENDWHILE
   SET cnt = 1
   SET arow = 1
   SET pick = 0
   CALL text((soffrow+ 1),(soffcol+ 2),"Facility")
   CALL text((soffrow+ 1),(soffcol+ 33),"Email")
   WHILE (pick=0)
     CALL text(quesrow,soffcol,"(M)ain Menu or (A)dd or (R)emove Email:")
     CALL accept(quesrow,(soffcol+ 39),"A;CUS","M"
      WHERE curaccept IN ("M", "A", "R"))
     CASE (curscroll)
      OF 0:
       IF (curaccept="M")
        GO TO main_menu
       ELSEIF (curaccept="A")
        CALL promptuserfornewemail(null)
        GO TO main_menu
       ELSE
        CALL removeemail(emails->list[cnt].br_name_value_id)
       ENDIF
       SET pick = 1
      OF 1:
       IF ((cnt < emails->emails_cnt))
        SET cnt = (cnt+ 1)
        SET facilitydisp = emails->list[cnt].facility_disp
        SET email = emails->list[cnt].email_address
        SET rowstr = build2(facilitydisp," ",email)
        CALL downarrow(rowstr)
       ENDIF
      OF 2:
       IF (cnt > 1)
        SET cnt = (cnt - 1)
        SET facilitydisp = emails->list[cnt].facility_disp
        SET email = emails->list[cnt].email_address
        SET rowstr = build2(facilitydisp," ",email)
        CALL uparrow(rowstr)
       ENDIF
     ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE loademails(null)
   DECLARE cnt = i4 WITH protect
   DECLARE pos = i4 WITH protect
   DECLARE facstr = vc WITH protect
   DECLARE notfnd = vc WITH protect, constant("<not_found>")
   SET stat = initrec(emails)
   SELECT INTO "nl:"
    fac_disp = uar_get_code_display(cnvtreal(bnv.br_name)), bnv.br_nv_key1, bnv.br_name,
    bnv.br_value
    FROM br_name_value bnv
    PLAN (bnv
     WHERE bnv.br_nv_key1=patstring(concat(script_name,"|EMAIL")))
    ORDER BY fac_disp, bnv.br_nv_key1
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1)
     IF (mod(cnt,5)=1)
      stat = alterlist(emails->list,(cnt+ 4))
     ENDIF
     emails->list[cnt].facility_cd = cnvtreal(bnv.br_name), emails->list[cnt].facility_disp =
     evaluate(cnvtreal(bnv.br_name),0.0,"All",fac_disp), emails->list[cnt].email_address = bnv
     .br_value,
     emails->list[cnt].br_name_value_id = bnv.br_name_value_id
    FOOT REPORT
     emails->emails_cnt = cnt
     IF (mod(cnt,5) != 0)
      stat = alterlist(emails->list,cnt)
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE promptuserfornewemail(null)
   DECLARE facilitycd = f8 WITH protect
   DECLARE facilitydisp = vc WITH protect
   DECLARE email = vc WITH protect
   SET facilitycd = - (1)
   SET email = ""
   CALL clearscreen(null)
   CALL text(soffrow,soffcol,"An output report will be sent to each email for a facility")
   WHILE ((facilitycd=- (1)))
     CALL text((soffrow+ 1),soffcol,"Facility display (Shift + F5 to select):")
     SET help = promptmsg("Facility display starts with:")
     SET help = pos(3,1,15,80)
     SET help =
     SELECT INTO "nl:"
      facility = substring(1,74,cv.display)
      FROM code_value cv
      PLAN (cv
       WHERE cv.code_set=220
        AND cv.active_ind=1
        AND cv.cdf_meaning="FACILITY"
        AND cnvtupper(cv.display) >= cnvtupper(curaccept))
      ORDER BY cv.display_key
     ;end select
     CALL accept((soffrow+ 2),(soffcol+ 1),"P(74);CP")
     SET facilitydisp = trim(cnvtupper(curaccept))
     SET help = off
     IF (cnvtupper(curaccept)="QUIT")
      GO TO main_menu
     ELSEIF (cnvtupper(curaccept)="ALL")
      SET facilitycd = 0
     ELSE
      SELECT INTO "nl:"
       cv.code_value
       FROM code_value cv
       WHERE cv.code_set=220
        AND cv.active_ind=1
        AND cv.cdf_meaning="FACILITY"
        AND trim(substring(1,74,cnvtupper(cv.display)))=cnvtupper(facilitydisp)
       DETAIL
        facilitycd = cv.code_value
       WITH nocounter
      ;end select
      IF (curqual != 1)
       CALL text((soffrow+ 3),soffcol,"No facility found! Enter a valid facility display value.")
      ELSE
       CALL clear((soffrow+ 3),soffcol,numcols)
      ENDIF
     ENDIF
   ENDWHILE
   CALL text((soffrow+ 3),soffcol,"Email address:")
   CALL accept((soffrow+ 4),(soffcol+ 1),"P(74);C"
    WHERE curaccept="*@*.*")
   SET email = curaccept
   SET stat = addemail(facilitycd,email)
   IF (stat=0)
    CALL text((soffrow+ 14),soffcol,"Error writing email address to br_name_value")
   ELSE
    CALL text((soffrow+ 14),soffcol,"Successfully saved email address")
   ENDIF
   CALL text(quesrow,soffcol,"Continue?:")
   CALL accept(quesrow,(soffcol+ 10),"A;CUS","Y"
    WHERE curaccept IN ("Y"))
 END ;Subroutine
 SUBROUTINE addemail(facilitycd,email)
   DECLARE retval = i2 WITH protect, noconstant(0)
   SET trace = recpersist
   RECORD br_request(
     1 br_name = vc
     1 br_value = vc
     1 br_nv_key1 = vc
   )
   RECORD br_reply(
     1 br_name_value_id = f8
     1 status_data
       2 status = c1
       2 subeventstatus[*]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET br_request->br_name = trim(cnvtstring(facilitycd))
   SET br_request->br_value = trim(email)
   SET br_request->br_nv_key1 = build(script_name,"|EMAIL")
   EXECUTE bed_add_name_value  WITH replace("REQUEST",br_request), replace("REPLY",br_reply)
   IF ((br_reply->status_data.status="F"))
    SET retval = 0
   ELSE
    COMMIT
    SET retval = 1
   ENDIF
   SET trace = norecpersist
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE runinitialsetup(null)
   DECLARE facpos = i4 WITH protect
   DECLARE idx = i4 WITH protect
   DECLARE faccnt = i4 WITH protect
   DECLARE facilitycd = f8 WITH protect, noconstant(- (1.0))
   DECLARE identcnt = i4 WITH protect
   DECLARE identtypecnt = i4 WITH protect
   DECLARE totalidentcnt = i4 WITH protect
   DECLARE facdisp = c50 WITH protect
   DECLARE setupdatedisp = c20 WITH protect
   RECORD facilities(
     1 list[*]
       2 disp = vc
       2 facility_cd = f8
       2 setup_dt_tm = dq8
       2 ident_list[*]
         3 disp = vc
         3 cnt = i4
   ) WITH protect
   SET stat = initrec(identifiers)
   CALL clearscreen(null)
   CALL loadmappings(null)
   SET faccnt = 0
   FOR (i = 1 TO mappings->mapping_cnt)
    SET facpos = locateval(idx,1,size(facilities->list,5),mappings->list[i].facility_cd,facilities->
     list[idx].facility_cd)
    IF (facpos=0)
     SET faccnt = (faccnt+ 1)
     SET stat = alterlist(facilities->list,faccnt)
     SET facilities->list[faccnt].disp = mappings->list[i].facility_disp
     SET facilities->list[faccnt].facility_cd = mappings->list[i].facility_cd
     SET facilities->list[faccnt].setup_dt_tm = getinitialsetupdatetime(mappings->list[i].facility_cd
      )
    ENDIF
   ENDFOR
   SET maxrows = 12
   CALL drawscrollbox((soffrow+ 1),(soffcol+ 1),numrows,(numcols+ 1))
   CALL text(soffrow,soffcol,"Choose a facility to setup")
   SET cnt = 0
   WHILE (cnt < maxrows
    AND cnt < size(facilities->list,5))
     SET cnt = (cnt+ 1)
     SET facdisp = facilities->list[cnt].disp
     SET setupdatedisp = format(facilities->list[cnt].setup_dt_tm,"@SHORTDATETIME")
     SET rowstr = build2(facdisp," ",setupdatedisp)
     CALL scrolltext(cnt,rowstr)
   ENDWHILE
   SET cnt = 1
   SET arow = 1
   SET pick = 0
   CALL text((soffrow+ 1),(soffcol+ 2),"Facility")
   CALL text((soffrow+ 1),(soffcol+ 53),"Setup Date/Time")
   WHILE ((facilitycd=- (1)))
     CALL text(quesrow,soffcol,"(M)ain Menu or (S)elect:")
     CALL accept(quesrow,(soffcol+ 24),"A;CUS","S"
      WHERE curaccept IN ("M", "S"))
     CASE (curscroll)
      OF 0:
       IF (curaccept="M")
        GO TO main_menu
       ELSE
        IF ((facilities->list[cnt].setup_dt_tm=0.0))
         SET facilitycd = facilities->list[cnt].facility_cd
        ELSE
         CALL clearscreen(null)
         CALL text(soffrow,soffcol,
          "The selected facility has already been setup. You cannot run setup")
         CALL text((soffrow+ 1),soffcol,"again for this facility.")
         CALL text(quesrow,soffcol,"Continue?:")
         CALL accept(quesrow,(soffcol+ 10),"A;CUS","Y"
          WHERE curaccept IN ("Y"))
         GO TO main_menu
        ENDIF
       ENDIF
      OF 1:
       IF (cnt < size(facilities->list,5))
        SET cnt = (cnt+ 1)
        SET facdisp = facilities->list[cnt].disp
        SET setupdatedisp = format(facilities->list[cnt].setup_dt_tm,"@SHORTDATETIME")
        SET rowstr = build2(facdisp," ",setupdatedisp)
        CALL downarrow(rowstr)
       ENDIF
      OF 2:
       IF (cnt > 1)
        SET cnt = (cnt - 1)
        SET facdisp = facilities->list[cnt].disp
        SET setupdatedisp = format(facilities->list[cnt].setup_dt_tm,"@SHORTDATETIME")
        SET rowstr = build2(facdisp," ",setupdatedisp)
        CALL uparrow(rowstr)
       ENDIF
     ENDCASE
   ENDWHILE
   CALL clearscreen(null)
   SELECT INTO "nl:"
    mi.value
    FROM med_identifier mi,
     med_def_flex mdf,
     med_flex_object_idx mfoi
    PLAN (mi
     WHERE mi.pharmacy_type_cd=inpatient_type_cd
      AND expand(i,1,mappings->mapping_cnt,facilitycd,mappings->list[i].facility_cd,
      mi.med_identifier_type_cd,mappings->list[i].med_identifier_type_cd)
      AND mi.active_ind=1
      AND mi.primary_ind=1)
     JOIN (mdf
     WHERE mdf.item_id=mi.item_id
      AND mdf.active_status_cd=active_status_type_cd
      AND mdf.pharmacy_type_cd=inpatient_type_cd
      AND mdf.flex_type_cd=system_pkg_type_cd)
     JOIN (mfoi
     WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
      AND mfoi.flex_object_type_cd=orderable_type_cd
      AND mfoi.parent_entity_id=facilitycd)
    ORDER BY mi.med_identifier_type_cd
    HEAD mi.med_identifier_type_cd
     identtypecnt = (identtypecnt+ 1), stat = alterlist(facilities->list[cnt].ident_list,identtypecnt
      ), facilities->list[cnt].ident_list[identtypecnt].disp = uar_get_code_display(mi
      .med_identifier_type_cd),
     identcnt = 0
    DETAIL
     identcnt = (identcnt+ 1), totalidentcnt = (totalidentcnt+ 1)
     IF (mod(totalidentcnt,100)=1)
      stat = alterlist(identifiers->list,(totalidentcnt+ 99))
     ENDIF
     identifiers->list[totalidentcnt].item_id = mi.item_id, identifiers->list[totalidentcnt].
     med_identifier_id = mi.med_identifier_id, identifiers->list[totalidentcnt].old_value = mi.value,
     identifiers->list[totalidentcnt].med_identifier_type_cd = mi.med_identifier_type_cd, identifiers
     ->list[totalidentcnt].facility_cd = mfoi.parent_entity_id
    FOOT  mi.med_identifier_type_cd
     facilities->list[cnt].ident_list[identtypecnt].cnt = identcnt
    FOOT REPORT
     IF (mod(totalidentcnt,100) != 0)
      stat = alterlist(identifiers->list,totalidentcnt)
     ENDIF
    WITH nocounter
   ;end select
   IF (totalidentcnt > 0)
    CALL text(soffrow,soffcol,"Warning existing identifiers found!")
    CALL text((soffrow+ 1),soffcol,
     "Continuing will overwrite identifiers with values from CSPricingTool")
    CALL text((soffrow+ 3),soffcol,"Number of identifiers found:")
    FOR (i = 1 TO size(facilities->list[cnt].ident_list,5))
     CALL text(((soffrow+ 3)+ i),soffcol,build2(facilities->list[cnt].ident_list[i].disp,":"))
     CALL text(((soffrow+ 3)+ i),(soffcol+ 20),trim(cnvtstring(facilities->list[cnt].ident_list[i].
        cnt)))
    ENDFOR
    CALL text(quesrow,soffcol,"Continue?:")
    CALL accept(quesrow,(soffcol+ 10),"A;CUS"
     WHERE curaccept IN ("Y", "N"))
    IF (curaccept="N")
     GO TO main_menu
    ENDIF
   ENDIF
   CALL clearscreen(null)
   CALL text(soffrow,soffcol,"Loading settings from CSPricingTool...")
   CALL loadexistingbillitems(facilitycd)
   CALL text(soffrow,(soffcol+ 38),"done")
   CALL text((soffrow+ 1),soffcol,"Updating identifiers...")
   CALL syncidentifiers(null)
   CALL text((soffrow+ 1),(soffcol+ 23),"done")
   CALL text(quesrow,soffcol,"Commit?:")
   CALL accept(quesrow,(soffcol+ 8),"A;CUS"
    WHERE curaccept IN ("Y", "N"))
   IF (curaccept="Y")
    SET stat = setinitialsetupdatetime(facilitycd)
    IF (stat=0)
     SET status = "F"
     SET statusstr = "Error setting the initial setup date/time for facility"
     GO TO exit_script
    ENDIF
    COMMIT
   ELSE
    ROLLBACK
   ENDIF
   GO TO main_menu
 END ;Subroutine
 SUBROUTINE displayidentifiercounts(null)
   DECLARE typecnt = i4 WITH protect
   DECLARE identdisp = c30 WITH protect
   DECLARE identcnt = i4 WITH protect
   DECLARE rx_misc_1_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"RX MISC1"))
   DECLARE rx_misc_2_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"RX MISC2"))
   DECLARE rx_misc_3_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"RX MISC3"))
   DECLARE rx_misc_4_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"RX MISC4"))
   DECLARE rx_misc_5_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"RX MISC5"))
   DECLARE rx_device_1_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"RX DEVICE1"))
   DECLARE rx_device_2_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"RX DEVICE2"))
   DECLARE rx_device_3_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"RX DEVICE3"))
   DECLARE rx_device_4_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"RX DEVICE4"))
   DECLARE rx_device_5_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"RX DEVICE5"))
   DECLARE hcpcs_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"HCPCS"))
   DECLARE desc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"DESC"))
   CALL clearscreen(null)
   RECORD identifiers(
     1 list[*]
       2 disp = vc
       2 cnt = i4
       2 code_value = f8
   ) WITH protect
   SELECT INTO "nl:"
    cv.display
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=11000
      AND cv.code_value IN (rx_misc_1_cd, rx_misc_2_cd, rx_misc_3_cd, rx_misc_4_cd, rx_misc_5_cd,
     rx_device_1_cd, rx_device_2_cd, rx_device_3_cd, rx_device_4_cd, rx_device_5_cd,
     hcpcs_cd)
      AND cv.active_ind=1)
    ORDER BY cv.display_key
    HEAD REPORT
     typecnt = 0
    DETAIL
     typecnt = (typecnt+ 1), stat = alterlist(identifiers->list,typecnt), identifiers->list[typecnt].
     disp = cv.display,
     identifiers->list[typecnt].code_value = cv.code_value
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    ident = uar_get_code_display(mi.med_identifier_type_cd), x = count(mi.med_identifier_id)
    FROM med_identifier mi
    PLAN (mi
     WHERE mi.pharmacy_type_cd=inpatient_type_cd
      AND mi.med_identifier_type_cd IN (rx_misc_1_cd, rx_misc_2_cd, rx_misc_3_cd, rx_misc_4_cd,
     rx_misc_5_cd,
     rx_device_1_cd, rx_device_2_cd, rx_device_3_cd, rx_device_4_cd, rx_device_5_cd,
     hcpcs_cd)
      AND mi.active_ind=1
      AND mi.med_product_id=0)
    GROUP BY mi.med_identifier_type_cd
    DETAIL
     typecnt = locateval(i,1,size(identifiers->list,5),mi.med_identifier_type_cd,identifiers->list[i]
      .code_value), identifiers->list[typecnt].cnt = x
    WITH nocounter
   ;end select
   SET maxrows = 12
   CALL drawscrollbox((soffrow+ 1),(soffcol+ 1),numrows,(numcols+ 1))
   SET cnt = 0
   WHILE (cnt < maxrows
    AND cnt < size(identifiers->list,5))
     SET cnt = (cnt+ 1)
     SET identdisp = identifiers->list[cnt].disp
     SET identcnt = identifiers->list[cnt].cnt
     SET rowstr = build2(identdisp," ",trim(cnvtstring(identcnt)))
     CALL scrolltext(cnt,rowstr)
   ENDWHILE
   SET cnt = 1
   SET arow = 1
   SET pick = 0
   CALL text((soffrow+ 1),(soffcol+ 2),"Identifier")
   CALL text((soffrow+ 1),(soffcol+ 33),"Number on products")
   WHILE (pick=0)
     CALL text(quesrow,soffcol,"(M)ain Menu or (V)iew identifiers:")
     CALL accept(quesrow,(soffcol+ 34),"A;CUS","V"
      WHERE curaccept IN ("M", "V"))
     CASE (curscroll)
      OF 0:
       IF (curaccept="M")
        GO TO main_menu
       ELSE
        SELECT
         desc = substring(1,60,mi2.value), identifier = substring(1,20,mi.value), mi.item_id
         FROM med_identifier mi,
          med_identifier mi2
         PLAN (mi
          WHERE mi.pharmacy_type_cd=inpatient_type_cd
           AND (mi.med_identifier_type_cd=identifiers->list[cnt].code_value)
           AND mi.active_ind=1
           AND mi.med_product_id=0)
          JOIN (mi2
          WHERE mi2.item_id=mi.item_id
           AND mi2.med_identifier_type_cd=desc_cd
           AND mi2.pharmacy_type_cd=inpatient_type_cd
           AND mi2.med_product_id=0
           AND mi2.active_ind=1
           AND mi2.primary_ind=1)
         ORDER BY mi2.value_key
         WITH nocounter
        ;end select
        GO TO main_menu
       ENDIF
      OF 1:
       IF (cnt < size(identifiers->list,5))
        SET cnt = (cnt+ 1)
        SET identdisp = identifiers->list[cnt].disp
        SET identcnt = identifiers->list[cnt].cnt
        SET rowstr = build2(identdisp," ",trim(cnvtstring(identcnt)))
        CALL downarrow(rowstr)
       ENDIF
      OF 2:
       IF (cnt > 1)
        SET cnt = (cnt - 1)
        SET identdisp = identifiers->list[cnt].disp
        SET identcnt = identifiers->list[cnt].cnt
        SET rowstr = build2(identdisp," ",trim(cnvtstring(identcnt)))
        CALL uparrow(rowstr)
       ENDIF
     ENDCASE
   ENDWHILE
 END ;Subroutine
 SUBROUTINE loadexistingbillitems(facilitycd)
   DECLARE bill_code_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",13019,"BILL CODE"))
   DECLARE billitemcnt = i4 WITH protect
   DECLARE billitempos = i4 WITH protect
   DECLARE identpos = i4 WITH protect
   DECLARE idx = i4 WITH protect
   DECLARE identtypecd = f8 WITH protect
   DECLARE identcnt = i4 WITH protect
   IF (cdm_pref=manf_item)
    SELECT INTO "nl:"
     mi.item_id, bim.bill_item_mod_id
     FROM med_identifier mi,
      med_def_flex mdf,
      med_flex_object_idx mfoi,
      med_def_flex mdf2,
      med_flex_object_idx mfoi2,
      med_product mp,
      bill_item bi,
      bill_item_modifier bim
     PLAN (mi
      WHERE mi.med_identifier_type_cd=ndc_type_cd
       AND mi.med_product_id != 0
       AND mi.active_ind=1
       AND mi.pharmacy_type_cd=inpatient_type_cd)
      JOIN (mdf
      WHERE mdf.item_id=mi.item_id
       AND mdf.flex_type_cd=system_type_cd
       AND mdf.pharmacy_type_cd=inpatient_type_cd)
      JOIN (mfoi
      WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
       AND mfoi.parent_entity_name="MED_PRODUCT"
       AND mfoi.sequence=1)
      JOIN (mdf2
      WHERE mdf2.item_id=mi.item_id
       AND mdf2.active_status_cd=active_status_type_cd
       AND mdf2.pharmacy_type_cd=inpatient_type_cd
       AND mdf2.flex_type_cd=system_pkg_type_cd)
      JOIN (mfoi2
      WHERE mfoi2.med_def_flex_id=mdf2.med_def_flex_id
       AND mfoi2.flex_object_type_cd=orderable_type_cd
       AND mfoi2.parent_entity_id=facilitycd)
      JOIN (mp
      WHERE mp.med_product_id=mfoi.parent_entity_id)
      JOIN (bi
      WHERE bi.ext_parent_reference_id=mp.manf_item_id
       AND bi.ext_owner_cd=pharm_act_cd
       AND bi.ext_parent_contributor_cd=ext_parent_manf_item_cd
       AND bi.active_ind=1)
      JOIN (bim
      WHERE bim.bill_item_id=bi.bill_item_id
       AND bim.bill_item_type_cd=bill_code_cd
       AND bim.active_ind=1
       AND bim.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND bim.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     ORDER BY mi.item_id, bi.bill_item_id, bim.bill_item_mod_id
     HEAD REPORT
      identcnt = size(identifiers->list,5)
     HEAD bim.bill_item_mod_id
      identpos = locateval(idx,1,mappings->mapping_cnt,facilitycd,mappings->list[idx].facility_cd,
       bim.key1_id,mappings->list[idx].bill_code_sched_cd)
      IF (identpos > 0)
       identtypecd = mappings->list[identpos].med_identifier_type_cd, identpos = locateval(idx,1,size
        (identifiers->list,5),mi.item_id,identifiers->list[idx].item_id,
        identtypecd,identifiers->list[idx].med_identifier_type_cd)
       IF (identpos > 0)
        identifiers->list[identpos].new_value = bim.key6, identifiers->list[identpos].update_ind = 1
       ELSE
        identcnt = (identcnt+ 1), stat = alterlist(identifiers->list,identcnt), identifiers->list[
        identcnt].bill_code_sched_cd = bim.key1_id,
        identifiers->list[identcnt].facility_cd = facilitycd, identifiers->list[identcnt].insert_ind
         = 1, identifiers->list[identcnt].item_id = mi.item_id,
        identifiers->list[identcnt].med_identifier_type_cd = identtypecd, identifiers->list[identcnt]
        .new_value = bim.key6
       ENDIF
       IF (uar_get_code_meaning(bim.key1_id)="HCPCS")
        identpos = locateval(idx,1,mappings->mapping_cnt,facilitycd,mappings->list[idx].facility_cd,
         - (1.0),mappings->list[idx].bill_code_sched_cd), identtypecd = mappings->list[identpos].
        med_identifier_type_cd, identpos = locateval(idx,1,size(identifiers->list,5),mi.item_id,
         identifiers->list[idx].item_id,
         identtypecd,identifiers->list[idx].med_identifier_type_cd)
        IF (identpos > 0)
         IF (bim.bim1_nbr=0.0)
          identifiers->list[identpos].new_value = "1"
         ELSE
          identifiers->list[identpos].new_value = trim(format(bim.bim1_nbr,"#####.#####;t(1)"),3)
         ENDIF
         identifiers->list[identpos].update_ind = 1
        ELSE
         identcnt = (identcnt+ 1), stat = alterlist(identifiers->list,identcnt), identifiers->list[
         identcnt].bill_code_sched_cd = - (1),
         identifiers->list[identcnt].facility_cd = facilitycd, identifiers->list[identcnt].insert_ind
          = 1, identifiers->list[identcnt].item_id = mi.item_id,
         identifiers->list[identcnt].med_identifier_type_cd = identtypecd
         IF (bim.bim1_nbr=0.0)
          identifiers->list[identcnt].new_value = "1"
         ELSE
          identifiers->list[identcnt].new_value = trim(format(bim.bim1_nbr,"#####.#####;t(1)"),3)
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     mi.item_id, bim.bill_item_mod_id
     FROM med_def_flex mdf,
      med_flex_object_idx mfoi,
      med_def_flex mdf2,
      med_flex_object_idx mfoi2,
      bill_item bi,
      bill_item_modifier bim
     PLAN (mdf
      WHERE mdf.active_status_cd=active_status_type_cd
       AND mdf.pharmacy_type_cd=inpatient_type_cd
       AND mdf.flex_type_cd=system_type_cd)
      JOIN (mfoi
      WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
       AND mfoi.parent_entity_name="MED_PRODUCT"
       AND mfoi.sequence=1)
      JOIN (mdf2
      WHERE mdf2.item_id=mi.item_id
       AND mdf2.active_status_cd=active_status_type_cd
       AND mdf2.pharmacy_type_cd=inpatient_type_cd
       AND mdf2.flex_type_cd=system_pkg_type_cd)
      JOIN (mfoi2
      WHERE mfoi.med_def_flex_id=mdf2.med_def_flex_id
       AND mfoi2.flex_object_type_cd=orderable_type_cd
       AND mfoi2.parent_entity_id=facilitycd)
      JOIN (bi
      WHERE bi.ext_parent_reference_id=mdf.med_def_flex_id
       AND bi.ext_owner_cd=pharm_act_cd
       AND bi.ext_parent_contributor_cd=ext_parent_manf_item_cd
       AND bi.active_ind=1)
      JOIN (bim
      WHERE bim.bill_item_id=bi.bill_item_id
       AND bim.bill_item_type_cd=bill_code_cd
       AND bim.active_ind=1
       AND bim.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND bim.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     ORDER BY mdf.item_id, bi.bill_item_id, bim.bill_item_mod_id
     HEAD REPORT
      identcnt = size(identifiers->list,5)
     HEAD bim.bill_item_mod_id
      identpos = locateval(idx,1,mappings->mapping_cnt,facilitycd,mappings->list[idx].facility_cd,
       bim.key1_id,mappings->list[idx].bill_code_sched_cd)
      IF (identpos > 0)
       identtypecd = mappings->list[identpos].med_identifier_type_cd, identpos = locateval(idx,1,size
        (identifiers->list,5),mi.item_id,identifiers->list[idx].item_id,
        identtypecd,identifiers->list[idx].med_identifier_type_cd)
       IF (identpos > 0)
        identifiers->list[identpos].new_value = bim.key6, identifiers->list[identpos].update_ind = 1
       ELSE
        identcnt = (identcnt+ 1), stat = alterlist(identifiers->list,identcnt), identifiers->list[
        identcnt].bill_code_sched_cd = bim.key1_id,
        identifiers->list[identcnt].facility_cd = facilitycd, identifiers->list[identcnt].insert_ind
         = 1, identifiers->list[identcnt].item_id = mi.item_id,
        identifiers->list[identcnt].med_identifier_type_cd = identtypecd, identifiers->list[identcnt]
        .new_value = bim.key6
       ENDIF
       IF (uar_get_code_meaning(bim.key1_id)="HCPCS")
        identpos = locateval(idx,1,mappings->mapping_cnt,facilitycd,mappings->list[idx].facility_cd,
         - (1.0),mappings->list[idx].bill_code_sched_cd), identtypecd = mappings->list[identpos].
        med_identifier_type_cd, identpos = locateval(idx,1,size(identifiers->list,5),mi.item_id,
         identifiers->list[idx].item_id,
         identtypecd,identifiers->list[idx].med_identifier_type_cd)
        IF (identpos > 0)
         identifiers->list[identpos].new_value = trim(cnvtstring(bim.bim1_nbr)), identifiers->list[
         identpos].update_ind = 1
        ELSE
         identcnt = (identcnt+ 1), stat = alterlist(identifiers->list,identcnt), identifiers->list[
         identcnt].bill_code_sched_cd = - (1),
         identifiers->list[identcnt].facility_cd = facilitycd, identifiers->list[identcnt].insert_ind
          = 1, identifiers->list[identcnt].item_id = mi.item_id,
         identifiers->list[identcnt].med_identifier_type_cd = identtypecd, identifiers->list[identcnt
         ].new_value = trim(cnvtstring(bim.bim1_nbr))
        ENDIF
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF (debug_ind=1)
    CALL echo("identifiers record after being loaded by loadExistingBillItems()")
    CALL echorecord(identifiers)
   ENDIF
 END ;Subroutine
 SUBROUTINE syncidentifiers(null)
   DECLARE itemcnt = i4 WITH protect
   DECLARE identcnt = i4 WITH protect
   DECLARE itempos = i4 WITH protect
   DECLARE idx = i4 WITH protect
   DECLARE cnt = i4 WITH protect
   DECLARE updtcnt = i4 WITH protect
   DECLARE insertcnt = i4 WITH protect
   DECLARE inactivecnt = i4 WITH protect
   SELECT INTO "nl:"
    md.med_type_flag
    FROM medication_definition md
    PLAN (md
     WHERE expand(i,1,size(identifiers->list,5),md.item_id,identifiers->list[i].item_id,
      1,identifiers->list[i].insert_ind))
    DETAIL
     IF (md.med_type_flag != 0)
      cnt = 1
      WHILE (cnt <= size(identifiers->list,5))
       itempos = locateval(idx,cnt,size(identifiers->list,5),md.item_id,identifiers->list[idx].
        item_id,
        0,identifiers->list[idx].med_type_flag),
       IF (itempos > 0)
        identifiers->list[itempos].med_type_flag = md.med_type_flag, cnt = (itempos+ 1)
       ELSE
        cnt = (size(identifiers->list,5)+ 1)
       ENDIF
      ENDWHILE
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    nextid = seq(inventory_seq,nextval)
    FROM (dummyt d1  WITH seq = value(size(identifiers->list,5))),
     dual d2
    PLAN (d1
     WHERE (identifiers->list[d1.seq].insert_ind=1))
     JOIN (d2)
    DETAIL
     identifiers->list[d1.seq].med_identifier_id = nextid, insertcnt = (insertcnt+ 1)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    mdf.med_def_flex_id
    FROM med_def_flex mdf
    PLAN (mdf
     WHERE expand(i,1,size(identifiers->list,5),mdf.item_id,identifiers->list[i].item_id)
      AND mdf.flex_type_cd=system_type_cd
      AND mdf.pharmacy_type_cd=inpatient_type_cd)
    DETAIL
     cnt = 1
     WHILE (cnt <= size(identifiers->list,5))
      itempos = locateval(idx,cnt,size(identifiers->list,5),mdf.item_id,identifiers->list[idx].
       item_id,
       0.0,identifiers->list[idx].med_def_flex_id),
      IF (itempos > 0)
       identifiers->list[itempos].med_def_flex_id = mdf.med_def_flex_id, cnt = (itempos+ 1)
      ELSE
       cnt = (size(identifiers->list,5)+ 1)
      ENDIF
     ENDWHILE
    WITH nocounter
   ;end select
   IF (debug_ind=1)
    CALL echo("identifiers record before updates in syncIdentifiers()")
    CALL echorecord(identifiers)
   ENDIF
   SELECT INTO "nl:"
    mi.med_identifier_id
    FROM med_identifier mi
    PLAN (mi
     WHERE expand(i,1,size(identifiers->list,5),mi.med_identifier_id,identifiers->list[i].
      med_identifier_id,
      0,identifiers->list[i].insert_ind,1,identifiers->list[i].update_ind)
      AND mi.med_identifier_id != 0.0)
    DETAIL
     updtcnt = (updtcnt+ 1)
    WITH nocounter, forupdate(mi)
   ;end select
   SELECT INTO "nl:"
    mi.med_identifier_id
    FROM med_identifier mi
    PLAN (mi
     WHERE expand(i,1,size(identifiers->list,5),mi.med_identifier_id,identifiers->list[i].
      med_identifier_id,
      0,identifiers->list[i].insert_ind,0,identifiers->list[i].update_ind)
      AND mi.med_identifier_id != 0.0)
    DETAIL
     inactivecnt = (inactivecnt+ 1)
    WITH nocounter, forupdate(mi)
   ;end select
   UPDATE  FROM (dummyt d1  WITH seq = value(size(identifiers->list,5))),
     med_identifier mi
    SET mi.value = trim(substring(1,200,identifiers->list[d1.seq].new_value)), mi.value_key = trim(
      cnvtalphanum(cnvtupper(substring(1,200,identifiers->list[d1.seq].new_value)))), mi.updt_dt_tm
      = cnvtdatetime(curdate,curtime3),
     mi.updt_id = reqinfo->updt_id, mi.updt_cnt = (mi.updt_cnt+ 1), mi.updt_applctx = 0,
     mi.updt_task = - (267)
    PLAN (d1
     WHERE (identifiers->list[d1.seq].med_identifier_id != 0.0)
      AND (identifiers->list[d1.seq].update_ind=1))
     JOIN (mi
     WHERE (mi.med_identifier_id=identifiers->list[d1.seq].med_identifier_id))
    WITH nocounter
   ;end update
   IF (((curqual != updtcnt) OR (error(errormsg,0) != 0)) )
    SET status = "F"
    SET statusstr = build2("Error updating med_identifier. curqual = ",trim(cnvtstring(curqual)),
     " expected = ",trim(cnvtstring(updtcnt)))
    GO TO exit_script
   ENDIF
   INSERT  FROM (dummyt d1  WITH seq = value(size(identifiers->list,5))),
     med_identifier mi
    SET mi.active_ind = 1, mi.flex_sort_flag = 600, mi.flex_type_cd = system_type_cd,
     mi.item_id = identifiers->list[d1.seq].item_id, mi.med_def_flex_id = identifiers->list[d1.seq].
     med_def_flex_id, mi.med_identifier_id = identifiers->list[d1.seq].med_identifier_id,
     mi.med_identifier_type_cd = identifiers->list[d1.seq].med_identifier_type_cd, mi.med_type_flag
      = identifiers->list[d1.seq].med_type_flag, mi.pharmacy_type_cd = inpatient_type_cd,
     mi.primary_ind = 1, mi.sequence = 1, mi.updt_applctx = 0,
     mi.updt_cnt = 0, mi.updt_dt_tm = cnvtdatetime(curdate,curtime3), mi.updt_id = reqinfo->updt_id,
     mi.updt_task = - (267), mi.value = trim(substring(1,200,identifiers->list[d1.seq].new_value)),
     mi.value_key = trim(cnvtalphanum(cnvtupper(substring(1,200,identifiers->list[d1.seq].new_value))
       ))
    PLAN (d1
     WHERE (identifiers->list[d1.seq].med_identifier_id != 0.0)
      AND (identifiers->list[d1.seq].insert_ind=1))
     JOIN (mi)
    WITH nocounter
   ;end insert
   IF (((curqual != insertcnt) OR (error(errormsg,0) != 0)) )
    SET status = "F"
    SET statusstr = build2("Error inserting into med_identifier. curqual = ",trim(cnvtstring(curqual)
      )," expected = ",trim(cnvtstring(insertcnt)))
    GO TO exit_script
   ENDIF
   UPDATE  FROM (dummyt d1  WITH seq = value(size(identifiers->list,5))),
     med_identifier mi
    SET mi.active_ind = 0, mi.primary_ind = 0, mi.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     mi.updt_id = reqinfo->updt_id, mi.updt_cnt = (mi.updt_cnt+ 1), mi.updt_applctx = 0,
     mi.updt_task = - (267)
    PLAN (d1
     WHERE (identifiers->list[d1.seq].med_identifier_id != 0.0)
      AND (identifiers->list[d1.seq].update_ind=0)
      AND (identifiers->list[d1.seq].insert_ind=0))
     JOIN (mi
     WHERE (mi.med_identifier_id=identifiers->list[d1.seq].med_identifier_id))
    WITH nocounter
   ;end update
   IF (((curqual != inactivecnt) OR (error(errormsg,0) != 0)) )
    SET status = "F"
    SET statusstr = build2("Error inactivating into med_identifier. curqual = ",trim(cnvtstring(
       curqual))," expected = ",trim(cnvtstring(inactivecnt)))
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE getcdmprefsetting(null)
   DECLARE retval = i2 WITH protect
   SELECT INTO "nl:"
    dp.pref_nbr
    FROM dm_prefs dp
    PLAN (dp
     WHERE dp.application_nbr=300000
      AND dp.person_id=0
      AND dp.pref_domain="PHARMNET-INPATIENT"
      AND dp.pref_section="BILLING"
      AND dp.pref_name="CDM OPTION")
    ORDER BY dp.pref_nbr
    HEAD dp.pref_nbr
     IF (dp.pref_nbr=1)
      retval = 1
     ELSE
      retval = 0
     ENDIF
    WITH nocounter
   ;end select
   IF (debug_ind=1)
    CALL echo(build2("cdm pref = ",trim(cnvtstring(retval))))
   ENDIF
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE setinitialsetupdatetime(facilitycd)
   DECLARE retval = i2 WITH protect, noconstant(0)
   DECLARE lastrundttm = dq8 WITH protect
   SET trace = recpersist
   RECORD br_request(
     1 br_name = vc
     1 br_value = vc
     1 br_nv_key1 = vc
   )
   RECORD br_reply(
     1 br_name_value_id = f8
     1 status_data
       2 status = c1
       2 subeventstatus[*]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain=info_domain
     AND d.info_name=script_name
    DETAIL
     lastrundttm = d.updt_dt_tm
    WITH nocounter
   ;end select
   IF (lastrundttm=0)
    INSERT  FROM dm_info d
     SET d.info_domain = info_domain, d.info_name = script_name, d.info_date = cnvtdatetime(curdate,
       curtime3),
      d.info_char = trim("Total number of products processed by the ops job"), d.updt_dt_tm =
      cnvtdatetime(curdate,curtime3), d.updt_cnt = 0,
      d.updt_id = reqinfo->updt_id, d.updt_task = - (267)
     WITH nocounter
    ;end insert
    IF (((curqual != 1) OR (error(errormsg,0) != 0)) )
     SET retval = 0
     RETURN(retval)
    ENDIF
   ENDIF
   SET br_request->br_name = trim(cnvtstring(facilitycd))
   SET br_request->br_value = trim(uar_get_code_display(facilitycd))
   SET br_request->br_nv_key1 = build(script_name,"|SETUPDTTM")
   EXECUTE bed_add_name_value  WITH replace("REQUEST",br_request), replace("REPLY",br_reply)
   IF ((br_reply->status_data.status="F"))
    SET retval = 0
   ELSE
    COMMIT
    SET retval = 1
   ENDIF
   SET trace = norecpersist
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE getinitialsetupdatetime(facilitycd)
   DECLARE retval = dq8 WITH protect
   SELECT INTO "nl:"
    bnv.br_nv_key1, bnv.br_name, bnv.br_value
    FROM br_name_value bnv
    PLAN (bnv
     WHERE bnv.br_nv_key1=patstring(concat(script_name,"|SETUPDTTM"))
      AND bnv.br_name=cnvtstring(facilitycd))
    DETAIL
     retval = bnv.updt_dt_tm
    WITH nocounter
   ;end select
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE removeemail(bnv_id)
   DELETE  FROM br_name_value bnv
    PLAN (bnv
     WHERE bnv.br_name_value_id=bnv_id
      AND bnv.br_name_value_id != 0.0)
    WITH nocounter
   ;end delete
   CALL clear(quesrow,soffcol,numcols)
   IF (curqual=1
    AND error(errormsg,0)=0)
    CALL text(quesrow,soffcol,"Commit?:")
    CALL accept(quesrow,(soffcol+ 8),"A;CU"
     WHERE curaccept IN ("Y", "N"))
    IF (curaccept="Y"
     AND error(errormsg,0)=0)
     COMMIT
    ELSE
     ROLLBACK
    ENDIF
   ELSE
    CALL text((soffrow+ 14),soffcol,"Error deleting email from br_name_value.Rolling back change.")
    ROLLBACK
    CALL text(quesrow,soffcol,"Continue?:")
    CALL accept(quesrow,(soffcol+ 10),"A;CU","Y"
     WHERE curaccept IN ("Y"))
   ENDIF
 END ;Subroutine
#exit_script
 CALL clear(1,1)
 SET message = nowindow
 IF (status="F")
  ROLLBACK
  CALL echo(statusstr)
  CALL echo(build2("CCL: ",errormsg))
 ENDIF
 SET last_mod = "001"
END GO
