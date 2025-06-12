CREATE PROGRAM ec_profiler_m98:dba
 DECLARE startpos = i4 WITH noconstant(0)
 DECLARE bfound = i2 WITH noconstant(0)
 DECLARE dfacilitycnt = i4 WITH noconstant(0)
 DECLARE dpositioncnt = i4 WITH noconstant(0)
 DECLARE ddetailcnt = i4 WITH noconstant(0)
 FREE RECORD template_hold
 RECORD template_hold(
   1 qual[*]
     2 template_name = vc
 )
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 SET last_mod = "001"
 SELECT INTO "nl:"
  FROM cr_report_template crt,
   long_text_reference ltr
  PLAN (crt
   WHERE crt.report_template_id > 0)
   JOIN (ltr
   WHERE ltr.parent_entity_id=crt.report_template_id)
  HEAD REPORT
   icnt = 0
  DETAIL
   startpos = findstring("flag-unflag-action-symbol",ltr.long_text)
   IF (startpos > 0)
    bfound = 1, icnt = (icnt+ 1), stat = alterlist(template_hold->qual,icnt),
    template_hold->qual[icnt].template_name = crt.template_name
   ENDIF
  WITH nocounter
 ;end select
 IF (bfound)
  SET dfacilitycnt = 0
  SET dfacilitycnt = (reply->facility_cnt+ 1)
  SET reply->facility_cnt = dfacilitycnt
  SET stat = alterlist(reply->facilities,dfacilitycnt)
  SET reply->facilities[dfacilitycnt].facility_cd = 0.0
  SET dpositioncnt = 0
  SET dpositioncnt = (dpositioncnt+ 1)
  SET reply->facilities[dfacilitycnt].position_cnt = dpositioncnt
  SET stat = alterlist(reply->facilities[dfacilitycnt].positions,dpositioncnt)
  SET reply->facilities[dfacilitycnt].positions[dpositioncnt].position_cd = 0.0
  SET reply->facilities[dfacilitycnt].positions[dpositioncnt].capability_in_use_ind = 1
  SET ddetailcnt = 0
  FOR (x = 1 TO size(template_hold,5))
    SET ddetailcnt = (reply->facilities[dfacilitycnt].positions[dpositioncnt].detail_cnt+ 1)
    SET reply->facilities[dfacilitycnt].positions[dpositioncnt].detail_cnt = ddetailcnt
    SET stat = alterlist(reply->facilities[dfacilitycnt].positions[dpositioncnt].details,ddetailcnt)
    SET reply->facilities[dfacilitycnt].positions[dpositioncnt].details[ddetailcnt].detail_name = ""
    SET reply->facilities[dfacilitycnt].positions[dpositioncnt].details[ddetailcnt].detail_value_txt
     = template_hold->qual[x].template_name
  ENDFOR
 ELSE
  SET reply->facility_cnt = 1
  SET stat = alterlist(reply->facilities,1)
  SET reply->facilities[1].position_cnt = 1
  SET stat = alterlist(reply->facilities[1].positions,1)
  SET reply->facilities[1].positions[1].capability_in_use_ind = 0
 ENDIF
END GO
