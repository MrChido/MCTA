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