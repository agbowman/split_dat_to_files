CREATE PROGRAM bed_rec_ds_adhoc_meds:dba
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
 FREE SET pos
 RECORD pos(
   1 qual[*]
     2 pos_code = f8
     2 valid = i2
 )
 FREE SET pos2
 RECORD pos2(
   1 qual[*]
     2 pos_code = f8
 )
 SET reply->run_status_flag = 1
 SET allow_adhoc_orders = 0
 SET cap_value = 0
 SET hpref = uar_prefcreateinstance(18)
 SET stat = uar_prefsetbasedn(hpref,"prefcontext=default,prefroot=prefroot")
 SET stat = uar_prefaddattr(hpref,"prefvalue")
 SET stat = uar_prefaddfilter(hpref,"prefentry=allow_adhoc_orders")
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
       SET cap_value = cnvtint(trim(xvalue))
       IF (cap_value=1)
        SET allow_adhoc_orders = 1
       ENDIF
     ENDFOR
   ENDFOR
 ENDFOR
 CALL uar_prefdestroyinstance(hpref)
 IF (allow_adhoc_orders=1)
  SET cap_value = 0
  SET hpref = uar_prefcreateinstance(18)
  SET stat = uar_prefsetbasedn(hpref,"prefcontext=default,prefroot=prefroot")
  SET stat = uar_prefaddattr(hpref,"prefvalue")
  SET stat = uar_prefaddfilter(hpref,"prefentry=adhoc_order_check_allergy")
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
        SET cap_value = cnvtint(trim(xvalue))
        IF (cap_value != 1)
         SET reply->run_status_flag = 3
        ENDIF
      ENDFOR
    ENDFOR
  ENDFOR
  CALL uar_prefdestroyinstance(hpref)
 ENDIF
 IF ((reply->run_status_flag=1))
  SET cap_value = 0
  SET hpref = uar_prefcreateinstance(18)
  SET stat = uar_prefsetbasedn(hpref,"prefcontext=position,prefroot=prefroot")
  SET stat = uar_prefaddattr(hpref,"prefvalue")
  SET stat = uar_prefaddfilter(hpref,"prefentry=allow_adhoc_orders")
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
        SET cap_value = cnvtint(trim(xvalue))
        IF (cap_value=1)
         SET qcnt = (size(pos->qual,5)+ 1)
         SET stat = alterlist(pos->qual,qcnt)
         SET pos->qual[qcnt].pos_code = cnvtint(trim(grpstr))
        ENDIF
      ENDFOR
    ENDFOR
  ENDFOR
  CALL uar_prefdestroyinstance(hpref)
  SET pcnt = size(pos->qual,5)
  IF (pcnt > 0)
   SET tot_valid = 0
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(pcnt)),
     code_value c,
     prsnl p
    PLAN (d)
     JOIN (c
     WHERE (c.code_value=pos->qual[d.seq].pos_code)
      AND c.active_ind=1)
     JOIN (p
     WHERE p.position_cd=c.code_value
      AND p.active_ind=1)
    ORDER BY d.seq
    HEAD d.seq
     pos->qual[d.seq].valid = 1, tot_valid = 1
    WITH nocounter
   ;end select
   IF (tot_valid=0)
    GO TO exit_script
   ENDIF
   SET cap_value = 0
   SET hpref = uar_prefcreateinstance(18)
   SET stat = uar_prefsetbasedn(hpref,"prefcontext=position,prefroot=prefroot")
   SET stat = uar_prefaddattr(hpref,"prefvalue")
   SET stat = uar_prefaddfilter(hpref,"prefentry=adhoc_order_check_allergy")
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
         SET cap_value = cnvtint(trim(xvalue))
         IF (cap_value=1)
          SET qcnt = (size(pos2->qual,5)+ 1)
          SET stat = alterlist(pos2->qual,qcnt)
          SET pos2->qual[qcnt].pos_code = cnvtint(trim(grpstr))
         ENDIF
       ENDFOR
     ENDFOR
   ENDFOR
   CALL uar_prefdestroyinstance(hpref)
   SET pcnt2 = size(pos2->qual,5)
   IF (pcnt2 > 0)
    FOR (p = 1 TO pcnt)
      IF ((pos->qual[p].valid=1))
       SET num = 0
       SET tindex = 0
       SET tindex = locateval(num,1,pcnt2,pos->qual[p].pos_code,pos2->qual[num].pos_code)
       IF (tindex=0)
        SET reply->run_status_flag = 3
        SET p = (pcnt+ 1)
       ENDIF
      ENDIF
    ENDFOR
   ELSE
    SET reply->run_status_flag = 3
   ENDIF
  ENDIF
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
