CREATE PROGRAM bhs_fh_put_camm_img:dba
 PROMPT
  "physician username" = "",
  "person id" = 0,
  "File name (w/extension)" = "",
  "File display name" = "",
  "Content Type" = ""
  WITH s_phys_username, f_person_id, s_file_name,
  s_file_disp, s_content_type
 FREE RECORD m_rec
 RECORD m_rec(
   1 msg[1]
     2 f_patient_id = f8
     2 c_status = c1
     2 s_detail = vc
 ) WITH protect
 SET m_rec->msg[1].c_status = "F"
 EXECUTE bhs_check_domain:dba
 EXECUTE bhs_hlp_ccl
 DECLARE ms_phys_username = vc WITH protect, constant(trim(cnvtupper( $S_PHYS_USERNAME)))
 DECLARE mf_person_id = f8 WITH protect, constant(cnvtreal( $F_PERSON_ID))
 DECLARE ms_img_file_name = vc WITH protect, constant(trim(cnvtlower( $S_FILE_NAME)))
 DECLARE ms_img_file_disp = vc WITH protect, constant(trim( $S_FILE_DISP))
 DECLARE ms_file_in_dir = vc WITH protect, constant(build(logical("bhscust"),"/fh/image/in/"))
 DECLARE ms_file_fail_dir = vc WITH protect, constant(build(logical("bhscust"),"/fh/image/fail/"))
 DECLARE ms_content_type = vc WITH protect, noconstant(trim(cnvtupper( $S_CONTENT_TYPE)))
 DECLARE ms_dclcom = vc WITH protect, noconstant(" ")
 DECLARE ms_log = vc WITH protect, noconstant(" ")
 DECLARE mn_stat = i2 WITH protect, noconstant(0)
 DECLARE ms_email = vc WITH protect, noconstant(" ")
 DECLARE mf_phys_id = f8 WITH protect, noconstant(0.0)
 CALL bhs_sbr_log("start","",0,"",0.0,
  "","Image Uploader App","")
 IF (mf_person_id < 1.0)
  SET ms_log = "PERSON ID = 0.0"
  GO TO exit_script
 ENDIF
 CALL echo(concat("ms_FILE_IN_DIR: ",ms_file_in_dir))
 SELECT INTO "nl:"
  FROM person p
  WHERE p.person_id=mf_person_id
   AND p.active_ind=1
  HEAD p.person_id
   m_rec->msg[1].f_patient_id = p.person_id
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SET ms_log = concat("PERSON_ID not found: ",trim(cnvtstring(mf_person_id)))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM prsnl p
  WHERE p.username=ms_phys_username
   AND p.active_ind=1
  DETAIL
   mf_phys_id = p.person_id
  WITH nocounter
 ;end select
 IF (textlen(ms_content_type)=0)
  SET ms_content_type = "PATPIC"
 ENDIF
 CALL bhs_sbr_put_camm_obj(m_rec->msg[1].f_patient_id,0.0,concat(ms_file_in_dir,ms_img_file_name),
  ms_img_file_disp,ms_content_type,
  "image/jpeg")
 SET m_rec->msg[1].c_status = u_bhs_hlp_ccl_reply->status[1].n_status
 SET ms_log = concat(u_bhs_hlp_ccl_reply->status[1].s_detail)
 IF ((m_rec->msg[1].c_status="S"))
  CALL bhs_sbr_log("log","",0,"PERSON_ID",mf_person_id,
   ms_dclcom,"Patient","S")
  CALL bhs_sbr_log("log","",0,"PRSNL_ID",mf_phys_id,
   trim(build2("Username: ",ms_phys_username)),ms_log,"S")
  CALL bhs_sbr_log("log","",0,ms_img_file_disp,0.0,
   trim(build2(ms_file_in_dir,ms_img_file_name)),ms_log,"S")
  CALL bhs_sbr_log("stop","",0,"",0.0,
   "",ms_log,"S")
  CALL echo("delete image from IN dir")
  SET ms_dclcom = concat("rm -f ",ms_file_in_dir,ms_img_file_name)
  CALL dcl(ms_dclcom,textlen(trim(ms_dclcom)),mn_stat)
 ENDIF
#exit_script
 IF ((m_rec->msg[1].c_status != "S"))
  CALL echo("move image to FAIL dir")
  SET ms_dclcom = concat("mv ",ms_file_in_dir,ms_img_file_name," ",ms_file_fail_dir,
   ms_img_file_name)
  CALL dcl(ms_dclcom,textlen(trim(ms_dclcom)),mn_stat)
  CALL bhs_sbr_log("log","",0,"PERSON_ID",mf_person_id,
   ms_dclcom,ms_log,"F")
  CALL bhs_sbr_log("log","",0,"PRSNL_ID",mf_phys_id,
   trim(build2("Username: ",ms_phys_username)),ms_log,"F")
  CALL bhs_sbr_log("log","",0,ms_img_file_disp,0.0,
   trim(build2(ms_file_in_dir,ms_img_file_name)),ms_log,"F")
  CALL bhs_sbr_log("stop","",0,"",0.0,
   "",trim(build2("Reason for failure: ",ms_log)),"F")
  SET ms_email = concat("Image Upload to CAMM failed at CCL level.",char(13),"Domain: ",
   gs_bhs_domain_name,char(13),
   "Dt/Tm: ",trim(format(sysdate,"mm/dd/yy hh:mm;;d")),char(13),char(13),"Log: ",
   ms_log,char(13),char(13),"User: ",ms_phys_username,
   char(13),"Patient ID: ",trim(cnvtstring(m_rec->msg[1].f_patient_id)),char(13),"File In Dir: ",
   ms_file_in_dir,char(13),"Img File Name: ",ms_img_file_name,char(13),
   "Img Disp Name: ",ms_img_file_disp,char(13),"DCL Command: ",ms_dclcom,
   char(13),"Fail Dir: ",ms_file_fail_dir)
  IF (gl_bhs_prod_flag=1)
   CALL uar_send_mail(nullterm("ciscore@bhs.org"),nullterm(concat("Image Uploader Fail ",trim(format(
        sysdate,"mm/dd/yy hh:mm;;d")))),nullterm(ms_email),nullterm("Image Uploader"),1,
    nullterm("IPM.NOTE"))
  ELSE
   CALL uar_send_mail(nullterm("John.SharpeIII@bhs.org"),nullterm(concat("Image Uploader Fail ",trim(
       format(sysdate,"mm/dd/yy hh:mm;;d")))),nullterm(ms_email),nullterm("Image Uploader"),1,
    nullterm("IPM.NOTE"))
  ENDIF
 ENDIF
 SET m_rec->msg[1].s_detail = ms_log
 SET _memory_reply_string = cnvtrectojson(m_rec)
 FREE RECORD m_rec
END GO
