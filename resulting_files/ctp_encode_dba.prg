CREATE PROGRAM ctp_encode:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Operation (ENCODE / DECODE)" = "",
  "File" = ""
  WITH outdev, operation, file
 SUBROUTINE (OS::uuencode(source=vc,target=vc) =i2 WITH protect)
   DECLARE cmd = vc WITH protect, noconstant(" ")
   DECLARE status = i2 WITH protect, noconstant(- (1))
   DECLARE cmd_len = i4 WITH protect, noconstant(0)
   SET cmd = concat("uuencode '",trim(source,3),"' '",trim(source,3),"'")
   SET cmd = concat(cmd," > '",trim(target,3),"'")
   SET cmd_len = size(cmd)
   SET stat = dcl(cmd,cmd_len,status)
   IF (stat != 1)
    RETURN(fail)
   ELSE
    RETURN(success)
   ENDIF
 END ;Subroutine
 SUBROUTINE (OS::uudecode(source=vc) =i2 WITH protect)
   DECLARE cmd = vc WITH protect, noconstant(" ")
   DECLARE status = i2 WITH protect, noconstant(- (1))
   DECLARE cmd_len = i4 WITH protect, noconstant(0)
   SET cmd = "cd $cer_temp"
   SET cmd = concat(cmd,lf,"uudecode '",trim(source,3),"'")
   SET cmd_len = size(cmd)
   SET stat = dcl(cmd,cmd_len,status)
   IF (stat != 1)
    RETURN(fail)
   ELSE
    RETURN(success)
   ENDIF
 END ;Subroutine
 SUBROUTINE (OS::copy(source=vc,target=vc) =i2 WITH protect)
   DECLARE cmd = vc WITH protect, noconstant(" ")
   DECLARE status = i2 WITH protect, noconstant(- (1))
   DECLARE cmd_len = i4 WITH protect, noconstant(0)
   SET cmd = concat("cp '",trim(source,3),"' '",trim(target,3),"'")
   SET stat = dcl(cmd,size(cmd),status)
   IF (stat != 1)
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE (OS::move(source=vc,target=vc) =i2 WITH protect)
   DECLARE cmd = vc WITH protect, noconstant(" ")
   DECLARE status = i2 WITH protect, noconstant(- (1))
   DECLARE cmd_len = i4 WITH protect, noconstant(0)
   SET cmd = concat("mv '",trim(source,3),"' '",trim(target,3),"'")
   SET stat = dcl(cmd,size(cmd),status)
   IF (stat != 1)
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE (findfile2(file_name=vc) =i2 WITH protect)
   IF (size(trim(file_name))=0)
    RETURN(0)
   ELSE
    RETURN(findfile(file_name))
   ENDIF
 END ;Subroutine
 SUBROUTINE (parsefilename(source=vc) =vc WITH protect)
   DECLARE path_delimiter = c1 WITH protect, constant("/")
   DECLARE env_logical = vc WITH protect, noconstant(" ")
   DECLARE target = vc WITH protect, noconstant(" ")
   DECLARE pos = i4 WITH protect, noconstant(0)
   IF (findstring(":",source) > 0)
    SET pos = findstring(":",source)
    SET env_logical = trim(substring(1,(pos - 1),source),3)
    SET target = trim(substring((pos+ 1),size(source),source),3)
    SET target = build(logical(env_logical),path_delimiter,target)
   ELSEIF (findstring(path_delimiter,source) > 0)
    SET target = trim(source,3)
   ELSEIF (size(trim(source)) > 0)
    SET target = build(logical("cer_temp"),path_delimiter,source)
   ELSE
    SET target = build(logical("cer_temp"),path_delimiter,source)
   ENDIF
   RETURN(target)
 END ;Subroutine
 DECLARE generatefileid(null) = vc WITH protect
 SUBROUTINE generatefileid(null)
   DECLARE file_id = vc WITH protect, noconstant(" ")
   SET file_id = build(format(cnvtdatetime(systimestamp),"HHMMSSCC;3;m"),currdbhandle)
   RETURN(file_id)
 END ;Subroutine
 DECLARE writeoutput(content=vc) = null WITH protect
 SUBROUTINE writeoutdev(content)
   RECORD outdev(
     1 file_desc = i4
     1 file_name = vc
     1 file_buf = vc
     1 file_dir = i4
     1 file_offset = i4
   ) WITH protect
   SET outdev->file_name =  $OUTDEV
   SET outdev->file_buf = "w"
   SET stat = cclio("OPEN",outdev)
   SET outdev->file_buf = concat("Node: ",curnode,fillstring(2,lf))
   SET stat = cclio("WRITE",outdev)
   SET outdev->file_buf = content
   SET stat = cclio("WRITE",outdev)
   SET stat = cclio("CLOSE",outdev)
 END ;Subroutine
 DECLARE success = i2 WITH protect, constant(1)
 DECLARE fail = i2 WITH protect, constant(0)
 DECLARE error_header = vc WITH protect, constant(">>>>ERROR<<<<")
 DECLARE lf = c1 WITH protect, constant(char(10))
 DECLARE decode = vc WITH protect, constant("DECODE")
 DECLARE encode = vc WITH protect, constant("ENCODE")
 DECLARE file_name = vc WITH protect, noconstant(" ")
 SET file_name = parsefilename( $FILE)
 IF (findfile2(file_name) != 1)
  CALL writeoutdev(concat(error_header,lf,"Could not find/open: ",file_name))
  GO TO exit_script
 ENDIF
 CASE (trim(cnvtupper( $OPERATION),3))
  OF decode:
   CALL decode(file_name)
  OF encode:
   CALL encode(file_name)
  ELSE
   CALL writeoutdev(concat(error_header,lf,"Unknown OPERATION"))
 ENDCASE
#exit_script
 SUBROUTINE (encode(binary_source=vc) =null WITH protect)
   DECLARE status = i2 WITH protect, noconstant(0)
   DECLARE encoded_target = vc WITH protect, noconstant(" ")
   SET encoded_target = build(logical("cer_temp"),"/ctpuue",generatefileid(0),".txt")
   SET status = OS::uuencode(binary_source,encoded_target)
   IF (status=success)
    CALL OS::copy(encoded_target, $OUTDEV)
   ELSE
    CALL writeoutdev(concat(error_header,lf,"Failed to ENCODE"))
   ENDIF
 END ;Subroutine
 SUBROUTINE (decode(encoded_source=vc) =null WITH protect)
   DECLARE status = i2 WITH protect, noconstant(0)
   SET status = OS::uudecode(encoded_source)
   IF (status=success)
    CALL writeoutdev("File DECODED")
   ELSE
    CALL writeoutdev(concat(error_header,lf,"Failed to DECODE"))
   ENDIF
 END ;Subroutine
#abort
END GO
