CREATE PROGRAM bed_rec_iview_back_min:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 run_status_flag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 EXECUTE prefrtl
 SET reply->run_status_flag = 1
 SET bmdi_lookback_ok = "Y"
 SET lb_value = 0
 DECLARE pos_cd = f8 WITH protect, noconstant(0)
 DECLARE loc_cd = f8 WITH protect, noconstant(0)
 SET hpref = uar_prefcreateinstance(18)
 SET stat = uar_prefsetbasedn(hpref,"prefcontext=default,prefroot=prefroot")
 SET stat = uar_prefaddattr(hpref,"prefvalue")
 SET stat = uar_prefaddfilter(hpref,"prefentry=bmdi_look_back_min")
 SET stat = uar_prefperform(hpref)
 DECLARE count = i4
 SET stat = uar_prefgetentrycount(hpref,count)
 SET i = 0
 DECLARE dnstr = c255 WITH noconstant("")
 SET strlen = 255
 FOR (x = 0 TO (count - 1))
   SET hentry = uar_prefgetentry(hpref,x)
   SET stat = uar_prefgetentryname(hentry,dnstr,strlen)
   SET acnt = 0
   SET stat = uar_prefgetentryattrcount(hentry,acnt)
   FOR (y = 0 TO (acnt - 1))
     SET hattr = uar_prefgetentryattr(hentry,y)
     SET valcnt = 0
     SET stat = uar_prefgetattrvalcount(hattr,valcnt)
     DECLARE xvalue = c255 WITH noconstant("")
     FOR (z = 0 TO (valcnt - 1))
       SET stat = uar_prefgetattrval(hattr,xvalue,255,z)
       SET lb_value = cnvtint(trim(xvalue))
       IF (((lb_value < 15) OR (lb_value > 60)) )
        SET bmdi_lookback_ok = "N"
       ENDIF
     ENDFOR
   ENDFOR
 ENDFOR
 CALL uar_prefdestroyinstance(hpref)
 IF (bmdi_lookback_ok="Y")
  SET hpref = uar_prefcreateinstance(18)
  SET stat = uar_prefsetbasedn(hpref,"prefcontext=position,prefroot=prefroot")
  SET stat = uar_prefaddattr(hpref,"prefvalue")
  SET stat = uar_prefaddfilter(hpref,"prefentry=bmdi_look_back_min")
  SET stat = uar_prefperform(hpref)
  DECLARE count = i4
  SET stat = uar_prefgetentrycount(hpref,count)
  SET i = 0
  DECLARE dnstr = c255 WITH noconstant("")
  DECLARE grpstr = c255 WITH noconstant("")
  SET strlen = 255
  FOR (x = 0 TO (count - 1))
    SET hentry = uar_prefgetentry(hpref,x)
    SET stat = uar_prefgetentryname(hentry,dnstr,strlen)
    SET a = findstring("prefgroup=",dnstr,1,1)
    SET b = findstring("=",dnstr,a)
    SET c = findstring(",",dnstr,a)
    SET grpstr = substring((b+ 1),((c - b) - 1),dnstr)
    SET acnt = 0
    SET stat = uar_prefgetentryattrcount(hentry,acnt)
    FOR (y = 0 TO (acnt - 1))
      SET hattr = uar_prefgetentryattr(hentry,y)
      SET valcnt = 0
      SET stat = uar_prefgetattrvalcount(hattr,valcnt)
      DECLARE xvalue = c255 WITH noconstant("")
      FOR (z = 0 TO (valcnt - 1))
        SET stat = uar_prefgetattrval(hattr,xvalue,255,z)
        SET lb_value = cnvtint(trim(xvalue))
        IF (((lb_value < 15) OR (lb_value > 60)) )
         SET valid_ind = 0
         SET pos_cd = cnvtreal(grpstr)
         SELECT INTO "nl:"
          FROM code_value cv,
           prsnl p
          PLAN (cv
           WHERE cv.code_value=pos_cd
            AND cv.active_ind=1)
           JOIN (p
           WHERE p.position_cd=cv.code_value
            AND p.active_ind=1)
          DETAIL
           valid_ind = 1
          WITH nocounter
         ;end select
         IF (valid_ind=1)
          SET bmdi_lookback_ok = "N"
         ENDIF
        ENDIF
      ENDFOR
    ENDFOR
  ENDFOR
  CALL uar_prefdestroyinstance(hpref)
  IF (bmdi_lookback_ok="Y")
   SET hpref = uar_prefcreateinstance(18)
   SET stat = uar_prefsetbasedn(hpref,"prefcontext=position location,prefroot=prefroot")
   SET stat = uar_prefaddattr(hpref,"prefvalue")
   SET stat = uar_prefaddfilter(hpref,"prefentry=bmdi_look_back_min")
   SET stat = uar_prefperform(hpref)
   DECLARE count = i4
   SET stat = uar_prefgetentrycount(hpref,count)
   SET i = 0
   DECLARE dnstr = c255 WITH noconstant("")
   DECLARE grpstr = c255 WITH noconstant("")
   SET strlen = 255
   FOR (x = 0 TO (count - 1))
     SET hentry = uar_prefgetentry(hpref,x)
     SET stat = uar_prefgetentryname(hentry,dnstr,strlen)
     SET a = findstring("prefgroup=",dnstr,1,1)
     SET b = findstring("=",dnstr,a)
     SET c = findstring(",",dnstr,a)
     SET grpstr = substring((b+ 1),((c - b) - 1),dnstr)
     SET acnt = 0
     SET stat = uar_prefgetentryattrcount(hentry,acnt)
     FOR (y = 0 TO (acnt - 1))
       SET hattr = uar_prefgetentryattr(hentry,y)
       SET valcnt = 0
       SET stat = uar_prefgetattrvalcount(hattr,valcnt)
       DECLARE xvalue = c255 WITH noconstant("")
       FOR (z = 0 TO (valcnt - 1))
         SET stat = uar_prefgetattrval(hattr,xvalue,255,z)
         SET lb_value = cnvtint(trim(xvalue))
         IF (((lb_value < 15) OR (lb_value > 60)) )
          SET valid_ind = 0
          SET a = findstring("^",grpstr)
          SET pos_cd = cnvtreal(substring(1,(a - 1),grpstr))
          SET b = textlen(grpstr)
          SET loc_cd = cnvtreal(substring((a+ 1),((b - a) - 1),grpstr))
          SELECT INTO "nl:"
           FROM code_value cv,
            prsnl p
           PLAN (cv
            WHERE cv.code_value=pos_cd
             AND cv.active_ind=1)
            JOIN (p
            WHERE p.position_cd=cv.code_value
             AND p.active_ind=1)
           DETAIL
            valid_ind = 1
           WITH nocounter
          ;end select
          IF (valid_ind=1)
           SET valid_ind = 0
           SELECT INTO "nl:"
            FROM code_value cv
            PLAN (cv
             WHERE cv.code_value=loc_cd)
            DETAIL
             valid_ind = 1
            WITH nocounter
           ;end select
           IF (valid_ind=1)
            SET bmdi_lookback_ok = "N"
           ENDIF
          ENDIF
         ENDIF
       ENDFOR
     ENDFOR
   ENDFOR
   CALL uar_prefdestroyinstance(hpref)
  ENDIF
 ENDIF
#exit_script
 IF (bmdi_lookback_ok="N")
  SET reply->run_status_flag = 3
 ENDIF
 SET reply->status_data.status = "S"
END GO
