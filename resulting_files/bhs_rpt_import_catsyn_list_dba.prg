CREATE PROGRAM bhs_rpt_import_catsyn_list:dba
 DECLARE mn_listsize = i4 WITH protect, noconstant(0)
 DECLARE mf_prsnlid = f8 WITH protect, noconstant(0.0)
 DECLARE ms_filename = vc WITH protect, noconstant(" ")
 DECLARE mf_realuserid = f8 WITH protect, noconstant(0.0)
 SET updt_dt_tm = cnvtdatetime(curdate,curtime3)
 FREE RECORD allord
 RECORD allord(
   1 qual[*]
     2 catalog_cd = f8
     2 synonym_id = f8
     2 list = c100
     2 list_key = c100
     2 status = c1
     2 status_txt = vc
 )
 SET ms_filename = concat("bhsivtopolistimport",format(cnvtdatetime(curdate,curtime3),
   "MMDDYYYYHHMM;;d"))
 IF (validate(reqinfo->updt_id) > 0
  AND (reqinfo->updt_id > 0))
  SET mf_realuserid = reqinfo->updt_id
 ELSE
  SET mf_realuserid = curuser
 ENDIF
 SELECT INTO "nl:"
  FROM prsnl p
  WHERE p.person_id=mf_realuserid
  DETAIL
   mf_prsnlid = p.person_id
  WITH nocounter
 ;end select
 CALL echo(mf_prsnlid)
 IF (curqual=0
  AND validate(reqinfo->updt_id,0) > 0)
  SET mf_prsnlid = reqinfo->updt_id
 ENDIF
 CALL echo(mf_prsnlid)
 SET mn_listsize = size(requestin->list_0,5)
 CALL echo(build("list size:",mn_listsize))
 SET stat = alterlist(allord->qual,mn_listsize)
 FOR (x = 1 TO mn_listsize)
   SET allord->qual[x].catalog_cd =
   IF (textlen(trim(requestin->list_0[x].catalog_cd,3)) > 0) cnvtreal(trim(requestin->list_0[x].
      catalog_cd,3))
   ELSE 0.0
   ENDIF
   SET allord->qual[x].synonym_id =
   IF (textlen(trim(requestin->list_0[x].synonym_id,3)) > 0) cnvtreal(trim(requestin->list_0[x].
      synonym_id,3))
   ELSE 0.0
   ENDIF
   SET allord->qual[x].list = trim(requestin->list_0[x].list,3)
   SET allord->qual[x].list_key = check(cnvtupper(replace(requestin->list_0[x].list," ","",0)),64)
   IF ((((allord->qual[x].catalog_cd > 0)) OR ((allord->qual[x].synonym_id > 0)))
    AND textlen(allord->qual[x].list) > 0)
    SET allord->qual[x].status = "U"
    SET allord->qual[x].status_txt = "Unprocessed"
   ELSE
    SET allord->qual[x].status = "F"
    SET allord->qual[x].status_txt = "Missing required field"
   ENDIF
   IF (((allord->qual[d.seq].synonym_id+ allord->qual[d.seq].catalog_cd) <= 0))
    CALL echo("catCd and SynonymId both are zero")
    SET allord->qual[d.seq].status = "F"
    SET allord->qual[d.seq].status_txt = "catCd and SynId are both zero"
   ENDIF
 ENDFOR
 CALL echorecord(allord)
 CALL echo("validate we have a true catCd or SynonymId")
 SELECT INTO "NL:"
  d.seq
  FROM order_catalog_synonym ocs,
   (dummyt d  WITH seq = mn_listsize),
   dummyt d1
  PLAN (d)
   JOIN (d1)
   JOIN (ocs
   WHERE  NOT ((allord->qual[d.seq].status IN ("F", "Z")))
    AND (((ocs.catalog_cd=allord->qual[d.seq].catalog_cd)) OR ((allord->qual[d.seq].catalog_cd=0)))
    AND (((ocs.synonym_id=allord->qual[d.seq].synonym_id)) OR ((allord->qual[d.seq].synonym_id=0))) )
  HEAD d.seq
   IF (ocs.synonym_id <= 0)
    CALL echo("catCd or SynonymId is invalid"), allord->qual[d.seq].status = "F", allord->qual[d.seq]
    .status_txt = "catCd or SynId is invalid"
   ENDIF
  WITH nocounter, outerjoin = d1
 ;end select
 CALL echo("check to see if the row already exists on the table")
 SELECT INTO "NL:"
  FROM bhs_ordcatsyn_list b,
   (dummyt d  WITH seq = mn_listsize)
  PLAN (d)
   JOIN (b
   WHERE  NOT ((allord->qual[d.seq].status IN ("F", "Z")))
    AND trim(b.list_key,3)=trim(allord->qual[d.seq].list_key,3)
    AND (((b.catalog_cd=allord->qual[d.seq].catalog_cd)) OR ((allord->qual[d.seq].catalog_cd=0)))
    AND (((b.synonym_id=allord->qual[d.seq].synonym_id)) OR ((allord->qual[d.seq].synonym_id=0))) )
  DETAIL
   CALL echo("row exists"), allord->qual[d.seq].status = "Z", allord->qual[d.seq].status_txt =
   "Row already exists on the table"
  WITH nocounter
 ;end select
 CALL echorecord(allord)
 CALL echo("insert rows into bhs_list")
 INSERT  FROM (dummyt d  WITH seq = mn_listsize),
   bhs_ordcatsyn_list b
  SET b.active_ind = 1, b.catalog_cd = allord->qual[d.seq].catalog_cd, b.synonym_id = allord->qual[d
   .seq].synonym_id,
   b.list = allord->qual[d.seq].list, b.list_key = allord->qual[d.seq].list_key, b.updt_dt_tm =
   cnvtdatetime(updt_dt_tm),
   b.updt_id = mf_prsnlid
  PLAN (d
   WHERE  NOT ((allord->qual[d.seq].status IN ("F", "Z"))))
   JOIN (b)
  WITH nocounter
 ;end insert
 CALL echorecord(allord)
 CALL echo("validate if the row was inserted")
 SELECT INTO "NL:"
  FROM bhs_ordcatsyn_list b,
   (dummyt d  WITH seq = mn_listsize)
  PLAN (d)
   JOIN (b
   WHERE trim(b.list_key,3)=trim(allord->qual[d.seq].list_key,3)
    AND b.catalog_cd IN (allord->qual[d.seq].catalog_cd, null, 0)
    AND b.synonym_id IN (allord->qual[d.seq].synonym_id, null, 0))
  DETAIL
   IF ( NOT ((allord->qual[d.seq].status IN ("F", "Z"))))
    IF (((b.catalog_cd > 0) OR (b.synonym_id > 0)) )
     allord->qual[d.seq].status = "S", allord->qual[d.seq].status_txt =
     "Row was successfully inserted into the table"
    ELSE
     allord->qual[d.seq].status = "F", allord->qual[d.seq].status_txt = "Row Failed to insert"
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(allord)
 COMMIT
 CALL echorecord(allord,ms_filename)
 CALL echo("Creating Output logFile")
 SELECT INTO value(ms_filename)
  active_ind = 1, catalog_cd = allord->qual[d.seq].catalog_cd, synonym_id = allord->qual[d.seq].
  synonym_id,
  list = substring(1,100,allord->qual[d.seq].list), list_key = substring(1,100,allord->qual[d.seq].
   list_key), status = substring(1,1,allord->qual[d.seq].status),
  status = substring(1,100,allord->qual[d.seq].status_txt), updt_dt_tm = substring(1,20,format(
    cnvtdatetime(updt_dt_tm),";;q")), updt_id = mf_prsnlid
  FROM (dummyt d  WITH seq = mn_listsize)
  PLAN (d)
  WITH format, separator = " ", append
 ;end select
 SET last_mod = "000"
END GO
