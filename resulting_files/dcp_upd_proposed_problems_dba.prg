CREATE PROGRAM dcp_upd_proposed_problems:dba
 PROMPT
  "Enter the import file name to process: " = "",
  "Enter the source vocabulary CDF_MEANING from code set 400: " = "",
  "Enter the target vocabulary CDF_MEANING from code set 400: " = ""
 RECORD data(
   1 qual_cnt = i4
   1 qual[*]
     2 nomenclature_id = f8
     2 problem_name = vc
     2 source_concept_cki = vc
     2 target_concept_cki = vc
     2 new_nomenclature_id = f8
     2 new_originating_nomenclature_id = f8
     2 classification_cd = f8
     2 new_classification_cd = f8
     2 process_flag = i2
     2 error_flag = i2
     2 nkp_ind = i2
 ) WITH protect
 RECORD person(
   1 qual_cnt = i4
   1 qual[*]
     2 person_id = f8
 ) WITH protect
 DECLARE sline = vc WITH protect, constant(fillstring(80,"-"))
 DECLARE dauth = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE dactive = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE dinactive = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"INACTIVE"))
 DECLARE scerner_nkp = vc WITH protect, constant("CERNER!NKP")
 DECLARE sicd9_nkp = vc WITH protect, constant("ICD9CM!NKP")
 DECLARE simo_nkp = vc WITH protect, constant("IMO!1557491")
 DECLARE ssnomed_nkp = vc WITH protect, constant("SNOMED!160245001")
 DECLARE stab_delimiter = c1 WITH protect, constant(char(9))
 DECLARE dcerner = f8 WITH protect, constant(uar_get_code_by("MEANING",400,"CERNER"))
 DECLARE dicd9 = f8 WITH protect, constant(uar_get_code_by("MEANING",400,"ICD9"))
 DECLARE dicd10_cm = f8 WITH protect, constant(uar_get_code_by("MEANING",400,"ICD10-CM"))
 DECLARE nerror_none = i2 WITH protect, constant(0)
 DECLARE nerror_source_ident_lookup = i2 WITH protect, constant(1)
 DECLARE nerror_target_ident_lookup = i2 WITH protect, constant(2)
 DECLARE nprocess_none = i2 WITH protect, constant(0)
 DECLARE nprocess_all = i2 WITH protect, constant(1)
 DECLARE nprocess_nomen = i2 WITH protect, constant(2)
 DECLARE nprocess_class = i2 WITH protect, constant(3)
 DECLARE dscripttime = f8 WITH private, noconstant(curtime3)
 DECLARE dstarttime = f8 WITH private, noconstant(0.0)
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE dstat = f8 WITH protect, noconstant(0.0)
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE lprobcnt = i4 WITH protect, noconstant(0)
 DECLARE linsertcnt = i4 WITH protect, noconstant(0)
 DECLARE lupdatecnt = i4 WITH protect, noconstant(0)
 DECLARE ltotalprobcnt = i4 WITH protect, noconstant(0)
 DECLARE ltotalprobupdcnt = i4 WITH protect, noconstant(0)
 DECLARE ssourcevocabmeaning = vc WITH protect, noconstant(trim(cnvtupper( $2),3))
 DECLARE stargetvocabmeaning = vc WITH protect, noconstant(trim(cnvtupper( $3),3))
 DECLARE dsourcevocabcd = f8 WITH protect, noconstant(0.0)
 DECLARE dtargetvocabcd = f8 WITH protect, noconstant(0.0)
 DECLARE dprsnlid = f8 WITH protect, noconstant(0.0)
 DECLARE sfilename = vc WITH protect, noconstant(trim(cnvtlower( $1),3))
 DECLARE suuid = vc WITH protect, noconstant("")
 DECLARE ntemptableind = i2 WITH protect, noconstant(0)
 DECLARE ncommitind = i2 WITH protect, noconstant(0)
 DECLARE ndebugind = i2 WITH protect, noconstant(validate(debug_ind,0))
 DECLARE stargetvocaberrormsg = vc WITH protect, noconstant("")
 DECLARE nidentlookupind = i2 WITH protect, noconstant(0)
 DECLARE ninvalidcolheaderind = i2 WITH protect, noconstant(0)
 DECLARE dnomenclatureid = f8 WITH protect, noconstant(0.0)
 DECLARE lrow = i4 WITH protect, noconstant(0)
 DECLARE snomenclatureid = vc WITH protect, noconstant("")
 DECLARE sproblemname = vc WITH protect, noconstant("")
 DECLARE sconceptcode = vc WITH protect, noconstant("")
 DECLARE sproblemtype = vc WITH protect, noconstant("")
 DECLARE sproblemcount = vc WITH protect, noconstant("")
 DECLARE scolumn6 = vc WITH protect, noconstant("")
 DECLARE smapaccepted = vc WITH protect, noconstant("")
 DECLARE scolumn8 = vc WITH protect, noconstant("")
 DECLARE snewsourceidentifier = vc WITH protect, noconstant("")
 DECLARE snewsourcetext = vc WITH protect, noconstant("")
 DECLARE snewtargetidentifier = vc WITH protect, noconstant("")
 DECLARE sclassification = vc WITH protect, noconstant("")
 DECLARE snewclassification = vc WITH protect, noconstant("")
 DECLARE nclasscolsexistind = i2 WITH protect, noconstant(0)
 DECLARE dclassificationcd = f8 WITH protect, noconstant(0.0)
 DECLARE dnewclassificationcd = f8 WITH protect, noconstant(0.0)
 DECLARE nprocessflag = i2 WITH protect, noconstant(0)
 DECLARE nsourceidentlookupind = i2 WITH protect, noconstant(0)
 DECLARE ntargetidentlookupind = i2 WITH protect, noconstant(0)
 DECLARE ncodifiedprocessallind = i2 WITH protect, noconstant(0)
 DECLARE nfreetextprocessallind = i2 WITH protect, noconstant(0)
 DECLARE ncodifiedprocessnomenind = i2 WITH protect, noconstant(0)
 DECLARE nfreetextprocessnomenind = i2 WITH protect, noconstant(0)
 DECLARE ncodifiedprocessclassind = i2 WITH protect, noconstant(0)
 DECLARE nfreetextprocessclassind = i2 WITH protect, noconstant(0)
 DECLARE nnkpind = i2 WITH protect, noconstant(0)
 DECLARE dcernernkpnomenid = f8 WITH protect, noconstant(0.0)
 DECLARE scernernkpdisplay = vc WITH protect, noconstant("")
 DECLARE createproposedtermerrorreport(null) = null
 DECLARE getconceptcki(sconceptvalue=vc,dvocabularycd=f8) = vc
 ROLLBACK
 IF (textlen(sfilename) <= 0)
  SET serrormsg = "Invalid file name"
  GO TO exit_script
 ENDIF
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
 IF (textlen(stargetvocabmeaning) <= 0)
  SET stargetvocaberrormsg = "Invalid target vocabulary value"
 ELSE
  SET dtargetvocabcd = uar_get_code_by("MEANING",400,stargetvocabmeaning)
  IF (dtargetvocabcd <= 0)
   SET stargetvocaberrormsg = concat("Target vocabulary code does not exist for ",stargetvocabmeaning
    )
  ENDIF
 ENDIF
 IF (error(serrormsg,0) != 0)
  GO TO exit_script
 ENDIF
 IF (((dauth <= 0) OR (((dactive <= 0) OR (dinactive <= 0)) )) )
  SET serrormsg = "Error retrieving code values"
  GO TO exit_script
 ENDIF
 SET dstarttime = curtime3
 FREE DEFINE rtl2
 DEFINE rtl2 sfilename
 SELECT INTO "nl:"
  FROM rtl2t r
  PLAN (r)
  HEAD REPORT
   lcnt = 0, lrow = 0
  DETAIL
   lrow = (lrow+ 1)
   IF (lrow > 1
    AND ninvalidcolheaderind=0)
    snomenclatureid = trim(piece(r.line,stab_delimiter,1,"NotFound"),3), sproblemname = trim(piece(r
      .line,stab_delimiter,2,"NotFound"),3), sconceptcode = trim(piece(r.line,stab_delimiter,3,
      "NotFound"),3),
    sproblemtype = trim(piece(r.line,stab_delimiter,4,"NotFound"),3), sproblemcount = trim(piece(r
      .line,stab_delimiter,5,"NotFound"),3), scolumn6 = trim(piece(r.line,stab_delimiter,6,"NotFound"
      ),3),
    smapaccepted = trim(piece(r.line,stab_delimiter,7,"NotFound"),3), scolumn8 = trim(piece(r.line,
      stab_delimiter,8,"NotFound"),3), snewsourceidentifier = trim(piece(r.line,stab_delimiter,9,
      "NotFound"),3),
    snewsourcetext = trim(piece(r.line,stab_delimiter,10,"NotFound"),3), snewtargetidentifier =
    IF (dtargetvocabcd IN (dicd9, dicd10_cm)) trim(piece(r.line,stab_delimiter,12,"NotFound"),3)
    ELSE trim(piece(r.line,stab_delimiter,11,"NotFound"),3)
    ENDIF
    , sclassification = trim(piece(r.line,stab_delimiter,13,"NotFound"),3),
    snewclassification = trim(piece(r.line,stab_delimiter,14,"NotFound"),3)
    IF (lrow=2)
     IF (((snomenclatureid != "NOMENCLATURE_ID") OR (((sproblemname != "PROBLEM_NAME") OR (((
     sconceptcode != "CONCEPT_CODE") OR (((sproblemtype != "PROBLEM_TYPE") OR (((sproblemcount !=
     "PROBLEM_COUNT") OR ((( NOT (scolumn6 IN ("IMO_RECOMMENDATION", "POSSIBLE_MATCH"))) OR ((( NOT (
     smapaccepted IN ("IMO_MAPIT_ACCEPTED", "ACCEPTED"))) OR ((( NOT (scolumn8 IN (
     "IMO_PRODUCT_IDENTIFIER", "NA"))) OR ((( NOT (snewsourceidentifier IN ("IMO_LEXICAL_CODE",
     "SOURCE_CONCEPT_CODE"))) OR ((( NOT (snewsourcetext IN ("IMO_LC_TEXT", "SOURCE_CONCEPT_TERM")))
      OR ( NOT (snewtargetidentifier IN ("SNMCT", "ICD", "TARGET_CONCEPT_CODE")))) )) )) )) )) )) ))
     )) )) )) )
      ninvalidcolheaderind = 1
     ELSE
      IF (sclassification="CLASSIFICATION"
       AND snewclassification="CLASSIFICATION_NEW")
       nclasscolsexistind = 1
      ENDIF
     ENDIF
    ELSEIF (smapaccepted="1"
     AND isnumeric(snomenclatureid) IN (1, 2))
     dnomenclatureid = cnvtreal(snomenclatureid)
     IF (dnomenclatureid >= 0)
      nprocessflag = nprocess_none, dclassificationcd = - (1.0), dnewclassificationcd = - (1.0)
      IF (dsourcevocabcd > 0
       AND textlen(snewsourceidentifier) > 0
       AND snewsourceidentifier != "NotFound"
       AND ((dnomenclatureid > 0) OR (dnomenclatureid=0
       AND textlen(sproblemname) > 0
       AND sproblemname != "NotFound"
       AND dtargetvocabcd > 0
       AND textlen(snewtargetidentifier) > 0
       AND snewtargetidentifier != "NotFound")) )
       nprocessflag = nprocess_nomen
      ENDIF
      IF (nclasscolsexistind=1
       AND sclassification != "NotFound"
       AND snewclassification != "NotFound"
       AND textlen(snewclassification) > 0)
       IF (textlen(sclassification) > 0)
        dclassificationcd = uar_get_code_by("DISPLAY",12033,sclassification)
       ELSE
        dclassificationcd = 0.0
       ENDIF
       dnewclassificationcd = uar_get_code_by("DISPLAY",12033,snewclassification)
       IF (dclassificationcd >= 0
        AND dnewclassificationcd > 0)
        IF (nprocessflag=nprocess_nomen)
         nprocessflag = nprocess_all
        ELSE
         nprocessflag = nprocess_class
         IF (dnomenclatureid > 0)
          ncodifiedprocessclassind = 1
         ELSE
          nfreetextprocessclassind = 1
         ENDIF
        ENDIF
       ENDIF
      ENDIF
      IF (nprocessflag != nprocess_none)
       IF (dnomenclatureid > 0)
        lidx = locateval(lidx,1,lcnt,dnomenclatureid,data->qual[lidx].nomenclature_id,
         dclassificationcd,data->qual[lidx].classification_cd)
       ELSE
        lidx = locateval(lidx,1,lcnt,sproblemname,data->qual[lidx].problem_name,
         dclassificationcd,data->qual[lidx].classification_cd)
       ENDIF
       IF (lidx=0)
        lcnt = (lcnt+ 1)
        IF (mod(lcnt,1000)=1)
         dstat = alterlist(data->qual,(lcnt+ 999))
        ENDIF
        data->qual[lcnt].nomenclature_id = dnomenclatureid, data->qual[lcnt].problem_name =
        sproblemname, data->qual[lcnt].process_flag = nprocessflag,
        data->qual[lcnt].classification_cd = dclassificationcd, data->qual[lcnt].
        new_classification_cd = dnewclassificationcd
        IF (nprocessflag IN (nprocess_all, nprocess_nomen))
         data->qual[lcnt].source_concept_cki = getconceptcki(snewsourceidentifier,dsourcevocabcd),
         data->qual[lcnt].target_concept_cki = getconceptcki(snewtargetidentifier,dtargetvocabcd)
         IF ((data->qual[lcnt].source_concept_cki IN (sicd9_nkp, simo_nkp, ssnomed_nkp)))
          data->qual[lcnt].nkp_ind = 1, nnkpind = 1
         ENDIF
         IF ((((data->qual[lcnt].nomenclature_id > 0)) OR ((data->qual[lcnt].nkp_ind=1))) )
          data->qual[lcnt].error_flag = nerror_source_ident_lookup, nsourceidentlookupind = 1
         ELSE
          data->qual[lcnt].error_flag = nerror_target_ident_lookup, ntargetidentlookupind = 1
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  FOOT REPORT
   dstat = alterlist(data->qual,lcnt), data->qual_cnt = lcnt
  WITH nocounter
 ;end select
 CALL echo(sline)
 CALL echo(build2("Time to read file in seconds: ",trim(cnvtstring(((curtime3 - dstarttime)/ 100),12,
     2),3)))
 IF (error(serrormsg,0) != 0)
  SET serrormsg = concat("Error reading import file: ",serrormsg)
  GO TO exit_script
 ENDIF
 IF (ninvalidcolheaderind=1)
  SET serrormsg = "Invalid column headers in the import file"
  GO TO exit_script
 ELSEIF ((data->qual_cnt=0))
  SET serrormsg = "No rows qualified in file to process"
  GO TO exit_script
 ENDIF
 CALL echo(sline)
 SET dstarttime = curtime3
 IF (checkdic("TEMP_DATA","T",0) != 0)
  RDB drop table temp_data
  END ;Rdb
  DROP TABLE temp_data
 ENDIF
 RDB create table temp_data ( temp_data_id number , process_flag number , error_flag number ,
 nomenclature_id number , new_nomenclature_id number , new_orig_nomenclature_id number ,
 classification_cd number , new_classification_cd number , problem_name varchar ( 255 ) )
 END ;Rdb
 EXECUTE oragen3 "temp_data"
 IF (error(serrormsg,0) != 0)
  SET serrormsg = concat("Error creating temp_data table: ",serrormsg)
  GO TO exit_script
 ENDIF
 IF (checkdic("TEMP_PROBLEM","T",0) != 0)
  RDB drop table temp_problem
  END ;Rdb
  DROP TABLE temp_problem
 ENDIF
 RDB create table temp_problem ( problem_instance_id number , person_id number , temp_data_id number
 , freetext_ind number , nomenclature_id number , orig_nomenclature_id number , classification_cd
 number , confirmation_status_cd number , annotated_display varchar ( 255 ) , problem_ftdesc varchar
 ( 255 ) , problem_instance_uuid varchar ( 255 ) )
 END ;Rdb
 EXECUTE oragen3 "temp_problem"
 IF (error(serrormsg,0) != 0)
  SET serrormsg = concat("Error creating temp_problem table: ",serrormsg)
  GO TO exit_script
 ENDIF
 SET ntemptableind = 1
 CALL echo(sline)
 CALL echo(build2("Time to create temp tables in seconds: ",trim(cnvtstring(((curtime3 - dstarttime)
     / 100),12,2),3)))
 CALL echo(sline)
 IF (nnkpind=1)
  SELECT INTO "nl:"
   FROM nomenclature n
   PLAN (n
    WHERE n.concept_cki=scerner_nkp
     AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND n.active_ind=1
     AND n.source_vocabulary_cd=dcerner
     AND  NOT (trim(n.cmti,3) IN (null, ""))
     AND n.primary_cterm_ind=1)
   HEAD REPORT
    lcnt = 0
   DETAIL
    lcnt = (lcnt+ 1)
   FOOT REPORT
    IF (lcnt=1)
     dcernernkpnomenid = n.nomenclature_id, scernernkpdisplay = n.source_string
    ENDIF
   WITH nocounter
  ;end select
  IF (error(serrormsg,0) != 0)
   SET serrormsg = concat("Error retrieving nomenclature_id for CERNER!NKP: ",serrormsg)
   GO TO exit_script
  ENDIF
 ENDIF
 IF (ntargetidentlookupind=1)
  SET dstarttime = curtime3
  INSERT  FROM shared_txt_gttd stg,
    (dummyt d  WITH seq = value(data->qual_cnt))
   SET stg.source_entity_txt = data->qual[d.seq].target_concept_cki
   PLAN (d
    WHERE (data->qual[d.seq].process_flag IN (nprocess_all, nprocess_nomen))
     AND (data->qual[d.seq].nomenclature_id=0)
     AND (data->qual[d.seq].nkp_ind=0))
    JOIN (stg)
  ;end insert
  IF (error(serrormsg,0) != 0)
   SET serrormsg = concat("Error moving target_concept_cki to shared_txt_gttd: ",serrormsg)
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM nomenclature n
   PLAN (n
    WHERE n.concept_cki IN (
    (SELECT DISTINCT
     source_entity_txt
     FROM shared_txt_gttd))
     AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND n.active_ind=1
     AND ((n.source_vocabulary_cd+ 0)=dtargetvocabcd)
     AND  NOT (trim(n.cmti,3) IN (null, ""))
     AND n.concept_cki != scerner_nkp
     AND n.primary_cterm_ind=1)
   ORDER BY n.concept_cki
   HEAD n.concept_cki
    lcnt = 0
   DETAIL
    lcnt = (lcnt+ 1)
   FOOT  n.concept_cki
    IF (lcnt=1)
     lidx = locateval(lidx,1,data->qual_cnt,n.concept_cki,data->qual[lidx].target_concept_cki)
     WHILE (lidx > 0)
      IF ((data->qual[lidx].error_flag=nerror_target_ident_lookup))
       data->qual[lidx].new_nomenclature_id = n.nomenclature_id, data->qual[lidx].error_flag =
       nerror_source_ident_lookup
      ENDIF
      ,lidx = locateval(lidx,(lidx+ 1),data->qual_cnt,n.concept_cki,data->qual[lidx].
       target_concept_cki)
     ENDWHILE
    ENDIF
   WITH nocounter, rdbcbopluszero
  ;end select
  ROLLBACK
  CALL echo(sline)
  CALL echo(build2("Time to identify new nomenclature_id's for free text problems in seconds: ",trim(
     cnvtstring(((curtime3 - dstarttime)/ 100),12,2),3)))
  IF (error(serrormsg,0) != 0)
   SET serrormsg = concat("Error identifying nomenclature_id's for free text problems: ",serrormsg)
   GO TO exit_script
  ENDIF
  CALL echo(sline)
 ENDIF
 IF (nsourceidentlookupind=1)
  SET dstarttime = curtime3
  INSERT  FROM shared_txt_gttd stg,
    (dummyt d  WITH seq = value(data->qual_cnt))
   SET stg.source_entity_txt = data->qual[d.seq].source_concept_cki
   PLAN (d
    WHERE (data->qual[d.seq].process_flag IN (nprocess_all, nprocess_nomen)))
    JOIN (stg)
  ;end insert
  IF (error(serrormsg,0) != 0)
   SET serrormsg = concat("Error moving source_concept_cki to shared_txt_gttd: ",serrormsg)
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM nomenclature n
   PLAN (n
    WHERE n.concept_cki IN (
    (SELECT DISTINCT
     source_entity_txt
     FROM shared_txt_gttd))
     AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND n.active_ind=1
     AND ((n.source_vocabulary_cd+ 0)=dsourcevocabcd)
     AND  NOT (trim(n.cmti,3) IN (null, ""))
     AND n.concept_cki != scerner_nkp
     AND n.primary_cterm_ind=1)
   ORDER BY n.concept_cki
   HEAD n.concept_cki
    lcnt = 0
   DETAIL
    lcnt = (lcnt+ 1)
   FOOT  n.concept_cki
    IF (lcnt=1)
     lidx = locateval(lidx,1,data->qual_cnt,n.concept_cki,data->qual[lidx].source_concept_cki)
     WHILE (lidx > 0)
      IF ((data->qual[lidx].error_flag=nerror_source_ident_lookup))
       IF ((data->qual[lidx].nkp_ind=1))
        IF (dcernernkpnomenid > 0)
         data->qual[lidx].new_nomenclature_id = dcernernkpnomenid, data->qual[lidx].
         new_originating_nomenclature_id = dcernernkpnomenid, data->qual[lidx].error_flag =
         nerror_none
        ENDIF
       ELSE
        data->qual[lidx].new_originating_nomenclature_id = n.nomenclature_id, data->qual[lidx].
        error_flag = nerror_none
       ENDIF
       IF ((data->qual[lidx].error_flag=nerror_none))
        IF ((data->qual[lidx].process_flag=nprocess_all))
         IF ((data->qual[lidx].nomenclature_id > 0))
          ncodifiedprocessallind = 1
         ELSE
          nfreetextprocessallind = 1
         ENDIF
        ELSEIF ((data->qual[lidx].process_flag=nprocess_nomen))
         IF ((data->qual[lidx].nomenclature_id > 0))
          ncodifiedprocessnomenind = 1
         ELSE
          nfreetextprocessnomenind = 1
         ENDIF
        ENDIF
       ENDIF
      ENDIF
      ,lidx = locateval(lidx,(lidx+ 1),data->qual_cnt,n.concept_cki,data->qual[lidx].
       source_concept_cki)
     ENDWHILE
    ENDIF
   WITH nocounter, rdbcbopluszero
  ;end select
  ROLLBACK
  CALL echo(sline)
  CALL echo(build2("Time to identify new originating_nomenclature_id's in seconds: ",trim(cnvtstring(
      ((curtime3 - dstarttime)/ 100),12,2),3)))
  IF (error(serrormsg,0) != 0)
   SET serrormsg = concat("Error identifying originating_nomenclature_id's: ",serrormsg)
   GO TO exit_script
  ENDIF
  SET nidentlookupind = 1
  CALL echo(sline)
 ENDIF
 INSERT  FROM temp_data td,
   (dummyt d  WITH seq = value(data->qual_cnt))
  SET td.temp_data_id = d.seq, td.nomenclature_id = data->qual[d.seq].nomenclature_id, td
   .problem_name = data->qual[d.seq].problem_name,
   td.new_nomenclature_id = data->qual[d.seq].new_nomenclature_id, td.new_orig_nomenclature_id = data
   ->qual[d.seq].new_originating_nomenclature_id, td.classification_cd = data->qual[d.seq].
   classification_cd,
   td.new_classification_cd = data->qual[d.seq].new_classification_cd, td.process_flag = data->qual[d
   .seq].process_flag, td.error_flag = data->qual[d.seq].error_flag
  PLAN (d
   WHERE (data->qual[d.seq].error_flag=nerror_none)
    AND (data->qual[d.seq].process_flag != nprocess_none))
   JOIN (td)
 ;end insert
 IF (error(serrormsg,0) != 0)
  SET serrormsg = concat("Error moving data record to temp_data table: ",serrormsg)
  GO TO exit_script
 ENDIF
 COMMIT
 IF (((ncodifiedprocessallind=1) OR (ncodifiedprocessnomenind=1)) )
  SET dstarttime = curtime3
  IF (ncodifiedprocessallind=1)
   INSERT  FROM temp_problem
    (problem_instance_id, person_id, temp_data_id,
    freetext_ind, nomenclature_id, orig_nomenclature_id,
    classification_cd, confirmation_status_cd, annotated_display,
    problem_ftdesc)(SELECT INTO "nl:"
     p.problem_instance_id, p.person_id, td.temp_data_id,
     0.0, p.nomenclature_id, td.new_orig_nomenclature_id,
     td.new_classification_cd, p.confirmation_status_cd, p.annotated_display,
     p.problem_ftdesc
     FROM temp_data td,
      nomenclature n,
      problem p
     WHERE td.process_flag=nprocess_all
      AND td.nomenclature_id > 0
      AND td.new_orig_nomenclature_id > 0
      AND td.new_classification_cd > 0
      AND n.nomenclature_id=td.nomenclature_id
      AND ((n.concept_cki=null) OR (n.concept_cki != scerner_nkp))
      AND ((p.nomenclature_id=n.nomenclature_id
      AND p.originating_nomenclature_id=0) OR (p.originating_nomenclature_id=n.nomenclature_id
      AND n.source_vocabulary_cd != dsourcevocabcd))
      AND p.nomenclature_id > 0
      AND p.problem_id > 0
      AND p.person_id > 0
      AND p.problem_type_flag IN (0, 1)
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND p.classification_cd=td.classification_cd)
   ;end insert
   IF (error(serrormsg,0) != 0)
    SET serrormsg = concat("Error identifying codified problems for process all update: ",serrormsg)
    GO TO exit_script
   ENDIF
  ENDIF
  IF (ncodifiedprocessnomenind=1)
   INSERT  FROM temp_problem
    (problem_instance_id, person_id, temp_data_id,
    freetext_ind, nomenclature_id, orig_nomenclature_id,
    classification_cd, confirmation_status_cd, annotated_display,
    problem_ftdesc)(SELECT INTO "nl:"
     p.problem_instance_id, p.person_id, td.temp_data_id,
     0.0, p.nomenclature_id, td.new_orig_nomenclature_id,
     p.classification_cd, p.confirmation_status_cd, p.annotated_display,
     p.problem_ftdesc
     FROM temp_data td,
      nomenclature n,
      problem p
     WHERE td.process_flag=nprocess_nomen
      AND td.nomenclature_id > 0
      AND td.new_orig_nomenclature_id > 0
      AND n.nomenclature_id=td.nomenclature_id
      AND ((n.concept_cki=null) OR (n.concept_cki != scerner_nkp))
      AND ((p.nomenclature_id=n.nomenclature_id
      AND p.originating_nomenclature_id=0) OR (p.originating_nomenclature_id=n.nomenclature_id
      AND n.source_vocabulary_cd != dsourcevocabcd))
      AND p.nomenclature_id > 0
      AND p.problem_id > 0
      AND p.person_id > 0
      AND p.problem_type_flag IN (0, 1)
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND  NOT (p.problem_instance_id IN (
     (SELECT
      tp.problem_instance_id
      FROM temp_problem tp
      WHERE tp.problem_instance_id=p.problem_instance_id))))
   ;end insert
   IF (error(serrormsg,0) != 0)
    SET serrormsg = concat("Error identifying codified problems for nomenclature update: ",serrormsg)
    GO TO exit_script
   ENDIF
  ENDIF
  CALL echo(sline)
  CALL echo(build2("Time to identify codified problems to update in seconds: ",trim(cnvtstring(((
      curtime3 - dstarttime)/ 100),12,2),3)))
  CALL echo(sline)
 ENDIF
 IF (((nfreetextprocessallind=1) OR (nfreetextprocessnomenind=1)) )
  SET dstarttime = curtime3
  IF (nfreetextprocessallind=1)
   INSERT  FROM temp_problem
    (problem_instance_id, person_id, temp_data_id,
    freetext_ind, nomenclature_id, orig_nomenclature_id,
    classification_cd, confirmation_status_cd, annotated_display,
    problem_ftdesc)(SELECT INTO "nl:"
     p.problem_instance_id, p.person_id, td.temp_data_id,
     1.0, td.new_nomenclature_id, td.new_orig_nomenclature_id,
     td.new_classification_cd, p.confirmation_status_cd, trim(p.annotated_display,3),
     null
     FROM temp_data td,
      problem p
     WHERE td.process_flag=nprocess_all
      AND td.nomenclature_id=0
      AND td.new_nomenclature_id > 0
      AND td.new_orig_nomenclature_id > 0
      AND td.new_classification_cd > 0
      AND trim(replace(p.problem_ftdesc,stab_delimiter," "),3)=td.problem_name
      AND p.nomenclature_id=0
      AND p.originating_nomenclature_id=0
      AND p.problem_id > 0
      AND p.person_id > 0
      AND p.problem_type_flag IN (0, 1)
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND p.classification_cd=td.classification_cd)
   ;end insert
   IF (error(serrormsg,0) != 0)
    SET serrormsg = concat("Error identifying free text problems for process all update: ",serrormsg)
    GO TO exit_script
   ENDIF
  ENDIF
  IF (nfreetextprocessnomenind=1)
   INSERT  FROM temp_problem
    (problem_instance_id, person_id, temp_data_id,
    freetext_ind, nomenclature_id, orig_nomenclature_id,
    classification_cd, confirmation_status_cd, annotated_display,
    problem_ftdesc)(SELECT INTO "nl:"
     p.problem_instance_id, p.person_id, td.temp_data_id,
     1.0, td.new_nomenclature_id, td.new_orig_nomenclature_id,
     p.classification_cd, p.confirmation_status_cd, trim(p.annotated_display,3),
     null
     FROM temp_data td,
      problem p
     WHERE td.process_flag=nprocess_nomen
      AND td.nomenclature_id=0
      AND td.new_nomenclature_id > 0
      AND td.new_orig_nomenclature_id > 0
      AND trim(replace(p.problem_ftdesc,stab_delimiter," "),3)=td.problem_name
      AND p.nomenclature_id=0
      AND p.originating_nomenclature_id=0
      AND p.problem_id > 0
      AND p.person_id > 0
      AND p.problem_type_flag IN (0, 1)
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND  NOT (p.problem_instance_id IN (
     (SELECT
      tp.problem_instance_id
      FROM temp_problem tp
      WHERE tp.problem_instance_id=p.problem_instance_id))))
   ;end insert
   IF (error(serrormsg,0) != 0)
    SET serrormsg = concat("Error identifying free text problems for nomenclature update: ",serrormsg
     )
    GO TO exit_script
   ENDIF
  ENDIF
  UPDATE  FROM temp_problem tp
   SET tp.annotated_display =
    (SELECT
     p.problem_ftdesc
     FROM problem p
     WHERE p.problem_instance_id=tp.problem_instance_id)
   PLAN (tp
    WHERE tp.problem_instance_id > 0
     AND tp.person_id > 0
     AND tp.freetext_ind=1
     AND tp.annotated_display IN (null, "")
     AND tp.orig_nomenclature_id != dcernernkpnomenid)
   WITH nocounter
  ;end update
  IF (error(serrormsg,0) != 0)
   SET serrormsg = concat("Error updating annotated_display on temp_problem: ",serrormsg)
   GO TO exit_script
  ENDIF
  CALL echo(sline)
  CALL echo(build2("Time to identify free text problems to update in seconds: ",trim(cnvtstring(((
      curtime3 - dstarttime)/ 100),12,2),3)))
  CALL echo(sline)
 ENDIF
 IF (((ncodifiedprocessclassind=1) OR (nfreetextprocessclassind=1)) )
  SET dstarttime = curtime3
  IF (ncodifiedprocessclassind=1)
   INSERT  FROM temp_problem
    (problem_instance_id, person_id, temp_data_id,
    freetext_ind, nomenclature_id, orig_nomenclature_id,
    classification_cd, confirmation_status_cd, annotated_display,
    problem_ftdesc)(SELECT INTO "nl:"
     p.problem_instance_id, p.person_id, td.temp_data_id,
     0.0, p.nomenclature_id, p.originating_nomenclature_id,
     td.new_classification_cd, p.confirmation_status_cd, p.annotated_display,
     p.problem_ftdesc
     FROM temp_data td,
      problem p
     WHERE td.process_flag=nprocess_class
      AND td.nomenclature_id > 0
      AND td.new_classification_cd > 0
      AND ((p.nomenclature_id=td.nomenclature_id
      AND p.originating_nomenclature_id=0) OR (p.originating_nomenclature_id=td.nomenclature_id))
      AND p.nomenclature_id > 0
      AND p.problem_id > 0
      AND p.person_id > 0
      AND p.problem_type_flag IN (0, 1)
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND p.classification_cd=td.classification_cd
      AND  NOT (p.problem_instance_id IN (
     (SELECT
      tp.problem_instance_id
      FROM temp_problem tp
      WHERE tp.problem_instance_id=p.problem_instance_id))))
   ;end insert
   IF (error(serrormsg,0) != 0)
    SET serrormsg = concat("Error identifying codified problems for classification update: ",
     serrormsg)
    GO TO exit_script
   ENDIF
  ENDIF
  IF (nfreetextprocessclassind=1)
   INSERT  FROM temp_problem
    (problem_instance_id, person_id, temp_data_id,
    freetext_ind, nomenclature_id, orig_nomenclature_id,
    classification_cd, confirmation_status_cd, annotated_display,
    problem_ftdesc)(SELECT INTO "nl:"
     p.problem_instance_id, p.person_id, td.temp_data_id,
     1.0, p.nomenclature_id, p.originating_nomenclature_id,
     td.new_classification_cd, p.confirmation_status_cd, p.annotated_display,
     p.problem_ftdesc
     FROM temp_data td,
      problem p
     WHERE td.process_flag=nprocess_class
      AND td.nomenclature_id=0
      AND td.new_classification_cd > 0
      AND trim(replace(p.problem_ftdesc,stab_delimiter," "),3)=td.problem_name
      AND p.nomenclature_id=0
      AND p.originating_nomenclature_id=0
      AND p.problem_id > 0
      AND p.person_id > 0
      AND p.problem_type_flag IN (0, 1)
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND p.classification_cd=td.classification_cd
      AND  NOT (p.problem_instance_id IN (
     (SELECT
      tp.problem_instance_id
      FROM temp_problem tp
      WHERE tp.problem_instance_id=p.problem_instance_id))))
   ;end insert
   IF (error(serrormsg,0) != 0)
    SET serrormsg = concat("Error identifying free text problems for classification update: ",
     serrormsg)
    GO TO exit_script
   ENDIF
  ENDIF
  CALL echo(sline)
  CALL echo(build2("Time to identify problems for classification update in seconds: ",trim(cnvtstring
     (((curtime3 - dstarttime)/ 100),12,2),3)))
  CALL echo(sline)
 ENDIF
 COMMIT
 SELECT INTO "nl:"
  FROM temp_problem tp
  PLAN (tp
   WHERE tp.problem_instance_id > 0
    AND tp.person_id > 0)
  ORDER BY tp.person_id
  HEAD REPORT
   lcnt = 0, ltotalprobcnt = 0
  HEAD tp.person_id
   lcnt = (lcnt+ 1)
   IF (mod(lcnt,100)=1)
    dstat = alterlist(person->qual,(lcnt+ 99))
   ENDIF
   person->qual[lcnt].person_id = tp.person_id
  DETAIL
   ltotalprobcnt = (ltotalprobcnt+ 1)
  FOOT  tp.person_id
   dstat = 0
  FOOT REPORT
   dstat = alterlist(person->qual,lcnt), person->qual_cnt = lcnt
  WITH nocounter
 ;end select
 IF (error(serrormsg,0) != 0)
  SET serrormsg = concat("Error identifying unique list of person_id values: ",serrormsg)
  GO TO exit_script
 ENDIF
 IF (ltotalprobcnt > 0)
  SELECT INTO "nl:"
   FROM prsnl p
   PLAN (p
    WHERE p.name_last_key="SYSTEM"
     AND p.name_first_key="SYSTEM"
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY p.person_id
   DETAIL
    dprsnlid = p.person_id
   WITH maxqual(p,1)
  ;end select
  IF (error(serrormsg,0) != 0)
   SET serrormsg = concat("Error retrieving SYSTEM user: ",serrormsg)
   GO TO exit_script
  ENDIF
  IF (dcernernkpnomenid > 0)
   UPDATE  FROM temp_problem tp
    SET tp.nomenclature_id = dcernernkpnomenid, tp.classification_cd = 0.0, tp.confirmation_status_cd
      = 0.0
    WHERE tp.orig_nomenclature_id=dcernernkpnomenid
   ;end update
   IF (error(serrormsg,0) != 0)
    SET serrormsg = concat("Error updating temp_problem for NKP: ",serrormsg)
    GO TO exit_script
   ENDIF
   UPDATE  FROM temp_problem tp
    SET tp.annotated_display = scernernkpdisplay
    WHERE tp.orig_nomenclature_id=dcernernkpnomenid
     AND tp.annotated_display IN (null, "")
   ;end update
   IF (error(serrormsg,0) != 0)
    SET serrormsg = concat("Error updating annotated_display on temp_problem for NKP: ",serrormsg)
    GO TO exit_script
   ENDIF
  ENDIF
  EXECUTE ccluarxrtl
  SET lcnt = 1
  WHILE (lcnt > 0)
    SET suuid = uar_createuuid(0)
    UPDATE  FROM temp_problem tp
     SET tp.problem_instance_uuid = suuid
     WHERE tp.problem_instance_uuid=null
     WITH maxqual(tp,1)
    ;end update
    IF (error(serrormsg,0) != 0)
     SET serrormsg = concat("Error updating problem_instance_uuid on temp_problem: ",serrormsg)
     GO TO exit_script
    ENDIF
    SET lcnt = curqual
  ENDWHILE
  COMMIT
 ENDIF
 FOR (lcnt = 1 TO person->qual_cnt)
   SET ncommitind = 0
   INSERT  FROM problem
    (active_ind, actual_resolution_dt_tm, beg_effective_tz,
    cancel_reason_cd, certainty_cd, cond_type_flag,
    contributor_system_cd, course_cd, del_ind,
    estimated_resolution_dt_tm, family_aware_cd, laterality_cd,
    life_cycle_dt_cd, life_cycle_dt_flag, life_cycle_dt_tm,
    life_cycle_status_cd, life_cycle_tz, onset_dt_cd,
    onset_dt_flag, onset_dt_tm, onset_tz,
    organization_id, persistence_cd, person_aware_cd,
    person_aware_prognosis_cd, person_id, probability,
    problem_id, problem_type_flag, problem_uuid,
    prognosis_cd, qualifier_cd, ranking_cd,
    sensitivity, severity_cd, severity_class_cd,
    severity_ftdesc, show_in_pm_history_ind, status_updt_dt_tm,
    status_updt_flag, status_updt_precision_cd, active_status_cd,
    active_status_dt_tm, active_status_prsnl_id, annotated_display,
    beg_effective_dt_tm, classification_cd, confirmation_status_cd,
    data_status_cd, data_status_dt_tm, data_status_prsnl_id,
    end_effective_dt_tm, nomenclature_id, originating_nomenclature_id,
    problem_ftdesc, problem_instance_id, problem_instance_uuid,
    updt_applctx, updt_cnt, updt_dt_tm,
    updt_id, updt_task)(SELECT
     p.active_ind, p.actual_resolution_dt_tm, p.beg_effective_tz,
     p.cancel_reason_cd, p.certainty_cd, p.cond_type_flag,
     p.contributor_system_cd, p.course_cd, p.del_ind,
     p.estimated_resolution_dt_tm, p.family_aware_cd, p.laterality_cd,
     p.life_cycle_dt_cd, p.life_cycle_dt_flag, p.life_cycle_dt_tm,
     p.life_cycle_status_cd, p.life_cycle_tz, p.onset_dt_cd,
     p.onset_dt_flag, p.onset_dt_tm, p.onset_tz,
     p.organization_id, p.persistence_cd, p.person_aware_cd,
     p.person_aware_prognosis_cd, p.person_id, p.probability,
     p.problem_id, p.problem_type_flag, p.problem_uuid,
     p.prognosis_cd, p.qualifier_cd, p.ranking_cd,
     p.sensitivity, p.severity_cd, p.severity_class_cd,
     p.severity_ftdesc, p.show_in_pm_history_ind, p.status_updt_dt_tm,
     p.status_updt_flag, p.status_updt_precision_cd, active_status_cd = dactive,
     active_status_dt_tm = cnvtdatetime(curdate,curtime3), active_status_prsnl_id = dprsnlid,
     annotated_display = tp.annotated_display,
     beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), classification_cd = tp.classification_cd,
     confirmation_status_cd = tp.confirmation_status_cd,
     data_status_cd = dauth, data_status_dt_tm = cnvtdatetime(curdate,curtime3), data_status_prsnl_id
      = dprsnlid,
     end_effective_dt_tm = cnvtdatetime("31-DEC-2100 23:59:59.99"), nomenclature_id = tp
     .nomenclature_id, originating_nomenclature_id = tp.orig_nomenclature_id,
     problem_ftdesc = tp.problem_ftdesc, problem_instance_id = cnvtreal(seq(problem_seq,nextval)),
     problem_instance_uuid = tp.problem_instance_uuid,
     updt_applctx = reqinfo->updt_applctx, updt_cnt = 0, updt_dt_tm = cnvtdatetime(curdate,curtime3),
     updt_id = dprsnlid, updt_task = reqinfo->updt_task
     FROM temp_problem tp,
      problem p
     WHERE (tp.person_id=person->qual[lcnt].person_id)
      AND tp.problem_instance_id > 0
      AND  NOT (tp.problem_instance_uuid IN (null, ""))
      AND p.problem_instance_id=tp.problem_instance_id
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   ;end insert
   SET linsertcnt = curqual
   IF (error(serrormsg,0) != 0)
    SET serrormsg = concat("Error during insert of problems: ",serrormsg)
    GO TO exit_script
   ELSE
    IF (linsertcnt > 0)
     UPDATE  FROM problem p
      SET p.active_ind = 0, p.active_status_cd = dinactive, p.active_status_dt_tm = cnvtdatetime(
        curdate,curtime3),
       p.active_status_prsnl_id = dprsnlid, p.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), p
       .updt_applctx = reqinfo->updt_applctx,
       p.updt_cnt = (p.updt_cnt+ 1), p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id =
       dprsnlid,
       p.updt_task = reqinfo->updt_task
      WHERE p.problem_instance_id IN (
      (SELECT
       tp.problem_instance_id
       FROM temp_problem tp
       WHERE (tp.person_id=person->qual[lcnt].person_id)
        AND tp.problem_instance_id > 0
        AND  NOT (tp.problem_instance_uuid IN (null, ""))))
       AND p.active_ind=1
       AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     ;end update
     SET lupdatecnt = curqual
     IF (error(serrormsg,0) != 0)
      SET serrormsg = concat("Error during update of problems: ",serrormsg)
      GO TO exit_script
     ELSE
      IF (lupdatecnt=linsertcnt)
       SET ncommitind = 1
       SET ltotalprobupdcnt = (ltotalprobupdcnt+ lupdatecnt)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (ncommitind=1)
    IF (ndebugind=0)
     COMMIT
    ENDIF
   ELSE
    ROLLBACK
   ENDIF
 ENDFOR
 SUBROUTINE createproposedtermerrorreport(null)
   DECLARE ncreatereportind = i2 WITH protect, noconstant(0)
   DECLARE snomenclatureid = vc WITH protect, noconstant("")
   DECLARE sproblemname = vc WITH protect, noconstant("")
   DECLARE sproposedsource = vc WITH protect, noconstant("")
   DECLARE sproposedtarget = vc WITH protect, noconstant("")
   DECLARE serrorreason = vc WITH protect, noconstant("")
   FOR (lcnt = 1 TO data->qual_cnt)
     IF ( NOT ((data->qual[lcnt].error_flag IN (nerror_none))))
      SET ncreatereportind = 1
      SET lcnt = data->qual_cnt
     ENDIF
   ENDFOR
   IF (ncreatereportind=1)
    SET sfilename = concat("proposed_term_error_rpt_",format(cnvtdatetime(curdate,curtime3),
      "YYYYMMDDHHMMSS;;q"),".csv")
    SELECT INTO value(concat("ccluserdir:",sfilename))
     problem_name = cnvtupper(data->qual[d.seq].problem_name)
     FROM (dummyt d  WITH seq = value(data->qual_cnt))
     PLAN (d
      WHERE  NOT ((data->qual[d.seq].error_flag IN (nerror_none))))
     ORDER BY problem_name
     HEAD REPORT
      "NOMENCLATURE_ID", ",", "PROBLEM_NAME",
      ",", "PROPOSED_SOURCE", ",",
      "PROPOSED_TARGET", ",", "ERROR_REASON"
     DETAIL
      row + 1, snomenclatureid = concat('"',trim(format(data->qual[d.seq].nomenclature_id,";;f"),3),
       '"'), sproblemname = concat('"',trim(data->qual[d.seq].problem_name,3),'"'),
      sproposedsource = concat('"',data->qual[d.seq].source_concept_cki,'"'), sproposedtarget =
      IF ((data->qual[d.seq].nomenclature_id > 0)) concat('"'," ",'"')
      ELSE concat('"',data->qual[d.seq].target_concept_cki,'"')
      ENDIF
      , serrorreason =
      IF ((data->qual[d.seq].error_flag=nerror_source_ident_lookup)) concat('"',
        "Proposed source could not be identified",'"')
      ELSEIF ((data->qual[d.seq].error_flag=nerror_target_ident_lookup)) concat('"',
        "Proposed target could not be identified",'"')
      ENDIF
      ,
      snomenclatureid, ",", sproblemname,
      ",", sproposedsource, ",",
      sproposedtarget, ",", serrorreason
     WITH format = variable, maxcol = 1000, maxrow = 1,
      nocounter, noheading
    ;end select
    CALL echo(sline)
    CALL echo(build2("Error report created in CCLUSERDIR: ",sfilename))
   ENDIF
 END ;Subroutine
 SUBROUTINE getconceptcki(sconceptvalue,dvocabularycd)
   DECLARE sprefix = vc WITH private, noconstant("")
   DECLARE scdfmeaning = vc WITH private, noconstant("")
   IF (findstring("!",sconceptvalue)=0)
    SET scdfmeaning = uar_get_code_meaning(dvocabularycd)
    IF (scdfmeaning="SNMCT")
     SET sprefix = "SNOMED"
    ELSEIF (scdfmeaning="ICD9")
     SET sprefix = "ICD9CM"
    ELSE
     SET sprefix = scdfmeaning
    ENDIF
    SET sconceptvalue = concat(sprefix,"!",sconceptvalue)
   ENDIF
   RETURN(sconceptvalue)
 END ;Subroutine
