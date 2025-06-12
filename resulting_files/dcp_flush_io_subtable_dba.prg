CREATE PROGRAM dcp_flush_io_subtable:dba
 DECLARE not_done = i2 WITH protect, noconstant(true)
 DECLARE not_failed = i2 WITH protect, noconstant(true)
 DECLARE cebit_val = i4 WITH protect, noconstant(0)
 DECLARE max_ce_io_result_id = f8 WITH protect, noconstant(0.0)
 DECLARE ce_io_result_id = f8 WITH protect, noconstant(1.0)
 DECLARE reference_event_id = f8 WITH protect, noconstant(0.0)
 DECLARE clinical_event_id = f8 WITH protect, noconstant(0.0)
 SELECT INTO "nl:"
  FROM ce_intake_output_result cir
  WHERE cir.ce_io_result_id > 0.0
   AND cir.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
  ORDER BY cir.ce_io_result_id DESC
  DETAIL
   max_ce_io_result_id = cir.ce_io_result_id
  WITH nocounter, maxrec = 1
 ;end select
 IF (max_ce_io_result_id > 0.0)
  WHILE (not_done)
    IF (ce_io_result_id=max_ce_io_result_id)
     SET not_done = false
    ENDIF
    SET not_failed = true
    SET reference_event_id = 0.0
    SELECT INTO "nl:"
     FROM ce_intake_output_result cir
     WHERE cir.ce_io_result_id >= ce_io_result_id
      AND cir.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
     ORDER BY cir.ce_io_result_id
     HEAD cir.ce_io_result_id
      ce_io_result_id = cir.ce_io_result_id, reference_event_id = cir.reference_event_id
     WITH nocounter, maxrec = 1
    ;end select
    IF (curqual=1)
     SET clinical_event_id = 0.0
     SET cebit_val = 0
     SELECT INTO "nl:"
      ce.clinical_event_id
      FROM clinical_event ce
      WHERE ce.event_id=reference_event_id
       AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
      DETAIL
       clinical_event_id = ce.clinical_event_id, cebit_val = ce.subtable_bit_map
      WITH nocounter, forupdate(ce)
     ;end select
     IF (curqual=1)
      SET cebit_val = bxor(cebit_val,8)
      UPDATE  FROM clinical_event ce
       SET ce.subtable_bit_map = cebit_val
       WHERE ce.clinical_event_id=clinical_event_id
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET not_failed = false
      ENDIF
     ELSE
      SET not_failed = false
     ENDIF
     IF (not_failed)
      DELETE  FROM ce_intake_output_result cir
       WHERE cir.ce_io_result_id=ce_io_result_id
       WITH nocounter
      ;end delete
      IF (curqual=1)
       COMMIT
      ELSE
       ROLLBACK
      ENDIF
     ELSE
      ROLLBACK
     ENDIF
     SET ce_io_result_id = (ce_io_result_id+ 1.0)
    ELSE
     SET not_done = false
    ENDIF
  ENDWHILE
 ENDIF
 DELETE  FROM ce_intake_output_result cir
  WHERE cir.ce_io_result_id > 0.0
   AND cir.valid_until_dt_tm != cnvtdatetime("31-DEC-2100")
  WITH nocounter
 ;end delete
 COMMIT
END GO
