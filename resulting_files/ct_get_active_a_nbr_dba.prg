CREATE PROGRAM ct_get_active_a_nbr:dba
 DECLARE activated_cd = f8 WITH protect, noconstant(0.0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 SET last_mod = "006"
 SET mod_date = "Apr 10, 2006"
 SET stat = uar_get_meaning_by_codeset(17274,"ACTIVATED",1,activated_cd)
 SELECT INTO "NL:"
  pr_am.amendment_nbr, pr_am.prot_amendment_id, pr_am.amendment_dt_tm,
  pr_am.revision_ind, pr_am.revision_nbr_txt
  FROM prot_amendment pr_am
  PLAN (pr_am
   WHERE pr_am.prot_master_id=pmid
    AND pr_am.amendment_status_cd=activated_cd)
  DETAIL
   activeamdnbr = pr_am.amendment_nbr, activeamdid = pr_am.prot_amendment_id, activedttm = pr_am
   .amendment_dt_tm,
   activerevisionnbrtxt = pr_am.revision_nbr_txt, activerevisionind = pr_am.revision_ind
  WITH nocounter
 ;end select
 IF (curqual != 1)
  SET activeamdnbr = - (9)
  SET activeamdid = - (9)
  SET activerevisionnbrtxt = ""
  SET activerevisionind = 0
 ENDIF
END GO
