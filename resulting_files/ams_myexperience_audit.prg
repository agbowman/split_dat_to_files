CREATE PROGRAM ams_myexperience_audit
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Audit All" = 0,
  "Search for an user" = "",
  "" = 0
  WITH outdev, allusersind, textuser,
  seluser
 EXECUTE ams_define_toolkit_common
 DECLARE script_name = c26 WITH constant("AMS_MYEXPERIENCE_AUDIT")
 DECLARE dba_position_cd = f8 WITH constant(uar_get_code_by("MEANING",88,"DBA")), protect
 DECLARE name_type_cd = f8 WITH constant(uar_get_code_by("MEANING",213,"PRSNL")), protect
 DECLARE incrementcount = f8 WITH protect
 SET incrementcount = 1
 CALL updtdminfo(script_name,cnvtreal(incrementcount))
 SELECT INTO  $OUTDEV
  client = ld.mnemonic, username = p.username, name_full = p.name_full_formatted,
  role_name = uar_get_code_display(rtr.role_type_cd), user_current_position = uar_get_code_display(p
   .position_cd), user_available_positions = uar_get_code_display(port.position_cd)
  FROM prsnl_role_type prt,
   role_type_reltn rtr,
   prsnl p,
   position_role_type port,
   logical_domain ld,
   person_name pn,
   prsnl p1
  PLAN (p1
   WHERE (p1.person_id=reqinfo->updt_id))
   JOIN (p
   WHERE p1.logical_domain_id=p.logical_domain_id
    AND p.active_ind=1
    AND p.end_effective_dt_tm > sysdate
    AND (((p.person_id= $SELUSER)) OR (( $ALLUSERSIND=1)))
    AND p.name_last_key != "*CERNER*"
    AND p.name_first_key != "*CERNER*"
    AND trim(p.username) != ""
    AND p.position_cd != value(uar_get_code_by("MEANING",88,"DBA")))
   JOIN (prt
   WHERE p.person_id=prt.person_id
    AND prt.active_ind=1
    AND prt.end_effective_dt_tm > sysdate)
   JOIN (rtr
   WHERE rtr.role_type_reltn_id=prt.role_type_reltn_id
    AND rtr.active_ind=1
    AND rtr.end_effective_dt_tm > sysdate)
   JOIN (port
   WHERE port.role_type_cd=rtr.role_type_cd
    AND port.active_ind=1
    AND port.end_effective_dt_tm > sysdate)
   JOIN (ld
   WHERE ld.logical_domain_id=p.logical_domain_id)
   JOIN (pn
   WHERE outerjoin(p.person_id)=pn.person_id
    AND pn.name_type_cd=outerjoin(value(uar_get_code_by("MEANING",213,"PRSNL")))
    AND pn.name_title != outerjoin("Cerner AMS")
    AND pn.active_ind=outerjoin(1)
    AND pn.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
  ORDER BY role_name, trim(cnvtupper(p.name_full_formatted),7), user_available_positions
  WITH nocounter, separator = " ", format
 ;end select
 SET last_mod = "000"
END GO
