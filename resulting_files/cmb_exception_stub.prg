CREATE PROGRAM cmb_exception_stub
 CALL echorecord(test_cust_script)
 SET dcem_reply->status = "S"
 SET dcem_reply->err_msg = "Maven Test Execution"
END GO
