CREATE PROGRAM aps_prt_cyto_scrn_wrksht_c:dba
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
 DECLARE susername = c50 WITH protect, noconstant("")
 DECLARE nstatus = i4 WITH protect, noconstant(0)
 DECLARE i18nhandle = i4 WITH protect, noconstant(0)
 DECLARE sunknownstring = vc WITH protect, noconstant("")
 DECLARE sstillbornstring = vc WITH protect, noconstant("")
 SET nstatus = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET sunknownstring = uar_i18ngetmessage(i18nhandle,"UNKNOWN_AGE","Unknown")
 SET sstillbornstring = uar_i18ngetmessage(i18nhandle,"STILLBORN_AGE","Stillborn")
 SELECT INTO "nl:"
  FROM prsnl pl
  WHERE (person_id=reqinfo->updt_id)
  DETAIL
   susername = pl.username
  WITH nocounter
 ;end select
 SUBROUTINE (formatage(birth_dt_tm=f8,deceased_dt_tm=f8,policy=vc) =vc WITH protect)
   DECLARE eff_end_dt_tm = f8 WITH private, noconstant(0.0)
   SET eff_end_dt_tm = deceased_dt_tm
   IF (((eff_end_dt_tm=null) OR (eff_end_dt_tm=0.00)) )
    SET eff_end_dt_tm = cnvtdatetime(sysdate)
   ENDIF
   IF (((birth_dt_tm > eff_end_dt_tm) OR (birth_dt_tm=null)) )
    RETURN(sunknownstring)
   ELSEIF (birth_dt_tm=deceased_dt_tm)
    RETURN(sstillbornstring)
   ELSE
    RETURN(cnvtage2(birth_dt_tm,eff_end_dt_tm,0,concat(policy,"/",trim(susername),"/",trim(cnvtstring
       (reqinfo->position_cd,32,2)))))
   ENDIF
 END ;Subroutine
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
 RECORD captions(
   1 prev = vc
   1 notver = vc
   1 rptaps = vc
   1 ap = vc
   1 ddate = vc
   1 dir = vc
   1 ttime = vc
   1 worklist = vc
   1 bby = vc
   1 ppage = vc
   1 mode = vc
   1 sel = vc
   1 thru = vc
   1 res = vc
   1 nofound = vc
   1 name = vc
   1 dob = vc
   1 spec = vc
   1 nospec = vc
   1 slides = vc
   1 alerts = vc
   1 collected = vc
   1 recd = vc
   1 reqby = vc
   1 priority = vc
   1 clininfo = vc
   1 none = vc
   1 scrninfo = vc
   1 notemplate = vc
   1 history = vc
   1 verby = vc
   1 posshist = vc
   1 id = vc
   1 contd = vc
   1 rptwksht = vc
   1 followup = vc
   1 opencases = vc
   1 pathhist = vc
   1 unknown = vc
   1 stillborn = vc
 )
 SET captions->prev = uar_i18ngetmessage(i18nhandle,"prev","Previous")
 SET captions->notver = uar_i18ngetmessage(i18nhandle,"notver","NOT VERIFIED")
 SET captions->rptaps = uar_i18ngetmessage(i18nhandle,"rptaps",
  "REPORT: APS_PRT_CYTO_SCRN_WRKSHT_C.PRG")
 SET captions->ap = uar_i18ngetmessage(i18nhandle,"ap","Anatomic Pathology")
 SET captions->ddate = uar_i18ngetmessage(i18nhandle,"ddate","DATE")
 SET captions->dir = uar_i18ngetmessage(i18nhandle,"dir","DIRECTORY")
 SET captions->ttime = uar_i18ngetmessage(i18nhandle,"ttime","TIME")
 SET captions->worklist = uar_i18ngetmessage(i18nhandle,"worklist","CYTOLOGY SCREENING WORKLIST")
 SET captions->bby = uar_i18ngetmessage(i18nhandle,"bby","BY")
 SET captions->ppage = uar_i18ngetmessage(i18nhandle,"ppage","PAGE")
 SET captions->mode = uar_i18ngetmessage(i18nhandle,"mode","MODE: CASE")
 SET captions->sel = uar_i18ngetmessage(i18nhandle,"sel","SELECTION")
 SET captions->thru = uar_i18ngetmessage(i18nhandle,"thru","through")
 SET captions->res = uar_i18ngetmessage(i18nhandle,"res","RESOURCE")
 SET captions->nofound = uar_i18ngetmessage(i18nhandle,"nofound",
  "No cases found meeting select criteria")
 SET captions->name = uar_i18ngetmessage(i18nhandle,"name","NAME")
 SET captions->dob = uar_i18ngetmessage(i18nhandle,"dob","DOB")
 SET captions->spec = uar_i18ngetmessage(i18nhandle,"spec","SPECIMEN")
 SET captions->nospec = uar_i18ngetmessage(i18nhandle,"nospec","No specimens found")
 SET captions->slides = uar_i18ngetmessage(i18nhandle,"slides","# SLIDES")
 SET captions->alerts = uar_i18ngetmessage(i18nhandle,"alerts","ALERTS")
 SET captions->collected = uar_i18ngetmessage(i18nhandle,"collect","COLLECTED")
 SET captions->recd = uar_i18ngetmessage(i18nhandle,"recd","RECEIVED")
 SET captions->reqby = uar_i18ngetmessage(i18nhandle,"reqby","REQUESTED BY")
 SET captions->priority = uar_i18ngetmessage(i18nhandle,"priority","PRIORITY")
 SET captions->clininfo = uar_i18ngetmessage(i18nhandle,"clininfo","CLINICAL INFORMATION")
 SET captions->none = uar_i18ngetmessage(i18nhandle,"none","NONE")
 SET captions->scrninfo = uar_i18ngetmessage(i18nhandle,"scrninfo","SCREENING INFORMATION")
 SET captions->notemplate = uar_i18ngetmessage(i18nhandle,"notemplate",
  "No Template Assigned to this Prefix")
 SET captions->history = uar_i18ngetmessage(i18nhandle,"history","HISTORY")
 SET captions->verby = uar_i18ngetmessage(i18nhandle,"verby","VERIFIED BY")
 SET captions->posshist = uar_i18ngetmessage(i18nhandle,"posshist",
  "POSSIBLE HISTORY BASED ON PERSON MATCH LOGIC")
 SET captions->id = uar_i18ngetmessage(i18nhandle,"id","ID")
 SET captions->contd = uar_i18ngetmessage(i18nhandle,"contd","CONTINUED...")
 SET captions->rptwksht = uar_i18ngetmessage(i18nhandle,"rptwksht",
  "REPORT: CYTOLOGY SCREENING WORKSHEET")
 SET captions->followup = uar_i18ngetmessage(i18nhandle,"followup","FOLLOWUP TRACKING IN PROGRESS")
 SET captions->opencases = uar_i18ngetmessage(i18nhandle,"opencases","OPEN CASES")
 SET captions->pathhist = uar_i18ngetmessage(i18nhandle,"pathhist","PATHOLOGY HISTORY (SEE BELOW)")
 SET captions->unknown = uar_i18ngetmessage(i18nhandle,"unknown","Unknown")
 SET captions->stillborn = uar_i18ngetmessage(i18nhandle,"STILLBORN","Stillborn")
 DECLARE stemp = vc WITH protect, noconstant("")
 DECLARE stempdt = vc WITH protect, noconstant("")
 DECLARE nsrvcntr = i4 WITH protect, noconstant(0)
 DECLARE temp1 = vc WITH protect, noconstant("")
 DECLARE npersonmatchcnt = i4 WITH protect, noconstant(0)
 DECLARE npersonidindx = i4 WITH protect, noconstant(0)
 DECLARE sblobout = gvc WITH protect, noconstant(" ")
 DECLARE blob_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",25,"BLOB"))
 RECORD temp_rec(
   1 history_m_cases = i4
   1 qual[20]
     2 name_full_formatted = vc
     2 birth_dt_tm = dq8
     2 birth_tz = i4
     2 deceased_dt_tm = dq8
     2 age = vc
     2 sex_cd = f8
     2 sex_disp = vc
     2 alias = vc
     2 person_id = f8
     2 report_id = f8
     2 case_id = f8
     2 prefix_cd = f8
     2 accession_nbr = c21
     2 pc_person_id = f8
     2 encntr_id = f8
     2 case_specimen_id = f8
     2 specimen_cnt = i4
     2 spec_qual[*]
       3 specimen_description = vc
       3 specimen_adeq_description = vc
     2 nbr_slides = f8
     2 collected_dt_tm = dq8
     2 received_dt_tm = dq8
     2 requested_by = vc
     2 requesting_phys_id = f8
     2 priority_cd = f8
     2 priority_disp = c40
     2 alert_row = c7
     2 clin_text_cnt = i4
     2 crc_clin_info_task_assay_cd = f8
     2 bclininfopt = i4
     2 ce_event_id = f8
     2 clin_info_text[*]
       3 text = vc
     2 hist_cases = i4
     2 hist_qual[*]
       3 accession_nbr = c21
       3 collected_dt_tm = dq8
       3 requesting_name = vc
       3 verified_name = vc
       3 proc_cnt = i4
       3 proc_qual[*]
         4 discrete_task_assay = f8
         4 text_cnt = i4
         4 text_qual[*]
           5 text = vc
     2 hist_m_cases = i4
     2 hist_m_qual[*]
       3 person_name = vc
       3 person_alias = vc
       3 birth_dt_tm = dq8
       3 deceased_dt_tm = dq8
       3 age = vc
       3 person_sex_cd = f8
       3 person_sex_disp = vc
       3 encntr_id = f8
       3 accession_nbr = c21
       3 collected_dt_tm = dq8
       3 requesting_name = vc
       3 verified_name = vc
       3 proc_cnt = i4
       3 proc_qual[*]
         4 discrete_task_assay = f8
         4 text_cnt = i4
         4 text_qual[*]
           5 text = vc
       3 birth_tz = i4
 )
 RECORD temp_template(
   1 template_qual[*]
     2 prefix_cd = f8
     2 qual[*]
       3 template_text = vc
 )
 RECORD hist_grp(
   1 proc_cnt = i4
   1 proc_qual[5]
     2 task_assay_cd = f8
     2 task_assay_display = vc
 )
 SET alert_string = fillstring(40," ")
 RECORD srv_rsrc_group(
   1 qual[*]
     2 service_resource_cd = f8
 )
 RECORD pm_dummy(
   1 qual[*]
     2 person_id = f8
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
 RECORD reply(
   1 ft_ind = i2
   1 path_history_ind = i2
   1 open_cases_ind = i2
   1 prev_abnormal_ind = i2
   1 prev_atypical_ind = i2
   1 prev_normal_ind = i2
   1 prev_unsat_ind = i2
   1 clin_high_risk_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 print_status_data
     2 print_directory = c19
     2 print_filename = c40
     2 print_dir_and_filename = c60
 )
 SET reply->status_data.status = "F"
 SET snormstring = fillstring(40," ")
 SET satypstring = fillstring(40," ")
 SET sabnstring = fillstring(40," ")
 SET sunsatstring = fillstring(40," ")
 SET max_spec_qual = 0
 SET deleted_status_cd = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(10," ")
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=1316
  DETAIL
   CASE (cv.cdf_meaning)
    OF "ABNORMAL":
     sabnstring = concat(captions->prev," ",cv.display)
    OF "ATYPICAL":
     satypstring = concat(captions->prev," ",cv.display)
    OF "NORMAL":
     snormstring = concat(captions->prev," ",cv.display)
    OF "UNSAT":
     sunsatstring = concat(captions->prev," ",cv.display)
   ENDCASE
  WITH nocounter
 ;end select
 SET queue_name = fillstring(40," ")
 SET shistmsg = fillstring(48," ")
 SET verified_cd = 0.0
 SET cancel_cd = 0.0
 SET corrected_cd = 0.0
 SET signinproc_cd = 0.0
 SET csigninproc_cd = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=1305
   AND cv.cdf_meaning IN ("VERIFIED", "CANCEL", "CORRECTED", "SIGNINPROC", "CSIGNINPROC")
  DETAIL
   CASE (cv.cdf_meaning)
    OF "VERIFIED":
     verified_cd = cv.code_value
    OF "CANCEL":
     cancel_cd = cv.code_value
    OF "CORRECTED":
     corrected_cd = cv.code_value
    OF "SIGNINPROC":
     signinproc_cd = cv.code_value
    OF "CSIGNINPROC":
     csigninproc_cd = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 SET code_value = 0.0
 SET mrn_alias_type_cd = 0.0
 SET code_set = 319
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_type_cd = code_value
 SET code_set = 48
 SET code_value = 0.0
 SET cdf_meaning = "DELETED"
 EXECUTE cpm_get_cd_for_cdf
 SET deleted_status_cd = code_value
 SET gyn_case_type_cd = 0.0
 SET ngyn_case_type_cd = 0.0
 SET code_value = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=1301
   AND cv.cdf_meaning IN ("GYN", "NGYN")
  DETAIL
   IF (cv.cdf_meaning="GYN")
    gyn_case_type_cd = cv.code_value
   ENDIF
   IF (cv.cdf_meaning="NGYN")
    ngyn_case_type_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET nsrvcntr = 0
 IF ((request->service_resource_cd > 0))
  SELECT INTO "nl:"
   rg.child_service_resource_cd
   FROM resource_group rg
   WHERE (request->service_resource_cd=rg.parent_service_resource_cd)
    AND rg.active_ind=1
    AND cnvtdatetime(sysdate) BETWEEN rg.beg_effective_dt_tm AND rg.end_effective_dt_tm
   DETAIL
    nsrvcntr += 1, stat = alterlist(srv_rsrc_group->qual,nsrvcntr), srv_rsrc_group->qual[nsrvcntr].
    service_resource_cd = rg.child_service_resource_cd
   WITH nocounter
  ;end select
  SET nsrvcntr += 1
  SET stat = alterlist(srv_rsrc_group->qual,nsrvcntr)
  SET srv_rsrc_group->qual[nsrvcntr].service_resource_cd = request->service_resource_cd
 ENDIF
 SET which_way_ind = " "
 SET num_of_cases = 0
 IF ((request->case_ind="Y"))
  SET pc_where = build("pc.accession_nbr between request->beg_acc and request->end_acc")
  IF ((request->resource_ind="Y"))
   SET rt_where = build("rt.service_resource_cd = srv_rsrc_group->qual[d.seq].service_resource_cd")
   SET which_way_ind = "1"
  ELSE
   SET rt_where = build("rt.service_resource_cd > 0")
   SET which_way_ind = "2"
   IF (nsrvcntr=0)
    SET nsrvcntr = 1
   ENDIF
  ENDIF
 ELSE
  SET pc_where = build("pc.report_id = null")
  IF ((request->resource_ind="Y"))
   SET rt_where = build("rt.service_resource_cd = srv_rsrc_group->qual[d.seq].service_resource_cd")
   SET which_way_ind = "3"
  ENDIF
 ENDIF
 SELECT
  IF (which_way_ind="1")
   PLAN (pc
    WHERE parser(trim(pc_where))
     AND pc.case_type_cd IN (gyn_case_type_cd, ngyn_case_type_cd)
     AND pc.cancel_cd IN (null, 0))
    JOIN (cr
    WHERE pc.case_id=cr.case_id
     AND  NOT (cr.status_cd IN (verified_cd, cancel_cd, corrected_cd, signinproc_cd, csigninproc_cd))
    )
    JOIN (crc
    WHERE cr.catalog_cd=crc.catalog_cd)
    JOIN (prr
    WHERE pc.prefix_id=prr.prefix_id
     AND cr.catalog_cd=prr.catalog_cd
     AND 1=prr.primary_ind)
    JOIN (d)
    JOIN (rt
    WHERE cr.report_id=rt.report_id
     AND parser(trim(rt_where)))
  ELSEIF (which_way_ind="2")
   PLAN (pc
    WHERE parser(trim(pc_where))
     AND pc.case_type_cd IN (gyn_case_type_cd, ngyn_case_type_cd)
     AND pc.cancel_cd IN (null, 0))
    JOIN (cr
    WHERE pc.case_id=cr.case_id
     AND  NOT (cr.status_cd IN (verified_cd, cancel_cd, corrected_cd, signinproc_cd, csigninproc_cd))
    )
    JOIN (crc
    WHERE cr.catalog_cd=crc.catalog_cd)
    JOIN (prr
    WHERE pc.prefix_id=prr.prefix_id
     AND cr.catalog_cd=prr.catalog_cd
     AND 1=prr.primary_ind)
    JOIN (rt
    WHERE cr.report_id=rt.report_id)
    JOIN (d)
  ELSEIF (which_way_ind="3")
   PLAN (d)
    JOIN (rt
    WHERE parser(trim(rt_where)))
    JOIN (cr
    WHERE rt.report_id=cr.report_id
     AND  NOT (cr.status_cd IN (verified_cd, cancel_cd, corrected_cd, signinproc_cd, csigninproc_cd))
    )
    JOIN (crc
    WHERE cr.catalog_cd=crc.catalog_cd)
    JOIN (prr
    WHERE cr.catalog_cd=prr.catalog_cd
     AND 1=prr.primary_ind)
    JOIN (pc
    WHERE cr.case_id=pc.case_id
     AND pc.case_type_cd IN (gyn_case_type_cd, ngyn_case_type_cd)
     AND pc.cancel_cd IN (null, 0)
     AND pc.prefix_id=prr.prefix_id)
  ELSE
  ENDIF
  INTO "nl:"
  pc.case_id
  FROM pathology_case pc,
   case_report cr,
   report_task rt,
   cyto_report_control crc,
   prefix_report_r prr,
   (dummyt d  WITH seq = value(nsrvcntr))
  ORDER BY pc.accession_nbr
  HEAD REPORT
   num_of_cases = 0
  DETAIL
   num_of_cases += 1
   IF (mod(num_of_cases,20)=1
    AND num_of_cases != 1)
    stat = alter(temp_rec->qual,(num_of_cases+ 19))
   ENDIF
   temp_rec->qual[num_of_cases].case_id = pc.case_id, temp_rec->qual[num_of_cases].accession_nbr = pc
   .accession_nbr, temp_rec->qual[num_of_cases].prefix_cd = pc.prefix_id,
   temp_rec->qual[num_of_cases].collected_dt_tm = pc.case_collect_dt_tm, temp_rec->qual[num_of_cases]
   .received_dt_tm = pc.case_received_dt_tm, temp_rec->qual[num_of_cases].requesting_phys_id = pc
   .requesting_physician_id,
   temp_rec->qual[num_of_cases].pc_person_id = pc.person_id, temp_rec->qual[num_of_cases].encntr_id
    = pc.encntr_id, temp_rec->qual[num_of_cases].report_id = cr.report_id,
   temp_rec->qual[num_of_cases].priority_cd = rt.priority_cd, temp_rec->qual[num_of_cases].
   crc_clin_info_task_assay_cd = crc.clin_info_task_assay_cd
  FOOT REPORT
   stat = alter(temp_rec->qual,num_of_cases)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET stat = alter(temp_rec->qual,0)
  GO TO report_maker
 ENDIF
 SELECT INTO "nl:"
  cs.case_id, cs.case_specimen_id, cs.specimen_cd,
  pr.name_full_formatted, pr.person_id, join_path2 = decode(s.seq,"S",c.seq,"C"," ")
  FROM case_specimen cs,
   person pr,
   slide s,
   prsnl p,
   code_value cv,
   code_value cv1,
   (dummyt d1  WITH seq = 1),
   (dummyt d4  WITH seq = 1),
   dummyt d2,
   (dummyt d  WITH seq = value(size(temp_rec->qual,5))),
   ap_task_assay_addl ataa,
   (dummyt d5  WITH seq = 1),
   cassette c,
   slide s2,
   ap_task_assay_addl ataa2
  PLAN (d)
   JOIN (p
   WHERE (temp_rec->qual[d.seq].requesting_phys_id=p.person_id))
   JOIN (pr
   WHERE (temp_rec->qual[d.seq].pc_person_id=pr.person_id))
   JOIN (cs
   WHERE (temp_rec->qual[d.seq].case_id=cs.case_id)
    AND cs.cancel_cd IN (null, 0.0))
   JOIN (d2)
   JOIN (cv
   WHERE cs.specimen_cd=cv.code_value)
   JOIN (cv1
   WHERE cs.inadequacy_reason_cd=cv1.code_value)
   JOIN (d4)
   JOIN (((d1
   WHERE 1=d1.seq)
   JOIN (s
   WHERE s.case_specimen_id=cs.case_specimen_id)
   JOIN (ataa
   WHERE ataa.task_assay_cd=s.task_assay_cd)
   ) ORJOIN ((d5
   WHERE 1=d5.seq)
   JOIN (c
   WHERE cs.case_specimen_id=c.case_specimen_id)
   JOIN (s2
   WHERE c.cassette_id=s2.cassette_id)
   JOIN (ataa2
   WHERE ataa2.task_assay_cd=s2.task_assay_cd)
   ))
  ORDER BY cs.case_id, cs.specimen_cd
  HEAD REPORT
   cntr = 0, spec_qual = 0, temp_rec->qual[d.seq].specimen_cnt = 0
  HEAD cs.case_id
   cntr += 1, temp_rec->qual[d.seq].name_full_formatted = pr.name_full_formatted, temp_rec->qual[d
   .seq].alias = captions->unknown,
   temp_rec->qual[d.seq].person_id = pr.person_id, temp_rec->qual[d.seq].birth_dt_tm = pr.birth_dt_tm,
   temp_rec->qual[d.seq].birth_tz = validate(pr.birth_tz,0),
   temp_rec->qual[d.seq].deceased_dt_tm = pr.deceased_dt_tm
   IF (curutc=1)
    temp_rec->qual[d.seq].age = formatage(cnvtdatetimeutc(datetimezone(pr.birth_dt_tm,pr.birth_tz),1),
     pr.deceased_dt_tm,"LABRPTAGE")
   ELSE
    temp_rec->qual[d.seq].age = formatage(pr.birth_dt_tm,pr.deceased_dt_tm,"LABRPTAGE")
   ENDIF
   temp_rec->qual[d.seq].sex_cd = pr.sex_cd, temp_rec->qual[d.seq].requested_by = trim(p
    .name_full_formatted), temp_rec->qual[d.seq].specimen_cnt = 0,
   spec_qual = 0
  HEAD cs.specimen_cd
   spec_qual += 1
   IF (spec_qual > max_spec_qual)
    max_spec_qual = spec_qual
   ENDIF
   temp_rec->qual[d.seq].specimen_cnt = spec_qual, stat = alterlist(temp_rec->qual[d.seq].spec_qual,
    spec_qual)
  DETAIL
   temp_rec->qual[d.seq].spec_qual[spec_qual].specimen_description = cv.description
   IF (cv1.description > " ")
    temp_rec->qual[d.seq].spec_qual[spec_qual].specimen_adeq_description = concat(" (",trim(cv1
      .description),")")
   ENDIF
   IF (join_path2="S")
    IF (s.slide_id != 0)
     IF (ataa.half_slide_ind=1)
      temp_rec->qual[d.seq].nbr_slides += 0.5
     ELSE
      temp_rec->qual[d.seq].nbr_slides += 1
     ENDIF
    ENDIF
   ELSEIF (join_path2="C")
    IF (s2.slide_id != 0)
     IF (ataa2.half_slide_ind=1)
      temp_rec->qual[d.seq].nbr_slides += 0.5
     ELSE
      temp_rec->qual[d.seq].nbr_slides += 1
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d1, outerjoin = d2,
   outerjoin = d4
 ;end select
 IF (curqual=0)
  GO TO report_maker
 ENDIF
 SELECT INTO "nl:"
  frmt_mrn = cnvtalias(ea.alias,ea.alias_pool_cd), ea.alias
  FROM encntr_alias ea,
   (dummyt d  WITH seq = value(size(temp_rec->qual,5)))
  PLAN (d)
   JOIN (ea
   WHERE (ea.encntr_id=temp_rec->qual[d.seq].encntr_id)
    AND ea.encntr_alias_type_cd=mrn_alias_type_cd
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
  DETAIL
   temp_rec->qual[d.seq].alias = frmt_mrn
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  pc.accession_nbr, apt.long_text_id
  FROM pathology_case pc,
   ap_prompt_test apt,
   long_text lt,
   (dummyt d  WITH seq = value(size(temp_rec->qual,5)))
  PLAN (d)
   JOIN (pc
   WHERE (temp_rec->qual[d.seq].case_id=pc.case_id))
   JOIN (apt
   WHERE pc.case_id=apt.accession_id
    AND 1=apt.active_ind
    AND (apt.task_assay_cd=temp_rec->qual[d.seq].crc_clin_info_task_assay_cd))
   JOIN (lt
   WHERE apt.long_text_id=lt.long_text_id
    AND 1=lt.active_ind)
  ORDER BY pc.accession_nbr
  HEAD pc.accession_nbr
   blob_cntr = 0
  DETAIL
   CALL rtf_to_text(lt.long_text,1,90)
   FOR (z = 1 TO size(tmptext->qual,5))
     blob_cntr += 1, stat = alterlist(temp_rec->qual[d.seq].clin_info_text,blob_cntr), temp_rec->
     qual[d.seq].clin_text_cnt = blob_cntr,
     temp_rec->qual[d.seq].clin_info_text[blob_cntr].text = trim(tmptext->qual[z].text), temp_rec->
     qual[d.seq].bclininfopt = 1
   ENDFOR
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  pc.accession_nbr, ce.event_id
  FROM pathology_case pc,
   case_report cr,
   clinical_event ce,
   (dummyt d  WITH seq = value(size(temp_rec->qual,5)))
  PLAN (d
   WHERE (temp_rec->qual[d.seq].bclininfopt != 1))
   JOIN (pc
   WHERE (temp_rec->qual[d.seq].case_id=pc.case_id))
   JOIN (cr
   WHERE pc.case_id=cr.case_id)
   JOIN (ce
   WHERE cr.event_id=ce.parent_event_id
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime)
    AND ce.record_status_cd != deleted_status_cd
    AND (ce.task_assay_cd=temp_rec->qual[d.seq].crc_clin_info_task_assay_cd))
  ORDER BY pc.accession_nbr, ce.event_id
  HEAD pc.accession_nbr
   blob_cntr = 0
  HEAD ce.event_id
   temp_rec->qual[d.seq].ce_event_id = ce.event_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cebr.event_id
  FROM ce_blob_result cebr,
   (dummyt d  WITH seq = value(size(temp_rec->qual,5)))
  PLAN (d
   WHERE (temp_rec->qual[d.seq].case_id > 0))
   JOIN (cebr
   WHERE (temp_rec->qual[d.seq].ce_event_id=cebr.event_id)
    AND cebr.valid_until_dt_tm > cnvtdatetime(curdate,curtime)
    AND cebr.storage_cd=blob_cd)
  HEAD REPORT
   blob_cntr = 0
  HEAD cebr.event_id
   blob_cntr = 0, recdate->datetime = cnvtdatetimeutc(cebr.valid_from_dt_tm), sblobout = "",
   blobsize = uar_get_ceblobsize(cebr.event_id,recdate)
   IF (blobsize > 0)
    stat = memrealloc(sblobout,1,build("C",blobsize)), status = uar_get_ceblob(cebr.event_id,recdate,
     sblobout,blobsize)
   ENDIF
   CALL rtf_to_text(sblobout,1,90)
   FOR (z = 1 TO size(tmptext->qual,5))
     blob_cntr += 1, stat = alterlist(temp_rec->qual[d.seq].clin_info_text,blob_cntr), temp_rec->
     qual[d.seq].clin_text_cnt = blob_cntr,
     temp_rec->qual[d.seq].clin_info_text[blob_cntr].text = trim(tmptext->qual[z].text)
   ENDFOR
  WITH nocounter
 ;end select
 FOR (x = 1 TO value(cnvtint(size(temp_rec->qual,5))))
   SET request->person_id = temp_rec->qual[x].person_id
   SET request->report_id = temp_rec->qual[x].report_id
   SET request->called_ind = "Y"
   EXECUTE aps_get_alerts
   SET temp_rec->qual[x].alert_row = build(reply->ft_ind,reply->path_history_ind,reply->
    open_cases_ind,reply->prev_abnormal_ind,reply->prev_atypical_ind,
    reply->prev_normal_ind,reply->prev_unsat_ind)
   SET reply->ft_ind = 0
   SET reply->path_history_ind = 0
   SET reply->open_cases_ind = 0
   SET reply->prev_abnormal_ind = 0
   SET reply->prev_atypical_ind = 0
   SET reply->prev_normal_ind = 0
   SET reply->prev_unsat_ind = 0
 ENDFOR
 SELECT INTO "nl:"
  cv.description
  FROM code_value cv,
   (dummyt d  WITH seq = value(size(temp_rec->qual,5)))
  PLAN (d)
   JOIN (cv
   WHERE (temp_rec->qual[d.seq].priority_cd=cv.code_value))
  DETAIL
   temp_rec->qual[d.seq].priority_disp = cv.description
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv.description
  FROM code_value cv,
   (dummyt d  WITH seq = value(size(temp_rec->qual,5)))
  PLAN (d)
   JOIN (cv
   WHERE (temp_rec->qual[d.seq].sex_cd=cv.code_value))
  DETAIL
   temp_rec->qual[d.seq].sex_disp = cv.description
  WITH nocounter
 ;end select
 SET ce_where = fillstring(13000," ")
 SELECT INTO "nl:"
  rhgr.grouping_cd, dta.mnemonic, dta.task_assay_cd
  FROM code_value cv,
   code_value_extension cve,
   report_history_grouping_r rhgr,
   discrete_task_assay dta
  PLAN (cv
   WHERE cv.code_set=1308
    AND cv.cdf_meaning="CYTO WSHEET")
   JOIN (cve
   WHERE cv.code_value=cve.code_value
    AND cve.code_set=1308
    AND cve.field_name="History Group")
   JOIN (rhgr
   WHERE cnvtint(cve.field_value)=rhgr.grouping_cd)
   JOIN (dta
   WHERE rhgr.task_assay_cd=dta.task_assay_cd)
  HEAD REPORT
   proc_cnt = 0, shistmsg = " "
  DETAIL
   proc_cnt += 1
   IF (mod(proc_cnt,5)=1
    AND proc_cnt != 1)
    stat = alter(hist_grp->proc_qual,(proc_cnt+ 4))
   ENDIF
   hist_grp->proc_qual[proc_cnt].task_assay_cd = dta.task_assay_cd, hist_grp->proc_qual[proc_cnt].
   task_assay_display = dta.mnemonic, hist_grp->proc_cnt = proc_cnt
   IF (proc_cnt > 1)
    ce_where = build(dta.task_assay_cd,",",trim(ce_where))
   ELSE
    ce_where = build(trim(ce_where),dta.task_assay_cd)
   ENDIF
  FOOT REPORT
   stat = alter(hist_grp->proc_qual,proc_cnt), ce_where = concat("ce.task_assay_cd in (",trim(
     ce_where),")"), shistmsg = " "
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET shistmsg = "Unable to retrieve history grouping information."
  SET ce_where = "NONE"
 ENDIF
 IF (ce_where="NONE")
  GO TO person_match
 ENDIF
 SELECT INTO "nl:"
  d.seq, pc.accession_nbr, pc_case_collect_dt_tm = pc.case_collect_dt_tm"@SHORTDATE",
  ce.event_id, cebr.event_id, pc.person_id,
  ce.task_assay_cd
  FROM case_report cr,
   pathology_case pc,
   clinical_event ce,
   ce_blob_result cebr,
   prsnl p,
   prsnl p1,
   (dummyt d  WITH seq = value(size(temp_rec->qual,5)))
  PLAN (d)
   JOIN (pc
   WHERE (pc.person_id=temp_rec->qual[d.seq].person_id)
    AND pc.cancel_cd IN (null, 0))
   JOIN (p1
   WHERE pc.requesting_physician_id=p1.person_id)
   JOIN (cr
   WHERE pc.case_id=cr.case_id
    AND (temp_rec->qual[d.seq].report_id != cr.report_id)
    AND cr.status_cd != cancel_cd)
   JOIN (p
   WHERE cr.status_prsnl_id=p.person_id)
   JOIN (ce
   WHERE cr.event_id=ce.parent_event_id
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime)
    AND ce.record_status_cd != deleted_status_cd
    AND parser(trim(ce_where)))
   JOIN (cebr
   WHERE ce.event_id=cebr.event_id
    AND cebr.valid_until_dt_tm > cnvtdatetime(curdate,curtime)
    AND cebr.storage_cd=blob_cd)
  ORDER BY d.seq, pc_case_collect_dt_tm DESC, pc.accession_nbr,
   ce.event_id, cebr.event_id
  HEAD REPORT
   cnt1 = 0, case_qual = 0
  HEAD d.seq
   case_qual = 0
  HEAD pc.accession_nbr
   case_qual += 1, stat = alterlist(temp_rec->qual[d.seq].hist_qual,case_qual), temp_rec->qual[d.seq]
   .hist_cases = case_qual,
   temp_rec->qual[d.seq].hist_qual[case_qual].accession_nbr = pc.accession_nbr, temp_rec->qual[d.seq]
   .hist_qual[case_qual].collected_dt_tm = pc.case_collect_dt_tm, temp_rec->qual[d.seq].hist_qual[
   case_qual].requesting_name = p1.name_full_formatted
   IF (cr.status_cd IN (verified_cd, corrected_cd, signinproc_cd, csigninproc_cd))
    temp_rec->qual[d.seq].hist_qual[case_qual].verified_name = p.name_full_formatted
   ELSE
    temp_rec->qual[d.seq].hist_qual[case_qual].verified_name = "NOT VERIFIED"
   ENDIF
   proc_qual = 0
  HEAD ce.event_id
   proc_qual += 1, stat = alterlist(temp_rec->qual[d.seq].hist_qual[case_qual].proc_qual,proc_qual),
   temp_rec->qual[d.seq].hist_qual[case_qual].proc_cnt = proc_qual,
   temp_rec->qual[d.seq].hist_qual[case_qual].proc_qual[proc_qual].discrete_task_assay = ce
   .task_assay_cd, blob_cntr = 0
  HEAD cebr.event_id
   recdate->datetime = cnvtdatetimeutc(cebr.valid_from_dt_tm), sblobout = "", blobsize =
   uar_get_ceblobsize(cebr.event_id,recdate)
   IF (blobsize > 0)
    stat = memrealloc(sblobout,1,build("C",blobsize)), status = uar_get_ceblob(cebr.event_id,recdate,
     sblobout,blobsize)
   ENDIF
   CALL rtf_to_text(sblobout,1,112)
   FOR (z = 1 TO size(tmptext->qual,5))
     blob_cntr += 1, stat = alterlist(temp_rec->qual[d.seq].hist_qual[case_qual].proc_qual[proc_qual]
      .text_qual,blob_cntr), temp_rec->qual[d.seq].hist_qual[case_qual].proc_qual[proc_qual].text_cnt
      = blob_cntr,
     temp_rec->qual[d.seq].hist_qual[case_qual].proc_qual[proc_qual].text_qual[blob_cntr].text = trim
     (tmptext->qual[z].text)
   ENDFOR
  WITH nocounter, memsort
 ;end select
