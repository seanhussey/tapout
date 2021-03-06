require 'tapout/reporters/abstract'
require 'ansi/progressbar'

module Tapout

  module Reporters

    # The progress report format utilises a progress bar to indicate
    # elapsed progress.
    #
    class ProgressReporter < Abstract

      FAIL  = "FAIL".ansi(*Tapout.config.fail)
      ERROR = "ERROR".ansi(*Tapout.config.error)

      #
      def start_suite(entry)
        @pbar = ::ANSI::Progressbar.new('Testing', entry['count'].to_i + 1)
        @pbar.style(:bar=>[:invert, *config.pass])
        @pbar.inc

        @i = 0

        super(entry)
      end

      def start_case(entry)
      end

      #def test(entry)
      #  #@pbar.inc
      #end

      def pass(entry)
        @pbar.style(:bar=>config.pass)
        @pbar.inc
      end

      #
      def fail(test)
        @pbar.clear

        err = test['exception']

        label    = test['label'].to_s
        errclass = err['class']
        message  = err['message']
        trace    = backtrace_snippets(test)
        capture  = captured_output(err)

        parts = [errclass, message, trace, capture].compact.reject{ |x| x.strip.empty? }

        puts "#{@i+=1}. #{FAIL} #{label}"
        puts
        puts parts.join("\n\n").tabto(4)
        puts

        @pbar.style(:bar=>config.fail)
        @pbar.inc
      end

      #
      def error(test)
        @pbar.clear

        err = test['exception']

        label    = test['label'].to_s
        errclass = err['class']
        message  = err['message']
        trace    = backtrace_snippets(test)
        capture  = captured_output(err)

        parts = [errclass, message, trace, capture].compact.reject{ |x| x.strip.empty? }

        puts "#{@i+=1}. #{ERROR} #{label}"
        puts
        puts parts.join("\n\n").tabto(4)
        puts

        @pbar.style(:bar=>config.error)
        @pbar.inc
      end

      #
      def todo(entry)
        @pbar.style(:bar=>config.todo)
        @pbar.inc
      end

      #
      def omit(entry)
        @pbar.style(:bar=>config.omit)
        @pbar.inc
      end

      #def finish_case(kase)
      #end

      def finish_suite(entry)
        total, pass, fail, error, todo, omit = count_tally(entry)

        @pbar.style(:bar=>config.pass)  if pass > 0
        @pbar.style(:bar=>config.error) if error > 0
        @pbar.style(:bar=>config.fail)  if fail > 0
        @pbar.finish

        #post_report(entry)
        puts
        puts tally_message(entry)
      end

    end

  end

end




=begin
    def start_suite(suite)
      @pbar = ::ANSI::Progressbar.new('Testing', suite.size)
      @pbar.inc
    end

    #def start_case(kase)
    #end

    #def start_test(test)
    #end

    #def pass(message=nil)
    #  #@pbar.inc
    #end

    #def fail(message=nil)
    #  #@pbar.inc
    #end

    #def error(message=nil)
    #  #@pbar.inc
    #end

    def finish_case(kase)
      @pbar.inc
    end

    def finish_suite(suite)
      @pbar.finish
      post_report(suite)
    end

    #
    def post_report(suite)
      tally = test_tally(suite)

      width = suite.collect{ |tr| tr.name.size }.max

      headers = [ 'TESTCASE  ', '  TESTS   ', 'ASSERTIONS', ' FAILURES ', '  ERRORS   ' ]
      io.puts "\n%-#{width}s       %10s %10s %10s %10s\n" % headers

      files = nil

      suite.each do |testrun|
        if testrun.files != [testrun.name] && testrun.files != files
          label = testrun.files.join(' ')
          label = Colorize.magenta(label)
          io.puts(label + "\n")
          files = testrun.files
        end
        io.puts paint_line(testrun, width)
      end

      #puts("\n%i tests, %i assertions, %i failures, %i errors\n\n" % tally)

      tally_line = "-----\n"
      tally_line << "%-#{width}s  " % "TOTAL"
      tally_line << "%10s %10s %10s %10s" % tally

      io.puts(tally_line + "\n")

      fails = suite.select do |testrun|
        testrun.fail? || testrun.error?
      end

      #if tally[2] != 0 or tally[3] != 0
        unless fails.empty? # or verbose?
          io.puts "\n\n-- Failures and Errors --\n\n"
          fails.uniq.each do |testrun|
            message = testrun.message.tabto(0).strip
            message = Colorize.red(message)
            io.puts(message+"\n\n")
          end
          io.puts
        end
      #end
    end

  private

    def paint_line(testrun, width)
      line = ''
      line << "%-#{width}s  " % [testrun.name]
      line << "%10s %10s %10s %10s" % testrun.counts
      line << " " * 8
      if testrun.fail?
        line << "[#{FAIL}]"
      elsif testrun.error?
        line << "[#{FAIL}]"
      else
        line << "[#{PASS}]"
      end
      line
    end

    def test_tally(suite)
      counts = suite.collect{ |tr| tr.counts }
      tally  = [0,0,0,0]
      counts.each do |count|
        4.times{ |i| tally[i] += count[i] }
      end
      return tally
    end

  end

=end

