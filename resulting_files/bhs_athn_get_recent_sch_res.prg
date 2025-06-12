CREATE PROGRAM bhs_athn_get_recent_sch_res
 RECORD out_rec(
   1 default_program = vc
   1 recents[*]
     2 resource_value = vc
     2 resource_disp = vc
     2 resource_position = vc
 )
 DECLARE t_line = vc
 DECLARE pos = i4
 DECLARE cnt = i4
 SELECT INTO "nl:"
  FROM prsnl pr,
   view_prefs ap,
   name_value_prefs nvp,
   name_value_prefs nvp1
  PLAN (pr
   WHERE (pr.person_id= $2))
   JOIN (ap
   WHERE ap.position_cd=pr.position_cd
    AND ap.frame_type="ORG"
    AND ap.application_number=600005
    AND ap.active_ind=1)
   JOIN (nvp
   WHERE nvp.parent_entity_id=ap.view_prefs_id
    AND nvp.pvc_name="DISPLAY_SEQ"
    AND nvp.pvc_value="1"
    AND nvp.active_ind=1)
   JOIN (nvp1
   WHERE nvp1.parent_entity_id=nvp.parent_entity_id
    AND nvp1.pvc_name="VIEW_CAPTION"
    AND nvp.active_ind=1)
  HEAD REPORT
   out_rec->default_program = nvp1.pvc_value
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "nl:"
  FROM application_ini ai
  PLAN (ai
   WHERE (ai.person_id= $2)
    AND ai.section="CPSSCHEDRECENTRES")
  HEAD REPORT
   t_line = ai.parameter_data
  WITH nocounter, time = 30
 ;end select
 SET stat = alterlist(out_rec->recents,10)
 SET pos = findstring("RES_CD0",t_line)
 SET out_rec->recents[1].resource_value = cnvtstring(substring((pos+ 8),15,t_line))
 SET pos = findstring("RES_ORDER0",t_line)
 SET out_rec->recents[1].resource_position = cnvtstring(substring((pos+ 11),1,t_line))
 SET pos = findstring("RES_CD1",t_line)
 SET out_rec->recents[2].resource_value = cnvtstring(substring((pos+ 8),15,t_line))
 SET pos = findstring("RES_ORDER1",t_line)
 SET out_rec->recents[2].resource_position = cnvtstring(substring((pos+ 11),1,t_line))
 SET pos = findstring("RES_CD2",t_line)
 SET out_rec->recents[3].resource_value = cnvtstring(substring((pos+ 8),15,t_line))
 SET pos = findstring("RES_ORDER2",t_line)
 SET out_rec->recents[3].resource_position = cnvtstring(substring((pos+ 11),1,t_line))
 SET pos = findstring("RES_CD3",t_line)
 SET out_rec->recents[4].resource_value = cnvtstring(substring((pos+ 8),15,t_line))
 SET pos = findstring("RES_ORDER3",t_line)
 SET out_rec->recents[4].resource_position = cnvtstring(substring((pos+ 11),1,t_line))
 SET pos = findstring("RES_CD4",t_line)
 SET out_rec->recents[5].resource_value = cnvtstring(substring((pos+ 8),15,t_line))
 SET pos = findstring("RES_ORDER4",t_line)
 SET out_rec->recents[5].resource_position = cnvtstring(substring((pos+ 11),1,t_line))
 SET pos = findstring("RES_CD5",t_line)
 SET out_rec->recents[6].resource_value = cnvtstring(substring((pos+ 8),15,t_line))
 SET pos = findstring("RES_ORDER5",t_line)
 SET out_rec->recents[6].resource_position = cnvtstring(substring((pos+ 11),1,t_line))
 SET pos = findstring("RES_CD6",t_line)
 SET out_rec->recents[7].resource_value = cnvtstring(substring((pos+ 8),15,t_line))
 SET pos = findstring("RES_ORDER6",t_line)
 SET out_rec->recents[7].resource_position = cnvtstring(substring((pos+ 11),1,t_line))
 SET pos = findstring("RES_CD7",t_line)
 SET out_rec->recents[8].resource_value = cnvtstring(substring((pos+ 8),15,t_line))
 SET pos = findstring("RES_ORDER7",t_line)
 SET out_rec->recents[8].resource_position = cnvtstring(substring((pos+ 11),1,t_line))
 SET pos = findstring("RES_CD8",t_line)
 SET out_rec->recents[9].resource_value = cnvtstring(substring((pos+ 8),15,t_line))
 SET pos = findstring("RES_ORDER8",t_line)
 SET out_rec->recents[9].resource_position = cnvtstring(substring((pos+ 11),1,t_line))
 SET pos = findstring("RES_CD9",t_line)
 SET out_rec->recents[10].resource_value = cnvtstring(substring((pos+ 8),15,t_line))
 SET pos = findstring("RES_ORDER9",t_line)
 SET out_rec->recents[10].resource_position = cnvtstring(substring((pos+ 11),1,t_line))
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(out_rec->recents,5)),
   code_value cv
  PLAN (d)
   JOIN (cv
   WHERE cv.code_value=cnvtreal(out_rec->recents[d.seq].resource_value))
  HEAD cv.code_value
   out_rec->recents[d.seq].resource_disp = cv.display
  WITH nocounter
 ;end select
 FOR (i = 1 TO size(out_rec->recents,5))
   IF ((out_rec->recents[i].resource_disp > " "))
    SET cnt = (cnt+ 1)
   ENDIF
 ENDFOR
 SET stat = alterlist(out_rec->recents,cnt)
 CALL echojson(out_rec, $1)
END GO
