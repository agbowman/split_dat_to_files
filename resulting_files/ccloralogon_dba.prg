CREATE PROGRAM ccloralogon:dba
 PAINT
 CALL video(r)
 CALL box(1,1,14,80)
 CALL box(1,1,4,80)
 CALL clear(2,2,78)
 CALL text(02,10,"CCL PROGRAM CCLORALOGON")
 CALL clear(3,2,78)
 CALL text(03,05,"Program to connect to oracle")
 CALL video(n)
 CALL text(06,05,"USER NAME")
 CALL text(08,05,"PASSWORD")
 CALL accept(06,40,"P(30);CU")
 SET p1 = curaccept
 CALL accept(08,40,"P(30);CU")
 SET p2 = curaccept
 CALL clear(1,1)
 FREE DEFINE oraclesystem
 DEFINE oraclesystem concat(trim(p1),"/",trim(p2))
END GO
