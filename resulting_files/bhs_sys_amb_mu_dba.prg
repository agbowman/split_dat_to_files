CREATE PROGRAM bhs_sys_amb_mu:dba
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
     2 cismrn = vc
     2 fname = vc
     2 lname = vc
     2 pid = f8
     2 eid = f8
     2 reg = vc
     2 probflag = i2
     2 epresflag = i2
     2 medallergyflag = i2
     2 smokeflag = i2
     2 vitalflag = i2
     2 ageless13 = i2
     2 fax_ind = i2
     2 print_ind = i2
     2 age = vc
 )
 FREE DEFINE rtl
 DEFINE rtl "ccluserdir:mu_person_ids.csv"
 SELECT INTO "nl:"
  FROM rtlt r
  WHERE r.line > " "
  HEAD REPORT
   x = 0
  DETAIL
   x = (x+ 1), stat = alterlist(temp->qual,x), temp->qual[x].pid = cnvtreal(r.line)
  WITH nocounter
 ;end select
 CALL echo(build("qualified:",size(temp->qual,5)))
 FOR (x = 150000 TO 160000)
   CALL echo(build("amb Loop:",x,"of:",size(temp->qual,5)))
   SELECT INTO "nl:"
    FROM clinical_event ce,
     encounter e
    PLAN (ce
     WHERE (ce.person_id=temp->qual[x].pid)
      AND ce.clinsig_updt_dt_tm BETWEEN cnvtdatetime(cnvtdate(09012009),0) AND cnvtdatetime(cnvtdate(
       09012010),0)
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
     JOIN (e
     WHERE e.encntr_id=ce.encntr_id
      AND e.encntr_class_cd=319457)
    ORDER BY ce.encntr_id
    HEAD ce.encntr_id
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
    FOOT  ce.encntr_id
     IF ((((((ht+ wt)+ bmi)+ bps)+ bpd)=5))
      temp->qual[x].vitalflag = 1
     ENDIF
     CALL echo(build("patient:",x))
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM orders o,
     encounter e,
     order_compliance oc,
     order_detail od
    PLAN (o
     WHERE (o.person_id=temp->qual[x].pid)
      AND o.orig_ord_as_flag IN (1, 2, 3)
      AND o.catalog_type_cd=2516
      AND o.orig_order_dt_tm BETWEEN cnvtdatetime(cnvtdate(09012009),0) AND cnvtdatetime(cnvtdate(
       09012010),0))
     JOIN (e
     WHERE e.encntr_id=o.encntr_id
      AND e.encntr_class_cd=319457.00)
     JOIN (oc
     WHERE oc.encntr_id=outerjoin(e.encntr_id)
      AND oc.no_known_home_meds_ind=outerjoin(1))
     JOIN (od
     WHERE od.order_id=outerjoin(o.order_id)
      AND od.oe_field_meaning=outerjoin("REQROUTINGTYPE"))
    DETAIL
     temp->qual[x].epresflag = 1
     IF (od.oe_field_display_value="Route to Pharmacy*")
      temp->qual[x].fax_ind = 1
     ENDIF
     IF (od.oe_field_display_value="Print*")
      temp->qual[x].print_ind = 1
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
      AND hem.modifier_dt_tm BETWEEN cnvtdatetime(cnvtdate(09012009),0) AND cnvtdatetime(cnvtdate(
       09012010),0))
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
   SELECT INTO "nl:"
    FROM person p,
     person_alias pa
    PLAN (p
     WHERE (p.person_id=temp->qual[x].pid))
     JOIN (pa
     WHERE pa.person_id=p.person_id
      AND pa.active_ind=1
      AND pa.alias_pool_cd=674546.00)
    DETAIL
     temp->qual[x].lname = p.name_last_key, temp->qual[x].fname = p.name_first_key, temp->qual[x].
     cismrn = pa.alias
     IF (datetimecmp(cnvtdatetime(cnvtdate(09012010),0),p.birth_dt_tm) < 4751)
      temp->qual[x].ageless13 = 1
     ENDIF
     temp->qual[x].age = cnvtage(p.birth_dt_tm,cnvtdatetime(cnvtdate(09012010),0),0)
    WITH nocounter
   ;end select
 ENDFOR
 SELECT INTO "mu_amb_new_data2.csv"
  cmrn = substring(1,10,temp->qual[d.seq].cismrn), first_name = substring(1,30,temp->qual[d.seq].
   fname), last_name = substring(1,30,temp->qual[d.seq].lname),
  person_id = substring(1,10,cnvtstring(temp->qual[d.seq].pid)), problem_flag = substring(1,1,
   cnvtstring(temp->qual[d.seq].probflag)), med_profile = substring(1,1,cnvtstring(temp->qual[d.seq].
    epresflag)),
  e_pres_fax = substring(1,1,cnvtstring(temp->qual[d.seq].fax_ind)), e_pres_print = substring(1,1,
   cnvtstring(temp->qual[d.seq].print_ind)), allergy_flag = substring(1,1,cnvtstring(temp->qual[d.seq
    ].medallergyflag)),
  smoke_flag = substring(1,1,cnvtstring(temp->qual[d.seq].smokeflag)), vital_flag = substring(1,1,
   cnvtstring(temp->qual[d.seq].vitalflag)), ag_less13_flag = substring(1,1,cnvtstring(temp->qual[d
    .seq].ageless13)),
  age = substring(1,20,temp->qual[d.seq].age)
  FROM (dummyt d  WITH seq = value(size(temp->qual,5)))
  WITH nocounter, format, separator = ","
 ;end select
#exit_script
END GO