#person_match
 IF ((request->personmatch != 1))
  GO TO after_match
 ENDIF
 SET num_of_current_cases = value(size(temp_rec->qual,5))
 SET temp_rec->history_m_cases = 0
 FOR (person_hist_cntr = 1 TO num_of_current_cases)
   SET stat = initrec(pm_dummy)
   SET npersonmatchcnt = 0
   SELECT INTO "nl:"
    pm.a_person_id, pm.b_person_id
    FROM person_matches pm
    PLAN (pm
     WHERE (((pm.a_person_id=temp_rec->qual[person_hist_cntr].person_id)) OR ((pm.b_person_id=
     temp_rec->qual[person_hist_cntr].person_id)))
      AND pm.active_ind=1
      AND pm.beg_effective_dt_tm < cnvtdatetime(sysdate)
      AND ((pm.end_effective_dt_tm > cnvtdatetime(sysdate)) OR (pm.end_effective_dt_tm=null)) )
    HEAD REPORT
     row + 0
    DETAIL
     IF ((pm.a_person_id=temp_rec->qual[person_hist_cntr].person_id))
      npersonmatchcnt += 1
      IF (mod(npersonmatchcnt,10)=1)
       stat = alterlist(pm_dummy->qual,(npersonmatchcnt+ 9))
      ENDIF
      pm_dummy->qual[npersonmatchcnt].person_id = pm.b_person_id
     ELSEIF ((pm.b_person_id=temp_rec->qual[person_hist_cntr].person_id))
      npersonmatchcnt += 1
      IF (mod(npersonmatchcnt,10)=1)
       stat = alterlist(pm_dummy->qual,(npersonmatchcnt+ 9))
      ENDIF
      pm_dummy->qual[npersonmatchcnt].person_id = pm.a_person_id
     ENDIF
    FOOT REPORT
     stat = alterlist(pm_dummy->qual,npersonmatchcnt)
    WITH nocounter
   ;end select
   IF (size(pm_dummy->qual,5) > 0)
    SELECT
     IF (size(pm_dummy->qual,5) > 1000)
      WITH nocounter, expand = 2
     ELSEIF (size(pm_dummy->qual,5) > 200)
      WITH nocounter, expand = 1
     ELSE
     ENDIF
     INTO "nl:"
     pc.accession_nbr, ce.event_id, cebr.event_id,
     pc.person_id, ce.task_assay_cd
     FROM case_report cr,
      pathology_case pc,
      clinical_event ce,
      ce_blob_result cebr,
      person p2,
      prsnl p,
      prsnl p1,
      code_value cv
     PLAN (pc
      WHERE (pc.case_id != temp_rec->qual[person_hist_cntr].case_id)
       AND pc.cancel_cd IN (null, 0)
       AND expand(npersonidindx,1,size(pm_dummy->qual,5),pc.person_id,pm_dummy->qual[npersonidindx].
       person_id))
      JOIN (p2
      WHERE pc.person_id=p2.person_id)
      JOIN (cv
      WHERE p2.sex_cd=cv.code_value)
      JOIN (p1
      WHERE pc.requesting_physician_id=p1.person_id)
      JOIN (cr
      WHERE pc.case_id=cr.case_id
       AND cr.status_cd != cancel_cd)
      JOIN (p
      WHERE cr.status_prsnl_id=p.person_id)
      JOIN (ce
      WHERE cr.event_id=ce.parent_event_id
       AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime)
       AND ce.record_status_cd != deleted_status_cd
       AND parser(trim(ce_where)))
      JOIN (cebr
      WHERE ce.event_id=cebr.event_id
       AND cebr.valid_until_dt_tm > cnvtdatetime(curdate,curtime)
       AND cebr.storage_cd=blob_cd)
     ORDER BY pc.case_collect_dt_tm DESC, pc.accession_nbr, ce.event_id,
      cebr.event_id
     HEAD REPORT
      cnt1 = 0, case_qual = 0
     HEAD pc.accession_nbr
      case_qual += 1, stat = alterlist(temp_rec->qual[person_hist_cntr].hist_m_qual,case_qual),
      temp_rec->qual[person_hist_cntr].hist_m_cases = case_qual
      IF ((case_qual > temp_rec->history_m_cases))
       temp_rec->history_m_cases = case_qual
      ENDIF
      temp_rec->qual[person_hist_cntr].hist_m_qual[case_qual].person_name = p2.name_full_formatted,
      temp_rec->qual[person_hist_cntr].hist_m_qual[case_qual].encntr_id = pc.encntr_id, temp_rec->
      qual[person_hist_cntr].hist_m_qual[case_qual].person_alias = captions->unknown,
      temp_rec->qual[person_hist_cntr].hist_m_qual[case_qual].birth_dt_tm = p2.birth_dt_tm, temp_rec
      ->qual[person_hist_cntr].hist_m_qual[case_qual].birth_tz = validate(p2.birth_tz,0), temp_rec->
      qual[person_hist_cntr].hist_m_qual[case_qual].deceased_dt_tm = p2.deceased_dt_tm,
      temp_rec->qual[person_hist_cntr].hist_m_qual[case_qual].person_sex_cd = p2.sex_cd, temp_rec->
      qual[person_hist_cntr].hist_m_qual[case_qual].person_sex_disp = cv.description, temp_rec->qual[
      person_hist_cntr].hist_m_qual[case_qual].accession_nbr = pc.accession_nbr,
      temp_rec->qual[person_hist_cntr].hist_m_qual[case_qual].collected_dt_tm = pc.case_collect_dt_tm,
      temp_rec->qual[person_hist_cntr].hist_m_qual[case_qual].requesting_name = p1
      .name_full_formatted
      IF (curutc=1)
       temp_rec->qual[person_hist_cntr].hist_m_qual[case_qual].age = formatage(cnvtdatetimeutc(
         datetimezone(p2.birth_dt_tm,p2.birth_tz),1),p2.deceased_dt_tm,"LABRPTAGE")
      ELSE
       temp_rec->qual[person_hist_cntr].hist_m_qual[case_qual].age = formatage(p2.birth_dt_tm,p2
        .deceased_dt_tm,"LABRPTAGE")
      ENDIF
      IF (cr.status_cd IN (verified_cd, corrected_cd, signinproc_cd, csigninproc_cd))
       temp_rec->qual[person_hist_cntr].hist_m_qual[case_qual].verified_name = p.name_full_formatted
      ELSE
       temp_rec->qual[person_hist_cntr].hist_m_qual[case_qual].verified_name = captions->notver
      ENDIF
      proc_qual = 0
     HEAD ce.event_id
      proc_qual += 1, stat = alterlist(temp_rec->qual[person_hist_cntr].hist_m_qual[case_qual].
       proc_qual,proc_qual), temp_rec->qual[person_hist_cntr].hist_m_qual[case_qual].proc_cnt =
      proc_qual,
      temp_rec->qual[person_hist_cntr].hist_m_qual[case_qual].proc_qual[proc_qual].
      discrete_task_assay = ce.task_assay_cd, blob_cntr = 0
     HEAD cebr.event_id
      recdate->datetime = cnvtdatetimeutc(cebr.valid_from_dt_tm), sblobout = "", blobsize =
      uar_get_ceblobsize(cebr.event_id,recdate)
      IF (blobsize > 0)
       stat = memrealloc(sblobout,1,build("C",blobsize)), status = uar_get_ceblob(cebr.event_id,
        recdate,sblobout,blobsize)
      ENDIF
      CALL rtf_to_text(sblobout,1,112)
      FOR (z = 1 TO size(tmptext->qual,5))
        blob_cntr += 1, stat = alterlist(temp_rec->qual[person_hist_cntr].hist_m_qual[case_qual].
         proc_qual[proc_qual].text_qual,blob_cntr), temp_rec->qual[person_hist_cntr].hist_m_qual[
        case_qual].proc_qual[proc_qual].text_cnt = blob_cntr,
        temp_rec->qual[person_hist_cntr].hist_m_qual[case_qual].proc_qual[proc_qual].text_qual[
        blob_cntr].text = trim(tmptext->qual[z].text)
      ENDFOR
     WITH nocounter, dontcare = p, dontcare = p1,
      dontcare = cv, memsort
    ;end select
    IF (size(temp_rec->qual[person_hist_cntr].hist_m_qual,5) > 0)
     SELECT INTO "nl:"
      temp_rec->qual[person_hist_cntr].hist_m_qual[d2.seq].encntr_id, frmt_mrn = cnvtalias(ea.alias,
       ea.alias_pool_cd), ea.alias
      FROM encntr_alias ea,
       (dummyt d2  WITH seq = value(temp_rec->history_m_cases))
      PLAN (d2
       WHERE d2.seq <= size(temp_rec->qual[person_hist_cntr].hist_m_qual,5))
       JOIN (ea
       WHERE (ea.encntr_id=temp_rec->qual[person_hist_cntr].hist_m_qual[d2.seq].encntr_id)
        AND ea.encntr_alias_type_cd=mrn_alias_type_cd
        AND ea.active_ind=1
        AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
      DETAIL
       temp_rec->qual[person_hist_cntr].hist_m_qual[d2.seq].person_alias = frmt_mrn
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
 ENDFOR
#after_match
 SELECT INTO "nl:"
  ap.prefix_id
  FROM ap_prefix ap,
   wp_template wp,
   wp_template_text wpt,
   long_text lt
  PLAN (ap
   WHERE ap.worksheet_template_id > 0)
   JOIN (wp
   WHERE ap.worksheet_template_id=wp.template_id)
   JOIN (wpt
   WHERE wp.template_id=wpt.template_id)
   JOIN (lt
   WHERE wpt.long_text_id=lt.long_text_id)
  ORDER BY ap.prefix_id
  HEAD REPORT
   tmplt_cntr = 0, prefix_cntr = 0
  HEAD ap.prefix_id
   prefix_cntr += 1, stat = alterlist(temp_template->template_qual,prefix_cntr), temp_template->
   template_qual[prefix_cntr].prefix_cd = ap.prefix_id,
   tmplt_cntr = 0
  DETAIL
   CALL rtf_to_text(lt.long_text,1,112)
   FOR (z = 1 TO size(tmptext->qual,5))
     tmplt_cntr += 1, stat = alterlist(temp_template->template_qual[prefix_cntr].qual,tmplt_cntr),
     temp_template->template_qual[prefix_cntr].qual[tmplt_cntr].template_text = trim(tmptext->qual[z]
      .text)
   ENDFOR
  WITH nocounter
 ;end select
#report_maker
 EXECUTE cpm_create_file_name_logical "aps_scrn_wrkshtc", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SELECT INTO value(reply->print_status_data.print_filename)
  x = 0, y = 0, temp_rec->qual[d.seq].accession_nbr,
  d.seq
  FROM (dummyt d  WITH seq = value(size(temp_rec->qual,5)))
  PLAN (d
   WHERE (temp_rec->qual[d.seq].case_id > 0))
  ORDER BY temp_rec->qual[d.seq].accession_nbr
  HEAD REPORT
   line1 = fillstring(125,"-"), line2 = fillstring(116,"-"), specimen_row1 = fillstring(95," ")
  HEAD PAGE
   row 1, col 0, captions->rptaps,
   CALL center(captions->ap,row,132), col 110, captions->ddate,
   ":", temp1 = format(curdate,"@SHORTDATE"), col 117,
   temp1, row + 1, col 0,
   captions->dir, ":", col 110,
   captions->ttime, ":", col 117,
   curtime, row + 1,
   CALL center(captions->worklist,row,132),
   col 112, captions->bby, ":",
   col 117, request->scuruser"##############", row + 1,
   col 110, captions->ppage, ":",
   col 117, curpage"###", row + 1,
   col 0, "     ", captions->mode
   IF ((request->beg_acc > " "))
    row + 1, col 0, captions->sel,
    ": ", beg_acc = uar_fmt_accession(request->beg_acc,size(trim(request->beg_acc),1)), end_acc =
    uar_fmt_accession(request->end_acc,size(trim(request->end_acc),1)),
    col 11, beg_acc, col + 1,
    captions->thru, col + 1, end_acc
   ENDIF
   IF ((request->service_resource_cd > 0))
    row + 1, col 0, " ",
    captions->res, ": ", col 11,
    request->service_resource_display
   ENDIF
   row + 2, col 0, line1
   IF (num_of_cases=0)
    row + 10, col 47, captions->nofound,
    "."
   ENDIF
  DETAIL
   IF ((request->pagebreak=1)
    AND d.seq > 1)
    BREAK
   ENDIF
   line_accession = uar_fmt_accession(temp_rec->qual[d.seq].accession_nbr,size(trim(temp_rec->qual[d
      .seq].accession_nbr),1)), row + 1, col 0,
   line_accession, col 25, captions->name,
   ":", col 32, temp_rec->qual[d.seq].name_full_formatted"############################",
   col 62, temp_rec->qual[d.seq].alias"########################", col 87,
   temp_rec->qual[d.seq].age, col 98, captions->dob,
   ":"
   IF (curutc=1)
    temp1 = format(cnvtdatetimeutc(datetimezone(temp_rec->qual[d.seq].birth_dt_tm,temp_rec->qual[d
       .seq].birth_tz),1),"@SHORTDATE4YR")
   ELSE
    temp1 = format(temp_rec->qual[d.seq].birth_dt_tm,"@SHORTDATE4YR")
   ENDIF
   col 104, temp1, col 117,
   temp_rec->qual[d.seq].sex_disp, row + 1, col 21,
   captions->spec, ":"
   IF ((temp_rec->qual[d.seq].specimen_cnt > 0))
    specimen_count = cnvtint(size(temp_rec->qual[d.seq].spec_qual,5))
    FOR (y = 1 TO specimen_count)
      IF (y > 1)
       temp_rec->qual[d.seq].spec_qual[y].specimen_description = concat(" ",temp_rec->qual[d.seq].
        spec_qual[y].specimen_description)
      ENDIF
      specimen_row1 = build(specimen_row1,temp_rec->qual[d.seq].spec_qual[y].specimen_description)
      IF ((temp_rec->qual[d.seq].spec_qual[y].specimen_adeq_description > " "))
       specimen_row1 = concat(trim(specimen_row1),trim(temp_rec->qual[d.seq].spec_qual[y].
         specimen_adeq_description))
      ENDIF
      IF (y < specimen_count)
       specimen_row1 = build(specimen_row1,";")
      ENDIF
    ENDFOR
    col 32, specimen_row1, specimen_row1 = fillstring(45," ")
   ELSE
    col 32, captions->nospec, specimen_row1 = fillstring(45," ")
   ENDIF
   row + 1, col 21, captions->slides,
   ":", col 32, temp_rec->qual[d.seq].nbr_slides"###.#",
   followup_ind = substring(1,1,temp_rec->qual[d.seq].alert_row), history_ind = substring(2,1,
    temp_rec->qual[d.seq].alert_row), open_cases_ind = substring(3,1,temp_rec->qual[d.seq].alert_row),
   prev_abnorm_ind = substring(4,1,temp_rec->qual[d.seq].alert_row), prev_atyp_ind = substring(5,1,
    temp_rec->qual[d.seq].alert_row), prev_norm_ind = substring(6,1,temp_rec->qual[d.seq].alert_row),
   prev_unsat_ind = substring(7,1,temp_rec->qual[d.seq].alert_row), col 80, captions->alerts,
   ":",
   CALL show_alerts("YES"), col 89,
   alert_string, row + 1, col 20,
   captions->collected, ":", stemp = format(temp_rec->qual[d.seq].collected_dt_tm,"@SHORTDATE;;q"),
   col 32, stemp,
   CALL show_alerts("NULL"),
   col 89, alert_string, row + 1,
   col 21, captions->recd, ":",
   stemp = format(temp_rec->qual[d.seq].received_dt_tm,"@SHORTDATE;;q"), col 32, stemp,
   CALL show_alerts("NULL"), col 89, alert_string,
   row + 1, col 17, captions->reqby,
   ":", col 32, temp_rec->qual[d.seq].requested_by,
   CALL show_alerts("NULL"), col 89, alert_string,
   row + 1, col 21, captions->priority,
   ":", col 32, temp_rec->qual[d.seq].priority_disp,
   CALL show_alerts("NULL"), col 89, alert_string,
   row + 1,
   CALL show_alerts("NULL"), col 89,
   alert_string, row + 1,
   CALL show_alerts("NULL"),
   col 89, alert_string
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
   row + 1, col 9, captions->clininfo,
   ": "
   IF ((temp_rec->qual[d.seq].clin_text_cnt > 0))
    FOR (clin_cnt = 1 TO temp_rec->qual[d.seq].clin_text_cnt)
      col 32, temp_rec->qual[d.seq].clin_info_text[clin_cnt].text
      IF (((row+ 10) > maxrow))
       BREAK
      ENDIF
      row + 1
    ENDFOR
   ELSE
    col 32, captions->none
   ENDIF
   row + 1, col 60, "***************",
   row + 1, col 0, captions->scrninfo,
   ":", row + 1
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
   num_of_prefixes = value(size(temp_template->template_qual,5)), col 8, captions->notemplate
   FOR (pref_num = 1 TO num_of_prefixes)
     IF ((temp_rec->qual[d.seq].prefix_cd=temp_template->template_qual[pref_num].prefix_cd))
      txt_size = cnvtint(size(temp_template->template_qual[pref_num].qual,5))
      FOR (line_cnt = 1 TO txt_size)
        col 8, "                                               ", col 8,
        temp_template->template_qual[pref_num].qual[line_cnt].template_text, row + 1
        IF (((row+ 10) > maxrow))
         BREAK
        ENDIF
      ENDFOR
      pref_num = num_of_prefixes
     ENDIF
   ENDFOR
   row + 1, col 60, "***************",
   row + 1, col 0, captions->history,
   ":"
   IF ((temp_rec->qual[d.seq].hist_cases > 0))
    FOR (hist_cases = 1 TO temp_rec->qual[d.seq].hist_cases)
      hist_accession = uar_fmt_accession(temp_rec->qual[d.seq].hist_qual[hist_cases].accession_nbr,
       size(trim(temp_rec->qual[d.seq].hist_qual[hist_cases].accession_nbr),1)), row + 1, col 0,
      hist_accession, col 21, captions->collected,
      ": ", stempdt = format(temp_rec->qual[d.seq].hist_qual[hist_cases].collected_dt_tm,
       "@SHORTDATE4YR"), col 33,
      stempdt, col 47, captions->reqby,
      ": ", col 62, temp_rec->qual[d.seq].hist_qual[hist_cases].requesting_name"####################",
      col 91, captions->verby, ": ",
      col 105, temp_rec->qual[d.seq].hist_qual[hist_cases].verified_name"####################"
      FOR (proc_cnt = 1 TO temp_rec->qual[d.seq].hist_qual[hist_cases].proc_cnt)
       FOR (spinner = 1 TO cnvtint(hist_grp->proc_cnt))
         IF ((hist_grp->proc_qual[spinner].task_assay_cd=temp_rec->qual[d.seq].hist_qual[hist_cases].
         proc_qual[proc_cnt].discrete_task_assay))
          IF (((row+ 10) > maxrow))
           BREAK
          ENDIF
          row + 1, col 5, hist_grp->proc_qual[spinner].task_assay_display
         ENDIF
       ENDFOR
       ,
       FOR (text_cnt = 1 TO temp_rec->qual[d.seq].hist_qual[hist_cases].proc_qual[proc_cnt].text_cnt)
         row + 1, col 8, temp_rec->qual[d.seq].hist_qual[hist_cases].proc_qual[proc_cnt].text_qual[
         text_cnt].text
         IF (((row+ 10) > maxrow))
          BREAK
         ENDIF
       ENDFOR
      ENDFOR
    ENDFOR
   ELSE
    IF (shistmsg > " ")
     col 9, shistmsg
    ELSE
     col 9, captions->none
    ENDIF
   ENDIF
   row + 1, col 60, "***************"
   IF ((request->personmatch=1))
    IF ((temp_rec->qual[d.seq].hist_m_cases > 0))
     row + 1, col 0, captions->posshist
    ENDIF
    FOR (hist_m_cases = 1 TO temp_rec->qual[d.seq].hist_m_cases)
      hist_m_accession = uar_fmt_accession(temp_rec->qual[d.seq].hist_m_qual[hist_m_cases].
       accession_nbr,size(trim(temp_rec->qual[d.seq].hist_m_qual[hist_m_cases].accession_nbr),1)),
      row + 1, col 0,
      hist_m_accession, col 21, captions->name,
      ": ", col 26, temp_rec->qual[d.seq].hist_m_qual[hist_m_cases].person_name
      "#################################",
      col 62, captions->id, ": ",
      col 66, temp_rec->qual[d.seq].hist_m_qual[hist_m_cases].person_alias"####################", col
       87,
      temp_rec->qual[d.seq].hist_m_qual[hist_m_cases].age, col 98, captions->dob,
      ": "
      IF (curutc=1)
       stempdt = format(cnvtdatetimeutc(datetimezone(temp_rec->qual[d.seq].hist_m_qual[hist_m_cases].
          birth_dt_tm,temp_rec->qual[d.seq].hist_m_qual[hist_m_cases].birth_tz),1),"@SHORTDATE4YR")
      ELSE
       stempdt = format(temp_rec->qual[d.seq].hist_m_qual[hist_m_cases].birth_dt_tm,"@SHORTDATE4YR")
      ENDIF
      col 104, stempdt, col 117,
      temp_rec->qual[d.seq].hist_m_qual[hist_m_cases].person_sex_disp, row + 1, col 21,
      captions->collected, ": ", stempdt = format(temp_rec->qual[d.seq].hist_m_qual[hist_m_cases].
       collected_dt_tm,"@SHORTDATE4YR"),
      col 33, stempdt, col 47,
      captions->reqby, ": ", col 62,
      temp_rec->qual[d.seq].hist_m_qual[hist_m_cases].requesting_name"####################", col 91,
      captions->verby,
      ": ", col 105, temp_rec->qual[d.seq].hist_m_qual[hist_m_cases].verified_name
      "####################"
      FOR (proc_cnt = 1 TO temp_rec->qual[d.seq].hist_m_qual[hist_m_cases].proc_cnt)
       FOR (spinner = 1 TO cnvtint(hist_grp->proc_cnt))
         IF ((hist_grp->proc_qual[spinner].task_assay_cd=temp_rec->qual[d.seq].hist_m_qual[
         hist_m_cases].proc_qual[proc_cnt].discrete_task_assay))
          IF (((row+ 10) > maxrow))
           BREAK
          ENDIF
          row + 1, col 5, hist_grp->proc_qual[spinner].task_assay_display
         ENDIF
       ENDFOR
       ,
       FOR (text_cnt = 1 TO temp_rec->qual[d.seq].hist_m_qual[hist_m_cases].proc_qual[proc_cnt].
       text_cnt)
         row + 1, col 8, temp_rec->qual[d.seq].hist_m_qual[hist_m_cases].proc_qual[proc_cnt].
         text_qual[text_cnt].text
         IF (((row+ 10) > maxrow))
          BREAK
         ENDIF
       ENDFOR
      ENDFOR
    ENDFOR
   ENDIF
  FOOT PAGE
   row 60, col 0, line1,
   row + 1, col 0, captions->rptwksht,
   today = concat(format(curdate,"@WEEKDAYABBREV")," ",format(curdate,"@MEDIUMDATE4YR")), col 53,
   today,
   col 110, captions->ppage, ":",
   col 117, curpage"###", row + 1,
   col 55, captions->contd
  FOOT REPORT
   col 55, "##########  "
  WITH nocounter, nullreport, maxcol = 132,
   maxrow = 63, compress
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SUBROUTINE show_alerts(first_time)
   SET alert_string = " "
   IF (followup_ind="1")
    SET alert_string = captions->followup
    SET followup_ind = "0"
   ELSEIF (open_cases_ind="1")
    SET alert_string = captions->opencases
    SET open_cases_ind = "0"
   ELSEIF (history_ind="1")
    SET alert_string = captions->pathhist
    SET history_ind = "0"
   ELSEIF (prev_norm_ind="1")
    SET alert_string = snormstring
    SET prev_norm_ind = "0"
   ELSEIF (prev_atyp_ind="1")
    SET alert_string = satypstring
    SET prev_atyp_ind = "0"
   ELSEIF (prev_abnorm_ind="1")
    SET alert_string = sabnstring
    SET prev_abnorm_ind = "0"
   ELSEIF (prev_unsat_ind="1")
    SET alert_string = sunsatstring
    SET prev_unsat_ind = "0"
   ELSEIF (first_time="YES")
    SET alert_string = captions->none
   ENDIF
   SET alert_string = trim(alert_string)
 END ;Subroutine
END GO
