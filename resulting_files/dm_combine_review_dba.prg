CREATE PROGRAM dm_combine_review:dba
 FREE SET rcmbchildren
 RECORD rcmbchildren(
   1 qual1[100]
     2 child_table = c50
     2 person_constraint = c50
     2 encntr_constraint = c50
   1 qual2[100]
     2 child_table = c50
     2 person_constraint = c50
     2 encntr_constraint = c50
   1 qual3[30]
     2 child_table = c50
     2 script_name = c50
     2 script_run_order = i4
 )
 FREE SET rcmblist
 RECORD rcmblist(
   1 qual[100]
     2 cmb_entity = c50
     2 cmb_entity_attribute = c50
     2 cmb_entity_pk = c50
     2 cmb_entity_encntr_attr = c50
 )
 RECORD pclist(
   1 pqual[*]
     2 person_combine_id = f8
     2 from_person_id = f8
     2 to_person_id = f8
     2 encntr_id = f8
 )
 RECORD eclist(
   1 equal[*]
     2 encntr_combine_id = f8
     2 from_encntr_id = f8
     2 to_encntr_id = f8
 )
 SET request->cmb_mode = "REVIEW"
 SET child_ind = 0
 SET childcount1 = 0
 SET childcount2 = 0
 SET childcount3 = 0
 SET childcount4 = 0
 SET max_script_run_order = 0
 SET rdate1 = cnvtdatetime((curdate - 2),curtime3)
 SET rdate2 = format(rdate1,"DD-MMM-YYYY;;D")
 SET rdate3_str = concat(rdate2," 23:00:00")
 SET rdate3 = cnvtdatetime(rdate3_str)
 SET sdate1 = cnvtdatetime((curdate - 1),curtime3)
 SET sdate2 = format(sdate1,"DD-MM-YYYY;;D")
 SET sdate3_str = concat(sdate2," 00:00:00")
 SET sdate3 = cnvtdatetime(sdate3_str)
 SET pc_cnt = 0
 SELECT INTO "nl:"
  pc.person_combine_id
  FROM person_combine pc
  WHERE pc.active_ind=1
   AND pc.updt_dt_tm BETWEEN cnvtdatetime(rdate3) AND cnvtdatetime(sdate3)
  DETAIL
   pc_cnt += 1, stat = alterlist(pclist->pqual,pc_cnt), pclist->pqual[pc_cnt].person_combine_id = pc
   .person_combine_id,
   pclist->pqual[pc_cnt].from_person_id = pc.from_person_id, pclist->pqual[pc_cnt].to_person_id = pc
   .to_person_id, pclist->pqual[pc_cnt].encntr_id = pc.encntr_id
  WITH nocounter
 ;end select
 SET request->parent_table = "PERSON"
 SET request->cmb_mode = "REVIEW"
 FOR (dm_x = 1 TO pc_cnt)
   SET stat = alterlist(request->xxx_combine,0)
   SET stat = alterlist(request->xxx_combine_det,0)
   SET request->xxx_combine[dm_x].xxx_combine_id = pclist->pqual[dm_x].person_combine_id
   SET request->xxx_combine[dm_x].from_xxx_id = pclist->pqual[dm_x].from_person_id
   SET request->xxx_combine[dm_x].to_xxx_id = pclist->pqual[dm_x].to_person_id
   SET request->xxx_combine[dm_x].encntr_id = pclist->pqual[dm_x].encntr_id
   EXECUTE dm_call_combine
   IF (dm_x=1)
    SET child_ind = 1
   ENDIF
 ENDFOR
 FREE SET pclist
 SET enc_cnt = 0
 SELECT INTO "nl:"
  ec.encntr_combine_id
  FROM encntr_combine ec
  WHERE ec.active_ind=1
   AND ec.updt_dt_tm BETWEEN cnvtdatetime(rdate3) AND cnvtdatetime(rdate2)
  DETAIL
   enc_cnt += 1, stat = alterlist(eclist->equal,enc_cnt), eclist->equal[enc_cnt].encntr_combine_id =
   ec.encntr_combine_id,
   eclist->equal[enc_cnt].from_encntr_id = ec.from_encntr_id, eclist->equal[enc_cnt].to_encntr_id =
   ec.to_encntr_id
  WITH nocounter
 ;end select
 SET request->parent_table = "ENCOUNTER"
 SET request->cmb_mode = "REVIEW"
 SET child_ind = 0
 FOR (dm_y = 1 TO enc_cnt)
   SET stat = alterlist(request->xxx_combine,0)
   SET stat = alterlist(request->xxx_combine_det,0)
   SET request->xxx_combine[dm_y].xxx_combine_id = eclist->equal[dm_y].encntr_combine_id
   SET request->xxx_combine[dm_y].from_xxx_id = eclist->equal[dm_y].from_encntr_id
   SET request->xxx_combine[dm_y].to_xxx_id = eclist->equal[dm_y].to_encntr_id
   SET request->xxx_combine[dm_y].encntr_id = eclist->equal[dm_y].encntr_id
   EXECUTE dm_call_combine
   IF (dm_y=1)
    SET child_ind = 1
   ENDIF
 ENDFOR
 FREE SET eclist
END GO
