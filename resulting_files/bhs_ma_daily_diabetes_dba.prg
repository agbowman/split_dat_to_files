CREATE PROGRAM bhs_ma_daily_diabetes:dba
 FREE RECORD t_record
 RECORD t_record(
   1 t_action_dt_tm = dq8
   1 start_dt_tm = dq8
   1 end_dt_tm = dq8
   1 meds_cnt = i4
   1 meds_qual[*]
     2 catalog_cd = f8
   1 person_cnt = i4
   1 person_qual[*]
     2 person_id = f8
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
 DECLARE glucose_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"GLUCOSELEVEL"))
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
 DECLARE pcp_update_cnt = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM bhs_problem_registry b,
   person_prsnl_reltn ppr
  PLAN (b
   WHERE b.problem="DIABETES")
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
     AND b.problem="DIABETES"
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
   WHERE n.nomen_list_key="HM_DIABETESSCREENING"
    AND n.active_ind=1
    AND n.nomenclature_id > 0)
   JOIN (p
   WHERE p.nomenclature_id=n.nomenclature_id
    AND p.updt_dt_tm >= cnvtdatetime(t_record->start_dt_tm)
    AND p.updt_dt_tm <= cnvtdatetime(t_record->end_dt_tm))
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
   WHERE n.nomen_list_key="HM_DIABETESSCREENING"
    AND n.active_ind=1
    AND n.nomenclature_id > 0)
   JOIN (d
   WHERE d.nomenclature_id=n.nomenclature_id
    AND d.updt_dt_tm >= cnvtdatetime(t_record->start_dt_tm)
    AND d.updt_dt_tm <= cnvtdatetime(t_record->end_dt_tm))
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
 FREE DEFINE rtl2
 DEFINE rtl2 "diabetes_meds.dat"
 SELECT INTO "nl:"
  FROM rtl2t m,
   order_catalog_synonym ocs
  PLAN (m)
   JOIN (ocs
   WHERE ocs.mnemonic_key_cap=m.line)
  DETAIL
   t_record->meds_cnt = (t_record->meds_cnt+ 1), idx = t_record->meds_cnt, stat = alterlist(t_record
    ->meds_qual,idx),
   t_record->meds_qual[idx].catalog_cd = ocs.catalog_cd
  WITH nocounter
 ;end select
 DECLARE med_string = vc
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->meds_cnt)
  PLAN (d)
  DETAIL
   IF (d.seq=1)
    med_string = trim(cnvtstring(t_record->meds_qual[d.seq].catalog_cd))
   ELSE
    med_string = concat(med_string,",",trim(cnvtstring(t_record->meds_qual[d.seq].catalog_cd)))
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(t_record->meds_qual,0)
 SET med_string = concat("o.catalog_cd+0 in (",med_string,")")
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE o.orig_order_dt_tm >= cnvtdatetime(t_record->start_dt_tm)
    AND o.orig_order_dt_tm <= cnvtdatetime(t_record->end_dt_tm)
    AND parser(med_string))
  DETAIL
   IF (o.orig_ord_as_flag=2)
    IF ((t_record->person_cnt=0))
     t_record->person_cnt = (t_record->person_cnt+ 1), idx = t_record->person_cnt, stat = alterlist(
      t_record->person_qual,idx),
     t_record->person_qual[idx].person_id = o.person_id
    ELSE
     idx1 = locateval(indx,1,t_record->person_cnt,o.person_id,t_record->person_qual[indx].person_id)
     IF (idx1=0)
      t_record->person_cnt = (t_record->person_cnt+ 1), idx = t_record->person_cnt, stat = alterlist(
       t_record->person_qual,idx),
      t_record->person_qual[idx].person_id = o.person_id
     ENDIF
    ENDIF
   ENDIF
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  result = cnvtint(ce.result_val)
  FROM clinical_event ce,
   encounter e
  PLAN (ce
   WHERE ce.clinsig_updt_dt_tm >= cnvtdatetime(t_record->start_dt_tm)
    AND ce.clinsig_updt_dt_tm <= cnvtdatetime(t_record->end_dt_tm)
    AND ce.event_cd=glucose_cd
    AND ce.event_class_cd=num_cd
    AND ce.result_status_cd=auth_cd)
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id
    AND e.encntr_type_cd IN (e_type_1_cd, e_type_2_cd, e_type_3_cd, e_type_4_cd, e_type_5_cd,
   e_type_6_cd, e_type_7_cd, e_type_8_cd, e_type_9_cd, e_type_10_cd,
   e_type_11_cd, e_type_12_cd, e_type_13_cd, e_type_14_cd, e_type_15_cd))
  DETAIL
   IF (result > 200)
    IF ((t_record->person_cnt=0))
     t_record->person_cnt = (t_record->person_cnt+ 1), idx = t_record->person_cnt, stat = alterlist(
      t_record->person_qual,idx),
     t_record->person_qual[idx].person_id = ce.person_id
    ELSE
     idx1 = locateval(indx,1,t_record->person_cnt,ce.person_id,t_record->person_qual[indx].person_id)
     IF (idx1=0)
      t_record->person_cnt = (t_record->person_cnt+ 1), idx = t_record->person_cnt, stat = alterlist(
       t_record->person_qual,idx),
      t_record->person_qual[idx].person_id = ce.person_id
     ENDIF
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
   t_record->person_qual[idx1].phys_id = ppr.prsnl_person_id
  WITH maxcol = 1000
 ;end select
 DECLARE on_table_ind = i2
 DECLARE pcp_update = i2
 FOR (i = 1 TO t_record->person_cnt)
   IF ((t_record->person_qual[i].phys_id != 0))
    SET on_table_ind = 0
    SET pcp_update = 1
    SELECT INTO "nl:"
     FROM bhs_problem_registry b
     PLAN (b
      WHERE (b.person_id=t_record->person_qual[i].person_id)
       AND b.problem="DIABETES")
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
 CALL echorecord(t_record,"t_record.dat")
#exit_script
 SET reply->status_data[1].status = "S"
END GO
