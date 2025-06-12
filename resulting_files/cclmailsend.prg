CREATE PROGRAM cclmailsend
 PROMPT
  "ENTER MAIL_TO             : " = curuser,
  "ENTER MAIL_FROM           : " = curuser,
  "ENTER MAIL_TYPE (M,A,B)   : " = "M",
  "ENTER MAIL_CNT            : " = 1,
  "ENTER MAIL_SUBJECT        : " = "TESTML",
  "ENTER MAIL_MSG            : " = "TEST MAIL"
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
 SET _mtotseq = ( $4/ 99)
 SET _modcnt = mod( $4,99)
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
     SET _mmsg[_num] = concat(trim(substring((1+ ((_pcnt - 1) * 78)),77, $6)),"^")
     SET _mlen[_num] = size(trim(_mmsg[_num]))
     SET _num += 1
   ENDWHILE
   IF (( $3="M"))
    INSERT
     SET ml05_1.user_id1 =  $1, ml05_1.message_type1 = "M", ml05_1.message_date1 = _mdate,
      ml05_1.message_time1 = _mtime, ml05_1.qualifier1 = 1, ml05_1.sequence_nbr1 = _mseq,
      ml05_1.sender_id2 =  $2, ml05_1.message_type2 = "M", ml05_1.message_date2 = _mdate,
      ml05_1.message_time2 = _mtime, ml05_1.qualifier2 = 1, ml05_1.sequence_nbr2 = _mseq,
      ml05_1.user_id3 =  $1, ml05_1.message_type3 = "M", ml05_1.subject3 =  $5,
      ml05_1.message_date3 = _mdate, ml05_1.message_time3 = _mtime, ml05_1.qualifier3 = 1,
      ml05_1.sequence_nbr3 = _mseq, ml05_1.sender_id =  $2, ml05_1.activity_date = _mdate,
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
     notranlog
    ;end insert
   ELSEIF (( $3="B"))
    INSERT
     SET ml05_1.user_id =  $1, ml05_1.message_type = "B", ml05_1.message_date = _mdate,
      ml05_1.message_time = _mtime, ml05_1.qualifier = 1, ml05_1.sequence_nbr = _mseq,
      ml05_1.sender_id2 =  $2, ml05_1.message_type2 = "B", ml05_1.message_date2 = _mdate,
      ml05_1.message_time2 = _mtime, ml05_1.qualifier2 = 1, ml05_1.sequence_nbr2 = _mseq,
      ml05_1.user_id3 =  $1, ml05_1.message_type3 = "B", ml05_1.subject3 =  $5,
      ml05_1.message_date3 = _mdate, ml05_1.message_time3 = _mtime, ml05_1.qualifier3 = 1,
      ml05_1.sequence_nbr3 = _mseq, ml05_1.sender_id =  $2, ml05_1.activity_date = _mdate,
      ml05_1.activity_time = _mtime, ml05_1.activity_task = "MLBBM", ml05_1.activity_status = "1",
      ml05_1.reviewed_by = " ", ml05_1.reply_allowed = "Y", ml05_1.reply_attached = "N",
      ml05_1.nbr_replies = 0, ml05_1.removal_date = _mremdate, ml05_1.lines_of_data = _numline,
      ml05_1.overflow =
      IF (_mtotseq > 1
       AND _mseq < _mtotseq) "Y"
      ELSE "N"
      ENDIF
      , ml05_2.end_of_line = _mlen[ml05_2.seq], ml05_3.message_line = _mmsg[ml05_3.seq]
     WHERE ml05_2.seq BETWEEN 1 AND _numline
      AND ml05_3.seq BETWEEN 1 AND _numline
     WITH clear = " ", maxqual(ml05_2,value(_numline)), maxqual(ml05_3,value(_numline)),
     notranlog
    ;end insert
   ELSEIF (( $3="A"))
    IF (_mseq=1)
     SET _qual = 1
     UPDATE
      SET _qual = (ml05_1.nbr_replies+ 1), _mdate2 = ml05_1.message_date1, _mtime2 = ml05_1
       .message_time1,
       ml05_1.reply_attached = "Y", ml05_1.nbr_replies = (ml05_1.nbr_replies+ 1), ml05_1
       .activity_date = _mdate,
       ml05_1.activity_time = _mtime, ml05_1.activity_task = "MLBBM"
      WHERE (ml05_1.user_id= $1)
       AND ml05_1.message_type="B"
       AND (ml05_1.subject= $5)
      WITH nocounter, notranlog
     ;end update
    ENDIF
    INSERT
     SET ml05_1.user_id =  $1, ml05_1.message_type = "A", ml05_1.message_date = _mdate2,
      ml05_1.message_time = _mtime2, ml05_1.qualifier = _qual, ml05_1.sequence_nbr = _mseq,
      ml05_1.sender_id2 =  $2, ml05_1.message_type2 = "A", ml05_1.message_date2 = _mdate,
      ml05_1.message_time2 = _mtime, ml05_1.qualifier2 = 1, ml05_1.sequence_nbr2 = _mseq,
      ml05_1.user_id3 =  $1, ml05_1.message_type3 = "A", ml05_1.subject3 =  $5,
      ml05_1.message_date3 = _mdate, ml05_1.message_time3 = _mtime, ml05_1.qualifier3 = 1,
      ml05_1.sequence_nbr3 = _mseq, ml05_1.sender_id =  $2, ml05_1.activity_date = _mdate,
      ml05_1.activity_time = _mtime, ml05_1.activity_task = "MLUNL", ml05_1.activity_status = "1",
      ml05_1.reviewed_by = " ", ml05_1.reply_allowed = "Y", ml05_1.reply_attached = "Y",
      ml05_1.nbr_replies = (_qual - 1), ml05_1.removal_date = _mremdate, ml05_1.lines_of_data =
      _numline,
      ml05_1.overflow =
      IF (_mtotseq > 1
       AND _mseq < _mtotseq) "Y"
      ELSE "N"
      ENDIF
      , ml05_2.end_of_line = _mlen[ml05_2.seq], ml05_3.message_line = _mmsg[ml05_3.seq]
     WHERE ml05_2.seq BETWEEN 1 AND _numline
      AND ml05_3.seq BETWEEN 1 AND _numline
     WITH clear = " ", maxqual(ml05_2,value(_numline)), maxqual(ml05_3,value(_numline)),
     notranlog
    ;end insert
   ENDIF
   SET _mseq += 1
 ENDWHILE
END GO
