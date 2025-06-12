CREATE PROGRAM bed_aud_iview_pref_settings:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist[*]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist[*]
        3 dbl_value = f8
        3 string_value = vc
      2 yes_no_ind = i2
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 EXECUTE prefrtl
 SET stat = alterlist(reply->collist,6)
 SET reply->collist[1].header_text = "Preference Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Recommended Setting"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Actual Setting"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Preference Value"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 1
 SET reply->collist[5].header_text = "Level"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Details"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET rcnt = 0
 SET reply->run_status_flag = 1
 DECLARE hpref = i4 WITH noconstant(0)
 SET hpref = uar_prefcreateinstance(18)
 SET stat = uar_prefsetbasedn(hpref,"prefroot=prefroot")
 SET stat = uar_prefaddattr(hpref,"prefvalue")
 SET stat = uar_prefaddattr(hpref,"prefcontext")
 SET stat = uar_prefaddfilter(hpref,"prefentry=seeker")
 SET stat = uar_prefperform(hpref)
 DECLARE count = i4
 SET stat = uar_prefgetentrycount(hpref,count)
 SET i = 0
 DECLARE dnstr = c255 WITH noconstant("")
 DECLARE grpstr = c255 WITH noconstant("")
 DECLARE posstr = c40 WITH noconstant("")
 DECLARE locstr = c40 WITH noconstant("")
 SET user_id = 0
 SET pos_cd = 0
 SET loc_cd = 0
 FOR (x = 0 TO (count - 1))
   SET hentry = uar_prefgetentry(hpref,x)
   SET stat = uar_prefgetentryname(hentry,dnstr,255)
   SET i = findstring("prefcontext=reference",dnstr)
   IF (i=0)
    SET a = findstring("prefgroup=",dnstr,1,1)
    SET b = findstring("=",dnstr,a)
    SET c = findstring(",",dnstr,a)
    SET grpstr = substring((b+ 1),((c - b) - 1),dnstr)
    SET rcnt = (rcnt+ 1)
    SET stat = alterlist(reply->rowlist,rcnt)
    SET stat = alterlist(reply->rowlist[rcnt].celllist,6)
    SET reply->rowlist[rcnt].celllist[1].string_value = "Seeker"
    SET reply->rowlist[rcnt].celllist[2].string_value = "Off"
    SET acnt = 0
    SET stat = uar_prefgetentryattrcount(hentry,acnt)
    FOR (y = 0 TO (acnt - 1))
      SET hattr = uar_prefgetentryattr(hentry,y)
      SET valcnt = 0
      DECLARE xvalue = c255 WITH noconstant("")
      DECLARE yvalue = c255 WITH noconstant("")
      SET stat = uar_prefgetattrval(hattr,xvalue,255,0)
      SET stat = uar_prefgetattrname(hattr,yvalue,255)
      CALL echo(build("value:",xvalue))
      IF (yvalue="prefvalue")
       SET reply->rowlist[rcnt].celllist[3].string_value = xvalue
      ENDIF
      IF (yvalue="prefcontext")
       SET reply->rowlist[rcnt].celllist[5].string_value = xvalue
       IF (xvalue="user")
        SET user_id = cnvtint(grpstr)
        SELECT INTO "nl:"
         FROM prsnl p
         PLAN (p
          WHERE p.person_id=user_id)
         DETAIL
          reply->rowlist[rcnt].celllist[6].string_value = p.name_full_formatted
         WITH nocounter
        ;end select
       ENDIF
       IF (xvalue="position")
        SET pos_cd = cnvtint(grpstr)
        SELECT INTO "nl:"
         FROM code_value c
         PLAN (c
          WHERE c.code_value=pos_cd)
         DETAIL
          reply->rowlist[rcnt].celllist[6].string_value = c.display
         WITH nocounter
        ;end select
       ENDIF
       IF (xvalue="position location")
        SET a = findstring("^",grpstr)
        SET pos_cd = cnvtint(substring(1,(a - 1),grpstr))
        SET b = textlen(grpstr)
        SET loc_cd = cnvtint(substring((a+ 1),((b - a) - 1),grpstr))
        SELECT INTO "nl:"
         FROM code_value c
         PLAN (c
          WHERE c.code_value=pos_cd)
         DETAIL
          posstr = c.display
         WITH nocounter
        ;end select
        SELECT INTO "nl:"
         FROM code_value c
         PLAN (c
          WHERE c.code_value=loc_cd)
         DETAIL
          locstr = c.display
         WITH nocounter
        ;end select
        SET reply->rowlist[rcnt].celllist[6].string_value = concat(trim(posstr),"/",trim(locstr))
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 CALL uar_prefdestroyinstance(hpref)
 SET hpref = uar_prefcreateinstance(18)
 SET stat = uar_prefsetbasedn(hpref,"prefroot=prefroot")
 SET stat = uar_prefaddattr(hpref,"prefvalue")
 SET stat = uar_prefaddattr(hpref,"prefcontext")
 SET stat = uar_prefaddfilter(hpref,"prefentry=last_x_hours")
 SET stat = uar_prefperform(hpref)
 DECLARE count = i4
 SET stat = uar_prefgetentrycount(hpref,count)
 SET i = 0
 DECLARE dnstr = c255 WITH noconstant("")
 DECLARE grpstr = c255 WITH noconstant("")
 DECLARE posstr = c40 WITH noconstant("")
 DECLARE locstr = c40 WITH noconstant("")
 SET user_id = 0
 SET pos_cd = 0
 SET loc_cd = 0
 FOR (x = 0 TO (count - 1))
   SET hentry = uar_prefgetentry(hpref,x)
   SET stat = uar_prefgetentryname(hentry,dnstr,255)
   CALL echo(dnstr)
   SET i = findstring("prefcontext=reference",dnstr)
   IF (i=0)
    SET a = findstring("prefgroup=",dnstr,1,1)
    SET b = findstring("=",dnstr,a)
    SET c = findstring(",",dnstr,a)
    SET grpstr = substring((b+ 1),((c - b) - 1),dnstr)
    CALL echo(grpstr)
    SET rcnt = (rcnt+ 1)
    SET stat = alterlist(reply->rowlist,rcnt)
    SET stat = alterlist(reply->rowlist[rcnt].celllist,6)
    SET reply->rowlist[rcnt].celllist[1].string_value = "Last X Hours"
    SET reply->rowlist[rcnt].celllist[2].string_value = "<= 12 Hours"
    SET acnt = 0
    SET stat = uar_prefgetentryattrcount(hentry,acnt)
    FOR (y = 0 TO (acnt - 1))
      SET hattr = uar_prefgetentryattr(hentry,y)
      SET valcnt = 0
      DECLARE xvalue = c255 WITH noconstant("")
      DECLARE yvalue = c255 WITH noconstant("")
      SET stat = uar_prefgetattrval(hattr,xvalue,255,0)
      SET stat = uar_prefgetattrname(hattr,yvalue,255)
      CALL echo(build("value:",xvalue))
      IF (yvalue="prefvalue")
       SET reply->rowlist[rcnt].celllist[3].string_value = xvalue
      ENDIF
      IF (yvalue="prefcontext")
       SET reply->rowlist[rcnt].celllist[5].string_value = xvalue
       IF (xvalue="user")
        SET user_id = cnvtint(grpstr)
        SELECT INTO "nl:"
         FROM prsnl p
         PLAN (p
          WHERE p.person_id=user_id)
         DETAIL
          reply->rowlist[rcnt].celllist[6].string_value = p.name_full_formatted
         WITH nocounter
        ;end select
       ENDIF
       IF (xvalue="position")
        SET pos_cd = cnvtint(grpstr)
        SELECT INTO "nl:"
         FROM code_value c
         PLAN (c
          WHERE c.code_value=pos_cd)
         DETAIL
          reply->rowlist[rcnt].celllist[6].string_value = c.display
         WITH nocounter
        ;end select
       ENDIF
       IF (xvalue="position location")
        SET a = findstring("^",grpstr)
        SET pos_cd = cnvtint(substring(1,(a - 1),grpstr))
        SET b = textlen(grpstr)
        SET loc_cd = cnvtint(substring((a+ 1),((b - a) - 1),grpstr))
        SELECT INTO "nl:"
         FROM code_value c
         PLAN (c
          WHERE c.code_value=pos_cd)
         DETAIL
          posstr = c.display
         WITH nocounter
        ;end select
        SELECT INTO "nl:"
         FROM code_value c
         PLAN (c
          WHERE c.code_value=loc_cd)
         DETAIL
          locstr = c.display
         WITH nocounter
        ;end select
        SET reply->rowlist[rcnt].celllist[6].string_value = concat(trim(posstr),"/",trim(locstr))
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 CALL uar_prefdestroyinstance(hpref)
 SET hpref = uar_prefcreateinstance(18)
 SET stat = uar_prefsetbasedn(hpref,"prefroot=prefroot")
 SET stat = uar_prefaddattr(hpref,"prefvalue")
 SET stat = uar_prefaddattr(hpref,"prefcontext")
 SET stat = uar_prefaddfilter(hpref,"prefentry=last_x_results")
 SET stat = uar_prefperform(hpref)
 DECLARE count = i4
 SET stat = uar_prefgetentrycount(hpref,count)
 SET i = 0
 DECLARE dnstr = c255 WITH noconstant("")
 DECLARE grpstr = c255 WITH noconstant("")
 DECLARE posstr = c40 WITH noconstant("")
 DECLARE locstr = c40 WITH noconstant("")
 SET user_id = 0
 SET pos_cd = 0
 SET loc_cd = 0
 FOR (x = 0 TO (count - 1))
   SET hentry = uar_prefgetentry(hpref,x)
   SET stat = uar_prefgetentryname(hentry,dnstr,255)
   SET i = findstring("prefcontext=reference",dnstr)
   IF (i=0)
    SET a = findstring("prefgroup=",dnstr,1,1)
    SET b = findstring("=",dnstr,a)
    SET c = findstring(",",dnstr,a)
    SET grpstr = substring((b+ 1),((c - b) - 1),dnstr)
    SET rcnt = (rcnt+ 1)
    SET stat = alterlist(reply->rowlist,rcnt)
    SET stat = alterlist(reply->rowlist[rcnt].celllist,6)
    SET reply->rowlist[rcnt].celllist[1].string_value = "Last X Results"
    SET reply->rowlist[rcnt].celllist[2].string_value = "> 0 and < 2000"
    SET acnt = 0
    SET stat = uar_prefgetentryattrcount(hentry,acnt)
    FOR (y = 0 TO (acnt - 1))
      SET hattr = uar_prefgetentryattr(hentry,y)
      SET valcnt = 0
      DECLARE xvalue = c255 WITH noconstant("")
      DECLARE yvalue = c255 WITH noconstant("")
      SET stat = uar_prefgetattrval(hattr,xvalue,255,0)
      SET stat = uar_prefgetattrname(hattr,yvalue,255)
      CALL echo(build("value:",xvalue))
      IF (yvalue="prefvalue")
       SET reply->rowlist[rcnt].celllist[3].string_value = xvalue
      ENDIF
      IF (yvalue="prefcontext")
       SET reply->rowlist[rcnt].celllist[5].string_value = xvalue
       IF (xvalue="user")
        SET user_id = cnvtint(grpstr)
        SELECT INTO "nl:"
         FROM prsnl p
         PLAN (p
          WHERE p.person_id=user_id)
         DETAIL
          reply->rowlist[rcnt].celllist[6].string_value = p.name_full_formatted
         WITH nocounter
        ;end select
       ENDIF
       IF (xvalue="position")
        SET pos_cd = cnvtint(grpstr)
        SELECT INTO "nl:"
         FROM code_value c
         PLAN (c
          WHERE c.code_value=pos_cd)
         DETAIL
          reply->rowlist[rcnt].celllist[6].string_value = c.display
         WITH nocounter
        ;end select
       ENDIF
       IF (xvalue="position location")
        SET a = findstring("^",grpstr)
        SET pos_cd = cnvtint(substring(1,(a - 1),grpstr))
        SET b = textlen(grpstr)
        SET loc_cd = cnvtint(substring((a+ 1),((b - a) - 1),grpstr))
        SELECT INTO "nl:"
         FROM code_value c
         PLAN (c
          WHERE c.code_value=pos_cd)
         DETAIL
          posstr = c.display
         WITH nocounter
        ;end select
        SELECT INTO "nl:"
         FROM code_value c
         PLAN (c
          WHERE c.code_value=loc_cd)
         DETAIL
          locstr = c.display
         WITH nocounter
        ;end select
        SET reply->rowlist[rcnt].celllist[6].string_value = concat(trim(posstr),"/",trim(locstr))
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 CALL uar_prefdestroyinstance(hpref)
 SET hpref = uar_prefcreateinstance(18)
 SET stat = uar_prefsetbasedn(hpref,"prefroot=prefroot")
 SET stat = uar_prefaddattr(hpref,"prefvalue")
 SET stat = uar_prefaddattr(hpref,"prefcontext")
 SET stat = uar_prefaddfilter(hpref,"prefentry=default_freq_interval")
 SET stat = uar_prefperform(hpref)
 DECLARE count = i4
 SET stat = uar_prefgetentrycount(hpref,count)
 SET i = 0
 DECLARE dnstr = c255 WITH noconstant("")
 DECLARE grpstr = c255 WITH noconstant("")
 DECLARE posstr = c40 WITH noconstant("")
 DECLARE locstr = c40 WITH noconstant("")
 SET user_id = 0
 SET pos_cd = 0
 SET loc_cd = 0
 FOR (x = 0 TO (count - 1))
   SET hentry = uar_prefgetentry(hpref,x)
   SET stat = uar_prefgetentryname(hentry,dnstr,255)
   SET i = findstring("prefcontext=reference",dnstr)
   IF (i=0)
    SET a = findstring("prefgroup=",dnstr,1,1)
    SET b = findstring("=",dnstr,a)
    SET c = findstring(",",dnstr,a)
    SET grpstr = substring((b+ 1),((c - b) - 1),dnstr)
    SET rcnt = (rcnt+ 1)
    SET stat = alterlist(reply->rowlist,rcnt)
    SET stat = alterlist(reply->rowlist[rcnt].celllist,6)
    SET reply->rowlist[rcnt].celllist[1].string_value = "Default Freq Interval"
    SET reply->rowlist[rcnt].celllist[2].string_value = "Actual"
    SET acnt = 0
    SET stat = uar_prefgetentryattrcount(hentry,acnt)
    FOR (y = 0 TO (acnt - 1))
      SET hattr = uar_prefgetentryattr(hentry,y)
      SET valcnt = 0
      DECLARE xvalue = c255 WITH noconstant("")
      DECLARE yvalue = c255 WITH noconstant("")
      SET stat = uar_prefgetattrval(hattr,xvalue,255,0)
      SET stat = uar_prefgetattrname(hattr,yvalue,255)
      CALL echo(build("value:",xvalue))
      IF (yvalue="prefvalue")
       SET reply->rowlist[rcnt].celllist[3].string_value = xvalue
      ENDIF
      IF (yvalue="prefcontext")
       SET reply->rowlist[rcnt].celllist[5].string_value = xvalue
       IF (xvalue="user")
        SET user_id = cnvtint(grpstr)
        SELECT INTO "nl:"
         FROM prsnl p
         PLAN (p
          WHERE p.person_id=user_id)
         DETAIL
          reply->rowlist[rcnt].celllist[6].string_value = p.name_full_formatted
         WITH nocounter
        ;end select
       ENDIF
       IF (xvalue="position")
        SET pos_cd = cnvtint(grpstr)
        SELECT INTO "nl:"
         FROM code_value c
         PLAN (c
          WHERE c.code_value=pos_cd)
         DETAIL
          reply->rowlist[rcnt].celllist[6].string_value = c.display
         WITH nocounter
        ;end select
       ENDIF
       IF (xvalue="position location")
        SET a = findstring("^",grpstr)
        SET pos_cd = cnvtint(substring(1,(a - 1),grpstr))
        SET b = textlen(grpstr)
        SET loc_cd = cnvtint(substring((a+ 1),((b - a) - 1),grpstr))
        SELECT INTO "nl:"
         FROM code_value c
         PLAN (c
          WHERE c.code_value=pos_cd)
         DETAIL
          posstr = c.display
         WITH nocounter
        ;end select
        SELECT INTO "nl:"
         FROM code_value c
         PLAN (c
          WHERE c.code_value=loc_cd)
         DETAIL
          locstr = c.display
         WITH nocounter
        ;end select
        SET reply->rowlist[rcnt].celllist[6].string_value = concat(trim(posstr),"/",trim(locstr))
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 CALL uar_prefdestroyinstance(hpref)
 SET hpref = uar_prefcreateinstance(18)
 SET stat = uar_prefsetbasedn(hpref,"prefroot=prefroot")
 SET stat = uar_prefaddattr(hpref,"prefvalue")
 SET stat = uar_prefaddattr(hpref,"prefcontext")
 SET stat = uar_prefaddfilter(hpref,"prefentry=enhanced_performance")
 SET stat = uar_prefperform(hpref)
 DECLARE count = i4
 SET stat = uar_prefgetentrycount(hpref,count)
 SET i = 0
 DECLARE dnstr = c255 WITH noconstant("")
 DECLARE grpstr = c255 WITH noconstant("")
 DECLARE posstr = c40 WITH noconstant("")
 DECLARE locstr = c40 WITH noconstant("")
 SET user_id = 0
 SET pos_cd = 0
 SET loc_cd = 0
 FOR (x = 0 TO (count - 1))
   SET hentry = uar_prefgetentry(hpref,x)
   SET stat = uar_prefgetentryname(hentry,dnstr,255)
   SET i = findstring("prefcontext=reference",dnstr)
   IF (i=0)
    SET a = findstring("prefgroup=",dnstr,1,1)
    SET b = findstring("=",dnstr,a)
    SET c = findstring(",",dnstr,a)
    SET grpstr = substring((b+ 1),((c - b) - 1),dnstr)
    SET rcnt = (rcnt+ 1)
    SET stat = alterlist(reply->rowlist,rcnt)
    SET stat = alterlist(reply->rowlist[rcnt].celllist,6)
    SET reply->rowlist[rcnt].celllist[1].string_value = "Enhanced Performance"
    SET reply->rowlist[rcnt].celllist[2].string_value = "On"
    SET acnt = 0
    SET stat = uar_prefgetentryattrcount(hentry,acnt)
    FOR (y = 0 TO (acnt - 1))
      SET hattr = uar_prefgetentryattr(hentry,y)
      SET valcnt = 0
      DECLARE xvalue = c255 WITH noconstant("")
      DECLARE yvalue = c255 WITH noconstant("")
      SET stat = uar_prefgetattrval(hattr,xvalue,255,0)
      SET stat = uar_prefgetattrname(hattr,yvalue,255)
      CALL echo(build("value:",xvalue))
      IF (yvalue="prefvalue")
       SET reply->rowlist[rcnt].celllist[3].string_value = xvalue
      ENDIF
      IF (yvalue="prefcontext")
       SET reply->rowlist[rcnt].celllist[5].string_value = xvalue
       IF (xvalue="user")
        SET user_id = cnvtint(grpstr)
        SELECT INTO "nl:"
         FROM prsnl p
         PLAN (p
          WHERE p.person_id=user_id)
         DETAIL
          reply->rowlist[rcnt].celllist[6].string_value = p.name_full_formatted
         WITH nocounter
        ;end select
       ENDIF
       IF (xvalue="position")
        SET pos_cd = cnvtint(grpstr)
        SELECT INTO "nl:"
         FROM code_value c
         PLAN (c
          WHERE c.code_value=pos_cd)
         DETAIL
          reply->rowlist[rcnt].celllist[6].string_value = c.display
         WITH nocounter
        ;end select
       ENDIF
       IF (xvalue="position location")
        SET a = findstring("^",grpstr)
        SET pos_cd = cnvtint(substring(1,(a - 1),grpstr))
        SET b = textlen(grpstr)
        SET loc_cd = cnvtint(substring((a+ 1),((b - a) - 1),grpstr))
        SELECT INTO "nl:"
         FROM code_value c
         PLAN (c
          WHERE c.code_value=pos_cd)
         DETAIL
          posstr = c.display
         WITH nocounter
        ;end select
        SELECT INTO "nl:"
         FROM code_value c
         PLAN (c
          WHERE c.code_value=loc_cd)
         DETAIL
          locstr = c.display
         WITH nocounter
        ;end select
        SET reply->rowlist[rcnt].celllist[6].string_value = concat(trim(posstr),"/",trim(locstr))
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 CALL uar_prefdestroyinstance(hpref)
 SET hpref = uar_prefcreateinstance(18)
 SET stat = uar_prefsetbasedn(hpref,"prefroot=prefroot")
 SET stat = uar_prefaddattr(hpref,"prefvalue")
 SET stat = uar_prefaddattr(hpref,"prefcontext")
 SET stat = uar_prefaddfilter(hpref,"prefentry=auto_populate_bmdi")
 SET stat = uar_prefperform(hpref)
 DECLARE count = i4
 SET stat = uar_prefgetentrycount(hpref,count)
 SET i = 0
 DECLARE dnstr = c255 WITH noconstant("")
 DECLARE grpstr = c255 WITH noconstant("")
 DECLARE posstr = c40 WITH noconstant("")
 DECLARE locstr = c40 WITH noconstant("")
 SET user_id = 0
 SET pos_cd = 0
 SET loc_cd = 0
 FOR (x = 0 TO (count - 1))
   SET hentry = uar_prefgetentry(hpref,x)
   SET stat = uar_prefgetentryname(hentry,dnstr,255)
   SET i = findstring("prefcontext=reference",dnstr)
   IF (i=0)
    SET a = findstring("prefgroup=",dnstr,1,1)
    SET b = findstring("=",dnstr,a)
    SET c = findstring(",",dnstr,a)
    SET grpstr = substring((b+ 1),((c - b) - 1),dnstr)
    SET rcnt = (rcnt+ 1)
    SET stat = alterlist(reply->rowlist,rcnt)
    SET stat = alterlist(reply->rowlist[rcnt].celllist,6)
    SET reply->rowlist[rcnt].celllist[1].string_value = "Auto-populate BMDI Time"
    SET reply->rowlist[rcnt].celllist[2].string_value = "Off"
    SET acnt = 0
    SET stat = uar_prefgetentryattrcount(hentry,acnt)
    FOR (y = 0 TO (acnt - 1))
      SET hattr = uar_prefgetentryattr(hentry,y)
      SET valcnt = 0
      DECLARE xvalue = c255 WITH noconstant("")
      DECLARE yvalue = c255 WITH noconstant("")
      SET stat = uar_prefgetattrval(hattr,xvalue,255,0)
      SET stat = uar_prefgetattrname(hattr,yvalue,255)
      CALL echo(build("value:",xvalue))
      IF (yvalue="prefvalue")
       SET reply->rowlist[rcnt].celllist[3].string_value = xvalue
      ENDIF
      IF (yvalue="prefcontext")
       SET reply->rowlist[rcnt].celllist[5].string_value = xvalue
       IF (xvalue="user")
        SET user_id = cnvtint(grpstr)
        SELECT INTO "nl:"
         FROM prsnl p
         PLAN (p
          WHERE p.person_id=user_id)
         DETAIL
          reply->rowlist[rcnt].celllist[6].string_value = p.name_full_formatted
         WITH nocounter
        ;end select
       ENDIF
       IF (xvalue="position")
        SET pos_cd = cnvtint(grpstr)
        SELECT INTO "nl:"
         FROM code_value c
         PLAN (c
          WHERE c.code_value=pos_cd)
         DETAIL
          reply->rowlist[rcnt].celllist[6].string_value = c.display
         WITH nocounter
        ;end select
       ENDIF
       IF (xvalue="position location")
        SET a = findstring("^",grpstr)
        SET pos_cd = cnvtint(substring(1,(a - 1),grpstr))
        SET b = textlen(grpstr)
        SET loc_cd = cnvtint(substring((a+ 1),((b - a) - 1),grpstr))
        SELECT INTO "nl:"
         FROM code_value c
         PLAN (c
          WHERE c.code_value=pos_cd)
         DETAIL
          posstr = c.display
         WITH nocounter
        ;end select
        SELECT INTO "nl:"
         FROM code_value c
         PLAN (c
          WHERE c.code_value=loc_cd)
         DETAIL
          locstr = c.display
         WITH nocounter
        ;end select
        SET reply->rowlist[rcnt].celllist[6].string_value = concat(trim(posstr),"/",trim(locstr))
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 CALL uar_prefdestroyinstance(hpref)
 SET hpref = uar_prefcreateinstance(18)
 SET stat = uar_prefsetbasedn(hpref,"prefroot=prefroot")
 SET stat = uar_prefaddattr(hpref,"prefvalue")
 SET stat = uar_prefaddattr(hpref,"prefcontext")
 SET stat = uar_prefaddfilter(hpref,"prefentry=auto_populate_bmdi_timeframe")
 SET stat = uar_prefperform(hpref)
 DECLARE count = i4
 SET stat = uar_prefgetentrycount(hpref,count)
 SET i = 0
 DECLARE dnstr = c255 WITH noconstant("")
 DECLARE grpstr = c255 WITH noconstant("")
 DECLARE posstr = c40 WITH noconstant("")
 DECLARE locstr = c40 WITH noconstant("")
 SET user_id = 0
 SET pos_cd = 0
 SET loc_cd = 0
 FOR (x = 0 TO (count - 1))
   SET hentry = uar_prefgetentry(hpref,x)
   SET stat = uar_prefgetentryname(hentry,dnstr,255)
   SET i = findstring("prefcontext=reference",dnstr)
   IF (i=0)
    SET a = findstring("prefgroup=",dnstr,1,1)
    SET b = findstring("=",dnstr,a)
    SET c = findstring(",",dnstr,a)
    SET grpstr = substring((b+ 1),((c - b) - 1),dnstr)
    SET rcnt = (rcnt+ 1)
    SET stat = alterlist(reply->rowlist,rcnt)
    SET stat = alterlist(reply->rowlist[rcnt].celllist,6)
    SET reply->rowlist[rcnt].celllist[1].string_value = "Auto-populate BMDI Timeframe"
    SET reply->rowlist[rcnt].celllist[2].string_value = ">= 12 Hours"
    SET acnt = 0
    SET stat = uar_prefgetentryattrcount(hentry,acnt)
    FOR (y = 0 TO (acnt - 1))
      SET hattr = uar_prefgetentryattr(hentry,y)
      SET valcnt = 0
      DECLARE xvalue = c255 WITH noconstant("")
      DECLARE yvalue = c255 WITH noconstant("")
      SET stat = uar_prefgetattrval(hattr,xvalue,255,0)
      SET stat = uar_prefgetattrname(hattr,yvalue,255)
      CALL echo(build("value:",xvalue))
      IF (yvalue="prefvalue")
       SET reply->rowlist[rcnt].celllist[3].string_value = xvalue
      ENDIF
      IF (yvalue="prefcontext")
       SET reply->rowlist[rcnt].celllist[5].string_value = xvalue
       IF (xvalue="user")
        SET user_id = cnvtint(grpstr)
        SELECT INTO "nl:"
         FROM prsnl p
         PLAN (p
          WHERE p.person_id=user_id)
         DETAIL
          reply->rowlist[rcnt].celllist[6].string_value = p.name_full_formatted
         WITH nocounter
        ;end select
       ENDIF
       IF (xvalue="position")
        SET pos_cd = cnvtint(grpstr)
        SELECT INTO "nl:"
         FROM code_value c
         PLAN (c
          WHERE c.code_value=pos_cd)
         DETAIL
          reply->rowlist[rcnt].celllist[6].string_value = c.display
         WITH nocounter
        ;end select
       ENDIF
       IF (xvalue="position location")
        SET a = findstring("^",grpstr)
        SET pos_cd = cnvtint(substring(1,(a - 1),grpstr))
        SET b = textlen(grpstr)
        SET loc_cd = cnvtint(substring((a+ 1),((b - a) - 1),grpstr))
        SELECT INTO "nl:"
         FROM code_value c
         PLAN (c
          WHERE c.code_value=pos_cd)
         DETAIL
          posstr = c.display
         WITH nocounter
        ;end select
        SELECT INTO "nl:"
         FROM code_value c
         PLAN (c
          WHERE c.code_value=loc_cd)
         DETAIL
          locstr = c.display
         WITH nocounter
        ;end select
        SET reply->rowlist[rcnt].celllist[6].string_value = concat(trim(posstr),"/",trim(locstr))
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 CALL uar_prefdestroyinstance(hpref)
 SET hpref = uar_prefcreateinstance(18)
 SET stat = uar_prefsetbasedn(hpref,"prefroot=prefroot")
 SET stat = uar_prefaddattr(hpref,"prefvalue")
 SET stat = uar_prefaddattr(hpref,"prefcontext")
 SET stat = uar_prefaddfilter(hpref,"prefentry=bmdi_look_back_min")
 SET stat = uar_prefperform(hpref)
 DECLARE count = i4
 SET stat = uar_prefgetentrycount(hpref,count)
 SET i = 0
 DECLARE dnstr = c255 WITH noconstant("")
 DECLARE grpstr = c255 WITH noconstant("")
 DECLARE posstr = c40 WITH noconstant("")
 DECLARE locstr = c40 WITH noconstant("")
 SET user_id = 0
 SET pos_cd = 0
 SET loc_cd = 0
 FOR (x = 0 TO (count - 1))
   SET hentry = uar_prefgetentry(hpref,x)
   SET stat = uar_prefgetentryname(hentry,dnstr,255)
   SET i = findstring("prefcontext=reference",dnstr)
   IF (i=0)
    SET a = findstring("prefgroup=",dnstr,1,1)
    SET b = findstring("=",dnstr,a)
    SET c = findstring(",",dnstr,a)
    SET grpstr = substring((b+ 1),((c - b) - 1),dnstr)
    SET rcnt = (rcnt+ 1)
    SET stat = alterlist(reply->rowlist,rcnt)
    SET stat = alterlist(reply->rowlist[rcnt].celllist,6)
    SET reply->rowlist[rcnt].celllist[1].string_value = "BMDI Look Back Minutes"
    SET reply->rowlist[rcnt].celllist[2].string_value = "30"
    SET acnt = 0
    SET stat = uar_prefgetentryattrcount(hentry,acnt)
    FOR (y = 0 TO (acnt - 1))
      SET hattr = uar_prefgetentryattr(hentry,y)
      SET valcnt = 0
      DECLARE xvalue = c255 WITH noconstant("")
      DECLARE yvalue = c255 WITH noconstant("")
      SET stat = uar_prefgetattrval(hattr,xvalue,255,0)
      SET stat = uar_prefgetattrname(hattr,yvalue,255)
      CALL echo(build("value:",xvalue))
      IF (yvalue="prefvalue")
       SET reply->rowlist[rcnt].celllist[3].string_value = xvalue
      ENDIF
      IF (yvalue="prefcontext")
       SET reply->rowlist[rcnt].celllist[5].string_value = xvalue
       IF (xvalue="user")
        SET user_id = cnvtint(grpstr)
        SELECT INTO "nl:"
         FROM prsnl p
         PLAN (p
          WHERE p.person_id=user_id)
         DETAIL
          reply->rowlist[rcnt].celllist[6].string_value = p.name_full_formatted
         WITH nocounter
        ;end select
       ENDIF
       IF (xvalue="position")
        SET pos_cd = cnvtint(grpstr)
        SELECT INTO "nl:"
         FROM code_value c
         PLAN (c
          WHERE c.code_value=pos_cd)
         DETAIL
          reply->rowlist[rcnt].celllist[6].string_value = c.display
         WITH nocounter
        ;end select
       ENDIF
       IF (xvalue="position location")
        SET a = findstring("^",grpstr)
        SET pos_cd = cnvtint(substring(1,(a - 1),grpstr))
        SET b = textlen(grpstr)
        SET loc_cd = cnvtint(substring((a+ 1),((b - a) - 1),grpstr))
        SELECT INTO "nl:"
         FROM code_value c
         PLAN (c
          WHERE c.code_value=pos_cd)
         DETAIL
          posstr = c.display
         WITH nocounter
        ;end select
        SELECT INTO "nl:"
         FROM code_value c
         PLAN (c
          WHERE c.code_value=loc_cd)
         DETAIL
          locstr = c.display
         WITH nocounter
        ;end select
        SET reply->rowlist[rcnt].celllist[6].string_value = concat(trim(posstr),"/",trim(locstr))
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 CALL uar_prefdestroyinstance(hpref)
 SET hpref = uar_prefcreateinstance(18)
 SET stat = uar_prefsetbasedn(hpref,"prefroot=prefroot")
 SET stat = uar_prefaddattr(hpref,"prefvalue")
 SET stat = uar_prefaddattr(hpref,"prefcontext")
 SET stat = uar_prefaddfilter(hpref,"prefentry=bmdi_look_forward_min")
 SET stat = uar_prefperform(hpref)
 DECLARE count = i4
 SET stat = uar_prefgetentrycount(hpref,count)
 SET i = 0
 DECLARE dnstr = c255 WITH noconstant("")
 DECLARE grpstr = c255 WITH noconstant("")
 DECLARE posstr = c40 WITH noconstant("")
 DECLARE locstr = c40 WITH noconstant("")
 SET user_id = 0
 SET pos_cd = 0
 SET loc_cd = 0
 FOR (x = 0 TO (count - 1))
   SET hentry = uar_prefgetentry(hpref,x)
   SET stat = uar_prefgetentryname(hentry,dnstr,255)
   SET i = findstring("prefcontext=reference",dnstr)
   IF (i=0)
    SET a = findstring("prefgroup=",dnstr,1,1)
    SET b = findstring("=",dnstr,a)
    SET c = findstring(",",dnstr,a)
    SET grpstr = substring((b+ 1),((c - b) - 1),dnstr)
    SET rcnt = (rcnt+ 1)
    SET stat = alterlist(reply->rowlist,rcnt)
    SET stat = alterlist(reply->rowlist[rcnt].celllist,6)
    SET reply->rowlist[rcnt].celllist[1].string_value = "BMDI Look Forward Minutes"
    SET reply->rowlist[rcnt].celllist[2].string_value = "5"
    SET acnt = 0
    SET stat = uar_prefgetentryattrcount(hentry,acnt)
    FOR (y = 0 TO (acnt - 1))
      SET hattr = uar_prefgetentryattr(hentry,y)
      SET valcnt = 0
      DECLARE xvalue = c255 WITH noconstant("")
      DECLARE yvalue = c255 WITH noconstant("")
      SET stat = uar_prefgetattrval(hattr,xvalue,255,0)
      SET stat = uar_prefgetattrname(hattr,yvalue,255)
      CALL echo(build("value:",xvalue))
      IF (yvalue="prefvalue")
       SET reply->rowlist[rcnt].celllist[3].string_value = xvalue
      ENDIF
      IF (yvalue="prefcontext")
       SET reply->rowlist[rcnt].celllist[5].string_value = xvalue
       IF (xvalue="user")
        SET user_id = cnvtint(grpstr)
        SELECT INTO "nl:"
         FROM prsnl p
         PLAN (p
          WHERE p.person_id=user_id)
         DETAIL
          reply->rowlist[rcnt].celllist[6].string_value = p.name_full_formatted
         WITH nocounter
        ;end select
       ENDIF
       IF (xvalue="position")
        SET pos_cd = cnvtint(grpstr)
        SELECT INTO "nl:"
         FROM code_value c
         PLAN (c
          WHERE c.code_value=pos_cd)
         DETAIL
          reply->rowlist[rcnt].celllist[6].string_value = c.display
         WITH nocounter
        ;end select
       ENDIF
       IF (xvalue="position location")
        SET a = findstring("^",grpstr)
        SET pos_cd = cnvtint(substring(1,(a - 1),grpstr))
        SET b = textlen(grpstr)
        SET loc_cd = cnvtint(substring((a+ 1),((b - a) - 1),grpstr))
        SELECT INTO "nl:"
         FROM code_value c
         PLAN (c
          WHERE c.code_value=pos_cd)
         DETAIL
          posstr = c.display
         WITH nocounter
        ;end select
        SELECT INTO "nl:"
         FROM code_value c
         PLAN (c
          WHERE c.code_value=loc_cd)
         DETAIL
          locstr = c.display
         WITH nocounter
        ;end select
        SET reply->rowlist[rcnt].celllist[6].string_value = concat(trim(posstr),"/",trim(locstr))
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 CALL uar_prefdestroyinstance(hpref)
 SET hpref = uar_prefcreateinstance(18)
 SET stat = uar_prefsetbasedn(hpref,"prefroot=prefroot")
 SET stat = uar_prefaddattr(hpref,"prefvalue")
 SET stat = uar_prefaddattr(hpref,"prefcontext")
 SET stat = uar_prefaddfilter(hpref,"prefentry=order_integration")
 SET stat = uar_prefperform(hpref)
 DECLARE count = i4
 SET stat = uar_prefgetentrycount(hpref,count)
 SET i = 0
 DECLARE dnstr = c255 WITH noconstant("")
 DECLARE grpstr = c255 WITH noconstant("")
 DECLARE posstr = c40 WITH noconstant("")
 DECLARE locstr = c40 WITH noconstant("")
 SET user_id = 0
 SET pos_cd = 0
 SET loc_cd = 0
 FOR (x = 0 TO (count - 1))
   SET hentry = uar_prefgetentry(hpref,x)
   SET stat = uar_prefgetentryname(hentry,dnstr,255)
   SET i = findstring("prefcontext=reference",dnstr)
   IF (i=0)
    SET a = findstring("prefgroup=",dnstr,1,1)
    SET b = findstring("=",dnstr,a)
    SET c = findstring(",",dnstr,a)
    SET grpstr = substring((b+ 1),((c - b) - 1),dnstr)
    SET rcnt = (rcnt+ 1)
    SET stat = alterlist(reply->rowlist,rcnt)
    SET stat = alterlist(reply->rowlist[rcnt].celllist,6)
    SET reply->rowlist[rcnt].celllist[1].string_value = "Order Integration"
    SET reply->rowlist[rcnt].celllist[2].string_value = "No"
    SET acnt = 0
    SET stat = uar_prefgetentryattrcount(hentry,acnt)
    FOR (y = 0 TO (acnt - 1))
      SET hattr = uar_prefgetentryattr(hentry,y)
      SET valcnt = 0
      DECLARE xvalue = c255 WITH noconstant("")
      DECLARE yvalue = c255 WITH noconstant("")
      SET stat = uar_prefgetattrval(hattr,xvalue,255,0)
      SET stat = uar_prefgetattrname(hattr,yvalue,255)
      CALL echo(build("value:",xvalue))
      IF (yvalue="prefvalue")
       SET reply->rowlist[rcnt].celllist[3].string_value = xvalue
      ENDIF
      IF (yvalue="prefcontext")
       SET reply->rowlist[rcnt].celllist[5].string_value = xvalue
       IF (xvalue="user")
        SET user_id = cnvtint(grpstr)
        SELECT INTO "nl:"
         FROM prsnl p
         PLAN (p
          WHERE p.person_id=user_id)
         DETAIL
          reply->rowlist[rcnt].celllist[6].string_value = p.name_full_formatted
         WITH nocounter
        ;end select
       ENDIF
       IF (xvalue="position")
        SET pos_cd = cnvtint(grpstr)
        SELECT INTO "nl:"
         FROM code_value c
         PLAN (c
          WHERE c.code_value=pos_cd)
         DETAIL
          reply->rowlist[rcnt].celllist[6].string_value = c.display
         WITH nocounter
        ;end select
       ENDIF
       IF (xvalue="position location")
        SET a = findstring("^",grpstr)
        SET pos_cd = cnvtint(substring(1,(a - 1),grpstr))
        SET b = textlen(grpstr)
        SET loc_cd = cnvtint(substring((a+ 1),((b - a) - 1),grpstr))
        SELECT INTO "nl:"
         FROM code_value c
         PLAN (c
          WHERE c.code_value=pos_cd)
         DETAIL
          posstr = c.display
         WITH nocounter
        ;end select
        SELECT INTO "nl:"
         FROM code_value c
         PLAN (c
          WHERE c.code_value=loc_cd)
         DETAIL
          locstr = c.display
         WITH nocounter
        ;end select
        SET reply->rowlist[rcnt].celllist[6].string_value = concat(trim(posstr),"/",trim(locstr))
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 CALL uar_prefdestroyinstance(hpref)
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("iview_pref_settings_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 SET reply->status_data.status = "S"
END GO
