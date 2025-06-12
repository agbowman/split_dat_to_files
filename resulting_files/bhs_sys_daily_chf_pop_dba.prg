CREATE PROGRAM bhs_sys_daily_chf_pop:dba
 FREE RECORD t_record
 RECORD t_record(
   1 t_action_dt_tm = dq8
   1 start_dt_tm = dq8
   1 end_dt_tm = dq8
   1 person_cnt = i4
   1 person_qual[*]
     2 person_id = f8
     2 phys_id = f8
     2 prob_ind = i2
   1 pat_cnt = i4
   1 pat_qual[*]
     2 pid = f8
     2 phys_id = f8
 )
 FREE RECORD reply
 RECORD reply(
   1 status_data[1]
     2 status = c1
 )
 FREE RECORD t_record2
 RECORD t_record2(
   1 qual[*]
     2 personid = f8
     2 pcp_id = f8
     2 updt_ind = i2
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
   WHERE b.problem="CHF")
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
     AND b.problem="CHF"
     AND b.active_ind=1
    WITH nocounter
   ;end update
   COMMIT
  ENDFOR
 ENDIF
 SELECT INTO "nl:"
  FROM bhs_nomen_list n,
   problem p
  PLAN (n
   WHERE n.nomen_list_key="REGISTRY-CHF")
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
   WHERE n.nomen_list_key="REGISTRY-CHF")
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
  FROM (dummyt d  WITH seq = t_record->person_cnt)
  PLAN (d
   WHERE (t_record->person_qual[d.seq].prob_ind=1))
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
 FOR (i = 1 TO t_record->pat_cnt)
   IF ((t_record->pat_qual[i].phys_id != 0))
    SET on_table_ind = 0
    SET pcp_update = 1
    SELECT INTO "nl:"
     FROM bhs_problem_registry b
     PLAN (b
      WHERE (b.person_id=t_record->pat_qual[i].pid)
       AND b.problem="CHF")
     DETAIL
      on_table_ind = 1
      IF ((b.pcp_id=t_record->pat_qual[i].phys_id))
       pcp_update = 0
      ENDIF
     WITH nocounter
    ;end select
    IF (on_table_ind=0)
     INSERT  FROM bhs_problem_registry b
      SET b.person_id = t_record->pat_qual[i].pid, b.pcp_id = t_record->pat_qual[i].phys_id, b
       .problem = "CHF",
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
