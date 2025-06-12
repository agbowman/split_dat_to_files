CREATE PROGRAM dm_dm_code_value_import:dba
 FREE SET request
 RECORD request(
   1 code_set = i4
   1 dm_mode = i2
   1 qual[1]
     2 code_value = f8
     2 cdf_meaning = c12
     2 display = c40
     2 display_key = c40
     2 description = vc
     2 definition = vc
     2 collation_seq = i4
     2 active_ind = i2
     2 authentic_ind = i2
     2 updt_cnt = i4
 )
 SET dup_rule_flag = 0
 SET code_set_val = 0.00
 SET cdf_meaning = "        "
 SET display = " "
 SET description = " "
 SET definition = " "
 SET active_ind = 0
 SET ret_contrib_cd = 0.00
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=73
   AND (cv.display=requestin->list_0[1].contributor_source_disp)
  DETAIL
   ret_contrib_cd = cv.code_value
  WITH nocounter
 ;end select
 SET request->dm_mode = 0
 SET request->code_set = cnvtreal(requestin->list_0[1].code_set)
 SET request->qual[1].cdf_meaning = requestin->list_0[1].cdf_meaning
 SET request->qual[1].display = requestin->list_0[1].display
 SET request->qual[1].description = requestin->list_0[1].description
 SET request->qual[1].definition = requestin->list_0[1].definition
 SET request->qual[1].active_ind = cnvtint(requestin->list_0[1].active_ind)
 SET request->qual[1].collation_seq = cnvtint(requestin->list_0[1].collation_seq)
 SET request->qual[1].authentic_ind = 1
 EXECUTE dm_dm_chg_code_value
END GO
