CREATE PROGRAM dcp_rpt_driver:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 output_device = vc
    1 script_name = vc
    1 person_cnt = i4
    1 person[*]
      2 person_id = f8
    1 visit_cnt = i4
    1 visit[*]
      2 encntr_id = f8
    1 prsnl_cnt = i4
    1 prsnl[*]
      2 prsnl_id = f8
    1 nv_cnt = i4
    1 nv[*]
      2 pvc_name = vc
      2 pvc_value = vc
    1 batch_selection = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 text = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
    1 large_text_qual[*]
      2 text_segment = vc
  )
 ENDIF
 RECORD tz(
   1 m_id = c64
   1 m_offset = i4
   1 m_daylight = i4
   1 m_tz[64] = c64
 ) WITH protect
 RECORD 100190_request(
   1 encntrs[*]
     2 encntr_id = f8
     2 transaction_dt_tm = dq8
   1 facilities[*]
     2 loc_facility_cd = f8
 )
 RECORD 100190_reply(
   1 encntrs_qual_cnt = i4
   1 encntrs[*]
     2 encntr_id = f8
     2 time_zone_indx = i4
     2 time_zone = vc
     2 transaction_dt_tm = dq8
     2 check = i2
     2 status = i2
     2 loc_fac_cd = f8
   1 facilities_qual_cnt = i4
   1 facilities[*]
     2 loc_facility_cd = f8
     2 time_zone_indx = i4
     2 time_zone = vc
     2 status = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET trace hipaa off
 CALL echo("HELLO1")
 SET program_name = fillstring(30," ")
 DECLARE max_size = i4 WITH noconstant(0)
 DECLARE segmentcount = i4 WITH noconstant(0)
 DECLARE scriptexists = i2 WITH noconstant(0)
 DECLARE script_version = vc WITH protect, noconstant(" ")
 DECLARE newtzname = vc WITH noconstant(" "), protect
 DECLARE uar_datelookuptimezone(p1=vc(ref),p2=vc(ref)) = null WITH image_aix = "libdate.a(libdate.o)",
 uar = "DateLookupTimeZone", protect
 DECLARE uar_datesettimezone(p1=vc(ref)) = null WITH image_axp = "datertl", image_aix =
 "libdate.a(libdate.o)", uar = "DateSetTimeZone",
 protect
 DECLARE uar_dategettimezone(p1=vc(ref)) = null WITH image_axp = "datertl", image_aix =
 "libdate.a(libdate.o)", uar = "DateGetTimeZone",
 protect
 DECLARE uar_dategetsystemtimezone(p1=vc(ref)) = null WITH image_axp = "datertl", image_aix =
 "libdate.a(libdate.o)", uar = "DateGetSystemTimeZone",
 protect
 DECLARE lusertz = i4 WITH protect, noconstant(0)
 DECLARE settzaspatientbirthtz(null) = null
 DECLARE settzasperencountertz(null) = null
 CALL echo("HELLO2")
 FOR (y = 1 TO request->nv_cnt)
  CALL echo(request->nv[y].pvc_name)
  CALL echo(request->nv[y].pvc_value)
 ENDFOR
 IF (trim(request->script_name) > " ")
  SET program_name = cnvtupper(trim(request->script_name))
  IF (substring(1,6,cnvtupper(request->script_name))="##ST##")
   SET program_name = "CV_GET_CLIN_NOTE_DOC"
  ENDIF
  SET scriptexists = checkprg(program_name)
  CALL echo(build("scriptexists = ",scriptexists))
  IF (scriptexists=0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "EXECUTE"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "Script"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build("program(",program_name,
    ") was not found in the object library")
   GO TO exit_program
  ENDIF
  SUBROUTINE settzaspatientbirthtz(null)
    SELECT INTO "nl:"
     FROM person p
     PLAN (p
      WHERE (p.person_id=request->person[1].person_id))
     DETAIL
      newtzname = concat(trim(datetimezonebyindex(p.birth_tz)),char(0))
     WITH nocounter
    ;end select
    CALL uar_datelookuptimezone(newtzname,tz)
    CALL uar_datesettimezone(tz)
  END ;Subroutine
  SUBROUTINE settzasperencountertz(null)
    SET stat = alterlist(100190_request->encntrs,1)
    SET 100190_request->encntrs[1].encntr_id = request->visit[1].encntr_id
    EXECUTE pm_get_encntr_loc_tz  WITH replace("REQUEST",100190_request), replace("REPLY",
     100190_reply)
    IF ((100190_reply->encntrs_qual_cnt > 0))
     IF ((100190_reply->encntrs[1].status=1))
      SET newtzname = concat(trim(100190_reply->encntrs[1].time_zone),char(0))
      CALL uar_datelookuptimezone(newtzname,tz)
      CALL uar_datesettimezone(tz)
     ELSEIF ((100190_reply->encntrs[1].status=2))
      CALL settzaspatientbirthtz(null)
     ENDIF
    ENDIF
  END ;Subroutine
  IF ((reqinfo->updt_app=3202004))
   IF ((request->visit_cnt > 0))
    CALL settzasperencountertz(null)
   ELSEIF ((request->person_cnt > 0))
    CALL settzaspatientbirthtz(null)
   ENDIF
  ENDIF
  EXECUTE value(program_name)
  CALL echo(build("text:",reply->text))
  SET max_size = 64000
  SET segmentcount = 1
  SET y = 0
  CALL echo(build("Size:",size(reply->text)))
  IF (size(reply->text,1) >= max_size)
   SET segmentcount = (size(reply->text,1)/ max_size)
   IF (mod(size(reply->text,1),max_size) != 0)
    SET segmentcount = (segmentcount+ 1)
   ENDIF
   SET stat = alterlist(reply->large_text_qual,segmentcount)
   FOR (y = 1 TO segmentcount)
    SET reply->large_text_qual[y].text_segment = substring(1,max_size,reply->text)
    SET reply->text = substring((max_size+ 1),(size(reply->text,1) - max_size),reply->text)
   ENDFOR
   SET reply->text = reply->large_text_qual[1].text_segment
  ENDIF
  GO TO exit_program
 ENDIF
#exit_program
 SET modify = hipaa
 IF ((request->script_name="DCP_RPT_PVPATLIST"))
  IF ((request->nv[1].pvc_name="LISTNAME"))
   DECLARE list_counter = i4 WITH noconstant(0)
   FOR (list_counter = 1 TO request->nv_cnt)
     EXECUTE cclaudit 0, "Run Report", "PowerChart",
     "System Object", "Report", "Patient List",
     "Report", 0.0, request->nv[list_counter].pvc_value
   ENDFOR
  ELSE
   EXECUTE cclaudit 0, "Run Report", "PowerChart",
   "System Object", "Report", "Report",
   "Report", 0.0, request->script_name
  ENDIF
 ELSE
  DECLARE slifecycle = vc WITH noconstant("")
  DECLARE seventname = vc WITH noconstant("")
  DECLARE seventtype = vc WITH noconstant("")
  IF ((request->output_device=""))
   SET slifecycle = "Access/Use"
   SET seventname = "Genview"
   SET seventtype = "View"
  ELSE
   SET slifecycle = "Report"
   SET seventname = "Run Report"
   SET seventtype = "PowerChart"
  ENDIF
  IF ((request->person_cnt > 0))
   DECLARE person_counter = i4 WITH noconstant(0)
   FOR (person_counter = 1 TO request->person_cnt)
    EXECUTE cclaudit 1, seventname, seventtype,
    "Person", "Patient", "Patient",
    slifecycle, request->person[person_counter].person_id, ""
    EXECUTE cclaudit 3, seventname, seventtype,
    "System Object", "Report", "Report",
    slifecycle, 0.0, request->script_name
   ENDFOR
  ELSEIF ((request->visit_cnt > 0))
   DECLARE visit_counter = i4 WITH noconstant(0)
   FOR (visit_counter = 1 TO request->visit_cnt)
    EXECUTE cclaudit 1, seventname, seventtype,
    "Encounter", "Patient", "Encounter",
    slifecycle, request->visit[visit_counter].encntr_id, ""
    EXECUTE cclaudit 3, seventname, seventtype,
    "System Object", "Report", "Report",
    slifecycle, 0.0, request->script_name
   ENDFOR
  ELSE
   EXECUTE cclaudit 0, seventname, seventtype,
   "System Object", "Report", "Report",
   slifecycle, 0.0, request->script_name
  ENDIF
 ENDIF
 IF ((reply->status_data.status != "F")
  AND (reply->status_data.status != "Z"))
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "MOD 006 11/10/17 DK031431"
END GO
