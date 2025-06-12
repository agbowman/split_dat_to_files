CREATE PROGRAM bhs_import_find_cv_from_cva:dba
 SET trace = echorecord
 IF (validate(requestin->list_0[1].lab_test_code) <= 0)
  RECORD requestin(
    1 list_0[*]
      2 lab_test_code = f8
      2 lab_test_desc = vc
      2 result_code = f8
      2 result_desc = vc
  )
  SET stat = alterlist(requestin->list_0,1)
  SET requestin->list_0[1].lab_test_code = 26500
  SET requestin->list_0[1].lab_test_desc = "1,25OH VITAMIN D"
  SET requestin->list_0[1].result_code = 26504
  SET requestin->list_0[1].result_desc = "1,25OH VITAMIN D"
 ENDIF
 RECORD results(
   1 qual[*]
   1 orderable_200 = f8
   1 events[*]
     2 event_72 = f8
 )
 SET filename = "cvatestfile"
 SELECT DISTINCT INTO value(filename)
  ca.contributor_source_cd, val = uar_get_code_display(ca.contributor_source_cd)
  FROM (dummyt d  WITH seq = size(requestin->list_0,5)),
   code_value_alias ca
  PLAN (d)
   JOIN (ca
   WHERE ca.alias=trim(cnvtstring(requestin->list_0[d.seq].lab_test_code),3))
  ORDER BY ca.contributor_source_cd, val
  WITH nocounter, format, append
 ;end select
 CALL echorecord(requestin,"cvatestfile2")
 SELECT INTO "cvatestfullout.csv"
  ca.alias, ca.code_value, code = uar_get_code_display(ca.contributor_source_cd),
  d = uar_get_code_display(ca.code_value), ca2.alias, ca2.code_value,
  code2 = uar_get_code_display(ca2.contributor_source_cd), d = uar_get_code_display(ca2.code_value)
  FROM (dummyt d  WITH seq = size(requestin->list_0,5)),
   code_value_alias ca,
   code_value_alias ca2
  PLAN (d)
   JOIN (ca
   WHERE ca.alias=trim(cnvtstring(requestin->list_0[d.seq].lab_test_code),3)
    AND ca.code_set=200)
   JOIN (ca2
   WHERE ca2.alias=outerjoin(trim(cnvtstring(requestin->list_0[d.seq].result_code),3))
    AND ca2.code_set=outerjoin(72))
  ORDER BY ca.alias, ca2.alias
  WITH nocounter, separator = " ", format,
   pcformat('"',","), append, time = 15
 ;end select
END GO
