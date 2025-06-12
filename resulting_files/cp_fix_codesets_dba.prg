CREATE PROGRAM cp_fix_codesets:dba
 SET successful_ind = 0
 SET pre_cnt = 0
 SET post_cnt = 0
 SELECT INTO "nl:"
  c.active_ind
  FROM code_value c
  WHERE c.code_set IN (14929, 14005)
   AND c.cdf_meaning IN ("PRELIM", "880", "1440", "1460", "1480",
  "1610", "1620", "1630", "1640", "1650",
  "1660", "1670", "240", "500", "780",
  "840", "860")
   AND c.active_ind=1
 ;end select
 IF (curqual > 0)
  SET pre_cnt = curqual
  UPDATE  FROM code_value c
   SET c.active_ind = 0
   WHERE c.code_set IN (14929, 14005)
    AND c.cdf_meaning IN ("PRELIM", "880", "1440", "1460", "1480",
   "1610", "1620", "1630", "1640", "1650",
   "1660", "1670", "240", "500", "780",
   "840", "860")
    AND c.active_ind=1
  ;end update
  SET post_cnt = curqual
 ENDIF
 IF (pre_cnt > 0
  AND pre_cnt=post_cnt)
  SET successful_ind = 1
 ENDIF
 IF (successful_ind=1)
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
END GO
