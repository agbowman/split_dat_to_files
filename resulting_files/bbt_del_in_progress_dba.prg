CREATE PROGRAM bbt_del_in_progress:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 exception_data[1]
     2 event_id = f8
 )
 SET reply->status_data.status = "F"
 SET number_of_product = cnvtint(size(request->qual,5))
 SET failed = "F"
 SET status_count = 0
 SET exception_count = 0
 FOR (x = 1 TO number_of_product)
  DELETE  FROM product_event p
   WHERE (p.product_event_id=request->qual[x].product_event_id)
   WITH nocounter
  ;end delete
  IF (curqual=0)
   SET failed = "T"
   SET status_count += 1
   IF (status_count > 1)
    SET stat = alter(reply->status_data.subeventstatus,(status_count+ 1))
   ENDIF
   SET reply->status_data.subeventstatus[status_count].operationname = "DELETE"
   SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
   SET reply->status_data.subeventstatus[status_count].targetobjectname = "Product Event"
   SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
   "Unable to delete product event"
   SET exception_count += 1
   IF (exception_count > 1)
    SET stat = alter(reply->exception_data,(exception_count+ 1))
   ENDIF
   SET reply->exception_data[exception_count].event_id = request->qual[x].product_event_id
   GO TO exit_script
  ELSEIF ((request->qual[x].bb_result_id > 0))
   SET hold_result_id[200] = 0.0
   SET long_text_id[200] = 0.0
   SET count1 = 0
   SET count2 = 0
   SELECT INTO "nl:"
    r.*
    FROM result r
    WHERE (r.bb_result_id=request->qual[x].bb_result_id)
    DETAIL
     count1 += 1, hold_result_id[count1] = r.result_id
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SELECT INTO "nl:"
     pr.*
     FROM perform_result pr,
      (dummyt d1  WITH seq = value(count1))
     PLAN (d1)
      JOIN (pr
      WHERE (pr.result_id=hold_result_id[d1.seq])
       AND pr.long_text_id > 0)
     DETAIL
      count2 += 1, long_text_id[count2] = pr.long_text_id
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     rc.*
     FROM result_comment rc,
      (dummyt d1  WITH seq = value(count1))
     PLAN (d1)
      JOIN (rc
      WHERE (rc.result_id=hold_result_id[d1.seq])
       AND rc.long_text_id > 0)
     DETAIL
      count2 += 1, long_text_id[count2] = rc.long_text_id
     WITH nocounter
    ;end select
    FOR (y = 1 TO count2)
     DELETE  FROM long_text l
      WHERE (l.long_text_id=long_text_id[y])
      WITH nocounter
     ;end delete
     IF (curqual=0)
      SET failed = "T"
      SET status_count += 1
      IF (status_count > 1)
       SET stat = alter(reply->status_data.subeventstatus,(status_count+ 1))
      ENDIF
      SET reply->status_data.subeventstatus[status_count].operationname = "DELETE"
      SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
      SET reply->status_data.subeventstatus[status_count].targetobjectname = "Long Text"
      SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
      "Unable to delete long text"
      GO TO exit_script
     ENDIF
    ENDFOR
    FOR (y = 1 TO count1)
      DELETE  FROM result_comment r
       WHERE (r.result_id=hold_result_id[y])
       WITH nocounter
      ;end delete
      DELETE  FROM result_event r
       WHERE (r.result_id=hold_result_id[y])
       WITH nocounter
      ;end delete
      IF (curqual=0)
       SET failed = "T"
       SET status_count += 1
       IF (status_count > 1)
        SET stat = alter(reply->status_data.subeventstatus,(status_count+ 1))
       ENDIF
       SET reply->status_data.subeventstatus[status_count].operationname = "DELETE"
       SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
       SET reply->status_data.subeventstatus[status_count].targetobjectname = "Result Event"
       SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
       "Unable to delete result event"
       GO TO exit_script
      ELSE
       DELETE  FROM perform_result r
        WHERE (r.result_id=hold_result_id[y])
        WITH nocounter
       ;end delete
       IF (curqual=0)
        SET failed = "T"
        SET status_count += 1
        IF (status_count > 1)
         SET stat = alter(reply->status_data.subeventstatus,(status_count+ 1))
        ENDIF
        SET reply->status_data.subeventstatus[status_count].operationname = "DELETE"
        SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
        SET reply->status_data.subeventstatus[status_count].targetobjectname = "Perform Result"
        SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
        "Unable to delete perform result"
        GO TO exit_script
       ELSE
        DELETE  FROM result r
         WHERE (r.result_id=hold_result_id[y])
         WITH nocounter
        ;end delete
        IF (curqual=0)
         SET failed = "T"
         SET status_count += 1
         IF (status_count > 1)
          SET stat = alter(reply->status_data.subeventstatus,(status_count+ 1))
         ENDIF
         SET reply->status_data.subeventstatus[status_count].operationname = "DELETE"
         SET reply->status_data.subeventstatus[status_count].operationstatus = "F"
         SET reply->status_data.subeventstatus[status_count].targetobjectname = "Result"
         SET reply->status_data.subeventstatus[status_count].targetobjectvalue =
         "Unable to delete result"
         GO TO exit_script
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
  ENDIF
 ENDFOR
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
