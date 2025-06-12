CREATE PROGRAM ccl_uuidtest
 PROMPT
  "Enter # of UUIDs to generate: " = 10
 EXECUTE ccluarxrtl
 DECLARE uuid1 = c36
 DECLARE uuid2 = c36
 DECLARE uuid1upper = c36
 DECLARE uuidnamespace1 = c36
 DECLARE uuidnamespace2 = c36
 DECLARE nidx = i4
 DECLARE nuuids = i4
 SET nuuids =  $1
 CALL echo(concat("UUID count= ",build(nuuids)))
 CALL echo("**** Begin uar_CreateUUID *****")
 FOR (nidx = 1 TO nuuids)
   SET uuid1 = uar_createuuid(0)
   CALL echo(concat("UAR_CREATE_UUID#1 ",uuid1))
   SET uuid2 = uar_createuuid(0)
   CALL echo(concat("UAR_CREATE_UUID#2 ",uuid2))
 ENDFOR
 CALL echo("**** Begin uar_CreateUUIDfromName *****")
 SET uuidnamespace1 = uuid1
 SET uuidnamespace2 = cnvtupper(uuid2)
 FOR (nidx = 1 TO nuuids)
   SET uuid1 = uar_createuuidfromname(uuidnamespace1,"www.widgets.com")
   CALL echo(concat("UAR_CREATE_UUID_FROM_NAME#1: ",uuid1))
   SET uuid2 = uar_createuuidfromname(uuidnamespace2,"www.widgets.com")
   CALL echo(concat("UAR_CREATE_UUID_FROM_NAME#2: ",uuid2))
 ENDFOR
END GO
