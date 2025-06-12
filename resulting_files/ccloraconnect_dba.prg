CREATE PROGRAM ccloraconnect:dba
 RDB select s . inst_id , s . sid , s . serial# , s . process , s . osuser , s . program , s .
 machine , p . spid , p . username from gv$session s , gv$process p where s . paddr = p . addr and s
 . inst_id = p . inst_id order by s . inst_id , s . sid
 END ;Rdb
END GO
