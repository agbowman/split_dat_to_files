CREATE PROGRAM djh_phys_addr_bus_ezs
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT INTO  $OUTDEV
  p.active_ind, p.active_status_cd, p_active_status_disp = uar_get_code_display(p.active_status_cd),
  p.username, p.name_full_formatted, p.position_cd,
  p_position_disp = uar_get_code_display(p.position_cd), p.end_effective_dt_tm, p.updt_dt_tm,
  a.street_addr, a.street_addr2, a.street_addr3,
  a.street_addr4, a.city, a_state_disp = uar_get_code_display(a.state_cd),
  a.state_cd, a.zipcode, p.physician_ind,
  p.person_id, a.parent_entity_id, a.active_ind,
  a.address_type_cd, a_address_type_disp = uar_get_code_display(a.address_type_cd)
  FROM prsnl p,
   address a
  PLAN (p
   WHERE p.physician_ind=1
    AND p.active_ind=1
    AND p.active_status_cd=188)
   JOIN (a
   WHERE p.person_id=a.parent_entity_id
    AND a.active_ind=1
    AND ((a.address_type_cd=754) OR (a.address_type_cd=78188909)) )
  WITH maxrec = 20000, nocounter, separator = " ",
   format
 ;end select
END GO
