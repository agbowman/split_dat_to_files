CREATE PROGRAM bb_clean_merge:dba
 SET modify = predeclare
 RECORD cves(
   1 cve_cnt = i4
   1 list[*]
     2 code_value = f8
     2 code_set = i4
     2 field_name = c32
 )
 SELECT INTO "nl:"
  cve.code_value, cve.field_name, cve.code_set,
  num_ind = isnumeric(cve.field_value)
  FROM code_value_extension cve
  PLAN (cve
   WHERE cve.code_set IN (1612, 1613, 1640, 1643)
    AND cve.field_name IN ("ABORH_cd", "ABOOnly_cd", "RhOnly_cd", "Opposite", "AntigenNeg"))
  HEAD REPORT
   cves->cve_cnt = 0
  DETAIL
   IF (num_ind=0)
    cves->cve_cnt = (cves->cve_cnt+ 1)
    IF ((cves->cve_cnt > size(cves->list,5)))
     stat = alterlist(cves->list,(cves->cve_cnt+ 20))
    ENDIF
    cves->list[cves->cve_cnt].code_value = cve.code_value, cves->list[cves->cve_cnt].code_set = cve
    .code_set, cves->list[cves->cve_cnt].field_name = cve.field_name
   ENDIF
  FOOT REPORT
   stat = alterlist(cves->list,cves->cve_cnt)
  WITH nocounter
 ;end select
 IF ((cves->cve_cnt > 0))
  SELECT INTO "nl:"
   cve.code_value
   FROM (dummyt d  WITH seq = value(cves->cve_cnt)),
    code_value_extension cve
   PLAN (d)
    JOIN (cve
    WHERE (cve.code_value=cves->list[d.seq].code_value)
     AND (cve.code_set=cves->list[d.seq].code_set)
     AND (cve.field_name=cves->list[d.seq].field_name))
   WITH nocounter, forupdate(cve)
  ;end select
  IF ((curqual=cves->cve_cnt))
   UPDATE  FROM code_value_extension cve,
     (dummyt d  WITH seq = value(cves->cve_cnt))
    SET cve.field_value = "0"
    PLAN (d)
     JOIN (cve
     WHERE (cve.code_value=cves->list[d.seq].code_value)
      AND (cve.code_set=cves->list[d.seq].code_set)
      AND (cve.field_name=cves->list[d.seq].field_name))
    WITH nocounter
   ;end update
   IF ((curqual=cves->cve_cnt))
    CALL echo(build(cves->cve_cnt,": rows updated"))
   ELSE
    CALL echo("Error updating rows!!")
   ENDIF
  ELSE
   CALL echo("Error locking rows!")
  ENDIF
 ELSE
  CALL echo("No rows to update.")
 ENDIF
 FREE RECORD cves
END GO
