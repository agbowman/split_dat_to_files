CREATE PROGRAM ct_get_last_a_nbr:dba
 SET trace = error
 SET nbr = - (9)
 SET id = - (9)
 SELECT INTO "NL:"
  pr_am.amendment_nbr, pr_am.prot_amendment_id
  FROM prot_amendment pr_am
  PLAN (pr_am
   WHERE pr_am.prot_master_id=pmid)
  DETAIL
   IF (nbr < pr_am.amendment_nbr)
    nbr = pr_am.amendment_nbr, id = pr_am.prot_amendment_id
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET lastamdnbr = - (9)
  SET lastamdid = - (9)
 ELSE
  SET lastamdid = id
  SET lastamdnbr = nbr
 ENDIF
 GO TO noecho
 CALL echo("LastAmdNbr = ",0)
 CALL echo(lastamdnbr,1)
 CALL echo("LastAmdID = ",0)
 CALL echo(lastamdid,1)
#noecho
END GO
