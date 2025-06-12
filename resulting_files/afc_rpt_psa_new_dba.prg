CREATE PROGRAM afc_rpt_psa_new:dba
 SET line130 = fillstring(130,"-")
 SET lineast = fillstring(130,"*")
 RECORD tpa_cd(
   1 qual = i2
   1 list[*]
     2 code_value_string = vc
     2 code_value = f8
     2 display = c10
     2 cdf_meaning = c12
 )
 RECORD gl_cd(
   1 qual = i2
   1 list[*]
     2 code_value = f8
     2 display = c10
     2 cdf_meaning = c12
 )
 RECORD cpt_cd(
   1 qual = i2
   1 list[*]
     2 code_value = f8
     2 display = c10
     2 cdf_meaning = c12
 )
 RECORD chg_pt_sched(
   1 qual = i2
   1 list[*]
     2 code_value = f8
     2 display = c10
     2 cdf_meaning = c12
 )
 SET count1 = 0
 SELECT INTO "nl:"
  cv.*
  FROM code_value cv
  WHERE cv.code_set=14002
   AND cv.cdf_meaning="CDM_SCHED"
   AND cv.active_ind=1
  DETAIL
   count1 = (count1+ 1), stat = alterlist(tpa_cd->list,count1), tpa_cd->list[count1].
   code_value_string = cnvtstring(cv.code_value,17,2),
   tpa_cd->list[count1].code_value = cv.code_value, tpa_cd->list[count1].display = cv.display, tpa_cd
   ->list[count1].cdf_meaning = cv.cdf_meaning
  WITH nocounter
 ;end select
 SET tpa_cd->qual = count1
 FOR (count1 = 1 TO tpa_cd->qual)
   CALL echo(tpa_cd->list[count1].code_value)
 ENDFOR
 SET count1 = 0
 SELECT INTO "nl:"
  cv.*
  FROM code_value cv
  WHERE cv.code_set=14002
   AND cv.cdf_meaning="GL"
   AND cv.active_ind=1
  DETAIL
   count1 = (count1+ 1), stat = alterlist(gl_cd->list,count1), gl_cd->list[count1].code_value = cv
   .code_value,
   gl_cd->list[count1].display = cv.display, gl_cd->list[count1].cdf_meaning = cv.cdf_meaning
  WITH nocounter
 ;end select
 SET gl_cd->qual = count1
 SET count1 = 0
 SELECT INTO "nl:"
  cv.*
  FROM code_value cv
  WHERE cv.code_set=14002
   AND cv.cdf_meaning="CPT4"
   AND cv.active_ind=1
  DETAIL
   count1 = (count1+ 1), stat = alterlist(cpt_cd->list,count1), cpt_cd->list[count1].code_value = cv
   .code_value,
   cpt_cd->list[count1].display = cv.display, cpt_cd->list[count1].cdf_meaning = cv.cdf_meaning
  WITH nocounter
 ;end select
 SET cpt_cd->qual = count1
 SET count1 = 0
 SELECT INTO "nl:"
  cv.*
  FROM code_value cv
  WHERE cv.code_set=14002
   AND cv.cdf_meaning="CHARGE POINT"
   AND cv.active_ind=1
  DETAIL
   count1 = (count1+ 1), stat = alterlist(chg_pt_sched->list,count1), chg_pt_sched->list[count1].
   code_value = cv.code_value,
   chg_pt_sched->list[count1].display = cv.display, chg_pt_sched->list[count1].cdf_meaning = cv
   .cdf_meaning
  WITH nocounter
 ;end select
 SET chg_pt_sched->qual = count1
 SET i = 0
 SET rowinc = 0
 SET maxrowinc = 0
 SELECT
  p.*, ps_desc = substring(1,100,p.price_sched_desc), psi.*,
  b.*, chg_lvl = substring(0,10,chglvl.display), bim.*,
  billcode = substring(0,9,bim.key2), desc = build(substring(1,50,b.ext_short_desc)," ",cnvtstring(b
    .bill_item_id))
  FROM price_sched p,
   price_sched_items psi,
   code_value chglvl,
   bill_item b,
   bill_item_modifier bim,
   (dummyt tpa_struct  WITH seq = value(tpa_cd->qual)),
   dummyt d1
  PLAN (b
   WHERE (b.ext_owner_cd=
   (SELECT
    cv.code_value
    FROM code_value cv
    WHERE cdf_meaning="GLB"
     AND code_set=106))
    AND b.active_ind=1)
   JOIN (d1)
   JOIN (psi
   WHERE psi.bill_item_id=b.bill_item_id
    AND psi.active_ind=1)
   JOIN (chglvl
   WHERE chglvl.code_value=psi.charge_level_cd)
   JOIN (p
   WHERE p.price_sched_id=psi.price_sched_id
    AND p.active_ind=1)
   JOIN (tpa_struct)
   JOIN (bim
   WHERE bim.bill_item_id=b.bill_item_id
    AND bim.active_ind=1
    AND (bim.key1=tpa_cd->list[tpa_struct.seq].code_value_string))
  ORDER BY p.price_sched_id, b.ext_parent_reference_id, b.ext_child_reference_id,
   bim.key3
  HEAD PAGE
   col 05, "Parent", row + 1,
   col 10, "Child Desc"
   FOR (i = 1 TO tpa_cd->qual)
     col 30, tpa_cd->list[i].display, row + 1,
     rowinc = i
   ENDFOR
   IF (rowinc > maxrowinc)
    maxrowinc = rowinc
   ENDIF
   row- (rowinc)
   FOR (i = 1 TO gl_cd->qual)
     col 45, gl_cd->list[i].display, row + 1,
     rowinc = i
   ENDFOR
   IF (rowinc > maxrowinc)
    maxrowinc = rowinc
   ENDIF
   row- (rowinc)
   FOR (i = 1 TO cpt_cd->qual)
     col 60, cpt_cd->list[i].display, row + 1,
     rowinc = i
   ENDFOR
   IF (rowinc > maxrowinc)
    maxrowinc = rowinc
   ENDIF
   row- (rowinc)
   FOR (i = 1 TO chg_pt_sched->qual)
     col 75, chg_pt_sched->list[i].display, row + 1,
     rowinc = i
   ENDFOR
   IF (rowinc > maxrowinc)
    maxrowinc = rowinc
   ENDIF
   row- (rowinc), col 90, "Charge Lvl",
   col 100, "Price", row + (maxrowinc+ 1),
   col 01, line130, row + 2
   IF (curpage > 1)
    col 02, "Price Schedule: ", col 20,
    ps_desc, row + 1
   ENDIF
  HEAD p.price_sched_id
   row + 2, col 01, "Price Schedule: ",
   col 20, ps_desc, row + 1
  HEAD b.ext_parent_reference_id
   IF (b.ext_child_reference_id=0)
    row + 1, col 05, desc,
    col 90, chg_lvl, col 100,
    psi.price
   ENDIF
  HEAD b.ext_child_reference_id
   IF (b.ext_child_reference_id > 0)
    row + 1
    IF (b.ext_parent_reference_id=0)
     col 09, "*"
    ENDIF
    col 10, b.ext_short_desc, col 90,
    chg_lvl, col 100, psi.price
   ENDIF
  DETAIL
   IF (trim(billcode,3) != "")
    col 30, billcode, row + 1
   ENDIF
  FOOT  p.price_sched_id
   row + 3
  WITH nocounter, outerjoin = tpa_struct, outerjoin = d1
 ;end select
 FREE SET tpa_cd
 FREE SET gl_cd
 FREE SET cpt_cd
 FREE SET chg_pt_sched
END GO
