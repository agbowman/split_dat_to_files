CREATE PROGRAM bhs_health_maint_upd_prob_list:dba
 PROMPT
  "Output-Printer/MINE" = "MINE",
  "" = "1",
  "List type (required):" = "",
  "Problems for list type:" = 0,
  "problems to add:" = 0,
  "Action" = ""
  WITH outdev, securitycheck, nomenlist,
  removeproblist, addproblist, action
 DECLARE promptvalueerr = i2 WITH protect, noconstant(0)
 DECLARE blankpromptmsg = vc WITH protect, noconstant(" ")
 DECLARE mf_snomed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",400,"SNMCT"))
 IF (( $ACTION="ADD")
  AND substring(1,1,reflect(parameter(5,0)))="I")
  SET promptvalueerr = 1
  SET blankpromptmsg = "You must select 1 or more items from the 'problems to add' listbox."
 ELSEIF (( $ACTION="REMOVE")
  AND substring(1,1,reflect(parameter(4,0)))="I")
  SET promptvalueerr = 1
  SET blankpromptmsg = "You must select 1 or more items from the 'problems for list type' listbox."
 ELSEIF (textlen(trim( $ACTION,3)) <= 1)
  SET promptvalueerr = 1
  SET blankpromptmsg = "You must select an action."
 ELSEIF (trim( $NOMENLIST,3)="")
  SET promptvalueerr = 1
  SET blankpromptmsg = "You must select a list."
 ENDIF
 CALL echo(substring(1,1,reflect(parameter(3,0))))
 IF (promptvalueerr=1)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = blankpromptmsg, msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/12}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_script
 ENDIF
 DECLARE prsnlid = f8 WITH protect, noconstant(0.0)
 DECLARE diagcnt = i4 WITH protect, noconstant(0)
 DECLARE nomenlistkey = vc WITH protect, noconstant(" ")
 DECLARE rowexistind = i2 WITH protect, noconstant(0)
 DECLARE listsize = i4 WITH protect, noconstant(0)
 DECLARE updcnt = i4 WITH protect, noconstant(0)
 DECLARE nomenlistl = vc WITH protect, noconstant(" ")
 SET nomenlistkey = cnvtupper(replace(trim( $NOMENLIST,3)," ","",0))
 SET nomenlistl = " "
 SELECT
  b.nomen_list_key
  FROM bhs_nomen_list b
  WHERE b.nomen_list_key=nomenlistkey
  DETAIL
   nomenlistl = trim(b.nomen_list,3)
  WITH maxrec = 1
 ;end select
 IF (curqual < 0)
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Failed finding list_type", msg2 = "  Please retry.", col 0,
    "{PS/792 0 translate 90 rotate/}", y_pos = 18, row + 1,
    "{F/1}{CPI/12}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1,
    row + 2, msg2
   WITH dio = 08, mine, time = 5
  ;end select
  GO TO exit_script
 ENDIF
 FREE RECORD allcki
 RECORD allcki(
   1 qual[*]
     2 nomenid = f8
     2 concept_cki = vc
     2 concept_source_cd = f8
     2 nomen_list = c100
     2 nomen_list_key = c100
     2 source_string = vc
     2 status = c1
     2 status_txt = vc
     2 existind = i2
 )
 IF (( $ACTION="OUTPUT"))
  SELECT INTO  $OUTDEV
   description = trim(n.source_string,3), sourcetype = uar_get_code_display(n.source_vocabulary_cd),
   sourcestringkey = trim(n.source_string_keycap,3),
   nomenid = n.nomenclature_id, vocabulary = uar_get_code_display(n.source_vocabulary_cd), code =
   IF (n.source_vocabulary_cd=mf_snomed_cd) trim(n.concept_cki)
   ELSE trim(n.source_identifier)
   ENDIF
   FROM bhs_nomen_list b,
    nomenclature n
   PLAN (b
    WHERE b.nomen_list_key=nomenlistkey
     AND b.active_ind=1
     AND b.nomenclature_id > 0)
    JOIN (n
    WHERE n.nomenclature_id=b.nomenclature_id)
   ORDER BY sourcestringkey
   WITH nocounter, seperator = " ", format
  ;end select
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM prsnl p
  WHERE p.username=trim(curuser,3)
  DETAIL
   prsnlid = p.person_id
  WITH nocounter
 ;end select
 IF (curqual=0
  AND validate(reqinfo->updt_id,0) > 0)
  SET prsnlid = reqinfo->updt_id
 ENDIF
 CALL echo(prsnlid)
 SELECT INTO "nl:"
  FROM nomenclature n,
   bhs_nomen_list b
  PLAN (n
   WHERE ((n.nomenclature_id IN ( $ADDPROBLIST)
    AND ( $ACTION="ADD")) OR (n.nomenclature_id IN ( $REMOVEPROBLIST)
    AND ( $ACTION="REMOVE"))) )
   JOIN (b
   WHERE b.nomenclature_id=outerjoin(n.nomenclature_id)
    AND b.nomen_list_key=outerjoin(nomenlistkey))
  DETAIL
   diagcnt = (diagcnt+ 1), stat = alterlist(allcki->qual,diagcnt), allcki->qual[diagcnt].concept_cki
    = n.concept_cki,
   allcki->qual[diagcnt].concept_source_cd = n.source_vocabulary_cd, allcki->qual[diagcnt].nomenid =
   n.nomenclature_id, allcki->qual[diagcnt].nomen_list = nomenlistl,
   allcki->qual[diagcnt].nomen_list_key = nomenlistkey
   IF (b.nomenclature_id > 0)
    allcki->qual[diagcnt].existind = 1, rowexistind = 1, allcki->qual[diagcnt].status = "Z",
    allcki->qual[diagcnt].status_txt = "Nomenclature found for update", allcki->qual[diagcnt].
    source_string = n.source_string
   ELSE
    allcki->qual[diagcnt].existind = 0, allcki->qual[diagcnt].status = "Z", allcki->qual[diagcnt].
    status_txt = "Nomenclature found for insert",
    allcki->qual[diagcnt].source_string = n.source_string
   ENDIF
  WITH nocounter, format
 ;end select
 SET listsize = size(allcki->qual,5)
 IF (( $ACTION="ADD"))
  CALL echo("Adding / updating rows")
  IF (rowexistind=1)
   CALL echo("atleast one row already exists on the table so update the activeInd to 1")
   UPDATE  FROM (dummyt d  WITH seq = listsize),
     bhs_nomen_list b
    SET b.active_ind = 1, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = prsnlid
    PLAN (d
     WHERE (allcki->qual[d.seq].existind=1))
     JOIN (b
     WHERE (b.nomenclature_id=allcki->qual[d.seq].nomenid)
      AND b.nomen_list_key=trim(allcki->qual[d.seq].nomen_list_key,3))
    WITH nocounter
   ;end update
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = listsize),
     bhs_nomen_list b
    PLAN (d
     WHERE (allcki->qual[d.seq].existind=1))
     JOIN (b
     WHERE b.nomenclature_id=outerjoin(allcki->qual[d.seq].nomenid)
      AND b.nomen_list_key=outerjoin(trim(allcki->qual[d.seq].nomen_list_key,3))
      AND b.active_ind=outerjoin(1))
    DETAIL
     IF (b.nomenclature_id > 0)
      allcki->qual[d.seq].status = "S", allcki->qual[d.seq].status_txt =
      "Row existed: activeInd set to 1", updcnt = (updcnt+ 1)
     ELSE
      allcki->qual[d.seq].status = "F", allcki->qual[d.seq].status_txt =
      "Row existed: Failed to set activeInd"
     ENDIF
    WITH nocounter
   ;end select
   CALL echo(build("updCnt:",updcnt))
   IF (curqual <= 0)
    CALL echo("Failed to update active ind on 1 or more items")
    GO TO exit_script
   ENDIF
  ENDIF
  IF (updcnt < listsize)
   CALL echo("Inserting rows")
   INSERT  FROM (dummyt d  WITH seq = listsize),
     bhs_nomen_list b
    SET b.active_ind = 1, b.concept_cki = allcki->qual[d.seq].concept_cki, b.concept_source_cd =
     allcki->qual[d.seq].concept_source_cd,
     b.nomen_list = allcki->qual[d.seq].nomen_list, b.nomen_list_key = allcki->qual[d.seq].
     nomen_list_key, b.nomenclature_id = allcki->qual[d.seq].nomenid,
     b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = prsnlid
    PLAN (d
     WHERE (allcki->qual[d.seq].existind=0))
     JOIN (b)
    WITH nocounter
   ;end insert
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = listsize),
     bhs_nomen_list b
    PLAN (d)
     JOIN (b
     WHERE b.nomenclature_id=outerjoin(allcki->qual[d.seq].nomenid)
      AND b.nomen_list_key=outerjoin(trim(allcki->qual[d.seq].nomen_list_key,3))
      AND b.active_ind=outerjoin(1))
    DETAIL
     IF (b.nomenclature_id > 0)
      allcki->qual[d.seq].status = "S", allcki->qual[d.seq].status_txt = "Row inserted", updcnt = (
      updcnt+ 1)
     ELSE
      allcki->qual[d.seq].status = "F", allcki->qual[d.seq].status_txt = "Failed to insert row"
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ELSEIF (( $ACTION="REMOVE"))
  CALL echo("Inactivating selected problem rows")
  UPDATE  FROM (dummyt d  WITH seq = listsize),
    bhs_nomen_list b
   SET b.active_ind = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = prsnlid
   PLAN (d)
    JOIN (b
    WHERE (b.nomenclature_id=allcki->qual[d.seq].nomenid)
     AND b.nomen_list_key=trim(allcki->qual[d.seq].nomen_list_key,3))
   WITH nocounter
  ;end update
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = listsize),
    bhs_nomen_list b
   PLAN (d
    WHERE (allcki->qual[d.seq].existind=1))
    JOIN (b
    WHERE b.nomenclature_id=outerjoin(allcki->qual[d.seq].nomenid)
     AND b.nomen_list_key=outerjoin(trim(allcki->qual[d.seq].nomen_list_key,3))
     AND b.active_ind=outerjoin(0))
   DETAIL
    IF (b.nomenclature_id > 0)
     allcki->qual[d.seq].status = "S", allcki->qual[d.seq].status_txt = "Row inactivated", updcnt = (
     updcnt+ 1)
    ELSE
     allcki->qual[d.seq].status = "F", allcki->qual[d.seq].status_txt = "Failed to inactivate row"
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 COMMIT
 CALL echorecord(allcki)
 SELECT INTO  $OUTDEV
  identifier = substring(0,100,allcki->qual[d.seq].source_string), status = allcki->qual[d.seq].
  status, status_txt = substring(0,100,allcki->qual[d.seq].status_txt),
  nomen_id = allcki->qual[d.seq].nomenid
  FROM (dummyt d  WITH seq = size(allcki->qual,5))
  PLAN (d)
  WITH nocounter, separator = " ", format
 ;end select
 SET filename = concat("bhshealthmaintupdprob",format(cnvtdatetime(curdate,curtime3),
   "MMDDYYYYHHMM;;d"))
 SELECT INTO value(value(build2("CCLUSERDIR:",filename)))
  nomen_id = allcki->qual[d.seq].nomenid, concept_cki = allcki->qual[d.seq].concept_cki,
  concept_source_cd = uar_get_code_display(allcki->qual[d.seq].concept_source_cd),
  nomen_list = substring(0,50,allcki->qual[d.seq].nomen_list), nomen_list_key = substring(0,50,allcki
   ->qual[d.seq].nomen_list_key), status = allcki->qual[d.seq].status,
  status_txt = substring(0,100,allcki->qual[d.seq].status_txt)
  FROM (dummyt d  WITH seq = size(allcki->qual,5))
  PLAN (d)
  WITH nocounter, separator = " ", format,
   pcformat('"',","), append
 ;end select
#exit_script
 FREE RECORD allcki
END GO
