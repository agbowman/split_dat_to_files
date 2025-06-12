CREATE PROGRAM bb_rpt_qc_schedules:dba
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
     2 schedule_name = c40
     2 active_ind = i2
     2 segments[*]
       3 segment_seq = i4
       3 segment_type_flag = i4
       3 time = i4
       3 component1_nbr = i4
       3 component2_nbr = i4
       3 component3_nbr = i4
       3 days_of_week_bit = i4
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
 DECLARE nstatus = i2 WITH protect, noconstant(0)
 DECLARE li18nhandle = i4 WITH protect, noconstant(0)
 DECLARE lcodeset = i4 WITH protect, constant(325573)
 DECLARE ncount = i2 WITH protect, noconstant(0)
 DECLARE nfirsttime = i2 WITH protect, noconstant(1)
 DECLARE nbreak = i2 WITH protect, noconstant(0)
 DECLARE nsegcount = i2 WITH protect, noconstant(0)
 DECLARE nlinesperpage = i2 WITH protect, constant(57)
 DECLARE nlinelength = i2 WITH protect, constant(70)
 DECLARE i = i2 WITH protect, noconstant(0)
 DECLARE ssegment = vc WITH protect, noconstant("")
 DECLARE stype = vc WITH protect, noconstant("")
 DECLARE sweekday = vc WITH protect, noconstant("")
 DECLARE sweek = vc WITH protect, noconstant("")
 DECLARE serror = vc WITH protect, noconstant("")
 DECLARE ndaily = i2 WITH protect, noconstant(1)
 DECLARE nweekly = i2 WITH protect, noconstant(2)
 DECLARE nmonthly = i2 WITH protect, noconstant(3)
 DECLARE nmonthly2 = i2 WITH protect, noconstant(4)
 DECLARE nasneeded = i2 WITH protect, noconstant(5)
 DECLARE ninterval = i2 WITH protect, noconstant(6)
 DECLARE ssixline = vc WITH protect, noconstant("")
 DECLARE sfortyline = vc WITH protect, noconstant("")
 DECLARE sseventyline = vc WITH protect, noconstant("")
 DECLARE nbitmonday = i2 WITH protect, constant(1)
 DECLARE nbittuesday = i2 WITH protect, constant(2)
 DECLARE nbitwednesday = i2 WITH protect, constant(4)
 DECLARE nbitthursday = i2 WITH protect, constant(8)
 DECLARE nbitfriday = i2 WITH protect, constant(16)
 DECLARE nbitsaturday = i2 WITH protect, constant(32)
 DECLARE nbitsunday = i2 WITH protect, constant(64)
 SET reply->status_data.status = "F"
 SET nstatus = uar_i18nlocalizationinit(li18nhandle,curprog,"",curcclrev)
 RECORD captions(
   1 stitle = vc
   1 susername = vc
   1 sdomain = vc
   1 sdate = vc
   1 stime = vc
   1 spage = vc
   1 sactive = vc
   1 sschedname = vc
   1 sschedseg = vc
   1 severy = vc
   1 sdays = vc
   1 sweeks = vc
   1 sday = vc
   1 sofevery = vc
   1 smonths = vc
   1 sthe = vc
   1 slookback = vc
   1 sminutes = vc
   1 sintervals = vc
   1 ssunday = vc
   1 smonday = vc
   1 stuesday = vc
   1 swednesday = vc
   1 sthursday = vc
   1 sfriday = vc
   1 ssaturday = vc
   1 sfirst = vc
   1 ssecond = vc
   1 sthird = vc
   1 sfourth = vc
   1 slast = vc
   1 sendofreport = vc
   1 sdaily = vc
   1 sweekly = vc
   1 smonthly = vc
   1 sasneeded = vc
   1 sinterval = vc
   1 syes = vc
   1 sno = vc
 )
 SET captions->stitle = uar_i18ngetmessage(li18nhandle,"TITLE",
  "PathNet Blood Bank: QC Schedules Report")
 SET captions->susername = uar_i18ngetmessage(li18nhandle,"NAME","Name:")
 SET captions->sdomain = uar_i18ngetmessage(li18nhandle,"DOMAIN","Domain:")
 SET captions->sdate = uar_i18ngetmessage(li18nhandle,"DATE","Date:")
 SET captions->stime = uar_i18ngetmessage(li18nhandle,"TIME","Time:")
 SET captions->spage = uar_i18ngetmessage(li18nhandle,"PAGE","Page:")
 SET captions->sactive = uar_i18ngetmessage(li18nhandle,"ACTIVE","Active")
 SET captions->sschedname = uar_i18ngetmessage(li18nhandle,"SCHEDNAME","Schedule Name")
 SET captions->sschedseg = uar_i18ngetmessage(li18nhandle,"SCHEDSEG","Segment Details")
 SET captions->severy = uar_i18ngetmessage(li18nhandle,"EVERY","Every")
 SET captions->sdays = uar_i18ngetmessage(li18nhandle,"DAYS","Day(s).")
 SET captions->sweeks = uar_i18ngetmessage(li18nhandle,"WEEKS","Week(s) on")
 SET captions->sday = uar_i18ngetmessage(li18nhandle,"DAY","Day")
 SET captions->sofevery = uar_i18ngetmessage(li18nhandle,"OFEVERY","of every")
 SET captions->smonths = uar_i18ngetmessage(li18nhandle,"MONTHS","Month(s)")
 SET captions->sthe = uar_i18ngetmessage(li18nhandle,"THE","The")
 SET captions->slookback = uar_i18ngetmessage(li18nhandle,"LOOKBACK","Lookback")
 SET captions->sminutes = uar_i18ngetmessage(li18nhandle,"MINUTES","Minutes")
 SET captions->sintervals = uar_i18ngetmessage(li18nhandle,"INTERVALS","Interval(s)")
 SET captions->ssunday = uar_i18ngetmessage(li18nhandle,"SUNDAY","Sunday")
 SET captions->smonday = uar_i18ngetmessage(li18nhandle,"MONDAY","Monday")
 SET captions->stuesday = uar_i18ngetmessage(li18nhandle,"TUESDAY","Tuesday")
 SET captions->swednesday = uar_i18ngetmessage(li18nhandle,"WEDNESDAY","Wednesday")
 SET captions->sthursday = uar_i18ngetmessage(li18nhandle,"THURSDAY","Thursday")
 SET captions->sfriday = uar_i18ngetmessage(li18nhandle,"FRIDAY","Friday")
 SET captions->ssaturday = uar_i18ngetmessage(li18nhandle,"SATURDAY","Saturday")
 SET captions->sfirst = uar_i18ngetmessage(li18nhandle,"FIRST","First")
 SET captions->ssecond = uar_i18ngetmessage(li18nhandle,"SECOND","Second")
 SET captions->sthird = uar_i18ngetmessage(li18nhandle,"THIRD","Third")
 SET captions->sfourth = uar_i18ngetmessage(li18nhandle,"FOURTH","Fourth")
 SET captions->slast = uar_i18ngetmessage(li18nhandle,"LAST","Last")
 SET captions->sendofreport = uar_i18ngetmessage(li18nhandle,"ENDOFREPORT",
  "* * * End of Report * * *")
 SET captions->sdaily = uar_i18ngetmessage(li18nhandle,"DAILY","Daily:")
 SET captions->sweekly = uar_i18ngetmessage(li18nhandle,"WEEKLY","Weekly:")
 SET captions->smonthly = uar_i18ngetmessage(li18nhandle,"MONTHLY","Monthly:")
 SET captions->sasneeded = uar_i18ngetmessage(li18nhandle,"ASNEEDED","As Needed:")
 SET captions->sinterval = uar_i18ngetmessage(li18nhandle,"INTERVAL","Interval:")
 SET captions->syes = uar_i18ngetmessage(li18nhandle,"YES","Yes")
 SET captions->sno = uar_i18ngetmessage(li18nhandle,"NO","No")
 SELECT INTO "nl:"
  FROM bb_qc_schedule_segment bbqcss,
   code_value cv
  PLAN (cv
   WHERE cv.code_set=lcodeset)
   JOIN (bbqcss
   WHERE (bbqcss.schedule_cd= Outerjoin(cv.code_value)) )
  ORDER BY cv.code_value, bbqcss.segment_seq
  HEAD cv.code_value
   ncount += 1
   IF (ncount > size(params->qual,5))
    nstatus = alterlist(params->qual,(ncount+ 9))
   ENDIF
   params->qual[ncount].schedule_name = cv.display, params->qual[ncount].active_ind = cv.active_ind,
   nsegcount = 0
  DETAIL
   IF (bbqcss.schedule_segment_id > 0)
    nsegcount += 1
    IF (nsegcount > size(params->qual[ncount].segments,5))
     nstatus = alterlist(params->qual[ncount].segments,(nsegcount+ 9))
    ENDIF
    params->qual[ncount].segments[nsegcount].segment_seq = bbqcss.segment_seq, params->qual[ncount].
    segments[nsegcount].segment_type_flag = bbqcss.segment_type_flag, params->qual[ncount].segments[
    nsegcount].time = bbqcss.time_nbr,
    params->qual[ncount].segments[nsegcount].component1_nbr = bbqcss.component1_nbr, params->qual[
    ncount].segments[nsegcount].component2_nbr = bbqcss.component2_nbr, params->qual[ncount].
    segments[nsegcount].component3_nbr = bbqcss.component3_nbr,
    params->qual[ncount].segments[nsegcount].days_of_week_bit = bbqcss.days_of_week_bit
   ENDIF
  FOOT  cv.code_value
   nstatus = alterlist(params->qual[ncount].segments,nsegcount)
  FOOT REPORT
   nstatus = alterlist(params->qual,ncount)
  WITH nocounter
 ;end select
 IF (error(serror,0) > 0)
  CALL subevent_add("REPORT","F","bb_rpt_qc_schedules",serror)
  GO TO exit_script
 ENDIF
 EXECUTE cpm_create_file_name "bb_qcs", "txt"
 IF ((cpm_cfn_info->status_data.status != "S"))
  CALL subevent_add("REPORT","F","bb_rpt_qc_schedules","Failed to create a file name")
  GO TO exit_script
 ENDIF
 IF (size(params->qual,5)=0)
  SELECT INTO cpm_cfn_info->file_name_path
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   HEAD REPORT
    ssixline = fillstring(6,"-"), sfortyline = fillstring(40,"-"), sseventyline = fillstring(70,"-")
   DETAIL
    CALL center(captions->stitle,1,130), row + 1, col 1,
    captions->susername, col 9, request->username,
    col 106, captions->sdate, col 112,
    curdate"@SHORTDATE", row + 1, col 1,
    captions->sdomain, col 9, request->domain,
    col 106, captions->stime, col 112,
    curtime3"@TIMEWITHSECONDS", row + 1, row + 1,
    col 1, captions->sactive, col 8,
    captions->sschedname, col 50, captions->sschedseg,
    row + 1, col 1, ssixline,
    col 8, sfortyline, col 50,
    sseventyline, row + 1
   FOOT PAGE
    row nlinesperpage, row + 2, col 61,
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
    ssixline = fillstring(6,"-"), sfortyline = fillstring(40,"-"), sseventyline = fillstring(70,"-")
   HEAD PAGE
    IF (((d.seq < value(size(params->qual,5))) OR (((nbreak=1) OR (value(size(params->qual,5))=1))
    )) )
     IF (((value(size(params->qual,5))=1
      AND ((nbreak=1) OR (nfirsttime=1)) ) OR (value(size(params->qual,5)) > 1)) )
      CALL center(captions->stitle,1,130), row + 1, col 1,
      captions->susername, col 9, request->username,
      col 106, captions->sdate, col 112,
      curdate"@SHORTDATE", row + 1, col 1,
      captions->sdomain, col 9, request->domain,
      col 106, captions->stime, col 112,
      curtime3"@TIMEWITHSECONDS", row + 1, row + 1,
      col 1, captions->sactive, col 8,
      captions->sschedname, col 50, captions->sschedseg,
      row + 1, col 1, ssixline,
      col 8, sfortyline, col 50,
      sseventyline, row + 1, nfirsttime = 0
     ENDIF
    ENDIF
   DETAIL
    IF (row >= nlinesperpage)
     nbreak = 1, BREAK
    ELSE
     nbreak = 0
    ENDIF
    IF ((params->qual[d.seq].active_ind=1))
     col 3, captions->syes
    ELSE
     col 3, captions->sno
    ENDIF
    col 8, params->qual[d.seq].schedule_name
    IF (size(params->qual[d.seq].segments,5)=0)
     row + 1
    ENDIF
    FOR (i = 1 TO size(params->qual[d.seq].segments,5))
      IF (row >= nlinesperpage)
       nbreak = 1, BREAK
      ELSE
       nbreak = 0
      ENDIF
      sweekday = " "
      CASE (params->qual[d.seq].segments[i].segment_type_flag)
       OF ndaily:
        stype = concat(captions->sdaily," ",captions->severy," ",trim(cnvtstring(params->qual[d.seq].
           segments[i].component1_nbr)),
         " ",captions->sdays)
       OF nweekly:
        IF (band(params->qual[d.seq].segments[i].days_of_week_bit,nbitsunday)=nbitsunday)
         IF (sweekday > "")
          sweekday = concat(sweekday,",",captions->ssunday)
         ELSE
          sweekday = concat(sweekday,captions->ssunday)
         ENDIF
        ENDIF
        ,
        IF (band(params->qual[d.seq].segments[i].days_of_week_bit,nbitmonday)=nbitmonday)
         IF (sweekday > "")
          sweekday = concat(sweekday,",",captions->smonday)
         ELSE
          sweekday = concat(sweekday,captions->smonday)
         ENDIF
        ENDIF
        ,
        IF (band(params->qual[d.seq].segments[i].days_of_week_bit,nbittuesday)=nbittuesday)
         IF (sweekday > "")
          sweekday = concat(sweekday,",",captions->stuesday)
         ELSE
          sweekday = concat(sweekday,captions->stuesday)
         ENDIF
        ENDIF
        ,
        IF (band(params->qual[d.seq].segments[i].days_of_week_bit,nbitwednesday)=nbitwednesday)
         IF (sweekday > "")
          sweekday = concat(sweekday,",",captions->swednesday)
         ELSE
          sweekday = concat(sweekday,captions->swednesday)
         ENDIF
        ENDIF
        ,
        IF (band(params->qual[d.seq].segments[i].days_of_week_bit,nbitthursday)=nbitthursday)
         IF (sweekday > "")
          sweekday = concat(sweekday,",",captions->sthursday)
         ELSE
          sweekday = concat(sweekday,captions->sthursday)
         ENDIF
        ENDIF
        ,
        IF (band(params->qual[d.seq].segments[i].days_of_week_bit,nbitfriday)=nbitfriday)
         IF (sweekday > "")
          sweekday = concat(sweekday,",",captions->sfriday)
         ELSE
          sweekday = concat(sweekday,captions->sfriday)
         ENDIF
        ENDIF
        ,
        IF (band(params->qual[d.seq].segments[i].days_of_week_bit,nbitsaturday)=nbitsaturday)
         IF (sweekday > "")
          sweekday = concat(sweekday,",",captions->ssaturday)
         ELSE
          sweekday = concat(sweekday,captions->ssaturday)
         ENDIF
        ENDIF
        ,stype = concat(captions->sweekly," ",captions->severy," ",trim(cnvtstring(params->qual[d.seq
           ].segments[i].component1_nbr)),
         " ",captions->sweeks," ",trim(sweekday))
       OF nmonthly:
        stype = concat(captions->smonthly," ",captions->sday," ",trim(cnvtstring(params->qual[d.seq].
           segments[i].component1_nbr)),
         " ",captions->sofevery," ",trim(cnvtstring(params->qual[d.seq].segments[i].component2_nbr)),
         " ",
         captions->smonths)
       OF nmonthly2:
        IF ((params->qual[d.seq].segments[i].component2_nbr=0))
         sweekday = captions->ssunday
        ELSEIF ((params->qual[d.seq].segments[i].component2_nbr=1))
         sweekday = captions->smonday
        ELSEIF ((params->qual[d.seq].segments[i].component2_nbr=2))
         sweekday = captions->stuesday
        ELSEIF ((params->qual[d.seq].segments[i].component2_nbr=3))
         sweekday = captions->swednesday
        ELSEIF ((params->qual[d.seq].segments[i].component2_nbr=4))
         sweekday = captions->sthursday
        ELSEIF ((params->qual[d.seq].segments[i].component2_nbr=5))
         sweekday = captions->sfriday
        ELSEIF ((params->qual[d.seq].segments[i].component2_nbr=6))
         sweekday = captions->ssaturday
        ENDIF
        ,
        IF ((params->qual[d.seq].segments[i].component1_nbr=0))
         sweek = captions->sfirst
        ELSEIF ((params->qual[d.seq].segments[i].component1_nbr=1))
         sweek = captions->ssecond
        ELSEIF ((params->qual[d.seq].segments[i].component1_nbr=2))
         sweek = captions->sthird
        ELSEIF ((params->qual[d.seq].segments[i].component1_nbr=3))
         sweek = captions->sfourth
        ELSEIF ((params->qual[d.seq].segments[i].component1_nbr=4))
         sweek = captions->slast
        ENDIF
        ,stype = concat(captions->smonthly," ",captions->sthe," ",sweek,
         " ",trim(sweekday)," ",captions->sofevery," ",
         trim(cnvtstring(params->qual[d.seq].segments[i].component3_nbr))," ",captions->smonths)
       OF nasneeded:
        stype = concat(captions->sasneeded," ",captions->slookback," ",trim(cnvtstring(params->qual[d
           .seq].segments[i].component1_nbr)),
         " ",captions->sminutes)
       OF ninterval:
        stype = concat(captions->sinterval," ",captions->severy," ",trim(cnvtstring(params->qual[d
           .seq].segments[i].component1_nbr)),
         " ",captions->sintervals)
      ENDCASE
      ssegment = ""
      IF ((params->qual[d.seq].segments[i].segment_type_flag IN (1, 2, 3, 4)))
       ssegment = concat(format(params->qual[d.seq].segments[i].time,"HH:MM;;M")," ",stype)
      ELSE
       ssegment = stype
      ENDIF
      tblobin = " ", tblobin = trim(ssegment),
      CALL rtf_to_text(trim(tblobin),1,nlinelength)
      FOR (z = 1 TO size(tmptext->qual,5))
        col 50, tmptext->qual[z].text, row + 1
        IF (row >= nlinesperpage)
         nbreak = 1, BREAK
        ELSE
         nbreak = 0
        ENDIF
      ENDFOR
    ENDFOR
    row + 1
    IF (d.seq=value(size(params->qual,5)))
     col 51, captions->sendofreport
    ENDIF
   FOOT PAGE
    row nlinesperpage, row + 2, col 61,
    captions->spage, col + 2, curpage"####;L"
   FOOT REPORT
    row + 0
   WITH nocounter
  ;end select
 ENDIF
 IF (error(serror,0) > 0)
  CALL subevent_add("REPORT","F","bb_rpt_qc_schedules",serror)
  GO TO exit_script
 ENDIF
 SET reply->file_name = cpm_cfn_info->file_name_path
 SET reply->node = curnode
 SET reply->status_data.status = "S"
#exit_script
 FREE RECORD params
 FREE RECORD captions
END GO
