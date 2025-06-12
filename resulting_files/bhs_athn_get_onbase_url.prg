CREATE PROGRAM bhs_athn_get_onbase_url
 DECLARE json = vc WITH protect, noconstant("")
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE parent_event_ids = vc WITH protect, noconstant("")
 DECLARE event_ids = vc WITH protect, noconstant("")
 SET req_evnts = trim(replace(replace( $2,"(","",0),")","",0),3)
 SET no_of_paires = cnvtint( $3)
 FREE RECORD ekg_urls
 RECORD ekg_urls(
   1 events[*]
     2 parent_event_id = f8
     2 event_id = f8
     2 contributor_system = vc
     2 url = vc
 )
 IF (textlen(req_evnts) > 3)
  FOR (i = 0 TO no_of_paires)
   SET evnt = piece(trim(req_evnts,3),",",i,"N/A")
   IF (evnt != " ")
    SET evnt_id = piece(trim(evnt,3),"|",1,"N/A")
    SET cont_sys = piece(trim(evnt,3),"|",2,"N/A")
    IF (cont_sys="ONBASE"
     AND evnt_id != "N/A")
     SET event_ids = build(event_ids,evnt_id,",")
    ELSEIF (evnt_id != "N/A")
     SET parent_event_ids = build(parent_event_ids,evnt_id,",")
    ENDIF
   ENDIF
  ENDFOR
 ENDIF
 IF (textlen(parent_event_ids) > 2)
  SET where_pevnt_params = build(" C.PARENT_EVENT_ID IN (",trim(substring(0,(textlen(parent_event_ids
      ) - 1),parent_event_ids),3),") ")
 ELSE
  SET where_pevnt_params = build(" C.PARENT_EVENT_ID != 0")
 ENDIF
 IF (textlen(event_ids) > 2)
  SET where_evnt_params = build(" C.EVENT_ID IN (",trim(substring(0,(textlen(event_ids) - 1),
     event_ids),3),") ")
 ELSE
  SET where_evnt_params = build(" C.EVENT_ID = 0")
 ENDIF
 IF (textlen(parent_event_ids) > 2)
  SELECT INTO "NL:"
   c.parent_event_id, c.event_id, c_contributor_system_disp = uar_get_code_display(c
    .contributor_system_cd),
   cbr.event_id, cbr_blob_handle = trim(replace(cbr.blob_handle," HNAM URL","",0))
   FROM clinical_event c,
    ce_blob_result cbr
   PLAN (c
    WHERE parser(where_pevnt_params)
     AND c.valid_from_dt_tm < sysdate
     AND c.valid_until_dt_tm > sysdate)
    JOIN (cbr
    WHERE cbr.event_id=c.event_id
     AND cbr.blob_handle != " "
     AND cbr.valid_from_dt_tm < sysdate
     AND cbr.valid_until_dt_tm > sysdate)
   HEAD REPORT
    cnt = cnt
   HEAD cbr.event_id
    cnt += 1, stat = alterlist(ekg_urls->events,cnt), ekg_urls->events[cnt].event_id = cbr.event_id,
    ekg_urls->events[cnt].url = cbr_blob_handle, ekg_urls->events[cnt].parent_event_id = c
    .parent_event_id, ekg_urls->events[cnt].contributor_system = c_contributor_system_disp
   WITH maxcol = 32000, time = 30
  ;end select
 ENDIF
 IF (textlen(event_ids) > 2)
  SELECT INTO "NL:"
   c.parent_event_id, c.event_id, c_contributor_system_disp = uar_get_code_display(c
    .contributor_system_cd),
   cbr.event_id, cbr_blob_handle = trim(replace(cbr.blob_handle," HNAM URL","",0))
   FROM clinical_event c,
    ce_blob_result cbr
   PLAN (c
    WHERE parser(where_evnt_params)
     AND c.valid_from_dt_tm < sysdate
     AND c.valid_until_dt_tm > sysdate)
    JOIN (cbr
    WHERE cbr.event_id=c.event_id
     AND cbr.blob_handle != " "
     AND cbr.valid_from_dt_tm < sysdate
     AND cbr.valid_until_dt_tm > sysdate)
   HEAD REPORT
    cnt = cnt
   HEAD cbr.event_id
    cnt += 1, stat = alterlist(ekg_urls->events,cnt), ekg_urls->events[cnt].event_id = cbr.event_id,
    ekg_urls->events[cnt].url = cbr_blob_handle, ekg_urls->events[cnt].parent_event_id = c
    .parent_event_id, ekg_urls->events[cnt].contributor_system = c_contributor_system_disp
   WITH maxcol = 32000, time = 30
  ;end select
 ENDIF
 SET json = cnvtrectojson(ekg_urls)
 SELECT INTO  $1
  json1 = replace(replace(json,'{"EKG_URLS":{"EVENTS":',"",0),"]}}","]",0)
  FROM dummyt d
  HEAD REPORT
   col 01, json1
  WITH maxcol = 32000, nocounter, format,
   separator = " ", time = 30
 ;end select
 FREE RECORD ekg_urls
END GO
