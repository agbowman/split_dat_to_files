CREATE PROGRAM cclmailread
 PAINT
 DEFINE ml
 SET board = fillstring(20," ")
 SET board_item = fillstring(30," ")
 RANGE OF _m1 IS ml05_1
 RANGE OF _m2 IS ml05_2
 RANGE OF _m3 IS ml05_3
 CALL box(2,1,10,80)
 CALL text(1,10,"CCLMAILREAD Program to read board messages",accept)
 CALL text(3,5,"Board")
 CALL text(5,5,"Subject")
 SET help = "Enter board name to read"
 CALL accept(3,20,"P(20);CU")
 SET board = curaccept
 SET help =
 SELECT INTO "NL:"
  subject = _m1.subject, board = _m1.user_id, replies = _m1.nbr_replies
  WHERE _m1.message_type="B"
   AND _m1.user_id=board
   AND _m1.qualifier=01
  WITH counter
 ;end select
 CALL accept(5,20,"P(30);CUF")
 SET board_item = curaccept
 SELECT
  _m1.sender_id2, _m1.message_date2, _m1.message_time2,
  _m3.message_line, grp = concat(_m1.sender_id2,format(_m1.message_date2,"######;RP0"),format(_m1
    .message_time2,"######;RP0"))
  WHERE _m1.message_type3 IN ("A", "B")
   AND _m1.subject3=board_item
   AND _m1.user_id3=board
   AND _m3.message_line != " "
  HEAD REPORT
   line = fillstring(100,"=")
  HEAD grp
   "Date: ", _m1.message_date2, col + 5,
   "Time: ", _m1.message_time2, col + 5,
   "Message: ", _m1.sender_id2, row + 1,
   line, row + 1
  DETAIL
   _m3.message_line, row + 1
  WITH nocounter
 ;end select
 FREE DEFINE ml
END GO
