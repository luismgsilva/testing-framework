require 'json'
def find_versions(prefix, source_dir, build_name)
      tools = ["gcc", "binutils-gdb", "glibc", "newlib"]
      Dir.chdir source_dir
      main_hash = `cd #{source_dir} ; git log -1 --format=format:"%H"`
      
      main_tool = source_dir.split("/")[-1]
      config = {}
      config.store("build_name", build_name)
      config.store("build_date", `date +"%Y-%m-%d %T"`.chomp)
      config.store(main_tool, main_hash)

      tools.each do |tool|
        next if !File.directory? "#{source_dir}/#{tool}"
        hash = `cd #{source_dir}/#{tool} ; git log -1 --format=format:"%H"`
        next if hash == main_hash
        config.store(tool, hash)
      end
      File.write("#{prefix}/versions.json", JSON.pretty_generate(config))
    end

find_versions(ARGV[0], ARGV[1], ARGV[2])
