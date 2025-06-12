CREATE PROGRAM ap_processing_grp_r_fix:dba
 RECORD temp(
   1 qual[*]
     2 grouper_cd = f8
     2 code_value_ind = i2
 )
 SET cnt = 0
 SELECT INTO "nl:"
  ap.grouper_cd, d1.seq, d2.seq,
  cv_exists = decode(cv.seq,1,0)
  FROM ap_processing_grp_r ap,
   (dummyt d1  WITH seq = 1),
   code_value cv,
   (dummyt d2  WITH seq = 1),
   ap_specimen_protocol asp
  PLAN (ap)
   JOIN (((d1
   WHERE 1=d1.seq)
   JOIN (cv
   WHERE ap.grouper_cd=cv.code_value)
   ) ORJOIN ((d2
   WHERE 1=d2.seq)
   JOIN (asp
   WHERE ap.grouper_cd=asp.protocol_id)
   ))
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,25)=1)
    stat = alterlist(temp->qual,(cnt+ 24))
   ENDIF
   temp->qual[cnt].grouper_cd = ap.grouper_cd, temp->qual[cnt].code_value_ind = cv_exists
  FOOT REPORT
   stat = alterlist(temp->qual,cnt)
  WITH nocounter
 ;end select
 IF (cnt != 0)
  UPDATE  FROM ap_processing_grp_r ap,
    (dummyt d  WITH seq = value(cnt))
   SET ap.parent_entity_id = temp->qual[d.seq].grouper_cd, ap.parent_entity_name =
    IF ((temp->qual[d.seq].code_value_ind=1)) "CODE_VALUE"
    ELSE "AP_SPECIMEN_PROTOCOL"
    ENDIF
   PLAN (d)
    JOIN (ap
    WHERE (temp->qual[d.seq].grouper_cd=ap.grouper_cd))
   WITH nocounter
  ;end update
  COMMIT
 ENDIF
END GO
