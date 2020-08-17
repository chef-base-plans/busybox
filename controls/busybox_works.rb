title 'Tests to confirm busybox works as expected'

plan_origin = ENV['HAB_ORIGIN']
plan_name = input('plan_name', value: 'busybox')

control 'core-plans-busybox-works' do
  impact 1.0
  title 'Ensure busybox works as expected'
  desc '
  Verify busybox by ensuring that
  (1) its installation directory exists 
  (2) it returns the expected version
  '
  
  plan_installation_directory = command("hab pkg path #{plan_origin}/#{plan_name}")
  describe plan_installation_directory do
    its('exit_status') { should eq 0 }
    its('stdout') { should_not be_empty }
    its('stderr') { should be_empty }
  end
  
  plan_pkg_version = plan_installation_directory.stdout.split("/")[5]
  ["head"].each do |binary_name|
    command_full_path = File.join(plan_installation_directory.stdout.strip, "bin", binary_name)
    describe command("#{command_full_path} --version") do
      its('exit_status') { should_not be 0 }
      its('stderr') { should_not be_empty }
      its('stderr') { should match /BusyBox v#{plan_pkg_version}/ }
      its('stdout') { should be_empty }
    end
  end

  ## DELETE THE FOLLOWING UNLESS REQUIRED
  # # (3) instmodsh and json_pp function as expected
  # #   instmodsh requires 'q' from stdin to quit
  # #   json_pp requires json input
  # #   pl2pm returns expected warning for a missing file
  # {
  #   "instmodsh" => {
  #     pattern: /List all installed modules/, 
  #     command_prefix: "echo 'q' | ",
  #     command_suffix: "--help",
  #     io: "stdout",
  #   },
  #   "json_pp" => {
  #     pattern: /key => \"value\"/, 
  #     command_prefix: "echo '{\"key\":\"value\"}' | ",
  #     command_suffix: "-f json -t dumper",
  #     io: "stdout",
  #   },
  #   "pl2pm" => {
  #     pattern: /Can't open file.that.does.not.exist: No such file or directory at \S+pl2pm line \d+/, 
  #     command_suffix: "file.that.does.not.exist",
  #     io: "stderr",
  #   },
  # }.each do |binary_name, value|
  #   command_full_path = File.join(plan_installation_directory.stdout.strip, "bin", binary_name)
  #   describe command("#{value[:command_prefix]} #{command_full_path} #{value[:command_suffix]}") do
  #     its(value[:io]) { should match value[:pattern] }
  #   end
  # end
end