CREATE PROGRAM dm_chg_dm_info:dba
 PAINT
 CALL text(1,1,"***********************************************")
 CALL text(2,1,"******* UPDATE NEXT SCHEMA REFRESH DATE *******")
 CALL text(3,1,"***********************************************")
#prev_last_date
 SET prev_last_datex = fillstring(11," ")
 SET prev_last_date = cnvtdatetime(prev_last_datex)
 CALL text(5,1,"Previous Last Schema Refresh Date: ")
 SELECT INTO "nl:"
  di.info_date
  FROM dm_info di
  WHERE di.info_name="LAST SCHEMA REFRESH"
  DETAIL
   prev_last_date = di.info_date
  WITH nocounter
 ;end select
 IF (curqual=1)
  SET prev_last_datex = format(prev_last_date,"DD-MMM-YYYY;;D")
  CALL text(5,36,prev_last_datex)
 ELSE
  CALL text(5,36,prev_last_datex)
 ENDIF
#prev_next_date
 SET prev_next_datex = fillstring(11," ")
 SET prev_next_date = cnvtdatetime(prev_next_datex)
 CALL text(6,1,"Previous Next Schema Refresh Date: ")
 SELECT INTO "nl:"
  di.info_date
  FROM dm_info di
  WHERE di.info_name="NEXT SCHEMA REFRESH"
  DETAIL
   prev_next_date = di.info_date
  WITH nocounter
 ;end select
 IF (curqual=1)
  SET prev_next_datex = format(prev_next_date,"DD-MMM-YYYY;;D")
  CALL text(6,36,prev_next_datex)
 ELSE
  CALL text(6,36,prev_next_datex)
 ENDIF
#last_date
 SET last_datex = fillstring(11," ")
 SET last_date = cnvtdatetime(last_datex)
 CALL text(9,1,"New Last Schema Refresh Date: ")
 SELECT INTO "nl:"
  di.info_date
  FROM dm_info di
  WHERE di.info_name="NEXT SCHEMA REFRESH"
  DETAIL
   last_date = di.info_date
  WITH nocounter
 ;end select
 IF (curqual=1)
  SET last_datex = format(last_date,"DD-MMM-YYYY;;D")
  CALL text(9,36,last_datex)
 ELSE
  CALL text(9,36,last_datex)
 ENDIF
#next_date
 SET next_datex = fillstring(11," ")
 SET next_date = cnvtdatetime(last_datex)
 CALL text(10,1,"Enter Next Schema Refresh Date: ")
 CALL accept(10,36,"p(11);cu")
 IF (((curaccept="") OR (curaccept=" ")) )
  GO TO next_date
 ELSE
  SET next_datex = curaccept
  SET next_date = cnvtdatetime(next_datex)
 ENDIF
 UPDATE  FROM dm_info
  SET info_date = cnvtdatetime(last_date)
  WHERE info_name="LAST SCHEMA REFRESH"
  WITH nocounter
 ;end update
 UPDATE  FROM dm_info
  SET info_date = cnvtdatetime(next_date)
  WHERE info_name="NEXT SCHEMA REFRESH"
  WITH nocounter
 ;end update
 COMMIT
END GO
