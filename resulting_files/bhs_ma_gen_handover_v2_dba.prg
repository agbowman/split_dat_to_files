CREATE PROGRAM bhs_ma_gen_handover_v2:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE pastmedicalhistory = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PASTMEDICALHX")),
 protect
 SET eid = request->visit[1].encntr_id
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 output_device = vc
    1 script_name = vc
    1 person_cnt = i4
    1 person[*]
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
  SET request->visit[1].encntr_id = 33799517.00
  SET request->visit_cnt = 1
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
  )
 ENDIF
 FREE RECORD drec
 RECORD drec(
   1 line_cnt = i4
   1 dislay_line = vc
   1 line_qual[*]
     2 disp_line = vc
 )
 FREE RECORD handover
 RECORD handover(
   1 severity = vc
   1 complanit = vc
   1 hxinllness = vc
   1 pastmedicalhistory = vc
   1 pending = vc
   1 todo = vc
   1 contingencies = vc
   1 topic1 = vc
   1 topic2 = vc
   1 topic3 = vc
   1 topic4 = vc
   1 topic5 = vc
   1 result1 = vc
   1 result2 = vc
   1 result3 = vc
   1 result4 = vc
   1 result5 = vc
   1 dcdate = vc
   1 stickynotes = vc
 )
 FREE RECORD dlrec
 RECORD dlrec(
   1 encntr_total = i4
   1 seq[*]
     2 encntr_id = f8
     2 person_id = f8
     2 total_sticky_notes = i4
     2 sticky_notes[*]
       3 notes = vc
       3 note_date = vc
       3 prsnl_name = vc
 )
 SET x = 1
 SET lidx = 0
 DECLARE tmp_display1 = vc
 DECLARE temp_disp1 = vc
 DECLARE rounds_note_cd = f8 WITH public, constant(uar_get_code_by("MEANING",14122,"ROUNDNOTE"))
 DECLARE sticky_note_cd = f8 WITH public, constant(uar_get_code_by("MEANING",14122,"POWERCHART"))
 SET rhead = "{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss Arial;}}"
 SET rh2r = "\plain \f0 \fs18 \cb2 \pard\sl0 "
 SET rh2b = "\plain \f0 \fs18 \b \cb2 \pard\sl0 "
 SET rh2bu = "\plain \f0 \fs18 \b \ul \cb2 \pard\sl0 "
 SET rh2u = "\plain \f0 \fs18 \u \cb2 \pard\sl0 "
 SET rh2i = "\plain \f0 \fs18 \i \cb2 \pard\sl0 "
 SET reol = "\par "
 SET rtab = "\tab "
 SET wr = " \plain \f0 \fs18 "
 SET wb = " \plain \f0 \fs18 \b \cb2 "
 SET wu = " \plain \f0 \fs18 \ul \cb "
 SET wi = " \plain \f0 \fs18 \i \cb2 "
 SET wbi = " \plain \f0 \fs18 \b \i \cb2 "
 SET wiu = " \plain \f0 \fs18 \i \ul \cb2 "
 SET wbiu = " \plain \f0 \fs18 \b \ul \i \cb2 "
 SET rtfeof = "}"
 SET complaint = uar_get_code_by("displaykey",72,"CHIEFCOMPLAINT")
 SET severity = uar_get_code_by("displaykey",72,"SEVERITYRATING")
 SET illness = uar_get_code_by("displaykey",72,"HISTORYOFPRESENTILLNESS")
 SET pending = uar_get_code_by("displaykey",72,"ITEMSPENDING")
 SET todo = uar_get_code_by("displaykey",72,"TODOITEMS")
 SET cont = uar_get_code_by("displaykey",72,"CONTINGENCYPLAN")
 SET topic1 = uar_get_code_by("displaykey",72,"TOPICFORFOLLOWUPI")
 SET topic2 = uar_get_code_by("displaykey",72,"TOPICFORFOLLOWUPII")
 SET topic3 = uar_get_code_by("displaykey",72,"TOPICFORFOLLOWUPIII")
 SET topic4 = uar_get_code_by("displaykey",72,"TOPICFORFOLLOWUPIV")
 SET topic5 = uar_get_code_by("displaykey",72,"TOPICFORFOLLOWUPV")
 SET result1 = uar_get_code_by("displaykey",72,"FOLLOWUPDETAILI")
 SET result2 = uar_get_code_by("displaykey",72,"FOLLOWUPDETAILII")
 SET result3 = uar_get_code_by("displaykey",72,"FOLLOWUPDETAILIII")
 SET result4 = uar_get_code_by("displaykey",72,"FOLLOWUPDETAILIV")
 SET result5 = uar_get_code_by("displaykey",72,"FOLLOWUPDETAILV")
 SET dcdate = uar_get_code_by("displaykey",72,"ANTICIPATEDDISCHARGEDATE")
 SET blob_size = 0
 SET blob_out_detail = fillstring(64000," ")
 SET blob_compressed_trimmed = fillstring(64000," ")
 SET blob_uncompressed = fillstring(64000," ")
 SET blob_rtf = fillstring(64000," ")
 SET blob_out_detail = fillstring(64000," ")
 SET blob_compressed_trimmed = fillstring(64000," ")
 SET blob_return_len = 0
 SET blob_return_len2 = 0
 DECLARE eventval = vc
 SELECT INTO "nl:"
  FROM clinical_event ce,
   ce_blob ceb
  PLAN (ce
   WHERE ce.encntr_id=eid
    AND ((ce.event_cd+ 0) IN (complaint, severity, illness, todo, pending,
   cont, dcdate, topic1, topic2, topic3,
   topic4, topic5, result1, result2, result3,
   result4, result5, pastmedicalhistory))
    AND ce.view_level=1
    AND ce.valid_until_dt_tm > sysdate)
   JOIN (ceb
   WHERE ceb.event_id=outerjoin(ce.event_id))
  ORDER BY ce.event_cd, ce.event_end_dt_tm DESC
  HEAD REPORT
   blob_size = 0, blob_out_detail = fillstring(64000," "), blob_compressed_trimmed = fillstring(64000,
    " "),
   blob_uncompressed = fillstring(64000," "), blob_rtf = fillstring(64000," "), blob_out_detail =
   fillstring(64000," "),
   blob_return_len = 0, blob_return_len2 = 0, eventval = " "
  HEAD ce.event_cd
   IF (ce.event_cd=complaint)
    handover->complanit = trim(ce.result_val)
   ELSEIF (ce.event_cd=pastmedicalhistory)
    handover->pastmedicalhistory = trim(ce.result_val)
   ELSEIF (ce.event_cd=severity)
    handover->severity = trim(ce.result_val)
   ELSEIF (ce.event_cd=illness)
    IF (trim(ce.result_val) > " ")
     eventval = trim(ce.result_val)
    ELSE
     blob_size = cnvtint(ceb.blob_length), blob_out_detail = fillstring(64000," "),
     blob_compressed_trimmed = fillstring(64000," "),
     blob_uncompressed = fillstring(64000," "), blob_rtf = fillstring(64000," "), blob_out_detail =
     fillstring(64000," "),
     blob_compressed_trimmed = ceb.blob_contents, blob_return_len = 0, blob_return_len2 = 0,
     CALL uar_ocf_uncompress(blob_compressed_trimmed,size(blob_compressed_trimmed),blob_uncompressed,
     size(blob_uncompressed),blob_return_len),
     CALL uar_rtf2(blob_uncompressed,blob_return_len,blob_rtf,size(blob_rtf),blob_return_len2,1),
     eventval = trim(blob_rtf,3)
    ENDIF
    handover->hxinllness = trim(eventval)
   ELSEIF (ce.event_cd=todo)
    handover->todo = trim(ce.result_val)
   ELSEIF (ce.event_cd=cont)
    handover->contingencies = trim(ce.result_val)
   ELSEIF (ce.event_cd=dcdate)
    handover->dcdate = trim(ce.result_val)
   ELSEIF (ce.event_cd=result1)
    handover->result1 = trim(ce.result_val)
   ELSEIF (ce.event_cd=result2)
    handover->result2 = trim(ce.result_val)
   ELSEIF (ce.event_cd=result3)
    handover->result3 = trim(ce.result_val)
   ELSEIF (ce.event_cd=result4)
    handover->result4 = trim(ce.result_val)
   ELSEIF (ce.event_cd=result5)
    handover->result5 = trim(ce.result_val)
   ELSEIF (ce.event_cd=topic1)
    handover->topic1 = trim(ce.result_val)
   ELSEIF (ce.event_cd=topic2)
    handover->topic2 = trim(ce.result_val)
   ELSEIF (ce.event_cd=topic3)
    handover->topic3 = trim(ce.result_val)
   ELSEIF (ce.event_cd=topic4)
    handover->topic4 = trim(ce.result_val)
   ELSEIF (ce.event_cd=topic5)
    handover->topic5 = trim(ce.result_val)
   ELSEIF (ce.event_cd=pending)
    handover->pending = trim(ce.result_val)
   ENDIF
  WITH nocounter
 ;end select
 DECLARE lastupdate = vc
 SELECT INTO "nl:"
  FROM clinical_event ce
  WHERE ce.encntr_id=eid
   AND ce.event_title_text="Handover/Transfer Form"
   AND ce.valid_until_dt_tm > sysdate
   AND ce.event_tag="DCP GENERIC CODE"
  ORDER BY ce.clinsig_updt_dt_tm
  HEAD ce.clinsig_updt_dt_tm
   lastupdate = format(ce.event_end_dt_tm,"mm/dd/yy hh:mm;;q")
  WITH nocounter
 ;end select
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = "HANDOVER"
 SET drec->line_qual[lidx].disp_line = concat(rhead,rh2bu,trim(temp_disp1),reol,reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("Last Charted: ",wr,lastupdate)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("CC: ",wr,handover->complanit)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("Past Medical Hx: ",wr,handover->pastmedicalhistory)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("Hx Present Illness: ",wr,handover->hxinllness)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("Pending Item: ",wr,handover->pending)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("To Do List: ",wr,handover->todo)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("Contingencies: ",wr,handover->contingencies)
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET temp_disp1 = ""
 IF ((handover->topic1 > "")
  AND (handover->result1 > ""))
  SET lidx = (lidx+ 1)
  SET stat = alterlist(drec->line_qual,lidx)
  SET temp_disp1 = concat("_",handover->topic1,": ",handover->result1,reol)
  SET drec->line_qual[lidx].disp_line = concat(wr,trim(temp_disp1))
 ENDIF
 SET temp_disp1 = ""
 IF ((handover->topic2 > "")
  AND (handover->result2 > ""))
  SET lidx = (lidx+ 1)
  SET stat = alterlist(drec->line_qual,lidx)
  SET temp_disp1 = concat("_",handover->topic2,": ",handover->result2,reol)
  SET drec->line_qual[lidx].disp_line = concat(wr,trim(temp_disp1))
 ENDIF
 SET temp_disp1 = ""
 IF ((handover->topic3 > "")
  AND (handover->result3 > ""))
  SET lidx = (lidx+ 1)
  SET stat = alterlist(drec->line_qual,lidx)
  SET temp_disp1 = concat("_",handover->topic3,": ",handover->result3,reol)
  SET drec->line_qual[lidx].disp_line = concat(wr,trim(temp_disp1))
 ENDIF
 SET temp_disp1 = ""
 IF ((handover->topic4 > "")
  AND (handover->result4 > ""))
  SET lidx = (lidx+ 1)
  SET stat = alterlist(drec->line_qual,lidx)
  SET temp_disp1 = concat("_",handover->topic4,": ",handover->result4,reol)
  SET drec->line_qual[lidx].disp_line = concat(wr,trim(temp_disp1))
 ENDIF
 SET temp_disp1 = ""
 IF ((handover->topic5 > "")
  AND (handover->result5 > ""))
  SET lidx = (lidx+ 1)
  SET stat = alterlist(drec->line_qual,lidx)
  SET temp_disp1 = concat("_",handover->topic5,": ",handover->result5,reol)
  SET drec->line_qual[lidx].disp_line = concat(wr,trim(temp_disp1))
 ENDIF
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("Anticipated D/C Date: ",wr,substring(7,2,handover->dcdate),"/",substring(9,
   2,handover->dcdate),
  "/",substring(3,4,handover->dcdate))
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 FOR (x = 1 TO lidx)
   SET reply->text = concat(reply->text,drec->line_qual[x].disp_line)
 ENDFOR
 SET reply->status_data.status = "S"
 SET reply->text = concat(reply->text,rtfeof)
 CALL echo(reply->text)
 FREE RECORD dlrec
 FREE RECORD request
END GO
