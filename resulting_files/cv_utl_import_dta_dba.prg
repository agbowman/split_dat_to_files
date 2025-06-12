CREATE PROGRAM cv_utl_import_dta:dba
 EXECUTE orm_import_dta
 UPDATE  FROM (dummyt d  WITH seq = value(size(requestin->list_0,5))),
   code_value cv
  SET cv.cdf_meaning = requestin->list_0[d.seq].cdf_meaning
  PLAN (d)
   JOIN (cv
   WHERE (cv.display=requestin->list_0[d.seq].mnemonic)
    AND cv.code_set=14003)
  WITH nocounter
 ;end update
END GO
