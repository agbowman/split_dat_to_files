CREATE PROGRAM ams_secure_ftp_put_file:dba
 PROMPT
  "Enter file name to upload to ftp3.cerner.com:" = ""
  WITH file
 DECLARE putfile(commandstr=vc) = i2 WITH protect
 DECLARE quote_str = c1 WITH protect, constant('"')
 DECLARE file_name = vc WITH protect, constant(trim( $FILE))
 DECLARE local_dir = vc WITH protect, constant(trim(logical("CCLUSERDIR")))
 DECLARE remote_host = vc WITH protect, constant("svcamsupload@ftp3.cerner.com")
 DECLARE ssh_key_file = vc WITH protect, constant("ams_key.txt")
 DECLARE script_name = c23 WITH protect, constant("AMS_SECURE_FTP_PUT_FILE")
 DECLARE last_mod = vc WITH protect
 DECLARE dclcom = vc WITH protect
 DECLARE statusmsg = vc WITH protect
 DECLARE retstat = i4 WITH protect
 DECLARE dclstatus = i4 WITH protect
 DECLARE ssh_key = vc WITH protect, constant(concat("-----BEGIN RSA PRIVATE KEY-----",char(10),
   "MIIEoQIBAAKCAQEAz3LbRqRiwd1iNobJQWoAxgOzMUpoR8CNMUY2NFniUXBBA45z",char(10),
   "peQgR2gY8W46mYpL3D/wFtKbOc3fJ8eHQxSr+bNjgsTssebvYbT2zc0/JFccZirV",
   char(10),"HabnEQP2Pvaep8DpGrubz4TTJcEP0DRYLFPMn5XqXn8F+ZiT/PkRDBtdWLhgVI0K",char(10),
   "7Hpw+McMqQGArHF6U7iT4yC6sHUjwNXYoKuKNpKk99GHmCL2a+E6Qg+1Ck6faEkq",char(10),
   "g0cc8+W+Xz/ZaYrKn2s5Nb7UG0TAdm7Zm5EvI2razeE/yUn31L2kZF1Fh4UgLQeQ",char(10),
   "MXdl/3MtsiNLtJcpkg6xab/2M+CXWTKodqCd/QIBIwKCAQBNDWdjYaEGLagi4Zs1",char(10),
   "jcXF5B38XXcwl/ntuv4ws6vVGxDVb2zIlo+lfm+qIaC8r7XG1et2MPfTpDzxhJ/0",
   char(10),"WCKekxZVJJJt9rCvQzcZPZscIFsBYF3JL10jk8Hc30I+Tvd+9TnfXTh7vLy7DCDA",char(10),
   "Ad5J5znLU8BkBXjLrPe0Cin8YRInwtTeZ/zFVgkdKFYth0idW2VbNTB/OVT3CSNv",char(10),
   "jRaZOeGj2YbDEHK3tOLrbjQPD1ZokT3BLOuQCNItgBfb+ZQH3pbLkBBZzAIlNOU7",char(10),
   "/HdcgRVBXeb5jZLK/2tFFRSlPMTh7K7qd9vYsGkGWpYU/lwMFjaGGbg6IDfKuaD/",char(10),
   "izaPAoGBAOsQBYIKita/PtZ5BnnEQISX9K6TZFGE75CE5nQ2Ns2SDZGvc3H9IUGG",
   char(10),"SOKSu+c7Vvc81saVZzEjDdr1vBfL7i8XTZu41xAoq6y8A7H/uwdkGSt4n5dUhsa4",char(10),
   "wTH4kkqUAx5lEkM0uToy+oj0miMjtzFYxctYW3dQWBplu/RSR6sPAoGBAOHtLDgU",char(10),
   "/wVhUc7herxtnVmd9TbkBdLosCSi1snvW1hqcxZAduXcmlioOy/TA7fNzl0R61s0",char(10),
   "jl3qmME9yG2v1UgQd5FY2g4Uh4QbK4Ncy/oVCdiRk50P90Nvm4yxzU02o1Isn3YP",char(10),
   "VBb7Ozs2RoDOgey2SCvjbgUL9quqR9tM9dYzAoGAFCXx1/JGai2mTOXNWuTvllYq",
   char(10),"6mRnrzdHu+4iYbuBCk5Y7zrso17W9vzhrQVDTlWLHIGOwJB2jy7j7jJR82lATS3i",char(10),
   "FKlxhQrM4uuLScV2blkJeMEyQCvRCbgQj0ExHFXUYbDkTudDE534N5/v9GIlpSTd",char(10),
   "wPjx5afNCZOxBlAyB1kCgYB6pVKE2DKrJjO5cxa+D56PvCYH2t6XEJoihEi2w8Pf",char(10),
   "ij55yzk69BlGEi7CMLjgH0Qj5Sf+T7r/yH7PTWzN1HsYfffD7me+gCxPB29kkXYL",char(10),
   "aoGwFINVQy51ELOG5C2e8cZfzxS8briewuWjzQGzo03YRbImdCXIObHK52jWInbT",
   char(10),"XQKBgQC/2KkdI9kq1F1YVigPvgEu+W/ssqHuOyMut5xDsQOHq236w4KENHcKJoN5",char(10),
   "/4A5H+LCXMOaOyBdHrrQv2Xw/P/Z/Lmdds13PeqAgE9zyRtGJZI2DTtHAGeh2eMc",char(10),
   "WFPfp5YdOosorp/GLOLrnGWJOtQsMRbSEEK8FneM0e6AEgXWhQ==",char(10),"-----END RSA PRIVATE KEY-----"))
 SET trace = nocallecho
 EXECUTE ams_define_toolkit_common
 SET trace = callecho
 IF (validate(request->batch_selection,"-1")="-1")
  IF ( NOT (validate(reply,0)))
   RECORD reply(
     1 ops_event = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
  ENDIF
 ENDIF
 SET statusmsg = "Error executing script"
 SET reply->status_data.status = "F"
 SET reply->ops_event = statusmsg
 IF (file_name=null)
  SET statusmsg = "Error: You must specify the filename"
  SET reply->status_data.status = "F"
  SET reply->ops_event = statusmsg
  RETURN
 ENDIF
 SELECT INTO value(ssh_key_file)
  FROM dummyt d
  DETAIL
   col 0, ssh_key
  WITH nocounter, maxcol = 2000
 ;end select
 SET dclcom = build2("chmod 400 ",ssh_key_file)
 SET retstat = dcl(dclcom,textlen(dclcom),dclstatus)
 IF (((retstat != 1) OR (dclstatus != 1)) )
  SET statusmsg = trim(substring(1,100,build2("Error setting read/write permissions on ",ssh_key_file
     )))
  SET reply->status_data.status = "F"
  SET reply->ops_event = statusmsg
  RETURN
 ENDIF
 IF (cursys="AIX")
  SET dclcom = build2("printf ",quote_str,"rm ",file_name,"\nput ",
   file_name,"\nquit",quote_str," | sftp -oPreferredAuthentications=publickey ",
   " -o StrictHostKeyChecking=no ",
   "-oIdentityFile=",ssh_key_file," ",remote_host)
  IF (putfile(dclcom)=1)
   SET reply->status_data.status = "S"
   SET reply->ops_event = statusmsg
  ELSE
   SET reply->status_data.status = "F"
   SET reply->ops_event = statusmsg
  ENDIF
 ELSE
  SET statusmsg = "Script does not support VMS"
  SET reply->status_data.status = "F"
  SET reply->ops_event = statusmsg
 ENDIF
 SET stat = remove(ssh_key_file)
 SET trace = nocallecho
 CALL updtdminfo(script_name,1.0)
 SET trace = callecho
 CALL echo(statusmsg)
 SUBROUTINE putfile(commandstr)
   IF (findfile(file_name))
    SET retstat = dcl(commandstr,textlen(commandstr),dclstatus)
    IF (retstat=1
     AND dclstatus=1)
     SET statusmsg = trim(substring(1,100,build2("Successfully transferred ",file_name,
        " to the AMSImports folder on ftp3.cerner.com")))
     RETURN(1)
    ELSE
     SET statusmsg = trim(substring(1,100,build2("Error transferring ",file_name)))
     RETURN(0)
    ENDIF
   ELSE
    SET statusmsg = build2("File to transfer does not exist: ",file_name)
    RETURN(0)
   ENDIF
 END ;Subroutine
 SET last_mod = "010"
END GO
