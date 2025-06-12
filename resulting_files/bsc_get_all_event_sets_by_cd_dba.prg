CREATE PROGRAM bsc_get_all_event_sets_by_cd:dba
 SET modify = predeclare
 RECORD reply(
   1 event_cd_list[*]
     2 event_cd = f8
     2 event_set_list[*]
       3 event_set_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE loadeventsetcds(null) = null
 DECLARE finalize(null) = null
 DECLARE printdebugmsg(msg=vc) = null
 DECLARE last_mod = c12 WITH private, noconstant(fillstring(12," "))
 DECLARE total_script_timer = f8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE subroutine_timer = f8 WITH protect, noconstant(0)
 DECLARE query_timer = f8 WITH protect, noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE error_cd = i2 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE event_cd_cnt = i4 WITH protect, noconstant(size(request->event_cd_list,5))
 DECLARE nstart = i4 WITH protect, noconstant(1)
 DECLARE ntotal = i4 WITH protect, noconstant(0)
 DECLARE nsize = i4 WITH protect, constant(50)
 CALL loadeventsetcds(null)
 CALL finalize(null)
 SUBROUTINE loadeventsetcds(null)
   CALL printdebugmsg("***SUBROUTINE LoadEventSetCds()***")
   IF (event_cd_cnt <= 0)
    RETURN
   ENDIF
   DECLARE event_cnt = i4 WITH protect, noconstant(0)
   DECLARE event_set_cnt = i4 WITH protect, noconstant(0)
   DECLARE iterator = i4 WITH protect, noconstant(1)
   SET subroutine_timer = cnvtdatetime(curdate,curtime3)
   SET ntotal = (ceil((cnvtreal(event_cd_cnt)/ nsize)) * nsize)
   SET stat = alterlist(request->event_cd_list,ntotal)
   FOR (i = (event_cd_cnt+ 1) TO ntotal)
     SET request->event_cd_list[i].event_cd = request->event_cd_list[event_cd_cnt].event_cd
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     v500_event_set_explode ese,
     v500_event_set_code esc
    PLAN (d1
     WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
     JOIN (ese
     WHERE expand(iterator,nstart,(nstart+ (nsize - 1)),ese.event_cd,request->event_cd_list[iterator]
      .event_cd))
     JOIN (esc
     WHERE esc.event_set_cd=ese.event_set_cd)
    ORDER BY ese.event_cd, ese.event_set_cd, ese.event_set_level
    HEAD REPORT
     CALL printdebugmsg(build("*****LoadEventSetCds() Query Time = ",datetimediff(cnvtdatetime(
        curdate,curtime3),subroutine_timer,5))), event_cnt = 0
    HEAD ese.event_cd
     event_cnt = (event_cnt+ 1), event_set_cnt = 0
     IF (event_cnt > size(reply->event_cd_list,5))
      stat = alterlist(reply->event_cd_list,(event_cnt+ 9))
     ENDIF
     reply->event_cd_list[event_cnt].event_cd = ese.event_cd
    HEAD ese.event_set_cd
     event_set_cnt = (event_set_cnt+ 1)
     IF (event_set_cnt > size(reply->event_cd_list[event_cnt].event_set_list,5))
      stat = alterlist(reply->event_cd_list[event_cnt].event_set_list,(event_set_cnt+ 9))
     ENDIF
     reply->event_cd_list[event_cnt].event_set_list[event_set_cnt].event_set_cd = ese.event_set_cd
    FOOT  ese.event_cd
     stat = alterlist(reply->event_cd_list[event_cnt].event_set_list,event_set_cnt)
    FOOT REPORT
     stat = alterlist(reply->event_cd_list,event_cnt),
     CALL printdebugmsg(build("*****LoadEventSetCds() Query Total Time = ",datetimediff(cnvtdatetime(
        curdate,curtime3),subroutine_timer,5)))
    WITH nocounter
   ;end select
   SET stat = alterlist(request->event_cd_list,event_cd_cnt)
   CALL printdebugmsg(build("*****LoadResults() SUBROUTINE Timer = ",datetimediff(cnvtdatetime(
       curdate,curtime3),subroutine_timer,5)))
 END ;Subroutine
 SUBROUTINE finalize(null)
   CALL printdebugmsg("***SUBROUTINE Finalize()***")
   IF ((request->debug_ind > 0))
    CALL echo("*********************************")
    CALL echo(build("Total Script Time = ",datetimediff(cnvtdatetime(curdate,curtime3),
       total_script_timer,5)))
    CALL echo("*********************************")
   ENDIF
   IF (size(reply->event_cd_list,5)=0)
    SET reply->status_data.status = "Z"
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
   SET error_cd = error(error_msg,1)
   IF (error_cd != 0)
    CALL echo("*********************************")
    CALL echo(build("ERROR MESSAGE : ",error_msg))
    CALL echo("*********************************")
    SET reply->status_data.status = "F"
   ENDIF
 END ;Subroutine
 SUBROUTINE printdebugmsg(msg)
   IF ((request->debug_ind > 0))
    CALL echo(msg)
   ENDIF
 END ;Subroutine
 SET last_mod = "001 04/21/11"
 SET modify = nopredeclare
END GO
