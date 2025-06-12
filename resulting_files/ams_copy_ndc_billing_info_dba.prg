CREATE PROGRAM ams_copy_ndc_billing_info:dba
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
 DECLARE getcdmprefsetting(null) = i2 WITH protect
 DECLARE getbillitemswithmissinginfo(null) = i4 WITH protect
 DECLARE performupdates(null) = i2 WITH protect
 DECLARE createoutputreport(filename=vc) = null WITH protect
 DECLARE incrementbillitemcount(inccnt=i4) = i2 WITH protect
 DECLARE clientstr = vc WITH protect, constant(cnvtlower(getclient(null)))
 DECLARE script_name = c25 WITH protect, constant("AMS_COPY_NDC_BILLING_INFO")
 DECLARE delim = vc WITH protect, constant(",")
 DECLARE output_report = vc WITH protect, constant(concat(clientstr,"_bill_items_updated_",cnvtlower(
    format(cnvtdatetime(curdate,curtime3),"dd_mmm_yyyy;;q")),".csv"))
 DECLARE manf_item = i2 WITH protect, constant(0)
 DECLARE ndc_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"NDC"))
 DECLARE desc_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"DESC"))
 DECLARE active_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE pharm_activity_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",106,"PHARMACY")
  )
 DECLARE inpatient_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4500,"INPATIENT"))
 DECLARE system_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4062,"SYSTEM"))
 DECLARE system_pkg_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4062,"SYSPKGTYP"))
 DECLARE ams_email = vc WITH protect, constant("ams_pharm_backups@cerner.com")
 DECLARE cdm_pref = i2 WITH protect, constant(getcdmprefsetting(null))
 DECLARE bill_code_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",13019,"BILL CODE"))
 DECLARE linestr = c30 WITH protect, constant(fillstring(30,"*"))
 DECLARE subjstr = vc WITH protect
 DECLARE recpstr = vc WITH protect
 DECLARE emailbody = vc WITH protect, noconstant("Bill item report attached.")
 DECLARE sendemailind = i2 WITH protect
 DECLARE ndccnt = i4
 RECORD ndcs(
   1 list[*]
     2 desc = vc
     2 item_id = f8
     2 primary_ndc = vc
     2 primary_bill_desc = vc
     2 bill_code_sched = vc
     2 bill_code = vc
     2 bill_code_desc = vc
     2 qcf = f8
     2 secondary_ndc = vc
     2 ndc_seq = i4
     2 secondary_bill_desc = vc
     2 updt_person = vc
     2 updt_dt_tm = dq8
     2 primary_bill_item_id = f8
     2 secondary_bill_item_id = f8
 ) WITH protect
 SET trace = nocallecho
 EXECUTE ams_define_toolkit_common
 SET trace = callecho
 CALL echo("***Beginning ams_copy_ndc_billing_info***")
 SET statusstr = "Error executing script"
 SET status = "F"
 IF (validate(request->batch_selection,"-1")="-1")
  SET sendemailind = 0
 ELSE
  IF ((request->output_dist="*@*.*"))
   SET sendemailind = 1
   SET recpstr = trim(request->output_dist)
  ELSEIF (textlen(request->output_dist) > 0)
   SET statusstr = "Output distribution does not contain a valid email address."
   SET status = "F"
   GO TO exit_script
  ENDIF
 ENDIF
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
 IF (cdm_pref != manf_item)
  SET statusstr = "Charging pref is set to drug form level. This ops job is not needed."
  SET status = "F"
  GO TO exit_script
 ELSE
  SET ndccnt = getbillitemswithmissinginfo(null)
  IF (ndccnt > 0)
   SET stat = performupdates(null)
   IF (stat=1)
    SET trace = nocallecho
    CALL updtdminfo(script_name,cnvtreal(ndccnt))
    SET trace = callecho
    CALL createoutputreport(output_report)
    CALL echo(build2("Filename: ",output_report))
    SET subjstr = build2(cnvtupper(clientstr)," ",trim(curdomain),": Copy NDC Billing Info ",trim(
      cnvtstring(ndccnt)),
     " Bill Items Updated")
    SET stat = emailfile(ams_email,ams_email,subjstr,emailbody,output_report)
    IF (stat != 1)
     SET status = "F"
     SET statusstr = "Email failed sending to AMS"
     GO TO exit_script
    ENDIF
    IF (sendemailind=1)
     SET stat = emailfile(recpstr,ams_email,subjstr,emailbody,output_report)
    ENDIF
    SET statusstr = build2("Successfully copied billing information to ",trim(cnvtstring(ndccnt)),
     " bill items.")
    SET status = "S"
   ELSE
    SET status = "F"
    SET statusstr = "Error occurred updating bill items in afc_ens_bill_item_modifier"
    GO TO exit_script
   ENDIF
  ELSE
   SET statusstr = build2("No non-primary NDCs found without billing info.")
   SET status = "S"
  ENDIF
 ENDIF
 SUBROUTINE getbillitemswithmissinginfo(null)
   DECLARE retval = i4 WITH protect
   CALL echo("Finding non-primary NDCs without billing information")
   SELECT INTO "nl:"
    desc = mi3.value, primary_ndc = mi1.value, primary_bill_item_description = bi.ext_description,
    bill_code_schedule = uar_get_code_display(bim.key1_id), bill_code = bim.key6, qcf = bim.bim1_nbr
    "######.###",
    bill_code_desc = bim.key7, secondary_ndc = mi2.value, ndc_number = mfoi2.sequence,
    secondary_bill_item_description = bi2.ext_description, p.name_full_formatted,
    primary_bill_item_id = bi.bill_item_id,
    secondary_bill_item_id = bi2.bill_item_id
    FROM med_def_flex mdf,
     med_def_flex mdf2,
     med_flex_object_idx mfoi,
     med_flex_object_idx mfoi2,
     med_identifier mi1,
     med_identifier mi2,
     med_identifier mi3,
     med_product mp,
     med_product mp2,
     bill_item bi,
     bill_item_modifier bim,
     bill_item bi2,
     prsnl p
    PLAN (mdf
     WHERE mdf.active_status_cd=active_type_cd
      AND mdf.pharmacy_type_cd=inpatient_type_cd
      AND mdf.flex_type_cd=system_pkg_type_cd)
     JOIN (mdf2
     WHERE mdf2.item_id=mdf.item_id
      AND mdf2.flex_type_cd=system_type_cd)
     JOIN (mfoi
     WHERE mfoi.med_def_flex_id=mdf2.med_def_flex_id
      AND mfoi.parent_entity_name="MED_PRODUCT"
      AND mfoi.sequence=1)
     JOIN (mfoi2
     WHERE mfoi2.med_def_flex_id=mdf2.med_def_flex_id
      AND mfoi2.parent_entity_name="MED_PRODUCT"
      AND mfoi2.sequence != 1)
     JOIN (mi1
     WHERE mi1.item_id=mdf.item_id
      AND mi1.med_def_flex_id=mdf2.med_def_flex_id
      AND mi1.med_product_id=mfoi.parent_entity_id
      AND mi1.med_identifier_type_cd=ndc_type_cd
      AND mi1.active_ind=1
      AND mi1.primary_ind=1)
     JOIN (mi2
     WHERE mi2.item_id=mdf.item_id
      AND mi2.med_def_flex_id=mdf2.med_def_flex_id
      AND mi2.med_product_id=mfoi2.parent_entity_id
      AND mi2.med_identifier_type_cd=ndc_type_cd
      AND mi2.active_ind=1
      AND mi2.primary_ind=1)
     JOIN (mi3
     WHERE mi3.item_id=mdf.item_id
      AND mi3.med_def_flex_id=mdf2.med_def_flex_id
      AND mi3.med_product_id=0
      AND mi3.med_identifier_type_cd=desc_type_cd
      AND mi3.active_ind=1
      AND mi3.primary_ind=1)
     JOIN (mp
     WHERE mp.med_product_id=mfoi.parent_entity_id)
     JOIN (mp2
     WHERE mp2.med_product_id=mfoi2.parent_entity_id)
     JOIN (bi
     WHERE bi.ext_parent_reference_id=mp.manf_item_id
      AND bi.ext_owner_cd=pharm_activity_type_cd
      AND bi.active_ind=1
      AND bi.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
      AND bi.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (bim
     WHERE bim.bill_item_id=bi.bill_item_id
      AND bim.active_ind=1
      AND bim.active_status_cd=active_type_cd
      AND bim.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
      AND bim.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (bi2
     WHERE bi2.ext_parent_reference_id=mp2.manf_item_id
      AND bi2.ext_owner_cd=pharm_activity_type_cd
      AND bi2.active_ind=1
      AND bi2.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
      AND bi2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND  NOT ( EXISTS (
     (SELECT
      bim2.bill_item_id
      FROM bill_item_modifier bim2
      WHERE bim2.bill_item_id=bi2.bill_item_id))))
     JOIN (p
     WHERE p.person_id=bi2.updt_id)
    ORDER BY mi3.value_key, mfoi2.sequence, bill_code_schedule
    HEAD REPORT
     i = 0, retval = 0
    HEAD mfoi2.parent_entity_id
     retval = (retval+ 1)
     IF (debug_ind=1)
      CALL echo(linestr),
      CALL echo(build2("item_id = ",trim(cnvtstring(mdf.item_id)))),
      CALL echo(build2("primary bill_item_id = ",trim(cnvtstring(bi.bill_item_id)))),
      CALL echo(build2("bill_item_id with no bim = ",trim(cnvtstring(bi2.bill_item_id)))),
      CALL echo(build2("mfoi2.parent_entity_id = ",trim(cnvtstring(mfoi2.parent_entity_id)))),
      CALL echo(linestr)
     ENDIF
    DETAIL
     i = (i+ 1)
     IF (mod(i,100)=1)
      stat = alterlist(ndcs->list,(i+ 99)), stat = alterlist(request->bill_item_modifier,(i+ 99))
     ENDIF
     IF (debug_ind=1)
      CALL echo(build2("bill_item_mod_id = ",trim(cnvtstring(bim.bill_item_mod_id)))),
      CALL echo(linestr)
     ENDIF
     ndcs->list[i].desc = desc, ndcs->list[i].item_id = mdf.item_id, ndcs->list[i].primary_ndc =
     primary_ndc,
     ndcs->list[i].primary_bill_desc = primary_bill_item_description, ndcs->list[i].bill_code_sched
      = bill_code_schedule, ndcs->list[i].bill_code = bill_code,
     ndcs->list[i].bill_code_desc = bill_code_desc, ndcs->list[i].qcf = cnvtreal(qcf), ndcs->list[i].
     secondary_ndc = secondary_ndc,
     ndcs->list[i].ndc_seq = ndc_number, ndcs->list[i].secondary_bill_desc =
     secondary_bill_item_description, ndcs->list[i].updt_person = p.name_full_formatted,
     ndcs->list[i].updt_dt_tm = bi2.updt_dt_tm, ndcs->list[i].primary_bill_item_id = bi.bill_item_id,
     ndcs->list[i].secondary_bill_item_id = bi2.bill_item_id,
     request->bill_item_modifier[i].action_type = "ADD", request->bill_item_modifier[i].bill_item_id
      = bi2.bill_item_id, request->bill_item_modifier[i].bill_item_type_cd = bill_code_type_cd,
     request->bill_item_modifier[i].key1_id = bim.key1_id, request->bill_item_modifier[i].key2_id =
     bim.key2_id, request->bill_item_modifier[i].key3_id = bim.key3_id,
     request->bill_item_modifier[i].key4_id = bim.key4_id, request->bill_item_modifier[i].key5_id =
     bim.key5_id, request->bill_item_modifier[i].key6 = bim.key6,
     request->bill_item_modifier[i].key7 = bim.key7, request->bill_item_modifier[i].key8 = bim.key8,
     request->bill_item_modifier[i].key9 = bim.key9,
     request->bill_item_modifier[i].key10 = bim.key10, request->bill_item_modifier[i].key11 = bim
     .key11, request->bill_item_modifier[i].key12 = bim.key12,
     request->bill_item_modifier[i].key13 = bim.key13, request->bill_item_modifier[i].key14 = bim
     .key14, request->bill_item_modifier[i].key15 = bim.key15,
     request->bill_item_modifier[i].key11_id = bim.key11_id, request->bill_item_modifier[i].key12_id
      = bim.key12_id, request->bill_item_modifier[i].key13_id = bim.key13_id,
     request->bill_item_modifier[i].key14_id = bim.key14_id, request->bill_item_modifier[i].key15_id
      = bim.key15_id, request->bill_item_modifier[i].bim1_int = bim.bim1_int,
     request->bill_item_modifier[i].bim1_nbr = bim.bim1_nbr, request->bill_item_modifier[i].bim2_int
      = bim.bim2_int, request->bill_item_modifier[i].bim_ind = bim.bim_ind,
     request->bill_item_modifier[i].bim1_ind = bim.bim1_ind, request->bill_item_modifier[i].
     active_ind_ind = bim.active_ind, request->bill_item_modifier[i].active_ind = bim.active_ind,
     request->bill_item_modifier[i].active_status_cd = bim.active_status_cd, request->
     bill_item_modifier[i].beg_effective_dt_tm = bim.beg_effective_dt_tm, request->
     bill_item_modifier[i].end_effective_dt_tm = bim.end_effective_dt_tm
    FOOT REPORT
     request->bill_item_modifier_qual = i
     IF (mod(i,100) != 0)
      stat = alterlist(ndcs->list,i), stat = alterlist(request->bill_item_modifier,i)
     ENDIF
    WITH nocounter
   ;end select
   CALL echo(build2(trim(cnvtstring(retval))," NDCs found without billing information"))
   IF (debug_ind=1)
    CALL echo("ndcs record after being loaded by getBillItemsWithMissingInfo()")
    CALL echorecord(ndcs)
    CALL echo("request record after being loaded by getBillItemsWithMissingInfo()")
    CALL echorecord(request)
   ENDIF
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE performupdates(null)
   CALL echo("Calling afc_ens_bill_item_modifier to update the bill items")
   EXECUTE afc_ens_bill_item_modifier
   CALL echo(build2("afc_ens_bill_item_modifier completed with status: ",reply->status_data.status))
   IF ((reply->status_data.status="S"))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE createoutputreport(filename)
   SELECT INTO value(filename)
    product_description = substring(1,1000,ndcs->list[d.seq].desc), primary_ndc = substring(1,1000,
     ndcs->list[d.seq].primary_ndc), primary_bill_item_description = substring(1,1000,ndcs->list[d
     .seq].primary_bill_desc),
    bill_code_schedule = substring(1,1000,ndcs->list[d.seq].bill_code_sched), bill_code = substring(1,
     1000,ndcs->list[d.seq].bill_code), qcf = evaluate(ndcs->list[d.seq].qcf,0.0,"",trim(cnvtstring(
       ndcs->list[d.seq].qcf))),
    bill_code_desc = substring(1,1000,ndcs->list[d.seq].bill_code_desc), secondary_ndc = substring(1,
     1000,ndcs->list[d.seq].secondary_ndc), ndc_number = ndcs->list[d.seq].ndc_seq,
    secondary_bill_item_description = substring(1,1000,ndcs->list[d.seq].secondary_bill_desc),
    last_person_to_updt = substring(1,1000,ndcs->list[d.seq].updt_person), last_updt_dt_tm = format(
     ndcs->list[d.seq].updt_dt_tm,";;q"),
    item_id = ndcs->list[d.seq].item_id, primary_bill_item_id = ndcs->list[d.seq].
    primary_bill_item_id, secondary_bill_item_id = ndcs->list[d.seq].secondary_bill_item_id
    FROM (dummyt d  WITH seq = value(size(ndcs->list,5)))
    PLAN (d)
    WITH format = stream, pcformat('"',delim,1), format
   ;end select
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
 IF (status="S")
  COMMIT
 ELSE
  ROLLBACK
  SET subjstr = build2("ERROR ",cnvtupper(clientstr)," ",trim(curdomain),
   ": Copy NDC Billing Info ops job failure")
  SET emailbody = build2(statusstr)
  SET stat = emailfile(ams_email,ams_email,subjstr,emailbody,output_report)
 ENDIF
 CALL echo(reply->ops_event)
 SET last_mod = "001"
END GO
