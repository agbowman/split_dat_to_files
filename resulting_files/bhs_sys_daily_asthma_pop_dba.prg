CREATE PROGRAM bhs_sys_daily_asthma_pop:dba
 FREE RECORD t_record
 RECORD t_record(
   1 twenty_one_dt = dq8
   1 t_action_dt_tm = dq8
   1 start_dt_tm = dq8
   1 end_dt_tm = dq8
   1 person_cnt = i4
   1 person_qual[*]
     2 person_id = f8
     2 dob = dq8
     2 phys_id = f8
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
   1 pat_cnt = i4
   1 pat_qual[*]
     2 pid = f8
     2 phys_id = f8
 )
 FREE RECORD t_record2
 RECORD t_record2(
   1 qual[*]
     2 personid = f8
     2 pcp_id = f8
     2 updt_ind = i2
 )
 FREE RECORD reply
 RECORD reply(
   1 status_data[1]
     2 status = c1
 )
 IF (validate(request->batch_selection))
  SET t_record->t_action_dt_tm = datetimeadd(cnvtdatetime(request->ops_date),- (1))
  IF ((t_record->t_action_dt_tm <= 0))
   SET t_record->t_action_dt_tm = datetimeadd(cnvtdatetime(curdate,curtime3),- (1))
  ENDIF
  SET t_record->start_dt_tm = datetimefind(t_record->t_action_dt_tm,"D","B","B")
  SET t_record->end_dt_tm = datetimefind(t_record->t_action_dt_tm,"D","E","E")
 ENDIF
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
 DECLARE is7_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"CICLESONIDE"))
 DECLARE os1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"PREDNISONE"))
 DECLARE os2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"PREDNISOLONE"))
 DECLARE mcs1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"CROMOLYN"))
 DECLARE mcs2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"NEDOCROMIL"))
 DECLARE antichol1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"IPRATROPIUM"))
 DECLARE ca1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"ALBUTEROLIPRATROPIUM"))
 DECLARE ca2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"FLUTICASONESALMETEROL")
  )
 DECLARE ca3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"BUDESONIDEFORMOTEROL"))
 DECLARE idx1 = i4
 DECLARE indx = i4
 DECLARE nsize = i4
 DECLARE nbucketsize = i4
 DECLARE ntotal = i4
 DECLARE nstart = i4
 DECLARE nbuckets = i4
 SELECT INTO "nl:"
  FROM bhs_problem_registry b,
   person_prsnl_reltn ppr
  PLAN (b
   WHERE b.problem="ASTHMA")
   JOIN (ppr
   WHERE ppr.person_id=b.person_id
    AND ppr.person_prsnl_r_cd=pcp_cd
    AND ppr.active_ind=1
    AND ppr.end_effective_dt_tm > sysdate
    AND ppr.prsnl_person_id != b.pcp_id)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(t_record2->qual,cnt), t_record2->qual[cnt].personid = b.person_id,
   t_record2->qual[cnt].pcp_id = ppr.prsnl_person_id, t_record2->qual[cnt].updt_ind = 1
  WITH nocounter
 ;end select
 SET pcp_update_cnt = size(t_record2->qual,5)
 IF (pcp_update_cnt > 0)
  FOR (x = 1 TO pcp_update_cnt)
   UPDATE  FROM bhs_problem_registry b
    SET b.pcp_id = t_record2->qual[x].pcp_id
    WHERE (b.person_id=t_record2->qual[x].personid)
     AND b.problem="ASTHMA"
     AND b.active_ind=1
    WITH nocounter
   ;end update
   COMMIT
  ENDFOR
 ENDIF
 SET t_record->twenty_one_dt = datetimeadd(cnvtdatetime(curdate,curtime3),- (7665))
 SELECT INTO "nl:"
  FROM bhs_nomen_list n,
   problem p
  PLAN (n
   WHERE n.nomen_list_key="REGISTRY-ASTHMA")
   JOIN (p
   WHERE p.nomenclature_id=n.nomenclature_id
    AND p.updt_dt_tm >= cnvtdatetime(t_record->start_dt_tm)
    AND p.updt_dt_tm <= cnvtdatetime(t_record->end_dt_tm))
  ORDER BY p.person_id
  HEAD p.person_id
   IF ((t_record->person_cnt=0))
    t_record->person_cnt = (t_record->person_cnt+ 1), idx = t_record->person_cnt, stat = alterlist(
     t_record->person_qual,idx),
    t_record->person_qual[idx].person_id = p.person_id, t_record->person_qual[idx].prob_ind = 1
   ELSE
    idx1 = locateval(indx,1,t_record->person_cnt,p.person_id,t_record->person_qual[indx].person_id)
    IF (idx1=0)
     t_record->person_cnt = (t_record->person_cnt+ 1), idx = t_record->person_cnt, stat = alterlist(
      t_record->person_qual,idx),
     t_record->person_qual[idx].person_id = p.person_id, t_record->person_qual[idx].prob_ind = 1
    ENDIF
   ENDIF
  WITH maxrec = 1000
 ;end select
 SELECT INTO "nl:"
  FROM bhs_nomen_list n,
   diagnosis d
  PLAN (n
   WHERE n.nomen_list_key="REGISTRY-ASTHMA")
   JOIN (d
   WHERE d.nomenclature_id=n.nomenclature_id
    AND d.updt_dt_tm >= cnvtdatetime(t_record->start_dt_tm)
    AND d.updt_dt_tm <= cnvtdatetime(t_record->end_dt_tm))
  ORDER BY d.person_id
  HEAD d.person_id
   IF ((t_record->person_cnt=0))
    t_record->person_cnt = (t_record->person_cnt+ 1), idx = t_record->person_cnt, stat = alterlist(
     t_record->person_qual,idx),
    t_record->person_qual[idx].person_id = d.person_id, t_record->person_qual[idx].prob_ind = 1
   ELSE
    idx1 = locateval(indx,1,t_record->person_cnt,d.person_id,t_record->person_qual[indx].person_id)
    IF (idx1=0)
     t_record->person_cnt = (t_record->person_cnt+ 1), idx = t_record->person_cnt, stat = alterlist(
      t_record->person_qual,idx),
     t_record->person_qual[idx].person_id = d.person_id, t_record->person_qual[idx].prob_ind = 1
    ENDIF
   ENDIF
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE o.orig_order_dt_tm >= cnvtdatetime(t_record->start_dt_tm)
    AND o.orig_order_dt_tm <= cnvtdatetime(t_record->end_dt_tm)
    AND ((o.catalog_cd+ 0) IN (saba1_cd, saba2_cd, saba3_cd, laba1_cd, laba2_cd,
   leuk1_cd, leuk2_cd, leuk3_cd, is1_cd, is2_cd,
   is3_cd, is4_cd, is5_cd, is6_cd, is7_cd,
   os1_cd, os2_cd, mcs1_cd, mcs2_cd, antichol1_cd,
   ca1_cd, ca2_cd, ca3_cd))
    AND o.order_status_cd IN (ordered_cd, on_hold_cd, pending_cd, pending_rev_cd, in_process_cd,
   future_cd))
  ORDER BY o.person_id, o.catalog_cd
  HEAD o.person_id
   IF ((t_record->person_cnt=0))
    t_record->person_cnt = (t_record->person_cnt+ 1), idx = t_record->person_cnt, stat = alterlist(
     t_record->person_qual,idx),
    t_record->person_qual[idx].person_id = o.person_id
   ELSE
    idx = locateval(indx,1,t_record->person_cnt,o.person_id,t_record->person_qual[indx].person_id)
    IF (idx=0)
     t_record->person_cnt = (t_record->person_cnt+ 1), idx = t_record->person_cnt, stat = alterlist(
      t_record->person_qual,idx),
     t_record->person_qual[idx].person_id = o.person_id
    ENDIF
   ENDIF
  HEAD o.catalog_cd
   IF (o.catalog_cd IN (saba1_cd, saba2_cd, saba3_cd))
    t_record->person_qual[idx].saba_ind = 1
   ELSEIF (o.catalog_cd IN (laba1_cd, laba2_cd))
    t_record->person_qual[idx].laba_ind = 1
   ELSEIF (o.catalog_cd IN (leuk1_cd, leuk2_cd, leuk3_cd))
    t_record->person_qual[idx].leuk_ind = 1
   ELSEIF (o.catalog_cd IN (is1_cd, is2_cd, is3_cd, is4_cd, is5_cd,
   is6_cd, is7_cd))
    t_record->person_qual[idx].is_ind = 1
   ELSEIF (o.catalog_cd IN (os1_cd, os2_cd))
    t_record->person_qual[idx].os_ind = 1
   ELSEIF (o.catalog_cd IN (mcs1_cd, mcs2_cd))
    t_record->person_qual[idx].mcs_ind = 1
   ELSEIF (o.catalog_cd IN (antichol1_cd))
    t_record->person_qual[idx].antichol_ind = 1
   ELSEIF (o.catalog_cd IN (ca1_cd, ca2_cd, ca3_cd))
    t_record->person_qual[idx].ca_ind = 1
   ENDIF
  WITH orahint("index(O XIE17ORDERS)")
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->person_cnt),
   person p
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=t_record->person_qual[d.seq].person_id))
  DETAIL
   IF ((p.birth_dt_tm > t_record->twenty_one_dt))
    IF ((((t_record->person_qual[d.seq].prob_ind=1)) OR ((((t_record->person_qual[d.seq].saba_ind=1))
     OR ((t_record->person_qual[d.seq].laba_ind=1))) )) )
     t_record->person_qual[d.seq].asthma_ind = 1
    ENDIF
    IF ((t_record->person_qual[d.seq].prob_ind=1)
     AND (((t_record->person_qual[d.seq].laba_ind=1)) OR ((t_record->person_qual[d.seq].ca_ind=1))) )
     t_record->person_qual[d.seq].asthma_ind = 1
    ENDIF
    IF ((t_record->person_qual[d.seq].prob_ind=1)
     AND (t_record->person_qual[d.seq].saba_ind=1)
     AND (((t_record->person_qual[d.seq].leuk_ind=1)) OR ((((t_record->person_qual[d.seq].is_ind=1))
     OR ((t_record->person_qual[d.seq].ca_ind=1))) )) )
     t_record->person_qual[d.seq].asthma_ind = 1
    ENDIF
    IF ((t_record->person_qual[d.seq].prob_ind=1)
     AND (t_record->person_qual[d.seq].saba_ind=1)
     AND (t_record->person_qual[d.seq].is_ind=1)
     AND (((t_record->person_qual[d.seq].leuk_ind=1)) OR ((t_record->person_qual[d.seq].ca_ind=1))) )
     t_record->person_qual[d.seq].asthma_ind = 1
    ENDIF
    IF ((t_record->person_qual[d.seq].saba_ind=1)
     AND (((t_record->person_qual[d.seq].leuk_ind=1)) OR ((((t_record->person_qual[d.seq].is_ind=1))
     OR ((((t_record->person_qual[d.seq].os_ind=1)) OR ((t_record->person_qual[d.seq].antichol_ind=1)
    )) )) )) )
     t_record->person_qual[d.seq].asthma_ind = 1
    ENDIF
    IF ((t_record->person_qual[d.seq].laba_ind=1)
     AND (((t_record->person_qual[d.seq].leuk_ind=1)) OR ((((t_record->person_qual[d.seq].is_ind=1))
     OR ((((t_record->person_qual[d.seq].os_ind=1)) OR ((t_record->person_qual[d.seq].antichol_ind=1)
    )) )) )) )
     t_record->person_qual[d.seq].asthma_ind = 1
    ENDIF
    IF ((t_record->person_qual[d.seq].saba_ind=1)
     AND (t_record->person_qual[d.seq].is_ind=1)
     AND (t_record->person_qual[d.seq].os_ind=1))
     t_record->person_qual[d.seq].asthma_ind = 1
    ENDIF
    IF ((t_record->person_qual[d.seq].prob_ind=1)
     AND (t_record->person_qual[d.seq].leuk_ind=1)
     AND (t_record->person_qual[d.seq].is_ind=1)
     AND (t_record->person_qual[d.seq].os_ind=1)
     AND (((t_record->person_qual[d.seq].saba_ind=1)) OR ((((t_record->person_qual[d.seq].laba_ind=1)
    ) OR ((t_record->person_qual[d.seq].ca_ind=1))) )) )
     t_record->person_qual[d.seq].asthma_ind = 1
    ENDIF
    IF ((t_record->person_qual[d.seq].prob_ind=1)
     AND (t_record->person_qual[d.seq].leuk_ind=1)
     AND (t_record->person_qual[d.seq].mcs_ind=1)
     AND (t_record->person_qual[d.seq].antichol_ind=1)
     AND (((t_record->person_qual[d.seq].saba_ind=1)) OR ((((t_record->person_qual[d.seq].laba_ind=1)
    ) OR ((t_record->person_qual[d.seq].ca_ind=1))) )) )
     t_record->person_qual[d.seq].asthma_ind = 1
    ENDIF
    IF ((t_record->person_qual[d.seq].leuk_ind=1)
     AND (t_record->person_qual[d.seq].is_ind=1)
     AND (t_record->person_qual[d.seq].os_ind=1)
     AND (((t_record->person_qual[d.seq].saba_ind=1)) OR ((((t_record->person_qual[d.seq].laba_ind=1)
    ) OR ((t_record->person_qual[d.seq].ca_ind=1))) )) )
     t_record->person_qual[d.seq].asthma_ind = 1
    ENDIF
    IF ((t_record->person_qual[d.seq].leuk_ind=1)
     AND (t_record->person_qual[d.seq].mcs_ind=1)
     AND (t_record->person_qual[d.seq].antichol_ind=1)
     AND (((t_record->person_qual[d.seq].saba_ind=1)) OR ((((t_record->person_qual[d.seq].laba_ind=1)
    ) OR ((t_record->person_qual[d.seq].ca_ind=1))) )) )
     t_record->person_qual[d.seq].asthma_ind = 1
    ENDIF
    IF ((t_record->person_qual[d.seq].prob_ind=1)
     AND (t_record->person_qual[d.seq].saba_ind=1)
     AND (t_record->person_qual[d.seq].laba_ind=1)
     AND (t_record->person_qual[d.seq].leuk_ind=1)
     AND (t_record->person_qual[d.seq].is_ind=1)
     AND (t_record->person_qual[d.seq].os_ind=1)
     AND (t_record->person_qual[d.seq].mcs_ind=1)
     AND (t_record->person_qual[d.seq].antichol_ind=1)
     AND (t_record->person_qual[d.seq].ca_ind=1))
     t_record->person_qual[d.seq].asthma_ind = 1
    ENDIF
   ELSE
    IF ((t_record->person_qual[d.seq].prob_ind=1))
     t_record->person_qual[d.seq].asthma_ind = 1
    ENDIF
   ENDIF
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->person_cnt)
  PLAN (d
   WHERE (t_record->person_qual[d.seq].asthma_ind=1))
  DETAIL
   t_record->pat_cnt = (t_record->pat_cnt+ 1)
   IF (mod(t_record->pat_cnt,100)=1)
    stat = alterlist(t_record->pat_qual,(t_record->pat_cnt+ 99))
   ENDIF
   t_record->pat_qual[t_record->pat_cnt].pid = t_record->person_qual[d.seq].person_id
  FOOT REPORT
   stat = alterlist(t_record->pat_qual,t_record->pat_cnt)
  WITH maxcol = 1000
 ;end select
 SET t_record->person_cnt = 0
 SET stat = alterlist(t_record->person_qual,t_record->person_cnt)
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
   person_prsnl_reltn ppr,
   prsnl p
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
   JOIN (ppr
   WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),ppr.person_id,t_record->pat_qual[indx].pid)
    AND ppr.person_prsnl_r_cd=pcp_cd
    AND ppr.active_ind=1
    AND ppr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (p
   WHERE p.person_id=ppr.prsnl_person_id
    AND p.name_last_key != "NOTONSTAFF")
  ORDER BY ppr.person_id
  HEAD ppr.person_id
   idx1 = locateval(indx,1,t_record->pat_cnt,ppr.person_id,t_record->pat_qual[indx].pid), t_record->
   pat_qual[idx1].phys_id = ppr.prsnl_person_id
  WITH maxcol = 1000
 ;end select
 DECLARE on_table_ind = i2
 DECLARE pcp_update = i2
 FOR (i = 1 TO t_record->pat_cnt)
   IF ((t_record->pat_qual[i].phys_id != 0))
    SET on_table_ind = 0
    SET pcp_update = 1
    SELECT INTO "nl:"
     FROM bhs_problem_registry b
     PLAN (b
      WHERE (b.person_id=t_record->pat_qual[i].pid)
       AND b.problem="ASTHMA")
     DETAIL
      on_table_ind = 1
     WITH nocounter
    ;end select
    IF (on_table_ind=0)
     INSERT  FROM bhs_problem_registry b
      SET b.person_id = t_record->pat_qual[i].pid, b.pcp_id = t_record->pat_qual[i].phys_id, b
       .problem = "ASTHMA",
       b.practice_id = 0.00, b.active_ind = 1
      WITH nocounter
     ;end insert
     COMMIT
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 SET reply->status_data[1].status = "S"
END GO
