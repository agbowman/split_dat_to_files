CREATE PROGRAM bhs_sys_inpt_bmc:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE str = vc WITH noconstant(" ")
 DECLARE notfnd = vc WITH constant("<not_found>")
 DECLARE num = i4 WITH noconstant(1)
 DECLARE data = vc
 SET bucket = 0
 FREE RECORD temp
 RECORD temp(
   1 qual[*]
     2 line = vc
     2 mrn = vc
     2 acct = vc
     2 fname = vc
     2 lname = vc
     2 pid = f8
     2 eidlist[*]
       3 eid = f8
       3 reg = vc
       3 etype = vc
     2 probflag = i2
     2 medflag = i2
     2 medallergyflag = i2
     2 cpoeflag = i2
     2 smokeflag = i2
     2 vitalflag = i2
     2 ageless13 = i2
     2 fax_ind = i2
     2 print_ind = i2
     2 pos = c2
     2 age = vc
 )
 FREE DEFINE rtl
 DEFINE rtl "ccluserdir:2010_bmc_mrn.txt"
 SELECT INTO "nl:"
  FROM rtlt r
  WHERE r.line > " "
  HEAD REPORT
   x = 0
  DETAIL
   x = (x+ 1), stat = alterlist(temp->qual,x), temp->qual[x].line = trim(r.line,3),
   temp->qual[x].mrn = trim(r.line,3)
  WITH nocounter
 ;end select
 CALL echo(build("qualified:",size(temp->qual,5)))
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(temp->qual,5))),
   person_alias pa,
   encounter e,
   person p
  PLAN (d)
   JOIN (pa
   WHERE (pa.alias=temp->qual[d.seq].mrn)
    AND ((pa.active_ind+ 0)=1)
    AND ((pa.end_effective_dt_tm+ 0) > sysdate)
    AND ((pa.alias_pool_cd+ 0)=674540.00))
   JOIN (e
   WHERE e.person_id=pa.person_id
    AND e.disch_dt_tm BETWEEN cnvtdatetime(cnvtdate(08012009),0) AND cnvtdatetime(cnvtdate(09312010),
    0)
    AND e.encntr_class_cd IN (319455, 319456))
   JOIN (p
   WHERE p.person_id=e.person_id)
  ORDER BY d.seq
  HEAD d.seq
   temp->qual[d.seq].pid = p.person_id, temp->qual[d.seq].fname = p.name_first_key, temp->qual[d.seq]
   .lname = p.name_last_key,
   cnt = 0, pos21 = 0, pos23 = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(temp->qual[d.seq].eidlist,cnt), temp->qual[d.seq].eidlist[cnt].
   eid = e.encntr_id,
   temp->qual[d.seq].eidlist[cnt].reg = format(e.reg_dt_tm,"mm/dd/yyyy hh:mm;;d"), temp->qual[d.seq].
   eidlist[cnt].etype = uar_get_code_display(e.encntr_class_cd)
   IF (datetimecmp(cnvtdatetime(cnvtdate(09012010),0),p.birth_dt_tm) < 4751)
    temp->qual[d.seq].ageless13 = 1
   ENDIF
   temp->qual[d.seq].age = cnvtage(p.birth_dt_tm,cnvtdatetime(cnvtdate(09012010),0),0)
   IF (e.encntr_class_cd=319455)
    pos23 = 1
   ELSE
    pos21 = 1
   ENDIF
  FOOT  d.seq
   IF (pos21=1)
    temp->qual[d.seq].pos = "21"
   ELSE
    temp->qual[d.seq].pos = "23"
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("qualified:",size(temp->qual,5)))
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(temp->qual,5))),
   problem p
  PLAN (d
   WHERE (temp->qual[d.seq].pid > 0))
   JOIN (p
   WHERE (p.person_id=temp->qual[d.seq].pid))
  DETAIL
   temp->qual[d.seq].probflag = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(temp->qual,5))),
   diagnosis dx
  PLAN (d
   WHERE (temp->qual[d.seq].pid > 0))
   JOIN (dx
   WHERE (dx.person_id=temp->qual[d.seq].pid))
  DETAIL
   temp->qual[d.seq].probflag = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(temp->qual,5))),
   allergy a
  PLAN (d
   WHERE (temp->qual[d.seq].pid > 0))
   JOIN (a
   WHERE (a.person_id=temp->qual[d.seq].pid)
    AND a.substance_type_cd=3288.00)
  DETAIL
   temp->qual[d.seq].medallergyflag = 1
  WITH nocounter
 ;end select
 FOR (x = 1 TO size(temp->qual,5))
  CALL echo(build("BMC LOOP:",x))
  IF ((temp->qual[x].pid > 0))
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(temp->qual[x].eidlist,5))),
     orders o,
     order_compliance oc
    PLAN (d)
     JOIN (o
     WHERE (o.encntr_id=temp->qual[x].eidlist[d.seq].eid)
      AND o.orig_ord_as_flag IN (1, 2, 3)
      AND o.catalog_type_cd=2516)
     JOIN (oc
     WHERE oc.encntr_id=outerjoin(o.encntr_id))
    DETAIL
     temp->qual[x].medflag = 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(temp->qual[x].eidlist,5))),
     orders o
    PLAN (d)
     JOIN (o
     WHERE (o.encntr_id=temp->qual[x].eidlist[d.seq].eid)
      AND  EXISTS (
     (SELECT
      oa.order_id
      FROM order_action oa
      WHERE oa.order_id=o.order_id
       AND oa.action_sequence=1
       AND  EXISTS (
      (SELECT
       pr.person_id
       FROM prsnl pr
       WHERE pr.person_id=oa.action_personnel_id
        AND pr.physician_ind=1)))))
    DETAIL
     temp->qual[x].cpoeflag = 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(temp->qual[x].eidlist,5))),
     clinical_event ce
    PLAN (d)
     JOIN (ce
     WHERE (ce.encntr_id=temp->qual[x].eidlist[d.seq].eid)
      AND  EXISTS (
     (SELECT
      cv.code_value
      FROM code_value cv
      WHERE cv.code_value=ce.event_cd
       AND cv.code_set=72
       AND ((cv.display_key="*SMOK*") OR (((cv.display_key="HEIGHT") OR (((cv.display_key="WEIGHT")
       OR (((cv.display_key="BODYMASSINDEX*") OR (((cv.display_key="SYSTOLICBLOODPRESSURE*") OR (cv
      .display_key="DIASTOLICBLOODPRESSURE*")) )) )) )) ))
       AND cv.code_set=72
       AND cv.active_ind=1)))
    ORDER BY d.seq
    HEAD REPORT
     bpd = 0, bps = 0, bmi = 0,
     wt = 0, ht = 0
    HEAD d.seq
     bpd = 0, bps = 0, bmi = 0,
     wt = 0, ht = 0
    DETAIL
     CASE (cnvtupper(uar_get_code_display(ce.event_cd)))
      OF "HEIGHT":
       ht = 1
      OF "WEIGHT":
       wt = 1
      OF "BODY MASS INDEX*":
       bmi = 1
      OF "SYSTOLIC BLOOD PRESSURE*":
       bps = 1
      OF "DIASTOLIC BLOOD PRESSURE*":
       bpd = 1
      OF "*SMOK*":
       temp->qual[x].smokeflag = 1
     ENDCASE
     CALL echo(cnvtupper(uar_get_code_display(ce.event_cd)))
    FOOT  d.seq
     IF ((((((ht+ wt)+ bmi)+ bps)+ bpd)=5))
      temp->qual[x].vitalflag = 1
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM hm_expect_mod hem,
     hm_expect_sat hes,
     hm_expect he
    PLAN (hem
     WHERE (hem.person_id=temp->qual[x].pid)
      AND hem.active_ind=1
      AND hem.modifier_dt_tm BETWEEN cnvtdatetime(cnvtdate(08012009),0) AND cnvtdatetime(cnvtdate(
       09312010),0))
     JOIN (hes
     WHERE hes.expect_sat_id=hem.expect_sat_id
      AND hes.active_ind=1)
     JOIN (he
     WHERE hes.expect_id=he.expect_id
      AND he.expect_name="Tobacco*"
      AND he.active_ind=1)
    DETAIL
     temp->qual[x].smokeflag = 1
    WITH nocounter
   ;end select
  ENDIF
 ENDFOR
 SELECT INTO "mu_inpt_bmc2.csv"
  mrn = substring(1,10,temp->qual[d.seq].mrn), first_name = substring(1,30,temp->qual[d.seq].fname),
  last_name = substring(1,30,temp->qual[d.seq].lname),
  person_id = substring(1,10,cnvtstring(temp->qual[d.seq].pid)), problem_flag = substring(1,1,
   cnvtstring(temp->qual[d.seq].probflag)), med_flag = substring(1,1,cnvtstring(temp->qual[d.seq].
    medflag)),
  allergy_flag = substring(1,1,cnvtstring(temp->qual[d.seq].medallergyflag)), smoke_flag = substring(
   1,1,cnvtstring(temp->qual[d.seq].smokeflag)), vital_flag = substring(1,1,cnvtstring(temp->qual[d
    .seq].vitalflag)),
  ag_less13_flag = substring(1,1,cnvtstring(temp->qual[d.seq].ageless13)), age = substring(1,20,temp
   ->qual[d.seq].age), cpoe = substring(1,1,cnvtstring(temp->qual[d.seq].cpoeflag)),
  pos = substring(1,2,temp->qual[d.seq].pos)
  FROM (dummyt d  WITH seq = value(size(temp->qual,5)))
  WITH nocounter, format, separator = ","
 ;end select
#exit_script
END GO
