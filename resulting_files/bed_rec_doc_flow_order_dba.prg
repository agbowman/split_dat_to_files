CREATE PROGRAM bed_rec_doc_flow_order:dba
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
 SET reply->run_status_flag = 1
 EXECUTE prefrtl
 SET order_ok = "Y"
 SET chron = 0
 SET rechron = 0
 DECLARE pos_cd = f8 WITH protect, noconstant(0)
 DECLARE loc_cd = f8 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM name_value_prefs n,
   detail_prefs d,
   application a
  PLAN (n
   WHERE n.pvc_name IN ("R_TIME_SORT", "MAR_TIME_SORT", "C_TIME_SORT", "LV_TIME_SORT")
    AND n.parent_entity_name="DETAIL_PREFS"
    AND n.active_ind=1)
   JOIN (d
   WHERE d.detail_prefs_id=n.parent_entity_id
    AND d.position_cd=0
    AND d.prsnl_id=0
    AND d.active_ind=1)
   JOIN (a
   WHERE a.application_number=d.application_number)
  DETAIL
   IF (n.pvc_value="1")
    rechron = (rechron+ 1)
   ELSE
    chron = (chron+ 1)
   ENDIF
  WITH nocounter
 ;end select
 IF (chron > 0
  AND rechron > 0)
  SET order_ok = "N"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM name_value_prefs n,
   app_prefs ap,
   application a
  PLAN (n
   WHERE n.pvc_name IN ("R_TIME_SORT", "MAR_TIME_SORT", "C_TIME_SORT", "LV_TIME_SORT")
    AND n.parent_entity_name="APP_PREFS"
    AND n.active_ind=1)
   JOIN (ap
   WHERE ap.app_prefs_id=n.parent_entity_id
    AND ap.position_cd=0
    AND ap.prsnl_id=0
    AND ap.active_ind=1)
   JOIN (a
   WHERE a.application_number=ap.application_number)
  DETAIL
   IF (n.pvc_value="1")
    rechron = (rechron+ 1)
   ELSE
    chron = (chron+ 1)
   ENDIF
  WITH nocounter
 ;end select
 IF (chron > 0
  AND rechron > 0)
  SET order_ok = "N"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM name_value_prefs n,
   detail_prefs d,
   application a,
   code_value cv,
   prsnl p
  PLAN (n
   WHERE n.pvc_name IN ("R_TIME_SORT", "MAR_TIME_SORT", "C_TIME_SORT", "LV_TIME_SORT")
    AND n.parent_entity_name="DETAIL_PREFS"
    AND n.active_ind=1)
   JOIN (d
   WHERE d.detail_prefs_id=n.parent_entity_id
    AND d.position_cd > 0
    AND d.active_ind=1)
   JOIN (a
   WHERE a.application_number=d.application_number)
   JOIN (cv
   WHERE cv.code_value=d.position_cd
    AND cv.active_ind=1)
   JOIN (p
   WHERE p.position_cd=d.position_cd
    AND p.active_ind=1)
  DETAIL
   IF (n.pvc_value="1")
    rechron = (rechron+ 1)
   ELSE
    chron = (chron+ 1)
   ENDIF
  WITH nocounter
 ;end select
 IF (chron > 0
  AND rechron > 0)
  SET order_ok = "N"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM name_value_prefs n,
   app_prefs ap,
   application a,
   code_value cv,
   prsnl p
  PLAN (n
   WHERE n.pvc_name IN ("R_TIME_SORT", "MAR_TIME_SORT", "C_TIME_SORT", "LV_TIME_SORT")
    AND n.parent_entity_name="APP_PREFS"
    AND n.active_ind=1)
   JOIN (ap
   WHERE ap.app_prefs_id=n.parent_entity_id
    AND ap.position_cd > 0
    AND ap.active_ind=1)
   JOIN (a
   WHERE a.application_number=ap.application_number)
   JOIN (cv
   WHERE cv.code_value=ap.position_cd
    AND cv.active_ind=1)
   JOIN (p
   WHERE p.position_cd=ap.position_cd
    AND p.active_ind=1)
  DETAIL
   IF (n.pvc_value="1")
    rechron = (rechron+ 1)
   ELSE
    chron = (chron+ 1)
   ENDIF
  WITH nocounter
 ;end select
 IF (chron > 0
  AND rechron > 0)
  SET order_ok = "N"
  GO TO exit_script
 ENDIF
 SET order_ind = " "
 IF (chron > 0)
  SET order_ind = "C"
 ELSEIF (rechron > 0)
  SET order_ind = "R"
 ENDIF
 SET hpref = uar_prefcreateinstance(18)
 SET stat = uar_prefsetbasedn(hpref,"prefcontext=default,prefroot=prefroot")
 SET stat = uar_prefaddattr(hpref,"prefvalue")
 SET stat = uar_prefaddfilter(hpref,"prefentry=chrono_time_sort")
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
      IF (order_ind=" ")
       IF (cnvtint(trim(xvalue))=1)
        SET order_ind = "C"
       ELSE
        SET order_ind = "R"
       ENDIF
      ELSE
       IF (((cnvtint(trim(xvalue))=1
        AND order_ind="R") OR (cnvtint(trim(xvalue))=0
        AND order_ind="C")) )
        CALL uar_prefdestroyinstance(hpref)
        SET order_ok = "N"
        GO TO exit_script
       ENDIF
      ENDIF
     ENDFOR
   ENDFOR
 ENDFOR
 CALL uar_prefdestroyinstance(hpref)
 SET hpref = uar_prefcreateinstance(18)
 SET stat = uar_prefsetbasedn(hpref,"prefcontext=position,prefroot=prefroot")
 SET stat = uar_prefaddattr(hpref,"prefvalue")
 SET stat = uar_prefaddfilter(hpref,"prefentry=chrono_time_sort")
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
      IF (((order_ind=" ") OR (((cnvtint(trim(xvalue))=1
       AND order_ind="R") OR (cnvtint(trim(xvalue))=0
       AND order_ind="C")) )) )
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
        IF (order_ind=" ")
         IF (cnvtint(trim(xvalue))=1)
          SET order_ind = "C"
         ELSE
          SET order_ind = "R"
         ENDIF
        ELSE
         IF (((cnvtint(trim(xvalue))=1
          AND order_ind="R") OR (cnvtint(trim(xvalue))=0
          AND order_ind="C")) )
          CALL uar_prefdestroyinstance(hpref)
          SET order_ok = "N"
          GO TO exit_script
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDFOR
   ENDFOR
 ENDFOR
 CALL uar_prefdestroyinstance(hpref)
 SET hpref = uar_prefcreateinstance(18)
 SET stat = uar_prefsetbasedn(hpref,"prefcontext=position location,prefroot=prefroot")
 SET stat = uar_prefaddattr(hpref,"prefvalue")
 SET stat = uar_prefaddfilter(hpref,"prefentry=chrono_time_sort")
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
      IF (((order_ind=" ") OR (((cnvtint(trim(xvalue))=1
       AND order_ind="R") OR (cnvtint(trim(xvalue))=0
       AND order_ind="C")) )) )
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
       ENDIF
       IF (valid_ind=1)
        IF (order_ind=" ")
         IF (cnvtint(trim(xvalue))=1)
          SET order_ind = "C"
         ELSE
          SET order_ind = "R"
         ENDIF
        ELSE
         IF (((cnvtint(trim(xvalue))=1
          AND order_ind="R") OR (cnvtint(trim(xvalue))=0
          AND order_ind="C")) )
          CALL uar_prefdestroyinstance(hpref)
          SET order_ok = "N"
          GO TO exit_script
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDFOR
   ENDFOR
 ENDFOR
 CALL uar_prefdestroyinstance(hpref)
#exit_script
 IF (order_ok="N")
  SET reply->run_status_flag = 3
 ENDIF
 SET reply->status_data.status = "S"
END GO
