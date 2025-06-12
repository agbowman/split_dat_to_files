CREATE PROGRAM aps_prt_db_cyto_std_rpts:dba
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
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD captions(
   1 rptaps = vc
   1 pathnetap = vc
   1 date = vc
   1 directory = vc
   1 ttime = vc
   1 refdbaudit = vc
   1 bby = vc
   1 cytostdrpt = vc
   1 ppage = vc
   1 rreport = vc
   1 stdrptseq = vc
   1 noseqspecified = vc
   1 stdreport = vc
   1 nostdrptdefined = vc
   1 active = vc
   1 inactive = vc
   1 procedure = vc
   1 status = vc
   1 resultvalue = vc
   1 required = vc
   1 notrequired = vc
   1 continued = vc
 )
 SET captions->rptaps = uar_i18ngetmessage(i18nhandle,"h1","REPORT:  APS_PRT_DB_CYTO_STD_RPTS.PRG")
 SET captions->pathnetap = uar_i18ngetmessage(i18nhandle,"h2","PATHNET ANATOMIC PATHOLOGY")
 SET captions->date = uar_i18ngetmessage(i18nhandle,"h3","DATE:")
 SET captions->directory = uar_i18ngetmessage(i18nhandle,"h4","DIRECTORY:")
 SET captions->ttime = uar_i18ngetmessage(i18nhandle,"h5","TIME:")
 SET captions->refdbaudit = uar_i18ngetmessage(i18nhandle,"h6","REFERENCE DATABASE AUDIT")
 SET captions->bby = uar_i18ngetmessage(i18nhandle,"h7","BY:")
 SET captions->cytostdrpt = uar_i18ngetmessage(i18nhandle,"h8","DB CYTOLOGY STANDARD REPORT TOOL")
 SET captions->ppage = uar_i18ngetmessage(i18nhandle,"h9","PAGE:")
 SET captions->rreport = uar_i18ngetmessage(i18nhandle,"h10","Report:")
 SET captions->stdrptseq = uar_i18ngetmessage(i18nhandle,"h11","STANDARD REPORT SEQUENCE:")
 SET captions->noseqspecified = uar_i18ngetmessage(i18nhandle,"h12","No sequence specified.")
 SET captions->stdreport = uar_i18ngetmessage(i18nhandle,"h13","STANDARD REPORT:")
 SET captions->nostdrptdefined = uar_i18ngetmessage(i18nhandle,"h14","No standard reports defined")
 SET captions->active = uar_i18ngetmessage(i18nhandle,"h15","ACTIVE")
 SET captions->inactive = uar_i18ngetmessage(i18nhandle,"h16","INACTIVE")
 SET captions->procedure = uar_i18ngetmessage(i18nhandle,"h17","PROCEDURE")
 SET captions->status = uar_i18ngetmessage(i18nhandle,"h18","STATUS")
 SET captions->resultvalue = uar_i18ngetmessage(i18nhandle,"h19","RESULT VALUE")
 SET captions->required = uar_i18ngetmessage(i18nhandle,"h20","REQUIRED")
 SET captions->notrequired = uar_i18ngetmessage(i18nhandle,"h21","NOT REQUIRED")
 SET captions->continued = uar_i18ngetmessage(i18nhandle,"f1","CONTINUED...")
 SET week = format(curdate,"@WEEKDAYABBREV;;Q")
 SET day = format(curdate,"@MEDIUMDATE;;Q")
 RECORD temp(
   1 max_sr_quals = i4
   1 max_srr_quals = i4
   1 report_qual[*]
     2 catalog_cd = f8
     2 short_desc = c40
     2 long_desc = c60
     2 num_of_hot_keys = i4
     2 sr_qual[*]
       3 standard_rpt_cd = f8
       3 hot_key_sequence = i4
       3 sort_hot_key_sequence = c1
       3 code = c5
       3 description = vc
       3 active_ind = i2
       3 srr_qual[*]
         4 task_assay_cd = f8
         4 task_assay_disp = c25
         4 pending_ind = i2
         4 nomenclature_id = f8
         4 result_disp = c40
         4 result_text = vc
 )
 RECORD reply(
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
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET x = 0
 SET err_cnt = 0
 DECLARE interp_code = f8 WITH protect, noconstant(0.0)
 DECLARE alpha_code = f8 WITH protect, noconstant(0.0)
 DECLARE text_code = f8 WITH protect, noconstant(0.0)
 SET dt_cnt = 0
 SET sr_cnt = 0
 SELECT INTO "nl:"
  oc.catalog_cd
  FROM order_catalog oc,
   cyto_report_control crc
  PLAN (crc
   WHERE crc.catalog_cd != 0.0)
   JOIN (oc
   WHERE crc.catalog_cd=oc.catalog_cd)
  HEAD REPORT
   cntr = 0
  DETAIL
   cntr += 1, stat = alterlist(temp->report_qual,cntr), temp->report_qual[cntr].catalog_cd = oc
   .catalog_cd,
   temp->report_qual[cntr].short_desc = oc.primary_mnemonic, temp->report_qual[cntr].long_desc = oc
   .description
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv1.code_value
  FROM code_value cv1
  WHERE 289=cv1.code_set
   AND cv1.cdf_meaning IN ("1", "2", "4")
  HEAD REPORT
   interp_code = 0, alpha_code = 0, text_code = 0
  DETAIL
   IF (cv1.cdf_meaning="1")
    text_code = cv1.code_value
   ENDIF
   IF (cv1.cdf_meaning="2")
    alpha_code = cv1.code_value
   ENDIF
   IF (cv1.cdf_meaning="4")
    interp_code = cv1.code_value
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  rep_catalog_cd = temp->report_qual[d.seq].catalog_cd, csr.standard_rpt_id, csr.catalog_cd,
  csr.description, csr.hot_key_sequence, csrr.task_assay_cd,
  n.mnemonic
  FROM (dummyt d  WITH seq = value(size(temp->report_qual,5))),
   cyto_standard_rpt csr,
   dummyt d2,
   cyto_standard_rpt_r csrr,
   nomenclature n
  PLAN (d)
   JOIN (csr
   WHERE (csr.catalog_cd=temp->report_qual[d.seq].catalog_cd))
   JOIN (d2)
   JOIN (csrr
   WHERE csr.standard_rpt_id=csrr.standard_rpt_id)
   JOIN (n
   WHERE csrr.nomenclature_id=n.nomenclature_id)
  ORDER BY rep_catalog_cd, csr.standard_rpt_id, csrr.task_assay_cd
  HEAD REPORT
   sr_cnt = 0, srr_cnt = 0, cat_cntr = 0
  HEAD rep_catalog_cd
   sr_cnt = 0
  HEAD csr.standard_rpt_id
   sr_cnt += 1
   IF ((sr_cnt > temp->max_sr_quals))
    temp->max_sr_quals = sr_cnt
   ENDIF
   stat = alterlist(temp->report_qual[d.seq].sr_qual,sr_cnt), temp->report_qual[d.seq].sr_qual[sr_cnt
   ].standard_rpt_cd = csr.standard_rpt_id, temp->report_qual[d.seq].sr_qual[sr_cnt].description =
   csr.description,
   temp->report_qual[d.seq].sr_qual[sr_cnt].active_ind = csr.active_ind
   IF (csr.hot_key_sequence=0)
    temp->report_qual[d.seq].sr_qual[sr_cnt].sort_hot_key_sequence = "C"
   ELSE
    IF (csr.hot_key_sequence=10)
     temp->report_qual[d.seq].sr_qual[sr_cnt].sort_hot_key_sequence = "B", temp->report_qual[d.seq].
     sr_qual[sr_cnt].hot_key_sequence = csr.hot_key_sequence
    ELSE
     temp->report_qual[d.seq].sr_qual[sr_cnt].sort_hot_key_sequence = "A", temp->report_qual[d.seq].
     sr_qual[sr_cnt].hot_key_sequence = csr.hot_key_sequence
    ENDIF
   ENDIF
   IF (csr.active_ind=0)
    temp->report_qual[d.seq].sr_qual[sr_cnt].sort_hot_key_sequence = "D", temp->report_qual[d.seq].
    sr_qual[sr_cnt].hot_key_sequence = csr.hot_key_sequence
   ENDIF
   temp->report_qual[d.seq].num_of_hot_keys += 1, temp->report_qual[d.seq].sr_qual[sr_cnt].code = csr
   .short_desc, srr_cnt = 0
  HEAD csrr.task_assay_cd
   srr_cnt += 1
   IF ((srr_cnt > temp->max_srr_quals))
    temp->max_srr_quals = srr_cnt
   ENDIF
   stat = alterlist(temp->report_qual[d.seq].sr_qual[sr_cnt].srr_qual,srr_cnt), temp->report_qual[d
   .seq].sr_qual[sr_cnt].srr_qual[srr_cnt].task_assay_cd = csrr.task_assay_cd, temp->report_qual[d
   .seq].sr_qual[sr_cnt].srr_qual[srr_cnt].nomenclature_id = csrr.nomenclature_id
   IF (csrr.nomenclature_id > 0)
    temp->report_qual[d.seq].sr_qual[sr_cnt].srr_qual[srr_cnt].result_disp = n.mnemonic
   ENDIF
   IF (csrr.result_text > " ")
    temp->report_qual[d.seq].sr_qual[sr_cnt].srr_qual[srr_cnt].result_text = trim(csrr.result_text)
   ENDIF
  WITH nocounter, outerjoin = d2
 ;end select
 SELECT INTO "nl:"
  rep_catalog_cd = temp->report_qual[d1.seq].catalog_cd, std_rpt_cd = temp->report_qual[d1.seq].
  sr_qual[d2.seq].standard_rpt_cd, task_assay_cd = temp->report_qual[d1.seq].sr_qual[d2.seq].
  srr_qual[d3.seq].task_assay_cd,
  nomenclature_id = temp->report_qual[d1.seq].sr_qual[d2.seq].srr_qual[d3.seq].nomenclature_id,
  dta_description = trim(dta.description), ptr.pending_ind,
  dta.*
  FROM (dummyt d1  WITH seq = value(size(temp->report_qual,5))),
   (dummyt d2  WITH seq = value(temp->max_sr_quals)),
   (dummyt d3  WITH seq = value(temp->max_srr_quals)),
   discrete_task_assay dta,
   profile_task_r ptr
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp->report_qual[d1.seq].sr_qual,5))
   JOIN (d3
   WHERE d3.seq <= size(temp->report_qual[d1.seq].sr_qual[d2.seq].srr_qual,5))
   JOIN (dta
   WHERE (temp->report_qual[d1.seq].sr_qual[d2.seq].srr_qual[d3.seq].task_assay_cd=dta.task_assay_cd)
   )
   JOIN (ptr
   WHERE (temp->report_qual[d1.seq].catalog_cd=ptr.catalog_cd)
    AND ptr.active_ind=1
    AND cnvtdatetime(sysdate) BETWEEN ptr.beg_effective_dt_tm AND ptr.end_effective_dt_tm
    AND dta.task_assay_cd=ptr.task_assay_cd)
  ORDER BY rep_catalog_cd, std_rpt_cd, d3.seq
  DETAIL
   temp->report_qual[d1.seq].sr_qual[d2.seq].srr_qual[d3.seq].task_assay_disp = dta_description, temp
   ->report_qual[d1.seq].sr_qual[d2.seq].srr_qual[d3.seq].pending_ind = ptr.pending_ind
  WITH nocounter
 ;end select
