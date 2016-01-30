module Danger
  class Local < Runner
    self.description = 'Run the Dangerfile locally.'
    self.command = 'local'

    def initialize(argv)
      @dangerfile_path = "Dangerfile" if File.exist? "Dangerfile"
      super
    end

    def validate!
      super
      unless @dangerfile_path
        help! "Could not find a Dangerfile."
      end
    end

    def run
      # The order of the following commands is *really* important
      dm = Dangerfile.new
      dm.env = EnvironmentManager.new(ENV)
      dm.env.ci_source = 
      dm.env.fill_environment_vars
      dm.env.scm.diff_for_folder(".", dm.env.ci_source.base_commit, dm.env.ci_source.head_commit)
      dm.parse Pathname.new(@dangerfile_path)

      post_results(dm)
    end

    def post_results(dm)
      gh = dm.env.request_source
      gh.update_pull_request!(warnings: dm.warnings, errors: dm.errors, messages: dm.messages)
    end
  end
end
