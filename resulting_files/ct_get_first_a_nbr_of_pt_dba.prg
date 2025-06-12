CREATE PROGRAM ct_get_first_a_nbr_of_pt:dba
 SET trace = error
 SET nbr = 9999999
 SET id = 0.0
 SELECT INTO "NL:"
  pr_am.amendment_nbr, pr_am.prot_amendment_id
  FROM prot_amendment pr_am,
   ct_pt_amd_assignment cpaa
  PLAN (cpaa
   WHERE cpaa.reg_id=regid
    AND cpaa.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (pr_am
   WHERE pr_am.prot_amendment_id=ppr.prot_amendment_id)
  ORDER BY cpaa.beg_effective_dt_tm
  HEAD cpaa.beg_effective_dt_tm
   nbr = pr_am.amendment_nbr, id = pr_am.prot_amendment_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET firstamdnbr = - (9)
  SET firstamdid = - (9)
 ELSE
  SET firstamdid = id
  SET firstamdnbr = nbr
 ENDIF
 GO TO noecho
 CALL echo(build("FirstAmdNbr = ",firstamdnbr))
 CALL echo(build("FirstAmdID = ",firstamdid))
#noecho
END GO
