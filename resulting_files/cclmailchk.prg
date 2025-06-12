CREATE PROGRAM cclmailchk
 PROMPT
  "ENTER MAIL TO USER:   " = "*",
  "ENTER MAIL FROM USER: " = curuser
 RANGE OF ml05_1 IS ml05_1
 RANGE OF ml05_2 IS ml05_2
 RANGE OF ml05_3 IS ml05_3
 DEFINE ml
 SELECT
  ml05_1.user_id1, ml05_1.message_type1, ml05_1.message_date1,
  ml05_1.message_time1, ml05_1.qualifier1, ml05_1.sequence_nbr1,
  ml05_1.sender_id2, ml05_1.message_type2, ml05_1.message_date2,
  ml05_1.message_time2, ml05_1.qualifier2, ml05_1.sequence_nbr2,
  ml05_1.user_id3, ml05_1.message_type3, ml05_1.subject3,
  ml05_1.message_date3, ml05_1.message_time3, ml05_1.qualifier3,
  ml05_1.sequence_nbr3, ml05_1.activity_date, ml05_1.activity_time,
  ml05_1.activity_task, ml05_1.activity_status, ml05_1.reviewed_by,
  ml05_1.confidential, ml05_1.screen_attached, ml05_1.type,
  ml05_1.response_req, ml05_1.response_date, ml05_1.response_time,
  ml05_1.response_by, ml05_1.priority, ml05_1.orig_to,
  ml05_1.orig_from, ml05_1.lines_of_data, ml05_1.overflow
  WHERE (ml05_1.user_id1= $1)
   AND (ml05_1.sender_id2= $2)
  WITH check
 ;end select
END GO
