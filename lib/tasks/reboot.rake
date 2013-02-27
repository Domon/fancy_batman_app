namespace :db do
  desc "Drop, create, migrate, and seed your database."
  task :reboot => [:drop, :create, :migrate, :seed] do
    puts "Database rebooted"
  end
end