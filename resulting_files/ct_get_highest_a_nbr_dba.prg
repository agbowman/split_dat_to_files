CREATE PROGRAM ct_get_highest_a_nbr:dba
 SET trace = error
 SET highestamdnbr = - (9)
 SELECT INTO "NL:"
  pr_am.amendment_nbr, pr_am.prot_amendment_id
  FROM prot_amendment pr_am,
   prot_master pr_m
  PLAN (pr_m
   WHERE pr_m.prot_master_id=pmid)
   JOIN (pr_am
   WHERE pr_am.prot_master_id=pr_m.prot_master_id
    AND pr_am.amendment_status_cd=pr_m.prot_status_cd)
  DETAIL
   IF (pr_am.amendment_nbr > highestamdnbr)
    highestamdnbr = pr_am.amendment_nbr, highestamdid = pr_am.prot_amendment_id
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET highestamdnbr = - (9)
  SET highestamdid = - (9)
 ENDIF
 CALL echo("HighestAmdNbr = ",0)
 CALL echo(highestamdnbr,1)
 CALL echo("HighestAmdID = ",0)
 CALL echo(highestamdid,1)
#noecho
END GO
