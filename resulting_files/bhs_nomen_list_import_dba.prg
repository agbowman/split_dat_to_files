CREATE PROGRAM bhs_nomen_list_import:dba
 CALL echo("Entering bhs_health_maint_prob_import")
 DECLARE listsize = i4 WITH protect, noconstant(0)
 DECLARE prsnlid = f8 WITH protect, noconstant(0.0)
 DECLARE filename = vc WITH protect, noconstant(" ")
 FREE RECORD allcki
 RECORD allcki(
   1 qual[*]
     2 nomenid = f8
     2 searchnomenid = vc
     2 concept_cki = vc
     2 concept_source_cd = f8
     2 nomen_list = c100
     2 nomen_list_key = c100
     2 source_string = vc
     2 status = c1
     2 status_txt = vc
 )
 SET filename = concat("bhsnomenlistimport",format(cnvtdatetime(curdate,curtime3),"MMDDYYYYHHMM;;d"))
 SELECT INTO "nl:"
  FROM prsnl p
  WHERE p.username=trim(curuser,3)
  DETAIL
   prsnlid = p.person_id
  WITH nocounter
 ;end select
 CALL echo(prsnlid)
 IF (curqual=0
  AND validate(reqinfo->updt_id,0) > 0)
  SET prsnlid = reqinfo->updt_id
 ENDIF
 CALL echo(prsnlid)
 SET listsize = size(requestin->list_0,5)
 CALL echo(build("list size:",listsize))
 SET stat = alterlist(allcki->qual,listsize)
 FOR (x = 1 TO listsize)
   SET allcki->qual[x].nomenid = cnvtreal(trim(requestin->list_0[x].nomenclature_id,3))
   SET allcki->qual[x].searchnomenid = concat("SNOMED!",trim(requestin->list_0[x].nomenclature_id,3),
    "*")
   SET allcki->qual[x].nomen_list = trim(requestin->list_0[x].nomen_list,3)
   SET allcki->qual[x].nomen_list_key = cnvtupper(replace(requestin->list_0[x].nomen_list," ","",0))
   SET allcki->qual[x].status = "F"
   SET allcki->qual[x].status_txt = "Row failed to processed"
   SET allcki->qual[x].source_string = trim(requestin->list_0[x].source_string,3)
 ENDFOR
 CALL echorecord(allcki)
 SELECT INTO "NL:"
  FROM nomenclature n,
   (dummyt d  WITH seq = listsize)
  PLAN (d)
   JOIN (n
   WHERE (n.nomenclature_id=allcki->qual[d.seq].nomenid))
  DETAIL
   allcki->qual[d.seq].concept_cki = n.concept_cki, allcki->qual[d.seq].concept_source_cd = n
   .source_vocabulary_cd, allcki->qual[d.seq].status_txt = "Nomen Found",
   allcki->qual[d.seq].status = "S",
   CALL echo(allcki->qual[d.seq].concept_cki),
   CALL echo(allcki->qual[d.seq].status)
  WITH nocounter, format
 ;end select
 SELECT INTO "NL:"
  n.source_string
  FROM nomenclature n,
   (dummyt d  WITH seq = size(allcki->qual,5))
  PLAN (d)
   JOIN (n
   WHERE operator(n.source_string,"like",patstring(allcki->qual[d.seq].source_string,1))
    AND (allcki->qual[d.seq].status_txt != "Nomen Found")
    AND n.active_ind=1
    AND ((n.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
    AND ((n.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3))
    AND ((n.source_vocabulary_cd+ 0)=778972.00)
    AND  NOT ((allcki->qual[d.seq].status IN ("S"))))
  ORDER BY n.source_string
  HEAD n.source_string
   cnt = 0, tempcki = n.concept_cki, tempsourcecd = n.source_vocabulary_cd,
   tmepstatus_txt = "Nomen Found"
  DETAIL
   cnt = (cnt+ 1)
  FOOT  n.source_string
   IF (cnt=1)
    allcki->qual[d.seq].nomenid = n.nomenclature_id, allcki->qual[d.seq].concept_cki = tempcki,
    allcki->qual[d.seq].concept_source_cd = tempsourcecd,
    allcki->qual[d.seq].status_txt = tmepstatus_txt, allcki->qual[d.seq].status = "S"
   ELSE
    allcki->qual[d.seq].status = "Z", allcki->qual[d.seq].status_txt =
    "Failed: no Nomen match or 2 or more string matches"
   ENDIF
  WITH nocounter, format
 ;end select
 SELECT INTO "NL:"
  n.source_string
  FROM nomenclature n,
   (dummyt d  WITH seq = size(allcki->qual,5))
  PLAN (d
   WHERE  NOT ((allcki->qual[d.seq].status IN ("S"))))
   JOIN (n
   WHERE operator(n.concept_cki,"like",patstring(allcki->qual[d.seq].searchnomenid,1))
    AND (allcki->qual[d.seq].status_txt != "Nomen Found")
    AND n.active_ind=1
    AND ((n.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
    AND ((n.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3))
    AND ((n.source_vocabulary_cd+ 0)=778972.00))
  ORDER BY n.concept_cki
  HEAD n.concept_cki
   IF (textlen(trim(n.concept_cki,3))=textlen(trim(n.concept_cki,3)))
    tempcki = n.concept_cki, tempsourcecd = n.source_vocabulary_cd, tmepstatus_txt = "Nomen Found"
   ENDIF
  FOOT  n.concept_cki
   IF (textlen(tempcki) > 0)
    allcki->qual[d.seq].nomenid = n.nomenclature_id, allcki->qual[d.seq].concept_cki = tempcki,
    allcki->qual[d.seq].concept_source_cd = tempsourcecd,
    allcki->qual[d.seq].status_txt = tmepstatus_txt, allcki->qual[d.seq].status = "S"
   ELSE
    allcki->qual[d.seq].status = "Z", allcki->qual[d.seq].status_txt =
    "Failed: no nomenclature match, no string match, found 2 or more snomedCds"
   ENDIF
  WITH nocounter, format
 ;end select
 SELECT INTO "NL:"
  FROM bhs_nomen_list b,
   (dummyt d  WITH seq = listsize)
  PLAN (d)
   JOIN (b
   WHERE (b.nomenclature_id=allcki->qual[d.seq].nomenid)
    AND b.nomen_list_key=trim(allcki->qual[d.seq].nomen_list_key,3))
  DETAIL
   allcki->qual[d.seq].status = "Z", allcki->qual[d.seq].status_txt =
   "Row already exists on the table"
  WITH nocounter
 ;end select
 INSERT  FROM (dummyt d  WITH seq = listsize),
   bhs_nomen_list b
  SET b.active_ind = 1, b.concept_cki = allcki->qual[d.seq].concept_cki, b.concept_source_cd = allcki
   ->qual[d.seq].concept_source_cd,
   b.nomen_list = allcki->qual[d.seq].nomen_list, b.nomen_list_key = allcki->qual[d.seq].
   nomen_list_key, b.nomenclature_id = allcki->qual[d.seq].nomenid,
   b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = prsnlid
  PLAN (d)
   JOIN (b
   WHERE (allcki->qual[d.seq].status IN ("S")))
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  FROM bhs_nomen_list b,
   (dummyt d  WITH seq = listsize)
  PLAN (d)
   JOIN (b
   WHERE b.nomenclature_id=outerjoin(allcki->qual[d.seq].nomenid)
    AND b.nomen_list_key=outerjoin(trim(allcki->qual[d.seq].nomen_list_key,3))
    AND (allcki->qual[d.seq].status=outerjoin("S")))
  DETAIL
   IF ((allcki->qual[d.seq].status="S"))
    IF (b.nomenclature_id > 0)
     allcki->qual[d.seq].status = "S", allcki->qual[d.seq].status_txt =
     "Row was successfully inserted into the table"
    ELSE
     allcki->qual[d.seq].status = "F", allcki->qual[d.seq].status_txt = "Row Failed to insert"
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 COMMIT
 CALL echorecord(allcki,filename)
 SELECT INTO value(filename)
  concept_cki = allcki->qual[d.seq].concept_cki, concept_source_cd = allcki->qual[d.seq].
  concept_source_cd, nomen_list = allcki->qual[d.seq].nomen_list,
  nomen_list_key = allcki->qual[d.seq].nomen_list_key, nomenclature_id = allcki->qual[d.seq].nomenid,
  updt_dt_tm = cnvtdatetime(curdate,curtime3),
  updt_id = prsnlid, string = substring(1,100,allcki->qual[d.seq].source_string)
  FROM (dummyt d  WITH seq = size(allcki->qual,5))
  PLAN (d
   WHERE cnvtupper(allcki->qual[d.seq].status) IN ("Z", "F"))
  WITH format, separator = " ", append
 ;end select
 SET last_mod = "000"
END GO
