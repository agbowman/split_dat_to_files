CREATE PROGRAM bhs_ops_mahie:dba
 FREE RECORD reply
 RECORD reply(
   1 status_data[1]
     2 status = c1
 )
 FREE RECORD m_rec
 RECORD m_rec(
   1 files_in[*]
     2 s_filename = vc
 ) WITH protect
 FREE RECORD bhs_request
 RECORD bhs_request(
   1 person_id = f8
   1 file_name = vc
   1 content_type = vc
   1 name = vc
   1 path = vc
 ) WITH protect
 EXECUTE bhs_hlp_ftp
 EXECUTE bhs_hlp_err
 EXECUTE bhs_hlp_lock
 DECLARE ms_files_in_loc_dir = vc WITH protect, constant(build(logical("bhscust"),"/mahie/in/"))
 DECLARE ms_files_out_loc_dir = vc WITH protect, constant(build(logical("bhscust"),"/mahie/out/"))
 DECLARE ms_files_in_rem_dir = vc WITH protect, constant("/chargereports/mahie/out/cda/")
 DECLARE ms_files_out_rem_dir = vc WITH protect, constant("/chargereports/mahie/archive/")
 DECLARE ms_ftp_host = vc WITH protect, constant("172.17.10.5")
 DECLARE ms_ftp_username = vc WITH protect, constant('"bhs\cisftp"')
 DECLARE ms_ftp_password = vc WITH protect, constant("C!sftp01")
 DECLARE ms_files_in = vc WITH protect, constant("bhs_mahie_files_in.txt")
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ms_dclcom = vc WITH protect, noconstant(" ")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE ms_file_out = vc WITH protect, noconstant(" ")
 DECLARE ms_ftp_cmd = vc WITH protect, noconstant(" ")
 CALL echo(concat("ms_FILES_IN_LOC_DIR: ",ms_files_in_loc_dir))
 CALL echo(concat("ms_FILES_OUT_LOC_DIR: ",ms_files_out_loc_dir))
 CALL echo(concat("ms_FILES_IN_REM_DIR: ",ms_files_in_rem_dir))
 CALL echo(concat("ms_FILES_OUT_REM_DIR: ",ms_files_out_rem_dir))
 SET ms_dclcom = concat("rm -f ",ms_files_in_loc_dir,"*")
 CALL echo(build("DCL:",ms_dclcom))
 CALL dcl(ms_dclcom,size(trim(ms_dclcom)),stat)
 SET ms_ftp_cmd = "mget *.xml*"
 SET stat = bhs_ftp_command(ms_ftp_cmd,ms_ftp_host,ms_ftp_username,ms_ftp_password,
  ms_files_in_loc_dir,
  ms_files_in_rem_dir,"/dev/null"," ")
 SET ms_dclcom = concat("ls -l ",ms_files_in_loc_dir," > ",ms_files_out_loc_dir,ms_files_in)
 CALL echo(build("DCL:",ms_dclcom))
 CALL dcl(ms_dclcom,size(trim(ms_dclcom)),stat)
 IF (bhs_error_thrown(0)=1)
  CALL echo("Error thrown while preparing input files.  Exiting.")
  GO TO exit_script
 ENDIF
 SET logical files_in value(build(ms_files_out_loc_dir,ms_files_in))
 FREE DEFINE rtl2
 DEFINE rtl2 "files_in"
 SELECT INTO "nl:"
  FROM rtl2t r
  WHERE  NOT (r.line IN ("", " ", null))
   AND r.line != "total *"
   AND r.line != "d*"
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   ms_tmp = trim(r.line,3), pl_cnt = (pl_cnt+ 1), stat = alterlist(m_rec->files_in,pl_cnt),
   ml_idx = findstring(" ",ms_tmp,1,1), m_rec->files_in[pl_cnt].s_filename = substring((ml_idx+ 1),(
    textlen(ms_tmp) - ml_idx),ms_tmp)
  FOOT REPORT
   CALL echo(build("Number of files to process:",size(m_rec->files_in,5)))
  WITH nocounter
 ;end select
 IF (bhs_error_thrown(0)=1)
  CALL echo(concat("Error thrown while reading ",ms_files_in,".  Exiting."))
  GO TO exit_script
 ENDIF
 FOR (ml_cnt = 1 TO size(m_rec->files_in,5))
   FOR (x = 1 TO 2)
     IF (x=1)
      SET bhs_request->person_id = 18756768
     ELSE
      SET bhs_request->person_id = 958821
     ENDIF
     SET bhs_request->file_name = m_rec->files_in[ml_cnt].s_filename
     SET bhs_request->content_type = "CCD"
     SET bhs_request->name = concat("CCD Received:",trim(format(sysdate,"dd-mmm-yyyy hh:mm;;d")))
     SET bhs_request->path = ms_files_in_loc_dir
     SET trace = recpersist
     EXECUTE bhs_mmf_store
     SET trace = norecpersist
   ENDFOR
   CALL echo("remove local files")
   SET ms_dclcom = concat("rm -f ",ms_files_in_loc_dir,m_rec->files_in[ml_cnt].s_filename)
   CALL dcl(ms_dclcom,size(trim(ms_dclcom)),stat)
   CALL echo(concat("stat: ",trim(cnvtstring(stat))))
   SET ms_file_out = concat(m_rec->files_in[ml_cnt].s_filename,".archive",trim(format(sysdate,
      "mmddyyhhmmss;;d")))
   CALL echo("move files from in to archive on remote dir")
   SET ms_ftp_cmd = concat("rename ",ms_files_in_rem_dir,m_rec->files_in[ml_cnt].s_filename," ",
    ms_files_out_rem_dir,
    ms_file_out)
   CALL echo(concat("bhs_ftp_command: ",ms_ftp_cmd))
   SET stat = bhs_ftp_command(ms_ftp_cmd,ms_ftp_host,ms_ftp_username,ms_ftp_password," ",
    " ","/dev/null"," ")
   CALL echo(concat("stat: ",trim(cnvtstring(stat))))
   SET stat = initrec(bhs_request)
 ENDFOR
 SET reply->status_data[1].status = "S"
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
