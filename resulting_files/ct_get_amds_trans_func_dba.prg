CREATE PROGRAM ct_get_amds_trans_func:dba
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE amd_status_mean = c12 WITH protect, noconstant(fillstring(12," "))
 DECLARE amd_cnt = i2 WITH protect, noconstant(0)
 SET cgat_status = "F"
 SET last_mod = "006"
 SET mod_date = "Aug 30, 2006"
 SELECT INTO "nl:"
  pm.prot_master_id, p_am.prot_amendment_id
  FROM prot_master pm,
   prot_amendment p_am
  PLAN (pm
   WHERE (pm.prot_master_id=request->prot_master_id))
   JOIN (p_am
   WHERE p_am.prot_master_id=pm.prot_master_id
    AND ((p_am.amendment_nbr > 0) OR (p_am.amendment_nbr=0
    AND p_am.revision_ind > 0)) )
  ORDER BY p_am.amendment_nbr, p_am.revision_seq
  DETAIL
   amd_status_mean = uar_get_code_meaning(p_am.amendment_status_cd),
   CALL echo(amd_status_mean)
   IF (amd_status_mean IN ("ACTIVATED", "COMPLETED", "CLOSED", "SUPERCEDED", "TEMPSUSPEND")
    AND p_am.amendment_dt_tm < cnvtdatetime(curdate,curtime3))
    amd_cnt = (amd_cnt+ 1), stat = alterlist(reply->amendment_info,amd_cnt), reply->amendment_info[
    amd_cnt].prot_amendment_id = p_am.prot_amendment_id,
    reply->amendment_info[amd_cnt].amendment_nbr = p_am.amendment_nbr, reply->amendment_info[amd_cnt]
    .revision_nbr_txt = p_am.revision_nbr_txt, reply->amendment_info[amd_cnt].revision_ind = p_am
    .revision_ind,
    CALL echo(build("cgpt_amendment_nbr:",cgpt_amendment_nbr))
    IF (p_am.amendment_status_cd=pm.prot_status_cd)
     cgpt_amendment_id = p_am.prot_amendment_id, cgpt_amendment_nbr = p_am.amendment_nbr,
     cur_amd_status = amd_status_mean,
     cgpt_revision_ind = p_am.revision_ind, cgpt_revision_nbr_txt = p_am.revision_nbr_txt,
     cgpt_revision_seq = p_am.revision_seq
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 FOR (i = 1 TO amd_cnt)
  CALL echo(build("amd id = ",reply->amendment_info[i].prot_amendment_id))
  CALL echo(build("amd nbr = ",reply->amendment_info[i].amendment_nbr))
 ENDFOR
 CALL echo(build("OUT - cgpt_amendment_id:",cgpt_amendment_id))
 IF (((curqual=0) OR (cgpt_amendment_id=0.0)) )
  SET cgat_status = "Z"
 ELSE
  SET cgat_status = "S"
 ENDIF
END GO
