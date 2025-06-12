CREATE PROGRAM ams_sched_keychain_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Audit All" = 0,
  "Search for a User:" = "",
  "" = 0,
  "Associated Keychains:" = ""
  WITH outdev, allusersind, textuser,
  selusers, dispkeychains
 EXECUTE ams_define_toolkit_common
 DECLARE script_name = c26 WITH constant("AMS_SCHED_KEYCHAIN_AUDIT")
 DECLARE dba_position_cd = f8 WITH constant(uar_get_code_by("MEANING",88,"DBA")), protect
 DECLARE name_type_cd = f8 WITH constant(uar_get_code_by("MEANING",213,"PRSNL")), protect
 DECLARE incrementcount = f8 WITH protect
 SET incrementcount = 1
 CALL updtdminfo(script_name,cnvtreal(incrementcount))
 SELECT DISTINCT INTO  $OUTDEV
  client = ld.mnemonic, keychain = so.mnemonic, user = p.name_full_formatted,
  username = p.username, position = substring(1,40,uar_get_code_display(p.position_cd)), p.person_id
  FROM prsnl pr,
   sch_assoc sa,
   sch_object so,
   prsnl p,
   person_name pn,
   logical_domain ld
  PLAN (pr
   WHERE (pr.person_id=reqinfo->updt_id))
   JOIN (sa
   WHERE sa.active_ind=1
    AND (((sa.child_id= $SELUSERS)) OR (( $ALLUSERSIND=1)))
    AND sa.data_source_meaning="PRSNL"
    AND sa.assoc_type_meaning="PRSNLCHAIN"
    AND sa.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND sa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (so
   WHERE so.sch_object_id=sa.parent_id)
   JOIN (p
   WHERE p.person_id=sa.child_id
    AND p.active_ind=1
    AND p.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND p.name_last_key != "*CERNER*"
    AND p.name_first_key != "*CERNER*"
    AND trim(p.username) != ""
    AND p.username != null
    AND p.position_cd != dba_position_cd
    AND p.position_cd != null
    AND p.position_cd != 0
    AND p.logical_domain_id=pr.logical_domain_id)
   JOIN (pn
   WHERE pn.person_id=p.person_id
    AND pn.name_type_cd=name_type_cd
    AND ((pn.name_title != "Cerner AMS") OR (pn.name_title=null))
    AND pn.active_ind=1
    AND pn.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND pn.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (ld
   WHERE p.logical_domain_id=ld.logical_domain_id)
  ORDER BY user, cnvtupper(so.mnemonic)
  WITH nocounter, separator = " ", format,
   format(date,";;q")
 ;end select
 SET last_mod = "000"
END GO
