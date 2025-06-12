CREATE PROGRAM bed_get_sn_comments:dba
 FREE SET reply
 RECORD reply(
   1 comments = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET prsnl_comm_type_cd = 0.0
 SET prefcard_comm_type_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=16289
   AND cv.cdf_meaning="PRSNL"
   AND cv.active_ind=1
  DETAIL
   prsnl_comm_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=16289
   AND cv.cdf_meaning="PREFCARD"
   AND cv.display_key="PREFERENCECARDCOMMENTS"
   AND cv.active_ind=1
  DETAIL
   prefcard_comm_type_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (prefcard_comm_type_cd=0.0)
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=16289
    AND cv.cdf_meaning="PREFCARD"
    AND cv.display="*Preference*"
    AND cv.active_ind=1
   DETAIL
    prefcard_comm_type_cd = cv.code_value
   WITH nocounter
  ;end select
  IF (prefcard_comm_type_cd=0.0)
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=16289
     AND cv.cdf_meaning="PREFCARD"
     AND cv.active_ind=1
    DETAIL
     prefcard_comm_type_cd = 0.0
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF ((request->procedure_code_value > 0))
  SELECT INTO "NL:"
   FROM preference_card pc,
    sn_comment_text sct,
    long_blob_reference lbr
   PLAN (pc
    WHERE (pc.catalog_cd=request->procedure_code_value)
     AND (pc.prsnl_id=request->surgeon_id)
     AND (pc.surg_area_cd=request->surgery_area_code_value))
    JOIN (sct
    WHERE sct.root_id=pc.pref_card_id
     AND sct.root_name="PREFERENCE_CARD"
     AND (sct.surg_area_cd=request->surgery_area_code_value)
     AND sct.comment_type_cd=prefcard_comm_type_cd
     AND sct.active_ind=1)
    JOIN (lbr
    WHERE lbr.long_blob_id=sct.long_blob_id)
   DETAIL
    reply->comments = lbr.long_blob
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "NL:"
   FROM sn_comment_text sct,
    long_blob_reference lbr
   PLAN (sct
    WHERE (sct.root_id=request->surgeon_id)
     AND sct.root_name="PRSNL"
     AND sct.comment_type_cd=prsnl_comm_type_cd
     AND sct.active_ind=1)
    JOIN (lbr
    WHERE lbr.long_blob_id=sct.long_blob_id)
   DETAIL
    reply->comments = lbr.long_blob
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
