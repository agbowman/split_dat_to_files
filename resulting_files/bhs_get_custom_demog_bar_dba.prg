CREATE PROGRAM bhs_get_custom_demog_bar:dba
 DECLARE icustomfieldindex = i4 WITH protect, noconstant(0)
 DECLARE icustfieldcnt = i4 WITH protect, noconstant(0)
 DECLARE customfield5(null) = null WITH protect
 DECLARE customfield4(null) = null WITH protect
 DECLARE customfield3(null) = null WITH protect
 DECLARE customfield2(null) = null WITH protect
 DECLARE customfield1(null) = null WITH protect
 DECLARE parserequest(null) = null WITH protect
 CALL echo("check request")
 IF (validate(request)=0)
  RECORD request(
    1 person_id = f8
    1 encntr_id = f8
    1 custom_field[1]
      2 custom_field_show = i2
  )
  SET request->person_id = 21975953.0
  SET request->encntr_id = 0.0
  SET request->custom_field[1].custom_field_show = 1
 ENDIF
 CALL echorecord(request)
 SET icustfieldcnt = size(request->custom_field,5)
 CALL echo("check reply")
 IF (validate(reply)=0)
  RECORD reply(
    1 custom_field[*]
      2 custom_field_index = i4
      2 custom_field_display = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->custom_field,icustfieldcnt)
 CALL echo(concat("icustfieldcnt: ",trim(cnvtstring(icustfieldcnt))))
 CALL parserequest(null)
 CALL echo(concat("icustomfieldindex: ",trim(cnvtstring(icustomfieldindex))))
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
   FROM bhs_demographics b
   WHERE (b.person_id=request->person_id)
    AND b.active_ind=1
    AND b.end_effective_dt_tm > sysdate
    AND b.display="ACTIVE"
    AND b.description="PORTAL_STATUS"
   DETAIL
    icustomfieldindex += 1, reply->custom_field[icustomfieldindex].custom_field_display =
    "myHealth: Y", reply->custom_field[icustomfieldindex].custom_field_index = 1
   WITH nocounter
  ;end select
  IF (curqual < 1)
   SET icustomfieldindex += 1
   SET reply->custom_field[icustomfieldindex].custom_field_display = "myHealth: N"
   SET reply->custom_field[icustomfieldindex].custom_field_index = 1
  ENDIF
 END ;Subroutine
 SUBROUTINE customfield2(null)
   CALL echo(build2("HCP"))
   DECLARE mf_hcp_scanned = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
     "HEALTHCAREPROXYSCANNEDFORM"))
   CALL echo(build2("mf_HCP_SCANNED: ",mf_hcp_scanned))
   DECLARE mf_inerror1_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",8,"IN ERROR"))
   DECLARE mf_inerror2_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",8,"INERRNOMUT"))
   DECLARE mf_inerror3_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",8,"INERRNOVIEW"))
   DECLARE mf_inerror4_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",8,"INERROR"))
   DECLARE mf_inprogress_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",8,"IN PROGRESS"))
   DECLARE mf_unauth_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",8,"UNAUTH"))
   DECLARE mf_notdone_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",8,"NOT DONE"))
   DECLARE mf_cancelled_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",8,"CANCELLED"))
   DECLARE mf_inlab_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",8,"IN LAB"))
   DECLARE mf_rejected_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",8,"REJECTED"))
   DECLARE mf_unknown_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",8,"UNKNOWN"))
   DECLARE mf_placeholder_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",53,"PLACEHOLDER"
     ))
   DECLARE mn_hcp_ind = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM clinical_event ce
    WHERE (ce.person_id=request->person_id)
     AND ce.event_cd=mf_hcp_scanned
     AND  NOT (ce.result_status_cd IN (mf_inerror1_cd, mf_inerror2_cd, mf_inerror3_cd, mf_inerror4_cd,
    mf_inprogress_cd,
    mf_unauth_cd, mf_notdone_cd, mf_cancelled_cd, mf_inlab_cd, mf_rejected_cd,
    mf_unknown_cd))
     AND ce.event_class_cd != mf_placeholder_cd
     AND ce.view_level=1
     AND ce.valid_from_dt_tm <= cnvtdatetime(sysdate)
     AND ce.valid_until_dt_tm >= cnvtdatetime(sysdate)
    ORDER BY ce.valid_from_dt_tm DESC
    HEAD ce.person_id
     CALL echo(build2("ce.event_cd: ",trim(cnvtstring(ce.event_cd),3)," ",uar_get_code_display(ce
       .event_cd)," ",
      ce.result_val)), mn_hcp_ind = 1
    WITH nocounter
   ;end select
   SET icustomfieldindex += 1
   SET reply->custom_field[icustomfieldindex].custom_field_display = evaluate(mn_hcp_ind,1,
    "Health Care Proxy: Y","Health Care Proxy: N")
   SET reply->custom_field[icustomfieldindex].custom_field_index = 2
   CALL echorecord(reply)
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
     icustomfieldindex += 1, reply->custom_field[icustomfieldindex].custom_field_display = spmage,
     reply->custom_field[icustomfieldindex].custom_field_index = 3
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
     icustomfieldindex += 1, reply->custom_field[icustomfieldindex].custom_field_display =
     scorrectedage, reply->custom_field[icustomfieldindex].custom_field_index = 4
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE customfield5(null)
   DECLARE status_priority = i1 WITH protect, noconstant(10)
   DECLARE cur_status_priority = i1 WITH protect, noconstant(0)
   DECLARE status_display = vc WITH protect
   DECLARE on_study_status_val = i1 WITH protect, constant(1)
   DECLARE on_treatment_status_val = i1 WITH protect, constant(2)
   DECLARE off_treatment_status_val = i1 WITH protect, constant(3)
   DECLARE off_study_status_val = i1 WITH protect, constant(4)
   SELECT INTO "nl:"
    FROM pt_prot_reg ppr,
     prot_master pm
    PLAN (ppr
     WHERE (ppr.person_id=request->person_id)
      AND ppr.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (pm
     WHERE pm.prot_master_id=ppr.prot_master_id
      AND pm.display_ind=1
      AND pm.end_effective_dt_tm > cnvtdatetime(sysdate))
    DETAIL
     CASE (ppr.status_enum)
      OF on_study_status_val:
       cur_status_priority = 1
      OF on_treatment_status_val:
       cur_status_priority = 2
      OF off_treatment_status_val:
       cur_status_priority = 4
      OF off_study_status_val:
       cur_status_priority = 6
      ELSE
       cur_status_priority = 10
     ENDCASE
     IF (cur_status_priority < status_priority)
      status_priority = cur_status_priority
     ENDIF
    WITH nocounter
   ;end select
   SET icustomfieldindex += 1
   SET reply->custom_field[icustomfieldindex].custom_field_index = 5
   CASE (status_priority)
    OF 1:
     SET status_display = "On Study"
    OF 2:
     SET status_display = "On Treatment"
    OF 4:
     SET status_display = "Off Treatment"
    OF 6:
     SET status_display = "No"
    ELSE
     SET status_display = "No"
   ENDCASE
   SET reply->custom_field[icustomfieldindex].custom_field_display = status_display
 END ;Subroutine
#exit_script
 CALL echorecord(reply)
END GO
