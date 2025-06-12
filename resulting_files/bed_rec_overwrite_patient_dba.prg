CREATE PROGRAM bed_rec_overwrite_patient:dba
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
 RECORD temprec(
   1 tlist[*]
     2 tprole = f8
   1 plist[*]
     2 tg_id = f8
     2 tp_id = f8
 )
 DECLARE prvreln_var = f8 WITH constant(uar_get_code_by("MEANING",16409,"PRVRELN")), protect
 EXECUTE prefrtl
 SET tcnt = 0
 SET cnt = 0
 SET reply->run_status_flag = 1
 SET patient_ok = "Y"
 DECLARE tprole_id = f8 WITH protect, noconstant(0)
 DECLARE tgrp_cd = f8 WITH protect, noconstant(0)
 SET hpref = uar_prefcreateinstance(18)
 SET stat = uar_prefsetbasedn(hpref,"prefcontext=tracking provider role,prefroot=prefroot")
 SET stat = uar_prefaddattr(hpref,"prefvalue")
 SET stat = uar_prefaddfilter(hpref,"prefentry=patient")
 SET stat = uar_prefaddfilter(hpref,"prefgroup=depart tab section")
 SET stat = uar_prefperform(hpref)
 DECLARE count = i4
 SET stat = uar_prefgetentrycount(hpref,count)
 SET i = 0
 DECLARE dnstr = c255 WITH noconstant("")
 SET strlen = 255
 DECLARE entstr = c150
 FOR (x = 0 TO (count - 1))
   SET hentry = uar_prefgetentry(hpref,x)
   SET stat = uar_prefgetentryname(hentry,dnstr,strlen)
   SET a = findstring("prefgroup=",dnstr,1,1)
   SET b = findstring("=",dnstr,a)
   SET c = findstring(",",dnstr,a)
   SET grpstr = substring((b+ 1),((c - b) - 1),dnstr)
   SET d = findstring("prefentry=",dnstr,1)
   IF (d > 0)
    SET e = findstring("=",dnstr,d)
    SET f = findstring(",",dnstr,d)
    SET entstr = substring((e+ 1),((f - e) - 1),dnstr)
   ELSE
    SET entstr = ""
   ENDIF
   SET acnt = 0
   SET stat = uar_prefgetentryattrcount(hentry,acnt)
   SET tprole_id = cnvtreal(grpstr)
   SET tcnt = (tcnt+ 1)
   SET stat = alterlist(temprec->tlist,tcnt)
   SET temprec->tlist[tcnt].tprole = tprole_id
   FOR (y = 0 TO (acnt - 1))
     SET hattr = uar_prefgetentryattr(hentry,y)
     SET valcnt = 0
     SET stat = uar_prefgetattrvalcount(hattr,valcnt)
     DECLARE xvalue = c255 WITH noconstant("")
     DECLARE xvalstr = c255 WITH noconstant("")
     FOR (z = 0 TO (valcnt - 1))
       SET stat = uar_prefgetattrval(hattr,xvalue,255,z)
       SET a = findstring(";",xvalue,1,1)
       SET b = textlen(xvalue)
       SET xvalstr = substring((a+ 1),((b - a) - 1),xvalue)
       IF (cnvtint(trim(xvalstr))=0)
        SET valid_ind = 0
        SELECT INTO "nl:"
         FROM track_reference tr,
          code_value cv
         PLAN (tr
          WHERE tr.tracking_ref_id=tprole_id
           AND tr.tracking_ref_type_cd=prvreln_var)
          JOIN (cv
          WHERE cv.code_value=tr.tracking_group_cd
           AND cv.active_ind=1)
         DETAIL
          valid_ind = 1
         WITH nocounter
        ;end select
        IF (valid_ind=1)
         SET patient_ok = "N"
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
 ENDFOR
 CALL uar_prefdestroyinstance(hpref)
 IF (patient_ok="Y")
  SET hpref = uar_prefcreateinstance(18)
  SET stat = uar_prefsetbasedn(hpref,"prefcontext=tracking group,prefroot=prefroot")
  SET stat = uar_prefaddattr(hpref,"prefvalue")
  SET stat = uar_prefaddfilter(hpref,"prefentry=patient")
  SET stat = uar_prefaddfilter(hpref,"prefgroup=depart tab section")
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
    CALL echo(build("hentry",hentry))
    FOR (y = 0 TO (acnt - 1))
      SET hattr = uar_prefgetentryattr(hentry,y)
      SET valcnt = 0
      SET stat = uar_prefgetattrvalcount(hattr,valcnt)
      DECLARE xvalue = c255 WITH noconstant("")
      DECLARE xvalstr = c255 WITH noconstant("")
      FOR (z = 0 TO (valcnt - 1))
        SET stat = uar_prefgetattrval(hattr,xvalue,255,z)
        SET a = findstring(";",xvalue,1,1)
        SET b = textlen(xvalue)
        SET xvalstr = substring((a+ 1),((b - a) - 1),xvalue)
        CALL echo(build("xvalue",xvalue))
        CALL echo(build("xvalstr",xvalstr))
        IF (cnvtint(trim(xvalstr))=000)
         SET valid_ind = 0
         SET tgrp_cd = cnvtreal(grpstr)
         SELECT INTO "nl:"
          FROM (dummyt d  WITH seq = tcnt),
           track_reference tr,
           dummyt d1
          PLAN (tr)
           JOIN (d1)
           JOIN (d
           WHERE (tr.tracking_ref_id=temprec->tlist[d.seq].tprole))
          ORDER BY tr.tracking_ref_id
          DETAIL
           cnt = (cnt+ 1), stat = alterlist(temprec->plist,cnt), temprec->plist[cnt].tp_id = tr
           .tracking_ref_id,
           CALL echo(build("tracking_ref_id:",tr.tracking_ref_id))
          WITH nocounter, outerjoin = d1, dontexist
         ;end select
         SELECT INTO "nl:"
          FROM (dummyt d  WITH seq = cnt),
           track_reference tr,
           code_value cv
          PLAN (d)
           JOIN (tr
           WHERE (tr.tracking_ref_id=temprec->plist[d.seq].tp_id)
            AND tr.tracking_group_cd=tgrp_cd
            AND tr.tracking_ref_type_cd=prvreln_var)
           JOIN (cv
           WHERE cv.code_value=tgrp_cd
            AND cv.code_set=16370
            AND cv.active_ind=1)
          DETAIL
           valid_ind = 1
          WITH nocounter
         ;end select
         IF (valid_ind=1)
          SET patient_ok = "N"
         ENDIF
        ENDIF
      ENDFOR
    ENDFOR
  ENDFOR
 ENDIF
#exit_script
 IF (patient_ok="N")
  SET reply->run_status_flag = 3
 ENDIF
 SET reply->status_data.status = "S"
END GO
