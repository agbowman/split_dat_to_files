CREATE PROGRAM bhs_pim_load_providers
 FREE RECORD work
 RECORD work(
   1 p_cnt = i4
   1 providers[*]
     2 prsnl_id = f8
     2 username = vc
     2 group_role = c1
 )
 DEFINE rtl3 "bhs_pim_provider_list.txt"
 SELECT INTO "nl:"
  FROM rtl3t r
  DETAIL
   IF (trim(piece(r.line,"|",1,""),4) > " ")
    work->p_cnt = (work->p_cnt+ 1)
    IF ((work->p_cnt > size(work->providers,5)))
     stat = alterlist(work->providers,work->p_cnt)
    ENDIF
    work->providers[work->p_cnt].username = trim(piece(r.line,"|",1,"ERROR"),3)
    IF (trim(piece(r.line,"|",2,"ERROR"),3)="1")
     work->providers[work->p_cnt].group_role = "I"
    ELSE
     work->providers[work->p_cnt].group_role = "C"
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(work->providers,work->p_cnt)
  WITH nocounter
 ;end select
 FREE DEFINE rtl3
 SELECT INTO "nl:"
  p.person_id, bpr.prsnl_id
  FROM (dummyt d  WITH seq = value(work->p_cnt)),
   bhs_pim_provider bpr,
   prsnl p
  PLAN (d)
   JOIN (p
   WHERE (p.username=work->providers[d.seq].username))
   JOIN (bpr
   WHERE outerjoin(p.person_id)=bpr.prsnl_id)
  DETAIL
   IF (bpr.prsnl_id=null)
    work->providers[d.seq].prsnl_id = p.person_id
   ENDIF
  WITH nocounter
 ;end select
 IF ((work->p_cnt > 0))
  INSERT  FROM bhs_pim_provider bpr,
    (dummyt d  WITH seq = value(work->p_cnt))
   SET bpr.prsnl_id = work->providers[d.seq].prsnl_id, bpr.group_role = work->providers[d.seq].
    group_role, bpr.active_ind = 1
   PLAN (d
    WHERE (work->providers[d.seq].prsnl_id > 0.00))
    JOIN (bpr)
   WITH nocounter
  ;end insert
  COMMIT
 ENDIF
END GO
