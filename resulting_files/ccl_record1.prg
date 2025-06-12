CREATE PROGRAM ccl_record1
 EXECUTE cclseclogin
 RECORD enc(
   1 qual[*]
     2 encounter = f8
 )
 SELECT INTO "NL:"
  e.encntr_id
  FROM encounter e
  ORDER BY e.encntr_id
  HEAD REPORT
   stat = alterlist(enc->qual,10), enc_cnt = 0
  DETAIL
   enc_cnt = (enc_cnt+ 1)
   IF (mod(enc_cnt,10)=1
    AND enc_cnt != 1)
    stat = alterlist(enc->qual,(enc_cnt+ 9))
   ENDIF
   enc->qual[enc_cnt].encounter = e.encntr_id
  FOOT REPORT
   stat = alterlist(enc->qual,enc_cnt),
   CALL echorecord(enc)
  WITH maxrec = 100
 ;end select
END GO