#exit_script
 IF (ntemptableind=1
  AND ndebugind=0)
  RDB drop table temp_data
  END ;Rdb
  DROP TABLE temp_data
  RDB drop table temp_problem
  END ;Rdb
  DROP TABLE temp_problem
 ENDIF
 IF (nidentlookupind=1)
  CALL createproposedtermerrorreport(null)
 ENDIF
 IF (textlen(trim(stargetvocaberrormsg,3)) > 0)
  CALL echo(sline)
  CALL echo(stargetvocaberrormsg)
 ENDIF
 IF (textlen(trim(serrormsg,3)) > 0)
  CALL echo(sline)
  CALL echo(serrormsg)
  ROLLBACK
 ENDIF
 IF (ltotalprobcnt > 0)
  CALL echo(sline)
  CALL echo(build2("Problems updated: ",trim(format(ltotalprobupdcnt,";;i"),3)," of ",trim(format(
      ltotalprobcnt,";;i"),3)))
 ELSE
  CALL echo(sline)
  CALL echo("No problems were updated")
 ENDIF
 CALL echo(sline)
 CALL echo(build2("Script elapsed time in seconds: ",trim(cnvtstring(((curtime3 - dscripttime)/ 100),
     12,2),3)))
 CALL echo(sline)
 FREE RECORD data
 FREE RECORD person
END GO
