CREATE PROGRAM dcp_get_custom_demog_bar
 DECLARE customfield5(null) = null WITH protect
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
      OF 5:
       CALL customfield5(null)
     ENDCASE
   ENDFOR
 END ;Subroutine
 SUBROUTINE customfield1(null)
   SELECT INTO "nl:"
    FROM encounter e
    WHERE (e.person_id=request->person_id)
     AND (e.encntr_id=request->encntr_id)
    DETAIL
     icustomfieldindex = (icustomfieldindex+ 1), reply->custom_field[icustomfieldindex].
     custom_field_display = format(e.inpatient_admit_dt_tm,"@SHORTDATETIME"), reply->custom_field[
     icustomfieldindex].custom_field_index = 1
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE customfield2(null)
   SELECT INTO "nl:"
    FROM person_patient p
    WHERE (p.person_id=request->person_id)
    DETAIL
     icustomfieldindex = (icustomfieldindex+ 1), reply->custom_field[icustomfieldindex].
     custom_field_display = trim(cnvtstring(p.gest_age_at_birth)), reply->custom_field[
     icustomfieldindex].custom_field_index = 2
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE customfield3(null)
   DECLARE spmage = vc WITH noconstant(" "), protect
   DECLARE dob_null = i2 WITH noconstant(0), protect
   DECLARE deceased_null = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    dob_null = nullind(p.birth_dt_tm), deceased_null = nullind(p.deceased_dt_tm)
    FROM person p,
     person_patient pp
    PLAN (p
     WHERE (p.person_id=request->person_id))
     JOIN (pp
     WHERE pp.person_id=p.person_id)
    DETAIL
     IF (dob_null=0
      AND p.birth_dt_tm > 0)
      IF (deceased_null=0
       AND p.deceased_dt_tm > 0)
       spmage = trim(cnvtage(cnvtdate2(format(datetimeadd(p.birth_dt_tm,- ((1 * pp.gest_age_at_birth)
            )),"ddmmmyyyy;;d"),"ddmmmyyyy"),cnvtint(format(p.birth_dt_tm,"hhmm;;m")),cnvtdate2(format
          (p.deceased_dt_tm,"ddmmmyyyy;;d"),"ddmmmyyyy"),cnvtint(format(p.deceased_dt_tm,"hhmm;;m")))
        )
      ELSE
       spmage = trim(cnvtage(cnvtdate2(format(datetimeadd(p.birth_dt_tm,- ((1 * pp.gest_age_at_birth)
            )),"ddmmmyyyy;;d"),"ddmmmyyyy"),cnvtint(format(p.birth_dt_tm,"hhmm;;m"))))
      ENDIF
     ENDIF
     icustomfieldindex = (icustomfieldindex+ 1), reply->custom_field[icustomfieldindex].
     custom_field_display = spmage, reply->custom_field[icustomfieldindex].custom_field_index = 3
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE customfield4(null)
   DECLARE scorrectedage = vc WITH noconstant(" "), protect
   DECLARE dob_null = i2 WITH noconstant(0), protect
   DECLARE deceased_null = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    dob_null = nullind(p.birth_dt_tm), deceased_null = nullind(p.deceased_dt_tm)
    FROM person p,
     person_patient pp
    PLAN (p
     WHERE (p.person_id=request->person_id))
     JOIN (pp
     WHERE pp.person_id=p.person_id)
    DETAIL
     IF (dob_null=0
      AND p.birth_dt_tm > 0)
      IF (deceased_null=0
       AND p.deceased_dt_tm > 0)
       scorrectedage = trim(cnvtage(cnvtdate2(format(datetimeadd(p.birth_dt_tm,- ((1 * (pp
            .gest_age_at_birth - 280)))),"ddmmmyyyy;;d"),"ddmmmyyyy"),cnvtint(format(p.birth_dt_tm,
           "hhmm;;m")),cnvtdate2(format(p.deceased_dt_tm,"ddmmmyyyy;;d"),"ddmmmyyyy"),cnvtint(format(
           p.deceased_dt_tm,"hhmm;;m"))))
      ELSE
       scorrectedage = trim(cnvtage(cnvtdate2(format(datetimeadd(p.birth_dt_tm,- ((1 * (pp
            .gest_age_at_birth - 280)))),"ddmmmyyyy;;d"),"ddmmmyyyy"),cnvtint(format(p.birth_dt_tm,
           "hhmm;;m"))))
      ENDIF
     ENDIF
     icustomfieldindex = (icustomfieldindex+ 1), reply->custom_field[icustomfieldindex].
     custom_field_display = scorrectedage, reply->custom_field[icustomfieldindex].custom_field_index
      = 4
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE customfield5(null)
  DECLARE vip_cd = f8 WITH constant(uar_get_code_by("MEANING",67,"NONE")), protect
  SELECT INTO "nl:"
   FROM person p
   WHERE (p.person_id=request->person_id)
   DETAIL
    icustomfieldindex = (icustomfieldindex+ 1)
    IF (p.vip_cd != vip_cd
     AND p.vip_cd != 0)
     reply->custom_field[icustomfieldindex].custom_field_display = "Yes"
    ELSE
     reply->custom_field[icustomfieldindex].custom_field_display = "No"
    ENDIF
    reply->custom_field[icustomfieldindex].custom_field_index = 5
   WITH nocounter
  ;end select
 END ;Subroutine
 SET script_version = "03/14/08 MS5566"
END GO
