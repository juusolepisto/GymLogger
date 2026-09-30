# Workbook data

`workout_program.json` contains the 12 weeks and four weekly workouts from
`Min-Max_Phase_2_-_4x.xlsx` (sheet `4x Per Week`, supplied by the user).
Exercise and substitution URLs are copied from the workbook hyperlinks.

`workout_program_5x.json` contains the 12 weeks and five weekly workouts from
`Min-Max_Phase_2_-_5x.xlsx` (sheet `5x Per Week`). This includes the separate Arms
day and the five-day plan's own exercise distribution. Empty substitution options
are omitted.

Consecutive rows for the same exercise are combined while retaining each work
set's rep target and RIR. Warm-ups are displayed only as a prescribed set count
or range. Their original data rows remain to preserve saved work-set indices,
but do not have input fields. Excel date serials
in the warm-up and rep-range columns are decoded as month-day ranges (for example,
46056 becomes 2-3, and 46118 becomes 4-6).

The app does not modify this prescription when sets are logged. Draft weights,
reps, logged sets, and workout completion are saved automatically to
`progress.json` in the device's private application-support directory. No cloud
database or account is used. A previous snapshot is retained locally for recovery.
Save failures are shown with a retry action; unreadable saves are preserved.

Work sets count as logged automatically when weight is a finite number at least
zero and reps are a positive integer. Clearing or invalidating either value makes
the set incomplete again. This also applies to previously saved entries regardless
of their old manual log flag. Enter all work sets, then tap Finish workout.
Warm-ups do not affect completion.
All four or five workouts in the selected plan complete the week and advance it to
the first unfinished week. Reopen workout allows corrections without clearing
set entries. Completing week 12 ends the program; no week 13 is created.

The home-screen selector saves the chosen frequency locally. Each plan keeps
independent set entries, completion, and current-week progress. Version-one saves
are read as four-day progress and upgraded to version two on the next save.

Local progress survives app restarts. Clearing the app's data or uninstalling it
can remove these files. Exercise videos still open external links.
