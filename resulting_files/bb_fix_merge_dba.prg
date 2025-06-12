CREATE PROGRAM bb_fix_merge:dba
 SET modify = predeclare
 RECORD cves(
   1 cve_cnt = i4
   1 list[*]
     2 code_value = f8
     2 code_set = i4
     2 field_name = c32
     2 field_cd = f8
     2 new_cd = f8
 )
 SELECT INTO "nl:"
  cve.field_value
  FROM code_value_extension cve,
   dm_merge_translate dmt_cv,
   code_value_extension@loc_mrg_link cve_src,
   dm_merge_translate dmt_fv
  PLAN (cve
   WHERE cve.code_set IN (1612, 1613, 1640, 1643)
    AND cve.field_name IN ("ABORH_cd", "ABOOnly_cd", "RhOnly_cd", "Opposite", "AntigenNeg"))
   JOIN (dmt_fv
   WHERE dmt_fv.from_value=cnvtreal(cve.field_value)
    AND dmt_fv.table_name="CODE_VALUE")
   JOIN (dmt_cv
   WHERE dmt_cv.to_value=cve.code_value
    AND dmt_cv.table_name="CODE_VALUE")
   JOIN (cve_src
   WHERE cve_src.code_value=dmt_cv.from_value
    AND cnvtcap(cve_src.field_name)=cnvtcap(cve.field_name)
    AND cve_src.code_set=cve.code_set
    AND cve_src.field_value=cve.field_value)
  HEAD REPORT
   cves->cve_cnt = 0
  DETAIL
   cves->cve_cnt = (cves->cve_cnt+ 1)
   IF ((cves->cve_cnt > size(cves->list,5)))
    stat = alterlist(cves->list,(cves->cve_cnt+ 20))
   ENDIF
   cves->list[cves->cve_cnt].code_value = cve.code_value, cves->list[cves->cve_cnt].code_set = cve
   .code_set, cves->list[cves->cve_cnt].field_name = cve.field_name,
   cves->list[cves->cve_cnt].field_cd = dmt_fv.from_value, cves->list[cves->cve_cnt].new_cd = dmt_fv
   .to_value
  FOOT REPORT
   stat = alterlist(cves->list,cves->cve_cnt)
  WITH counter
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
   WITH counter, forupdate(cve)
  ;end select
  IF ((curqual=cves->cve_cnt))
   UPDATE  FROM code_value_extension cve,
     (dummyt d  WITH seq = value(cves->cve_cnt))
    SET cve.field_value = trim(cnvtstring(cves->list[d.seq].new_cd,20,0,r))
    PLAN (d)
     JOIN (cve
     WHERE (cve.code_value=cves->list[d.seq].code_value)
      AND (cve.code_set=cves->list[d.seq].code_set)
      AND (cve.field_name=cves->list[d.seq].field_name))
    WITH counter
   ;end update
   IF ((curqual=cves->cve_cnt))
    CALL echo(build(cves->cve_cnt,": rows updated"))
   ELSE
    CALL echo("Error updating rows!!")
   ENDIF
  ELSE
   CALL echo("Error locking rows!!")
  ENDIF
 ELSE
  CALL echo("No rows to update!")
 ENDIF
 FREE RECORD cves
END GO
