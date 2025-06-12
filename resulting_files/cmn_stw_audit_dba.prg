CREATE PROGRAM cmn_stw_audit:dba
 PROMPT
  'outdev ["MINE"]:   ' = "MINE",
  "category meaning [*]:   " = "*",
  "match mode ((R)egular Expression), (E)xact, (P)atstring)  [R]:   " = "R",
  "logcial domain id (-1 for all) [-1]:   " = - (1.0),
  "output format (HTML JSON, CSV, RAWCSV, REC, RAWREC) [HTML]:   " = "HTML"
  WITH outdev, categorymean, matchmode,
  logicaldomainid, outputformat
 IF ( NOT (validate(cmn_string_utils_imported)))
  EXECUTE cmn_string_utils
 ENDIF
 DECLARE PUBLIC::errorcheck(replystructure=vc(ref),operation=vc) = null
 SUBROUTINE PUBLIC::errorcheck(replystructure,operation)
   DECLARE errormsg = c255 WITH protect, noconstant("")
   DECLARE errorcode = i4 WITH protect, noconstant(0)
   SET errorcode = error(errormsg,0)
   IF (errorcode != 0)
    WHILE (errorcode != 0)
      SET replystructure->status_data.subeventstatus[1].operationname = operation
      SET replystructure->status_data.subeventstatus[1].targetobjectname = cnvtstring(errorcode,10)
      SET replystructure->status_data.subeventstatus[1].targetobjectvalue = errormsg
      SET replystructure->status_data.status = "F"
      IF ((reqdata->loglevel >= 4))
       CALL echo(errormsg)
      ENDIF
      SET errorcode = error(errormsg,0)
    ENDWHILE
    GO TO exit_script
   ENDIF
 END ;Subroutine
 RECORD brdatabyld(
   1 ld[*]
     2 mnemonic = vc
     2 id = f8
     2 tpl[*]
       3 name = vc
       3 mean = vc
       3 id = f8
       3 rpt[*]
         4 name = vc
         4 mean = vc
         4 id = f8
         4 filter[*]
           5 display = vc
           5 mean = vc
           5 id = f8
           5 category_mean = vc
           5 seq = i4
           5 value[*]
             6 id = f8
             6 freetext_desc = vc
             6 mpage_param_value = vc
             6 value_type_flag = i2
             6 parent_entity_name = vc
             6 parent_entity_id = f8
             6 parent_entity_display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 RECORD brdatabytemplate(
   1 tpl[*]
     2 name = vc
     2 mean = vc
     2 id = f8
     2 ld[*]
       3 mnemonic = vc
       3 id = f8
       3 rpt[*]
         4 name = vc
         4 mean = vc
         4 id = f8
         4 filter[*]
           5 display = vc
           5 mean = vc
           5 id = f8
           5 category_mean = vc
           5 seq = i4
           5 value[*]
             6 id = f8
             6 freetext_desc = vc
             6 mpage_param_value = vc
             6 value_type_flag = i2
             6 parent_entity_name = vc
             6 parent_entity_id = f8
             6 parent_entity_display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE PUBLIC::main(null) = null WITH protect
 DECLARE PUBLIC::retrievedata(matchstring=vc,matchmode=vc,brdata=vc(ref),generatecsvdata=i2,csvdata=
  vc(ref)) = null WITH protect
 DECLARE PUBLIC::reorganizedata(null) = null WITH protect
 DECLARE PUBLIC::getyesnodisplay(rawvalue=vc) = vc WITH protect
 DECLARE PUBLIC::generatefreetextoptiondisplay(filtermean=vc,valuefreetext=vc) = vc WITH protect
 DECLARE PUBLIC::generatetidyvaluedisplay(filtermean=vc,valuefreetext=vc,mpageparamvalue=vc,
  valuetypeflag=i2,pen=vc,
  pei=f8,ped=vc) = vc WITH protect
 DECLARE PUBLIC::generatevaluedisplay(filtermean=vc,valuefreetext=vc,mpageparamvalue=vc,valuetypeflag
  =i2,pen=vc,
  pei=f8,ped=vc) = vc WITH protect
 DECLARE PUBLIC::generaterawcsvrow(templatename=vc,templateid=vc,ld=vc,componentname=vc,filtername=vc,
  filterid=vc,val=vc) = vc WITH protect
 DECLARE PUBLIC::generatehtml(null) = vc WITH protect
 DECLARE PUBLIC::generatecsv(null) = vc WITH protect
 DECLARE csvdata = vc WITH protect, noconstant("")
 SUBROUTINE PUBLIC::retrievedata(matchstring,matchmode,brdata,generatecsvdata,csvdata)
   DECLARE valuedisplay = vc WITH protect, noconstant("")
   DECLARE rowdisplay = vc WITH protect, noconstant("")
   DECLARE operatorstring = vc WITH protect, noconstant("")
   DECLARE sep = vc WITH protect, noconstant("")
   SET sep = char(9)
   DECLARE outdev = vc WITH protect, noconstant("nl:")
   DECLARE layout_flag_smart_template = i4 WITH protect, constant(2)
   DECLARE crlf = vc WITH protect, noconstant("")
   SET crlf = concat(char(10),char(13))
   IF (generatecsvdata=true)
    SET outdev = value( $OUTDEV)
    SET rowdisplay = generaterawcsvrow("TEMPLATE ID","SETTING ID","LOGICAL DOMAIN","TEMPLATE NAME",
     "COMPONENT",
     "SETTING NAME","SETTING VALUE")
   ENDIF
   CASE (cnvtupper(matchmode))
    OF "P":
     SET matchstring = patstring(matchstring,1)
     SET operatorstring = "LIKE"
    OF "E":
     SET operatorstring = "="
    ELSE
     SET operatorstring = "REGXPLIKE"
   ENDCASE
   SELECT INTO value(outdev)
    cat_name_upper = cnvtupper(c.category_name), ld_mnemonic_upper = cnvtupper(ld.mnemonic),
    ld_mnemonic =
    IF (ld.logical_domain_id > 0.0) ld.mnemonic
    ELSE "(default)"
    ENDIF
    ,
    ped =
    IF (v.parent_entity_name="CODE_VALUE") uar_get_code_display(v.parent_entity_id)
    ELSEIF (v.parent_entity_name="ORDER_CATALOG_SYNONYM") ocs.mnemonic
    ELSE ""
    ENDIF
    FROM br_datamart_category c,
     br_datamart_report r,
     br_datamart_report_filter_r rfr,
     br_datamart_filter f,
     br_datamart_value v,
     (left JOIN order_catalog_synonym ocs ON v.parent_entity_id=ocs.synonym_id
      AND v.parent_entity_name="ORDER_CATALOG_SYNONYM"),
     br_datamart_value vr,
     logical_domain ld
    WHERE c.layout_flag=layout_flag_smart_template
     AND operator(c.category_mean,operatorstring,matchstring)
     AND r.br_datamart_category_id=c.br_datamart_category_id
     AND rfr.br_datamart_report_id=r.br_datamart_report_id
     AND rfr.br_datamart_filter_id=f.br_datamart_filter_id
     AND vr.br_datamart_category_id=c.br_datamart_category_id
     AND vr.parent_entity_name="BR_DATAMART_REPORT"
     AND vr.parent_entity_id=r.br_datamart_report_id
     AND ((vr.mpage_param_mean = null) OR (vr.mpage_param_mean != "mp_vb_component_status"))
     AND vr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND vr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND v.br_datamart_filter_id=f.br_datamart_filter_id
     AND v.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND v.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND v.logical_domain_id=vr.logical_domain_id
     AND ld.logical_domain_id=v.logical_domain_id
     AND (ld.logical_domain_id=
    IF (( $LOGICALDOMAINID < 0.0)) ld.logical_domain_id
    ELSE  $LOGICALDOMAINID
    ENDIF
    )
    ORDER BY ld_mnemonic_upper, ld.logical_domain_id, cat_name_upper,
     c.br_datamart_category_id, cnvtint(vr.value_seq), r.br_datamart_report_id,
     f.filter_seq, f.br_datamart_filter_id, cnvtint(v.value_seq),
     v.br_datamart_value_id
    HEAD REPORT
     ldcnt = 0, tplcnt = 0, rptcnt = 0,
     fltcnt = 0, valcnt = 0
     IF (generatecsvdata=true)
      csvdata = build(rowdisplay,crlf), rowdisplay, row + 1
     ENDIF
    HEAD ld.logical_domain_id
     tplcnt = 0, rptcnt = 0, fltcnt = 0,
     valcnt = 0, ldcnt = (ldcnt+ 1), stat = alterlist(brdata->ld,ldcnt),
     brdata->ld[ldcnt].id = v.logical_domain_id, brdata->ld[ldcnt].mnemonic = ld_mnemonic
    HEAD c.br_datamart_category_id
     rptcnt = 0, fltcnt = 0, valcnt = 0,
     tplcnt = (tplcnt+ 1), stat = alterlist(brdata->ld[ldcnt].tpl,tplcnt), brdata->ld[ldcnt].tpl[
     tplcnt].id = c.br_datamart_category_id,
     brdata->ld[ldcnt].tpl[tplcnt].mean = c.category_mean, brdata->ld[ldcnt].tpl[tplcnt].name = c
     .category_name
    HEAD r.br_datamart_report_id
     fltcnt = 0, valcnt = 0, rptcnt = (rptcnt+ 1),
     stat = alterlist(brdata->ld[ldcnt].tpl[tplcnt].rpt,rptcnt), brdata->ld[ldcnt].tpl[tplcnt].rpt[
     rptcnt].id = r.br_datamart_report_id, brdata->ld[ldcnt].tpl[tplcnt].rpt[rptcnt].mean = r
     .report_mean,
     brdata->ld[ldcnt].tpl[tplcnt].rpt[rptcnt].name = r.report_name
    HEAD f.br_datamart_filter_id
     valcnt = 0, fltcnt = (fltcnt+ 1), stat = alterlist(brdata->ld[ldcnt].tpl[tplcnt].rpt[rptcnt].
      filter,fltcnt),
     brdata->ld[ldcnt].tpl[tplcnt].rpt[rptcnt].filter[fltcnt].id = f.br_datamart_filter_id, brdata->
     ld[ldcnt].tpl[tplcnt].rpt[rptcnt].filter[fltcnt].mean = f.filter_mean, brdata->ld[ldcnt].tpl[
     tplcnt].rpt[rptcnt].filter[fltcnt].display = f.filter_display,
     brdata->ld[ldcnt].tpl[tplcnt].rpt[rptcnt].filter[fltcnt].category_mean = f.filter_category_mean,
     brdata->ld[ldcnt].tpl[tplcnt].rpt[rptcnt].filter[fltcnt].seq = f.filter_seq
    HEAD v.br_datamart_value_id
     valcnt = (valcnt+ 1), stat = alterlist(brdata->ld[ldcnt].tpl[tplcnt].rpt[rptcnt].filter[fltcnt].
      value,valcnt), brdata->ld[ldcnt].tpl[tplcnt].rpt[rptcnt].filter[fltcnt].value[valcnt].id = v
     .br_datamart_value_id,
     brdata->ld[ldcnt].tpl[tplcnt].rpt[rptcnt].filter[fltcnt].value[valcnt].freetext_desc = v
     .freetext_desc, brdata->ld[ldcnt].tpl[tplcnt].rpt[rptcnt].filter[fltcnt].value[valcnt].
     mpage_param_value = v.mpage_param_value, brdata->ld[ldcnt].tpl[tplcnt].rpt[rptcnt].filter[fltcnt
     ].value[valcnt].value_type_flag = v.value_type_flag,
     brdata->ld[ldcnt].tpl[tplcnt].rpt[rptcnt].filter[fltcnt].value[valcnt].parent_entity_name = v
     .parent_entity_name, brdata->ld[ldcnt].tpl[tplcnt].rpt[rptcnt].filter[fltcnt].value[valcnt].
     parent_entity_id = v.parent_entity_id, brdata->ld[ldcnt].tpl[tplcnt].rpt[rptcnt].filter[fltcnt].
     value[valcnt].parent_entity_display = ped
    DETAIL
     IF (generatecsvdata=true)
      valuedisplay = generatetidyvaluedisplay(f.filter_mean,v.freetext_desc,v.mpage_param_value,v
       .value_type_flag,v.parent_entity_name,
       v.parent_entity_id,ped), rowdisplay = generaterawcsvrow(c.category_mean,f.filter_mean,
       ld_mnemonic,c.category_name,r.report_name,
       f.filter_display,valuedisplay), csvdata = build(csvdata,rowdisplay,crlf),
      rowdisplay, row + 1
     ENDIF
    WITH nocounter, maxcol = 3000, format = variable,
     formfeed = none
   ;end select
   CALL errorcheck(brdata,"retrieveData")
 END ;Subroutine
 SUBROUTINE PUBLIC::reorganizedata(null)
   SET stat = moverec(brdatabyld->status_data,brdatabytemplate->status_data)
   IF (size(brdatabyld->ld,5)=0)
    RETURN(null)
   ENDIF
   SELECT INTO "nl:"
    templatename = substring(1,100,brdatabyld->ld[d_ld.seq].tpl[d_tpl.seq].name), domainname =
    substring(1,100,brdatabyld->ld[d_ld.seq].mnemonic), templatenameupper = cnvtupper(substring(1,100,
      brdatabyld->ld[d_ld.seq].tpl[d_tpl.seq].name)),
    domainnameupper = cnvtupper(substring(1,100,brdatabyld->ld[d_ld.seq].mnemonic))
    FROM (dummyt d_ld  WITH seq = size(brdatabyld->ld,5)),
     (dummyt d_tpl  WITH seq = 1)
    PLAN (d_ld
     WHERE maxrec(d_tpl,size(brdatabyld->ld[d_ld.seq].tpl,5)))
     JOIN (d_tpl)
    ORDER BY templatenameupper, domainnameupper
    HEAD REPORT
     tplcnt = 0, ldcnt = 0, rptidx = 0,
     fltidx = 0, validx = 0
    HEAD templatename
     ldcnt = 0, tplcnt = (tplcnt+ 1), stat = alterlist(brdatabytemplate->tpl,tplcnt),
     brdatabytemplate->tpl[tplcnt].name = templatename, brdatabytemplate->tpl[tplcnt].mean =
     substring(1,30,brdatabyld->ld[d_ld.seq].tpl[d_tpl.seq].mean), brdatabytemplate->tpl[tplcnt].id
      = brdatabyld->ld[d_ld.seq].tpl[d_tpl.seq].id
    DETAIL
     ldcnt = (ldcnt+ 1), stat = alterlist(brdatabytemplate->tpl[tplcnt].ld,ldcnt), brdatabytemplate->
     tpl[tplcnt].ld[ldcnt].mnemonic = domainname,
     brdatabytemplate->tpl[tplcnt].ld[ldcnt].id = brdatabyld->ld[d_ld.seq].id
     FOR (rptidx = 1 TO size(brdatabyld->ld[d_ld.seq].tpl[d_tpl.seq].rpt,5))
       stat = alterlist(brdatabytemplate->tpl[tplcnt].ld[ldcnt].rpt,rptidx), brdatabytemplate->tpl[
       tplcnt].ld[ldcnt].rpt[rptidx].name = substring(1,200,brdatabyld->ld[d_ld.seq].tpl[d_tpl.seq].
        rpt[rptidx].name), brdatabytemplate->tpl[tplcnt].ld[ldcnt].rpt[rptidx].mean = substring(1,30,
        brdatabyld->ld[d_ld.seq].tpl[d_tpl.seq].rpt[rptidx].mean),
       brdatabytemplate->tpl[tplcnt].ld[ldcnt].rpt[rptidx].id = brdatabyld->ld[d_ld.seq].tpl[d_tpl
       .seq].rpt[rptidx].id
       FOR (fltidx = 1 TO size(brdatabyld->ld[d_ld.seq].tpl[d_tpl.seq].rpt[rptidx].filter,5))
         stat = alterlist(brdatabytemplate->tpl[tplcnt].ld[ldcnt].rpt[rptidx].filter,fltidx),
         brdatabytemplate->tpl[tplcnt].ld[ldcnt].rpt[rptidx].filter[fltidx].display = substring(1,100,
          brdatabyld->ld[d_ld.seq].tpl[d_tpl.seq].rpt[rptidx].filter[fltidx].display),
         brdatabytemplate->tpl[tplcnt].ld[ldcnt].rpt[rptidx].filter[fltidx].mean = substring(1,30,
          brdatabyld->ld[d_ld.seq].tpl[d_tpl.seq].rpt[rptidx].filter[fltidx].mean),
         brdatabytemplate->tpl[tplcnt].ld[ldcnt].rpt[rptidx].filter[fltidx].id = brdatabyld->ld[d_ld
         .seq].tpl[d_tpl.seq].rpt[rptidx].filter[fltidx].id
         FOR (validx = 1 TO size(brdatabyld->ld[d_ld.seq].tpl[d_tpl.seq].rpt[rptidx].filter[fltidx].
          value,5))
           stat = alterlist(brdatabytemplate->tpl[tplcnt].ld[ldcnt].rpt[rptidx].filter[fltidx].value,
            validx), brdatabytemplate->tpl[tplcnt].ld[ldcnt].rpt[rptidx].filter[fltidx].value[validx]
           .id = brdatabyld->ld[d_ld.seq].tpl[d_tpl.seq].rpt[rptidx].filter[fltidx].value[validx].id,
           brdatabytemplate->tpl[tplcnt].ld[ldcnt].rpt[rptidx].filter[fltidx].value[validx].
           freetext_desc = substring(1,255,brdatabyld->ld[d_ld.seq].tpl[d_tpl.seq].rpt[rptidx].
            filter[fltidx].value[validx].freetext_desc),
           brdatabytemplate->tpl[tplcnt].ld[ldcnt].rpt[rptidx].filter[fltidx].value[validx].
           mpage_param_value = substring(1,255,brdatabyld->ld[d_ld.seq].tpl[d_tpl.seq].rpt[rptidx].
            filter[fltidx].value[validx].mpage_param_value), brdatabytemplate->tpl[tplcnt].ld[ldcnt].
           rpt[rptidx].filter[fltidx].value[validx].value_type_flag = brdatabyld->ld[d_ld.seq].tpl[
           d_tpl.seq].rpt[rptidx].filter[fltidx].value[validx].value_type_flag, brdatabytemplate->
           tpl[tplcnt].ld[ldcnt].rpt[rptidx].filter[fltidx].value[validx].parent_entity_name =
           substring(1,50,brdatabyld->ld[d_ld.seq].tpl[d_tpl.seq].rpt[rptidx].filter[fltidx].value[
            validx].parent_entity_name),
           brdatabytemplate->tpl[tplcnt].ld[ldcnt].rpt[rptidx].filter[fltidx].value[validx].
           parent_entity_id = brdatabyld->ld[d_ld.seq].tpl[d_tpl.seq].rpt[rptidx].filter[fltidx].
           value[validx].parent_entity_id, brdatabytemplate->tpl[tplcnt].ld[ldcnt].rpt[rptidx].
           filter[fltidx].value[validx].parent_entity_display = substring(1,40,brdatabyld->ld[d_ld
            .seq].tpl[d_tpl.seq].rpt[rptidx].filter[fltidx].value[validx].parent_entity_display)
         ENDFOR
       ENDFOR
     ENDFOR
    WITH nocounter
   ;end select
   CALL errorcheck(brdatabytemplate,"reorganizeData")
 END ;Subroutine
 SUBROUTINE PUBLIC::getyesnodisplay(rawvalue)
  IF (rawvalue="1")
   RETURN("Yes")
  ENDIF
  RETURN("No")
 END ;Subroutine
 SUBROUTINE PUBLIC::generatefreetextoptiondisplay(filtermean,valuefreetext)
   DECLARE valsep = vc WITH protect, constant("|")
   DECLARE valuedisplay = vc WITH protect, noconstant("")
   DECLARE valuedescription = vc WITH protect, noconstant("")
   SET valuedisplay = trim(format(cnvtreal(valuefreetext),"##########;T(1)RP ;F"),3)
   CASE (filtermean)
    OF "SMART_CE_SORTING":
     CASE (valuedisplay)
      OF "1":
       SET valuedescription = "Alphabetical"
      OF "2":
       SET valuedescription = "Event Set Hierarchy"
     ENDCASE
    OF "SMART_DT_TM_FORMAT":
     CASE (valuedisplay)
      OF "1":
       SET valuedescription = "Date only"
      OF "2":
       SET valuedescription = "Date and Time"
      OF "3":
       SET valuedescription = "Time only"
      OF "4":
       SET valuedescription = "none"
     ENDCASE
    OF "SMART_REPORT_DT_TM_FORMAT":
     CASE (valuedisplay)
      OF "1":
       SET valuedescription = "short numeric"
      OF "2":
       SET valuedescription = "abbreviated"
      OF "3":
       SET valuedescription = "long"
     ENDCASE
    OF "SMART_ALLERGY_DISPLAY_FORMAT":
    OF "SMART_CE_DISPLAY_FORMAT":
     CASE (valuedisplay)
      OF "1":
       SET valuedescription = "grid with borders"
      OF "2":
       SET valuedescription = "grid without borders"
      OF "3":
       SET valuedescription = "horizontal list"
      OF "4":
       SET valuedescription = "vertical list"
     ENDCASE
    OF "SMART_DT_QUAL_OPT":
    OF "SMART_DT_DISPLAY_OPT":
     CASE (valuedisplay)
      OF "1":
       SET valuedescription = "clinsig_updt_dt_tm"
      OF "2":
       SET valuedescription = "event_end_dt_tm"
     ENDCASE
    OF "SMART_ALLERGY_SORT":
     CASE (valuedisplay)
      OF "1":
       SET valuedescription = "Alphabetical"
      OF "2":
       SET valuedescription = "Onset"
      OF "3":
       SET valuedescription = "Reverse Onset"
      OF "4":
       SET valuedescription = "Severity"
     ENDCASE
   ENDCASE
   IF (valuedescription != "")
    RETURN(concat(valuedisplay,valsep,valuedescription))
   ELSE
    RETURN(valuedisplay)
   ENDIF
 END ;Subroutine
 SUBROUTINE PUBLIC::generaterawcsvrow(templatename,templateid,ld,componentname,filtername,filterid,
  val)
   DECLARE sep = vc WITH protect, noconstant("")
   SET sep = char(9)
   RETURN(build2(trim(templatename,3),sep,trim(templateid,3),sep,trim(ld,3),
    sep,trim(componentname,3),sep,trim(filtername,3),sep,
    trim(filterid,3),sep,trim(val,3)))
 END ;Subroutine
 SUBROUTINE PUBLIC::generatetidyvaluedisplay(filtermean,valuefreetext,mpageparamvalue,valuetypeflag,
  pen,pei,ped)
   RETURN(generatevaluedisplay(trim(filtermean,3),trim(valuefreetext,3),trim(mpageparamvalue,3),
    valuetypeflag,trim(pen,3),
    pei,trim(ped,3)))
 END ;Subroutine
 SUBROUTINE PUBLIC::generatevaluedisplay(filtermean,valuefreetext,mpageparamvalue,valuetypeflag,pen,
  pei,ped)
   DECLARE valsep = vc WITH protect, constant("|")
   DECLARE ret = vc WITH protect, noconstant("")
   DECLARE strid = vc WITH protect, noconstant("")
   SET strid = trim(format(pei,"#########################;T(1)RP ;F"),3)
   CASE (filtermean)
    OF "SMART_REPORT_TIME_RANGE_OPT":
    OF "SMART_TM_RANGE_OPT":
    OF "SMART_NONMEDORD_TIME_RANGE_OPT":
     CASE (valuetypeflag)
      OF 2:
       SET ret = "Current Encounter"
      ELSE
       SET ret = "All Encounters"
     ENDCASE
     SET ret = concat(ret," - ",mpageparamvalue," ",ped)
    OF "SMART_IO_COUNTS":
    OF "SMART_REPORT_EVENT_SET":
    OF "SMART_NONMEDORD_SYNONYMS":
    OF "SMART_NONMEDORD_STATUS":
     IF (cmnisnotblank(valuefreetext))
      SET ret = build2(valuefreetext,valsep,strid)
     ELSE
      SET ret = build2(ped,valsep,strid)
     ENDIF
    OF "SMART_ALLERGY_DISPLAY_FORMAT":
    OF "SMART_ALLERGY_SORT":
    OF "SMART_CE_SORTING":
    OF "SMART_CE_DISPLAY_FORMAT":
    OF "SMART_DT_QUAL_OPT":
    OF "SMART_DT_DISPLAY_OPT":
    OF "SMART_DT_TM_FORMAT":
    OF "SMART_REPORT_DT_TM_FORMAT":
     SET ret = generatefreetextoptiondisplay(filtermean,valuefreetext)
    OF "SMART_ALLERGY_HEADER":
    OF "SMART_ALLERGY_COLUMN_OPT":
    OF "SMART_CE_HEADER":
    OF "SMART_CE_NO_RESULTS":
    OF "SMART_CE_TRENDING":
    OF "SMART_REPORT_HEADER":
    OF "SMART_REPORT_START_OPT":
    OF "SMART_REPORT_END_OPT":
    OF "SMART_IO_HEADER":
    OF "SMART_PROB_HEADER":
    OF "SMART_PROB_SELECT_IND":
    OF "SMART_PROB_DISPLAY_IND":
    OF "SMART_PROB_COLUMN_OPT":
    OF "SMART_PROB_SORT_IND":
    OF "SMART_NONMEDORD_HEADER":
     SET ret = valuefreetext
    OF "SMART_ALLERGY_ONSET_IND":
    OF "SMART_ALLERGY_REACTION_IND":
    OF "SMART_ALLERGY_SEVERITY_IND":
    OF "SMART_CE_NUMERIC_EVENT_TAG":
    OF "SMART_RESULT_RETRIEVE_IND":
    OF "SMART_ENC_RETRIEVE_IND":
    OF "SMART_REPORT_DATE_OPT":
    OF "SMART_REPORT_IN_PROGRESS_OPT":
    OF "SMART_REPORT_ORDER_BY_OPT":
    OF "SMART_REPORT_RESULT_IND":
    OF "SMART_REPORT_SIGNED_BY_OPT":
    OF "SMART_PROB_CLASS_IND":
    OF "SMART_PROB_COMMENT_IND":
    OF "SMART_PROB_ONSET_IND":
     SET ret = getyesnodisplay(valuefreetext)
    OF "SMART_REPORT_ENC_IND":
     SET ret = concat(getyesnodisplay(valuefreetext),"(deprectated with Administration.99)")
    ELSE
     IF (filtermean="SMART_CLIN_EVENT_*")
      IF (cmnisnotblank(valuefreetext))
       SET ret = build2(valuefreetext,valsep,strid)
      ELSE
       SET ret = build2(ped,valsep,strid)
      ENDIF
     ELSEIF (filtermean="SMART_EVENT_SET_*_HEADER")
      SET ret = valuefreetext
     ELSEIF (filtermean="SMART_EVENT_SET_*_COLUMN")
      SET ret = valuefreetext
     ELSE
      SET ret = build2("Unrecognized: ",filtermean,valsep,valuefreetext,valsep,
       mpageparamvalue,valsep,trim(cnvtstring(valuetypeflag),3),valsep,pen,
       valsep,strid)
     ENDIF
   ENDCASE
   RETURN(ret)
 END ;Subroutine
 SUBROUTINE PUBLIC::generatehtml(null)
   DECLARE tplidx = i4 WITH protect, noconstant(0)
   DECLARE ldidx = i4 WITH protect, noconstant(0)
   DECLARE rptidx = i4 WITH protect, noconstant(0)
   DECLARE fltidx = i4 WITH protect, noconstant(0)
   DECLARE validx = i4 WITH protect, noconstant(0)
   DECLARE templatenamelast = vc WITH protect, noconstant("")
   DECLARE domainnamelast = vc WITH protect, noconstant("")
   DECLARE rowclass = vc WITH protect, noconstant("even")
   DECLARE newtemplate = i2 WITH protect, noconstant(true)
   DECLARE sep = vc WITH protect, noconstant("")
   SET sep = char(9)
   DECLARE crlf = vc WITH protect, noconstant("")
   SET crlf = concat(char(10),char(13))
   DECLARE ret = vc WITH protect, noconstant("")
   SET ret = concat("<html>","<head>","<title>Smart Template Wizard Report</title>","<style>",
    "table,th,td{border:1px solid black;}",
    "td{padding-right: 10px}","tr.header{font-weight:bold;}","tr.even{background-color:aliceblue;}",
    "tr.odd{background-color:mistyrose;}","</style>",
    "</head>","<body>","<div>","<table>","<thead>",
    "<tr class='header'>","<td>Template ID</td>","<td>Setting ID</td>","<td>Logical Domain</td>",
    "<td>Template Name</td>",
    "<td>Component</td>","<td>Setting Name</td>","<td>Setting Value</td>","</tr>","</thead>",
    "<tbody>")
   FOR (tplidx = 1 TO size(brdatabytemplate->tpl,5))
     FOR (ldidx = 1 TO size(brdatabytemplate->tpl[tplidx].ld,5))
       FOR (rptidx = 1 TO size(brdatabytemplate->tpl[tplidx].ld[ldidx].rpt,5))
         FOR (fltidx = 1 TO size(brdatabytemplate->tpl[tplidx].ld[ldidx].rpt[rptidx].filter,5))
           FOR (validx = 1 TO size(brdatabytemplate->tpl[tplidx].ld[ldidx].rpt[rptidx].filter[fltidx]
            .value,5))
             SET newtemplate = false
             IF (templatenamelast != trim(brdatabytemplate->tpl[tplidx].name,3))
              SET newtemplate = true
              SET templatenamelast = trim(brdatabytemplate->tpl[tplidx].name,3)
             ENDIF
             IF (domainnamelast != trim(brdatabytemplate->tpl[tplidx].ld[ldidx].mnemonic,3))
              SET newtemplate = true
              SET domainnamelast = trim(brdatabytemplate->tpl[tplidx].ld[ldidx].mnemonic,3)
             ENDIF
             IF (newtemplate=true)
              IF (rowclass="even")
               SET rowclass = "odd"
              ELSE
               SET rowclass = "even"
              ENDIF
             ENDIF
             SET ret = build(ret,"<tr class='",rowclass,"'><td>",trim(brdatabytemplate->tpl[tplidx].
               mean,3),
              "</td><td>",trim(brdatabytemplate->tpl[tplidx].ld[ldidx].rpt[rptidx].filter[fltidx].
               mean,3),"</td><td>",trim(brdatabytemplate->tpl[tplidx].ld[ldidx].mnemonic,3),
              "</td><td>",
              trim(brdatabytemplate->tpl[tplidx].name,3),"</td><td>",trim(brdatabytemplate->tpl[
               tplidx].ld[ldidx].rpt[rptidx].name,3),"</td><td>",trim(brdatabytemplate->tpl[tplidx].
               ld[ldidx].rpt[rptidx].filter[fltidx].display,3),
              "</td><td>",generatevaluedisplay(brdatabytemplate->tpl[tplidx].ld[ldidx].rpt[rptidx].
               filter[fltidx].mean,brdatabytemplate->tpl[tplidx].ld[ldidx].rpt[rptidx].filter[fltidx]
               .value[validx].freetext_desc,brdatabytemplate->tpl[tplidx].ld[ldidx].rpt[rptidx].
               filter[fltidx].value[validx].mpage_param_value,brdatabytemplate->tpl[tplidx].ld[ldidx]
               .rpt[rptidx].filter[fltidx].value[validx].value_type_flag,brdatabytemplate->tpl[tplidx
               ].ld[ldidx].rpt[rptidx].filter[fltidx].value[validx].parent_entity_name,
               brdatabytemplate->tpl[tplidx].ld[ldidx].rpt[rptidx].filter[fltidx].value[validx].
               parent_entity_id,brdatabytemplate->tpl[tplidx].ld[ldidx].rpt[rptidx].filter[fltidx].
               value[validx].parent_entity_display),"</td></tr>")
           ENDFOR
         ENDFOR
       ENDFOR
     ENDFOR
   ENDFOR
   SET ret = concat(ret,"</tbody></table></div></body></html>")
   RETURN(ret)
   CALL errorcheck(brdatabytemplate,"generateHTML")
 END ;Subroutine
 SUBROUTINE PUBLIC::generatecsv(null)
   DECLARE currow = vc WITH protect, noconstant("")
   DECLARE currowlen = i4 WITH protect, noconstant(0)
   DECLARE maxwidth = i4 WITH protect, noconstant(0)
   DECLARE valuedisplay = vc WITH protect, noconstant("")
   DECLARE tplidx = i4 WITH protect, noconstant(0)
   DECLARE ldidx = i4 WITH protect, noconstant(0)
   DECLARE rptidx = i4 WITH protect, noconstant(0)
   DECLARE fltidx = i4 WITH protect, noconstant(0)
   DECLARE validx = i4 WITH protect, noconstant(0)
   DECLARE sep = vc WITH protect, noconstant("")
   SET sep = char(9)
   DECLARE crlf = vc WITH protect, noconstant("")
   SET crlf = concat(char(10),char(13))
   DECLARE ret = vc WITH protect, noconstant("")
   SET ret = concat("TEMPLATE ID",sep,"SETTING ID",sep,"LOGICAL DOMAIN",
    sep,"TEMPLATE NAME",sep,"COMPONENT",sep,
    "SETTING NAME",sep,"SETTING VALUE",crlf)
   SET maxwidth = textlen(ret)
   FOR (tplidx = 1 TO size(brdatabytemplate->tpl,5))
     FOR (ldidx = 1 TO size(brdatabytemplate->tpl[tplidx].ld,5))
       FOR (rptidx = 1 TO size(brdatabytemplate->tpl[tplidx].ld[ldidx].rpt,5))
         FOR (fltidx = 1 TO size(brdatabytemplate->tpl[tplidx].ld[ldidx].rpt[rptidx].filter,5))
           FOR (validx = 1 TO size(brdatabytemplate->tpl[tplidx].ld[ldidx].rpt[rptidx].filter[fltidx]
            .value,5))
             SET valuedisplay = generatevaluedisplay(brdatabytemplate->tpl[tplidx].ld[ldidx].rpt[
              rptidx].filter[fltidx].mean,brdatabytemplate->tpl[tplidx].ld[ldidx].rpt[rptidx].filter[
              fltidx].value[validx].freetext_desc,brdatabytemplate->tpl[tplidx].ld[ldidx].rpt[rptidx]
              .filter[fltidx].value[validx].mpage_param_value,brdatabytemplate->tpl[tplidx].ld[ldidx]
              .rpt[rptidx].filter[fltidx].value[validx].value_type_flag,brdatabytemplate->tpl[tplidx]
              .ld[ldidx].rpt[rptidx].filter[fltidx].value[validx].parent_entity_name,
              brdatabytemplate->tpl[tplidx].ld[ldidx].rpt[rptidx].filter[fltidx].value[validx].
              parent_entity_id,brdatabytemplate->tpl[tplidx].ld[ldidx].rpt[rptidx].filter[fltidx].
              value[validx].parent_entity_display)
             SET currow = build(trim(brdatabytemplate->tpl[tplidx].mean,3),sep,trim(brdatabytemplate
               ->tpl[tplidx].ld[ldidx].rpt[rptidx].filter[fltidx].mean,3),sep,trim(brdatabytemplate->
               tpl[tplidx].ld[ldidx].mnemonic,3),
              sep,trim(brdatabytemplate->tpl[tplidx].name,3),sep,trim(brdatabytemplate->tpl[tplidx].
               ld[ldidx].rpt[rptidx].name,3),sep,
              trim(brdatabytemplate->tpl[tplidx].ld[ldidx].rpt[rptidx].filter[fltidx].display,3),sep,
              valuedisplay,crlf)
             SET currowlen = textlen(currow)
             IF (maxwidth < currowlen)
              SET maxwidth = currowlen
             ENDIF
             SET ret = build(ret,currow)
           ENDFOR
         ENDFOR
       ENDFOR
     ENDFOR
   ENDFOR
   CALL errorcheck(brdatabytemplate,"generateCSV 1")
   SELECT INTO  $OUTDEV
    FROM (dummyt d  WITH seq = size(brdatabytemplate->tpl,5))
    HEAD REPORT
     "TEMPLATE ID", sep, "SETTING ID",
     sep, "LOGICAL DOMAIN", sep,
     "TEMPLATE NAME", sep, "COMPONENT",
     sep, "SETTING NAME", sep,
     "SETTING VALUE", row + 1
    DETAIL
     FOR (ldidx = 1 TO size(brdatabytemplate->tpl[d.seq].ld,5))
       FOR (rptidx = 1 TO size(brdatabytemplate->tpl[d.seq].ld[ldidx].rpt,5))
         FOR (fltidx = 1 TO size(brdatabytemplate->tpl[d.seq].ld[ldidx].rpt[rptidx].filter,5))
           FOR (validx = 1 TO size(brdatabytemplate->tpl[d.seq].ld[ldidx].rpt[rptidx].filter[fltidx].
            value,5))
             valuedisplay = generatevaluedisplay(brdatabytemplate->tpl[d.seq].ld[ldidx].rpt[rptidx].
              filter[fltidx].mean,brdatabytemplate->tpl[d.seq].ld[ldidx].rpt[rptidx].filter[fltidx].
              value[validx].freetext_desc,brdatabytemplate->tpl[d.seq].ld[ldidx].rpt[rptidx].filter[
              fltidx].value[validx].mpage_param_value,brdatabytemplate->tpl[d.seq].ld[ldidx].rpt[
              rptidx].filter[fltidx].value[validx].value_type_flag,brdatabytemplate->tpl[d.seq].ld[
              ldidx].rpt[rptidx].filter[fltidx].value[validx].parent_entity_name,
              brdatabytemplate->tpl[d.seq].ld[ldidx].rpt[rptidx].filter[fltidx].value[validx].
              parent_entity_id,brdatabytemplate->tpl[d.seq].ld[ldidx].rpt[rptidx].filter[fltidx].
              value[validx].parent_entity_display), brdatabytemplate->tpl[d.seq].mean, sep,
             brdatabytemplate->tpl[d.seq].ld[ldidx].rpt[rptidx].filter[fltidx].mean, sep,
             brdatabytemplate->tpl[d.seq].ld[ldidx].mnemonic,
             sep, brdatabytemplate->tpl[d.seq].name, sep,
             brdatabytemplate->tpl[d.seq].ld[ldidx].rpt[rptidx].name, sep, brdatabytemplate->tpl[d
             .seq].ld[ldidx].rpt[rptidx].filter[fltidx].display,
             sep, valuedisplay, row + 1
           ENDFOR
         ENDFOR
       ENDFOR
     ENDFOR
    WITH nocounter, maxcol = value(maxwidth), formfeed = none
   ;end select
   CALL errorcheck(brdatabytemplate,"generateCSV 2")
   RETURN(ret)
 END ;Subroutine
 SUBROUTINE PUBLIC::main(null)
   DECLARE generatecsvdata = i2 WITH protect, noconstant(false)
   DECLARE outputstring = vc WITH protect, noconstant("")
   DECLARE outputformat = vc WITH protect, noconstant("")
   SET outputformat = cnvtupper( $OUTPUTFORMAT)
   IF (outputformat="RAWCSV")
    SET generatecsvdata = true
   ENDIF
   CALL retrievedata( $CATEGORYMEAN, $MATCHMODE,brdatabyld,generatecsvdata,outputstring)
   CALL reorganizedata(null)
   CASE (outputformat)
    OF "HTML":
     SET outputstring = generatehtml(null)
     CALL echo(outputstring)
     SET _memory_reply_string = outputstring
    OF "JSON":
     SET _memory_reply_string = cnvtrectojson(brdatabytemplate)
    OF "CSV":
     SET outputstring = generatecsv(outputstring)
     SET _memory_reply_string = outputstring
    OF "RAWCSV":
     SET _memory_reply_string = outputstring
    OF "REC":
     IF (cnvtupper( $OUTDEV) != "MINE")
      CALL echorecord(brdatabytemplate, $OUTDEV,1)
     ELSE
      CALL echorecord(brdatabytemplate)
     ENDIF
    OF "RAWREC":
     IF (cnvtupper( $OUTDEV) != "MINE")
      CALL echorecord(brdatabyld, $OUTDEV,0)
     ELSE
      CALL echorecord(brdatabyld)
     ENDIF
    ELSE
     CALL echo("")
     CALL echo(build2("The output format ", $OUTPUTFORMAT," is not recognized."))
     CALL echo("")
     SET _memory_reply_string = concat(
      "<html><head><title>Invalid output format</title></head><body><div><span>The output format ",
       $OUTPUTFORMAT," is not recognized.</span></div></body></html>")
   ENDCASE
   CALL errorcheck(brdatabytemplate,"main")
 END ;Subroutine
 CALL main(null)
#exit_script
END GO
