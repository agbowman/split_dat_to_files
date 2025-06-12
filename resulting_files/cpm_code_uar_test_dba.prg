CREATE PROGRAM cpm_code_uar_test:dba
 DECLARE validcodevalue = f8 WITH noconstant(0.0)
 DECLARE invalidcodevalue = f8 WITH constant(99999.0)
 DECLARE validcodeset = i4 WITH noconstant(0)
 DECLARE invalidcodeset = i4 WITH constant(99999)
 DECLARE validmeaning = vc WITH noconstant("")
 DECLARE invalidmeaning = vc WITH constant("BOGUS")
 DECLARE multimeaningset = i4 WITH noconstant(0)
 DECLARE multimeaning = vc WITH noconstant("")
 DECLARE emptymeaningset = i4 WITH noconstant(0)
 DECLARE emptymeaning = vc WITH constant(" ")
 DECLARE uniquemeaning = vc WITH noconstant("")
 DECLARE uniquemeaningset = i4 WITH noconstant(0)
 DECLARE validcki = vc WITH noconstant("")
 DECLARE invalidcki = vc WITH constant("BOGUS.CKI")
 DECLARE validdisplay = vc WITH noconstant("")
 DECLARE multidisplayset = i4 WITH noconstant(0)
 DECLARE multidisplay = vc WITH noconstant("")
 DECLARE uniquedisplayset = i4 WITH noconstant(0)
 DECLARE uniquedisplay = vc WITH noconstant("")
 DECLARE uniquedisplaykey = vc WITH noconstant("")
 DECLARE validdisplaykey = vc WITH noconstant("")
 DECLARE multidisplaykey = vc WITH noconstant("")
 DECLARE validdesc = vc WITH noconstant("")
 DECLARE multidescset = i4 WITH noconstant(0)
 DECLARE multidesc = vc WITH noconstant("")
 DECLARE uniquedesc = vc WITH noconstant("")
 DECLARE uniquedescset = i4 WITH noconstant(0)
 DECLARE bydisplay = vc WITH constant("DISPLAY")
 DECLARE bydisplaykey = vc WITH constant("DISPLAYKEY")
 DECLARE bydisplay_key = vc WITH constant("DISPLAY_KEY")
 DECLARE bydescription = vc WITH constant("DESCRIPTION")
 DECLARE bymeaning = vc WITH constant("MEANING")
 DECLARE validconceptset = i4 WITH noconstant(0)
 DECLARE validconceptvalue = f8 WITH noconstant(0.0)
 DECLARE invalidconceptvalue = f8 WITH constant(99999.0)
 DECLARE validconceptcki = vc WITH noconstant("")
 DECLARE invalidconceptcki = vc WITH constant("BOGUS.CONCEPTCKI")
 DECLARE validdefvalue = f8 WITH noconstant(0.0)
 DECLARE invaliddefvalue = f8 WITH constant(99999.0)
 DECLARE validdispkeyvalue = f8 WITH noconstant(0.0)
 DECLARE invaliddispkeyvalue = f8 WITH constant(99999.0)
 DECLARE codelist[20] = f8
 DECLARE occur = i4 WITH noconstant(1)
 DECLARE remain = i4 WITH noconstant(0)
 DECLARE index = i4 WITH noconstant(1)
 DECLARE status = i4 WITH noconstant(0)
 DECLARE display = c40
 DECLARE meaning = c12
 DECLARE description = c60
 DECLARE cki = c63
 DECLARE codeset = i4 WITH noconstant(0)
 DECLARE codevalue = f8 WITH noconstant(0.0)
 DECLARE indexhold = i4 WITH noconstant(0)
 DECLARE indexloop = i4 WITH noconstant(0)
 SUBROUTINE resetglobals(void)
   SET occur = 20
   SET remain = 0
   SET index = 1
   SET status = 0
   SET display = fillstring(40," ")
   SET meaning = fillstring(12," ")
   SET description = fillstring(60," ")
   SET cki = fillstring(63," ")
   SET codeset = 0
   SET codevalue = 0.0
 END ;Subroutine
 CALL echo("Retrieving common values to test with...")
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE trim(cv.cdf_meaning) != ""
   AND trim(cv.display) != ""
   AND trim(cv.description) != ""
   AND trim(cv.cki) != ""
   AND cv.collation_seq > 0
   AND cv.code_set > 0
   AND cv.code_value > 0
   AND cv.active_ind=1
   AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   validcodevalue = cv.code_value, validcodeset = cv.code_set, validmeaning = cv.cdf_meaning,
   validcki = cv.cki, validdisplay = cv.display, validdisplaykey = cv.display_key,
   validdesc = cv.description
  WITH maxrec = 1, nocounter
 ;end select
 CALL echo("Retrieving cdf meaning values to test with...")
 DECLARE meaningfound = i2 WITH noconstant(0)
 DECLARE uniquemeaningfound = i2 WITH noconstant(0)
 DECLARE prevmeaning = vc WITH noconstant("")
 DECLARE prevprevmeaning = vc WITH noconstant("")
 DECLARE curmeaning = vc WITH noconstant("")
 DECLARE prevset = i4 WITH noconstant(0)
 DECLARE curset = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE trim(cv.cdf_meaning) != ""
   AND cv.code_set > 0
   AND cv.code_value > 0
   AND cv.active_ind=1
   AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  ORDER BY cv.code_set, cv.cdf_meaning DESC
  DETAIL
   prevprevmeaning = prevmeaning, prevmeaning = curmeaning, curmeaning = cv.cdf_meaning,
   prevset = curset, curset = cv.code_set
   IF (uniquemeaningfound=0
    AND prevprevmeaning != "")
    IF (prevprevmeaning != prevmeaning
     AND prevmeaning != curmeaning)
     uniquemeaningfound = 1, uniquemeaning = prevmeaning, uniquemeaningset = prevset
    ENDIF
   ENDIF
   IF (meaningfound=0)
    IF (cv.cdf_meaning=multimeaning)
     meaningfound = 1
    ELSE
     multimeaning = cv.cdf_meaning, multimeaningset = cv.code_set
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv.code_set
  FROM code_value cv
  WHERE trim(cv.cdf_meaning)=""
   AND cv.code_set > 0
   AND cv.code_value > 0
   AND cv.active_ind=1
   AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   emptymeaningset = cv.code_set
  WITH maxrec = 1, nocounter
 ;end select
 CALL echo("Retrieving display values to test with...")
 DECLARE displayfound = i2 WITH noconstant(0)
 DECLARE uniquedisplayfound = i2 WITH noconstant(0)
 DECLARE prevprevdisplay = vc WITH noconstant("")
 DECLARE prevdisplay = vc WITH noconstant("")
 DECLARE curdisplay = vc WITH noconstant("")
 DECLARE prevdisplaykey = vc WITH noconstant("")
 DECLARE curdisplaykey = vc WITH noconstant("")
 SET prevset = 0
 SET curset = 0
 SELECT INTO "nl:"
  cv.display
  FROM code_value cv
  WHERE trim(cv.display) != ""
   AND cv.code_set > 0
   AND cv.code_value > 0
   AND cv.active_ind=1
   AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  ORDER BY cv.code_set, cv.display DESC
  DETAIL
   prevprevdisplay = prevdisplay, prevdisplay = curdisplay, curdisplay = cv.display,
   prevdisplaykey = curdisplaykey, curdisplaykey = cv.display_key, prevset = curset,
   curset = cv.code_set
   IF (uniquedisplayfound=0
    AND prevprevdisplay != "")
    IF (prevprevdisplay != prevdisplay
     AND prevdisplay != curdisplay)
     uniquedisplayfound = 1, uniquedisplay = prevdisplay, uniquedisplayset = prevset,
     uniquedisplaykey = prevdisplaykey
    ENDIF
   ENDIF
   IF (displayfound=0)
    IF (cv.display=multidisplay)
     displayfound = 1
    ELSE
     multidisplay = cv.display, multidisplayset = cv.code_set, multidisplaykey = cv.display_key
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("Retrieving description values to test with...")
 DECLARE descfound = i2 WITH noconstant(0)
 DECLARE uniquedescfound = i2 WITH noconstant(0)
 DECLARE prevprevdesc = vc WITH noconstant("")
 DECLARE prevdesc = vc WITH noconstant("")
 DECLARE curdesc = vc WITH noconstant("")
 SET prevset = 0
 SET curset = 0
 SELECT INTO "nl:"
  cv.description
  FROM code_value cv
  WHERE trim(cv.description) != ""
   AND cv.code_set > 0
   AND cv.code_value > 0
   AND cv.active_ind=1
   AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  ORDER BY cv.code_set, cv.description DESC
  DETAIL
   prevprevdesc = prevdesc, prevdesc = curdesc, curdesc = cv.description,
   prevset = curset, curset = cv.code_set
   IF (uniquedescfound=0
    AND prevprevdesc != "")
    IF (prevprevdesc != prevdesc
     AND prevdesc != curdesc)
     uniquedescfound = 1, uniquedesc = prevdesc, uniquedescset = prevset
    ENDIF
   ENDIF
   IF (descfound=0)
    IF (cv.description=multidesc)
     descfound = 1
    ELSE
     multidesc = cv.description, multidescset = cv.code_set
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("Retrieving concept cki values to test with...")
 DECLARE conceptckifound = i2 WITH noconstant(0)
 SELECT INTO "nl:"
  cv.code_set, cv.code_value, cv.concept_cki
  FROM code_value cv
  WHERE trim(cv.concept_cki) != ""
   AND cv.code_set > 0
   AND cv.code_value > 0
   AND cv.active_ind=1
   AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  ORDER BY cv.concept_cki DESC
  DETAIL
   IF (conceptckifound=0)
    IF (cv.concept_cki=validconceptcki)
     conceptckifound = 1
    ELSE
     validconceptset = cv.code_set, validconceptvalue = cv.code_value, validconceptcki = cv
     .concept_cki
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("Retrieving definition values to test with...")
 DECLARE definitionfound = i2 WITH noconstant(0)
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE trim(cv.definition) != ""
   AND cv.code_set > 0
   AND cv.code_value > 0.0
   AND cv.active_ind=1
   AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  ORDER BY cv.definition DESC
  DETAIL
   IF (definitionfound=0)
    validdefvalue = cv.code_value, definitionfound = 1
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("Retrieving display key values to test with...")
 DECLARE displaykeyfound = i2 WITH noconstant(0)
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE trim(cv.display_key) != ""
   AND cv.code_set > 0
   AND cv.code_value > 0.0
   AND cv.active_ind=1
   AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  ORDER BY cv.display_key DESC
  DETAIL
   IF (displaykeyfound=0)
    validdispkeyvalue = cv.code_value, displaykeyfound = 1
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("***************************************************")
 CALL echo("uar_get_code...")
 CALL resetglobals(0)
 SET status = uar_get_code(validcodevalue,display,meaning,description)
 CALL echo(build("  Test with VALID code value..",validcodevalue))
 CALL echo(build("    status.......",status))
 CALL echo(build("    display......",display))
 CALL echo(build("    meaning......",meaning))
 CALL echo(build("    description..",description))
 CALL resetglobals(0)
 SET status = uar_get_code(invalidcodevalue,display,meaning,description)
 CALL echo(build("  Test with INVALID code value..",invalidcodevalue))
 CALL echo(build("    status.......",status))
 CALL echo(build("    display......",display))
 CALL echo(build("    meaning......",meaning))
 CALL echo(build("    description..",description))
 CALL resetglobals(0)
 SET status = uar_get_code(0.0,display,meaning,description)
 CALL echo("  Test with ZERO code value")
 CALL echo(build("    status.......",status))
 CALL echo(build("    display......",display))
 CALL echo(build("    meaning......",meaning))
 CALL echo(build("    description..",description))
 CALL echo("***************************************************")
 CALL echo("uar_get_code2...")
 CALL resetglobals(0)
 SET status = uar_get_code2(validcodevalue,display,meaning,description,cki,
  codeset)
 CALL echo(build("  Test with VALID code value..",validcodevalue))
 CALL echo(build("    status.......",status))
 CALL echo(build("    display......",display))
 CALL echo(build("    meaning......",meaning))
 CALL echo(build("    description..",description))
 CALL echo(build("    cki..........",cki))
 CALL echo(build("    codeset......",codeset))
 CALL resetglobals(0)
 SET status = uar_get_code2(invalidcodevalue,display,meaning,description,cki,
  codeset)
 CALL echo(build("  Test with INVALID code value..",invalidcodevalue))
 CALL echo(build("    status.......",status))
 CALL echo(build("    display......",display))
 CALL echo(build("    meaning......",meaning))
 CALL echo(build("    description..",description))
 CALL echo(build("    cki..........",cki))
 CALL echo(build("    codeset......",codeset))
 CALL resetglobals(0)
 SET status = uar_get_code2(0.0,display,meaning,description,cki,
  codeset)
 CALL echo("  Test with ZERO code value")
 CALL echo(build("    status.......",status))
 CALL echo(build("    display......",display))
 CALL echo(build("    meaning......",meaning))
 CALL echo(build("    description..",description))
 CALL echo(build("    cki..........",cki))
 CALL echo(build("    codeset......",codeset))
 CALL resetglobals(0)
 CALL echo("***************************************************")
 CALL echo("uar_get_code_set...")
 CALL echo(build("  Test with VALID code value..",validcodevalue))
 CALL echo(build("    code set..",uar_get_code_set(validcodevalue)))
 CALL echo(build("  Test with INVALID code value..",invalidcodevalue))
 CALL echo(build("    code set..",uar_get_code_set(invalidcodevalue)))
 CALL echo("  Test with ZERO code value")
 CALL echo(build("    code set..",uar_get_code_set(0.0)))
 CALL resetglobals(0)
 CALL echo("***************************************************")
 CALL echo("uar_get_code_meaning...")
 CALL echo(build("  Test with VALID code value..",validcodevalue))
 CALL echo(build("    meaning..",uar_get_code_meaning(validcodevalue)))
 CALL echo(build("  Test with INVALID code value..",invalidcodevalue))
 CALL echo(build("    meaning..",uar_get_code_meaning(invalidcodevalue)))
 CALL echo("  Test with ZERO code value")
 CALL echo(build("    meaning..",uar_get_code_meaning(0.0)))
 CALL resetglobals(0)
 CALL echo("***************************************************")
 CALL echo("uar_get_code_display...")
 CALL echo(build("  Test with VALID code value..",validcodevalue))
 CALL echo(build("    display..",uar_get_code_display(validcodevalue)))
 CALL echo(build("  Test with INVALID code value..",invalidcodevalue))
 CALL echo(build("    display..",uar_get_code_display(invalidcodevalue)))
 CALL echo("  Test with ZERO code value")
 CALL echo(build("    display..",uar_get_code_display(0.0)))
 CALL resetglobals(0)
 CALL echo("***************************************************")
 CALL echo("uar_get_code_description...")
 CALL echo(build("  Test with VALID code value..",validcodevalue))
 CALL echo(build("    description..",uar_get_code_description(validcodevalue)))
 CALL echo(build("  Test with INVALID code value..",invalidcodevalue))
 CALL echo(build("    description..",uar_get_code_description(invalidcodevalue)))
 CALL echo("  Test with ZERO code value")
 CALL echo(build("    description..",uar_get_code_description(0.0)))
 CALL resetglobals(0)
 CALL echo("***************************************************")
 CALL echo("uar_get_code_cki...")
 CALL echo(build("  Test with VALID code value..",validcodevalue))
 CALL echo(build("    cki..",uar_get_code_cki(validcodevalue)))
 CALL echo(build("  Test with INVALID code value..",invalidcodevalue))
 CALL echo(build("    cki..",uar_get_code_cki(invalidcodevalue)))
 CALL echo("  Test with ZERO code value")
 CALL echo(build("    cki..",uar_get_code_cki(0.0)))
 CALL resetglobals(0)
 CALL echo("***************************************************")
 CALL echo("uar_get_collation_seq...")
 CALL echo(build("  Test with VALID code value..",validcodevalue))
 CALL echo(build("    collation_seq..",uar_get_collation_seq(validcodevalue)))
 CALL echo(build("  Test with INVALID code value..",invalidcodevalue))
 CALL echo(build("    collation_seq..",uar_get_collation_seq(invalidcodevalue)))
 CALL echo("  Test with ZERO code value")
 CALL echo(build("    collation_seq..",uar_get_collation_seq(0.0)))
 CALL resetglobals(0)
 CALL echo("***************************************************")
 CALL echo("uar_get_meaning_by_codeset...")
 SET status = uar_get_meaning_by_codeset(invalidcodeset,nullterm(invalidmeaning),index,codevalue)
 CALL echo(build("  Test with INVALID code set..",invalidcodeset))
 CALL echo(build("    status......",status))
 CALL echo(build("    code value..",codevalue))
 CALL echo(build("    index.......",index))
 CALL resetglobals(0)
 SET status = uar_get_meaning_by_codeset(0,nullterm(invalidmeaning),index,codevalue)
 CALL echo("  Test with ZERO code set")
 CALL echo(build("    status......",status))
 CALL echo(build("    code value..",codevalue))
 CALL echo(build("    index.......",index))
 CALL resetglobals(0)
 SET index = 0
 SET status = uar_get_meaning_by_codeset(uniquemeaningset,nullterm(uniquemeaning),index,codevalue)
 CALL echo("  Test with ZERO index")
 CALL echo(build("    status......",status))
 CALL echo(build("    code value..",codevalue))
 CALL echo(build("    index.......",index))
 CALL resetglobals(0)
 SET status = uar_get_meaning_by_codeset(uniquemeaningset,nullterm(invalidmeaning),index,codevalue)
 CALL echo(build("  Test with VALID code set and INVALID meaning..",uniquemeaningset,"-",
   invalidmeaning))
 CALL echo(build("    status......",status))
 CALL echo(build("    code value..",codevalue))
 CALL echo(build("    index.......",index))
 CALL resetglobals(0)
 SET status = uar_get_meaning_by_codeset(uniquemeaningset,nullterm(uniquemeaning),index,codevalue)
 CALL echo(build("  Test with VALID code set and VALID meaning..",uniquemeaningset,"-",uniquemeaning)
  )
 CALL echo(build("    status......",status))
 CALL echo(build("    code value..",codevalue))
 CALL echo(build("    index.......",index))
 CALL resetglobals(0)
 SET status = uar_get_meaning_by_codeset(multimeaningset,nullterm(multimeaning),index,codevalue)
 CALL echo(build("  Test with multiple values for one meaning..",multimeaningset,"-",multimeaning,
   "-1"))
 CALL echo(build("    status......",status))
 CALL echo(build("    code value..",codevalue))
 CALL echo(build("    index.......",index))
 SET indexhold = index
 FOR (indexloop = 2 TO indexhold)
   CALL resetglobals(0)
   SET index = indexloop
   SET status = uar_get_meaning_by_codeset(multimeaningset,nullterm(multimeaning),index,codevalue)
   CALL echo(build("  Test with multiple values for one meaning..",multimeaningset,"-",multimeaning,
     "-",
     indexloop))
   CALL echo(build("    status......",status))
   CALL echo(build("    code value..",codevalue))
   CALL echo(build("    index.......",index))
 ENDFOR
 CALL resetglobals(0)
 SET index = (indexhold+ 1)
 SET status = uar_get_meaning_by_codeset(multimeaningset,nullterm(multimeaning),index,codevalue)
 CALL echo(build("  Test with index greater than number of values..",multimeaningset,"-",multimeaning
   ))
 CALL echo(build("    status......",status))
 CALL echo(build("    code value..",codevalue))
 CALL echo(build("    index.......",index))
 CALL resetglobals(0)
 SET status = uar_get_meaning_by_codeset(emptymeaningset,nullterm(emptymeaning),index,codevalue)
 CALL echo(build("  Test with an empty meaning..",emptymeaningset))
 CALL echo(build("    status......",status))
 CALL echo(build("    code value..",codevalue))
 CALL echo(build("    index.......",index))
 CALL resetglobals(0)
 CALL echo("***************************************************")
 CALL echo("uar_get_code_by_cki...")
 CALL echo(build("  Test with VALID cki..",validcki))
 CALL echo(build("    code value..",uar_get_code_by_cki(nullterm(validcki))))
 CALL echo(build("  Test with INVALID cki..",invalidcki))
 CALL echo(build("    code value..",uar_get_code_by_cki(nullterm(invalidcki))))
 CALL resetglobals(0)
 CALL echo("***************************************************")
 CALL echo("uar_get_code_list_by_display...")
 SET status = uar_get_code_list_by_display(uniquedisplayset,nullterm(uniquedisplay),index,occur,
  remain,
  codelist)
 CALL echo(build("  Test with VALID code set and VALID display..",uniquedisplayset,"-",uniquedisplay)
  )
 CALL echo(build("    status....",status))
 CALL echo(build("    occur.....",occur))
 CALL echo(build("    remain....",remain))
 FOR (indexloop = 1 TO occur)
   CALL echo(build("    value.....",codelist[indexloop]))
 ENDFOR
 CALL resetglobals(0)
 SET status = uar_get_code_list_by_display(multidisplayset,nullterm(multidisplay),index,occur,remain,
  codelist)
 CALL echo(build("  Test multiple values for display..",multidisplayset,"-",multidisplay))
 CALL echo(build("    status....",status))
 CALL echo(build("    occur.....",occur))
 CALL echo(build("    remain....",remain))
 FOR (indexloop = 1 TO occur)
   CALL echo(build("    value.....",codelist[indexloop]))
 ENDFOR
 CALL resetglobals(0)
 CALL echo("***************************************************")
 CALL echo("uar_get_code_list_by_dispkey...")
 SET status = uar_get_code_list_by_dispkey(uniquedisplayset,nullterm(uniquedisplaykey),index,occur,
  remain,
  codelist)
 CALL echo(build("  Test with VALID code set and VALID display key..",uniquedisplayset,"-",
   uniquedisplaykey))
 CALL echo(build("    status....",status))
 CALL echo(build("    occur.....",occur))
 CALL echo(build("    remain....",remain))
 FOR (indexloop = 1 TO occur)
   CALL echo(build("    value.....",codelist[indexloop]))
 ENDFOR
 CALL resetglobals(0)
 SET status = uar_get_code_list_by_dispkey(multidisplayset,nullterm(multidisplaykey),index,occur,
  remain,
  codelist)
 CALL echo(build("  Test multiple values for display key..",multidisplayset,"-",multidisplaykey))
 CALL echo(build("    status....",status))
 CALL echo(build("    occur.....",occur))
 CALL echo(build("    remain....",remain))
 FOR (indexloop = 1 TO occur)
   CALL echo(build("    value.....",codelist[indexloop]))
 ENDFOR
 CALL resetglobals(0)
 CALL echo("***************************************************")
 CALL echo("uar_get_code_list_by_descr...")
 SET status = uar_get_code_list_by_descr(uniquedescset,nullterm(uniquedesc),index,occur,remain,
  codelist)
 CALL echo(build("  Test with VALID code set and VALID description..",uniquedescset,"-",uniquedesc))
 CALL echo(build("    status....",status))
 CALL echo(build("    occur.....",occur))
 CALL echo(build("    remain....",remain))
 FOR (indexloop = 1 TO occur)
   CALL echo(build("    value.....",codelist[indexloop]))
 ENDFOR
 CALL resetglobals(0)
 SET status = uar_get_code_list_by_descr(multidescset,nullterm(multidesc),index,occur,remain,
  codelist)
 CALL echo(build("  Test multiple values for description..",multidescset,"-",multidesc))
 CALL echo(build("    status....",status))
 CALL echo(build("    occur.....",occur))
 CALL echo(build("    remain....",remain))
 FOR (indexloop = 1 TO occur)
   CALL echo(build("    value.....",codelist[indexloop]))
 ENDFOR
 CALL resetglobals(0)
 CALL echo("***************************************************")
 CALL echo("uar_get_code_list_by_meaning...")
 SET status = uar_get_code_list_by_meaning(uniquemeaningset,nullterm(uniquemeaning),index,occur,
  remain,
  codelist)
 CALL echo(build("  Test with VALID code set and VALID meaning..",uniquemeaningset,"-",uniquemeaning)
  )
 CALL echo(build("    status....",status))
 CALL echo(build("    occur.....",occur))
 CALL echo(build("    remain....",remain))
 FOR (indexloop = 1 TO occur)
   CALL echo(build("    value.....",codelist[indexloop]))
 ENDFOR
 CALL resetglobals(0)
 SET status = uar_get_code_list_by_meaning(multimeaningset,nullterm(multimeaning),index,occur,remain,
  codelist)
 CALL echo(build("  Test multiple values for meaning..",multimeaningset,"-",multimeaning))
 CALL echo(build("    status....",status))
 CALL echo(build("    occur.....",occur))
 CALL echo(build("    remain....",remain))
 FOR (indexloop = 1 TO occur)
   CALL echo(build("    value.....",codelist[indexloop]))
 ENDFOR
 CALL resetglobals(0)
 CALL echo("***************************************************")
 CALL echo("uar_get_code_by...display")
 CALL echo(build("  Test VALID code set and VALID display..",uniquedisplayset,"-",uniquedisplay))
 CALL echo(build("    code value..",uar_get_code_by(nullterm(bydisplay),uniquedisplayset,nullterm(
     uniquedisplay))))
 CALL echo(build("  Test VALID code set and INVALID display..",validcodeset,"-",invalidmeaning))
 CALL echo(build("    code value..",uar_get_code_by(nullterm(bydisplay),validcodeset,nullterm(
     invalidmeaning))))
 CALL echo(build("  Test INVALID code set and VALID display..",invalidcodeset,"-",validdisplay))
 CALL echo(build("    code value..",uar_get_code_by(nullterm(bydisplay),invalidcodeset,nullterm(
     validdisplay))))
 CALL echo(build("  Test multiple values with the same display..",multidisplayset,"-",multidisplay))
 CALL echo(build("    code value..",uar_get_code_by(nullterm(bydisplay),multidisplayset,nullterm(
     multidisplay))))
 CALL echo("  Test ZERO code set")
 CALL echo(build("    code value..",uar_get_code_by(nullterm(bydisplay),0,nullterm(validdisplay))))
 CALL resetglobals(0)
 CALL echo("***************************************************")
 CALL echo("uar_get_code_by...displaykey")
 CALL echo(build("  Test VALID code set and VALID display key..",uniquedisplayset,"-",
   uniquedisplaykey))
 CALL echo(build("    code value..",uar_get_code_by(nullterm(bydisplaykey),uniquedisplayset,nullterm(
     uniquedisplaykey))))
 CALL echo(build("  Test VALID code set and INVALID display key..",validcodeset,"-",invalidmeaning))
 CALL echo(build("    code value..",uar_get_code_by(nullterm(bydisplaykey),validcodeset,nullterm(
     invalidmeaning))))
 CALL echo(build("  Test INVALID code set and VALID display key..",invalidcodeset,"-",validdisplaykey
   ))
 CALL echo(build("    code value..",uar_get_code_by(nullterm(bydisplaykey),invalidcodeset,nullterm(
     validdisplaykey))))
 CALL echo(build("  Test multiple values with the same display key..",multidisplayset,"-",
   multidisplaykey))
 CALL echo(build("    code value..",uar_get_code_by(nullterm(bydisplaykey),multidisplayset,nullterm(
     multidisplaykey))))
 CALL echo("  Test ZERO code set")
 CALL echo(build("    code value..",uar_get_code_by(nullterm(bydisplaykey),0,nullterm(validdisplaykey
     ))))
 CALL resetglobals(0)
 CALL echo("***************************************************")
 CALL echo("uar_get_code_by...display_key")
 CALL echo(build("  Test VALID code set and VALID display_key..",uniquedisplayset,"-",
   uniquedisplaykey))
 CALL echo(build("    code value..",uar_get_code_by(nullterm(bydisplay_key),uniquedisplayset,nullterm
    (uniquedisplaykey))))
 CALL echo(build("  Test VALID code set and INVALID display_key..",validcodeset,"-",invalidmeaning))
 CALL echo(build("    code value..",uar_get_code_by(nullterm(bydisplay_key),validcodeset,nullterm(
     invalidmeaning))))
 CALL echo(build("  Test INVALID code set and VALID display_key..",invalidcodeset,"-",validdisplaykey
   ))
 CALL echo(build("    code value..",uar_get_code_by(nullterm(bydisplay_key),invalidcodeset,nullterm(
     validdisplaykey))))
 CALL echo(build("  Test multiple values with the same display_key..",multidisplayset,"-",
   multidisplaykey))
 CALL echo(build("    code value..",uar_get_code_by(nullterm(bydisplay_key),multidisplayset,nullterm(
     multidisplaykey))))
 CALL echo("  Test ZERO code set")
 CALL echo(build("    code value..",uar_get_code_by(nullterm(bydisplay_key),0,nullterm(
     validdisplaykey))))
 CALL resetglobals(0)
 CALL echo("***************************************************")
 CALL echo("uar_get_code_by...description")
 CALL echo(build("  Test VALID code set and VALID description..",uniquedescset,"-",uniquedesc))
 CALL echo(build("    code value..",uar_get_code_by(nullterm(bydescription),uniquedescset,nullterm(
     uniquedesc))))
 CALL echo(build("  Test VALID code set and INVALID description..",validcodeset,"-",invalidmeaning))
 CALL echo(build("    code value..",uar_get_code_by(nullterm(bydescription),validcodeset,nullterm(
     invalidmeaning))))
 CALL echo(build("  Test INVALID code set and VALID description..",invalidcodeset,"-",validdesc))
 CALL echo(build("    code value..",uar_get_code_by(nullterm(bydescription),invalidcodeset,nullterm(
     validdesc))))
 CALL echo(build("  Test multiple values with the same description..",multidescset,"-",multidesc))
 CALL echo(build("    code value..",uar_get_code_by(nullterm(bydescription),multidescset,nullterm(
     multidesc))))
 CALL echo("  Test ZERO code set")
 CALL echo(build("    code value..",uar_get_code_by(nullterm(bydescription),0,nullterm(validdesc))))
 CALL resetglobals(0)
 CALL echo("***************************************************")
 CALL echo("uar_get_code_by...meaning")
 CALL echo(build("  Test VALID code set and VALID meaning..",uniquemeaningset,"-",uniquemeaning))
 CALL echo(build("    code value..",uar_get_code_by(nullterm(bymeaning),uniquemeaningset,nullterm(
     uniquemeaning))))
 CALL echo(build("  Test VALID code set and INVALID meaning..",uniquemeaningset,"-",invalidmeaning))
 CALL echo(build("    code value..",uar_get_code_by(nullterm(bymeaning),validcodeset,nullterm(
     invalidmeaning))))
 CALL echo(build("  Test INVALID code set and VALID meaning..",invalidcodeset,"-",validmeaning))
 CALL echo(build("    code value..",uar_get_code_by(nullterm(bymeaning),invalidcodeset,nullterm(
     validmeaning))))
 CALL echo(build("  Test multiple values with the same description..",multimeaningset,"-",
   multimeaning))
 CALL echo(build("    code value..",uar_get_code_by(nullterm(bymeaning),multimeaningset,nullterm(
     multimeaning))))
 CALL echo("  Test ZERO code set")
 CALL echo(build("    code value..",uar_get_code_by(nullterm(bymeaning),0,nullterm(validmeaning))))
 CALL resetglobals(0)
 CALL echo("***************************************************")
 CALL echo("uar_get_code_by...bogus")
 CALL echo(build("    code_value..",uar_get_code_by(nullterm(invalidmeaning),validcodeset,nullterm(
     validmeaning))))
 CALL echo("***************************************************")
 CALL echo("uar_get_conceptcki...")
 CALL echo(build("  Test with VALID code value..",validconceptvalue))
 CALL echo(build("    conceptcki..",uar_get_conceptcki(validconceptvalue)))
 CALL echo(build("  Test with INVALID code value..",invalidconceptvalue))
 CALL echo(build("    conceptcki..",uar_get_conceptcki(invalidconceptvalue)))
 CALL echo("  Test with ZERO code value")
 CALL echo(build("    conceptcki..",uar_get_conceptcki(0.0)))
 CALL echo("***************************************************")
 CALL echo("uar_get_code_list_by_conceptcki...")
 CALL resetglobals(0)
 SET status = uar_get_code_list_by_conceptcki(validconceptset,nullterm(validconceptcki),index,occur,
  remain,
  codelist)
 CALL echo(build("  Test with VALID concept cki..",validconceptcki))
 CALL echo(build("    status....",status))
 CALL echo(build("    occur.....",occur))
 CALL echo(build("    remain....",remain))
 FOR (indexloop = 1 TO occur)
   CALL echo(build("    value.....",codelist[indexloop]))
 ENDFOR
 CALL resetglobals(0)
 SET status = uar_get_code_list_by_conceptcki(validconceptset,nullterm(invalidconceptcki),index,occur,
  remain,
  codelist)
 CALL echo(build("  Test with INVALID concept cki..",invalidconceptcki))
 CALL echo(build("    status....",status))
 CALL echo(build("    occur.....",occur))
 CALL echo(build("    remain....",remain))
 FOR (indexloop = 1 TO occur)
   CALL echo(build("    value.....",codelist[indexloop]))
 ENDFOR
 CALL echo("***************************************************")
 CALL echo("uar_get_definition...")
 CALL echo(build("  Test with VALID code value..",validdefvalue))
 CALL echo(build("    definition..",uar_get_definition(validdefvalue)))
 CALL echo(build("  Test with INVALID code value..",invaliddefvalue))
 CALL echo(build("    definition..",uar_get_definition(invaliddefvalue)))
 CALL echo("  Test with ZERO code value")
 CALL echo(build("    definition..",uar_get_definition(0.0)))
 CALL echo("***************************************************")
 CALL echo("uar_get_displaykey..")
 CALL echo(build("  Test with VALID code value..",validdispkeyvalue))
 CALL echo(build("    displaykey..",uar_get_displaykey(validdispkeyvalue)))
 CALL echo(build("  Test with INVALID code value..",invaliddispkeyvalue))
 CALL echo(build("    displaykey..",uar_get_displaykey(invaliddispkeyvalue)))
 CALL echo("  Test with ZERO code value")
 CALL echo(build("    displaykey..",uar_get_displaykey(0.0)))
END GO
