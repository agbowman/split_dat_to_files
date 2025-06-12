CREATE PROGRAM dm_stat_resendmsa_file:dba
 DECLARE dir_name = vc WITH noconstant("CCLUSERDIR")
 DECLARE msa_file = vc
 DECLARE full_name = vc
 DECLARE err_msg = vc
 DECLARE dclcmd = vc
 DECLARE status = i4
 DECLARE linecnt = i4
 DECLARE position = i4
 DECLARE status_tmp = vc WITH noconstant("status.tmp")
 DECLARE file_names_tmp = vc WITH noconstant("filename.tmp")
 DECLARE msa_status = i2 WITH noconstant(0)
 DECLARE msa_status2 = i2 WITH noconstant(0)
 DECLARE dss_id = f8 WITH noconstant(0.0)
 DECLARE checkmsalogicals(x=vc) = null
 DECLARE promptuser(x=vc) = null
 DECLARE checkinput(x=vc) = null
 DECLARE sendxmlfile(x=vc) = null
 DECLARE updatexmlfile(file_name=vc) = null
 DECLARE deletexmlfile(file_name=vc) = null
 CALL checkmsalogicals("x")
 CALL promptuser("x")
 CALL checkinput("x")
 CALL sendxmlfile("x")
 GO TO exit_program
 SUBROUTINE checkmsalogicals(z)
   IF (logical("MSA_SERVER")=null)
    CALL echo("ERROR: MSA_SERVER logical is not setup")
    SET msa_status = 1
   ENDIF
   IF (logical("CLIENT_MNEMONIC")=null)
    CALL echo("ERROR: CLIENT_MNEMONIC logical is not setup")
    SET msa_status = 1
   ENDIF
   IF (msa_status=1)
    GO TO exit_program
   ENDIF
 END ;Subroutine
 SUBROUTINE promptuser(z)
   SET width = 132
   SET message = window
   CALL clear(1,1)
   CALL text(2,5,"Please enter XML file name: ")
   CALL accept(2,34,"P(50);CU")
   CALL video(b)
   CALL text(4,5,"Processing request.....")
   CALL video(n)
   SET message = nowindow
   SET msa_file = cnvtlower(trim(curaccept,3))
   SET position = 4
 END ;Subroutine
 SUBROUTINE checkinput(z)
  IF (cursys="AIX")
   SET full_name = build(dir_name,"/",msa_file)
  ELSE
   SET full_name = build(dir_name,":",msa_file)
  ENDIF
  IF (findfile(msa_file)=0)
   CALL clear(position,5)
   SET err_msg = concat("ERROR: Cannot find ",full_name)
   CALL echo(err_msg)
   GO TO exit_program
  ENDIF
 END ;Subroutine
 SUBROUTINE sendxmlfile(z)
   IF (cursys="AIX")
    SET dclcmd = concat("$cer_exe/msaclient -file ","$",dir_name,"/",msa_file,
     " | grep 'Status' > ",status_tmp)
   ELSE
    SET dclcmd = concat("pipe mcr cer_exe:msaclient -file ",dir_name,":",msa_file,
     " | search sys$input Status/out = ",
     status_tmp)
   ENDIF
   CALL dcl(dclcmd,size(dclcmd),status)
   CALL clear(position,5)
   IF (status=0)
    SET err_msg = "ERROR: msaclient call failed"
    CALL echo(err_msg)
    GO TO exit_program
   ENDIF
   FREE DEFINE rtl2
   DEFINE rtl2 status_tmp
   SELECT INTO "nl:"
    a.line
    FROM rtl2t a
    DETAIL
     IF (findstring("<Code>0</Code>",trim(a.line)) > 0)
      CALL echo(concat(msa_file," file sent successfully")), msa_status = 1
     ELSE
      msa_status2 = 1
     ENDIF
    WITH nocounter, maxrec = 1
   ;end select
   IF (((msa_status2=1) OR (curqual=0)) )
    CALL echo(concat(msa_file," file was not sent successfully"))
    CALL updatexmlfile(msa_file)
   ENDIF
   IF (msa_status=1)
    CALL deletexmlfile(msa_file)
   ENDIF
 END ;Subroutine
 SUBROUTINE updatexmlfile(file_name)
  SELECT INTO "nl:"
   FROM dm_stat_resend_retry drr
   WHERE drr.file_name=cnvtupper(file_name)
   DETAIL
    dss_id = drr.dm_stat_resend_retry_id
   WITH nocounter
  ;end select
  IF (curqual > 0)
   UPDATE  FROM dm_stat_resend_retry drr
    SET drr.file_name = cnvtupper(file_name), drr.resend_retry_cnt = (drr.resend_retry_cnt+ 1), drr
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     drr.updt_id = reqinfo->updt_id, drr.updt_task = reqinfo->updt_task, drr.updt_applctx = reqinfo->
     updt_applctx,
     drr.updt_cnt = (drr.updt_cnt+ 1)
    WHERE drr.dm_stat_resend_retry_id=dss_id
    WITH nocounter
   ;end update
   COMMIT
   CALL echo(concat(msa_file," was updated in the resend table"))
  ENDIF
 END ;Subroutine
 SUBROUTINE deletexmlfile(file_name)
  SELECT INTO "nl:"
   FROM dm_stat_resend_retry drr
   WHERE drr.file_name=cnvtupper(file_name)
   DETAIL
    dss_id = drr.dm_stat_resend_retry_id
   WITH nocounter
  ;end select
  IF (curqual > 0)
   DELETE  FROM dm_stat_resend_retry drr
    WHERE drr.dm_stat_resend_retry_id=dss_id
   ;end delete
   COMMIT
   CALL echo(concat(msa_file," is deleted from the resend table"))
  ENDIF
 END ;Subroutine
#exit_program
END GO
