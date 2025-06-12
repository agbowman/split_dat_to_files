CREATE PROGRAM ccl_uar_codetest:dba
 PROMPT
  "Output device (MINE): " = "MINE",
  "Enter code set (optional): " = 0,
  "Enter code value (all): " = 0,
  "Enter mode (UAR/UAR_OCI): " = "UAR"
  WITH outdev, codeset, codevalue,
  uarmode
 DECLARE code_set = i4
 DECLARE code_value = f8
 DECLARE cdf_meaning = c12
 DECLARE resetglobals(cnt=i2) = null
 DECLARE init_uar_test(cnt=i4,code_set=i4,uarname=vc,key_value=vc) = null
 SET code_set =  $CODESET
 SET code_value =  $CODEVALUE
 SET uar_mode =  $UARMODE
 SET _line = fillstring(80,"=")
 SUBROUTINE resetglobals(cnt)
   SET occurs = 50
   SET remain = 0
   SET index = 1
   SET status = 0
   SET display = fillstring(40," ")
   SET meaning = fillstring(12," ")
   SET codeset = 0
   SET codevalue = 0.0
   SET codecnt = 0
   FOR (i = 1 TO 100)
     SET codelist[i] = 0.0
   ENDFOR
 END ;Subroutine
 SUBROUTINE init_uar_test(cnt,code_set,uarname,key_value)
   SET stat = alterlist(codes->uar,cnt)
   SET codes->uar[uarcnt].name = uarname
   SET codes->uar[uarcnt].code_set = code_set
   SET codes->uar[uarcnt].key_value = key_value
   CALL echo(_line)
   CALL echo(concat("Time= ",format(cnvtdatetime(curdate,curtime3),";;q")))
   CALL echo(concat("uar= ",uarname,", code set= ",build(code_set),", key value= ",
     key_value))
 END ;Subroutine
 IF (uar_mode="UAR")
  IF (code_value=0)
   SELECT INTO  $OUTDEV
    code_value = cv.code_value, cdf_meaning = uar_get_code_meaning(cv.code_value), display =
    substring(1,30,uar_get_code_display(cv.code_value)),
    concept_cki = substring(1,40,uar_get_conceptcki(cv.code_value)), cki = uar_get_code_cki(cv
     .code_value)
    FROM code_value cv
    WHERE cv.code_set=code_set
    ORDER BY cv.code_value
    WITH nocounter
   ;end select
  ELSE
   CALL echo(concat("Code value: ",build(code_value),char(10),char(13),"   CDF_MEANING= ",
     build(uar_get_code_meaning(code_value)),char(10),char(13),"   DISPLAY= ",build(
      uar_get_code_display(code_value)),
     char(10),char(13),"   CKI=  ",build(uar_get_code_cki(code_value)),char(10),
     char(13),"   CONCEPT_CKI=  ",build(uar_get_conceptcki(code_value))))
  ENDIF
 ELSEIF (uar_mode="UAR_LIST")
  FREE RECORD cv
  RECORD cv(
    1 cvlist[*]
      2 cv = f8
  ) WITH protect
  FREE RECORD temp_code
  RECORD temp_code(
    1 codes[*]
      2 cv = f8
  ) WITH protect
  DECLARE iremaining = i4 WITH protect, noconstant(0)
  DECLARE dcodevalue = f8 WITH protect, noconstant(0.0)
  DECLARE icv_cnt = i4 WITH protect, noconstant(1)
  DECLARE mlcounter = i4 WITH protect, noconstant(0)
  DECLARE mltotalremaining = i4 WITH protect, noconstant(0)
  DECLARE mlstartindex = i4 WITH protect, noconstant(1)
  DECLARE mloccurances = i4 WITH protect, noconstant(2)
  DECLARE mlstructsize = i4 WITH protect, noconstant(0)
  CALL uar_get_meaning_by_codeset(14002,"REVENUE",icv_cnt,dcodevalue)
  SET stat = memalloc(mdcodelist,icv_cnt,"f8")
  CALL echo(concat(
    "Code set= 14002, Meaning= REVENUE, uar_get_code_list_by_meaning() with code array"))
  CALL uar_get_code_list_by_meaning(14002,"REVENUE",mlstartindex,mloccurances,mltotalremaining,
   mdcodelist)
  SET mlstructsize = (mloccurances+ mltotalremaining)
  CALL echo(concat("mlStructSize=",build(mlstructsize),", mlOccurances= ",build(mloccurances),
    ", mlTotalRemaining= ",
    build(mltotalremaining)))
  SET stat = alterlist(temp_code->codes,mlstructsize)
  FOR (mlcounter = 1 TO mloccurances)
    SET temp_code->codes[mlcounter].cv = mdcodelist[mlcounter]
  ENDFOR
  IF (mltotalremaining > 0)
   SET mlstartindex = (mloccurances+ 1)
   SET mloccurances = mltotalremaining
   SET stat = memrealloc(mdcodelist,mloccurances,"f8")
   CALL uar_get_code_list_by_meaning(14002,"REVENUE",mlstartindex,mloccurances,mltotalremaining,
    mdcodelist)
   FOR (mlcounter = mlstartindex TO mlstructsize)
     SET temp_code->codes[mlcounter].cv = mdcodelist[(mlcounter - (mlstartindex - 1))]
   ENDFOR
  ENDIF
  CALL echo(concat("Size temp_code->codes= ",build(size(temp_code->codes,5))))
  CALL echorecord(temp_code)
  SET stat = memfree(mdcodelist)
  SET stat = alterlist(cv->cvlist,icv_cnt)
  CALL echo(concat(
    "Code set= 14002, Meaning= REVENUE, uar_get_code_list_by_meaning() with F8 pointer to code list")
   )
  CALL echo(concat("Size cv->cvlist= ",build(size(cv->cvlist,5))))
  CALL uar_get_code_list_by_meaning(14002,"REVENUE",1,icv_cnt,iremaining,
   cv->cvlist.cv)
  CALL echorecord(cv)
 ELSEIF (uar_mode="UAR_OCI")
  RECORD codes(
    1 uar[*]
      2 name = vc
      2 code_set = i4
      2 key_value = vc
      2 query_count = i4
      2 uar_count = i4
      2 uarlist[*]
        3 code_value = f8
      2 uarocilist[*]
        3 code_value = f8
  ) WITH protect
  DECLARE uarcnt = i4 WITH noconstant(0)
  DECLARE validmeaning = vc WITH noconstant("NURSEUNIT")
  DECLARE invalidmeaning = vc WITH constant("BOGUS")
  DECLARE multimeaningset1 = i4 WITH noconstant(14002)
  DECLARE multimeaning1 = vc WITH noconstant("REVENUE")
  DECLARE multimeaningset2 = i4 WITH noconstant(220)
  DECLARE multimeaning2 = vc WITH noconstant("AMBULATORY")
  DECLARE emptymeaningset = i4 WITH noconstant(0)
  DECLARE emptymeaning = vc WITH constant(" ")
  DECLARE multidisplayset = i4 WITH noconstant(220)
  DECLARE multidisplay = vc WITH noconstant("")
  DECLARE uniquedisplayset = i4 WITH noconstant(200)
  DECLARE uniquedisplay = vc WITH noconstant("Blood Pressure")
  DECLARE uniquedisplaykey = vc WITH noconstant("BLOODPRESSURE")
  DECLARE uniquedescset = i4 WITH noconstant(200)
  DECLARE uniquedescrip = vc WITH noconstant("Blood Pressure")
  DECLARE multidisplaykey = vc WITH noconstant("")
  DECLARE multiconceptckiset = i4 WITH noconstant(200)
  DECLARE conceptcki1 = vc
  DECLARE conceptcki2 = vc
  DECLARE conceptckivalid = i2
  IF (curdomain="DISCERNDEV")
   SET conceptcki1 = "SNOMED!73756003"
   SET conceptcki2 = "SNOMED!225399009"
   SET conceptckivalid = 1
  ELSE
   SELECT INTO "nl:"
    c.concept_cki
    FROM code_value c
    WHERE c.code_set=200
     AND active_ind=1
     AND trim(c.concept_cki) > ""
    GROUP BY c.concept_cki
    HAVING count(*)=1
    ORDER BY c.concept_cki
    DETAIL
     conceptcki1 = c.concept_cki
    WITH nocounter, maxqual(c,1)
   ;end select
   SELECT INTO "nl:"
    count(*), c.concept_cki
    FROM code_value c
    WHERE c.code_set=200
     AND active_ind=1
     AND trim(c.concept_cki) > ""
    GROUP BY c.concept_cki
    HAVING count(*) >= 2
    ORDER BY c.concept_cki
    DETAIL
     conceptcki2 = c.concept_cki
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET conceptckivalid = 1
   ELSE
    SET conceptckivalid = 0
    SET conceptcki2 = "<No valid CONCEPT CKI exists>"
   ENDIF
  ENDIF
  DECLARE codecnt = i4
  DECLARE codelist[100] = f8
  DECLARE codelist2[100] = f8
  DECLARE occurs = i4 WITH noconstant(1)
  DECLARE remain = i4 WITH noconstant(0)
  DECLARE index = i4 WITH noconstant(1)
  DECLARE status = i4 WITH noconstant(0)
  DECLARE display = c40
  DECLARE meaning = c12
  DECLARE codeset = i4 WITH noconstant(0)
  DECLARE codevalue = f8 WITH noconstant(0.0)
  DECLARE idx = i4 WITH noconstant(0)
  SET codevalue = uar_get_code_by("DISPLAYKEY",200,nullterm(uniquedisplaykey))
  IF (codevalue < 0)
   SELECT INTO "nl:"
    c.display, c.display_key
    FROM code_value c
    WHERE c.code_set=200
     AND c.display_key="BLOODPRESSURE*"
     AND c.active_ind=1
    DETAIL
     uniquedisplay = c.display, uniquedisplaykey = c.display_key, uniquedescrip = c.description
    WITH nocounter, maxqual(c,1)
   ;end select
  ENDIF
  SET time_begin = cnvtdatetime(curdate,curtime3)
  CALL echo(_line)
  CALL echo("uar_get_code_by... code set 200")
  SET codevalue = uar_get_code_by("DISPLAYKEY",200,"VITALSIGNS")
  CALL echo(build("  VALID DisplayKey= VITALSIGNS, code= ",build(codevalue)))
  SET codevalue = uar_get_code_by("DISPLAYKEY",200,"BADEVENTSET")
  CALL echo(build("  INVALID DisplayKey= BADEVENTSET, code= ",build(codevalue)))
  SET codevalue = uar_get_code_by("DISPLAY",200,"BADEVENTSET")
  CALL echo(build("  INVALID Display= BADEVENTSET, code= ",build(codevalue)))
  FOR (idx = 1 TO 10)
    SET codevalue = uar_get_code_by("DISPLAYKEY",200,nullterm(uniquedisplaykey))
    CALL echo(build("  VALID DisplayKey= ",uniquedisplaykey,", code= ",build(codevalue)))
    SET codevalue = uar_get_code_by("DISPLAY",200,nullterm(uniquedisplay))
    CALL echo(build("  VALID Display= ",uniquedisplay,", code= ",build(codevalue)))
    SET codevalue = uar_get_code_by("DESCRIPTION",200,nullterm(uniquedescrip))
    CALL echo(build("  VALID Description= ",uniquedescrip,", code= ",build(codevalue)))
  ENDFOR
  CALL echo(_line)
  CALL echo("uar_get_code_by... code set 220")
  SET codevalue = uar_get_code_by("MEANING",220,nullterm(invalidmeaning))
  CALL echo(build("  INVALID Meaning of: ",invalidmeaning,", code= ",build(codevalue)))
  SET codevalue = uar_get_code_by("MEANING",220,nullterm(multimeaning2))
  CALL echo(build("  Multiple Meaning of: ",multimeaning2,", code= ",build(codevalue)))
  SET time_end = cnvtdatetime(curdate,curtime3)
  SET time_begin2 = cnvtdatetime(curdate,curtime3)
  SET codeset = 4000601
  CALL echo(_line)
  CALL echo("uar_oci_get_code_by... code set 4000601")
  SET codevalue = uar_oci_get_code_by("DISPLAYKEY",codeset,"CPMSCRIPTBATCH")
  CALL echo(build("  VALID DisplayKey= CPMSCRIPTBATCH, code= ",build(codevalue)))
  SET codevalue = uar_oci_get_code_by("DISPLAY",codeset,"CpmScriptBatch")
  CALL echo(build("  VALID DisplayKey= CpmScriptBatch, code= ",build(codevalue)))
  SET codevalue = uar_oci_get_code_by("MEANING",codeset,"DEFAULT")
  CALL echo(build("  VALID MEANING= DEFAULT, code= ",build(codevalue)))
  SET codevalue = uar_oci_get_code_by("MEANING",codeset,nullterm(invalidmeaning))
  CALL echo(build("  INVALID MEANING= invalidMeaning, code= ",build(codevalue)))
  SET codevalue = uar_oci_get_code_by("BADTYPE",codeset,"DEFAULT")
  CALL echo(build("  INVALID code type= BADTYPE, code= ",build(codevalue)))
  SET time_end2 = cnvtdatetime(curdate,curtime3)
  SET time_begin3 = cnvtdatetime(curdate,curtime3)
  CALL resetglobals(0)
  SET uarcnt = (uarcnt+ 1)
  CALL init_uar_test(uarcnt,uniquedisplayset,"uar_get_code_list_by_display",uniquedisplay)
  SELECT INTO "nl:"
   querycnt = count(*)
   FROM code_value c
   WHERE c.code_set=uniquedisplayset
    AND c.display=uniquedisplay
    AND c.active_ind=1
   FOOT REPORT
    codes->uar[uarcnt].query_count = querycnt
   WITH nocounter, noheading
  ;end select
  SET status = uar_get_code_list_by_display(uniquedisplayset,nullterm(uniquedisplay),index,occurs,
   remain,
   codelist)
  CALL echo(concat("   UAR status= ",build(status),", occurs= ",build(occurs),", remain= ",
    build(remain)))
  SET stat = alterlist(codes->uar[uarcnt].uarlist,occurs)
  SET codes->uar[uarcnt].uar_count = occurs
  FOR (idx = 1 TO occurs)
    SET codes->uar[uarcnt].uarlist[idx].code_value = codelist[idx]
  ENDFOR
  CALL resetglobals(0)
  SET uarcnt = (uarcnt+ 1)
  CALL init_uar_test(uarcnt,uniquedisplayset,"uar_get_code_list_by_dispkey",uniquedisplaykey)
  SELECT INTO "nl:"
   querycnt = count(*)
   FROM code_value c
   WHERE c.code_set=uniquedisplayset
    AND c.display_key=uniquedisplaykey
    AND c.active_ind=1
   DETAIL
    codes->uar[uarcnt].query_count = querycnt
   WITH nocounter, noheading
  ;end select
  SET status = uar_get_code_list_by_dispkey(uniquedisplayset,nullterm(uniquedisplaykey),index,occurs,
   remain,
   codelist)
  CALL echo(concat("   UAR status= ",build(status),", occurs= ",build(occurs),", remain= ",
    build(remain)))
  SET stat = alterlist(codes->uar[uarcnt].uarlist,occurs)
  SET codes->uar[uarcnt].uar_count = occurs
  FOR (idx = 1 TO occurs)
    SET codes->uar[uarcnt].uarlist[idx].code_value = codelist[idx]
  ENDFOR
  CALL resetglobals(0)
  SET uarcnt = (uarcnt+ 1)
  CALL init_uar_test(uarcnt,uniquedescset,"uar_get_code_list_by_descr",uniquedescrip)
  SELECT INTO "nl:"
   querycnt = count(*)
   FROM code_value c
   WHERE c.code_set=uniquedescset
    AND c.display_key=uniquedescrip
    AND c.active_ind=1
   DETAIL
    codes->uar[uarcnt].query_count = querycnt
   WITH nocounter, noheading
  ;end select
  SET status = uar_get_code_list_by_descr(uniquedescset,nullterm(uniquedescrip),index,occurs,remain,
   codelist)
  CALL echo(concat("   UAR status= ",build(status),", occurs= ",build(occurs),", remain= ",
    build(remain)))
  SET stat = alterlist(codes->uar[uarcnt].uarlist,occurs)
  SET codes->uar[uarcnt].uar_count = occurs
  FOR (idx = 1 TO occurs)
    SET codes->uar[uarcnt].uarlist[idx].code_value = codelist[idx]
  ENDFOR
  CALL resetglobals(0)
  SET uarcnt = (uarcnt+ 1)
  CALL init_uar_test(uarcnt,multimeaningset1,"uar_get_code_list_by_meaning",multimeaning1)
  SELECT INTO "nl:"
   querycnt = count(*)
   FROM code_value c
   WHERE c.code_set=multimeaningset1
    AND c.cdf_meaning=multimeaning1
    AND c.active_ind=1
   FOOT REPORT
    codes->uar[uarcnt].query_count = querycnt
   WITH nocounter
  ;end select
  SET index = 1
  CALL echo("uar_oci_get_code_list_by_meaning: multi-CDF meaning, OCI method...")
  SET status = uar_oci_get_code_list_by_meaning(multimeaningset1,nullterm(multimeaning1),index,occurs,
   remain,
   codelist2)
  CALL echo(concat("   UAR status= ",build(status),", occurs= ",build(occurs),", remain= ",
    build(remain)))
  SET index = 1
  SET occurs = 50
  CALL echo("uar_get_code_list_by_meaning: multi-CDF meaning, cache method...")
  SET status = uar_get_code_list_by_meaning(multimeaningset1,nullterm(multimeaning1),index,occurs,
   remain,
   codelist)
  CALL echo(concat("   UAR status= ",build(status),", occurs= ",build(occurs),", remain= ",
    build(remain)))
  IF (occurs > 0)
   SET stat = alterlist(codes->uar[uarcnt].uarlist,occurs)
   SET stat = alterlist(codes->uar[uarcnt].uarocilist,occurs)
   SET codes->uar[uarcnt].uar_count = occurs
   FOR (idx = 1 TO occurs)
    SET codes->uar[uarcnt].uarlist[idx].code_value = codelist[idx]
    SET codes->uar[uarcnt].uarocilist[idx].code_value = codelist2[idx]
   ENDFOR
  ENDIF
  SELECT INTO noforms
   _index = d.seq, _codevalue = codes->uar[uarcnt].uarlist[d.seq].code_value, _meaning =
   uar_get_code_meaning(codes->uar[uarcnt].uarlist[d.seq].code_value),
   _display = uar_get_code_display(codes->uar[uarcnt].uarlist[d.seq].code_value)
   FROM code_value c,
    (dummyt d  WITH seq = value(size(codes->uar[uarcnt].uarlist,5)))
   PLAN (c
    WHERE c.code_set=multimeaningset1
     AND c.cdf_meaning=multimeaning1
     AND c.active_ind=1)
    JOIN (d
    WHERE (c.code_value=codes->uar[uarcnt].uarlist[d.seq].code_value))
   ORDER BY c.display_key
   WITH nocounter
  ;end select
  CALL resetglobals(0)
  SET uarcnt = (uarcnt+ 1)
  CALL init_uar_test(uarcnt,multimeaningset2,"uar_get_code_list_by_meaning",multimeaning2)
  SELECT INTO "nl:"
   querycnt = count(*)
   FROM code_value c
   WHERE c.code_set=multimeaningset2
    AND c.cdf_meaning=multimeaning2
    AND c.active_ind=1
   FOOT REPORT
    codes->uar[uarcnt].query_count = querycnt
   WITH nocounter
  ;end select
  SET remain = 1
  SET codecnt = 0
  WHILE (status=0
   AND remain > 0)
    SET status = uar_get_code_list_by_meaning(multimeaningset2,nullterm(multimeaning2),index,occurs,
     remain,
     codelist)
    CALL echo(concat("   UAR status= ",build(status),", occurs= ",build(occurs),", remain= ",
      build(remain)))
    IF (occurs=0
     AND remain > 0)
     CALL echo("ERROR in uar_get_code_list_by_meaning, remaining param incorrect")
    ENDIF
    IF (occurs > 0)
     SET codecnt = (codecnt+ occurs)
     SET stat = alterlist(codes->uar[uarcnt].uarlist,codecnt)
     FOR (idx = 1 TO occurs)
       SET i = (index+ (idx - 1))
       SET codes->uar[uarcnt].uarlist[i].code_value = codelist[idx]
       SET codelist[idx] = 0.0
     ENDFOR
     SET index = (index+ occurs)
     SET occurs = 50
    ENDIF
  ENDWHILE
  SET codes->uar[uarcnt].uar_count = codecnt
  SELECT INTO noforms
   _index = d.seq, _codevalue = codes->uar[uarcnt].uarlist[d.seq].code_value, _meaning =
   uar_get_code_meaning(codes->uar[uarcnt].uarlist[d.seq].code_value),
   _display = uar_get_code_display(codes->uar[uarcnt].uarlist[d.seq].code_value)
   FROM code_value c,
    (dummyt d  WITH seq = value(codecnt))
   PLAN (c
    WHERE c.code_set=multimeaningset2
     AND c.cdf_meaning=multimeaning2
     AND c.active_ind=1)
    JOIN (d
    WHERE (c.code_value=codes->uar[uarcnt].uarlist[d.seq].code_value))
   ORDER BY c.display_key
   WITH nocounter
  ;end select
  CALL resetglobals(0)
  SET occurs = 1
  SET uarcnt = (uarcnt+ 1)
  CALL init_uar_test(uarcnt,multiconceptckiset,"uar_get_code_list_by_conceptcki",conceptcki1)
  SELECT INTO "nl:"
   querycnt = count(*)
   FROM code_value c
   WHERE c.code_set=multiconceptckiset
    AND c.concept_cki=conceptcki1
    AND c.active_ind=1
   FOOT REPORT
    codes->uar[uarcnt].query_count = querycnt
   WITH nocounter
  ;end select
  DECLARE ptt_cd = f8
  SET status = uar_get_code_list_by_conceptcki(multiconceptckiset,nullterm(conceptcki1),1,occurs,
   remain,
   ptt_cd)
  IF (status=0)
   CALL echo(build("uar_get_code_list_by_conceptcki: occurs= ",occurs))
  ENDIF
  SET codes->uar[uarcnt].uar_count = occurs
  SET stat = alterlist(codes->uar[uarcnt].uarlist,occurs)
  SET codes->uar[uarcnt].uarlist[codecnt].code_value = ptt_cd
  CALL resetglobals(0)
  SET occurs = 1
  SET uarcnt = (uarcnt+ 1)
  CALL init_uar_test(uarcnt,multiconceptckiset,"uar_get_code_list_by_conceptcki",conceptcki2)
  SELECT INTO "nl:"
   querycnt = count(*)
   FROM code_value c
   WHERE c.code_set=multiconceptckiset
    AND c.concept_cki=conceptcki2
    AND c.active_ind=1
   FOOT REPORT
    codes->uar[uarcnt].query_count = querycnt
   WITH nocounter
  ;end select
  IF (conceptckivalid=1)
   SET cvct = 0
   SET cvct2 = 0
   SET iret = uar_get_code_list_by_conceptcki(multiconceptckiset,nullterm(conceptcki2),index,occurs,
    remain,
    codevalue)
   SET cvct = (remain+ 1)
   IF (iret=0)
    SET codecnt = (codecnt+ 1)
    SET stat = alterlist(codes->uar[uarcnt].uarlist,codecnt)
    SET codes->uar[uarcnt].uarlist[codecnt].code_value = codevalue
   ENDIF
   IF (cvct > 1)
    FOR (cvct2 = 2 TO cvct)
      SET index = cvct2
      SET occurs = 1
      SET iret = uar_get_code_list_by_conceptcki(multiconceptckiset,nullterm(conceptcki2),index,
       occurs,remain,
       codevalue)
      IF (iret=0)
       SET codecnt = (codecnt+ 1)
       SET stat = alterlist(codes->uar[uarcnt].uarlist,codecnt)
       SET codes->uar[uarcnt].uarlist[codecnt].code_value = codevalue
      ENDIF
    ENDFOR
   ENDIF
   CALL echo(build("uar_get_code_list_by_conceptcki: occurs= ",codecnt))
   SET codes->uar[uarcnt].uar_count = codecnt
   SELECT INTO noforms
    _index = d.seq, _codevalue = codes->uar[uarcnt].uarlist[d.seq].code_value, _meaning =
    uar_get_code_meaning(codes->uar[uarcnt].uarlist[d.seq].code_value),
    _display = uar_get_code_display(codes->uar[uarcnt].uarlist[d.seq].code_value)
    FROM code_value c,
     (dummyt d  WITH seq = value(codecnt))
    PLAN (c
     WHERE c.code_set=multiconceptckiset
      AND c.concept_cki=conceptcki2
      AND c.active_ind=1)
     JOIN (d
     WHERE (c.code_value=codes->uar[uarcnt].uarlist[d.seq].code_value))
    ORDER BY c.display_key
    WITH nocounter
   ;end select
  ELSE
   CALL echo("Bypassing test for Concept cki mapped to multiple codes. No valid Concept cki exists.")
  ENDIF
  CALL echorecord(codes,"ccl_uar_codetest.dat")
  CALL echoxml(codes,"ccl_uar_codetest.xml")
  SET time_end3 = cnvtdatetime(curdate,curtime3)
  CALL echo(build("Elapsed time of uar_get_code_by*= ",(datetimediff(time_end,time_begin,6)/ 100),
    " secs"))
  CALL echo(build("Elapsed time of uar_oci_get_code_by*= ",(datetimediff(time_end2,time_begin2,6)/
    100)," secs"))
  CALL echo(build("Elapsed time of uar_get_code_list_by*= ",(datetimediff(time_end3,time_begin3,6)/
    100)," secs"))
 ELSE
  CALL echo("mode not recognized")
 ENDIF
END GO
