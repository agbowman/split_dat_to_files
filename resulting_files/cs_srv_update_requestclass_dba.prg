CREATE PROGRAM cs_srv_update_requestclass:dba
 UPDATE  FROM request
  SET requestclass = 0
  WHERE request_number=951093
  WITH nocounter
 ;end update
END GO
