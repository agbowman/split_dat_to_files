CREATE PROGRAM bsc_get_discipline_event_sets:dba
 SET modify = predeclare
 RECORD reply(
   1 discipline_list[*]
     2 discipline_cd = f8
     2 event_list[*]
       3 event_set_cd = f8
       3 event_set_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE disciplinecnt = i2 WITH protect, noconstant(0)
 DECLARE eventcnt = i2 WITH protect, noconstant(0)
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE nstat = i2 WITH protect, noconstant(0)
 DECLARE req_disp_cnt = i4 WITH protect, noconstant(size(request->discipline_list,5))
 DECLARE start = i4 WITH protect, noconstant(1)
 DECLARE nsize = i4 WITH protect, noconstant(50)
 DECLARE ntotal = i4 WITH noconstant((ceil((cnvtreal(req_disp_cnt)/ nsize)) * nsize))
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 SET reply->status_data.status = "F"
 IF (size(request->discipline_list,5)=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus.operationname = "No discplines submitted"
  GO TO exit_script
 ENDIF
 SET nstat = alterlist(request->discipline_list,ntotal)
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
   dscpln_event_r der,
   v500_event_set_code v
  PLAN (d1
   WHERE initarray(start,evaluate(d1.seq,1,1,(start+ nsize))))
   JOIN (der
   WHERE expand(lidx,start,(start+ (nsize - 1)),der.discipline_cd,request->discipline_list[lidx].
    discipline_cd))
   JOIN (v
   WHERE v.event_set_cd=der.event_set_cd)
  ORDER BY der.discipline_cd
  HEAD REPORT
   disciplinecnt = 0
  HEAD der.discipline_cd
   disciplinecnt = (disciplinecnt+ 1), eventcnt = 0
   IF (mod(disciplinecnt,10)=1)
    nstat = alterlist(reply->discipline_list,(disciplinecnt+ 9))
   ENDIF
   reply->discipline_list[disciplinecnt].discipline_cd = der.discipline_cd
  HEAD der.event_set_cd
   eventcnt = (eventcnt+ 1)
   IF (mod(eventcnt,10)=1)
    nstat = alterlist(reply->discipline_list[disciplinecnt].event_list,(eventcnt+ 9))
   ENDIF
   reply->discipline_list[disciplinecnt].event_list[eventcnt].event_set_cd = der.event_set_cd, reply
   ->discipline_list[disciplinecnt].event_list[eventcnt].event_set_name = v.event_set_name
  FOOT  der.discipline_cd
   nstat = alterlist(reply->discipline_list[disciplinecnt].event_list,eventcnt)
  FOOT REPORT
   nstat = alterlist(reply->discipline_list,disciplinecnt)
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = errmsg
 ELSEIF (size(reply->discipline_list,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
 SET last_mod = "001"
 SET mod_date = "05/15/2007"
 CALL echorecord(reply)
 SET modify = nopredeclare
END GO
