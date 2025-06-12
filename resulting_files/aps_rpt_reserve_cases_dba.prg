CREATE PROGRAM aps_rpt_reserve_cases:dba
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
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD temp(
   1 qual[*]
     2 prefix_cd = f8
     2 prefix_name = c2
     2 site_cd = f8
     2 site_disp = c40
     2 accession_nbr = c21
     2 case_id = f8
     2 case_reserved_dt_tm = dq8
     2 accession_prsnl_id = f8
     2 accession_user_name = vc
     2 person_id = c16
     2 encounter_id = f8
     2 person_name = vc
     2 comments_long_text_id = f8
     2 text_cnt = i4
     2 text_qual[*]
       3 comment = vc
 )
 RECORD temp_pref(
   1 pref_qual[*]
     2 prefix_cd = f8
     2 prefix_name = c2
     2 site_cd = f8
     2 site_disp = c40
 )
 RECORD reply(
   1 ops_event = vc
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
 RECORD captions(
   1 rpt = vc
   1 ana = vc
   1 dt = vc
   1 dir = vc
   1 tm = vc
   1 res_list = vc
   1 bye = vc
   1 pg = vc
   1 pre = vc
   1 cse = vc
   1 res = vc
   1 bby = vc
   1 p_nm = vc
   1 com = vc
   1 non = vc
   1 des = vc
   1 title = vc
   1 cont = vc
   1 end_rpt = vc
 )
 SET captions->rpt = uar_i18ngetmessage(i18nhandle,"t1","REPORT: APS_RPT_RESERVE_CASES.PRG")
 SET captions->ana = uar_i18ngetmessage(i18nhandle,"t2","Anatomic Pathology")
 SET captions->dt = uar_i18ngetmessage(i18nhandle,"t3","DATE:")
 SET captions->dir = uar_i18ngetmessage(i18nhandle,"t4","DIRECTORY:")
 SET captions->tm = uar_i18ngetmessage(i18nhandle,"t5","TIME:")
 SET captions->res_list = uar_i18ngetmessage(i18nhandle,"t6","RESERVED CASE NUMBER LISTING")
 SET captions->bye = uar_i18ngetmessage(i18nhandle,"t7","BY:")
 SET captions->pg = uar_i18ngetmessage(i18nhandle,"t8","PAGE:")
 SET captions->pre = uar_i18ngetmessage(i18nhandle,"t9","Prefix(es)  :")
 SET captions->cse = uar_i18ngetmessage(i18nhandle,"t10","CASE")
 SET captions->res = uar_i18ngetmessage(i18nhandle,"t11","RESERVED")
 SET captions->bby = uar_i18ngetmessage(i18nhandle,"t12","BY")
 SET captions->p_nm = uar_i18ngetmessage(i18nhandle,"t13","PERSON NAME/ID")
 SET captions->com = uar_i18ngetmessage(i18nhandle,"t14","COMMENT")
 SET captions->non = uar_i18ngetmessage(i18nhandle,"t15","No cases matching criteria were found.")
 SET captions->des = uar_i18ngetmessage(i18nhandle,"t16","NOT DESIGNATED")
 SET captions->title = uar_i18ngetmessage(i18nhandle,"t17","REPORT: RESERVED CASE NUMBER LISTING")
 SET captions->cont = uar_i18ngetmessage(i18nhandle,"t18","CONTINUED...")
 SET captions->end_rpt = uar_i18ngetmessage(i18nhandle,"t19","### END OF REPORT ###")
 SET x = 1
 SET nbr_of_prefixes = cnvtint(size(request->request_qual,5))
 SET stat = alterlist(temp_pref->pref_qual,nbr_of_prefixes)
 SELECT INTO "nl:"
  ap.*
  FROM (dummyt d  WITH seq = value(size(request->request_qual,5))),
   ap_prefix ap,
   code_value cv
  PLAN (d)
   JOIN (ap
   WHERE (request->request_qual[d.seq].prefix_cd=ap.prefix_id))
   JOIN (cv
   WHERE cv.code_value=ap.site_cd)
  DETAIL
   temp_pref->pref_qual[d.seq].prefix_cd = request->request_qual[d.seq].prefix_cd, temp_pref->
   pref_qual[d.seq].prefix_name = ap.prefix_name, temp_pref->pref_qual[d.seq].site_cd = ap.site_cd,
   temp_pref->pref_qual[d.seq].site_disp = cv.display
  WITH nocounter
 ;end select
 SET x = 1
 SET no_cases_found = "F"
 SET nbr_of_prefixes = cnvtint(size(request->request_qual,5))
 SET cnt = 0
 SET code_value = 0.0
 SET mrn_alias_type_cd = 0.0
 SET code_set = 319
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_type_cd = code_value
 SELECT INTO "nl:"
  pc.accession_nbr, ap.prefix_name, frmt_mrn = cnvtalias(ea.alias,ea.alias_pool_cd),
  cv.display, pr.name_full_formatted, p.name_full_formatted
  FROM (dummyt d  WITH seq = value(size(request->request_qual,5))),
   pathology_case pc,
   ap_prefix ap,
   code_value cv,
   (dummyt d1  WITH seq = 1),
   prsnl pr,
   (dummyt d2  WITH seq = 1),
   person p,
   (dummyt d3  WITH seq = 1),
   encntr_alias ea,
   (dummyt d4  WITH seq = 1),
   encounter e
  PLAN (d)
   JOIN (pc
   WHERE (request->request_qual[d.seq].prefix_cd=pc.prefix_id)
    AND pc.reserved_ind=1)
   JOIN (ap
   WHERE pc.prefix_id=ap.prefix_id)
   JOIN (cv
   WHERE cv.code_value=ap.site_cd)
   JOIN (d1)
   JOIN (pr
   WHERE pc.accession_prsnl_id=pr.person_id)
   JOIN (d2)
   JOIN (p
   WHERE pc.person_id=p.person_id)
   JOIN (d3)
   JOIN (e
   WHERE pc.encntr_id=e.encntr_id
    AND e.active_ind=1
    AND e.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND e.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (d4)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mrn_alias_type_cd
    AND ea.active_ind=1)
  ORDER BY pc.accession_nbr
  HEAD pc.accession_nbr
   cnt += 1, stat = alterlist(temp->qual,cnt), temp->qual[cnt].prefix_cd = pc.prefix_id,
   temp->qual[cnt].prefix_name = ap.prefix_name, temp->qual[cnt].site_cd = ap.site_cd, temp->qual[cnt
   ].site_disp = cv.display,
   temp->qual[cnt].accession_nbr = pc.accession_nbr, temp->qual[cnt].case_id = pc.case_id, temp->
   qual[cnt].case_reserved_dt_tm = cnvtdatetime(pc.accessioned_dt_tm),
   temp->qual[cnt].accession_prsnl_id = pc.accession_prsnl_id, temp->qual[cnt].accession_user_name =
   pr.username
   IF (ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mrn_alias_type_cd)
    temp->qual[cnt].person_id = frmt_mrn
   ELSE
    temp->qual[cnt].person_id = "Unknown"
   ENDIF
   temp->qual[cnt].person_name = p.name_full_formatted, temp->qual[cnt].comments_long_text_id = pc
   .comments_long_text_id, blob_cntr = 0
  WITH nocounter, outerjoin = d1, outerjoin = d2,
   outerjoin = d3, outerjoin = d4, maxcol = 132
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHOLOGY_CASE"
  SET reply->status_data.status = "Z"
  SET no_cases_found = "T"
  GO TO report_maker
 ELSE
  SET reply->status_data.status = "S"
  SET no_cases_found = "F"
 ENDIF
 SELECT INTO "nl:"
  lt.long_text_id, temp->qual[d1.seq].accession_nbr
  FROM long_text lt,
   (dummyt d1  WITH seq = value(size(temp->qual,5)))
  PLAN (d1
   WHERE (temp->qual[d1.seq].comments_long_text_id > 0))
   JOIN (lt
   WHERE (temp->qual[d1.seq].comments_long_text_id=lt.long_text_id)
    AND lt.parent_entity_name="PATHOLOGY_CASE"
    AND (lt.parent_entity_id=temp->qual[d1.seq].case_id))
  HEAD REPORT
   blob_cntr = 0
  HEAD d1.seq
   blob_cntr = 0
  DETAIL
   CALL rtf_to_text(lt.long_text,1,40)
   FOR (z = 1 TO size(tmptext->qual,5))
     blob_cntr += 1, stat = alterlist(temp->qual[d1.seq].text_qual,blob_cntr), temp->qual[d1.seq].
     text_cnt = blob_cntr,
     temp->qual[d1.seq].text_qual[blob_cntr].comment = trim(tmptext->qual[z].text)
   ENDFOR
  WITH nocounter
 ;end select
#report_maker
 EXECUTE cpm_create_file_name_logical "aps_reserve_case", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SELECT INTO value(reply->print_status_data.print_filename)
  d.seq, acc_nbr = temp->qual[d.seq].accession_nbr, person_name = temp->qual[d.seq].person_name
  FROM (dummyt d  WITH seq = value(size(temp->qual,5)))
  PLAN (d)
  ORDER BY acc_nbr
  HEAD REPORT
   line1 = fillstring(125,"-"), line2 = fillstring(116,"-"), bbreak = 0,
   ssiteprefix = "       "
  HEAD PAGE
   row + 1, col 0, captions->rpt,
   col 56,
   CALL center(captions->ana,row,132), col 110,
   captions->dt, col 117, curdate"@SHORTDATE;;D",
   row + 1, col 0, captions->dir,
   col 110, captions->tm, col 117,
   curtime"@TIMENOSECONDS;;M", row + 1, col 53,
   CALL center(captions->res_list,row,132), col 112, captions->bye,
   col 117, request->scuruser"##############", row + 1,
   col 110, captions->pg, col 117,
   curpage"###", row + 1, col 0,
   captions->pre, col 15, last_pref = value(size(temp_pref->pref_qual,5))
   FOR (x = 1 TO last_pref)
     IF ((temp_pref->pref_qual[x].site_cd > 0))
      ssiteprefix = build(temp_pref->pref_qual[x].site_disp,temp_pref->pref_qual[x].prefix_name)
     ELSE
      ssiteprefix = trim(temp_pref->pref_qual[x].prefix_name)
     ENDIF
     IF (((col+ 10) > maxcol))
      row + 1, col 15
     ENDIF
     ssiteprefix
     IF (x < last_pref)
      ", "
     ENDIF
   ENDFOR
   row + 2, col 0, captions->cse,
   col 18, captions->res, col 30,
   captions->bby, col 40, captions->p_nm,
   col 90, captions->com, row + 1,
   col 0, line1, row + 1
   IF (no_cases_found="T")
    row + 5,
    CALL center(captions->non,row,132)
   ENDIF
  HEAD d.seq
   IF (no_cases_found="F")
    IF (((row+ 10) > maxrow))
     BREAK
    ENDIF
    row + 1, scuraccession = uar_fmt_accession(temp->qual[d.seq].accession_nbr,size(trim(temp->qual[d
       .seq].accession_nbr),1)), col 0,
    scuraccession, col 18, temp->qual[d.seq].case_reserved_dt_tm"@SHORTDATE4YR;;D",
    col 30, temp->qual[d.seq].accession_user_name"########"
    IF ((temp->qual[d.seq].person_name=""))
     col 40, captions->des
    ELSE
     col 40, temp->qual[d.seq].person_name"#######################", col 67,
     temp->qual[d.seq].person_id"#####################"
    ENDIF
    IF ((temp->qual[d.seq].text_cnt > 0))
     FOR (txt_cnt = 1 TO temp->qual[d.seq].text_cnt)
       col 90, temp->qual[d.seq].text_qual[txt_cnt].comment
       IF (((row+ 10) > maxrow))
        BREAK
       ENDIF
       row + 1
     ENDFOR
    ENDIF
   ENDIF
  FOOT PAGE
   row 60, col 0, line1,
   row + 1, col 0, captions->title,
   wk = format(curdate,"@WEEKDAYABBREV;;D"), dy = format(curdate,"@MEDIUMDATE4YR;;D"), today = concat
   (wk," ",dy),
   col 53, today, col 110,
   captions->pg, col 117, curpage"###",
   row + 1, col 55, captions->cont
  FOOT REPORT
   col 55, captions->end_rpt
  WITH nocounter, maxcol = 132, nullreport,
   maxrow = 63, compress
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
END GO
