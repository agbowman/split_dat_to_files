CREATE PROGRAM dcp_get_custom_demog_bar2
 DECLARE customfield4(null) = null WITH protect
 DECLARE customfield3(null) = null WITH protect
 DECLARE customfield2(null) = null WITH protect
 DECLARE customfield1(null) = null WITH protect
 DECLARE parserequest(null) = null WITH protect
 DECLARE icustomfieldindex = i4 WITH noconstant(0), protect
 DECLARE icustfieldcnt = i4 WITH constant(size(request->custom_field,5)), protect
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->custom_field,icustfieldcnt)
 CALL parserequest(null)
 SET stat = alterlist(reply->custom_field,icustomfieldindex)
 SET reply->status_data.status = "S"
 SUBROUTINE parserequest(x)
   FOR (ind = 1 TO icustfieldcnt)
     CASE (request->custom_field[ind].custom_field_show)
      OF 1:
       CALL customfield1(null)
      OF 2:
       CALL customfield2(null)
      OF 3:
       CALL customfield3(null)
      OF 4:
       CALL customfield4(null)
     ENDCASE
   ENDFOR
 END ;Subroutine
 SUBROUTINE customfield1(null)
   DECLARE clinicalwt_cd = f8 WITH constant(uar_get_code_by_cki("CKI.EC!9528")), protect
   DECLARE altered_cd = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!16901")), protect
   DECLARE auth_cd = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!2628")), protect
   DECLARE modified_cd = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!2636")), protect
   DECLARE powerchart_cd = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!4835")), protect
   SET icustomfieldindex = (icustomfieldindex+ 1)
   SET reply->custom_field[icustomfieldindex].custom_field_index = 1
   SET reply->custom_field[icustomfieldindex].custom_field_display = ""
   SELECT INTO "nl:"
    ce.event_cd, ce.clinical_event_id
    FROM clinical_event ce
    WHERE (ce.person_id=request->person_id)
     AND (ce.encntr_id=request->encntr_id)
     AND ce.event_cd=clinicalwt_cd
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
     AND ce.result_status_cd IN (altered_cd, auth_cd, modified_cd)
     AND ce.view_level=1
     AND ce.publish_flag=1
     AND ce.contributor_system_cd=powerchart_cd
    ORDER BY ce.event_end_dt_tm DESC
    HEAD ce.event_cd
     reply->custom_field[icustomfieldindex].custom_field_display = build2(trim(cnvtstring(ce
        .result_val,10,3))," ",trim(uar_get_code_display(ce.result_units_cd),3)," ","(",
      trim(format(ce.updt_dt_tm,"MM/DD/YYYY"),3),")")
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE customfield2(null)
   DECLARE 200_resus_status_cd = f8 WITH constant(uar_get_code_by("DISPLAY_KEY",200,
     "RESUSCITATIONSTATUS")), protect
   DECLARE 6004_ordered_status_cd = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!3102")),
   protect
   DECLARE 16449_resus_type_cd = f8 WITH constant(uar_get_code_by("DISPLAY_KEY",16449,
     "RESUSCITATION STATUS")), protect
   SELECT INTO "nl"
    FROM orders o,
     order_detail od
    PLAN (o
     WHERE (o.encntr_id=request->encntr_id)
      AND o.catalog_cd=200_resus_status_cd
      AND o.order_status_cd=6004_ordered_status_cd
      AND o.active_ind=1)
     JOIN (od
     WHERE od.order_id=o.order_id
      AND od.oe_field_id=16449_resus_type_cd
      AND (od.action_sequence=
     (SELECT
      max(od2.action_sequence)
      FROM order_detail od2
      WHERE od.order_id=od2.order_id
       AND od.oe_field_id=16449_resus_type_cd)))
    ORDER BY o.order_id, od.oe_field_id, od.action_sequence DESC,
     od.detail_sequence DESC
    HEAD o.order_id
     icustomfieldindex = (icustomfieldindex+ 1), reply->custom_field[icustomfieldindex].
     custom_field_display = trim(od.oe_field_display_value), reply->custom_field[icustomfieldindex].
     custom_field_index = 2
    HEAD od.oe_field_id
     null
    HEAD od.detail_sequence
     null
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE customfield3(null)
   DECLARE 200_isolation_status_cd = f8 WITH constant(uar_get_code_by("DISPLAY_KEY",200,
     "PATIENTISOLATION")), protect
   DECLARE 6004_ordered_status_cd = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!3102")),
   protect
   DECLARE 16449_isolation_cd = f8 WITH constant(uar_get_code_by("DISPLAY_KEY",16449,"ISOLATIONCODE")
    ), protect
   SELECT INTO "nl"
    FROM orders o,
     order_detail od
    PLAN (o
     WHERE (o.encntr_id=request->encntr_id)
      AND o.catalog_cd=200_isolation_status_cd
      AND o.order_status_cd=6004_ordered_status_cd
      AND o.active_ind=1)
     JOIN (od
     WHERE od.order_id=o.order_id
      AND od.oe_field_id=16449_isolation_cd
      AND (od.action_sequence=
     (SELECT
      max(od2.action_sequence)
      FROM order_detail od2
      WHERE od.order_id=od2.order_id
       AND od.oe_field_id=16449_isolation_cd)))
    ORDER BY o.order_id, od.oe_field_id, od.action_sequence DESC,
     od.detail_sequence DESC
    HEAD o.order_id
     icustomfieldindex = (icustomfieldindex+ 1), reply->custom_field[icustomfieldindex].
     custom_field_display = trim(od.oe_field_display_value), reply->custom_field[icustomfieldindex].
     custom_field_index = 3
    HEAD od.oe_field_id
     null
    HEAD od.detail_sequence
     null
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE customfield4(null)
   DECLARE on_study = i2 WITH constant(1), protect
   DECLARE off_study = i2 WITH constant(0), protect
   DECLARE no_data = i2 WITH constant(- (1)), protect
   DECLARE study_ind = i2 WITH noconstant(no_data), protect
   SELECT INTO "nl:"
    FROM pt_prot_reg ppr
    WHERE (ppr.person_id=request->person_id)
     AND ppr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND ppr.end_effective_dt_tm > cnvtdatetime(sysdate)
    DETAIL
     IF (ppr.off_study_dt_tm < cnvtdatetime(sysdate))
      IF (study_ind != on_study)
       study_ind = off_study
      ENDIF
     ELSE
      study_ind = on_study
     ENDIF
    WITH nocounter
   ;end select
   SET icustomfieldindex = (icustomfieldindex+ 1)
   SET reply->custom_field[icustomfieldindex].custom_field_index = 4
   IF (study_ind=on_study)
    SET reply->custom_field[icustomfieldindex].custom_field_display = "Clinical Research: On Study"
   ELSEIF (study_ind=off_study)
    SET reply->custom_field[icustomfieldindex].custom_field_display = "Clinical Research: Off Study"
   ELSE
    SET reply->custom_field[icustomfieldindex].custom_field_display = ""
   ENDIF
 END ;Subroutine
 SET script_version = "08/27/12 PB026393"
END GO
