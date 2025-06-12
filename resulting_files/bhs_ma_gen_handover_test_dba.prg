CREATE PROGRAM bhs_ma_gen_handover_test:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SET eid = 36639122.00
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
 SET complaint = uar_get_code_by("displaykey",72,"CURRENTCHIEFCOMPLAINT")
 SET severity = uar_get_code_by("displaykey",72,"SEVERITYRATING")
 SET illness = uar_get_code_by("displaykey",72,"HISTORYOFPRESENTILLNESSTRANSFER")
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
 SELECT INTO "nl:"
  FROM clinical_event ce
  WHERE ce.encntr_id=eid
   AND ((ce.event_cd+ 0) IN (complaint, severity, illness, todo, pending,
  cont, dcdate, topic1, topic2, topic3,
  topic4, topic5, result1, result2, result3,
  result4, result5))
   AND ce.view_level=1
   AND ce.valid_until_dt_tm > sysdate
  ORDER BY ce.event_cd, ce.event_end_dt_tm DESC
  HEAD ce.event_cd
   IF (ce.event_cd=complaint)
    handover->complanit = trim(ce.result_val)
   ELSEIF (ce.event_cd=severity)
    handover->complanit = trim(ce.result_val)
   ELSEIF (ce.event_cd=illness)
    handover->hxinllness = trim(ce.result_val)
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
 SELECT INTO "nl:"
  encntr_id = eid
  FROM encounter e,
   sticky_note sn,
   prsnl p
  PLAN (e
   WHERE e.encntr_id=eid)
   JOIN (sn
   WHERE sn.parent_entity_name="PERSON"
    AND sn.parent_entity_id=e.person_id
    AND ((sn.sticky_note_type_cd=sticky_note_cd) OR (sn.sticky_note_type_cd=rounds_note_cd
    AND sn.public_ind=1))
    AND sn.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
   JOIN (p
   WHERE p.person_id=sn.updt_id)
  ORDER BY sn.parent_entity_id, encntr_id, sn.beg_effective_dt_tm DESC
  HEAD REPORT
   stat = alterlist(dlrec->seq,1), sn_cnt = 0
  DETAIL
   sn_cnt = (sn_cnt+ 1), stat = alterlist(dlrec->seq[1].sticky_notes,sn_cnt), dlrec->seq[1].
   sticky_notes[sn_cnt].notes = trim(sn.sticky_note_text),
   dlrec->seq[1].sticky_notes[sn_cnt].note_date = format(sn.beg_effective_dt_tm,"mm/dd/yyyy hh:mm;;d"
    ), dlrec->seq[1].sticky_notes[sn_cnt].prsnl_name = trim(p.name_full_formatted)
  FOOT  encntr_id
   dlrec->seq[1].total_sticky_notes = sn_cnt
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
 SET temp_disp1 = "MD HANDOVER"
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
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = "Topics and Info: "
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
 CALL echorecord(drec)
 GO TO exist_code
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = concat("Anticipated D/C Date: ",wr,substring(7,2,handover->dcdate),"/",substring(9,
   2,handover->dcdate),
  "/",substring(3,4,handover->dcdate))
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 SET lidx = (lidx+ 1)
 SET stat = alterlist(drec->line_qual,lidx)
 SET temp_disp1 = "Rounds/Sticky Notes:"
 SET drec->line_qual[lidx].disp_line = concat(rh2b,trim(temp_disp1),reol)
 IF ((dlrec->seq[1].total_sticky_notes > 0))
  FOR (ncnt = 1 TO dlrec->seq[1].total_sticky_notes)
    SET lidx = (lidx+ 1)
    SET stat = alterlist(drec->line_qual,lidx)
    SET temp_disp1 = concat(trim(dlrec->seq[1].sticky_notes[ncnt].note_date)," ",trim(dlrec->seq[1].
      sticky_notes[ncnt].prsnl_name),"- ",trim(dlrec->seq[1].sticky_notes[ncnt].notes))
    SET drec->line_qual[lidx].disp_line = concat(wr," ",trim(temp_disp1),reol)
  ENDFOR
 ELSE
  SET lidx = (lidx+ 1)
  SET stat = alterlist(drec->line_qual,lidx)
  SET temp_disp1 = "No notes found on patient."
  SET drec->line_qual[lidx].disp_line = concat(wr," ",trim(temp_disp1),reol)
 ENDIF
 FOR (x = 1 TO lidx)
   SET reply->text = concat(reply->text,drec->line_qual[x].disp_line)
 ENDFOR
 SET reply->status_data.status = "S"
 SET reply->text = concat(reply->text,rtfeof)
 CALL echo(reply->text)
 FREE RECORD dlrec
 FREE RECORD request
#exit_code
END GO
