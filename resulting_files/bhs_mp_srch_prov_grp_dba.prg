CREATE PROGRAM bhs_mp_srch_prov_grp:dba
 PROMPT
  "Search term" = "",
  "Provider group name key" = "CHMP"
  WITH s_search_term, s_provdr_grp_name_key
 FREE RECORD data
 RECORD data(
   1 cnt = i4
   1 grp_id = f8
   1 grp_name = vc
   1 grp_class = vc
   1 members[*]
     2 person_id = f8
     2 name_first = vc
     2 name_last = vc
     2 name_full_formatted = vc
     2 username = vc
 ) WITH protect
 DECLARE mf_provider_group_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",19189,
   "PROVIDERGROUP"))
 DECLARE ms_search_term = vc WITH protect, constant(cnvtlower(trim( $S_SEARCH_TERM,3)))
 DECLARE ms_group_name_key = vc WITH protect
 IF (cnvtupper(trim( $S_PROVDR_GRP_NAME_KEY,3)) IN ("HOSPITALIST", "RESIDENT"))
  SET ms_group_name_key = "CHMP"
 ELSEIF (cnvtupper(trim( $S_PROVDR_GRP_NAME_KEY,3)) IN ("NOBLEHOSPITALIST"))
  SET ms_group_name_key = "NOBLE HOSPITAL MEDICINE"
 ENDIF
 IF (cnvtupper(trim( $S_PROVDR_GRP_NAME_KEY,3)) IN ("HOSPITALIST", "RESIDENT", "NOBLEHOSPITALIST"))
  SELECT INTO "nl:"
   FROM prsnl_group pg,
    prsnl_group_reltn pgr,
    prsnl p
   PLAN (pg
    WHERE pg.active_ind=1
     AND pg.prsnl_group_class_cd=mf_provider_group_cd
     AND pg.prsnl_group_name_key=ms_group_name_key)
    JOIN (pgr
    WHERE pgr.active_ind=1
     AND pg.prsnl_group_id=pgr.prsnl_group_id)
    JOIN (p
    WHERE p.active_ind=1
     AND pgr.person_id=p.person_id
     AND cnvtlower(p.name_full_formatted)=patstring(ms_search_term))
   ORDER BY pg.prsnl_group_name, p.person_id, p.name_full_formatted
   HEAD REPORT
    data->cnt = 0, data->grp_name = trim(pg.prsnl_group_name,3), data->grp_id = pg.prsnl_group_id,
    data->grp_class = trim(uar_get_code_display(pg.prsnl_group_class_cd),3)
   HEAD p.person_id
    data->cnt += 1
    IF (mod(data->cnt,100)=1)
     stat = alterlist(data->members,(data->cnt+ 99))
    ENDIF
    data->members[data->cnt].person_id = p.person_id, data->members[data->cnt].name_first = trim(p
     .name_first), data->members[data->cnt].name_last = trim(p.name_last),
    data->members[data->cnt].name_full_formatted = trim(p.name_full_formatted), data->members[data->
    cnt].username = trim(p.username,3)
   FOOT REPORT
    stat = alterlist(data->members,data->cnt)
   WITH nocounter
  ;end select
 ELSEIF (cnvtupper(trim( $S_PROVDR_GRP_NAME_KEY,3)) IN ("PEDIHOSPITALIST"))
  SELECT INTO "NL:"
   FROM prsnl p,
    code_value cv
   PLAN (p
    WHERE p.active_ind=1
     AND p.active_status_cd=188
     AND cnvtupper(p.username)="EN*"
     AND cnvtlower(p.name_full_formatted)=patstring(ms_search_term)
     AND p.physician_ind=1)
    JOIN (cv
    WHERE cv.code_value=p.position_cd
     AND cv.active_ind=1
     AND cv.display_key IN ("BHSASSOCIATEPROFESSIONAL", "BHSCARDIACSURGERYMD", "BHSCARDIOLOGYMD",
    "BHSCRITICALCAREMD", "BHSEDMEDICINEMD",
    "BHSGIMD", "BHSGENERALPEDIATRICSMD", "BHSGENERALSURGERYMD", "BHSHOSPITALMEDICINE",
    "BHSINFECTIOUSDISEASEMD",
    "BHSMIDWIFE", "BHSNEONATALMD", "BHSOBRESIDENT", "BHSOBGYNMD", "BHSONCOLOGYMD",
    "BHSORTHOPEDICSMD", "BHSPCOASSOCIATEPROFESSIONAL", "BHSPHYSICIANGENERALMEDICINE",
    "BHSPHYSICIANNEUROLOGY", "BHSPHYSICIANGENERALSURGERY",
    "BHSPRIMARYCAREPHYSICIAN", "BHSPSYCHIATRYMD", "BHSPULMONARYMD", "BHSRADRESIDENT",
    "BHSRADIOLOGYMD",
    "BHSRENALMD", "BHSRESIDENT", "BHSTHORACICMD", "BHSPHYSICIANHOSPITALMEDICINE",
    "BHSPHYSICIANPRIMARYCARE"))
   ORDER BY p.person_id
   HEAD REPORT
    data->cnt = 0
   HEAD p.person_id
    data->cnt += 1
    IF (mod(data->cnt,100)=1)
     stat = alterlist(data->members,(data->cnt+ 99))
    ENDIF
    data->members[data->cnt].person_id = p.person_id, data->members[data->cnt].name_first = trim(p
     .name_first), data->members[data->cnt].name_last = trim(p.name_last),
    data->members[data->cnt].name_full_formatted = trim(p.name_full_formatted), data->members[data->
    cnt].username = trim(p.username,3)
   FOOT REPORT
    stat = alterlist(data->members,data->cnt)
   WITH nocounter
  ;end select
 ENDIF
 SET _memory_reply_string = cnvtrectojson(data,2,1)
#exit_program
 CALL echo(_memory_reply_string)
END GO
