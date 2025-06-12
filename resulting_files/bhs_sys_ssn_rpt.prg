CREATE PROGRAM bhs_sys_ssn_rpt
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 FREE RECORD temp
 RECORD temp(
   1 cnt = i2
   1 qual[*]
     2 person_id = f8
     2 name = vc
     2 position = vc
     2 updatedt = vc
     2 updtid = f8
     2 updtname = vc
     2 dataparam = cv
     2 ssn_ind = i2
 )
 SELECT INTO "nl:"
  FROM application_ini a
  PLAN (a
   WHERE a.application_number=968600
    AND a.section="CPS_FLEXPERSONINFO")
  HEAD REPORT
   skip = 0
  DETAIL
   IF (findstring("SCH_FLEXSSN=-1",a.parameter_data,1,0) > 0)
    skip = 1
   ELSE
    temp->cnt = (temp->cnt+ 1), stat = alterlist(temp->qual,temp->cnt), temp->qual[temp->cnt].
    person_id = a.person_id,
    temp->qual[temp->cnt].updatedt = format(a.updt_dt_tm,"mm/dd/yyyy hh:mm;;d"), temp->qual[temp->cnt
    ].updtid = a.updt_id, temp->qual[temp->cnt].dataparam = trim(a.parameter_data,3),
    temp->qual[temp->cnt].ssn_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM prsnl pr,
   (dummyt d  WITH seq = value(temp->cnt))
  PLAN (d)
   JOIN (pr
   WHERE (((pr.person_id=temp->qual[d.seq].person_id)) OR ((pr.person_id=temp->qual[d.seq].updtid)))
   )
  DETAIL
   IF ((pr.person_id=temp->qual[d.seq].person_id))
    temp->qual[d.seq].name = pr.name_full_formatted, temp->qual[d.seq].position =
    uar_get_code_display(pr.position_cd)
   ENDIF
   IF ((pr.person_id=temp->qual[d.seq].updtid))
    temp->qual[d.seq].updtname = pr.name_full_formatted
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(temp)
 DECLARE position = vc
 DECLARE update_date = vc
 SELECT INTO  $1
  user_name = temp->qual[d.seq].name, position = temp->qual[d.seq].position, updated_by = temp->qual[
  d.seq].updtname,
  update_date = temp->qual[d.seq].updatedt
  FROM (dummyt d  WITH seq = value(temp->cnt))
  WHERE d.seq > 0
  WITH format, separator = " "
 ;end select
END GO
