CREATE PROGRAM cps_add_nomen_from_codeset
 PAINT
 CALL clear(1,1)
 CALL video(i)
 CALL box(2,2,23,79)
 CALL line(4,2,78,xhor)
 CALL video(n)
 CALL text(3,5,"L O A D   N O M E N C L A T U R E   F R O M   C O D E S E T")
 CALL text(6,5,"CODESET NUMBER")
 CALL text(8,5,"SOURCE VOCABULARY")
 CALL text(10,5,"PRINCIPLE TYPE")
 SET home = correct
 SET codeset = 0
 SET source_vocabulary_cd = 0.0
 SET source_vocabulary_mean = fillstring(12," ")
 SET principle_type_cd = 0.0
 SET principle_type_mean = fillstring(12," ")
 SET doc = off
#accept_codeset
 CALL clear(06,30,30)
 CALL clear(24,02,35)
 SET help =
 SELECT INTO "NL:"
  c.code_set, c.display
  FROM code_value_set c
  WHERE c.code_set >= curaccept
   AND c.code_set > 0
  ORDER BY c.code_set
  WITH nocounter
 ;end select
 SET help = promptmsg("  Enter Codeset here: ")
 SET help = pos(5,5,2)
 CALL text(24,03,"HELP available")
 CALL accept(06,30,"###########;PN")
 IF (curaccept=0)
  GO TO accept_codeset
 ELSE
  SET code_display = fillstring(30," ")
  SET codeset = curaccept
  SELECT INTO "NL:"
   c.code_set, c.display
   FROM code_value_set c
   WHERE c.code_set=curaccept
   DETAIL
    code_display = c.display
   WITH nocounter, maxqual(c,1)
  ;end select
  IF (curqual <= 0)
   GO TO accept_codeset
  ENDIF
  CALL text(06,30,format(cnvtstring(codeset),"###########;c"))
  CALL text(06,40,code_display)
 ENDIF
#accept_source_vocabulary
 CALL clear(08,30,30)
 CALL clear(24,02,35)
 SET help =
 SELECT INTO "NL:"
  c.code_value, c.display
  FROM code_value c
  WHERE c.code_set=400
   AND c.code_value > 0
   AND cnvtupper(c.display) >= cnvtupper(cnvtstring(curaccept))
   AND c.cdf_meaning > " "
   AND c.display > " "
  ORDER BY c.display
  WITH nocounter
 ;end select
 SET help = promptmsg("  Enter Vocabulary Description here: ")
 SET help = pos(5,5,2)
 CALL text(24,03,"HELP available")
 CALL accept(08,30,"PPPPPPPPPPPPPP;CUFP")
 IF (curaccept=" ")
  GO TO accept_source_vocabulary
 ELSE
  SET source_display = fillstring(30," ")
  SET source_vocabulary_cd = cnvtint(curaccept)
  SELECT INTO "NL"
   FROM code_value c
   WHERE c.code_set=400
    AND c.code_value=source_vocabulary_cd
   DETAIL
    source_display = c.display, source_vocabulary_mean = c.cdf_meaning
   WITH nocounter
  ;end select
  IF (curqual <= 0)
   GO TO accept_source_vocabulary
  ENDIF
  CALL text(08,30,cnvtstring(source_vocabulary_cd))
  CALL text(08,40,source_display)
 ENDIF
