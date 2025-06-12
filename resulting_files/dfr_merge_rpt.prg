CREATE PROGRAM dfr_merge_rpt
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 RECORD psid_cmb(
   1 pat_cnt = i4
   1 pat_qual[*]
     2 from_person_id = f8
     2 from_name = vc
     2 from_mrn = vc
     2 from_fin = vc
     2 to_person_id = f8
     2 to_name = vc
     2 to_mrn = vc
     2 to_fin = vc
 )
 RECORD psid_move(
   1 pat_cnt = i4
   1 pat_qual[*]
     2 from_person_id = f8
     2 from_name = vc
     2 from_mrn = vc
     2 from_fin = vc
     2 to_person_id = f8
     2 to_name = vc
     2 to_mrn = vc
     2 to_fin = vc
 )
 RECORD enbr_cmb(
   1 pat_cnt = i4
   1 pat_qual[*]
     2 from_person_id = f8
     2 from_name = vc
     2 from_mrn = vc
     2 from_fin = vc
     2 to_person_id = f8
     2 to_name = vc
     2 to_mrn = vc
     2 to_fin = vc
 )
 SELECT INTO  $OUTDEV
  pc.active_ind, pc.active_status_dt_tm"dd-mmm-yyyy hh:mm:ss;3;d", pc.encntr_id,
  pc.from_person_id, pc.to_person_id, from_name = p1.name_full_formatted,
  from_active = p1.active_ind, to_name = p2.name_full_formatted, to_active = p2.active_ind
  FROM person_combine pc,
   person p1,
   person p2
  PLAN (pc
   WHERE pc.encntr_id > 0)
   JOIN (p1
   WHERE p1.person_id=pc.from_person_id)
   JOIN (p2
   WHERE p2.person_id=pc.to_person_id)
  WITH nocounter, check
 ;end select
END GO
