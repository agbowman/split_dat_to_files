CREATE PROGRAM bhs_prob_import_source_string:dba
 CALL echo("Entering bhs_health_maint_prob_import")
 DECLARE listsize = i4 WITH protect, noconstant(0)
 DECLARE prsnlid = f8 WITH protect, noconstant(0.0)
 DECLARE filename = vc WITH protect, noconstant(" ")
 DECLARE totalcnt = i4 WITH protect, noconstant(0)
 FREE RECORD allnomen
 RECORD allnomen(
   1 qual[*]
     2 source_string = vc
     2 nomen_list = c100
 )
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
 SET totalcnt = size(requestin->list_0,5)
 CALL echo(build("list size:",totalcnt))
 SET stat = alterlist(allnomen->qual,totalcnt)
 FOR (x = 1 TO totalcnt)
  SET allnomen->qual[x].source_string = trim(requestin->list_0[x].source_string,3)
  SET allnomen->qual[x].nomen_list = trim(requestin->list_0[x].nomen_list,3)
 ENDFOR
 SELECT INTO "NL:"
  FROM nomenclature n,
   (dummyt d  WITH seq = totalcnt)
  PLAN (d)
   JOIN (n
   WHERE (n.source_string=allnomen->qual[d.seq].source_string)
    AND n.active_ind=1)
  ORDER BY n.source_string
  HEAD REPORT
   listsize = 0
  DETAIL
   listsize = (listsize+ 1), stat = alterlist(allcki->qual[d.seq],listsize), allcki->qual[listsize].
   concept_cki = n.concept_cki,
   allcki->qual[listsize].concept_source_cd = n.source_vocabulary_cd, allcki->qual[listsize].
   nomen_list = allnomen->qual[d.seq].nomen_list, allcki->qual[listsize].nomen_list_key = cnvtupper(
    replace(allnomen->qual[d.seq].nomen_list," ","",0)),
   allcki->qual[listsize].nomenid = n.nomenclature_id, allcki->qual[listsize].source_string =
   allnomen->qual[d.seq].source_string, allcki->qual[listsize].status = "S",
   allcki->qual[listsize].status_txt = "Nomen Found"
  WITH nocounter, format
 ;end select
 CALL echorecord(allcki)
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
