CREATE PROGRAM bhs_populate_diabetes:dba
 FREE RECORD t_record
 RECORD t_record(
   1 person_cnt = i4
   1 person_qual[*]
     2 person_id = f8
     2 phys_id = f8
     2 phys_name = vc
 )
 DECLARE glucose_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"GLUCOSELEVEL"))
 DECLARE hemo_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"HEMOGLOBINA1C"))
 DECLARE num_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",53,"NUM"))
 DECLARE auth_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",8,"AUTHVERIFIED"))
 DECLARE pcp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",331,"PCP"))
 DECLARE e_type_1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"ACTIVEVNH"))
 DECLARE e_type_2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHVNH"))
 DECLARE e_type_3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"RECUROFFICEVISIT"))
 DECLARE e_type_4_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "PRERECUROFFICEVISIT"))
 DECLARE e_type_5_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "DISCHRECUROFFICEVISIT"))
 DECLARE e_type_6_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DISCHRECURRINGOP"))
 DECLARE e_type_7_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"PRECMTYOFFICEVISIT"
   ))
 DECLARE e_type_8_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,
   "ACTIVECMTYOFFICEVISIT"))
 DECLARE e_type_9_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"VNH"))
 DECLARE e_type_10_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"PREOFFICEVISIT"))
 DECLARE e_type_11_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"OFFICEVISIT"))
 DECLARE e_type_12_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"PREOUTPT"))
 DECLARE e_type_13_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"RECURRINGOP"))
 DECLARE e_type_14_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"ONETIMEOP"))
 DECLARE e_type_15_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"OUTPATIENT"))
 DECLARE idx1 = i4
 DECLARE indx = i2 WITH protect, noconstant(0)
 DECLARE nsize = i4 WITH protect, noconstant(0)
 DECLARE nbucketsize = i4 WITH protect, noconstant(0)
 DECLARE ntotal = i4 WITH protect, noconstant(0)
 DECLARE nstart = i4 WITH protect, noconstant(0)
 DECLARE nbuckets = i4 WITH protect, noconstant(0)
 DECLARE increment = i4 WITH protect, noconstant(100000)
 DECLARE start_id = f8 WITH protect, noconstant(0.00)
 DECLARE last_id = f8
 SET last_id = (start_id+ increment)
 DECLARE end_id = f8 WITH protect, noconstant(540000000.00)
 DECLARE done = i2
 WHILE (done=0)
   CALL echo(start_id)
   CALL echo(last_id)
   CALL echo(end_id)
   SELECT INTO "start_end.txt"
    FROM (dummyt d  WITH seq = 1)
    PLAN (d)
    DETAIL
     col 0,
     CALL print(start_id), row + 1,
     col 0,
     CALL print(last_id)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    result = cnvtint(ce.result_val)
    FROM clinical_event ce,
     encounter e
    PLAN (ce
     WHERE ce.clinical_event_id >= start_id
      AND ce.clinical_event_id <= last_id
      AND ce.event_cd=glucose_cd
      AND ce.event_class_cd=num_cd
      AND ce.result_status_cd=auth_cd)
     JOIN (e
     WHERE e.encntr_id=ce.encntr_id
      AND e.encntr_type_cd IN (e_type_1_cd, e_type_2_cd, e_type_3_cd, e_type_4_cd, e_type_5_cd,
     e_type_6_cd, e_type_7_cd, e_type_8_cd, e_type_9_cd, e_type_10_cd,
     e_type_11_cd, e_type_12_cd, e_type_13_cd, e_type_14_cd, e_type_15_cd))
    DETAIL
     IF (result > 125)
      IF ((t_record->person_cnt=0))
       t_record->person_cnt = (t_record->person_cnt+ 1), idx = t_record->person_cnt, stat = alterlist
       (t_record->person_qual,idx),
       t_record->person_qual[idx].person_id = ce.person_id
      ELSE
       idx1 = locateval(indx,1,t_record->person_cnt,ce.person_id,t_record->person_qual[indx].
        person_id)
       IF (idx1=0)
        t_record->person_cnt = (t_record->person_cnt+ 1)
        IF (mod(t_record->person_cnt,1000)=1)
         stat = alterlist(t_record->person_qual,(t_record->person_cnt+ 999))
        ENDIF
        idx = t_record->person_cnt, stat = alterlist(t_record->person_qual,idx), t_record->
        person_qual[idx].person_id = ce.person_id
       ENDIF
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(t_record->person_qual,t_record->person_cnt)
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
     idx1 = locateval(indx,1,t_record->person_cnt,ppr.person_id,t_record->person_qual[indx].person_id
      ), t_record->person_qual[idx1].phys_id = ppr.prsnl_person_id
    WITH maxcol = 1000
   ;end select
   DECLARE on_table_ind = i2
   FOR (i = 1 TO t_record->person_cnt)
     IF ((t_record->person_qual[i].phys_id != 0))
      SET on_table_ind = 0
      SELECT INTO "nl:"
       FROM bhs_problem_registry b
       PLAN (b
        WHERE (b.person_id=t_record->person_qual[i].person_id))
       DETAIL
        on_table_ind = 1
       WITH nocounter
      ;end select
      IF (on_table_ind=0)
       INSERT  FROM bhs_problem_registry b
        SET b.person_id = t_record->person_qual[i].person_id, b.pcp_id = t_record->person_qual[i].
         phys_id, b.active_ind = 1,
         b.practice_id = 0.00, b.problem = "DIABETES"
        WITH nocounter
       ;end insert
       COMMIT
      ENDIF
     ENDIF
   ENDFOR
   SET t_record->person_cnt = 0
   SET stat = alterlist(t_record->person_qual,0)
   SET start_id = (last_id+ 1)
   SET last_id = (start_id+ increment)
   IF (last_id > end_id)
    SET done = 1
   ENDIF
 ENDWHILE
END GO
