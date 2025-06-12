CREATE PROGRAM bb_rpt_qc_templates:dba
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
   1 qual[*]
     2 template_name = vc
     2 active_ind = i2
     2 filters[*]
       3 filter_name = vc
       3 filter_set_nbr = i4
       3 display_seq_nbr = i4
       3 cdf_meaning = vc
       3 active_ind = i2
       3 defaults[*]
         4 filter_default_seq_nbr = i4
         4 filter_nbr = i4
         4 parent_entity_name = vc
         4 parent_entity_display = vc
 )
 RECORD tmptext2(
   1 qual[*]
     2 text = vc
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
 DECLARE li18nhandle = i4 WITH protect, noconstant(0)
 DECLARE ncount = i4 WITH protect, noconstant(0)
 DECLARE noriginalrow = i4 WITH protect, noconstant(0)
 DECLARE nmaxrow = i4 WITH protect, noconstant(0)
 DECLARE nmaxnum = i4 WITH protect, noconstant(0)
 DECLARE ntempcount = i4 WITH protect, noconstant(0)
 DECLARE ncount2 = i4 WITH protect, noconstant(0)
 DECLARE ncount3 = i4 WITH protect, noconstant(0)
 DECLARE ncount4 = i4 WITH protect, noconstant(0)
 DECLARE nbreak = i4 WITH protect, noconstant(0)
 DECLARE nsegcount = i4 WITH protect, noconstant(0)
 DECLARE nlinesperpage = i4 WITH protect, constant(57)
 DECLARE nlinelength = i4 WITH protect, constant(45)
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE j = i4 WITH protect, noconstant(0)
 DECLARE ssegment = vc WITH protect, noconstant("")
 DECLARE stype = vc WITH protect, noconstant("")
 DECLARE sweekday = vc WITH protect, noconstant("")
 DECLARE sweek = vc WITH protect, noconstant("")
 DECLARE scurstring = vc WITH protect, noconstant("")
 DECLARE serror = vc WITH protect, noconstant("")
 DECLARE snamehold = vc WITH protect, noconstant("")
 DECLARE stemphold = vc WITH protect, noconstant("")
 DECLARE stemphold2 = vc WITH protect, noconstant("")
 DECLARE nstartposn = i4 WITH protect, noconstant(0)
 DECLARE ncurposn = i4 WITH protect, noconstant(0)
 DECLARE sfiftyline = vc WITH protect, noconstant("")
 DECLARE sseventyeightline = vc WITH protect, noconstant("")
 DECLARE sequalsline = vc WITH protect, noconstant("")
 DECLARE sa_prev_wk = vc WITH protect, constant("A_PREV_WK")
 DECLARE sa_prev_mth = vc WITH protect, constant("A_PREV_MTH")
 DECLARE sa_wk_dt = vc WITH protect, constant("A_WK_DT")
 DECLARE sa_mth_dt = vc WITH protect, constant("A_MTH_DT")
 DECLARE sa_days = vc WITH protect, constant("A_DAYS")
 DECLARE sb_grp_name = vc WITH protect, constant("B_GRP_NAME")
 DECLARE sb_reagent = vc WITH protect, constant("B_REAGENT")
 DECLARE sb_reagent_lot = vc WITH protect, constant("B_REAGENT_LOT")
 DECLARE sb_cntrl_mtrl = vc WITH protect, constant("B_CNTRL_MTRL")
 DECLARE sb_cntrl_lot = vc WITH protect, constant("B_CNTRL_LOT")
 DECLARE sb_enhcmt_med = vc WITH protect, constant("B_ENHCMT_MED")
 DECLARE sb_enhcmt_lot = vc WITH protect, constant("B_ENHCMT_LOT")
 DECLARE sb_rslt_stat = vc WITH protect, constant("B_RSLT_STAT")
 DECLARE sb_serv_res = vc WITH protect, constant("B_SERV_RES")
 DECLARE sb_signoff = vc WITH protect, constant("B_SIGNOFF")
 DECLARE sb_signoff2 = vc WITH protect, constant("B_SIGNOFF2")
 DECLARE sb_rsult = vc WITH protect, constant("B_RSULT")
 DECLARE sb_abn_ind = vc WITH protect, constant("B_ABN_IND")
 SET reply->status_data.status = "F"
 SET nstatus = uar_i18nlocalizationinit(li18nhandle,curprog,"",curcclrev)
 RECORD captions(
   1 stitle = vc
   1 susername = vc
   1 sdomain = vc
   1 sdate = vc
   1 stemplate = vc
   1 stime = vc
   1 spage = vc
   1 sactive = vc
   1 stemplate = vc
   1 sfilter = vc
   1 scriteria = vc
   1 stemplatefilter = vc
   1 sfilterset = vc
   1 sendofreport = vc
 )
 SET captions->stitle = uar_i18ngetmessage(li18nhandle,"TITLE",
  "PathNet Blood Bank: QC Templates Report")
 SET captions->susername = uar_i18ngetmessage(li18nhandle,"NAME","Name:")
 SET captions->sdomain = uar_i18ngetmessage(li18nhandle,"DOMAIN","Domain:")
 SET captions->sdate = uar_i18ngetmessage(li18nhandle,"DATE","Date:")
 SET captions->stemplate = uar_i18ngetmessage(li18nhandle,"TEMPLATE","Template:")
 SET captions->stime = uar_i18ngetmessage(li18nhandle,"TIME","Time:")
 SET captions->spage = uar_i18ngetmessage(li18nhandle,"PAGE","Page:")
 SET captions->sactive = uar_i18ngetmessage(li18nhandle,"ACTIVE","Active")
 SET captions->stemplate = uar_i18ngetmessage(li18nhandle,"TEMPLATE","Template: ")
 SET captions->sfilter = uar_i18ngetmessage(li18nhandle,"FILTER","Filter")
 SET captions->scriteria = uar_i18ngetmessage(li18nhandle,"CRITERIA","Criteria")
 SET captions->stemplatefilter = uar_i18ngetmessage(li18nhandle,"TEMPLATEFILTER","Template Filter:")
 SET captions->sfilterset = uar_i18ngetmessage(li18nhandle,"FILTERSET","Filter Set:")
 SET captions->sendofreport = uar_i18ngetmessage(li18nhandle,"ENDOFREPORT",
  "* * * End of Report * * *")
 SELECT INTO "nl:"
  code_value_name = uar_get_code_display(pcfd.parent_entity_id), pcf_ind = evaluate(nullind(pcfd
    .filter_id),0,1,0)
  FROM pcs_qc_filter pcf,
   code_value cv1,
   code_value cv2,
   pcs_qc_filter_default pcfd
  PLAN (pcf
   WHERE (((request->template_cd=0)) OR ((pcf.template_cd=request->template_cd)))
    AND pcf.filter_id > 0)
   JOIN (cv1
   WHERE cv1.code_value=pcf.template_cd
    AND cv1.code_set=255232
    AND cv1.cdf_meaning="BB"
    AND (((request->active_ind=1)) OR ((cv1.active_ind=request->active_ind))) )
   JOIN (cv2
   WHERE cv2.code_set=255231
    AND cv2.code_value=pcf.filter_cd)
   JOIN (pcfd
   WHERE (pcfd.filter_id= Outerjoin(pcf.filter_id)) )
  ORDER BY pcf.template_cd, cv1.display_key, pcf.filter_set_nbr,
   pcf.filter_id, pcf.display_seq_nbr, pcfd.filter_default_seq_nbr
  HEAD pcf.template_cd
   ntempcount += 1
   IF (ntempcount > size(params->qual,5))
    nstatus = alterlist(params->qual,(ntempcount+ 9))
   ENDIF
   params->qual[ntempcount].template_name = cv1.display, params->qual[ntempcount].active_ind = cv1
   .active_ind, ncount = 0
  HEAD pcf.filter_id
   ncount += 1
   IF (ncount > size(params->qual[ntempcount].filters,5))
    nstatus = alterlist(params->qual[ntempcount].filters,(ncount+ 9))
   ENDIF
   params->qual[ntempcount].filters[ncount].filter_name = cv2.description, params->qual[ntempcount].
   filters[ncount].active_ind = cv2.active_ind, params->qual[ntempcount].filters[ncount].
   filter_set_nbr = pcf.filter_set_nbr,
   params->qual[ntempcount].filters[ncount].display_seq_nbr = pcf.display_seq_nbr, params->qual[
   ntempcount].filters[ncount].cdf_meaning = cv2.cdf_meaning, nsegcount = 0
  DETAIL
   IF (pcf_ind=1)
    nsegcount += 1
    IF (nsegcount > size(params->qual[ntempcount].filters[ncount].defaults,5))
     nstatus = alterlist(params->qual[ntempcount].filters[ncount].defaults,(nsegcount+ 9))
    ENDIF
    params->qual[ntempcount].filters[ncount].defaults[nsegcount].filter_default_seq_nbr = pcfd
    .filter_default_seq_nbr, params->qual[ntempcount].filters[ncount].defaults[nsegcount].filter_nbr
     = pcfd.filter_nbr, params->qual[ntempcount].filters[ncount].defaults[nsegcount].
    parent_entity_name = pcfd.parent_entity_name,
    params->qual[ntempcount].filters[ncount].defaults[nsegcount].parent_entity_display =
    code_value_name
   ENDIF
  FOOT  pcf.filter_id
   nstatus = alterlist(params->qual[ntempcount].filters[ncount].defaults,nsegcount)
  FOOT  pcf.template_cd
   nstatus = alterlist(params->qual[ntempcount].filters,ncount)
  FOOT REPORT
   nstatus = alterlist(params->qual,ntempcount)
  WITH nocounter
 ;end select
 IF (error(serror,0) > 0)
  CALL subevent_add("REPORT","F","bb_rpt_qc_templates",serror)
  GO TO exit_script
 ENDIF
 EXECUTE cpm_create_file_name "bb_tem", "txt"
 IF ((cpm_cfn_info->status_data.status != "S"))
  CALL subevent_add("REPORT","F","bb_rpt_qc_templates","Failed to create a file name")
  GO TO exit_script
 ENDIF
 IF (size(params->qual,5)=0)
  SELECT INTO cpm_cfn_info->file_name_path
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   HEAD REPORT
    ssingleline = fillstring(130,"-"), sdoubleline = fillstring(130,"="), sfiftyline = fillstring(50,
     "-"),
    sseventyeightline = fillstring(78,"-"), sverticalline = "|"
   DETAIL
    row 1,
    CALL center(captions->stitle,1,130), row + 1,
    col 1, captions->susername, col 9,
    request->username, col 117, captions->sdate,
    col 123, curdate"@SHORTDATE", row + 1,
    col 1, captions->sdomain, col 9,
    request->domain, col 117, captions->stime,
    col 123, curtime3"@TIMEWITHSECONDS"
   FOOT PAGE
    row nlinesperpage, row + 2, col 120,
    captions->spage, col + 2, curpage"####;L"
   FOOT REPORT
    row + 0
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO cpm_cfn_info->file_name_path
   FROM (dummyt d  WITH seq = value(size(params->qual,5)))
   PLAN (d)
   HEAD REPORT
    ssingleline = fillstring(130,"-"), sdoubleline = fillstring(130,"="), sfiftyline = fillstring(50,
     "-"),
    sseventyeightline = fillstring(78,"-"), sverticalline = "|"
   HEAD PAGE
    IF (((d.seq < value(size(params->qual,5))) OR (((nbreak=1) OR (value(size(params->qual,5))=1))
    )) )
     IF (((value(size(params->qual,5))=1
      AND ((nbreak=1) OR (nfirsttime=1)) ) OR (value(size(params->qual,5)) > 1)) )
      row 1,
      CALL center(captions->stitle,1,130), row + 1,
      col 1, captions->susername, col 9,
      request->username, col 117, captions->sdate,
      col 123, curdate"@SHORTDATE", row + 1,
      col 1, captions->sdomain, col 9,
      request->domain, col 117, captions->stime,
      col 123, curtime3"@TIMEWITHSECONDS", row + 1
      IF (nbreak=1)
       row + 1
      ENDIF
      nfirsttime = 0
     ENDIF
    ENDIF
   DETAIL
    row + 1, col 1, captions->stemplate,
    col 11, params->qual[d.seq].template_name, row + 2,
    col 1, captions->sfilter, col 53,
    captions->scriteria, row + 1, col 1,
    sfiftyline, col 53, sseventyeightline,
    row + 1
    FOR (i = 1 TO size(params->qual[d.seq].filters,5))
      stemphold = " ", snamehold = " "
      IF ((params->qual[d.seq].filters[i].cdf_meaning IN (sb_grp_name, sb_reagent, sb_reagent_lot,
      sb_cntrl_mtrl, sb_cntrl_lot,
      sb_enhcmt_med, sb_enhcmt_lot, sb_rslt_stat, sb_serv_res, sb_signoff,
      sb_signoff2, sb_rsult)))
       snamehold = params->qual[d.seq].filters[i].filter_name
       FOR (j = 1 TO size(params->qual[d.seq].filters[i].defaults,5))
         IF (stemphold=" ")
          stemphold = params->qual[d.seq].filters[i].defaults[j].parent_entity_display
         ELSE
          stemphold = concat(stemphold,", ",params->qual[d.seq].filters[i].defaults[j].
           parent_entity_display)
         ENDIF
       ENDFOR
      ELSEIF ((params->qual[d.seq].filters[i].cdf_meaning IN (sa_prev_wk, sa_prev_mth, sa_wk_dt,
      sa_mth_dt, sa_days,
      sb_abn_ind)))
       snamehold = params->qual[d.seq].filters[i].filter_name
       FOR (j = 1 TO size(params->qual[d.seq].filters[i].defaults,5))
         IF (stemphold=" ")
          stemphold = concat(trim(cnvtstring(params->qual[d.seq].filters[i].defaults[j].filter_nbr)),
           " ",params->qual[d.seq].filters[i].defaults[j].parent_entity_display)
         ELSE
          stemphold = concat(stemphold," ",trim(cnvtstring(params->qual[d.seq].filters[i].defaults[j]
             .filter_nbr))," ",params->qual[d.seq].filters[i].defaults[j].parent_entity_display)
         ENDIF
       ENDFOR
      ENDIF
      tblobin = " ", tblobin = trim(snamehold),
      CALL rtf_to_text(trim(tblobin),1,32),
      ncount4 = 0, nstatus = alterlist(tmptext2->qual,0)
      FOR (j = 1 TO size(tmptext->qual,5))
        ncount4 += 1
        IF (ncount4 > size(tmptext2->qual,5))
         nstatus = alterlist(tmptext2->qual,(ncount4+ 9))
        ENDIF
        tmptext2->qual[j].text = tmptext->qual[j].text
      ENDFOR
      nstatus = alterlist(tmptext2->qual,ncount4), nstatus = alterlist(tmptext->qual,0), tblobin =
      " ",
      tblobin = trim(stemphold),
      CALL rtf_to_text(trim(tblobin),1,70)
      IF (size(tmptext2->qual,5) >= size(tmptext->qual,5))
       nmaxnum = size(tmptext2->qual,5)
      ELSE
       nmaxnum = size(tmptext->qual,5)
      ENDIF
      IF ((nmaxnum > (nlinesperpage - 12)))
       CALL echo("Detail won't fit on page.  Should go to exit_script.")
      ENDIF
      IF ((((row+ nmaxnum)+ 3) >= nlinesperpage))
       nbreak = 1, BREAK
      ELSE
       nbreak = 0
      ENDIF
      IF (nmaxnum > 0)
       IF ((params->qual[d.seq].filters[i].filter_set_nbr=0))
        col 1, captions->stemplatefilter
       ELSE
        col 1, captions->sfilterset, sfilternbr = trim(cnvtstring(params->qual[d.seq].filters[i].
          filter_set_nbr)),
        col 13, sfilternbr
       ENDIF
       FOR (j = 1 TO nmaxnum)
         IF (j <= size(tmptext2->qual,5))
          col 18, tmptext2->qual[j].text
         ENDIF
         IF (j <= size(tmptext->qual,5))
          col 53, tmptext->qual[j].text
         ENDIF
         row + 1
       ENDFOR
      ENDIF
    ENDFOR
    col 1, ssingleline, row + 1
    IF (d.seq=value(size(params->qual,5)))
     col 51, captions->sendofreport
    ENDIF
   FOOT PAGE
    row nlinesperpage, row + 2, col 120,
    captions->spage, col + 2, curpage"####;L"
   FOOT REPORT
    row + 0
   WITH nocounter
  ;end select
 ENDIF
 IF (error(serror,0) > 0)
  CALL subevent_add("REPORT","F","bb_rpt_qc_templates",serror)
  GO TO exit_script
 ENDIF
 SET reply->file_name = cpm_cfn_info->file_name_path
 SET reply->node = curnode
 SET reply->status_data.status = "S"
#exit_script
 FREE RECORD params
 FREE RECORD captions
END GO
