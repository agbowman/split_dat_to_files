CREATE PROGRAM doc_id_mult_freetext_in_para
 PROMPT
  "Date on which you installed the earliest of 2012.01.03, 2012.01.04 or 2012.01.05 (DD-MMM-YYYY, default: 07-MAR-2012): "
   = "07-MAR-2012"
  WITH begindate
 DECLARE begindatetime = dq8 WITH constant(cnvtdatetime( $BEGINDATE))
 EXECUTE cclseclogin
 SET message = nowindow
 SET doc_code = uar_get_code_by("MEANING",15749,"DOC")
 DECLARE freetext_id = f8 WITH noconstant(0.0)
 SELECT INTO "nl:"
  ft_id = scr_term_id
  FROM scr_term_hier
  WHERE scr_term_hier_id IN (
  (SELECT
   scr_term_hier_id
   FROM scr_term_hier
   WHERE scr_sentence_id IN (
   (SELECT
    scr_sentence_id
    FROM scr_sentence
    WHERE scr_pattern_id IN (
    (SELECT
     scr_pattern_id
     FROM scr_pattern
     WHERE cki_identifier="SENT FREE TEXT SENTENCE"))))))
  DETAIL
   freetext_id = ft_id
  WITH nocounter
 ;end select
 IF (freetext_id=0.0)
  CALL echo(
   "*** The Free Text sentence was not found in this system. There is nothing to report. ***")
  GO TO exit_prog
 ENDIF
 CALL echo("")
 CALL echo("* Searching for affected notes...")
 CALL echo("")
 SELECT DISTINCT INTO doc_id_mult_freetext_in_para
  note_title = s.title, event_id = s.event_id, story_id = s.scd_story_id,
  author_id = s.author_id, author_name = p.name_full_formatted, patient_id = s.person_id,
  patient_name = p1.name_full_formatted, note_status = s.story_completion_status_cd, note_status_cd
   = uar_get_code_description(s.story_completion_status_cd),
  performed_dt_tm = ce.performed_dt_tm, service_dt_tm = ce.event_end_dt_tm
  FROM scd_story s,
   person p,
   person p1,
   clinical_event ce
  PLAN (s
   WHERE s.story_type_cd=doc_code
    AND s.scd_story_id IN (
   (SELECT DISTINCT
    s1.scd_story_id
    FROM scd_sentence s1
    WHERE s1.scd_paragraph_id IN (
    (SELECT
     s2.scd_paragraph_id
     FROM scd_sentence s2
     WHERE s2.scd_sentence_id IN (
     (SELECT DISTINCT
      scd_sentence_id
      FROM scd_term
      WHERE active_ind > 0
       AND scr_term_id=freetext_id
       AND scd_story_id IN (
      (SELECT
       scd_story_id
       FROM scd_story
       WHERE updt_dt_tm >= cnvtdatetime(begindatetime)))))
     GROUP BY s2.scd_paragraph_id
     HAVING count(s2.scd_sentence_id) > 1)))))
   JOIN (p
   WHERE p.person_id=s.author_id)
   JOIN (p1
   WHERE p1.person_id=s.person_id)
   JOIN (ce
   WHERE ce.event_id=s.event_id)
  WITH nocounter, pcformat('"',",",1), format = stream
 ;end select
 CALL echo("")
 CALL echo("*** Search complete. Results output to $CCLUSERDIR/doc_id_mult_freetext_in_para.dat")
 CALL echo("")
#exit_prog
END GO
