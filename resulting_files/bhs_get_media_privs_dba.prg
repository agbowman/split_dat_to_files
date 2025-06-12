CREATE PROGRAM bhs_get_media_privs:dba
 PROMPT
  "Enter username: " = ""
  WITH s_username
 FREE RECORD m_rec
 RECORD m_rec(
   1 s_msg = vc
   1 c_status = c1
   1 s_userid = vc
   1 s_userfirstname = vc
   1 s_userlastname = vc
   1 folders[*]
     2 s_folder = vc
     2 s_description = vc
 ) WITH protect
 DECLARE mf_addmediapriv_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6016,"ADDMEDIA"))
 DECLARE mf_prsnl_id = f8 WITH protect, noconstant(0.00)
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_knt = i4 WITH protect, noconstant(0)
 DECLARE mn_any_ind = i2 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM prsnl pr
  PLAN (pr
   WHERE (pr.username= $S_USERNAME)
    AND pr.active_ind=1
    AND pr.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
  HEAD REPORT
   mf_prsnl_id = pr.person_id, m_rec->s_userid = trim(pr.username), m_rec->s_userfirstname = trim(pr
    .name_first),
   m_rec->s_userlastname = trim(pr.name_last), m_rec->s_msg =
   "User does not have Add Media privileges", m_rec->c_status = "E"
  WITH nocounter
 ;end select
 CALL echo(build2("mf_prsnl_id: ",build(cnvtint(mf_prsnl_id))))
 IF (mf_prsnl_id=0.00)
  SET m_rec->s_msg = "User name invalid"
  SET m_rec->c_status = "E"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM prsnl pr,
   priv_loc_reltn plr,
   privilege p,
   privilege_exception pe,
   dms_content_type dct
  PLAN (pr
   WHERE pr.person_id=mf_prsnl_id)
   JOIN (plr
   WHERE ((plr.person_id=pr.person_id
    AND plr.position_cd=0.00) OR (plr.position_cd=pr.position_cd
    AND plr.person_id=0.00))
    AND plr.active_ind=1
    AND plr.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
   JOIN (p
   WHERE p.priv_loc_reltn_id=plr.priv_loc_reltn_id
    AND p.privilege_cd IN (mf_addmediapriv_cd)
    AND p.active_ind=1)
   JOIN (pe
   WHERE (pe.privilege_id= Outerjoin(p.privilege_id))
    AND (pe.active_ind= Outerjoin(1)) )
   JOIN (dct
   WHERE (dct.dms_content_type_id= Outerjoin(pe.exception_id))
    AND (dct.active_ind= Outerjoin(1)) )
  ORDER BY plr.person_id DESC, dct.content_type_key, dct.description
  HEAD REPORT
   ml_knt = 0, mn_any_ind = 0
   IF (uar_get_code_display(p.priv_value_cd)="Yes")
    m_rec->s_msg = "", m_rec->c_status = "S", mn_any_ind = 1
   ELSEIF (uar_get_code_display(p.priv_value_cd) != "No")
    m_rec->s_msg = "", m_rec->c_status = "S", mn_any_ind = 0
   ENDIF
  HEAD plr.person_id
   null
  HEAD dct.content_type_key
   null
  HEAD dct.description
   IF (pe.privilege_exception_id > 0.00)
    ml_knt += 1, p0 = alterlist(m_rec->folders,ml_knt), m_rec->folders[ml_knt].s_folder = trim(dct
     .content_type_key),
    m_rec->folders[ml_knt].s_description = trim(dct.display)
   ENDIF
  WITH nocounter
 ;end select
 IF (mn_any_ind=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dms_content_type dct
  PLAN (dct
   WHERE dct.dms_content_type_id > 0.00
    AND dct.active_ind=1
    AND dct.cerner_ind=0
    AND dct.access_flag=3)
  ORDER BY cnvtupper(dct.display)
  HEAD REPORT
   ml_knt = 0
  DETAIL
   ml_knt += 1, p0 = alterlist(m_rec->folders,ml_knt), m_rec->folders[ml_knt].s_folder = trim(dct
    .content_type_key),
   m_rec->folders[ml_knt].s_description = trim(dct.display)
  WITH nocounter
 ;end select
#exit_script
 SET ms_tmp = cnvtrectojson(m_rec)
 SET ml_pos = (findstring(":",ms_tmp)+ 1)
 SET ms_tmp = substring(ml_pos,(textlen(ms_tmp) - ml_pos),ms_tmp)
 SET _memory_reply_string = ms_tmp
 CALL echo(_memory_reply_string)
 FREE RECORD m_rec
END GO
