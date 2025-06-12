CREATE PROGRAM aps_prt_db_prompt_fields:dba
 RECORD reply(
   1 prompt_test_qual[*]
     2 prefix_cd = f8
     2 task_assay_cd = f8
     2 catalog_cd = f8
     2 specimen_catalog_cd = f8
     2 required_ind = i2
     2 description = vc
     2 specimen_description = vc
     2 text = vc
     2 prompt_id = f8
     2 long_text_id = f8
     2 action_flag = i2
     2 updt_cnt = i4
     2 field_qual[*]
       3 field_nbr = i2
       3 field_type = c18
       3 field_action_flag = i2
       3 field_oe_field_id = f8
       3 oe_field_display = vc
     2 text_qual[*]
       3 line = vc
   1 print_status_data
     2 print_directory = c19
     2 print_filename = c40
     2 print_dir_and_filename = c60
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
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
 DECLARE h = i4 WITH protect, noconstant(0)
 DECLARE i18nhandle = i4 WITH protect, noconstant(0)
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE sreport = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"sReport","REPORT: "))
 DECLARE sap = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"sAP","Anatomic Pathology"))
 DECLARE sdate = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"sDate","DATE: "))
 DECLARE stime = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"sTime","TIME:"))
 DECLARE spromptfieldshead = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"sPromptFldHead",
   "PROMPT FIELDS"))
 DECLARE sby = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"sBy","BY: "))
 DECLARE spage = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"sPage","PAGE: "))
 DECLARE sspecimenprocedures = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"sSpecProcs",
   "SPECIMEN PROCEDURES: "))
 DECLARE sspecimenprocedure = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"sSpecProc",
   "SPECIMEN PROCEDURE: "))
 DECLARE spromptprocedure = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"sPromptProc",
   "PROMPT PROCEDURE: "))
 DECLARE sappend = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"sAppend",
   "APPEND ADDITIONAL SPECIMENS: "))
 DECLARE spromptfields = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"sPromptFlds",
   "PROMPT FIELDS: "))
 DECLARE sprompttext = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"sPromptTxt",
   "PROMPT TEXT: "))
 DECLARE snone = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"sNone","NONE"))
 DECLARE syes = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"sYes","Yes"))
 DECLARE sno = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"sNo","No"))
 DECLARE scontinued = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"sContinued",
   "CONTINUED..."))
 DECLARE sendreport = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"sEndReport",
   "##### END OF REPORT #####"))
 DECLARE sunderscore = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"sUnderscore",
   "Use an underscore"))
 DECLARE sentirefield = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"sEntireField",
   "Remove entire field"))
 DECLARE sall = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,"sAll","ALL"))
 DECLARE susername = vc WITH protect, noconstant("")
 DECLARE sprocedurelist = vc WITH protect, noconstant("")
 DECLARE sappenddisplay = vc WITH protect, noconstant("")
 DECLARE sfieldaction = vc WITH protect, noconstant("")
 DECLARE nmaxfieldsize = i4 WITH protect, noconstant(0)
 DECLARE ssepchar = vc WITH protect, noconstant("")
 DECLARE swrappingstring = vc WITH protect, noconstant("")
 DECLARE swrappingstringtemp = vc WITH protect, noconstant("")
 DECLARE nidx = i4 WITH protect, noconstant(0)
 DECLARE nidx2 = i4 WITH protect, noconstant(0)
 EXECUTE aps_get_prompts
 IF ((reply->status_data.status != "S"))
  GO TO exit_aps_prt_db_prompt_fields
 ELSE
  EXECUTE aps_get_prompt_fields  WITH replace(request,reply)
  IF ((reply->status_data.status != "S"))
   GO TO exit_aps_prt_db_prompt_fields
  ENDIF
 ENDIF
 SET reply->status_data.status = "F"
 IF (size(request->prompt_test_qual,5) > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = size(request->prompt_test_qual,5))
   DETAIL
    sprocedurelist = concat(sprocedurelist,ssepchar,request->prompt_test_qual[d.seq].
     specimen_description), ssepchar = notrim(", ")
   WITH nocounter
  ;end select
 ELSE
  SET sprocedurelist = sall
 ENDIF
 FOR (nidx = 1 TO size(reply->prompt_test_qual,5))
   SET nmaxfieldsize = maxval(nmaxfieldsize,size(reply->prompt_test_qual[nidx].field_qual,5))
   CALL replaceoefields(nidx)
   CALL rtf_to_text(reply->prompt_test_qual[nidx].text,1,(maxcol - 3))
   SET stat = alterlist(reply->prompt_test_qual[nidx].text_qual,size(tmptext->qual,5))
   FOR (nidx2 = 1 TO size(tmptext->qual,5))
     SET reply->prompt_test_qual[nidx].text_qual[nidx2].line = tmptext->qual[nidx2].text
   ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE (p.person_id=reqinfo->updt_id)
    AND p.active_ind=1
    AND cnvtdatetime(sysdate) BETWEEN p.beg_effective_dt_tm AND p.end_effective_dt_tm)
  DETAIL
   susername = p.username
  WITH nocounter
 ;end select
 EXECUTE cpm_create_file_name_logical "APS_PROMPT", "DAT"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SELECT INTO trim(cpm_cfn_info->file_name_full_path)
  dtest = decode(d2.seq,1,0)
  FROM (dummyt d1  WITH seq = size(reply->prompt_test_qual,5)),
   (dummyt d2  WITH seq = nmaxfieldsize)
  PLAN (d1
   WHERE (reply->prompt_test_qual[d1.seq].prompt_id > 0))
   JOIN (d2
   WHERE d2.seq <= size(reply->prompt_test_qual[d1.seq].field_qual,5))
  ORDER BY cnvtalphanum(cnvtupper(reply->prompt_test_qual[d1.seq].specimen_description)),
   cnvtalphanum(cnvtupper(reply->prompt_test_qual[d1.seq].description)), reply->prompt_test_qual[d1
   .seq].field_qual[d2.seq].field_nbr
  HEAD REPORT
   nrowsneeded = 0, nfootrows = 0,
   MACRO (checkspace)
    IF ((((value(row)+ nrowsneeded)+ nfootrows) > maxrow))
     BREAK
    ENDIF
   ENDMACRO
   ,
   nwrappingposition = 0, nwrappingindent = 0, nwrappinghangingindent = 0,
   nwrappingleftcol = 0, bwrappingresetvalues = 1,
   MACRO (wrappingstring)
    col + (nwrappingindent+ nwrappingleftcol)
    WHILE ((textlen(swrappingstring) > (maxcol - value(col))))
      nwrappingposition = findstring(" ",substring(1,(maxcol - value(col)),swrappingstring),1,1),
      nwrappingposition = evaluate(nwrappingposition,0,((maxcol - 1) - value(col)),nwrappingposition),
      swrappingstringtemp = substring(1,nwrappingposition,swrappingstring),
      swrappingstringtemp, row + 1, col value((nwrappinghangingindent+ nwrappingleftcol)),
      swrappingstring = concat(substring((nwrappingposition+ 1),(textlen(swrappingstring) -
        nwrappingposition),swrappingstring))
    ENDWHILE
    swrappingstringtemp = swrappingstring, swrappingstringtemp, row + 1,
    col 0
    IF (bwrappingresetvalues=1)
     nwrappingindent = 0, nwrappinghangingindent = 0, nwrappingleftcol = 0
    ENDIF
    swrappingstring = ""
   ENDMACRO
   ,
   bfirstpage = 1, bnewpage = 1, nidx = 0,
   ntab1 = (maxcol - 27), ntab2 = (maxcol - 15), sline = fillstring(value((maxcol - 1)),"-"),
   nfootrows = 3, nfieldsize = 0
  HEAD PAGE
   col 0, sreport, col + 1,
   curprog,
   CALL center(sap,1,maxcol), col ntab1,
   sdate, col ntab2, curdate"@SHORTDATE",
   row + 1, col ntab1, stime,
   col ntab2, curtime3"@TIMENOSECONDS", row + 1,
   CALL center(spromptfieldshead,1,maxcol), col ntab1, sby,
   col ntab2, susername"##############", row + 1,
   col ntab1, spage, col ntab2,
   curpage"###;L", row + 1
   IF (bfirstpage=1)
    col 0, sspecimenprocedures, swrappingstring = sprocedurelist,
    nwrappingindent = 1, nwrappinghangingindent = 3, wrappingstring,
    bfirstpage = 0
   ENDIF
   col 0, sline, row + 1,
   bnewpage = 1
  HEAD d1.seq
   IF (bnewpage=1)
    bnewpage = 0
   ELSE
    row + 1
   ENDIF
   nrowsneeded = (4+ size(reply->prompt_test_qual[d1.seq].text_qual,5)), nfieldsize = size(reply->
    prompt_test_qual[d1.seq].field_qual,5)
   IF (nfieldsize > 0)
    nrowsneeded = ((nrowsneeded+ nfieldsize)+ 1)
   ENDIF
   checkspace, col 0, sspecimenprocedure,
   col + 1, reply->prompt_test_qual[d1.seq].specimen_description, row + 1,
   col 0, spromptprocedure, col + 1,
   reply->prompt_test_qual[d1.seq].description, row + 1
   IF (nfieldsize > 0)
    sappenddisplay = evaluate(reply->prompt_test_qual[d1.seq].action_flag,1,syes,sno), col 0, sappend,
    col + 1, sappenddisplay, row + 1,
    col 0, spromptfields, row + 1
   ELSE
    col 0, spromptfields, col + 1,
    snone, row + 1
   ENDIF
   bnewpage = 0
  DETAIL
   IF (dtest=1)
    col 2, reply->prompt_test_qual[d1.seq].field_qual[d2.seq].oe_field_display, col + 1,
    "-", sfieldaction = evaluate(reply->prompt_test_qual[d1.seq].field_qual[d2.seq].field_action_flag,
     1,sentirefield,sunderscore), col + 1,
    sfieldaction, row + 1
   ENDIF
  FOOT  d1.seq
   col 0, sprompttext, row + 1
   FOR (nidx = 1 TO size(reply->prompt_test_qual[d1.seq].text_qual,5))
     col 2, reply->prompt_test_qual[d1.seq].text_qual[nidx].line, row + 1
   ENDFOR
  FOOT PAGE
   nendrow = (maxrow - 3), row nendrow, col 0,
   sline, row + 1, col 0,
   sreport, col + 1, spromptfieldshead,
   CALL center(concat(format(curdate,"@WEEKDAYABBREV")," ",format(curdate,"@SHORTDATE")),1,maxcol),
   col ntab1, spage,
   col ntab2, curpage"###;L", row + 1
   IF (curendreport=0)
    CALL center(scontinued,1,maxcol)
   ELSE
    CALL center(sendreport,1,maxcol)
   ENDIF
  WITH nocounter, outerjoin = d1
 ;end select
 SET reply->status_data.status = "S"
 SUBROUTINE (replaceoefields(npromptidx=i4) =null)
   DECLARE sbegintag = vc WITH protect, constant("[OEFMarkerBegin]")
   DECLARE sendtag = vc WITH protect, constant("[OEFMarkerEnd]")
   DECLARE nbeginlocation = i4 WITH protect, noconstant(0)
   DECLARE nfieldidx = i4 WITH protect, noconstant(0)
   DECLARE stext = vc WITH protect, noconstant("")
   FOR (nfieldidx = 1 TO size(reply->prompt_test_qual[npromptidx].field_qual,5))
     SET stext = build(sbegintag,cnvtstring(reply->prompt_test_qual[npromptidx].field_qual[nfieldidx]
       .field_oe_field_id,20),sendtag)
     SET nbeginlocation = findstring(stext,reply->prompt_test_qual[npromptidx].text)
     SET reply->prompt_test_qual[npromptidx].text = replace(reply->prompt_test_qual[npromptidx].text,
      stext,concat("[",reply->prompt_test_qual[npromptidx].field_qual[nfieldidx].oe_field_display,"]"
       ),1)
   ENDFOR
   RETURN
 END ;Subroutine
#exit_aps_prt_db_prompt_fields
END GO
