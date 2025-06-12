CREATE PROGRAM aps_get_word_phrases:dba
 RECORD reply(
   1 word_qual[*]
     2 word = vc
     2 singular_word = vc
     2 used_singular_ind = i2
     2 word_frequency = i4
     2 qual[*]
       3 nomenclature_id = f8
       3 source_vocabulary_cd = f8
       3 vocab_axis_cd = f8
       3 source_identifier = vc
       3 word_phrase = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 word_qual[*]
     2 word = vc
 )
 SET reply->status_data.status = "F"
 SET source_where = fillstring(500," ")
 SET totalcnt = 0
 SET x = 0
 SET z = 0
 SET excludecnt = cnvtint(size(request->exclude_axis_qual,5))
 SET ncnt = cnvtint(size(request->source_vocab_qual,5))
 SET wordcnt = cnvtint(size(request->word_qual,5))
 SET asterixstring = "*"
 SET spacestring = fillstring(1," ")
 SET exclude_where = fillstring(1000," ")
 SET singular_cnt = 0
 SET tempword = fillstring(1000," ")
 SET stat = alterlist(temp->word_qual,wordcnt)
 FOR (x = 1 TO wordcnt)
   IF (textlen(trim(request->word_qual[x].word)) > 0)
    SET temp->word_qual[x].word = request->word_qual[x].word
    SET request->word_qual[x].word = concat(cnvtlower(trim(request->word_qual[x].word)),spacestring,
     asterixstring)
   ELSE
    GO TO blank_word_error
   ENDIF
 ENDFOR
 FOR (x = 1 TO ncnt)
   IF (x=1)
    SET source_where = build("n.source_vocabulary_cd in (",request->source_vocab_qual[x].
     source_vocabulary_cd)
   ELSE
    SET source_where = build(trim(source_where),",",request->source_vocab_qual[x].
     source_vocabulary_cd)
   ENDIF
 ENDFOR
 SET source_where = concat(trim(source_where),")")
 IF ((request->from_server_ind != 1))
  IF (excludecnt > 0)
   FOR (x = 1 TO excludecnt)
     IF (x=1)
      SET exclude_where = build("n.vocab_axis_cd not in (",request->exclude_axis_qual[x].
       exclude_axis_cd)
     ELSE
      SET exclude_where = build(trim(exclude_where),",",request->exclude_axis_qual[x].exclude_axis_cd
       )
     ENDIF
   ENDFOR
   SET exclude_where = concat(trim(exclude_where),")")
  ELSE
   SET exclude_where = "0 = 0"
  ENDIF
 ELSE
  SET exclude_where = "0 = 0"
 ENDIF
 SET stat = alterlist(reply->word_qual,wordcnt)
 FOR (z = 1 TO wordcnt)
   SET reply->word_qual[z].word = temp->word_qual[z].word
   SET reply->word_qual[z].singular_word = request->word_qual[z].singular_word
   SET reply->word_qual[z].word_frequency = request->word_qual[z].word_frequency
   SELECT INTO "nl:"
    n.nomenclature_id, nsi.normalized_string
    FROM nomenclature n,
     normalized_string_index nsi
    PLAN (nsi
     WHERE nsi.normalized_string=patstring(request->word_qual[z].word))
     JOIN (n
     WHERE nsi.nomenclature_id=n.nomenclature_id
      AND parser(source_where)
      AND parser(exclude_where)
      AND n.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
      AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND  NOT (n.vocab_axis_cd IN (0, null)))
    HEAD REPORT
     x = 0, stat = alterlist(reply->word_qual[z].qual,10)
    DETAIL
     x = (x+ 1)
     IF (mod(x,10)=1
      AND x != 1)
      stat = alterlist(reply->word_qual[z].qual,(x+ 9))
     ENDIF
     reply->word_qual[z].qual[x].nomenclature_id = n.nomenclature_id, reply->word_qual[z].qual[x].
     source_vocabulary_cd = n.source_vocabulary_cd, reply->word_qual[z].qual[x].source_identifier =
     trim(n.source_identifier),
     reply->word_qual[z].qual[x].word_phrase = trim(n.source_string), reply->word_qual[z].qual[x].
     vocab_axis_cd = n.vocab_axis_cd
    FOOT REPORT
     stat = alterlist(reply->word_qual[z].qual,x), totalcnt = (totalcnt+ x)
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET x = 0
    IF (textlen(trim(request->word_qual[z].singular_word)) > 0)
     SET tempword = concat(cnvtlower(trim(request->word_qual[z].singular_word)),spacestring,
      asterixstring)
     SET reply->word_qual[z].used_singular_ind = 1
     SELECT INTO "nl:"
      n.nomenclature_id, nsi.normalized_string
      FROM nomenclature n,
       normalized_string_index nsi
      PLAN (nsi
       WHERE nsi.normalized_string=patstring(tempword))
       JOIN (n
       WHERE nsi.nomenclature_id=n.nomenclature_id
        AND parser(source_where)
        AND parser(exclude_where)
        AND n.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
        AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
        AND  NOT (n.vocab_axis_cd IN (0, null)))
      HEAD REPORT
       x = 0, stat = alterlist(reply->word_qual[z].qual,10)
      DETAIL
       x = (x+ 1)
       IF (mod(x,10)=1
        AND x != 1)
        stat = alterlist(reply->word_qual[z].qual,(x+ 9))
       ENDIF
       reply->word_qual[z].qual[x].nomenclature_id = n.nomenclature_id, reply->word_qual[z].qual[x].
       source_vocabulary_cd = n.source_vocabulary_cd, reply->word_qual[z].qual[x].source_identifier
        = trim(n.source_identifier),
       reply->word_qual[z].qual[x].word_phrase = trim(n.source_string)
      FOOT REPORT
       stat = alterlist(reply->word_qual[z].qual,x), totalcnt = (totalcnt+ x)
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
 ENDFOR
 IF (totalcnt=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "NOMENCLATURE"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 GO TO end_program
#blank_word_error
 SET reply->status_data.subeventstatus[1].operationname = "INPUT DATA"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "WORD"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "WORD IS SPACES"
 SET reply->status_data.status = "F"
#end_program
END GO
