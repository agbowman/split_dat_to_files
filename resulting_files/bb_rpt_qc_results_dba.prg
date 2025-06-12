CREATE PROGRAM bb_rpt_qc_results:dba
 RECORD reply(
   1 file_name = vc
   1 node = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD params(
   1 reagent_list[*]
     2 group_reagent_activity_id = f8
     2 related_reagent_id = f8
     2 reagent_disp = c40
     2 manufacturer_disp = c40
     2 lot_number_disp = c40
     2 expiry_dt_tm = f8
     2 visual_inspection_disp = c40
     2 interpretation_disp = c19
   1 result_list[*]
     2 reagent_disp = c40
     2 enhancement_disp = c40
     2 control_disp = c40
     2 result_disp = c40
     2 expected_result_list[*]
       3 expected_result_disp = c40
 )
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 RECORD tmptext(
   1 qual[*]
     2 text = vc
 )
 DECLARE uar_get_ceblobsize(p1=f8(ref),p2=vc(ref)) = i4 WITH image_aix =
 "uar_ce_blob.a(uar_ce_blob.o)", uar = "uar_get_ceblobsize", persist
 DECLARE uar_get_ceblob(p1=f8(ref),p2=vc(ref),p3=vc(ref),p4=i4(value)) = i4 WITH image_aix =
 "uar_ce_blob.a(uar_ce_blob.o)", uar = "uar_get_ceblob", persist
 RECORD recdate(
   1 datetime = dq8
 ) WITH protect
 DECLARE format = i2
 DECLARE outbuffer = vc
 DECLARE nortftext = vc
 SET format = 0
 DECLARE txt_pos = i4
 DECLARE start = i4
 DECLARE len = i4
 DECLARE linecnt = i4
 SUBROUTINE (rtf_to_text(rtftext=vc,format=i2,line_len=i2) =null)
   SET all_len = 0
   SET start = 0
   SET len = 0
   SET text_pos = 0
   SET linecnt = 0
   SET inbuffer = fillstring(value(size(rtftext))," ")
   SET outbufferlen = 0
   SET bfl = 0
   SET bfl2 = 1
   SET outbuffer = ""
   SET nortftext = ""
   SET stat = memrealloc(outbuffer,1,build("C",value(size(rtftext))))
   SET stat = memrealloc(nortftext,1,build("C",value(size(rtftext))))
   IF (substring(1,5,rtftext)=asis("{\rtf"))
    SET inbuffer = trim(rtftext)
    CALL uar_rtf2(inbuffer,size(inbuffer),outbuffer,size(outbuffer),outbufferlen,
     bfl)
   ELSE
    SET outbuffer = trim(rtftext)
   ENDIF
   SET nortftext = trim(outbuffer)
   SET stat = alterlist(tmptext->qual,0)
   SET crchar = concat(char(13),char(10))
   SET lfchar = char(10)
   SET ffchar = char(12)
   IF (format > 0)
    SET all_len = cnvtint(size(trim(outbuffer)))
    SET tot_len = 0
    SET start = 1
    SET bigfirst = "Y"
    SET crstart = start
    WHILE (all_len > tot_len)
      SET crpos = crstart
      SET crfirst = "Y"
      SET loaded = "N"
      WHILE ((crpos <= ((crstart+ line_len)+ 1))
       AND loaded="N"
       AND all_len > tot_len)
       IF ((crpos=((crstart+ line_len)+ 1))
        AND crfirst="N")
        SET start = crstart
        SET first = "Y"
        SET text_pos = ((start+ line_len) - 1)
        IF (bigfirst="Y"
         AND text_pos >= all_len)
         SET text_pos = start
        ENDIF
        SET bigfirst = "N"
        WHILE (text_pos >= start
         AND all_len > tot_len)
          IF (text_pos=start)
           SET text_pos = ((start+ line_len) - 1)
           SET linecnt += 1
           SET stat = alterlist(tmptext->qual,linecnt)
           SET len = ((text_pos - start)+ 1)
           SET tmptext->qual[linecnt].text = substring(start,len,outbuffer)
           SET start = (text_pos+ 1)
           SET crstart = (text_pos+ 1)
           SET text_pos = 0
           SET tot_len = ((tot_len+ len) - 1)
           SET loaded = "Y"
          ELSE
           IF (substring(text_pos,1,outbuffer)=" ")
            SET len = (text_pos - start)
            IF (cnvtint(size(trim(substring(start,len,outbuffer)))) > 0)
             SET linecnt += 1
             SET stat = alterlist(tmptext->qual,linecnt)
             SET tmptext->qual[linecnt].text = substring(start,len,outbuffer)
             SET loaded = "Y"
            ENDIF
            SET start = (text_pos+ 1)
            SET crstart = (text_pos+ 1)
            SET text_pos = 0
            SET tot_len += len
           ELSE
            IF (first="Y")
             SET first = "N"
             SET tot_len += 1
            ENDIF
            SET text_pos -= 1
           ENDIF
          ENDIF
        ENDWHILE
       ELSE
        SET crfirst = "N"
        IF (((substring(crpos,1,outbuffer)=crchar) OR (((substring(crpos,1,outbuffer)=lfchar) OR (
        substring(crpos,1,outbuffer)=ffchar)) )) )
         SET crlen = (crpos - crstart)
         SET linecnt += 1
         SET stat = alterlist(tmptext->qual,linecnt)
         SET tmptext->qual[linecnt].text = substring(crstart,crlen,outbuffer)
         SET loaded = "Y"
         IF (substring(crpos,1,outbuffer)=crchar)
          SET crstart = (crpos+ textlen(crchar))
         ELSEIF (substring(crpos,1,outbuffer)=lfchar)
          SET crstart = (crpos+ textlen(lfchar))
         ELSEIF (substring(crpos,1,outbuffer)=ffchar)
          SET crstart = (crpos+ textlen(ffchar))
         ENDIF
         SET tot_len += crlen
        ENDIF
       ENDIF
       SET crpos += 1
      ENDWHILE
    ENDWHILE
   ENDIF
   SET rtftext = fillstring(value(size(rtftext))," ")
   SET inbuffer = fillstring(value(size(rtftext))," ")
 END ;Subroutine
 DECLARE outbufmaxsiz = i2
 DECLARE tblobin = c32000
 DECLARE tblobout = c32000
 DECLARE blobin = c32000
 DECLARE blobout = c32000
 SUBROUTINE (decompress_text(tblobin=vc) =null)
   SET tblobout = fillstring(32000," ")
   SET blobout = fillstring(32000," ")
   SET outbufmaxsiz = 0
   SET blobin = trim(tblobin)
   CALL uar_ocf_uncompress(blobin,size(blobin),blobout,size(blobout),outbufmaxsiz)
   SET tblobout = blobout
   SET tblobin = fillstring(32000," ")
   SET blobin = fillstring(32000," ")
 END ;Subroutine
 SUBROUTINE (subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value
   )) =null WITH protect)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
 DECLARE nstatus = i2 WITH protect, noconstant(0)
 DECLARE nfirsttime = i2 WITH protect, noconstant(1)
 DECLARE nprintedreagentsheader = i2 WITH protect, noconstant(0)
 DECLARE nprintedresultsheader = i2 WITH protect, noconstant(0)
 DECLARE ndonereagents = i2 WITH protect, noconstant(0)
 DECLARE ndoneresults = i2 WITH protect, noconstant(0)
 DECLARE ncount = i2 WITH protect, noconstant(0)
 DECLARE ncount1 = i2 WITH protect, noconstant(0)
 DECLARE nbreak = i2 WITH protect, noconstant(0)
 DECLARE nlinesperpage = i2 WITH protect, constant(57)
 DECLARE nlinelength = i2 WITH protect, constant(21)
 DECLARE i = i2 WITH protect, noconstant(0)
 DECLARE j = i2 WITH protect, noconstant(0)
 DECLARE li18nhandle = i4 WITH protect, noconstant(0)
 DECLARE ssegment = vc WITH protect, noconstant("")
 DECLARE sserviceresourcename = vc WITH protect, noconstant("")
 DECLARE scurstring = vc WITH protect, noconstant("")
 DECLARE sthirtyline = vc WITH protect, noconstant(fillstring(30,"-"))
 DECLARE sfifteenline = vc WITH protect, noconstant(fillstring(15,"-"))
 DECLARE selevenline = vc WITH protect, noconstant(fillstring(11,"-"))
 DECLARE sfourteenline = vc WITH protect, noconstant(fillstring(14,"-"))
 DECLARE snineteenline = vc WITH protect, noconstant(fillstring(19,"-"))
 DECLARE stwentyoneline = vc WITH protect, noconstant(fillstring(21,"-"))
 DECLARE sfortythreeline = vc WITH protect, noconstant("")
 DECLARE sequalsline = vc WITH protect, noconstant("")
 DECLARE sdashesline = vc WITH protect, noconstant("")
 DECLARE serror = vc WITH protect, noconstant("")
 SET reply->status_data.status = "F"
 SET nstatus = uar_i18nlocalizationinit(li18nhandle,curprog,"",curcclrev)
 SET sserviceresourcename = uar_get_code_display(request->service_resource_cd)
 RECORD captions(
   1 stitle = vc
   1 susername = vc
   1 sdomain = vc
   1 sdate = vc
   1 stime = vc
   1 spage = vc
   1 sactive = vc
   1 srelationship = vc
   1 sreagent = vc
   1 scontrolmaterial = vc
   1 senhancementmedia = vc
   1 sexpectedresults = vc
   1 sendofreport = vc
   1 smanufacturer = vc
   1 slotnumber = vc
   1 sexpirydate = vc
   1 svisualinspection = vc
   1 sinterpretation = vc
   1 sresult = vc
   1 sserviceresource = vc
   1 sgroup = vc
   1 sdaterange = vc
   1 sresults = vc
   1 sreagents = vc
 )
 SET captions->stitle = uar_i18ngetmessage(li18nhandle,"TITLE",
  "PathNet Blood Bank: QC Results Report")
 SET captions->susername = uar_i18ngetmessage(li18nhandle,"NAME","Username:")
 SET captions->sdomain = uar_i18ngetmessage(li18nhandle,"DOMAIN","Domain:")
 SET captions->sdate = uar_i18ngetmessage(li18nhandle,"DATE","Date:")
 SET captions->stime = uar_i18ngetmessage(li18nhandle,"TIME","Time:")
 SET captions->spage = uar_i18ngetmessage(li18nhandle,"PAGE","Page:")
 SET captions->sactive = uar_i18ngetmessage(li18nhandle,"ACTIVE","Active")
 SET captions->srelationship = uar_i18ngetmessage(li18nhandle,"RELATIONSHIP","Relationship: ")
 SET captions->sreagent = uar_i18ngetmessage(li18nhandle,"REAGENT","Reagent")
 SET captions->scontrolmaterial = uar_i18ngetmessage(li18nhandle,"CONTROL","Control")
 SET captions->senhancementmedia = uar_i18ngetmessage(li18nhandle,"ENHANCEMENT","Enhancement Media")
 SET captions->sexpectedresults = uar_i18ngetmessage(li18nhandle,"RESULTS","Expected Results")
 SET captions->sendofreport = uar_i18ngetmessage(li18nhandle,"ENDOFREPORT",
  "* * * End of Report * * *")
 SET captions->smanufacturer = uar_i18ngetmessage(li18nhandle,"MANUFACTURER","Manufacturer")
 SET captions->slotnumber = uar_i18ngetmessage(li18nhandle,"LOTNUMBER","Lot Number")
 SET captions->sexpirydate = uar_i18ngetmessage(li18nhandle,"EXPIRYDATE","Expiry Date")
 SET captions->svisualinspection = uar_i18ngetmessage(li18nhandle,"VISUALINSPECTION",
  "Visual Inspection")
 SET captions->sinterpretation = uar_i18ngetmessage(li18nhandle,"INTERPRETATION","Interpretation")
 SET captions->sresult = uar_i18ngetmessage(li18nhandle,"RESULT","Result")
 SET captions->sserviceresource = uar_i18ngetmessage(li18nhandle,"SERVICERESOURCE",
  "Service Resource:")
 SET captions->sgroup = uar_i18ngetmessage(li18nhandle,"GROUP","Group:")
 SET captions->sdaterange = uar_i18ngetmessage(li18nhandle,"DATERANGE","Date Range:")
 SET captions->sresults = uar_i18ngetmessage(li18nhandle,"RESULTS","RESULTS")
 SET captions->sreagents = uar_i18ngetmessage(li18nhandle,"REAGENTS","REAGENTS")
 SELECT INTO "nl:"
  sreagentdisp = uar_get_code_display(pld.parent_entity_id), smanufacturerdisp = uar_get_code_display
  (pld.manufacturer_cd), svisualinspectiondisp = uar_get_code_display(bbqcgra.visual_inspection_cd),
  sinterpretationdisp = uar_get_code_display(bbqcgra.interpretation_cd)
  FROM bb_qc_group_activity bbqcga,
   (dummyt d  WITH seq = value(size(request->group_activity_list,5))),
   bb_qc_grp_reagent_activity bbqcgra,
   bb_qc_grp_reagent_lot bbqcgrl,
   pcs_lot_information pli,
   pcs_lot_definition pld
  PLAN (d)
   JOIN (bbqcga
   WHERE (request->group_activity_list[d.seq].group_activity_id=bbqcga.group_activity_id))
   JOIN (bbqcgra
   WHERE bbqcgra.group_activity_id=bbqcga.group_activity_id)
   JOIN (bbqcgrl
   WHERE bbqcgrl.group_reagent_lot_id=bbqcgra.group_reagent_lot_id
    AND cnvtdatetime(sysdate) BETWEEN bbqcgrl.beg_effective_dt_tm AND bbqcgrl.end_effective_dt_tm)
   JOIN (pli
   WHERE pli.lot_information_id=bbqcgrl.lot_information_id)
   JOIN (pld
   WHERE pld.lot_definition_id=pli.lot_definition_id)
  ORDER BY bbqcgrl.display_order_seq
  HEAD REPORT
   ncount = 0
  DETAIL
   ncount += 1
   IF (ncount > size(params->reagent_list,5))
    nstatus = alterlist(params->reagent_list,(ncount+ 9))
   ENDIF
   params->reagent_list[ncount].group_reagent_activity_id = bbqcgra.group_reagent_activity_id, params
   ->reagent_list[ncount].related_reagent_id = bbqcgrl.related_reagent_id, params->reagent_list[
   ncount].reagent_disp = sreagentdisp,
   params->reagent_list[ncount].manufacturer_disp = smanufacturerdisp, params->reagent_list[ncount].
   lot_number_disp = pli.lot_ident, params->reagent_list[ncount].expiry_dt_tm = pli.expire_dt_tm,
   params->reagent_list[ncount].visual_inspection_disp = svisualinspectiondisp, params->reagent_list[
   ncount].interpretation_disp = sinterpretationdisp
  FOOT REPORT
   nstatus = alterlist(params->reagent_list,ncount)
  WITH nocounter
 ;end select
 IF (error(serror,0) > 0)
  CALL subevent_add("REPORT","F","BB_RPT_QC_RESULTS",serror)
  GO TO exit_script
 ENDIF
 IF (size(params->reagent_list,5) > 0)
  SELECT INTO "nl:"
   sreagentdisp = uar_get_code_display(bbqcrr.reagent_cd), senhancementdisp = uar_get_code_display(
    bbqcrrd.enhancement_cd), scontroldisp = uar_get_code_display(bbqcrrd.control_cd)
   FROM bb_qc_result bbqcr,
    (dummyt d  WITH seq = value(size(params->reagent_list,5))),
    bb_qc_grp_reagent_activity bbqcgra,
    bb_qc_grp_reagent_activity bbqcgra2,
    bb_qc_grp_reagent_activity bbqcgra3,
    bb_qc_grp_reagent_lot bbqcgrl,
    bb_qc_grp_reagent_lot bbqcgrl2,
    bb_qc_grp_reagent_lot bbqcgrl3,
    pcs_lot_information pli2,
    pcs_lot_information pli3,
    pcs_lot_definition pld2,
    pcs_lot_definition pld3,
    nomenclature n,
    bb_qc_rel_reagent bbqcrr,
    bb_qc_rel_reagent_detail bbqcrrd,
    bb_qc_expected_result_r bbqcerr,
    nomenclature n2
   PLAN (d)
    JOIN (bbqcr
    WHERE (((params->reagent_list[d.seq].group_reagent_activity_id=bbqcr.group_reagent_activity_id))
     OR ((((params->reagent_list[d.seq].group_reagent_activity_id=bbqcr.enhancement_activity_id)) OR
    ((params->reagent_list[d.seq].group_reagent_activity_id=bbqcr.control_activity_id))) )) )
    JOIN (n
    WHERE n.nomenclature_id=bbqcr.nomenclature_id)
    JOIN (bbqcgra
    WHERE bbqcgra.group_reagent_activity_id=bbqcr.group_reagent_activity_id)
    JOIN (bbqcgrl
    WHERE bbqcgrl.group_reagent_lot_id=bbqcgra.group_reagent_lot_id)
    JOIN (bbqcgra2
    WHERE bbqcgra2.group_reagent_activity_id=bbqcr.enhancement_activity_id)
    JOIN (bbqcgrl2
    WHERE bbqcgrl2.group_reagent_lot_id=bbqcgra2.group_reagent_lot_id)
    JOIN (pli2
    WHERE pli2.lot_information_id=bbqcgrl2.lot_information_id)
    JOIN (pld2
    WHERE pld2.lot_definition_id=pli2.lot_definition_id)
    JOIN (bbqcgra3
    WHERE bbqcgra3.group_reagent_activity_id=bbqcr.control_activity_id)
    JOIN (bbqcgrl3
    WHERE bbqcgrl3.group_reagent_lot_id=bbqcgra3.group_reagent_lot_id)
    JOIN (pli3
    WHERE pli3.lot_information_id=bbqcgrl3.lot_information_id)
    JOIN (pld3
    WHERE pld3.lot_definition_id=pli3.lot_definition_id)
    JOIN (bbqcrr
    WHERE bbqcrr.related_reagent_id=bbqcgrl.related_reagent_id)
    JOIN (bbqcrrd
    WHERE bbqcrrd.related_reagent_id=bbqcrr.related_reagent_id
     AND bbqcrrd.enhancement_cd=pld2.parent_entity_id
     AND bbqcrrd.control_cd=pld3.parent_entity_id
     AND bbqcrrd.phase_cd=bbqcr.phase_cd)
    JOIN (bbqcerr
    WHERE bbqcerr.related_reagent_detail_id=bbqcrrd.related_reagent_detail_id)
    JOIN (n2
    WHERE n2.nomenclature_id=bbqcerr.nomenclature_id)
   ORDER BY bbqcr.qc_result_id, bbqcerr.nomenclature_id
   HEAD REPORT
    ncount = 0
   HEAD bbqcr.qc_result_id
    ncount += 1, ncount1 = 0
    IF (ncount > size(params->result_list,5))
     nstatus = alterlist(params->result_list,(ncount+ 9))
    ENDIF
    params->result_list[ncount].reagent_disp = sreagentdisp, params->result_list[ncount].
    enhancement_disp = senhancementdisp, params->result_list[ncount].control_disp = scontroldisp,
    params->result_list[ncount].result_disp = n.source_string
   HEAD bbqcerr.nomenclature_id
    ncount1 += 1
    IF (ncount1 > size(params->result_list[ncount].expected_result_list,5))
     nstatus = alterlist(params->result_list[ncount].expected_result_list,(ncount1+ 9))
    ENDIF
    params->result_list[ncount].expected_result_list[ncount1].expected_result_disp = n2.source_string
   FOOT  bbqcerr.nomenclature_id
    row + 0
   FOOT  bbqcr.qc_result_id
    nstatus = alterlist(params->result_list[ncount].expected_result_list,ncount1)
   FOOT REPORT
    nstatus = alterlist(params->result_list,ncount)
   WITH nocounter
  ;end select
 ENDIF
 IF (error(serror,0) > 0)
  CALL subevent_add("REPORT","F","BB_RPT_QC_RESULTS",serror)
  GO TO exit_script
 ENDIF
 CALL echorecord(params)
 EXECUTE cpm_create_file_name "bb_qrs", "txt"
 IF ((cpm_cfn_info->status_data.status != "S"))
  CALL subevent_add("SELECT","F","FILE_NAME","Failed to create a file name")
  GO TO exit_script
 ENDIF
 IF (size(params->reagent_list,5)=0)
  SELECT INTO cpm_cfn_info->file_name_path
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   HEAD REPORT
    sequalsline = fillstring(129,"="), sdashesline = fillstring(129,"-")
   DETAIL
    row 1,
    CALL center(captions->stitle,1,128), row + 1,
    col 1, captions->susername, col 11,
    request->username, col 116, captions->sdate,
    col 122, curdate"@SHORTDATE", row + 1,
    col 1, captions->sdomain, col 11,
    request->domain, col 116, captions->stime,
    col 122, curtime3"@TIMEWITHSECONDS", row + 2,
    col 1, captions->sserviceresource, row + 1,
    col 1, captions->sgroup, row + 1,
    col 1, captions->sdaterange, row + 2,
    col 1, sequalsline, row + 2,
    CALL center(captions->sreagents,1,128), row + 1, col 1,
    sdashesline, row + 1, col 1,
    captions->sreagent, col 32, captions->smanufacturer,
    col 63, captions->slotnumber, col 79,
    captions->sexpirydate, col 91, captions->svisualinspection,
    col 111, captions->sinterpretation, row + 1,
    col 1, sthirtyline, col 32,
    sthirtyline, col 63, sfifteenline,
    col 79, selevenline, col 91,
    snineteenline, col 111, snineteenline,
    row + 2,
    CALL center(captions->sresults,1,128), row + 1,
    col 1, sdashesline, row + 1,
    col 1, captions->sreagent, col 32,
    captions->senhancementmedia, col 63, captions->scontrolmaterial,
    col 94, captions->sresult, col 109,
    captions->sexpectedresults, row + 1, col 1,
    sthirtyline, col 32, sthirtyline,
    col 63, sthirtyline, col 94,
    sfourteenline, col 109, stwentyoneline
   FOOT PAGE
    row nlinesperpage, row + 1, col 1,
    sdashesline, row + 1, col 61,
    captions->spage, col + 2, curpage"####;L"
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO cpm_cfn_info->file_name_path
   FROM (dummyt d  WITH seq = value(size(params->reagent_list,5)))
   PLAN (d)
   HEAD REPORT
    sequalsline = fillstring(129,"="), sdashesline = fillstring(129,"-")
   HEAD PAGE
    IF (((d.seq < value(size(params->reagent_list,5))) OR (((nbreak=1) OR (value(size(params->
      reagent_list,5))=1)) )) )
     IF (((value(size(params->reagent_list,5))=1
      AND ((nbreak=1) OR (nfirsttime=1)) ) OR (value(size(params->reagent_list,5)) > 1)) )
      row 1,
      CALL center(captions->stitle,1,128), row + 1,
      col 1, captions->susername, col 11,
      request->username, col 116, captions->sdate,
      col 122, curdate"@SHORTDATE", row + 1,
      col 1, captions->sdomain, col 11,
      request->domain, col 116, captions->stime,
      col 122, curtime3"@TIMEWITHSECONDS", row + 2,
      col 1, captions->sserviceresource, col 19,
      sserviceresourcename, row + 1, col 1,
      captions->sgroup, col 8, request->group_name,
      row + 1, col 1, captions->sdaterange,
      col 13, request->start_dt_tm"@SHORTDATETIME", col 31,
      "-", col 33, request->end_dt_tm"@SHORTDATETIME",
      row + 2, col 1, sequalsline,
      nfirsttime = 0
      IF (nbreak=1)
       row + 2
      ENDIF
     ENDIF
    ENDIF
   DETAIL
    IF ((row >= (nlinesperpage - 3)))
     nbreak = 1, BREAK
    ELSE
     nbreak = 0, row + 2
    ENDIF
    IF (nprintedreagentsheader=0)
     CALL center(captions->sreagents,1,128), row + 1, col 1,
     sdashesline, row + 1, col 1,
     captions->sreagent, col 32, captions->smanufacturer,
     col 63, captions->slotnumber, col 79,
     captions->sexpirydate, col 91, captions->svisualinspection,
     col 111, captions->sinterpretation, row + 1,
     col 1, sthirtyline, col 32,
     sthirtyline, col 63, sfifteenline,
     col 79, selevenline, col 91,
     snineteenline, col 111, snineteenline,
     row + 1, nprintedreagentsheader = 1
    ENDIF
    IF (ndonereagents=0)
     strunc1 = substring(1,30,params->reagent_list[d.seq].reagent_disp), col 1, strunc1,
     strunc2 = substring(1,30,params->reagent_list[d.seq].manufacturer_disp), col 32, strunc2,
     strunc3 = substring(1,15,params->reagent_list[d.seq].lot_number_disp), col 63, strunc3,
     col 79, params->reagent_list[d.seq].expiry_dt_tm"@SHORTDATE", strunc4 = substring(1,19,params->
      reagent_list[d.seq].visual_inspection_disp),
     col 91, strunc4, strunc5 = substring(1,19,params->reagent_list[d.seq].interpretation_disp),
     col 111, strunc5, row + 1
     IF (d.seq=value(size(params->reagent_list,5)))
      ndonereagents = 1
      IF (nprintedresultsheader=0)
       IF ((row >= (nlinesperpage - 5)))
        nbreak = 1, BREAK
       ELSE
        nbreak = 0
       ENDIF
       col 1, sdashesline, row + 2,
       CALL center(captions->sresults,1,128), row + 1, col 1,
       sdashesline, row + 1, col 1,
       captions->sreagent, col 32, captions->senhancementmedia,
       col 63, captions->scontrolmaterial, col 94,
       captions->sresult, col 109, captions->sexpectedresults,
       row + 1, col 1, sthirtyline,
       col 32, sthirtyline, col 63,
       sthirtyline, col 94, sfourteenline,
       col 109, stwentyoneline, nprintedresultsheader = 1
      ENDIF
     ENDIF
    ENDIF
    IF (ndonereagents=1)
     FOR (i = 1 TO value(size(params->result_list,5)))
       row + 1
       IF ((row >= (nlinesperpage - 3)))
        nbreak = 1, BREAK
       ELSE
        nbreak = 0
       ENDIF
       strunc6 = substring(1,30,params->result_list[i].reagent_disp), col 1, strunc6,
       strunc7 = substring(1,30,params->result_list[i].enhancement_disp), col 32, strunc7,
       strunc8 = substring(1,30,params->result_list[i].control_disp), col 63, strunc8,
       strunc9 = substring(1,14,params->result_list[i].result_disp), col 94, strunc9,
       ssegment = ""
       FOR (j = 1 TO size(params->result_list[i].expected_result_list,5))
         IF (ssegment="")
          ssegment = nullterm(params->result_list[i].expected_result_list[j].expected_result_disp)
         ELSE
          ssegment = build(nullterm(ssegment),",",nullterm(params->result_list[i].
            expected_result_list[j].expected_result_disp))
         ENDIF
       ENDFOR
       tblobin = " ", tblobin = trim(ssegment),
       CALL rtf_to_text(trim(tblobin),1,nlinelength)
       FOR (z = 1 TO size(tmptext->qual,5))
         col 109, tmptext->qual[z].text, row + 1
         IF ((row >= (nlinesperpage - 3)))
          nbreak = 1, BREAK
         ELSE
          nbreak = 0
         ENDIF
       ENDFOR
     ENDFOR
     IF (d.seq=value(size(params->reagent_list,5)))
      row + 1, col 51, captions->sendofreport
     ENDIF
    ENDIF
   FOOT PAGE
    row nlinesperpage, row + 1, col 1,
    sdashesline, row + 1, col 61,
    captions->spage, col + 2, curpage"####;L"
   WITH nocounter
  ;end select
 ENDIF
 IF (error(serror,0) > 0)
  CALL subevent_add("REPORT","F","BB_RPT_QC_RESULTS",serror)
  GO TO exit_script
 ENDIF
 SET reply->file_name = cpm_cfn_info->file_name_path
 SET reply->node = curnode
 SET reply->status_data.status = "S"
#exit_script
 FREE RECORD params
 FREE RECORD captions
END GO
