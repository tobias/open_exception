open_exception
==============

open_exception opens an exception in your favorite editor when developing locally. It
works by parsing the backtrace, and opening the offending file at the offending line 
in your favorite editor (assuming your favorite editor supports remote open commands).

You can add filters that allow you to ignore some exceptions, and filters that allow you 
to scope the backtrace search. The backtrace scoping is useful for opening the last call
in your application code when the exception occurs in a framework or lib.

Editors
-------

Out if the box, the gem supports three editors (with the following open commands):

    :emacs => '/usr/bin/emacsclient -n +{line} {file}',
    :textmate => '/usr/local/bin/mate -a -d -l {line} {file}',
    :macvim => '/usr/local/bin/mvim +{line} {file}'

Any of these will open the file and set focus on the editor. `:emacs` is the default.

If you are using emacs, you can also open the backtrace along with the file using `:emacs_with_trace` as the `:open_with` argument. This uses: 
    /usr/bin/emacsclient -e '(open-trace-and-file "{tracefile}" "{file}" {line})'
as the open command. To use this, you will need to add the following function to your emacs init:

    (defun open-trace-and-file (tracefile file linenum)
      "Visits TRACEFILE in one window (in compilation mode), and visit FILE at LINENUM in another"
      (find-file-other-window tracefile)
      (goto-line 2)
      (compilation-mode)
      (find-file-other-window file)
      (goto-line linenum))

This will open the backtrace in a compilation buffer, making it easy to navigate to other files in the trace.

If using `(open-trace-and-file)`, emacs will *not* take focus - you will need to switch to it manually. 

Note: for `emacsclient` to work, you will need to be running `emacsserver`. To start the server:
    M-x server-start
or add the following to your init:
    (server-start)

Configuration
-------------

To configure, pass a block to the configure method:
    
    OpenException.configure do |oe|
      # open_with can be one of the built in editors (:emacs, :emacs_with_trace, :macvim, :textmate)
      # or a command to execute to open the file, where {file}, {line}, and {tracefile} will be replaced
      # with the file path, line number, and path to tmp file holding the backtrace, respectively. See 'Editors' above for an example.
      # The default editor is :emacs.

      oe.open_with = :emacs

      # you can add exclusion filters to ignore exceptions. A filter can be an exception class to 
      # ignore, or a proc that is passed the exception, and should evaluate to true if the exception 
      # should be ignored. Be careful with using a class - it uses is_a?, so any subclasses of the
      # passed class will be ignored as well. The list of filters is [] by default.

      oe.exclusion_filters << SomeErrorClass
      oe.exclusion_filters << lambda { |exception| true if exception_should_be_excluded }

      # you can scope the search for the file:line to open with a filter as well. A filter can be a 
      # regular expression that is matched against the line, or a proc that is passed the line and 
      # should evaluate to true if the line should be used. The first line that any filter passes for 
      # will be the file:line that is opened. This is useful for opening the point in the stack just
      # before control passes out of your app code when the exception occurs in an external 
      # lib/framework. The list of filters is [] by default. 

      oe.backtrace_line_filters << %r{/app/root/(app|lib)} 
      oe.backtrace_line_filters << lambda { |backtrace_line| true if line_should_be_used }

    end


Rails Integration
-----------------

The gem also alias chains in to rails' `ActionController#rescue_action_locally` method to automatically
open exceptions in development mode. The gem also adds the following filter to the `:backtrace_line_filters` to scope the opened files to the app:

    %r{#{Rails.root}/(app|lib)}

To replace or remove this filter, you will need to reset the `:backtrace_line_filters` in your configure 
block: 
    OpenException.configure do |oe|
      oe.backtrace_line_filters = []
      oe.backtrace_line_filters << my_new_filter
    end

This has been tested with rails v2.3.5, but should work fine with 2.1 <= rails < 3. It may work with
rails 3 as well, I just haven't yet looked at rails 3.

Standalone/Other Frameworks
---------------------------

To manually open an exception, or wire it up in another framework, you call:

    OpenException.open(exception)

You can override the default (or configured) options by passing a hash as the second arg:

    OpenException.open(exception, {:open_with => :textmate, :backtrace_line_filters => [filter, another_filter])

Growl Support
-------------

If you are on MacOSX and have the [growl gem](http://rubygems.org/gems/growl) installed,
you will get a growl notification with the exception message when the file is opened.

Note that growlnotify currently has to be in the path for this to work until the growl gem 
is fixed to look in the default location and/or allow overriding the binary location.

Note on Patches/Pull Requests
-----------------------------
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Commit, do not mess with rakefile, version, or history. (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.


Copyright (c) 2010 Tobias Crawley. See LICENSE for details.
