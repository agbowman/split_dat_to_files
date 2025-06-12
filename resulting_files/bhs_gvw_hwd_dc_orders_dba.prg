CREATE PROGRAM bhs_gvw_hwd_dc_orders:dba
 DECLARE ms_ord = vc WITH protect, noconstant("")
 DECLARE ml_maxexist = i4 WITH protect, noconstant(0)
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data[1]
      2 status = c4
    1 text = gvc
  )
 ENDIF
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 output_device = vc
    1 script_name = vc
    1 person_cnt = i4
    1 person[1]
      2 person_id = f8
    1 visit_cnt = i4
    1 visit[1]
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
 FREE RECORD rrec
 RECORD rrec(
   1 item[*]
     2 type = vc
     2 label = vc
     2 current_order[*]
       3 display = vc
       3 pt_friendly_display = vc
     2 discharge_key = vc
     2 discharge_order = vc
     2 dta = vc
   1 discharge_request = vc
   1 pcp = vc
   1 attending_id = f8
   1 attending_name = vc
   1 dc_synonym_id = f8
   1 makeorder[*]
     2 synonym_id = f8
     2 mnemonic = vc
     2 exist[*]
       3 clinical_display_line = vc
       3 order_id = f8
       3 oe_format_id = f8
 )
 EXECUTE uhs_mpg_get_dc_orders "NL:", value(request->person[1].person_id), value(request->visit[1].
  encntr_id),
 ""
 CALL echorecord(rrec)
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = size(rrec->item,5))
  PLAN (d)
  ORDER BY d.seq
  HEAD REPORT
   reply->text = build(reply->text,"{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Tahoma;}}\fs18\par\b  ",
    "Discharge Orders"," \b0\par ")
  HEAD d.seq
   ms_ord = ""
   IF (textlen(trim(rrec->item[d.seq].discharge_order)) > 0)
    ms_ord = trim(rrec->item[d.seq].discharge_order)
    IF (findstring("||",ms_ord) > 0)
     ms_ord = trim(substring((findstring("||",ms_ord)+ 2),textlen(ms_ord),ms_ord),3)
    ENDIF
    reply->text = build(reply->text,trim(rrec->item[d.seq].label),": ",trim(ms_ord)," \par ")
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = size(rrec->makeorder,5))
  PLAN (d
   WHERE (rrec->makeorder[d.seq].synonym_id != rrec->dc_synonym_id))
  ORDER BY d.seq
  HEAD d.seq
   ml_maxexist = size(rrec->makeorder[d.seq].exist,5)
   IF (ml_maxexist > 0)
    reply->text = build(reply->text,"\b ",trim(rrec->makeorder[d.seq].mnemonic)," \b0\par ")
    FOR (ml_idx = 1 TO ml_maxexist)
      reply->text = build(reply->text,trim(rrec->makeorder[d.seq].exist[ml_idx].clinical_display_line
        )," \par")
    ENDFOR
   ENDIF
  WITH nocounter
 ;end select
 IF (size(trim(reply->text,3)) > 0)
  SET reply->text = build2(reply->text,"}")
 ENDIF
 CALL echorecord(reply)
END GO
