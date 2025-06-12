CREATE PROGRAM doe_pref_utility:dba
 PAINT
 CALL clear(1,1)
 CALL video(i)
 CALL box(7,1,18,80)
 CALL line(9,1,80,xhor)
 CALL video(l)
 CALL text(8,3,"D O E  P R E F E R E N C E S  U T I L I T Y")
 CALL video(i)
 CALL text(10,2,"This application no longer is available; please use Preference Manager")
 CALL text(11,2,"(PreferenceManager.exe) instead.  To view and change Department Order")
 CALL text(12,2,"Entry settings, navigate to the following location in the Database")
 CALL text(13,2,"View tree: Default > System > Application > DeptOrderEntry >")
 CALL text(14,2,"Application Settings.  Please refer to the CMSG for more information")
 CALL text(15,2,"about Department Order Entry preferences.  An explanation of each")
 CALL text(16,2,"preference also is displayed in Preference Manager.")
 CALL text(20,2," ")
END GO
