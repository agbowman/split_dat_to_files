CREATE PROGRAM cpm_get_rtms_config:dba
 RECORD reply(
   1 configstrings[*]
     2 configpath = vc
     2 configvalue = vc
     2 configvalues[*]
       3 value = vc
   1 configdoubles[*]
     2 configpath = vc
     2 configvalue = f8
 )
 DECLARE stringcount = i4 WITH noconstant(0)
 DECLARE doublecount = i4 WITH noconstant(0)
 DECLARE definitioncount = i4 WITH noconstant(0)
 DECLARE timerpath = vc
 IF (validate(timerepository_def,999)=999)
  CALL echo("Declaring timerepository_def")
  DECLARE timerepository_def = i2 WITH persist
  SET timerepository_def = 1
  IF (((((currev * 10000)+ (currevminor * 100))+ currevminor2) >= 81203))
   DECLARE uar_timer_getconfigdouble(p1=vc(ref),p2=f8(ref),p3=h(value)) = i4 WITH image_axp =
   "timerepository", image_aix = "libtimerepository.a(libtimerepository.o)", uar =
   "TIMER_GetConfigDouble",
   persist
   DECLARE uar_timer_getconfigstring(p1=vc(ref),p2=vc(ref),p3=h(value),p4=h(value)) = i4 WITH
   image_axp = "timerepository", image_aix = "libtimerepository.a(libtimerepository.o)", uar =
   "TIMER_GetConfigString",
   persist
  ELSE
   IF (((((currev * 10000)+ (currevminor * 100))+ currevminor2) >= 80900))
    DECLARE uar_timer_getconfigdouble(p1=vc(ref),p2=f8(ref),p3=w8(value)) = i4 WITH image_axp =
    "timerepository", image_aix = "libtimerepository.a(libtimerepository.o)", uar =
    "TIMER_GetConfigDouble",
    persis
    DECLARE uar_timer_getconfigstring(p1=vc(ref),p2=vc(ref),p3=w8(value),p4=w8(value)) = i4 WITH
    image_axp = "timerepository", image_aix = "libtimerepository.a(libtimerepository.o)", uar =
    "TIMER_GetConfigString",
    persis
   ELSE
    DECLARE uar_timer_getconfigdouble(p1=vc(ref),p2=f8(ref),p3=i4(value)) = i4 WITH image_axp =
    "timerepository", image_aix = "libtimerepository.a(libtimerepository.o)", uar =
    "TIMER_GetConfigDouble",
    persis
    DECLARE uar_timer_getconfigstring(p1=vc(ref),p2=vc(ref),p3=i4(value),p4=i4(value)) = i4 WITH
    image_axp = "timerepository", image_aix = "libtimerepository.a(libtimerepository.o)", uar =
    "TIMER_GetConfigString",
    persis
   ENDIF
  ENDIF
 ENDIF
 SUBROUTINE loadtimer(name)
   SET timerpath = build("timers/",trim(name))
   DECLARE functionpath = vc
   SET functionpath = build(timerpath,"/functions")
   DECLARE functionname = c256
   DECLARE functioncount = w8 WITH noconstant(0)
   DECLARE functionnodepolicypath = vc
   DECLARE functionnodepolicy = c256
   DECLARE functionnodepath = vc
   DECLARE functionnode = c256
   DECLARE functionnodecount = w8 WITH noconstant(0)
   WHILE (uar_timer_getconfigstring(nullterm(functionpath),functionname,255,functioncount)=1)
     SET stringcount = (stringcount+ 1)
     SET stat = alterlist(reply->configstrings,stringcount)
     SET reply->configstrings[stringcount].configpath = functionpath
     SET reply->configstrings[stringcount].configvalue = trim(functionname)
     SET functionnodepolicypath = build(timerpath,"/",trim(functionname),"/nodepolicy")
     IF (uar_timer_getconfigstring(nullterm(functionnodepolicypath),functionnodepolicy,255,0)=1)
      SET stringcount = (stringcount+ 1)
      SET stat = alterlist(reply->configstrings,stringcount)
      SET reply->configstrings[stringcount].configpath = functionnodepolicypath
      SET reply->configstrings[stringcount].configvalue = trim(functionnodepolicy)
     ENDIF
     SET functionnodepath = build(timerpath,"/",trim(functionname),"/nodes")
     SET functionnodecount = 0
     WHILE (uar_timer_getconfigstring(nullterm(functionnodepath),functionnode,255,functionnodecount)=
     1)
       SET stringcount = (stringcount+ 1)
       SET stat = alterlist(reply->configstrings,stringcount)
       SET reply->configstrings[stringcount].configpath = functionnodepath
       SET reply->configstrings[stringcount].configvalue = trim(functionnode)
       SET functionnodecount = (functionnodecount+ 1)
     ENDWHILE
     SET functioncount = (functioncount+ 1)
   ENDWHILE
   DECLARE repositorypath = vc
   SET repositorypath = build(timerpath,"/activerepositories")
   DECLARE repositoryname = c256
   DECLARE repositorycount = w8 WITH noconstant(0)
   DECLARE datatypepath = vc
   DECLARE datatype = f8 WITH noconstant(0.0)
   DECLARE destinationtypepath = vc
   DECLARE destinationtype = f8 WITH noconstant(0.0)
   DECLARE intervalpath = vc
   DECLARE interval = f8 WITH noconstant(0.0)
   DECLARE bucketpath = vc
   DECLARE bucketvalue = f8 WITH noconstant(0.0)
   DECLARE bucketcount = i4 WITH noconstant(0)
   WHILE (uar_timer_getconfigstring(nullterm(repositorypath),repositoryname,255,repositorycount)=1)
     SET stringcount = (stringcount+ 1)
     SET stat = alterlist(reply->configstrings,stringcount)
     SET reply->configstrings[stringcount].configpath = repositorypath
     SET reply->configstrings[stringcount].configvalue = trim(repositoryname)
     SET datatypepath = build(timerpath,"/",trim(repositoryname),"/datatype")
     IF (uar_timer_getconfigdouble(nullterm(datatypepath),datatype,0)=1)
      SET doublecount = (doublecount+ 1)
      SET stat = alterlist(reply->configdoubles,doublecount)
      SET reply->configdoubles[doublecount].configpath = datatypepath
      SET reply->configdoubles[doublecount].configvalue = datatype
     ENDIF
     SET destinationtypepath = build(timerpath,"/",trim(repositoryname),"/destinationtype")
     IF (uar_timer_getconfigdouble(nullterm(destinationtypepath),destinationtype,0)=1)
      SET doublecount = (doublecount+ 1)
      SET stat = alterlist(reply->configdoubles,doublecount)
      SET reply->configdoubles[doublecount].configpath = destinationtypepath
      SET reply->configdoubles[doublecount].configvalue = destinationtype
     ENDIF
     SET intervalpath = build(timerpath,"/",trim(repositoryname),"/interval")
     IF (uar_timer_getconfigdouble(nullterm(intervalpath),interval,0)=1)
      SET doublecount = (doublecount+ 1)
      SET stat = alterlist(reply->configdoubles,doublecount)
      SET reply->configdoubles[doublecount].configpath = intervalpath
      SET reply->configdoubles[doublecount].configvalue = interval
     ENDIF
     SET bucketpath = build(timerpath,"/",trim(repositoryname),"/additionalbuckets")
     SET bucketcount = 0
     WHILE (uar_timer_getconfigdouble(nullterm(bucketpath),bucketvalue,bucketcount)=1)
       SET doublecount = (doublecount+ 1)
       SET stat = alterlist(reply->configdoubles,doublecount)
       SET reply->configdoubles[doublecount].configpath = bucketpath
       SET reply->configdoubles[doublecount].configvalue = bucketvalue
       SET bucketcount = (bucketcount+ 1)
     ENDWHILE
     SET repositorycount = (repositorycount+ 1)
   ENDWHILE
   DECLARE nodepolicypath = vc
   SET nodepolicypath = build(timerpath,"/nodepolicy")
   DECLARE nodepolicy = c256
   IF (uar_timer_getconfigstring(nullterm(nodepolicypath),nodepolicy,255,0)=1)
    SET stringcount = (stringcount+ 1)
    SET stat = alterlist(reply->configstrings,stringcount)
    SET reply->configstrings[stringcount].configpath = nodepolicypath
    SET reply->configstrings[stringcount].configvalue = nodepolicy
   ENDIF
   DECLARE nodespath = vc
   SET nodespath = build(timerpath,"/nodes")
   DECLARE node = c256
   DECLARE nodecount = w8 WITH noconstant(0)
   WHILE (uar_timer_getconfigstring(nullterm(nodespath),node,255,nodecount)=1)
     SET stringcount = (stringcount+ 1)
     SET stat = alterlist(reply->configstrings,stringcount)
     SET reply->configstrings[stringcount].configpath = nodespath
     SET reply->configstrings[stringcount].configvalue = node
     SET nodecount = (nodecount+ 1)
   ENDWHILE
   DECLARE deffilespath = vc
   SET deffilespath = build(timerpath,"/definitionfiles")
   DECLARE contents = c524288
   DECLARE trimcontents = vc
   DECLARE filecount = w8 WITH noconstant(0)
   DECLARE chunkcount = i4
   DECLARE contentslength = i4
   DECLARE position = i4
   WHILE (uar_timer_getconfigstring(nullterm(deffilespath),contents,524287,filecount)=1)
     SET stringcount = (stringcount+ 1)
     SET stat = alterlist(reply->configstrings,stringcount)
     SET reply->configstrings[stringcount].configpath = deffilespath
     SET trimcontents = trim(contents)
     SET contentslength = size(trimcontents,1)
     IF (contentslength > 65535)
      SET chunkcount = (1+ ((contentslength - 1)/ 65535))
      SET stat = alterlist(reply->configstrings[stringcount].configvalues,chunkcount)
      SET position = 1
      SET chunknumber = 0
      WHILE (chunknumber < chunkcount)
        SET chunknumber = (chunknumber+ 1)
        SET reply->configstrings[stringcount].configvalues[chunknumber].value = notrim(substring(
          position,minval(65535,((contentslength - position)+ 1)),trimcontents))
        SET position = (position+ 65535)
      ENDWHILE
     ELSE
      SET reply->configstrings[stringcount].configvalue = trimcontents
     ENDIF
     SET filecount = (filecount+ 1)
   ENDWHILE
   DECLARE flushintervalpath = vc
   SET flushintervalpath = build(timerpath,"/flushinterval")
   DECLARE flushinterval = f8
   IF (uar_timer_getconfigdouble(nullterm(flushintervalpath),flushinterval,0)=1)
    SET doublecount = (doublecount+ 1)
    SET stat = alterlist(reply->configdoubles,doublecount)
    SET reply->configdoubles[doublecount].configpath = flushintervalpath
    SET reply->configdoubles[doublecount].configvalue = flushinterval
   ENDIF
 END ;Subroutine
 DECLARE timername = c256
 DECLARE timercount = w8 WITH noconstant(0)
 WHILE (uar_timer_getconfigstring(nullterm("timers/activetimers"),timername,255,timercount)=1)
   SET stringcount = (stringcount+ 1)
   SET stat = alterlist(reply->configstrings,stringcount)
   SET reply->configstrings[stringcount].configpath = "timers/activetimers"
   SET reply->configstrings[stringcount].configvalue = trim(timername)
   CALL loadtimer(trim(timername))
   SET timercount = (timercount+ 1)
 ENDWHILE
 CALL echorecord(reply)
END GO
