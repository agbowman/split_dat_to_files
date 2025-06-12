CREATE PROGRAM ams_pharm_bill_item_setup:dba
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
 DECLARE getlastrundttime(null) = dq8 WITH protect
 DECLARE setlastrundttime(rundttm=dq8,updtcnt=i4) = null WITH protect
 DECLARE getidentifiertoschedmappings(null) = i2 WITH protect
 DECLARE getupdatedproducts(null) = i4 WITH protect
 DECLARE getcdmprefsetting(null) = i2 WITH protect
 DECLARE getbillitems(null) = null WITH protect
 DECLARE loadrequest(null) = null WITH protect
 DECLARE performupdates(null) = null WITH protect
 DECLARE createoutputreport(faccd=f8) = null WITH protect
 DECLARE loademails(null) = null WITH protect
 DECLARE updateinvalididentifier(identid=f8,msg=vc) = null WITH protect
 DECLARE updateidentifier(identid=f8,value=vc) = null WITH protect
 DECLARE info_domain = vc WITH protect, constant("AMS_TOOLKIT")
 DECLARE script_name = vc WITH protect, constant("AMS_PHARM_BILL_ITEM_SETUP")
 DECLARE inpatient_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4500,"INPATIENT"))
 DECLARE ndc_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"NDC"))
 DECLARE desc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"DESC"))
 DECLARE pharm_act_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",106,"PHARMACY"))
 DECLARE ext_parent_manf_item_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",13016,
   "MANF ITEM"))
 DECLARE bill_code_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",13019,"BILL CODE"))
 DECLARE active_status_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE system_pkg_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4062,"SYSPKGTYP"))
 DECLARE orderable_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4063,"ORDERABLE"))
 DECLARE manf_item = i2 WITH protect, constant(0)
 DECLARE cdm_pref = i2 WITH protect, constant(getcdmprefsetting(null))
 DECLARE system_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4062,"SYSTEM"))
 DECLARE ams_email = vc WITH protect, constant("ams_auto_product_update@cerner.com")
 DECLARE lastrundatetime = dq8 WITH protect
 DECLARE currentrundatetime = dq8 WITH protect
 DECLARE productcnt = i4 WITH protect
 DECLARE subjstr = vc WITH protect
 DECLARE recpstr = vc WITH protect
 DECLARE bodystr = vc WITH protect
 DECLARE filename = vc WITH protect
 DECLARE errormsg = vc WITH protect
 DECLARE begeffdatetime = dq8 WITH protect
 DECLARE endeffdatetime = dq8 WITH protect
 DECLARE requestlogfile = vc WITH protect
 SET requestlogfile = build2("ams_pharm_bill_item_setup_request_",cnvtlower(format(cnvtdatetime(
     curdate,curtime3),"dd_mmm_yyyy_hh_mm;;q")),".csv")
 RECORD products(
   1 fac_list[*]
     2 facility_cd = f8
     2 error_found = i2
     2 prod_list[*]
       3 item_id = f8
       3 desc = vc
       3 beg_effective_dt_tm = dq8
       3 manf_list[*]
         4 med_product_id = f8
         4 bill_item_id = f8
         4 stacked_ndc_ind = i2
         4 ndc = vc
         4 bill_item_desc = vc
         4 idents_not_updt[*]
           5 med_identifier_type_cd = f8
       3 ident_list[*]
         4 med_identifier_id = f8
         4 value = vc
         4 med_identifier_type_cd = f8
         4 bill_code_sched_cd = f8
         4 updt_dt_tm = dq8
         4 error_ind = i2
         4 message = vc
 ) WITH protect
 RECORD bill_items(
   1 list[*]
     2 item_id = f8
     2 med_product_id = f8
     2 bill_item_id = f8
     2 bill_item_desc = vc
     2 bim_list[*]
       3 bill_item_mod_id = f8
       3 bill_code_sched_cd = f8
       3 bill_code_sched_disp = vc
       3 key5_id = f8
       3 key_6 = vc
       3 key_7 = vc
       3 bim1_nbr = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
 ) WITH protect
 RECORD mappings(
   1 list[*]
     2 facility_cd = f8
     2 facility_disp = vc
     2 bcs_list[*]
       3 bill_code_sched_cd = f8
       3 bill_code_sched_disp = vc
       3 med_identifier_type_cd = f8
 ) WITH protect
 RECORD emails(
   1 emails_cnt = i4
   1 list[*]
     2 facility_cd = f8
     2 facility_disp = vc
     2 email_address = vc
     2 br_name_value_id = f8
 ) WITH protect
 RECORD med_ident_type_cds(
   1 list[*]
     2 med_ident_type_cd = f8
 ) WITH protect
 RECORD items(
   1 list[*]
     2 item_id = f8
 ) WITH protect
 RECORD output(
   1 list[*]
     2 status = vc
     2 desc = vc
     2 bill_item_desc = vc
     2 bill_code_schedule = vc
     2 value = vc
     2 beg_effective_dt_tm = dq8
     2 item_id = f8
     2 bill_item_id = f8
 ) WITH protect
 EXECUTE ams_define_toolkit_common
 CALL echo("***Beginning ams_pharm_bill_item_setup***")
 RECORD request(
   1 bill_item_modifier_qual = i2
   1 bill_item_modifier[*]
     2 action_type = c3
     2 bill_item_mod_id = f8
     2 bill_item_id = f8
     2 bill_item_type_cd = f8
     2 key1_id = f8
     2 key2_id = f8
     2 key3_id = f8
     2 key4_id = f8
     2 key5_id = f8
     2 key6 = vc
     2 key7 = vc
     2 key8 = vc
     2 key9 = vc
     2 key10 = vc
     2 key11 = vc
     2 key12 = vc
     2 key13 = vc
     2 key14 = vc
     2 key15 = vc
     2 key11_id = f8
     2 key12_id = f8
     2 key13_id = f8
     2 key14_id = f8
     2 key15_id = f8
     2 bim1_int = f8
     2 bim1_nbr = f8
     2 bim2_int = f8
     2 bim_ind = i2
     2 bim1_ind = i2
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
   1 bill_item_ids[*]
     2 bill_item_id = f8
 ) WITH protect
 RECORD reply(
   1 bill_item_modifier_qual = i2
   1 bill_item_modifier[*]
     2 bill_item_mod_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c8
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 ) WITH protect
 SET lastrundatetime = getlastrundttime(null)
 SET currentrundatetime = cnvtdatetime(curdate,curtime3)
 SET endeffdatetime = cnvtdatetime(curdate,curtime)
 SET endeffdatetime = cnvtlookahead("59,S",endeffdatetime)
 SET begeffdatetime = cnvtlookahead("1,S",endeffdatetime)
 IF (lastrundatetime=0)
  SET status = "F"
  SET statusstr =
  "Last run date/time not found. Initial setup must be completed before running this script."
  GO TO exit_script
 ENDIF
 IF (getidentifiertoschedmappings(null)=0)
  SET status = "F"
  SET statusstr =
  "Identifier to bill code schedule mapping not found. Initial setup must be completed before running."
  GO TO exit_script
 ENDIF
 SET productcnt = getupdatedproducts(null)
 IF (productcnt > 0)
  CALL loademails(null)
  CALL getbillitems(null)
  CALL loadrequest(null)
  SET stat = performupdates(null)
  IF (stat=1)
   CALL setlastrundttime(currentrundatetime,productcnt)
   FOR (i = 1 TO size(products->fac_list,5))
     IF (size(products->fac_list[i].prod_list,5) > 0)
      CALL createoutputreport(products->fac_list[i].facility_cd)
     ENDIF
   ENDFOR
   SET status = "S"
   SET statusstr = build2("Successfully processed ",trim(cnvtstring(productcnt)),
    " products with updated or new billing information.")
  ELSE
   SET status = "F"
   SET statusstr = "Error occurred updating bill items in afc_ens_bill_item_modifier"
  ENDIF
 ELSE
  CALL setlastrundttime(currentrundatetime,productcnt)
  SET status = "S"
  SET statusstr = "No products found with updated billing information."
 ENDIF
 SUBROUTINE getlastrundttime(null)
   DECLARE lastrundttm = dq8 WITH protect
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain=info_domain
     AND d.info_name=script_name
    DETAIL
     lastrundttm = d.updt_dt_tm
    WITH nocounter
   ;end select
   CALL echo(build2("Program was last run ",format(lastrundttm,";;q")))
   RETURN(lastrundttm)
 END ;Subroutine
 SUBROUTINE setlastrundttime(rundttm,updtcnt)
   CALL echo(build2("Setting the last run date/time to ",format(rundttm,";;q")))
   UPDATE  FROM dm_info d
    SET d.updt_dt_tm = cnvtdatetime(rundttm), d.info_number = (evaluate(d.info_number,null,0.0,d
      .info_number)+ updtcnt), d.updt_cnt = (d.updt_cnt+ 1),
     d.updt_id = reqinfo->updt_id, d.updt_task = - (267)
    WHERE d.info_domain=info_domain
     AND d.info_name=script_name
    WITH nocounter
   ;end update
   IF (((curqual != 1) OR (error(errormsg,0) != 0)) )
    SET status = "F"
    SET statusstr = build2("Error updating last run date/time. curqual = ",trim(cnvtstring(curqual)))
    GO TO exit_script
   ENDIF
   CALL updtdminfo(script_name,cnvtreal(updtcnt))
 END ;Subroutine
 SUBROUTINE getupdatedproducts(null)
   DECLARE totalprodcnt = i4 WITH protect
   DECLARE prodcnt = i4 WITH protect
   DECLARE itemcnt = i4 WITH protect
   DECLARE manfcnt = i4 WITH protect
   DECLARE manfpos = i4 WITH protect
   DECLARE itempos = i4 WITH protect
   DECLARE identcnt = i4 WITH protect
   DECLARE identpos = i4 WITH protect
   DECLARE facpos = i4 WITH protect
   DECLARE faccnt = i4 WITH protect
   DECLARE idx = i4 WITH protect
   DECLARE idy = i4 WITH protect
   DECLARE idz = i4 WITH protect
   DECLARE j = i4 WITH protect
   DECLARE k = i4 WITH protect
   CALL echo("Finding products with new NDCs or updated identifiers")
   SET stat = initrec(products)
   SET stat = initrec(items)
   SELECT
    IF (cdm_pref=manf_item)
     PLAN (mi
      WHERE mi.pharmacy_type_cd=inpatient_type_cd
       AND ((expand(i,1,size(med_ident_type_cds->list,5),mi.med_identifier_type_cd,med_ident_type_cds
       ->list[i].med_ident_type_cd)) OR (mi.med_identifier_type_cd=ndc_type_cd
       AND  EXISTS (
      (SELECT
       mch.med_product_id
       FROM med_cost_hx mch
       WHERE mch.med_product_id=mi.med_product_id
        AND mch.active_ind=1
        AND mch.beg_effective_dt_tm BETWEEN cnvtdatetime(lastrundatetime) AND cnvtdatetime(
        currentrundatetime)))))
       AND mi.updt_dt_tm BETWEEN cnvtdatetime(lastrundatetime) AND cnvtdatetime(currentrundatetime)
       AND mi.active_ind=1
       AND mi.primary_ind=1
       AND mi.value_key != "*ERROR*")
      JOIN (mdf
      WHERE mdf.item_id=mi.item_id
       AND mdf.active_status_cd=active_status_type_cd
       AND mdf.pharmacy_type_cd=inpatient_type_cd
       AND mdf.flex_type_cd=system_pkg_type_cd)
      JOIN (mfoi
      WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
       AND mfoi.flex_object_type_cd=orderable_type_cd
       AND expand(j,1,size(mappings->list,5),mfoi.parent_entity_id,mappings->list[j].facility_cd))
      JOIN (desc1
      WHERE desc1.item_id=mi.item_id
       AND desc1.med_identifier_type_cd=desc_cd
       AND desc1.pharmacy_type_cd=inpatient_type_cd
       AND desc1.active_ind=1
       AND desc1.med_product_id=0
       AND desc1.primary_ind=1)
      JOIN (mi2
      WHERE mi2.item_id=mi.item_id
       AND expand(k,1,size(med_ident_type_cds->list,5),mi2.med_identifier_type_cd,med_ident_type_cds
       ->list[k].med_ident_type_cd)
       AND mi2.pharmacy_type_cd=inpatient_type_cd
       AND mi2.med_product_id=0
       AND mi2.active_ind=1
       AND mi2.primary_ind=1)
      JOIN (mi3
      WHERE mi3.item_id=mi.item_id
       AND mi3.med_identifier_type_cd=ndc_type_cd
       AND mi3.pharmacy_type_cd=inpatient_type_cd
       AND mi3.active_ind=1
       AND mi3.primary_ind=1)
    ELSE
     PLAN (mi
      WHERE mi.pharmacy_type_cd=inpatient_type_cd
       AND expand(i,1,size(med_ident_type_cds->list,5),mi.med_identifier_type_cd,med_ident_type_cds->
       list[i].med_ident_type_cd)
       AND mi.updt_dt_tm BETWEEN cnvtdatetime(lastrundatetime) AND cnvtdatetime(currentrundatetime)
       AND mi.active_ind=1
       AND mi.primary_ind=1
       AND mi.value_key != "*ERROR*")
      JOIN (mdf
      WHERE mdf.item_id=mi.item_id
       AND mdf.active_status_cd=active_status_type_cd
       AND mdf.pharmacy_type_cd=inpatient_type_cd
       AND mdf.flex_type_cd=system_pkg_type_cd)
      JOIN (mfoi
      WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
       AND mfoi.flex_object_type_cd=orderable_type_cd
       AND expand(j,1,size(mappings->list,5),mfoi.parent_entity_id,mappings->list[j].facility_cd))
      JOIN (desc1
      WHERE desc1.item_id=mi.item_id
       AND desc1.med_identifier_type_cd=desc_cd
       AND desc1.pharmacy_type_cd=inpatient_type_cd
       AND desc1.active_ind=1
       AND desc1.med_product_id=0
       AND desc1.primary_ind=1)
      JOIN (mi2
      WHERE mi2.item_id=mi.item_id
       AND expand(k,1,size(med_ident_type_cds->list,5),mi2.med_identifier_type_cd,med_ident_type_cds
       ->list[k].med_ident_type_cd)
       AND mi2.pharmacy_type_cd=inpatient_type_cd
       AND mi2.med_product_id=0
       AND mi2.active_ind=1
       AND mi2.primary_ind=1)
      JOIN (mi3
      WHERE mi3.item_id=mi.item_id
       AND mi3.med_identifier_type_cd=ndc_type_cd
       AND mi3.pharmacy_type_cd=inpatient_type_cd
       AND mi3.active_ind=1
       AND mi3.primary_ind=1)
    ENDIF
    DISTINCT INTO "nl:"
    desc1.item_id, desc1.value, mi2.med_identifier_type_cd,
    mi2.value
    FROM med_identifier mi,
     med_def_flex mdf,
     med_flex_object_idx mfoi,
     med_identifier desc1,
     med_identifier mi2,
     med_identifier mi3
    ORDER BY mfoi.parent_entity_id, desc1.item_id, desc1.value,
     mi2.med_identifier_type_cd, mi2.value, mi.value,
     mi3.med_product_id
    HEAD REPORT
     faccnt = 0
    HEAD mfoi.parent_entity_id
     faccnt = (faccnt+ 1)
     IF (mod(faccnt,10)=1)
      stat = alterlist(products->fac_list,(faccnt+ 9))
     ENDIF
     products->fac_list[faccnt].facility_cd = mfoi.parent_entity_id, prodcnt = 0
    HEAD desc1.item_id
     itempos = locateval(idx,1,size(items->list,5),desc1.item_id,items->list[idx].item_id)
     IF (itempos=0)
      itemcnt = (itemcnt+ 1), stat = alterlist(items->list,(itemcnt+ 9)), items->list[itemcnt].
      item_id = desc1.item_id,
      totalprodcnt = (totalprodcnt+ 1), prodcnt = (prodcnt+ 1)
      IF (mod(prodcnt,10)=1)
       stat = alterlist(products->fac_list[faccnt].prod_list,(prodcnt+ 9))
      ENDIF
      products->fac_list[faccnt].prod_list[prodcnt].desc = desc1.value, products->fac_list[faccnt].
      prod_list[prodcnt].item_id = mi.item_id, identcnt = 0,
      manfcnt = 0
     ENDIF
    HEAD mi2.med_identifier_type_cd
     IF (itempos=0)
      facpos = locateval(idx,1,size(mappings->list,5),mfoi.parent_entity_id,mappings->list[idx].
       facility_cd)
      IF (facpos > 0)
       identpos = locateval(idy,1,size(mappings->list[facpos].bcs_list,5),mi2.med_identifier_type_cd,
        mappings->list[facpos].bcs_list[idy].med_identifier_type_cd)
       IF (identpos > 0)
        identcnt = (identcnt+ 1), stat = alterlist(products->fac_list[faccnt].prod_list[prodcnt].
         ident_list,identcnt), products->fac_list[faccnt].prod_list[prodcnt].ident_list[identcnt].
        med_identifier_type_cd = mi2.med_identifier_type_cd,
        products->fac_list[faccnt].prod_list[prodcnt].ident_list[identcnt].value = mi2.value,
        products->fac_list[faccnt].prod_list[prodcnt].ident_list[identcnt].updt_dt_tm = mi2
        .updt_dt_tm, products->fac_list[faccnt].prod_list[prodcnt].ident_list[identcnt].
        med_identifier_id = mi2.med_identifier_id
       ENDIF
      ENDIF
     ENDIF
    HEAD mi3.med_product_id
     IF (itempos=0)
      IF (cdm_pref=manf_item)
       IF (((mi.med_identifier_type_cd=ndc_type_cd
        AND mi.value=mi3.value) OR (mi.med_identifier_type_cd != ndc_type_cd
        AND mi.updt_dt_tm > cnvtdatetime(lastrundatetime))) )
        manfpos = locateval(idz,1,size(products->fac_list[faccnt].prod_list[prodcnt].manf_list,5),mi3
         .med_product_id,products->fac_list[faccnt].prod_list[prodcnt].manf_list[idz].med_product_id)
        IF (manfpos > 0
         AND mi.med_identifier_type_cd=ndc_type_cd)
         products->fac_list[faccnt].prod_list[prodcnt].manf_list[manfpos].stacked_ndc_ind = 1,
         products->fac_list[faccnt].prod_list[prodcnt].manf_list[manfpos].ndc = mi.value
        ENDIF
        IF (manfpos=0)
         manfcnt = (manfcnt+ 1), stat = alterlist(products->fac_list[faccnt].prod_list[prodcnt].
          manf_list,manfcnt), products->fac_list[faccnt].prod_list[prodcnt].manf_list[manfcnt].
         med_product_id = mi3.med_product_id
         IF (mi.med_identifier_type_cd=ndc_type_cd)
          products->fac_list[faccnt].prod_list[prodcnt].manf_list[manfcnt].stacked_ndc_ind = 1,
          products->fac_list[faccnt].prod_list[prodcnt].manf_list[manfcnt].ndc = mi.value
         ENDIF
        ENDIF
       ENDIF
      ELSE
       stat = alterlist(products->fac_list[faccnt].prod_list[prodcnt].manf_list,1), products->
       fac_list[faccnt].prod_list[prodcnt].manf_list[1].med_product_id = mi3.med_product_id
      ENDIF
     ENDIF
    FOOT  mfoi.parent_entity_id
     IF (mod(prodcnt,10) != 0)
      stat = alterlist(products->fac_list[faccnt].prod_list,prodcnt)
     ENDIF
    FOOT REPORT
     IF (mod(faccnt,10) != 0)
      stat = alterlist(products->fac_list,faccnt)
     ENDIF
    WITH nocounter
   ;end select
   IF (totalprodcnt > 0)
    SELECT INTO "nl:"
     fac = products->fac_list[d1.seq].facility_cd, mch.beg_effective_dt_tm
     FROM (dummyt d1  WITH seq = value(size(products->fac_list,5))),
      (dummyt d2  WITH seq = 1),
      med_identifier mi,
      med_cost_hx mch
     PLAN (d1
      WHERE maxrec(d2,size(products->fac_list[d1.seq].prod_list,5)))
      JOIN (d2)
      JOIN (mi
      WHERE (mi.item_id=products->fac_list[d1.seq].prod_list[d2.seq].item_id)
       AND mi.med_identifier_type_cd=ndc_type_cd
       AND mi.active_ind=1
       AND mi.primary_ind=1
       AND mi.med_product_id != 0.0)
      JOIN (mch
      WHERE mch.med_product_id=mi.med_product_id
       AND mch.active_ind=1
       AND mch.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     ORDER BY fac, mi.item_id, mch.beg_effective_dt_tm DESC
     DETAIL
      products->fac_list[d1.seq].prod_list[d2.seq].beg_effective_dt_tm = mch.beg_effective_dt_tm
     WITH nocounter
    ;end select
   ENDIF
   CALL echo(build2("Number of products found that have been updated since last run: ",trim(
      cnvtstring(totalprodcnt))))
   IF (debug_ind=1)
    CALL echo("products record after being loaded in getUpdatedProducts()")
    CALL echorecord(products)
   ENDIF
   RETURN(totalprodcnt)
 END ;Subroutine
 SUBROUTINE getidentifiertoschedmappings(null)
   DECLARE retval = i2 WITH protect
   DECLARE facilitycnt = i4 WITH protect
   DECLARE cnt = i4 WITH protect
   DECLARE medtypecdcnt = i4 WITH protect
   DECLARE pos = i4 WITH protect
   DECLARE facstr = vc WITH protect
   DECLARE notfnd = vc WITH protect, constant("<not_found>")
   DECLARE hcpcsfound = i2 WITH protect
   DECLARE qcffound = i2 WITH protect
   CALL echo("Loading identifier to bill code schedule mappings")
   SET stat = initrec(mappings)
   SELECT INTO "nl:"
    bnv.br_nv_key1, bnv.br_name, bnv.br_value
    FROM br_name_value bnv
    PLAN (bnv
     WHERE bnv.br_nv_key1=patstring(concat(script_name,"|*"))
      AND bnv.br_nv_key1 != concat(script_name,"|EMAIL")
      AND bnv.br_nv_key1 != concat(script_name,"|SETUPDTTM"))
    ORDER BY bnv.br_nv_key1
    HEAD REPORT
     facilitycnt = 0
    HEAD bnv.br_nv_key1
     facilitycnt = (facilitycnt+ 1)
     IF (mod(facilitycnt,5)=1)
      stat = alterlist(mappings->list,(facilitycnt+ 4))
     ENDIF
     facstr = piece(bnv.br_nv_key1,"|",2,notfnd,3)
     IF (facstr != notfnd)
      mappings->list[facilitycnt].facility_cd = cnvtreal(facstr)
     ENDIF
     mappings->list[facilitycnt].facility_disp = uar_get_code_display(mappings->list[facilitycnt].
      facility_cd), cnt = 0
    DETAIL
     cnt = (cnt+ 1)
     IF (mod(cnt,2)=1)
      stat = alterlist(mappings->list[facilitycnt].bcs_list,(cnt+ 1))
     ENDIF
     mappings->list[facilitycnt].bcs_list[cnt].bill_code_sched_cd = cnvtreal(bnv.br_value), mappings
     ->list[facilitycnt].bcs_list[cnt].bill_code_sched_disp = uar_get_code_display(cnvtreal(bnv
       .br_value)), mappings->list[facilitycnt].bcs_list[cnt].med_identifier_type_cd = cnvtreal(bnv
      .br_name),
     pos = locateval(i,1,size(med_ident_type_cds->list,5),cnvtreal(bnv.br_name),med_ident_type_cds->
      list[i].med_ident_type_cd)
     IF (pos=0)
      medtypecdcnt = (medtypecdcnt+ 1), stat = alterlist(med_ident_type_cds->list,medtypecdcnt),
      med_ident_type_cds->list[medtypecdcnt].med_ident_type_cd = cnvtreal(bnv.br_name)
     ENDIF
    FOOT  bnv.br_nv_key1
     IF (mod(cnt,2) != 0)
      stat = alterlist(mappings->list[facilitycnt].bcs_list,cnt)
     ENDIF
    FOOT REPORT
     IF (mod(facilitycnt,5) != 0)
      stat = alterlist(mappings->list,facilitycnt)
     ENDIF
    WITH nocounter
   ;end select
   FOR (i = 1 TO facilitycnt)
     SET hcpcsfound = 0
     SET qcffound = 0
     FOR (cnt = 1 TO size(mappings->list[i].bcs_list,5))
       IF ((mappings->list[i].bcs_list[cnt].bill_code_sched_cd=- (1)))
        SET qcffound = 1
       ELSEIF (uar_get_code_meaning(mappings->list[i].bcs_list[cnt].bill_code_sched_cd)="HCPCS")
        SET hcpcsfound = 1
       ENDIF
     ENDFOR
     IF (((hcpcsfound=1
      AND qcffound=0) OR (hcpcsfound=0
      AND qcffound=1)) )
      SET status = "F"
      SET statusstr = build2("Facility: ",evaluate(mappings->list[i].facility_cd,0.0,"All",trim(
         uar_get_code_display(mappings->list[i].facility_cd))),
       " has invalid mapping. Both QCF and HCPCS must be mapped.")
      GO TO exit_script
     ENDIF
   ENDFOR
   IF (facilitycnt > 0)
    SET retval = 1
   ENDIF
   IF (debug_ind=1)
    CALL echo("mappings record after being loaded by getIdentifierToSchedMappings()")
    CALL echorecord(mappings)
    CALL echo("med_ident_type_cds record after being loaded by getIdentifierToSchedMappings()")
    CALL echorecord(med_ident_type_cds)
   ENDIF
   RETURN(retval)
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
    CALL echo(build2("CDM pref = ",trim(cnvtstring(retval))))
   ENDIF
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE getbillitems(null)
   DECLARE idx = i4 WITH protect
   DECLARE j = i4 WITH protect
   DECLARE billitemcnt = i4 WITH protect
   DECLARE bimcnt = i4 WITH protect
   DECLARE facpos = i4 WITH protect
   DECLARE bcspos = i4 WITH protect
   SET stat = initrec(bill_items)
   CALL echo("Finding existing bill code schedules for products")
   IF (cdm_pref=manf_item)
    SELECT INTO "nl:"
     mi.item_id, bim.bill_item_mod_id
     FROM (dummyt d1  WITH seq = value(size(products->fac_list,5))),
      (dummyt d2  WITH seq = 1),
      (dummyt d3  WITH seq = 1),
      med_identifier mi,
      med_product mp,
      bill_item bi,
      bill_item_modifier bim
     PLAN (d1
      WHERE maxrec(d2,size(products->fac_list[d1.seq].prod_list,5)))
      JOIN (d2
      WHERE maxrec(d3,size(products->fac_list[d1.seq].prod_list[d2.seq].manf_list,5)))
      JOIN (d3)
      JOIN (mi
      WHERE (mi.item_id=products->fac_list[d1.seq].prod_list[d2.seq].item_id)
       AND mi.med_identifier_type_cd=ndc_type_cd
       AND (mi.med_product_id=products->fac_list[d1.seq].prod_list[d2.seq].manf_list[d3.seq].
      med_product_id)
       AND mi.active_ind=1
       AND mi.pharmacy_type_cd=inpatient_type_cd)
      JOIN (mp
      WHERE mp.med_product_id=mi.med_product_id)
      JOIN (bi
      WHERE bi.ext_parent_reference_id=mp.manf_item_id
       AND bi.ext_owner_cd=pharm_act_cd
       AND bi.ext_parent_contributor_cd=ext_parent_manf_item_cd)
      JOIN (bim
      WHERE bim.bill_item_id=outerjoin(bi.bill_item_id)
       AND bim.active_ind=outerjoin(1)
       AND bim.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate,curtime3))
       AND bim.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
     ORDER BY mi.item_id, mp.manf_item_id, bi.bill_item_id,
      bim.bill_item_mod_id
     HEAD REPORT
      billitemcnt = 0
     HEAD bi.bill_item_id
      billitemcnt = (billitemcnt+ 1)
      IF (mod(billitemcnt,10)=1)
       stat = alterlist(bill_items->list,(billitemcnt+ 9))
      ENDIF
      bill_items->list[billitemcnt].bill_item_id = bi.bill_item_id, bill_items->list[billitemcnt].
      item_id = mi.item_id, bill_items->list[billitemcnt].med_product_id = mi.med_product_id,
      bill_items->list[billitemcnt].bill_item_desc = bi.ext_description, bimcnt = 0
     HEAD bim.bill_item_mod_id
      IF (bim.bill_item_mod_id > 0)
       bimcnt = (bimcnt+ 1), stat = alterlist(bill_items->list[billitemcnt].bim_list,bimcnt),
       bill_items->list[billitemcnt].bim_list[bimcnt].bill_item_mod_id = bim.bill_item_mod_id,
       bill_items->list[billitemcnt].bim_list[bimcnt].bill_code_sched_cd = bim.key1_id, bill_items->
       list[billitemcnt].bim_list[bimcnt].bill_code_sched_disp = uar_get_code_display(bim.key1_id),
       bill_items->list[billitemcnt].bim_list[bimcnt].key5_id = bim.key5_id,
       bill_items->list[billitemcnt].bim_list[bimcnt].key_6 = bim.key6, bill_items->list[billitemcnt]
       .bim_list[bimcnt].key_7 = bim.key7, bill_items->list[billitemcnt].bim_list[bimcnt].bim1_nbr =
       bim.bim1_nbr,
       bill_items->list[billitemcnt].bim_list[bimcnt].beg_effective_dt_tm = bim.beg_effective_dt_tm,
       bill_items->list[billitemcnt].bim_list[bimcnt].end_effective_dt_tm = bim.end_effective_dt_tm
      ENDIF
     FOOT REPORT
      IF (mod(billitemcnt,10) != 0)
       stat = alterlist(bill_items->list,billitemcnt)
      ENDIF
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     mi.item_id, bim.bill_item_mod_id
     FROM (dummyt d1  WITH seq = value(size(products->fac_list,5))),
      (dummyt d2  WITH seq = 1),
      med_def_flex mdf,
      bill_item bi,
      bill_item_modifier bim
     PLAN (d1
      WHERE maxrec(d2,size(products->fac_list[d1.seq].prod_list,5)))
      JOIN (d2)
      JOIN (mdf
      WHERE (mdf.item_id=products->fac_list[d1.seq].prod_list[d2.seq].item_id)
       AND mdf.active_status_cd=active_status_type_cd
       AND mdf.pharmacy_type_cd=inpatient_type_cd
       AND mdf.flex_type_cd=system_type_cd)
      JOIN (bi
      WHERE bi.ext_parent_reference_id=mdf.med_def_flex_id
       AND bi.ext_owner_cd=pharm_act_cd
       AND bi.ext_parent_contributor_cd=ext_parent_manf_item_cd
       AND bi.active_ind=1)
      JOIN (bim
      WHERE bim.bill_item_id=outerjoin(bi.bill_item_id)
       AND bim.active_ind=outerjoin(1)
       AND bim.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
       AND bim.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3)))
     ORDER BY mdf.item_id, bi.bill_item_id, bim.bill_item_mod_id
     HEAD REPORT
      billitemcnt = 0
     HEAD bi.bill_item_id
      billitemcnt = (billitemcnt+ 1)
      IF (mod(billitemcnt,10)=1)
       stat = alterlist(bill_items->list,(billitemcnt+ 9))
      ENDIF
      bill_items->list[billitemcnt].bill_item_id = bi.bill_item_id, bill_items->list[billitemcnt].
      item_id = mdf.item_id, bill_items->list[billitemcnt].bill_item_desc = bi.ext_description,
      bimcnt = 0
     HEAD bim.bill_item_mod_id
      IF (bim.bill_item_mod_id > 0)
       bimcnt = (bimcnt+ 1), stat = alterlist(bill_items->list[billitemcnt].bim_list,bimcnt),
       bill_items->list[billitemcnt].bim_list[bimcnt].bill_item_mod_id = bim.bill_item_mod_id,
       bill_items->list[billitemcnt].bim_list[bimcnt].bill_code_sched_cd = bim.key1_id, bill_items->
       list[billitemcnt].bim_list[bimcnt].bill_code_sched_disp = uar_get_code_display(bim.key1_id),
       bill_items->list[billitemcnt].bim_list[bimcnt].key5_id = bim.key5_id,
       bill_items->list[billitemcnt].bim_list[bimcnt].key_6 = bim.key6, bill_items->list[billitemcnt]
       .bim_list[bimcnt].key_7 = bim.key7, bill_items->list[billitemcnt].bim_list[bimcnt].bim1_nbr =
       bim.bim1_nbr,
       bill_items->list[billitemcnt].bim_list[bimcnt].beg_effective_dt_tm = bim.beg_effective_dt_tm,
       bill_items->list[billitemcnt].bim_list[bimcnt].end_effective_dt_tm = bim.end_effective_dt_tm
      ENDIF
     FOOT REPORT
      IF (mod(billitemcnt,10) != 0)
       stat = alterlist(bill_items->list,billitemcnt)
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF (debug_ind=1)
    CALL echo("bill_items record after being loaded by getBillItems()")
    CALL echorecord(bill_items)
   ENDIF
 END ;Subroutine
 SUBROUTINE loadrequest(null)
   DECLARE faccnt = i4 WITH protect
   DECLARE prodcnt = i4 WITH protect
   DECLARE manfcnt = i4 WITH protect
   DECLARE idx = i4 WITH protect
   DECLARE prodpos = i4 WITH protect
   DECLARE bimpos = i4 WITH protect
   DECLARE identcnt = i4 WITH protect
   DECLARE identpos = i4 WITH protect
   DECLARE facpos = i4 WITH protect
   DECLARE billcodeschedcd = f8 WITH protect
   DECLARE qcfidentifiertypecd = f8 WITH protect
   DECLARE revenuecd = f8 WITH protect
   DECLARE afccnt = i4 WITH protect
   DECLARE qcfnbr = f8 WITH protect
   DECLARE qcfpos = i4 WITH protect
   DECLARE hcpcspos = i4 WITH protect
   DECLARE desc = vc WITH protect
   DECLARE notfnd = vc WITH protect, constant("<not_found>")
   DECLARE hcpcs_vocab_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",400,"HCPCS"))
   DECLARE procedure_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",401,"PROCEDURE"))
   DECLARE needupdtind = i2 WITH protect
   DECLARE cnt = i4 WITH protect
   SET stat = initrec(request)
   IF (debug_ind=1)
    CALL echo("Inside loadrequest()")
   ENDIF
   FOR (faccnt = 1 TO size(products->fac_list,5))
    IF (debug_ind=1)
     CALL echo(build2("Starting on facCnt: ",trim(cnvtstring(faccnt))," of ",trim(cnvtstring(size(
          products->fac_list,5)))))
     CALL echo(uar_get_code_display(products->fac_list[faccnt].facility_cd))
     CALL echo(products->fac_list[faccnt].facility_cd)
    ENDIF
    FOR (prodcnt = 1 TO size(products->fac_list[faccnt].prod_list,5))
      IF (debug_ind=1)
       CALL echo(build2("Starting on prodCnt: ",trim(cnvtstring(prodcnt))," of ",trim(cnvtstring(size
           (products->fac_list[faccnt].prod_list,5)))))
       CALL echo(products->fac_list[faccnt].prod_list[prodcnt].desc)
       CALL echo(products->fac_list[faccnt].prod_list[prodcnt].item_id)
      ENDIF
      SET facpos = locateval(idx,1,size(mappings->list,5),products->fac_list[faccnt].facility_cd,
       mappings->list[idx].facility_cd)
      SET qcfpos = locateval(idx,1,size(mappings->list[facpos].bcs_list,5),- (1.0),mappings->list[
       facpos].bcs_list[idx].bill_code_sched_cd)
      IF (qcfpos > 0)
       SET qcfidentifiertypecd = mappings->list[facpos].bcs_list[qcfpos].med_identifier_type_cd
       SET qcfpos = locateval(idx,1,size(products->fac_list[faccnt].prod_list[prodcnt].ident_list,5),
        qcfidentifiertypecd,products->fac_list[faccnt].prod_list[prodcnt].ident_list[idx].
        med_identifier_type_cd)
       IF (qcfpos > 0)
        SET qcfnbr = cnvtreal(products->fac_list[faccnt].prod_list[prodcnt].ident_list[qcfpos].value)
        IF (debug_ind=1)
         CALL echo(build2("qcfNbr: ",trim(cnvtstring(qcfnbr))))
        ENDIF
        IF (qcfnbr > 0)
         SET hcpcspos = locateval(idx,1,size(mappings->list[facpos].bcs_list,5),"HCPCS",
          uar_get_code_meaning(mappings->list[facpos].bcs_list[idx].bill_code_sched_cd))
         SET hcpcspos = locateval(idx,1,size(products->fac_list[faccnt].prod_list[prodcnt].ident_list,
           5),mappings->list[facpos].bcs_list[hcpcspos].med_identifier_type_cd,products->fac_list[
          faccnt].prod_list[prodcnt].ident_list[idx].med_identifier_type_cd)
         IF (hcpcspos=0)
          SET products->fac_list[faccnt].error_found = 1
          SET products->fac_list[faccnt].prod_list[prodcnt].ident_list[qcfpos].error_ind = 1
          SET products->fac_list[faccnt].prod_list[prodcnt].ident_list[qcfpos].message =
          "ERROR: Product cannot have QCF without HCPCS"
          CALL updateinvalididentifier(products->fac_list[faccnt].prod_list[prodcnt].ident_list[
           qcfpos].med_identifier_id,products->fac_list[faccnt].prod_list[prodcnt].ident_list[qcfpos]
           .message)
         ENDIF
        ELSE
         SET products->fac_list[faccnt].error_found = 1
         SET products->fac_list[faccnt].prod_list[prodcnt].ident_list[qcfpos].error_ind = 1
         SET products->fac_list[faccnt].prod_list[prodcnt].ident_list[qcfpos].message =
         "ERROR: QCF is not greater than 0"
         CALL updateinvalididentifier(products->fac_list[faccnt].prod_list[prodcnt].ident_list[qcfpos
          ].med_identifier_id,products->fac_list[faccnt].prod_list[prodcnt].ident_list[qcfpos].
          message)
        ENDIF
       ELSE
        SET qcfnbr = 1.0
       ENDIF
      ENDIF
      FOR (identcnt = 1 TO size(products->fac_list[faccnt].prod_list[prodcnt].ident_list,5))
       IF (debug_ind=1)
        CALL echo(build2("Starting on identCnt: ",trim(cnvtstring(identcnt))," of ",trim(cnvtstring(
            size(products->fac_list[faccnt].prod_list[prodcnt].ident_list,5)))))
        CALL echo(uar_get_code_display(products->fac_list[faccnt].prod_list[prodcnt].ident_list[
          identcnt].med_identifier_type_cd))
        CALL echo(products->fac_list[faccnt].prod_list[prodcnt].ident_list[identcnt].
         med_identifier_type_cd)
        CALL echo(products->fac_list[faccnt].prod_list[prodcnt].ident_list[identcnt].value)
       ENDIF
       FOR (manfcnt = 1 TO size(products->fac_list[faccnt].prod_list[prodcnt].manf_list,5))
         SET billcodeschedcd = 0
         IF (debug_ind=1)
          CALL echo(build2("Starting on manfCnt: ",trim(cnvtstring(manfcnt))," of ",trim(cnvtstring(
              size(products->fac_list[faccnt].prod_list[prodcnt].manf_list,5)))))
          CALL echo(build2("med_product_id: ",trim(cnvtstring(products->fac_list[faccnt].prod_list[
              prodcnt].manf_list[manfcnt].med_product_id))))
          CALL echo(build2("bill_item_id: ",trim(cnvtstring(products->fac_list[faccnt].prod_list[
              prodcnt].manf_list[manfcnt].bill_item_id))))
         ENDIF
         IF (cdm_pref=manf_item)
          SET prodpos = locateval(idx,1,size(bill_items->list,5),products->fac_list[faccnt].
           prod_list[prodcnt].item_id,bill_items->list[idx].item_id,
           products->fac_list[faccnt].prod_list[prodcnt].manf_list[manfcnt].med_product_id,bill_items
           ->list[idx].med_product_id)
         ELSE
          SET prodpos = locateval(idx,1,size(bill_items->list,5),products->fac_list[faccnt].
           prod_list[prodcnt].item_id,bill_items->list[idx].item_id)
         ENDIF
         IF (prodpos=0)
          CALL echo("PRODUCT MISSING BILL_ITEM!")
          CALL echo(build2("item_id: ",trim(cnvtstring(products->fac_list[faccnt].prod_list[prodcnt].
              item_id))))
          CALL echo(build2("med_product_id: ",trim(cnvtstring(products->fac_list[faccnt].prod_list[
              prodcnt].manf_list[manfcnt].med_product_id))))
         ELSE
          SET identpos = locateval(idx,1,size(mappings->list[facpos].bcs_list,5),products->fac_list[
           faccnt].prod_list[prodcnt].ident_list[identcnt].med_identifier_type_cd,mappings->list[
           facpos].bcs_list[idx].med_identifier_type_cd)
          IF (identpos > 0)
           SET billcodeschedcd = mappings->list[facpos].bcs_list[identpos].bill_code_sched_cd
          ENDIF
          IF (debug_ind=1)
           CALL echo(build2("identPos: ",trim(cnvtstring(identpos))))
           CALL echo(build2("billCodeSchedCd: ",trim(cnvtstring(billcodeschedcd))))
          ENDIF
          SET products->fac_list[faccnt].prod_list[prodcnt].ident_list[identcnt].bill_code_sched_cd
           = billcodeschedcd
          SET products->fac_list[faccnt].prod_list[prodcnt].manf_list[manfcnt].bill_item_id =
          bill_items->list[prodpos].bill_item_id
          SET products->fac_list[faccnt].prod_list[prodcnt].manf_list[manfcnt].bill_item_desc =
          bill_items->list[prodpos].bill_item_desc
          IF ((products->fac_list[faccnt].prod_list[prodcnt].ident_list[identcnt].error_ind=0))
           IF ((products->fac_list[faccnt].prod_list[prodcnt].manf_list[manfcnt].stacked_ndc_ind=1))
            SET products->fac_list[faccnt].prod_list[prodcnt].ident_list[identcnt].message = build2(
             "SUCCESS: Added ",trim(evaluate(billcodeschedcd,- (1.0),"QCF",uar_get_code_display(
                billcodeschedcd)))," to stacked NDC")
           ELSE
            SET products->fac_list[faccnt].prod_list[prodcnt].ident_list[identcnt].message = build2(
             "SUCCESS: Updated ",evaluate(billcodeschedcd,- (1.0),"QCF",uar_get_code_display(
               billcodeschedcd)))
           ENDIF
          ENDIF
          SET bimpos = locateval(idx,1,size(bill_items->list[prodpos].bim_list,5),billcodeschedcd,
           bill_items->list[prodpos].bim_list[idx].bill_code_sched_cd)
         ENDIF
         IF (billcodeschedcd > 0)
          SET afccnt = (afccnt+ 1)
          IF (mod(afccnt,10)=1)
           SET stat = alterlist(request->bill_item_modifier,(afccnt+ 9))
          ENDIF
          IF (debug_ind=1)
           CALL echo("adding bill item modifier")
           CALL echo(build2("afcCnt: ",trim(cnvtstring(afccnt))))
           CALL echo(build2("bimPos: ",trim(cnvtstring(bimpos))))
          ENDIF
          IF (bimpos > 0)
           SET needupdtind = 0
           SET request->bill_item_modifier[afccnt].action_type = "UPT"
           SET request->bill_item_modifier[afccnt].bill_item_mod_id = bill_items->list[prodpos].
           bim_list[bimpos].bill_item_mod_id
           IF ((bill_items->list[prodpos].bim_list[bimpos].beg_effective_dt_tm < products->fac_list[
           faccnt].prod_list[prodcnt].beg_effective_dt_tm))
            SET request->bill_item_modifier[afccnt].beg_effective_dt_tm = bill_items->list[prodpos].
            bim_list[bimpos].beg_effective_dt_tm
            SET products->fac_list[faccnt].prod_list[prodcnt].beg_effective_dt_tm = bill_items->list[
            prodpos].bim_list[bimpos].beg_effective_dt_tm
           ELSE
            SET request->bill_item_modifier[afccnt].beg_effective_dt_tm = products->fac_list[faccnt].
            prod_list[prodcnt].beg_effective_dt_tm
           ENDIF
           SET request->bill_item_modifier[afccnt].end_effective_dt_tm = bill_items->list[prodpos].
           bim_list[bimpos].end_effective_dt_tm
          ELSE
           SET request->bill_item_modifier[afccnt].action_type = "ADD"
           SET request->bill_item_modifier[afccnt].beg_effective_dt_tm = products->fac_list[faccnt].
           prod_list[prodcnt].beg_effective_dt_tm
           SET request->bill_item_modifier[afccnt].end_effective_dt_tm = cnvtdatetime(
            "31-DEC-2100 23:59:59")
          ENDIF
          SET request->bill_item_modifier[afccnt].bill_item_id = bill_items->list[prodpos].
          bill_item_id
          SET request->bill_item_modifier[afccnt].bill_item_type_cd = bill_code_type_cd
          SET request->bill_item_modifier[afccnt].key1_id = billcodeschedcd
          SET request->bill_item_modifier[afccnt].bim1_int = 1.0
          IF (debug_ind=1)
           CALL echo(build2("action_type: ",request->bill_item_modifier[afccnt].action_type))
           CALL echo(build2("billCodeSchedCd meaning: ",uar_get_code_meaning(billcodeschedcd)))
          ENDIF
          IF (uar_get_code_meaning(billcodeschedcd)="HCPCS")
           SET desc = piece(products->fac_list[faccnt].prod_list[prodcnt].ident_list[identcnt].value,
            "|",2,notfnd,3)
           IF (desc=notfnd)
            SET request->bill_item_modifier[afccnt].key6 = cnvtupper(products->fac_list[faccnt].
             prod_list[prodcnt].ident_list[identcnt].value)
            SELECT INTO "nl:"
             n.source_string
             FROM nomenclature n
             WHERE n.source_identifier=cnvtupper(products->fac_list[faccnt].prod_list[prodcnt].
              ident_list[identcnt].value)
              AND n.source_vocabulary_cd=hcpcs_vocab_cd
              AND n.principle_type_cd=procedure_type_cd
              AND n.active_ind=1
             DETAIL
              desc = n.source_string
             WITH nocounter
            ;end select
           ELSE
            SET request->bill_item_modifier[afccnt].key6 = piece(products->fac_list[faccnt].
             prod_list[prodcnt].ident_list[identcnt].value,"|",1,notfnd,3)
           ENDIF
           IF (desc != notfnd)
            SET request->bill_item_modifier[afccnt].key7 = substring(1,200,desc)
           ENDIF
           SET request->bill_item_modifier[afccnt].bim1_nbr = qcfnbr
           IF (bimpos > 0)
            IF ((bill_items->list[prodpos].bim_list[bimpos].beg_effective_dt_tm < products->fac_list[
            faccnt].prod_list[prodcnt].beg_effective_dt_tm))
             SET products->fac_list[faccnt].prod_list[prodcnt].beg_effective_dt_tm = bill_items->
             list[prodpos].bim_list[bimpos].beg_effective_dt_tm
            ENDIF
           ENDIF
           IF ((products->fac_list[faccnt].prod_list[prodcnt].ident_list[identcnt].error_ind=0))
            IF ((request->bill_item_modifier[afccnt].action_type="UPT"))
             IF ((request->bill_item_modifier[afccnt].key6 != bill_items->list[prodpos].bim_list[
             bimpos].key_6))
              SET needupdtind = 1
              IF (debug_ind=1)
               CALL echo("key6 is changing")
               CALL echo(build2("before: ",bill_items->list[prodpos].bim_list[bimpos].key_6))
               CALL echo(build2("after: ",request->bill_item_modifier[afccnt].key6))
              ENDIF
             ENDIF
             IF ((request->bill_item_modifier[afccnt].key7 != bill_items->list[prodpos].bim_list[
             bimpos].key_7))
              SET needupdtind = 1
              IF (debug_ind=1)
               CALL echo("key7 is changing")
               CALL echo(build2("before: ",bill_items->list[prodpos].bim_list[bimpos].key_7))
               CALL echo(build2("after: ",request->bill_item_modifier[afccnt].key7))
              ENDIF
             ENDIF
             IF ((request->bill_item_modifier[afccnt].bim1_nbr != bill_items->list[prodpos].bim_list[
             bimpos].bim1_nbr)
              AND  NOT ((request->bill_item_modifier[afccnt].bim1_nbr=1)
              AND (bill_items->list[prodpos].bim_list[bimpos].bim1_nbr=0)))
              SET needupdtind = 1
              IF (debug_ind=1)
               CALL echo("qcf is changing")
               CALL echo(build2("before: ",bill_items->list[prodpos].bim_list[bimpos].bim1_nbr))
               CALL echo(build2("after: ",request->bill_item_modifier[afccnt].bim1_nbr))
              ENDIF
             ELSE
              IF (debug_ind=1)
               CALL echo("qcf is NOT changing")
               CALL echo(build2("qcf: ",bill_items->list[prodpos].bim_list[bimpos].bim1_nbr))
               CALL echo("adding med_identifier_type_cd to the idents_not_updt list:")
               CALL echo(qcfidentifiertypecd)
               CALL echo(uar_get_code_display(qcfidentifiertypecd))
              ENDIF
              SET cnt = (size(products->fac_list[faccnt].prod_list[prodcnt].manf_list[manfcnt].
               idents_not_updt,5)+ 1)
              SET stat = alterlist(products->fac_list[faccnt].prod_list[prodcnt].manf_list[manfcnt].
               idents_not_updt,cnt)
              SET products->fac_list[faccnt].prod_list[prodcnt].manf_list[manfcnt].idents_not_updt[
              cnt].med_identifier_type_cd = qcfidentifiertypecd
             ENDIF
            ENDIF
           ENDIF
          ENDIF
          IF (uar_get_code_meaning(billcodeschedcd)="REVENUE")
           SET desc = notfnd
           SELECT INTO "nl:"
            cv.description
            FROM code_value cv
            WHERE cv.code_set=20769
             AND (cv.display_key=products->fac_list[faccnt].prod_list[prodcnt].ident_list[identcnt].
            value)
             AND cv.active_ind=1
            HEAD REPORT
             revenuecd = 0
            DETAIL
             desc = cv.description, revenuecd = cv.code_value
            WITH nocounter
           ;end select
           IF (desc=notfnd)
            SELECT INTO "nl:"
             cv.description
             FROM code_value cv
             WHERE cv.code_set=20769
              AND cv.display_key=concat("0",products->fac_list[faccnt].prod_list[prodcnt].ident_list[
              identcnt].value)
              AND cv.active_ind=1
             HEAD REPORT
              revenuecd = 0
             DETAIL
              desc = cv.description, revenuecd = cv.code_value, products->fac_list[faccnt].prod_list[
              prodcnt].ident_list[identcnt].value = concat("0",products->fac_list[faccnt].prod_list[
               prodcnt].ident_list[identcnt].value)
             WITH nocounter
            ;end select
            IF (revenuecd > 0)
             CALL updateidentifier(products->fac_list[faccnt].prod_list[prodcnt].ident_list[identcnt]
              .med_identifier_id,products->fac_list[faccnt].prod_list[prodcnt].ident_list[identcnt].
              value)
            ENDIF
           ENDIF
           IF (desc != notfnd)
            SET request->bill_item_modifier[afccnt].key5_id = revenuecd
            SET request->bill_item_modifier[afccnt].key6 = products->fac_list[faccnt].prod_list[
            prodcnt].ident_list[identcnt].value
            SET request->bill_item_modifier[afccnt].key7 = desc
           ELSE
            SET afccnt = (afccnt - 1)
            SET products->fac_list[faccnt].error_found = 1
            SET products->fac_list[faccnt].prod_list[prodcnt].ident_list[identcnt].error_ind = 1
            SET products->fac_list[faccnt].prod_list[prodcnt].ident_list[identcnt].message =
            "ERROR: Invalid revenue code"
            CALL updateinvalididentifier(products->fac_list[faccnt].prod_list[prodcnt].ident_list[
             identcnt].med_identifier_id,products->fac_list[faccnt].prod_list[prodcnt].ident_list[
             identcnt].message)
           ENDIF
           IF ((products->fac_list[faccnt].prod_list[prodcnt].ident_list[identcnt].error_ind=0))
            IF ((request->bill_item_modifier[afccnt].action_type="UPT"))
             IF ((request->bill_item_modifier[afccnt].key5_id != bill_items->list[prodpos].bim_list[
             bimpos].key5_id))
              SET needupdtind = 1
              IF (debug_ind=1)
               CALL echo("key5_id is changing")
               CALL echo(build2("before: ",bill_items->list[prodpos].bim_list[bimpos].key5_id))
               CALL echo(build2("after: ",request->bill_item_modifier[afccnt].key5_id))
              ENDIF
             ENDIF
             IF ((request->bill_item_modifier[afccnt].key6 != bill_items->list[prodpos].bim_list[
             bimpos].key_6))
              SET needupdtind = 1
              IF (debug_ind=1)
               CALL echo("key6 is changing")
               CALL echo(build2("before: ",bill_items->list[prodpos].bim_list[bimpos].key_6))
               CALL echo(build2("after: ",request->bill_item_modifier[afccnt].key6))
              ENDIF
             ENDIF
             IF ((request->bill_item_modifier[afccnt].key7 != bill_items->list[prodpos].bim_list[
             bimpos].key_7))
              SET needupdtind = 1
              IF (debug_ind=1)
               CALL echo("key7 is changing")
               CALL echo(build2("before: ",bill_items->list[prodpos].bim_list[bimpos].key_7))
               CALL echo(build2("after: ",request->bill_item_modifier[afccnt].key7))
              ENDIF
             ENDIF
            ENDIF
           ENDIF
          ENDIF
         ENDIF
         IF (needupdtind=0
          AND billcodeschedcd > 0
          AND (request->bill_item_modifier[afccnt].action_type="UPT"))
          IF (debug_ind=1)
           CALL echo("removing bill item modifier to update since it has not changed")
           CALL echo(build2("afcCnt before: ",trim(cnvtstring(afccnt))))
          ENDIF
          SET afccnt = (afccnt - 1)
          SET cnt = (size(products->fac_list[faccnt].prod_list[prodcnt].manf_list[manfcnt].
           idents_not_updt,5)+ 1)
          SET stat = alterlist(products->fac_list[faccnt].prod_list[prodcnt].manf_list[manfcnt].
           idents_not_updt,cnt)
          SET products->fac_list[faccnt].prod_list[prodcnt].manf_list[manfcnt].idents_not_updt[cnt].
          med_identifier_type_cd = products->fac_list[faccnt].prod_list[prodcnt].ident_list[identcnt]
          .med_identifier_type_cd
         ELSEIF (needupdtind=1
          AND billcodeschedcd > 0
          AND (request->bill_item_modifier[afccnt].action_type="UPT"))
          IF (debug_ind=1)
           CALL echo("modify bill item modifier to end effective old row and add new row")
           CALL echo(build2("afcCnt before: ",trim(cnvtstring(afccnt))))
           CALL echo(build2("end effective dating bill_item_modifier: ",request->bill_item_modifier[
             afccnt].bill_item_mod_id))
          ENDIF
          SET request->bill_item_modifier[afccnt].action_type = "ADD"
          SET request->bill_item_modifier[afccnt].beg_effective_dt_tm = begeffdatetime
          SET afccnt = (afccnt+ 1)
          IF (mod(afccnt,10)=1)
           SET stat = alterlist(request->bill_item_modifier,(afccnt+ 9))
          ENDIF
          SET request->bill_item_modifier[afccnt].action_type = "UPT"
          SET request->bill_item_modifier[afccnt].end_effective_dt_tm = endeffdatetime
          SET request->bill_item_modifier[afccnt].bill_item_type_cd = bill_code_type_cd
          SET request->bill_item_modifier[afccnt].bill_item_mod_id = request->bill_item_modifier[(
          afccnt - 1)].bill_item_mod_id
          SET request->bill_item_modifier[afccnt].bill_item_id = request->bill_item_modifier[(afccnt
           - 1)].bill_item_id
          SET request->bill_item_modifier[afccnt].bim1_int = 1.0
          SET request->bill_item_modifier[afccnt].bim1_nbr = bill_items->list[prodpos].bim_list[
          bimpos].bim1_nbr
          SET request->bill_item_modifier[(afccnt - 1)].bill_item_mod_id = 0.0
          SET products->fac_list[faccnt].prod_list[prodcnt].beg_effective_dt_tm = begeffdatetime
         ENDIF
       ENDFOR
      ENDFOR
    ENDFOR
   ENDFOR
   SET stat = alterlist(request->bill_item_modifier,afccnt)
   SET request->bill_item_modifier_qual = afccnt
   IF (debug_ind=1)
    CALL echo("products record after being loaded in loadRequest()")
    CALL echorecord(products)
    CALL echo("request after being loaded in loadRequest()")
    CALL echorecord(request)
    SELECT INTO value(requestlogfile)
     action_type = substring(1,3,request->bill_item_modifier[d.seq].action_type), bill_item_mod_id =
     request->bill_item_modifier[d.seq].bill_item_mod_id, bill_item_id = request->bill_item_modifier[
     d.seq].bill_item_id,
     bill_item_type_cd = request->bill_item_modifier[d.seq].bill_item_type_cd, key1_id = request->
     bill_item_modifier[d.seq].key1_id, key2_id = request->bill_item_modifier[d.seq].key2_id,
     key3_id = request->bill_item_modifier[d.seq].key3_id, key4_id = request->bill_item_modifier[d
     .seq].key4_id, key5_id = request->bill_item_modifier[d.seq].key5_id,
     key6 = substring(1,1000,request->bill_item_modifier[d.seq].key6), key7 = substring(1,1000,
      request->bill_item_modifier[d.seq].key7), key8 = substring(1,1000,request->bill_item_modifier[d
      .seq].key8),
     key9 = substring(1,1000,request->bill_item_modifier[d.seq].key9), key10 = substring(1,1000,
      request->bill_item_modifier[d.seq].key10), key11 = substring(1,1000,request->
      bill_item_modifier[d.seq].key11),
     key12 = substring(1,1000,request->bill_item_modifier[d.seq].key12), key13 = substring(1,1000,
      request->bill_item_modifier[d.seq].key13), key14 = substring(1,1000,request->
      bill_item_modifier[d.seq].key14),
     key15 = substring(1,1000,request->bill_item_modifier[d.seq].key15), key11_id = request->
     bill_item_modifier[d.seq].key11_id, key12_id = request->bill_item_modifier[d.seq].key12_id,
     key13_id = request->bill_item_modifier[d.seq].key13_id, key14_id = request->bill_item_modifier[d
     .seq].key14_id, key15_id = request->bill_item_modifier[d.seq].key15_id,
     bim1_int = request->bill_item_modifier[d.seq].bim1_int, bim1_nbr = request->bill_item_modifier[d
     .seq].bim1_nbr, bim2_int = request->bill_item_modifier[d.seq].bim2_int,
     bim_ind = request->bill_item_modifier[d.seq].bim_ind, bim1_ind = request->bill_item_modifier[d
     .seq].bim1_ind, active_ind_ind = request->bill_item_modifier[d.seq].active_ind_ind,
     active_ind = request->bill_item_modifier[d.seq].active_ind, active_status_cd = request->
     bill_item_modifier[d.seq].active_status_cd, active_status_dt_tm = format(request->
      bill_item_modifier[d.seq].active_status_dt_tm,";;q"),
     active_status_prsnl_id = request->bill_item_modifier[d.seq].active_status_prsnl_id,
     beg_effective_dt_tm = format(request->bill_item_modifier[d.seq].beg_effective_dt_tm,";;q"),
     end_effective_dt_tm = format(request->bill_item_modifier[d.seq].end_effective_dt_tm,";;q")
     FROM (dummyt d  WITH seq = value(size(request->bill_item_modifier,5)))
     PLAN (d)
     WITH format = stream, pcformat('"',",",1), format
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE performupdates(null)
   DECLARE updttask = i4 WITH protect
   CALL echo("Calling afc_ens_bill_item_modifier to update the bill items")
   SET updttask = reqinfo->updt_task
   SET reqinfo->updt_task = - (267)
   EXECUTE afc_ens_bill_item_modifier
   SET reqinfo->updt_task = updttask
   CALL echo(build2("afc_ens_bill_item_modifier completed with status: ",reply->status_data.status))
   IF ((reply->status_data.status="S"))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE createoutputreport(faccd)
   DECLARE facname = vc WITH protect
   DECLARE facpos = i4 WITH protect
   DECLARE idx = i4 WITH protect
   DECLARE j = i4 WITH protect
   DECLARE prodcnt = i4 WITH protect
   DECLARE identcnt = i4 WITH protect
   DECLARE manfcnt = i4 WITH protect
   DECLARE removeidentpos = i4 WITH protect
   SET stat = initrec(output)
   IF (faccd > 0)
    SET facname = uar_get_code_display(faccd)
    SET filename = cnvtlower(concat(replace(facname," ","_"),"_",trim(curdomain),"_bill_item_updts_",
      format(cnvtdatetime(curdate,curtime3),"dd_mmm_yyyy_hh_mm;;q"),
      ".csv"))
   ELSE
    SET facname = "All facilities"
    SET filename = cnvtlower(concat("all_facilities_bill_item_updts_",format(cnvtdatetime(curdate,
        curtime3),"dd_mmm_yyyy_hh_mm;;q"),".csv"))
   ENDIF
   SET facpos = locateval(idx,1,size(products->fac_list,5),faccd,products->fac_list[idx].facility_cd)
   SET idx = 0
   FOR (prodcnt = 1 TO size(products->fac_list[facpos].prod_list,5))
     FOR (identcnt = 1 TO size(products->fac_list[facpos].prod_list[prodcnt].ident_list,5))
       FOR (manfcnt = 1 TO size(products->fac_list[facpos].prod_list[prodcnt].manf_list,5))
        SET removeidentpos = locateval(j,1,size(products->fac_list[facpos].prod_list[prodcnt].
          manf_list[manfcnt].idents_not_updt,5),products->fac_list[facpos].prod_list[prodcnt].
         ident_list[identcnt].med_identifier_type_cd,products->fac_list[facpos].prod_list[prodcnt].
         manf_list[manfcnt].idents_not_updt[j].med_identifier_type_cd)
        IF (removeidentpos=0)
         SET idx = (idx+ 1)
         IF (mod(idx,100)=1)
          SET stat = alterlist(output->list,(idx+ 99))
         ENDIF
         SET output->list[idx].status = products->fac_list[facpos].prod_list[prodcnt].ident_list[
         identcnt].message
         SET output->list[idx].desc = products->fac_list[facpos].prod_list[prodcnt].desc
         SET output->list[idx].bill_item_desc = products->fac_list[facpos].prod_list[prodcnt].
         manf_list[manfcnt].bill_item_desc
         SET output->list[idx].bill_code_schedule = evaluate(products->fac_list[facpos].prod_list[
          prodcnt].ident_list[identcnt].bill_code_sched_cd,- (1.0),"QCF",uar_get_code_display(
           products->fac_list[facpos].prod_list[prodcnt].ident_list[identcnt].bill_code_sched_cd))
         SET output->list[idx].value = products->fac_list[facpos].prod_list[prodcnt].ident_list[
         identcnt].value
         SET output->list[idx].beg_effective_dt_tm = products->fac_list[facpos].prod_list[prodcnt].
         beg_effective_dt_tm
         SET output->list[idx].item_id = products->fac_list[facpos].prod_list[prodcnt].item_id
         SET output->list[idx].bill_item_id = products->fac_list[facpos].prod_list[prodcnt].
         manf_list[manfcnt].bill_item_id
        ENDIF
       ENDFOR
     ENDFOR
   ENDFOR
   SET stat = alterlist(output->list,idx)
   IF (debug_ind=1)
    CALL echo(build2("output record for ",uar_get_code_display(faccd)))
    CALL echorecord(output)
   ENDIF
   IF (idx > 0)
    IF ((products->fac_list[facpos].error_found=1))
     SET subjstr = build2("ERROR: ",facname," ",trim(curdomain),": Pharmacy Bill Item Report ",
      format(cnvtdatetime(curdate,curtime3),"@SHORTDATETIME"))
    ELSE
     SET subjstr = build2(facname," ",trim(curdomain),": Pharmacy Bill Item Report ",format(
       cnvtdatetime(curdate,curtime3),"@SHORTDATETIME"))
    ENDIF
    SET bodystr = build2("Attached is the report of bill item changes that occurred between ",format(
      lastrundatetime,"dd_mmm_yyyy_hh_mm;;q")," and ",format(currentrundatetime,
      "dd_mmm_yyyy_hh_mm;;q"))
    CALL echo(build2("Creating output report: ",filename))
    SELECT INTO value(filename)
     status = substring(1,1000,output->list[d1.seq].status), product_description = substring(1,100,
      output->list[d1.seq].desc), bill_item_desc = substring(1,200,output->list[d1.seq].
      bill_item_desc),
     bill_code_schedule = substring(1,100,output->list[d1.seq].bill_code_schedule), value = substring
     (1,100,output->list[d1.seq].value), beg_effective_dt_tm = format(output->list[d1.seq].
      beg_effective_dt_tm,";;q"),
     item_id = output->list[d1.seq].item_id, bill_item_id = output->list[d1.seq].bill_item_id
     FROM (dummyt d1  WITH seq = value(size(output->list,5)))
     PLAN (d1)
     ORDER BY cnvtupper(output->list[d1.seq].desc), cnvtupper(output->list[d1.seq].bill_item_desc),
      bill_code_schedule
     WITH format = stream, pcformat('"',",",1), format
    ;end select
    SET recpstr = ams_email
    SET stat = emailfile(recpstr,ams_email,subjstr,bodystr,filename)
    IF (stat != 1)
     SET status = "F"
     SET statusstr = "Email failed sending to AMS"
     GO TO exit_script
    ENDIF
    FOR (j = 1 TO emails->emails_cnt)
      IF ((emails->list[j].facility_cd=faccd))
       SET recpstr = emails->list[j].email_address
       SET stat = emailfile(recpstr,ams_email,subjstr,bodystr,filename)
       IF (stat=1)
        CALL echo(build2("Sending output report to ",recpstr))
       ELSE
        SET status = "F"
        SET statusstr = build2("Email failed sending to ",recpstr)
        GO TO exit_script
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
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
 SUBROUTINE updateinvalididentifier(identid,msg)
   DECLARE valuestr = vc WITH protect
   DECLARE valuekeystr = vc WITH protect
   SELECT INTO "nl:"
    FROM med_identifier mi
    WHERE mi.med_identifier_id=identid
    DETAIL
     valuestr = trim(substring(1,200,build2(trim(msg)," - ",mi.value))), valuekeystr = cnvtupper(
      cnvtalphanum(valuestr))
    WITH nocounter, forupdate(mi)
   ;end select
   IF (valuekeystr != "*ERROR*ERROR*")
    UPDATE  FROM med_identifier mi
     SET mi.value = valuestr, mi.value_key = valuekeystr, mi.updt_dt_tm = cnvtdatetime(curdate,
       curtime3),
      mi.updt_id = reqinfo->updt_id, mi.updt_cnt = (mi.updt_cnt+ 1), mi.updt_applctx = 0,
      mi.updt_task = - (267)
     PLAN (mi
      WHERE mi.med_identifier_id=identid)
     WITH nocounter
    ;end update
    IF (((curqual != 1) OR (error(errormsg,0) != 0)) )
     SET status = "F"
     SET statusstr = build2("Error updating invalid identifier",trim(cnvtstring(identid)))
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE updateidentifier(identid,value)
   DECLARE valuestr = vc WITH protect
   DECLARE valuekeystr = vc WITH protect
   SELECT INTO "nl:"
    FROM med_identifier mi
    WHERE mi.med_identifier_id=identid
    WITH nocounter, forupdate(mi)
   ;end select
   UPDATE  FROM med_identifier mi
    SET mi.value = value, mi.value_key = cnvtupper(cnvtalphanum(value)), mi.updt_dt_tm = cnvtdatetime
     (curdate,curtime3),
     mi.updt_id = reqinfo->updt_id, mi.updt_cnt = (mi.updt_cnt+ 1), mi.updt_applctx = 0,
     mi.updt_task = - (267)
    PLAN (mi
     WHERE mi.med_identifier_id=identid)
    WITH nocounter
   ;end update
   IF (((curqual != 1) OR (error(errormsg,0) != 0)) )
    SET status = "F"
    SET statusstr = build2("Error updating existing identifier",trim(cnvtstring(identid)))
    GO TO exit_script
   ENDIF
 END ;Subroutine
#exit_script
 FREE RECORD reply
 RECORD reply(
   1 ops_event = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = status
 SET reply->ops_event = statusstr
 IF (status="F")
  CALL echo("SCRIPT FAILED EXECUTING")
  CALL echo(statusstr)
  CALL echo(errormsg)
  ROLLBACK
  SET recpstr = ams_email
  SET subjstr = build2("ERROR ",getclient(null)," : ",trim(curdomain)," ops job failure")
  SET bodystr = build2(statusstr,char(10),errormsg)
  SET stat = emailfile(ams_email,recpstr,subjstr,bodystr,"")
 ELSE
  COMMIT
 ENDIF
 SET last_mod = "013"
END GO