#accept_principle_type
 CALL clear(10,30,30)
 CALL clear(24,02,35)
 SET help =
 SELECT INTO "NL:"
  code = c.code_value, principle_type = c.display
  FROM code_value c
  WHERE c.code_set=401
   AND c.code_value > 0
   AND cnvtupper(c.display) >= cnvtupper(cnvtstring(curaccept))
   AND c.cdf_meaning > " "
   AND c.display > " "
  ORDER BY c.display
  WITH nocounter
 ;end select
 CALL text(24,03,"HELP available")
 SET help = promptmsg("  Enter Principle Type Description here: ")
 SET help = pos(5,5,2)
 CALL text(24,03,"HELP available")
 CALL accept(10,30,"PPPPPPPPPPPPPP;FPCU")
 IF (curaccept=" ")
  GO TO accept_principle_type
 ELSE
  SET principle_display = fillstring(30," ")
  SET principle_type_cd = cnvtint(curaccept)
  SELECT INTO "NL"
   FROM code_value c
   WHERE c.code_set=401
    AND c.code_value=principle_type_cd
   DETAIL
    principle_display = c.display, principle_type_mean = c.cdf_meaning
   WITH nocounter
  ;end select
  IF (curqual <= 0)
   GO TO accept_principle_type
  ENDIF
  CALL text(10,30,cnvtstring(principle_type_cd))
  CALL text(10,40,principle_display)
  GO TO correct
 ENDIF
#correct
 CALL clear(24,00,65)
 SET accept = nochange
 CALL text(24,2,"CORRECT?")
 CALL accept(24,12,"A;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 CALL clear(24,1)
 IF (curaccept="N")
  SET accept = change
  GO TO accept_codeset
 ELSE
  CALL video(b)
  CALL text(22,55,"PROCESSING ... ")
  CALL video(n)
 ENDIF
#build_request
 RECORD requestin(
   1 list_0[*]
     2 principle_type_mean = vc
     2 active_status_mean = vc
     2 contributor_system_mean = vc
     2 source_string = vc
     2 source_identifier = vc
     2 string_identifier = vc
     2 string_status_mean = vc
     2 term_identifier = vc
     2 term_source_mean = vc
     2 language_mean = vc
     2 data_status_mean = vc
     2 short_string = vc
     2 mnemonic = vc
     2 concept_identifier = vc
     2 concept_source_mean = vc
     2 string_source_mean = vc
     2 source_vocabulary_mean = vc
 )
 SET stat = alterlist(requestin->list_0,50)
 SELECT INTO "NL:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=codeset
    AND c.display > " ")
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (count1 >= size(requestin->list_0,5))
    stat = alterlist(requestin->list_0,(count1+ 10))
   ENDIF
   requestin->list_0[count1].principle_type_mean = principle_type_mean, requestin->list_0[count1].
   contributor_system_mean = " ", requestin->list_0[count1].source_string = c.display,
   requestin->list_0[count1].source_identifier = cnvtstring(codeset), requestin->list_0[count1].
   string_identifier = " ", requestin->list_0[count1].string_status_mean = "ACTIVE",
   requestin->list_0[count1].term_identifier = " ", requestin->list_0[count1].term_source_mean = " ",
   requestin->list_0[count1].language_mean = "ENG",
   requestin->list_0[count1].data_status_mean = " ", requestin->list_0[count1].short_string =
   substring(1,60,c.display), requestin->list_0[count1].mnemonic = substring(1,25,c.display),
   requestin->list_0[count1].concept_identifier = " ", requestin->list_0[count1].concept_source_mean
    = " ", requestin->list_0[count1].string_source_mean = " ",
   requestin->list_0[count1].source_vocabulary_mean = source_vocabulary_mean
  FOOT REPORT
   stat = alterlist(requestin->list_0,count1)
  WITH check, nocounter
 ;end select
 EXECUTE cps_import_nomenclature
 CALL clear(22,55,15)
#load_another
 CALL clear(24,00,65)
 SET accept = nochange
 CALL text(24,2,"Would you like to load another codeset?")
 CALL accept(24,45,"A;CU","N"
  WHERE curaccept IN ("Y", "N"))
 CALL clear(24,1)
 IF (curaccept="N")
  GO TO exit_script
 ELSE
  CALL clear(06,30,30)
  CALL clear(08,30,30)
  CALL clear(10,30,30)
  SET accept = change
  GO TO accept_codeset
 ENDIF
#exit_script
END GO
