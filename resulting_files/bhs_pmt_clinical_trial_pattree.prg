CREATE PROGRAM bhs_pmt_clinical_trial_pattree
 PROMPT
  "Display value or initial state command ('INIT' or '%LIST%')" = "INIT",
  "Search item locataion code" = 1.0,
  "Item terminal selection state (1 or 0)" = 1,
  "Item expanded icon number" = 0,
  "Item collapsed icon number" = 0,
  "Item expandable (1=expandable)" = 1,
  "Location meaning value" = "",
  "Location path string" = ""
  WITH item_display, item_keyvalue, item_terminal_flag,
  item_icon_opened, item_icon_closed, item_expand_flag,
  item_meaning, item_path
 EXECUTE ccl_prompt_api_dataset "dataset", "parameter"
 RECORD patval(
   1 qual[*]
     2 value = vc
 )
 DECLARE cmrn = f8 WITH constant(uar_get_code_by("MEANING",4,"CMRN")), protect
 IF (( $ITEM_DISPLAY="INIT")
  AND cnvtint( $ITEM_KEYVALUE)=1)
  SELECT INTO "NL:"
   item_display = substring(0,80,p.name_full_formatted), item_keyvalue = p.person_id, item_terminal
    = 1,
   item_icon_opened = 6, item_icon_closed = 6, item_expand_flag = 1,
   item_meaning =  $ITEM_PATH, item_path =  $ITEM_PATH
   FROM bhs_clinical_trial_person b,
    person p
   PLAN (b
    WHERE (b.irb_number= $ITEM_PATH)
     AND b.active_ind=1)
    JOIN (p
    WHERE p.person_id=b.person_id)
   ORDER BY p.name_full_formatted
   HEAD REPORT
    stat = makedataset(1000)
   HEAD item_keyvalue
    stat = writerecord(0)
   FOOT REPORT
    stat = closedataset(0)
   WITH reporthelp, check
  ;end select
 ELSE
  SET personid = 0.0
  SET listcnt = 0
  SELECT INTO "NL:"
   p.name_full_formatted
   FROM bhs_clinical_trial_person b,
    person p,
    person_alias pa
   PLAN (b
    WHERE (b.irb_number= $ITEM_PATH)
     AND b.person_id=cnvtreal( $ITEM_KEYVALUE)
     AND b.active_ind=1)
    JOIN (p
    WHERE p.person_id=b.person_id)
    JOIN (pa
    WHERE pa.person_id=p.person_id
     AND pa.person_alias_type_cd=cmrn
     AND pa.active_ind=1)
   ORDER BY p.name_full_formatted
   DETAIL
    personid = p.person_id, listcnt = (listcnt+ 1), stat = alterlist(patval->qual,listcnt),
    patval->qual[listcnt].value = concat("Birth date = ",format(cnvtdatetime(p.birth_dt_tm),
      "MM/DD/YYYY;;q")), listcnt = (listcnt+ 1), stat = alterlist(patval->qual,listcnt),
    patval->qual[listcnt].value = concat("Community Medical Record # = ",trim(pa.alias,3)),
    temporderalertdays =
    IF (datetimecmp(datetimeadd(cnvtdatetime(b.alert_notify_start_dt_tm),b.alert_notify_length),
     cnvtdatetime(curdate,235959)) > 0) datetimecmp(datetimeadd(cnvtdatetime(b
        .alert_notify_start_dt_tm),b.alert_notify_length),cnvtdatetime(curdate,235959))
    ELSE 0
    ENDIF
    , tempinboxalertdays =
    IF (datetimecmp(datetimeadd(cnvtdatetime(b.email_notify_start_dt_tm),b.email_notify_length),
     cnvtdatetime(curdate,235959)) > 0) datetimecmp(datetimeadd(cnvtdatetime(b
        .email_notify_start_dt_tm),b.email_notify_length),cnvtdatetime(curdate,235959))
    ELSE 0
    ENDIF
    ,
    listcnt = (listcnt+ 1), stat = alterlist(patval->qual,listcnt), patval->qual[listcnt].value =
    concat("# of days left on order alert = ",cnvtstring(temporderalertdays)),
    listcnt = (listcnt+ 1), stat = alterlist(patval->qual,listcnt), patval->qual[listcnt].value =
    concat("# of days left on email alert = ",cnvtstring(tempinboxalertdays))
   WITH nocounter
  ;end select
  CALL echorecord(patval)
  SELECT INTO "NL:"
   item_display = substring(0,80,patval->qual[d.seq].value), item_keyvalue = personid, item_terminal
    = 1,
   item_icon_opened = 3, item_icon_closed = 9, item_expand_flag = 0,
   item_meaning =  $ITEM_PATH, item_path =  $ITEM_PATH
   FROM (dummyt d  WITH seq = size(patval->qual,5))
   PLAN (d)
   HEAD REPORT
    stat = makedataset(1000)
   DETAIL
    stat = writerecord(0)
   FOOT REPORT
    stat = closedataset(0)
   WITH reporthelp, check
  ;end select
 ENDIF
END GO
