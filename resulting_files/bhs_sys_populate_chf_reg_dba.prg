CREATE PROGRAM bhs_sys_populate_chf_reg:dba
 FREE RECORD t_record
 RECORD t_record(
   1 phys_cnt = i4
   1 phys_qual[*]
     2 phys_id = f8
   1 pat_cnt = i4
   1 pat_qual[*]
     2 pid = f8
     2 doc_id = f8
     2 prob_ind = i2
     2 chf_ind = i2
     2 iv_ind = i2
     2 coreg_ind = i2
 )
 DECLARE pcp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",331,"PCP"))
 DECLARE ordered_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE on_hold_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ONHOLDMEDSTUDENT")
  )
 DECLARE pending_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"PENDINGCOMPLETE"))
 DECLARE pending_rev_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"PENDINGREVIEW"
   ))
 DECLARE in_process_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"INPROCESS"))
 DECLARE future_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"FUTURE"))
 DECLARE coreg_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"CARVEDILOL"))
 DECLARE spir1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"SPIRONOLACTONE"))
 DECLARE spir2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HYDROCHLOROTHIAZIDESPIRONOLACTONE"))
 DECLARE iv1_rte_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4001,"IVINFUSION"))
 DECLARE iv2_rte_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4001,"IVPUSH"))
 DECLARE iv3_rte_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4001,"IVPUSHSLOWLY"))
 DECLARE iv4_rte_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4001,"IVPB"))
 DECLARE iv5_rte_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4001,
   "SUBCUTANEOUSINJECTION"))
 DECLARE iv6_rte_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4001,"INTRAMUSCULAR"))
 DECLARE iv1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"MILRINONE"))
 DECLARE iv2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"NESIRITIDE"))
 DECLARE iv3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"DOBUTAMINE"))
 DECLARE iv4_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"NITROPRUSSIDE"))
 DECLARE iv5_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"FUROSEMIDE"))
 DECLARE indx = i4
 DECLARE nsize = i4
 DECLARE nbucketsize = i4
 DECLARE ntotal = i4
 DECLARE nstart = i4
 DECLARE nbuckets = i4
 SELECT INTO "nl:"
  FROM prsnl p,
   person_prsnl_reltn ppr
  PLAN (p
   WHERE p.physician_ind=1
    AND p.active_ind=1
    AND p.end_effective_dt_tm=cnvtdatetime("31-dec-2100 00:00:00"))
   JOIN (ppr
   WHERE ppr.prsnl_person_id=p.person_id
    AND ppr.active_ind=1
    AND ppr.person_prsnl_r_cd=pcp_cd
    AND ppr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
  ORDER BY p.person_id
  HEAD p.person_id
   t_record->phys_cnt = (t_record->phys_cnt+ 1)
   IF (mod(t_record->phys_cnt,1000)=1)
    stat = alterlist(t_record->phys_qual,(t_record->phys_cnt+ 999))
   ENDIF
   t_record->phys_qual[t_record->phys_cnt].phys_id = p.person_id
  FOOT REPORT
   stat = alterlist(t_record->phys_qual,t_record->phys_cnt)
  WITH maxcol = 1000
 ;end select
 CALL echo(t_record->phys_cnt)
 FOR (i = 2001 TO 2612)
   SELECT INTO "nl:"
    FROM person_prsnl_reltn ppr
    PLAN (ppr
     WHERE (ppr.prsnl_person_id=t_record->phys_qual[i].phys_id)
      AND ppr.active_ind=1
      AND ppr.person_prsnl_r_cd=pcp_cd
      AND ppr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
    ORDER BY ppr.person_id
    HEAD ppr.person_id
     t_record->pat_cnt = (t_record->pat_cnt+ 1)
     IF (mod(t_record->pat_cnt,1000)=1)
      stat = alterlist(t_record->pat_qual,(t_record->pat_cnt+ 999))
     ENDIF
     t_record->pat_qual[t_record->pat_cnt].pid = ppr.person_id, t_record->pat_qual[t_record->pat_cnt]
     .doc_id = ppr.prsnl_person_id
    FOOT REPORT
     stat = alterlist(t_record->pat_qual,t_record->pat_cnt)
    WITH maxcol = 1000
   ;end select
   SET nsize = t_record->pat_cnt
   SET nbucketsize = 40
   SET ntotal = (ceil((cnvtreal(nsize)/ nbucketsize)) * nbucketsize)
   SET nstart = 1
   SET nbuckets = value((1+ ((ntotal - 1)/ nbucketsize)))
   SET stat = alterlist(t_record->pat_qual,ntotal)
   FOR (j = (nsize+ 1) TO ntotal)
     SET t_record->pat_qual[j].pid = t_record->pat_qual[nsize].pid
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = nbuckets),
     problem p,
     bhs_nomen_list b
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
     JOIN (p
     WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),p.person_id,t_record->pat_qual[indx].pid))
     JOIN (b
     WHERE b.nomenclature_id=p.nomenclature_id
      AND b.nomen_list_key="REGISTRY-CHF")
    DETAIL
     idx = locateval(indx,1,t_record->pat_cnt,p.person_id,t_record->pat_qual[indx].pid), t_record->
     pat_qual[idx].prob_ind = 1
    WITH maxcol = 1000
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = nbuckets),
     diagnosis di,
     bhs_nomen_list b
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
     JOIN (di
     WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),di.person_id,t_record->pat_qual[indx].pid))
     JOIN (b
     WHERE b.nomenclature_id=di.nomenclature_id
      AND b.nomen_list_key="REGISTRY-CHF")
    DETAIL
     idx = locateval(indx,1,t_record->pat_cnt,di.person_id,t_record->pat_qual[indx].pid), t_record->
     pat_qual[idx].prob_ind = 1
    WITH maxcol = 1000
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = nbuckets),
     orders o,
     order_detail od
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
     JOIN (o
     WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),o.person_id,t_record->pat_qual[indx].pid)
      AND o.catalog_cd IN (iv1_cd, iv2_cd, iv3_cd, iv4_cd, iv5_cd))
     JOIN (od
     WHERE od.order_id=o.order_id
      AND od.oe_field_meaning="RXROUTE"
      AND od.oe_field_value IN (iv1_rte_cd, iv2_rte_cd, iv3_rte_cd, iv4_rte_cd, iv5_rte_cd,
     iv6_rte_cd))
    ORDER BY o.person_id, o.catalog_cd
    HEAD o.person_id
     idx = locateval(indx,1,t_record->pat_cnt,o.person_id,t_record->pat_qual[indx].pid)
    HEAD o.catalog_cd
     t_record->pat_qual[idx].iv_ind = 1
    WITH orahint("index(O XIE3ORDERS)")
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = nbuckets),
     orders o
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
     JOIN (o
     WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),o.person_id,t_record->pat_qual[indx].pid)
      AND o.catalog_cd IN (spir1_cd, spir2_cd, coreg_cd))
    ORDER BY o.person_id, o.catalog_cd
    HEAD o.person_id
     idx = locateval(indx,1,t_record->pat_cnt,o.person_id,t_record->pat_qual[indx].pid)
    HEAD o.catalog_cd
     IF (o.catalog_cd IN (spir1_cd, spir2_cd)
      AND o.catalog_cd=coreg_cd)
      t_record->pat_qual[idx].coreg_ind = 1
     ENDIF
    WITH orahint("index(O XIE3ORDERS)")
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = t_record->pat_cnt)
    PLAN (d)
    DETAIL
     IF ((((t_record->pat_qual[d.seq].prob_ind=1)) OR ((((t_record->pat_qual[d.seq].iv_ind=1)) OR ((
     t_record->pat_qual[d.seq].coreg_ind=1))) )) )
      t_record->pat_qual[d.seq].chf_ind = 1
     ENDIF
    WITH maxcol = 1000
   ;end select
   INSERT  FROM (dummyt d  WITH seq = t_record->pat_cnt),
     bhs_problem_registry b
    SET b.person_id = t_record->pat_qual[d.seq].pid, b.pcp_id = t_record->pat_qual[d.seq].doc_id, b
     .problem = "CHF",
     b.practice_id = 0.00, b.active_ind = 1
    PLAN (d
     WHERE (t_record->pat_qual[d.seq].chf_ind=1))
     JOIN (b
     WHERE (b.person_id != t_record->pat_qual[d.seq].pid)
      AND b.problem != "CHF")
    WITH nocounter
   ;end insert
   COMMIT
   SET count = 0
   FOR (z = 1 TO t_record->pat_cnt)
     IF ((t_record->pat_qual[z].chf_ind=1))
      SET count = (count+ 1)
     ENDIF
   ENDFOR
   CALL echo("***************")
   CALL echo(t_record->phys_cnt)
   CALL echo(i)
   CALL echo(count)
   SET t_record->pat_cnt = 0
   SET stat = alterlist(t_record->pat_qual,t_record->pat_cnt)
   SELECT INTO "last_chf_phys.txt"
    FROM (dummyt d  WITH seq = 1)
    PLAN (d)
    DETAIL
     col 0, i
    WITH nocounter
   ;end select
 ENDFOR
END GO
