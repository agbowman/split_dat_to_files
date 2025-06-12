CREATE PROGRAM dcp_pwrgrid_event_cd_rpt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE count = i4
 SET count = 0
 DECLARE count1 = i4
 SET count1 = 0
 DECLARE count2 = i4
 SET count2 = 0
 DECLARE curr_input_ref_id = f8
 DECLARE prev_input_ref_id = f8
 DECLARE curr_merge_id = f8
 DECLARE prev_merge_id = f8
 DECLARE def = vc
 DECLARE desc = vc
 RECORD pwrgrid_event_cd(
   1 list[*]
     2 input_ref_id = f8
     2 parent_entity_name = vc
     2 pvc_name = c32
     2 merge_id = f8
   1 section_ref_id_list[*]
     2 sec_ref_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SELECT INTO "TEMP:"
  d.dcp_input_ref_id, d.dcp_section_ref_id, n.parent_entity_name,
  n.pvc_name, n.merge_id
  FROM dcp_input_ref d,
   name_value_prefs n
  PLAN (d
   WHERE d.active_ind=1
    AND d.input_type=17)
   JOIN (n
   WHERE n.parent_entity_id=d.dcp_input_ref_id
    AND n.parent_entity_name="DCP_INPUT_REF"
    AND ((n.pvc_name="grid_event_cd") OR (n.pvc_name="row_event_cd")) )
  ORDER BY d.dcp_input_ref_id
  HEAD REPORT
   count = 0, stat = alterlist(pwrgrid_event_cd->list,10), stat = alterlist(pwrgrid_event_cd->
    section_ref_id_list,10)
  DETAIL
   count = (count+ 1)
   IF (mod(count,10)=1)
    stat = alterlist(pwrgrid_event_cd->list,(count+ 9))
   ENDIF
   pwrgrid_event_cd->list[count].parent_entity_name = n.parent_entity_name, pwrgrid_event_cd->list[
   count].merge_id = n.merge_id, pwrgrid_event_cd->list[count].pvc_name = n.pvc_name,
   pwrgrid_event_cd->list[count].input_ref_id = d.dcp_input_ref_id
   IF (count=1)
    prev_input_ref_id = pwrgrid_event_cd->list[count].input_ref_id, prev_merge_id = pwrgrid_event_cd
    ->list[count].merge_id
   ENDIF
   IF (count != 1)
    curr_input_ref_id = pwrgrid_event_cd->list[count].input_ref_id, curr_merge_id = pwrgrid_event_cd
    ->list[count].merge_id
    IF (curr_input_ref_id=prev_input_ref_id)
     IF (curr_merge_id=prev_merge_id)
      count1 = (count1+ 1)
      IF (mod(count1,10)=1)
       stat = alterlist(pwrgrid_event_cd->section_ref_id_list,(count1+ 9))
      ENDIF
      pwrgrid_event_cd->section_ref_id_list[count1].sec_ref_id = d.dcp_section_ref_id
     ENDIF
    ENDIF
    prev_input_ref_id = curr_input_ref_id, prev_merge_id = curr_merge_id
   ENDIF
  FOOT REPORT
   stat = alterlist(pwrgrid_event_cd->list,count), stat = alterlist(pwrgrid_event_cd->
    section_ref_id_list,count1)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET pwrgrid_event_cd->status_data.status = "Z"
  SET pwrgrid_event_cd->status_data.subeventstatus[1].operationname = "select"
  SET pwrgrid_event_cd->status_data.subeventstatus[1].operationstatus = "F"
  SET pwrgrid_event_cd->status_data.subeventstatus[1].targetobjectname = "PERSON"
  SET pwrgrid_event_cd->status_data.subeventstatus[1].targetobjectvalue = "None Qualified"
 ELSE
  SET pwrgrid_event_cd->status_data.status = "S"
 ENDIF
 SELECT DISTINCT
  ds.definition, ds.description
  FROM dcp_section_ref ds
  WHERE expand(count1,1,size(pwrgrid_event_cd->section_ref_id_list,5),ds.dcp_section_ref_id,
   pwrgrid_event_cd->section_ref_id_list[count1].sec_ref_id)
  ORDER BY ds.dcp_section_ref_id
  HEAD REPORT
   col 35, "List of sections having event code of the grid equal to those of its rows", row + 3,
   col 40, "DEFINITION", col 85,
   "DESCRIPTION", row + 1, col 40,
   "-------------------------------", col 85, "-------------------------------",
   row + 2
  DETAIL
   def = ds.definition, desc = ds.description, col 40,
   def, col 85, desc,
   row + 1
  FOOT REPORT
   row + 3, col 35, "******** END OF REPORT *******"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET pwrgrid_event_cd->status_data.status = "Z"
  SET pwrgrid_event_cd->status_data.subeventstatus[1].operationname = "select"
  SET pwrgrid_event_cd->status_data.subeventstatus[1].operationstatus = "F"
  SET pwrgrid_event_cd->status_data.subeventstatus[1].targetobjectname = "PERSON"
  SET pwrgrid_event_cd->status_data.subeventstatus[1].targetobjectvalue = "None Qualified"
 ELSE
  SET pwrgrid_event_cd->status_data.status = "S"
 ENDIF
END GO
