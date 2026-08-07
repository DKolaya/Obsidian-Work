---
title: ORDA Positive Pay review transcript
created: 2026-08-06
type: import
source: "[[07_Meetings/2026-07-22 Positive Pay review]]"
tags:
  - imported/teams
  - project/orda-positive-pay
---

Raw Teams transcript for the 2026-07-22 "Positive Pay review" kickoff meeting (Nathan Sawyer, Drew Kolaya). Graph API transcript access is disabled tenant-wide, so this was pasted manually from the Teams UI for archival — full text kept as-is, not summarized (summary already lives in [[07_Meetings/2026-07-22 Positive Pay review]]).

---

Nathan Sawyer 0 minutes 6 seconds
Um...
Nathan Sawyer 0 minutes 8 seconds
there within the app, the single application, there's different modules that perform different imports, or in the case of positive pay, which is less common, it's actually an export. But so these toolkit applications are
Nathan Sawyer 0 minutes 28 seconds
Generally the same amongst all of these customers with minor variations for their business logic needs. Oftentimes that's like the file is different. You know, it might be the same import process, but the file's different. Or they need certain...
Nathan Sawyer 0 minutes 47 seconds
validation or business logic check, you know, based on the data coming in or the data that needs to go out, what they want to see on the screen, these are manual imports. So there's a UI that people interact with, you know, multi-step, like upload the file, validate it.
Nathan Sawyer 1 minute 6 seconds
push it to intact, that kind of whole deal.
Nathan Sawyer 1 minute 11 seconds
So that's primarily the imports. Now, positive pay, and what you'll be focused on here, is actually an export. So what is positive pay? So positive pay is a process with the bank where
Nathan Sawyer 1 minute 31 seconds
checks, physical checks have been deposited not at a bank itself. They've been deposited through like an electronic check scanner on somebody's desk, say at the main office of whatever, you know, the customer. And positive pay
Nathan Sawyer 1 minute 51 seconds
is the terminology used primarily for a file that contains the list of check numbers and check information that you send to the bank to acknowledge these are the checks that I've
Nathan Sawyer 2 minutes 8 seconds
completed. It's like a secondary form of verification. Of course, when you scan a check and you receive funds, that goes to the bank in one way. This is like a separate way to like confirm. That's my understanding of it. Essentially, the positive pay process, as far as we are concerned, is we look for checks in intact.
Nathan Sawyer 41 minutes 41 seconds
That's what we've got. So your next steps would probably be just.
Nathan Sawyer 41 minutes 48 seconds
Work on digesting the core, and you know the CSAC project you'll probably have right alongside, you know, your your order project, you know, as you're developing it to to be able to look back and forth.
Nathan Sawyer 42 minutes 4 seconds
I'll work on maybe setting up a Monday board, I guess. I assume Patrick would like that.
Nathan Sawyer 42 minutes 13 seconds
And.
Nathan Sawyer 42 minutes 16 seconds
I'll take a look in a little more detail on that documentation for the file, just to see if I can.
Nathan Sawyer 42 minutes 23 seconds
to make that easier for you, just say this is the file versus having you sift through that 30 page document or whatever it is.
Nathan Sawyer 42 minutes 32 seconds
But.
Nathan Sawyer 42 minutes 34 seconds
Yeah, I mean, theoretically, I think...
Nathan Sawyer 42 minutes 37 seconds
We're at a point where I think we can split off and you can start digesting and maybe even make your repository, you know, kind of get that stuff started.
Drew Kolaya 42 minutes 49 seconds
Yeah, definitely.
Nathan Sawyer 42 minutes 52 seconds
Sweet.
Nathan Sawyer 42 minutes 55 seconds
All right, well, I'll stop Sharon.
Nathan Sawyer 43 minutes 1 second
Yeah, I think that's about it. I could have missed something, but you know, this is not the last time we'll meet and review stuff. So just let me know if you have any questions or want to meet on anything from here.
Drew Kolaya 43 minutes 11 seconds
Yeah.
Nathan Sawyer 43 minutes 13 seconds
Yeah, I'll work on a Monday board. Like all the others, you know, start super basic, like make repository, you know, whatever, you know, so we can get that started.
Drew Kolaya 43 minutes 21 seconds
Mhm.
Nathan Sawyer 43 minutes 27 seconds
But should be good to go, I think.
Nathan Sawyer 43 minutes 31 seconds
Oh yeah, as far as timing, you know, Patrick said, we've got plenty of time.
Nathan Sawyer 43 minutes 37 seconds
I wanted to backtrack a little bit. You know, I threw out an arbitrary timeline of a week. I don't, we don't need to attempt to adhere to anything like that.
Nathan Sawyer 43 minutes 49 seconds
But I just meant that more in the sense of like, we're not designing something from scratch here. You know, we're using a system that we already have and just.
Nathan Sawyer 43 minutes 59 seconds
doing that last 10, 20% specifically for Orta. So hopefully it's not as much effort as totally starting from scratch on something like this is more what I was intending to get at. But I do know also, you know, you've got today, tomorrow, and then you're off.
Drew Kolaya 44 minutes 11 seconds
Yeah.
Nathan Sawyer 44 minutes 18 seconds
for a week, right? Yeah.
Drew Kolaya 44 minutes 20 seconds
I am. There's a good chance that I won't really get much of anything done for this this week. And I'm probably going to forget most of it. That's why I wanted to record it so I could rewatch it when I come back.
Nathan Sawyer 44 minutes 26 seconds
Yep.
Nathan Sawyer 44 minutes 33 seconds
Yep. Nope, that's smart. Yeah. I had the same concern, but Patrick indicated that he wanted us to meet this week, so.
Drew Kolaya 44 minutes 41 seconds
Yeah.
Nathan Sawyer 44 minutes 43 seconds
Um...
Nathan Sawyer 44 minutes 45 seconds
So cool, that all makes sense to me.
Nathan Sawyer 44 minutes 49 seconds
Yeah, I may.
Nathan Sawyer 44 minutes 51 seconds
I may, it depends on timing. I may do some work on the positive pay stuff like those pages to get it more in line with the core.
Drew Kolaya 44 minutes 58 seconds
Mhm.
Nathan Sawyer 45 minutes 2 seconds
between now and when you're back from vacation. And if I do make any changes, of course, I'll let you know. We can review it together just so that you've got the latest. But.
Nathan Sawyer 45 minutes 16 seconds
We'll see if that actually happens.
Drew Kolaya 45 minutes 19 seconds
Yeah, no worries about that.
Nathan Sawyer 45 minutes 23 seconds
Cool. Okay. Yeah, I think we've got direction. I'll work on some Monday stuff and you can take a look at it or, you know, just work on the stuff you're working on this week. And then when you come back, you know, whatever you got to do. There's no...
Nathan Sawyer 45 minutes 39 seconds
The timeline is open. So we've got time. You know, I think as long as we get started on it, when you're back from your vacation, we'll be right on track with where we got to be. So.
Drew Kolaya 45 minutes 41 seconds
Yeah.
Drew Kolaya 45 minutes 51 seconds
Yeah, I'm not too worried about it.
Nathan Sawyer 45 minutes 55 seconds
Beep.
Drew Kolaya 45 minutes 57 seconds
Alright, see you in the afternoon then.
Nathan Sawyer 45 minutes 58 seconds
All right.
Nathan Sawyer 45 minutes 59 seconds
All right, sounds good, man. Talk to you later. Bye.
Drew Kolaya 46 minutes 1 second
Bye.
