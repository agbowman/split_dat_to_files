CREATE PROGRAM dcp_upd_dcpgeneric:dba
 RECORD temp(
   1 qual[*]
     2 clinical_event_id = f8
     2 grid_event_cd = f8
     2 name_full_formatted = vc
     2 event_end_date_time = vc
     2 event_title_text = vc
     2 grid_event_disp = vc
 )
 SET count1 = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 0.0
 SET code_value = 0.0
 SET grp_cd = 0.0
 SET dcpgeneric_cd = 0.0
 SET code_set = 53
 SET cdf_meaning = "GRP"
 EXECUTE cpm_get_cd_for_cdf
 SET grp_cd = code_value
 SET code_set = 72
 SET cdf_meaning = "DCPGENERIC"
 EXECUTE cpm_get_cd_for_cdf
 SET dcpgeneric_cd = code_value
 SELECT INTO "nl:"
  c.clinical_event_id, n.pvc_value
  FROM clinical_event c,
   dcp_input_ref d,
   name_value_prefs n,
   person p,
   code_value cv
  PLAN (c
   WHERE c.event_cd=dcpgeneric_cd
    AND c.event_class_cd=grp_cd)
   JOIN (d
   WHERE trim(cnvtstring(d.dcp_input_ref_id,20,0),3)=c.collating_seq)
   JOIN (n
   WHERE n.parent_entity_id=d.dcp_input_ref_id
    AND n.parent_entity_name="DCP_INPUT_REF"
    AND n.pvc_name="grid_event_cd")
   JOIN (p
   WHERE p.person_id=c.person_id)
   JOIN (cv
   WHERE cv.code_value=cnvtreal(n.pvc_value))
  HEAD REPORT
   count1 = 0
  DETAIL
   IF (cnvtreal(n.pvc_value) != dcpgeneric_cd)
    count1 = (count1+ 1), stat = alterlist(temp->qual,count1), temp->qual[count1].clinical_event_id
     = c.clinical_event_id,
    temp->qual[count1].grid_event_cd = cnvtreal(n.pvc_value), temp->qual[count1].name_full_formatted
     = trim(p.name_full_formatted), temp->qual[count1].event_end_date_time = format(c.event_end_dt_tm,
     "mm/dd/yy hh:mm"),
    temp->qual[count1].event_title_text = trim(c.event_title_text), temp->qual[count1].
    grid_event_disp = cv.display
   ENDIF
  WITH nocounter, check
 ;end select
 FOR (x = 1 TO count1)
   UPDATE  FROM clinical_event c
    SET c.event_cd = temp->qual[x].grid_event_cd
    WHERE (c.clinical_event_id=temp->qual[x].clinical_event_id)
    WITH nocounter
   ;end update
 ENDFOR
 SELECT
  d.seq
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD REPORT
   start_cnt = 1
  DETAIL
   IF (count1=0)
    "No rows found to update."
   ENDIF
   FOR (x = start_cnt TO count1)
     "CLINICAL_EVENT_ID: ", temp->qual[x].clinical_event_id";L", row + 1,
     "   The clinical event row with event_title_text = ", temp->qual[x].event_title_text, row + 1,
     "  and event_end_dt_tm = ", temp->qual[x].event_end_date_time, " for patient ",
     temp->qual[x].name_full_formatted, row + 1, "  was updated from ",
     dcpgeneric_cd";L", " to ", temp->qual[x].grid_event_cd";L",
     " ", temp->qual[x].grid_event_disp, row + 2
   ENDFOR
  FOOT PAGE
   start_cnt = (x+ 1)
 ;end select
END GO
