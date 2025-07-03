This is Caleb's Readme file.
This app, Melzers Condtion Tracking App (better name pending)
Is a project to not only showcase my skills as a software designer
but to also aid My wife and others in tracking their physical condition on their phones.

This app is intended to track the following
Fatuige
Pain tollerance
wake and sleep hours
blood sugar levels (single point per entry)
meals and medications consumed
Activites performed

all entries are stored in a localy placed database, where ever this app is located

There is a review feature but is currently limited to individual dates, at this time a export feture is planned but not implemented

Planed Project completion for initial state is end of the summer. 
App testing and tweaking planned for the fall season.
Submition for Google Play planned at the end of the year.

Development timeline:

May 2025:
App creation started

June 2025:
New build documented on github, .gitignore and cleanups performed, dates look more like a calendar form, still tending to the app/database connection, adjusting the calendar date positions to relate to the shown month.
Shifted the database query point to the 'timestamp' collumn and away from 'day' column. a quirk in the Review entries button was discovered.
Fixed the carryover from the review mode button. It was retaining a state as months were changed, implemented an auto shut off for review mode when chaning dates. Implemented a way to select a particular month and year instead of having to cycle months. Also created a gradient "path" from one designated color to another, so as the number of entries are made on days, the richer the next color becomes. Also affected the flare icon for 10+ entries, now the flare is almost twice the size and retains the yellow color that is underneath, It is a good contrast against the review indigo color as well.
Also changed the privacy setting fo the app on github to private. Since this is a peice that has a significant meaning, I need to protect it. visiblity is granted only by request untill i have made a full release of the program.
Made the Month and Year, an opperable element alowing a user to select month and year without having to cycle through months. Quite a useful feature if it is needed.

July 2025
7/3 Did some major restructuring of the project code, the Main.dart file was getting to heavy so the things like color control and the bulk of the calendarWidget got moved to their own file structure.
The Flare Icon that the user will see, emerges at 10 datapoints but as more entries are placec beyond 10 the larger that Flare Icon will grow. This signifies not only tie importance and urgency of the date, but in the event that there are a string of days with litteraly flare ups, you can visualy see which was the worse day. In talking with the wife/client, a end of the month review was discussed. at this point, a monthly review of the 3 most prevelant symptoms would be a good idea. We will see how we will implement that after establishing the review display. 