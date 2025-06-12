CREATE PROGRAM bhs_sys_populate_asthma_reg:dba
 FREE RECORD t_record
 RECORD t_record(
   1 twenty_one_dt = dq8
   1 phys_cnt = i4
   1 phys_qual[*]
     2 phys_id = f8
   1 pat_cnt = i4
   1 pat_qual[*]
     2 pid = f8
     2 dob = dq8
     2 doc_id = f8
     2 asthma_ind = i2
     2 prob_ind = i2
     2 saba_ind = i2
     2 laba_ind = i2
     2 leuk_ind = i2
     2 is_ind = i2
     2 os_ind = i2
     2 mcs_ind = i2
     2 antichol_ind = i2
     2 ca_ind = i2
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
 DECLARE saba1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"ALBUTEROL"))
 DECLARE saba2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"LEVALBUTEROL"))
 DECLARE saba3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"PIRBUTEROL"))
 DECLARE laba1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"SALMETEROL"))
 DECLARE laba2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"FORMOTEROL"))
 DECLARE leuk1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"MONTELUKAST"))
 DECLARE leuk2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"ZAFIRLUKAST"))
 DECLARE leuk3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"ZILEUTON"))
 DECLARE is1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"FLUTICASONE"))
 DECLARE is2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"BUDESONIDE"))
 DECLARE is3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"FLUNISOLIDE"))
 DECLARE is4_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"MOMETASONE"))
 DECLARE is5_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"TRIAMCINOLONE"))
 DECLARE is6_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"BECLOMETHASONE"))
 DECLARE os1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"PREDNISONE"))
 DECLARE os2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"PREDNISOLONE"))
 DECLARE mcs1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"CROMOLYN"))
 DECLARE mcs2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"NEDOCROMIL"))
 DECLARE antichol1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"IPRATROPIUM"))
 DECLARE ca1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"ALBUTEROLIPRATROPIUM"))
 DECLARE ca2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"FLUTICASONESALMETEROL")
  )
 DECLARE ca3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"BUDESONIDEFORMOTEROL"))
 DECLARE indx = i4
 DECLARE nsize = i4
 DECLARE nbucketsize = i4
 DECLARE ntotal = i4
 DECLARE nstart = i4
 DECLARE nbuckets = i4
 SET t_record->twenty_one_dt = datetimeadd(cnvtdatetime(curdate,curtime3),- (7665))
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
 FOR (i = 2501 TO t_record->phys_cnt)
   SELECT INTO "nl:"
    FROM person_prsnl_reltn ppr,
     person p
    PLAN (ppr
     WHERE (ppr.prsnl_person_id=t_record->phys_qual[i].phys_id)
      AND ppr.active_ind=1
      AND ppr.person_prsnl_r_cd=pcp_cd
      AND ppr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
     JOIN (p
     WHERE p.person_id=ppr.person_id
      AND p.active_ind=1)
    ORDER BY ppr.person_id
    HEAD ppr.person_id
     t_record->pat_cnt = (t_record->pat_cnt+ 1)
     IF (mod(t_record->pat_cnt,1000)=1)
      stat = alterlist(t_record->pat_qual,(t_record->pat_cnt+ 999))
     ENDIF
     t_record->pat_qual[t_record->pat_cnt].pid = ppr.person_id, t_record->pat_qual[t_record->pat_cnt]
     .dob = p.birth_dt_tm, t_record->pat_qual[t_record->pat_cnt].doc_id = ppr.prsnl_person_id
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
      AND b.nomen_list_key="REGISTRY-ASTHMA")
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
      AND b.nomen_list_key="REGISTRY-ASTHMA")
    DETAIL
     idx = locateval(indx,1,t_record->pat_cnt,di.person_id,t_record->pat_qual[indx].pid), t_record->
     pat_qual[idx].prob_ind = 1
    WITH maxcol = 1000
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = nbuckets),
     orders o
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
     JOIN (o
     WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),o.person_id,t_record->pat_qual[indx].pid)
      AND o.catalog_cd IN (saba1_cd, saba2_cd, saba3_cd, laba1_cd, laba2_cd,
     leuk1_cd, leuk2_cd, leuk3_cd, is1_cd, is2_cd,
     is3_cd, is4_cd, is5_cd, is6_cd, os1_cd,
     os2_cd, mcs1_cd, mcs2_cd, antichol1_cd, ca1_cd,
     ca2_cd, ca3_cd)
      AND o.order_status_cd IN (ordered_cd, on_hold_cd, pending_cd, pending_rev_cd, in_process_cd,
     future_cd))
    ORDER BY o.person_id, o.catalog_cd
    HEAD o.person_id
     idx = locateval(indx,1,t_record->pat_cnt,o.person_id,t_record->pat_qual[indx].pid)
    HEAD o.catalog_cd
     IF (o.catalog_cd IN (saba1_cd, saba2_cd, saba3_cd))
      t_record->pat_qual[idx].saba_ind = 1
     ELSEIF (o.catalog_cd IN (laba1_cd, laba2_cd))
      t_record->pat_qual[idx].laba_ind = 1
     ELSEIF (o.catalog_cd IN (leuk1_cd, leuk2_cd, leuk3_cd))
      t_record->pat_qual[idx].leuk_ind = 1
     ELSEIF (o.catalog_cd IN (is1_cd, is2_cd, is3_cd, is4_cd, is5_cd,
     is6_cd))
      t_record->pat_qual[idx].is_ind = 1
     ELSEIF (o.catalog_cd IN (os1_cd, os2_cd))
      t_record->pat_qual[idx].os_ind = 1
     ELSEIF (o.catalog_cd IN (mcs1_cd, mcs2_cd))
      t_record->pat_qual[idx].mcs_ind = 1
     ELSEIF (o.catalog_cd IN (antichol1_cd))
      t_record->pat_qual[idx].antichol_ind = 1
     ELSEIF (o.catalog_cd IN (ca1_cd, ca2_cd, ca3_cd))
      t_record->pat_qual[idx].ca_ind = 1
     ENDIF
    WITH orahint("index(O XIE99ORDERS)")
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = t_record->pat_cnt)
    PLAN (d)
    DETAIL
     IF ((t_record->pat_qual[d.seq].dob > t_record->twenty_one_dt))
      IF ((((t_record->pat_qual[d.seq].prob_ind=1)) OR ((((t_record->pat_qual[d.seq].saba_ind=1)) OR
      ((t_record->pat_qual[d.seq].laba_ind=1))) )) )
       t_record->pat_qual[d.seq].asthma_ind = 1
      ENDIF
      IF ((t_record->pat_qual[d.seq].prob_ind=1)
       AND (((t_record->pat_qual[d.seq].laba_ind=1)) OR ((t_record->pat_qual[d.seq].ca_ind=1))) )
       severity = 2
      ENDIF
      IF ((t_record->pat_qual[d.seq].prob_ind=1)
       AND (t_record->pat_qual[d.seq].saba_ind=1)
       AND (((t_record->pat_qual[d.seq].leuk_ind=1)) OR ((((t_record->pat_qual[d.seq].is_ind=1)) OR (
      (t_record->pat_qual[d.seq].ca_ind=1))) )) )
       t_record->pat_qual[d.seq].asthma_ind = 1
      ENDIF
      IF ((t_record->pat_qual[d.seq].prob_ind=1)
       AND (t_record->pat_qual[d.seq].saba_ind=1)
       AND (t_record->pat_qual[d.seq].is_ind=1)
       AND (((t_record->pat_qual[d.seq].leuk_ind=1)) OR ((t_record->pat_qual[d.seq].ca_ind=1))) )
       t_record->pat_qual[d.seq].asthma_ind = 1
      ENDIF
      IF ((t_record->pat_qual[d.seq].saba_ind=1)
       AND (((t_record->pat_qual[d.seq].leuk_ind=1)) OR ((((t_record->pat_qual[d.seq].is_ind=1)) OR (
      (((t_record->pat_qual[d.seq].os_ind=1)) OR ((t_record->pat_qual[d.seq].antichol_ind=1))) )) ))
      )
       t_record->pat_qual[d.seq].asthma_ind = 1
      ENDIF
      IF ((t_record->pat_qual[d.seq].laba_ind=1)
       AND (((t_record->pat_qual[d.seq].leuk_ind=1)) OR ((((t_record->pat_qual[d.seq].is_ind=1)) OR (
      (((t_record->pat_qual[d.seq].os_ind=1)) OR ((t_record->pat_qual[d.seq].antichol_ind=1))) )) ))
      )
       t_record->pat_qual[d.seq].asthma_ind = 1
      ENDIF
      IF ((t_record->pat_qual[d.seq].saba_ind=1)
       AND (t_record->pat_qual[d.seq].is_ind=1)
       AND (t_record->pat_qual[d.seq].os_ind=1))
       t_record->pat_qual[d.seq].asthma_ind = 1
      ENDIF
      IF ((t_record->pat_qual[d.seq].prob_ind=1)
       AND (t_record->pat_qual[d.seq].leuk_ind=1)
       AND (t_record->pat_qual[d.seq].is_ind=1)
       AND (t_record->pat_qual[d.seq].os_ind=1)
       AND (((t_record->pat_qual[d.seq].saba_ind=1)) OR ((((t_record->pat_qual[d.seq].laba_ind=1))
       OR ((t_record->pat_qual[d.seq].ca_ind=1))) )) )
       severity = 3
      ENDIF
      IF ((t_record->pat_qual[d.seq].prob_ind=1)
       AND (t_record->pat_qual[d.seq].leuk_ind=1)
       AND (t_record->pat_qual[d.seq].mcs_ind=1)
       AND (t_record->pat_qual[d.seq].antichol_ind=1)
       AND (((t_record->pat_qual[d.seq].saba_ind=1)) OR ((((t_record->pat_qual[d.seq].laba_ind=1))
       OR ((t_record->pat_qual[d.seq].ca_ind=1))) )) )
       t_record->pat_qual[d.seq].asthma_ind = 1
      ENDIF
      IF ((t_record->pat_qual[d.seq].leuk_ind=1)
       AND (t_record->pat_qual[d.seq].is_ind=1)
       AND (t_record->pat_qual[d.seq].os_ind=1)
       AND (((t_record->pat_qual[d.seq].saba_ind=1)) OR ((((t_record->pat_qual[d.seq].laba_ind=1))
       OR ((t_record->pat_qual[d.seq].ca_ind=1))) )) )
       t_record->pat_qual[d.seq].asthma_ind = 1
      ENDIF
      IF ((t_record->pat_qual[d.seq].leuk_ind=1)
       AND (t_record->pat_qual[d.seq].mcs_ind=1)
       AND (t_record->pat_qual[d.seq].antichol_ind=1)
       AND (((t_record->pat_qual[d.seq].saba_ind=1)) OR ((((t_record->pat_qual[d.seq].laba_ind=1))
       OR ((t_record->pat_qual[d.seq].ca_ind=1))) )) )
       t_record->pat_qual[d.seq].asthma_ind = 1
      ENDIF
      IF ((t_record->pat_qual[d.seq].prob_ind=1)
       AND (t_record->pat_qual[d.seq].saba_ind=1)
       AND (t_record->pat_qual[d.seq].laba_ind=1)
       AND (t_record->pat_qual[d.seq].leuk_ind=1)
       AND (t_record->pat_qual[d.seq].is_ind=1)
       AND (t_record->pat_qual[d.seq].os_ind=1)
       AND (t_record->pat_qual[d.seq].mcs_ind=1)
       AND (t_record->pat_qual[d.seq].antichol_ind=1)
       AND (t_record->pat_qual[d.seq].ca_ind=1))
       t_record->pat_qual[d.seq].asthma_ind = 1
      ENDIF
     ELSE
      IF ((t_record->pat_qual[d.seq].prob_ind=1)
       AND (t_record->pat_qual[d.seq].leuk_ind=1))
       t_record->pat_qual[d.seq].asthma_ind = 1
      ENDIF
     ENDIF
    WITH maxcol = 1000
   ;end select
   INSERT  FROM (dummyt d  WITH seq = t_record->pat_cnt),
     bhs_problem_registry b
    SET b.person_id = t_record->pat_qual[d.seq].pid, b.pcp_id = t_record->pat_qual[d.seq].doc_id, b
     .problem = "ASTHMA",
     b.practice_id = 0.00, b.active_ind = 1
    PLAN (d
     WHERE (t_record->pat_qual[d.seq].asthma_ind=1))
     JOIN (b
     WHERE (b.person_id != t_record->pat_qual[d.seq].pid)
      AND b.problem != "ASTHMA")
    WITH nocounter
   ;end insert
   COMMIT
   SET count = 0
   FOR (z = 1 TO t_record->pat_cnt)
     IF ((t_record->pat_qual[z].asthma_ind=1))
      SET count = (count+ 1)
     ENDIF
   ENDFOR
   CALL echo("***************")
   CALL echo(t_record->phys_cnt)
   CALL echo(i)
   CALL echo(count)
   SET t_record->pat_cnt = 0
   SET stat = alterlist(t_record->pat_qual,t_record->pat_cnt)
   SELECT INTO "last_asthma_phys.txt"
    FROM (dummyt d  WITH seq = 1)
    PLAN (d)
    DETAIL
     col 0, i
    WITH nocounter
   ;end select
 ENDFOR
END GO
