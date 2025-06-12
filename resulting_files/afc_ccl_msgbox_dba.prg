CREATE PROGRAM afc_ccl_msgbox:dba
 PAINT
 RECORD msg(
   1 line[*]
     2 msg = c37
 )
 SET smsg =  $1
 SET stitle =  $2
 SET stype =  $3
 SET done = 0
 SET istartchar = 1
 SET ilinecnt = 0
 SET schar = fillstring(1," ")
 SET imaxwidth = 37
 SET imsgwidth = imaxwidth
 SET imsgsize = size(smsg)
 SET iboxrowstart = 0
 SET iboxcolstart = 0
 SET iboxrowend = 0
 SET iboxcolend = 0
 WHILE (done=0)
   SET imsgwidth = imaxwidth
   SET schar = substring((istartchar+ imsgwidth),1,smsg)
   IF (schar != " ")
    WHILE (schar != " ")
     SET imsgwidth = (imsgwidth - 1)
     SET schar = substring((istartchar+ imsgwidth),1,smsg)
    ENDWHILE
   ENDIF
   SET ilinecnt = (ilinecnt+ 1)
   SET stat = alterlist(msg->line,ilinecnt)
   SET msg->line[ilinecnt].msg = substring(istartchar,imsgwidth,smsg)
   SET istartchar = ((istartchar+ imsgwidth)+ 1)
   IF (istartchar > imsgsize)
    SET done = 1
   ENDIF
 ENDWHILE
 SET iboxrowstart = ((24/ 2) - ((ilinecnt+ 3)/ 2))
 SET iboxrowend = ((iboxrowstart+ ilinecnt)+ 3)
 FOR (x = iboxrowstart TO iboxrowend)
   CALL clear(x,20,41)
 ENDFOR
 CALL box(iboxrowstart,20,iboxrowend,60)
 IF (size(stitle) > 0)
  CALL video(r)
  CALL text(iboxrowstart,21,stitle)
  CALL video(n)
 ENDIF
 FOR (x = 1 TO ilinecnt)
   CALL text((iboxrowstart+ x),22,msg->line[x].msg)
 ENDFOR
 IF (stype="OK")
  CALL accept((iboxrowend - 1),39,"XX;;CU","OK"
   WHERE curaccept IN ("OK"))
 ELSEIF (stype="YN")
  CALL text((iboxrowend - 1),35,"Y/N")
  CALL accept((iboxrowend - 1),39,"x;;CU","Y"
   WHERE curaccept IN ("Y", "N"))
  CASE (curaccept)
   OF "Y":
    SET response->yes_ind = 1
    SET response->no_ind = 0
   OF "N":
    SET response->no_ind = 1
    SET response->yes_ind = 0
  ENDCASE
 ELSEIF (stype="NY")
  CALL text((iboxrowend - 1),35,"Y/N")
  CALL accept((iboxrowend - 1),39,"x;;CU","N"
   WHERE curaccept IN ("Y", "N"))
  CASE (curaccept)
   OF "Y":
    SET response->yes_ind = 1
    SET response->no_ind = 0
   OF "N":
    SET response->no_ind = 1
    SET response->yes_ind = 0
  ENDCASE
 ENDIF
 FOR (x = iboxrowstart TO iboxrowend)
   CALL clear(x,20,41)
 ENDFOR
END GO
