def run(cmd)
  puts "* Executing: #{cmd}"
  system cmd
  puts "* Done.\n\n"
end

namespace :pants do
  namespace :clone do
    desc "Copy production database into the local development environment."
    task :db do
      remote_dump_cmd  = "pg_dump --clean pants_production"
      local_import_cmd = "psql -U pants pants_development"

      run "ssh pants@pants-1.mans.de #{remote_dump_cmd} | #{local_import_cmd}"
    end
  end
end
