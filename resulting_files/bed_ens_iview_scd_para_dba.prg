CREATE PROGRAM bed_ens_iview_scd_para:dba
 FREE SET reply
 RECORD reply(
   1 file_loaded_ind = i2
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET status = 0
 SET len = 0
 DECLARE ln = vc
 DECLARE fdir = vc
 DECLARE cdir = vc
 SET fdir = logical("CER_INSTALL")
 IF (cursys="AXP")
  SET ln = concat("dir ",trim(fdir),"scd_paragraphs_modifier.csv")
 ELSE
  SET ln = concat("ls ",trim(fdir),"/scd_paragraphs_modifier.csv")
 ENDIF
 SET len = size(ln)
 SET status = 0
 CALL dcl(ln,len,status)
 CALL echo(status)
 SET cdir = logical("CCLUSERDIR")
 IF (cursys="AXP")
  SET ln = concat("copy ",fdir,"scd_paragraphs_modifier.csv ",cdir)
 ELSE
  SET ln = concat("cp -p ",fdir,"/scd_paragraphs_modifier.csv ",cdir,"/")
 ENDIF
 SET len = size(ln)
 SET status = 0
 CALL dcl(ln,len,status)
 CALL echo(status)
 IF (status=0)
  SET fdir = logical("CCLUSERDIR")
  IF (cursys="AXP")
   SET ln = concat("dir ",trim(fdir),"scd_paragraphs_modifier.csv")
  ELSE
   SET ln = concat("ls ",trim(fdir),"/scd_paragraphs_modifier.csv")
  ENDIF
  SET len = size(ln)
  SET status = 0
  CALL dcl(ln,len,status)
  CALL echo(status)
 ENDIF
 IF (status=1)
  IF (cursys="AXP")
   SET ln = concat("@cer_install:scd_para_load paragraphs_modifier")
  ELSE
   SET ln = concat("$cer_install/scd_para_load.ksh paragraphs_modifier")
  ENDIF
  SET len = size(ln)
  SET status = 0
  CALL dcl(ln,len,status)
  CALL echo(status)
 ENDIF
 SELECT INTO "nl:"
  FROM scr_paragraph_type s
  PLAN (s
   WHERE s.cki_identifier="MODIFIER")
  DETAIL
   reply->file_loaded_ind = 1
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
