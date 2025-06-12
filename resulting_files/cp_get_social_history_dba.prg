CREATE PROGRAM cp_get_social_history:dba
 RECORD print(
   1 updtstatus = vc
   1 updtstatus_wrapcnt = i2
   1 updtstatus_wrap[*]
     2 line = vc
   1 unable_to_obtain = vc
   1 category[*]
     2 display = vc
     2 wrapcnt = i2
     2 wrap[*]
       3 line = vc
     2 assessment = vc
     2 assessment_wrapcnt = i2
     2 assessment_wrap[*]
       3 line = vc
     2 activity[*]
       3 detail_summary = vc
       3 detail_summary_wrapcnt = i2
       3 detail_summary_wrap[*]
         4 line = vc
       3 comments[*]
         4 value = vc
         4 wrapcnt = i2
         4 wrap[*]
           5 line = vc
   1 incomplete_data_msg = vc
   1 incomplete_data_msg_wrapcnt = i2
   1 incomplete_data_msg_wrap[*]
     2 line = vc
 )
 RECORD reply(
   1 num_lines = f8
   1 qual[*]
     2 line = c255
   1 output_file = vc
   1 log_info[*]
     2 log_level = i2
     2 log_message = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
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
   1 scomment = vc
   1 slast = vc
   1 supdated = vc
   1 sassessment = vc
   1 sby = vc
   1 sunable = vc
   1 sto = vc
   1 sobtain = vc
   1 sdat = vc
 )
 SUBROUTINE fillcaptions(dummyvar)
   SET captions->scomment = trim(uar_i18ngetmessage(i18nhandle,"COMMENT","Comment"))
   SET captions->slast = trim(uar_i18ngetmessage(i18nhandle,"LAST","Last"))
   SET captions->supdated = trim(uar_i18ngetmessage(i18nhandle,"UPDATED","Updated"))
   SET captions->sassessment = trim(uar_i18ngetmessage(i18nhandle,"ASSESSMENT","Assessment"))
   SET captions->sby = trim(uar_i18ngetmessage(i18nhandle,"BY","by"))
   SET captions->sunable = trim(uar_i18ngetmessage(i18nhandle,"UNABLE","Unable"))
   SET captions->sto = trim(uar_i18ngetmessage(i18nhandle,"TO","to"))
   SET captions->sobtain = trim(uar_i18ngetmessage(i18nhandle,"OBTAIN","Obtain"))
   SET captions->sdat = trim(uar_i18ngetmessage(i18nhandle,"DATA",
     "All recorded Social History data on this record is not viewable"))
 END ;Subroutine
 RECORD blob(
   1 line = vc
   1 cnt = i2
   1 qual[*]
     2 line = vc
     2 sze = i4
 )
 SUBROUTINE parsetext(stext,nmax_length)
   DECLARE lf = vc WITH protect, noconstant(concat(char(13),char(10)))
   DECLARE l = i4 WITH protect, noconstant(0)
   DECLARE h = i4 WITH protect, noconstant(0)
   DECLARE cr = i4 WITH protect, noconstant(0)
   DECLARE length = i4 WITH protect, noconstant(0)
   DECLARE check_blob = c32000 WITH protect, noconstant(fillstring(32000," "))
   DECLARE max_length = i4 WITH protect, noconstant(0)
   DECLARE ntab = i4 WITH protect, noconstant(5)
   DECLARE stempstring = c5 WITH protect, noconstant(fillstring(5," "))
   DECLARE c = i4 WITH noconstant(0)
   SET check_blob = stext
   SET max_length = nmax_length
   SET check_blob = concat(trim(check_blob),lf)
   SET blob->cnt = 0
   SET cr = findstring(lf,check_blob)
   SET length = textlen(check_blob)
   WHILE (cr > 0)
     SET blob->line = substring(1,(cr - 1),check_blob)
     SET check_blob = substring((cr+ 2),(length - (cr+ 2)),check_blob)
     SET blob->cnt = (blob->cnt+ 1)
     SET stat = alterlist(blob->qual,blob->cnt)
     SET blob->qual[blob->cnt].line = trim(blob->line)
     SET blob->qual[blob->cnt].sze = textlen(trim(blob->line))
     SET cr = findstring(lf,check_blob)
   ENDWHILE
   FOR (j = 1 TO blob->cnt)
     WHILE ((blob->qual[j].sze > max_length))
       SET h = l
       SET c = max_length
       WHILE (c > 0)
        IF (substring(c,1,blob->qual[j].line) IN (" ", "-"))
         SET l = (l+ 1)
         SET stat = alterlist(pt->lns,l)
         IF (l=1)
          SET pt->lns[l].line = substring(1,c,blob->qual[j].line)
          SET blob->qual[j].line = substring((c+ 1),(blob->qual[j].sze - c),blob->qual[j].line)
          SET max_length = (nmax_length - ntab)
          SET c = max_length
         ELSE
          SET pt->lns[l].line = build2(stempstring,substring(1,c,blob->qual[j].line))
          SET blob->qual[j].line = substring((c+ 1),(blob->qual[j].sze - c),blob->qual[j].line)
         ENDIF
         SET c = 1
        ENDIF
        SET c = (c - 1)
       ENDWHILE
       IF (h=l)
        SET l = (l+ 1)
        SET stat = alterlist(pt->lns,l)
        IF (l=1)
         SET pt->lns[l].line = substring(1,max_length,blob->qual[j].line)
         SET blob->qual[j].line = substring((max_length+ 1),(blob->qual[j].sze - max_length),blob->
          qual[j].line)
         SET max_length = (nmax_length - ntab)
        ELSE
         SET pt->lns[l].line = build2(stempstring,substring(1,max_length,blob->qual[j].line))
         SET blob->qual[j].line = substring((max_length+ 1),(blob->qual[j].sze - max_length),blob->
          qual[j].line)
        ENDIF
       ENDIF
       SET blob->qual[j].sze = size(trim(blob->qual[j].line))
     ENDWHILE
     SET l = (l+ 1)
     SET stat = alterlist(pt->lns,l)
     IF (l=1)
      SET max_length = (nmax_length - ntab)
      SET pt->lns[l].line = substring(1,blob->qual[j].sze,blob->qual[j].line)
     ELSE
      SET pt->lns[l].line = build2(stempstring,substring(1,blob->qual[j].sze,blob->qual[j].line))
      CALL echo(build2(stempstring,substring(1,blob->qual[j].sze,blob->qual[j].line)))
     ENDIF
     SET pt->line_cnt = l
   ENDFOR
 END ;Subroutine
 RECORD data(
   1 activity_qual[*]
     2 shx_category_def_id = f8
     2 shx_category_ref_id = f8
     2 shx_activity_id = f8
     2 shx_activity_group_id = f8
     2 unable_to_obtain_ind = i2
     2 shx_category_description = vc
     2 priority = i4
     2 person_id = f8
     2 organization_id = f8
     2 type_mean = c12
     2 status_cd = f8
     2 assessment_cd = f8
     2 detail_summary_text_id = f8
     2 detail_summary = vc
     2 last_review_dt_tm = dq8
     2 updt_cnt = i4
     2 comment_qual[*]
       3 shx_comment_id = f8
       3 long_text_id = f8
       3 long_text = vc
       3 comment_prsnl_id = f8
       3 comment_prsnl_full_name = vc
       3 comment_dt_tm = dq8
       3 comment_dt_tm_tz = i4
       3 updt_cnt = i4
     2 action_qual[*]
       3 shx_action_id = f8
       3 prsnl_id = f8
       3 prsnl_full_name = vc
       3 action_type_mean = c12
       3 action_dt_tm = dq8
       3 action_tz = i4
       3 updt_cnt = i4
     2 last_updt_prsnl_id = f8
     2 last_updt_prsnl_name = vc
     2 last_updt_dt_tm = dq8
   1 incomplete_data_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE numrows = i4 WITH noconstant(0)
 DECLARE numlines = i4 WITH noconstant(0)
 DECLARE pagevar = i4 WITH noconstant(0)
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE i = i4 WITH noconstant(0)
 DECLARE j = i4 WITH noconstant(0)
 DECLARE x = i4 WITH noconstant(0)
 DECLARE y = i4 WITH noconstant(0)
 DECLARE ln = i4 WITH noconstant(0)
 DECLARE cnodata = c1 WITH noconstant("Y")
 DECLARE cfailed = c1 WITH noconstant("F")
 DECLARE nage = i4 WITH protect, noconstant(0)
 DECLARE nmonth = i4 WITH protect, noconstant(0)
 DECLARE exceptioncnt = i4 WITH noconstant(0)
 DECLARE loginfocnt = i4 WITH noconstant(0)
 DECLARE dummyvoid = i2 WITH constant(0)
 DECLARE debug = i2 WITH noconstant(0)
 IF ((request->scope_flag=777))
  SET debug = 1
 ENDIF
 DECLARE viewsochist_cd = f8 WITH constant(uar_get_code_by("MEANING",6016,"VIEWSOCHIST"))
 DECLARE unknown_cd = f8 WITH constant(uar_get_code_by("MEANING",25320,"UNKNOWN"))
 DECLARE active_cd = f8 WITH constant(uar_get_code_by("MEANING",4002172,"ACTIVE"))
 DECLARE stime = vc WITH protect
 DECLARE processprivileges(dummyvar=i2) = null
 DECLARE fetchdata(dummyvar=i2) = null
 DECLARE parsedata(dummyvar=i2) = null
 DECLARE formatreport(dummyvar=i2) = null
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 CALL fillcaptions(dummyvoid)
 CALL processprivileges(dummyvoid)
 CALL fetchdata(dummyvoid)
 CALL parsedata(dummyvoid)
 CALL formatreport(dummyvoid)
 SUBROUTINE fetchdata(dummyvar)
   DECLARE category_ref_id = f8
   RECORD get_print_data(
     1 person_id = f8
     1 prsnl_id = f8
     1 category_qual[*]
       2 shx_category_ref_id = f8
   )
   EXECUTE prefrtl
   SET hpref = uar_prefcreateinstance(0)
   SET stat = uar_prefaddcontext(hpref,"default","system")
   IF ((reqinfo->position_cd > 0))
    CALL echo(build("Position_CD",reqinfo->position_cd))
    SET position_cd = cnvtstring(reqinfo->position_cd,11,2)
    SET stat = uar_prefaddcontext(hpref,"position",nullterm(position_cd))
   ENDIF
   IF ((reqinfo->updt_id > 0))
    CALL echo(build("user",reqinfo->updt_id))
    SET user_id = cnvtstring(reqinfo->updt_id,11,2)
    SET stat = uar_prefaddcontext(hpref,"user",nullterm(user_id))
   ENDIF
   SET stat = uar_prefsetsection(hpref,"component")
   SET hgroup = uar_prefcreategroup()
   SET stat = uar_prefsetgroupname(hgroup,"social history")
   SET stat = uar_prefaddgroup(hpref,hgroup)
   SET stat = uar_prefperform(hpref)
   SET hsection = uar_prefgetsectionbyname(hpref,"component")
   SET hrepgroup = uar_prefgetgroupbyname(hsection,"social history")
   SET entrycnt = 0
   SET stat = uar_prefgetgroupentrycount(hrepgroup,entrycnt)
   SET idxentry = 0
   FOR (idxentry = 0 TO (entrycnt - 1))
     SET hentry = uar_prefgetgroupentry(hrepgroup,idxentry)
     SET len = 255
     DECLARE entryname = c255 WITH noconstant("")
     SET stat = uar_prefgetentryname(hentry,entryname,len)
     IF (trim(entryname)="category list")
      SET hattr = uar_prefgetentryattr(hentry,0)
      SET valcnt = 0
      SET stat = uar_prefgetattrvalcount(hattr,valcnt)
      SET idxval = 0
      DECLARE val = c255 WITH noconstant("")
      SET stat = alterlist(get_print_data->category_qual,valcnt)
      FOR (idxval = 0 TO (valcnt - 1))
        SET len = 255
        SET stat = uar_prefgetattrval(hattr,val,len,idxval)
        SET category_ref_id = cnvtreal(trim(val))
        SET get_print_data->category_qual[(idxval+ 1)].shx_category_ref_id = category_ref_id
        IF (debug=1)
         CALL echo(build("Pref Order:",cnvtreal(trim(val))))
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   CALL uar_prefdestroysection(hsection)
   CALL uar_prefdestroygroup(hgroup)
   CALL uar_prefdestroyinstance(hpref)
   SET size = (size(get_print_data->category_qual,5)+ 1)
   SET stat = alterlist(get_print_data->category_qual,size)
   SET get_print_data->category_qual[size].shx_category_ref_id = 0
   SET get_print_data->person_id = request->person_id
   SET get_print_data->prsnl_id = reqinfo->updt_id
   IF (debug=1)
    CALL echorecord(get_print_data)
   ENDIF
   EXECUTE shx_get_activity  WITH replace("REQUEST","GET_PRINT_DATA"), replace("REPLY","DATA")
   SET modify = nopredeclare
   IF ((data->status_data.status="F"))
    SET stat = alterlist(reply->log_info,1)
    SET reply->log_info[i].log_level = 1
    SET reply->log_info[i].log_message = "Call to shx_get_activity failed"
    SET cfailed = "T"
    CALL report_failure("EXECUTE","F","CP_GET_SOCIAL_HISTORY","Call to shx_get_activity failed")
    FOR (errcnt = 1 TO value(size(reply->status_data.subeventstatus,5)))
      CALL report_failure(data->status_data.subeventstatus[errcnt].operationname,data->status_data.
       subeventstatus[errcnt].operationstatus,data->status_data.subeventstatus[errcnt].
       targetobjectname,data->status_data.subeventstatus[errcnt].targetobjectvalue)
    ENDFOR
   ENDIF
   IF (debug=1)
    CALL echorecord(data)
   ENDIF
   SET activitycnt = value(size(data->activity_qual,5))
   IF (cfailed="T")
    GO TO exit_script
   ELSE
    IF (activitycnt > 0)
     SET cnodata = "N"
    ELSE
     GO TO exit_script
    ENDIF
   ENDIF
   SELECT INTO "NL:"
    def_id = data->activity_qual[d1.seq].shx_category_def_id
    FROM shx_category_ref ref,
     (dummyt d1  WITH seq = size(data->activity_qual,5))
    PLAN (ref)
     JOIN (d1
     WHERE (data->activity_qual[d1.seq].shx_category_ref_id=ref.shx_category_ref_id))
    DETAIL
     data->activity_qual[d1.seq].shx_category_description = ref.description
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM (dummyt d1  WITH seq = size(data->activity_qual,5)),
     (dummyt d2  WITH seq = size(data->activity_qual,5))
    WHERE (data->activity_qual[d1.seq].shx_category_ref_id=data->activity_qual[d2.seq].
    shx_category_ref_id)
     AND (data->activity_qual[d1.seq].type_mean="DETAIL")
     AND (data->activity_qual[d1.seq].status_cd=active_cd)
     AND (data->activity_qual[d2.seq].status_cd=active_cd)
     AND (((data->activity_qual[d2.seq].type_mean="ASSESSMENT")) OR ((data->activity_qual[d2.seq].
    type_mean="ASSESSMENT_NONUNIQUE")))
    DETAIL
     IF ((data->activity_qual[d2.seq].assessment_cd != 0))
      data->activity_qual[d1.seq].assessment_cd = data->activity_qual[d2.seq].assessment_cd, data->
      activity_qual[d2.seq].type_mean = "ASSESSMENT_NONUNIQUE"
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM (dummyt d1  WITH seq = size(get_print_data->category_qual,5)),
     (dummyt d2  WITH seq = size(data->activity_qual,5))
    WHERE (get_print_data->category_qual[d1.seq].shx_category_ref_id=data->activity_qual[d2.seq].
    shx_category_ref_id)
    DETAIL
     data->activity_qual[d2.seq].priority = d1.seq
    WITH nocounter
   ;end select
   IF (debug=1)
    CALL echorecord(data)
   ENDIF
 END ;Subroutine
 SUBROUTINE processprivileges(dummyvar)
   DECLARE reqsize = i4
   SET reqsize = value(size(request->privileges,5))
   IF (validate(request->privileges) <= 0)
    SET cnodata = "Y"
    GO TO exit_script
    RETURN
   ENDIF
   IF (reqsize=0)
    RETURN
   ENDIF
   FOR (i = 1 TO reqsize)
     IF ((request->privileges[i].privilege_cd=viewsochist_cd)
      AND reqsize > 0)
      IF ((request->privileges[i].default[1].granted_ind=0))
       SET cnodata = "Y"
       GO TO exit_script
      ELSE
       RETURN
      ENDIF
     ENDIF
   ENDFOR
   SET cnodata = "Y"
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE parsedata(dummyvar)
   DECLARE categorycnt = i4 WITH protect, noconstant(0)
   DECLARE activitycnt = i4 WITH protect, noconstant(0)
   DECLARE commentcnt = i4 WITH protect, noconstant(0)
   DECLARE max_length = i4 WITH noconstant(0)
   RECORD pt(
     1 line_cnt = i2
     1 lns[*]
       2 line = vc
   )
   SELECT INTO "nl:"
    scategory = data->activity_qual[d1.seq].shx_category_description, npriority = data->
    activity_qual[d1.seq].priority, ndef = data->activity_qual[d1.seq].shx_category_def_id
    FROM (dummyt d1  WITH seq = value(size(data->activity_qual,5)))
    WHERE (data->activity_qual[d1.seq].status_cd=active_cd)
     AND ((trim(data->activity_qual[d1.seq].type_mean)="ASSESSMENT") OR (((trim(data->activity_qual[
     d1.seq].type_mean)="DETAIL") OR (trim(data->activity_qual[d1.seq].type_mean)="PERSON")) ))
    ORDER BY npriority, scategory
    HEAD REPORT
     catcnt = 0
    HEAD npriority
     dummyvalue = 0
    HEAD scategory
     activcnt = 0
     IF ((((data->activity_qual[d1.seq].type_mean="DETAIL")) OR ((data->activity_qual[d1.seq].
     type_mean="ASSESSMENT"))) )
      IF ((((data->activity_qual[d1.seq].detail_summary != "")) OR (((size(data->activity_qual[d1.seq
       ].comment_qual,5) != 0) OR ((data->activity_qual[d1.seq].type_mean="ASSESSMENT"))) )) )
       catcnt = (catcnt+ 1)
       IF (catcnt > size(print->category,5))
        stat = alterlist(print->category,(catcnt+ 10))
       ENDIF
       print->category[catcnt].display = data->activity_qual[d1.seq].shx_category_description
       IF ((data->incomplete_data_ind=1))
        print->incomplete_data_msg = concat(captions->sdat)
       ENDIF
       IF ((data->activity_qual[d1.seq].assessment_cd != 0))
        print->category[catcnt].assessment = concat(captions->sassessment,": ",uar_get_code_display(
          data->activity_qual[d1.seq].assessment_cd))
        IF ((data->activity_qual[d1.seq].detail_summary=""))
         print->category[catcnt].assessment = concat(print->category[catcnt].assessment," (",captions
          ->slast," ",captions->supdated,
          " ",format(data->activity_qual[d1.seq].last_updt_dt_tm,"MM/DD/YYYY;;D")," ",format(data->
           activity_qual[d1.seq].last_updt_dt_tm,"HH:MM;;S")," ",
          captions->sby," ",data->activity_qual[d1.seq].last_updt_prsnl_name,")")
        ENDIF
       ENDIF
      ENDIF
     ELSE
      IF ((data->activity_qual[d1.seq].unable_to_obtain_ind=1))
       print->unable_to_obtain = concat(captions->sunable," ",captions->sto," ",captions->sobtain),
       print->updtstatus = concat(captions->slast," ",captions->supdated," ",format(data->
         activity_qual[d1.seq].last_updt_dt_tm,"MM/DD/YYYY;;D"),
        " ",format(data->activity_qual[d1.seq].last_updt_dt_tm,"HH:MM;;S")," ",captions->sby," ",
        data->activity_qual[d1.seq].last_updt_prsnl_name)
      ENDIF
     ENDIF
    DETAIL
     IF (catcnt > 0
      AND catcnt <= size(print->category,5)
      AND (data->activity_qual[d1.seq].type_mean="DETAIL"))
      IF ((((data->activity_qual[d1.seq].detail_summary != "")) OR (size(data->activity_qual[d1.seq].
       comment_qual,5) != 0)) )
       activcnt = (activcnt+ 1)
       IF (activcnt > size(print->category[catcnt].activity,5))
        stat = alterlist(print->category[catcnt].activity,(activcnt+ 10))
       ENDIF
       IF ((data->activity_qual[d1.seq].detail_summary != ""))
        print->category[catcnt].activity[activcnt].detail_summary = concat(data->activity_qual[d1.seq
         ].detail_summary," (",captions->slast," ",captions->supdated,
         " ",format(data->activity_qual[d1.seq].last_updt_dt_tm,"MM/DD/YYYY;;D")," ",format(data->
          activity_qual[d1.seq].last_updt_dt_tm,"HH:MM;;S")," ",
         captions->sby," ",data->activity_qual[d1.seq].last_updt_prsnl_name,")")
       ENDIF
       cmtcnt = size(data->activity_qual[d1.seq].comment_qual,5), stat = alterlist(print->category[
        catcnt].activity[activcnt].comments,cmtcnt)
       FOR (x = 1 TO cmtcnt)
         print->category[catcnt].activity[activcnt].comments[x].value = concat(captions->scomment,
          ": ",data->activity_qual[d1.seq].comment_qual[x].long_text," (",format(cnvtdatetime(
            cnvtdatetimeutc(data->activity_qual[d1.seq].comment_qual[x].comment_dt_tm,1,data->
             activity_qual[d1.seq].comment_qual[x].comment_dt_tm_tz)),"MM/DD/YYYY;;D"),
          " ",format(cnvtdatetimeutc(data->activity_qual[d1.seq].comment_qual[x].comment_dt_tm,1,data
            ->activity_qual[d1.seq].comment_qual[x].comment_dt_tm_tz),"HH:MM;;S")," - ",data->
          activity_qual[d1.seq].comment_qual[x].comment_prsnl_full_name,")")
       ENDFOR
      ENDIF
     ENDIF
    FOOT  scategory
     IF (activcnt > 0)
      stat = alterlist(print->category[catcnt].activity,activcnt)
     ENDIF
    FOOT REPORT
     IF (catcnt > 0)
      stat = alterlist(print->category,catcnt)
     ENDIF
    WITH nocounter
   ;end select
   SET categorycnt = value(size(print->category,5))
   IF (categorycnt < 1
    AND (print->unable_to_obtain=""))
    SET cnodata = "Y"
    GO TO exit_script
   ENDIF
   SET max_length = 100
   SET pt->line_cnt = 0
   CALL parsetext(print->incomplete_data_msg,max_length)
   SET stat = alterlist(print->incomplete_data_msg_wrap,pt->line_cnt)
   SET print->incomplete_data_msg_wrapcnt = pt->line_cnt
   FOR (j = 1 TO pt->line_cnt)
     SET print->incomplete_data_msg_wrap[j].line = pt->lns[j].line
   ENDFOR
   SET max_length = 110
   SET pt->line_cnt = 0
   CALL parsetext(print->updtstatus,max_length)
   SET stat = alterlist(print->updtstatus_wrap,pt->line_cnt)
   SET print->updtstatus_wrapcnt = pt->line_cnt
   FOR (j = 1 TO pt->line_cnt)
     SET print->updtstatus_wrap[j].line = pt->lns[j].line
   ENDFOR
   FOR (i = 1 TO categorycnt)
     SET max_length = 110
     SET pt->line_cnt = 0
     CALL parsetext(print->category[i].display,max_length)
     SET stat = alterlist(print->category[i].wrap,pt->line_cnt)
     SET print->category[i].wrapcnt = pt->line_cnt
     FOR (j = 1 TO pt->line_cnt)
       SET print->category[i].wrap[j].line = pt->lns[j].line
     ENDFOR
     SET pt->line_cnt = 0
     CALL parsetext(print->category[i].assessment,max_length)
     SET stat = alterlist(print->category[i].assessment_wrap,pt->line_cnt)
     SET print->category[i].assessment_wrapcnt = pt->line_cnt
     FOR (j = 1 TO pt->line_cnt)
       SET print->category[i].assessment_wrap[j].line = pt->lns[j].line
     ENDFOR
     SET activitycnt = value(size(print->category[i].activity,5))
     FOR (x = 1 TO activitycnt)
       SET max_length = 100
       SET pt->line_cnt = 0
       FREE RECORD blob
       EXECUTE dcp_parse_text value(print->category[i].activity[x].detail_summary), value(max_length)
       SET stat = alterlist(print->category[i].activity[x].detail_summary_wrap,pt->line_cnt)
       SET print->category[i].activity[x].detail_summary_wrapcnt = pt->line_cnt
       FOR (j = 1 TO pt->line_cnt)
         SET print->category[i].activity[x].detail_summary_wrap[j].line = pt->lns[j].line
       ENDFOR
       RECORD blob(
         1 line = vc
         1 cnt = i2
         1 qual[*]
           2 line = vc
           2 sze = i4
       )
       SET commentcnt = value(size(print->category[i].activity[x].comments,5))
       FOR (y = 1 TO commentcnt)
         SET max_length = 95
         SET pt->line_cnt = 0
         CALL parsetext(value(print->category[i].activity[x].comments[y].value),value(max_length))
         SET stat = alterlist(print->category[i].activity[x].comments[y].wrap,pt->line_cnt)
         SET print->category[i].activity[x].comments[y].wrapcnt = pt->line_cnt
         FOR (j = 1 TO pt->line_cnt)
           SET print->category[i].activity[x].comments[y].wrap[j].line = pt->lns[j].line
         ENDFOR
       ENDFOR
     ENDFOR
   ENDFOR
   IF (debug=1)
    CALL echorecord(print)
   ENDIF
 END ;Subroutine
 SUBROUTINE formatreport(dummyvar)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = 1)
    PLAN (d1)
    HEAD REPORT
     IF ((print->unable_to_obtain != ""))
      FOR (j = 1 TO print->updtstatus_wrapcnt)
        col 0, print->updtstatus_wrap[j].line, row + 1
      ENDFOR
      row + 1, col 0, print->unable_to_obtain,
      row + 2
     ENDIF
    DETAIL
     catcnt = size(print->category,5)
     FOR (i = 1 TO catcnt)
       wrapcnt = print->category[i].wrapcnt
       FOR (j = 1 TO wrapcnt)
         col 0, print->category[i].wrap[j].line, row + 1
       ENDFOR
       activcnt = size(print->category[i].activity,5)
       IF ((print->category[i].assessment != ""))
        wrapcnt = print->category[i].assessment_wrapcnt
        FOR (j = 1 TO wrapcnt)
          col 5, print->category[i].assessment_wrap[j].line, row + 1
        ENDFOR
        IF (activcnt < 1)
         row + 1
        ENDIF
       ENDIF
       FOR (x = 1 TO activcnt)
         IF ((print->category[i].activity[x].detail_summary != ""))
          wrapcnt = print->category[i].activity[x].detail_summary_wrapcnt
          FOR (j = 1 TO wrapcnt)
            col 10, print->category[i].activity[x].detail_summary_wrap[j].line, row + 1
          ENDFOR
         ENDIF
         cmtcnt = size(print->category[i].activity[x].comments,5)
         IF (cmtcnt > 0)
          FOR (y = 1 TO cmtcnt)
            row + 1, cmtwrapcnt = print->category[i].activity[x].comments[y].wrapcnt
            FOR (j = 1 TO cmtwrapcnt)
              col 15, print->category[i].activity[x].comments[y].wrap[j].line, row + 1
            ENDFOR
          ENDFOR
         ENDIF
         row + 1
       ENDFOR
     ENDFOR
    FOOT PAGE
     numrows = row, stat = alterlist(reply->qual,((ln+ numrows)+ 1))
     FOR (pagevar = 0 TO numrows)
       ln = (ln+ 1), reply->qual[ln].line = reportrow((pagevar+ 1)), done = "F"
       WHILE (done="F")
        nullpos = findstring(char(0),reply->qual[ln].line),
        IF (nullpos > 0)
         stat = movestring(" ",1,reply->qual[ln].line,nullpos,1)
        ELSE
         done = "T"
        ENDIF
       ENDWHILE
     ENDFOR
     reply->num_lines = ln
    WITH nocounter, maxcol = 132, maxrow = 10000
   ;end select
 END ;Subroutine
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET cfailed = "T"
   SET cnt = size(reply->status_data.subeventstatus,5)
   IF (((cnt != 1) OR (cnt=1
    AND (reply->status_data.subeventstatus[1].operationstatus != null))) )
    SET cnt = (cnt+ 1)
    SET stat = alter(reply->status_data.subeventstatus,value(cnt))
   ENDIF
   SET reply->status_data.subeventstatus[cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[cnt].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[cnt].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 IF (cfailed="T")
  SET reply->status_data.status = "F"
 ELSE
  IF (cnodata="Y")
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 IF (debug=1)
  CALL echorecord(reply)
 ENDIF
 FREE RECORD blob
 FREE RECORD print
 FREE RECORD data
 FREE RECORD captions
 FREE RECORD get_print_data
END GO
