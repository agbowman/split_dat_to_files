CREATE PROGRAM dm_omf_groupings_import
 SET ret_grouping_cd = 0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.active_ind=cnvtint(requestin->list_0[1].active_ind)
   AND cv.code_set=13003
   AND (cv.cdf_meaning=requestin->list_0[1].group_type)
  DETAIL
   ret_grouping_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("Cdf meaning doesn't exist.")
  GO TO ext_prg
 ENDIF
 SET ret_grouping_status_cd = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=48
   AND cv.cdf_meaning="ACTIVE"
  DETAIL
   ret_grouping_status_cd = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("Code value doesn't exist.")
  GO TO ext_prg
 ENDIF
 SET ret_key2 = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE (cv.cdf_meaning=requestin->list_0[1].group_name)
   AND cv.code_set=14629
  DETAIL
   ret_key2 = cv.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("ICD-9 code value doesn't exist.")
  GO TO ext_prg
 ENDIF
 SET ret_code_value = 0.0
 SELECT INTO "nl:"
  xyz = seq(omf_groupings_seq,nextval)
  FROM dual
  DETAIL
   ret_code_value = cnvtreal(xyz)
  WITH nocounter
 ;end select
 FREE SET request
 RECORD request(
   1 omf_grouping_id = f8
   1 grouping_cd = f8
   1 key1 = c200
   1 key2 = c200
   1 valid_from_dt_tm = dq8
   1 valid_until_dt_tm = dq8
   1 grouping_status_cd = f8
 )
 SET request->omf_grouping_id = ret_code_value
 SET request->grouping_cd = ret_grouping_cd
 SET request->key1 = requestin->list_0[1].icd9_code
 SET request->key2 = cnvtstring(ret_key2)
 SET request->valid_from_dt_tm = cnvtdatetime(requestin->list_0[1].from_dt_tm)
 SET request->valid_until_dt_tm = cnvtdatetime(requestin->list_0[1].to_dt_tm)
 SET request->grouping_status_cd = ret_grouping_status_cd
 EXECUTE dm_omf_groupings
#ext_prg
END GO
