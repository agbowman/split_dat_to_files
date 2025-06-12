CREATE PROGRAM cps_ens_normalized_index:dba
 RECORD string_index(
   1 str = vc
   1 strlist[0]
     2 normalized_string = vc
   1 language_cd = f8
   1 active_status_cd = f8
 )
 SET m1 =  $1
 SET buflen = 1000
 SET outstr = fillstring(1000," ")
 SET wcard = " "
 SET wcard2 = ""
 SET wcount = 0
 SET next_code = 0.0
 SET stat = alter(string_index->strlist,0)
 SET tempstr = fillstring(1000," ")
 DELETE  FROM normalized_string_index n
  WHERE n.nomenclature_id=m1
 ;end delete
 DECLARE eng_cd = f8
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=36
   AND c.cdf_meaning="ENG"
  DETAIL
   eng_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  n.nomenclature_id, n.source_string, n.string_identifier
  FROM nomenclature n,
   code_value c2
  PLAN (n
   WHERE n.nomenclature_id=m1)
   JOIN (c2
   WHERE c2.code_set=48
    AND c2.cdf_meaning="ACTIVE")
  DETAIL
   tempstr = nullterm(n.source_string),
   CALL uar_normalize_string(nullterm(tempstr),outstr,nullterm(wcard2),buflen,wcount), string_index->
   str = trim(outstr,3)
   IF (n.language_cd > 0.0)
    string_index->language_cd = n.language_cd
   ELSE
    string_index->language_cd = eng_cd
   ENDIF
   string_index->active_status_cd = c2.code_value
  WITH nocounter
 ;end select
 IF (wcount > 0)
  SET stat = alter(string_index->strlist,(wcount+ 1))
  FOR (i = 1 TO wcount)
    IF (i=1)
     SET string_index->strlist[i].normalized_string = fillstring(1000," ")
     SET string_index->strlist[i].normalized_string = string_index->str
     SET istr = fillstring(1000," ")
     SET istr = string_index->str
    ELSE
     SET string_index->strlist[i].normalized_string = fillstring(1000," ")
     SET ipos = findstring(wcard,istr)
     SET istr = substring((ipos+ 1),1000,trim(istr))
     SET string_index->strlist[i].normalized_string = trim(istr)
    ENDIF
  ENDFOR
 ENDIF
 FOR (i = 1 TO wcount)
   IF ( NOT ((string_index->strlist[i].normalized_string IN (" ", null))))
    SET the_string = fillstring(255," ")
    SET the_string = trim(string_index->strlist[i].normalized_string,3)
    EXECUTE cps_next_nom_seq
    INSERT  FROM normalized_string_index n
     SET n.normalized_string_id = next_code, n.language_cd = string_index->language_cd, n
      .nomenclature_id = m1,
      n.normalized_string = concat(the_string," "), n.updt_cnt = 0, n.updt_dt_tm = cnvtdatetime(
       curdate,curtime3),
      n.updt_id = reqinfo->updt_id, n.updt_task = reqinfo->updt_task, n.updt_applctx = reqinfo->
      updt_applctx,
      n.active_ind = 1, n.active_status_cd = string_index->active_status_cd, n.active_status_dt_tm =
      cnvtdatetime(curdate,curtime3),
      n.active_status_prsnl_id = reqinfo->updt_id, n.beg_effective_dt_tm = cnvtdatetime(curdate,
       curtime3), n.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
     WITH nocounter
    ;end insert
   ENDIF
 ENDFOR
 COMMIT
END GO
