CREATE PROGRAM bhs_fsi_mod_msg:dba
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 DECLARE ml_pii_cnt = i4 WITH protect, noconstant(0)
 FREE RECORD m_temp_oen_reply
 RECORD m_temp_oen_reply(
   1 person_group[1]
     2 pat_group[1]
       3 pid[1]
         4 patient_id_int[*]
           5 id = vc
           5 check_digit = vc
           5 check_digit_scheme = vc
           5 assign_auth
             6 name_id = vc
             6 univ_id = vc
             6 univ_id_type = vc
           5 type_cd = vc
           5 assign_fac_id
             6 name_id = vc
             6 univ_id = vc
             6 univ_id_type = vc
           5 effective_date = vc
           5 expiration_date = vc
         4 alternate_pat_id[*]
           5 id = vc
           5 check_digit = vc
           5 check_digit_scheme = vc
           5 assign_auth
             6 name_id = vc
             6 univ_id = vc
             6 univ_id_type = vc
           5 type_cd = vc
           5 assign_fac_id
             6 name_id = vc
             6 univ_id = vc
             6 univ_id_type = vc
           5 effective_date = vc
           5 expiration_date = vc
 ) WITH protect
 IF (validate(oen_reply->person_group[1].pat_group[1].pid,"Z") != "Z")
  IF (size(oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int,5) > 0)
   FOR (ml_idx1 = 1 TO size(oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int,5))
     IF (validate(oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].assign_auth.
      name_id,"Z") != "Z")
      IF (trim(oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].assign_auth.
       name_id,3) != "CERNFED")
       SET ml_pii_cnt = (ml_pii_cnt+ 1)
       SET stat = alterlist(m_temp_oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int,
        ml_pii_cnt)
       IF (validate(oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].id,"Z")
        != "Z")
        SET m_temp_oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_pii_cnt].id =
        oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].id
       ENDIF
       IF (validate(oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].
        check_digit,"Z") != "Z")
        SET m_temp_oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_pii_cnt].
        check_digit = oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].
        check_digit
       ENDIF
       IF (validate(oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].
        check_digit_scheme,"Z") != "Z")
        SET m_temp_oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_pii_cnt].
        check_digit_scheme = oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].
        check_digit_scheme
       ENDIF
       IF (validate(oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].
        assign_auth.name_id,"Z") != "Z")
        SET m_temp_oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_pii_cnt].
        assign_auth.name_id = oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].
        assign_auth.name_id
       ENDIF
       IF (validate(oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].
        assign_auth.univ_id,"Z") != "Z")
        SET m_temp_oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_pii_cnt].
        assign_auth.univ_id = oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].
        assign_auth.univ_id
       ENDIF
       IF (validate(oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].
        assign_auth.univ_id_type,"Z") != "Z")
        SET m_temp_oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_pii_cnt].
        assign_auth.univ_id_type = oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[
        ml_idx1].assign_auth.univ_id_type
       ENDIF
       IF (validate(oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].type_cd,
        "Z") != "Z")
        SET m_temp_oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_pii_cnt].type_cd
         = oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].type_cd
       ENDIF
       IF (validate(oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].
        assign_fac_id.name_id,"Z") != "Z")
        SET m_temp_oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_pii_cnt].
        assign_fac_id.name_id = oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1
        ].assign_fac_id.name_id
       ENDIF
       IF (validate(oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].
        assign_fac_id.univ_id,"Z") != "Z")
        SET m_temp_oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_pii_cnt].
        assign_fac_id.univ_id = oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1
        ].assign_fac_id.univ_id
       ENDIF
       IF (validate(oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].
        assign_fac_id.univ_id_type,"Z") != "Z")
        SET m_temp_oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_pii_cnt].
        assign_fac_id.univ_id_type = oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[
        ml_idx1].assign_fac_id.univ_id_type
       ENDIF
       IF (validate(oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].
        effective_date,"Z") != "Z")
        SET m_temp_oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_pii_cnt].
        effective_date = oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].
        effective_date
       ENDIF
       IF (validate(oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].
        expiration_date,"Z") != "Z")
        SET m_temp_oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_pii_cnt].
        expiration_date = oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].
        expiration_date
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   SET stat = alterlist(oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int,0)
   FOR (ml_idx1 = 1 TO size(m_temp_oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int,5))
     SET stat = alterlist(oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int,ml_idx1)
     IF (size(trim(m_temp_oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].id,3
       )) > 0)
      SET oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].id =
      m_temp_oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].id
     ENDIF
     IF (size(trim(m_temp_oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].
       check_digit,3)) > 0)
      SET oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].check_digit =
      m_temp_oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].check_digit
     ENDIF
     IF (size(trim(m_temp_oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].
       check_digit_scheme,3)) > 0)
      SET oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].check_digit_scheme
       = m_temp_oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].
      check_digit_scheme
     ENDIF
     IF (size(trim(m_temp_oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].
       assign_auth.name_id,3)) > 0)
      SET oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].assign_auth.name_id
       = m_temp_oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].assign_auth.
      name_id
     ENDIF
     IF (size(trim(m_temp_oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].
       assign_auth.univ_id,3)) > 0)
      SET oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].assign_auth.univ_id
       = m_temp_oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].assign_auth.
      univ_id
     ENDIF
     IF (size(trim(m_temp_oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].
       assign_auth.univ_id_type,3)) > 0)
      SET oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].assign_auth.
      univ_id_type = m_temp_oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].
      assign_auth.univ_id_type
     ENDIF
     IF (size(trim(m_temp_oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].
       type_cd,3)) > 0)
      SET oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].type_cd =
      m_temp_oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].type_cd
     ENDIF
     IF (size(trim(m_temp_oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].
       assign_fac_id.name_id,3)) > 0)
      SET oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].assign_fac_id.
      name_id = m_temp_oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].
      assign_fac_id.name_id
     ENDIF
     IF (size(trim(m_temp_oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].
       assign_fac_id.univ_id,3)) > 0)
      SET oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].assign_fac_id.
      univ_id = m_temp_oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].
      assign_fac_id.univ_id
     ENDIF
     IF (size(trim(m_temp_oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].
       assign_fac_id.univ_id_type,3)) > 0)
      SET oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].assign_fac_id.
      univ_id_type = m_temp_oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].
      assign_fac_id.univ_id_type
     ENDIF
     IF (size(trim(m_temp_oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].
       effective_date,3)) > 0)
      SET oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].effective_date =
      m_temp_oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].effective_date
     ENDIF
     IF (size(trim(m_temp_oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].
       expiration_date,3)) > 0)
      SET oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].expiration_date =
      m_temp_oen_reply->person_group[1].pat_group[1].pid[1].patient_id_int[ml_idx1].expiration_date
     ENDIF
   ENDFOR
  ENDIF
  SET ml_pii_cnt = 0
  SET ml_idx1 = 0
  IF (size(oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id,5) > 0)
   FOR (ml_idx1 = 1 TO size(oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id,5))
     IF (validate(oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].
      assign_auth.name_id,"Z") != "Z")
      IF (trim(oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].assign_auth.
       name_id,3) != "CERNFED")
       SET ml_pii_cnt = (ml_pii_cnt+ 1)
       SET stat = alterlist(m_temp_oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id,
        ml_pii_cnt)
       IF (validate(oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].id,"Z")
        != "Z")
        SET m_temp_oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_pii_cnt].id =
        oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].id
       ENDIF
       IF (validate(oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].
        check_digit,"Z") != "Z")
        SET m_temp_oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_pii_cnt].
        check_digit = oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].
        check_digit
       ENDIF
       IF (validate(oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].
        check_digit_scheme,"Z") != "Z")
        SET m_temp_oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_pii_cnt].
        check_digit_scheme = oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1]
        .check_digit_scheme
       ENDIF
       IF (validate(oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].
        assign_auth.name_id,"Z") != "Z")
        SET m_temp_oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_pii_cnt].
        assign_auth.name_id = oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1
        ].assign_auth.name_id
       ENDIF
       IF (validate(oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].
        assign_auth.univ_id,"Z") != "Z")
        SET m_temp_oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_pii_cnt].
        assign_auth.univ_id = oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1
        ].assign_auth.univ_id
       ENDIF
       IF (validate(oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].
        assign_auth.univ_id_type,"Z") != "Z")
        SET m_temp_oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_pii_cnt].
        assign_auth.univ_id_type = oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[
        ml_idx1].assign_auth.univ_id_type
       ENDIF
       IF (validate(oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].type_cd,
        "Z") != "Z")
        SET m_temp_oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_pii_cnt].
        type_cd = oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].type_cd
       ENDIF
       IF (validate(oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].
        assign_fac_id.name_id,"Z") != "Z")
        SET m_temp_oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_pii_cnt].
        assign_fac_id.name_id = oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[
        ml_idx1].assign_fac_id.name_id
       ENDIF
       IF (validate(oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].
        assign_fac_id.univ_id,"Z") != "Z")
        SET m_temp_oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_pii_cnt].
        assign_fac_id.univ_id = oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[
        ml_idx1].assign_fac_id.univ_id
       ENDIF
       IF (validate(oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].
        assign_fac_id.univ_id_type,"Z") != "Z")
        SET m_temp_oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_pii_cnt].
        assign_fac_id.univ_id_type = oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[
        ml_idx1].assign_fac_id.univ_id_type
       ENDIF
       IF (validate(oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].
        effective_date,"Z") != "Z")
        SET m_temp_oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_pii_cnt].
        effective_date = oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].
        effective_date
       ENDIF
       IF (validate(oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].
        expiration_date,"Z") != "Z")
        SET m_temp_oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_pii_cnt].
        expiration_date = oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].
        expiration_date
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   SET stat = alterlist(oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id,0)
   FOR (ml_idx1 = 1 TO size(m_temp_oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id,5)
    )
     SET stat = alterlist(oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id,ml_idx1)
     IF (size(trim(m_temp_oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].id,
       3)) > 0)
      SET oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].id =
      m_temp_oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].id
     ENDIF
     IF (size(trim(m_temp_oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].
       check_digit,3)) > 0)
      SET oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].check_digit =
      m_temp_oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].check_digit
     ENDIF
     IF (size(trim(m_temp_oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].
       check_digit_scheme,3)) > 0)
      SET oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].check_digit_scheme
       = m_temp_oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].
      check_digit_scheme
     ENDIF
     IF (size(trim(m_temp_oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].
       assign_auth.name_id,3)) > 0)
      SET oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].assign_auth.
      name_id = m_temp_oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].
      assign_auth.name_id
     ENDIF
     IF (size(trim(m_temp_oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].
       assign_auth.univ_id,3)) > 0)
      SET oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].assign_auth.
      univ_id = m_temp_oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].
      assign_auth.univ_id
     ENDIF
     IF (size(trim(m_temp_oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].
       assign_auth.univ_id_type,3)) > 0)
      SET oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].assign_auth.
      univ_id_type = m_temp_oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].
      assign_auth.univ_id_type
     ENDIF
     IF (size(trim(m_temp_oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].
       type_cd,3)) > 0)
      SET oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].type_cd =
      m_temp_oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].type_cd
     ENDIF
     IF (size(trim(m_temp_oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].
       assign_fac_id.name_id,3)) > 0)
      SET oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].assign_fac_id.
      name_id = m_temp_oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].
      assign_fac_id.name_id
     ENDIF
     IF (size(trim(m_temp_oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].
       assign_fac_id.univ_id,3)) > 0)
      SET oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].assign_fac_id.
      univ_id = m_temp_oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].
      assign_fac_id.univ_id
     ENDIF
     IF (size(trim(m_temp_oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].
       assign_fac_id.univ_id_type,3)) > 0)
      SET oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].assign_fac_id.
      univ_id_type = m_temp_oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].
      assign_fac_id.univ_id_type
     ENDIF
     IF (size(trim(m_temp_oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].
       effective_date,3)) > 0)
      SET oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].effective_date =
      m_temp_oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].effective_date
     ENDIF
     IF (size(trim(m_temp_oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].
       expiration_date,3)) > 0)
      SET oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].expiration_date =
      m_temp_oen_reply->person_group[1].pat_group[1].pid[1].alternate_pat_id[ml_idx1].expiration_date
     ENDIF
   ENDFOR
  ENDIF
 ENDIF
#exit_script
END GO
