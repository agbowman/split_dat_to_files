CREATE PROGRAM djh_sample_3:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter Medication:" = "<<Enter Med Name>>"
  WITH outdev, medname
 FREE RECORD rec1
 RECORD rec1(
   1 med_name = c40
   1 qual[*]
     2 pt_name = c30
     2 ords_date = c10
     2 location = c30
     2 personid = f8
     2 algeries[*]
       3 display = vc
     2 diagnosis[*]
       3 display = vc
     2 care_providers[*]
       3 name = c30
       3 position = c30
 )
 DECLARE medication_cd = f8
 SET medication_cd = uar_get_code_by("displaykey",200,value( $MEDNAME))
 SELECT INTO "nl:"
  FROM orders o,
   person pe,
   encounter e
  PLAN (o
   WHERE o.catalog_cd=medication_cd
    AND o.orig_order_dt_tm BETWEEN cnvtdatetime((curdate - 60),0) AND cnvtdatetime(curdate,0))
   JOIN (pe
   WHERE pe.person_id=o.person_id)
   JOIN (e
   WHERE e.encntr_id=o.encntr_id)
  ORDER BY o.person_id
  HEAD REPORT
   cnt = 0, rec1->med_name =  $MEDNAME
  HEAD o.person_id
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(rec1->qual,(cnt+ 9))
   ENDIF
   rec1->qual[cnt].pt_name = substring(1,30,pe.name_full_formatted), rec1->qual[cnt].ords_date =
   format(o.orig_order_dt_tm,"mm/dd/yy;;d"), rec1->qual[cnt].location = build(uar_get_code_dislpay(e
     .loc_nurse_unit_cd)," /",uar_get_code_display(e.loc_room_cd)," /",uar_get_code_display(e
     .loc_bed_cd)),
   rec1->qual[cnt].personid = o.person_id
  FOOT REPORT
   stat = alterlist(rec1->qual,(cnt+ 9))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  personid = rec1->qual[d1.seq].personid
  FROM (dummyt d1  WITH seq = vaule(size(rec1->qual,5))),
   allergy a,
   nomenclature n
  PLAN (d1)
   JOIN (a
   WHERE a.person_id=outerjoin(rec1->qual[d1.seq].personid))
   JOIN (n
   WHERE n.nomenclature_id=outerjoin(a.substance_nom_id))
  ORDER BY personid
  HEAD REPORT
   cnt = 0
  HEAD personid
   cnt = (cnt+ 1), stat = alterlist(rec1->qual[d1.seq].allergies,cnt), rec1->qual[d1.seq].allergies[
   cnt].display = build(n.souce_string,a.substance_ftdesc)
  FOOT  personid
   cnt = 0
  FOOT REPORT
   stat = alterlist(rec1->qual[d1.seq].allergies,cnt)
 ;end select
 SELECT INTO  $OUTDEV
  HEAD REPORT
   col 10, "TEST PRINT", row + 1
 ;end select
END GO
