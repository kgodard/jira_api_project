class JiraReportCli
  attr_reader :options, :parser, :status_hash

  def initialize(args)
    @options = ScriptOptions.new
    @status_hash = init_status_hash

    parse_args(args)
    do_misc
    do_report
  end

  def parse_args(args)
    option_parser.parse!(args)
  rescue OptionParser::InvalidOption
    puts "Invalid option given"
    puts ""
    puts parser
    exit
  end

  def option_parser
    @parser ||= OptionParser.new do |parser|
      parser.banner = "Usage: jrp [options]"
      parser.separator ""
      parser.separator "Specific options:"

      parser.on("-c", "--show-cycle-time", "show cycle time in report table") do
        options.show_cycle_time = true
      end

      parser.on("-p", "--parents PARENTS", "only return issues with specified parents, ex: -p CQC-555,CQC-123") do |parents|
        options.parents = parents
      end

      parser.on("-s", "--statuses STATUSES", "only return issues with specified statuses (0-5) ex: -s 345") do |statuses|
        options.statuses = statuses
      end

      parser.on("-z", "--show-statuses", "show all possible issue statuses (column names)") do
        options.show_statuses = true
      end

      parser.separator ""
      parser.separator "Common options:"

      parser.on_tail("-h", "--help", "Show this message") do
        puts parser
        exit
      end
    end
  end

  def show_statuses
    puts "Possible issue statuses are:"
    puts ""
    status_hash.each do |k,v|
      puts "#{k} - #{v}"
    end
  end

  def init_status_hash
    sthsh = {}
    JiraSearch::STATUSES.each_with_index do |status, idx|
      sthsh[idx] = status
    end
    sthsh
  end

  def do_misc
    show_statuses if options.show_statuses
  end

  def do_report
    return if options.show_statuses

    search = JiraSearch.new(statuses: get_statuses, created_time: "-16w", only_parents: get_parents)
    cycle_times_reporter = JiraCycleTimesReporter.new(search, upto: highest_status)
    reporter = JiraReporter.new(search.issues)
    puts ""
    cycle_times_reporter.render
    puts ""
    reporter.report(sort_by: "start_time", show_cycle_time: options.show_cycle_time)
  end

  def get_parents
    if options.parents
      options.parents.split(",")
    else
      nil
    end
  end

  def highest_status
    get_statuses.last
  end

  def get_statuses
    if options.statuses
      options.statuses.split("").sort.map do |num|
        status_hash[num.to_i]
      end
    else
      default_statuses
    end
  end

  def default_statuses
    ["In Testing", "Ready for Deployment", "Done"]
  end
end
