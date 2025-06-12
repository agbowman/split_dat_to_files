CREATE PROGRAM ams_mltm_weekly_load:dba
 PROMPT
  "Enter name of the file that contains the new NDCs:" = "ams_mltm_weekly_ndcs.csv"
  WITH file
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
 DECLARE readfile(filename=vc) = i2 WITH protect
 DECLARE performupdates(null) = i2 WITH protect
 DECLARE createoutputreport(null) = null WITH protect
 DECLARE cleanupmltmordercatalogload(null) = i2 WITH protect
 DECLARE clientstr = vc WITH protect, constant(getclient(null))
 DECLARE delim = vc WITH protect, constant(",")
 DECLARE file_name = vc WITH protect, constant(trim( $FILE))
 DECLARE local_dir = vc WITH protect, constant(trim(logical("CCLUSERDIR")))
 DECLARE output_report = vc WITH protect, constant(concat("ams_weekly_ndcs_",cnvtlower(format(
     cnvtdatetime(curdate,curtime3),"dd_mmm_yyyy;;q")),".csv"))
 DECLARE cfrom = c31 WITH protect, constant("ams_mltm_weekly_load@cerner.com")
 DECLARE vcsubject = vc WITH protect, constant(build2("Weekly NDC Load Report ",clientstr,": ",
   curdomain))
 DECLARE prog_name = c20 WITH protect, constant("AMS_MLTM_WEEKLY_LOAD")
 DECLARE add = i4 WITH protect, noconstant(0)
 DECLARE unavailable = i4 WITH protect, noconstant(1)
 DECLARE ndc_exists = i4 WITH protect, noconstant(2)
 DECLARE sendemailind = i2 WITH protect
 DECLARE emailbody = vc WITH protect, noconstant("Weekly NDC report attached.")
 RECORD br_request(
   1 import_method_flag = i2
   1 list_0[*]
     2 status = i4
     2 ndc_code = vc
     2 brand_description = vc
     2 brand_description_id = i4
     2 primary_description = vc
     2 generic_description = vc
     2 generic_description_id = i4
     2 trade_description = vc
     2 trade_description_id = i4
     2 main_multum_drug_code = i4
     2 dose_form_description = vc
     2 dose_form_id = i4
     2 inner_package_size = f8
     2 inner_package_description = vc
     2 inner_package_code = i4
     2 outer_package_size = f8
     2 source_desc = vc
     2 source_id = i4
     2 awp = f8
     2 product_strength_code = i4
     2 csa = i4
     2 brand_function_id = i4
     2 brand_description_oef = vc
     2 brand_id_rxmask = i4
     2 primary_description_id = i4
     2 primary_description_oef = vc
     2 primary_id_rxmask = i4
     2 generic_description_oef = vc
     2 generic_id_rxmask = i4
     2 trade_description_oef = vc
     2 trade_id_rxmask = i4
     2 gbo = vc
 ) WITH protect
 SET trace = nocallecho
 EXECUTE ams_define_toolkit_common
 SET trace = callecho
 IF (validate(request->batch_selection,"-1")="-1")
  IF ( NOT (validate(reply,0)))
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
  ENDIF
 ELSE
  IF ((request->output_dist > " "))
   SET sendemailind = 1
  ENDIF
 ENDIF
 SET statusstr = "Error executing script"
 SET reply->status_data.status = "F"
 SET reply->ops_event = statusstr
 IF (file_name=null)
  SET statusstr = "Error: You must specify the filename"
  SET reply->status_data.status = "F"
  GO TO exit_script
 ELSE
  SET stat = findfile(file_name)
  IF (stat != 1)
   SET statusstr = build2("Error: ",file_name," not found")
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
 ENDIF
 IF (readfile(file_name))
  IF (performupdates(null))
   IF (cleanupmltmordercatalogload(null))
    SET trace = nocallecho
    CALL updtdminfo(prog_name,1.0)
    SET trace = callecho
    SET reply->status_data.status = "S"
    SET statusstr = "Successfully loaded new NDCs"
   ELSE
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
  ELSE
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SUBROUTINE cleanupmltmordercatalogload(null)
   DECLARE cnt = i4 WITH protect
   RECORD syns(
     1 list[*]
       2 synonym_cki = vc
       2 catalog_cki = vc
   ) WITH protect
   SELECT INTO "nl:"
    mocl.synonym_cki, mocl.catalog_cki
    FROM mltm_order_catalog_load mocl
    PLAN (mocl
     WHERE ((mocl.rx_mask_nbr=0) OR (mocl.order_entry_format=" ")) )
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1)
     IF (mod(cnt,100)=1)
      stat = alterlist(syns->list,(cnt+ 99))
     ENDIF
     syns->list[cnt].catalog_cki = mocl.catalog_cki, syns->list[cnt].synonym_cki = mocl.synonym_cki
    FOOT REPORT
     IF (mod(cnt,100) != 0)
      stat = alterlist(syns->list,cnt)
     ENDIF
    WITH nocounter
   ;end select
   IF (debug_ind=1)
    CALL echo("syns record after being populated by cleanupMltmOrderCatalogLoad():")
    CALL echorecord(syns)
   ENDIF
   IF (size(syns->list,5) > 0)
    DELETE  FROM mltm_order_catalog_load mocl,
      (dummyt d  WITH seq = size(syns->list,5))
     SET mocl.seq = 0
     PLAN (d)
      JOIN (mocl
      WHERE (mocl.synonym_cki=syns->list[d.seq].synonym_cki)
       AND (mocl.catalog_cki=syns->list[d.seq].catalog_cki))
     WITH nocounter
    ;end delete
   ENDIF
   IF (curqual=size(syns->list,5))
    COMMIT
    RETURN(1)
   ELSE
    ROLLBACK
    SET statusstr = "Error removing newly created synonyms from mltm_order_catalog_load"
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE createoutputreport(null)
   DECLARE status_add = vc WITH protect, constant("Add")
   DECLARE status_unavail = vc WITH protect, constant("Unavailable")
   DECLARE status_exist = vc WITH protect, constant("Existing")
   DECLARE status_unavail_iv = vc WITH protect, constant("Unavailable - Product is an IV solution")
   DECLARE status_unavail_primary = vc WITH protect, constant(
    "Unavailable - Product's primary does not exist")
   SELECT INTO "nl:"
    mdnm.drug_identifier
    FROM mltm_drug_name_map mdnm,
     (dummyt d  WITH seq = value(size(br_request->list_0,5)))
    PLAN (d
     WHERE (br_request->list_0[d.seq].status=unavailable))
     JOIN (mdnm
     WHERE mdnm.drug_identifier IN ("d04128", "d04129", "d04130", "d04131", "d04132")
      AND (mdnm.drug_synonym_id=br_request->list_0[d.seq].primary_description_id))
    DETAIL
     br_reply->list_0[d.seq].status = 3
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM mltm_drug_name mdn,
     mltm_drug_name_map mdnm,
     (dummyt d  WITH seq = size(br_request->list_0,5)),
     dummyt d2
    PLAN (d
     WHERE (br_request->list_0[d.seq].status=unavailable))
     JOIN (d2)
     JOIN (mdn
     WHERE (br_request->list_0[d.seq].primary_description=mdn.drug_name))
     JOIN (mdnm
     WHERE mdn.drug_synonym_id=mdnm.drug_synonym_id
      AND mdnm.function_id=16)
    DETAIL
     br_reply->list_0[d.seq].status = 4
    WITH outerjoin = d2, dontexist
   ;end select
   SET stat = remove("ams_weekly_ndcs_*.csv")
   SELECT INTO value(output_report)
    status = evaluate(br_reply->list_0[d.seq].status,0,status_add,1,status_unavail,
     2,status_exist,3,status_unavail_iv,4,
     status_unavail_primary), ndc = format(br_request->list_0[d.seq].ndc_code,"#####-####-##"),
    brand_description = substring(1,200,br_request->list_0[d.seq].brand_description),
    primary_description = substring(1,200,br_request->list_0[d.seq].primary_description),
    generic_description = substring(1,200,br_request->list_0[d.seq].generic_description),
    trade_description = substring(1,200,br_request->list_0[d.seq].trade_description),
    dose_form_desc = substring(1,200,br_request->list_0[d.seq].dose_form_description), inner_pack_sz
     = br_request->list_0[d.seq].inner_package_size, inner_pack_desc = substring(1,200,br_request->
     list_0[d.seq].inner_package_description),
    outer_pack_sz = br_request->list_0[d.seq].outer_package_size, source_desc = substring(1,200,
     br_request->list_0[d.seq].source_desc), awp = br_request->list_0[d.seq].awp,
    csa = br_request->list_0[d.seq].csa, mmdc = br_request->list_0[d.seq].main_multum_drug_code,
    brand_desc_id = br_request->list_0[d.seq].brand_description_id,
    generic_desc_id = br_request->list_0[d.seq].generic_description_id, trade_desc_id = br_request->
    list_0[d.seq].trade_description_id
    FROM (dummyt d  WITH seq = size(br_request->list_0,5))
    PLAN (d)
    WITH format = stream, pcformat('"',delim,1), format
   ;end select
   IF (sendemailind=1)
    CALL emailfile(trim(request->output_dist),cfrom,vcsubject,emailbody,output_report)
   ENDIF
 END ;Subroutine
 SUBROUTINE performupdates(null)
   IF (debug_ind=1)
    CALL echo("Beginning mltm_br_weekly_load...")
   ENDIF
   SET trace = recpersist
   EXECUTE mltm_br_weekly_load  WITH replace("REQUEST",br_request), replace("REPLY",br_reply)
   SET trace = norecpersist
   IF (debug_ind=1)
    CALL echo("End of mltm_br_weekly_load")
    CALL echo("br_reply record : ")
    CALL echorecord(br_reply)
   ENDIF
   IF ((br_reply->status_data.status="S"))
    CALL createoutputreport(null)
    RETURN(1)
   ELSE
    SET statusstr = "Failed executing mltm_br_weekly_load"
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE readfile(filename)
   DECLARE ndc_pos = i2 WITH protect, constant(4)
   DECLARE brand_desc_pos = i2 WITH protect, constant(5)
   DECLARE brand_desc_id_pos = i2 WITH protect, constant(6)
   DECLARE brand_func_id_pos = i2 WITH protect, constant(7)
   DECLARE primary_desc_pos = i2 WITH protect, constant(8)
   DECLARE generic_desc_pos = i2 WITH protect, constant(10)
   DECLARE generic_desc_id_pos = i2 WITH protect, constant(11)
   DECLARE trade_desc_pos = i2 WITH protect, constant(12)
   DECLARE trade_desc_id_pos = i2 WITH protect, constant(13)
   DECLARE mmdc_pos = i2 WITH protect, constant(14)
   DECLARE dose_form_desc_pos = i2 WITH protect, constant(15)
   DECLARE dose_form_id_pos = i2 WITH protect, constant(16)
   DECLARE inner_pack_sz_pos = i2 WITH protect, constant(17)
   DECLARE inner_pack_desc_pos = i2 WITH protect, constant(18)
   DECLARE inner_pack_code_pos = i2 WITH protect, constant(19)
   DECLARE outer_pack_sz_pos = i2 WITH protect, constant(20)
   DECLARE source_desc_pos = i2 WITH protect, constant(21)
   DECLARE source_id_pos = i2 WITH protect, constant(22)
   DECLARE awp_pos = i2 WITH protect, constant(23)
   DECLARE product_stren_code_pos = i2 WITH protect, constant(24)
   DECLARE csa_pos = i2 WITH protect, constant(25)
   DECLARE brand_desc_oef_pos = i2 WITH protect, constant(29)
   DECLARE brand_id_rxmask_pos = i2 WITH protect, constant(30)
   DECLARE primary_desc_id_pos = i2 WITH protect, constant(9)
   DECLARE primary_desc_oef_pos = i2 WITH protect, constant(27)
   DECLARE primary_id_rxmask_pos = i2 WITH protect, constant(28)
   DECLARE generic_desc_oef_pos = i2 WITH protect, constant(31)
   DECLARE generic_id_rxmask_pos = i2 WITH protect, constant(32)
   DECLARE trade_desc_oef_pos = i2 WITH protect, constant(33)
   DECLARE trade_id_rxmask_pos = i2 WITH protect, constant(34)
   DECLARE gbo_pos = i2 WITH protect, constant(26)
   DECLARE str = vc WITH protect
   DECLARE notfnd = vc WITH protect, constant("<not_found>")
   DECLARE piecenum = i4 WITH protect
   DECLARE cnt = i4 WITH protect
   FREE DEFINE rtl2
   DEFINE rtl2 filename
   SELECT INTO "nl:"
    r.line
    FROM rtl2t r
    HEAD REPORT
     cnt = 0
    DETAIL
     IF (cnvtreal(piece(r.line,delim,ndc_pos,notfnd,3)) > 0.0)
      cnt = (cnt+ 1)
      IF (mod(cnt,100)=1)
       stat = alterlist(br_request->list_0,(cnt+ 99))
      ENDIF
      piecenum = 1, str = "", br_request->import_method_flag = 1,
      br_request->list_0[cnt].status = add
      WHILE (str != notfnd)
        str = piece(r.line,delim,piecenum,notfnd,3)
        CASE (piecenum)
         OF ndc_pos:
          IF (textlen(str) < 11)
           WHILE (textlen(str) != 11)
             str = concat("0",str)
           ENDWHILE
          ENDIF
          ,br_request->list_0[cnt].ndc_code = str
         OF brand_desc_pos:
          br_request->list_0[cnt].brand_description = str
         OF brand_desc_id_pos:
          br_request->list_0[cnt].brand_description_id = cnvtint(str)
         OF primary_desc_pos:
          br_request->list_0[cnt].primary_description = str
         OF generic_desc_pos:
          br_request->list_0[cnt].generic_description = str
         OF generic_desc_id_pos:
          br_request->list_0[cnt].generic_description_id = cnvtint(str)
         OF trade_desc_pos:
          br_request->list_0[cnt].trade_description = str
         OF trade_desc_id_pos:
          br_request->list_0[cnt].trade_description_id = cnvtint(str)
         OF mmdc_pos:
          br_request->list_0[cnt].main_multum_drug_code = cnvtint(str)
         OF dose_form_desc_pos:
          br_request->list_0[cnt].dose_form_description = str
         OF dose_form_id_pos:
          br_request->list_0[cnt].dose_form_id = cnvtint(str)
         OF inner_pack_sz_pos:
          br_request->list_0[cnt].inner_package_size = cnvtreal(str)
         OF inner_pack_desc_pos:
          br_request->list_0[cnt].inner_package_description = str
         OF inner_pack_code_pos:
          br_request->list_0[cnt].inner_package_code = cnvtint(str)
         OF outer_pack_sz_pos:
          br_request->list_0[cnt].outer_package_size = cnvtreal(str)
         OF source_desc_pos:
          br_request->list_0[cnt].source_desc = str
         OF source_id_pos:
          br_request->list_0[cnt].source_id = cnvtint(str)
         OF awp_pos:
          br_request->list_0[cnt].awp = cnvtreal(str)
         OF product_stren_code_pos:
          br_request->list_0[cnt].product_strength_code = cnvtint(str)
         OF csa_pos:
          br_request->list_0[cnt].csa = cnvtint(str)
         OF brand_func_id_pos:
          br_request->list_0[cnt].brand_function_id = cnvtint(str)
         OF brand_desc_oef_pos:
          br_request->list_0[cnt].brand_description_oef = str
         OF brand_id_rxmask_pos:
          br_request->list_0[cnt].brand_id_rxmask = cnvtint(str)
         OF primary_desc_id_pos:
          br_request->list_0[cnt].primary_description_id = cnvtint(str)
         OF primary_desc_oef_pos:
          br_request->list_0[cnt].primary_description_oef = str
         OF primary_id_rxmask_pos:
          br_request->list_0[cnt].primary_id_rxmask = cnvtint(str)
         OF generic_desc_oef_pos:
          br_request->list_0[cnt].generic_description_oef = str
         OF generic_id_rxmask_pos:
          br_request->list_0[cnt].generic_id_rxmask = cnvtint(str)
         OF trade_desc_oef_pos:
          br_request->list_0[cnt].trade_description_oef = str
         OF trade_id_rxmask_pos:
          br_request->list_0[cnt].trade_id_rxmask = cnvtint(str)
         OF gbo_pos:
          br_request->list_0[cnt].gbo = str
        ENDCASE
        piecenum = (piecenum+ 1)
      ENDWHILE
     ENDIF
    FOOT REPORT
     IF (mod(cnt,100) != 0)
      stat = alterlist(br_request->list_0,cnt)
     ENDIF
    WITH nocounter
   ;end select
   IF (debug_ind=1)
    CALL echo("br_request record after being populated by readFile():")
    CALL echorecord(br_request)
   ENDIF
   IF (cnt > 0)
    RETURN(1)
   ELSE
    SET statusstr = "No NDCs were found in file"
    RETURN(0)
   ENDIF
 END ;Subroutine
#exit_script
 SET reply->ops_event = statusstr
 IF (debug_ind=1)
  CALL echo(build2("Status = ",reply->status_data.status))
  CALL echo(reply->ops_event)
 ENDIF
 SET last_mod = "005"
END GO
