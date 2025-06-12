CREATE PROGRAM bhs_athn_unsigned_notes_new
 DECLARE pid = f8
 DECLARE eid = f8
 DECLARE prsnl_id = f8
 SET pid =  $2
 SET eid =  $3
 SET prsnl_id =  $4
 DECLARE doc = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",53,"DOC"))
 DECLARE mdoc = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",53,"MDOC"))
 DECLARE inprogress = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",8,"INPROGRESS"))
 DECLARE inerror = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE modified = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE action_type_sign = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",21,"SIGN"))
 DECLARE action_status_inerror = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",103,
   "INERROR"))
 DECLARE action_status_pending = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",103,
   "PENDING"))
 DECLARE action_status_requested = f8 WITH protect, constant(uar_get_code_by("DISPLAY_KEY",103,
   "REQUESTED"))
 IF (pid=0)
  SET where_params = build("E.ENCNTR_ID =",eid)
 ELSE
  SET where_params = build("E.PERSON_ID =",pid)
 ENDIF
 SELECT DISTINCT INTO  $1
  ce_person_id = trim(replace(cnvtstring(ce.person_id),".0*","",0),3), ce_encntr_id = trim(replace(
    cnvtstring(ce.encntr_id),".0*","",0),3), ce_parent_event_id = trim(replace(cnvtstring(ce
     .parent_event_id),".0*","",0),3),
  ce_event_id = trim(replace(cnvtstring(ce.event_id),".0*","",0),3), title = trim(replace(replace(
     replace(replace(replace(ce.event_title_text,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
     "&apos;",0),'"',"&quot;",0),3), event_disp = trim(replace(replace(replace(replace(replace(
        uar_get_code_display(ce.event_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
    '"',"&quot;",0),3),
  ce_event_cd = cnvtint(ce.event_cd), created_by = trim(replace(replace(replace(replace(replace(p
        .name_full_formatted,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
    0),3), result_status = trim(replace(replace(replace(replace(replace(uar_get_code_display(ce
         .result_status_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0
    ),3),
  saved_dt = datetimezoneformat(ce.performed_dt_tm,ce.performed_tz,"MM/dd/yyyy HH:mm:ss",
   curtimezonedef), saved_dt_tz = substring(21,3,datetimezoneformat(ce.performed_dt_tm,ce
    .performed_tz,"MM/dd/yyyy hh:mm:ss ZZZ",curtimezonedef)), event_end_dt = datetimezoneformat(ce
   .event_end_dt_tm,ce.event_end_tz,"MM/dd/yyyy HH:mm:ss",curtimezonedef),
  event_end_tz = substring(21,3,datetimezoneformat(ce.event_end_dt_tm,ce.event_end_tz,
    "MM/dd/yyyy hh:mm:ss ZZZ",curtimezonedef)), v_event_cd = cnvtint(v.event_cd), v_event_disp =
  uar_get_code_display(v.event_cd),
  v_event_set_cd = cnvtint(v.event_set_cd), v_event_set_disp = uar_get_code_display(v.event_set_cd),
  v.event_set_level,
  v_event_set_status_disp = uar_get_code_display(v.event_set_status_cd), ce_performed_prsnl_id =
  cnvtint(ce.performed_prsnl_id), p_position_cd = cnvtint(p.position_cd),
  p_position_disp = uar_get_code_display(p.position_cd), ce_event_class_disp =
  IF (ce.event_class_cd=224) "SingleDocument"
  ELSEIF (ce.event_class_cd=231) "MasterDocument"
  ENDIF
  , updt_dt_tm = datetimezoneformat(ce.updt_dt_tm,curtimezonesys,"MM/dd/yyyy HH:mm:ss",curtimezonedef
   )
  FROM encounter e,
   clinical_event ce,
   prsnl p,
   ce_event_prsnl cep,
   v500_event_set_explode v
  PLAN (e
   WHERE parser(where_params))
   JOIN (ce
   WHERE ce.encntr_id=e.encntr_id
    AND ce.event_end_dt_tm BETWEEN cnvtdatetime( $5) AND cnvtdatetime( $6)
    AND ce.event_class_cd IN (doc, mdoc)
    AND ce.verified_dt_tm = null
    AND ce.performed_dt_tm IS NOT null
    AND ce.person_id > 0
    AND ce.result_status_cd IN (inprogress, inerror, modified)
    AND ce.view_level=1
    AND ce.valid_until_dt_tm > sysdate
    AND ce.valid_from_dt_tm < sysdate)
   JOIN (p
   WHERE p.person_id=ce.performed_prsnl_id
    AND p.active_ind=1.00
    AND p.person_id=prsnl_id)
   JOIN (cep
   WHERE cep.event_id=ce.event_id
    AND cep.action_type_cd=action_type_sign
    AND cep.action_status_cd IN (action_status_pending, action_status_inerror,
   action_status_requested)
    AND cep.valid_until_dt_tm > sysdate
    AND cep.valid_from_dt_tm < sysdate)
   JOIN (v
   WHERE (v.event_cd= Outerjoin(ce.event_cd))
    AND (v.event_set_level= Outerjoin(0)) )
  ORDER BY ce.performed_dt_tm DESC
  HEAD REPORT
   html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
    '"',"UTF-8",'"'," ?>"), col 0, html_tag,
   row + 1, col + 1, "<ReplyMessage>",
   row + 1, enc_id1 = build("<EncntrId>",ce_encntr_id,"</EncntrId>"), col + 1,
   enc_id1, row + 1, p_id1 = build("<PersonId>",ce_person_id,"</PersonId>"),
   col + 1, p_id1, row + 1,
   prsl_id = build("<prsnl_id>",ce_performed_prsnl_id,"</prsnl_id>"), col + 1, prsl_id,
   row + 1, cted_by = build("<Created_By>",created_by,"</Created_By>"), col + 1,
   cted_by, row + 1, rcnt = 0
  DETAIL
   rcnt += 1, col 1, "<Events>",
   row + 1, enc_id = build("<EncounterId>",ce_encntr_id,"</EncounterId>"), col + 1,
   enc_id, row + 1, p_id = build("<PersonId>",ce_person_id,"</PersonId>"),
   col + 1, p_id, row + 1,
   e_par_id = build("<ParentEventId>",ce_parent_event_id,"</ParentEventId>"), col + 1, e_par_id,
   row + 1, e_id = build("<EventId>",ce_event_id,"</EventId>"), col + 1,
   e_id, row + 1, t_desc = build("<EventTitle>",title,"</EventTitle>"),
   col + 1, t_desc, row + 1,
   e_dis = build("<EventDisplay>",event_disp,"</EventDisplay>"), col + 1, e_dis,
   row + 1, e_code = build("<EventCode>",ce_event_cd,"</EventCode>"), col + 1,
   e_code, row + 1, v2 = build("<EventSetCode>",v_event_set_cd,"</EventSetCode>"),
   col + 1, v2, row + 1,
   e_res = build("<ResultStatus>",result_status,"</ResultStatus>"), col + 1, e_res,
   row + 1, e_save = build("<SavedDate>",saved_dt,"</SavedDate>"), col + 1,
   e_save, row + 1, e_save_tz = build("<SavedTimeZone>",saved_dt_tz,"</SavedTimeZone>"),
   col + 1, e_save_tz, row + 1,
   e_event = build("<EventEndDateTime>",event_end_dt,"</EventEndDateTime>"), col + 1, e_event,
   row + 1, e_event_tz = build("<EventEndTimeZone>",event_end_tz,"</EventEndTimeZone>"), col + 1,
   e_event_tz, row + 1, v1 = build("<EnteredBy>",created_by,"</EnteredBy>"),
   col + 1, v1, row + 1,
   v2 = build("<EnteredById>",ce_performed_prsnl_id,"</EnteredById>"), col + 1, v2,
   row + 1, v3 = build("<PositionId>",p_position_cd,"</PositionId>"), col + 1,
   v3, row + 1, v4 = build("<PositionValue>",p_position_disp,"</PositionValue>"),
   col + 1, v4, row + 1,
   v5 = build("<DocumentType>",ce_event_class_disp,"</DocumentType>"), col + 1, v5,
   row + 1, v6 = build("<UpdatedDateTime>",updt_dt_tm,"</UpdatedDateTime>"), col + 1,
   v6, row + 1, col 1,
   "</Events>", row + 1
  FOOT REPORT
   e_cnt = build("<RecordCount>",rcnt,"</RecordCount>"), col + 1, e_cnt,
   row + 1, col + 1, "</ReplyMessage>",
   row + 1
  WITH maxcol = 32000, maxrow = 0, nocounter,
   nullreport, formfeed = none, format = variable,
   time = 45
 ;end select
END GO
