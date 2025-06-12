CREATE PROGRAM doc_dea_add:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO  $OUTDEV
  p.name_full_formatted, pa_prsnl_alias_type_disp = uar_get_code_display(pa.prsnl_alias_type_cd), pa
  .alias,
  a.street_addr, a.street_addr2, a.street_addr3,
  a.street_addr4, a.city, a.state,
  a.zipcode, phone = format(ph.phone_num,"(###) ###-####")
  FROM prsnl p,
   prsnl_alias pa,
   address a,
   phone ph
  PLAN (p
   WHERE p.physician_ind=1
    AND p.active_status_cd=188)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.prsnl_alias_type_cd=1084
    AND  NOT (pa.person_id IN (
   (SELECT
    p1.person_id
    FROM prsnl_alias p1
    WHERE p1.prsnl_alias_type_cd=1088
     AND p1.alias="9*"
     AND p1.person_id=pa.person_id))))
   JOIN (a
   WHERE a.parent_entity_id=outerjoin(p.person_id)
    AND a.parent_entity_name=outerjoin("PERSON")
    AND a.address_type_cd=outerjoin(78188909.00))
   JOIN (ph
   WHERE ph.parent_entity_id=outerjoin(p.person_id)
    AND ph.phone_type_cd=outerjoin(78189133.00))
  WITH nocounter, format
 ;end select
END GO
