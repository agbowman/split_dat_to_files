CREATE PROGRAM bhs_ma_update_diabetes:dba
 FREE RECORD t_record
 RECORD t_record(
   1 person_cnt = i4
   1 person_qual[*]
     2 person_id = f8
     2 phys_id = f8
     2 phys_name = vc
     2 location_cd = f8
     2 active_ind = i2
 )
 DECLARE pcp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",331,"PCP"))
 DECLARE office_visit_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"OFFICEVISIT"))
 DECLARE pcp1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",333,"PPRIMARYCAREPHYSICIAN"
   ))
 DECLARE loc_ind = i2
 DECLARE indx = i4
 DECLARE on_table_ind = i2
 DECLARE count = i4
 SELECT INTO "nl:"
  FROM bhs_nomen_list n,
   problem p
  PLAN (n
   WHERE n.nomen_list_key="HM_DIABETESSCREENING")
   JOIN (p
   WHERE p.nomenclature_id=n.nomenclature_id
    AND  NOT ( EXISTS (
   (SELECT
    b.person_id
    FROM bhs_problem_registry b
    WHERE b.person_id=p.person_id))))
  ORDER BY p.person_id
  HEAD p.person_id
   IF ((t_record->person_cnt=0))
    t_record->person_cnt = (t_record->person_cnt+ 1), idx = t_record->person_cnt, stat = alterlist(
     t_record->person_qual,idx),
    t_record->person_qual[idx].person_id = p.person_id
   ELSE
    idx1 = locateval(indx,1,t_record->person_cnt,p.person_id,t_record->person_qual[indx].person_id)
    IF (idx1=0)
     t_record->person_cnt = (t_record->person_cnt+ 1), idx = t_record->person_cnt, stat = alterlist(
      t_record->person_qual,idx),
     t_record->person_qual[idx].person_id = p.person_id
    ENDIF
   ENDIF
 ;end select
 SELECT INTO "nl:"
  FROM bhs_nomen_list n,
   diagnosis d
  PLAN (n
   WHERE n.nomen_list_key="HM_DIABETESSCREENING")
   JOIN (d
   WHERE d.nomenclature_id=n.nomenclature_id
    AND  NOT ( EXISTS (
   (SELECT
    b.person_id
    FROM bhs_problem_registry b
    WHERE b.person_id=d.person_id))))
  ORDER BY d.person_id
  HEAD d.person_id
   IF ((t_record->person_cnt=0))
    t_record->person_cnt = (t_record->person_cnt+ 1), idx = t_record->person_cnt, stat = alterlist(
     t_record->person_qual,idx),
    t_record->person_qual[idx].person_id = d.person_id
   ELSE
    idx1 = locateval(indx,1,t_record->person_cnt,d.person_id,t_record->person_qual[indx].person_id)
    IF (idx1=0)
     t_record->person_cnt = (t_record->person_cnt+ 1), idx = t_record->person_cnt, stat = alterlist(
      t_record->person_qual,idx),
     t_record->person_qual[idx].person_id = d.person_id
    ENDIF
   ENDIF
  WITH maxcol = 1000
 ;end select
 SET nsize = t_record->person_cnt
 SET nbucketsize = 100
 SET ntotal = (ceil((cnvtreal(nsize)/ nbucketsize)) * nbucketsize)
 SET nstart = 1
 SET nbuckets = value((1+ ((ntotal - 1)/ nbucketsize)))
 SET stat = alterlist(t_record->person_qual,ntotal)
 FOR (j = (nsize+ 1) TO ntotal)
   SET t_record->person_qual[j].person_id = t_record->person_qual[nsize].person_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = nbuckets),
   person_prsnl_reltn ppr,
   prsnl p
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
   JOIN (ppr
   WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),ppr.person_id,t_record->person_qual[indx].
    person_id)
    AND ppr.person_prsnl_r_cd=pcp_cd
    AND ppr.active_ind=1
    AND ppr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (p
   WHERE p.person_id=ppr.prsnl_person_id
    AND p.name_last_key != "NOTONSTAFF")
  ORDER BY ppr.person_id
  HEAD ppr.person_id
   idx1 = locateval(indx,1,t_record->person_cnt,ppr.person_id,t_record->person_qual[indx].person_id),
   t_record->person_qual[idx1].phys_id = ppr.prsnl_person_id, t_record->person_qual[idx1].phys_name
    = p.name_full_formatted
  WITH nocounter
 ;end select
 FOR (i = 1 TO t_record->person_cnt)
   SELECT INTO "nl:"
    FROM sch_appt sa,
     sch_appt sa1,
     encounter e
    PLAN (sa
     WHERE (sa.person_id=t_record->person_qual[i].person_id)
      AND sa.state_meaning="CHECKED IN"
      AND sa.role_meaning="PATIENT")
     JOIN (sa1
     WHERE sa1.schedule_id=sa.schedule_id
      AND (sa1.person_id=t_record->person_qual[i].phys_id)
      AND sa1.state_meaning="CHECKED IN"
      AND sa1.role_meaning="RESOURCE")
     JOIN (e
     WHERE e.encntr_id=sa.encntr_id)
    ORDER BY sa1.beg_dt_tm DESC
    HEAD REPORT
     done_ind = 0
    HEAD sa1.beg_dt_tm
     IF (done_ind=0)
      t_record->person_qual[i].location_cd = e.location_cd, done_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   INSERT  FROM bhs_problem_registry b
    SET b.person_id = t_record->person_qual[i].person_id, b.pcp_id = t_record->person_qual[i].phys_id,
     b.practice_id = t_record->person_qual[i].location_cd,
     b.active_ind = 1, b.problem = "DIABETES"
    WITH nocounter
   ;end insert
   COMMIT
 ENDFOR
END GO
