CREATE PROGRAM bhs_test_ftp
 SET node_name = trim(curnode)
 SET domain_name = trim(curdomain)
 SET msg1 = concat(trim("Test ftp from node: "),node_name)
 SET date = trim(format(cnvtdatetime(curdate,curtime),";;q"))
 SET var_output = concat(trim("ftp_test.txt"))
 SELECT INTO value(var_output)
  FROM dummyt
  HEAD REPORT
   msg1
  WITH dio = 00, time = 5
 ;end select
 CALL echo("Send FILES")
 SET filenamein = var_output
 CALL echo(build("fileNameIn =",filenamein))
 SET dclcom = concat("$cust_script/bhs_ftp_file.ksh ",filenamein,
  " 172.17.10.5 'bhs\cisftp' C!sftp01 ciscore/testing")
 SET status = 0
 SET len = size(trim(dclcom))
 CALL dcl(dclcom,len,status)
 CALL echo(status)
 SET stat = remove(var_output)
 CALL echo(dclcom)
END GO
