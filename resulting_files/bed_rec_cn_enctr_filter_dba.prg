CREATE PROGRAM bed_rec_cn_enctr_filter:dba
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
 DECLARE hpref = i4 WITH noconstant(0)
 SET hpref = uar_prefcreateinstance(18)
 SET stat = uar_prefsetbasedn(hpref,"prefroot=prefroot")
 SET stat = uar_prefaddattr(hpref,"prefvalue")
 SET stat = uar_prefaddfilter(hpref,"prefentry=encntr_filter")
 SET stat = uar_prefaddfilter(hpref,"prefgroup=intake and output")
 SET stat = uar_prefperform(hpref)
 DECLARE count = i4
 SET stat = uar_prefgetentrycount(hpref,count)
 SET i = 0
 DECLARE dnstr = c255 WITH noconstant("")
 DECLARE grpstr = c255 WITH noconstant("")
 DECLARE cxtstr = c255 WITH noconstant("")
 DECLARE viewstr = c255 WITH noconstant("")
 DECLARE posstr = c40 WITH noconstant("")
 DECLARE locstr = c40 WITH noconstant("")
 SET user_id = 0
 SET pos_cd = 0
 SET loc_cd = 0
 FOR (x = 0 TO (count - 1))
   SET hentry = uar_prefgetentry(hpref,x)
   SET stat = uar_prefgetentryname(hentry,dnstr,255)
   SET j = 0
   SET i = 0
   SET l = 0
   SET i = findstring("prefcontext=reference",dnstr)
   SET j = findstring("prefcontext=user",dnstr)
   SET l = findstring("prefcontext=app",dnstr)
   IF (i=0
    AND j=0
    AND l=0)
    SET a = findstring("prefgroup=",dnstr,1,1)
    SET b = findstring("=",dnstr,a)
    SET c = findstring(",",dnstr,a)
    SET grpstr = substring((b+ 1),((c - b) - 1),dnstr)
    SET a = findstring("prefcontext=",dnstr,1)
    SET b = findstring("=",dnstr,a)
    SET c = findstring(",",dnstr,(b+ 1))
    SET cxtstr = substring((b+ 1),((c - b) - 1),dnstr)
    SET a = findstring("prefgroup=",dnstr,1)
    SET b = findstring("=",dnstr,a)
    SET c = findstring(",",dnstr,a)
    SET viewstr = substring((b+ 1),((c - b) - 1),dnstr)
    SET acnt = 0
    SET stat = uar_prefgetentryattrcount(hentry,acnt)
    FOR (y = 0 TO (acnt - 1))
      SET hattr = uar_prefgetentryattr(hentry,y)
      SET valcnt = 0
      SET stat = uar_prefgetattrvalcount(hattr,valcnt)
      FOR (z = 0 TO (valcnt - 1))
        DECLARE xvalue = c255 WITH noconstant("")
        SET stat = uar_prefgetattrval(hattr,xvalue,255,z)
        IF (xvalue="0*")
         SET reply->run_status_flag = 3
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
 ENDFOR
 CALL uar_prefdestroyinstance(hpref)
#exit_script
 SET reply->status_data.status = "S"
END GO
