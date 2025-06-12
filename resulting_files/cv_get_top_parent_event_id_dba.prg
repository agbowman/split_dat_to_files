CREATE PROGRAM cv_get_top_parent_event_id:dba
 FREE SET internal
 RECORD internal(
   1 event_id = f8
   1 parent_event_id = f8
 )
 DECLARE index = i4 WITH protect, noconstant(0)
 DECLARE cntx = i4 WITH protect, noconstant(0)
 DECLARE parent_event_id = f8 WITH protect, noconstant(0.0)
 DECLARE called = c1 WITH protect, noconstant("F")
 SET cntx = value(size(register->rec,5))
 DECLARE recursive_sub(cur_parent_event_id=f8) = f8
 FOR (index = 1 TO cntx)
  SET parent_event_id = register->rec[index].parent_event_id
  CALL recursive_sub(parent_event_id)
 ENDFOR
 SUBROUTINE recursive_sub(cur_parent_event_id)
   SET passed_in_value = cur_parent_event_id
   FREE SET cur_parent_event_id
   DECLARE new_parent_event_id = f8
   SELECT INTO "nl:"
    cr.event_id
    FROM cv_registry_event cr
    WHERE cr.event_id=passed_in_value
     AND cr.event_id=cr.parent_event_id
    WITH nocounter
   ;end select
   IF (curqual=0)
    SELECT INTO "nl:"
     ce.event_id, ce.parent_event_id
     FROM clinical_event ce
     WHERE ce.event_id=passed_in_value
     DETAIL
      internal->event_id = ce.event_id, internal->parent_event_id = ce.parent_event_id,
      new_parent_event_id = ce.parent_event_id
     WITH nocounter
    ;end select
    IF ((internal->event_id=internal->parent_event_id)
     AND called="F")
     SET cv_omf_rec->top_parent_event_id = internal->parent_event_id
     SET called = "T"
     CALL echo(build("Top_Parent_Event_Id:",internal->parent_event_id))
    ELSE
     CALL recursive_sub(new_parent_event_id)
    ENDIF
   ELSE
    IF (called="F")
     SET cv_omf_rec->top_parent_event_id = passed_in_value
     SET cv_omf_rec->form_event_id = passed_in_value
     CALL echo(build("This is Top Parent_Event_Id:",passed_in_value))
     SET called = "T"
    ENDIF
   ENDIF
   RETURN(100)
 END ;Subroutine
#end_program
 DECLARE cv_get_top_parent_event_id_vrsn = vc WITH private, constant("MOD 003 03/23/06 BM9013")
END GO
