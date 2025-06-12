CREATE PROGRAM bhs_rpt_pref_ancillary:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Surgical Area:" = "",
  "Procedure Name (wildchar accepted):" = "*",
  "Procedure Code (wildchar accepted):" = "*",
  "Surgeon (wildcard accepted)" = "*"
  WITH outdev, ms_surg_area, ms_proc_name,
  ms_proc_code, ms_prsnl
 DECLARE mf_ancillary_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"ANCILLARY"))
 DECLARE ms_parse_syn = vc WITH protect, noconstant("")
 DECLARE ms_parse_str = vc WITH protect, noconstant(" 1=1 ")
 SET ms_data_type = reflect(parameter(2,0))
 IF (substring(1,1,ms_data_type) != "L")
  SET ms_parse_str = parameter(2,1)
  IF (size(trim(ms_parse_str)) > 0)
   IF (trim(ms_parse_str)=char(42))
    SET ms_parse_str = " 1=1 "
   ELSE
    SET ms_parse_str = concat(" p.surg_area_cd-0 = ",trim(ms_parse_str))
   ENDIF
  ELSE
   GO TO exit_program
  ENDIF
 ELSE
  FOR (ml_cnt = 1 TO cnvtint(substring(2,(size(ms_data_type) - 1),ms_data_type)))
   SET ms_tmp_str = parameter(5,ml_cnt)
   IF (ml_cnt=1)
    SET ms_parse_str = concat(" p.surg_area_cd-0 in (",trim(ms_tmp_str))
   ELSE
    SET ms_parse_str = concat(ms_parse_str,", ",trim(ms_tmp_str))
   ENDIF
  ENDFOR
  SET ms_parse_str = concat(ms_parse_str,")")
 ENDIF
 IF (size(trim( $MS_PROC_CODE,3))=1
  AND trim( $MS_PROC_CODE)=char(42))
  SET ms_parse_syn = concat(
   "o.catalog_cd = outerjoin(p.catalog_cd) and o.mnemonic_type_cd = outerjoin(",trim(cnvtstring(
     mf_ancillary_cd,20),3),') and o.mnemonic = outerjoin("0*")')
 ELSE
  SET ms_parse_syn = concat("o.catalog_cd = p.catalog_cd and o.mnemonic_type_cd = ",trim(cnvtstring(
     mf_ancillary_cd,20),3),' and substring(1,8,o.mnemonic) = "', $MS_PROC_CODE,'"')
 ENDIF
 SELECT DISTINCT INTO  $OUTDEV
  surgarea = uar_get_code_display(p.surg_area_cd), surgeon = omf_get_pers_full(p.prsnl_id), doctype
   = uar_get_code_display(p.doc_type_cd),
  proc_code = substring(1,8,trim(o.mnemonic)), procedure_name = uar_get_code_description(p.catalog_cd
   ), speciaity = omf_get_prsnl_grp_name(p.surg_specialty_id),
  create_date = p.create_dt_tm"@SHORTDATETIME", create_by = omf_get_pers_full(p.create_prsnl_id),
  update_date = p.updt_dt_tm"@SHORTDATETIME",
  updated_by = omf_get_pers_full(p.updt_id), total_use = p.tot_nbr_cases, lase_used = p
  .last_used_dt_tm"@SHORTDATETIME"
  FROM preference_card p,
   code_value cv,
   prsnl pr,
   order_catalog_synonym o
  PLAN (p
   WHERE p.active_ind=1
    AND parser(ms_parse_str))
   JOIN (cv
   WHERE cv.code_value=p.catalog_cd
    AND (cnvtupper(cv.description)= $MS_PROC_NAME))
   JOIN (pr
   WHERE pr.person_id=p.prsnl_id
    AND (cnvtupper(pr.name_full_formatted)= $MS_PRSNL))
   JOIN (o
   WHERE parser(ms_parse_syn))
  ORDER BY surgarea, surgeon, procedure_name
  WITH nocounter, separator = " ", format
 ;end select
#exit_script
END GO
