CREATE PROGRAM aps_prt_db_word_proc_templates:dba
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
   1 rptaps = vc
   1 hnacommoncomp = vc
   1 ddate = vc
   1 directory = vc
   1 ttime = vc
   1 refdbaudit = vc
   1 bby = vc
   1 dbwordproctemp = vc
   1 ppage = vc
   1 requestingparam = vc
   1 ttemplates = vc
   1 bothactiveandinactive = vc
   1 activetemponly = vc
   1 templatetypes = vc
   1 bothtempandletters = vc
   1 templatesonly = vc
   1 lettersonly = vc
   1 activitytypes = vc
   1 allactivitytypes = vc
   1 uuser = vc
   1 allusers = vc
   1 fromtemplatename = vc
   1 firstavailabletemp = vc
   1 thrutemplatename = vc
   1 lastavailabletemp = vc
   1 notempfound = vc
   1 nname = vc
   1 description = vc
   1 status = vc
   1 templatetype = vc
   1 inactive = vc
   1 letter = vc
   1 template = vc
   1 unknown = vc
   1 activitytype = vc
   1 user = vc
   1 none = vc
   1 lastupdatetemplateparam = vc
   1 lastupdatetemplate = vc
   1 active = vc
   1 continued = vc
   1 orgs = vc
   1 allorgs = vc
   1 alltemplates = vc
   1 ucase_orgs = vc
 )
 SET captions->rptaps = uar_i18ngetmessage(i18nhandle,"h1",
  "REPORT:  APS_PRT_DB_WORD_PROC_TEMPLATES.PRG")
 SET captions->hnacommoncomp = uar_i18ngetmessage(i18nhandle,"h2","HNA COMMON COMPONENTS")
 SET captions->ddate = uar_i18ngetmessage(i18nhandle,"h3","DATE:")
 SET captions->directory = uar_i18ngetmessage(i18nhandle,"h4","DIRECTORY:")
 SET captions->ttime = uar_i18ngetmessage(i18nhandle,"h5","TIME:")
 SET captions->refdbaudit = uar_i18ngetmessage(i18nhandle,"h6","REFERENCE DATABASE AUDIT")
 SET captions->bby = uar_i18ngetmessage(i18nhandle,"h7","BY:")
 SET captions->dbwordproctemp = uar_i18ngetmessage(i18nhandle,"h8",
  "DB WORD PROCESSING TEMPLATES TOOL")
 SET captions->ppage = uar_i18ngetmessage(i18nhandle,"h9","PAGE:")
 SET captions->requestingparam = uar_i18ngetmessage(i18nhandle,"h10","Requesting Parameters")
 SET captions->ttemplates = uar_i18ngetmessage(i18nhandle,"h11","Templates:")
 SET captions->bothactiveandinactive = uar_i18ngetmessage(i18nhandle,"h12",
  "Both Active and Inactive Templates")
 SET captions->activetemponly = uar_i18ngetmessage(i18nhandle,"h13","Active Templates Only")
 SET captions->templatetypes = uar_i18ngetmessage(i18nhandle,"h14","Template Types:")
 SET captions->bothtempandletters = uar_i18ngetmessage(i18nhandle,"h15","Both Templates and Letters")
 SET captions->templatesonly = uar_i18ngetmessage(i18nhandle,"h16","Templates Only")
 SET captions->lettersonly = uar_i18ngetmessage(i18nhandle,"h17","Letters Only")
 SET captions->activitytypes = uar_i18ngetmessage(i18nhandle,"h18","Activity Types:")
 SET captions->allactivitytypes = uar_i18ngetmessage(i18nhandle,"h19","All activity types")
 SET captions->uuser = uar_i18ngetmessage(i18nhandle,"h20","User:")
 SET captions->allusers = uar_i18ngetmessage(i18nhandle,"h21","All Users")
 SET captions->fromtemplatename = uar_i18ngetmessage(i18nhandle,"h22","From Template Name:")
 SET captions->firstavailabletemp = uar_i18ngetmessage(i18nhandle,"h23","(First available template)")
 SET captions->thrutemplatename = uar_i18ngetmessage(i18nhandle,"h24","Thru Template Name:")
 SET captions->lastavailabletemp = uar_i18ngetmessage(i18nhandle,"h25","(Last available template)")
 SET captions->notempfound = uar_i18ngetmessage(i18nhandle,"h26",
  "No templates found matching requesting parameters.")
 SET captions->nname = uar_i18ngetmessage(i18nhandle,"h27","NAME:")
 SET captions->description = uar_i18ngetmessage(i18nhandle,"h28","DESCRIPTION:")
 SET captions->status = uar_i18ngetmessage(i18nhandle,"h29","STATUS:")
 SET captions->templatetype = uar_i18ngetmessage(i18nhandle,"h30","TEMPLATE TYPE:")
 SET captions->inactive = uar_i18ngetmessage(i18nhandle,"h31","INACTIVE")
 SET captions->letter = uar_i18ngetmessage(i18nhandle,"h32","LETTER")
 SET captions->template = uar_i18ngetmessage(i18nhandle,"h33","TEMPLATE")
 SET captions->unknown = uar_i18ngetmessage(i18nhandle,"h34","UNKNOWN")
 SET captions->activitytype = uar_i18ngetmessage(i18nhandle,"h35","ACTIVITY TYPE:")
 SET captions->user = uar_i18ngetmessage(i18nhandle,"h36","USER:")
 SET captions->none = uar_i18ngetmessage(i18nhandle,"h37","(NONE)")
 SET captions->lastupdatetemplateparam = uar_i18ngetmessage(i18nhandle,"h38",
  "LAST UPDATE TEMPLATE PARAMETERS:")
 SET captions->lastupdatetemplate = uar_i18ngetmessage(i18nhandle,"h39","LAST UPDATE TEMPLATE TEXT:")
 SET captions->active = uar_i18ngetmessage(i18nhandle,"h40","ACTIVE")
 SET captions->continued = uar_i18ngetmessage(i18nhandle,"f1","CONTINUED...")
 SET captions->orgs = uar_i18ngetmessage(i18nhandle,"h41","Organizations:")
 SET captions->ucase_orgs = uar_i18ngetmessage(i18nhandle,"h44","ORGANIZATIONS:")
 SET captions->allorgs = uar_i18ngetmessage(i18nhandle,"h42","All Available Organizations")
 SET captions->alltemplates = uar_i18ngetmessage(i18nhandle,"h43","All Available Templates")
 SET week = format(curdate,"@WEEKDAYABBREV;;Q")
 SET date = format(curdate,"@MEDIUMDATE;;Q")
 SET day = format(curdate,"@SHORTDATE4YR;;Q")
 SET time = format(curdate,"@TIMENOSECONDS;;Q")
 SET a = concat(day," ",time)
 DECLARE one_org_name = vc WITH protected, noconstant("")
 DECLARE org_facility_cd = f8 WITH protected, noconstant(0.0)
 DECLARE req_org_cnt = i4 WITH protected, noconstant(0)
 DECLARE letter_cd = f8 WITH protected, noconstant(0.0)
 DECLARE template_cd = f8 WITH protected, noconstant(0.0)
 DECLARE activity_type_disp = c40 WITH protected, noconstant("")
 DECLARE new_text = vc WITH protected, noconstant("")
 DECLARE snewlongtext = vc WITH protected, noconstant("")
 DECLARE slongtext = vc WITH protected, noconstant("")
 DECLARE lstart = i4 WITH protected, noconstant(0)
 DECLARE schunkeduptext = c32000 WITH protected, noconstant("")
 DECLARE spartext = c4 WITH protected, noconstant("")
 DECLARE norgspopulated = i2 WITH protected, noconstant(0)
 SET lstart = 1
 SET org_facility_cd = uar_get_code_by("MEANING",30620,"WPTEMPLATE")
 SET req_org_cnt = size(request->org_qual,5)
 RECORD temp(
   1 max_sequences = i4
   1 max_text_quals = i4
   1 qual[*]
     2 template_id = f8
     2 short_desc = c25
     2 long_desc = c60
     2 type_cd = f8
     2 activity_type_cd = f8
     2 activity_type_disp = c25
     2 person_id = f8
     2 user_name = c50
     2 name_full_formatted = c50
     2 active_ind = i2
     2 last_update_temp_params_dt_tm = dq8
     2 last_update_temp_params_person_id = f8
     2 last_update_temp_params_person_name = c79
     2 last_update_temp_text_dt_tm = dq8
     2 last_update_temp_text_person_id = f8
     2 last_update_temp_text_person_name = c79
     2 num_of_sequences = i4
     2 sequence_qual[*]
       3 sequence = i4
       3 text_qual[*]
         4 text_sequence = i4
         4 line_of_text = c112
     2 org_text_qual[*]
       3 line_of_org_names = vc
 )
 RECORD reply(
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
 SET reply->status_data.status = "F"
 SET letter_cd = uar_get_code_by("MEANING",1303,"LETTER")
 SET template_cd = uar_get_code_by("MEANING",1303,"TEMPLATE")
 SET single_activity_type_disp = fillstring(80," ")
 IF ((request->activity_type_cd > 0))
  SET single_activity_type_disp = uar_get_code_display(request->activity_type_cd)
 ENDIF
 SET single_user_disp = fillstring(80," ")
 SET single_user_signon = fillstring(80," ")
 IF ((request->person_id > 0))
  SELECT INTO "nl:"
   p.person_id
   FROM prsnl p
   WHERE (p.person_id=request->person_id)
   DETAIL
    single_user_disp = trim(p.name_full_formatted), single_user_signon = trim(p.username)
   WITH nocounter
  ;end select
 ENDIF
 SET active_ind_where = fillstring(40," ")
 SET letter_template_where = fillstring(80," ")
 SET activity_type_where = fillstring(50," ")
 SET person_where = fillstring(40," ")
 SET concat_beg_and_end_template = fillstring(110," ")
 IF ((request->inactive_ind=1))
  SET active_ind_where = "wp.active_ind in (1,0)"
 ELSE
  SET active_ind_where = "wp.active_ind = 1"
 ENDIF
 IF ((request->template_ind=1)
  AND (request->letter_ind=1))
  SET letter_template_where = build("wp.template_type_cd in (",letter_cd,",",template_cd,")")
 ENDIF
 IF ((request->template_ind=1)
  AND (request->letter_ind=0))
  SET letter_template_where = build("wp.template_type_cd = ",template_cd)
 ENDIF
 IF ((request->template_ind=0)
  AND (request->letter_ind=1))
  SET letter_template_where = build("wp.template_type_cd = ",letter_cd)
 ENDIF
 IF ((request->activity_type_cd > 0))
  SET activity_type_where = "wp.activity_type_cd = request->activity_type_cd"
 ELSE
  SET activity_type_where = "wp.activity_type_cd > -1"
 ENDIF
 IF ((request->person_id > 0))
  SET person_where = "wp.person_id = request->person_id"
 ELSE
  SET person_where = "wp.person_id > -1"
 ENDIF
 SET empty_string = " "
 IF (textlen(request->beg_template_name) > 0
  AND textlen(request->end_template_name) > 0)
  SET concat_beg_and_end_template =
  "wp.short_desc between request->beg_template_name and request->end_template_name"
 ELSEIF (textlen(request->beg_template_name) > 0
  AND textlen(request->end_template_name)=0)
  SET concat_beg_and_end_template = "wp.short_desc >= request->beg_template_name"
 ELSEIF (textlen(request->beg_template_name)=0
  AND textlen(request->end_template_name) > 0)
  SET concat_beg_and_end_template = "wp.short_desc <= request->end_template_name"
 ELSEIF (textlen(request->beg_template_name)=0
  AND textlen(request->end_template_name)=0)
  SET concat_beg_and_end_template = "wp.short_desc >= empty_string"
 ENDIF
 IF ((request->suppress_unassociated=0))
  SELECT INTO "nl:"
   wp.short_desc, wp.template_id, wpt.template_id,
   wpt.sequence, lt.long_text
   FROM wp_template wp,
    prsnl p,
    wp_template_text wpt,
    long_text lt
   PLAN (wp
    WHERE wp.template_id > 0.0
     AND (( NOT (wp.template_type_cd=template_cd)) OR (wp.template_type_cd=template_cd
     AND (wp.result_layout_exists_ind > (request->result_layout_exists_ind - 1))))
     AND parser(active_ind_where)
     AND parser(letter_template_where)
     AND parser(activity_type_where)
     AND parser(person_where)
     AND parser(concat_beg_and_end_template)
     AND  NOT ( EXISTS (
    (SELECT
     fer.parent_entity_id
     FROM filter_entity_reltn fer
     WHERE fer.parent_entity_id=wp.template_id
      AND fer.parent_entity_name="WP_TEMPLATE"
      AND fer.filter_entity1_name="ORGANIZATION"
      AND fer.filter_type_cd=org_facility_cd
      AND fer.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND fer.end_effective_dt_tm >= cnvtdatetime(sysdate)))))
    JOIN (p
    WHERE wp.person_id=p.person_id)
    JOIN (wpt
    WHERE wp.template_id=wpt.template_id)
    JOIN (lt
    WHERE lt.long_text_id=wpt.long_text_id)
   ORDER BY wp.short_desc, wp.template_id, wpt.sequence
   HEAD REPORT
    cnt = 0, tmplt_cntr = 0, sequence_cnt = 0
   HEAD wp.template_id
    tmplt_cntr = 0, cnt += 1, stat = alterlist(temp->qual,cnt),
    stat = alterlist(temp->qual[cnt].org_text_qual,0), temp->qual[cnt].template_id = wp.template_id,
    temp->qual[cnt].short_desc = trim(wp.short_desc),
    temp->qual[cnt].long_desc = trim(wp.description), temp->qual[cnt].type_cd = wp.template_type_cd,
    temp->qual[cnt].activity_type_cd = wp.activity_type_cd,
    temp->qual[cnt].person_id = wp.person_id, temp->qual[cnt].user_name = trim(p.username), temp->
    qual[cnt].name_full_formatted = trim(p.name_full_formatted),
    temp->qual[cnt].active_ind = wp.active_ind, temp->qual[cnt].last_update_temp_params_dt_tm = wp
    .updt_dt_tm, temp->qual[cnt].last_update_temp_params_person_id = wp.updt_id,
    temp->qual[cnt].last_update_temp_text_dt_tm = lt.updt_dt_tm, temp->qual[cnt].
    last_update_temp_text_person_id = lt.updt_id, sequence_cnt = 0,
    snewlongtext = " ", lstart = 1
   HEAD wpt.sequence
    tmplt_cntr = 0, sequence_cnt += 1, stat = alterlist(temp->qual[cnt].sequence_qual,sequence_cnt)
    IF ((sequence_cnt > temp->max_sequences))
     temp->max_sequences = sequence_cnt
    ENDIF
    temp->qual[cnt].sequence_qual[sequence_cnt].sequence = wpt.sequence, snewlongtext = concat(
     snewlongtext,lt.long_text)
   FOOT  wp.template_id
    IF (mod(size(snewlongtext),32000) > 0)
     nnumberofchunks = ((size(snewlongtext)/ 32000)+ 1)
    ELSE
     nnumberofchunks = 1
    ENDIF
    FOR (y = 1 TO nnumberofchunks)
      schunkeduptext = substring(lstart,32000,snewlongtext),
      CALL rtf_to_text(schunkeduptext,1,112)
      FOR (z = 1 TO size(tmptext->qual,5))
        tmplt_cntr += 1, stat = alterlist(temp->qual[cnt].sequence_qual[sequence_cnt].text_qual,
         tmplt_cntr)
        IF ((tmplt_cntr > temp->max_text_quals))
         temp->max_text_quals = tmplt_cntr
        ENDIF
        temp->qual[cnt].sequence_qual[sequence_cnt].text_qual[tmplt_cntr].text_sequence = tmplt_cntr,
        temp->qual[cnt].sequence_qual[sequence_cnt].text_qual[tmplt_cntr].line_of_text = trim(tmptext
         ->qual[z].text)
      ENDFOR
      lstart = ((y * 32000)+ 1)
    ENDFOR
   FOOT REPORT
    stat = alterlist(temp->qual,size(temp->qual,5))
   WITH nocounter
  ;end select
  IF (req_org_cnt > 0)
   SELECT INTO "nl:"
    wp.short_desc, wp.template_id, wpt.template_id,
    wpt.sequence, lt.long_text, o.org_name
    FROM wp_template wp,
     prsnl p,
     wp_template_text wpt,
     long_text lt,
     filter_entity_reltn fer,
     organization o,
     (dummyt d1  WITH seq = size(request->org_qual,5))
    PLAN (wp
     WHERE wp.template_id > 0.0
      AND (( NOT (wp.template_type_cd=template_cd)) OR (wp.template_type_cd=template_cd
      AND (wp.result_layout_exists_ind > (request->result_layout_exists_ind - 1))))
      AND parser(active_ind_where)
      AND parser(letter_template_where)
      AND parser(activity_type_where)
      AND parser(person_where)
      AND parser(concat_beg_and_end_template))
     JOIN (p
     WHERE wp.person_id=p.person_id)
     JOIN (wpt
     WHERE wp.template_id=wpt.template_id)
     JOIN (lt
     WHERE lt.long_text_id=wpt.long_text_id)
     JOIN (fer
     WHERE fer.parent_entity_id=wp.template_id
      AND fer.parent_entity_name="WP_TEMPLATE"
      AND fer.filter_entity1_name="ORGANIZATION"
      AND fer.filter_type_cd=org_facility_cd
      AND fer.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND fer.end_effective_dt_tm >= cnvtdatetime(sysdate))
     JOIN (o
     WHERE o.organization_id=fer.filter_entity1_id)
     JOIN (d1
     WHERE (fer.filter_entity1_id=request->org_qual[d1.seq].organization_id))
    ORDER BY wp.short_desc, wp.template_id, wpt.sequence
    HEAD REPORT
     cnt = size(temp->qual,5), tmplt_cntr = 0, sequence_cnt = 0,
     new_text = "", new_text_size = 0
    HEAD wp.template_id
     norgspopulated = 0, orgs_cntr = 0, cur_line = 0,
     tmplt_cntr = 0, cnt += 1, stat = alterlist(temp->qual,cnt),
     temp->qual[cnt].template_id = wp.template_id, temp->qual[cnt].short_desc = trim(wp.short_desc),
     temp->qual[cnt].long_desc = trim(wp.description),
     temp->qual[cnt].type_cd = wp.template_type_cd, temp->qual[cnt].activity_type_cd = wp
     .activity_type_cd, temp->qual[cnt].person_id = wp.person_id,
     temp->qual[cnt].user_name = trim(p.username), temp->qual[cnt].name_full_formatted = trim(p
      .name_full_formatted), temp->qual[cnt].active_ind = wp.active_ind,
     temp->qual[cnt].last_update_temp_params_dt_tm = wp.updt_dt_tm, temp->qual[cnt].
     last_update_temp_params_person_id = wp.updt_id, temp->qual[cnt].last_update_temp_text_dt_tm = lt
     .updt_dt_tm,
     temp->qual[cnt].last_update_temp_text_person_id = lt.updt_id, sequence_cnt = 0, snewlongtext =
     " ",
     lstart = 1
    HEAD wpt.sequence
     tmplt_cntr = 0, sequence_cnt += 1, stat = alterlist(temp->qual[cnt].sequence_qual,sequence_cnt)
     IF ((sequence_cnt > temp->max_sequences))
      temp->max_sequences = sequence_cnt
     ENDIF
     temp->qual[cnt].sequence_qual[sequence_cnt].sequence = wpt.sequence, snewlongtext = concat(
      snewlongtext,lt.long_text)
    DETAIL
     IF (norgspopulated=0)
      IF (req_org_cnt > 0)
       IF ((temp->qual[cnt].template_id=fer.parent_entity_id))
        orgs_cntr += 1
        IF (orgs_cntr=1)
         cur_line += 1, stat = alterlist(temp->qual[cnt].org_text_qual,cur_line), temp->qual[cnt].
         org_text_qual[cur_line].line_of_org_names = trim(o.org_name,3)
        ELSE
         new_text = concat(temp->qual[cnt].org_text_qual[cur_line].line_of_org_names,", ",trim(o
           .org_name,3)), new_text_size = size(new_text,1)
         IF (new_text_size > 100)
          cur_line += 1, stat = alterlist(temp->qual[cnt].org_text_qual,cur_line), temp->qual[cnt].
          org_text_qual[cur_line].line_of_org_names = trim(o.org_name,3)
         ELSE
          temp->qual[cnt].org_text_qual[cur_line].line_of_org_names = new_text
         ENDIF
        ENDIF
       ENDIF
      ELSE
       stat = alterlist(temp->qual[cnt].org_text_qual,0)
      ENDIF
     ENDIF
    FOOT  wpt.sequence
     norgspopulated = 1
    FOOT  wp.template_id
     IF (mod(size(snewlongtext),32000) > 0)
      nnumberofchunks = ((size(snewlongtext)/ 32000)+ 1)
     ELSE
      nnumberofchunks = 1
     ENDIF
     FOR (y = 1 TO nnumberofchunks)
       schunkeduptext = substring(lstart,32000,snewlongtext),
       CALL rtf_to_text(schunkeduptext,1,112)
       FOR (z = 1 TO size(tmptext->qual,5))
         tmplt_cntr += 1, stat = alterlist(temp->qual[cnt].sequence_qual[sequence_cnt].text_qual,
          tmplt_cntr)
         IF ((tmplt_cntr > temp->max_text_quals))
          temp->max_text_quals = tmplt_cntr
         ENDIF
         temp->qual[cnt].sequence_qual[sequence_cnt].text_qual[tmplt_cntr].text_sequence = tmplt_cntr,
         temp->qual[cnt].sequence_qual[sequence_cnt].text_qual[tmplt_cntr].line_of_text = trim(
          tmptext->qual[z].text)
       ENDFOR
       lstart = ((y * 32000)+ 1)
     ENDFOR
    FOOT REPORT
     stat = alterlist(temp->qual,size(temp->qual,5))
    WITH nocounter
   ;end select
  ENDIF
 ELSE
  SELECT INTO "nl:"
   wp.short_desc, wp.template_id, wpt.template_id,
   wpt.sequence, lt.long_text, o.org_name
   FROM wp_template wp,
    prsnl p,
    wp_template_text wpt,
    long_text lt,
    filter_entity_reltn fer,
    organization o,
    (dummyt d1  WITH seq = size(request->org_qual,5))
   PLAN (wp
    WHERE wp.template_id > 0.0
     AND (( NOT (wp.template_type_cd=template_cd)) OR (wp.template_type_cd=template_cd
     AND (wp.result_layout_exists_ind > (request->result_layout_exists_ind - 1))))
     AND parser(active_ind_where)
     AND parser(letter_template_where)
     AND parser(activity_type_where)
     AND parser(person_where)
     AND parser(concat_beg_and_end_template))
    JOIN (p
    WHERE wp.person_id=p.person_id)
    JOIN (wpt
    WHERE wp.template_id=wpt.template_id)
    JOIN (lt
    WHERE lt.long_text_id=wpt.long_text_id)
    JOIN (fer
    WHERE fer.parent_entity_id=wp.template_id
     AND fer.parent_entity_name="WP_TEMPLATE"
     AND fer.filter_entity1_name="ORGANIZATION"
     AND fer.filter_type_cd=org_facility_cd
     AND fer.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND fer.end_effective_dt_tm >= cnvtdatetime(sysdate))
    JOIN (o
    WHERE o.organization_id=fer.filter_entity1_id)
    JOIN (d1
    WHERE (fer.filter_entity1_id=request->org_qual[d1.seq].organization_id))
   ORDER BY wp.short_desc, wp.template_id, wpt.sequence
   HEAD REPORT
    cnt = 0, tmplt_cntr = 0, sequence_cnt = 0,
    new_text = "", new_text_size = 0
   HEAD wp.template_id
    norgspopulated = 0, orgs_cntr = 0, cur_line = 0,
    tmplt_cntr = 0, cnt += 1, stat = alterlist(temp->qual,cnt),
    temp->qual[cnt].template_id = wp.template_id, temp->qual[cnt].short_desc = trim(wp.short_desc),
    temp->qual[cnt].long_desc = trim(wp.description),
    temp->qual[cnt].type_cd = wp.template_type_cd, temp->qual[cnt].activity_type_cd = wp
    .activity_type_cd, temp->qual[cnt].person_id = wp.person_id,
    temp->qual[cnt].user_name = trim(p.username), temp->qual[cnt].name_full_formatted = trim(p
     .name_full_formatted), temp->qual[cnt].active_ind = wp.active_ind,
    temp->qual[cnt].last_update_temp_params_dt_tm = wp.updt_dt_tm, temp->qual[cnt].
    last_update_temp_params_person_id = wp.updt_id, temp->qual[cnt].last_update_temp_text_dt_tm = lt
    .updt_dt_tm,
    temp->qual[cnt].last_update_temp_text_person_id = lt.updt_id, sequence_cnt = 0, snewlongtext =
    " ",
    lstart = 1
   HEAD wpt.sequence
    tmplt_cntr = 0, sequence_cnt += 1, stat = alterlist(temp->qual[cnt].sequence_qual,sequence_cnt)
    IF ((sequence_cnt > temp->max_sequences))
     temp->max_sequences = sequence_cnt
    ENDIF
    temp->qual[cnt].sequence_qual[sequence_cnt].sequence = wpt.sequence, snewlongtext = concat(
     snewlongtext,lt.long_text)
   DETAIL
    IF (norgspopulated=0)
     IF (req_org_cnt > 0)
      IF ((temp->qual[cnt].template_id=fer.parent_entity_id))
       orgs_cntr += 1
       IF (orgs_cntr=1)
        cur_line += 1, stat = alterlist(temp->qual[cnt].org_text_qual,cur_line), temp->qual[cnt].
        org_text_qual[cur_line].line_of_org_names = trim(o.org_name,3)
       ELSE
        new_text = concat(temp->qual[cnt].org_text_qual[cur_line].line_of_org_names,", ",trim(o
          .org_name,3)), new_text_size = size(new_text,1)
        IF (new_text_size > 100)
         cur_line += 1, stat = alterlist(temp->qual[cnt].org_text_qual,cur_line), temp->qual[cnt].
         org_text_qual[cur_line].line_of_org_names = trim(o.org_name,3)
        ELSE
         temp->qual[cnt].org_text_qual[cur_line].line_of_org_names = new_text
        ENDIF
       ENDIF
      ENDIF
     ELSE
      stat = alterlist(temp->qual[cnt].org_text_qual,0)
     ENDIF
    ENDIF
   FOOT  wpt.sequence
    norgspopulated = 1
   FOOT  wp.template_id
    IF (mod(size(snewlongtext),32000) > 0)
     nnumberofchunks = ((size(snewlongtext)/ 32000)+ 1)
    ELSE
     nnumberofchunks = 1
    ENDIF
    FOR (y = 1 TO nnumberofchunks)
      schunkeduptext = substring(lstart,32000,snewlongtext),
      CALL rtf_to_text(schunkeduptext,1,112)
      FOR (z = 1 TO size(tmptext->qual,5))
        tmplt_cntr += 1, stat = alterlist(temp->qual[cnt].sequence_qual[sequence_cnt].text_qual,
         tmplt_cntr)
        IF ((tmplt_cntr > temp->max_text_quals))
         temp->max_text_quals = tmplt_cntr
        ENDIF
        temp->qual[cnt].sequence_qual[sequence_cnt].text_qual[tmplt_cntr].text_sequence = tmplt_cntr,
        temp->qual[cnt].sequence_qual[sequence_cnt].text_qual[tmplt_cntr].line_of_text = trim(tmptext
         ->qual[z].text)
      ENDFOR
      lstart = ((y * 32000)+ 1)
    ENDFOR
   FOOT REPORT
    stat = alterlist(temp->qual,size(temp->qual,5))
   WITH nocounter
  ;end select
 ENDIF
 CALL echorecord(temp)
 IF (req_org_cnt=1)
  SELECT INTO "nl:"
   o.org_name
   FROM organization o
   WHERE (o.organization_id=request->org_qual[1].organization_id)
   DETAIL
    one_org_name = trim(o.org_name,3)
  ;end select
 ENDIF
 SELECT INTO "nl:"
  p.name_full_formatted
  FROM (dummyt d1  WITH seq = value(size(temp->qual,5))),
   prsnl p
  PLAN (d1
   WHERE (temp->qual[d1.seq].last_update_temp_params_person_id > 0.0))
   JOIN (p
   WHERE (temp->qual[d1.seq].last_update_temp_params_person_id=p.person_id))
  DETAIL
   temp->qual[d1.seq].last_update_temp_params_person_name = p.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.name_full_formatted
  FROM (dummyt d1  WITH seq = value(size(temp->qual,5))),
   prsnl p
  PLAN (d1
   WHERE (temp->qual[d1.seq].last_update_temp_text_person_id > 0.0))
   JOIN (p
   WHERE (temp->qual[d1.seq].last_update_temp_text_person_id=p.person_id))
  DETAIL
   temp->qual[d1.seq].last_update_temp_text_person_name = p.name_full_formatted
  WITH nocounter
 ;end select
 FOR (ix = 1 TO size(temp->qual,5))
   SET temp->qual[ix].activity_type_disp = uar_get_code_display(temp->qual[ix].activity_type_cd)
 ENDFOR
#report_maker
 EXECUTE cpm_create_file_name_logical "apsDbWordTemps", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SELECT INTO value(reply->print_status_data.print_filename)
  short_desc = temp->qual[d1.seq].short_desc, template_id = temp->qual[d1.seq].template_id, sequence
   = temp->qual[d1.seq].sequence_qual[d2.seq].sequence,
  long_desc = temp->qual[d1.seq].long_desc, type_cd = temp->qual[d1.seq].type_cd, activity_type_cd =
  temp->qual[d1.seq].activity_type_cd,
  activity_type_disp = temp->qual[d1.seq].activity_type_disp, person_id = temp->qual[d1.seq].
  person_id, both_names = concat(trim(temp->qual[d1.seq].user_name),", ",trim(temp->qual[d1.seq].
    name_full_formatted)),
  active_ind = temp->qual[d1.seq].active_ind, temp_dt_tm = temp->qual[d1.seq].
  last_update_temp_params_dt_tm, temp_person_id = temp->qual[d1.seq].
  last_update_temp_params_person_id,
  temp_person_name = temp->qual[d1.seq].last_update_temp_params_person_name, text_dt_tm = temp->qual[
  d1.seq].last_update_temp_text_dt_tm, text_person_id = temp->qual[d1.seq].
  last_update_temp_text_person_id,
  text_person_name = temp->qual[d1.seq].last_update_temp_text_person_name, line_of_text = temp->qual[
  d1.seq].sequence_qual[d2.seq].text_qual[d3.seq].line_of_text, text_sequence = temp->qual[d1.seq].
  sequence_qual[d2.seq].text_qual[d3.seq].text_sequence
  FROM (dummyt d1  WITH seq = value(size(temp->qual,5))),
   (dummyt d2  WITH seq = value(temp->max_sequences)),
   (dummyt d3  WITH seq = value(temp->max_text_quals))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp->qual[d1.seq].sequence_qual,5))
   JOIN (d3
   WHERE d3.seq <= size(temp->qual[d1.seq].sequence_qual[d2.seq].text_qual,5))
  ORDER BY short_desc, template_id, sequence,
   text_sequence
  HEAD REPORT
   line1 = fillstring(125,"-")
  HEAD PAGE
   row + 1, col 0, captions->rptaps,
   CALL center(captions->hnacommoncomp,0,132), col 110, captions->ddate,
   col 117, curdate"@SHORTDATE;;Q", row + 1,
   col 0, captions->directory, col 110,
   captions->ttime, col 117, curtime,
   row + 1,
   CALL center(captions->refdbaudit,0,132), col 112,
   captions->bby, col 117, request->scuruser"##############",
   row + 1,
   CALL center(captions->dbwordproctemp,0,132), col 110,
   captions->ppage, col 117, curpage"###",
   row + 2
   IF (curpage=1)
    col 0, captions->requestingparam, "  ",
    row + 1, col 12, captions->ttemplates,
    " ", col 23
    IF ((request->inactive_ind=1))
     captions->bothactiveandinactive
    ELSE
     captions->activetemponly
    ENDIF
    row + 1, col 7, captions->templatetypes,
    " ", col 23
    IF ((request->template_ind=1)
     AND (request->letter_ind=1))
     captions->bothtempandletters
    ELSEIF ((request->template_ind=1))
     captions->templatesonly
    ELSEIF ((request->letter_ind=1))
     captions->lettersonly
    ENDIF
    row + 1, col 7, captions->activitytypes,
    col 23
    IF ((request->activity_type_cd > 0))
     single_activity_type_disp
    ELSE
     captions->allactivitytypes
    ENDIF
    row + 1, col 17, captions->uuser,
    " "
    IF ((request->person_id > 0))
     col 23, single_user_signon, row + 1,
     col 23, single_user_disp
    ELSE
     captions->allusers
    ENDIF
    row + 1, col 8, captions->orgs,
    " ", col 23
    IF ((request->suppress_unassociated=0))
     captions->alltemplates
    ELSE
     IF (req_org_cnt > 1)
      captions->allorgs
     ELSE
      one_org_name
     ENDIF
    ENDIF
    row + 1, col 3, captions->fromtemplatename,
    " ", col 23
    IF (textlen(request->beg_template_name) > 0)
     request->beg_template_name
    ELSE
     captions->firstavailabletemp
    ENDIF
    row + 1, col 3, captions->thrutemplatename,
    " ", col 23
    IF (textlen(request->end_template_name) > 0)
     request->end_template_name
    ELSE
     captions->lastavailabletemp
    ENDIF
    row + 1,
    CALL center("* * * * * * * * * * * * * * * * *",0,132)
   ENDIF
   IF (template_id=0)
    row + 2,
    CALL center(captions->notempfound,0,132)
   ENDIF
  HEAD template_id
   IF (((row+ 11) > maxrow))
    BREAK
   ENDIF
   row + 1, col 9, captions->nname,
   col 16, short_desc, row + 1,
   col 2, captions->description, col 16,
   long_desc, row + 1, col 7,
   captions->status, col 16
   IF (active_ind=1)
    captions->active
   ELSE
    captions->inactive
   ENDIF
   row + 1, col 0, captions->templatetype,
   col 16
   IF (type_cd=letter_cd)
    captions->letter
   ELSEIF (type_cd=template_cd)
    captions->template
   ELSE
    captions->unknown
   ENDIF
   row + 1, col 0, captions->activitytype,
   col 16
   IF (activity_type_cd > 0)
    activity_type_disp
   ELSE
    captions->none
   ENDIF
   row + 1, col 9, captions->user,
   col 16
   IF (person_id > 0)
    both_names
   ELSE
    captions->none
   ENDIF
   row + 1, col 0, captions->ucase_orgs,
   col 16
   IF (((req_org_cnt=0) OR (size(temp->qual[d1.seq].org_text_qual,5)=0)) )
    captions->none, row + 1
   ELSE
    FOR (z = 1 TO size(temp->qual[d1.seq].org_text_qual,5))
      temp->qual[d1.seq].org_text_qual[z].line_of_org_names, row + 1, col 16
    ENDFOR
   ENDIF
   row + 1, col 0, captions->lastupdatetemplateparam,
   col 35, temp_dt_tm"@SHORTDATE;;D", col 65,
   temp_person_name"####################################", row + 1, col 6,
   captions->lastupdatetemplate, col 35, text_dt_tm"@SHORTDATE;;D",
   col 65, text_person_name"####################################", row + 1
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
  DETAIL
   row + 1, col 12, temp->qual[d1.seq].sequence_qual[d2.seq].text_qual[d3.seq].line_of_text
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
  FOOT  short_desc
   row + 1,
   CALL center("* * * * * * * * * * * * *",0,132)
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
  FOOT PAGE
   row 60, col 0, line1,
   row + 1, col 0, captions->rptaps,
   today = concat(week," ",date), col 53, today,
   col 110, captions->ppage, col 117,
   curpage"###", row + 1, col 55,
   captions->continued
  FOOT REPORT
   col 55, "##########                              "
  WITH nocounter, maxcol = 132, nullreport,
   maxrow = 63, compress
 ;end select
 SET reply->status_data.status = "S"
END GO
