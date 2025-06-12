CREATE PROGRAM cpm_get_all_cd_for_cdf:dba
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=code_set
   AND c.cdf_meaning=cnvtupper(cdf_meaning)
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  HEAD REPORT
   nbr_of_cd = 0
  DETAIL
   nbr_of_cd = (nbr_of_cd+ 1), stat = alterlist(cd->qual,nbr_of_cd), cd->qual[nbr_of_cd].code_value
    = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET nbr_of_cd = 0
 ENDIF
END GO
