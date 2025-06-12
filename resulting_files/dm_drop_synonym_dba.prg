CREATE PROGRAM dm_drop_synonym:dba
 SET width = 132
 SUBROUTINE drop_syn(sname,sowner)
   IF (sowner="PUBLIC")
    CALL echo("*******")
    CALL echo(concat("RDB drop PUBLIC synonym ",sname," GO"))
    CALL parser(concat("RDB drop PUBLIC synonym ",sname," GO"),1)
    CALL echo("*******")
   ELSE
    CALL echo("*******")
    CALL echo(concat("RDB drop synonym ",sname," GO"))
    CALL parser(concat("RDB drop synonym ",sname," GO"),1)
    CALL echo("*******")
   ENDIF
   SELECT
    IF (((cnvtupper( $2)="NULL") OR (cnvtupper( $2)="")) )
     WHERE a.synonym_name=patstring(cnvtupper( $1))
      AND owner IN ("PUBLIC", currdbuser)
      AND db_link = null
    ELSE
    ENDIF
    INTO "nl:"
    FROM all_synonyms a
    WHERE a.synonym_name=patstring(cnvtupper(sname))
     AND owner=sowner
     AND db_link=patstring(cnvtupper( $2))
    WITH nocounter
   ;end select
   IF (curqual)
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 FREE RECORD synlst
 RECORD synlst(
   1 cnt = i2
   1 qual[*]
     2 name = vc
     2 owner = vc
     2 chk_flg = i2
 )
 SELECT
  IF (((cnvtupper( $2)="NULL") OR (cnvtupper( $2)="")) )
   WHERE a.synonym_name=patstring(cnvtupper( $1))
    AND owner IN ("PUBLIC", currdbuser)
    AND db_link = null
  ELSE
  ENDIF
  INTO "nl:"
  FROM all_synonyms a
  WHERE a.synonym_name=patstring(cnvtupper( $1))
   AND owner IN ("PUBLIC", currdbuser)
   AND db_link=patstring(cnvtupper( $2))
  HEAD REPORT
   synlst->cnt = 0, stat = alterlist(synlst->qual,synlst->cnt)
  DETAIL
   synlst->cnt = (synlst->cnt+ 1), stat = alterlist(synlst->qual,synlst->cnt), synlst->qual[synlst->
   cnt].name = a.synonym_name,
   synlst->qual[synlst->cnt].owner = a.owner, synlst->qual[synlst->cnt].chk_flg = 0
  WITH nocounter
 ;end select
 IF (curqual)
  IF ((synlst->cnt=1))
   SET synlst->qual[1].chk_flg = drop_syn(synlst->qual[1].name,synlst->qual[1].owner)
  ELSE
   FOR (xtz = 1 TO value(synlst->cnt))
     SET synlst->qual[xtz].chk_flg = drop_syn(synlst->qual[xtz].name,synlst->qual[xtz].owner)
   ENDFOR
  ENDIF
 ELSE
  CALL echo("*******")
  CALL echo(concat("The following synonym '",cnvtupper( $1),
    "' does not exist in the ALL_SYNONYMS table."))
  CALL echo("*******")
 ENDIF
 IF ((synlst->cnt=1))
  IF (synlst->qual[1].chk_flg)
   CALL echo(concat("SUCCESS: The following synonym ",synlst->qual[1].owner,".",synlst->qual[1].name,
     " was dropped."))
  ELSE
   CALL echo(concat("ERROR: The following synonym ",synlst->qual[1].owner,".",synlst->qual[1].name,
     " was NOT dropped."))
  ENDIF
 ELSE
  FOR (xt = 1 TO value(synlst->cnt))
    IF ((synlst->qual[xt].chk_flg=1))
     CALL echo(concat("SUCCESS: (",trim(cnvtstring(xt)),") The following synonym ",synlst->qual[xt].
       owner,".",
       synlst->qual[xt].name," was dropped."))
    ENDIF
  ENDFOR
  FOR (yt = 1 TO value(synlst->cnt))
    IF ((synlst->qual[yt].chk_flg=0))
     CALL echo(concat("ERROR: (",trim(cnvtstring(yt)),") The following synonym ",synlst->qual[yt].
       owner,".",
       synlst->qual[yt].name," was NOT dropped."))
    ENDIF
  ENDFOR
 ENDIF
#end_program
END GO
