# Shell Homework (classes 1 and 2)
	
**1.** Find all rows that include department name «Marketing» and get rid of department name (i.e. pick only name  and phone). Write results in a new file called «marketing_<YESTERDAY>.txt», where YESTERDAY is yesterday‘s date in format YYYY-MM-DD.

**2.** Using files «sample_cut.txt» and «marketing_<YESTERDAY>.txt» Find people (i.e. Names) from file «marketing_<YESTERDAY>.txt» that not work in Marketing department (i.e. not present in «sample_cut.txt»). Put results into the new file called «namesakes_preparation»

**3.** Append to the end of file «namesakes_preparation» a new row with count of the people from file «sample_cut.txt» who has the same name as a person in «namesakes_preparation».

**4.** Rename «namesakes_preparation» to «namesakes.txt»

**Use:**
 - 1 line-commands only ! 
 - pipes «|», redirections «>» and «>>», command substitution.
 - utilities: grep, cat, cut, sed, awk, date 

**Do not use:** bash-scripting! i.e don't use cycles and if-constructions

**Result:**

- 3 files: «marketing_<YESTERDAY>.txt», «namesakes_preparation»,  «namesakes.txt»
- 4 files where you save your commands (each of task 1-4 in separate file). Call them "command_n", where n - task number


