CREATE PROGRAM dcp_get_proc_list_by_proc_ids:dba
 DECLARE knt1 = i4 WITH public, noconstant(0,0)
 SET qual_cnt = size(request->proc_qual,5)
 SET ierrcode = 0
 SELECT INTO "nl:"
  d.seq
  FROM (dummyt dt  WITH seq = value(qual_cnt)),
   procedure p,
   encounter e,
   nomenclature n,
   (dummyt d  WITH seq = 1),
   proc_prsnl_reltn ppr,
   prsnl pr
  PLAN (dt)
   JOIN (p
   WHERE (p.procedure_id=request->proc_qual[dt.seq].procedure_id))
   JOIN (e
   WHERE e.encntr_id=p.encntr_id)
   JOIN (n
   WHERE n.nomenclature_id=p.nomenclature_id)
   JOIN (d)
   JOIN (ppr
   WHERE ppr.procedure_id=p.procedure_id
    AND ppr.active_ind=1)
   JOIN (pr
   WHERE pr.person_id=ppr.prsnl_person_id)
  ORDER BY e.person_id, p.procedure_id, ppr.beg_effective_dt_tm DESC
  HEAD REPORT
   knt = 0, stat = alterlist(reply->proc_list,1)
  HEAD p.procedure_id
   knt1 = 0, knt = (knt+ 1)
   IF (mod(knt,10)=1)
    stat = alterlist(reply->proc_list,(knt+ 9))
   ENDIF
   reply->proc_list[knt].person_id = e.person_id, reply->proc_list[knt].procedure_id = p.procedure_id,
   reply->proc_list[knt].encntr_id = e.encntr_id,
   reply->proc_list[knt].active_ind = p.active_ind, reply->proc_list[knt].nomenclature_id = p
   .nomenclature_id
   IF (p.nomenclature_id > 0)
    reply->proc_list[knt].source_string = n.source_string
   ELSE
    reply->proc_list[knt].source_string = p.proc_ftdesc
   ENDIF
   reply->proc_list[knt].organization_id = e.organization_id, reply->proc_list[knt].proc_dt_tm =
   cnvtdatetime(p.proc_dt_tm), reply->proc_list[knt].proc_ft_dt_tm_ind = p.proc_ft_dt_tm_ind,
   reply->proc_list[knt].proc_ft_time_frame = p.proc_ft_time_frame, reply->proc_list[knt].
   proc_prsnl_reltn_id = ppr.proc_prsnl_reltn_id, reply->proc_list[knt].proc_prsnl_reltn_cd = ppr
   .proc_prsnl_reltn_cd,
   reply->proc_list[knt].proc_prsnl_id = ppr.prsnl_person_id
   IF (ppr.prsnl_person_id > 0)
    reply->proc_list[knt].proc_prsnl_name = pr.name_full_formatted
   ELSE
    reply->proc_list[knt].proc_prsnl_name = ppr.proc_ft_prsnl, reply->proc_list[knt].proc_ft_prsnl =
    ppr.proc_ft_prsnl
   ENDIF
   reply->proc_list[knt].proc_prsnl_ft_ind = ppr.proc_prsnl_ft_ind, reply->proc_list[knt].proc_loc_cd
    = p.proc_loc_cd, reply->proc_list[knt].proc_loc_ft_ind = p.proc_loc_ft_ind,
   reply->proc_list[knt].proc_ft_loc = p.proc_ft_loc, reply->proc_list[knt].comment_ind = p
   .comment_ind, reply->proc_list[knt].long_text_id = p.long_text_id
  HEAD ppr.proc_prsnl_reltn_id
   IF (ppr.proc_prsnl_reltn_id > 0)
    knt1 = (knt1+ 1), stat = alterlist(reply->proc_list[knt].proc_prsnl_reltns,knt1), reply->
    proc_list[knt].proc_prsnl_reltns[knt1].proc_prsnl_reltn_id = ppr.proc_prsnl_reltn_id,
    reply->proc_list[knt].proc_prsnl_reltns[knt1].proc_prsnl_reltn_cd = ppr.proc_prsnl_reltn_cd,
    reply->proc_list[knt].proc_prsnl_reltns[knt1].proc_prsnl_id = ppr.prsnl_person_id
    IF (ppr.proc_prsnl_ft_ind > 0)
     reply->proc_list[knt].proc_prsnl_reltns[knt1].proc_ft_prsnl = ppr.proc_ft_prsnl
    ELSE
     reply->proc_list[knt].proc_prsnl_reltns[knt1].proc_prsnl_name = pr.name_full_formatted, reply->
     proc_list[knt].proc_prsnl_reltns[knt1].proc_prsnl_id = ppr.prsnl_person_id
    ENDIF
    reply->proc_list[knt].proc_prsnl_reltns[knt1].proc_prsnl_ft_ind = ppr.proc_prsnl_ft_ind
   ENDIF
  FOOT REPORT
   reply->proc_cnt = knt, stat = alterlist(reply->proc_list,knt)
  WITH nocounter, outerjoin = d
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "PROCEDURE"
 ENDIF
END GO
