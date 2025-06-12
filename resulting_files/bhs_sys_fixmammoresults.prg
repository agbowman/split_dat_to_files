CREATE PROGRAM bhs_sys_fixmammoresults
 FREE DEFINE rtl
 DEFINE rtl "bhscust:bhsmammolist.dat"
 FREE RECORD temp
 RECORD temp(
   1 qual[*]
     2 cid = f8
 )
 SELECT INTO "nl:"
  id = cnvtint(r.line)
  FROM rtlt r
  WHERE r.line > " "
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].cid = id
  WITH nocounter
 ;end select
 FOR (x = 1 TO size(temp->qual,5))
  UPDATE  FROM clinical_event ce
   SET ce.event_cd = 698057, ce.event_tag = "MM Mammogram Bilat", ce.event_title_text =
    "MM Mammogram Bilat"
   WHERE (ce.clinical_event_id=temp->qual[x].cid)
    AND ce.event_cd=783525
    AND ce.event_title_text="MAMMOGRAM BILATERAL"
  ;end update
  COMMIT
 ENDFOR
END GO
