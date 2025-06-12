CREATE PROGRAM bed_rec_autosave_pat_inst_emr:dba
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
 DECLARE tgrp_cd = f8 WITH protect, noconstant(0)
 DECLARE yes = f8 WITH constant(uar_get_code_by("MEANING",20317,"YES")), protect
 EXECUTE prefrtl
 SET tcnt = 0
 SET cnt = 0
 SET reply->run_status_flag = 1
 SET hpref = uar_prefcreateinstance(18)
 SET stat = uar_prefsetbasedn(hpref,"prefcontext=tracking group,prefroot=prefroot")
 CALL echo(build("hpref:",hpref))
 SET stat = uar_prefaddattr(hpref,"prefvalue")
 SET stat = uar_prefaddfilter(hpref,"prefentry=save on print")
 SET stat = uar_prefaddfilter(hpref,"prefgroup=patienteducation")
 SET stat = uar_prefperform(hpref)
 DECLARE count = i4
 SET stat = uar_prefgetentrycount(hpref,count)
 SET i = 0
 DECLARE dnstr = c255 WITH noconstant("")
 DECLARE grpstr = c255 WITH noconstant("")
 SET strlen = 255
 CALL echo(build("count:",count))
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
       SET valid_ind = 0
       SET tgrp_cd = cnvtreal(grpstr)
       IF (cnvtint(trim(xvalue)) != yes)
        SELECT INTO "nl:"
         FROM code_value cv
         PLAN (cv
          WHERE cv.code_value=tgrp_cd
           AND cv.code_set=16370
           AND cv.active_ind=1)
         DETAIL
          reply->run_status_flag = 3
         WITH nocounter
        ;end select
       ENDIF
     ENDFOR
   ENDFOR
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
