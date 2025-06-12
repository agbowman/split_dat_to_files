CREATE PROGRAM agc_test_scd:dba
 SELECT
  scdt.*, scdtd.*, scrt.*,
  scrtt.*
  FROM clinical_event ce,
   scd_story scds,
   scd_term scdt,
   scd_term_data scdtd,
   scr_term scrt,
   scr_term_text scrtt,
   scd_sentence scdsen
  PLAN (ce
   WHERE ce.parent_event_id=992779)
   JOIN (scds
   WHERE scds.event_id=ce.parent_event_id)
   JOIN (scdt
   WHERE outerjoin(scds.scd_story_id)=scdt.scd_story_id)
   JOIN (scdtd
   WHERE outerjoin(scdt.scd_term_data_id)=scdtd.scd_term_data_id)
   JOIN (scrt
   WHERE outerjoin(scdt.scr_term_id)=scrt.scr_term_id)
   JOIN (scrtt
   WHERE scrtt.scr_term_id=scrt.scr_term_id)
   JOIN (scdsen
   WHERE outerjoin(scdt.scd_sentence_id)=scdsen.scd_sentence_id)
  ORDER BY scdt.sequence_number, scdt.parent_scd_term_id
 ;end select
END GO
