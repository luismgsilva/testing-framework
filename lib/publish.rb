module Publish
  def self.publish
    persistent_ws = DirManager.get_persistent_ws_path
    commit_msg_hash = {}
    status = JSON.parse(File.read(DirManager.get_status_file))

    tasks = Config.instance.tasks.keys
    tasks.select { |task| status[task.to_s] == 0 }.sort.each do |task|
      to_execute = Config.instance.publish_header(task)
      next if to_execute.nil?

      Helper.set_internal_vars(task)
      to_execute = VarManager.instance.prepare_data(to_execute)
      place_holder = {}

      Array(to_execute).each do |execute|
        output = Helper.return_execute(execute)
        unless $?.success?
          raise Ex::PublishCommandException.new(execute)
        end
        commit_msg = JSON.parse(output, symbolize_names: true)
        place_holder.merge!(commit_msg)
      end

      commit_msg_hash[task] = place_holder
    end

    GitManager.publish(JSON.pretty_generate(commit_msg_hash))
  end
end