#report_maker
 EXECUTE cpm_create_file_name_logical "apsDbCytoStdRpt", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SELECT INTO value(reply->print_status_data.print_filename)
  short_desc = temp->report_qual[d1.seq].short_desc, long_desc = temp->report_qual[d1.seq].long_desc,
  hot_key_seq = temp->report_qual[d1.seq].sr_qual[d3.seq].hot_key_sequence,
  sr_code = temp->report_qual[d1.seq].sr_qual[d3.seq].code, sr_code_desc = temp->report_qual[d1.seq].
  sr_qual[d3.seq].description, sr_active_ind = temp->report_qual[d1.seq].sr_qual[d3.seq].active_ind,
  hot_key_and_code = build(temp->report_qual[d1.seq].sr_qual[d3.seq].sort_hot_key_sequence,temp->
   report_qual[d1.seq].sr_qual[d3.seq].hot_key_sequence,temp->report_qual[d1.seq].sr_qual[d3.seq].
   code), srr_task_assay_cd = temp->report_qual[d1.seq].sr_qual[d3.seq].srr_qual[d4.seq].
  task_assay_cd, srr_nomenclature_id = temp->report_qual[d1.seq].sr_qual[d3.seq].srr_qual[d4.seq].
  nomenclature_id,
  srr_result_text = temp->report_qual[d1.seq].sr_qual[d3.seq].srr_qual[d4.seq].result_text,
  sr_standard_rpt_cd = temp->report_qual[d1.seq].sr_qual[d3.seq].standard_rpt_cd
  FROM (dummyt d1  WITH seq = value(size(temp->report_qual,5))),
   dummyt o1,
   (dummyt d3  WITH seq = value(temp->max_sr_quals)),
   (dummyt d4  WITH seq = value(temp->max_srr_quals))
  PLAN (d1)
   JOIN (o1)
   JOIN (d3
   WHERE d3.seq <= size(temp->report_qual[d1.seq].sr_qual,5))
   JOIN (d4
   WHERE d4.seq <= size(temp->report_qual[d1.seq].sr_qual[d3.seq].srr_qual,5))
  ORDER BY short_desc, hot_key_and_code, sr_standard_rpt_cd,
   srr_task_assay_cd
  HEAD REPORT
   line1 = fillstring(125,"-")
  HEAD PAGE
   row + 1, col 0, captions->rptaps,
   col 0,
   CALL center(captions->pathnetap,0,132), col 110,
   captions->date, col 117, curdate"@SHORTDATE;;Q",
   row + 1, col 0, captions->directory,
   col 110, captions->ttime, col 117,
   curtime, row + 1, col 0,
   CALL center(captions->refdbaudit,0,132), col 112, captions->bby,
   col 117, request->scuruser"##############", row + 1,
   col 0,
   CALL center(captions->cytostdrpt,0,132), col 110,
   captions->ppage, col 117, curpage"###",
   row + 1
  HEAD short_desc
   row + 1, col 1, captions->rreport,
   "  ", col 9, short_desc,
   row + 1, col 9, long_desc,
   row + 2, col 9, captions->stdrptseq,
   "  "
   IF ((temp->report_qual[d1.seq].num_of_hot_keys > 0))
    position_number = 1, code_position_col = 35
    FOR (loop1 = 1 TO temp->report_qual[d1.seq].num_of_hot_keys)
     loop = 1,
     WHILE ((loop <= temp->report_qual[d1.seq].num_of_hot_keys))
      IF ((temp->report_qual[d1.seq].sr_qual[loop].hot_key_sequence=position_number))
       col code_position_col, temp->report_qual[d1.seq].sr_qual[loop].code, code_position_col += 10,
       position_number += 1
      ENDIF
      ,loop += 1
     ENDWHILE
    ENDFOR
   ELSE
    col 35, captions->noseqspecified
   ENDIF
   row + 1
  HEAD hot_key_and_code
   IF (((row+ 12) > maxrow))
    BREAK
   ENDIF
   row + 1, col 9, captions->stdreport,
   "  "
   IF (sr_code > " ")
    col 27, sr_code, col 35,
    sr_code_desc
   ELSE
    col 27, captions->nostdrptdefined
   ENDIF
   row + 1, col 27
   IF (sr_active_ind=1)
    IF (sr_code > " ")
     captions->active
    ELSE
     " "
    ENDIF
   ELSE
    captions->inactive
   ENDIF
   row + 2, col 27, captions->procedure,
   col 54, captions->status, col 70,
   captions->resultvalue, row + 1, col 27,
   "-------------------------", col 54, "--------------",
   col 70, "------------------------------------------------------------"
  HEAD srr_task_assay_cd
   IF ((temp->report_qual[d1.seq].sr_qual[d3.seq].srr_qual[d4.seq].nomenclature_id > 0))
    row + 1, col 27, temp->report_qual[d1.seq].sr_qual[d3.seq].srr_qual[d4.seq].task_assay_disp
    IF ((temp->report_qual[d1.seq].sr_qual[d3.seq].srr_qual[d4.seq].pending_ind=1))
     col 54, captions->required
    ELSE
     col 54, captions->notrequired
    ENDIF
    col 70, temp->report_qual[d1.seq].sr_qual[d3.seq].srr_qual[d4.seq].result_disp
   ELSEIF ((temp->report_qual[d1.seq].sr_qual[d3.seq].srr_qual[d4.seq].nomenclature_id=0))
    IF ((temp->report_qual[d1.seq].sr_qual[d3.seq].srr_qual[d4.seq].result_text > " "))
     row + 1, col 27, temp->report_qual[d1.seq].sr_qual[d3.seq].srr_qual[d4.seq].task_assay_disp
     IF ((temp->report_qual[d1.seq].sr_qual[d3.seq].srr_qual[d4.seq].pending_ind=1))
      col 54, captions->required
     ELSE
      col 54, captions->notrequired
     ENDIF
     IF ((temp->report_qual[d1.seq].sr_qual[d3.seq].srr_qual[d4.seq].nomenclature_id > 0))
      col 70, temp->report_qual[d1.seq].sr_qual[d3.seq].srr_qual[d4.seq].result_text
     ELSE
      CALL rtf_to_text(trim(temp->report_qual[d1.seq].sr_qual[d3.seq].srr_qual[d4.seq].result_text),1,
      60)
      IF ((((size(tmptext->qual,5)+ row)+ 10) >= maxrow))
       BREAK
      ENDIF
      FOR (ntextlinecnt = 1 TO size(tmptext->qual,5))
        IF (((row+ 10) > maxrow))
         BREAK
        ENDIF
        col 70, tmptext->qual[ntextlinecnt].text
        IF (ntextlinecnt != size(tmptext->qual,5))
         row + 1
        ENDIF
      ENDFOR
     ENDIF
    ENDIF
   ENDIF
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
  FOOT  hot_key_and_code
   row + 1
  FOOT  short_desc
   row + 1, col 55, "* * * * * * * * * *",
   row + 1
  FOOT PAGE
   row 60, col 0, line1,
   row + 1, col 0, captions->rptaps,
   today = concat(week," ",day), col 53, today,
   col 110, captions->ppage, col 117,
   curpage"###", row + 1, col 55,
   captions->continued
  FOOT REPORT
   col 55, "##########  "
  WITH nocounter, outerjoin = o1, maxcol = 132,
   nullreport, maxrow = 63, compress
 ;end select
 SET reply->status_data.status = "S"
END GO
