CREATE PROGRAM dm_code_value_alias_import:dba
 IF (size(requestin->list_0[1].cdf_meaning) > 12)
  SET cdf_meaning = substring(1,12,requestin->list_0[1].cdf_meaning)
 ELSE
  SET cdf_meaning = requestin->list_0[1].cdf_meaning
 ENDIF
 IF (size(requestin->list_0[1].display) > 40)
  SET display = substring(1,40,requestin->list_0[1].display)
 ELSE
  SET display = requestin->list_0[1].display
 ENDIF
 SELECT INTO "nl:"
  cs.*
  FROM code_value_set cs
  WHERE cs.code_set=cnvtint(requestin->list_0[1].code_set)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo(concat("Code set ",concat(cnvtstring(requestin->list_0[1].code_set)," does not exist.")))
  GO TO ext_prg
 ENDIF
 SET y = fillstring(255," ")
 SELECT INTO "nl:"
  d.seq
  FROM dummyt d
  DETAIL
   y = validate(requestin->list_0[1].cki,"N")
  WITH nocounter
 ;end select
 SET ret_code_value = 0.0
 SET valid_ind = 0
 IF (y != "N")
  SET cki = fillstring(255," ")
  SET cki = requestin->list_0[1].cki
  SELECT INTO "nl:"
   a.code_value
   FROM code_value a
   WHERE a.code_set=cnvtint(requestin->list_0[1].code_set)
    AND a.cki=cki
   DETAIL
    ret_code_value = a.code_value
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET valid_ind = 1
  ENDIF
 ENDIF
 IF (valid_ind=0)
  SET cdf_flag = 1
  SET display_key_flag = 1
  SET active_flag = 1
  SET display_flag = 1
  SELECT INTO "nl:"
   cvs.cdf_meaning_dup_ind, cvs.display_key_dup_ind, cvs.active_ind_dup_ind,
   cvs.display_dup_ind
   FROM code_value_set cvs
   WHERE cvs.code_set=cnvtint(requestin->list_0.code_set)
   DETAIL
    cdf_flag = cvs.cdf_meaning_dup_ind, display_key_flag = cvs.display_key_dup_ind, active_flag = cvs
    .active_ind_dup_ind,
    display_flag = cvs.display_dup_ind
   WITH nocounter
  ;end select
  SET line_buffer[20] = fillstring(132," ")
  SET line_buffer[1] = 'select into "nl:" cv.code_value'
  SET line_buffer[2] = " from code_value cv"
  SET line_buffer[3] = " where cv.code_set=cnvtint(requestin->list_0[1]->code_set)"
  SET line_num = 4
  IF (cdf_flag=1)
   SET line_buffer[line_num] = " and cv.cdf_meaning=cnvtupper(cdf_meaning)"
   SET line_num = (line_num+ 1)
  ENDIF
  IF (display_key_flag=1)
   SET line_buffer[line_num] = " and cv.display_key=trim(cnvtupper(display))"
   SET line_num = (line_num+ 1)
  ENDIF
  IF (active_flag=1)
   SET line_buffer[line_num] = " and cv.active_ind=cnvtint(requestin->list_0[1]->active_ind)"
   SET line_num = (line_num+ 1)
  ENDIF
  IF (display_flag=1)
   SET line_buffer[line_num] = " and cv.display=display"
   SET line_num = (line_num+ 1)
  ENDIF
  SET line_buffer[line_num] = " detail ret_code_value=cv.code_value"
  SET line_num = (line_num+ 1)
  SET line_buffer[line_num] = " with nocounter go"
  SET x = 1
  FOR (x = 1 TO line_num)
    CALL parser(line_buffer[x],1)
  ENDFOR
  IF (curqual=0)
   CALL echo("This code value does not exist.")
   GO TO ext_prg
  ELSEIF (curqual > 1)
   CALL echo("This code value is non-unique.")
   GO TO ext_prg
  ENDIF
 ENDIF
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
 IF (curqual=0)
  CALL echo("Contributor code does not exist")
  GO TO ext_prg
 ENDIF
 FREE SET dmrequest
 RECORD dmrequest(
   1 alias = c255
   1 code_set = i4
   1 contributor_source_cd = f8
   1 code_value = f8
   1 alias_type_meaning = c12
   1 primary_ind = i2
   1 cki = c255
   1 cdf_meaning = c15
   1 contributor_source_disp = vc
   1 display = c40
 )
 IF (y != "N")
  SET dmrequest->cki = requestin->list_0[1].cki
 ENDIF
 SET dmrequest->alias = requestin->list_0[1].alias
 SET dmrequest->code_set = cnvtint(requestin->list_0[1].code_set)
 SET dmrequest->cdf_meaning = cdf_meaning
 SET dmrequest->contributor_source_disp = requestin->list_0[1].contributor_source_disp
 SET dmrequest->contributor_source_cd = ret_contrib_cd
 SET dmrequest->code_value = ret_code_value
 SET dmrequest->display = display
 SET dmrequest->alias_type_meaning = requestin->list_0[1].alias_type_meaning
 SET dmrequest->primary_ind = cnvtint(requestin->list_0[1].primary_ind)
 EXECUTE dm_code_value_alias
 COMMIT
#ext_prg
END GO
