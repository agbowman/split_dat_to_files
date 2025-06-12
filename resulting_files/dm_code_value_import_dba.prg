CREATE PROGRAM dm_code_value_import:dba
 FREE SET dmrequest
 RECORD dmrequest(
   1 dup_rule_flag = i2
   1 code_set = f8
   1 code_value = f8
   1 cdf_meaning = c12
   1 cki = c255
   1 display = c40
   1 description = c60
   1 definition = c100
   1 collation_seq = i2
   1 active_ind = i2
   1 contributor_source_cd = f8
   1 alias = c255
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
 SELECT INTO "nl:"
  cvs.code_set
  FROM code_value_set cvs
  WHERE cvs.code_set=cnvtreal(requestin->list_0[1].code_set)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("Code set doesn't exist")
  GO TO end_prg
 ENDIF
 SET x = fillstring(255," ")
 SELECT INTO "nl:"
  d.seq
  FROM dummyt d
  DETAIL
   x = validate(requestin->list_0[1].cki,"N")
  WITH nocounter
 ;end select
 IF (x != "N")
  SET dmrequest->cki = requestin->list_0[1].cki
 ENDIF
 SET dmrequest->dup_rule_flag = 0
 SET dmrequest->code_set = cnvtreal(requestin->list_0[1].code_set)
 SET dmrequest->cdf_meaning = requestin->list_0[1].cdf_meaning
 SET dmrequest->display = requestin->list_0[1].display
 SET dmrequest->description = requestin->list_0[1].description
 SET dmrequest->definition = requestin->list_0[1].definition
 SET dmrequest->active_ind = cnvtint(requestin->list_0[1].active_ind)
 SET dmrequest->collation_seq = cnvtint(requestin->list_0[1].collation_seq)
 SET dmrequest->alias = requestin->list_0[1].alias
 SET dmrequest->contributor_source_cd = ret_contrib_cd
 EXECUTE dm_insert_code_value
#end_prg
END GO
