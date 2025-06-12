CREATE PROGRAM cclmailsend2:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c15
       3 sourceobjectqual = i4
       3 sourceobjectvalue = c50
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c50
       3 sub_event_dt_tm = di8
 )
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET _mremdate = 0
 SET _mdate = 0
 SET _mtime = 0
 SET _mdate2 = 0
 SET _mtime2 = 0
 SET _mlen[99] = 0
 SET _mmsg[99] = fillstring(78," ")
 SET _mseq = 0
 SET _mtotseq = 0
 SET _modcnt = 0
 SET _numline = 0
 SET _num = 0
 SET _pcnt = 0
 SET _qual = 0
 SET modify = system
 FREE DEFINE ml
 DEFINE ml  WITH modify
 RANGE OF ml05_1 IS ml05_1
 RANGE OF ml05_2 IS ml05_2
 RANGE OF ml05_3 IS ml05_3
 SET _mremdate = cnvtint(format((curdate+ 30),"YYMMDD;;D"))
 SET _mdate = cnvtint(format(curdate,"YYMMDD;;D"))
 SET _mtime = (curtime * 100)
 SET message = - (1)
 SET _mtime = curtime2
 SET message = 2
 SET _mdate2 = _mdate
 SET _mtime2 = _mtime
 SET _mtotseq = 0
 SET _mtotseq = (request->msg_size/ 99)
 SET _modcnt = mod(request->msg_size,99)
 IF (_modcnt > 0)
  SET _mtotseq += 1
 ENDIF
 SET _mseq = 1
 WHILE (_mseq <= _mtotseq)
   IF (((_mseq < _mtotseq) OR (_modcnt=0)) )
    SET _numline = 99
   ELSE
    SET _numline = _modcnt
   ENDIF
   SET _num = 1
   WHILE (_num <= _numline)
     SET _pcnt += 1
     SET _mmsg[_num] = concat(trim(substring((1+ ((_pcnt - 1) * 78)),77,request->msg_text)),"^")
     SET _mlen[_num] = size(trim(_mmsg[_num]))
     SET _num += 1
   ENDWHILE
   INSERT
    SET ml05_1.user_id1 = request->userid_to, ml05_1.message_type1 = "M", ml05_1.message_date1 =
     _mdate,
     ml05_1.message_time1 = _mtime, ml05_1.qualifier1 = 1, ml05_1.sequence_nbr1 = _mseq,
     ml05_1.sender_id2 = request->userid_from, ml05_1.message_type2 = "M", ml05_1.message_date2 =
     _mdate,
     ml05_1.message_time2 = _mtime, ml05_1.qualifier2 = 1, ml05_1.sequence_nbr2 = _mseq,
     ml05_1.user_id3 = request->userid_to, ml05_1.message_type3 = "M", ml05_1.subject3 = request->
     subject,
     ml05_1.message_date3 = _mdate, ml05_1.message_time3 = _mtime, ml05_1.qualifier3 = 1,
     ml05_1.sequence_nbr3 = _mseq, ml05_1.sender_id = request->userid_from, ml05_1.activity_date =
     _mdate,
     ml05_1.activity_time = _mtime, ml05_1.activity_task = "MLMOV", ml05_1.activity_status = "1",
     ml05_1.reviewed_by = " ", ml05_1.confidential = "N", ml05_1.screen_attached = "N",
     ml05_1.type = "M", ml05_1.response_req = 0, ml05_1.response_date = 0,
     ml05_1.response_time = 0, ml05_1.response_by = " ", ml05_1.priority = 1,
     ml05_1.orig_to = " ", ml05_1.orig_from = " ", ml05_1.lines_of_data = _numline,
     ml05_1.overflow =
     IF (_mtotseq > 1
      AND _mseq < _mtotseq) "Y"
     ELSE "N"
     ENDIF
     , ml05_2.end_of_line = _mlen[ml05_2.seq], ml05_3.message_line = _mmsg[ml05_3.seq]
    WHERE ml05_2.seq BETWEEN 1 AND _numline
     AND ml05_3.seq BETWEEN 1 AND _numline
    WITH clear = " ", maxqual(ml05_2,value(_numline)), maxqual(ml05_3,value(_numline)),
    notranlog, size = 9200
   ;end insert
   SET _mseq += 1
 ENDWHILE
 IF (curqual > 0)
  SET failed = "S"
 ENDIF
 IF (failed="S")
  COMMIT
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "sys_send_mail"
 ELSE
  ROLLBACK
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
 ENDIF
END GO
