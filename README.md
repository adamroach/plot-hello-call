# plot-hello-call

This is a very rudimentary script to plot the server logging for a hello call.
Note that these logs are only those produced by loop.services.mozilla.com

You'll need the following tools to use this:

* Callplot: http://sourceforge.net/projects/callplot/
* OmniGraffle: https://www.omnigroup.com/omnigraffle
* perl
* The following perl modules (available via CPAN):
** LWP::Simple
** HTTP::Request
** JSON

You also need access to the elasticsearch database that the server uses to log its data. If you don't know how to get this, then you probably aren't authorized to get to the logs. Sorry.

If you do have access, you'll need to create a file, called "userpass.txt", that contains your username on the first line and your password on the second.

You may also need to update graffle2img.scpt so that it uses the name of your Graffle program (for example, you may need to change "OmniGraffle Professional 5" to "OmniGraffle 6" depending on the version of program you have installed)

Once you have all that set up, you should be able to do:

  make [token].png

Where "[token]" is the token associated with the room you want to plot. If there's too much data, you can go in and edit the .cp file, and do the make again. If you want to re-fetch from the server, you'll need to delete all the associated files ("rm [token].*") and do a fresh make.
