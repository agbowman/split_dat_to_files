CREATE PROGRAM dcp_get_problem_extract:dba
 PROMPT
  "Enter which problems to identify (0=All, 1=Codified, 2=Free text): " = "0",
  "Enter the source vocabulary CDF_MEANING from code set 400 (Required for Codified): " = "",
  "Include the problem classifications (Y or N): " = "N"
 RECORD data(
   1 qual_cnt = i4
   1 qual[*]
     2 nomenclature_id = f8
     2 classification_cd = f8
     2 duplicate_ind = i2
     2 problem_count = i4
 ) WITH protect
 DECLARE sline = vc WITH protect, constant(fillstring(80,"-"))
 DECLARE sdelimiter = c1 WITH protect, constant(char(9))
 DECLARE sfile_extension = vc WITH protect, constant(".txt")
 DECLARE dgroup1_id = f8 WITH protect, constant(- (10.0))
 DECLARE dgroup2_id = f8 WITH protect, constant(- (20.0))
 DECLARE nsearch_all = i2 WITH protect, constant(0)
 DECLARE nsearch_codified = i2 WITH protect, constant(1)
 DECLARE nsearch_freetext = i2 WITH protect, constant(2)
 DECLARE sspace = vc WITH protect, constant(" ")
 DECLARE dscripttime = f8 WITH private, noconstant(curtime3)
 DECLARE dstarttime = f8 WITH private, noconstant(0.0)
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE sfilename = vc WITH protect, noconstant("")
 DECLARE ssourcevocabmeaning = vc WITH protect, noconstant(trim(cnvtupper( $2),3))
 DECLARE dsourcevocabcd = f8 WITH protect, noconstant(0.0)
 DECLARE nsearchflag = i2 WITH protect, noconstant(- (1))
 DECLARE sclientmnemonic = vc WITH protect, noconstant("")
 DECLARE lprobcnt = i4 WITH protect, noconstant(0)
 DECLARE snomenclatureid = vc WITH protect, noconstant("")
 DECLARE sproblemname = vc WITH protect, noconstant("")
 DECLARE sconceptcode = vc WITH protect, noconstant("")
 DECLARE sproblemtype = vc WITH protect, noconstant("")
 DECLARE sproblemcount = vc WITH protect, noconstant("")
 DECLARE sclassification = vc WITH protect, noconstant("")
 DECLARE ndebugind = i2 WITH protect, noconstant(validate(debug_ind,0))
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE dstat = f8 WITH protect, noconstant(0.0)
 DECLARE sincludeprobclass = vc WITH protect, noconstant(trim(cnvtupper( $3),3))
 DECLARE getconceptcode(sconceptcki=vc) = vc
 IF (isnumeric( $1)=1)
  SET nsearchflag = cnvtint( $1)
 ENDIF
 IF ( NOT (nsearchflag IN (nsearch_all, nsearch_codified, nsearch_freetext)))
  SET serrormsg = "Invalid search flag value"
  GO TO exit_script
 ENDIF
 IF (nsearchflag IN (nsearch_all, nsearch_codified))
  IF (textlen(ssourcevocabmeaning) <= 0)
   SET serrormsg = "Invalid source vocabulary value"
   GO TO exit_script
  ELSE
   SET dsourcevocabcd = uar_get_code_by("MEANING",400,ssourcevocabmeaning)
   IF (dsourcevocabcd <= 0)
    SET serrormsg = concat("Source vocabulary code does not exist for ",ssourcevocabmeaning)
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 IF ( NOT (sincludeprobclass IN ("Y", "N")))
  SET serrormsg = "Invalid problem classification value"
  GO TO exit_script
 ENDIF
 IF (error(serrormsg,0) != 0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info di
  PLAN (di
   WHERE di.info_domain="DATA MANAGEMENT"
    AND di.info_name="CLIENT MNEMONIC")
  DETAIL
   sclientmnemonic = trim(di.info_char,3)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET serrormsg = "Error identifying client mnemonic on dm_info table"
  GO TO exit_script
 ENDIF
 ROLLBACK
 IF (nsearchflag IN (nsearch_all, nsearch_codified))
  SET dstarttime = curtime3
  CALL echo(sline)
  CALL echo("Identifying codified problems...")
  CALL echo(sline)
  IF (sincludeprobclass="Y")
   INSERT  FROM shared_list_gttd
    (source_entity_id, source_entity_seq, source_entity_value,
    source_entity_nbr)(SELECT INTO "nl:"
     source_entity_id = dgroup1_id, source_entity_seq = p.nomenclature_id, source_entity_value = p
     .classification_cd,
     source_entity_nbr = count(p.classification_cd)
     FROM problem p
     WHERE p.person_id > 0
      AND p.problem_id > 0
      AND p.nomenclature_id > 0
      AND p.originating_nomenclature_id=0
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND p.problem_type_flag IN (0, 1)
     GROUP BY p.nomenclature_id, p.classification_cd)
   ;end insert
   IF (error(serrormsg,0) != 0)
    SET serrormsg = concat(
     "Error identifying codified problems with originating_nomenclature_id = 0: ",serrormsg)
    GO TO exit_script
   ENDIF
   INSERT  FROM shared_list_gttd
    (source_entity_id, source_entity_seq, source_entity_value,
    source_entity_nbr)(SELECT INTO "nl:"
     source_entity_id = dgroup2_id, source_entity_seq = p.originating_nomenclature_id,
     source_entity_value = p.classification_cd,
     source_entity_nbr = count(p.classification_cd)
     FROM problem p
     WHERE p.person_id > 0
      AND p.problem_id > 0
      AND p.nomenclature_id > 0
      AND p.originating_nomenclature_id > 0
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND p.problem_type_flag IN (0, 1)
     GROUP BY p.originating_nomenclature_id, p.classification_cd)
   ;end insert
   IF (error(serrormsg,0) != 0)
    SET serrormsg = concat(
     "Error identifying codified problems with originating_nomenclature_id > 0: ",serrormsg)
    GO TO exit_script
   ENDIF
  ELSE
   INSERT  FROM shared_list_gttd
    (source_entity_id, source_entity_seq, source_entity_value,
    source_entity_nbr)(SELECT INTO "nl:"
     source_entity_id = dgroup1_id, source_entity_seq = p.nomenclature_id, source_entity_value = 0.0,
     source_entity_nbr = count(p.nomenclature_id)
     FROM problem p
     WHERE p.person_id > 0
      AND p.problem_id > 0
      AND p.nomenclature_id > 0
      AND p.originating_nomenclature_id=0
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND p.problem_type_flag IN (0, 1)
     GROUP BY p.nomenclature_id)
   ;end insert
   IF (error(serrormsg,0) != 0)
    SET serrormsg = concat(
     "Error identifying codified problems with originating_nomenclature_id = 0: ",serrormsg)
    GO TO exit_script
   ENDIF
   INSERT  FROM shared_list_gttd
    (source_entity_id, source_entity_seq, source_entity_value,
    source_entity_nbr)(SELECT INTO "nl:"
     source_entity_id = dgroup2_id, source_entity_seq = p.originating_nomenclature_id,
     source_entity_value = 0.0,
     source_entity_nbr = count(p.originating_nomenclature_id)
     FROM problem p
     WHERE p.person_id > 0
      AND p.problem_id > 0
      AND p.nomenclature_id > 0
      AND p.originating_nomenclature_id > 0
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND p.problem_type_flag IN (0, 1)
     GROUP BY p.originating_nomenclature_id)
   ;end insert
   IF (error(serrormsg,0) != 0)
    SET serrormsg = concat(
     "Error identifying codified problems with originating_nomenclature_id > 0: ",serrormsg)
    GO TO exit_script
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   FROM shared_list_gttd slg1,
    nomenclature n,
    shared_list_gttd slg2
   PLAN (slg1
    WHERE slg1.source_entity_id=dgroup2_id
     AND slg1.source_entity_seq > 0)
    JOIN (n
    WHERE n.nomenclature_id=slg1.source_entity_seq
     AND n.source_vocabulary_cd != dsourcevocabcd)
    JOIN (slg2
    WHERE slg2.source_entity_id=outerjoin(dgroup1_id)
     AND slg2.source_entity_seq=outerjoin(slg1.source_entity_seq)
     AND slg2.source_entity_value=outerjoin(slg1.source_entity_value))
   HEAD REPORT
    lcnt = 0
   DETAIL
    lcnt = (lcnt+ 1)
    IF (mod(lcnt,100)=1)
     dstat = alterlist(data->qual,(lcnt+ 99))
    ENDIF
    data->qual[lcnt].nomenclature_id = slg1.source_entity_seq, data->qual[lcnt].classification_cd =
    slg1.source_entity_value
    IF (slg2.source_entity_id=dgroup1_id
     AND slg2.source_entity_seq=slg1.source_entity_seq
     AND slg2.source_entity_value=slg1.source_entity_value)
     data->qual[lcnt].duplicate_ind = 1, data->qual[lcnt].problem_count = (slg1.source_entity_nbr+
     slg2.source_entity_nbr)
    ENDIF
   FOOT REPORT
    dstat = alterlist(data->qual,lcnt), data->qual_cnt = lcnt
   WITH nocounter
  ;end select
  IF (error(serrormsg,0) != 0)
   SET serrormsg = concat("Error filtering values on shared_list_gttd table: ",serrormsg)
   GO TO exit_script
  ENDIF
  IF ((data->qual_cnt > 0))
   UPDATE  FROM shared_list_gttd slg,
     (dummyt d  WITH seq = value(data->qual_cnt))
    SET slg.source_entity_nbr = data->qual[d.seq].problem_count
    PLAN (d
     WHERE (data->qual[d.seq].duplicate_ind=1))
     JOIN (slg
     WHERE slg.source_entity_id=dgroup1_id
      AND (slg.source_entity_seq=data->qual[d.seq].nomenclature_id)
      AND (slg.source_entity_value=data->qual[d.seq].classification_cd))
   ;end update
   IF (error(serrormsg,0) != 0)
    SET serrormsg = concat("Error updating problem counts on shared_list_gttd table: ",serrormsg)
    GO TO exit_script
   ENDIF
   UPDATE  FROM shared_list_gttd slg,
     (dummyt d  WITH seq = value(data->qual_cnt))
    SET slg.source_entity_id = dgroup1_id
    PLAN (d
     WHERE (data->qual[d.seq].duplicate_ind=0))
     JOIN (slg
     WHERE slg.source_entity_id=dgroup2_id
      AND (slg.source_entity_seq=data->qual[d.seq].nomenclature_id)
      AND (slg.source_entity_value=data->qual[d.seq].classification_cd))
   ;end update
   IF (error(serrormsg,0) != 0)
    SET serrormsg = concat("Error updating non-duplicates on shared_list_gttd table: ",serrormsg)
    GO TO exit_script
   ENDIF
  ENDIF
  FREE RECORD data
  INSERT  FROM shared_list_gttd
   (source_entity_id, source_entity_value, source_entity_nbr)(SELECT INTO "nl:"
    source_entity_id = n.nomenclature_id, source_entity_value = slg.source_entity_value,
    source_entity_nbr = slg.source_entity_nbr
    FROM shared_list_gttd slg,
     nomenclature n
    WHERE slg.source_entity_id=dgroup1_id
     AND slg.source_entity_seq > 0
     AND n.nomenclature_id=slg.source_entity_seq
     AND textlen(trim(n.source_string,3)) > 0
     AND ((n.concept_cki=null) OR (n.concept_cki != "CERNER!NKP")) )
  ;end insert
  IF (error(serrormsg,0) != 0)
   SET serrormsg = concat("Error moving group one rows to shared_list_gttd table: ",serrormsg)
   GO TO exit_script
  ENDIF
  DELETE  FROM shared_list_gttd slg
   WHERE slg.source_entity_id IN (dgroup1_id, dgroup2_id)
  ;end delete
  IF (error(serrormsg,0) != 0)
   SET serrormsg = concat("Error deleting rows from shared_list_gttd table: ",serrormsg)
   GO TO exit_script
  ENDIF
  CALL echo(sline)
  CALL echo(build2("Time to identify codified problems in seconds: ",trim(cnvtstring(((curtime3 -
      dstarttime)/ 100),12,2),3)))
  CALL echo(sline)
 ENDIF
 IF (nsearchflag IN (nsearch_all, nsearch_freetext))
  SET dstarttime = curtime3
  IF (nsearchflag=nsearch_freetext)
   CALL echo(sline)
  ENDIF
  CALL echo("Identifying free text problems...")
  CALL echo(sline)
  IF (sincludeprobclass="Y")
   INSERT  FROM shared_list_gttd
    (source_entity_id, source_entity_value, source_entity_nbr,
    source_entity_txt)(SELECT INTO "nl:"
     source_entity_id = 0.0, source_entity_value = p.classification_cd, source_entity_nbr = count(p
      .classification_cd),
     source_entity_txt = p.problem_ftdesc
     FROM problem p
     WHERE p.person_id > 0
      AND p.problem_id > 0
      AND p.nomenclature_id=0
      AND p.originating_nomenclature_id=0
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND p.problem_type_flag IN (0, 1)
      AND textlen(trim(p.problem_ftdesc,3)) > 0
     GROUP BY p.problem_ftdesc, p.classification_cd)
   ;end insert
  ELSE
   INSERT  FROM shared_list_gttd
    (source_entity_id, source_entity_value, source_entity_nbr,
    source_entity_txt)(SELECT INTO "nl:"
     source_entity_id = 0.0, source_entity_value = 0.0, source_entity_nbr = count(p.problem_ftdesc),
     source_entity_txt = p.problem_ftdesc
     FROM problem p
     WHERE p.person_id > 0
      AND p.problem_id > 0
      AND p.nomenclature_id=0
      AND p.originating_nomenclature_id=0
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND p.problem_type_flag IN (0, 1)
      AND textlen(trim(p.problem_ftdesc,3)) > 0
     GROUP BY p.problem_ftdesc)
   ;end insert
  ENDIF
  CALL echo(sline)
  CALL echo(build2("Time to identify free text problems in seconds: ",trim(cnvtstring(((curtime3 -
      dstarttime)/ 100),12,2),3)))
  IF (error(serrormsg,0) != 0)
   SET serrormsg = concat("Error identifying free text problems: ",serrormsg)
   GO TO exit_script
  ENDIF
  CALL echo(sline)
 ENDIF
 SELECT INTO "nl:"
  row_cnt = count(*)
  FROM shared_list_gttd slg
  PLAN (slg
   WHERE slg.source_entity_id >= 0)
  DETAIL
   lprobcnt = row_cnt
  WITH nocounter
 ;end select
 IF (lprobcnt > 0)
  SET sfilename = concat(cnvtlower(sclientmnemonic),"_problem_extract_",format(cnvtdatetime(curdate,
     curtime3),"YYYYMMDDHHMMSS;;q"),sfile_extension)
  SELECT INTO value(concat("ccluserdir:",sfilename))
   sourcetxtupper =
   IF (n.nomenclature_id > 0) n.source_string_keycap
   ELSE cnvtupper(trim(slg.source_entity_txt,3))
   ENDIF
   , classdisplayupper = cnvtupper(uar_get_code_display(slg.source_entity_value))
   FROM shared_list_gttd slg,
    nomenclature n
   PLAN (slg
    WHERE slg.source_entity_id >= 0)
    JOIN (n
    WHERE n.nomenclature_id=slg.source_entity_id)
   ORDER BY sourcetxtupper, classdisplayupper
   HEAD REPORT
    sclientmnemonic, row + 1, "NOMENCLATURE_ID",
    sdelimiter, "PROBLEM_NAME", sdelimiter,
    "CONCEPT_CODE", sdelimiter, "PROBLEM_TYPE",
    sdelimiter, "PROBLEM_COUNT"
    IF (sincludeprobclass="Y")
     sdelimiter, "POSSIBLE_MATCH", sdelimiter,
     "ACCEPTED", sdelimiter, "NA",
     sdelimiter, "SOURCE_CONCEPT_CODE", sdelimiter,
     "SOURCE_CONCEPT_TERM", sdelimiter, "TARGET_CONCEPT_CODE",
     sdelimiter, "NA", sdelimiter,
     "CLASSIFICATION", sdelimiter, "CLASSIFICATION_NEW"
    ENDIF
   DETAIL
    row + 1
    IF (n.nomenclature_id > 0)
     snomenclatureid = trim(format(n.nomenclature_id,";;f"),3), sproblemname = trim(replace(n
       .source_string,sdelimiter," "),3), sconceptcode = getconceptcode(n.concept_cki),
     sproblemtype = trim(uar_get_code_display(n.source_vocabulary_cd),3)
    ELSE
     snomenclatureid = "0", sproblemname = trim(replace(slg.source_entity_txt,sdelimiter," "),3),
     sconceptcode = "Free text",
     sproblemtype = " "
    ENDIF
    sproblemcount = trim(format(slg.source_entity_nbr,";;f"),3), snomenclatureid, sdelimiter,
    sproblemname, sdelimiter, sconceptcode,
    sdelimiter, sproblemtype, sdelimiter,
    sproblemcount
    IF (sincludeprobclass="Y")
     sclassification = trim(uar_get_code_display(slg.source_entity_value),3), sdelimiter, sspace,
     sdelimiter, "0", sdelimiter,
     sspace, sdelimiter, sspace,
     sdelimiter, sspace, sdelimiter,
     sspace, sdelimiter, sspace,
     sdelimiter, sclassification, sdelimiter,
     sspace
    ENDIF
   WITH format = variable, maxcol = 1000, maxrow = 1,
    nocounter, noheading
  ;end select
  CALL echo(sline)
  CALL echo(build2("File created in CCLUSERDIR: ",sfilename))
 ELSE
  CALL echo(sline)
  CALL echo("No problems qualified for file to be created")
 ENDIF
 SUBROUTINE getconceptcode(sconceptcki)
   DECLARE scode = vc WITH private, noconstant(" ")
   DECLARE lpos = i4 WITH private, noconstant(findstring("!",sconceptcki))
   DECLARE lckilength = i4 WITH private, noconstant(textlen(sconceptcki))
   IF (lpos > 0
    AND lpos < lckilength)
    SET scode = trim(substring((lpos+ 1),(lckilength - lpos),sconceptcki),3)
   ENDIF
   RETURN(scode)
 END ;Subroutine
#exit_script
 IF (ndebugind=0)
  ROLLBACK
 ENDIF
 IF (textlen(trim(serrormsg,3)) > 0)
  CALL echo(sline)
  CALL echo(serrormsg)
 ENDIF
 CALL echo(sline)
 CALL echo(build2("Script elapsed time in seconds: ",trim(cnvtstring(((curtime3 - dscripttime)/ 100),
     12,2),3)))
 CALL echo(sline)
END GO
